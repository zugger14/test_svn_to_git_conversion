<?php
ob_start();
include '../../../adiha.php.scripts/components/include.file.v3.php';
ob_clean();

$report_name = get_sanitized_value($_GET['report_name'] ?? '');
$paramset_id = get_sanitized_value($_GET['paramset_id'] ?? '');

$filename = get_sanitized_value($_GET['filename'] ?? '');
$mode = get_sanitized_value($_REQUEST['mode'] ?? '');
$action = get_sanitized_value($_REQUEST['action'] ?? '');

$msg_desc = '';
$power_bi_api_url = 'https://api.powerbi.com/v1.0/myorg/groups/';
$power_bi_msn_url = 'https://login.microsoftonline.com/common/oauth2/token';

//GET reportid and datasetid
    $rfx_sql1 = "EXEC [spa_power_bi_report] @flag = 'q', @report_name = '".$report_name."', @paramset_id = '".$paramset_id."'" ;
    $return_value = readXMLURL($rfx_sql1);            
    $updated_report_id = $return_value[0][0];
    $updated_dataset_id = $return_value[0][1];
    $source_report = $return_value[0][2];
	$powerbi_username = $return_value[0][3];
	$powerbi_password = $return_value[0][4];
	$powerbi_client_id = $return_value[0][5];
	$powerbi_group_id = $return_value[0][6];
	$powerbi_gateway_id = $return_value[0][7];
	$powerbi_process_table = $return_value[0][8];

    if ($powerbi_process_table == 'NULL') {
		$return = 'false';
		$msg_desc = 'Error! Generate PowerBI Template first.';
		goto return_point;		
	}

//Get ACCESS TOKEN
    $client_id = $powerbi_client_id;
    $username = $powerbi_username;
    $password = $powerbi_password;
    $group_id = $powerbi_group_id;

	
    $url = $power_bi_msn_url;
    $headers = array(
        'Content-Type: application/x-www-form-urlencoded'
    );
    $fields_len = 'grant_type=password&client_id='.$client_id.'&resource=https://analysis.windows.net/powerbi/api&scope=openid&username='.$username.'&password='.$password;
    $results = power_bi_api($url, $headers, $fields_len, true);         
    $token_type = $results->token_type;
    $access_token = $results->access_token;

	if ($access_token == '') {
		$return = 'false';
		$msg_desc = 'Error! Unable to connect microsoftonline.';
		goto return_point;
	}
    

//Download Mode
if ($mode == "download") {
    //download api url
    $url = $power_bi_api_url.$group_id."/reports/".$updated_report_id."/Export";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

    curl_setopt ( $ch, CURLOPT_HTTPHEADER, array (
            'Authorization: ' .$token_type. ' ' . $access_token,
            'Content-Type: multipart/form-data;' 
    ) );
    curl_setopt ( $ch, CURLOPT_SSL_VERIFYPEER, false );
    $response = curl_exec($ch);

    curl_close ( $ch );
    
    ob_clean();
    $save_name = $report_name . "-" . date("Y-m-d h-i-s") . '.pbix';
    header("Cache-Control: public");
    header("Content-Description: File Transfer");
    header("Content-Disposition: attachment; filename = $save_name");
    header("Content-Type: application/zip");
    header("Content-Transfer-Encoding: binary");
    echo $response;
    exit;
    die();
}


//Upload Mode
if ($mode == "html5" || $mode == "flash") {
    $state = 'false';
    $filename = ($filename != '') ? $filename . '.pbix' : $_FILES["file"]["name"]; 
        
    $extension = explode('.', $_FILES["file"]["name"]);
    $extension = $extension[1];
    $filetype = $_FILES["file"]["type"];
    
    if (validate_file_extension($filetype, $extension)) {
        $state = 'true';
        $upload_status = move_uploaded_file($_FILES["file"]["tmp_name"], $temp_path . "/" . $filename);
		
		if($upload_status) {    
			/*****Power BI Deployment*****************************************************/
			$return = 'false';
			$msg_desc = 'Error! Unable to deploy file.';

			$report_name_original = $report_name;
			$report_name = str_replace(' ', '_',$source_report);

				//CHECK if dataset exists
				$name_conflict_val = 'Abort';
				if ($updated_dataset_id != '' && $updated_dataset_id != 'NULL') {
					$url = $power_bi_api_url.$group_id."/datasets/".$updated_dataset_id;
					$headers = array(
						'Content-Type: application/json',
						'Authorization: ' .$token_type. ' ' . $access_token
					);
					$fields_len = '{}';
					$results = power_bi_api($url, $headers, $fields_len, false);

					if ($results->id != '') {
						$name_conflict_val = 'Overwrite';
					}
				}

				sleep(2);
				//upload as import
				$url = $power_bi_api_url.$group_id."/imports?datasetDisplayName=".$report_name."&nameConflict=".$name_conflict_val;

				$file = $temp_path . "/" . $filename;
				$boundary = "----------BOUNDARY";

				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, $url);
				curl_setopt($ch, CURLOPT_POST, true);
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

				$postdata = "--" . $boundary . "\r\n";
				$postdata .= "Content-Disposition: form-data; name=\"" . $report_name . "\"; filename=\"" . $file . "\"\r\n";
				$postdata .= "Content-Type: application/octet-stream\r\n\r\n";
				$postdata .= file_get_contents($file);
				$postdata .= "\r\n";
				$postdata .= "--" . $boundary . "--\r\n";
				curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);
				curl_setopt ( $ch, CURLOPT_HTTPHEADER, array (
						'Authorization: ' .$token_type. ' ' . $access_token,
						'Content-Type: multipart/form-data; boundary='.$boundary,
						'Content-Length: ' . strlen($postdata)
				) );
				curl_setopt ( $ch, CURLOPT_SSL_VERIFYPEER, false );
				$response = json_decode(curl_exec($ch));

				//ob_clean(); var_dump($response); 
				if (curl_error($ch)) {
					$msg_desc = curl_error($ch);
					goto return_point;
				}
				curl_close ( $ch );
				sleep(2);
				
			//Get Dataset ID
				if ($response->id) {

					if ($name_conflict_val == 'Abort') {
						// new insertion Abort means:
						
						$url = $power_bi_api_url.$group_id."/imports/".$response->id;
						$headers = array(
							'Content-Type: application/json',
							'Authorization: ' .$token_type. ' ' . $access_token
						);
						$fields_len = '{}';
						$results = power_bi_api($url, $headers, $fields_len, false);

						$updated_dataset_id = $results->datasets[0]->id;
						$updated_report_id = $results->reports[0]->id;
					}
					//used to hold
					sleep(5);
						
					//Update reportid and datasetid
					$rfx_sql = "EXEC [spa_power_bi_report] @flag = 'p', @report_name = '".$report_name_original."',@source_report = '".$source_report."',  @power_service_report_id='".$updated_report_id."', @power_service_dataset_id ='".$updated_dataset_id."'" ;
					$return_value = readXMLURL($rfx_sql);
					
					if ($return_value[0][0] == 'Success') {
						$return = 'true';
						//updated datasource to Dataset ID
						$url = $power_bi_api_url.$group_id."/datasets/".$updated_dataset_id."/updatedatasources";
						$headers = array(
							'Content-Type: application/json',
							'Authorization: ' .$token_type. ' ' . $access_token
						);
						$db_servername_update = str_replace("\\","\\\\",$db_servername);
						$fields_len = '{ 
										  "updateDetails":[ 
											{ 
											  "connectionDetails": 
											  { 
												"server": "' . $db_servername_update . '", 
												"database": "' . $database_name . '" 
											  }
											}
											] 
										}';

						$results = power_bi_api($url, $headers, $fields_len, true); 
						if ($results != 'NULL' && $results != '') {

							$return = 'false';
							$msg_desc = 'Error! Unable to update Datasource.';
							goto return_point;
						} 						
						//used to hold
						sleep(2);
					
						//Bind Gateway to dataset
						$url = $power_bi_api_url.$group_id."/datasets/".$updated_dataset_id."/Default.BindToGateway";
						$headers = array(
								'Content-Type: application/json',
								'Authorization: ' .$token_type. ' ' . $access_token
							);
						$fields_len = '{
										  "gatewayObjectId": "'.$powerbi_gateway_id.'"
										}';
						$results = power_bi_api($url, $headers, $fields_len, true); 
						if ($results != 'NULL' && $results != '') {
							$return = 'false';
							$msg_desc = 'Error! Unable to bind Gateway.';
							goto return_point;
						} else {
								$return = 'true';
						}
						
					}
				} else {
					$return = 'false';
					$msg_desc = 'Error! Unable to import file to power bi service.';
					goto return_point;
				}
		} else {
			$return = 'false';
			$msg_desc = 'Error! Unable to upload file.';
			goto return_point;
		}
        
        /************************************************************************/
    }
}
	return_point:
    header("Content-Type: text/json");
    print_r("{state: " . $return . ", extra: { msg:'" . $msg_desc . "'}, name:'" . str_replace("'", "\\'", $filename) . "'}");

/*

HTML4 MODE

response format:

to cancel uploading
{state: 'cancelled'}

if upload was good, you need to specify state=true, name - will passed in form.send() as serverName param, size - filesize to update in list
{state: 'true', name: 'filename', size: 1234}

*/

if ($mode == "html4") {
    header("Content-Type: text/html");
    
    if ($action == "cancel") {
        print_r("{state:'cancelled'}");
    } else {
        $state = 'false';
        $filename = ($filename != '') ? $filename . '.pbix' : $_FILES["file"]["name"]; 
        $extension = explode('.', $_FILES["file"]["name"]);
        $extension = $extension[1];
        $filetype = $_FILES["file"]["type"];
        
        if (validate_file_extension($filetype, $extension)) {
            $state = 'true';
            move_uploaded_file($_FILES["file"]["tmp_name"], $temp_path . "/" . $filename);
        }
        print_r("{state: " . $state . ", name:'" . str_replace("'", "\\'", $filename) . "', size:" . $_FILES["file"]["size"] . "}");
    }
}

function validate_file_extension($filetype, $extension) {
    
    if ($extension == 'pbix') {
        return true;
    } else {
       return false;
    }
}

function power_bi_api($url, $headers, $fields, $is_post) {
    // Open connection
    $ch = curl_init();

    // Set the URL, number of POST vars, POST data
    curl_setopt( $ch, CURLOPT_URL, $url);
    if ($is_post)
        curl_setopt( $ch, CURLOPT_POST, true);
    curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true);
    if ($is_post)
        curl_setopt( $ch, CURLOPT_POSTFIELDS, $fields);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
     if ($is_post)
        curl_setopt($ch, CURLOPT_POST, true);
     curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    // Execute post
    $result = curl_exec($ch);

    // Close connection
    curl_close($ch);
    return json_decode($result);

 }