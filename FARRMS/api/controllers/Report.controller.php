<?php
/**
*  @brief ReportController Report Information extends REST class
*  @par Description
*  This class is used to get Report Information
*  @copyright Pioneer Solutions.
*/
class ReportController extends REST {
    
    private $app_user_name;
    /**
     * Constructor
     *
     * @param   String  $app_user_name  User Login
     */
     public function __construct($app_user_name = null) {
        parent::__construct();              // Init parent contructor
       if ($app_user_name) {
            $this->app_user_name = $app_user_name; 
        }
    }
    
    /**
     * Get List of All available Mobile Enabled Reports
     *
     * @return  JSON  List of Reports
     */
    public function index() {
        $results = Report::find();
        $this->response($this->json($results));
    }

    /**
     * Get Report Info based on Report ID
     *
     * @param   String  $reportId  Report ID
     *
     * @return  JSON                Report Detail Information
     */
    public function get($reportId) {
        $results = Report::findOne($reportId);
        $this->response($this->json($results[0]), 200);
    }
    
    /**
     * Get Report Filter Parameters
     *
     * @param   Integer  $reportParamId  Paramset ID
     * @param   Integer  $reportId       Report ID
     *
     * @return  JSON                     Filter List
     */
    public function getFilter($reportParamId, $reportId = '') {
        $results = Report::reportfilter($reportParamId);
        $results_filter = Report::getApplyFilter($reportParamId, $reportId);

        $json_head_arr = json_decode($results[0]['form_json'], true);
        $json_apply_filter_arr = json_decode($results_filter[0]['filter_json'] ?? '', true);

        array_splice($json_head_arr, 0, 1);

        $json_head_arr1 = array();
        $json_arr = array();
        $json_filters_arr = array();


        $count_arr = 0;
        foreach ($json_head_arr as $key => $val) {

            foreach($val as $key1 => $val1) {
                foreach ((array) $val1 as $key2 => $val2) {
                    $val2_arr = (array) $val2;
                    if ($key1 == 'list' && $val2_arr ['type'] != 'newcolumn') {
                        $json_head_arr1[$count_arr] = (array) $val2;
                        $count_arr++;
                    }
                }
            }
        }

        foreach($json_head_arr1 as $key => $val) {

            foreach($val as $key1 => $val1) {
                if ($val['name'] == 'report_name' || $val['name'] == 'report_paramset_id' || $val['name'] == 'items_combined') {
                    //var_dump($val['value']);
                    $json_arr[$val['name']] = $val['value'];
                }  else if ($val['name'] != 'report_name' && $val['name'] != 'report_paramset_id' && $val['name'] != 'items_combined') {
                    $val1_arr = (array) $val;
                    unset($val1_arr['position'],$val1_arr['offsetLeft'],$val1_arr['labelWidth'],$val1_arr['inputWidth']);
                    $json_filters_arr[$key] = $val1_arr;
                }
            }
        }
        
        $json_arr['new_report_id'] = $json_arr['report_paramset_id'] . '_' . $reportId;
        $json_arr['report_filters'] = $json_filters_arr;

        if (is_array($json_apply_filter_arr))
            $json_arr = array_merge($json_arr, $json_apply_filter_arr);
        
        $this->response($this->json($json_arr), 200);

    }
    
    /**
     * Get Book Structure
     *
     * @return  JSON List of Book Structure
     */
    public function getBookStructure() {
        $result0 = Report::getBookStructure();
        //var_dump($result0); die();
        $arr = array();
        $cnt1 = 0;
        $cnt_com = -1;
        
        foreach ($result0 as $result) {
            
            foreach ($result as $key => $val) {
                
                
                if ($key == 'node_type') {                    
                    if ($val == 3) {
                        $cnt_com++;
                        $arr[$cnt_com] = array('level'=>'company', 'id'=>$result0[$cnt1]['entity_id'], 'name'=>$result0[$cnt1]['entity_name']);                
                        $cnt_sub = -1;
                    } else{
                        $entity_arr = explode('|',$result0[$cnt1]['entity_name']);
                    }
                    
                    if ($val == 2) {
                        $cnt_sub++;
                        //$sub_arr = explode('|',$result0[$cnt1]['entity_name']);
                        $arr[$cnt_com]['children'][$cnt_sub] = array('level'=>'sub', 'id'=>$result0[$cnt1]['entity_id'], 'name'=>$entity_arr[0]);                
                        $cnt_stra = -1;
                    }
                    
                    if ($val == 1) {
                        $cnt_stra++;
                        //$stra_arr = explode('|',$result0[$cnt1]['entity_name']);
                        $arr[$cnt_com]['children'][$cnt_sub]['children'][$cnt_stra] = array('level'=>'stra', 'id'=>$result0[$cnt1]['entity_id'], 'name'=>$entity_arr[1]);
                        $cnt_book = -1;
                    }
                    
                    if ($val == 0) {
                        $cnt_book++;
                        //$book_arr = explode('|',$result0[$cnt1]['entity_name']);
                        $arr[$cnt_com]['children'][$cnt_sub]['children'][$cnt_stra]['children'][$cnt_book] = array('level'=>'book', 'id'=>$result0[$cnt1]['entity_id'], 'name'=>$entity_arr[2]);
                        $cnt_subbook = -1;
                    }
                    
                    if ($val == -1) {
                        $cnt_subbook++;
                        //$book_arr = explode('|',$result0[$cnt1]['entity_name']);
                        $arr[$cnt_com]['children'][$cnt_sub]['children'][$cnt_stra]['children'][$cnt_book]['children'][$cnt_subbook] = array('level'=>'sub_book', 'id'=>$result0[$cnt1]['entity_id'], 'name'=>$entity_arr[3]);
                        
                    }
                    
                }
            }
            $cnt1++;
            
        }
        
        $this->response($this->json($arr));
    }
    
    /**
     * get Excel Report View
     *
     * @param   Array  $body  POST Body Data
     *
     * @return  JSON         View Data or Failure Message
     */
    public function viewExcelReport($body) {
        global $farrms_client_dir;
        // global $database_name;
        global $rootdir;
        
        if(isset($body->report_id)) {

            $report_name = $body->report_name;
            $excel_sheet_id = $body->report_id;
            $report_type = $body->report_type;
            $refresh_type = $body->refresh_type;
            $screen_width = ($body->screen_width) ? $body->screen_width : 500;
            
            $page = 1;
            
            include_once '../trm/adiha.php.scripts/components/file_path.php';
            include_once '../' . $farrms_client_dir . '/adiha.config.ini.rec.php';
            
            
            $data_report_info_param = Report::getExcelSnapshot($excel_sheet_id, $refresh_type);
            $ssrs_config = Deal::getSSRSLogin();
            $client_date_format = Auth::dateFormat();
            if(count($ssrs_config) < 1) {
                $error = array('status' => "Failed", "message" => "Report(s) not found.");
                $this->response($this->json($error), 404);
            }
            
            /*
            $postdata = http_build_query(
                array(
                    'report_type' => '4',
                    'windowTitle' => 'Report Viewer',
                    'export_type' => 'HTML4.0',
                    'report_name' => $data_report_info_param[0]['report_name'],
                    'report_title' => $report_name,
                    'excel_sheet_id' => $excel_sheet_id,
                    'snapshot_filename' => $data_report_info_param[0]['snapshot_filename'],
                    'snapshot_applied_filter' => $data_report_info_param[0]['snapshot_applied_filter'],
                    'snapshot_refreshed_on' => $data_report_info_param[0]['snapshot_refreshed_on'],
                    'description' => $data_report_info_param[0]['description'],
                    'call_from' => 'excel',
                    'farrms_client_dir' => $farrms_client_dir,
                    'ssrs_config' => $ssrs_config[0],
                    'date_format' => $client_date_format,
                    'page' => $page,
                    'screen_width' => $screen_width
                )
            );
            */

            // $CLOUD_USER_DATABASE_NAME = 'cloud_user_database';
            // $cookie_name = md5($CLOUD_USER_DATABASE_NAME);

            /**********************/
            $excel_sheet_id = $excel_sheet_id;
            $export_type = 'HTML4.0';
            $initial_scale = ($screen_width > 400) ? '0.7' : '0.4';
            $report_name = $data_report_info_param[0]['report_name'];
            //$snapshot_filename =  $app_php_script_loc.'dev/shared_docs/Excel_Reports/'.$data_report_info_param[0]['snapshot_filename'];
			$snapshot_filename =  str_replace('adiha_pm_html/process_controls/clientImageFile.jpg','dev/shared_docs/temp_Note/'.$data_report_info_param[0]['snapshot_filename'],$ssrs_config[0]['file_attachment_path']);
            
            //$snapshot_filename_doc =  $rootdir . '\\' . $farrms_root . '\\adiha.php.scripts\\dev\\shared_docs\\Excel_Reports\\' . $data_report_info_param[0]['snapshot_filename'];
                    
            $formatted_filter = '';
            $formatted_filter .= '<span style="float:left">' . str_replace(',','|',str_replace(':',' = ',$data_report_info_param[0]['snapshot_applied_filter'])) . ' </span><span style="float:right;"> Refresh on ' . $data_report_info_param[0]['snapshot_refreshed_on'] . '</span>';
            
            /*if ($report_name && file_exists($snapshot_filename_doc)) {                 
                $snapshot_filename_img =  '<img src="'.$snapshot_filename.'" />';            
            }   else {
                $snapshot_filename_img =  "<div>" . $data_report_info_param[0]['description'] . "</div>";
            }*/
            
            $excel_html_output = '
                        <!DOCTYPE html>
                        <html>
                          <head>
                            <meta http-equiv="content-type" content="text/html; charset=utf-8">
                            <meta name="viewport" content="user-scalable=yes, width=device-width, initial-scale='.$initial_scale.'; maximum-scale=1.0; minimum-scale=0.25" />
                            <style type="text/css">
                                
                                #cn-ssrs-viewer-report {
                                    padding: 10px;
                                }
                    
                                .cn-ssrs-viewer-paginator {
                                    text-align: right;
                                    padding:4px;
                                    height:25px;
                                }
                    
                                .report_name {
                                    font-family: \'Verdana\';
                                    font-size: 14px;    
                                    font-weight: bold;
                                    color: #2571af;
                                    padding-left: 10px;
                                    padding-top:7px;
                                }
                                body {
                                overflow: auto;
                                }
                                
                                .report_filter_font {
                                    font-family: \'Tahoma\';
                                    font-size: 12px;
                                }
                                .report_header_new {
                                    background-color: #86e2d5; /*e4f9fe*/
                                    padding: 7px;
                                    width: 99%;
                                    border: 1px solid #4dcb8c; /*#8ca0ab*/
                                    font-family: "Open Sans";
                                    font-style: italic;
                                    font-size: 11px;  
                                    font-weight: bold;
                                    margin: 10px 10px 5px 12px;
                                    padding-bottom:18px;
                                } 
                            </style>
                            </head>
                            <body>
                            <div id="report-body">
                                <div id="cn-ssrs-viewer-header">
                                    <p class="report_name">' . $report_name . ' </p>
                                </div>
                                <div class="report_header_new" >' . $formatted_filter . '</div>
                                <div id="cn-ssrs-viewer-report">' . $snapshot_filename_img . '</div>
                            </div>
                            </body>
                            </html>';
            
            $result = '<?xml version="1.0" encoding="UTF-8"?>
                            <root>
                               <paging>
                                  <current>1</current>
                                  <total>1</total>
                               </paging>
                               <report_html><![CDATA[' . $excel_html_output . ']]></report_html>
                            </root>';
            /************************/
            /*
            $opts = array('http' =>
                array(
                    'method'  => 'POST',
                    'header'  => "Content-type: application/x-www-form-urlencoded\r\n".
                            "Cookie: ".$cookie_name."=".base64_encode($database_name)."",
                    'content' => $postdata
                )
            );
            $context = stream_context_create($opts);
            $result = file_get_contents($rpc_url, false, $context);
            */
            ob_get_clean();
            header('Content-type: application/xml');
            echo $result;
        } else {
            $error = array('status' => "Failed", "message" => "Report(s) not found.");
            $this->response($this->json($error), 404);  // If no records "No Content" status
        }
    }
    
    /**
     * get Standard Report View
     *
     * @param   Array  $body  POST Body Data
     *
     * @return  JSON         View Data or Failure Message
     */
    public function viewStandardReport($body) {
        include_once '../trm/adiha.php.scripts/components/file_path.php';

        global $farrms_client_dir, $new_db_name, $new_db_server_name;
        
        $rpc_url = $app_php_script_loc . 'dev/spa_html.php';
        
        $enable_paging = 'false';
        $np = 0;
        $rnd = (isset($body->rnd)) ? $body->rnd : 4;
        $applied_filters =  (isset($body->applied_filters)) ? str_replace('"', "'", $body->applied_filters) : '';
        $sql = (isset($body->sql)) ? $body->sql : $body->spa;

        if (isset($body->enable_paging)) {
            $enable_paging = $body->enable_paging;
            $np = 1;
        }
        
        $post_data_array = array(
            'spa' => $sql,
            'applied_filters' => $applied_filters,
            'call_from' => 'mobile',
            'farrms_client_dir' => $farrms_client_dir,
            'enable_paging' => $enable_paging,
            'np' => $np,
            'rnd' => $rnd,
            'app_user_name' => $this->app_user_name,
            'new_db_name' => $new_db_name,
            'new_db_server_name' => $new_db_server_name
        );

        if (isset($body->page_no)) {
            $post_data_array['page_no'] = $body->page_no;
            $post_data_array['__total_row_return__'] = "551";
        }

        $postdata = http_build_query($post_data_array);
        $data_len = strlen($postdata);

        $opts = array('http' =>
            array(
                'method'  => 'POST',
                'header'  => "Content-type: application/x-www-form-urlencoded\r\n" .
                        "Content-Length: $data_len\r\n",
                'content' => $postdata
            )
        );
        
        $context = stream_context_create($opts);
        $result = file_get_contents($rpc_url, false, $context);
        
        if (strpos($result, '<_0>Error</_0>') !== false) {
            $error = array('status' => "Failed", "message" => "Error in Report.");
            $this->response($this->json($error), 400);
        }
        
        ob_get_clean();
        header('Content-type: application/xml');
        echo $result;
    }
    
    /**
     * get Power BI Report View
     *
     * @param   Array  $body  POST Body Data
     *
     * @return  JSON         View Data or Failure Message
     */
    public function viewBIReport($body) {
        global $farrms_client_dir;
        global $app_user_name;
        if(isset($body->paramset_id)) {

            $report_name = $body->report_name;
            $report_filter = $body->report_filter;
            $items_combined = $body->items_combined;
            $paramset_id = $body->paramset_id;
            $power_bi_report_id = $body->report_id;            
                      

            include_once '../trm/adiha.php.scripts/components/file_path.php';
            
            $rpc_url = $app_php_script_loc . '../adiha.html.forms/_reporting/report_manager_dhx/power.bi.mobile.php';
                        
            $ssrs_config = Deal::getSSRSLoginParamset($paramset_id);            
            if(count($ssrs_config) < 1) {
                $error = array('status' => "Failed", "message" => "Report(s) not found.");
                $this->response($this->json($error), 404);
            }
            $report_filter_arr = explode("_-_", $report_filter);
            $report_filter = $report_filter_arr[0];
            $sec_filter_process_id = $report_filter_arr[1];
            $power_bi_report = Report::getPowerBIReport($power_bi_report_id,$report_filter,$sec_filter_process_id);
            
            if($power_bi_report[0]['error_code'] != 'success') {
                $error = array('status' => "Failed", "message" => "Report(s) not found.");
                $this->response($this->json($error), 404);  // If no records "No Content" status
            }
            
            $postdata = http_build_query(
                array(
                    'report_name' => $report_name,
                    'report_title' => $report_name,
                    'report_filter' => $report_filter,
                    'source_report' => $power_bi_report[0]['source_report'],
                    'power_bi_report_id' => $power_bi_report_id,
                    'farrms_client_dir' => $farrms_client_dir,
                    'app_user_name' => $app_user_name,
					'power_bi_username' => $power_bi_report[0]['power_bi_username'],
					'power_bi_password' => $power_bi_report[0]['power_bi_password']
                )
            );

            $opts = array('http' =>
                array(
                    'method'  => 'POST',
                    'header'  => 'Content-type: application/x-www-form-urlencoded',
                    'content' => $postdata
                )
            );
            $context = stream_context_create($opts);
            $result = file_get_contents($rpc_url, false, $context);            
            
            ob_get_clean();
            header('Content-type: application/xml');
            echo $result;
        } else {
            $error = array('status' => "Failed", "message" => "Report(s) not found.");
            $this->response($this->json($error), 404);  // If no records "No Content" status
        }
    }

    /**
     * get Report Manager Report View
     *
     * @param   Array  $body  POST Body Data
     *
     * @return  JSON         View Data or Failure Message
     */
    public function viewReport($body) {
        global $farrms_client_dir;
        if(isset($body->paramset_id)) {

            $report_name = $body->report_name;
            $report_filter = $body->report_filter;
            $items_combined = $body->items_combined;
            $paramset_id = $body->paramset_id;
            $screen_width = ($body->screen_width) ? $body->screen_width : 500;
            $execution_id = isset($body->execution_id) ? $body->execution_id : '';
            $app_user_name = $this->app_user_name;          
            
            if (isset($body->page)) {
                $page = $body->page;    
            } else{
                $page = 1;
            }    
            
            include_once '../trm/adiha.php.scripts/components/file_path.php';
            
            $ssrs_config = Deal::getSSRSLoginParamset($paramset_id);
            
            $client_date_format = Auth::dateFormat();
            if(count($ssrs_config) < 1) {
                $error = array('status' => "Failed", "message" => "Report(s) not found.");
                $this->response($this->json($error), 404);
            }
            
            $paramset_id = "paramset_id:".$paramset_id;
            $report_filter = "report_filter:''".$report_filter."''";
        
            #report view params (Global/User)
            $report_region = isset($ssrs_config[0]['REPORT_REGION']) ? $ssrs_config[0]['REPORT_REGION'] : 'en-US';
            $rfx_report_default_param = array(
                'report_region' => $report_region,
                'runtime_user' => $app_user_name,
                'global_currency_format' => '$',
                'global_date_format' => str_replace('mm', 'M', $client_date_format[0]['date_format']),
                'global_thousand_format' => ',#',
                'global_rounding_format' => '#0.00',
                'global_science_rounding_format' => '2',
                'global_negative_mark_format' => '1'
            );

            
            $parameters = $items_combined.','.$paramset_id.','.$report_filter;
            
            $parameters .= ",report_region:".$rfx_report_default_param['report_region'];
            $parameters .= ",runtime_user:".$rfx_report_default_param['runtime_user'];
            $parameters .= ",global_currency_format:".$rfx_report_default_param['global_currency_format'];
            $parameters .= ",global_date_format:".$rfx_report_default_param['global_date_format'];
            $parameters .= ",global_thousand_format:".$rfx_report_default_param['global_thousand_format'];
            $parameters .= ",global_rounding_format:".$rfx_report_default_param['global_rounding_format'];
            $parameters .= ",global_science_rounding_format:".$rfx_report_default_param['global_science_rounding_format'];
            $parameters .= ",global_negative_mark_format:".$rfx_report_default_param['global_negative_mark_format'];
            
            $file_att_path = str_replace('adiha_pm_html/process_controls/clientImageFile.jpg','dev/shared_docs/temp_Note/',$ssrs_config[0]['file_attachment_path']);
			
            $device_info = "<DeviceInfo><Toolbar>False</Toolbar><Section>".$page."</Section><StreamRoot>".$file_att_path."</StreamRoot><ReplacementRoot></ReplacementRoot></DeviceInfo>";
            
            $sorting = "";
            $toggle_item = "";
            $export_type = "HTML4.0";
            
            
            $results_arr = Report::getViewReport($report_name, $parameters, $device_info, $sorting, $toggle_item, $execution_id, $export_type);
                    //var_dump($results_arr); die();
            $result_html = $results_arr[0]['Html'];
                        
            $initial_scale = ($screen_width > 400) ? '0.9' : '0.4';
            $result_html = preg_replace('!custom_sort(.*?)<img(.*?)onerror=.*?src(.*?)unsorted.gif"(.*?)>!i', '">', $result_html);
            $result_html = preg_replace('!show_hide_toggle(.*?)<img(.*?)onerror=.*?src(.*?)ToggleMinus.gif"(.*?)>!i', '">', $result_html);
            $result_html = preg_replace('!ShowHideToggle(.*?)</a>!i', 'ShowHideToggle="></a>', $result_html);
            $result_html = preg_replace('!<style type="text/css">!', '<meta name="viewport" content="user-scalable=yes, width=device-width, initial-scale='.$initial_scale.'; maximum-scale=1.0; minimum-scale=0.25" /><style type="text/css">', $result_html);
            $result =  '<?xml version="1.0" encoding="UTF-8"?>
                <root>
                   <paging>
                      <current>' . $page . '</current>
                      <total>' . $results_arr[0]["TotalPages"] . '</total>
                      <execution_id>' . $results_arr[0]["ExecutionID"] . '</execution_id>
                   </paging>
                   <report_html><![CDATA[' . $result_html . ']]></report_html>
                </root>';
            
            
            if (strpos($result, 'rsProcessingError') !== false) {
                $this->error_show('rsProcessingError');
            } else if (strpos($result, 'rsProcessingAborted') !== false) {
                $this->error_show('rsProcessingAborted');
            } else if (strpos($result, 'rsItemNotFound') !== false) {
                $this->error_show('rsItemNotFound');
            } else if (strpos($result, 'rsInvalidParameter') !== false) {
                $this->error_show('rsInvalidParameter');
            } else if (strpos($result, 'rsMissingParameter') !== false) {
                $this->error_show('rsMissingParameter');
            } else if (strpos($result, 'rsExecutionNotFound') !== false) {
                $this->error_show('rsExecutionNotFound');
            } else if (strpos($result, 'rsMissingElement') !== false) {
                $this->error_show('rsMissingElement');
            } else if (strpos($result, 'Report processing is aborted.') !== false) {
                $error = array('status' => "Failed", "message" => "Report processing is aborted. Please check sql used.");
                $this->response($this->json($error), 404);  // If no records "No Content" status
            } else if (strpos($result, 'SOAP-ERROR') !== false) {
                $error = array('status' => "Failed", "message" => "Report processing is aborted.");
                $this->response($this->json($error), 404);  // If no records "No Content" status
            } else if (strpos($result, 'Report has not been deployed') !== false) {
                $error = array('status' => "Failed", "message" => "Report has not been deployed yet to the application.");
                $this->response($this->json($error), 404);  // If no records "No Content" status
            }
            
            ob_get_clean();
            //header('Content-type: application/xml');
            echo $result;
        } else {
            $error = array('status' => "Failed", "message" => "Report(s) not found.");
            $this->response($this->json($error), 404);  // If no records "No Content" status
        }
    }
    
    /**
     * get Custom Report View : Trade Ticket, Invoice, Confirmation
     *
     * @param   String  $report_name    Report Name
     * @param   String  $parameters     Parameters
     * @param   Integer  $screen_width    Screen Width
     *
     * @return  JSON         View Data or Failure Message
     */
    public function viewCustomReport($report_name, $parameters, $screen_width) {
        global $farrms_client_dir, $app_php_script_loc;
        include_once '../trm/adiha.php.scripts/components/file_path.php';
        
        $page = 1;
            
        $device_info = "<DeviceInfo><Toolbar>False</Toolbar><Section>".$page."</Section><StreamRoot>".$app_php_script_loc."dev/shared_docs/temp_Note/</StreamRoot><ReplacementRoot></ReplacementRoot></DeviceInfo>";
        $sorting = "";
        $toggle_item = "";
        $execution_id = "";
        $export_type = "HTML4.0";
                
        $results_arr = Report::getViewReport($report_name, $parameters, $device_info, $sorting, $toggle_item, $execution_id, $export_type);
                //var_dump($results_arr); die();
        $result_html = $results_arr[0]['Html'] ?? '';
                        
        $initial_scale = ($screen_width > 400) ? '0.9' : '0.45';
        $result = preg_replace('!<style type="text/css">!', '<meta name="viewport" content="user-scalable=yes, width=device-width, initial-scale='.$initial_scale.'; maximum-scale=1.0; minimum-scale=0.25" /><style type="text/css">', $result_html);
        
        if (strpos($result, 'rsProcessingError') !== false) {
            $this->error_show('rsProcessingError');
        } else if (strpos($result, 'rsProcessingAborted') !== false) {
            $this->error_show('rsProcessingAborted');
        } else if (strpos($result, 'rsItemNotFound') !== false) {
            $this->error_show('rsItemNotFound');
        } else if (strpos($result, 'rsInvalidParameter') !== false) {
            $this->error_show('rsInvalidParameter');
        } else if (strpos($result, 'rsMissingParameter') !== false) {
            $this->error_show('rsMissingParameter');
        } else if (strpos($result, 'rsExecutionNotFound') !== false) {
            $this->error_show('rsExecutionNotFound');
        } else if (strpos($result, 'SOAP-ERROR') !== false) {
            $error = array('status' => "Failed", "message" => "Report processing is aborted.");
            $this->response($this->json($error), 404);  // If no records "No Content" status
        } else if (strpos($result, 'Report has not been deployed') !== false) {
            $error = array('status' => "Failed", "message" => "Report has not been deployed yet to the application.");
            $this->response($this->json($error), 404);  // If no records "No Content" status
        }
        
        $this->_content_type = 'text/html';
        $this->response($result, 200);
    }
    
    /**
     * Get Trade Ticket Report View
     *
     * @param   String  $deal_ids  Comma separated Deal IDs
     *
     * @return  JSON             Trade Ticket Report
     */
    public function tradeticket($deal_ids) {
        $this->tradeticketWithWidth($deal_ids,500);
    }
    
    /**
     * Get Trade Ticket Report View
     *
     * @param   String  $deal_ids  Comma separated Deal IDs
     * @param   Integer  $screen_width  Screen Width
     *
     * @return  JSON             Trade Ticket Report
     */
    public function tradeticketWithWidth($deal_ids,$screen_width) {        
        
        $report_name = "custom_reports/Trade Ticket Collection";
        $parameters = "source_deal_header_id:" . $deal_ids;
        
        $this->viewCustomReport($report_name, $parameters, $screen_width);
    }
    
    /**
     * Get Confirmation Report View
     *
     * @param   String  $deal_ids  Comma separated Deal IDs
     *
     * @return  JSON             Confirmation Report
     */
    public function confirmation($deal_ids) {
        $this->confirmationWithWidth($deal_ids,500);
    }
    
    /**
     * Get Confirmation Report View
     *
     * @param   String  $deal_ids  Comma separated Deal IDs
     * @param   Integer  $screen_width  Screen Width
     *
     * @return  JSON             Confirmation Report
     */
    public function confirmationWithWidth($deal_ids,$screen_width) {
        $report_name = "custom_reports/Confirm Replacement Report Collection";
        $parameters = "source_deal_header_id:" . $deal_ids;
        
        $this->viewCustomReport($report_name, $parameters, $screen_width);      
    }
    
    /**
     * Get Invoice Report View
     *
     * @param   String  $deal_ids  Comma separated Deal IDs
     *
     * @return  JSON             Invoice Report
     */
    public function invoice($invoice_ids) {
        $this->invoiceWithWidth($invoice_ids,500);
    }
    
    /**
     * Get Invoice Report View
     *
     * @param   String  $deal_ids  Comma separated Deal IDs
     * @param   Integer  $screen_width  Screen Width
     * 
     * @return  JSON             Invoice Report
     */
    public function invoiceWithWidth($invoice_ids,$screen_width) {
        $report_name = "custom_reports/Invoice Report Collection";
        $parameters = "export_type:HTML4.0,invoice_ids:" . $invoice_ids;

        $this->viewCustomReport($report_name, $parameters, $screen_width);
    }
    
    /**
     * Show Error Description
     *
     * @param   String  $errcode  Error Code
     *
     * @return  JSON            Error Description
     */
    public function error_show($errcode) {
        $exception_msg = array(
            'rrRenderingError' => 'Report page couldnot be found. click to go to First page of report.',
            'rsItemNotFound' => 'Report has not been deployed yet to the application.',
            'rsInvalidParameter' => 'Invalid Parameter(s) specified.',
            'rsMissingParameter' => 'Required Parameter(s) is missing.',
            'rsAccessDenied' => 'Access Denied.',
            'rsExecutionNotFound' => 'Report has expired. Please re-run the report from Report Manager.',
            'rsProcessingAborted' => 'Report processing is aborted. Check SQL used.',
            'rsMissingElement' => 'The required field Name is missing from the input structure.'
        );
        
        $error = array('status' => "Failed", "message" =>  $exception_msg[$errcode]);
        $this->response($this->json($error), 400);
    }
    
    /**
     * Get List of Reports
     *
     * @return  JSON  List of Reports
     */
    public function getReportList() {
        $results = Report::getReportList();
		$this->response($this->json($results));
    }
    
    /**
     *  Get Report Parameters
     *
     * @param   Array  $body POST Data
     *
     * @return  JSON         Parameters List
     */
    public function getReportParameter($body) {
		$report_name = $body->report_name;
        $report_hash = $body->report_hash;
        
        $results = Report::getReportParameter($report_name, $report_hash);
        
        if (is_array($results)) {
            $results_size = sizeof($results);
            if ($results_size == 0) {
                $response_json = array('ErrorCode' => 'Success',' Message' => 'No Data Found', 'Recommendation' => '');
                $this->response($this->json($response_json), 200);
                return;
            }
            $this->response($this->json($results));
        } else if ($results == 'not_privilege') {
			$response_json = array('ErrorCode' => 'Error', 'Message' => 'Insufficient privilege to run the request.', 'Recommendation' => '');
			$this->response($this->json($response_json), 401);
		} else if ($results == 'invalid_hash') {
            $response_json = array('ErrorCode' => 'Error', 'Message' => 'Invalid Report Hash', 'Recommendation' => '');
			$this->response($this->json($response_json), 200);
        }
    }
    
    /**
     * Get Report Data using API Service
     *
     * @param   Array  $body POST Data
     *
     * @return  JSON        Report Data
     */
    public function getReportData($body) {
		$report_hash = $body->report_hash;
        $report_parameters = $body->report_parameters;
        
		$results = (new Report)->getReportData($report_hash, $report_parameters);
        
        if (is_array($results)) {
            $results_size = sizeof($results);
            if ($results_size == 0) {
                $response_json = array('ErrorCode' => 'Success',' Message' => 'No Data Found', 'Recommendation' => '');
                $this->response($this->json($response_json), 200);
                return;
            }
            $this->response($this->json($results));
        } else if ($results == 'not_privilege') {
			$response_json = array('ErrorCode' => 'Error', 'Message' => 'Insufficient privilege to run the report.', 'Recommendation' => '');
			$this->response($this->json($response_json), 401);
		} else if ($results == 'invalid_hash') {
            $response_json = array('ErrorCode' => 'Error', 'Message' => 'Invalid Report Hash', 'Recommendation' => '');
			$this->response($this->json($response_json), 200);
        }
    }
}
