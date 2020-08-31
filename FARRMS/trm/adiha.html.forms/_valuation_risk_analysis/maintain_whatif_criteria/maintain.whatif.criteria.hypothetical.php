<?php
/**
* Maintain whatif criteria hypothetical screen
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
    
	$whatif_criteria_other_id = get_sanitized_value($_GET['whatif_criteria_other_id']);
	$criteria_id = get_sanitized_value($_GET['criteria_id']);
	$form_name = 'form_hypothetical';
    $namespace = 'popup_hypotheical';
	
	$rights_maintain_whatif_criteria_hypothetical = 10183414;
    $rights_maintain_whatif_criteria_hypothetical_del = 10183415;
	
	  list(
        $has_rights_maintain_whatif_criteria_hypothetical,
        $has_rights_maintain_whatif_criteria_hypothetical_del
    ) = build_security_rights (
        $rights_maintain_whatif_criteria_hypothetical,
        $rights_maintain_whatif_criteria_hypothetical_del
    );
    

	$layout_json = '[
                        {
                            id:             "a",
                            text:           "Hypothetical",
                            header:         true,
                            fix_size:       [false,null] 
                        }
                    ]';

    $layout_hypothetical = new AdihaLayout();

    echo $layout_hypothetical	->	init_layout('popup_win_hypothetical', '', '1C', $layout_json, $namespace);
    echo $layout_hypothetical	->	hide_header('a');

    $form_object = new AdihaForm();

	$menu_json_hypothetical = "[{
		id:'save', text:'Save', img:'save.gif', title:'Save' ,enabled:".$has_rights_maintain_whatif_criteria_hypothetical."
	}]";  

	$menu_obj_hypothetical = new AdihaMenu();

	echo $layout_hypothetical	->	attach_menu_cell("menu_ok_hypothetical", "a");
	echo $menu_obj_hypothetical ->	init_by_attach("menu_ok_hypothetical", $namespace);
	echo $menu_obj_hypothetical ->	load_menu($menu_json_hypothetical);
	echo $menu_obj_hypothetical ->	attach_event('', 'onClick', 'on_ok_btn_click');

	//Dropdown options
	//Sub book
	$spa_sub_book = "EXEC spa_get_source_book_map @flag='z',@function_id=10183400";
	echo "var combo_option_sub_book = ". $form_object->adiha_form_dropdown($spa_sub_book, 0, 1). ";"."\n";
	
	//template
	$spa_template = "EXEC spa_getDealTemplate @flag='s'";
	echo "var combo_option_template = ". $form_object->adiha_form_dropdown($spa_template, 0, 1). ";"."\n";
	
	//Counterparty
	$spa_counterparty = "EXEC spa_source_counterparty_maintain 'c'";
	echo "var combo_option_counterparty = ". $form_object->adiha_form_dropdown($spa_counterparty, 0, 1, false, '', 2). ";"."\n";

	//Market Index Buy sell
	$spa_market_price_buy_sell = "EXEC spa_source_price_curve_def_maintain 'l'";
	echo "var combo_option_mibs = ". $form_object->adiha_form_dropdown($spa_market_price_buy_sell, 0, 1, false, '', 2). ";"."\n";

	//Pricing Index Buy sell
	$spa_pricing_index_buy_sell = "EXEC spa_source_price_curve_def_maintain 'l'";
	echo "var combo_option_mib = ". $form_object->adiha_form_dropdown($spa_pricing_index_buy_sell, 0, 1, true, '', 2). ";"."\n";

	//Block Definition
	$spa_block_definition = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 10018";
	echo "var combo_option_block_definition = ". $form_object->adiha_form_dropdown($spa_block_definition, 0, 1, true, '', 2). ";"."\n";
	//Market Index
	$spa_market_index = "EXEC spa_source_price_curve_def_maintain @flag='l'";
	echo "var combo_option_market = ". $form_object->adiha_form_dropdown($spa_market_index, 0, 1, false, '', 2). ";"."\n";
	//Pricing Index
	$spa_market_index_price = "EXEC spa_source_price_curve_def_maintain @flag='l'";
	echo "var combo_option_market_price = ". $form_object->adiha_form_dropdown($spa_market_index_price, 0, 1, true, '', 2). ";"."\n";
	//Currency
	$spa_currency = "EXEC spa_source_currency_maintain 'b'";
	echo "var combo_option_currency = ". $form_object->adiha_form_dropdown($spa_currency, 0, 1, true, '', 2). ";"."\n";
	//Volume Frequency 
	$spa_volume_frequency = "EXEC spa_getVolumeFrequency NULL, 'a,x,y'";
	echo "var combo_option_volume_frequency = ". $form_object->adiha_form_dropdown($spa_volume_frequency, 0, 1). ";"."\n";
	//UOM
	$spa_uom = "EXEC spa_source_uom_maintain 's'";
	echo "var combo_option_uom = ". $form_object->adiha_form_dropdown($spa_uom, 0, 1, false, '', 2). ";"."\n";
	
	$form_json_hypothetical = "[
	{type:'settings'},
	{type: 'combo', name: 'sub_book','filtering':'true', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Sub Book', required: 'true', options: combo_option_sub_book, width: 200, position: 'absolute', labelLeft: 10, labelTop: 30, inputLeft: 150, inputTop: 30},
	
	{type: 'combo', name: 'counterparty','filtering':'true', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Counterparty', required: 'true', options: combo_option_counterparty, width: 200, position: 'absolute', labelLeft: 10, labelTop: 70, inputLeft: 150, inputTop: 70},
	
	{type: 'checkbox', name: 'buy', label: 'Buy', labelAlign: 'right', value: 'buy', width: 200, position: 'absolute', labelLeft: 10, labelTop: 110, inputLeft: 150, inputTop: 110, checked: true},

	{type: 'combo', name: 'market_index_buy','filtering':'true', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Market Index', required: 'true', options: combo_option_mibs, width: 200, position: 'absolute', labelLeft: 10, labelTop: 150, inputLeft: 150, inputTop: 150},
	{type: 'numeric', name: 'price_buy', label: 'Price', width: 200, required: 'false', position: 'absolute', labelLeft: 10, labelTop: 190, inputLeft: 150, inputTop: 190, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Number'}},
	{type: 'combo', name: 'pricing_index_buy','filtering':'true', label: 'Pricing Index', required: 'false', options: combo_option_mib, width: 200, position: 'absolute', labelLeft: 10, labelTop: 230, inputLeft: 150, inputTop: 230, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Selection'}},
	{type: 'combo', name: 'currency_buy','filtering':'true', label: 'Currency', required: 'false', options: combo_option_currency, width: 200, position: 'absolute', labelLeft: 10, labelTop: 270, inputLeft: 150, inputTop: 270, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Selection'}},
	{type: 'numeric', name: 'volume_buy', validate:'NotEmpty', userdata:{validation_message:'Invalid Numbers'},validate: 'ValidNumeric', label: 'Volume', width: 200, required: 'true', position: 'absolute', labelLeft: 10, labelTop: 310, inputLeft: 150, inputTop: 310},
	{type: 'combo', name: 'uom_buy','filtering':'true', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'UOM', required: 'true', options: combo_option_uom, width: 200, position: 'absolute', labelLeft: 10, labelTop: 350, inputLeft: 150, inputTop: 350},
	{type: 'combo', name: 'volume_frequency_buy','filtering':'true', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Volume Frequency', required: 'true', options: combo_option_volume_frequency, width: 200, position: 'absolute', labelLeft: 10, labelTop: 390, inputLeft: 150, inputTop: 390},
	{type: 'numeric', name: 'total_volume_buy', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Total Volume', width: 200, required: 'false', position: 'absolute', labelLeft: 10, labelTop: 430, inputLeft: 150, inputTop: 430, disabled: true},
	
	{type: 'calendar', name: 'term_start_buy', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Term Start', serverDateFormat:'%Y-%m-%d', required: 'true', width: 200, position: 'absolute', labelLeft: 10, labelTop: 470, inputLeft: 150, inputTop: 470},
	{type: 'calendar', name: 'term_end_buy', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Term End', serverDateFormat:'%Y-%m-%d', required: 'true', width: 200, position: 'absolute', labelLeft: 10, labelTop: 510, inputLeft: 150, inputTop: 510},
	
	{type: 'newcolumn', offset: 20},
	
	{type: 'combo', name: 'template','filtering':'true', label: 'Template', required: 'true', options: combo_option_template, width: 200, position: 'absolute', labelLeft: 380, labelTop: 30, inputLeft: 510, inputTop: 30, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Selection'}},

	{type: 'combo', name: 'block_definition','filtering':'true', label: 'Block Definition', required: 'false', options: combo_option_block_definition, width: 200, position: 'absolute', labelLeft: 380, labelTop: 70, inputLeft: 510, inputTop: 70, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Selection'}},

	{type: 'checkbox', name: 'sell', label: 'Sell', labelAlign: 'right', value: 'sell', position: 'absolute', labelLeft: 380, labelTop: 110, inputLeft: 510, inputTop: 110, checked: true},

	{type: 'combo', name: 'market_index_sell','filtering':'true', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Market Index', required: 'true', options: combo_option_mibs, width: 200, position: 'absolute', labelLeft: 380, labelTop: 150, inputLeft: 510, inputTop: 150},
	{type: 'numeric', name: 'price_sell', label: 'Price', width: 200, required: 'false', position: 'absolute', labelLeft: 380, labelTop: 190, inputLeft: 510, inputTop: 190, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Number'}},
	{type: 'combo', name: 'pricing_index_sell','filtering':'true', label: 'Pricing Index', required: 'false', options: combo_option_mib, width: 200, position: 'absolute', labelLeft: 380, labelTop: 230, inputLeft: 510, inputTop: 230, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Selection'}},
	{type: 'combo', name: 'currency_sell','filtering':'true', label: 'Currency', required: 'false', options: combo_option_currency, width: 200, position: 'absolute', labelLeft: 380, labelTop: 270, inputLeft: 510, inputTop: 270, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Selection'}},
	{type: 'numeric', name: 'volume_sell', validate:'NotEmpty', userdata:{validation_message:'Invalid Numbers'},validate: 'ValidNumeric', label: 'Volume', width: 200, required: 'true', position: 'absolute', labelLeft: 380, labelTop: 310, inputLeft: 510, inputTop: 310},
	{type: 'combo', name: 'uom_sell','filtering':'true', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'UOM', required: 'true', options: combo_option_uom, width: 200, position: 'absolute', labelLeft: 380, labelTop: 350, inputLeft: 510, inputTop: 350},
	{type: 'combo', name: 'volume_frequency_sell','filtering':'true', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Volume Frequency', required: 'true', options: combo_option_volume_frequency, width: 200, position: 'absolute', labelLeft: 380, labelTop: 390, inputLeft: 510, inputTop: 390},
	{type: 'numeric', name: 'total_volume_sell', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Total Volume', width: 200, required: 'false', position: 'absolute', labelLeft: 380, labelTop: 430, inputLeft: 510, inputTop: 430, disabled: true},
	{type: 'calendar', name: 'term_start_sell', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Term Start', serverDateFormat:'%Y-%m-%d', required: 'true', width: 200, position: 'absolute', labelLeft: 380, labelTop: 470, inputLeft: 510, inputTop: 470},
	{type: 'calendar', name: 'term_end_sell', validate:'NotEmpty', userdata:{validation_message:'Required Field'}, label: 'Term End', serverDateFormat:'%Y-%m-%d', required: 'true', width: 200, position: 'absolute', labelLeft: 380, labelTop: 510, inputLeft: 510, inputTop: 510}
	
	]";

    echo $layout_hypothetical -> attach_form ($form_name, 'a');    
    echo $form_object		  -> init_by_attach ($form_name, $namespace);
    echo $form_object		  -> load_form ($form_json_hypothetical);
    echo $form_object		  -> attach_event ('', 'onChange', 'on_checkbox_changed');

    echo $layout_hypothetical -> close_layout();
?>

<script>
	var whatif_criteria_other_id = '<?php echo $whatif_criteria_other_id; ?>';
	var has_rights_maintain_whatif_criteria_hypothetical =<?php echo (($has_rights_maintain_whatif_criteria_hypothetical) ? $has_rights_maintain_whatif_criteria_hypothetical : '0'); ?>;
    var has_rights_maintain_whatif_criteria_hypothetical_del =<?php echo (($has_rights_maintain_whatif_criteria_hypothetical_del) ? $has_rights_maintain_whatif_criteria_hypothetical_del : '0'); ?>;
	var criteria_id = '<?php echo $criteria_id; ?>';
		
	$(function(){
		//load data in update mode
		var data = {
						"action": "spa_maintain_criteria_dhx", 
						"flag": "a", 
						"whatif_criteria_other_id": whatif_criteria_other_id
					};

		adiha_post_data('return_array', data, '', '', 'load_criteria_other_data', '');
	})

	load_criteria_other_data = function(response_data) {
		var sub_book = response_data[0][0];
		var template = response_data[0][1];
		var block_definition = response_data[0][3];
		var counterparty = response_data[0][2];
		var buy = (response_data[0][4] == 'y') ? true : false;
		var market_index_buy = response_data[0][5];
		var price_buy = response_data[0][6];
		var pricing_index_buy = response_data[0][7];
		var currency_buy = response_data[0][8];
		var volume_buy = response_data[0][9];
		var total_volume_buy = response_data[0][10];
		var volume_frequency_buy = response_data[0][11];
		var uom_buy = response_data[0][12];		
		var sell = (response_data[0][15] == 'y') ? true : false;
		var market_index_sell = response_data[0][16];
		var price_sell = response_data[0][17];
		var pricing_index_sell = response_data[0][18];
		var currency_sell = response_data[0][19];
		var volume_sell = response_data[0][20];
		var total_volume_sell = response_data[0][21];
		var volume_frequency_sell = response_data[0][22];
		var uom_sell = response_data[0][23];
		var term_start_buy = response_data[0][13];
		var term_end_buy = response_data[0][14];
		var term_start_sell = response_data[0][24];
		var term_end_sell = response_data[0][25]
	
		popup_hypotheical.form_hypothetical.setFormData({                      
			sub_book: sub_book,
			template: template,
			counterparty: counterparty,
			buy: buy,
			market_index_buy: market_index_buy,
			price_buy: price_buy,
			pricing_index_buy: pricing_index_buy,
			currency_buy: currency_buy,
			volume_buy: volume_buy,
			total_volume_buy: total_volume_buy,
			volume_frequency_buy: volume_frequency_buy,
			uom_buy: uom_buy,
			block_definition: block_definition,
			sell: sell,
			market_index_sell: market_index_sell,
			price_sell: price_sell,
			pricing_index_sell: pricing_index_sell,
			currency_sell: currency_sell,
			volume_sell: volume_sell,
			total_volume_sell: total_volume_sell,
			volume_frequency_sell: volume_frequency_sell,
			uom_sell: uom_sell,
			term_start_buy: term_start_buy,
			term_end_buy: term_end_buy,
			term_start_sell: term_start_sell,
			term_end_sell: term_end_sell
		});
		
		on_checkbox_changed('buy', '', buy);
		on_checkbox_changed('sell', '', sell);
	}

	function on_checkbox_changed ( name, value, status ) { 	
		// if (name == 'market_index_buy') {
		// 	name = 'buy';
		// 	status = true;
		// }	
		
		// if (name == 'market_index_sell') {
		// 	name = 'sell';
		// 	status = true;
		// }

		if ( name == 'buy' && !status ) { 
			popup_hypotheical.form_hypothetical.disableItem ('pricing_index_buy');
			popup_hypotheical.form_hypothetical.disableItem ('market_index_buy');
			popup_hypotheical.form_hypothetical.disableItem ('price_buy');
			popup_hypotheical.form_hypothetical.disableItem ('pricing_index_buy');
			popup_hypotheical.form_hypothetical.disableItem ('currency_buy');
			popup_hypotheical.form_hypothetical.disableItem ('volume_buy');
			popup_hypotheical.form_hypothetical.disableItem ('volume_frequency_buy');
			popup_hypotheical.form_hypothetical.disableItem ('uom_buy');
	 		popup_hypotheical.form_hypothetical.disableItem ('term_start_buy');
			popup_hypotheical.form_hypothetical.disableItem ('term_end_buy'); 

			// empty the field when disabled
			popup_hypotheical.form_hypothetical.setItemValue ('price_buy', '');
			popup_hypotheical.form_hypothetical.setItemValue ('pricing_index_buy', '');
			popup_hypotheical.form_hypothetical.setItemValue ('currency_buy', '');
			popup_hypotheical.form_hypothetical.setItemValue ('volume_buy', ''); 
			popup_hypotheical.form_hypothetical.setItemValue ('term_start_buy', ''); 
			popup_hypotheical.form_hypothetical.setItemValue ('term_end_buy', ''); 

			var combo1 = popup_hypotheical.form_hypothetical.getCombo('market_index_buy');
			combo1.addOption([
			    ["",""],
			]);
			popup_hypotheical.form_hypothetical.setItemValue ('market_index_buy', ''); //Market Index

			var combo2 = popup_hypotheical.form_hypothetical.getCombo('uom_buy');
			combo2.addOption([
			    ["",""],
			]);
			popup_hypotheical.form_hypothetical.setItemValue ('uom_buy', ''); //UOM

			var combo3 = popup_hypotheical.form_hypothetical.getCombo('volume_frequency_buy');
			combo3.addOption([
			    ["",""],
			]);
			popup_hypotheical.form_hypothetical.setItemValue ('volume_frequency_buy', ''); // Volume Frequency

		 } else if ( name == 'buy' && status ) {
			popup_hypotheical.form_hypothetical.enableItem ('market_index_buy');
			popup_hypotheical.form_hypothetical.enableItem ('price_buy');
			popup_hypotheical.form_hypothetical.enableItem ('pricing_index_buy');
			popup_hypotheical.form_hypothetical.enableItem ('currency_buy');
			popup_hypotheical.form_hypothetical.enableItem ('volume_buy');
			popup_hypotheical.form_hypothetical.enableItem ('volume_frequency_buy');
			popup_hypotheical.form_hypothetical.enableItem ('uom_buy');
			popup_hypotheical.form_hypothetical.enableItem ('term_start_buy');
			popup_hypotheical.form_hypothetical.enableItem ('term_end_buy');

			var combo1 = popup_hypotheical.form_hypothetical.getCombo('market_index_buy');
			var combo1_index = combo1.getIndexByValue('');
			if (combo1_index > 0) {
				combo1.deleteOption('');
				combo1.selectOption(0);
			}

			var combo2 = popup_hypotheical.form_hypothetical.getCombo('uom_buy');
			var combo2_index = combo2.getIndexByValue('');
			if (combo2_index > 0) {
				combo2.deleteOption('');
				combo2.selectOption(0);
			}

			var combo3 = popup_hypotheical.form_hypothetical.getCombo('volume_frequency_buy');
			var combo3_index = combo3.getIndexByValue('');
			if (combo3_index > 0) {
				combo3.deleteOption('');
				combo3.selectOption(0);
			}

		} else	if ( name == 'sell' && !status ) { 
			popup_hypotheical.form_hypothetical.disableItem ('market_index_sell');
			popup_hypotheical.form_hypothetical.disableItem ('price_sell');
			popup_hypotheical.form_hypothetical.disableItem ('pricing_index_sell');
			popup_hypotheical.form_hypothetical.disableItem ('currency_sell');
			popup_hypotheical.form_hypothetical.disableItem ('volume_sell');
			popup_hypotheical.form_hypothetical.disableItem ('volume_frequency_sell');
			popup_hypotheical.form_hypothetical.disableItem ('uom_sell');
			popup_hypotheical.form_hypothetical.disableItem ('term_start_sell');
			popup_hypotheical.form_hypothetical.disableItem ('term_end_sell');
	
			// empty the field when disabled
			popup_hypotheical.form_hypothetical.setItemValue ('price_sell', '');
			popup_hypotheical.form_hypothetical.setItemValue ('pricing_index_sell', '');
			popup_hypotheical.form_hypothetical.setItemValue ('currency_sell', '');
			popup_hypotheical.form_hypothetical.setItemValue ('volume_sell', ''); 
			popup_hypotheical.form_hypothetical.setItemValue ('term_start_sell', ''); 
			popup_hypotheical.form_hypothetical.setItemValue ('term_end_sell', ''); 

			var combo1 = popup_hypotheical.form_hypothetical.getCombo('market_index_sell');
			combo1.addOption([
			    ["",""],
			]);
			popup_hypotheical.form_hypothetical.setItemValue ('market_index_sell', ''); //Market Index

			var combo2 = popup_hypotheical.form_hypothetical.getCombo('uom_sell');
			combo2.addOption([
			    ["",""],
			]);
			popup_hypotheical.form_hypothetical.setItemValue ('uom_sell', ''); //UOM

			var combo3 = popup_hypotheical.form_hypothetical.getCombo('volume_frequency_sell');
			combo3.addOption([
			    ["",""],
			]);
			popup_hypotheical.form_hypothetical.setItemValue ('volume_frequency_sell', ''); // Volume Frequency

		} else if ( name == 'sell' && status ) {
			popup_hypotheical.form_hypothetical.enableItem ('market_index_sell');
			popup_hypotheical.form_hypothetical.enableItem ('price_sell');
			popup_hypotheical.form_hypothetical.enableItem ('pricing_index_sell');
			popup_hypotheical.form_hypothetical.enableItem ('currency_sell');
			popup_hypotheical.form_hypothetical.enableItem ('volume_sell');
			popup_hypotheical.form_hypothetical.enableItem ('volume_frequency_sell');
			popup_hypotheical.form_hypothetical.enableItem ('uom_sell');
			popup_hypotheical.form_hypothetical.enableItem ('term_start_sell');
			popup_hypotheical.form_hypothetical.enableItem ('term_end_sell');

			
			var combo1 = popup_hypotheical.form_hypothetical.getCombo('market_index_sell');
			var combo1_index = combo1.getIndexByValue('');
			if (combo1_index > 0) {
				combo1.deleteOption('');
				combo1.selectOption(0);
			}

			var combo2 = popup_hypotheical.form_hypothetical.getCombo('uom_sell');
			var combo2_index = combo2.getIndexByValue('');
			if (combo2_index > 0) {
				combo2.deleteOption('');
				combo2.selectOption(0);
			}

			var combo3 = popup_hypotheical.form_hypothetical.getCombo('volume_frequency_sell');
			var combo3_index = combo3.getIndexByValue('');
			if (combo3_index > 0) {
				combo3.deleteOption('');
				combo3.selectOption(0);
			}
		}
		
	}

	function on_ok_btn_click () {
		var status = validate_form(popup_hypotheical.form_hypothetical);
		if (status == false) {
			generate_error_message();
			return;
		}
		
		var buy_chk = popup_hypotheical.form_hypothetical.isItemChecked('buy');
		var sell_chk = popup_hypotheical.form_hypothetical.isItemChecked('sell');
		
		if (buy_chk == false && sell_chk == false) {
			show_messagebox('Please check either buy or sell.');
			return;
		} 
		//
		var term_start_buy = popup_hypotheical.form_hypothetical.getItemValue('term_start_buy');
		var term_end_buy = popup_hypotheical.form_hypothetical.getItemValue('term_end_buy');

		if (term_start_buy > term_end_buy) {
			show_messagebox("<b>Term End</b> should be greater than <b>Term Start</b>.");
            return false;
		}
		
		var term_start_sell = popup_hypotheical.form_hypothetical.getItemValue('term_start_sell');
		var term_end_sell = popup_hypotheical.form_hypothetical.getItemValue('term_end_sell');

		if (term_start_sell > term_end_sell) {
			show_messagebox("<b>Term End</b> should be greater than <b>Term Start</b>.");
            return false;
		}
		//
		var criteria_other_xml = '<Root><CriteriaOther whatif_criteria_other_id="' + whatif_criteria_other_id + '" ';
		data = popup_hypotheical.form_hypothetical.getFormData();
		
		var field_value;
		popup_hypotheical.form_hypothetical.forEachItem( function ( name ) {
			if ( name == 'term_start_buy' || name == 'term_start_sell' || name == 'term_end_buy' || name == 'term_end_sell' ) {
				field_value = popup_hypotheical.form_hypothetical.getItemValue(name, true);
			} else if (name == 'buy' || name == 'sell') {
				field_value = (popup_hypotheical.form_hypothetical.isItemChecked(name) == 1) ? 'y' : 'n';
			} else {
				field_value = popup_hypotheical.form_hypothetical.getItemValue(name);
			}

			criteria_other_xml += " " + name + "=\"" + field_value + "\"";
		});
		criteria_other_xml += '/></Root>'

		var data = {
						"action": "spa_maintain_criteria_dhx",
						"flag": "w",
						"criteria_other_xml": criteria_other_xml,
						"criteria_id": criteria_id
					};

		adiha_post_data('return_json', data, '', '', 'ok_callback', '');
	}
	
	function ok_callback(result) {
		var return_data = JSON.parse(result);
		
		if (return_data[0].errorcode == 'Success') {
			dhtmlx.message({
                text:return_data[0].message,
                expire:1000
            });
			
			
			if (return_data[0].recommendation != '') {
				return_value = return_data[0].recommendation.split(',');
				whatif_criteria_other_id = return_value[0];
				popup_hypotheical.form_hypothetical.setItemValue('total_volume_buy', return_value[1]);
				popup_hypotheical.form_hypothetical.setItemValue('total_volume_sell', return_value[2]);
				
			}
		} else {
			dhtmlx.message({
				type: "alert-error",
				title: "Error",
				text: return_data[0].message
			});
		}
	}
</script>
</body>
</html>