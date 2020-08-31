<?php
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET,PUT,POST,DELETE');
    header('Access-Control-Allow-Headers: Content-Type');
        
    require 'config.php';
    include_once './db_functions.php';
    include_once 'GCM.php';
    include_once 'APN.php';
    
    $push_xml = (isset($_REQUEST['push_xml'])) ? $_REQUEST['push_xml'] : ''; 
    /*
    $push_xml = '<?xml version="1.0" encoding="UTF-8"?>
            <root>
                <messages>
                    <message title="Message title" body="Message Body" type="workflow"/>
                </messages>
                <users>
                    <user id="farrms_admin,pl"/>
                </users>          
            </root>';
    */
    $xml_parser = xml_parser_create();
    xml_parse_into_struct($xml_parser,$push_xml,$result_arr);
    xml_parser_free($xml_parser);
    
    foreach ($result_arr as $arr) {
        if (strtoupper($arr['tag']) == 'MESSAGE') {
            $push_title = $arr['attributes']['TITLE'];
            $push_message = $arr['attributes']['BODY'];     
            $push_type = $arr['attributes']['TYPE'];
        }
        
        if (strtoupper($arr['tag']) == 'USER') {
            $user_login_id = $arr['attributes']['ID'];
        }
    }
    
    
    //$push_title = (isset($_REQUEST['push_title'])) ? $_REQUEST['push_title'] : 'TRMTracker Message';
    //$push_message = $_REQUEST['push_message'];
    $badge = '0';
    //$user_login_id = $_REQUEST['user_login_id'];  
    
    $data = array("push_title"=>$push_title, "push_message"=>$push_message, "badge"=>$badge, "push_type"=>$push_type);
    
    $db_con = new DB_Functions();
    $gcm = new GCM($api_key, $gcm_host);
    $apn = new APN($apns_pass, $apns_cert, $apns_host, $apns_port);
    
    $list_devices = $db_con->getDeviceIds($user_login_id);
    
    $device_tokens_ios = array();
    $device_tokens_android = array();
    
    
    //$push_message = 'tes 15556660';
    //$device_tokens_ios = array('925de9dd9d2efcab9fd27be20f5c17abaf4f4f0e1a935b95a1b7ec0ecf3be0e4');
   // $device_tokens_android = array('cPDvTR6tHnc:APA91bHFEVzP2lskmarLqIHOHuREtYCTO3z0pIxMvLngt8loHc8T3hiZoSKF4jMmPPs4BPNEKOUAexje-wTl3ZvrN7dA2uFoFfqQHuqOcKFQJ_Fky6eOy4C9PJXzY0OmDqD_XT0fDwCm');
    
    
    /*
    if (isset($param1 )) {
    $db = new DB_Functions();
    $res = $db->insertAlertMessage($param1, $param2);
    }
    */

    // Send message for iOS device : Push Notification.
    $device_tokens_ios = explode(',', $list_devices[0]['ios_tokens']);
    $device_tokens_android = explode(',', $list_devices[0]['android_tokens']);
    
    /*
    echo '<pre>';
    var_dump($device_tokens_ios);
    var_dump($device_tokens_android);
    echo '</pre>';
    */
    $sendMessage_ios = $apn->send_notification($device_tokens_ios, $data);
    
    if ($sendMessage_ios) {
        echo 'Send Message to IOS.';
    } else {
        echo 'Cannot send Message to IOS.';
    }
        
    $sendMessage_android = $gcm->send_notification($device_tokens_android, $data); 
    
    echo '<br />';
    //var_dump($sendMessage_android);
    if ($sendMessage_android['success'] > 0) {
        echo 'Send Message to Android.';
    } else {
        echo 'Cannot send Message to Android.';
    }
?>