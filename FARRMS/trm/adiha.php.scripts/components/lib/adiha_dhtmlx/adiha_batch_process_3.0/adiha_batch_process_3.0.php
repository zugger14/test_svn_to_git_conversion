<?php
include '../../../include.file.v3.php';

$flag = isset($_GET['flag']) ? $_GET['flag'] : 'i';
$call_from = isset($_GET['call_from']) ? $_GET['call_from'] : '';
$gen_as_of_date = isset($_GET['gen_as_of_date']) ? $_GET['gen_as_of_date'] : 0;
$source = isset($_GET['source']) && $_GET['source'] != '' ? $_GET['source'] : 'NULL';
$exec_call = isset($_REQUEST['exec_call']) ? $_REQUEST['exec_call'] : '';
$schedule_id = '';
$job_id = isset($_GET['job_id']) ? $_GET['job_id'] : '';
$batch_type = isset($_GET['batch_type']) ? $_GET['batch_type'] : 'r'; 
$as_of_date_value = isset($_GET['as_of_date']) ? $_GET['as_of_date'] : date('Y-m-d');
$report_type = isset($_REQUEST['rfx']) ? 'Report Manager' : 'Standard Report';
$get_as_of_date_value = isset($_GET['as_of_date']) ? $_GET['as_of_date'] : 'NULL';
$as_of_date_value = ($get_as_of_date_value == 'NULL' ? date('Y-m-d') : $get_as_of_date_value); 
$report_paramset_id = isset($_GET['report_paramset_id']) && $_GET['report_paramset_id'] != '' ? $_GET['report_paramset_id'] : 'NULL';
$paramset_hash = isset($_GET['paramset_hash']) && $_GET['paramset_hash'] != '' ? $_GET['paramset_hash'] : 'NULL';
$ixp_rules_id = isset($_GET['ixp_rules_id']) ? $_GET['ixp_rules_id'] : 'NULL';
$is_stmt = isset($_GET['is_stmt']) ? $_GET['is_stmt'] : 0;
//For Invoice Batch Start
if ($call_from == 'invoice') {
    if ($exec_call <> '' && strpos($exec_call, 'invoice_ids=') > -1) {
        $invoice_ids = str_replace('invoice_ids=', '',$exec_call);
    } else {
        $invoice_ids = isset($_GET['invoice_ids']) ? $_GET['invoice_ids'] : '';
    }
    
    $reporting_param = isset($_GET['reporting_param']) ? $_GET['reporting_param'] : '';
    $report_file_path = isset($_GET['report_file_path']) ? $_GET['report_file_path'] : '';
    $report_folder = isset($_GET['report_folder']) ? $_GET['report_folder'] : '';
}
//For Invoice Batch End

if ($call_from == 'view_schedule') {
    $exec_call = 'JobID:' . $job_id;
    $source = 'immediate_run';
} 

if ($flag == 'x' || $flag == 'u') {
    $sp_url = "EXEC batch_report_process @flag='x', @jobId='" . $job_id . "', @spa = NULL"; 
    $return_value = readXMLURL($sp_url);
    
    if (strpos($return_value[0][1], 'spa_export_RDL') != '' && $flag == 'u') {
        $report_type = 'Report Manager';
    } else {
        $job_id = $return_value[0][0];
        $exec_call = $return_value[0][1];
        $source = 'immediate_run';
    }
}

if ($flag == 'u') {
    $default_run_mode = 's';
} else {
    $default_run_mode = 'r';
    $job_name = '';
}
$notification_type = 'NULL';
$mins = '';
$hour = '';
$mins3 = '';
$hour3 = '';
$recurs_every = '';
$mon_day = '';
$mon_mon = '';
$occurs = '';
$edate = 'false';
$day1 = 'false';
$day2 = 'false';
$day3 = 'false';
$day4 = 'false';
$day5 = 'false';
$day6 = 'false';
$day7 = 'false';
$export_table_name = '';
$non_system_users = '';
$attach_file = '';
$type = '';
$act_st_date = '';
$act_en_date = '';
$holiday_calendar_id = '';
$date_month = '';
$export_format = '';
$export_csv_path = '';
$ftp_folder_path = '';
$export_web_services_id = '';
$export_file_transfer_endpoint_id = '';
$report_header = '';

if ($flag == 'u') {
    $sp_url = "EXEC batch_report_process @flag='a', @jobId='" . $job_id . "'"; 
    $sp_xml = readXMLURL($sp_url);
    $length = 0;

    foreach ($sp_xml as $temp)
        $length += sizeof($temp);

    $job = 's';
    $job_id = ($length > 0) ? $sp_xml[0][0] : 'NULL';
    $job_name = ($length > 0) ? $sp_xml[0][1] : 'NULL';
    $process_id = substr($job_name, -13);
    $schedule_id = ($length > 0) ? $sp_xml[0][2] : 'NULL';
    $occurs = ($length > 0) ? $sp_xml[0][3] : 'NULL';
    $freq_interval = ($length > 0) ? $sp_xml[0][4] : 'NULL'; 
    $store = array();
    $value = $freq_interval;
    $mon_day = 'NULL';
    $mon_mon = 'NULL';

    for ($i = 64; $i >= 1; $i = $i / 2) {
        if ($value >= $i) {
            array_push($store, $i);
            $value = $value - $i;
        }
        
        if ($value == '1') {
            array_push($store, $value);
            break;
        }
    }

    function check_day($store, $val) {
        for ($i = 0; $i < sizeof($store); $i++) {
            if ($store[$i] == $val)
                return true;
        }
    }

    $freq_subday_type = $sp_xml[0][5];
    $freq_sub_day_interval = $sp_xml[0][6];
    $freq_relative_interval = $sp_xml[0][7];
    $freq_recurrence_factor = $sp_xml[0][8];
    $active_start_date = $sp_xml[0][9];
    $act_st_yr = substr($active_start_date, 0, 4);
    $act_st_mo = substr($active_start_date, 4, 2);
    $act_st_da = substr($active_start_date, 6, 2);
    $act_st_date = $act_st_yr. '-' . $act_st_mo . '-' . $act_st_da;
    $active_end_date = ($length > 0) ? $sp_xml[0][10] : 'NULL';

    if ($active_end_date == '') {
        $edate = 'true';
        $act_en_date = null;
    } else {
        $act_en_yr = substr($active_end_date, 0, 4);
        $act_en_mo = substr($active_end_date, 4, 2);
        $act_en_da = substr($active_end_date, 6, 2);
        $act_en_date = $act_en_yr . '-' . $act_en_mo . '-' . $act_en_da ;
    }

    $active_start_time = ($length > 0) ? $sp_xml[0][11] : 'NULL';

    while (strlen(trim($active_start_time)) != 6) {
        $active_start_time = '0' . $active_start_time;
    }

    $act_hour = intval(substr($active_start_time, 0, 2));
    $act_min = intval(substr($active_start_time, 2, 2));

    $active_end_time = $sp_xml[0][12];

    if ($occurs == 1) {
        $job_type = 'ONE_TIME';
        $job_type_value = 'One Time';
    } else {
        $job_type = 'RECURRING';
        $job_type_value = 'Recurring';
    }

    $type = $job_type;

    if ($occurs == '4') {
        $recurs_every = $freq_interval;
    } else {
        $recurs_every = $freq_recurrence_factor;
    }

    if ($occurs != '1') {
        $hour3 = $act_hour;
        $mins3 = $act_min;        
    }

    if ($occurs == '16') {
        $mon_day = $freq_interval;
        $mon_mon = $freq_recurrence_factor;
    }

    if ($occurs == '1') {
        $as_of_date_from = $act_st_date;
        $hour = $act_hour;
        $mins = $act_min;
    }
    
    if (check_day($store, 1)) $day1 = 'true';
    if (check_day($store, 2)) $day2 = 'true';
    if (check_day($store, 4)) $day3 = 'true';
    if (check_day($store, 8)) $day4 = 'true';
    if (check_day($store, 16)) $day5 = 'true';
    if (check_day($store, 32)) $day6 = 'true';
    if (check_day($store, 64)) $day7 = 'true';
    

    $export_csv_path = ($length > 0) ? $sp_xml[0][13] : 'NULL';
    $export_csv_path = str_replace('\\', "\\\\", $export_csv_path);
    $notification_type = ($length > 0) ? $sp_xml[0][14] : 'NULL';
    $attach_file = ($length > 0) ? $sp_xml[0][15] : 'NULL';

    if ($attach_file == 'y') {
        $attach_file = 'true';
    }

    $holiday_calendar_id = $sp_xml[0][16];
    $export_table_name = $sp_xml[0][17];
    $compress_file = ($sp_xml[0][18] == 'y') ? 1 : 0;
    $delimeter = $sp_xml[0][19];
    $report_header = $sp_xml[0][20];
    $export_format = $sp_xml[0][21];
    $sp_url_non = "EXEC batch_report_process @flag='f', @report_name='" . $job_name . "'"; 
    $return_value_non = readXMLURL($sp_url_non);
    if (sizeof($return_value_non) > 0)
        $non_system_users = $return_value_non[0][0];

    
    $ftp_folder_path = addslashes($sp_xml[0][22]);
    $export_web_services_id = $sp_xml[0][23];
    $export_file_transfer_endpoint_id = $sp_xml[0][24];    
}

$enable_non_sys = ($notification_type == 750 || $notification_type == 752 || $notification_type == 754 || $notification_type == 756 ) ? 'false' : 'true';

$exec_call = str_replace(array("\r\n","\n\r","\r", "\n"), '', $exec_call);

$exec_call = ($flag == 'x') ? str_replace('"', '\"', $exec_call) : $exec_call;

$layout = new AdihaLayout();
$form_obj = new AdihaForm();
$tab_obj = new AdihaTab();

$json = '[
            {
                id:             "a",
                header:         false,
                collapse:       false,
                fix_size:       [false,null]
            }
        ]';
$layout_name = 'batch_process_layout';
$layout_namespace = 'batch_layout_namespace';

if ($flag == 'u') {
    $date = $act_st_date;    
} else {    
    $date = date("Y-m-d");
}

echo $layout->init_layout($layout_name, '', '1C', $json, $layout_namespace);

//Start of Tabs
$tab_name = 'batch_process_tabs';

$json_tab = '[
    {
        id:      "a1",
        text:    "General",
        width:   null,
        index:   null,
        active:  true,
        enabled: true,
        close:   false
    },
    {
        id:      "a2",
        text:    "Report",
        width:   null,
        index:   null,
        active:  false,
        enabled: true,
        close:   false
    },
    {
        id:      "a3",
        text:    "Notifications",
        width:   null,
        index:   null,
        active:  false,
        enabled: true,
        close:   false
    }
    ]';
echo $layout->attach_tab_cell($tab_name, 'a', $json_tab);

//general form

$value_array = array('DATE.C', 'DATE.F', 'DATE.L', 'DATE.1', 'DATE.X');
$label_array = array('Custom As of Date', 'First Day of the Month', 'Last Day of the Month', 'Day Before Run Date', 'Custom Days Before Run Date');

$value_array_frequency = array('4', '8', '16');
$label_array_frequency = array('Daily', 'Weekly', 'Monthly');

for ($i = 0; $i < 24; $i++) {
    $data_array_hr[$i] = $i;
}

for ($i = 0; $i < 60; $i++) {
    $data_array_min[$i] = $i;
}

for ($i = 0; $i < 101; $i++) {
    $data_array_recurring[$i] = $i+1;
}

$export_report_name = '';
$export_file_path = '';
$export_report_format = '';
$delimiter = '';
$display_header = '';
$compress_file = '';
$xml_format = '';

if ($report_paramset_id != 'NULL') {
    $xml_url_report_paramset = "EXEC spa_rfx_report_paramset_dhx @flag='z', @report_paramset_id='$report_paramset_id'";
    $data_report_param_db = readXMLURL2($xml_url_report_paramset);

    $export_report_name = $data_report_param_db[0]['export_report_name'];
    $export_file_path = str_replace("\\", "\\\\", $data_report_param_db[0]['export_location']);
    $export_report_format = $data_report_param_db[0]['output_file_format'];
    $delimiter = $data_report_param_db[0]['delimiter'];
    $display_header = ($data_report_param_db[0]['report_header'] != '') ? $data_report_param_db[0]['report_header'] : $report_header;
    $compress_file = ($data_report_param_db[0]['compress_file'] != '') ? $data_report_param_db[0]['compress_file'] : $compress_file;
    $xml_format = $data_report_param_db[0]['xml_format'];
}

if($xml_format == '') {
    $xml_format = '-100000';
}

$export_report_format = ($export_report_format == '') ? $export_format : $export_report_format;

if ($report_type == 'Standard Report') {
    $json_export_report_format_opt = '
    [
        {text: "CSV"  , value: ".csv", selected: ' . ($export_report_format == '.csv' ? '1' : '0') . '},
        {text: "Text" , value: ".txt", selected: ' . ($export_report_format == '.txt' ? '1' : '0') . '},
        {text: "XML"  , value: ".xml", selected: ' . ($export_report_format == '.xml' ? '1' : '0') . '},
    ]
    ';
} else if ($call_from == 'Report Batch Job Excel Addin') {
    $export_report_format = '.pdf';
    $delimiter = '';
    $display_header = 'n';
    $json_export_report_format_opt = '
    [
        {text: "PDF"  , value: ".pdf", selected: ' . ($export_report_format == '.pdf' ? '1' : '0') . '},
        {text: "Excel"   , value: ".xlsx", selected: ' . ($export_report_format == '.xlsx' ? '1' : '0') . '}
    ]
    ';
} else {
    $json_export_report_format_opt = '
    [
        {text: "Excel", value: ".xlsx", selected: ' . ($export_report_format == '.xlsx' ? '1' : '0') . '},
        {text: "CSV"  , value: ".csv", selected: ' . ($export_report_format == '.csv' ? '1' : '0') . '},
        {text: "Text" , value: ".txt", selected: ' . ($export_report_format == '.txt' ? '1' : '0') . '},
        {text: "XML"  , value: ".xml", selected: ' . ($export_report_format == '.xml' ? '1' : '0') . '},
    ]
    ';
}

$json_delimiter_opt = '
[
    {text: "Comma"   , value: ",", selected: ' . ($delimiter == ',' ? '1' : '0') . '},
    {text: "Semi Colon"  , value: ";", selected: ' . ($delimiter == ';' ? '1' : '0') . '},
    {text: "Colon" , value: ":", selected: ' . ($delimiter == ':' ? '1' : '0') . '},
    {text: "Tab"  , value: "\t", selected: ' . ($delimiter == '\t' ? '1' : '0') . '},
    {text: "Vertical Bar(Pipe)"  , value: "|", selected: ' . ($delimiter == '|' ? '1' : '0') . '},
]
';

if ($report_type == 'Standard Report' && $flag != 'u') {
    $display_header =  1;
}

$cmb_option_count = count(($export_format_array_label ?? array()));
$export_format = ($batch_type == 'remit') ? '.xml' : '.csv';
$export_format = ($report_type == 'Report Manager' && $flag != 'u') ? '.xlsx' : $export_format;

$delim_array_value = array(',', ';', ':', '\t', '|');
$delim_array_label = array('Comma', 'Semi Colon', 'Colon', 'Tab', 'Vertical Bar(Pipe)');
$sp_url_xml_format = "EXEC spa_staticDataValues @flag='h', @type_id=100000";
$sp_url_web_service = "EXEC spa_export_web_service 'c'";           
$sp_url_holiday_calendar = "EXEC spa_get_holiday_calendar @flag='s'";
$sp_url_notification_type_v = "EXEC spa_staticDataValues @flag='s', @type_id=750";
$sp_file_transfer_endpoint = "EXEC spa_file_transfer_endpoint @flag = 'endpoint with url', @endpoint_type = 2";

echo "cmb_notification_type_v= ".  $form_obj->adiha_form_dropdown($sp_url_notification_type_v, 1, 2) . ";"."\n";
echo "cmb_holiday_calendar = ".  $form_obj->adiha_form_dropdown($sp_url_holiday_calendar, 1, 2, true) . ";"."\n";
echo "cmb_min = ".  $form_obj->create_static_combo_box($data_array_min, $data_array_min, $mins, 60) . ";"."\n";
echo "cmb_hour = ".  $form_obj->create_static_combo_box($data_array_hr, $data_array_hr, $hour, 24) . ";"."\n";
echo "cmb_min_r = ".  $form_obj->create_static_combo_box($data_array_min, $data_array_min, $mins3, 60) . ";"."\n";
echo "cmb_hour_r = ".  $form_obj->create_static_combo_box($data_array_hr, $data_array_hr, $hour3, 24) . ";"."\n";
echo "cmb_as_of_date = ".  $form_obj->create_static_combo_box($value_array, $label_array, '', 5) . ";"."\n";
echo "cmb_recurring = ".  $form_obj->create_static_combo_box($data_array_recurring, $data_array_recurring, $recurs_every, 101) . ";"."\n";
echo "cmb_days_c = ".  $form_obj->create_static_combo_box($data_array_recurring, $data_array_recurring, $mon_day, 101) . ";"."\n";
echo "cmb_of_every_c = ".  $form_obj->create_static_combo_box($data_array_recurring, $data_array_recurring, $mon_mon, 101) . ";"."\n";
echo "cmb_frequency = ".  $form_obj->create_static_combo_box($value_array_frequency, $label_array_frequency, "$occurs", 3) . ";"."\n";
echo "cmb_xml_format = ".  $form_obj->adiha_form_dropdown($sp_url_xml_format, 0, 1, false, -100000) . ";"."\n";
echo "cmb_web_service_option = ".  $form_obj->adiha_form_dropdown($sp_url_web_service, 0, 1, true, "$export_web_services_id") . ";"."\n";
echo "file_transfer_endpoint_id = ".  $form_obj->adiha_form_dropdown($sp_file_transfer_endpoint, 0, 1, true, "$export_file_transfer_endpoint_id") . ";"."\n";
//Delivery Method
if ($call_from == 'invoice') {
    $sp_url_delivery_method = "EXEC spa_staticDataValues @flag='q',  @value_ids='21306,21301'";
    echo "cmb_delivery_method= ".  $form_obj->adiha_form_dropdown($sp_url_delivery_method, 0, 1) . ";"."\n";
} else {
    $sp_url_delivery_method = "EXEC spa_staticDataValues @flag='s', @type_id=21300";
    echo "cmb_delivery_method= ".  $form_obj->adiha_form_dropdown($sp_url_delivery_method, 1, 2) . ";"."\n";
}

$form_structure = "[    
    {type:'input', name:'txt_job_name', label:'Job Name ', position:'label-top', value: '$job_name', inputWidth:720, offsetLeft: 0, inputHeight: 12},
    
    {type: 'fieldset', name: 'grp_as_of_date', label: 'As of Date', inputWidth: 720, list:[
        { type:'combo' , name:'cmb_as_of_date_c', label:'As of Date', required: true, labelWidth:120, position:'label-top', inputWidth:180, options: cmb_as_of_date},
        { type:'calendar', dateFormat: '$date_format',  name:'dt_custom_as_of_date', required: true, value: '$as_of_date_value', label:'Custom As of Date ',inputHeight: 25, inputWidth:180, labelWidth:130, position:'absolute', inputTop: 20, labelTop: 0, inputLeft: 480, labelLeft: 480},
        { type:'combo' , name:'txt_no_of_days', label:'No. of Days ', inputWidth:180, labelWidth:120, position:'absolute', disabled: true, options: cmb_recurring, inputLeft: 240, labelLeft: 240, inputTop: 20, labelTop: 0},
        
    ]},

    {type: 'settings', position: 'label-right'},
    {type: 'fieldset', name:'run_mode', label: 'Run Mode', inputWidth: 720,  list:[
        { type:'radio' , name:'rdo_run_mode', label:'Immediate', labelAlign:'left', value: 'r', checked: true},
        {type: 'newcolumn'},
        { type:'radio' , name:'rdo_run_mode', label:'Schedule ', labelAlign:'left', offsetLeft:300, value: 's'},
    ]},
    
    {type: 'settings', position: 'label-right', offsetLeft:0},
    {type: 'fieldset', label: 'Job Schedule', name:'job_schedule', inputWidth: 720, list:[
        {type: 'settings', position: 'label-right'},
        {type: 'fieldset',name:'schedule_type', label: 'Schedule Type', inputWidth: 680, disabled: true, list:[
        { type:'radio' , name:'rdo_one_time', label:' One Time ', position: 'label-right', value: 'ONE_TIME'},
        {type: 'newcolumn'},
        { type:'radio' , name:'rdo_one_time', label:' Recurring ', position:'label-right', offsetLeft: 300, value: 'RECURRING'},
        ]},

        {type: 'settings', position: 'label-right'},
        {type: 'fieldset', label: 'One Time Occurance', inputWidth: 680, name: 'one_time_occurance', disabled: true, list:[
            { type:'calendar', dateFormat: '$date_format', name:'dt_date', label:'Date ', labelTop:200, position: 'label-top', inputWidth: 180, required: true},
            { type:'combo' , name:'cmb_hour_c', label:'Hour ', inputWidth:80, position: 'absolute', options: cmb_hour, inputLeft: 220, labelLeft: 220, inputTop: 23, labelTop: 7},
            { type:'combo' , name:'cmb_min_c', label:'Minute ', inputWidth:80, position: 'absolute', options: cmb_min, inputTop: 23, labelTop: 7, inputLeft: 320, labelLeft: 320},
        ]},

        {type: 'settings', position: 'label-right'},
        {type: 'fieldset', label: 'Recurring', name: 'recurring', disabled: true, inputWidth: 680, list:[
            { type:'calendar', dateFormat: '$date_format', name:'dt_start_date', label:'Start Date ', inputWidth:180, position: 'label-top', required:true},
            { type:'calendar', dateFormat: '$date_format', name:'dt_end_date', label:'End Date ', inputWidth:180, position: 'absolute', labelLeft: 220, inputLeft: 220, inputTop: 22, labelTop: 6},
            { type:'checkbox' , name:'chk_no_end_date', label:' No End Date ', position: 'absolute', labelLeft: 453, inputLeft: 440, inputTop: 25, labelTop: 27, checked: '$edate'},                    
            { type:'combo' , name:'cmb_frequency_c', label:'Frequency ', required: true, inputWidth:180, position: 'label-top', options: cmb_frequency},
            { type:'combo' , name:'cmb_holiday_calendar_c', label:'Holiday Calendar ', inputWidth:180, position: 'absolute', options: cmb_holiday_calendar, labelLeft: 220, inputLeft: 220, inputTop: 69, labelTop: 53},
            { type:'combo' , name:'cmb_recurring_c', label:'Recurs Every ', required: true, inputWidth:180, position: 'label-top', options: cmb_recurring},
            { type:'combo' , name:'cmb_hour_rec', label:'Hour ', inputWidth:80, position: 'absolute', options: cmb_hour_r, labelLeft: 220, inputLeft: 220, inputTop: 116, labelTop: 100},
            { type:'combo' , name:'cmb_minute_rec', label:'Minute ', inputWidth:80, position: 'absolute', options: cmb_min_r, labelLeft: 320, inputLeft: 320, inputTop: 116, labelTop: 100},
            
            {type: 'combo', name: 'cmb_days', label: 'Days', position: 'label-top', inputWidth: 180, options: cmb_days_c},
            {type: 'combo', name: 'cmb_of_every', label: 'Of Every', position: 'label-top', inputWidth: 180, options: cmb_of_every_c},
            {type: 'label', name: 'notes_of_every', labelWidth: 150, label: 'Month(s)', position: 'absolute', labelTop: 233, labelLeft: '180'},
            
            {type: 'fieldset', name: 'week_days', label: 'Week Days', inputWidth: 640, hidden: true, list:[
                { type:'checkbox', name:'chk_sunday', label:'Sunday', inputLeft: 0, labelLeft: 0, checked: '$day1'},
                { type:'checkbox', name:'chk_monday', label:'Monday', position: 'absolute', labelTop: 9, inputTop: 7, checked: '$day2', inputLeft: 70, labelLeft: 85},
                { type:'checkbox', name:'chk_tuesday', label:'Tuesday', position: 'absolute', labelTop: 9, inputTop: 7, checked: '$day3', inputLeft: 150, labelLeft: 165},
                { type:'checkbox', name:'chk_wednesday', label:'Wednesday', position: 'absolute', labelTop: 9, inputTop: 7, checked: '$day4', inputLeft: 230, labelLeft: 245},
                { type:'checkbox', name:'chk_thursday', label:'Thursday', position: 'absolute', labelTop: 9, inputTop: 7, checked: '$day5', inputLeft: 330, labelLeft: 345},
                { type:'checkbox', name:'chk_friday', label:'Friday', position: 'absolute', labelTop: 9, inputTop: 7, checked: '$day6', inputLeft: 410, labelLeft: 425},
                { type:'checkbox', name:'chk_saturday', label:'Saturday', position: 'absolute', labelTop: 9, inputTop: 7, checked: '$day7', inputLeft: 470, labelLeft: 485},
            ]},
        ]},
    ]},
]";

$form_name = 'general_form';
echo $tab_obj->attach_form_new($tab_name, $form_name, 'a1', $form_structure, $layout_namespace);

//report form
$local_file_path = addslashes('(Local File Path: E.g. D:\\csv_reports)');
$network_file_path = addslashes('(Network File Path: E.g. \\\\File Server\\bcp\\)');
$endpoint_label = 'FTP/(SFTP) Endpoint detail.';
$export_file_path = ($batch_type == 'remit') ? str_replace('\\', '\\\\',$BATCH_FILE_EXPORT_PATH) : $export_file_path;
$ftp_folder_path_enabled = 'false';

if($call_from !== 'invoice' && $flag != 'u')
    $export_csv_path = $export_file_path;

if ($call_from == 'Report Snapshot Batch Job') {
    $format_export_enabled = 'true';
} else {
    $format_export_enabled = 'false';
}
$form_structure = "[
                    {type: 'fieldset', label: 'Format', inputWidth: 700, disabled: " . $format_export_enabled . ", list:[
                        {type: 'combo', name: 'cmb_export_format', label: 'Export Format', position: 'label-top', width: 180, options: $json_export_report_format_opt, offsetLeft: 20},
                        {type: 'newcolumn'},
                        {type: 'combo', name: 'cmb_delimiter_c', label: 'Delimiter', position: 'label-top', width: 180, options: $json_delimiter_opt, offsetLeft: 20},
                        {type: 'newcolumn'},
                        {type: 'combo', name: 'cmb_xml_format_c', label: 'XML Format', position: 'label-top', width: 180, options: cmb_xml_format, offsetLeft: 20},
                        {type: 'newcolumn'},
                        {type: 'checkbox', name: 'chk_display_header', label: 'Display Header', position: 'label-right', offsetLeft: 20, checked: '$display_header', label_width :180, offsetTop : 26},
                        {type: 'newcolumn'},
                        {type: 'checkbox', name: 'chk_compress_file', label: 'Compress File', position: 'label-right', offsetLeft: 20, label_width :180, offsetTop : 26, checked: '$compress_file'},
                        
                        
                    ]},
                    {type: 'fieldset', label: 'Export', inputWidth: 700, list:[";

if ($report_type !== 'Standard Report') {   
$form_structure .="
                    {type: 'input', name: 'txt_export_report_name', label: 'Export Report Name', position: 'label-top', width: 600, labelWidth: 150, value: '$export_report_name'},
                    {type: 'newcolumn'},";
}

$form_structure .="
                    {type: 'input', name: 'txt_export_to_directory', label: 'Export to Directory', position: 'label-top', width: 600, labelWidth: 150, value: '$export_csv_path'},
                    {type: 'label', labelWidth: 600, label: '$local_file_path', position: 'absolute', labelTop: 40},
                    {type: 'label', labelWidth: 600, label: '$network_file_path'},
                    {type: 'input', name: 'txt_export_to_table', label: 'Export to Table', position: 'label-top', width: 600, labelWidth: 150, disabled: " . $format_export_enabled . ", value: '$export_table_name'},
                    {type: 'label', labelWidth: 600, label: '(Special characters except space are not allowed.)', position: 'absolute', labelTop: 120, disabled: " . $format_export_enabled . "},
                    {type: 'label', position:'label-top', labelWidth: 600, label: '', offsetTop: 10},
                    {type: 'fieldset', label: 'Export to FTP', inputWidth: 600, list:[
                        {type: 'combo', name: 'cmb_file_transfer_endpoint_id', label: 'File Transfer Endpoint', position: 'label-top', width: 200, options: file_transfer_endpoint_id},
                        {type: 'newcolumn'},
                        {type: 'input', name: 'txt_export_to_ftp_directory', label: 'FTP Folder', position: 'label-top', offsetLeft: 20, width: 335, labelWidth: 150, value: '$ftp_folder_path',disabled:" . $ftp_folder_path_enabled . "},
                        {type: 'newcolumn'},
                        {type: 'label', name: 'endpoint_label', labelWidth: 600, label: '$endpoint_label',  position:'label-left', disabled: false}
                        ]},                  
                    
                    {type: 'combo', name: 'cmb_post_to_web', label: 'Post to Web Service', position: 'label-top', width: 180, options: cmb_web_service_option},
                     ]}                
                    
                    ]";

$form_name = 'report_form';
echo $tab_obj->attach_form_new($tab_name, $form_name, 'a2', $form_structure, $layout_namespace);

//notification form
$sp_url_user_from_notification_list = "EXEC spa_application_users @flag='v'";
$sp_url_role_from_list = "EXEC spa_application_security_role @flag='s'";
$sp_url_user_to_notification_list = "EXEC batch_report_process @flag='n', @report_name='" . $job_name . "'";
$sp_url_role_to_list = "EXEC batch_report_process @flag='v', @report_name='" . $job_name . "'";
if($call_from == "Import") {
    $sp_url_user_from_notification_list = "EXEC spa_application_users @flag='b',@ixp_rules_id = ".$ixp_rules_id;
    $sp_url_role_from_list = "EXEC spa_application_security_role @flag='l',@ixp_rules_id = ".$ixp_rules_id;
    $sp_url_user_to_notification_list = "EXEC spa_application_users @flag='o',@ixp_rules_id = ".$ixp_rules_id;
    $sp_url_role_to_list = "EXEC spa_application_security_role @flag='q',@ixp_rules_id = ".$ixp_rules_id;
}
echo "user_from_notification_list_array = " . $form_obj->adiha_form_dropdown($sp_url_user_from_notification_list, 0, 1) . ";" . "\n";
echo "role_from_list_array = " . $form_obj->adiha_form_dropdown($sp_url_role_from_list, 0, 1) . ";" . "\n";
echo "user_to_notification_list_array = " . $form_obj->adiha_form_dropdown($sp_url_user_to_notification_list, 0, 1) . ";" . "\n";
echo "role_to_list_array = " . $form_obj->adiha_form_dropdown($sp_url_role_to_list, 0, 1) . ";" . "\n";

$form_structure = "[
                    {type: 'fieldset', label: 'Send Options', name: 'delivery_method', hidden: true, inputWidth: 500, list:[
                        {type: 'checkbox', name: 'chk_as_defined', label: 'As defined in Counterparty', position: 'label-left', checked: true},
                        {type: 'newcolumn'},
                        {type: 'combo', name: 'cmb_delivery_method', options: cmb_delivery_method, width: 165, offsetLeft:20, disabled: true}
                    
                    ]},
                    
                    {type: 'fieldset', label: 'Notification Type', name: 'notification_type_fieldset', inputWidth: 700, list:[
                        {type: 'combo', name: 'cmb_notification_type', label: 'Notification Type',offsetLeft:20, position: 'label-top', options: cmb_notification_type_v, width: 165 }
                    
                    ]},
                    
                    {type: 'settings', position: 'label-top'},
                    { type: 'fieldset', label: 'Users and Roles', width: 700, list: [
                        {type: 'block', width:680, list:[
                            {type: 'multiselect', label: 'User List', name: 'user_from', size:6,  options: user_from_notification_list_array, inputWidth:250},
                            {type: 'newcolumn', offset:10},
                            {type: 'block', width:100, list:[
                                {type: 'button', name: 'add_user', className: 'arrow_right', value: '', offsetTop:40, title: 'Right', inputLeft: 20},
                                {type: 'button', name: 'remove_user', value: '', className: 'arrow_left', title: 'Left', inputLeft: 20}
                        ]},
                        {type: 'newcolumn', offset:10},
                        {type: 'multiselect', label: 'Notify Users', name: 'user_to', size:6, inputWidth: 250, options: user_to_notification_list_array},
                    ]}, 
                    
                    {type: 'block', width:680, list:[
                            {type: 'multiselect', label: 'Role List', name: 'role_from', size:6,  options: role_from_list_array, inputWidth:250},
                            {type: 'newcolumn', offset:10},
                            {type: 'block', width:100, list:[
                                {type: 'button', name: 'add_role', className: 'arrow_right', value: '', offsetTop:40, title: 'Right', inputLeft: 20},
                                {type: 'button', name: 'remove_role', className: 'arrow_left', value: '', title: 'Left', inputLeft: 20}
                        ]},
                        {type: 'newcolumn', offset:10},
                        {type: 'multiselect', label: 'Notify Roles', name: 'role_to', size:6, inputWidth: 250, options: role_to_list_array},
                    ]}, 
                                
                ]},
                {type: 'input', name: 'txt_send_email', label: 'Send E-mail to non-system users', disabled: '$enable_non_sys', position: 'label-top', rows:5, width:700, value: '$non_system_users'},
                {type: 'label', name: 'note_send_email', labelWidth: 600, label: 'Please use semi-colon (;) to separate multiple email address.'},
                {type: 'checkbox', name: 'chk_attach_report', label: 'Attach Report', position: 'label-right', checked: '$attach_file'},

            ]";

$form_name = 'notification_form';
echo $tab_obj->attach_form_new($tab_name, $form_name, 'a3', $form_structure, $layout_namespace);

//submit button
$form_name = "button_form";
$toolbar_json = '[      
                        { id: "ok", type: "button", img: "tick.png", text: "OK", title: "Ok"}
                     ]';

echo $layout->attach_toolbar_cell($form_name, 'a');
$run_batch_toolbar = new AdihaToolbar();
echo $run_batch_toolbar->init_by_attach($form_name, $layout_namespace);
echo $run_batch_toolbar->load_toolbar($toolbar_json);
echo $run_batch_toolbar->attach_event('', 'onClick', 'btn_ok_click');

echo "
    var flag = '$flag';
    var job_name = '$job_name';
    var call_from = '$call_from';
    var batch_type = '$batch_type';
    var default_date = new Date('$date');
    default_date = app_date_format_converter(default_date);
    
    var as_of_date_value = new Date();
    as_of_date_value = app_date_format_converter(as_of_date_value);
    
    var job_type = '$type';
    var as_of_date_value_current = dates.convert_to_user_format('$as_of_date_value');
    var today = new Date();
    var first_day_of_month = new Date(today.getFullYear(), today.getMonth(), 1);;
    first_day_of_month = app_date_format_converter(first_day_of_month);
    
    var last_day_of_month = new Date(today.getFullYear(), today.getMonth()+1, 0);
    last_day_of_month = app_date_format_converter(last_day_of_month);
    var yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
       
    var run_mode_obj = batch_layout_namespace.general_form.getForm('rdo_run_mode');
    var start_date_obj = batch_layout_namespace.general_form.getForm('dt_date');
    var start_date_r_obj = batch_layout_namespace.general_form.getForm('dt_start_date');
    var end_date_r_obj = batch_layout_namespace.general_form.getForm('dt_end_date');
    var one_time_hour_obj = batch_layout_namespace.general_form.getCombo('cmb_hour_c');
    var one_time_mins_obj = batch_layout_namespace.general_form.getCombo('cmb_min_c');
    var holiday_calendar_obj = batch_layout_namespace.general_form.getCombo('cmb_holiday_calendar_c');
    var custom_as_of_date_obj = batch_layout_namespace.general_form.getForm('dt_custom_as_of_date');
    custom_as_of_date_obj.setItemValue('dt_custom_as_of_date', as_of_date_value_current);    
    //var cmb_delimiter_c_obj = batch_layout_namespace.report_form.getCombo('cmb_delimiter_c');            
    var export_format_obj = batch_layout_namespace.report_form.getCombo('cmb_export_format');           
    var report_type = '$report_type';
    //On page load hide these items.
    
    batch_layout_namespace.general_form.hideItem('cmb_of_every');
    batch_layout_namespace.general_form.hideItem('cmb_days');
    batch_layout_namespace.general_form.hideItem('notes_of_every');

    if (report_type == 'Standard Report') {
        batch_layout_namespace.report_form.showItem('cmb_delimiter_c');
        batch_layout_namespace.report_form.showItem('chk_display_header');
    } else {
        // batch_layout_namespace.report_form.hideItem('cmb_delimiter_c');
        // batch_layout_namespace.report_form.hideItem('chk_display_header');
    }
    batch_layout_namespace.report_form.hideItem('cmb_xml_format_c');
    
    if ('$gen_as_of_date' != 1) {
        batch_layout_namespace.general_form.hideItem('grp_as_of_date');
    }
    
    if (batch_type == 'c' || call_from == 'Import') {        
        batch_layout_namespace.batch_process_tabs.tabs('a2').hide();
        batch_layout_namespace.notification_form.disableItem('chk_attach_report');
    }

    var export_format_value = batch_layout_namespace.report_form.getItemValue('cmb_export_format');
    if (export_format_value == '.xlsx' || export_format_value == '.pdf') {
        batch_layout_namespace.report_form.hideItem('cmb_delimiter_c');
        batch_layout_namespace.report_form.hideItem('cmb_xml_format_c');
        batch_layout_namespace.report_form.hideItem('chk_display_header');
    } else if (export_format_value == '.xml') {
        batch_layout_namespace.report_form.hideItem('cmb_delimiter_c');
        batch_layout_namespace.report_form.showItem('cmb_xml_format_c');
        batch_layout_namespace.report_form.hideItem('chk_display_header');
    } else {            
        batch_layout_namespace.report_form.hideItem('cmb_xml_format_c');
        batch_layout_namespace.report_form.showItem('cmb_delimiter_c');
        batch_layout_namespace.report_form.showItem('chk_display_header');
    }

    if (batch_layout_namespace.report_form.getItemValue('cmb_file_transfer_endpoint_id') == '') {
        batch_layout_namespace.report_form.setItemValue('txt_export_to_ftp_directory', '');
        batch_layout_namespace.report_form.disableItem('txt_export_to_ftp_directory');
    } else {
        batch_layout_namespace.report_form.enableItem('txt_export_to_ftp_directory');
    }

    export_format_obj.attachEvent('onChange', function(){
        var export_format_value = batch_layout_namespace.report_form.getItemValue('cmb_export_format');
        var cmb_delimiter_c_obj = batch_layout_namespace.report_form.getCombo('cmb_delimiter_c'); 
        if (export_format_value == '.xlsx' || export_format_value == '.pdf'){
            batch_layout_namespace.report_form.hideItem('cmb_delimiter_c');
            batch_layout_namespace.report_form.hideItem('cmb_xml_format_c');
            batch_layout_namespace.report_form.hideItem('chk_display_header');
        } else if (export_format_value == '.xml'){
            batch_layout_namespace.report_form.hideItem('cmb_delimiter_c');
            batch_layout_namespace.report_form.showItem('cmb_xml_format_c');
            batch_layout_namespace.report_form.hideItem('chk_display_header');
        } else {            
            batch_layout_namespace.report_form.hideItem('cmb_xml_format_c');
            batch_layout_namespace.report_form.showItem('cmb_delimiter_c');
            batch_layout_namespace.report_form.showItem('chk_display_header');
        }
    });

    if (call_from == 'invoice') {
        batch_layout_namespace.notification_form.showItem('delivery_method');
        batch_layout_namespace.notification_form.hideItem('notification_type_fieldset');
        batch_layout_namespace.notification_form.disableItem('txt_send_email');
        batch_layout_namespace.notification_form.disableItem('note_send_email');
        
        batch_layout_namespace.notification_form.attachEvent('onChange', function (){
            
            var as_defined = (batch_layout_namespace.notification_form.getItemValue('chk_as_defined') == 1) ? 'y' : 'n';
                
            if (as_defined == 'y') {
                batch_layout_namespace.notification_form.disableItem('cmb_delivery_method');
                batch_layout_namespace.notification_form.disableItem('txt_send_email');
                batch_layout_namespace.notification_form.disableItem('note_send_email');
            } else {
                batch_layout_namespace.notification_form.enableItem('cmb_delivery_method');
                batch_layout_namespace.notification_form.enableItem('txt_send_email');
                batch_layout_namespace.notification_form.enableItem('note_send_email');
            }
        });        
    } 
    
    if (flag == 'u') {
        var active_start_date = new Date('$act_st_date');
        active_start_date = app_date_format_converter(active_start_date);
        
        if ('$act_en_date' == '') {
            var active_end_date = '$act_en_date';
        } else {
            var active_end_date = new Date('$act_en_date');
            active_end_date = app_date_format_converter(active_end_date);
        }
        var holiday_calendar = '$holiday_calendar_id';
        var run_mode_obj =  batch_layout_namespace.general_form.getForm('run_mode');
        
        if (active_end_date == '') {
            batch_layout_namespace.general_form.disableItem('dt_end_date');
        }
        
        run_mode_obj.checkItem('rdo_run_mode', 's');
        batch_layout_namespace.general_form.disableItem('run_mode');
        var schedule_type = job_type;
        
        batch_layout_namespace.general_form.checkItem('rdo_one_time', 'ONE_TIME');
        batch_layout_namespace.general_form.disableItem('txt_job_name');
        batch_layout_namespace.general_form.enableItem('schedule_type');
        batch_layout_namespace.general_form.enableItem('one_time_occurance');
        batch_layout_namespace.general_form.hideItem('grp_as_of_date');
        check_schedule_type(schedule_type);
    }    
    
    if (flag == 'u') {
        var notification_type_combo = batch_layout_namespace.notification_form.getCombo('cmb_notification_type');
        notification_type_combo.setComboValue('$notification_type');
    } else {
        var notification_type_combo = batch_layout_namespace.notification_form.getCombo('cmb_notification_type');
        notification_type_combo.setComboValue(751);
    }
    
    notification_type_combo.attachEvent('onChange', function() {
       var notification_type = batch_layout_namespace.notification_form.getItemValue('cmb_notification_type');
       
       if (notification_type == 750 || notification_type == 752 || notification_type == 754 || notification_type == 756 ) {
            batch_layout_namespace.notification_form.enableItem('txt_send_email');
            batch_layout_namespace.notification_form.enableItem('note_send_email');
       } else {
            batch_layout_namespace.notification_form.disableItem('txt_send_email');
            batch_layout_namespace.notification_form.disableItem('note_send_email');
       }
    });
    
    var as_of_date_obj = batch_layout_namespace.general_form.getCombo('cmb_as_of_date_c');
    var no_of_days_obj = batch_layout_namespace.general_form.getForm('txt_no_of_days');
    
    batch_layout_namespace.report_form.attachEvent('onChange', function(name, value, state) {        
        var endpoint = '';
        var remote_directory = '';
        var cmb_endpoint_obj = '';

        if (name == 'cmb_file_transfer_endpoint_id' || name == 'txt_export_to_ftp_directory') {            
            cmb_endpoint_obj = batch_layout_namespace.report_form.getCombo('cmb_file_transfer_endpoint_id'); 
            endpoint = cmb_endpoint_obj.getSelectedValue();
            endpoint = endpoint.substr(endpoint.indexOf('|')+1);

            if (endpoint == '') {
                endpoint = '$endpoint_label';
                batch_layout_namespace.report_form.setItemLabel('endpoint_label',endpoint);
                if (name == 'cmb_file_transfer_endpoint_id') {
                    batch_layout_namespace.report_form.setItemValue('txt_export_to_ftp_directory', '');
                    batch_layout_namespace.report_form.disableItem('txt_export_to_ftp_directory');
                }
            } else { 
                batch_layout_namespace.report_form.enableItem('txt_export_to_ftp_directory');
                remote_directory = batch_layout_namespace.report_form.getItemValue('txt_export_to_ftp_directory');               
                remote_directory = '( ' + endpoint + '/' + remote_directory + ' )';
                batch_layout_namespace.report_form.setItemLabel('endpoint_label',remote_directory);
            }            
        }
    });

    as_of_date_obj.attachEvent('onChange', function() {
        var as_of_date = batch_layout_namespace.general_form.getItemValue('cmb_as_of_date_c');
        
        if (as_of_date == 'DATE.C') {
            batch_layout_namespace.general_form.enableItem('dt_custom_as_of_date');
            custom_as_of_date_obj.setItemValue('dt_custom_as_of_date', '');
            custom_as_of_date_obj.setRequired('dt_custom_as_of_date', true);
            custom_as_of_date_obj.setItemValue('dt_custom_as_of_date', as_of_date_value);
            batch_layout_namespace.general_form.disableItem('txt_no_of_days');
            no_of_days_obj.setRequired('txt_no_of_days', false);
        } else if (as_of_date == 'DATE.X'){
            batch_layout_namespace.general_form.disableItem('dt_custom_as_of_date');
            custom_as_of_date_obj.setItemValue('dt_custom_as_of_date', '');
            custom_as_of_date_obj.setRequired('dt_custom_as_of_date', false);
            batch_layout_namespace.general_form.enableItem('txt_no_of_days');
            no_of_days_obj.setRequired('txt_no_of_days', true);
        } else if (as_of_date == 'DATE.F') {
            custom_as_of_date_obj.setItemValue('dt_custom_as_of_date', '');
            batch_layout_namespace.general_form.disableItem('dt_custom_as_of_date');
            custom_as_of_date_obj.setRequired('dt_custom_as_of_date', false);
            batch_layout_namespace.general_form.disableItem('txt_no_of_days');
            no_of_days_obj.setRequired('txt_no_of_days', false);
        } else if (as_of_date == 'DATE.L') {
            custom_as_of_date_obj.setItemValue('dt_custom_as_of_date', '');
            batch_layout_namespace.general_form.disableItem('dt_custom_as_of_date');
            custom_as_of_date_obj.setRequired('dt_custom_as_of_date', false);
            batch_layout_namespace.general_form.disableItem('txt_no_of_days');
            no_of_days_obj.setRequired('txt_no_of_days', false);
        } else {
            batch_layout_namespace.general_form.disableItem('dt_custom_as_of_date');
            custom_as_of_date_obj.setItemValue('dt_custom_as_of_date', '');
            custom_as_of_date_obj.setRequired('dt_custom_as_of_date', false);
            batch_layout_namespace.general_form.disableItem('txt_no_of_days');
            no_of_days_obj.setRequired('txt_no_of_days', false);
        }   
    });
    
    run_mode_obj.attachEvent('onChange', function(name, run_mode, schedule_type) {
        var run_mode = batch_layout_namespace.general_form.getItemValue('rdo_run_mode');
        
        if (name == 'rdo_run_mode' || name == 'rdo_one_time' || name == 'cmb_frequency_c') {
            if (run_mode == 's') {
                batch_layout_namespace.general_form.enableItem('schedule_type');
                batch_layout_namespace.general_form.enableItem('one_time_occurance');
                batch_layout_namespace.general_form.enableItem('recurring');
                
                if (batch_layout_namespace.general_form.getItemValue('rdo_one_time') == undefined) {
                    batch_layout_namespace.general_form.checkItem('rdo_one_time', 'ONE_TIME');
                }
                
                var schedule_type = batch_layout_namespace.general_form.getItemValue('rdo_one_time');
                
                if (schedule_type == 'ONE_TIME') {
                    batch_layout_namespace.general_form.enableItem('one_time_occurance');
                    batch_layout_namespace.general_form.disableItem('recurring');
                    start_date_obj.setItemValue('dt_date', as_of_date_value);
                    start_date_r_obj.setItemValue('dt_start_date', '');
                    end_date_r_obj.setItemValue('dt_end_date', '');
                    end_date_r_obj.setRequired('dt_end_date', false);
                } else if (schedule_type == 'RECURRING') { 
                    batch_layout_namespace.general_form.disableItem('one_time_occurance');
                    batch_layout_namespace.general_form.enableItem('recurring');
                    start_date_obj.setItemValue('dt_date', '');
                    
                    if (name != 'cmb_frequency_c') {
                        start_date_r_obj.setItemValue('dt_start_date', as_of_date_value);
                    }
                    
                    if (batch_layout_namespace.general_form.getItemValue('chk_no_end_date') != 1) {
                        end_date_r_obj.setItemValue('dt_end_date', as_of_date_value);
                        end_date_r_obj.setRequired('dt_end_date', true);
                    }
                    
                    var frequency = batch_layout_namespace.general_form.getItemValue('cmb_frequency_c');
                    
                    if (frequency == '4') {
                        var some_date = batch_layout_namespace.general_form.getItemValue('dt_start_date');
                        
                        if (batch_layout_namespace.general_form.getItemValue('chk_no_end_date') != 1) {
                            end_date_r_obj.setItemValue('dt_end_date', some_date);
                        }
                    } else if (frequency == '8') {                        
                        var some_date = batch_layout_namespace.general_form.getItemValue('dt_start_date');
                        var dd = some_date.getDate() + 7;
                        dd = ((dd.toString()).split('').length == 1) ? ('0' + dd) : dd;
                        var mm = some_date.getMonth() + 1;
                        var y = some_date.getFullYear();
                        mm = ((mm.toString()).split('').length == 1) ? ('0' + mm) : mm;
                        var default_date_week = y + '-'+ mm + '-'+ dd;
                        default_date_week = new Date(default_date_week);
                        default_date_week = app_date_format_converter(default_date_week);
                        
                        if (batch_layout_namespace.general_form.getItemValue('chk_no_end_date') != 1) {
                            end_date_r_obj.setItemValue('dt_end_date', default_date_week);
                        }
                    } else if (frequency == '16') {
                        var default_date_month = '$date_month';
                        var some_date = batch_layout_namespace.general_form.getItemValue('dt_start_date');
                        var dd = some_date.getDate();
                        dd = ((dd.toString()).split('').length == 1) ? ('0' + dd) : dd;
                        var mm = some_date.getMonth() + 2;
                        var y = some_date.getFullYear();
                        mm = ((mm.toString()).split('').length == 1) ? ('0' + mm) : mm;
                        var default_date_month = y + '-'+ mm + '-'+ dd;
                        default_date_month = new Date(default_date_month);
                        default_date_month = app_date_format_converter(default_date_month);
                        
                        if (batch_layout_namespace.general_form.getItemValue('chk_no_end_date') != 1) {
                            end_date_r_obj.setItemValue('dt_end_date', default_date_month);
                        }
                    }
                    
                    if (frequency == '8') {
                        batch_layout_namespace.general_form.showItem('week_days');                        
                    } else {
                        batch_layout_namespace.general_form.hideItem('week_days');                        
                    }
                    
                    if (frequency == '16') {
                        batch_layout_namespace.general_form.showItem('cmb_of_every');
                        batch_layout_namespace.general_form.showItem('cmb_days');
                        batch_layout_namespace.general_form.showItem('notes_of_every');
                    } else {
                        batch_layout_namespace.general_form.hideItem('cmb_of_every');
                        batch_layout_namespace.general_form.hideItem('cmb_days');
                        batch_layout_namespace.general_form.hideItem('notes_of_every');
                    }
                }                
            } else {
                batch_layout_namespace.general_form.uncheckItem('rdo_one_time', 'ONE_TIME');
                batch_layout_namespace.general_form.disableItem('schedule_type');
                batch_layout_namespace.general_form.disableItem('one_time_occurance');
                batch_layout_namespace.general_form.disableItem('recurring');
                start_date_obj.setItemValue('dt_date', '');
                start_date_r_obj.setItemValue('dt_start_date', '');
                end_date_r_obj.setItemValue('dt_end_date', '');
                end_date_r_obj.setRequired('dt_end_date', false);
            }
        }
    });
    
    function check_schedule_type(schedule_type) {
        if (schedule_type == 'ONE_TIME') {
            batch_layout_namespace.general_form.checkItem('rdo_one_time', 'ONE_TIME');
            batch_layout_namespace.general_form.enableItem('one_time_occurance');
            batch_layout_namespace.general_form.disableItem('recurring');
            start_date_obj.setItemValue('dt_date', default_date);
        } else if (schedule_type == 'RECURRING') {
            batch_layout_namespace.general_form.checkItem('rdo_one_time', 'RECURRING');
            batch_layout_namespace.general_form.disableItem('one_time_occurance');
            batch_layout_namespace.general_form.enableItem('recurring');
            start_date_r_obj.setItemValue('dt_start_date', active_start_date);
            end_date_r_obj.setItemValue('dt_end_date', active_end_date);            
            end_date_r_obj.setRequired('dt_end_date', true);
            holiday_calendar_obj.setComboValue(holiday_calendar); 
            
            var frequency = batch_layout_namespace.general_form.getItemValue('cmb_frequency_c');
            
            if (frequency == '8') {
                batch_layout_namespace.general_form.showItem('week_days');                        
            } else {
                batch_layout_namespace.general_form.hideItem('week_days');                        
            }
            
            if (frequency == '16') {
                batch_layout_namespace.general_form.showItem('cmb_of_every');
                batch_layout_namespace.general_form.showItem('cmb_days');
                batch_layout_namespace.general_form.showItem('notes_of_every');
            } else {
                batch_layout_namespace.general_form.hideItem('cmb_of_every');
                batch_layout_namespace.general_form.hideItem('cmb_days');
                batch_layout_namespace.general_form.hideItem('notes_of_every');
            }
        }       
    }
    
    var no_end_date_obj = batch_layout_namespace.general_form.getForm('chk_no_end_date');
    
    no_end_date_obj.attachEvent('onChange', function(name) {
        if (name == 'chk_no_end_date') {
            var no_end_date = (batch_layout_namespace.general_form.getItemValue('chk_no_end_date') == 1) ? 'y' : 'n';
    
            if (no_end_date == 'y') {
                batch_layout_namespace.general_form.disableItem('dt_end_date');
                end_date_r_obj.setItemValue('dt_end_date', '');
                end_date_r_obj.setRequired('dt_end_date', false);
            } else {
                batch_layout_namespace.general_form.enableItem('dt_end_date');
                var frequency = batch_layout_namespace.general_form.getItemValue('cmb_frequency_c');
                
                if (frequency == '4') {
                        var some_date = batch_layout_namespace.general_form.getItemValue('dt_start_date');
                        some_date = app_date_format_converter(some_date);
                        end_date_r_obj.setItemValue('dt_end_date', some_date);
                    } else if (frequency == '8') {
                        var some_date = batch_layout_namespace.general_form.getItemValue('dt_start_date');
                        var dd = some_date.getDate() + 7;
                        var mm = some_date.getMonth() + 1;
                        var y = some_date.getFullYear();
                        
                        mm = ((mm.toString()).split('').length == 1) ? ('0' + mm) : mm;
                        dd = ((dd.toString()).split('').length == 1) ? ('0' + dd) : dd;
                        
                        var default_date_week = y + '-'+ mm + '-'+ dd;
                        default_date_week = new Date(default_date_week);
                        default_date_week = app_date_format_converter(default_date_week);
                        
                        end_date_r_obj.setItemValue('dt_end_date', default_date_week);
                    } else if (frequency == '16') {
                        var some_date = batch_layout_namespace.general_form.getItemValue('dt_start_date');
                        var dd = some_date.getDate();
                        var mm = some_date.getMonth() + 2;
                        var y = some_date.getFullYear();
                        
                        mm = ((mm.toString()).split('').length == 1) ? ('0' + mm) : mm;
                        dd = ((dd.toString()).split('').length == 1) ? ('0' + dd) : dd;
                        
                        var default_date_month = y + '-'+ mm + '-'+ dd;
                        
                        default_date_month = new Date(default_date_month);
                        default_date_month = app_date_format_converter(default_date_month);
                        
                        end_date_r_obj.setItemValue('dt_end_date', default_date_month);
                    }
                
                end_date_r_obj.setRequired('dt_end_date', true);
            }
        }
    });
    
";

//closing the layout of the main layout.
echo $layout->close_layout();
?>
<script type="text/javascript">
    var report_name = parent.batch_win.getText();
    var app_date_format = '<?php echo $date_format; ?>';
    var date_separator = app_date_format.split('')[2];
    var batch_layout_namespace = {};
    var report_type = '<?php echo $report_type; ?>';
    var exec_call = "<?php echo ($flag == 'x') ? addslashes($exec_call) : $exec_call; ?>";
    var is_stmt = '<?php echo $is_stmt; ?>';
    
    $(function() {
        batch_layout_namespace.batch_process_tabs.setTabsMode("bottom");        
        var cmb_as_of_date_c_obj = batch_layout_namespace.general_form.getCombo('cmb_as_of_date_c');
        cmb_as_of_date_c_obj.enableFilteringMode(true);

        var txt_no_of_days_obj = batch_layout_namespace.general_form.getCombo('txt_no_of_days');
        txt_no_of_days_obj.enableFilteringMode(true);

        var cmb_hour_c_obj = batch_layout_namespace.general_form.getCombo('cmb_hour_c');
        cmb_hour_c_obj.enableFilteringMode(true);

        var cmb_min_c_obj = batch_layout_namespace.general_form.getCombo('cmb_min_c');
        cmb_min_c_obj.enableFilteringMode(true);

        var cmb_frequency_c_obj = batch_layout_namespace.general_form.getCombo('cmb_frequency_c');
        cmb_frequency_c_obj.enableFilteringMode(true);

        var cmb_holiday_calendar_c_obj = batch_layout_namespace.general_form.getCombo('cmb_holiday_calendar_c');
        cmb_holiday_calendar_c_obj.enableFilteringMode(true);

        var cmb_recurring_c_obj = batch_layout_namespace.general_form.getCombo('cmb_recurring_c');
        cmb_recurring_c_obj.enableFilteringMode(true);

        var cmb_hour_rec_obj = batch_layout_namespace.general_form.getCombo('cmb_hour_rec');
        cmb_hour_rec_obj.enableFilteringMode(true);

        var cmb_minute_rec_obj = batch_layout_namespace.general_form.getCombo('cmb_minute_rec');
        cmb_minute_rec_obj.enableFilteringMode(true);

        var cmb_days_obj = batch_layout_namespace.general_form.getCombo('cmb_days');
        cmb_days_obj.enableFilteringMode(true);

        var cmb_of_every_obj = batch_layout_namespace.general_form.getCombo('cmb_of_every');
        cmb_of_every_obj.enableFilteringMode(true);

        var cmb_export_format_obj = batch_layout_namespace.report_form.getCombo('cmb_export_format');
        cmb_export_format_obj.enableFilteringMode(true);

        var cmb_delimiter_c_obj = batch_layout_namespace.report_form.getCombo('cmb_delimiter_c');
        cmb_delimiter_c_obj.enableFilteringMode(true);

        var cmb_notification_type_obj = batch_layout_namespace.notification_form.getCombo('cmb_notification_type');
        cmb_notification_type_obj.enableFilteringMode(true);
        var batch_type = '<?php echo $batch_type; ?>';

        if (batch_type == 'remit') {
            batch_layout_namespace.report_form.hideItem('cmb_delimiter_c');
            batch_layout_namespace.report_form.showItem('cmb_xml_format_c');
            batch_layout_namespace.report_form.hideItem('chk_display_header');
        }

        var cmb_export_format_obj = batch_layout_namespace.report_form.getCombo('cmb_export_format');
        var file_transfer_endpoint_id = batch_layout_namespace.report_form.getItemValue('cmb_file_transfer_endpoint_id');
        file_transfer_endpoint_id = file_transfer_endpoint_id.substr(file_transfer_endpoint_id.indexOf('|')+1);
        var export_to_ftp_directory = batch_layout_namespace.report_form.getItemValue('txt_export_to_ftp_directory');
        
        if (file_transfer_endpoint_id != '') {
            file_transfer_endpoint_id = '(' + file_transfer_endpoint_id + '/' + export_to_ftp_directory + ')';                
            batch_layout_namespace.report_form.setItemLabel('endpoint_label',file_transfer_endpoint_id);
        }
                
    });

    function btn_ok_click (arg) {
        switch (arg) {
            case 'ok':
                var call_from = '<?php echo $call_from; ?>';
                var flag = '<?php echo $flag; ?>';
                var gen_as_of_date = '<?php echo $gen_as_of_date; ?>';
                var batch_unique_id = '<?php echo uniqid(); ?>'; 
                var source = '<?php echo $source; ?>';
                var job_id = '<?php echo $job_id; ?>';
                var schedule_id = '<?php echo $schedule_id; ?>';
                var as_of_date_value = '<?php echo $as_of_date_value; ?>';
                var batch_type = '<?php echo $batch_type; ?>';
                var gen_as_of_date = '<?php echo $gen_as_of_date; ?>';
                
                //General Tab Fields
                var job_name = batch_layout_namespace.general_form.getItemValue('txt_job_name');
                var as_of_date = batch_layout_namespace.general_form.getItemValue('cmb_as_of_date_c');
                var no_of_days = batch_layout_namespace.general_form.getItemValue('txt_no_of_days');
                var custom_as_of_date = batch_layout_namespace.general_form.getItemValue('dt_custom_as_of_date', true);
                var run_mode = batch_layout_namespace.general_form.getItemValue('rdo_run_mode');
                var one_time = batch_layout_namespace.general_form.getItemValue('rdo_one_time');
                var date_time_now = '<?php echo getCurrentDate('t'); ?>'; 
                var split_date_time = date_time_now.split(" ");
                var time_now = split_date_time[1].split(':');
                var frequency = batch_layout_namespace.general_form.getItemValue('cmb_frequency_c');
                var holiday_calendar = batch_layout_namespace.general_form.getItemValue('cmb_holiday_calendar_c');
                var today_date_time = new_date_construct(split_date_time[0], time_now[0], time_now[1]);
                
                //Report Tab Fields

                var export_format = batch_layout_namespace.report_form.getItemValue('cmb_export_format');
                var xml_format = batch_layout_namespace.report_form.getItemValue('cmb_xml_format_c');
                xml_format = (xml_format == '') ? 'NULL' : xml_format;
                var delimiter = batch_layout_namespace.report_form.getItemValue('cmb_delimiter_c');
                var display_header = (batch_layout_namespace.report_form.getItemValue('chk_display_header') == 1) ? '1' : '0';
                var compress_file = (batch_layout_namespace.report_form.getItemValue('chk_compress_file') == 1) ? 'y' : 'n';
                var export_to_directory = batch_layout_namespace.report_form.getItemValue('txt_export_to_directory');
                var export_to_table = batch_layout_namespace.report_form.getItemValue('txt_export_to_table'); 
                var export_report_name = batch_layout_namespace.report_form.getItemValue('txt_export_report_name');
                var web_services = batch_layout_namespace.report_form.getItemValue('cmb_post_to_web');
                var file_transfer_endpoint_id = batch_layout_namespace.report_form.getItemValue('cmb_file_transfer_endpoint_id');
                file_transfer_endpoint_id = file_transfer_endpoint_id.substr(0,file_transfer_endpoint_id.indexOf('|'));
                var export_to_ftp_directory = batch_layout_namespace.report_form.getItemValue('txt_export_to_ftp_directory');
                
                if (/[^a-zA-Z0-9\_\ \/]/.test(export_to_table)) {
                    show_messagebox('Special characters except space are not allowed.');
                    return;
                }
                
                //Notification Tab Fields
                var notification_type = batch_layout_namespace.notification_form.getItemValue('cmb_notification_type');
                var to_users = batch_layout_namespace.notification_form.getOptions('user_to');
                var to_role = batch_layout_namespace.notification_form.getOptions('role_to');
                var user_list = get_all_list_values(to_users);
                var role_list = get_all_list_values(to_role);

                var non_sys_users = batch_layout_namespace.notification_form.getItemValue('txt_send_email');
                var attach_report = (batch_layout_namespace.notification_form.getItemValue('chk_attach_report') == 1) ? 'y' : 'n';
                var decode_non_sys_users = decodeURIComponent(non_sys_users);
                var split_non_sys_users = decode_non_sys_users.split(';');
                var temp_csv_path = <?php echo "'" . addslashes(addslashes($BATCH_FILE_EXPORT_PATH)) . "'"; ?> ;
                temp_csv_path = temp_csv_path.replace(/\\\\/g, '\\');

                if (flag == 'x') flag = 'i';
                var data = '';
               
                if ((custom_as_of_date == '' || custom_as_of_date == null) && as_of_date == 'DATE.C') {
                    var message = 'Please enter Custom As Of Date.'
                    show_messagebox(message);
                    return;
                }

                for (var i = 0; i < split_non_sys_users.length; i++) {
                    if (split_non_sys_users[i] != '') { 
                        if (isEmail(split_non_sys_users[i]) == false) {
                            var message = 'Please enter a valid e-mail address for ' + singleQuote(split_non_sys_users[i]);                            
                            show_messagebox(message);
                            return;
                        } 
                    }
                }
                
                if (gen_as_of_date == 1)
                    var as_of_date = batch_layout_namespace.general_form.getItemValue('dt_custom_as_of_date', true);
                
                if (gen_as_of_date == 1) 
                    var custom_as_of_date_minus = batch_layout_namespace.general_form.getItemValue('txt_no_of_days');
            
                if (gen_as_of_date == 1) {
                    var type_as_of_date = batch_layout_namespace.general_form.getItemValue('cmb_as_of_date_c');
                    custom_as_of_date_minus = batch_layout_namespace.general_form.getItemValue('txt_no_of_days');
                    var d_val_split = custom_as_of_date_minus.split('.');
                    
                    if (type_as_of_date == 'DATE.X') {
                        if (custom_as_of_date_minus == 'NULL') {
                            show_messagebox("Please enter 'No of Days'.");
                            return;
                        } else if ((!isNum(custom_as_of_date_minus)) || custom_as_of_date_minus < 0) {
                            show_messagebox("'No of Days' should be an positive integer.");
                            return;
                        } else if(d_val_split.length > 1) {
                            show_messagebox("'No. of Days' should not be a decimal value.");
                            return;
                        } else {
                            type_as_of_date = 'DATE.' + custom_as_of_date_minus;
                        }
                    } else if (type_as_of_date == 'DATE.C') {
                        type_as_of_date = dates.convert_to_sql(as_of_date);
                    }
                    
                    exec_call = exec_call.replace('$AS_OF_DATE$', type_as_of_date);
                } else {
                    type_as_of_date = '';
                }
                var export_ext = '';
                if (export_format == '.csv') {
                    export_ext = 'CSV';
                } else if (export_format == '.xml') {
                    export_ext = 'XML';
                } else if (export_format == '.txt') {
                    export_ext = 'TEXT';
                } else {
                    export_ext = 'EXCELOPENXML';
                }
                var date_time = '<?php echo date('Y_m_d_His');; ?>';
                var user_name = js_user_name;

                if(export_report_name !== '') {
                    report_name = export_report_name;
                }

                var report_file = report_name + "_" + user_name  + export_format;
                var report_file_path = '<?php echo addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL']) ?>' + '\\' + report_file;
                var paramset_hash = '<?php echo $paramset_hash; ?>'

                if (call_from == 'Report Batch Job') {
                    exec_call = exec_call + ", @report_file_name='" + report_file + "'" + ", @report_file_full_path='" + report_file_path + "'" + ", @output_file_format='" + export_ext + "'" + ", @paramset_hash='" + paramset_hash + "'";
                }

                if (report_type !== 'Standard Report') {
                    if(export_report_name !== '' && flag != 'u') {
                        exec_call += ', @export_report_name="' + export_report_name + '"';
                    }
                }

                //For Invoice Start
                if (call_from == 'invoice') {
                    var send_option = (batch_layout_namespace.notification_form.getItemValue('chk_as_defined') == 1) ? 'y' : 'n';
                    var delivery_method = 'NULL';
                    var printer = '';//batch_layout_namespace.notification_form.getItemValue('cmb_printer');
                    if (send_option == 'n') {
                        delivery_method = batch_layout_namespace.notification_form.getItemValue('cmb_delivery_method');
                    }
                    
                    var invoice_ids = "<?php echo $invoice_ids ?? ''; ?>";
                    var reporting_param = '<?php echo $reporting_param ?? ''; ?>';
                    var report_file_path = '<?php echo $report_file_path ?? ''; ?>';
                    var report_folder = "<?php echo $report_folder ?? ''; ?>";
                }

                if (run_mode == 'r') {
                    if (call_from == 'invoice' && is_stmt!= 1) {
                        data = {
                                    "action":                   "spa_print_invoices",
                                    "flag":                     'g',
                                    "report_name":              job_name,
                                    "invoice_ids":              invoice_ids,
                                    "reporting_param":          reporting_param,
                                    "report_file_path":         report_file_path,
                                    "report_folder":            report_folder,
                                    "notify_users":             user_list,
                                    "notify_roles":             role_list,
                                    "batch_process_id":         batch_unique_id,
                                    "export_csv_path":          export_to_directory,
                                    "non_system_users":         decode_non_sys_users, 
                                    "send_option":              send_option,
                                    "delivery_method":          delivery_method, 
                                    "printer_name":             printer
                                }
                    } else if (call_from == 'invoice' && is_stmt== 1) {
                        data = {
                                    "action":                   "spa_stmt_invoice",
                                    "flag":                     'e',
                                    "stmt_invoice_id":          invoice_ids,
                                    "notify_users":             user_list,
                                    "notify_roles":             role_list,
                                    "non_system_users":         decode_non_sys_users,
									"send_option":              send_option
                               }
                    } else { 

                        // Set export format for excel addin reports.
                        if (call_from == 'Report Batch Job Excel Addin') {
                            get_export_format = batch_layout_namespace.report_form.getCombo('cmb_export_format') .getSelectedValue();
                            if (get_export_format == '.pdf') {
                                get_export_format = 'PDF';
                            } else if (get_export_format == '.xlsx') {
                                get_export_format = 'XLSX';
                            } else {
                                get_export_format = get_export_format.split(".")[1].toUpperCase();
                            }
                            exec_call += ", @export_format='" + get_export_format + "'";
                        }
                        
                        data = {
                                "action":                       "batch_report_process",
                                "spa":                          exec_call,
                                "flag":                         flag,
                                "jobId":                        '',
                                "scheduleId":                   '',
                                "report_name":                  job_name,
                                "active_start_date":            '',
                                "active_start_time":            '',
                                "freq_type":                    '',
                                "freq_interval":                '',
                                "freq_subday_type":             '',
                                "freq_subday_interval":         '',
                                "freq_relative_interval":       '',
                                "freq_recurrence_factor":       '',
                                "active_end_date":              '',
                                "active_end_time":              '',
                                "batch_type":                   batch_type,
                                "generate_dynamic_params":      gen_as_of_date,
                                "custom_as_of_date":            type_as_of_date,
                                "notify_users":                 user_list,
                                "notify_roles":                 role_list,
                                "notification_type":            notification_type,
                                "send_attachment":              attach_report,
                                "batch_unique_id":              batch_unique_id,
                                "source":                       source,
                                "csv_path":                     export_to_directory,
                                "login_id":                     '',
                                "holiday_calendar_id":          '',
                                "non_sys_users":                decode_non_sys_users,
                                "temp_notes_path":              temp_csv_path,
                                "export_table_name":            export_to_table,
                                "export_table_name_suffix":     '',
                                "compress_file":                compress_file,                                
                                "delim":                        delimiter,
                                "is_header":                    display_header,                              
                                "xml_format":                   xml_format,                             
                                "export_file_format":           export_format,
                                "ftp_folder_path":              export_to_ftp_directory,
                                "debug_mode":                   '',
                                "export_web_services_id":       web_services,
                                "file_transfer_endpoint_id":    file_transfer_endpoint_id
                        };
                    }
                    
                    //$("*").css("cursor", "progress");
                    batch_layout_namespace.batch_process_layout.cells("a").progressOn();
                    adiha_post_data('alert', data, '', '', 'call_back_msg');  
                } else {
                    var schedule_type = batch_layout_namespace.general_form.getItemValue('rdo_one_time');
                    
                    if (schedule_type == 'ONE_TIME') {
                        var active_start_date = batch_layout_namespace.general_form.getItemValue('dt_date', true);
                        var one_time_occurence_hour = batch_layout_namespace.general_form.getItemValue('cmb_hour_c');
                        var one_time_occurence_minute = batch_layout_namespace.general_form.getItemValue('cmb_min_c');
                        
                        one_time_occurence_minute = (one_time_occurence_minute.length == 1) ? ('0' + one_time_occurence_minute) : one_time_occurence_minute;            
                        one_time_occurence_hour = (one_time_occurence_hour.length == 1) ? ('0' + one_time_occurence_hour) : one_time_occurence_hour;
                        
                        var active_start_time = one_time_occurence_hour + one_time_occurence_minute + "00";
                        var freq_type = 1;
                        var active_end_date = 'NULL';
                        var freq_interval = 'NULL';
                        var freq_subday_type = 'NULL';
                        var freq_recurrence_factor = 'NULL';
                        var one_time_as_of_date_from = batch_layout_namespace.general_form.getItemValue('dt_date', true);
                        var selected_date_time = new_date_construct(one_time_as_of_date_from, one_time_occurence_hour, one_time_occurence_minute);
                        
                        if (selected_date_time < today_date_time) {
                            show_messagebox('You are not allowed to schedule a batch process for past date/time.');
                            return;
                        } 
                    } else {
                        if (frequency == '4') {
                            var freq_type = 4;
                            var freq_interval = batch_layout_namespace.general_form.getItemValue('cmb_recurring_c');
                            var freq_subday_type = 0;
                            var freq_recurrence_factor = 0;
                            var active_start_date = batch_layout_namespace.general_form.getItemValue('dt_start_date', true);
                            
                            var date = new Date();
                            var recurring_hour = batch_layout_namespace.general_form.getItemValue('cmb_hour_rec');
                            var recurring_min = batch_layout_namespace.general_form.getItemValue('cmb_minute_rec');
                            var selected_date_time_start = new_date_construct(active_start_date, recurring_hour, recurring_min);
                            
                            if (selected_date_time_start < today_date_time) {
                                var message = 'You are not allowed to schedule a batch process for past date/time.';
                                show_messagebox(message);
                                return;
                            }
                            
                            recurring_min = (recurring_min.length == 1) ? ('0' + recurring_min) : recurring_min; 
                            recurring_hour = (recurring_hour.length == 1) ? ('0' + recurring_hour) : recurring_hour;    
                               
                            var active_start_time = recurring_hour + recurring_min + '00'; 
                            var no_end_date = (batch_layout_namespace.general_form.getItemValue('chk_no_end_date') == 1) ? 'y' : 'n';
                            
                            if (no_end_date == 'n') {
                                var active_end_date = batch_layout_namespace.general_form.getItemValue('dt_end_date', true);
                                var selected_date_time_end = new_date_construct(active_end_date, recurring_hour, recurring_min);
                                
                                if (selected_date_time_end < today_date_time) {
                                    var message = 'You are not allowed to schedule a batch process for past date/time.';
                                    show_messagebox(message);
                                    return;
                                }
                                
                                if (selected_date_time_start > selected_date_time_end) {                                    
                                    var message = 'Start Date cannot be greater than End Date.';
                                    show_messagebox(message);
                                    return;
                                }
                                
                                if (selected_date_time_end < today_date_time) {
                                    var message = 'End date cannot be less than today\'s date.';
                                    show_messagebox(message);
                                    return;
                                }                                                        
                            } else {
                                var active_end_date = 'NULL';
                            }
                        } else if (frequency == '8') {
                            var freq_type = 8;
                            var sunday = (batch_layout_namespace.general_form.getItemValue('chk_sunday') == 1) ? 'y' : 'n';
                            var monday = (batch_layout_namespace.general_form.getItemValue('chk_monday') == 1) ? 'y' : 'n';
                            var tuesday = (batch_layout_namespace.general_form.getItemValue('chk_tuesday') == 1) ? 'y' : 'n';
                            var wednesday = (batch_layout_namespace.general_form.getItemValue('chk_wednesday') == 1) ? 'y' : 'n';
                            var thursday = (batch_layout_namespace.general_form.getItemValue('chk_thursday') == 1) ? 'y' : 'n';
                            var friday = (batch_layout_namespace.general_form.getItemValue('chk_friday') == 1) ? 'y' : 'n';
                            var saturday = (batch_layout_namespace.general_form.getItemValue('chk_saturday') == 1) ? 'y' : 'n';
                            
                            if (sunday == 'n' && monday == 'n' && tuesday == 'n' && wednesday == 'n' && thursday == 'n' && friday == 'n' && saturday == 'n') {
                                var message = 'Please select day(s) of the week.';
                                show_messagebox( message);
                                return;    
                            }
                            
                            var day1 = (sunday == 'y') ? 1 : 0;
                            var day2 = (monday == 'y') ? 2 : 0;
                            var day3 = (tuesday == 'y') ? 4 : 0;
                            var day4 = (wednesday == 'y') ? 8 : 0;
                            var day5 = (thursday == 'y') ? 16 : 0;
                            var day6 = (friday == 'y') ? 32 : 0;
                            var day7 = (saturday == 'y') ? 64 : 0;
                            
                            var freq_interval = day1 + day2 + day3 + day4 + day5 + day6 + day7;
                            var freq_subday_type = 1; 
                            var freq_recurrence_factor = batch_layout_namespace.general_form.getItemValue('cmb_recurring_c');
                            var active_start_date = batch_layout_namespace.general_form.getItemValue('dt_start_date', true);
                            var active_start_date_c = batch_layout_namespace.general_form.getItemValue('dt_start_date');
                            var recurring_hour = batch_layout_namespace.general_form.getItemValue('cmb_hour_rec');
                            var recurring_min = batch_layout_namespace.general_form.getItemValue('cmb_minute_rec');
                            var selected_date_time_start = new_date_construct(active_start_date, recurring_hour, recurring_min);
                            
                            if (selected_date_time_start < today_date_time) {
                                var message = 'You are not allowed to schedule a batch process for past date/time.';
                                show_messagebox(message);
                                return;
                            }
                            
                            if (freq_recurrence_factor < 1) {
                                var message = 'Recurs Every must be at least 1 for weekly Frequency.';
                                show_messagebox( message);
                                return; 
                            }
                            
                            var recurring_hour = batch_layout_namespace.general_form.getItemValue('cmb_hour_rec');
                            var recurring_min = batch_layout_namespace.general_form.getItemValue('cmb_minute_rec');
                            var day_array = new Array();
                            
                            if (sunday = 'y')
                                day_array.push(1);
                        
                            if (monday = 'y')
                                day_array.push(2);
                        
                            if (tuesday = 'y')
                                day_array.push(3);
                        
                            if (wednesday = 'y')
                                day_array.push(4);
                        
                            if (thursday = 'y')
                                day_array.push(5);
                        
                            if (friday = 'y')
                                day_array.push(6);
                        
                            if (saturday = 'y')
                                day_array.push(0);
                                
                            recurring_hour = (recurring_hour.length == 1) ? ('0' + recurring_hour) : recurring_hour;
                            recurring_min = (recurring_min.length == 1) ? ('0' + recurring_min) : recurring_min;
                            
                            var active_start_time = recurring_hour + recurring_min + '00';
                            
                            var no_end_date = (batch_layout_namespace.general_form.getItemValue('chk_no_end_date') == 1) ? 'y' : 'n';
                            
                            if (no_end_date == 'n') {
                                var active_end_date_c = batch_layout_namespace.general_form.getItemValue('dt_end_date');
                                var active_end_date = batch_layout_namespace.general_form.getItemValue('dt_end_date', true);
                                
                                if (!check_days(day_array, active_start_date, active_end_date)) {
                                    var message = 'Cannot schedule the batch process. Run date does not fall within the given duration.';
                                    show_messagebox(message);
                                    return;
                                }
                                
                                if (!check_date_time_in_given_week(day_array, active_start_date, active_end_date, active_start_time)) {
                                    var message = 'Cannot schedule the batch process. Run date does not fall within the given duration.';
                                    show_messagebox(message);
                                    return;
                                }
                                
                                var active_start_date_cmp = new Date(active_start_date);
                                var active_end_date_cmp = new Date(active_end_date);
                                
                                if (active_start_date_cmp > active_end_date_cmp) {
                                    var message = 'Start Date cannot be greater than End Date.';
                                    show_messagebox(message);
                                    return;
                                }
                                
                                if (active_end_date < today_date_time) {
                                    var message = 'End date cannot be less than today\'s date.';
                                    show_messagebox(message);
                                    return;
                                }
                                
                                var run_date_time = new_date_construct(active_start_date, recurring_hour, recurring_min);
                                
                                if (active_start_date == active_end_date && run_date_time < today_date_time) {
                                    var message = 'You are not allowed to schedule a batch process for past date/time.';
                                    show_messagebox(message);
                                    return;
                                }
                            } else {
                                var active_end_date = 'NULL';
                            }
                        } else if (frequency == '16') {
                            var freq_type = 16;
                            var freq_interval = batch_layout_namespace.general_form.getItemValue('cmb_days');
                            
                            if (freq_interval == '') {
                                var message = 'Please select the occurs day.';
                                show_messagebox(message);
                                return;
                            }
                            
                            var freq_subday_type = 1;
                            var freq_recurrence_factor = batch_layout_namespace.general_form.getItemValue('cmb_of_every');
                            
                             if (freq_recurrence_factor == '') {
                                var message = 'Please select the occurs month.';
                                show_messagebox(message);
                                return;
                            }
                            
                            var recurring_hour = batch_layout_namespace.general_form.getItemValue('cmb_hour_rec');
                            var recurring_min = batch_layout_namespace.general_form.getItemValue('cmb_minute_rec');
                            var active_start_date = batch_layout_namespace.general_form.getItemValue('dt_start_date', true);
                            var active_start_time = recurring_hour + recurring_min + '00';
                            var no_end_date = (batch_layout_namespace.general_form.getItemValue('chk_no_end_date') == 1) ? 'y' : 'n';
                            
                            if (app_date_format.split('')[1] == 'n' || app_date_format.split('')[1] == 'm') {
                                var start_year_field = active_start_date.split(date_separator)[2];
                                var start_day_field = active_start_date.split(date_separator)[1];
                                var start_month_field = active_start_date.split(date_separator)[0];
                            } else {
                                var start_year_field = active_start_date.split(date_separator)[2];
                                var start_month_field = active_start_date.split(date_separator)[1];
                                var start_day_field = active_start_date.split(date_separator)[0];
                            }
                                
                            start_month_field = ((start_month_field.toString()).split('').length == 1) ? ('0' + start_month_field) : start_month_field;
                            start_day_field = ((start_day_field.toString()).split('').length == 1) ? ('0' + start_day_field) : start_day_field;    
                            
                            var start_date = start_year_field + date_separator + start_month_field + date_separator + start_day_field;
                            start_date = new Date(start_date);
                            start_date = app_date_format_converter(start_date);
                            start_date = new_date_construct(start_date, recurring_hour, recurring_min);
                            
                            if (no_end_date == 'n') {
                                var active_end_date = batch_layout_namespace.general_form.getItemValue('dt_end_date', true);
                                var end_date = new Date(active_end_date);
                                
                                if (start_date < today_date_time) {
                                    var message = 'You are not allowed to schedule a batch process for past date/time.';
                                    show_messagebox(message);
                                    return;
                                }
                                
                                var active_start_date_cmp = new Date(active_start_date);
                                var active_end_date_cmp = new Date(active_end_date);
                                
                                if (active_start_date_cmp > active_end_date_cmp) {
                                    var message = 'Start Date cannot be greater than End Date.';
                                    show_messagebox(message);
                                    return;
                                }
                                
                                if (end_date < today_date_time) {
                                    var message = 'End date cannot be less than today\'s date.';
                                    show_messagebox(message);
                                    return;
                                }
                               
                                var start_date1 = new_date_construct(active_start_date, time_now[0], time_now[1]);
                                var end_date1 = new_date_construct(active_end_date, 23,59,59);
                                var month_diff = Math.floor(((Date.parse(end_date1) -  Date.parse(start_date1)) % 31536000000) / 2628000000);
                                                                
                                var correct_date = false;
                                month_diff = month_diff + 1;
                                
                                if (month_diff >= freq_recurrence_factor) {
                                    for (var i = 0; i < month_diff; i++) {
                                        var chk_mon = parseInt(start_month_field) + parseInt(i);
                                        
                                        chk_mon = ((chk_mon.toString()).split('').length == 1) ? ('0' + chk_mon) : chk_mon;
                                        freq_interval = ((freq_interval.toString()).split('').length == 1) ? ('0' + freq_interval) : freq_interval;
                                        
                                        var new_date = start_year_field + '-' + chk_mon + '-' + freq_interval;
                                        
                                        new_date = new Date(new_date);
                                        new_date = app_date_format_converter(new_date); 
                                        new_date = new_date_construct(new_date, recurring_hour, recurring_min);
                                                                                
                                        var new_day = new_date.getDate();
                                        
                                        if (new_day == freq_interval && new_date >= start_date1 && new_date <= end_date1) {
                                            correct_date = true;
                                            break;
                                        }
                                    }
                                } else {
                                    correct_date = true;
                                }
                                
                                if (!correct_date) {
                                    var message = 'Cannot schedule the batch process. Run date does not fall within the given duration.';
                                    show_messagebox(message);
                                    return;
                                }                                
                            } else {
                                var active_end_date = 'NULL';
                            }                            
                        }
                    }
                    
                    var job_id = '<?php echo $job_id; ?>';
                    var schedule_id = '<?php echo $schedule_id; ?>';
                    var active_end_time = active_start_time;
                     
                    active_start_date = (active_start_date != 'NULL') ? dates.convert_to_sql(active_start_date) : active_start_date;
                    active_end_date = (active_end_date != 'NULL') ? dates.convert_to_sql(active_end_date) : active_end_date;

                    if (call_from == 'invoice' && is_stmt!= 1) {
                        data = {
                            "action": "spa_print_invoices",
                            "flag": 'g',
                            "report_name": job_name,
                            "invoice_ids": invoice_ids,
                            "reporting_param": reporting_param,
                            "report_file_path": report_file_path,
                            "report_folder": report_folder,
                            "notify_users": user_list,
                            "notify_roles": role_list,
                            "batch_process_id": batch_unique_id,
                            "export_csv_path": export_to_directory,
                            "non_system_users": decode_non_sys_users, 
                            "send_option": send_option,
                            "delivery_method": delivery_method, 
                            "printer_name": printer,
                            "active_start_date": active_start_date,
                            "active_start_time": active_start_time,
                            "freq_type": freq_type,
                            "freq_interval": freq_interval,
                            "active_end_date": active_end_date,
                            "freq_subday_type": freq_subday_type,
                            "freq_recurrence_factor": freq_recurrence_factor,
                            "holiday_calendar_id": holiday_calendar
                        }
                    } else if (call_from == 'invoice' && is_stmt== 1) {
                        data = {
                            "action":  "spa_stmt_invoice",
                            "flag": 'e',
                            "stmt_invoice_id": invoice_ids,
                            "notify_users": user_list,
                            "notify_roles": role_list,
                            "non_system_users": decode_non_sys_users,
							"send_option": send_option
                         };
                                
                    } else {
                        data = {        
                            "action": "batch_report_process",
                            "spa": exec_call,
                            "flag": flag,
                            "jobId": job_id,
                            "scheduleId": schedule_id,
                            "report_name": job_name,
                            "active_start_date": active_start_date,
                            "active_start_time": active_start_time,
                            "freq_type": freq_type,
                            "freq_interval": freq_interval,
                            "freq_subday_type": freq_subday_type,
                            "freq_subday_interval": '',
                            "freq_relative_interval": '',
                            "freq_recurrence_factor": freq_recurrence_factor,
                            "active_end_date": active_end_date,
                            "active_end_time": active_end_time,
                            "batch_type": batch_type,
                            "generate_dynamic_params": '',
                            "custom_as_of_date": type_as_of_date,
                            "notify_users": user_list,
                            "notify_roles": role_list,
                            "notification_type": notification_type,
                            "send_attachment": attach_report,
                            "batch_unique_id": batch_unique_id,
                            "source": source,
                            "csv_path": export_to_directory,
                            "login_id": '',
                            "holiday_calendar_id": holiday_calendar,
                            "non_sys_users": decode_non_sys_users,
                            "temp_notes_path": temp_csv_path,
                            "export_table_name": export_to_table,
                            "export_table_name_suffix": '',
                            "compress_file": compress_file,
                            "delim": delimiter,
                            "is_header": display_header,
                            "xml_format": xml_format, 
                            "export_file_format": export_format,
                            "ftp_folder_path": export_to_ftp_directory,
                            "debug_mode": '',
                            "export_web_services_id": web_services,
                            "file_transfer_endpoint_id":    file_transfer_endpoint_id
                        };
                    }
                        
                    batch_layout_namespace.batch_process_layout.cells("a").progressOn();
                    adiha_post_data('alert', data, '', '', 'call_back_msg');
                }
                
            break;
        }
    }
    
    function call_back_msg(array) {
        var call_from = '<?php echo $call_from; ?>';
        var flag = '<?php echo $flag; ?>';
        var export_format = batch_layout_namespace.report_form.getItemValue('cmb_export_format');
        
        if(array[0]['errorcode'] == 'Success') {
            if (call_from == '' && flag == 'x') {
                setTimeout('parent.grid_refresh_after();', 1000);
            } else if (call_from == 'remit') {
                setTimeout('parent.remit_submission.refresh_grid();', 1000);
            } else if (call_from == 'approve_gen_link') {
                setTimeout('parent.view_outst_ns.refresh_grd_view_hedge_group();', 1000);
            }
            setTimeout('parent.batch_win.close()', 1000);
        }

        batch_layout_namespace.batch_process_layout.cells('a').progressOff();

    }
    
    function check_date_time_in_given_week(days, start_date, end_date, start_time) {
        if (app_date_format.split('')[1] == 'n' || app_date_format.split('')[1] == 'm') {
            var start_year_field = start_date.split(date_separator)[2];
            var start_day_field = start_date.split(date_separator)[1];
            var start_month_field = start_date.split(date_separator)[0];
            var end_year_field = end_date.split(date_separator)[2];
            var end_day_field = end_date.split(date_separator)[1];
            var end_month_field = end_date.split(date_separator)[0];
        } else {
            var start_year_field = start_date.split(date_separator)[2];
            var start_month_field = start_date.split(date_separator)[1];
            var start_day_field = start_date.split(date_separator)[0];
            var end_year_field = end_date.split(date_separator)[2];
            var end_month_field = end_date.split(date_separator)[1];
            var end_day_field = end_date.split(date_separator)[0];
        }
        
        var start_date = new Date(start_year_field, start_month_field - 1, start_day_field);
        var end_date = new Date(end_year_field, end_month_field - 1, end_day_field);    
        var day_len = days.length;
        var result = false;
        var now_date_time = new Date();
        var hour = start_time.substr(0, 2);
        var minute = start_time.substr(2, 2);
        var check_date_time;
    
        while (start_date <= end_date) {
            var start_date_obj = app_date_format_converter(start_date);
            check_date_time = new_date_construct(start_date_obj, hour, minute);

            for (var i = 0; i < day_len; i++) {
                if (check_date_time.getDay() == days[i]) {
                    var result = true;
                    break;                
                } else {
                    result = false;
                }
            }
                
            if (result && check_date_time > now_date_time) {
                return true;
            }
                
            start_date.setDate(start_date.getDate() + 1);        
        }
        
        return false;
    }
    
    function check_days(days, start_date, end_date) {
        if (app_date_format.split('')[1] == 'n' || app_date_format.split('')[1] == 'm') {
            var start_year_field = start_date.split(date_separator)[2];
            var start_day_field = start_date.split(date_separator)[1];
            var start_month_field = start_date.split(date_separator)[0];
            var end_year_field = end_date.split(date_separator)[2];
            var end_day_field = end_date.split(date_separator)[1];
            var end_month_field = end_date.split(date_separator)[0];
        } else {
            var start_year_field = start_date.split(date_separator)[2];
            var start_month_field = start_date.split(date_separator)[1];
            var start_day_field = start_date.split(date_separator)[0];
            var end_year_field = end_date.split(date_separator)[2];
            var end_month_field = end_date.split(date_separator)[1];
            var end_day_field = end_date.split(date_separator)[0];
        }
        
        var start_date = new Date(start_year_field, start_month_field - 1, start_day_field);
        var end_date = new Date(end_year_field, end_month_field - 1, end_day_field);        
        var start_day = start_date.getDay();
        var end_day = end_date.getDay();
        var day_len = days.length;
        var result = false;

        for (var i = 0; i < day_len; i++) {
            if (start_day > end_day) {
                result = result || parseInt(days[i]) >= start_day || parseInt(days[i]) + 7 <= end_day + 7;
            } else { 
                result = result || parseInt(days[i]) >= start_day && parseInt(days[i]) <= end_day;
            }
        }
        
        return result;
    }
    
    function close_batch_process() {
        parent.edit_popup.hide();
    }
    
    $(function(){
        batch_layout_namespace.notification_form.attachEvent('onButtonClick', function(id) {
            if (id == 'add_user' || id == 'remove_user') {
                change_contact_state(id == 'add_user', 'user_from', 'user_to');
            } else if (id == 'add_role' || id == 'remove_role') {
                change_contact_state(id == 'add_role', 'role_from', 'role_to');
            }         
        });        
    });

    function change_contact_state(block, from, to) {   
        var ida = (block ? from : to); 
        var idb = (block ? to : from);
        var sa = batch_layout_namespace.notification_form.getSelect(ida);
        var sb = batch_layout_namespace.notification_form.getSelect(idb);
        var t = batch_layout_namespace.notification_form.getItemValue(ida);
        
        var validation_empty = '';

        if (t.length == 0) {
            if (from == 'user_from') {
                if (block === true) {
                    validation_empty = 'Please select User from User List.';    
                } else {
                    validation_empty = 'Please select User from Notify Users.'; 
                }
            } else if (from == 'role_from') {
                if (block === true) {
                    validation_empty = 'Please select Role from Roles List.';    
                } else {
                    validation_empty = 'Please select Role from Notify Roles.'; 
                }
            } 
            
            show_messagebox(validation_empty);
            return;
        }
        
        eval('var k={"'+t.join('":true,"')+'":true};');
        
        var w = 0;
        var ind = -1;
        
        while (w < sa.options.length) {
            if (k[sa.options[w].value]) {
                sb.options.add(new Option(sa.options[w].text,sa.options[w].value));
                sa.options.remove(w);
                ind = w;
            } else {
                w++;
            }
        }
        
        if (sa.options.length > 0 && ind >= 0) {
            if (sa.options.length > 0) sa.options[t.length>1?0:Math.min(ind,sa.options.length-1)].selected = true;
        }

        var arr_texts = new Array();

        for (var i = 0; i < sb.length; i++) {
            arr_texts[i] = sb.options[i].text;
        }

        arr_texts.sort();

        for (var i = 0; i < sb.length; i++) {
            sb.options[i].text = arr_texts[i];
        }

    }
    
    onload = function () {
        var from_users = batch_layout_namespace.notification_form.getSelect('user_from');
        var to_users = batch_layout_namespace.notification_form.getSelect('user_to');
        var from_roles = batch_layout_namespace.notification_form.getSelect('role_from');
        var roles_to = batch_layout_namespace.notification_form.getSelect('role_to');
        
        from_users.ondblclick = function () {
            change_contact_state(true, 'user_from', 'user_to');
        }

        to_users.ondblclick = function () {
            change_contact_state(false, 'user_from', 'user_to');
        }

        from_roles.ondblclick = function () {
            change_contact_state(true, 'role_from', 'role_to');
        }

        roles_to.ondblclick = function () {
            change_contact_state(false, 'role_from', 'role_to');
        }
    }
    
    function get_all_list_values(item_options) {
      var opt = "";
      var result = "";
      for (var i=0, len=item_options.length; i<len; i++) {
        opt = item_options[i];
        if (i == 0) {
            result = opt.value;
        }else{    
            result = result + "," + opt.value;
        }    
      }
       return result;
    }
    
    function app_date_format_converter(input_date) {        
        var dd = input_date.getDate();        
        var mm = input_date.getMonth() + 1;
        var y = input_date.getFullYear();
        mm = ((mm.toString()).split('').length == 1) ? ('0' + mm) : mm;
        dd = ((dd.toString()).split('').length == 1) ? ('0' + dd) : dd;
        
        if (app_date_format == '%n/%j/%Y' || app_date_format == '%m/%d/%Y') {
            return (mm + '/'+ dd + '/'+ y);
        } else if (app_date_format == '%j-%n-%Y' || app_date_format == '%d-%m-%Y') {
            return (dd + '-'+ mm + '-'+ y);
        } else if (app_date_format == '%j.%n.%Y' || app_date_format == '%d.%m.%Y') {
            return (dd + '.'+ mm + '.'+ y);
        } else if (app_date_format == '%j/%n/%Y' || app_date_format == '%d/%m/%Y') {
            return (dd + '/'+ mm + '/'+ y);
        } else if (app_date_format == '%n-%j-%Y' || app_date_format == '%m-%d-%Y') {
            return (mm + '-'+ dd + '-'+ y);
        }
    }
    
    function new_date_construct(date, hour, min) {
        var date_part = date.split(date_separator);
        var final_date;
        
        hour = (hour != 'undefined') ? hour : '';
        min = (min != 'undefined') ? min : '';
        
        if (app_date_format.split('')[1] == 'n' || app_date_format.split('')[1] == 'm') {
            var day = date_part[1];
            var month = date_part[0];
            var year = date_part[2];
        } else if (app_date_format.split('')[1] == 'j' || app_date_format.split('')[1] == 'd') {
            var day = date_part[0];
            var month = date_part[1];
            var year = date_part[2];
        }
        
        final_date = new Date(year, month - 1, day, hour, min);
        return final_date;
    }  
</script>
<form name="<?php echo $form_name;?>">
    <input type="hidden" id="dropdown" name="dropdown">
    <div id='layoutHeader'></div>
    <div id='layoutfooter'></div>
</form>
<style type="text/css">
    div.dhxcombo_dhx_web.dhxcombo_disabled input.dhxcombo_input {
        margin: 4px 0 0 0;
    }
</style>

