<?php
 
class APN {
 
    private $passphrase;
    private $apns_cert;
    private $apns_host;
    private $apns_port;
    
    // constructor
    public function __construct($passphrase, $apns_cert, $apns_host, $apns_port) {
       if ($passphrase) {
            $this->passphrase = $passphrase;
            $this->apns_cert = $apns_cert;
            $this->apns_host = $apns_host;
            $this->apns_port = $apns_port;
        }
    }
 
    /**
     * Sending Push Notification
     */
    public function send_notification($listDeviceId, $data) {
		$deviceToken = $listDeviceId; 
		
		// Put your private key's passphrase here:
		$passphrase = $this->passphrase;
        $apns_cert = $this->apns_cert;
        $apns_host = $this->apns_host;
        $apns_port = $this->apns_port;

		$ctx = stream_context_create();
        		
		// Production
		stream_context_set_option($ctx, 'ssl', 'local_cert', $apns_cert);	
		
		stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase); 
		// Open a connection to the APNS server
			
		// live Open a connection to the APNS server
		
		$fp = stream_socket_client(
			'ssl://'.$apns_host.':'.$apns_port, $err,
			$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);	

		if (!$fp)
			exit("Failed to connect: $err $errstr" . PHP_EOL);

		// Create the payload body
		$body['aps'] = array(
			'alert' => array(
			    'title' => $data['push_title'],
                'body' => $data['push_message'],
                'type' => $data['push_type'],
			 ),
			'sound' => 'default',
			'badge' => $data['badge'],
			'data'	=> array(
				'type' => $data['push_type']
			)
		);

		// Encode the payload as JSON
		$payload = json_encode($body);

		// Build the binary notification
		foreach($deviceToken as $device) {
    		$Symbol = array("<", ">");
    		$clrSymbolToken = str_replace($Symbol,'',$device); 	
    		$deviceId =str_replace(' ','',$clrSymbolToken);
    		//echo $deviceId .'------';
    		$msg = chr(0) . pack('n', 32) . pack('H*', $deviceId) . pack('n', strlen($payload)) . $payload;
    		
    		// Send it to the server
    		$result = fwrite($fp, $msg, strlen($msg));
		}
        
		if (!$result) {
            // Close the connection to the server
            fclose($fp);
			return false;
		 } else {
            // Close the connection to the server
            fclose($fp);
			return true;
        }	
	}
 
}
 
?>