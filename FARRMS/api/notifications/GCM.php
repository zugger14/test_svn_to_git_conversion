<?php
 
class GCM {
     
    private $api_key;
    private $gcm_host;
    
    // constructor
    function __construct($api_key, $gcm_host) {
        if ($api_key) {
            $this->api_key = $api_key;
            $this->gcm_host = $gcm_host;            
        }        
    }
 
    /**
     * Sending Push Notification
     */
    public function send_notification($registation_ids, $data) {

    $apiKey = $this->api_key;
    $url = $this->gcm_host;
	
	$message = array(
	            'title' => $data['push_title'],
	            'message' => $data['push_message'],
	            'subtitle' => '',
	            'tickerText' => '',
	            'msgcnt' => $data['badge'],
	            'vibrate' => 1,
                'data'	=> array(
					'type' => $data['push_type']
				)
	        );
    
    $fields = array(
        'registration_ids' => $registation_ids,
        'data' => $message
    );
    $headers = array(
        'Authorization: key=' . $apiKey,
        'Content-Type: application/json'
    );

    // Open connection
    $ch = curl_init();

    // Set the URL, number of POST vars, POST data
    curl_setopt( $ch, CURLOPT_URL, $url);
    curl_setopt( $ch, CURLOPT_POST, true);
    curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt( $ch, CURLOPT_POSTFIELDS, json_encode( $fields));

    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
     curl_setopt($ch, CURLOPT_POST, true);
     curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode( $fields));

    // Execute post
    $result = curl_exec($ch);

    // Close connection
    curl_close($ch);
    
    return json_decode($result, true);
 

    }
 
}
 
?>