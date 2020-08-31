<?php
/**
* Report viewer custom screen
* @copyright Pioneer Solutions
*/
?>
<?php
    ob_start();
    include "../../../adiha.php.scripts/components/include.file.v3.php";
    $php_script_loc = $app_php_script_loc;
    global $app_adiha_loc;
    $form_name = "report_viewer_custom";
    $call_from = isset($_GET['call_from']) ? $_GET['call_from'] : '';
    /*
    if ($call_from != 'DASHBOARD') {
        echo paint_formHeaderUI("FARRMS: Report Viewer");
    }
    */
    $report_folder = '/' . $ssrs_config["REPORT_TARGET_FOLDER"] . '/';
    $arguments = array();
    $arguments['__user_name__'] = $_GET['__user_name__'];
    $arguments['session_id'] = $_GET['session_id'];
    $arguments['disable_header'] = $_GET['disable_header']; //$arguments['disable_header'] = 1 for single custom report and $arguments['disable_header'] = 2 for multiple invoice view.
    $arguments['windowTitle'] = $_GET['windowTitle'];
    $arguments['report_name'] = isset($_GET['report_name']) ? $_GET['report_name'] : '';
    $arguments['report_title'] = isset($_GET['report_title']) ? $_GET['report_title'] : '';
    $arguments['export_type'] = isset($_GET['export_type']) ? $_GET['export_type'] : '';
    $arguments['trade_type_pdf']  = isset($_GET['trade_type_pdf']) ? $_GET['trade_type_pdf'] : '';
    $arguments['is_excel'] = (isset($_GET['is_excel']) ? $_GET['is_excel']: 0);
    $arguments['invoice_ids'] = (isset($_GET['invoice_ids']) ? $_GET['invoice_ids']: 0);
    $arguments['flag'] = (isset($_GET['flag']) ? $_GET['flag']: 'a');
    $arguments['source_deal_header_id'] = (isset($_GET['source_deal_header_id']) ? $_GET['source_deal_header_id']: 0);
    $arguments['t_type'] = (isset($_GET['t_type']) ? $_GET['t_type']: 0);
    $arguments['t_category'] = (isset($_GET['t_category']) ? $_GET['t_category']: 0);

    $arguments['page'] = (isset($_GET['page']) && intval($_GET['page']) > 0) ? intval($_GET['page']) : 1;
    $arguments['page_total'] = (isset($_GET['page_total']) && intval($_GET['page_total']) > 0) ? intval($_GET['page_total']) : 1;
    $arguments['call_from'] = $call_from;
    $arguments['param_list'] = trim($_GET['param_list']);


    if($arguments['flag'] == 'b') {
        $custom_params_list = ($arguments['t_type'] == -38) ? substr($arguments['param_list'], 0, 41) : substr($arguments['param_list'], 0, 21);
    } else {
        $custom_params_list = ($arguments['t_type'] == 38) ? substr($arguments['param_list'], 0, 36) : substr($arguments['param_list'], 0, 21);
    }

    $batch_function = (isset($_GET['batch_call']) && ($_GET['batch_call']) == 'y') ? ('batch_pressed();') : '';
    $batch_call_from = (isset($_GET['batch_call_from'])) ? $_GET['batch_call_from'] : '';

    $custom_params_list = ($custom_params_list != '') ? explode(',', $custom_params_list) : array();
    
    //previously the value of $arguments['export_type'] is taken as the template file name which is actually the template name. 
    //so when the template name is updated from the Report Template Setup form the path becomes invalid.
    //so instead of template name the actual file name is taken instead of template name.
    //$xml_file = $php_script_loc . 'spa_contract_report_template.php?flag=f&file_name=' . $report_name . '&use_grid_labels=false&__user_name__=' . $app_user_name;
    //$return_value = readXMLURL($xml_file);
    //$file_name = $return_value[0][0];

    $report_name = $arguments['report_name'];
    $img_path = $app_php_script_loc . "adiha_pm_html/process_controls/toolbar";
    $img_path_on_click = $app_php_script_loc . "adiha_pm_html/process_controls/toolbar_onClick";
    $img_path_on_over = $app_php_script_loc . "adiha_pm_html/process_controls/toolbar_onOver";
    $export_type_bkp = $arguments['export_type'];

    //excel template view
    $template_type = $arguments['t_type'];
    $template_category = $arguments['t_category'];
    
    $object_id =  ($template_type == 38) || ($template_type == -38)  ? $arguments['invoice_ids'] : $arguments['source_deal_header_id'];
    
    if ($arguments['is_excel'] == 1)
    {   
       // $file_format = ($arguments['is_excel'] == 1 && $arguments['export_type'] == 'HTML4.0' && $arguments['trade_type_pdf'] != 'PDF') ? 'PNG' : 'PDF';

        if ($arguments['is_excel'] == 1 && $arguments['export_type'] == 'HTML4.0' && $arguments['trade_type_pdf'] != 'PDF') {
            $file_format = 'PNG';
        } else if($arguments['is_excel'] == 1 && $arguments['export_type'] == 'EXCEL' && $arguments['trade_type_pdf'] != 'PDF'){
            $file_format = 'EXCEL';
        } else {
             $file_format = 'PDF';
        }

        $url_generate_document_from_excel = "EXEC spa_generate_document_from_excel @object_id='" . $object_id . "', @template_type='" . $template_type . "', @template_category='" . $template_category . "', @export_format = '".$file_format."'";
        $data_param = readXMLURL2($url_generate_document_from_excel);
        $document_name = $data_param[0]['document_name'];
        $status = $data_param[0]['status'];
        $description = $data_param[0]['description'];

        if ($arguments['export_type'] == 'HTML4.0' &&  $arguments['trade_type_pdf'] != 'PDF')
        {
            $snapshot_filename =  $php_script_loc.'dev/shared_docs/temp_note/' . $document_name;
            $snapshot_filename_img =  '<img src="'.$snapshot_filename.'" />';
        ?>  
        <div id="report-body">
            <div id="cn-ssrs-viewer-report">
                <div style="margin-bottom: 8px;"></div>
                <?php
                    if ($status == 'Success')
                    {
                        $result_html = $snapshot_filename_img;
                    } else {
                        $result_html = $description;
                    }
                    echo ($result_html);
                ?>
                </div>
            </div>
        <p>&nbsp;</p>
        <script type="text/javascript">
            
            $(function() {
                if (parent.parent.window_trade_ticket) {
                    parent.parent.window_trade_ticket.progressOff();
                }

                if (parent.window_invoice) {
                    parent.window_invoice.progressOff();
                }

            });

        </script>
        <?php
       } else {
        //header('Location:'. $php_script_loc.'force_download.php?path=dev/shared_docs/temp_note/'. $document_name);
		
        //exit;
		ob_clean();
		echo '<script type="text/javascript">';
		echo 'parent.window_download("' . $php_script_loc.'force_download.php?path=dev/shared_docs/temp_note/'. $document_name.'");';
		echo '</script>';
       }  
       die(); 
    }
    
    if (strpos($report_name, '.') == true) {
        $doc_name = explode('.', $report_name);
        $doc_type = array_pop($doc_name);
        $doc_name = implode('.',$doc_name);    
    } else $doc_name = $report_name;

    $doc_title = $arguments['report_title'];
    
    $batch_call_param = '';
    
    if (is_array($custom_params_list) && sizeof($custom_params_list) > 0) {
        foreach ($custom_params_list as $param_name) {
            $batch_call_param .= isset($_GET[$param_name]) ? '&' . $param_name . '=' . $_GET[$param_name] : '';
            $arguments[$param_name] = isset($_GET[$param_name]) ? $_GET[$param_name] : '';
        }
    }

    $batch_counterparty_id = ($batch_call_from == 'invoice') ? $arguments['counterparty_id'] : '';

    $batch_call_param = substr($batch_call_param, 1);
    
    if ($doc_name == 'Confirm Replacement Report Collection' || $doc_name == 'Trade Ticket Collection') {
        $batch_call_param = str_replace('HTML4.0','PDF',$batch_call_param);
    }
    //ob_clean();
    #use relative path only; absolute not supported
    $image_path = '../../../' . $relative_temp_path . '/';

    if ($doc_name != '') {
		$xml_url_report_paramset_name = "EXEC spa_rfx_report_paramset @flag='m'";
        $data_url_major_ver = readXMLURL2($xml_url_report_paramset_name);
        $major_version_no = $data_url_major_ver[0]['major_version_no'];

        function get_report_url($args, $page = NULL) {
            $url_partial = '';

            foreach ($args as $ky => $arg) {
                if ($ky != 'page')
                    $url_partial .= $ky . '=' . $arg . '&amp;';
            }

            if ($page != NULL)
                $url_partial .= 'page=' . $page;
            return get_page_url() . '?' . $url_partial;
        }

        function get_page_url() {
            $page_url = $_SERVER["HTTPS"] == "on" ? 'https://' : 'http://';
            $uri = $_SERVER["REQUEST_URI"];
            $index = strpos($uri, '?');

            if ($index !== false) {
                $uri = substr($uri, 0, $index);
            }

            $page_url .= $_SERVER["SERVER_NAME"] . ":" . $_SERVER["SERVER_PORT"] . $uri;
            return $page_url;
        }

        
        function get_extension($type, $major_version_no) {
            switch ($type) {
                case "CSV":
                    return array('.csv', 'application/csv');
                case "EXCEL":
                    ob_clean();
                    //return (intval($major_version_no) > 10 )?array('.xlsx', 'application/vnd.ms-excel'):array('.xls', 'application/vnd.ms-excel');
					return array('.xls', 'application/vnd.ms-excel');
                case "IMAGE":
                    return array('.tiff', 'image/tiff');
                case "PDF":
                    return array('.pdf', 'application/pdf');
                case "WORD":
                    return array('.doc', 'application/msword');
                case "XML":
                    ob_clean();
                    return array('.xml', 'application/vnd.ms-excel');
                case "MHTML":
                    return array('.mht', 'message/rfc82');
                default:
                    return array('', 'application/force-download');
            }
        }

        $report = 'custom_reports/' . $doc_name;
        $result_html = '';
        $exception_msg = '';

        
            $next_page = $arguments['page'];

            /********************************/
            $param_arr = array();
            $parameters = '';
            //$parameters = 'report_region:en-US';
            if (is_array($custom_params_list) && sizeof($custom_params_list) > 0) {
                foreach ($custom_params_list as $pname) {
                    array_push($param_arr, $pname . ':' . $arguments[$pname]);
                }
            }
            
            $parameters = implode(',', $param_arr);

             $ssrs_sql = "EXEC spa_ssrs_html @report_name = '".$report."', @parameters='".$parameters."', @device_info='<DeviceInfo><Toolbar>False</Toolbar><Section>".$next_page."</Section><StreamRoot>".$app_php_script_loc."dev/shared_docs/temp_Note/</StreamRoot><ReplacementRoot></ReplacementRoot></DeviceInfo>'";
            
            if (isset($_REQUEST['rs:SortId']) && $_REQUEST['rs:SortId'] <> 'Sort') {
                $ssrs_sql .= ", @sorting='<Sort><Item>".$_REQUEST['rs:SortId']."</Item><Direction>".$_REQUEST['rs:SortDirection']."</Direction><Clear>".$_REQUEST['rs:ClearSort']."</Clear></Sort>'";
            }
            if (isset($_REQUEST['rs:ShowHideToggle'])) {
                $ssrs_sql .= ", @toggle_item='" . $_REQUEST['rs:ShowHideToggle'] . "'";
            }

            if (isset($_REQUEST['rs:execution_id'])) {
                $ssrs_sql .= ", @execution_id='" . $_REQUEST['rs:execution_id'] . "'";
            }

            $ssrs_sql .= ", @export_type='" . $arguments['export_type'] . "'";

            $ssrs_data = readXMLURL2($ssrs_sql);
            $ssrs_status = $ssrs_data[0]['status'];
			$errcode = '';
            if ($ssrs_status == 'Success') {
                $result_html = $ssrs_data[0]['html'];
                $total_pages = $ssrs_data[0]['totalpages'];
                $execution_id = $ssrs_data[0]['executionid'];
            } else {
                $errcode = $ssrs_data[0]['html'];
                $result_html = "";
                $total_pages = 1;
                $execution_id = '';
            }


            $_SESSION['page_total'] = $total_pages;
            /**********************/

            //force Download
            if ($arguments['export_type'] != "HTML4.0") {
                ob_clean();
                $ext_info = get_extension($arguments['export_type'],$major_version_no);
                header('Content-Type: application/octet-stream');
                header("Content-Transfer-Encoding: Binary"); 
                header("Content-disposition: attachment; filename=\"" . $execution_id . $ext_info[0]. "\""); 

                readfile($result_html);
                exit;
            }

            $exception_msg = array(
            'rrRenderingError' => get_locale_value('Report page couldnot be found. click', false) . '<a href="' . get_report_url($arguments, 1) . '">' . get_locale_value('here', false) . '</a>' . get_locale_value('to go to First page of report.', false),
            'rsItemNotFound' => get_locale_value('Report has not been deployed yet to the application.', false),
            'rsInvalidParameter' => get_locale_value('Invalid Parameter(s) specified.', false),
            'rsMissingParameter' => get_locale_value('Required Parameter(s) is missing.', false),
            'rsAccessDenied' => get_locale_value('Access Denied.', false),
            'rsExecutionNotFound' => get_locale_value('Report has expired. Please re-run the report from Report Manager.', false),
            'rsProcessingAborted' => get_locale_value('Report processing is aborted. Check SQL used.', false),
        );
        
        ?>
        <style type="text/css">
            body {
                background: white;
                overflow-x: hidden;
            }  

            #report-body {
                margin:0;
            }

            #cn-ssrs-viewer-report {
                border-top: 1px solid <?php echo ($arguments['disable_header'] != '1') ? 'steelblue' : 'white'; ?>;
            }

            .cn-ssrs-viewer-paginator {
                text-align: right;
                padding:4px;
                height:25px;
            }

            #report-name {
                font-family: 'Tahoma';
                font-size: 15px;    
                font-weight: bold;
            }

            .tree-navigator .plus {
                background-image: url('<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/TogglePlus.gif');
                background-repeat:no-repeat; 
                cursor: hand; 
                font-weight: bold;
            }

            .tree-navigator .minus {
                background-image: url('<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/ToggleMinus.gif');
            }

            .tree-navigator {  
                margin-bottom: 2px;
                padding-right: 2px;
                text-indent: 12px;
            }

            .child {
                display:none;
                text-indent: 12px;
                margin-left: 20px;
            }

            #fixed-bar {
                width:100%;
                height:35px;                
                background: #ffffff;
                margin-top: 0px;
                border-top: 4px #ffffff solid;
            }
            
            .ieixedbar {               
               position: relative;              
            }

        </style>
        <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui-1.8.20.custom.min.js"></script>
        <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery.fixedposition.js"></script>
        
        <script type="text/javascript">
            $(function() {

                if (parent.parent.window_trade_ticket) {
                    parent.parent.window_trade_ticket.progressOff();
                }
                
                if (parent.window_invoice) {
                    parent.window_invoice.progressOff();
                }

                $('img[src$="ToggleMinus.gif"]').attr('src', '<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/ToggleMinus.gif');
                $('img[src$="TogglePlus.gif"]').attr('src', '<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/TogglePlus.gif');
                $('img[src$="unsorted.gif"]').attr('src', '<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/unsorted.gif');
                $('img[src$="sortAsc.gif"]').attr('src', '<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/sortAsc.gif');
                $('img[src$="sortDesc.gif"]').attr('src', '<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/sortDesc.gif');
                                                        
                $('.cn-ssrs-viewer-paginator a[href!="javascript:void(0)"]').click(function() {
                    $('#hourglass').show();
                });
                                                        
                $('.cn-ssrs-viewer-paginator a[href="javascript:void(0)"]').each(function() {
                    var link_object = $('img', $(this));
                    link_object.attr('src', link_object.attr('src').replace('.gif', '_disable.gif'));
                });
                                                        
                hideHourGlass();
                                                        
                $('#page-list').change(function() {
                    var page_segment = 'page=' + $(this).val();
                    var page_url = '<?php echo get_report_url($arguments); ?>' + page_segment; 
                    window.location = page_url;
                                                                                    
                });
                                                        
                $('#page-list').val('<?php echo $arguments['page']; ?>');
                
                $(".tree-navigator .plus").click(function() {
                    $(this).toggleClass( "tree-navigator minus"); 
                    var current_item = $('#report-body').find('.child');
                    
                    if (current_item.css('display') == 'none') {
                        current_item.fadeIn('fast');
                    } else {
                        current_item.fadeOut('fast');
                    }
                });
                                                        
                $("#fixed-bar").fixedPosition({
                    debug: false,
                    fixedTo: "top"
                });

            }); 
                                                    
        </script>
        
        <?php if ($arguments['disable_header'] != '2'): ?> 
            <div id="fixed-bar">
                <table class='ExportBGColor'>
                    <tr>
                        <td nowrap>
                            <img src="<?php echo $img_path; ?>/grid.jpg" class="ExportTool" 
                                 onClick="window.parent.reload_rfx_frame();" 
                                 onMouseOver="change_btn_image(this, '<?php echo $img_path_on_over; ?>/grid.jpg')" 
                                 onMouseDown="change_btn_image(this, '<?php echo $img_path_on_click; ?>/grid.jpg')" 
                                 onmouseout="change_btn_image(this, '<?php echo $img_path; ?>/grid.jpg')" alt='REFRESH'>                                
                            <img src="<?php echo $img_path; ?>/excel.jpg" class="ExportTool" 
                                onclick="window.open('<?php
                                                        $arguments['export_type'] = 'EXCEL';
                                                        echo get_report_url($arguments, '')
                                                        ?>');" 
                                onMouseOver="change_btn_image(this, '<?php echo $img_path_on_over; ?>/excel.jpg')" 
                                onMouseDown="change_btn_image(this, '<?php echo $img_path_on_click; ?>/excel.jpg')" 
                                onmouseout="change_btn_image(this, '<?php echo $img_path; ?>/excel.jpg')" alt='EXCEL'>
                            <img src="<?php echo $img_path; ?>/pdf.jpg" class="ExportTool" 
                                 onclick="window.open('<?php
                                                        $arguments['export_type'] = 'PDF';
                                                        echo get_report_url($arguments, '')
                                                        ?>');" 
                                 onMouseOver="change_btn_image(this, '<?php echo $img_path_on_over; ?>/pdf.jpg')" 
                                 onMouseDown="change_btn_image(this, '<?php echo $img_path_on_click; ?>/pdf.jpg')" 
                                 onmouseout="change_btn_image(this, '<?php echo $img_path; ?>/pdf.jpg')" alt='PDF'>
                            <?php if ($batch_function != '') { ?>
                                <img src="<?php echo $img_path ?>/batch.jpg" class="ExportTool" 
                                     onclick="<?php echo $batch_function; ?>" 
                                     onMouseOver="change_btn_image(this, '<?php echo $img_path_on_over; ?>/batch.jpg')" 
                                     onMouseDown="change_btn_image(this, '<?php echo $img_path_on_click; ?>/batch.jpg')" 
                                     onmouseout="change_btn_image(this, '<?php echo $img_path; ?>/batch.jpg')" alt='BATCH'>
                            <?php } ?>
                        </td>
                    </tr>
                </table>
            </div>
        <?php endif; ?>
        <div id="report-body">
            <?php if ($arguments['disable_header'] != '1'): ?>
                <?php if ($arguments['disable_header'] != '2'): ?> 
                    <div id="cn-ssrs-viewer-header">
                        <p id="report-name"><?php echo str_replace('_', ' ', $doc_title); ?></p>
                    </div>
                    <div class="tree-navigator" >
                        <div class="plus"> <label class=""><?php echo get_locale_value('Report Filter', true); ?></label></div>
                        <div class="child" >
                            <?php
                            if (is_array($custom_params_list) && sizeof($custom_params_list) > 0) {
                                foreach ($custom_params_list as $pkey => $pname) {
                                    $custom_params_list[$pkey] = ucfirst($pname) . "=" . $arguments[$pname];
                                }
                                echo implode(',', $custom_params_list);
                            } else {
                                echo '<small>(' . get_locale_value('no parameter specified', false) . ')</small>';
                            }
                            ?> 
                        </div> 
                    </div>
                <?php endif; ?>
                <div class="cn-ssrs-viewer-paginator">
                    <?php
                    $arguments['export_type'] = $export_type_bkp;
                    $href_first = "javascript:void(0)";
                    $href_prev = "javascript:void(0)";
                    $href_next = "javascript:void(0)";
                    $href_last = "javascript:void(0)";

                    if ($next_page != 1) {
                        $href_first = get_report_url($arguments, '');
                    }

                    if ($next_page >= 2) {
                        $href_prev = get_report_url($arguments, ($next_page - 1));
                    }

                    if ($next_page < $_SESSION['page_total'] && $next_page != $_SESSION['page_total']) {
                        $href_next = get_report_url($arguments, ($next_page + 1));
                    }
                    if ($next_page != $arguments['page_total']) {
                        $href_last = get_report_url($arguments, $arguments['page_total']);
                    }
                    ?>
                    <table align="right">
                        <tr>
                            <td><a href="<?php echo $href_first; ?>"><img style="cursor: pointer" title="First Page"  border="0" name="im_first_deal_page" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/paging/move_first.gif"></a></td>
                            <td><a href="<?php echo $href_prev; ?>"><img style="cursor: pointer" title="Previous Page"  border="0" name=im_prev_deal_page src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/paging/move_prev.gif"></a></td>
                            <td id="label_paging">&nbsp;
                                <?php echo $arguments['page'], ' of ', $arguments['page_total'], ' Pages'; ?></td>
                            <td>
                                <select class="adiha_control" id="page-list" >
                                    <?php for ($x = 1; $x <= $arguments['page_total']; $x++) { ?>
                                        <option value="<?php echo $x ?>" > <?php echo $x; ?></option>
                                    <?php } ?>
                                </select>
                            </td>
                            <td><a href="<?php echo $href_next; ?>"><img style="cursor: pointer" title="Next Page"  border="0" name="im_next_deal_page" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/paging/move_next.gif"></a></td>
                            <td><a href="<?php echo $href_last; ?>"><img style="cursor: pointer; bordercolor: black" title="Last Page"   border=0 name=im_last_deal_page src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/paging/move_last.gif"></a></td>
                        </tr>
                    </table>
                </div>
            <?php endif; ?>
            <div id="cn-ssrs-viewer-report">
                <div style="margin-bottom: 8px;"></div>
                <?php
                echo (strlen($errcode) > 0) ? $exception_msg[$errcode] : '';
                echo ($result_html);
                ?>
            </div>
        </div>
        <p>&nbsp;</p>
    <?php } ?>
    <?php if ($batch_function != '') { ?>    
        <script lang="text/javascript">
            /** RFX Cutom Batch Intregation Start **/
             function batch_pressed() {
                var php_path = '<?php echo $app_php_script_loc; ?>';
                var batch_call_from = '<?php echo $batch_call_from; ?>';
                var date_object = new Date();
                var date_str = '_' + date_object.getFullYear() + '_' +date_object.getMonth() + '_' +date_object.getDate() + '_' + date_object.getHours() + '_' + date_object.getMinutes() + '_' + date_object.getSeconds();
                var report_name = '<?php echo $doc_name; ?>';
                var rdl_report_name = report_name;
                // Changed the form title name for Confirm Replacement Report Collection.rdl
                if (report_name == 'Confirm Replacement Report Collection') {
                    report_name = 'Confirmation Report Batch';
                    rdl_report_name = 'Confirm Replacement Report Collection';
                } else if (report_name == 'TT1') {
                    report_name = 'Trade Ticket';
                    rdl_report_name = 'Trade Ticket Collection';
                }

                var report_filter = '<?php echo str_replace('&', ';', str_replace('=', ':', $batch_call_param)); ?>';
                var batch_counterparty_id = '<?php echo $batch_counterparty_id; ?>';
                var arg = "call_from=Report Batch Job&gen_as_of_date=1&rfx=1";
                var report_title = '<?php echo $doc_title; ?>';
                
                is_ftp_enabled = 'n'; // feature not available              
                var ftp_param = construct_report_export_ftp_cmd(is_ftp_enabled);
                var param = 'call_from=Report Batch Job&gen_as_of_date=1&rfx=1';
               
                if (batch_call_from == 'invoice') {
                    param = param + '&batch_counterparty_id=' + batch_counterparty_id;
                } else if (batch_call_from == 'trade_ticket') {
                    param = 'call_from=Report Batch Job&rfx=1';
                }
                
                var cmd_command = construct_report_export_cmd(report_title + date_str, rdl_report_name , report_filter);
                var exec_call = return_batch_sp_call(cmd_command, report_title, report_title + date_str + '.pdf');
                exec_call = exec_call + ",'" + ftp_param + "'";   
                adiha_run_batch_process(exec_call, param, report_name);  
            }
                                                                
            function construct_report_export_ftp_cmd(flag) {            
                if (flag == 'y') {
                    var ftp_call = '<?php
                                    $ftp_cmd = "rs";
                                    $ftp_cmd .= " -e Exec2005";
                                    $ftp_cmd .= " -s " . $ssrs_config['SERVICE_URL'];
                                    $ftp_cmd .= ' -i "' . addslashes(addslashes($ssrs_config['FTP_RS'])) . '"';
                                    $ftp_cmd .= ' -v vFTPServer="ftp://' . $ssrs_config['FTP_SERV'] . '/' . $ssrs_config['FTP_REMOTE_FILE_PATH'] . '/remote.xls"';
                                    $ftp_cmd .= ' -v vFTPUser="' . $ssrs_config['FTP_USER'] . '"';
                                    $ftp_cmd .= ' -v vFTPPass="' . $ssrs_config['FTP_PSWD'] . '"';
                                    $ftp_cmd .= ' -v vSourceFileName="' . addslashes(addslashes($ssrs_config['FTP_LOCAL_FILE_PATH'])) . '\\\\' . 'local.xls"';

                                    echo $ftp_cmd;
                                    ?>';                             
            } else {
                var ftp_call = "NULL";
            }
            
            return ftp_call;
        }
                                                                
        function construct_report_export_cmd(output_file, report_path, report_filter) {            
            output_file = '\\\\' + output_file;
            var cmd_call = '<?php
                            $report_export_cmd = "rs";
                            $report_export_cmd .= " -e Exec2005";
                            $report_export_cmd .= " -l " . $ssrs_config['RS_TIMEOUT'];
                            $report_export_cmd .= " -s " . $ssrs_config['SERVICE_URL'];
                            $report_export_cmd .= ' -i "' . addslashes(addslashes($ssrs_config['REPORT_EXPORTER_PATH_CUSTOM'])) . '"';
                            $report_export_cmd .= ' -v vFullPathOfOutputFile="' . addslashes(addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL'])) . '' . "' + output_file + '" . '.pdf"';
                            $report_export_cmd .= ' -v vReportPath="' . $ssrs_config['REPORT_TARGET_FOLDER'] . '/custom_reports/' . "' + report_path + '" . '"';
                            $report_export_cmd .= ' -v vFormat="PDF"';
                            $report_export_cmd .= ' -v vReportFilter="' . "' + report_filter + '" . '"';

                            echo $report_export_cmd;
                            ?>';
            return cmd_call;
        }
                                                                        
        function return_batch_sp_call(cmd_command, report_title, report_file) {           
            var batch_report = 'BatchReport';
            var user_name = js_user_name;
            report_file_path = '<?php echo addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL']); ?>/' + report_file;
            return "EXEC spa_rfx_export_report_job '" + cmd_command 
                    + "', '" + batch_report 
                    + "', '" + user_name 
                    + "', '" + report_title 
                    + "', '" + report_file 
                    + "', '" + report_file_path + "'";
        }
        /** RFX End **/  
        </script>
    <?php } ?>