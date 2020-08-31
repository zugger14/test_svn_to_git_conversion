<?php
    $farrms_client_dir = $_POST['farrms_client_dir'];
    
    $mobile_app = true;
    
    try {
        include_once '../../../adiha.php.scripts/components/file_path.php';
         
        include_once '../../../../' . $farrms_client_dir . '/adiha.config.ini.rec.php';
       
        // include_once '../../../adiha.php.scripts/components/include.ssrs.reporting.files.php';
        // include_once '../../../adiha.php.scripts/components/include.main.files.php';

        //include '../../../adiha.php.scripts/components/adiha_php_function.php';
        //include '../../../adiha.php.scripts/components/lib/adiha.xml.parser.1.0.php';

        //include_once '../../../adiha.php.scripts/components/components.files.php';
         
        //require_once 'report.global.vars.php';   
    } catch(Exception $e) {
        echo 'Error Plotting Report';
        exit;
    }

    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $_POST['app_user_name'];
    $report_filter = $_REQUEST['report_filter'];
    $report_name = $_REQUEST['source_report'];
	$powerbi_username = $_REQUEST['power_bi_username'];
	$powerbi_password = $_REQUEST['power_bi_password'];
    //$report_name = str_replace(' ', '_', substr($report_name, 0, -5));
    $report_name = str_replace(' ', '_', $report_name);
    /*
    $power_bi_report_id = $_REQUEST['power_bi_report_id'];
    // $has_rights_report_manager_powerbi = $_POST['has_rights_report_manager_powerbi'];

    $report_filter_arr = explode("_-_", $report_filter);
    $report_filter = $report_filter_arr[0];
    $sec_filter_process_id = $report_filter_arr[1];

    $xml_formatted_filter = "EXEC spa_power_bi_report @flag='f', @power_bi_report_id=".$power_bi_report_id.", @report_filter='$report_filter'";
        
    $result_formatted_filter_power_bi = readXMLURL2($xml_formatted_filter);
    $formatted_filter = '';
    for ($i = 0; $i < sizeof($result_formatted_filter_power_bi); $i++) {
        $formatted_filter .= $result_formatted_filter_power_bi[$i]['filter_display_label'] . ' = ' . $result_formatted_filter_power_bi[$i]['filter_display_value'] . ($i == sizeof($result_formatted_filter_power_bi) - 1 ? '' : ' | ');
    }
    

    $xml_power_bi_info = "EXEC spa_power_bi_report @flag = 'r', @report_filter = '" . $report_filter . "', @power_bi_report_id='" . $power_bi_report_id . "', @sec_filter_process_id='" . $sec_filter_process_id . "'";

    $data_power_bi_info = readXMLURL2($xml_power_bi_info); //die(print_r($data_power_bi_info)); 
    $power_bi_url = $data_power_bi_info[0]['report_url'];
    $power_bi_table = $data_power_bi_info[0]['process_id'];
    */
    
    $output_html = '
    <script language="JavaScript" src="' . $app_php_script_loc . 'components/jQuery/jquery-1.11.1.js"></script>
    <script type="text/javascript" src="' . $app_php_script_loc .'components/lib/power_bi/es6-promise.js"></script>
    <script type="text/javascript" src="' . $app_php_script_loc .'components/lib/power_bi/powerbi.js"></script>';

    $output_html .= '<div id="report-body">
                <div id="cn-ssrs-viewer-report">
                    <div style="margin-bottom: 8px"></div>
                    <div id="power_bi_report_div" style="height:100%;"></div>
                </div>
            </div>';
        
    /*************************************************************************************/
         
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
    //Get ACCESS TOKEN
    $client_id = $powerbi_client_id;
    $username = $powerbi_username;
    $password = $powerbi_password;
    $group_id = $powerbi_group_id;
    $api_power_bi_url = "https://api.powerbi.com/v1.0/myorg/groups/";
    $app_power_bi_url = "https://app.powerbi.com/reportEmbed";

    $url = "https://login.microsoftonline.com/common/oauth2/token";
    $headers = array(
        'Content-Type: application/x-www-form-urlencoded'
    );
    $fields_len = 'grant_type=password&client_id='.$client_id.'&resource=https://analysis.windows.net/powerbi/api&scope=openid&username='.$username.'&password='.$password;
    $results = power_bi_api($url, $headers, $fields_len, true);
    //var_dump($results); die();
    
    $token_type = $results->token_type;
    $access_token = $results->access_token;

    // echo '<pre>'; var_dump($results); echo '</pre>'; die();

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

        if($report_lists[$i]->name == $report_name) {
            $report_exists = true;
            $report_id = $report_lists[$i]->id;
            $dataset_id = $report_lists[$i]->datasetId;
            continue;
        }
   }
           
    if ($report_exists) {
        $report_id = $report_id;
        $dataset_id = $dataset_id;
        $role = 'Role1';  

        //Get EMBEDDED TOKEN
        $url = $api_power_bi_url.$group_id."/reports/".$report_id."/GenerateToken";

        $headers = array(
            'Content-Type: application/json',
            'Authorization: ' .$token_type. ' ' . $access_token
        );

        // if ($has_rights_report_manager_powerbi == 1) {
        //     $edit_view = 'edit';
        // } else {
            $edit_view = 'view';
        // }

        $fields_len = '{   
                        "accessLevel": "'.$edit_view.'",
                        "allowSaveAs": "true",
                        "identities": [     
                            {      
                                "username": "'.$app_user_loc.'",
                                "roles": ["'.$role.'"],
                                "datasets": [ "'.$dataset_id.'" ]
                            }   
                            ] 
                        }';
        $results = power_bi_api($url, $headers, $fields_len, true);
        $embed_token = $results->token;

        

        $embed_url = $app_power_bi_url.'?reportId='.$report_id.'&groupId='.$group_id;

        $output_html .= "

         <script type=text/javascript>
            var embedToken = '" . $embed_token . "';
            var embedURL = '" . $embed_url . "';
            var embedID = '" . $report_id . "';

            // Get models. models contains enums that can be used.
            var models = window['powerbi-client'].models;
            //console.log(models);
            
            // We give All permissions to demonstrate switching between View and Edit mode and saving report.
            var permissions = models.Permissions.ReadWrite;
            //var permissions = models.Permissions.All;

            view_mode = 'view';

            var embedConfiguration = {
                type: 'report',
                tokenType: models.TokenType.Embed,
                accessToken: embedToken,
                embedUrl: embedURL,
                id: embedID,
                permissions: permissions,
                viewMode: models.ViewMode.View,
                settings: {
                    layoutType: models.LayoutType.MobilePortrait
                }
            };

            // Grab the reference to the div HTML element that will host the report
            var reportContainer = $('#power_bi_report_div')[0];

            // Embed report
            report = powerbi.embed(reportContainer, embedConfiguration);

            // Report.off removes a given event handler if it exists.
            report.off('loaded');
             
            // Report.on will add an event handler which prints to Log window.
            report.on('loaded', function() {
                console.log('Loaded');
            });
             
            report.on('error', function(event) {
               console.log(event);
                report.off('error');
            });

        </script>";
    } else {
        $output_html = 'No Report Exists';
    }

    ob_clean();
    echo '<?xml version="1.0" encoding="UTF-8"?>
            <root>
               <paging>
                  <current>1</current>
                  <total>1</total>
               </paging>
               <report_html><![CDATA[' . $output_html . ']]></report_html>
            </root>';
?>