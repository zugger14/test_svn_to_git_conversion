<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_setup_cng_deal_detail';
    $name_space = 'setup_cng_deal_detail';
    $rights_setup_cng_deals_iu = 10132310;
    $today_date = Date('Y-m-d');
    $deal_id = get_sanitized_value($_GET['deal_id'] ?? '');
    $flag = get_sanitized_value($_GET['flag'] ?? 'i');
    $transaction_hr = '';
    $transaction_min = '';
    $transaction_sec = '';
    $start_hr = '';
    $start_min = '';
    $start_sec = '';
    $end_hr = '';
    $end_min = '';
    $end_sec = '';
    $pulser_start_hr = '';
    $pulser_start_min = '';
    $pulser_start_sec = '';
    $pulser_end_hr = '';
    $pulser_end_min = '';
    $pulser_end_sec = '';
    $payment_status = '';
    $card_type = '';
    $location_id = '';
    $credit_card_no = '';
    $quantity = '';
    $price = '';
    $pump_no = '';
    $driver = '';
    $vehicle_id = '';
    $odometer = '';

    if ($flag == 'u') {
        $sp_url = "EXEC spa_source_deal_cng @flag='x', @source_deal_cng_id='" . $deal_id . "'"; 
        $return_value = readXMLURL($sp_url);
        
        $id = $return_value[0][0];
    	$card_type = $return_value[0][1];
    	$credit_card_no = $return_value[0][3];
    	$transaction = explode(' ', $return_value[0][4]);
    	$start = explode(' ', $return_value[0][5]);
    	$end = explode(' ', $return_value[0][6]);
    	$pulser_start = explode(' ', $return_value[0][7]);
    	$pulser_end  = explode(' ', $return_value[0][8]);
    	$location_id = $return_value[0][9];    	
    	$quantity = $return_value[0][10];
    	$price = $return_value[0][11];
    	$pump_no = $return_value[0][12];
    	$driver = $return_value[0][13];
    	$vehicle_id = $return_value[0][14];
    	$odometer = $return_value[0][15];
        $payment_status = $return_value[0][16];
        $transaction_date = $transaction[0];
                        
        $transaction_time = explode(':', $transaction[1]);
        
        $transaction_hr = $transaction_time[0];
        $transaction_min = $transaction_time[1];
        $transaction_sec = str_replace('.000', '', $transaction_time[2]);
        
        $start_date = $start[0];
        $start_time = explode(':', $start[1]);
        $start_hr = $start_time[0];
        $start_min = $start_time[1];
        $start_sec = str_replace('.000', '', $start_time[2]);
        
        $end_date = $end[0];
        $end_time = explode(':', $end[1]);
        $end_hr = $end_time[0];
        $end_min = $end_time[1];
        $end_sec = str_replace('.000', '', $end_time[2]);
        
        $pulser_start_date = $pulser_start[0];
        $pulser_start_time = explode(':', $pulser_start[1]);
        $pulser_start_hr = $pulser_start_time[0];
        $pulser_start_min = $pulser_start_time[1];
        $pulser_start_sec = str_replace('.000', '', $pulser_start_time[2]);
        
        $pulser_end_date = $pulser_end[0];
        $pulser_end_time = explode(':', $pulser_end[1]);
        $pulser_end_hr = $pulser_end_time[0];
        $pulser_end_min = $pulser_end_time[1];
        $pulser_end_sec = str_replace('.000', '', $pulser_end_time[2]);
        
        $date_t = $transaction_date;
        $date_s = $start_date;
        $date_e = $end_date;
        $date_ps = $pulser_start_date;
        $date_pe = $pulser_end_date;
    } else {
        $date_t = $today_date;
        $date_s = $today_date;
        $date_e = $today_date;
        $date_ps = $today_date;
        $date_pe = $today_date;
    }
   
    list($has_rights_setup_cng_deals_iu) = build_security_rights($rights_setup_cng_deals_iu);
    
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Setup CNG Deals Detail",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    
    $setup_cng_deal_detail_layout = new AdihaLayout();
    echo $setup_cng_deal_detail_layout->init_layout('setup_cng_deal_detail_layout', '', '1C', $layout_json, $name_space);
    
    $toolbar_json = '[  
                        {id:"Save", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"},
                    ]';
    
    $toolbar_setup_cng_deal_detail = new AdihaMenu();
    echo $setup_cng_deal_detail_layout->attach_menu_cell('setup_cng_deal_toobar', "a"); 
    echo $toolbar_setup_cng_deal_detail->init_by_attach('setup_cng_deal_toobar', $name_space);
    echo $toolbar_setup_cng_deal_detail->load_menu($toolbar_json);
    echo $toolbar_setup_cng_deal_detail->attach_event('', 'onClick', 'run_toolbar_click');

    $form_object = new AdihaForm();
    
    for ($i = 0; $i < 24; $i++) {
        $data_array_hr[$i] = (strlen($i) == 1) ? '0' . $i : $i;
        
    }
    
    for ($i = 0; $i < 60; $i++) {
        $data_array_min[$i] = (strlen($i) == 1) ? '0' . $i : $i;
    }
    
    $payment_status_value = array(0, 1);
    $payment_status_label = array('Unpaid', 'Paid');
    
    echo "cmb_hour_tran = " . $form_object->create_static_combo_box($data_array_hr, $data_array_hr, $transaction_hr, 24) . ";"."\n";
    echo "cmb_min_tran = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $transaction_min, 60) . ";"."\n";
    echo "cmb_sec_tran = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $transaction_sec, 60) . ";"."\n";
    
    echo "cmb_hour_st = " . $form_object->create_static_combo_box($data_array_hr, $data_array_hr, $start_hr, 24) . ";"."\n";
    echo "cmb_min_st = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $start_min, 60) . ";"."\n";
    echo "cmb_sec_st = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $start_sec, 60) . ";"."\n";
    
    echo "cmb_hour_en = " . $form_object->create_static_combo_box($data_array_hr, $data_array_hr, $end_hr, 24) . ";"."\n";
    echo "cmb_min_en = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $end_min, 60) . ";"."\n";
    echo "cmb_sec_en = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $end_sec, 60) . ";"."\n";
    
    echo "cmb_hour_pst = " . $form_object->create_static_combo_box($data_array_hr, $data_array_hr, $pulser_start_hr, 24) . ";"."\n";
    echo "cmb_min_pst = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $pulser_start_min, 60) . ";"."\n";
    echo "cmb_sec_pst = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $pulser_start_sec, 60) . ";"."\n";
    
    echo "cmb_hour_pen = " . $form_object->create_static_combo_box($data_array_hr, $data_array_hr, $pulser_end_hr, 24) . ";"."\n";
    echo "cmb_min_pen = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $pulser_end_min, 60) . ";"."\n";
    echo "cmb_sec_pen = " .  $form_object->create_static_combo_box($data_array_min, $data_array_min, $pulser_end_sec, 60) . ";"."\n";
    
    echo "cmb_payment_status_c = ".  $form_object->create_static_combo_box($payment_status_value, $payment_status_label, $payment_status, 2) . ";"."\n";
    
    $sp_url_card_type = "EXEC spa_StaticDataValues 'h', 32300";
    echo "card_type_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_card_type, 0, 1, false, $card_type, 2) . ";"."\n";
    
    $sp_url_location = "EXEC spa_source_minor_location 'o'";
    echo "location_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_location, 0, 1, true, $location_id, 2) . ";"."\n";
    
    $general_form_structure = "[
        {type: 'combo', name: 'cmb_card_type', label: 'Card Type',required: 'true', width: 200, position: 'absolute', inputLeft: 15, inputTop: 27, labelLeft: 15, labelTop: 5, inputWidth: 200, inputHeight: 25, options: card_type_dropdown, validate: 'NotEmpty', userdata:{validation_message:'Required Field'}},
        {type: 'input', name: 'txt_credit_card_no', label: 'Credit Card No.', value: '$credit_card_no', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, width: 200, position: 'absolute', inputLeft: 230, inputTop: 27, labelLeft: 230, labelTop: 5, inputWidth: 200, inputHeight: 25},
        
        {type: 'calendar', name: 'dt_transaction_date', label: 'Transaction Date', value: '$date_t', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, width: 200, position: 'absolute', inputLeft: 15, inputTop: 87, labelLeft: 15, labelTop: 65, inputWidth: 200, inputHeight: 25},
        {type: 'combo', name: 'cmb_transaction_date_hr', label: 'Hr:', width: 55, position: 'absolute', inputLeft: 230, inputTop: 87, labelLeft: 230, labelTop: 65, inputWidth: 200, inputHeight: 25, options: cmb_hour_tran},
        {type: 'combo', name: 'cmb_transaction_date_min', label: 'Min:', width: 55, position: 'absolute', inputLeft: 300, inputTop: 87, labelLeft: 300, labelTop: 65, inputWidth: 200, inputHeight: 25, options: cmb_min_tran},
        {type: 'combo', name: 'cmb_transaction_date_sec', label: 'Sec:', width: 55, position: 'absolute', inputLeft: 370, inputTop: 87, labelLeft: 370, labelTop: 65, inputWidth: 200, inputHeight: 25, options: cmb_sec_tran},
        {type: 'combo', name: 'cmb_location', label: 'Location', width: 200, position: 'absolute', inputLeft: 440, inputTop: 87, labelLeft: 440, labelTop: 65, inputWidth: 200, inputHeight: 25, options: location_dropdown},
        
        {type: 'calendar', name: 'dt_start_time', label: 'Start Time', value: '$date_s', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, width: 200, position: 'absolute', inputLeft: 15, inputTop: 147, labelLeft: 15, labelTop: 125, inputWidth: 200, inputHeight: 25},
        {type: 'combo', name: 'cmb_start_time_hr', label: 'Hr:', width: 55, position: 'absolute', inputLeft: 230, inputTop: 147, labelLeft: 230, labelTop: 125, inputWidth: 200, inputHeight: 25, options: cmb_hour_st},
        {type: 'combo', name: 'cmb_start_time_min', label: 'Min:', width: 55, position: 'absolute', inputLeft: 300, inputTop: 147, labelLeft: 300, labelTop: 125, inputWidth: 200, inputHeight: 25, options: cmb_min_st},
        {type: 'combo', name: 'cmb_start_time_sec', label: 'Sec:', width: 55, position: 'absolute', inputLeft: 370, inputTop: 147, labelLeft: 370, labelTop: 125, inputWidth: 200, inputHeight: 25, options: cmb_sec_st},
        {type: 'calendar', name: 'dt_end_time', label: 'End Time', value: '$date_e', width: 200, position: 'absolute', inputLeft: 440, inputTop: 147, labelLeft: 440, labelTop: 125, inputWidth: 200, inputHeight: 25},
        {type: 'combo', name: 'cmb_end_time_hr', label: 'Hr:', width: 55, position: 'absolute', inputLeft: 655, inputTop: 147, labelLeft: 655, labelTop: 125, inputWidth: 200, inputHeight: 25, options: cmb_hour_en},
        {type: 'combo', name: 'cmb_end_time_min', label: 'Min:', width: 55, position: 'absolute', inputLeft: 725, inputTop: 147, labelLeft: 725, labelTop: 125, inputWidth: 200, inputHeight: 25, options: cmb_min_en},
        {type: 'combo', name: 'cmb_end_time_sec', label: 'Sec:', width: 55, position: 'absolute', inputLeft: 795, inputTop: 147, labelLeft: 795, labelTop: 125, inputWidth: 200, inputHeight: 25, options: cmb_sec_en},
        
        {type: 'calendar', name: 'dt_pulser_start_time', label: 'Pulser Start Time', value: '$date_ps', width: 200, position: 'absolute', inputLeft: 15, inputTop: 207, labelLeft: 15, labelTop: 185, inputWidth: 200, inputHeight: 25},
        {type: 'combo', name: 'cmb_pulser_start_time_hr', label: 'Hr:', width: 55, position: 'absolute', inputLeft: 230, inputTop: 207, labelLeft: 230, labelTop: 185, inputWidth: 200, inputHeight: 25, options: cmb_hour_pst},
        {type: 'combo', name: 'cmb_pulser_start_time_min', label: 'Min:', width: 55, position: 'absolute', inputLeft: 300, inputTop: 207, labelLeft: 300, labelTop: 185, inputWidth: 200, inputHeight: 25, options: cmb_min_pst},
        {type: 'combo', name: 'cmb_pulser_start_time_sec', label: 'Sec:', width: 55, position: 'absolute', inputLeft: 370, inputTop: 207, labelLeft: 370, labelTop: 185, inputWidth: 200, inputHeight: 25, options: cmb_sec_pst},
        {type: 'calendar', name: 'dt_pulser_end_time', label: 'Pulser End Time', value: '$date_pe', width: 200, position: 'absolute', inputLeft: 440, inputTop: 207, labelLeft: 440, labelTop: 185, inputWidth: 200, inputHeight: 25},
        {type: 'combo', name: 'cmb_pulser_end_time_hr', label: 'Hr:', width: 55, position: 'absolute', inputLeft: 655, inputTop: 207, labelLeft: 655, labelTop: 185, inputWidth: 200, inputHeight: 25, options: cmb_hour_pen},
        {type: 'combo', name: 'cmb_pulser_end_time_min', label: 'Min:', width: 55, position: 'absolute', inputLeft: 725, inputTop: 207, labelLeft: 725, labelTop: 185, inputWidth: 200, inputHeight: 25, options: cmb_min_pen},
        {type: 'combo', name: 'cmb_pulser_end_time_sec', label: 'Sec:', width: 55, position: 'absolute', inputLeft: 795, inputTop: 207, labelLeft: 795, labelTop: 185, inputWidth: 200, inputHeight: 25, options: cmb_sec_pen},
        
        {type: 'input', name: 'txt_quantity', label: 'Quantity', value: '$quantity', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, width: 200, position: 'absolute', inputLeft: 15, inputTop: 267, labelLeft: 15, labelTop: 245, inputWidth: 200, inputHeight: 25},
        {type: 'input', name: 'txt_price', label: 'Price', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, value: '$price', width: 200, position: 'absolute', inputLeft: 230, inputTop: 267, labelLeft: 230, labelTop: 245, inputWidth: 200, inputHeight: 25},
        {type: 'input', name: 'txt_pump_number', label: 'Pump Number', value: '$pump_no', width: 200, position: 'absolute', inputLeft: 440, inputTop: 267, labelLeft: 440, labelTop: 245, inputWidth: 200, inputHeight: 25},
        {type: 'input', name: 'txt_driver', label: 'Driver', value: '$driver', width: 200, position: 'absolute', inputLeft: 655, inputTop: 267, labelLeft: 655, labelTop: 245, inputWidth: 200, inputHeight: 25},
        
        {type: 'input', name: 'txt_vehical_id', label: 'Vehicle ID', value: '$vehicle_id', width: 200, position: 'absolute', inputLeft: 15, inputTop: 322, labelLeft: 15, labelTop: 305, inputWidth: 200, inputHeight: 25},
        {type: 'input', name: 'txt_odo_meter', label: 'OdoMeter', value: '$odometer', width: 200, position: 'absolute', inputLeft: 230, inputTop: 322, labelLeft: 230, labelTop: 305, inputWidth: 200, inputHeight: 25},
        {type: 'combo', name: 'cmb_payment_status', label: 'Payment Status', width: 200, position: 'absolute', inputLeft: 440, inputTop: 322, labelLeft: 440, labelTop: 305, inputWidth: 200, inputHeight: 25, options: cmb_payment_status_c},
    ]";   
    
    echo $setup_cng_deal_detail_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($general_form_structure);
    
    echo $setup_cng_deal_detail_layout->close_layout();       
        
?>
<script type="text/javascript">
    function run_toolbar_click() {
        var deal_id = '<?php echo $deal_id; ?>';
        var card_type = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_card_type');
        var credit_card_no = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('txt_credit_card_no');
        
        var transaction_date = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('dt_transaction_date', true);
        var transaction_date_hr = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_transaction_date_hr');
        var transaction_date_min = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_transaction_date_min');
        var transaction_date_sec = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_transaction_date_sec');
        var location_id = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_location');
        
        var start_time = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('dt_start_time', true);
        var start_time_hr = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_start_time_hr');
        var start_time_min = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_start_time_min');
        var start_time_sec = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_start_time_sec');
        var end_time = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('dt_end_time', true);
        var end_time_hr = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_end_time_hr');
        var end_time_min = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_end_time_min');
        var end_time_sec = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_end_time_sec');
        
        var pulser_start_time = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('dt_pulser_start_time', true);
        var pulser_start_time_hr = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_pulser_start_time_hr');
        var pulser_start_time_min = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_pulser_start_time_min');
        var pulser_start_time_sec = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_pulser_start_time_sec');
        var pulser_end_time = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('dt_pulser_end_time', true);
        var pulser_end_time_hr = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_pulser_end_time_hr');
        var pulser_end_time_min = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_pulser_end_time_min');
        var pulser_end_time_sec = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_pulser_end_time_sec');
        
        var quantity = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('txt_quantity');
        var price = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('txt_price');
        var pump_number = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('txt_pump_number');
        var driver = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('txt_driver');
        
        var vehical_id = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('txt_vehical_id');
        var odo_meter = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('txt_odo_meter');
        var payment_status = setup_cng_deal_detail.form_setup_cng_deal_detail.getItemValue('cmb_payment_status');
        var flag = '<?php echo $flag; ?>';
        
        //Validation starts
        var form_obj = setup_cng_deal_detail.setup_cng_deal_detail_layout.cells("a").getAttachedObject();
        var validate_return = validate_form(form_obj);
        if(!validate_return) {
            generate_error_message();
            return;
        }
        
        if (card_type == 'NULL' || card_type == '') {
            show_messagebox(get_message('CARD_TYPE')); 
            return;
        }
        
        if (transaction_date == 'NULL' || transaction_date == '') {
            show_messagebox(get_message('TRANSACTION_DATE')); 
            return;
        } else {
            transaction_date = transaction_date + ' ' + ((transaction_date_hr < 10) ? '0' + transaction_date_hr : transaction_date_hr) + ':' + ((transaction_date_min < 10) ? '0' + transaction_date_min : transaction_date_min) + ':' + ((transaction_date_sec < 10) ? '0' + transaction_date_sec : transaction_date_sec);
        }
        
        if (start_time == 'NULL' || start_time == '') {
            show_messagebox(get_message('START_TIME')); 
            return;
        } else {
            start_time = start_time + ' ' + ((start_time_hr < 10) ? '0' + start_time_hr : start_time_hr) + ':' + ((start_time_min < 10) ? '0' + start_time_min : start_time_min) + ':' + ((start_time_sec < 10) ? '0' + start_time_sec : start_time_sec);
        }
        
        if (quantity == 'NULL' || quantity == '') {
            show_messagebox(get_message('QUANITY_REQUIRED')); 
            return;
        }
        
        if (price == 'NULL' || price == '') {
            show_messagebox(get_message('PRICE_REQUIRED')); 
            return;
        }
        
        if (isNaN(quantity) && quantity != 'NULL') {
            show_messagebox(get_message('QUANTITY_ERROR')); 
            return;
        }
        
        if (isNaN(price) && price != 'NULL') {
            show_messagebox(get_message('PRICE_ERROR')); 
            return;
        }
        
        if (isNaN(pump_number) && pump_number != 'NULL') {
            show_messagebox(get_message('PUMP_NO_ERROR')); 
            return;
        }
        
        if (isNaN(driver) && driver != 'NULL') {
            show_messagebox(get_message('DRIVER_ERROR')); 
            return;
        }  
        
        if (isNaN(vehical_id) && vehical_id != 'NULL') {
            show_messagebox(get_message('VEHICAL_ID_ERROR')); 
            return;
        }
        
        if (isNaN(odo_meter) && odo_meter != 'NULL') {
            show_messagebox(get_message('ODO_METER_ERROR')); 
            return;
        }
        //Validation ends
        if (end_time != 'NULL' && end_time != '') {
            end_time = end_time + ' ' + ((end_time_hr < 10) ? '0' + end_time_hr : end_time_hr) + ':' + ((end_time_min < 10) ? '0' + end_time_min : end_time_min) + ':' + ((end_time_sec < 10) ? '0' + end_time_sec : end_time_sec);
        }
        
        if (pulser_start_time != 'NULL' && pulser_start_time != '') {
            pulser_start_time = pulser_start_time + ' ' + ((pulser_start_time_hr < 10) ? '0' + pulser_start_time_hr : pulser_start_time_hr) + ':' + ((pulser_start_time_min < 10) ? '0' + pulser_start_time_min : pulser_start_time_min) + ':' + ((pulser_start_time_sec < 10) ? '0' + pulser_start_time_sec : pulser_start_time_sec);
        }
        
        if (pulser_end_time != 'NULL' && pulser_end_time != '') {
            pulser_end_time = pulser_end_time + ' ' + ((pulser_end_time_hr < 10) ? '0' + pulser_end_time_hr : pulser_end_time_hr) + ':' + ((pulser_end_time_min < 10) ? '0' + pulser_end_time_min : pulser_end_time_min) + ':' + ((pulser_end_time_sec < 10) ? '0' + pulser_end_time_sec : pulser_end_time_sec);
        }
        
        if (start_time > end_time) {
            show_messagebox(get_message('START_TIME_ERROR')); 
            return;
        } 
        
        if (pulser_start_time > pulser_end_time) {
            show_messagebox(get_message('PULSER_TIME_ERROR')); 
            return;
        } 
                    
        
        data = {
                    'action': 'spa_source_deal_cng',
                    'flag': flag,     
                    'source_deal_cng_id': deal_id,                
                    'card_type': card_type,                    
                    'credit_card_no': credit_card_no,
                    'transaction_date': transaction_date,
                    'start_time': start_time,
                    'end_time': end_time,
                    'pulser_start_time': pulser_start_time,
                    'pulser_end_time': pulser_end_time,
                    'location_id': location_id,
                    'quantity': quantity,
                    'price': price,
                    'pump_number': pump_number,
                    'driver': driver,
                    'vehicle_id': vehical_id,
                    'odo_meter': odo_meter,
                    'payment_status': payment_status
                }
        setup_cng_deal_detail.setup_cng_deal_toobar.setItemDisabled('Save');
        setup_cng_deal_detail.setup_cng_deal_detail_layout.cells("a").progressOn();        
        adiha_post_data('alert', data, '', '', 'callback_grid_refresh');
    }
    
    function get_message(args) {
            switch (args) {                
                case 'TRANSACTION_DATE':
                    return 'Please enter transaction date.';    
                case 'START_TIME':
                    return 'Please enter start time.';    
                case 'QUANTITY_ERROR':
                    return 'Please enter integer value for <b>Quantity</b>.';      
                case 'PRICE_ERROR':
                    return 'Please enter integer value for <b>Price</b>.';
                case 'PUMP_NO_ERROR':
                    return 'Please enter integer value for <b>Pump Number</b>.';
                case 'DRIVER_ERROR':
                    return 'Please enter integer value for <b>Driver</b>.'; 
                case 'VEHICAL_ID_ERROR':
                    return 'Please enter integer value for <b>Vehicle ID</b>.'; 
                case 'ODO_METER_ERROR':
                    return 'Please enter integer value for <b>OdoMeter</b>.';   
                case 'START_TIME_ERROR':
                    return '<b>Start Time</b> should be less than or equals to <b>End Time</b>.';      
                case 'PULSER_TIME_ERROR':
                    return '<b>Pulsor Start Time</b> should be less than or equals to <b>Pulsor End Time</b>'; 
                case 'QUANITY_REQUIRED':
                    return 'Please enter Quantity.'; 
                case 'PRICE_REQUIRED':
                    return 'Please enter Price.';                                                                          
            }
        }
        
    function callback_grid_refresh(args) {   
        if (args[0].errorcode == 'Error') {
            setup_cng_deal_detail.setup_cng_deal_detail_layout.cells("a").progressOff();    
            return;
        }
        
        setTimeout('parent.refresh_grid()', 1000);
        setTimeout('parent.new_cng_iu.close()', 1000);
    }
</script>