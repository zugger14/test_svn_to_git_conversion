<?php
ob_start();
include_once '../../'.$_GET["cfolder"].'/farrms.client.config.ini.php';
ob_clean();

$path=$_GET['path'];
$name=isset($_GET['name']) ? $_GET['name'] : '';
$paramset_hash=isset($_GET['paramset_hash']) ? $_GET['paramset_hash'] : '';
$powerbi_username=isset($_REQUEST['uname']) ? $_REQUEST['uname'] : '';
$power_bi_password=isset($_REQUEST['pwd']) ? $_REQUEST['pwd'] : '';
$path=str_replace("<<PLUS>>","+",$path);
$path=str_replace("<<HASH>>","#",$path);
$path=str_replace("<<AMP>>","&",$path);

$path2= 'dev/shared_docs/power_bi/files/template_for_report'.$_GET["dataset_count"].'.pbit';
$path3= 'dev/shared_docs/power_bi/files/Readme.txt';
$path4= 'dev/shared_docs/power_bi/files/powerbi.cmd';

if (isset($_GET['new_exist_update']) && $_GET['new_exist_update'] == 'e') {
    //Get ACCESS TOKEN
    $client_id = $powerbi_client_id;
    $username = $powerbi_username;
    $password = $powerbi_password;
    $group_id = $powerbi_group_id;
    $api_power_bi_url = "https://api.powerbi.com/v1.0/myorg/groups/";

    $url = "https://login.microsoftonline.com/common/oauth2/token";
    $headers = array(
        'Content-Type: application/x-www-form-urlencoded'
    );
    $fields_len = 'grant_type=password&client_id='.$client_id.'&resource=https://analysis.windows.net/powerbi/api&scope=openid&username='.$username.'&password='.$password;
    $results = power_bi_api($url, $headers, $fields_len, true);         
    $token_type = $results->token_type;
    $access_token = $results->access_token;

    //Get list of reports            
    $url = $api_power_bi_url.$group_id."/reports";
    $headers = array(
        'Content-Type: application/json',
        'Authorization: ' .$token_type. ' ' . $access_token
    );
    $fields_len = '{}';
    $results = power_bi_api($url, $headers, $fields_len, false);
    $report_lists = $results->value;
    $report_exists = false;
    for($i=0;$i<count($report_lists); $i++) {

        if($report_lists[$i]->name == str_replace(' ', '_',$paramset_hash)) {
            $report_exists = true;
            $report_id = $report_lists[$i]->id;
            $dataset_id = $report_lists[$i]->datasetId;
            continue;
        }
   }
//echo '<pre>'; var_dump($report_exists); echo '</pre>'; die();
   if ($report_exists) {
       //download api url
        $url = $api_power_bi_url.$group_id."/reports/".$report_id."/Export";

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
        $save_name = $name . "-" . date("Y-m-d h-i-s") . '.pbix';
        
        /*header("Cache-Control: public");
        header("Content-Description: File Transfer");
        header("Content-Disposition: attachment; filename = $save_name");
        header("Content-Type: application/zip");
        header("Content-Transfer-Encoding: binary");
        echo $response;
        */
        $path2= 'dev/shared_docs/temp_Note/'.$save_name;
        file_put_contents("$path2", $response);
    }
}


$files = array($path, $path2, $path3, $path4);
$name = $name."-" . date("Y-m-d h-i-s").'.zip';
$zipname = "dev/shared_docs/temp_Note/".$name;
$zip = new ZipArchive;
$zip->open($zipname, ZipArchive::CREATE);
foreach ($files as $file) {
    $file_arr = explode('/', $file);
    $new_filename = $file_arr[count($file_arr)-1];
    //echo $new_filename;
  $zip->addFile($file, $new_filename);
}
$zip->close();

//die();

header('Content-Type: application/zip');
header('Content-disposition: attachment; filename='.$name);
header('Content-Length: ' . filesize($zipname));
readfile($zipname);
exit;

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
?>