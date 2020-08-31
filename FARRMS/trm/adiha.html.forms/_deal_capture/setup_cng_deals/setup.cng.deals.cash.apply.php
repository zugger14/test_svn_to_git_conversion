<!DOCTYPE html>
<html> 
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>

<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_setup_cng_deal_cash_apply';
    $name_space = 'setup_cng_deal_cash_apply';
    $rights_setup_cng_deals_iu = 10132312;
    $today_date = Date('Y-m-d');
    $id = get_sanitized_value($_GET['id'] ?? 'NULL');
    
    list($has_rights_setup_cng_deals_iu) = build_security_rights($rights_setup_cng_deals_iu);
    
    $xml_file = "EXEC spa_source_deal_cng @flag='a', @source_deal_cng_id='" . $id . "'";
    $return_value = readXMLURL($xml_file);

    $id = $return_value[0][0] ?? '';
	$counterparty_id = $return_value[0][1] ?? '';
	$excess_cash = $return_value[0][2] ?? '';
    $cash_apply = $return_value[0][3] ?? '';
    $receive_date = (($return_value[0][4] ?? '') != '') ? $return_value[0][4] : $today_date;
    
    if ($cash_apply == '') {
       $counterparty_id = '';
       $counterparty_name = '';
    }
    
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "CNG Cash Apply",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    
    $setup_cng_deal_cash_apply_layout = new AdihaLayout();
    echo $setup_cng_deal_cash_apply_layout->init_layout('setup_cng_deal_cash_apply_layout', '', '1C', $layout_json, $name_space);
    
    $toolbar_json = '[  
                        {id:"Save", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"},
                    ]';
    
    $toolbar_setup_cng_deal_cash_apply = new AdihaMenu();
    echo $setup_cng_deal_cash_apply_layout->attach_menu_cell('setup_cng_deal_cash_apply_toobar', "a"); 
    echo $toolbar_setup_cng_deal_cash_apply->init_by_attach('setup_cng_deal_cash_apply_toobar', $name_space);
    echo $toolbar_setup_cng_deal_cash_apply->load_menu($toolbar_json);
    echo $toolbar_setup_cng_deal_cash_apply->attach_event('', 'onClick', 'run_toolbar_click');

    $form_object = new AdihaForm();
    
    $sp_url_counterparty = "EXEC spa_getsourcecounterparty 's'";
    echo "counterparty_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_counterparty, 0, 1, true, $counterparty_id) . ";"."\n";
    
    $general_form_structure = "[
        {type: 'combo', name: 'cmb_counterparty', label: 'Counterparty', required: 'true', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, inputWidth: ".$ui_settings['field_size'].", position: 'label-top' , options: counterparty_dropdown, offsetLeft : ".$ui_settings['offset_left']."},
        {type : 'newcolumn'},
        {type: 'calendar', name: 'dt_recieved_date', label: 'Recieved Date', value: '$today_date', inputWidth: ".$ui_settings['field_size'].", position: 'label-top', offsetLeft : ".$ui_settings['offset_left']."},  
        {type : 'newcolumn'},      
        {type: 'input', name: 'txt_excess_cash', label: 'Excess Cash', disabled: 'true', value: '$excess_cash', position: 'label-top',  inputWidth: ".$ui_settings['field_size'].", offsetLeft : ".$ui_settings['offset_left']."},
        {type : 'newcolumn'},
        {type: 'input', name: 'txt_cash_apply', label: 'Cash Apply', value: '$cash_apply', required: 'true', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, position: 'label-top',  inputWidth: ".$ui_settings['field_size'].", offsetLeft : ".$ui_settings['offset_left']."},
    ]";   
    
    echo $setup_cng_deal_cash_apply_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($general_form_structure);
    
    echo $setup_cng_deal_cash_apply_layout->close_layout();       
        
?>

<script type="text/javascript">
    $(function (){
        var counterparty_id_object = setup_cng_deal_cash_apply.form_setup_cng_deal_cash_apply.getCombo('cmb_counterparty');
        
        counterparty_id_object.attachEvent('onChange', function (name) {
            var counterparty_id = setup_cng_deal_cash_apply.form_setup_cng_deal_cash_apply.getItemValue('cmb_counterparty');
            var data = {
                    'action': 'spa_source_deal_cng',
                    'flag': 'a',                    
                    'counterparty_id': counterparty_id
                }
                
			adiha_post_data('return_array', data, '', '', 'call_back_set_excess_cash');
        });
    });
    
    function call_back_set_excess_cash(return_value) {
        if (return_value[0] == undefined || return_value[0][2] == null) {
            return_value = [[0,0,0],[0,0,0]];    
        }
        
        setup_cng_deal_cash_apply.form_setup_cng_deal_cash_apply.setItemValue('txt_excess_cash', return_value[0][2]);			
    }
    
    function run_toolbar_click() {
        var counterparty_id = setup_cng_deal_cash_apply.form_setup_cng_deal_cash_apply.getItemValue('cmb_counterparty');        
        var cash_apply = setup_cng_deal_cash_apply.form_setup_cng_deal_cash_apply.getItemValue('txt_cash_apply');
		var received_date =  setup_cng_deal_cash_apply.form_setup_cng_deal_cash_apply.getItemValue('dt_recieved_date', true);
		var current_date = '<?php echo date("Y-m-d"); ?>';
		var remaining_cash = setup_cng_deal_cash_apply.form_setup_cng_deal_cash_apply.getItemValue('txt_excess_cash');
        remaining_cash = (remaining_cash == '') ? 0 : remaining_cash;
		var mode = 'a';
                        
        //Validation starts
        var form_obj = setup_cng_deal_cash_apply.setup_cng_deal_cash_apply_layout.cells("a").getAttachedObject();
        var validate_return = validate_form(form_obj);
    
    
        if (validate_return === false) {
            return;
        }
        
        if (isNaN(cash_apply) && cash_apply != 'NULL') {
            show_messagebox(get_message('CASH_ERROR')); 
            return;
        }
        if ( counterparty_id == 'NULL') {
            show_messagebox(get_message('COUNTERPARTY_ERROR')); 
            return;
        }   
		if ( cash_apply < 0) {
            show_messagebox(get_message('NEG_CASH_ERROR')); 
            return;
        }
        
        if (received_date > current_date){
            show_messagebox(get_message('RECEIVED_DATE_ERROR')); 
            return;
        }			   

        var id = '<?php echo $id; ?>';
		cash_apply = parseFloat(cash_apply) + parseFloat(remaining_cash);
		
        data = {
                    'action': 'spa_apply_cash_cng',
                    'flag': 'a',                    
                    'counterparty_id': counterparty_id,
            		'cash_applied': cash_apply,
            		'receive_date': received_date 
                }
                
        adiha_post_data('alert', data, '', '', 'callback_grid_refresh');
    }
    
    function get_message(args) {
        switch (args) {
            case 'CASH_ERROR':
                return 'Please enter integer value for cash apply.'; 
			case 'COUNTERPARTY_ERROR':
                return 'Please select counterparty as counterparty cannot be blank.';    	
			case 'NEG_CASH_ERROR':
                return 'Cash applied value cannot be negative.'; 	
			case 'RECEIVED_DATE_ERROR':
                return 'Received date cannot be greater then current date.';					
        }
    }
    
    function callback_grid_refresh() {        
        setTimeout('parent.refresh_grid()', 1000);
        setTimeout('parent.new_cng_cash_apply.close()', 1000);        
    }
</script>
</html>