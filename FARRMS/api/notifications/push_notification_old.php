<?php
	header('Access-Control-Allow-Origin: *');
	header('Access-Control-Allow-Methods: GET,PUT,POST,DELETE');
	header('Access-Control-Allow-Headers: Content-Type');
		
    require 'config.php';
    $gcm_host = 'https://fcm.googleapis.com/fcm/send';
        
    include_once './db_functions.php';
    
    include_once 'GCM.php';
    include_once 'APN.php';
    
	$push_xml_sample = '<?xml version="1.0" encoding="UTF-8"?>
            <root>
                <messages>
                    <message title="TRMd" body="Message test msg" type="alerts"/>
                </messages>
                <users>
                    <user id="farrms_admin"/>
                </users>          
            </root>';
			//alerts
    $push_xml = (isset($_REQUEST['push_xml'])) ? $_REQUEST['push_xml'] : $push_xml_sample;
	
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
	
	var_dump($data);
    
    $db_con = new DB_Functions();    
    $gcm = new GCM($api_key, $gcm_host);
    $apn = new APN($apns_pass, $apns_cert, $apns_host, $apns_port);
    
    $list_devices = $db_con->getDeviceIds($user_login_id);
	
    $device_tokens_ios = array();
    $device_tokens_android = array();
    
    
    //$push_message = 'tes 15556660';
    //$device_tokens_ios = array('9f9ae662401a83280b2a31e29f2906c68366dd558083ff12c57bc5a8005d2cf3','2db87998f94b6a23f4176488bd64906d2055a1778eebc00b48309c9850348471');
   //$device_tokens_android = array('fbfB6Ud-JGE:APA91bFYl6xlKP9lH9Anb2MtX0pOGc8NIg4S-Nq0FUDpYKToCvr2y6yhFMpJh1Wp5RZ9b5m3X1rTdhUGpfqM2tKlmuUrnmTgsRZ9lcpARTkHOUDJHAMLwjoJ4IXeQ0WbRdsW1cdbSU11');
   //$device_tokens_android = array('e98OTX1ZgXQ:APA91bH2tYsQK3HkozL-GWqoqQPAtaKMC088NnDAVfY9FGkVDBL7H8RwAHSvyzFgDXQOpZzSLcIP1qEaw5Qa4H1yq0dvPTeeOml2vXNXkA65QEfukFr0hD4uJf_Ql7Cq1z0KFiVVlAad');
    
	
    /*
	if (isset($param1 )) {
	$db = new DB_Functions();
	$res = $db->insertAlertMessage($param1, $param2);
	}
    */

	// Send message for iOS device : Push Notification.
    //$device_tokens_ios = explode(',', $list_devices[0]['ios_tokens']);
    $device_tokens_android = explode(',', $list_devices[0]['android_tokens']);
	
	/*
	echo '<pre>';
	var_dump($device_tokens_ios);
	var_dump($device_tokens_android);
    echo '</pre>';
	*/
	/*
	$sendMessage_ios = $apn->send_notification($device_tokens_ios, $data);
	
	if ($sendMessage_ios) {
		echo 'Send Message to IOS.';
	} else {
		echo 'Cannot send Message to IOS.';
	}
	 */   
    $sendMessage_android = $gcm->send_notification($device_tokens_android, $data); 
    //var_dump($sendMessage_android);
	
	echo '<br />';
	//var_dump($sendMessage_android);
	if ($sendMessage_android['success'] > 0) {
		echo 'Send Message to Android.';
	} else {
		echo 'Cannot send Message to Android.';
	}
?>