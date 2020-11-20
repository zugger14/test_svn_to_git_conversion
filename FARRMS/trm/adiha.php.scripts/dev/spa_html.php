<?php
/**
 * Builds HTML for reports
 * 
 * @copyright Pioneer Solutions
 */
// Namespaces to use by PHPSpreadsheet while exporting to Excel
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use PhpOffice\PhpSpreadsheet\Style\NumberFormat;

$build_exec_code = [];
    $is_called_from_mobile = isset($_POST['call_from']) && $_POST['call_from'] == 'mobile';
    if ($is_called_from_mobile) {
        echo '<?xml version="1.0" encoding="UTF-8"?>
            <root>
            <report_html><![CDATA[';
                
        $xml_end_struc = ']]>
            </report_html>
            <sql></sql>
            <paging>
                <current>1</current>
                <total>1</total>
            </paging>
        </root>';
    }
    ob_start();
?>
<!--Doctype transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
    <head>
        <style type="text/css">
            .report_header {
                margin-left: 10px;
            }

            .result_wrapper {
                position: absolute;
                width: 100%;    
                padding-left: 10px;
                padding-right: 10px;
                padding-bottom: 10px;    
            }

            .result_wrapper table {
                border-collapse: collapse;
                border: 1px solid #77a7cf;
            }

            .report_grid {
                font-size: 11px;
                border-left: 1px solid #77a7cf;
            }

            .report_grid th {
                height: 14px;
                font-family: Verdana, Arial, Helvetica, sans-serif;
                text-align: left;
                padding: 5px;
                white-space: nowrap;
                background: #2571af url(../graph/flashgraph/bg_header.jpg) repeat-x;
                color: #FFFFFF;
                border-right: 1px solid #77a7cf;
            }

            .report_grid td {
                height: 12px;
                font-family: Tahoma;
                text-align: left;
                padding: 5px;
                white-space: nowrap;
                border-right: 1px solid #77a7cf;
                border-bottom: 1px solid #77a7cf;
            }

            table.report_grid tr:hover {
                background: #C3CCDC !important;
                cursor: pointer;
            }

            .mismatch_data_regression {
                color: red;
                font-weight: bold;
            }

            .report_grid tr {
                background: #f8fbfe; 
            }

            .report_grid tr.total {
                background:#2571af url(../graph/flashgraph/bg_header.jpg) repeat-x; 
                color:#fff; 
                font-weight:bold;
            }

            .report_grid tr.subtotal {
                background-color:#E5F7FF; 
                color:#2571af; 
                font:italic; 
            }

            tr.report_name {
            color:#2571af;
            font-size: 14px;  
            font-family: Verdana;
            font-weight: bold;
            }

            tr.report_detail {
                font-size: 11px;  
                font-family: Verdana;
                font-style: italic;
                background-color:#E5F7FF;
            }

            td.report_param > div { 
                width: 100%; 
                height: 100%; 
            }

            td.report_param {
                border:1px solid #77a7cf;
                padding: 5px;
                display: none;
            }

            .export_button {
                margin-left: 6px;
            }

            .export_button td {
                font-size: 10px;
            
            }
            .toggle_content {
                font-size: 10px;  
                font-family: Verdana;
                color: #000000;
                font-style: italic;
                background-color:#E5F7FF;
                border:1px solid #77a7cf;
                font-weight: normal;
            }

            .report_header_new {
                background-color: #86e2d5;
                padding: 7px;
                width: 97%;
                border: 1px solid #4dcb8c;
                font-family: "Open Sans";
                font-style: italic;
                font-size: 11px;  
                font-weight: bold;
                margin: 10px 10px 5px 12px;
                overflow:hidden;
                height:12px;
            }
        </style>

		<!-- Moved style tag to head -->
        <!-- Added to remove grid scroll -->
        <?php 
            if ($is_called_from_mobile) {
                ?>
                    <style>
                        div.grid {
                            overflow: visible!important;
                        } 
                    </style>;
                <?php
            }
        ?>

        <link href="<?php echo $app_php_script_loc;?>../css/adiha_style.css" rel="stylesheet" type="text/css">
    </head>
    <body>
        <div id="window_label" style="display: none;"></div>
        <div id="window_name" style="display: none;"></div>
        <div id="file_path" style="display: none;"></div>

        <?php
            $sql = isset($_REQUEST['spa']) ? urldecode($_REQUEST["spa"]) : '';

        require_once "../components/include.file.v3.php";

            if ($is_called_from_mobile) {
                $new_db_name = $_POST['new_db_name'];
                $new_db_server_name = $_POST['new_db_server_name'];
                $app_user_name = $_POST['app_user_name'];
                
                include_once '../../../' . $_POST['farrms_client_dir'] . '/adiha.config.ini.rec.php';
                require_once "../components/lib/adiha.xml.parser.1.0.php";
                require_once "../components/lib/adiha_dhtmlx/adiha_php_functions.3.0.php";
            }

            $show_header = (isset($_REQUEST['show_header'])) ? $_REQUEST['show_header'] : 'true';

            if ($show_header == null) {
                $show_header = 'false';
            }

            if ((isset($_REQUEST["writeFile"]) == true) && ($_REQUEST["writeFile"] == "true")) {
                $writeFile = true;
                $relationalPath = "../..";
                $show_header = false;
            } else {
                $writeFile = false;
                $relationalPath = "..";
            }

            if ((isset($_REQUEST["writeCSV"]) == true) && ($_REQUEST["writeCSV"] == "true")) {
                ob_clean(); 
                $writeCSV = true;
                $relationalPath = "../..";
            } else {
                $writeCSV = false;
                $relationalPath = "..";
            }

            if ((isset($_REQUEST["writeDoc"]) == true) && ($_REQUEST["writeDoc"] == "true")) {
                $writeDoc = true;
                $relationalPath = "../..";
            } else {
                $writeDoc = false;
                $relationalPath = "..";
            }
            
            $spName = '';

            if (isset($_REQUEST['exec'])) {
                $sql = $_REQUEST['exec'];
                $sql = stripslashes($sql);
                $spName = explode(' ', $sql);
                $spName = $spName[1];
            }

            if (isset($_GET['message_id'])) {
                $select_id = $_GET['message_id'];
                $url_or_desc = $_GET['url_or_desc'];
                $xml_user = "EXEC spa_message_board @flag='s', @user_login_id='" . $app_user_name . "', @message_id=" . $select_id . ", @returnOutput='y', @url_or_desc='".$url_or_desc."'"; 
                $recordsets = readXMLURL2($xml_user);
                $sql = $recordsets[0]['spa'];
            }

            $manual_enable_paging_status = false;
            $manual_enable_paging_sp = ['spa_get_import_process_status','spa_get_mtm_test_run_log','spa_run_whatif_scenario_report'];
            foreach ($manual_enable_paging_sp as $sp_name) {
                $sp_position = stripos($sql, $sp_name);
                if ($sp_position) {
                    $manual_enable_paging_status = true;
                    break;
                }
            }

            $req_enable_pagging =  $manual_enable_paging_status ? 'y' : (isset($_REQUEST["enable_paging"]) ? $_REQUEST["enable_paging"] : 'false');
            $sql = str_replace('"', "'", $sql);
            $sql = str_replace("'", "''", $sql);
            $decompose_sp = "EXEC spa_serialize_sp_execution '" . $sql. "'";
            $recordsets = readXMLURL2($decompose_sp);
            $sql = $recordsets[0]['result'];

            if ($sql == "") {
                if ($is_called_from_mobile) {
                    echo $xml_end_struc;
                }
                die();
            }

            $report_name = "";
            $no_sum_report_name = "";

            //read rounding value from url if available, otherwise set it to 4
            $round_no = (isset($_REQUEST["rnd"])) ? intval($_REQUEST["rnd"]) : 4;
            $html_str = "";
            $html_str1 = "";

            if ($is_called_from_mobile) {
                include_once '../components/file_path.php';
            }

            /* Added By Narendra Shrestha - To decentralize report */
            include 'report_classes/Report.php';

            function getClassName($sql) {
                $sqlExplodeArray = explode(' ', trim($sql));
                $spa = str_replace(array('spa_', '_paging', '_NoHyperLink'), '', trim($sqlExplodeArray[1]));
                return str_replace(' ', '', ucwords(str_replace('_', ' ', $spa)));
            }

            $className = getClassName($sql);
            $classFile = 'report_classes/' . $className . '.php';
            $newFormat = false;
            $reportInstance = null;

            if (file_exists($classFile)) {
                include($classFile);
                $newFormat = true;
                $reportInstance = new $className();
            }

            include "spa_html_header.php";

            include "../PHP_CLASS_EXTENSIONS/PS.Recordset.1.0.php";
        
            $recordset_object = new PSRecordSet(false);
            $recordset_object->connectToDatabase('', '', '');

            if (isset($_REQUEST['batch_report_param'])) {
                //TODO: repalce only when param comes in double quotes like this 'deal_id=''34'',as_of_date=2009-02-27'
                //$sql=str_replace("''","'",stripslashes( $_REQUEST['batch_report_param']));
                $sql = stripslashes($_REQUEST['batch_report_param']);
            }

            /* Customized Invoice Report */
            if (strpos($sql, "spa_create_rec_invoice_report") != false) {
                include "invoice.report.php";
                die();
            }

            /* Customized Invoice Report */
            if (strpos($sql, "spa_create_rec_confirm_report") != false) {
                include "confirmed.report.php";
                
                if ($writeCSV != true) {
                    die();
                }
            }

            if (strpos($sql, "spa_create_rec_compliance_report") != false) {
                include "compliance.report.php";
                die();
            }

            $show_logo = 'true';

            if (strpos($sql, "spa_create_rec_compliance_report_format2") != false) {
                include "compliance.report.co.php";
                $show_header = 'false';
            }

            if (strpos($sql, "spa_create_rec_compliance_report_format3") != false) {
                include "compliance.report.co.php";
                $show_header = 'false';
            }

            $report_name1 = '';

            if (strpos($sql, "spa_trader_Position_Report") != false) {
                $show_logo = 'true';
                $report_name1 = "spa_trader_Position_Report";
            }

            if (strpos($sql, "spa_Create_MTM_Period_Report") != false) {
                $show_logo = 'true';
            }

            /* Customized Trade Ticket Report */
            if (strpos($sql, "spa_trade_ticket_report") != false) {
                $template_dir = 'report_template/';
                include $template_dir . "trade_ticket_report.php";
                die();
            }

            /* Customized Deal Confirmation Letter */
            if (strpos($sql, "spa_deal_confirm_report") != false || strpos($sql, "spa_confirm_report") != false) {
                $template_dir = 'report_template/';
                include $template_dir . "deal_template.php";
                die();
            }

            /* Customized Auto Matching of Hedge Report */
            if (strpos($sql, "spa_auto_matching_report") !== false) {
                $report_display = urldecode($_REQUEST['report_display']);
                
                if ($report_display == 'g') {
                    include '../../adiha.html.forms/_accounting/derivative/transaction_processing/auto_matching_hedge/auto.matching.hedge.report.data.php';
                    die();
                }
            }
    
            if ($show_header == 'true' && !isset($_POST['call_from'])) {
                $spa_html_header = get_header($sql, "100%", $app_php_script_loc, $recordset_object->getConnection(), $arrayR, $_REQUEST, $show_logo, $reportInstance);
            } else {
                $spa_html_header = "";
                $arrayR = array();
                $arrayR = decode_param($sql);
            }

            $arr_list = array();
            $arr_list = decode_param($sql);
            $existing_param = '';


            /* Paging Started */
            $url_args = $_SERVER['QUERY_STRING'];

            if (isset($_REQUEST['page_no'])) {
                $sel_page = $_REQUEST['page_no'];
                $total_row_return = $_REQUEST['__total_row_return__'];
                $call_from_paging = true;

                $sql = "EXEC $arr_list[1]";
                $cnt = count($arr_list);

                //replace last page_no parameter with new page no.
                if ($cnt > 1) {
                    $existing_param = $arr_list[2];
                }

                for ($i = 3; $i < $cnt - 1; $i++) {
                    $existing_param .= "," . $arr_list[$i];
                }

                $existing_param .= ", @page_no = " . $sel_page;

                $sql = $sql . " " . $existing_param;
                
            } else {
                $sel_page = 1;
                $call_from_paging = false;
            }

            $paging_enabled = isset($req_enable_pagging) ? 'y' : 'n';
            $paging_enabled = $manual_enable_paging_status ? 'y' : $paging_enabled;
    
            if (isset($req_enable_pagging)
                && (($req_enable_pagging) == 'false' ? false : true == true)
                && ($call_from_paging == false)
                && ($writeFile == false)
                && ($writeCSV == false)
            ) {

                $enable_paging = true;
                $arr_list = array();
                $arr_list = decode_param($sql);

                $new_paging = (isset($_REQUEST["np"]) ? ($_REQUEST["np"] == 1 ? true : false) : false);
                
                $new_paging = $manual_enable_paging_status ? true : $new_paging;

                //don't append _paging in sp name if it is paging done with new method
                $sql = 'EXEC ' . $arr_list[1] . ($new_paging ? '' : '_paging');
                
                
                $existing_param = '';
                $cnt = count($arr_list);
                if ($cnt > 1)
                    $existing_param = $arr_list[2];
                for ($i = 3; $i < $cnt; $i++)
                    $existing_param .= "," . $arr_list[$i];

                //in case of new paging, 3 new params (batch_process_id, batch_report_param & enable_paging) have to be passed as well) for the first call.
                $paging_param = ($new_paging ? ', @batch_process_id = NULL, @batch_report_param = NULL, @enable_paging = 1' : '');

                $sql .= " " . $existing_param;
                $paging_sql = $sql . $paging_param;
                
                //Exec Sql to get TOTAL Row and Process ID
                
                $recordset_object->runSQLStmt($paging_sql, $session_id);
                $result = array();
                $result = $recordset_object->recordsets();

                $total_row_return = $result[0];
                $process_id = $result[1];

                //put batch_process_id in the $new_paging_params
                $paging_param = ($new_paging ? '", @batch_report_param = NULL, @enable_paging = 1' : '');
                $paging_param = '@batch_process_id = "' . $process_id . $paging_param . ', @page_size =100, @page_no = 1' ;
                
                if ($is_called_from_mobile) {
                    $paging_param = str_replace('"', '"', $paging_param); 
                }

                $add_param = (strlen($existing_param) == 0 ? ' ' : ' ,') . $paging_param;
                $sql = $sql . $add_param;

                $url_args = $url_args . "&__total_row_return__=$total_row_return";
            } else {
                $enable_paging = false;
            }

            $spa_html_paging = "";
            if (($enable_paging == true) || ($call_from_paging == true)) {
                $spa_html_paging = get_paging($total_row_return, $max_row_for_html, $sel_page, $url_args, $sql);
            }
            /* Paging Ended */
            

            $recordset_object->runSQLStmt($sql, $session_id);

            $fields = $recordset_object->clms;


            /* Code for total */
            $clm_total = array();
            $clm_total_format = array();
            $clm_sub_total = array();
            $clm_tot_col_span = 0;
            $clm_sub_col_span = 0;
            $report_total_clm_start = 0;
            $sub_total_clm = -1;
            $temp_index = '';

            if ($newFormat) {
                $reportDefination = $reportInstance->getReportDefinition($fields, $arrayR, $temp_index);
                $report_name = $reportInstance->getReportSPName();
                $clm_total = array_key_exists('clm_total', $reportDefination) ? $reportDefination['clm_total'] : array();
                $clm_total_format = array_key_exists('clm_total_format', $reportDefination) ? $reportDefination['clm_total_format'] : array();
                $report_total_clm_start = array_key_exists('report_total_clm_start', $reportDefination) ? $reportDefination['report_total_clm_start'] : -1;
                $clm_sub_total = array_key_exists('clm_sub_total', $reportDefination) ? $reportDefination['clm_sub_total'] : array();
                $sub_total_clm = array_key_exists('sub_total_clm', $reportDefination) ? $reportDefination['sub_total_clm'] : -1;
                $clm_sub_col_span = array_key_exists('clm_sub_col_span', $reportDefination) ? $reportDefination['clm_sub_col_span'] : 0;
                $clm_tot_col_span = array_key_exists('clm_tot_col_span', $reportDefination) ? $reportDefination['clm_tot_col_span'] : 0;
            } else {
                if (strpos(strtoupper($sql), strtoupper("spa_create_hedges_pnl_deferral_report")) != false) {
                    $report_name = "spa_create_hedges_pnl_deferral_report";

                    if ($fields == 3) {
                        $clm_total = array("Total", "", "", "");
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 4) {
                        $clm_total = array("Total", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 6 && $arrayR[9] == "'d'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = 1;
                    } else if ($fields == 5 && $arrayR[9] == "'s'") {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } else if ($fields == 10 && $arrayR[9] == "'t'") {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = 4;
                    } else if ($fields == 6) {
                        $clm_total = array("Total", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 10) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", 0.00, 0.00);
                        $sub_total_clm = 5;
                    }
                } else if (strpos($sql, "spa_get_market_variance_report") != false or strpos($sql, "spa_get_market_variance_report") != false) {
                    $report_name = "spa_get_market_variance_report";

                    //summary cash-flow
                    if ($fields == 1) {
                        $clm_total = array("Total", "N");
                        $clm_total_format = array("N", "N");
                        $clm_sub_total = array("");
                        $report_total_clm_start = -1;
                        $sub_total_clm = -1;
                    }

                    if ($fields == 12) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "$.2", "$.2", "$.4", "$.4", "$.4", "$.4", "$.2", "$.2", "$.2", "N");
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $report_total_clm_start = 1;
                        $sub_total_clm = 2;
                    }

                    if ($fields == 14) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.2", "$.2", "$.4", "$.4", "$.4", "$.4", "$.2", "$.2", "$.2", "N");
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $report_total_clm_start = 1;
                        $sub_total_clm = 2;
                    }

                    if ($fields == 15) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.2", "$.2", "$.4", "$.4", "$.4", "$.4", "$.2", "$.2", "$.2", "N");
                        $clm_sub_total = array("", "", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $report_total_clm_start = 1;
                        $sub_total_clm = 3;
                    }

                    if ($fields == 35) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.4", "$.4", "$.2", "$.2", "$.2", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.4", "$.4", "$.2", "$.2", "$.2", "N", "$.2", "$.2", "$.2", "N");
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $report_total_clm_start = 1;
                        $sub_total_clm = 2;
                    }

                    if ($fields == 36) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.4", "$.4", "$.2", "$.2", "$.2", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.4", "$.4", "$.2", "$.2", "$.2", "N", "$.2", "$.2", "$.2", "N");
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $report_total_clm_start = 1;
                        $sub_total_clm = 1;
                    }

                    if ($fields == 37) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.4", "$.4", "$.2", "$.2", "$.2", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.4", "$.4", "$.2", "$.2", "$.2", "N", "$.2", "$.2", "$.2", "N");
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $report_total_clm_start = 1;
                        $sub_total_clm = 2;
                    }
                } elseif (strpos($sql, "spa_Create_MTM_Journal_Entry_Report_Reverse") != false) {
                    $report_name = "Journal Entry Report";

                    if (count($arrayR) > 11) {
                        $round_no = $arrayR[14];
                    } else {
                        $round_no = "0";
                    }

                    if ($fields == 4) {
                        $clm_total = array("Total", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));// From FASTracker
                        $clm_sub_total = array("Sub-total", "esc_td", 0.00, 0.00);
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));// From FASTracker
                        $clm_sub_total = array("<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $sub_total_clm = 2;
                    } elseif ($fields == 9) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("$", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no));
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", 0.00);
                        $report_total_clm_start = 2;
                        $clm_tot_col_span = 1;
                        $sub_total_clm = -1;
                    } elseif ($fields == 13) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));// FASTracker
                        $clm_sub_total = array("Sub-total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
                        $report_total_clm_start = 10;
                        $clm_tot_col_span = -1;
                        $sub_total_clm = -1;
                    } elseif ($fields == 14) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $clm_sub_total = array("Sub-total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
                        $report_total_clm_start = 10;
                        $clm_tot_col_span = -1;
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Create_Hedges_Measurement_Report") != false or strpos($sql, "spa_create_hedges_measurement_report_paging") != false) {
                    $report_name = "spa_Create_Hedges_Measurement_Report";

                    if (count($arrayR) > 11) {
                        $round_no = $arrayR[11];
                    } else {
                        $round_no = "0";
                    }

                    //summary MTM
                    if ($fields == 15) { //summary cash-flow
                        $clm_total = array("Total", "esc_td", "esc_td",  "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 3;
                        $clm_tot_col_span = 4;
                        $sub_total_clm = -1;
                    } elseif ($fields == 20) { //detail cash-flow
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 7;
                        $clm_sub_total = array("", "", "<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        
                        if ($arrayR[9] == "'l'") {
                            $sub_total_clm = 2;
                            $report_name = "spa_Create_Hedges_Measurement_Report_NoHyperLink";
                        } else {
                            $sub_total_clm = 4;
                        }

                        $clm_sub_col_span = 1;
                        $clm_tot_col_span = 8;
                    } elseif ($fields == 16) { //summary fair-value
                        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 2;
                        $clm_tot_col_span = 3;
                    } elseif ($fields == 17) { //summary fair-value
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start =3;
                        $clm_tot_col_span =4;       
                    } elseif ($fields == 21) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 7;
                        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_sub_col_span = 5;
                        $sub_total_clm = -1;
                        $clm_tot_col_span = 8;
                    } elseif ($fields == 22) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "", "","", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start =8;
                        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_sub_col_span=6;
                        $sub_total_clm = -1;
                        $clm_tot_col_span =9;       
                    } elseif ($fields == 37) {
                        $clm_total              = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "", "", "", "", "", "", "", 0.00, 0.00, 0.00,0.00,0.00, "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format       = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no),"N","N","N","N","N","N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "N", "N","N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $clm_sub_total          = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00,"","","","","","","",0.00,"",0.00,0.00,0.00,"","","","",0.00,0.00,0.00, 0.00);
                        $report_total_clm_start = 5;
                        $clm_sub_col_span       = 0;
                        $sub_total_clm          = 9;
                        $clm_tot_col_span       = 0;
                    }
                } elseif (strpos($sql, "spa_create_storage_position_report") != false) {
                    $report_name = "spa_create_storage_position_report ";
                    
                    if ($fields == 7) {
                        $clm_total = array("Total", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 11) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", ""); 
                        $clm_total_format = array("N", "N", "N", "$", "$", "$", "$", "N", "$", "$", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    }
                } elseif (strpos($sql, "spa_storage_position_report") != false) {
                    $report_name = "spa_storage_position_report ";
                    
                    if ($fields == 11) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", ""); 
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } else if (strpos($sql, "spa_storage_position_report_sw") != false) {
                    if ($fields == 15) {
                        $report_name = "spa_storage_position_report_sw";
                        $clm_total = array("Total", "", "", "", "", "", "", "", "$.2", "$.2", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = '';//array("Sub-total", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
				} else if (strpos($sql, "spa_flow_optimization_hourly") != false) { //position report for flow optimization hourly grid
					$report_name = 'spa_flow_optimization_hourly';
					if ($fields == 33) { 
						$clm_total = array("Total", "", "", "", "", "", "", ""
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
							);
						$clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N"
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
								, "$." . str_replace("'", "", $round_no)
						);
						$report_total_clm_start = 1;
						$clm_sub_total = "";
						$sub_total_clm = -1;
						
					}
                } else if (strpos($sql, "spa_flow_optimization") != false) { //position report for flow optimization grid
                    $report_name = 'spa_flow_optimization';
                    if ($fields == 13) { 
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        //$clm_sub_total = array("Sub-total", "", "", "", "", "", "", "", "", "", "", "", "", "", "$." . str_replace("'", "", $round_no), "");
                        //$sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Create_AOCI_Report") != false || strpos($sql, "spa_create_aoci_report_paging") != false) {
                    $report_name = "spa_Create_AOCI_Report";

                    if (count($arrayR) > 9) {
                        $round_no = $arrayR[9];
                    } else {
                        $round_no = "0";
                    }

                    if ($fields == 3) { //summary
                        $clm_total = array("Total", "", 0.00);
                        $clm_total_format = array("", "", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00);
                        $sub_total_clm = 0;
                        $clm_sub_col_span = 0;
                        $clm_tot_col_span = 0;
                    } elseif ($fields == 4 && $arrayR[8] == "'t'") { //another summary
                        $clm_total = array("Total", "", "", 0.00);
                        $clm_total_format = array("", "", "", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 2;
                        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00);
                        $sub_total_clm = 1;
                        $clm_sub_col_span = 0;
                        $clm_tot_col_span = 0;
                    } elseif ($fields == 4 && $arrayR[8] != "'t'") { //another summary
                        $clm_total = array("Total", "", "", 0.00);
                        $clm_total_format = array("", "", "", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 2;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", 0.00);
                        $sub_total_clm = 0;
                        $clm_sub_col_span = 0;
                        $clm_tot_col_span = 0;
                    } elseif ($fields == 13) { //Detail
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("Total", "", "", "", "", "", "", "", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", 0.00, 0.00);
                        $report_total_clm_start = 10;
                        $sub_total_clm = 2;
                    }
                } elseif (strpos($sql, "spa_drill_down_msmt_report") != false) {
                    if ($fields == 26 && $arrayR[2] == "'link'") {
                        $report_name = "spa_drill_down_msmt_report";
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "", "");
                        $clm_total_format = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "N", "N", "$", "$", "$", "$", "$", "$", "$", "$", "N", "N");
                        $report_total_clm_start = 15;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "", "");
                        $sub_total_clm = 0;
                        $clm_sub_col_span = 0;
                        $clm_tot_col_span = 0;
                    } elseif ($fields == 39 && $arrayR[2] == "'link'") {
                        $report_name = "spa_drill_down_msmt_report";
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "0.00", "", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "$.2", "$.2", "$.2", "$.2", "$.2", "", "", "", "$.2", "$.2", "$.2", "$.2");
                        $clm_total_format = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "$.", "N", "N", "N", "N", "$.2", "$.2", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "$.2", "$.2", "$.2", "$.2");
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "$.", "", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "$.2", "$.2", "$.2", "$.2", "$.2", "", "", "", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 15;
                        $sub_total_clm = 4;
                        $clm_sub_col_span = 0;
                        $clm_tot_col_span = 0;
                    } elseif ($fields == 9 && strtolower($arrayR[2]) == "'aoci'") {
                        $report_name = "spa_drill_down_msmt_report";
                        $clm_total = array("", "", "", "", "Total", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 5;
                        // $clm_tot_col_span = 2;
                    } elseif ($fields == 11 && strtolower($arrayR[2]) == "'pnl'") {
                        $report_name = "spa_drill_down_msmt_report";
                        $clm_total = array("", "", "", "", "Total", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 5;
                        $clm_tot_col_span = 2;
                    } elseif ($fields == 12 && strtolower($arrayR[2]) == "'pnl'") {
                        $report_name = "spa_drill_down_msmt_report";
                        $clm_total = array("", "", "", "", "Total", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 5;
                        $clm_tot_col_span = 2;
                    }
                } elseif (strpos($sql, "spa_create_detailed_aoci_schedule") != false || strpos($sql, "spa_create_detailed_aoci_schedule_paging") != false) {
                    if ($fields == 13) {
                        $report_name = "spa_create_detailed_aoci_schedule";
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("Total", "", "", "", "", "", "", "", "", "", "", "$.2", "$.2");
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", 0.00, 0.00);
                        $report_total_clm_start = 10;
                        $sub_total_clm = 2;
                        // $clm_tot_col_span = 2;
                    }
                } elseif (strpos($sql, "spa_Create_Hedge_Item_Matching_Report") != false) {
                    if ($fields == 7) {
                        $report_name = "spa_Create_Hedge_Item_Matching_Report";
                        $clm_total = array("", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("Total", "N", "N", "$", "$", "$", "N");
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, "N");
                        $report_total_clm_start = 2;
                        $sub_total_clm = 0;
                        // $clm_tot_col_span = 2;
                    }

                    if ($fields == 8 && $arrayR[7] == "m") {
                        $report_name = "spa_Create_Hedge_Item_Matching_Report";
                        $clm_total = array("", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("Total", "", "", "N", "N", "N", "N", "$");
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00);
                        $report_total_clm_start = 2;
                        $sub_total_clm = 2;
                        // $clm_tot_col_span = 2;
                    }
                }

                /* Start - FRORMAT Data for Emmission Input Limit/Violation Report */
                else if (strpos($sql, "spa_get_emmission_input_report") != false) {
                    $report_name = "spa_get_emmission_input_report";
        
                    if ($arrayR[2] == "'h'") {
                        $clm_total = array("Total", "");
                        $clm_total_format = array("N");
                        $clm_sub_total = array("");

                        for ($x = 0; $x < $fields - 1; $x++) {
                            array_push($clm_total, "");
                            array_push($clm_total_format, "");
                            array_push($clm_sub_total, "");
                        }

                        $report_total_clm_start = 0;
                        $sub_total_clm = -1;
                    } else {
                        if ($fields == 12) {
                            $clm_total = array("", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "N", "N");
                            $clm_sub_total = array("", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, "", "");
                            $report_total_clm_start = -1;
                            $sub_total_clm = -1;
                        }
                    }
                }
                /* END - Format Data for Emmission Input Limit/Violation Report */

                else if (strpos($sql, "spa_sourcedealheader_reconcile_cash") != false) {
                    if ($fields == 7) {
                        $report_name = "spa_sourcedealheader_reconcile_cash";
                        $clm_total = array("", "", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("Total", "N", "N", "N", "$.2", "$.2", "$.2");
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "N", 0.00, 0.00, 0.00);
                        $report_total_clm_start = 3;
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 12) {
                        $report_name = "spa_sourcedealheader_reconcile_cash";
                        $clm_total = array("", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("Total", "", "", "", "", "", "", "", "$.2", "$.2", "$.2", "N");
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $report_total_clm_start = 7;
                        $sub_total_clm = 1;
                    }
                } elseif (strpos($sql, "spa_calc_explain_position") != false) {
                    $report_name = "spa_calc_explain_position";
        
                    if ($fields == 13) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("", "", "", "", "", "", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 5;
                    }

                    if ($fields == 14) {
                        if ($arrayR[13] == 'p') {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "");
                            $clm_total_format = array("", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "N");
                            $report_total_clm_start = 4;
                        } else {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "");
                            $clm_total_format = array("", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "N");
                            $report_total_clm_start = 4;
                        }
                    }

                    if ($fields == 15) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("", "", "", "", "", '', "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 5;
                    }

                    if ($fields == 16) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "esc_td");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                    }

                    if ($fields == 17) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "esc_td");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                    }
                } elseif (strpos($sql, "spa_create_fx_exposure_report") != false) {
                    $report_name = "spa_create_fx_exposure_report";
        
                    if ($fields == 4) {
                        $clm_total = array("Total", "esc_td", 0.00, "esc_td");
                        $clm_total_format = array("N", "N", "$.X", "N");
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 5) {
                        $clm_total = array("Total", "esc_td", "esc_td", 0.00, "esc_td");
                        $clm_total_format = array("N", "N", "N", "$.X", "N");
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, "");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 6) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", 0.00, "esc_td");
                        $clm_total_format = array("N", "N", "N", "N", "$.X", "N");
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, "");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 7) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, "esc_td");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.X", "N");
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, "");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 17) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, "esc_td", "esc_td", 0.00, 0.00, 0.00, "esc_td");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "N", "N", "N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $sub_total_clm = -1;
                    }
                } elseif ($fields != 2 && strpos($sql, "spa_get_db_measurement_trend") != false) {
                    $report_name = "spa_get_db_measurement_trend";

                    //summary cash-flow
                    if ($fields == 12) {
                        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 2;
                        $clm_tot_col_span = 3;
                    }
                    //detail cash-flow
                    elseif ($fields == 21) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 7;
                        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 3;
                        $clm_sub_col_span = 5;
                        $clm_tot_col_span = 8;
                    }
                    //summary fair-value
                    elseif ($fields == 15) {
                        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 2;
                        $clm_tot_col_span = 3;
                    } elseif ($fields == 20) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 7;
                        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_sub_col_span = 5;
                        $sub_total_clm = 3;
                        $clm_tot_col_span = 8;
                    }
                    
                    if ($fields == 9) {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("$", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    }
                    
                    if ($fields == 3) {
                        $clm_total = array("Total", 0.00, 0.00);
                        $clm_total_format = array("$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    }
                    
                    if ($fields == 4) {
                        $clm_total = array("Total", 0.00, 0.00, 0.00);
                        $clm_total_format = array("$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    }
                    
                    if ($fields == 5) {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    }
                    
                    if ($fields == 6) {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    }
                    
                    if ($fields == 7) {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    }
                    
                    if ($fields == 8) {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    }
                    
                    if ($fields == 10) {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    }
                } elseif (strpos($sql, "spa_Create_MTM_Measurement_Report") != false or strpos($sql, "spa_create_mtm_measurement_report_paging") != false) {
                    $report_name = "spa_Create_MTM_Measurement_Report";
        
                    if (count($arrayR) > 11) {
                        $round_no = $arrayR[11];
                    } else {
                        $round_no = "0";
                    }

                    if ($fields == 12) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        //   $clm_total_format = array("", "", "", "$", "$", "$", "$", "$", "$", "$", "$");
                        $clm_total_format = array("", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 3;
                        $clm_tot_col_span = 4;
                        $sub_total_clm = 1;
                    } elseif ($fields == 15) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 6;
                        $clm_sub_total = array("", "", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.0, 0.000);
                        $sub_total_clm = 3;
                        $clm_sub_col_span = 3;
                        $clm_tot_col_span = 7;
                    } elseif ($fields == 36) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "N", "N", "N", "N", "N", "N", "$.", "$.", "$.", "$.", "$." . str_replace("'", "", $round_no), "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 5;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $clm_sub_col_span = 0;
                        $sub_total_clm = 4;
                        $clm_tot_col_span = 0;
	                  } elseif ($fields == 37) {
	                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "","", 0.00, 0.00, 0.00, 0.00);
	                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "N", "N", "N", "N", "N", "N", "$.", "$.", "$.", "$.", "$." . str_replace("'", "", $round_no), "N", "N", "N", "N","$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
	                        $report_total_clm_start = 5;
	                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "","", 0.00, 0.00, 0.00, 0.00);
	                        $clm_sub_col_span = 0;
	                        $sub_total_clm = 4;
	                        $clm_tot_col_span = 0;
	                    }
                } elseif (strpos($sql, "spa_Create_MTM_Journal_Entry_Report") != false) {
                    if (count($arrayR) > 14) {
                        $round_no = $arrayR[14];
                    } else {
                        $round_no = "0";
                    }

                    $report_name = "spa_Create_MTM_Journal_Entry_Report";
        
                    if ($fields == 4) {
                        $clm_total = array("Total", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 2;
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 4;
                        $clm_sub_total = array("", "", "<i>Sub-total</i>", "esc_td", "esc_td", 0.00, 0.00);
                        $sub_total_clm = 2;
                        $clm_sub_col_span = 3;
                        $clm_tot_col_span = 5;
                    }
                } elseif (strpos($sql, "spa_Create_Inventory_Journal_Entry_Report") != false || strpos($sql, "spa_create_inventory_journal_entry_report_paging") != false) {
                    $report_name = "spa_Create_Inventory_Journal_Entry_Report";
                
                    if ($fields == 4) {
                        $clm_total = array("Total", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("", "", "$", "$");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 2;
                    } elseif ($fields == 5 && $arrayR[8] == "'j'") {
                        $clm_total = array("Total", "", "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 5 && $arrayR[8] == "'t'") {
                        $clm_total = array(0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$", "$", "$", "$");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array(0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 6 && $arrayR[8] == "'j'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 6 && $arrayR[8] == "'t'") {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 8 && $arrayR[7] == "'t'") {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.2", "N", "$.2", "N", "$.2", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0, 00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 8) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("Total", "N", "N", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0, 00, 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 7 && $arrayR[8] == "'j'") {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 7 && $arrayR[8] == "'t'") {
                        $clm_total = array("N", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 14) {
                        //  echo $sql;
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("Total", "N", "", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, 0, 00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 30 && $arrayR[8] == "'j'") {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, "", "", "", "", "");
                        $clm_total_format = array("Total", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        //     $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, 0,00, 0.00, 0.00, 0.00, 0.00);
                        //  $sub_total_clm = 0;
                    } elseif ($fields == 10 && $arrayR[7] == "'g'") {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

                        if (count($arrayR) == 17)
                            $clm_total_format = array("N", "N", "$.2", "N", "N", "N", "X", "N", "N", "N");
                        else
                            $clm_total_format = array("N", "N", "$.2", "N", "N", "N", "N", "N", "N", "N");

                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 11 && $arrayR[7] == "'g'") {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        
                        if (count($arrayR) == 17)
                            $clm_total_format = array("N", "N", "$.2", "$.2", "N", "N", "N", "X", "N", "N", "N");
                        else
                            $clm_total_format = array("N", "N", "$.2", "$.2", "N", "N", "N", "N", "N", "N", "N");

                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 12 && $arrayR[7] == "'g'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        
                        if (count($arrayR) == 17)
                            $clm_total_format = array("N", "N", "N", "$.2", "$.2", "N", "N", "N", "X", "N", "N", "N");
                        else
                            $clm_total_format = array("N", "N", "N", "$.2", "$.2", "N", "N", "N", "N", "N", "N", "N");

                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Netted_Journal_Entry_Report") != false or strpos($sql, "spa_Netted_Journal_Entry_Report_Reverse") != false) {
                    if (count($arrayR) > 9) {
                        $round_no = $arrayR[9];
                    } else {
                        $round_no = "0";
                    }

                    $report_name = "spa_Netted_Journal_Entry_Report";
        
                    if ($fields == 5) {
                        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 2;
                        $clm_tot_col_span = 3;
                    } elseif ($fields == 6) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 3;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "esc_td", "esc_td", 0.00, 0.00);
                        $sub_total_clm = 1;
                        $clm_sub_col_span = 3;
                        $clm_tot_col_span = 4;
                    } elseif ($fields == 9) { //CSV Export format 1
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, "", "", "");
                        $clm_total_format = array("", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "N", "N");
                        $report_total_clm_start = 2;
                        $clm_sub_total = array("", "", "", 0.00, 0.00, 0.00, "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 37) { //CSV Export format 2
                        $report_name = "";
                        $report_total_clm_start = -1;
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Create_Dedesignation_Values_Report") != false || strpos($sql, "spa_create_dedesignation_values_report_paging") != false) {
                    $report_name = "spa_Create_Dedesignation_Values_Report";

                    if (count($arrayR) > 10) {
                        $round_no = $arrayR[10];
                    } else {
                        $round_no = "0";
                    }

                    if ($fields == 7) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 3;
                        $clm_tot_col_span = 4;
                    } elseif ($fields == 10) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 6;
                        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = 2;
                    }
                } elseif (strpos($sql, "spa_Create_Available_Hedge_Capacity_Exception_Report") != false) {
                    $report_name = "spa_Create_Available_Hedge_Capacity_Exception_Report";
                    $round_no = str_replace("'", '', $arrayR[15]);

                    if ($fields == 11) {
                        $clm_total = array("<B>Total</B>", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, "esc_td");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$", "$", "$", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub Total</i>", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 3;
                        $clm_sub_col_span = 3;
                        $clm_tot_col_span = 0;
                    } elseif ($fields == 13) {
                        if ($arrayR[7] == "'d'") {
                            $clm_total = array("<B>Total</B>", "", "", "", "", "", "", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "$.$round_no", "$.$round_no", "N", "N", "N", "N", "$.$round_no", "N");
                            $report_total_clm_start = 1;
                            $clm_sub_total = array("<i>Sub Total</i>", "", "", "", "", "", "", "esc_td", "esc_td", "esc_td", 0.00, "");
                            $sub_total_clm = 3;
                            $clm_sub_col_span = 2;
                            $clm_tot_col_span = 0;    
                        } else {
                            $clm_total = array("<B>Total</B>", "", "", "", "", "", "", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "$", "$", "$", "N");
                            $report_total_clm_start = 1;
                            $clm_sub_total = array("<i>Sub Total</i>", "", "", "", "", "", "", "esc_td", 0.00, 0.00, 0.00, "");
                            $sub_total_clm = 3;
                            $clm_sub_col_span = 2;
                            $clm_tot_col_span = 1;  
                        }

                    } else if ($fields == 10) {
                        $clm_total = array("<B>Total</B>", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00);
                        $clm_total_format = array("", "N", "N", "N", "N", "N", "N", "$.$round_no", "$.$round_no", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "","esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00);
                        $sub_total_clm = 3;
                        $clm_sub_col_span = 4;
                        $clm_tot_col_span = 7;
                    } 
                } elseif (strpos($sql, "spa_hedge_capacity_report") != false) {
                    $report_name = "spa_hedge_capacity_report";
                    
                    if ($fields == 14) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = 7;
                        $clm_sub_total = array("", "", "", "", "", "", "", "<B><i>Sub-total</i></B>", '', '', 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 4;
                        $clm_sub_col_span = 7;
                        $clm_tot_col_span = 8;
                    } else if ($fields == 12) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "0.00", "0.00", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "<B><i>Sub-total</i></B>", '', '', 0.00, "");
                        $sub_total_clm = 0;
                        $clm_sub_col_span = 7;
                        $clm_tot_col_span = -1;   
                    }
                } elseif((strpos($sql,"spa_create_hedge_effectiveness_report") != false) || (strpos($sql,"spa_create_hedge_effectiveness_report_paging") != false)){
                    $report_name = "spa_create_hedge_effectiveness_report";
                    
                    if (count($arrayR) > 10) {
                        $round_no = $arrayR[11];
                    } else {
                        $round_no = "0";
                    }
    
                    if ($fields == 10) {
                        $clm_total          = array("Total", "", "", "", "", "", "", "",  "", "");
                        $clm_total_format   = array("", "", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 1;
                        $clm_sub_total      = array("", "",  "", "", "", "", "", "", "", "");
                        $clm_sub_col_span = -1;
                        $sub_total_clm = -1;    
                    } elseif ($fields == 13) {
                        $clm_total          = array("Total", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format   = array("", "", "", "", "","$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 4;
                        $clm_sub_total      = array("", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_sub_col_span = -1;
                        $sub_total_clm = -1;
                    }  else if($fields == 19) {        
                        $clm_total          = array("Total","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format   = array("", "", "", "", "", "", "", "", "", "", "","$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 10;
                        $clm_sub_total      = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_sub_col_span = -1;
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Get_All_Notes") != false) {
                    $no_sum_report_name = "spa_Get_All_Notes";
                } elseif (strpos($sql, "spa_Create_Cash_Flow_Report") != false) {
                    $report_name = "spa_Create_Cash_Flow_Report";
        
                    if ($fields == 3) {
                        $clm_total = array("Total", "", 0.00);
                        $clm_total_format = array("", "", "$");
                        $report_total_clm_start = 1;
                    } elseif ($fields == 4) {
                        $clm_total = array("Total", "", "", 0.00);
                        $clm_total_format = array("", "", "", "$");
                        $report_total_clm_start = 2;
                    }
                } elseif (strpos($sql, "spa_Create_Disclosure_Report") != false) {
                    if ($fields == 6) {
                        $report_name = "spa_Create_Disclosure_Report";
                        $clm_total = array("", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "");
                        $report_total_clm_start = -1;
                    }
                } elseif (strpos($sql, "spa_Create_Reconciliation_Report") != false) {
                    $round_no = str_replace("'", '', $arrayR[11]);
                    
                    if ($fields == 3) { //summary MTM
                        $report_name = "spa_Create_Reconciliation_Report";
                        $clm_total = array("", "", "");
                        $clm_total_format = array("N", "N", "");
                        $report_total_clm_start = -1;
                    }
                    
                    if ($fields == 7) { //summary cash-flow and fair value
                        $report_name = "spa_Create_Reconciliation_Report";
                        $clm_total = array("", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "", "", "", "", "");
                        $report_total_clm_start = -1;
                    }

                    if ($fields == 13) { //detail cash flow and fair value
                        $report_name = "spa_Create_Reconciliation_Report";
                        $clm_total = array("", "", "", "", "", "", "", "", "0.00", "0.00", "0.00", "0.00", "0.00");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.$round_no", "$.$round_no", "$.$round_no", "$.$round_no", "$.$round_no");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 6;
                    }
                    
                    if ($fields == 9) { //detail cash flow and fair value
                        $report_name = "spa_Create_Reconciliation_Report";
                        $clm_total = array("", "", "", "", "", "", "", "", "0.00");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.$round_no");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "<i>Sub-total</i>", 0.00);
                        $sub_total_clm = 6;
                    }
                    
                    if ($fields == 8) { //detail cash flow and fair value
                        $report_name = "spa_Create_Reconciliation_Report";
                        $clm_total = array("", "", "", "0.00", "0.00", "0.00", "0.00", "0.00");
                        $clm_total_format = array("N", "N", "N", "$.$round_no", "$.$round_no", "$.$round_no", "$.$round_no", "$.$round_no");
                        $report_total_clm_start = -1;
                    }      
                                    
                } elseif (strpos($sql, "spa_Create_NetAsset_Report") != false) {
                    $report_name = "spa_Create_NetAsset_Report";
                    
                    if ($fields == 1) { //summary MTM
                        $clm_total = array("", "");
                        $clm_total_format = array("", "");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("", "", "");
                    }

                    if ($fields == 2) { //summary MTM
                        $clm_total = array("", "");
                        $clm_total_format = array("", "X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "");
                    }

                    if ($fields == 3) { //summary MTM
                        $clm_total = array("", "", "");
                        $clm_total_format = array("", "", "");
                        $report_total_clm_start = 4;
                        $clm_sub_total = array("", "", "");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 4 && $arrayR[7] != "'b'") { //summary MTM
                        $clm_total = array("", "", "", "");
                        $clm_total_format = array("", "", "", "$");
                        $report_total_clm_start = 4;
                        $clm_sub_total = array("", "", "", "");
                        $sub_total_clm = 1;
                        $clm_sub_col_span = 0;
                        $clm_tot_col_span = 0;
                    }

                    if ($fields == 5 && $arrayR[7] != "'b'") { //summary MTM
                        $clm_total = array("", "", "", "", "");
                        $clm_total_format = array("", "", "", "", "$");
                        $report_total_clm_start = 5;
                        $clm_sub_total = array("", "", "", "", "");
                        $sub_total_clm = 2;
                        $clm_sub_col_span = 0;
                        $clm_tot_col_span = 0;
                    }

                    if ($fields == 7 && $arrayR[7] == "'b'") { //sumary MTM
                        $clm_total = array("Total", "", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 5;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00);
                    }

                    if ($fields == 8 && $arrayR[7] == "'b'") { //sumary MTM
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 0;
                        $sub_total_clm = -1;
                    }

                    if ($fields == 9 && $arrayR[7] == "'b'") { //sumary MTM
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", 0.00);
                        $sub_total_clm = 0;
                    }

                    if ($fields == 10 && $arrayR[7] == "'b'") { //sumary MTM
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 2;
                        $clm_sub_total = array("", "", "<i>Sub-total</i>", "", "", "", "", "", "", 0.00);
                        $sub_total_clm = 1;
                    }
                } elseif (strpos($sql, "spa_drill_down_jentries") != false) {
                    $report_name = "spa_drill_down_jentries";

                    if ($fields == 3) { //sumary MTM
                        $clm_total = array("Total", "", 0.00);
                        $clm_total_format = array("N", "N", "$");
                        $report_total_clm_start = 1;
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Create_Reclassification_Report ") != false) {
                    $report_name = "spa_Create_Reclassification_Report ";

                    //temp fix since the report should never return 2clms

                    if ($fields == 2) { //sumary MTM
                        $report_name = "";
                    }
                    
                    if ($fields == 4) { //sumary MTM
                        $clm_total = array("Total", 0.00, 0.00, "");
                        $clm_total_format = array("N", "$", "$", "N");
                        $report_total_clm_start = 0;
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 5) { //sumary MTM
                        $clm_total = array("Total", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "$", "$", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, "");
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 6) { //sumary MTM
                        $clm_total = array("Total", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$", "$", "N");
                        $report_total_clm_start = 2;
                        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }
                } elseif (strpos($sql, "spa_create_income_statement ") != false) {
                    $report_name = "spa_create_income_statement ";

                    if ($fields == 3) { //sumary MTM
                        $clm_total = array("Total", "", 0.00);
                        $clm_total_format = array("N", "N", "$");
                        $report_total_clm_start = 0;
                        $sub_total_clm = -1;
                    }

                    if ($fields == 4) { //sumary MTM
                        $clm_total = array("Total", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$");
                        $report_total_clm_start = 0;
                        $sub_total_clm = -1;
                    }

                    if ($fields == 5) { //sumary MTM
                        $clm_total = array("Total", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }
                    
                    if ($fields == 6) { //sumary MTM
                        $clm_total = array("Total", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$");
                        $report_total_clm_start = 2;
                        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00, 0.00, "");
                        $sub_total_clm = 2;
                    }
                } elseif (strpos($sql, "spa_journal_entry_posting_temp") != false) {
                    $report_name = "spa_journal_entry_posting_temp";
                    
                    if ($fields == 4) {
                        $clm_total = array("Total", "esc_td", 0.00, 0.00);
                        $clm_total_format = array("", "", "$", "$");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 2;
                    }
                } elseif (strpos($sql, "spa_journal_entry_posting") != false) {
                    $report_name = "spa_journal_entry_posting";
                    
                    if ($fields == 6) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("", "", "", "", "", "$");
                        $report_total_clm_start = 3;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00);
                        $sub_total_clm = 1;
                    }
                } elseif (strpos($sql, "spa_compare_msmt_values") != false) {
                    if ($fields == 11) {
                        $report_name = "spa_compare_msmt_values";
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("", "", "", "", "$", "$", "$", "$", "$", "$", "N");
                        $report_total_clm_start = 3;
                        $clm_tot_col_span = 0;
                    }
                } elseif (strpos($sql, "spa_REC_State_Allocation_Report") != false) {
                    $report_name = "spa_REC_State_Allocation_Report";
                    
                    if ($fields == 5) {
                        $clm_total = array("Total", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "X", "X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, "");
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 4) {
                        $clm_total = array("Total", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "X");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00);
                        $sub_total_clm = 0;
                    }
                }

                //start new added
                elseif (strpos($sql, "spa_run_ghg_goal_tracking_report") != false) {
                    $report_name = "spa_run_ghg_goal_tracking_report";
                    $round_no = str_replace("'", "", $arrayR[59]);

                    if ($arrayR[27] == "'5'") {
                        $format = "N";
                    } else {
                        $format = "$." . $round_no;
                    }

                    if (sizeof($arrayR) > 65) {
                        if ($arrayR[65] != 'NULL')
                            $format2 = "N";
                        else {
                            $format2 = "$." . $round_no;
                        }
                    } else
                    
                    $format2 = "$." . $round_no;

                    if ($fields == 3) { //summary
                        $clm_total = array("Total", "", 0.00, "");
                        $clm_total_format = array("N", "$." . $round_no, "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 4) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", $format, "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 5) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, "", "");
                        $clm_total_format = array("N", $format, "$." . $round_no, "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", $format, "N", $format2, "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", $format, "$." . $round_no, "N", $format2, "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 8) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $clm_total_format = array("N", $format, "$." . $round_no, "N", "$0.0", "$." . $round_no, "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 9) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                        $clm_total_format = array("N", $format, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 10) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                        $clm_total_format = array("N", $format, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 11) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                        $clm_total_format = array("N", $format, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                    }
                } elseif (strpos($sql, "spa_run_cashflow_earnings_report") != false) {
                    if (sizeof($arrayR) > 19){
                        $round_no = str_replace("'", "", $arrayR[20]);
                    } else {
                        $round_no = 0;
                    }   

                    $report_name = "spa_run_cashflow_earnings_report";
            
                    if ($fields == 5) { //summary{
                        $clm_total = array("Total", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$." . $round_no, "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 4) { //summary{
                        $clm_total = array("Total", "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$." . $round_no);
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 6) { //summary{
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . $round_no);
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) { //summary{
                        $clm_total = array("Total", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . $round_no);
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 8) { //summary{
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . $round_no, "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 9) { //summary{
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . $round_no, "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 11) { //summary{
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . $round_no);
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_run_emissions_whatif_report") != false) {
                    $report_name = "spa_run_emissions_whatif_report";
                    $round_no = str_replace("'", "", $arrayR[31]);

                    if ($fields == 7) { //summary{
                        $clm_total = array("Total", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 8) { //summary{
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 25) { //summary{
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . $round_no);
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00);
                        $sub_total_clm = -1;
                    }
                }
                //end new added

                elseif (strpos($sql, "spa_REC_Target_Report_Drill") != false || strpos($sql, "spa_rec_target_report_drill_paging") != false) {
                    $report_name = "spa_REC_Target_Report_Drill";
                    $round_no = $arrayR[21];
                    
                    if ($fields == 16) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "X", "X", "X", "N");
                        $report_total_clm_start = 4;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }
                    
                    if ($fields == 20) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "N");
                        $report_total_clm_start = 5;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = 3;
                    }
                } elseif (strpos($sql, "spa_REC_Target_Report") != false || strpos($sql, "spa_rec_target_report_paging") != false || strpos($sql, "spa_create_target_position_report") != false) {
                    $report_name = "spa_REC_Target_Report";
                    $round_no = $arrayR[24];

                    if ($arrayR[25] == "'y'" && $arrayR[7] != "'d'") {
                        $clm_total = array("Total", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        
                        if ($arrayR[36] == "'p'" || $arrayR[36] == "'c'" || $arrayR[36] == "'u'") {
                            $report_total_clm_start = -1;
                        }
                        
                        if ($arrayR[7] == "'s'") {
                            if ($arrayR[36] == "'p'") {
                                $sub_total_clm = 2;
                            } elseif ($arrayR[36] == "'t'") {
                                $sub_total_clm = 1;
                            } else {
                                $sub_total_clm = -1;
                            }
                        } else {
                            $sub_total_clm = 0;
                        }

                        for ($x = 2; $x < $fields - 1; $x++) {
                            array_push($clm_total, "0.00");
                            array_push($clm_total_format, "$." . str_replace("'", "", $round_no));
                            array_push($clm_sub_total, "0.00");
                        }
                    } else {
                        if ($fields == 10) {
                            $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                            $report_total_clm_start = 2;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("", "", "<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, "");
                            
                            if ($arrayR[7] == "'s'") {
                                $sub_total_clm = 1;
                            } else {
                                $sub_total_clm = 0;
                            }
                        }

                        if ($fields == 11) {
                            $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                            $report_total_clm_start = 2;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("", "", "<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, "");
                            
                            if ($arrayR[7] == "'s'") {
                                $sub_total_clm = 1;
                            } else {
                                $sub_total_clm = 0;
                            }
                        } elseif ($fields == 14) {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                            $report_total_clm_start = 4;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $sub_total_clm = 1;
                        } elseif ($fields == 15) {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                            $report_total_clm_start = 5;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $sub_total_clm = 3;
                        } elseif ($fields == 16) {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                            $report_total_clm_start = 5;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $sub_total_clm = 3;
                        } elseif ($fields == 18) {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                            $report_total_clm_start = 5;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $sub_total_clm = 3;
                        } elseif ($fields == 19) {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                            $report_total_clm_start = 5;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                            $sub_total_clm = 3;
                        } elseif ($fields == 20) {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "N");
                            $report_total_clm_start = 5;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "");
                            $sub_total_clm = 3;
                        }
                    }
                } elseif (strpos($sql, "spa_target_report") != false || strpos($sql, "spa_target_report_paging") != false || strpos($sql, "spa_create_target_position_report") != false) {
                    $report_name = "spa_target_report";
                    $round_no = $arrayR[24];
                    
                    if ($arrayR[25] == "'y'" && $arrayR[7] != "'d'") {
                        $clm_total = array("Total", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        
                        if ($arrayR[36] == "'p'" || $arrayR[36] == "'c'" || $arrayR[36] == "'u'") {
                            $report_total_clm_start = -1;
                        }
                        
                        if ($arrayR[7] == "'s'") {
                            if ($arrayR[36] == "'p'") {
                                $sub_total_clm = 2;
                            } elseif ($arrayR[36] == "'t'") {
                                $sub_total_clm = 1;
                            } else {
                                $sub_total_clm = -1;
                            }
                        } else {
                            $sub_total_clm = 0;
                        }

                        for ($x = 2; $x < $fields - 1; $x++) {
                            array_push($clm_total, "0.00");
                            array_push($clm_total_format, "$." . str_replace("'", "", $round_no));
                            array_push($clm_sub_total, "0.00");
                        }
                    } else {
                        if ($arrayR[2] == "'s'") {
                            if ($fields == 2) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 3) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$");
                                $report_total_clm_start = -1;
                            }		

                            if ($fields == 4) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 5) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 6) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$", "$", "$","$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 7) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$", "$", "$","$","$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 8) {
                                $clm_total_format = array("N", "N", "$", "$", "$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 9) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 10) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 11) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 12) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 13) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" ,"$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 14) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 15) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 16) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 17) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$" , "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 18) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$" , "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 19) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$" , "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 20) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }  
                        }
                    
                        if ($arrayR[2] == "'p'") {
                            if ($fields == 2) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 3) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N");
                                $report_total_clm_start = -1;
                            }	

                            if ($fields == 4) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "N");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 5) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "N", "N");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 6) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "N", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 7) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 8) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 9) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 10) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" ,"$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 11) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 12) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 13) {
                            var_dump('here');
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 14) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 15) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 16) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 17) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 18) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 19) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 20) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                        }
                    
                        if ($arrayR[2] == "'g'" OR $arrayR[2] == "'e'" OR $arrayR[2] == "'h'" OR $arrayR[2] == "'t'" ) {
                            if ($fields == 2) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 3) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 4) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 5) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 6) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "$", "$","$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 7) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "$", "$","$","$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 8) {
                                $clm_total_format = array("N", "N", "N", "$", "$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 9) {
                                $clm_total_format = array("N", "N", "N", "$", "$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 10) {
                                $clm_total_format = array("N", "N","N", "$", "$", "$", "$","$" ,"$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 11) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 12) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 13) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$","$" ,"$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 14) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 15) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 16) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 17) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$" ,"$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 18) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 19) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 20) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                        }
                    }
                } elseif (strpos($sql, "spa_create_lifecycle_of_recs") != false) {
                    // Copied from Emissions spa_html
                    $report_name = "spa_create_lifecycle_of_recs";
                    $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                    $clm_total_format = array("N", "N", "N", "N", "N", "$.2", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                    $report_total_clm_start = -1;
                    $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                    $sub_total_clm = -1;
                } elseif (strpos($sql, "spa_find_gis_recon_deals") != false) {
                    $report_name = "spa_find_gis_recon_deals";

                    if ($fields == 10) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 1;
                    }
                    
                    if ($fields == 6) {
                        $clm_total = array("", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 9) {
                        $clm_total = array("", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 1;
                    }
                    
                    if ($fields == 11) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 1;
                    }
                } elseif (strpos($sql, "spa_create_rec_settlement_report") != false) {
                    $report_name = "spa_create_rec_settlement_report";
                    
                    if ($fields == 2) {
                        $clm_total = array("Total", 0.00);
                        $clm_total_format = array("N", "$");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", 0.00);
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 6) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.5", "$.2");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "", "", "", "", 0.00);
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 9) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.2");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", 0.00);
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 11) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "N", "N", "N", "$.2");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", 0.00);
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 12) {
                        if ($arrayR[10] == "'n'") {
                            $clm_total = array("Total", "", "", "", "", "", 0.00, "", "", "", 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "N", "N", "N", "$.2", "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, "", "", "", 0.00, "");
                            $sub_total_clm = -1;
                        } else {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", 0.00);
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "N", "N", "N", "$.2");
                            $report_total_clm_start = 0;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", 0.00);
                            $sub_total_clm = 0;
                        }
                    }
                } elseif (strpos($sql, "spa_get_rec_activity_report") != false) {
                    $report_name = "spa_get_rec_activity_report";

                    if ( $arrayR[49] == 'default') {
                        $round_no = 2;
                    } else {
                        $round_no = $arrayR[49];
                    }

                    if ($fields == 5) { //summary
                        $clm_total = array("Total", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, "");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 6) { //summary
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 7 && $arrayR[8] != "'b'") { //summary
                        $clm_total = array("Total", "", "", "", 0.00, "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, "", 0.00, 0.00);
                        $sub_total_clm = 1;
                    }

                    if ($fields == 8 && $arrayR[8] == "'b'") { //Activity By Year
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N","$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00,"");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 8 && $arrayR[8] == "'s'" && $arrayR[44] != "'t'") { //summary
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 8 && $arrayR[8] == "'e'" ) { //expiration
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 7 && $arrayR[44] == "'t'" && $arrayR[8] == "'s'") { //summary
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 8 && $arrayR[44] == "'t'" && $arrayR[8] == "'v'") { //summary
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    } elseif ($fields == 8 && $arrayR[44] == "'t'" && $arrayR[8] != "'s'") { //summary
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 8 && $arrayR[8] == "'a'") { //summary
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 9 && $arrayR[8] == "'s'") { //summary
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 9 && $arrayR[8] == "'a'") { //summary
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 10 && $arrayR[8] == "'x'") { //Tier Type
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 9 && ($arrayR[8] == 'default' || $arrayR[8] == 'null' || $arrayR[8] == ' ')) { //No Report Group Type
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no),"$." . str_replace("'", "", $round_no),"N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 9 && $arrayR[8] == "'v'") { //obligation
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, "", 0.00);
                        $sub_total_clm = 1;
                    }

                    if ($fields == 10 && $arrayR[44] == "'t'" && $arrayR[8] == "'c'") { //counterparty and transactions
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, "", 0.00, 0.00);
                        $sub_total_clm = 1;
                    }

                    if ($fields == 9 && $arrayR[44] == "'t'" && ($arrayR[8] == "'g'" || $arrayR[8] == "'h'" || $arrayR[8] == "'y'")) { //generator and transactions
                        $clm_total = array("Total", "", "", "", "", 0.00, "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, "", 0.00, 0.00);
                        $sub_total_clm = 1;
                    }

                    if ($fields == 10 && $arrayR[44] != "'t'") { //counterparty
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, "", 0.00, 0.00);
                        $sub_total_clm = 1;
                    }

                    if ($fields == 10 && $arrayR[44] != "'t'" && $arrayR[8] == "'y'") { //counterparty
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, "", 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 10 && $arrayR[44] == "'t'") { //generator
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 10 && $arrayR[44] == "'t'" && $arrayR[8] == "'c'") { //generator

                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }
                    
                    if ($fields == 10 && $arrayR[44] != "'t'" && ($arrayR[8] == "'g'" || $arrayR[8] == "'h'")) { //generator
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 12 && $arrayR[44] == "'t'") { //generator group and transactions

                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 11 && $arrayR[44] != "'t'") { //generator group
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    }
                    
                    if ($fields == 13 && $arrayR[8] != "'a'") { //trader
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", 0.00);
                        $sub_total_clm = 0;
                    }

                    if ($fields == 14  && $arrayR[8] == "'p'") { //deal_detail options
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", 0.00);
                        $sub_total_clm = -1;
                    }

                    if ($fields == 21) { //detail
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_rec_invoice_report") != false) {
                    $report_name = "spa_create_rec_invoice_report";
                    
                    if ($fields == 12) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", 0.00, "");
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 10) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", 0.00, "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 6) {
                        $clm_total = array("Total", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.5", "$.2");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "", "", "", 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_rec_confirm_report") != false) {
                    $report_name = "spa_create_rec_confirm_report";
                    
                    if ($fields == 9) {
                        $clm_total = array("", "", "", "", "", "0.00", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 1;
                    }
                } elseif (strpos($sql, "spa_create_rec_compliance_report") != false) {
                    $report_name = "spa_create_rec_compliance_report";
                    
                    if ($fields == 9) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 10) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 12) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 18) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "X", "X", "X", "X");
                        $report_total_clm_start = 12;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 19) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "X", "X", "X", "X");
                        $report_total_clm_start = 12;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 11) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 0;
                    }
                } elseif (strpos($sql, "spa_run_wght_avg_inventory_cost_report") != false) {
                    $report_name = "spa_run_wght_avg_inventory_cost_report";

                    if ($fields == 5) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.4", ".4", "$.4");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }

                    if ($fields == 7) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.4", ".4", "$.4");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 8) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.4", ".4", "$.4");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 9) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.4", ".4", "$.4");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_rec_margin_report") != false) {
                    $report_name = "spa_create_rec_margin_report";
                    
                    if ($fields == 10) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.2", "N", "N", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 17) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N", "N", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", 0.00, "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_rec_compliance_exclusivegen_report") != false) {
                    $report_name = "spa_create_rec_compliance_exclusivegen_report";
                
                    if ($fields == 2) {
                        $clm_total = array("", "");
                        $clm_total_format = array("N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 9) {
                        $clm_total = array("", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_rec_compliance_requirement_report") != false) {
                    $report_name = "spa_create_rec_compliance_requirement_report";
                    $clm_total = array("", "", "", "");
                    $clm_total_format = array("N", "L", "N", "N");
                    $report_total_clm_start = -1;
                    $clm_sub_total = array("", "", "", "");
                    $sub_total_clm = -1;
                } elseif (strpos($sql, "spa_get_rec_assign_log") != false) {
                    $report_name = "spa_get_rec_assign_log";
                    $clm_total = array("", "", "", "", "", "", "");
                    $clm_total_format = array("N", "N", "N", "N", "N", "N", "N");
                    $report_total_clm_start = -1;
                    $clm_sub_total = array("", "", "", "", "", "", "");
                    $sub_total_clm = -1;
                } elseif (strpos($sql, "spa_credit_exposure_calculation_log") != false) {
                    $report_name = "spa_credit_exposure_calculation_log";
                    $clm_total = array("", "", "", "", "", "", "");
                    $clm_total_format = array("N", "N", "N", "N", "N", "N", "N");
                    $report_total_clm_start = -1;
                    $clm_sub_total = array("", "", "", "", "", "", "");
                    $sub_total_clm = -1;
                } elseif (strpos($sql, "spa_run_settlement_invoice_report") != false) {
                    $report_name = "spa_run_settlement_invoice_report";
                    $round = $arrayR[21];
                    $round_number = substr($round , 14 , 1);
                    if ($fields == 9) {
                        $clm_total = array("Total", "", "", "","");
                        $clm_total_format = array("N", "N", "N", "N", "N","N","N", "$." . str_replace("'", "", $round),"N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "","","");
                        $sub_total_clm = 2;
                    } else if ($fields == 13) {  
                        $clm_total = array("Total", "", "", "", "","","","", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N","N", "N","N","N","$." . str_replace("'", "", $round), "$." . str_replace("'", "", $round),"N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "","", "","", "","");
                        $sub_total_clm = 3;
                    } else if ($fields == 23) {
                        $clm_total = array("Total", "", "", "", "","","","","","","","","","","","","","","","","","","");
                        $clm_total_format = array("N", "N", "N", "N","N","N","N","N","N","N","N", "$." . str_replace("'", "", $round), "$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round),"N","N","$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round),"N","N","$." . str_replace("'", "", $round));
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "","", "","", "","","","","","","","","","","","","","","","","");
                        $sub_total_clm = 0;
                    } else if ($fields == 27) {
                        $clm_total = array("Total", "", "", "", "","","","","","","","","","","","","","","","","","","","", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N","N","$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round),"$." . str_replace("'", "", $round), "N", "N","$." . str_replace("'", "", $round), "N","$." . str_replace("'", "", $round), "N", "N", "$." . str_replace("'", "", $round));
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "","", "","", "","","","","","","","","","","","","","","","","");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_view_target_report") != false) {
                    $report_name = "spa_view_target_report";
                    $round_no = $arrayR[24];

                    if ($arrayR[25] == "'y'" && $arrayR[7] != "'d'") {
                        $clm_total = array("Total", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        
                        if ($arrayR[36] == "'p'" || $arrayR[36] == "'c'" || $arrayR[36] == "'u'") {
                            $report_total_clm_start = -1;
                        }
                        
                        if ($arrayR[7] == "'s'") {
                            if ($arrayR[36] == "'p'") {
                                $sub_total_clm = 2;
                            } elseif ($arrayR[36] == "'t'") {
                                $sub_total_clm = 1;
                            } else {
                                $sub_total_clm = -1;
                            }
                        } else {
                            $sub_total_clm = 0;
                        }

                        for ($x = 2; $x < $fields - 1; $x++) {
                            array_push($clm_total, "0.00");
                            array_push($clm_total_format, "$." . str_replace("'", "", $round_no));
                            array_push($clm_sub_total, "0.00");
                        }
                    } else {
                        if ($arrayR[2] == "'s'") {
                            if ($fields == 2) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 3) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$");
                                $report_total_clm_start = -1;
                            }  

                            if ($fields == 4) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 5) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 6) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$", "$", "$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 7) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "$", "$", "$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 8) {
                                $clm_total_format = array("N", "N", "$", "$", "$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 9) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 10) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 11) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 12) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 13) {
                                var_dump('here');
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" ,"$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 14) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 15) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 16) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 17) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$" , "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 18) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$" , "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 19) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$" , "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                            
                            if ($fields == 20) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$" , "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                        }
                    
                        if ($arrayR[2] == "'p'") {
                            if ($fields == 2) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 3) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N");
                                $report_total_clm_start = -1;
                            }  

                            if ($fields == 4) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "N");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 5) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "N", "N");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 6) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "N", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 7) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 8) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 9) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 10) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" ,"$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 11) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 12) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 13) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 14) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 15) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 16) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 17) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 18) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 19) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 20) {
                                $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "$" , "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                                $report_total_clm_start = -1;
                            }
                        }
                    
                        if ($arrayR[2] == "'g'" OR $arrayR[2] == "'e'" OR $arrayR[2] == "'h'" OR $arrayR[2] == "'t'" ){
                            if ($fields == 2) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 3) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 4) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 5) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "$", "$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 6) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "$", "$","$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 7) {
                                $clm_total = array("", "");
                                $clm_total_format = array("N", "N", "N", "$", "$","$","$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 8) {
                                $clm_total_format = array("N", "N", "N", "$", "$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 9) {
                                $clm_total_format = array("N", "N", "N", "$", "$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                    
                            if ($fields == 10) {
                                $clm_total_format = array("N", "N","N", "$", "$", "$", "$","$" ,"$","$");
                                $report_total_clm_start = -1;
                            }
                        
                            if ($fields == 11) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$");
                                $report_total_clm_start = -1;
                            }
                    
                            if ($fields == 12) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$");
                                $report_total_clm_start = -1;
                            }
                    
                            if ($fields == 13) {
                                $clm_total_format = array("N", "N", "$", "$", "$", "$", "$","$" ,"$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                    
                            if ($fields == 14) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                    
                            if ($fields == 15) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 16) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 17) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$" ,"$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 18) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 19) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }

                            if ($fields == 20) {
                                $clm_total_format = array("N", "N", "N", "$", "$", "$", "$","$" ,"$","$","$","$","$","$","$","$","$","$","$","$");
                                $report_total_clm_start = -1;
                            }
                        }
                    }
                } elseif (strpos($sql, "spa_REC_Exposure_Report") != false || strpos($sql, "spa_rec_exposure_report_paging ") != false) {
                    $round_no = $arrayR[14];
                    $report_name = "spa_REC_Exposure_Report";
                    
                    if ($fields == 10) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, "", "", 0.00, 0.00);
                        $sub_total_clm = 4;
                    } elseif ($fields == 7 && $arrayR[19] == "'m'") {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 7 && $arrayR[19] == "'a'") {
                        $clm_total = array("", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "", "", 0.00, 0.00);
                        $sub_total_clm = 1;
                    } elseif ($fields == 6) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 8 && $arrayR[19] == "'m'") {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, "", "", 0.00, 0.00);
                        $sub_total_clm = 0;
                    } elseif ($fields == 8 && $arrayR[19] == "'a'") {
                        $clm_total = array("", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", 0.00, "", "", 0.00, 0.00);
                        $sub_total_clm = 1;
                    } elseif ($fields == 9) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, "", "", 0.00, 0.00, "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 15) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "");
                        $sub_total_clm = 0;
                    }
                } elseif (strpos($sql, "spa_find_matching_rec_deals") != false) {
                    $report_name = "spa_find_matching_rec_deals";
                    
                    if ($fields == 16) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 18) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 17) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 15) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_gen_invoice_variance_report") != false) {
                    $report_name = "spa_gen_invoice_variance_report";		

                    if($arrayR[21] ?? '' != ""){
                        $round_no = $arrayR[21];
                    }
                    
                    if ($fields == 2) {
                        $clm_total = array("", 0.00);
                        $clm_total_format = array("N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }        
                    
                    if ($fields == 2 && $arrayR[6] == "'d'") {
                        $clm_total = array("", 0.00);
                        $clm_total_format = array("N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }        
                    
                    if ($fields == 4 && $arrayR[6] != "'d'") {
                        $clm_total = array("", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 5) {
                        $clm_total = array("", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6 && count($arrayR) == 7) {
                        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif($fields == 11 && $arrayR[6] == "'h'") {
                        $clm_total = array("Total", "", "", "", "","", "",0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2","$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", '', '', '', '', '', '', '', '', '', '', '');
                        $sub_total_clm = -1;	
                    } elseif($fields == 10 && $arrayR[6] == "'h'") {
                        $clm_total = array("Total", "", "", "","", "","", 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N","$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", '', '', '', '', '', '', '', '', '', '');
                        $sub_total_clm = -1;		
                    } elseif($fields == 13 && $arrayR[6] == "'h'") {
                        $clm_total = array("Total", "", "", "", "",0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", '', '', '', '', '', '', '', '', '', '', '', '', '');
                        $sub_total_clm = -1;
                    } elseif ($fields == 6 && count($arrayR) == 19 && ($arrayR[6]=="'m'" || $arrayR[6]=="m")) {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6 && count($arrayR) == 19 && $arrayR[6]=="'f'") {    
                
                        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6 && count($arrayR) == 8 && $arrayR[6] == "'f'") {
                        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6 && count($arrayR) == 13 && $arrayR[6] == "'f'") {
                        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6 && count($arrayR) == 6) {
                        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 3 && $arrayR[6] != "'d'") {
                        $clm_total = array("", 0.00, 0.00,);
                        $clm_total_format = array("N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 4 && $arrayR[6] == "'d'") {
                        $clm_total = array("", 0.00, 0.00, 0.00,);
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no));
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 10 && $arrayR[6] != "'h'") {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "",  "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($arrayR[6] == "'h'") {
                        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "", "");
                        $sub_total_clm = -1;			
                        
                        for ($x = 8; $x < $fields; $x++) {
                            array_push($clm_total, "0.00");
                            array_push($clm_total_format, "$." . str_replace("'", "", $round_no));
                            array_push($clm_sub_total, "0.00");
                        }
                        array_push($clm_total_format, "N");
                    } 		
                } elseif (strpos($sql, "spa_get_calc_invoice_volume") != false) {
                    $report_name = 'spa_get_calc_invoice_volume';
                    
                    if ($fields == 10) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$.2", "$.2", "$.2", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 13) {
                        $clm_total = array('', '', '', '', '', '', '', '', '', '', '', '', '', '');
                        $clm_total_format = array('N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N');
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", '', '', '', '', '', '', '', '', '', '', '', '', '');
                        $sub_total_clm = -1;
                    }
                
                } elseif (strpos($sql, "spa_rec_production_report") != false) {
                    $report_name = "spa_rec_production_report";

                    if ($fields == 16) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 1;
                    }
                } elseif (strpos($sql, "spa_create_hourly_position_report") != false) {
                    if (count($arrayR) > 20) {
                        $round_no = $arrayR[22];
                    } else {
                        $round_no = 0;
                    }

                    $report_name = "spa_create_hourly_position_report";

                    if ($fields == 4) {
                        $clm_total = array("Total", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 5) {
                        if (count($arrayR) > 22) {
                            $round_no = $arrayR[22];
                        } else {
                            $round_no = 0;
                        }

                        $clm_total = array("Total", "", "", 0.00, "", "");
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no), "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 6) {
                        if (count($arrayR) > 22) {
                            $round_no = $arrayR[22];
                        } else {
                            $round_no = 0;
                        }

                        $clm_total = array("Total", "", "", "", 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 7) {
                        if (count($arrayR) > 22){
                            $round_no = $arrayR[22];
                        } else {
                            $round_no = 0;
                        }

                        $clm_total = array("Total", "", "", "", "", 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 9) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 3) {
                        $clm_total = array("Total", "", 0.00, "");
                        $clm_total_format = array("N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 27) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 28) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 29) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 51) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 99) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_get_locked_values") != false) {
                    $report_name = "spa_get_locked_values";
                    
                    if ($fields == 4) {
                        $clm_total = array("Total", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 5) {
                        $clm_total = array("Total", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 10) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$", "$", "N");
                        $report_total_clm_start = 7;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$", "$", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 19) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 7;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 20) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
                        $report_total_clm_start = 7;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_rec_compliance_summary_report ") != false) {
                    $report_name = "spa_create_rec_compliance_summary_report";

                    if ($fields == 13) {
                        $clm_total = array("Total", "", 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$.0", "N", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Create_fas157_Disclosure_Report ") != false) {
                    $report_name = "spa_Create_fas157_Disclosure_Report";
                    $round_no = str_replace("'", '', $arrayR[13]);

                    if ($fields == 5) {
                        $clm_total = array("Total", "0.00", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$.$round_no", "$.$round_no", "$.$round_no", "$.$round_no");
                        $report_total_clm_start = 0;
                        $sub_total_clm = -1;
                    } elseif ($fields == 2) {
                        $clm_total = array("Total", "0.00", "0.00");
                        $clm_total_format = array("N", "N");
                        $report_total_clm_start = -1;
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_wind_pur_power_report ") != false) {
                    $report_name = "spa_wind_pur_power_report";

                    if ($fields == 14) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0", "$.0");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 15) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.00", "$.2", "$.00", "$.2", "$.00", "$.2", "$.00", "$.2", "$.00", "$.2");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 16 && $arrayR[10] == "'d'") {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.1", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                    }

                    if ($fields == 16 && $arrayR[8] == "'c'") {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "N", "$.2", "N", "$.2", "N", "$.2", "N", "$.2");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 1;
                    }

                    if ($fields == 17) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N", "$.2", "N", "$.2", "N", "$.2", "N", "$.2");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    }
                } elseif (strpos($sql, "spa_rec_generator_report") != false) {
                    $report_name = "spa_rec_generator_report";

                    if ($fields == 14) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_tagging_audit_report") != false) {
                    $report_name = "spa_create_tagging_audit_report";

                    if ($fields == 12) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_get_counterparty_exposure_report") != false || strpos($sql, "spa_get_counterparty_exposure_report_paging") != false) {
                    $report_name = "spa_get_counterparty_exposure_report";
                    $round_no = $arrayR[24];
                
                    if ($fields == 2) {
                        $clm_total = array("Total", "", 0.00);
                        $clm_total_format = array("N", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 3) {
                        $clm_total = array("Total", "", 0.00, 0.00);
                        $clm_total_format = array("N", "$.X", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 4 && $arrayR[2] != "'a'") {
                        $clm_total = array("Total", "", "", "", "");
                        $clm_total_format = array("N", "N", "$.X", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 5 && $arrayR[3] == "'k'") {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 5 && $arrayR[3] == "'c'") {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 5 && $arrayR[2] == "'f'") {
                        $clm_total = array("Total", "", "", "", "", "");
                        $clm_total_format = array("N", "$.X", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 5 && $arrayR[2] != "'r'" && $arrayR[2] != "'a'") {
                        $round_no = $arrayR[24];
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.X", "$.X", "$.X");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 4 && $arrayR[2] == "'a'") {
                        $clm_total = array("Total", "", "", "", "");
                        $clm_total_format = array("N", "N", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 5 && $arrayR[2] == "'a'" && $arrayR[3] == "'s'") {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 5 && $arrayR[2] == "'a'" && $arrayR[3] == "'d'") {
                        if ($arrayR[23] != "'d'"){
                            $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                            $clm_total_format = array("N", "N", "$.2", "$.2", "$.2");
                        } else {
                            $clm_total = array("Total", "", "", "", 0.00, 0.00);
                            $clm_total_format = array("N", "N", "N", "$.2", "$.2");
                        }   
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 5) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6) {
                        $round_no = $arrayR[24];

                        if ($arrayR[2] == "'r'") {
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "$.X", "$.X", "$.X", "$.X");
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00);
                            $sub_total_clm = 0;
                        } elseif ($arrayR[2] != "'f'" && $arrayR[5] == "'b'") {
                            $clm_total = array("Total", "", "", "", "", 0.00, 0.00);
                            $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X");
                        } elseif ($arrayR[2] == "'f'") {
                            if ($arrayR[4] == "'t'" || $arrayR[4] == "'i'" || $arrayR[4] == "'d'" || $arrayR[4] == "'c'" || $arrayR[4] == "'s'" || $arrayR[4] == "'b'" || $arrayR[4] == "'e'" || $arrayR[4] == "'p'" || $arrayR[4] == "'r'") {
                                if ($arrayR[23] == "'s'" && $arrayR[3] == "'s'") {
                                    $clm_total = array("Total", "", "", "", "", "");
                                    $clm_total_format = array("N", "$.X", "$.X", "$.X", "$.X", "$.X");
                                    $report_total_clm_start = 0;
                                    $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                                    $sub_total_clm = -1;
                                } else {
                                    $clm_total = array("Total", "", "", "", "", "");
                                    $clm_total_format = array("N", "N", "$.X", "$.X", "$.X", "$.X");
                                    $report_total_clm_start = 0;
                                    $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                                    $sub_total_clm = 0;
                                }
                            } else {
                                $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00);
                                $clm_total_format = array("N", "$.X", "$.X", "$.X", "$.X", "$.X");
                            }
                        } elseif ($arrayR[2] == "'c'") {
                            $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00);
                            $clm_total_format = array("N", "$.X", "$.X", "$.X", "$.X", "$.X");
                        } elseif ($arrayR[2] == "'e'" && $arrayR[3] == "'r'") {
                            $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00);
                            $clm_total_format = array("N", "N", "N", "N", "N", "$.X");
                        } else {
                            $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "$.X", "$.X", "$.X", "$.X", "N");
                        }

                        if ($arrayR[2] != "'f'") {
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");

                            if ($arrayR[3] == "'d'") {
                                $report_total_clm_start = 2;
                            } elseif ($arrayR[3] == "'s'") {
                                $report_total_clm_start = 0;
                            } elseif ($arrayR[3] == "'f'") {
                                $report_total_clm_start = 0;
                            } else {
                                $report_total_clm_start = -1;
                            }
                        }

                        if ($arrayR[23] == "'s'") {
                            if ($arrayR[2] == "'f'") {
                                if ($arrayR[4] == "'p'" || $arrayR[4] == "'c'" || $arrayR[4] == "'b'") {
                                    $sub_total_clm = -1;
                                } else {
                                    $sub_total_clm = 0;
                                }
                            }
                        } else {
                            $sub_total_clm = 0;
                        }
                    } elseif ($fields == 7 && $arrayR[3] != "'c'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X", "$.X");
                        
                        if (($arrayR[2] == "'f'" || $arrayR[2] == "'r'" || $arrayR[2] == "'c'") && $arrayR[3] == "'d'"){
                            $clm_total = array("Total", "", "", "", "", "", 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X", "N");
                        }

                        $report_total_clm_start = 2;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7 && $arrayR[3] != "'k'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "$.X", "$.X", "N", "N", "$.X", "N");
                        
                        if ($arrayR[2] == "'r'") {
                            $report_total_clm_start = 0;
                        } else {
                            $report_total_clm_start = 2;
                        }
                        
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7 && $arrayR[3] == "'k'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 3;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 8 && $arrayR[3] == "'s'") {
                        if ($arrayR[2] == "'r'") {
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "");
                            $sub_total_clm = 0;
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                            $clm_total_format = array("N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X");
                            $report_total_clm_start = 0;
                        } else {
                            if ($arrayR[5] == "'b'") {
                                $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                                $clm_total_format = array("N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X");
                            } else {
                                $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                                $clm_total_format = array("N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X");
                            }

                            $report_total_clm_start = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "");
                            $sub_total_clm = -1;
                        }
                    } elseif ($fields == 8 && $arrayR[3] != "'s'") {
                        if ($arrayR[2] == "'r'") {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                            $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X");
                        } else {
                            $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                            $clm_total_format = array("N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X");
                        }
                        
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 9) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$.X", "$.X", "N", "$.X", "$.X", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 10) {
                        if ($arrayR[2] == "'e'") {
                            $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "N");
                            $report_total_clm_start = 2;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                            $sub_total_clm = -1;
                        } else {
                            $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                            $clm_total_format = array("N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X");
                            $report_total_clm_start = -1;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "");
                            $sub_total_clm = -1;
                        }
                    } elseif ($fields == 11) {
                        if ($arrayR[2] == "'e'") {
                            $clm_total = array("Total", "", "", 0.00, "", "", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", 0, "N", "$.X", "$.X", 0, "$.X", "N");
                            $report_total_clm_start = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "");
                            $sub_total_clm = -1;
                        } else {
                            $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X");
                            $report_total_clm_start = -1;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "");
                            $sub_total_clm = -1;
                        }
                    } elseif ($fields == 13) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 15) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 42) {
                        $round_no = $arrayR[24];
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "N", "N", "$.X", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "N", "N", "N", "$.X", "$.X");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_view_volatility_and_correlation") != false) {
                    $report_name = "spa_view_volatility_and_correlation";

                    if ($fields == 4) {
                        $clm_total = array("Total", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.6");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 5) {
                        if ($arrayR[2] == "'v'") {
                            $clm_total = array("Total", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N");
                        } else {
                            $clm_total = array("Total", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$.6");
                        }

                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6) {
                        if ($arrayR[2] == "'b'") {
                            $clm_total = array("Total", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "$.6");
                        } elseif ($arrayR[2] == "'c'"){
                            $clm_total = array("Total", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "$.6");
                        }else {
                            $clm_total = array("Total", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$.6", "$.6");
                        }
                        
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        if ($arrayR[2] == "'b'") {
                            $clm_total = array("Total", "", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.6");
                        } else {
                            $clm_total = array("Total", "", "", "", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N", "$.6", "$.6");
                        }

                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_get_implied_volatility_report") != false) {

                    $report_name = "spa_get_implied_volatility_report";

                    if ($fields == 5) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00);
                        $clm_total_format = array("N", "N", "", "$.2", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_get_counterparty_credit_report") != false) {
                    $report_name = "spa_get_counterparty_credit_report";

                    if ($fields == 16) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 4) {
                        $clm_total = array("Total", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Create_Options_Report") != false || strpos($sql, "spa_create_options_report") != false) {
                    $report_name = "spa_Create_Options_Report";

                    if ($fields == 19) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 20) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "", "N", "N", "", "", "", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 21) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2",);
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 23) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "", "", "", "", "N", "N", "N", "", "N", "", "", "", "", "", "", "", "");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 33) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 36) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "", "N", "N", "", "", "", "", "", "", "", "N", "N", "", "", "", "", "", "", "", "");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_get_limits_report") != false) {
                    $report_name = "spa_get_limits_report";

                    if ($fields == 10) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 11) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, "", "");
                        $clm_total_format = array("N", "N", "$.2", "$.2", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 15) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("", "N", "N", "", "N", "N", "$.2", "N", "N", "$.2", "$.2", "N", "", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_get_var_report") != false || strpos($sql, "spa_get_VaR_report") != false) {
                    $report_name = "spa_get_var_report";

                    if ($fields == 5) {
                        $clm_total = array("Total", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.4", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6) {
                        $clm_total = array("Total", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.4", "N", "$.4");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        $clm_total = array("", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "", "$.4", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$.4", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 9) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.4", "$.4", "$.4", "$.4");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 10) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 11) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 12) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 13) { //Added by Shushil Bohara for At Risk Report of Report Option Type "All"
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$.4", "$.4", "$.4", "$.4", "$.4", "$.4", "$.4", "$.4", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 14) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 15) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 3) {
                        $clm_total = array("Total", "", "");
                        $clm_total_format = array("N", "$", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_deal_schedule_report") != false) {
                    $report_name = "spa_deal_schedule_report";

                    if ($fields == 9 && $arrayR[2] == "'t'") {
                        $clm_total = array("Total", "","", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$", "$", "$", "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields == 10  && $arrayR[2] == "'d'") {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N","N","N", "N", "N", "N", "N", "$", "$", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_power_position_report") != false) {
                    $report_name = "spa_create_power_position_report";

                    if ($fields == 5) {
                        $clm_total = array("Total", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 9) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6) {
                        $clm_total = array("Total", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("Sub-total", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_get_emissions_inventory ") != false || strpos($sql, "spa_get_emissions_inventory_paging") != false) {
                    $report_name = "spa_get_emissions_inventory";

                    if ($fields == 10 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 10 && $arrayR[2] == "s" && $arrayR[25] == "'g'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 12 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 12 && $arrayR[2] == "s" && $arrayR[25] == "'g'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 5 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 6 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 8 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 9 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 10 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 11 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 12 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 13 && $arrayR[2] == "s" && $arrayR[35] == "'n'" && $arrayR[25] == "'s'") {
                        $round_no = $arrayR[39];
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 4;
                    } elseif ($fields == 13 && $arrayR[2] == "s" && $arrayR[35] == "'n'" && $arrayR[25] == "'g'") {
                        $round_no = $arrayR[39];
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 4;
                    } elseif ($fields == 13 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {

                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 1;
                    } elseif ($fields == 14 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 15 && $arrayR[2] == "s" && $arrayR[35] == "'n'") {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", 0.00, "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 3;
                    } elseif ($fields == 15 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 16 && $arrayR[2] == "s" && $arrayR[35] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "N", "");
                        $clm_total_format = array("N", "N", "N", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 14 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N", "$.2", "N", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 14 && $arrayR[2] == "s" && $arrayR[25] == "'g'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N", "$.2", "N", "$.2", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 1;
                    } elseif ($fields == 15 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $round_no = $arrayR[39];
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 4;
                    } elseif ($fields == 15 && $arrayR[2] == "s" && $arrayR[25] == "'g'") {
                        $round_no = $arrayR[39];
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 4;
                    } elseif ($fields == 16 && $arrayR[2] == "s" && $arrayR[25] == "'s'" && $arrayR[35] != "'y'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.4", "$.4", "$.4", "N", "$.4", "N", "$.4", "N", "$.4", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 16 && $arrayR[2] == "s" && $arrayR[25] == "'g'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 17 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.4", "$.4", "$.4", "N", "$.4", "N", "$.4", "N", "$.4", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 17 && $arrayR[2] == "s" && $arrayR[25] == "'g'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 18 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 18 && $arrayR[2] == "s" && $arrayR[25] == "'g'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 19 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 19 && $arrayR[2] == "s" && $arrayR[25] == "'g'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 20 && $arrayR[2] == "s" && ($arrayR[25] == "'s'" || $arrayR[25] == "'g'")) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 22 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 24 && $arrayR[2] == "s" && $arrayR[25] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.3", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 9 && $arrayR[2] == "s") {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.3", "N", "$.3", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 2;
                    } elseif ($fields == 9 && $arrayR[2] == "'d'") {
                        $clm_total = array("Total", "", "", "", 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$.4", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 10 && $arrayR[2] == "'d'") {
                        $clm_total = array("Total", "", "", "", 0.00, "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$.4", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 8 && $arrayR[2] == "'d'") {
                        $clm_total = array("Total", "", "", "", 0.00, "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.4", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    } elseif ($fields == 6 && $arrayR[2] == "'f'") {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.4");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 7 && $arrayR[2] == "'f'") {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.4", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_run_emissions_whatif_report") != false) {
                    $report_name = "spa_run_emissions_whatif_report";
                    $round_no = str_replace("'", "", $arrayR[31]);

                    if ($fields == 7) { //summary
                        $clm_total = array("Total", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 8) { //summary
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_Create_MTM_Period_Report_TRM") != false || strpos($sql, "spa_create_mtm_period_report_trm") != false) {
                    $report_name = "spa_Create_MTM_Period_Report_TRM";
                    $round_no = $arrayR[30];
                    
                    if ($fields == 5 && $arrayR[9] == "'1'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, "");
                        $sub_total_clm = 2;
                    } else if ($fields == 8 && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 2;
                    } else if ($fields == 6 && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, "");
                        $sub_total_clm = 2;
                    } else if ($fields == 7 && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, "");
                        $sub_total_clm = 2;
                    } else if ($fields == 9 && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 2;
                    } else if ($fields == 5 && $arrayR[9] == "'4'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", esc_td, esc_td, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, 0.00, "");
                        $sub_total_clm = 0;
                    } else if ($fields == 4 && $arrayR[9] == "'5'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", esc_td, 0.00, "");
                        $clm_total_format = array("N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "");
                        $sub_total_clm = 0;
                    } else if ($fields == 3 && $arrayR[9] == "'6'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", 0.00, "");
                        $clm_total_format = array("N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 5 && $arrayR[9] == "'6'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 4 && $arrayR[9] == "'7'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", es_td, 0.00, "");
                        $clm_total_format = array("N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 4 && $arrayR[9] == "'8'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", es_td, 0.00, "");
                        $clm_total_format = array("N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, 0.00, "");
                        $sub_total_clm = 0;
                    } else if ($fields == 4 && $arrayR[9] == "'9'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", es_td, 0.00, "");
                        $clm_total_format = array("N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, 0.00, "");
                        $sub_total_clm = 0;
                    } else if ($fields == 5 && $arrayR[9] == "'10'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", es_td, esc_td, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, 0.00, "");
                        $sub_total_clm = 0;
                    } else if ($fields == 3 && $arrayR[9] == "'11'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", 0.00, "");
                        $clm_total_format = array("N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 5 && $arrayR[9] == "'11'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 4 && $arrayR[9] == "'12'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", esc_td, 0.00, "");
                        $clm_total_format = array("N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 17 && $arrayR[9] == "'13'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 13 && $arrayR[9] == "'14'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 15 && $arrayR[9] == "'14'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 19 && $arrayR[9] == "'20'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, esc_td);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                    } else if ($fields == 27 && $arrayR[9] == "'15'" && $arrayR[46] == "'n'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, esc_td, 0.00, esc_td, esc_td, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "N", "$.X", "N", "N", "$.X", "$.X");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, esc_td, 0.00, esc_td, esc_td, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } else if ($fields == 5 && $arrayR[9] == "'1'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, "");
                        $sub_total_clm = 2;
                    } else if ($fields == 6 && $arrayR[9] == "'2'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, "");
                        $sub_total_clm = 2;
                    } else if ($fields == 7 && $arrayR[9] == "'3'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, "");
                        $sub_total_clm = 3;
                    } else if ($fields == 5 && $arrayR[9] == "'4'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, "");
                        $sub_total_clm = 1;
                    } else if ($fields == 4 && $arrayR[9] == "'5'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", "", 0.00, "");
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "");
                        $sub_total_clm = 0;
                    } else if ($fields == 3 && $arrayR[9] == "'6'" && $arrayR[46] == "'y'") {
                        $round_no = $arrayR[30];
                        $clm_total = array("Total", 0.00, "");
                        $clm_total_format = array("N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 4 && $arrayR[9] == "'7'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", "", 0.00, "");
                        $clm_total_format = array("N", "N", "$." . str_replace("'", "", $round_no), "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "");
                        $sub_total_clm = 0;
                    } else if ($fields == 13 && $arrayR[9] == "'14'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 15 && $arrayR[9] == "'13'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 22 || $fields == 21 && $arrayR[9] != "'19'") {
                        if ($arrayR[62] == "'c'" && $arrayR[46] == "'y'") {
                            $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "", '', '', '', '');
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "N", "$.X", "N", "N", "$.X", "N", "N", "N", "N", "$.X", 'N');
                            $report_total_clm_start = 0;
                            $clm_tot_col_span = 1;
                            $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, "", '', '', '', '');
                            $sub_total_clm = -1;
                        } else if ($arrayR[9] == "'20'" && $arrayR[46] == "'n'") {
                            $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, esc_td, esc_td, esc_td, esc_td);
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "N");
                            $report_total_clm_start = 0;
                            $clm_tot_col_span = 1;
                            $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, esc_td);
                            $sub_total_clm = -1;
                        } else { //Summary by Deal with Fees
                            $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, esc_td, esc_td, esc_td, esc_td);
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", 'N');
                            $report_total_clm_start = 0;
                            $clm_tot_col_span = 1;
                            $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, esc_td);
                            $sub_total_clm = -1;
                        }
                    } else if ($fields == 31 && $arrayR[62] == "'c'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "$." . str_replace("'", "", $round_no), "N", "N", "$." . str_replace("'", "", $round_no), "N", "N", "N", "$." . str_replace("'", "", $round_no), "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 20 && $arrayR[62] == "'s'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "N", "$.X", "N", "$.X", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($fields == 58 && $arrayR[62] == "'p'" && $arrayR[46] == "'y'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.X", "N", "$.X", "N", "N", "$.X", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "$." . str_replace("'", "", $round_no), "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } else if ($arrayR[9] == "'19'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td);
                        $sub_total_clm = -1;

                        for ($x = 14; $x < $fields; $x++) {
                            array_push($clm_total, "0.00");
                            array_push($clm_total_format, "$." . str_replace("'", "", $round_no));
                            array_push($clm_sub_total, "0.00");
                        }

                        array_push($clm_total_format, "N");
                    } else if ($arrayR[9] == "'20'") {
                        $clm_total = array("Total", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td, esc_td);
                        $sub_total_clm = -1;

                        for ($x = 15; $x < $fields; $x++) {
                            array_push($clm_total, "0.00");
                            array_push($clm_total_format, "$." . str_replace("'", "", $round_no));
                            array_push($clm_sub_total, "0.00");
                        }
                        
                        array_push($clm_total_format, "N");
                    }
                } elseif (strpos($sql, "spa_run_emissions_intensity_report") != false) {
                    $report_name = "spa_run_emissions_intensity_report";
                    $round_no = str_replace("'", "", $arrayR[31]);
                    $report_total_clm_start = 1;
                    $clm_tot_col_span = 0;
                    $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, "");
                    $sub_total_clm = -1;

                    if (($arrayR[3] == "'1'" || $arrayR[3] == "'5'" || $arrayR[3] == "'6'") && $arrayR[4] == "'1'") {
                        $report_total_clm_start = 1;
                        $format = "$.3";
                    } elseif ($arrayR[4] == "'1'") {
                        $report_total_clm_start = 0;
                        $format = "$.2";
                    } elseif ($arrayR[3] == "'2'") {
                        $format = "$.2";
                        $report_total_clm_start = 1;
                    } elseif ($arrayR[3] == "'3'") {
                        $format = "$.2";
                        $report_total_clm_start = 1;
                    } elseif ($arrayR[3] == "'4'") {
                        $format = "$.2";
                        $report_total_clm_start = 1;
                    } else {
                        $format = "";
                    }
                    
                    if ($fields == 3) { //summary
                        $clm_total = array("Total", 0.00, "");
                        $clm_total_format = array("N", "$.2", "N");
                        $report_total_clm_start = 0;
                    } elseif ($fields == 4) { //summary
                        $clm_total = array("Total", "", 0.00, "");
                        $clm_total_format = array("N", "N", "$." . $round_no, "N");
                    } elseif ($fields == 5) { //summary
                        $clm_total = array("Total", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$." . $round_no, "N");
                    } elseif ($fields == 5 && strtoupper($arrayR[29]) == "NULL") { //summary
                        $clm_total = array("Total", "", 0.00, "", 0.00);
                        $clm_total_format = array("N", "N", "$." . $round_no, "$." . $round_no, "N");
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, "",);
                        $sub_total_clm = -1;
                    } elseif ($arrayR[4] == "'6'") {
                        if ($fields == 5) {
                            $clm_total = array("Total", "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "N");
                            $report_total_clm_start = 1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, "",);
                            $sub_total_clm = 1;
                        } elseif ($fields == 6) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "$.2", "$.2", "N");
                            $report_total_clm_start = 1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00, "",);
                            $sub_total_clm = 2;
                        } elseif ($fields == 7) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, "",);
                            $sub_total_clm = -1;
                        } elseif ($fields == 9) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, "",);
                            $sub_total_clm = -1;
                        } elseif ($fields == 8) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, "",);
                            $sub_total_clm = -1;
                        } elseif ($fields == 109) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.0, 00.00, "",);
                            $sub_total_clm = -1;
                        } elseif ($fields == 11) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.0, 00.00, 00.00, "",);
                            $sub_total_clm = -1;
                        } elseif ($fields == 12) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = 1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "",);
                            $sub_total_clm = 2;
                        } elseif ($fields == 13) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $sub_total_clm = -1;
                        } elseif ($fields == 14) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $sub_total_clm = -1;
                        } elseif ($fields == 15) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = 1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $sub_total_clm = -1;
                        } elseif ($fields == 16) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = 1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $sub_total_clm = -1;
                        } elseif ($fields == 17) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $sub_total_clm = -1;
                        } elseif ($fields == 18) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$.2", "$.2", "$.2", "$.2", "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $sub_total_clm = -1;
                        } elseif ($fields == 19) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $sub_total_clm = -1;
                        } elseif ($fields == 20) {
                            $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "");
                            $clm_total_format = array("N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "N");
                            $report_total_clm_start = -1;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                            $sub_total_clm = -1;
                        } else {
                            $clm_total = array("Total", "", "");
                            $clm_total_format = array("N", $format, $format);
                            
                            for ($x = 2; $x < $fields - 2; $x++) {
                                array_push($clm_total, "0.00");
                                array_push($clm_total_format, "$.2");
                            }
                        }
                    } else {
                        $clm_total = array("Total", "", "");
                        
                        if ($arrayR[4] != "'1'") {
                            $clm_total_format = array("N", "N", "N");
                            for ($x = 2; $x < $fields - 2; $x++) {
                                array_push($clm_total, "0.00");
                                array_push($clm_total_format, "$.2");
                            }
                        } else {
                            $clm_total_format = array("N", "N");
                            for ($x = 2; $x < $fields - 1; $x++) {
                                array_push($clm_total, "0.00");
                                array_push($clm_total_format, "N");
                            }
                        }

                        array_push($clm_total, "");
                        array_push($clm_total_format, "N");
                    }
                }

                /* for MTM Counterparty Report  */ 
                elseif (strpos($sql, "spa_Counterparty_MTM_Report") != false or strpos($sql, "spa_counterparty_mtm_report_paging") != false) {
                    $report_name = "spa_Counterparty_MTM_Report";
                    $round_no = str_replace("'", "", $arrayR[26]);
                    
                    if ($fields == 11) { //summary{
                        $clm_total = array("Total", 0.00, 0.00, 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "$", "$", "$", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no);
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 12) { //summary{
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "$", "$", "$", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no);
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 13) { //summary{
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "$", "$", "$", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no);
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 14) { //summary{
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "$", "$", "$", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no);
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 15) { //summary{
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$", "$", "$", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no);
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 16) { //summary{
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$", "$", "$", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no);
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 17) { //summary{
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$", "$", "$", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no);
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 18) { //summary{
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "N", "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "$." . $round_no, "N");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_deal_transfer") != false) {
                    $report_name = "spa_deal_transfer";
                    
                    if ($fields == 9) {
                        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.3", "$.4", "$.4");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } 
                } elseif (strpos($sql, "spa_check_emissions_target_limit") != false) {
                    $report_name = "spa_check_emissions_target_limit";
                    
                    if ($fields == 7) {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.2", ".2", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_approve_status_control_activities_all") != false) {
                    $report_name = "spa_approve_status_control_activities_all";
                    
                    if ($fields == 11) {
                        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_counterparty_limits_report") != false) {
                    $report_name = "spa_counterparty_limits_report";

                    if ($fields == 3) {
                        $clm_total = array("Total", "", "", 0.00);
                        $clm_total_format = array("N", "N", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 4) {
                        $clm_total = array("Total", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 5) {
                        $clm_total = array("Total", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 6) {
                        $clm_total = array("Total", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 7) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    }
                    
                    if ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                    
                    if ($fields == 9) {
                        $clm_total = array("Total", "", "", "", "", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 10) {
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    } else if ($fields > 10) {
                        $add_total = '0.00';
                        $add_format = "$.2";
                        $add_sub_total = '""';

                        for ($i = 3; $i < $fields; $i++) {
                            $clm_total[0] = "Total";
                            $clm_total[1] = '""';
                            $clm_total[2] = '""';
                            $clm_total[$i] = $add_total;

                            $clm_total_format[0] = "N";
                            $clm_total_format[1] = "N";
                            $clm_total_format[2] = "N";
                            $clm_total_format[$i] = $add_format;

                            $report_total_clm_start = -1;

                            $clm_sub_total[0] = '""';
                            $clm_sub_total[1] = '""';
                            $clm_sub_total[2] = '""';
                            $clm_sub_total[$i] = $add_sub_total;

                            $sub_total_clm = -1;
                        }
                    }
                } elseif (strpos($sql, "spa_create_roll_forward_inventory_report") != false) {
                    $report_name = "spa_create_roll_forward_inventory_report";

                    if ($fields == 6) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.X", ".0", "N", "$.X");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 7) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "$.X", ".0", "N", "$.X", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    } elseif ($fields == 11) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", ".0", "$.X", "$.X", ".0", ".0", "N", "$.X", "$.X");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 12) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", ".0", "$.X", "$.X", "N", ".0", "N", "N", "$.X", "$.X");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 9) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", ".0", "N", "N", "$.X", "$.X");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 10) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.X", "N", "N", "$.X", "$.X");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 13) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "N", "$.X", "$.X", "$.X");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } elseif ($fields == 14) {
                        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "N", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = -1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = -1;
                    }
                } else if (strpos($sql, "spa_run_sql") != false) { // FASTracker
                    $get_report_id = explode(',', $sql);
                    $get_report_id = explode(' ', $get_report_id[0]);
                    $report_id = $get_report_id[2];
                    $xmlFile = "spa_Report_record.php?flag=a&report_id=" . $report_id;
                    $returnvalue = readXMLURL($xmlFile); 
                    $report_name = $returnvalue[0][0];

                    if ($report_name == 'Limit Report') { //report name must be same
                        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00);
                        $sub_total_clm = 0;   
                    } else if ($report_name == 'UK Monthly Ineffectiveness Report') {
                        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
                        $report_total_clm_start = 1;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 0;   
                    } else if ($report_name == 'Available Hedge Capacity Report') {
                        $clm_total = array("Total", "N", "N", "N", "N", "N", "N", "N", "N", 0.00, 0.00, 0.00, 0.00, 0.00, "N");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 3;   
                    } else {
                        $clm_total = array();

                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"
                            , "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"
                            , "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"
                            , "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N"
                        );

                        $report_total_clm_start = -1;
                        $clm_tot_col_span = -1;

                        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""
                            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""
                            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""
                            , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""
                        );

                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_create_imbalance_report") != false) {
                    $report_name = "spa_create_imbalance_report";

                    if ($fields == 7) { 
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.4", "$.4", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } else if ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.4", "$.4", "$.4", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } else if ($fields == 9 && $arrayR[2] == "'s'") {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.4", "$.4", "$.4", "N", "N", "$$.4");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 0;
                    } else if ($fields == 9 && $arrayR[2] == "'d'") {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.0", "$.2", "$.2", "$.2", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00,  0.00,  0.00);
                        $sub_total_clm = 1;
                    } else if ($fields == 9) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.4", "$.4", "$.4", "$.4", "$.4", "N");
                        $report_total_clm_start = 2;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = -1;
                    } else if ($fields == 14) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
						$clm_total_format = array("N", "N", "N", "N", "N", '$.0', '$.0', '$.0', '$.0', '$.0', '$.0', "N", '$.0', "N");
						$report_total_clm_start = 0;
						$clm_tot_col_span = 0;
						$clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
						$sub_total_clm = -1;
                    } else if ($fields == 11) {
                        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", '$.X', '$.X', '$.X', '$.X', '$.X', "N", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $sub_total_clm = 1;
                    } else if ($fields == 13) {
                            $clm_total = array("Total", "", "", "", "", "", "", "",  0.00,  0.00,  0.00,  0.00,  0.00,  0.00);
                            $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", '$.X', '$.X', '$.X', '$.X', 'N',  'N');
                            $report_total_clm_start = 0;
                            $clm_tot_col_span = 0;
                            $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00,  "",  '$.X');
                            $sub_total_clm = 1;
                    } else if ($fields == 15) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", '$.0', '$.0', '$.0', '$.0', '$.0', '$.0', "N", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $sub_total_clm = 1;
                    } else if ($fields == 13){
                        $clm_total = array("Total", "", "", 0.00,  0.00,  0.00,  0.00, 0.00, 0.00, 0.00,  0.00,  0.00, "");
                        $clm_total_format = array("N", "N", "N", '$.X', '$.X', '$.X', '$.X', '$.X', '$.X', '$.X', '$.X', '$.X', 'N');
                        $report_total_clm_start = 0;
                        $clm_tot_col_span = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 'N');
                        $sub_total_clm = 1;
                    }
                    
                    if ($arrayR[26] == "'dr'" || $arrayR[26] == "'mr'") {
                        $report_total_clm_start = -1;
                    }
                    
                } elseif (strpos($sql, "spa_settlement_production_report") != false) {
                    $report_name = "spa_settlement_production_report";

                    if ($fields == 4) {
                        $clm_total = array("Total", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 5) {
                        $clm_total = array("Total", "", "", 0.00, "", "");
                        $clm_total_format = array("N", "N", "$.X", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 6) {
                        $clm_total = array("Total", "", "", 0.00, "", "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.X");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 7) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.X", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.X", "N", "N");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "");
                        $sub_total_clm = 0;
                    }

                    if ($fields == 28) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "$.X", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 29) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 99) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N",);
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 51) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }

                    if ($fields == 27) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
                        $report_total_clm_start = -1;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                        $sub_total_clm = -1;
                    }
                } elseif (strpos($sql, "spa_run_pnl_report") != false) {
                    $report_name = "spa_run_pnl_report";

                    if ($fields == 3) {
                        $clm_total = array("Total", "", "", 0.00);
                        $clm_total_format = array("N", "N", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "");
                        $sub_total_clm = 0;
                    } else if ($fields == 5) {
                        $clm_total = array("Total", "", "", "", "", 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "$.2");
                        $report_total_clm_start = 0;
                        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "");
                        $sub_total_clm = 1;
                    }
                } elseif ($spName == 'spa_virtual_storage') {
                    $report_name = 'spa_virtual_storage';
                    
                    if ($fields == 10) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "", "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "N", "N");
                    }
                } elseif (strpos($sql, "spa_run_whatif_scenario_report") != false || strpos($sql, "spa_run_whatif_scenario_report") != false) {
                    $report_name = 'spa_run_whatif_scenario_report';
                    
                    if ($fields == 7) {
                        $clm_total = array("Total", "", "", 0.00, "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "$.2", "N", "$.2", "N");
                    }   elseif ($fields == 9) {
                        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00);
                        $clm_total_format = array("N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2");
                    } elseif ($fields == 8) {
                        $clm_total = array("Total", "", "", "", "", "", 0.00, "");
                        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "N");
					} elseif ($fields == 11) {
						$clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
						$clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
                    } elseif ($fields == 14) {
                        $pos_tformat = '';
                        $mtm_tformat = '';
                        $var_tformat = '';
                        $cash_flow_tformat = '';
                        $cfar_tformat = '';
                        $earnings_tformat = '';
                        $ear_tformat = '';
                        $pfe_tformat = '';
                        $tmp_rows = $recordset_object->rows; 
                        
                        for ($i = 0; $i < $tmp_rows; $i++) {
                            $pos_tformat = ($recordset_object->recordsetsMDArray[$i][3] != '' && $recordset_object->recordsetsMDArray[$i][3] != 'NULL') ? '$.2' : ($pos_tformat == '$.2') ? '$.2' : 'N';
                            $mtm_tformat = ($recordset_object->recordsetsMDArray[$i][4] != '' && $recordset_object->recordsetsMDArray[$i][4] != 'NULL') ? '$.2' : ($mtm_tformat == '$.2') ? '$.2' : 'N';
                            $var_tformat = ($recordset_object->recordsetsMDArray[$i][5] != '' && $recordset_object->recordsetsMDArray[$i][5] != 'NULL') ? '$.2' : ($var_tformat == '$.2') ? '$.2' : 'N';
                            $cash_flow_tformat = ($recordset_object->recordsetsMDArray[$i][6] != '' && $recordset_object->recordsetsMDArray[$i][6] != 'NULL') ? '$.2' : ($cash_flow_tformat == '$.2') ? '$.2' : 'N';
                            $cfar_tformat = ($recordset_object->recordsetsMDArray[$i][7] != '' && $recordset_object->recordsetsMDArray[$i][7] != 'NULL') ? '$.2' : ($cfar_tformat == '$.2') ? '$.2' : 'N';
                            $earnings_tformat = ($recordset_object->recordsetsMDArray[$i][8] != '' && $recordset_object->recordsetsMDArray[$i][8] != 'NULL') ? '$.2' : ($earnings_tformat == '$.2') ? '$.2' : 'N';
                            $ear_tformat = ($recordset_object->recordsetsMDArray[$i][9] != '' && $recordset_object->recordsetsMDArray[$i][9] != 'NULL') ? '$.2' : ($ear_tformat == '$.2') ? '$.2' : 'N';
                            $pfe_tformat = ($recordset_object->recordsetsMDArray[$i][10] != '' && $recordset_object->recordsetsMDArray[$i][10] != 'NULL') ? '$.2' : ($pfe_tformat == '$.2') ? '$.2' : 'N';
                        }

                        $clm_total = array('Total', '', '', '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', '', '');
                        $clm_total_format = array('N', 'N', 'N', 'N', '$.2', $var_tformat, $cash_flow_tformat, $cfar_tformat, $earnings_tformat, $ear_tformat, $pfe_tformat, 'N', 'N', 'N');
                    }   
                } else if ($spName == 'spa_get_cva_report') { //cva report
                    $report_name = 'Credit Value Adjustment Report';
                    
                    if ($fields == 10) {
                        $clm_total = array('Total', '', '', '', '', '', '', '', '', '');
                        $clm_total_format = array('N', 'N', 'N', '$.X', '$.X', '$.X', '$.X', '$.X', '$.X', 'N');
                    } else if ($fields == 9) {
                        $clm_total = array('Total', '', '', '', '', '', '', '', '');
                        $clm_total_format = array('N', 'N', '$.X', '$.X', '$.X', '$.X', '$.X', '$.X', 'N');
                    } else if ($fields == 11) {
                        $clm_total = array('Total', '', '', '', '', '', '', '', '', '', '');
                        $clm_total_format = array('N', 'N', 'N', 'N', '$.X', '$.X', '$.X', '$.X', '$.X', '$.X', 'N');
                    }  
                } elseif ($spName == 'spa_virtual_storage_constraints') {
                    $report_name = 'spa_virtual_storage_constraints';
                    
                    if ($fields == 6) {
                        $clm_total = array("Total", "", 0.00, "", "", "");
                        $clm_total_format = array("N", "N", "$.2", "N", "N", "N");
                    }
                } elseif (strpos($sql, "spa_create_withdrawal_schedule") != false) {
                    $report_name = "spa_create_withdrawal_schedule";
                    
                    if ($fields == 3) {
                        $clm_total = array("Total", "", 0.00, 0.00);
                        $clm_total_format = array("N", "$.2", "$.2");
                        $report_total_clm_start = -1;
                    }
                } elseif ($spName == 'spa_pratos_mapping_index') {
                    $report_name = 'spa_pratos_mapping_index';
                    
                    if ($fields == 8) {
                        $clm_total = array('Total', 'esc_td', 'esc_td', 'esc_td', 'esc_td', 'esc_td', 'esc_td', 'esc_td');
                        $clm_total_format = array('N', 'N', 'N', 'N', 'N', 'N', 'N', 'N');
                        $clm_tot_col_span = -1;
                        $report_total_clm_start = -1;
                    }
                } elseif ($spName == 'spa_meter_data_report') {
                    $report_name = "spa_meter_data_report";
                
                    $round = $arrayR[11];
                    $granularity_value = $arrayR[4];
                    $round_no = str_replace("'", "", $round);
                    $granularity_check = str_replace("'", "",$granularity_value);
                    
                    if ($arrayR[10] == "'r'") {
                        if ($fields == 6) {
                            $clm_total = array('Total', 'esc_td', 'esc_td', 'esc_td', 'esc_td',  0.00);
                            $clm_total_format = array('N', 'N', 'N', 'N', 'N',  "$.$round_no");
                            $clm_tot_col_span = 1;
                            $report_total_clm_start = 0;
                        } elseif ($fields == 5) {
                            $clm_total = array('Total', 'esc_td', 'esc_td', 'esc_td', 0.00);
                            $clm_total_format = array('N', 'N', 'N', 'N', "$.$round_no");
                            $clm_tot_col_span = 1;
                            $report_total_clm_start = 0;
                        } else if ($fields == 4 && ($arrayR[3] == 'NULL' || $arrayR[3] == 'null' || $arrayR[3] == '')) {
                            $clm_total = array('Total', '', '',  0.00);
                            $clm_total_format = array('N', 'N', 'N', "$.$round_no");
                            $clm_tot_col_span = 1;
                            $report_total_clm_start = 0;
                        } else if ($fields == 4) {
                            $clm_total = array('Total', '', '', '', 0.00);
                            $clm_total_format = array('N', 'N', 'N', "$.$round_no");
                            $clm_tot_col_span = 1;
                            $report_total_clm_start = 0;
                        } else if ($fields == 3) {
                            $clm_total = array('Total', '', 0.00);
                            $clm_total_format = array('N', 'N', "$.$round_no");
                            $clm_tot_col_span = 0;
                            $report_total_clm_start = 2;
                        } else if ($fields == 7) {
                            $clm_total = array('Total', 'esc_td', 'esc_td', 'esc_td', 'esc_td',  'esc_td');
                            $clm_total_format = array('N', 'N', 'N', 'N', 'N','N',  "N");
                            $clm_tot_col_span = 1;
                            $report_total_clm_start = 0;
                        }
                    } else {
                        if ($arrayR[9] == "'d'") {
                            if ($arrayR[3] == 'NULL' || $arrayR[3] == 'null' || $arrayR[3] == '') {
                                $clm_total[0] = 'Total';
                                $clm_total[1] = 'esc_td';
                                $clm_total[2] = 'esc_td';
                                                                
                                $clm_total_format[0] = 'N';
                                $clm_total_format[1] = 'N';
                                $clm_total_format[2] = "N";
                                                                    
                                $clm_tot_col_span = 3;
                                $report_total_clm_start = 2;
            
                                //	Added for 5 Min / 10 Min Period column is added for 5/10 min granularity
                                if ($arrayR[4] == "'995'" || $arrayR[4] == "'994'") {
                                    $clm_total[1] = '';
                                    $clm_total[2] = '';
                                    $clm_total[3] = '';
                                    $clm_total_format[3] = 'N';
                                    $clm_tot_col_span = 0;
                                    $report_total_clm_start = 3;
                                }
            
                            } else {
                                $clm_total[0] = 'Total';
                                $clm_total[1] = 'esc_td';
                                $clm_total[2] = 'esc_td';
                                $clm_total[3] = 'esc_td';
                                
                                $clm_total_format[0] = 'N';
                                $clm_total_format[1] = 'N';
                                $clm_total_format[2] = 'N';
                                $clm_total_format[3] = 'N';
                            
                                $clm_tot_col_span = 4;
                                $report_total_clm_start = 4;
                            }
                        } else if ($arrayR[3] == 'NULL' || $arrayR[3] == 'null' || $arrayR[3] == '') {
                            if ($granularity_check == '980' || $fields == 4) {
                                $clm_total[0] = 'Total';
                                $clm_total[1] = 'esc_td';
                                $clm_total[2] = 'esc_td';
                
                                $clm_total_format[0] = 'N';
                                $clm_total_format[1] = 'N';
                                $clm_total_format[2] = "$.$round_no";
                            } else {
                                $clm_total[0] = 'Total';
                                $clm_total[1] = 'esc_td';
                                $clm_total[2] = 'esc_td';
                
                                $clm_total_format[0] = 'N';
                                $clm_total_format[1] = 'N';
                                $clm_total_format[2] = "$.$round_no";
                            }

                            if ($granularity_check == '980') {
                                $clm_total[3] = 'esc_td';
                                $clm_total_format[3] = 'N';

                                $clm_tot_col_span = 4;
                                $report_total_clm_start = 3;
                            } else {
                                $clm_tot_col_span =0;
                                $report_total_clm_start = 0;
                            }
                        } else {
                            $clm_total[0] = 'Total';
                            $clm_total[1] = 'esc_td';
                            $clm_total[2] = 'esc_td';

                            $clm_total_format[0] = 'N';
                            $clm_total_format[1] = 'N';
                            $clm_total_format[2] = 'N';

                            if ($granularity_check == 980) {
                                $clm_total[3] = 'esc_td';
                                $clm_total_format[3] = 'N';
                                
                                $clm_tot_col_span = 1;
                                $report_total_clm_start = 0;
                            } else {
                                $clm_tot_col_span = 3;
                                $report_total_clm_start = 2;
                            }
                        }
                            
                        for ($i = count($clm_total); $i <= $fields; $i++) {
                            $clm_total[$i] = 0.00;
                            $clm_total_format[$i] = "$.$round_no";
                        }
                    }
                }
            }
            /* end of code total */

            $result = array();
            $result = $recordset_object->recordsets();

            function encloseTD($string, $clm_sub_col_span) {
                global $writeCSV, $fields, $j, $sql, $report_name, $report_name1, $clm_tot_col_span, $clm_total_format;
                
                if ($writeCSV == true) {
                    $string = strip_tags($string, '<span><div><font><b><i><u>');
                    
                    if ($string == "<B><i>Sub-total</i></B>" && $string != '0') {
                        if ($clm_sub_col_span != 0) {
                            $clm_sub_col = "<td>$string</td>"; 
                            
                            for($i=0; $i<$clm_sub_col_span-1; $i++) {
                                $clm_sub_col =  $clm_sub_col . "<td></td>";
                            }

                            return $clm_sub_col;   
                        }
                    }
                }

                if ($string == "<B><i>Sub-total</i></B>" && $string != '0') {
                    if ($clm_sub_col_span != 0) {
                        return ("<td valign='middle' colspan=$clm_sub_col_span nowrap=nowrap><font face='arial'><b>$string</b></font></td>");
                    } else {
                        return ("<td valign='middle' nowrap=nowrap><font face='arial'><b>$string</b></font></td>");
                    }
                } elseif ($string == "<B>Total</B>") {
                    if ($clm_tot_col_span != 0) {
                            $ret_val = "<td valign='middle' nowrap=nowrap><font face='arial' ><b>$string</b></font></td>";
                            
                            if ($clm_tot_col_span >= 2) {
                                for ($i=0; $i < $clm_tot_col_span-1; $i++) { 
                                    $ret_val .= '<td></td>';
                                }
                            }
                            return $ret_val;
                    } else {
                        return ("<td valign='middle' nowrap=nowrap><font face='arial' ><b>$string</b></font></td>");
                    }
                } elseif ($string == "<B>esc_td</B>") {
                    return "";
                } elseif ($writeCSV == true) {
                    if (strpos($sql, "spa_Create_Inventory_Journal_Entry_Report") != false && $j == 0) {
                        $html_str = '<td height=30 bgcolor=#f8fbfe><font size=1 face=tahoma>="' . $string . '"</font></td>';
                    } elseif (strpos($sql, "spa_wind_pur_power_report") != false && $fields == 16 && $j == 2) {
                        $html_str = '<td height=30 bgcolor=#f8fbfe><font size=1 face=tahoma>="' . $string . '"</font></td>';
                    } elseif (strpos($sql, "spa_wind_pur_power_report") != false && $fields == 15 && $j == 0) {
                        $html_str = '<td height=30 bgcolor=#f8fbfe><font size=1 face=tahoma>="' . $string . '"</font></td>';
                    } elseif (strpos($sql, "spa_wind_pur_power_report") != false && $fields == 17 && $j == 3) {
                        $html_str = '<td height=30 bgcolor=#f8fbfe><font size=1 face=tahoma>="' . $string . '"</font></td>';
                    } elseif (strpos($sql, "spa_rec_generator_report") != false && $fields == 14 && $j == 6) {
                        $html_str = '<td height=30 bgcolor=#f8fbfe><font size=1 face=tahoma>="' . $string . '"</font></td>';
                    } elseif (strpos($sql, "spa_meter_data_report ") != false && $j == 0) {
                        $html_str = '<td height=30 bgcolor=#f8fbfe><font size=1 face=tahoma>="' . $string . '"</font></td>';
                    } else {
                        $html_str = "<td>" . strip_tags($string) . "</td>";
                    }

                    return ($html_str);
                } elseif ($report_name == "spa_counterparty_limits_report") {
                    $value = $string;
                    $pieces = explode("</A>", $string);

                    if (count($pieces) > 1) {
                        $pieces_1 = explode(">", $pieces[0]);
                        $font_start = $pieces_1[0] . ">";
                        $font_end = "</A>";
                        $value = $pieces_1[count($pieces_1) - 1];
                    }

                    if ($j == 1) {
                        return ("<td valign='middle' align='center'><font face='tahoma' >$string&nbsp;</font></td>");
                    }

                    if ($value == "0.00") {
                        if ($fields == 4) {
                            return ("<td valign='middle' nowrap=nowrap><font face='tahoma' >$string&nbsp;</font></td>");
                        } else {
                            return ("<td valign='middle' bgcolor='#FF0000'><font face='tahoma' >$string&nbsp;</font></td>");
                        }
                    } else {
                        return ("<td valign='middle'><font face='tahoma' >$string&nbsp;</font></td>");
                    }
                } else {
                    if ($j == 0 && $report_name1 == "spa_trader_Position_Report") { // Freeze the first column
                        return ("<td valign='middle' class='side' nowrap='nowrap'><font face='tahoma' >$string&nbsp;</font></td>");
                    } else {
                        return ("<td valign='middle'  nowrap='nowrap'><font face='tahoma'>$string&nbsp;</font></td>");
                    }
                }
            }

            function encloseTH($string) {
                global $show_header;

                if ($show_header == 'true') {
                    if ($string == 'Internal Rating') {
                        return "<th class='header'>" . get_locale_value($string, false) . "</th>";
                    } else if ($string == 'Product') {
                        return "<th class='side'>" . get_locale_value($string, false) . "</th>";
                    }  else {
                        return "<th class='header'>" . get_locale_value($string, false) . "</th>";
                    }
                } else {
                    return "<th class='header'>" . get_locale_value($string, false) . "</th>";
                }
            }

            /*
            * Formates the numerical value by rounding to fixed decimal value, and putting thousand separator (,)
            * eg. formats $.2 means number value will be rounded to 2 decimal places
            * $.X means number will be rounded to decimal places defined by $round_no.
            */
            function my_number_format($format_str, $value) {
                global $round_no;
                global $DECIMAL_SEPARATOR;
                global $GROUP_SEPARATOR;
                $group_separator = str_replace("\\","",$GROUP_SEPARATOR);
                $font_start = "";
                $font_end = "";

                if (strlen($value) == 0) {
                    return "";
                } else {
                    if ($format_str != "N" && $format_str != "X" && $format_str != '') {
                        if ($format_str == "L" && number_format($value) == 0) {
                            return "";
                        } else {
                            $decimals = 0;
                            $pieces = explode(".", $format_str);
                            
                            if (count($pieces) > 1) {
                                $decimals = ($pieces[1] == 'X' ? str_replace("'", "", $round_no) : $pieces[1]);
                            }

                            $pieces = explode("</font>", $value);
                            
                            if (count($pieces) > 1) {
                                $pieces_1 = explode(">", $pieces[0]);
                                $font_start = $pieces_1[0] . ">";
                                $font_end = "</font>";
                                $value = $pieces_1[1];
                            }
							
							if($decimals == '')
							{
							   $decimals = 0;	
							}

                           return $font_start . number_format(((float)$value), $decimals,$DECIMAL_SEPARATOR,$group_separator) . $font_end;
                        }
                    } else {
                        return $value;
                    }
                }
            }

            function number_format_str($format_str) {
                if ($format_str != "N" && (strrpos($format_str, "$") === false) && $format_str != "X") {
                    return $format_str;
                } else {
                    return "";
                }
            }

            function get_drilldown_phpref($phpRefPath, $clmType, $linkId, $termMonth, $arrayR) {
                $php_ref = "";

                if (strpos($phpRefPath, "drill_down_measurement_report.php") != false) {
                    if ($termMonth != "NULL"){
                        $termMonth = "'$termMonth'";
                    }

                    $sql_stmt = "EXEC spa_drill_down_msmt_report '$clmType', $arrayR[6], $arrayR[2], '$linkId', $arrayR[7], $termMonth";
                    $php_ref =  $sql_stmt;
                }

                return $php_ref;
            }

            function get_settlement_drilldown_phpref($clmType, $linkId, $linkType, $termMonth, $entityName, $arrayR) {
                if ($termMonth != "NULL") {
                    $termMonth = "'$termMonth'";
                }
                
                $sql_stmt = "EXEC spa_drill_down_settlement '$clmType', '" . $entityName . "', '$linkId', $arrayR[7], $termMonth, '" . trim($linkType) . "'," . strtoupper($arrayR[5]);
                $php_ref = "spa_html.php?spa=" . $sql_stmt;

                return $php_ref;
            }

            function get_rec_compliance_drilldown_phpref($drillType, $arrayR) {
                $sp_name = "";
                
                if ($drillType == 1) {
                    $sp_name = "spa_create_rec_compliance_sold_report";
                }
                
                if ($drillType == 2) {
                    $sp_name = "spa_create_rec_compliance_requirement_report";
                }
                
                if ($drillType == 3) {
                    $sp_name = "spa_create_rec_compliance_exclusivegen_report";
                }

                $sql_stmt = "EXEC $sp_name $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8]";
                $php_ref = "spa_html.php?spa=" . $sql_stmt;

                return $php_ref;
            }

            function get_notes_phpref($attachmentFileName) {
                global $documentPath, $attach_docs_url_path;

                if (isset($documentPath)) {
                    $file = $documentPath . $attachmentFileName;
                    $file_path = $attach_docs_url_path . '/' . $attachmentFileName;
                    $status = file_exists($file);
                    
                    if ($status == true) {
                        if (!copy($file, $file_path)) {
                            echo "failed to copy $file...\n";
                        }
                    } else {
                        $file_path = $attach_docs_url_path . '/' . $attachmentFileName;
                    }
                } else {
                    $file_path = $attach_docs_url_path . '/' . $attachmentFileName;
                }

                $php_ref = $file_path;

                return $php_ref;
            }

			// Applied Filter Display
            $applied_filters = $_REQUEST['applied_filters'] ?? '';
			$xml_user = "EXEC spa_get_resolve_dyn_date_value @flag=?, @applied_filters=?";
			$param_values = array('s', str_replace("'", "''", $applied_filters));
			$recordsets = readXMLURL2($xml_user, false, $param_values);

			$filters_new = '';
            if ($applied_filters != 'undefined' && $applied_filters != '') {
                $filters_new = "<div class='report_header_new '>";
    			$filters_new = $filters_new . "<img class='message_image' src='" . $image_path . "dhxtoolbar_web/plus.png' alt='plus' height='16' width='16'  onclick='message_expand_collapse()'/>";
                $filters_new = $filters_new .  $recordsets[0]['result'];
    			$filters_new = $filters_new . "</div>";
            }

            $fieldNames = array();
            $fieldNames = $recordset_object->clmNames;
            $html_str = " <html>";

            if ($writeCSV != true) {
                $html_str .= $spa_html_header . $filters_new;
                $html_str = $html_str . $html_str1;
                
                if (!isset($_POST['call_from']) || (isset($_POST['call_from']) && $_POST['call_from'] != 'mobile')) {  
                    $html_str .= "<td style='font-family: arial;'>" . $spa_html_paging . "</td></tr></table>";
                }
            }

            $height = '70%';

            if (strpos($sql, "spa_trader_Position_Report") != false) {
                $height = '70%';
            }

            //TODO: enable for scrollbars in inner frame
            $html_str .= "<div style='height:" . $height . ";width:98%; margin-left: 12px; overflow:auto;display:inline;' class='grid' id='gridTest'>";

            if ($show_header == 'true') {
                $html_str .= "
                    <table align='left' cellpadding='10' cellspacing='0'  width='100%' class='report_grid' id='report_grid' border='0'>
                        <tr valign='middle'>"; //class='header'
            } else {
                $html_str .= " 
                    <table align='left' cellpadding='10' cellspacing='0'  width='100%' class='report_grid' id='report_grid' border='0'>
                        <tr valign='middle'>";
            }

            if ($report_name == "spa_run_ghg_goal_tracking_report" && (in_array("ProcessID", $fieldNames))) {
                $maxVal = sizeof($fieldNames);
            } else {
                $maxVal = sizeof($fieldNames);
            }

            /*
            The following Transformation of Report Column Header and Creating a Sub Header Row.   // FROM FASTracker
            This applies to the SAP Journal Entry Report in RDE_DE.
            */
            $chk = explode(',',$sql);
            $is_sap_report = isset($_REQUEST['is_sap_report']) ? $_REQUEST["is_sap_report"] : 0;

            if ((strpos($sql, "spa_Create_MTM_Journal_Entry_Report_Reverse") != false) && $is_sap_report != 0) {
                $fieldNames = array('Belegpos','Buchungsschl?ssel','Konto','Auftrag','Zuordnung','Partner','Bewegungsart','Text','Betrag');
            }
            /* END Transformation */

            for ($i = 0; $i < $maxVal; $i++) {
                $data = encloseTH($fieldNames[$i]);
                
                if ($show_header == 'true') {
                    $html_str .= " $data ";
                } else {
                    $html_str .= "$data";
                }
            }

            $html_str .= "</tr>";

            /*
            The following Transformation of Report Column Header and Creating a Sub Header Row.
            This applies to the SAP Journal Entry Report in RDE_DE.

            Number = Belegpos,POSNR
            Posting Code = Buchungsschl�ssel, NEWBS
            Account = Konto,NEWKO
            Internal Order = Auftrag, AUFNR
            Assignment = Zuordnung, ZUONR
            Partner = Partner,VBUND
            Flow Code = Bewegungsart,BEWAR
            Text = Text,SGTXT
            Amount = Betrag,WRBTR
            */
            if ((strpos($sql, "spa_Create_MTM_Journal_Entry_Report_Reverse") != false) && $is_sap_report != 0) {
                $html_str .= "  <tr >
                        <th class='header'> POSNR </th>
                        <th class='header'> NEWBS </th>
                        <th class='header'> NEWKO </th>
                        <th class='header'> AUFNR </th>
                        <th class='header'> ZUONR </th>
                        <th class='header'> VBUND </th>
                        <th class='header'> BEWAR </th>
                        <th class='header'> SGTXT </th>
                        <th class='header'> WRBTR </th>
                    </tr>
                ";   
            } 
            /* End Column Transformation */

            $sub_total_str = "";
            $sub_total_pre_str = "";
            $noOfRows = sizeof($result) / $fields;

            //if no records found then no need to total report and drill-down features.
            if ($noOfRows == 0) {
                $report_name = "";
            }

            /* Modified for Paging */

            for ($i = 0; $i < $noOfRows; $i++) {
                $sub_total_str = "";

                if ($sub_total_clm >= 0) {

                    //build subtotal comparision string
                    for ($m = 0; $m <= $sub_total_clm; $m++) {
                        $sub_total_str = $sub_total_str . $result[($i * $fields) + $m];
                    }

                    if ($sub_total_pre_str != "" && $sub_total_str != $sub_total_pre_str) {
                        
                        //print the subtotal line and initilize sub total array
                        if ($show_header == 'false' && $sub_total_pre_str != $sub_total_str) {
                            if ($fields == 11) {
                                $html_str .= "
                                    <tr><td><td colspan=10><hr size='1'></td></tr> ";
                            } elseif ($fields == 10) {
                                $html_str .= "
                                    <tr><td><td colspan=9><hr size='1'></td></tr> ";
                            } else {
                                $html_str .= "
                                    <tr><td><td colspan=8><hr size='1'></td></tr> ";
                            }
                        }

                        $html_str .= "
                            <tr class='subtotal' valign='center' height='10'>";

                        for ($j = 0; $j < $fields; $j++) {
                            if ($newFormat) {
                                $linkRef = $reportInstance->getSubTotalDrillDownRef($result, $arrayR, $fields, $i, $j, $tmpIndex);
                                
                                if ($linkRef != null) {
                                    $linkRef .= "&rnd=" . $round_no;
                                    $dispData = '<B>' . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . '</B>';
                                    $dataString = '<a target="_blank" href="' . $linkRef . '">' . $dispData . '</a>';
                                    $data = encloseTD($dataString, $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = "<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . "</B>";
                                    $data = encloseTD("<B>" . $data . "</B>", $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } else {
                                if ($j > $report_total_clm_start) {
                                    $data = "<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . "</B>";
                                    
                                    if ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 20 && ($j == 17 || $j == 15 || $j == 16)) {
                                        $last_row_index = ($i - 1) * $fields;
                                        
                                        if ($j == 15) { //AOCI
                                            $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "AOCI", $result[$last_row_index + 4], "NULL", $arrayR);
                                        }

                                        if ($j == 16) { //PNL
                                            $result[$last_row_index + 5];
                                            
                                            if (trim($result[$last_row_index + 5]) == "D") { //D for 'Deal' , L for 'Designation'
                                                $tmp_clmType = "LINK";
                                                $tmp_linkId = $result[$last_row_index + 4] . "-D";
                                            } else {
                                                $tmp_clmType = "PNL";
                                                $tmp_linkId = $result[$last_row_index + 4];
                                            }

                                            $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "$tmp_clmType", $tmp_linkId, "NULL", $arrayR);
                                        }

                                        if ($j == 17) { //Settlement
                                            $php_ref = get_settlement_drilldown_phpref("Settlement", $result[$last_row_index + 4], $result[$last_row_index + 5], "NULL", $result[$last_row_index], $arrayR);
                                        }
                
                                        $php_ref = str_replace("'", "^", $php_ref);    
                                        $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . $data . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } elseif ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 21 && ($j == 18 || $j == 19)) {
                                        $last_row_index = ($i - 1) * $fields;
                                        if ($j == 18) //PNL
                                            {
                                            $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "PNL", $result[$last_row_index + 3], "NULL", $arrayR);
                                        }
                                        if ($j == 19) //Settlement
                                            {
                                            $php_ref = get_settlement_drilldown_phpref("Settlement", $result[$last_row_index + 3], $result[$last_row_index + 4], "NULL", $result[$last_row_index], $arrayR);
                                        }
                
                                        $php_ref = str_replace("'", "^", $php_ref);
                                        $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . $data . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } elseif ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 20) {
                                        if ($j == 4 && $fields == 20) {
                                            if (is_numeric($result[$tmpIndex])) {
                                                $drill_dealid = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                                $php_ref = "EXEC spa_Create_Hedges_Measurement_Report $arrayR[2], $arrayR[3], $arrayR[4],                                       $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8],'m', $drill_dealid, $arrayR[11], $arrayR[12], $arrayR[13],$arrayR[14],$arrayR[15]";
                                                $php_ref = str_replace("'", "^", $php_ref);
                                                $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                            } else {
                                                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                            }
                                        } else
                                        
                                        $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
                                    } elseif ($report_name == "spa_Create_Hedges_Measurement_Report_NoHyperLink" && $fields == 19) {
                                        if ($j == 3 && $fields == 19) {
                                            if (is_numeric($result[$tmpIndex])) {
                                                $drill_dealid = "'" . $result[($tmpIndex - $j + 3)] . "'";
                
                                                $php_ref = "EXEC spa_Create_Hedges_Measurement_Report $arrayR[2], $arrayR[3], $arrayR[4],                                       $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], 'm', $drill_dealid, $arrayR[11], $arrayR[12], $arrayR[13],$arrayR[14],$arrayR[15]";
                                                $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                            } else {
                                                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                
                                            }
                                        } else {
                                            $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
                                        }
                                    } else {
                                        $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } else {
                                    $data = encloseTD("<B>" . $clm_sub_total[$j] . "</B>", $clm_sub_col_span, $clm_tot_col_span);
                                }
                            }

                            $html_str .= $data;
                        }

                        $html_str .= "</tr>";
                        
                        if ($show_header == 'false') {
                            if ($fields == 11) {
                                $html_str .= "
                                    <tr><td><td colspan=10><hr size='1'></td></tr> ";
                            } elseif ($fields == 10) {
                                $html_str .= "
                                    <tr><td><td colspan=9><hr size='1'></td></tr> ";
                            } else {
                                $html_str .= "
                                    <tr><td><td colspan=8><hr size='1'></td></tr> ";
                            }
                        }
                        
                        for ($k = $report_total_clm_start + 1; $k < $fields; $k++) {
                            $clm_sub_total[$k] = 0.00;
                        }
                        
                        $sub_total_pre_str = "";
                    }
                }
                $html_str .= "<tr valign='center' onmouseover=\"this.style.backgroundColor='#CCCCCC';\" onmouseout=\"this.style.backgroundColor='#F8FBFE';\">";
                
                for ($j = 0; $j < $fields; $j++) {
                    $tmpIndex = ($i * $fields) + $j;

                    if ($no_sum_report_name == "spa_Get_All_Notes" && $j == 3) {
                        if ($result[$tmpIndex] != "") {
                            $php_ref = get_notes_phpref($result[$tmpIndex - $j + 3]);
                            $result[$tmpIndex] = "<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . "<IMG SRC=\"../adiha_pm_html/process_controls/doc.jpg\">" . $result[$tmpIndex] . "</A>";
                        }
                    }

                    if ($newFormat) {
                        $linkRef = $reportInstance->getDrillDownRef($result, $arrayR, $fields, $i, $j, $tmpIndex, $fieldNames);
                        
                        if ($linkRef != null) {
                            $linkRef .= "&rnd=" . $round_no;
                            $dispData = my_number_format($clm_total_format[$j], $result[$tmpIndex]);
                            $dataString = '<a target="_blank" href="' . $linkRef . '">' . $dispData . '</a>';
                            $data = encloseTD($dataString, $clm_sub_col_span, $clm_tot_col_span);
                        } else {
                            $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                        }
                    } else {
                        if ($report_name != "" && $j > $report_total_clm_start) {

                            // imbalance report
                            if ($report_name == "spa_create_imbalance_report" && $arrayR[2] == "'s'" && $j == 4) {
                                if ($j == 4) {
                                    $location = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $pieces = explode("<l>", str_replace("</l>", "<l>", "'" . $result[($tmpIndex - $j + 2)] . "'"));

                                    if (count($pieces) > 1) {
                                        $meter = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                    } else {
                                        $meter = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    }
                                    
                                    $php_ref = "./spa_html.php?spa=EXEC spa_create_imbalance_report 'd', $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7],$arrayR[8],$arrayR[9],$arrayR[10],$arrayR[11],$arrayR[12],$location,$meter,NULL";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                }
                                
                            } else if ($report_name == "spa_run_settlement_invoice_report" && ($arrayR[2]=="'c'" || $arrayR[2]=="'d'") && $j==9){
                                $as_of_date = "'" . getStdDateFormat($result[($tmpIndex-$j)]) . "'";
                                
                                if($arrayR[2] == "'c'"){
                                    $prod_month = "'" . getStdDateFormat($result[($tmpIndex-$j)+1]) . "'";
                                    $counterparty = "'" . $result[($tmpIndex-$j)+3] . "'";
                                    $contract = "'" . $result[($tmpIndex-$j)+4] . "'";
                                    $invoice_type = "'" . $result[($tmpIndex-$j)+5] . "'";
                                    $settlement_date = "'" . ($result[($tmpIndex-$j)+2] == "")?"NULL":getStdDateFormat($result[($tmpIndex-$j)+2]) . "'";
                                } else {
                                    if (($result[($tmpIndex-$j)+4] <> '') && ($result[($tmpIndex-$j)+4] <> 'NULL')) {
                                        $prod_month = "'" . getStdDateFormat($result[($tmpIndex-$j)+4]) . "'";
                                    } else {
                                        $prod_month = 'NULL';
                                    }

                                    $counterparty = "'" . $result[($tmpIndex-$j)+1] . "'";
                                    $contract = "'" . $result[($tmpIndex-$j)+2] . "'";
                                    $invoice_type = "'" . $result[($tmpIndex-$j)+3] . "'";
                                    $settlement_date = "'" . "'" . ($result[($tmpIndex-$j)+5] == "")?"NULL":getStdDateFormat($result[($tmpIndex-$j)+5]) . "'";
                                }
                        
                                $line_item = "'" . $result[($tmpIndex-$j)+6] . "'";
                            
                                $php_ref = "./spa_html.php?spa= EXEC spa_gen_invoice_variance_report NULL, $prod_month, NULL, " . $line_item . ",'h',$as_of_date,'','',$arrayR[15],NULL,NULL,$counterparty,$contract, NULL,NULL,$invoice_type, $settlement_date,NULL, NULL" . "&rnd=" . $round_no . "&call_from=" . $call_from;
                                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                            } else if ($report_name == "spa_run_pnl_report" && $arrayR[2] == "'s'" && $j == 2) {
                                if ($j == 2) {
                                    $counterparty = "'" . $result[($tmpIndex - $j)] . "'";
                                    $term = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_run_pnl_report 'd', $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $counterparty, $term";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);

                                }
                            }
                    
                            //schedule and delivery
                            else if ($report_name == "spa_deal_schedule_report" && $fields == 9  && $arrayR[2] == "'t'" && $j == 6) {
                                //$phy_deal_id = $_GET['phy_deal_id'];
                                $term_start = "'" . $result[($tmpIndex-$j) + 1] . "'";
                                $term_end = "'" . $result[($tmpIndex-$j) + 2] . "'";
                                $php_ref = "./spa_html.php?spa=EXEC spa_deal_schedule_report 'd', $arrayR[3], $term_start, $term_end";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            }

                            //Added by Shushil Bohara for drill of At Risk Report 
                            else if ($report_name == "spa_get_var_report" && $fields == 9 && $arrayR[2] == "'v'" && $j == 7) {
                                $as_of_date = getStdDateFormat($result[($tmpIndex - $j)]);
                                $breakdown_value = $result[($tmpIndex - $j) + 2];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $counterparty = $result[($tmpIndex - $j) + 1];
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?var_criteria_id=$criteria_id&as_of_date=$as_of_date&counterparty=$counterparty";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } else if ($report_name == "spa_get_var_report" && $fields == 8 && $arrayR[2] == "'g'" && $j == 6) {
                                $as_of_date = getStdDateFormat($result[($tmpIndex - $j)+1]);
                                $breakdown_value = $result[($tmpIndex - $j) + 0];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?var_criteria_id=$criteria_id&as_of_date=$as_of_date&counterparty=$counterparty";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } else if ($report_name == "spa_get_var_report" && $fields == 9 && $arrayR[2] == "r" && $j == 7) {
                                $as_of_date = getStdDateFormat($result[($tmpIndex - $j)]);
                                $breakdown_value = $result[($tmpIndex - $j) + 2];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $counterparty = $result[($tmpIndex - $j) + 1];
                                $php_ref = "../../../../trm/adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?var_criteria_id=$criteria_id&as_of_date=$as_of_date&counterparty=$counterparty";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } else if ($report_name == "spa_get_var_report" && $fields == 8 && $j == 4 && $arrayR[3] == "'m'" && $arrayR[2] != "'g'") {
                                $as_of_date = getStdDateFormat($result[($tmpIndex - $j)]);
                                $breakdown_value = $result[($tmpIndex - $j) + 1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?var_criteria_id=$criteria_id&as_of_date=$as_of_date";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == "spa_get_var_report" && $fields == 8 && $j == 4 && $arrayR[3] == "null" && $arrayR[2] != "'g'"){
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $as_of_date = getStdDateFormat($result[($tmpIndex-$j)]);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?var_criteria_id=$criteria_id&as_of_date=$as_of_date";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } else if ($report_name == "spa_get_var_report" && $fields == 13 && $j == 4) {
                                $breakdown_value = $result[($tmpIndex - $j) + 1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $as_of_date = getStdDateFormat($result[($tmpIndex - $j)]);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?var_criteria_id=$criteria_id&as_of_date=$as_of_date";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            }

                            //New code added for MTM drill down report in WhatIF        
                            else if  ($report_name == "spa_run_whatif_scenario_report" && $arrayR[3] == "'m'" && $fields == 14 && $j == 4){ //mtm drill
                                $breakdown_value = $result[($tmpIndex - $j) + 1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $php_ref = "./spa_html.php?spa=EXEC spa_run_whatif_scenario_report $arrayR[2], 'd', $criteria_id, 'y'";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } else if ($report_name == "spa_run_whatif_scenario_report" && $arrayR[3] == "'m'" && $fields == 14 && $j == 3){ //position drill
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $build_exec_code[$tmpIndex] = urldecode("EXEC spa_create_hourly_position_report 'm', NULL, NULL, NULL, NULL, $arrayR[2], NULL, NULL, 982, 'i', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4, NULL, NULL, 'b', 'f', NULL, 'c', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', $criteria_id,NULL");
                                $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);            
                            } else if ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "'m'" && $fields == 14 && $j == 6) { //cashflow drill
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $php_ref = "./spa_html.php?spa=EXEC spa_run_whatif_scenario_report $arrayR[2], 'c', $criteria_id, 'y'";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "'m'" && $fields == 14 && $j == 7) { //Cfar drill plot
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $as_of_date = getStdDateFormat($result[($tmpIndex-$j)]);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?measure=17352&call_from=whatif&var_criteria_id=$criteria_id&as_of_date=$as_of_date";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "'m'" && $fields == 14 && $j == 10) { // pfe drill
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $php_ref = "./spa_html.php?spa=EXEC spa_run_whatif_scenario_report $arrayR[2], 'p', $criteria_id, 'y'";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "'m'" && $fields == 14 && $j == 8) { //earnings drill
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $php_ref = "./spa_html.php?spa=EXEC spa_run_whatif_scenario_report $arrayR[2], 'e', $criteria_id, 'y'";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "'m'" && $fields == 14 && $j == 9) { //Ear drill plot
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $as_of_date = getStdDateFormat($result[($tmpIndex-$j)]);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?measure=17353&call_from=whatif&var_criteria_id=$criteria_id&as_of_date=$as_of_date";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "'p'" && $fields == 9 && $j == 7) { //pfe plot
                                $counterparty = $result[($tmpIndex-$j)+1];
                                $breakdown_value = $result[($tmpIndex-$j)+2];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $as_of_date = getStdDateFormat($result[($tmpIndex-$j)]);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?measure=17355&call_from=whatif&var_criteria_id=$criteria_id&as_of_date=$as_of_date&counterparty=$counterparty";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "p" && $fields == 9 && $j == 7) { //pfe plot
                                $counterparty = $result[($tmpIndex-$j)+1];
                                $breakdown_value = $result[($tmpIndex-$j)+2];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $as_of_date = getStdDateFormat($result[($tmpIndex-$j)]);
                                //echo "Test"; die();
                                $php_ref = "../../../../trm/adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?measure=17355&call_from=whatif&var_criteria_id=$criteria_id&as_of_date=$as_of_date&counterparty=$counterparty";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "'m'" && $fields == 14 && $j == 5) { //var drill plot
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $as_of_date = getStdDateFormat($result[($tmpIndex-$j)]);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?measure=17351&call_from=whatif&var_criteria_id=$criteria_id&as_of_date=$as_of_date";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } else if  ($report_name == 'spa_run_whatif_scenario_report' && $arrayR[3] == "'m'" && $fields == 14 && $j == 12) { //var drill plot
                                $breakdown_value = $result[($tmpIndex-$j)+1];
                                $criteria_id = capture_criteria_id_with_breakdown($breakdown_value);
                                $as_of_date = getStdDateFormat($result[($tmpIndex-$j)]);
                                $php_ref = "../../adiha.html.forms/_valuation_risk_analysis/showPlot/showPlot.php?measure=17357&call_from=whatif&var_criteria_id=$criteria_id&as_of_date=$as_of_date";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>",$clm_sub_col_span,$clm_tot_col_span);
                            } elseif ($report_name == "spa_run_cashflow_earnings_report") {
                                if ($j == 3 && $fields == 5) {
                                    $drill_model_name = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j + 0)] . "'"));
                                    if (count($pieces) > 1) {
                                        $drill_model_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                    }
                                    $drill_exp_date = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_run_cashflow_earnings_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], 'f', $arrayR[7], $arrayR[8], $arrayR[9],  $arrayR[10], $arrayR[11], $arrayR[12],$arrayR[13], $arrayR[14], $arrayR[15],  $arrayR[16], $arrayR[17], $arrayR[18],$arrayR[19], $arrayR[20], $arrayR[21],  $arrayR[22], $arrayR[23], $arrayR[24],$arrayR[25], $arrayR[26],$arrayR[27], $arrayR[28], $arrayR[29],  $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], null, NULL, NULL, NULL, NULL, NULL, NULL, $drill_exp_date, $drill_model_name, null, null";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 10 && $fields == 11) {
                                    $drill_sub = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_strategy = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_book = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_counterparty = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_dealdate = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_exp_date = "'" . $result[($tmpIndex - $j + 9)] . "'";

                                    $php_ref = "./spa_html.php?spa=EXEC spa_run_cashflow_earnings_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], 'f', $arrayR[7], $arrayR[8], $arrayR[9],  $arrayR[10], $arrayR[11], $arrayR[12],$arrayR[13], $arrayR[14], $arrayR[15],  $arrayR[16], $arrayR[17], $arrayR[18],$arrayR[19], $arrayR[20], $arrayR[21],  $arrayR[22], $arrayR[23], $arrayR[24],$arrayR[25], $arrayR[26],$arrayR[27], $arrayR[28], $arrayR[29],  $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], null, $drill_sub, $drill_strategy, $drill_book, $drill_counterparty, NULL, $drill_dealdate, $drill_exp_date, null, null, null";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                }
                                else
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_Create_fas157_Disclosure_Report" && ($j > 1)) {
                                $desc = "'" . urlencode($result[($tmpIndex - $j)]) . "'";
                                $index = $j + 1;
                                $php_ref = "spa_html.php?spa=EXEC spa_Create_fas157_Disclosure_Report  $arrayR[2], $arrayR[3], $arrayR[4],$arrayR[5],$arrayR[6],$arrayR[7],$arrayR[8],$arrayR[9],2,$index,$desc";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_power_position_report" && ($fields == 5 && $j == 3)) {
                                if ($j == 3) {
                                    $index = "'" . $result[($tmpIndex - $j)] . "'";
                                    $term = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $hour = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                }

                                $php_ref = "spa_html.php?spa=EXEC spa_create_power_position_report 'd', $arrayR[3], $arrayR[4], $arrayR[5],  $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11],$arrayR[12],$arrayR[13],$arrayR[14],$arrayR[15],$arrayR[16],$arrayR[17],$arrayR[18],$arrayR[19],$arrayR[20],$arrayR[21],$arrayR[22],$arrayR[23],$arrayR[24],$arrayR[25],NULL,$index,$term,$hour";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_hourly_position_report" && ($fields == 28 && ($j > 2 && $j < 27))) {
                                $index = "'" . $result[($tmpIndex - $j)] . "'";
                                $term = "'" . getStdDateFormat($result[($tmpIndex - $j + 2)]) . "'";
                                $uom = "'" . $result[($tmpIndex - $j + 27)] . "'";
                                $physical_financial = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                
                                if (trim($physical_financial, "'") == 'Financial')
                                    $physical_financial = 'f';
                                elseif (trim($physical_financial, "'") == 'Physical')
                                    $physical_financial = 'p';

                                //  echo 'aa' + $arrayR[28] + 'bb';
                                $arrayR[28] = $arrayR[28] == 'null' ? 'c' : $arrayR[28];
                                
                                if ($arrayR[45] == "") {
                                    $arrayR[45] = "NULL";
                                }
                                //$php_ref = "./spa_html.php?spa=EXEC spa_create_hourly_position_report 'l', $arrayR[3], $arrayR[4], $arrayR[5],  $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $physical_financial, $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $index, $term, $arrayR[2], '$fieldNames[$j]', $uom, NULL, $arrayR[43], $arrayR[44],  $arrayR[45],  $arrayR[46],  $arrayR[47],  $arrayR[48]";
                                $build_exec_code[$tmpIndex] = urldecode("EXEC spa_create_hourly_position_report 'l', $arrayR[3], $arrayR[4], $arrayR[5],  $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $physical_financial, $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $index, $term, $arrayR[2], '$fieldNames[$j]', $uom, NULL, $arrayR[43], $arrayR[44],  $arrayR[45],  $arrayR[46],  $arrayR[47],  $arrayR[48]");
                                $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_roll_forward_inventory_report" && ($fields == 14 && $j == 11)) {
                                $as_of_date = "'" . getStdDateFormat($result[($tmpIndex - $j)]) . "'";
                                $group_name = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                $inventory_name = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                $term_date = ($result[($tmpIndex - $j + 3)] == '') ? "NULL" : "'" . getStdDateFormat($result[($tmpIndex - $j + 3)]) . "'";
                                $php_ref = "./spa_html.php?spa=EXEC spa_create_roll_forward_inventory_report 'd', $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $as_of_date, $group_name, $inventory_name, NULL, $term_date";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_get_counterparty_credit_report" && ($fields == 12) && ($j == 5)) {
                                if ($j == 5) {
                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", $counterparty_name));

                                    if (count($pieces) > 1) {
                                        $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                    } else {
                                        $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                    }
                                }

                                $php_ref = "./spa_html.php?spa=EXEC spa_get_counterparty_credit_report 'r', $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $counterparty_name";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_get_counterparty_credit_report" && ($fields == 4) && ($j == 3)) {
                                if ($fields == 4) {
                                    $item = "'" . urlencode($result[($tmpIndex - $j)]) . "'";
                                }

                                if ($j == 3) {
                                    $flag = 'v';
                                } else {
                                    $flag = 'NULL';
                                }
                                
                                if ($j == 3) {
                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_market_variance_report NULL, NULL, NULL, NULL, NULL, NULL, 'b', $arrayR[4], 'h', 0.01, $item";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "spa_get_counterparty_exposure_report" 
                                && (($fields == 5 && $arrayR[3] == "'s'" && $arrayR[2] != "'r'" 
                                        && $arrayR[2] != "'a'" && ($j == 1)) || ($fields == 10 
                                        && ($j == 4 || $j == 5 || $j == 6)) || ($fields == 9 
                                        && ($j == 1 || $j == 2)) || ($fields == 5 && ($arrayR[23] == "'s'" 
                                        && $arrayR[3] == "'s'" && $arrayR[2] == "'r'") 
                                        && ($j == 1 || $j == 2)
                                    ) 
                                    || ($fields == 8 && ($arrayR[23] == "'c'" && $arrayR[3] == "'s'" && $arrayR[2] == "'r'") && ($j == 1)) 
                                    || ($fields == 6 && ($arrayR[23] == "'u'" && $arrayR[3] == "'s'" && $arrayR[2] == "'r'") && ($j == 1)) 
                                    || ($fields == 4 && ($j == 1) && $arrayR[2] != "'a'") || ($fields == 3 && ($j == 1 || $j == 2)) 
                                    || ($fields == 6 && $arrayR[3] == "'s'" && $arrayR[23] == "'s'" && ($j == 1 || $j == 2)) 
                                    || ($fields == 6 && $arrayR[2] == "'f'" && $arrayR[3] == "'s'" && $arrayR[23] == "'s'" && ($j == 1 || $j == 2 || $j == 3))
                                    || ($fields == 5 && $arrayR[2] == "'f'" && $arrayR[3] == "'s'" && ($j == 1 || $j == 2)) 
                                    || ($fields == 6 && ($arrayR[2] == "'f'" && ($arrayR[3] == "'f'" || $arrayR[3] == "'s'")) && ($j == 1))
                                    || ($fields == 6 && $arrayR[3] == "'m'" && $arrayR[23] == "'s'" && $j == 1)
                                )
                            ) {
                                $counterparty_name = "";
                                $drill_term = "";
                                $report_type = "";

                                if ($j == 4) {
                                    if ($arrayR[2] == "'e'") {
                                        $report_type = "'c'";
                                        if ($arrayR[4] != "'e'" && $arrayR[4] != "'r'" && $arrayR[4] != "'s'" && $arrayR[4] != "'t'" && $arrayR[4] != "'i'" && $arrayR[4] != "'d'") {
                                            $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                            $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                        } else {
                                            $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                        }
                                
                                        $drill_term = "NULL";
                                    }
                                } elseif ($j == 3) {
                                    if ($arrayR[2] == "'f'") {
                                        $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                        $drill_term = "NULL";
                                        $report_type = "'m'";
                                        
                                        if ($arrayR[23] == "'s'" && $arrayR[3] == "'s'") {
                                            if ($arrayR[4] == "'p'" || $arrayR[4] == "'c'" || $arrayR[4] == "'b'") {
                                                $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                            }
                                        }
                                    }
                                } elseif (($j == 5) || ($j == 6)) {
                                    if ($j == 5) {
                                        switch ($j) {
                                            case 5:
                                                $report_type = "'d'";
                                                break;
                                            default:
                                                $report_type = "'n'";
                                                break;
                                        }
                                    }
                                        
                                    $report_type = "'d'";
                                    $drill_term = "NULL";
                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";

                                    if ($arrayR[2] == "'e'") /* Credit Exposure Report */ {
                                        if (($arrayR[4] == "'c'") || ($arrayR[4] == "'p'")) {
                                            $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                            $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                        }
                                    } else {
                                        if ($arrayR[4] != "'e'" && $arrayR[4] != "'r'" && $arrayR[4] != "'s'" && $arrayR[4] != "'t'" && $arrayR[4] != "'i'" && $arrayR[4] != "'d'") {
                                            $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                            $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                        }
                                    }
                                } elseif ($j == 1) {
                                    if ($arrayR[2] == "'e'") {
                                        if (($arrayR[23] != "'s'") && ($arrayR[3] == "'s'")) {
                                            
                                            /* When Tenor option : Contract OR Cumulative Month , do the following */
                                            $report_type = "'k'";
                                        
                                            if (($arrayR[4] == "'p'") || ($arrayR[4] == "'c'") || ($arrayR[4] == "'b'")) {
                                                $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                            } else {
                                                $counterparty_name = "'" . $result[($tmpIndex - 1)] . "'";
                                            }
                                            $drill_term = "'" . $result[($tmpIndex)] . "'";
                                        } else {
                                            /* When Tenor option : Summary, do the following */
                                            if (($arrayR[4] == "'c'") || ($arrayR[4] == "'p'")) { //Group by : Individual Counterparty OR Parent Counterparty
                                                $report_type = "'k'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                
                                                if ($arrayR[3] == "'d'" || $arrayR[3] == "'n'")
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                else {
                                                    $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                    $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                                }
                                            } elseif ($arrayR[4] == "'b'") { //Group by : Exposure for them
                                                if ($arrayR[3] == "'s'") { //HTML Button Report
                                                    /* if its HTML Button Report and Group by :'Exposure for them', pass the parameter as 'c' for the drill down of Limit.
                                                    Note : when $arrayR[3] ='s', its a HTML Button Report on the click of the HTML button */
                                                    $report_type = "'c'";
                                                    $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                    $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                                    $drill_term = "NULL";
                                                } else {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                }
                                            } else {
                                                //For all the group By except 'Parent Counterparty','Individual Counterparty' and 'Exposure for them'
                                                if ($arrayR[3] == "'s'") { //HTML Button Report
                                                    $report_type = "'d'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - 1)] . "'";
                                                    $drill_term = "NULL";
                                                } else {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - 1)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                }
                                            }
                                        } //if($arrayR[3]=="'s'" /*Report Type : Summary */)
                                    } elseif ($arrayR[2] == "'f'") {
                                        if ($arrayR[4] == "'c'") {
                                            if ($arrayR[3] == "'s'") {
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                } elseif ($arrayR[23] == "'s'") {
                                                    $report_type = "'c'"; //rrr
                                                    $drill_term = "NULL";
                                                    
                                                    if ($arrayR[4] == "'p'" || $arrayR[4] == "'c'" || $arrayR[4] == "'b'") {
                                                        $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                        $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                                    }
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'m'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            }
                                        }
                                        
                                        if ($arrayR[4] == "'b'") {
                                            if ($arrayR[3] == "'s'") {
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                } else {
                                                    $report_type = "'c'";
                                                    $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                    $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                                    $drill_term = "NULL";
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'m'") {

                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            }
                                        } elseif ($arrayR[4] == "'e'") {
                                            if ($arrayR[3] == "'s'") {
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                } else {
                                                    $report_type = "'f'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "NULL";
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'m'") {

                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            }
                                        } elseif ($arrayR[4] == "'r'") {
                                            if ($arrayR[3] == "'s'") {
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                } else {
                                                    $report_type = "'f'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "NULL";
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'m'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            }
                                        } elseif ($arrayR[4] == "'d'") {
                                            if ($arrayR[3] == "'s'") {
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                } else {
                                                    $report_type = "'f'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "NULL";
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'m'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            }
                                        } elseif ($arrayR[4] == "'p'") {
                                            if ($arrayR[3] == "'s'") {
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                } else {
                                                    $report_type = "'c'";
                                                    $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                    $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                                    $drill_term = "NULL";
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'m'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            }
                                        } elseif ($arrayR[4] == "'i'") {
                                            if ($arrayR[3] == "'s'") {
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                } else {
                                                    $report_type = "'f'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "NULL";
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'m'") {

                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            }
                                        } elseif ($arrayR[4] == "'t'") {
                                            if ($arrayR[3] == "'s'") {
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                } else {
                                                    $report_type = "'f'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "NULL";
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'m'") {

                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            }
                                        } elseif ($arrayR[4] == "'s'") {
                                            if ($arrayR[3] == "'s'") {
                                                if ($arrayR[23] == "'c'" || $arrayR[23] == "'u'") {
                                                    $report_type = "'k'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                } else {
                                                    $report_type = "'f'";
                                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                    $drill_term = "NULL";
                                                }
                                            } elseif ($arrayR[3] == "'f'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } else {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "NULL";
                                            }
                                        }
                                    } elseif ($arrayR[2] == "'c'") { //Concentration Report
                                        if ($arrayR[4] == "'e'" || $arrayR[4] == "'i'" || $arrayR[4] == "'t'" || $arrayR[4] == "'s'" || $arrayR[4] == "'d'" || $arrayR[4] == "'r'") {
                                            if ($arrayR[3] == "'d'") {
                                                $report_type = "'k'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "'" . $result[($tmpIndex)] . "'";
                                            } elseif ($arrayR[3] == "'s'") {
                                                $drill_term = "NULL";
                                                
                                                if ($arrayR[23] == "'s'")
                                                    $report_type = "'d'";
                                                else {
                                                    $report_type = "'k'";
                                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                                }
                                                
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                            } else {
                                                $report_type = "'c'";
                                                $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                                $drill_term = "NULL";
                                            }
                                        } elseif ($arrayR[4] == "'c'" || $arrayR[4] == "'p'" || $arrayR[4] == "'b'") {
                                            $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                            $drill_term = "'" . $result[($tmpIndex)] . "'";

                                            switch ($arrayR[3]) {
                                                case "'d'":
                                                    $report_type = "'k'";
                                                    break; // Detail
                                                case "'s'":
                                                    $report_type = "'k'";
                                                    break; // Summary
                                                default:
                                                    break;
                                            }

                                            if (($arrayR[3] == "'s'") && ($arrayR[23] == "'s'")) {
                                                $report_type = "'c'";
                                                $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                                $drill_term = "NULL";
                                            }
                                        } else {
                                            if ($arrayR[3] == "'s'") {
                                                $report_type = "'d'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "NULL";
                                            } else {
                                                $report_type = "'c'";
                                                $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                                $drill_term = "NULL";
                                            }
                                        }
                                    } elseif ($arrayR[2] == "'r'") { //reserve : Hyper link Col - 1
                                        $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";

                                        if (($arrayR[4] == "'p'" || $arrayR[4] == "'c'" || $arrayR[4] == "'b'")) {
                                            if ($arrayR[3] == "'s'") {
                                                $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                            }
                                        }

                                        if (($arrayR[3] == "'d'" || $arrayR[3] == "'n'") || ($arrayR[23] <> "'s'")) {
                                            $report_type = "'k'";
                                            $drill_term = "'" . $result[($tmpIndex)] . "'";
                                        } elseif (($arrayR[3] == "'s'")) {
                                            $report_type = "'d'";
                                            $drill_term = "NULL";
                                        }
                                    }
                                } elseif ($j == 2) {
                                    if ($arrayR[2] == "'e'") {
                                        if ($arrayR[3] == "'s'") {
                                            
                                            /* if its HTML Button Report pass the parameter as 'n' */
                                            $report_type = "'n'";
                                            $drill_term = "NULL";
                                            $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                            
                                            if ($arrayR[4] == "'b'") {

                                                /* When Group By Option is 'Exposure For Them */
                                                $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                            }
                                        }
                                    } elseif ($arrayR[2] == "'f'") {
                                        $report_type = "'f'";
                                        $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                        $drill_term = "NULL";

                                        if ($arrayR[23] == "'s'") { //if tenor option is 'Summary'
                                            if (($arrayR[4] == "'c'") || ($arrayR[4] == "'p'") || ($arrayR[4] == "'b'")) {
                                                //For Summary the group by as : Counterparty,Parent Counterparty and Exposure for them.
                                                $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                            } else {
                                                $report_type = "'m'";
                                            }
                                        }
                                    } elseif ($arrayR[2] == "'c'") {
                                        if ($arrayR[4] != "'e'" && $arrayR[4] != "'i'" && $arrayR[4] != "'t'" && $arrayR[4] != "'s'" && $arrayR[4] != "'d'" && $arrayR[4] != "'r'") {
                                            $report_type = "'d'";
                                            $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                            $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                            $drill_term = "NULL";
                                        } else {
                                            $report_type = "'d'";
                                            $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                            $drill_term = "NULL";
                                        }
                                    } elseif ($arrayR[2] == "'r'") { //reserve : Hyper link Col - 2
                                        $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";
                                        $report_type = "'n'";
                                        $drill_term = "NULL"; //nnn j==2
                                        
                                        if ($arrayR[3] == "'s'") {
                                            if ($arrayR[4] == "'p'" || $arrayR[4] == "'c'" || $arrayR[4] == "'b'") {
                                                $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                                $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                            }
                                        }
                                    }
                                }

                                if ($report_type == "" && ($arrayR[2] == "'a'")) {
                                    $report_type = 'd';
                                    $report_option = "'e'";
                                    $counterparty_name = "'" . $result[($tmpIndex)] . "'";
                                    $drill_term = "NULL";
                                } else {
                                    $report_option = $arrayR[2];
                                }

                                $build_exec_code[$tmpIndex] = urldecode("EXEC spa_get_counterparty_exposure_report $report_option, $report_type, $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], NULL, NULL, $counterparty_name, $drill_term");
                                $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_get_counterparty_exposure_report" &&
                                (($fields == 5 && $arrayR[3] == "'s'" && $arrayR[2] == "'a'" && $arrayR[23] == "'s'" && ($j == 2 || $j == 3 || $j == 4)) ||
                                ($fields == 4 && ($arrayR[3] == "'d'" || $arrayR[3] == "'3'" || $arrayR[3] == "'6'" || $arrayR[3] == "'9'") && $arrayR[2] == "'a'" && $arrayR[23] == "'s'" && $j == 1)
                                )){
                                    
                                //Aged A/R Report
                                if ($j==2) {
                                    $report_type = "'3'";
                                } else if ($j==3) {
                                    $report_type = "'6'";
                                } else if ($j==4) {
                                    $report_type = "'9'";
                                } else {
                                    $report_type = "'d'";
                                }
                                    
                                $report_option = "'a'";

                                if($arrayR[3] == "'s'") {
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", "'" . $result[($tmpIndex - $j)] . "'"));
                                    $counterparty_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                } else {
                                    $counterparty_name = "'" . $result[($tmpIndex - $j)] . "'";   
                                }
                                
                                if ($arrayR[3] != "'s'" && $arrayR[23] == "'s'"){
                                    $tenor_option = "'d'";
                                    $drill_term = "'" . $result[($tmpIndex)] . "'";
                                } else {
                                    $tenor_option = "'s'";
                                    $drill_term = "NULL";
                                }    
                            
                                $build_exec_code[$tmpIndex] = urldecode("EXEC spa_get_counterparty_exposure_report $report_option, $report_type, $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $tenor_option, $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], NULL, NULL, $counterparty_name, $drill_term");
                                $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                
                            } elseif ($report_name == "spa_get_limits_report" && ($fields == 15 && ($j == 11 || $j == 14))) {
                                $drill_term = "NULL";
                                
                                if ($j == 11) {
                                    $drillId = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drillIdFor = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drillCurveId = "'" . urlencode($result[($tmpIndex - $j + 5)]) . "'";
                                    $drillPosLimitType = "'" . $result[($tmpIndex - $j + 8)] . "'";
                                    $drillflag = "'p'";
                                    $drillTenorLimit = $result[($tmpIndex - $j + 6)];
                                } elseif ($j == 14) {
                                    $drillId = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drillIdFor = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drillCurveId = "'" . urlencode($result[($tmpIndex - $j + 5)]) . "'";
                                    $drillPosLimitType = "'" . $result[($tmpIndex - $j + 8)] . "'";
                                    $drillflag = "'t'";
                                    $drillTenorLimit = $result[($tmpIndex - $j + 12)];
                                }

                                $drill_term = urlencode($drill_term);

                                $php_ref = "./spa_html.php?spa=EXEC spa_get_limits_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $drillId, $drillIdFor, $drillCurveId, $drillPosLimitType, $drillflag, $drillTenorLimit";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . ($php_ref) . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } 
                            
                            // DRILL DOWN FOR "spa_counterparty_limits_report"
                            elseif ($report_name == "spa_counterparty_limits_report" && ($j > 1)) {
                                if ($arrayR[2] == "'s'") {
                                    $drill_counterparty = "'" . $result[($tmpIndex - $j)] . "'";
                                    $drill_bucket = "'" . $fieldNames[$j] . "'";
                                    $drill_limit_type = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_counterparty_limits_report 'd', $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $drill_counterparty, $drill_bucket, $drill_limit_type";

                                    if ($j == 2) {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . ($php_ref) . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } else if ($arrayR[2] == "'d'") {
                                    if ($j == 2 || $j == 3) {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . ($php_ref) . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                }
                            } else if ($report_name == "spa_settlement_production_report" && ($fields == 7 || $fields == 29 || $fields == 8 || $fields == 4 || $fields == 5)) {
                                if (($j == 4 && $fields == 7) || ($j == 1 && $fields == 4)) {
                                    if ($fields == 7) {
                                        $drill_Counterparty = urlencode("'" . $result[($tmpIndex - $j + 0)] . "'");
                                        $drill_Technology = ($result[($tmpIndex - $j + 1)] != '') ? "'" . $result[($tmpIndex - $j + 1)] . "'" : 'NULL';
                                        $drill_DealDate = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                        $drill_generator = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                        $drill_BuySell = "NULL";
                                        $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                        $drill_UOM = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    } else if ($fields == 4) {
                                        $drill_Counterparty = urlencode("'" . $result[($tmpIndex - $j + 0)] . "'");
                                        $drill_Technology = "NULL";
                                        $drill_DealDate = "" . $result[($tmpIndex - $j + 1)] . "";
                                        $drill_generator = "NULL";
                                        $drill_BuySell = "NULL";
                                        $drill_State = "NULL";
                                        $drill_UOM = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    }

                                    $date_array = explode(" - ", $drill_DealDate);
                                    
                                    if (count($date_array) > 1) {
                                        $drill_DealDate = "NULL";
                                        $term_start = "'" . getStdDateFormat($date_array[0]) . "'";
                                        $term_end = "'" . getStdDateFormat($date_array[1]) . "'";
                                    } else {
                                        $drill_DealDate = "'" . getStdDateFormat($drill_DealDate) . "'";
                                        $term_start = $arrayR[11];
                                        $term_end = $arrayR[12];
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_settlement_production_report $arrayR[2], $arrayR[3], $arrayR[4], " .
                                            "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $term_start, $term_end, 'd', $drill_Counterparty, $drill_Technology, $drill_DealDate, $drill_BuySell, NULL, NULL, NULL, $drill_generator, $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27]";

                                    if ($arrayR[13] == "'z'") {
                                        $php_ref = "./spa_html.php?spa=EXEC spa_settlement_production_report $arrayR[2], $arrayR[3], $arrayR[4], " .
                                                "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], 'y', $drill_Counterparty, $drill_Technology, $drill_DealDate, $drill_BuySell, NULL, NULL, NULL, $drill_generator, $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27]";

                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else if ($arrayR[13] == "'s'") {
                                        $php_ref = "./spa_html.php?spa=EXEC spa_settlement_production_report $arrayR[2], $arrayR[3], $arrayR[4], " .
                                                "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], 'h', $drill_Counterparty, $drill_Technology, $drill_DealDate, $drill_BuySell, NULL, NULL, NULL, $drill_generator, $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27]";

                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } else if (($j == 7 && $fields == 8) || ($j == 4 && $fields == 5)) {
                                    if ($fields == 8) {
                                        $drill_Counterparty = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                        $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                        $drill_DealDate = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                        $drill_generator = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                        $drill_BuySell = "NULL";
                                        $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                        $drill_UOM = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    } else if ($fields == 5) {
                                        $drill_Counterparty = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                        $drill_Technology = "NULL";
                                        $drill_DealDate = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                        $drill_generator = "NULL";
                                        $drill_BuySell = "NULL";
                                        $drill_State = "NULL";
                                        $drill_UOM = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    }

                                    $date_array = explode(" - ", $drill_DealDate);
                                    
                                    if (count($date_array) > 1) {
                                        $drill_DealDate = "NULL";
                                        $term_start = "'" . getStdDateFormat($date_array[0]) . "'";
                                        $term_end = "'" . getStdDateFormat($date_array[1]) . "'";
                                    } else {
                                        $drill_DealDate = "'" . getStdDateFormat($drill_DealDate) . "'";
                                        $term_start = $arrayR[11];
                                        $term_end = $arrayR[12];
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_settlement_production_report $arrayR[2], $arrayR[3], $arrayR[4], " .
                                            "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $term_start, $term_end, 'r', $drill_Counterparty, $drill_Technology, $drill_DealDate, $drill_BuySell, NULL, NULL, NULL, $drill_generator";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if (($j == 4 && $fields == 8) || ($j == 1 && $fields == 5)) {
                                    if ($fields == 8) {
                                        $drill_Counterparty = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                        $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                        $drill_DealDate = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                        $drill_generator = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                        $drill_BuySell = "NULL";
                                        $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                        $drill_UOM = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    } else if ($fields == 5) {
                                        $drill_Counterparty = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                        $drill_Technology = "NULL";
                                        $drill_DealDate = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                        $drill_generator = "NULL";
                                        $drill_BuySell = "NULL";
                                        $drill_State = "NULL";
                                        $drill_UOM = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    }

                                    $date_array = explode(" - ", $drill_DealDate);
                                    
                                    if (count($date_array) > 1) {
                                        $drill_DealDate = "NULL";
                                        $term_start = "'" . getStdDateFormat($date_array[0]) . "'";
                                        $term_end = "'" . getStdDateFormat($date_array[1]) . "'";
                                    } else {
                                        $drill_DealDate = "'" . getStdDateFormat($drill_DealDate) . "'";
                                        $term_start = $arrayR[11];
                                        $term_end = $arrayR[12];
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_settlement_production_report $arrayR[2], $arrayR[3], $arrayR[4], " .
                                            "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], 'c', $drill_Counterparty, $drill_Technology, $drill_DealDate, $drill_BuySell, NULL, NULL, NULL, $drill_generator";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 28 && $fields == 29) {
                                    $drill_Counterparty = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_recorderid = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_generator = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_channel = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_settlement_production_report $arrayR[2], $arrayR[3], $arrayR[4], " .
                                            "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], 'r', $drill_Counterparty, NULL, $drill_DealDate, NULL, NULL, NULL, NULL, $arrayR[21]";

                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            }

                            //drill down for measurement cash flow detail report only
                            elseif ($report_name == "spa_get_emissions_inventory_report") {
                                if ($fields == 12 && $arrayR[6] == "'i.2.a.1'" && ($j == 5 || $j == 6 || $j == 7 || $j == 8 || $j == 9 || $j == 10 || $j == 8)) {
                                    $source = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $group1 = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $gas = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $group1 = "NULL";
                                    $group2 = "NULL";
                                    $group3 = "NULL";
                                    
                                    if ($j == 5) {
                                        $report_year_level = 1;
                                    }
                                    
                                    if ($j == 6) {
                                        $report_year_level = 2;
                                    }
                                    
                                    if ($j == 7) {
                                        $report_year_level = 3;
                                    }
                                    
                                    if ($j == 8) {
                                        $report_year_level = 4;
                                    }
                                    
                                    if ($j == 9) {
                                        $report_year_level = 5;
                                    }
                                    
                                    if ($j == 10) {
                                        $report_year_level = 6;
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 1, " . "$report_year_level, $source, $group1, $group2, $group3, $gas";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 11 && ($arrayR[6] == "'i.2.b.1.a'" || $arrayR[6] == "'i.2.b.1.b'" || $arrayR[6] == "'i.2.b.1.e'" || $arrayR[6] == "'i.2.b.2.c'") && ($j == 3 || $j == 4 || $j == 5 || $j == 6 || $j == 7 || $j == 8)) {
                                    $source = "NULL";
                                    $group3 = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $gas = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $group2 = "NULL";
                                    $group1 = "NULL";
                                    
                                    if ($j == 3) {
                                        $report_year_level = 1;
                                    }
                                    
                                    if ($j == 4) {
                                        $report_year_level = 2;
                                    }
                                    
                                    if ($j == 5) {
                                        $report_year_level = 3;
                                    }
                                    
                                    if ($j == 6) {
                                        $report_year_level = 4;
                                    }
                                    
                                    if ($j == 7) {
                                        $report_year_level = 5;
                                    }
                                    
                                    if ($j == 8) {
                                        $report_year_level = 6;
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 1, " . "$report_year_level, $source, $group1, $group2, $group3, $gas";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 9 && ($arrayR[6] == "'i.2.b.2.a'") && ($j == 2 || $j == 3 || $j == 4 || $j == 5 || $j == 6 || $j == 7)) {
                                    $source = "NULL";
                                    $group3 = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $gas = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $group2 = "NULL";
                                    $group1 = "NULL";
                                    
                                    if ($j == 2) {
                                        $report_year_level = 1;
                                    }
                                    
                                    if ($j == 3) {
                                        $report_year_level = 2;
                                    }
                                    
                                    if ($j == 4) {
                                        $report_year_level = 3;
                                    }
                                    
                                    if ($j == 5) {
                                        $report_year_level = 4;
                                    }
                                    
                                    if ($j == 6) {
                                        $report_year_level = 5;
                                    }
                                    
                                    if ($j == 7) {
                                        $report_year_level = 6;
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], " . "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $term_start, $term_end, 'r', $drill_Counterparty, $drill_Technology, $drill_DealDate, $drill_BuySell, NULL, NULL, NULL, $drill_generator";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 9 && ($arrayR[6] == "'i.2.b.4.a'") && ($j == 3 || $j == 5)) {
                                    $source = "NULL";
                                    $group3 = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $gas = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $group2 = "NULL";
                                    $group1 = "NULL";
                                    
                                    if ($j == 3) {
                                        $report_year_level = 1;
                                    }
                                    
                                    if ($j == 4) {
                                        $report_year_level = 2;
                                    }
                                    
                                    if ($j == 5) {
                                        $report_year_level = 6;
                                    }
                                    
                                    if ($j == 6) {
                                        $report_year_level = 4;
                                    }
                                    
                                    if ($j == 7) {
                                        $report_year_level = 5;
                                    }
                                    if ($j == 7) {
                                        $report_year_level = 6;
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 1, " . "$report_year_level, $source, $group1, $group2, $group3, NULL";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 5 && ($arrayR[6] == "'i.2.b.4.h'") && ($j == 3)) {
                                    $source = "NULL";
                                    $group2 = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $gas = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $group3 = "NULL";
                                    $group1 = "NULL";
                                    $report_year_level = 6;
                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 1, " . "$report_year_level, $source, $group1, $group2, $group3, $gas";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 7 && ($arrayR[6] == "'i.2.b.5'") && ($j == 4 || $j == 5)) {
                                    $group1 = "NULL";
                                    $source = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $group2 = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $gas = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $group3 = "NULL";
                                    $report_year_level = 6;
                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 1, " . "$report_year_level, $source, $group1, $group2, $group3, $gas, NULL, NULL, NULL, NULL, 'y'";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 11 && ($arrayR[6] == "'i.2.b.2.b'") && ($j == 3 || $j == 4 || $j == 5 || $j == 6 || $j == 7 || $j == 8)) {
                                    $source = "NULL";
                                    $group3 = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $gas = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $group2 = "NULL";
                                    $group1 = "NULL";
                                    
                                    if ($j == 2) {
                                        $report_year_level = 1;
                                    }
                                    
                                    if ($j == 3) {
                                        $report_year_level = 2;
                                    }
                                    
                                    if ($j == 4) {
                                        $report_year_level = 3;
                                    }
                                    
                                    if ($j == 5) {
                                        $report_year_level = 4;
                                    }
                                    
                                    if ($j == 6) {
                                        $report_year_level = 5;
                                    }
                                    
                                    if ($j == 7) {
                                        $report_year_level = 6;
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 1, " . "$report_year_level, $source, $group1, $group2, $group3, $gas";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 10 && ($arrayR[6] == "'i.2.c'") && ($j == 4 || $j == 5 || $j == 6 || $j == 7 || $j == 8 || $j == 9)) {
                                    $source = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $gas = "NULL";
                                    $group2 = "NULL";
                                    $group1 = "NULL";
                                    $group3 = "NULL";
                                    
                                    if ($j == 4) {
                                        $report_year_level = 1;
                                    }
                                    
                                    if ($j == 5) {
                                        $report_year_level = 2;
                                    }
                                    
                                    if ($j == 6) {
                                        $report_year_level = 3;
                                    }
                                    
                                    if ($j == 7) {
                                        $report_year_level = 4;
                                    }
                                    
                                    if ($j == 8) {
                                        $report_year_level = 5;
                                    }
                                    
                                    if ($j == 9) {
                                        $report_year_level = 6;
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 1, " . "$report_year_level, $source, $group1, $group2, $group3, $gas";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif (($j == 4 || $j == 5) && ($fields == 5 || $fields == 6) && $arrayR[16] == '1') {
                                    $curve = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $uom = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $generator_array = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", $generator_array));
                                    $generator = "'" . str_replace("<l>", "", $pieces[1]) . "'";

                                    if ($j == 4) {
                                        $emissions_reductions = 'e';
                                    } elseif ($j == 5) {
                                        $emissions_reductions = 'r';
                                    }
                                    
                                    $de_minimis = 'n';
                                    
                                    if (count($arrayR) == 28) {
                                        if ($arrayR[27] == "'y'") {
                                            $de_minimis = 'y';
                                        }
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 2, " . "$arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $generator, NULL, NULL, $emissions_reductions, $de_minimis";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($j == 5 && ($arrayR[6] == "'i.3.a.1'" || $arrayR[6] == "'i.3.b.1'") && $arrayR[16] != 1) {
                                    $generator_array = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", $generator_array));
                                    $generator = $pieces[0];
                                    $curve = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $uom = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], NULL, 1, " . "NULL, NULL, NULL, NULL, NULL, $curve, $generator";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($j == 6 && $fields == 7 && $arrayR[16] == '2') {
                                    $gas = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $term_start = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $term_end = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $uom = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $generator = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory 'd', NULL, $term_start, $term_end, NULL, $gas, $uom, $term_start, $generator, $arrayR[26]";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } else if ($report_name == "spa_Create_MTM_Period_Report_TRM") {
                                if ($j == 3 && $fields == '7' && $arrayR[9] == "'1'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = 'NULL';
                                    $expiration = 'NULL';
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 4 && $fields == '8' && $arrayR[9] == "'2'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 3] . "'";
                                    $expiration = 'NULL';
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 5 && $fields == '9' && $arrayR[9] == "'3'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 3] . "'";
                                    $expiration = "'" . $result[($tmpIndex - $j) + 4] . "'";
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 3 && $fields == '7' && $arrayR[9] == "'4'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $expiration = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 2 && $fields == '6' && $arrayR[9] == "'5'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $expiration = 'NULL';
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 1 && $fields == '5' && $arrayR[9] == "'6'" && $arrayR[46] == "'n'") {
                                    $subsidiary = 'NULL';
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = "'" . $result[($tmpIndex - $j)] . "'";
                                    $expiration = 'NULL';
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 2 && $fields == '6' && $arrayR[9] == "'7'" && $arrayR[46] == "'n'") {
                                    $subsidiary = 'NULL';
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = "'" . $result[($tmpIndex - $j)] . "'";
                                    $expiration = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 2 && $fields == '6' && $arrayR[9] == "'8'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = 'NULL';
                                    $expiration = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 2 && $fields == '6' && $arrayR[9] == "'9'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = 'NULL';
                                    $expiration = 'NULL';
                                    $trader = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 3 && $fields == '7' && $arrayR[9] == "'10'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = 'NULL';
                                    $expiration = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $trader = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 1 && $fields == '5' && $arrayR[9] == "'11'" && $arrayR[46] == "'n'") {
                                    $subsidiary = 'NULL';
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = 'NULL';
                                    $expiration = 'NULL';
                                    $trader = "'" . $result[($tmpIndex - $j)] . "'";
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 2 && $fields == '6' && $arrayR[9] == "'12'" && $arrayR[46] == "'n'") {
                                    $subsidiary = 'NULL';
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = 'NULL';
                                    $expiration = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $trader = "'" . $result[($tmpIndex - $j)] . "'";
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 14 && $fields == '18' && $arrayR[9] == "'13'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 7] . "'";
                                    $expiration = $arrayR[51];
                                    $trader = "'" . $result[($tmpIndex - $j) + 8] . "'";
                                    $deal_id = "'" . $result[($tmpIndex - $j) + 10] . "'";
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '15', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $deal_id, $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 13 && $fields == '17' && $arrayR[9] == "'13'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 7] . "'";
                                    $expiration = $arrayR[51];
                                    $trader = "'" . $result[($tmpIndex - $j) + 8] . "'";
                                    $deal_id = "'" . $result[($tmpIndex - $j) + 10] . "'";
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '15', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $deal_id, $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<Ahref=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 11 && $fields == '15' && $arrayR[9] == "'14'" && $arrayR[46] == "'n'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 3] . "'";
                                    $expiration = "'" . $result[($tmpIndex - $j) + 9] . "'";
                                    $trader = "'" . $result[($tmpIndex - $j) + 4] . "'";
                                    $deal_id = "'" . $result[($tmpIndex - $j) + 6] . "'";
                                    $trader = str_replace('&', '^', $trader);
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '15', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $deal_id, $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = (encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span));
                                } else if ($j == 3 && $fields == 5 && $arrayR[9] == "'1'" && $arrayR[46] == "'y'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = 'NULL';
                                    $expiration = 'NULL';
                                    $trader = 'NULL';
                                    $currency = "'" . $result[($tmpIndex - $j) + 4] . "'";
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<a href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</a>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 4 && $fields == 6 && $arrayR[9] == "'2'" && $arrayR[46] == "'y'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 3] . "'";
                                    $expiration = 'NULL';
                                    $trader = 'NULL';
                                    $currency = "'" . $result[($tmpIndex - $j) + 5] . "'";;
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 5 && $fields == 7 && $arrayR[9] == "'3'" && $arrayR[46] == "'y'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $book = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 3] . "'";
                                    $expiration = "'" . $result[($tmpIndex - $j) + 4] . "'";
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 3 && $fields == 5 && $arrayR[9] == "'4'" && $arrayR[46] == "'y'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $expiration = "'" . $result[($tmpIndex - $j) + 2] . "'";
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 2 && $fields == 4 && $arrayR[9] == "'5'" && $arrayR[46] == "'y'") {
                                    $subsidiary = "'" . $result[($tmpIndex - $j)] . "'";
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $expiration = 'NULL';
                                    $trader = 'NULL';
                                    $currency = "'" . $result[($tmpIndex - $j) + 3] . "'";
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 1 && $fields == 3 && $arrayR[9] == "'6'" && $arrayR[46] == "'y'") {
                                    $subsidiary = 'NULL';
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = "'" . $result[($tmpIndex - $j)] . "'";
                                    $expiration = 'NULL';
                                    $trader = 'NULL';
                                    $currency = $result[($tmpIndex - $j) + 2]; 
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else if ($j == 2 && $fields == 4 && $arrayR[9] == "'7'" && $arrayR[46] == "'y'") {
                                    $subsidiary = 'NULL';
                                    $strategy = 'NULL';
                                    $book = 'NULL';
                                    $counterparty = "'" . $result[($tmpIndex - $j)] . "'";
                                    $expiration = "'" . $result[($tmpIndex - $j) + 1] . "'";
                                    $trader = 'NULL';
                                    $currency = 'NULL';
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_Create_MTM_Period_Report_TRM $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], '13', $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $subsidiary, $strategy, $book, $counterparty, $expiration, $trader, $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59], $arrayR[60], $arrayR[61], $arrayR[62], $arrayR[63], $currency");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "Journal Entry Report" && $fields == 4) {
                                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 20 && ($j == 17 || $j == 15 || $j == 16)) {
                                if ($j == 15) {//AOCI
                                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "AOCI", $result[$tmpIndex - $j + 4], $result[$tmpIndex - $j + 8], $arrayR);
                                }

                                if ($j == 16) { // PNL
                                    if (trim($result[$tmpIndex - $j + 5]) == "D") { //D for 'Deal' , L for 'Designation'
                                        $tmp_clmType = "LINK";
                                        $tmp_linkId = $result[$tmpIndex - $j + 4] . "-D";
                                    } else {
                                        $tmp_clmType = "PNL";
                                        $tmp_linkId = $result[$tmpIndex - $j + 4];
                                    }

                                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "$tmp_clmType", $tmp_linkId, $result[$tmpIndex - $j + 8], $arrayR);
                                }

                                if ($j == 17) { //Settlement
                                    $php_ref = get_settlement_drilldown_phpref("Settlement", $result[$tmpIndex - $j + 4], $result[$tmpIndex - $j + 5], $result[$tmpIndex - $j + 8], $result[$tmpIndex - $j], $arrayR);
                                }

                                $php_ref = str_replace("'", "^", $php_ref);
                                $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 21 && ($j == 18 || $j == 19)) {
                                if ($j == 18) { //PNL
                                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "PNL", $result[$tmpIndex - $j + 3], $result[$tmpIndex - $j + 7], $arrayR);
                                }

                                if ($j == 19) { //PNL
                                    $php_ref = get_settlement_drilldown_phpref("Settlement", $result[$tmpIndex - $j + 3], $result[$tmpIndex - $j + 4], $result[$tmpIndex - $j + 7], $result[$tmpIndex - $j], $arrayR);
                                }
                                
                                $php_ref = str_replace("'", "^", $php_ref);
                                $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_drill_down_msmt_report" && $fields == 9 && $j == 8) {
                                if ($j == 8) //AOCI Detailed Schedule
                                    {
                                    $term = "'" . $result[$tmpIndex - $j + 5] . "-01'";
                                    $php_ref = "EXEC spa_create_detailed_aoci_schedule $arrayR[4], $arrayR[5], $term, $arrayR[3], NULL, NULL, NULL, 'd', '2',NULL,NULL";//"./spa_html.php?enable_paging=true&spa=EXEC spa_create_detailed_aoci_schedule $arrayR[4], $arrayR[5], $term, $arrayR[3], NULL, NULL, NULL, 'd', '2',NULL,NULL";

                                }
                                
                                $php_ref = str_replace("'", "^", $php_ref);
                                $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_drill_down_settlement" && $fields == 4 && $j == 3 && ($result[$tmpIndex - $j + 1] == "AOCI Release to Earnings" || $result[$tmpIndex - $j + 1] =="AOCI Release to Earnings due to De-Designation Not Probable")) {
                                if ($j == 3) //AOCI Detailed Schedule
                                    {
                                    $term = "'" . $result[$tmpIndex - $j + 2] . "-01'";
                                    $link_id = $result[$tmpIndex - $j];
                                    
                                    $php_ref = "./spa_html.php?spa=EXEC spa_create_detailed_aoci_schedule $arrayR[3], $link_id , $term, $arrayR[8]";

                                }
                            
                                $php_ref = str_replace("'", "^", $php_ref);
                                $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_rec_compliance_sold_report" && $j == 2) {
                                $php_ref = "./spa_html.php?spa=EXEC spa_create_rec_compliance_sold_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7],'" . $result[($tmpIndex - 1)] . "'&enable_paging=true";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_rec_margin_report" && $fields == 10 && $j == 3) {
                                if ($arrayR[11] == "'s'") {
                                    $drill_sub = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_as_of_date = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_production_month = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_counterparty = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $trader = "null";
                                } else {
                                    $drill_sub = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_as_of_date = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_production_month = "null";
                                    $drill_counterparty = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $trader = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                }

                                $php_ref = "./spa_html.php?spa=EXEC spa_create_rec_margin_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], 'd', $drill_sub, $drill_as_of_date, $drill_production_month, $drill_counterparty, $trader&enable_paging=true";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_rec_invoice_report" && $j == 2 && $fields != 6) {
                                $save_invoice_id = "NULL";
                                
                                if (count($arrayR) > 12) {
                                    $save_invoice_id = $arrayR[12];
                                }
                                
                                $php_ref = "./spa_html.php?spa=EXEC spa_create_rec_invoice_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $save_invoice_id, 'd'";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_rec_compliance_report" && ($j == 2 || $j == 3 || $j == 4 || $j == 6 || $j == 7 || $j == 8 || $j == 10 || $j == 11) && $arrayR[9] == 1) { //Report format 1
                                $resource_name = $result[($tmpIndex - $j + 1)];
                                $type = $result[($tmpIndex - $j)];
                                $pieces = explode("<u>", str_replace("</u>", "<u>", $resource_name));

                                if (count($pieces) > 1) {
                                    $resource_name = $pieces[1];
                                } else {
                                    $resource_name = $resource_name;
                                }
                                
                                $php_ref = "./spa_html.php?spa=EXEC spa_create_rec_compliance_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7],$arrayR[8],$arrayR[9],$arrayR[10],$arrayR[11], $j, '" . $resource_name . "','" . $type . "'&enable_paging=true";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_rec_compliance_report" && ($j == 3 || $j == 4 || $j == 5 || $j == 7 || $j == 8 || $j == 9) && $arrayR[9] == 3 && $show_header == 'true') { //Report format 2
                                $resource_name = $result[($tmpIndex - $j + 1)];
                                $pieces = explode("<u>", str_replace("</u>", "<u>", $resource_name));
                                
                                if (count($pieces) > 1) {
                                    $resource_name = $pieces[1];
                                } else {
                                    $resource_name = $resource_name;
                                }
                                
                                $x = $j - 1;
                                $php_ref = "./spa_html.php?spa=EXEC spa_create_rec_compliance_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7],$arrayR[8],$arrayR[9], $x, '" . $resource_name . "'&enable_paging=true";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_REC_Exposure_Report" && ($j == 5)) {
                                if ($arrayR[2] == "'m'" && $j == 5 && $arrayR[19] != "'d'") {
                                    $state = $result[($tmpIndex - $j)];
                                    $vintage = $result[($tmpIndex - $j + 1)];
                                    $jurisdiction = $result[($tmpIndex - $j + 2)];
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", $jurisdiction));
                                    
                                    if (count($pieces) > 1) {
                                        $jurisdiction = $pieces[1];
                                    } else {
                                        $jurisdiction = $jurisdiction;
                                    }

                                    if ($arrayR[19] == "'a'") {
                                        $detail_option = 'd';
                                        $technology = $result[($tmpIndex - $j + 3)];
                                    } else {
                                        $detail_option = 'a';
                                        $technology = $result[($tmpIndex - $j + 3)];
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_REC_Exposure_Report 'm', $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7],  $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], '$detail_option', NULL, NULL, '$state' , '$vintage', '$jurisdiction', '$technology'";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "spa_find_gis_recon_deals" && $fields == 6 && $j == 2) {
                                $feeder_deal_id = $result[($tmpIndex - $j + 2)];
                                $php_ref = "./spa_html.php?spa=EXEC spa_find_gis_recon_deals $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], '$feeder_deal_id'";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_find_gis_recon_deals" && $fields == 9 && $j == 3) {
                                $feeder_deal_id = $result[($tmpIndex - $j + 3)];
                                $php_ref = "./spa_html.php?spa=EXEC spa_find_gis_recon_deals $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], '$feeder_deal_id'";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_create_rec_settlement_report" && $arrayR[10] != "'d'") {
                                if ($fields == 6) {
                                    if ($j == 5) {
                                        $item = "'" . $result[($tmpIndex - $j)] . "'";
                                        $prod_month = "'" . getStdDateFormat($result[($tmpIndex - $j + 1)]) . "'";
                                        
                                        $php_ref = "./spa_html.php?spa=EXEC spa_gen_invoice_variance_report $arrayR[9], $prod_month, $arrayR[17], $item, 'm', $arrayR[7], NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $arrayR[20], $arrayR[23]" . "&call_from=" . $call_from;
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                }
                            } elseif ($report_name == "spa_create_rec_settlement_report" && $j == 2 && $fields != 6 && $arrayR[10] != "'d'") { //&& count($arrayR) == 12)
                                $feeder_deal_id = "";
                                
                                if ($fields == 9) {
                                    $feeder_deal_id = "d";
                                } else {
                                    $feeder_deal_id = $result[($tmpIndex - $j + 1)];
                                }
                                
                                $php_ref = "./spa_html.php?spa=EXEC spa_create_rec_settlement_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], 'd', $arrayR[11], NULL, '$feeder_deal_id'&enable_paging=true";
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_get_rec_activity_report" && (($j == 2 && $fields != 10 && $fields != 11) || ($j == 3 && $fields == 10 && $arrayR[43] != "'n'") || ($j == 3 && $fields == 10 && $arrayR[7] == "'c'") || ($fields == 10 && $arrayR[43] != "'t'" && $arrayR[7] == "'g'" && $j == 2) || ($fields == 10 && $arrayR[7] == "'y'" && $j == 2 && $arrayR[43] == "'n'") || ($fields == 10 && $arrayR[43] == "'n'" && $arrayR[7] == "'h'" && $j == 2) || ($fields == 11 && $arrayR[43] == "'n'" && $arrayR[7] == "'i'" && $j == 3)) && $fields != 21) {
                                if ($fields == 6 && $arrayR[43] != "'t'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "null";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";
                                }

                                if ($fields == 5 && $arrayR[43] == "'t'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "null";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";
                                }

                                if ($fields == 7 && $arrayR[8] != "'b'") {
                                    $drill_Counterparty = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "null";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";
                                }
                                
                                if ($fields == 8 && $arrayR[8] == "'b'") {
                                    $drill_Counterparty = "NULL";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 7)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "null";
                                }

                                if ($fields == 8 && $arrayR[8] == "'e'") {
                                    $drill_Counterparty = "NULL";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "NULL";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 7)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                }

                                if ($fields == 7 && $arrayR[8] == "'s'" && $arrayR[43] == "'t'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "NULL";

                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 8 && $arrayR[8] == "'a'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 7)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Expiration = "NULL";

                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 8 && $arrayR[8] == "'v'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "null";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_trader = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";

                                    if ($drill_State != "null") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 9 && $arrayR[8] == "'v'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "null";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    $drill_trader = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";

                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        
                                        if (count($pieces2) > 1) {
                                            $drill_State = "'" . $pieces2[1] . "'";
                                        }
                                    }
                                }
                                if ($fields == 9 && $arrayR[8] == "'s'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 8)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 4)] . "'";

                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 9 && $arrayR[8] == "'a'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 8)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 4)] . "'";

                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 10 && $arrayR[8] == "'c'") {
                                    $drill_Counterparty = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_BuySell = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 7)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 10 && $arrayR[8] == "'y'" && $j != 2 && $j != 3) {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 5)] . "'";

                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }

                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 10 && $arrayR[8] == "'y'" && $j == 2) {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 5)] . "'";

                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 9 && $arrayR[43] == "'t'" && ($arrayR[8] == "'g'" || $arrayR[8] == "'h'" || $arrayR[8] == "'y'")) {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 8)] . "'";
                                    $drill_Expiration = "NULL";

                                    if ($arrayR[8] == "'h'") {
                                        $drill_trader = "'zzz'";
                                    } else {
                                        $drill_trader = "null";
                                    }
                                    
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    
                                    if ($arrayR[8] == "'y'") {
                                        $drill_Expiration = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    } else {
                                        $drill_DealDate = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    }
                                    
                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 10 && $arrayR[43] != "'t'" && ($arrayR[8] == "'h'" && $j != 2)) { //Added $j!=2
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 5)] . "'";

                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 10 && $arrayR[43] == "'n'" && $arrayR[8] == "'h'" && $j == 2) {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                    $drill_trader = "zzz";
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 5)] . "'";

                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }
                                
                                if ($fields == 10 && $arrayR[43] != "'t'" && $arrayR[8] == "'g'" && $j == 2) {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 5)] . "'";

                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 10 && $arrayR[43] == "'t'" && $arrayR[8] != "'c'" && $j == 3) {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_Expiration = "NULL";

                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 11 && $arrayR[43] == "'n'" && $arrayR[8] == "'i'" && $j == 3) { //Added
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 10)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 6)] . "'";

                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 11 && $arrayR[43] != "'t'" && $j != 3) {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 10)] . "'";
                                    $drill_trader = "null";
                                    $drill_Generator = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 6)] . "'";

                                    if ($drill_Generator != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_Generator));
                                        $drill_Generator = "'" . $pieces[1] . "'";
                                    }
                                    
                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 12 && $arrayR[43] == "'t'") { // transactions report and trader drill
                                    $drill_Counterparty = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_BuySell = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                    $drill_trader = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";

                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 13 && $arrayR[43] != "'t'") {
                                    $drill_Counterparty = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_BuySell = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 10)] . "'";
                                    $drill_trader = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";

                                    if ($drill_State != "''") {
                                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                                        $drill_State = "'" . $pieces2[1] . "'";
                                    }
                                }

                                if ($fields == 13 && $arrayR[43] == "'t'") {
                                    $drill_Counterparty = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_DealDate = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $drill_BuySell = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $drill_State = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_oblication = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                    $drill_trader = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";
                                }

                                if ($fields == 14 && $arrayR[43] == "'t'") {
                                    $drill_Counterparty = "null";
                                    $drill_Technology = "null";
                                    $drill_DealDate = "null";
                                    $drill_BuySell = "null";
                                    $drill_State = "null";
                                    $drill_oblication = "null";
                                    $drill_UOM = "null";
                                    $drill_trader = "null";
                                    $drill_Generator = "null";
                                    $drill_Assignment = "null";
                                    $drill_Expiration = "null";
                                }
                                
                                $php_ref = "./spa_html.php?spa=EXEC spa_get_rec_activity_report $arrayR[2], $arrayR[3], $arrayR[4], " . "$arrayR[5], $arrayR[6], 'd', $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], " . "$arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], " . "$arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], " . "$arrayR[26], $arrayR[27], $arrayR[28],$arrayR[29],$arrayR[30],$arrayR[31],$drill_Counterparty, $drill_Technology,$drill_DealDate, $drill_BuySell, " . "$drill_State, $drill_oblication, $drill_UOM,$drill_trader,$drill_Generator,$drill_Assignment," . "$drill_Expiration";
                                
                                if ($arrayR[43] == "'t'") {
                                    $php_ref = $php_ref . ",'t',NULL,NULL,NULL,NULL,$arrayR[48] ";
                                } else {
                                    $php_ref = $php_ref . ",'n',NULL,NULL,NULL,NULL,$arrayR[48]";
                                }

                                $php_ref = $php_ref . ", $arrayR[49], $arrayR[50], $arrayR[51], $arrayR[52], $arrayR[53], $arrayR[55], $arrayR[55], $arrayR[56]";  
                            } elseif ($report_name == "spa_REC_State_Allocation_Report") {
                                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                            } elseif (($report_name == "spa_gen_invoice_variance_report") && ($arrayR[6] == "'h'" && $j == $fields - 1)) { 
                                if ($result[($tmpIndex - $j + 6)] !="") {
                                    $hour =  "'" . $result[($tmpIndex - $j + 5)].":".$result[($tmpIndex - $j + 6)]. "'";
                                } else {
                                    $hour =    "'" . $result[($tmpIndex - $j + 5)] . ":00'";
                                }

                                $prod_month = "'" . getStdDateFormat($result[($tmpIndex - $j + 3)]) . "'";
                                $deal_id = "'" . $result[($tmpIndex - $j)] . "'";
                                $pieces = explode("<u>", str_replace("</u>", "<u>", $prod_month));
                                $counterparty = 'NULL';
                                $contract = 'NULL';
                                $deal_detail_id = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                $is_dst =   $result[($tmpIndex - $j + 4)] ;
                                                
                                if ($is_dst == '') {
                                    $is_dst = 'NULL';
                                }
                                
                                if ($hour == "''") {
                                    $hour = 'NULL';
                                }

                                if ($deal_id == "''") {
                                    $deal_id = 'NULL';
                                }

                                if ($deal_detail_id == "''") {
                                    $deal_detail_id = 'NULL';
                                }

                                if (count($arrayR) >= 13) {
                                    $counterparty = $arrayR[13];
                                    $contract = $arrayR[14];
                                }
                                
                                if (count($pieces) > 1) {
                                    $prod_month = "'" . getStdDateFormat($pieces[1]) . "'";
                                }

                                $pieces = explode("<u>", str_replace("</u>", "<u>", $deal_id));
                                
                                if (count($pieces) > 1) {
                                    $deal_id = "'" . $pieces[1] . "'";
                                }

                                $pieces = explode("<u>", str_replace("</u>", "<u>", $deal_detail_id));
                                
                                if (count($pieces) > 1) {
                                    $deal_detail_id = "'" . $pieces[1] . "'";
                                }

                                if ($arrayR[12] == '') {
                                    $arrayR[12] = "NULL";
                                }
                                            
                                if ($arrayR[3] == '') {
                                    $arrayR[3] = "NULL";
                                }
                                                
                                if ($arrayR[19] == '') {
                                    $arrayR[19] = "NULL";
                                }
                            
                                $add_drilldown_paging = ($enable_paging) ? '&enable_paging=true' : '';
                                $is_new_paging = ($new_paging) ? '&np=1' : '';
                            
                                $deal_id = str_replace('</l>','',str_replace('<l>', '', $deal_id));

                                $php_ref = "./spa_html.php?spa=EXEC spa_gen_invoice_variance_report $arrayR[2], $prod_month, $arrayR[4]," . urlencode($arrayR[5]) . ",'d', $arrayR[7], $hour, $arrayR[3], $deal_id, $arrayR[11], $arrayR[12], $counterparty, $contract, $deal_detail_id, NULL, NULL, NULL, $is_dst, $arrayR[19]" . $add_drilldown_paging . $is_new_paging . "&rnd=" . $round_no . "&call_from=" . ($call_from ?? '');
                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">". my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ((($report_name == "spa_gen_invoice_variance_report") && ($arrayR[6] != "'h'") && (($j == 1 && ($fields == 4 && $arrayR[6] != "'d'") || $fields == 2 || $fields == 6 || $fields == 7 || ($fields == 3 && $arrayR[6] != "'d'"))))) {
                                if ($fields == 4) {
                                    $item = "'" . urlencode($result[($tmpIndex - $j)]) . "'";
                                }

                                if ($j == 3) {
                                    $flag = 'v';
                                } else {
                                    $flag = 'm';
                                }

                                if ($arrayR[19] == '') {
                                    $arrayR[19] = "NULL";
                                }
                            
                                if ($arrayR[20] == '') {
                                    $arrayR[20] = "NULL";
                                }

                                $php_ref = "./spa_html.php?spa= EXEC spa_gen_invoice_variance_report $arrayR[2], $arrayR[3], $arrayR[4], $item, $flag, $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11],  $arrayR[12], $arrayR[13], $arrayR[14],$arrayR[15],$arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20]" . "&rnd=" . $round_no . "&call_from=" . $call_from;
                                
                                if ($fields == 6 && ($arrayR[6] == "'f'")) {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 7 && $arrayR[6] == "'h'") {
                                    if ($j == 6) {
                                        $hour = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                        $prod_month = "'" . getStdDateFormat($result[($tmpIndex - $j + 1)]) . "'";
                                        $deal_id = "'" . $result[($tmpIndex - $j)] . "'";
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $prod_month));
                                        $counterparty = 'NULL';
                                        $contract = 'NULL';
                                        
                                        if (count($arrayR) == 14) {
                                            $counterparty = $arrayR[12];
                                            $contract = $arrayR[13];
                                        }
                                        
                                        if (count($pieces) > 1) {
                                            $prod_month = "'" . getStdDateFormat($pieces[1]) . "'";
                                        }

                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $deal_id));
                                        
                                        if (count($pieces) > 1) {
                                            $deal_id = "'" . $pieces[1] . "'";
                                        }

                                        if ($arrayR[19] == '') {
                                            $arrayR[19] = "NULL";
                                        }
                                        
                                        if ($arrayR[20] == '') {
                                            $arrayR[20] = "NULL";
                                        } 
                                                        
                                        $php_ref = "./spa_html.php?spa=EXEC spa_gen_invoice_variance_report $arrayR[2], $prod_month, $arrayR[4]," . urlencode($arrayR[5]) . ",'d', $arrayR[7], $hour, $arrayR[3], $deal_id, $arrayR[11], $arrayR[12], $counterparty, $contract, $arrayR[15], $arrayR[16], $arrayR[17],$arrayR[18], $arrayR[19], $arrayR[20]" . "&rnd=" . $round_no. "&call_from=" . $call_from;
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } elseif ($fields == 6 && $arrayR[6] != "'h'") {
                                    if ($j == 5) {
                                        if ($arrayR[19] == '') {
                                            $arrayR[19] = "NULL";
                                        }
                                    
                                        if ($arrayR[20] == '') {
                                            $arrayR[20] = "NULL";
                                        }
                                    
                                        $php_ref = "./spa_html.php?spa=EXEC spa_gen_invoice_variance_report $arrayR[2], $arrayR[3], $arrayR[4]," . urlencode($arrayR[5]) . ",'f', $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20]" . "&rnd=" . $round_no. "&call_from=" . $call_from;
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } elseif ($j == 4) {
                                        if ($arrayR[19] == '') {
                                            $arrayR[19] = "NULL";
                                        }
                                        
                                        if ($arrayR[20] == '') {
                                            $arrayR[20] = "NULL";
                                        }
                                        
                                        $php_ref = "./spa_html.php?spa=EXEC spa_gen_invoice_variance_report $arrayR[2], $arrayR[3], $arrayR[4]," . urlencode($arrayR[5]) . ",'h', $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20]" . "&rnd=" . $round_no. "&call_from=" . $call_from;
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } elseif ($item == "'Volume'" || $item == "'OnPeak+Volume'" || $item == "'OffPeak+Volume'") {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                } elseif (count($arrayR) == 7 && $arrayR[5] != "'f'") {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 2 && $arrayR[5] != 'null') {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 4 && $arrayR[6] == "'h'") {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 3) {
                                    $php_ref = "./spa_html.php?spa=EXEC spa_gen_invoice_variance_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], 'h', $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17] " . "&rnd=" . $round_no. "&call_from=" . $call_from;
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($fields == 5) {
                                    $php_ref = "./spa_html.php?spa=EXEC spa_gen_invoice_variance_report $arrayR[2], $arrayR[3], $arrayR[4], $item, 'h', $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17] " . "&rnd=" . $round_no. "&call_from=" . $call_from;
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "spa_create_hourly_position_report" && ($fields == 4 || $fields == 5)) {
                                if (($j == 2)) {
                                    $drill_index = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $drill_term = "'" . getStdDateFormat($result[($tmpIndex - $j + 1)]) . "'";
                                    $drill_uom = "'" . $result[($tmpIndex - $j + 5)] . "'";

                                    if ($arrayR[48] == ''){
                                        $arrayR[48] = 'NULL';
                                    }

                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_create_hourly_position_report 'h', $arrayR[3], $arrayR[4], " . "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12],$arrayR[13],$arrayR[14],$arrayR[15],$arrayR[16],$arrayR[17],$arrayR[18],$arrayR[19],$arrayR[20],$arrayR[21],$arrayR[22],$arrayR[23],$arrayR[24],$arrayR[25],$arrayR[26],$arrayR[27],$arrayR[28],$arrayR[29],$arrayR[30],$arrayR[31],$arrayR[32],$arrayR[33],$arrayR[34],$arrayR[35],$arrayR[36],$drill_index,$drill_term,$arrayR[2],NULL,$drill_uom,NULL,$arrayR[43],$arrayR[44],$arrayR[45], $arrayR[46], $arrayR[47], $arrayR[48]");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "spa_create_hourly_position_report" && ($fields == 6)) {
                                if (($j == 3)) {
                                    $drill_index = "'" . $result[($tmpIndex - $j + 0)] . "'";

                                    if ($arrayR[2] == "'d'") {
                                        $drill_term = "'" . getStdDateFormat($result[($tmpIndex - $j + 2)]) . "'";
                                    } else {
                                        $drill_term = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    }

                                    if ($arrayR[2] == "'d'") {
                                        $drill_term = "'" . getStdDateFormat($result[($tmpIndex - $j + 2)]) . "'";
                                    } else {
                                        $drill_term = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    }

                                    $drill_uom = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $physical_financial = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    
                                    if (trim($physical_financial, "'") == 'Financial') {
                                        $physical_financial = 'f';
                                    } elseif (trim($physical_financial, "'") == 'Physical') {
                                        $physical_financial = 'p';
                                    }

                                    $drill_index = urlencode($drill_index);

                                    if ($arrayR[43] == "") {
                                        $arrayR[43] = "NULL";
                                    }

                                    if ($arrayR[44] == "") {
                                        $arrayR[44] = "NULL";
                                    }

                                    if ($arrayR[45] == "") {
                                        $arrayR[45] = "NULL";
                                    }

                                    if ($arrayR[46] == "") {
                                        $arrayR[46] = "NULL";
                                    }

                                    if ($arrayR[47] == "") {
                                        $arrayR[47] = "NULL";
                                    }

                                    if ($arrayR[48] == "") {
                                        $arrayR[48] = "NULL";
                                    }

                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_create_hourly_position_report 'h', $arrayR[3], $arrayR[4], " . "$arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12],$arrayR[13],$arrayR[14],$arrayR[15],$arrayR[16],$arrayR[17],$arrayR[18],$arrayR[19],$arrayR[20],$arrayR[21],$arrayR[22],$arrayR[23],$arrayR[24],$physical_financial,$arrayR[26],$arrayR[27],$arrayR[28],$arrayR[29],$arrayR[30],$arrayR[31],$arrayR[32],$arrayR[33],$arrayR[34],$arrayR[35],$arrayR[36],$drill_index,$drill_term,$arrayR[2],NULL,$drill_uom,NULL,$arrayR[43],$arrayR[44], $arrayR[45], $arrayR[46], $arrayR[47], $arrayR[48]");
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\" \>" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "spa_create_hourly_position_report" && ($fields == 7)) {
                                if (($j == 4)) {
                                    $drill_index = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    
                                    if ($arrayR[2] == "'d'") {
                                        $drill_term = "'" . getStdDateFormat($result[($tmpIndex - $j + 2)]) . "'";
                                    } else {
                                        $drill_term = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    }
                                    
                                    if ($arrayR[2] == "'d'") {
                                        $drill_term = "'" . getStdDateFormat($result[($tmpIndex - $j + 3)]) . "'";
                                    } else {
                                        $drill_term = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    }

                                    $drill_uom = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    $physical_financial = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_loc = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    
                                    if (trim($physical_financial, "'") == 'Financial') {
                                        $physical_financial = 'f';
                                    } elseif (trim($physical_financial, "'") == 'Physical') {
                                        $physical_financial = 'p';
                                    }

                                    $drill_index = urlencode($drill_index);

                                    if ($arrayR[43] ?? "" == "") {
                                        $arrayR[43] = "NULL";
                                    }

                                    if ($arrayR[44] ?? "" == "") {
                                        $arrayR[44] = "NULL";
                                    }

                                    if ($arrayR[45] ?? "" == "") {
                                        $arrayR[45] = "NULL";
                                    }

                                    if ($arrayR[46] ?? "" == "") {
                                        $arrayR[46] = "NULL";
                                    }

                                    if ($arrayR[47] ?? "" == "") {
                                        $arrayR[47] = "NULL";
                                    }

                                    if ($arrayR[48] ?? "" == "") {
                                        $arrayR[48] = "NULL";
                                    }
                                    
                                    if ($drill_loc == "") {
                                        $drill_loc = "NULL";
                                    }
                            
                                    $build_exec_code[$tmpIndex] = urldecode("EXEC spa_create_hourly_position_report 'h', 
                                        $arrayR[3], 
                                        $arrayR[4], 
                                        " . "$arrayR[5], 
                                        $arrayR[6], 
                                        $arrayR[7], 
                                        $arrayR[8], 
                                        $arrayR[9],
                                        $arrayR[10], 
                                        $arrayR[11], 
                                        $arrayR[12], 
                                        $arrayR[13], 
                                        $arrayR[14], 
                                        $arrayR[15], 
                                        $arrayR[16],
                                        $arrayR[17],
                                        $arrayR[18],
                                        $arrayR[19],
                                        $arrayR[20],
                                        $arrayR[21],
                                        $arrayR[22],
                                        $arrayR[23],
                                        $arrayR[24],
                                        $physical_financial,
                                        $arrayR[26],
                                        $arrayR[27],
                                        $arrayR[28],
                                        $arrayR[29],
                                        $arrayR[30],
                                        $arrayR[31],
                                        $arrayR[32],
                                        $arrayR[33],
                                        $arrayR[34],
                                        $arrayR[35],
                                        $arrayR[36],
                                        $drill_index,
                                        $drill_term,
                                        $arrayR[2],
                                        NULL,
                                        $drill_uom,
                                        NULL,
                                        $arrayR[43],
                                        $arrayR[44],
                                        $arrayR[45],
                                        $arrayR[46],
                                        $arrayR[47],
                                        $arrayR[48],
                                        $drill_loc"
                                    );
                                    $data = encloseTD("<A href=\"javascript:void(0);\" onclick=\"run_exec_code($tmpIndex)\" \>" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif (strpos($sql, "spa_run_wght_avg_inventory_cost_report") != false) {
                                if ($j == 8) {
                                    $group_name = "'" . $result[($tmpIndex - $j)] . "'";
                                    $account_name = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $gl_name = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $as_of_date = "'" . getStdDateFormat($result[($tmpIndex - $j + 4)]) . "'";
                                    $term_date = "'" . getStdDateFormat($result[($tmpIndex - $j + 5)]) . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_run_wght_avg_inventory_cost_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $as_of_date, $group_name, $account_name, $gl_name, $term_date";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ((strpos($sql, "spa_run_emissions_intensity_report") != false) && $arrayR[4] != "'16'") {
                                if ($arr_list[4] != "'15'") {
                                    $tmpIndexVar = $tmpIndex;

                                    if ($j == 1) {
                                        $tmpIndexVar = $tmpIndex;
                                    }

                                    if ($arrayR[4] == "'6'" || $arrayR[4] == "'1'") {
                                        $generator = "'" . $result[($tmpIndex - $j)] . "'";
                                        $curve = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    } else {
                                        $generator = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                        $curve = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    }

                                    $sub = "'" . $result[($tmpIndex - $j)] . "'";
                                    $drill_criteria = "'" . $result[($tmpIndex - $j + 1)] . "'";

                                    if ((($j > 1 && ($arr_list[4] == "'1'")) || ($j > 2 && ($arr_list[3] == "'1'" || $arr_list[3] == "'5'" || $arr_list[3] == "'6'")) || ($j > 2 && ($arr_list[3] == "'2'" || $arr_list[3] == "'3'" || $arr_list[3] == "'4'"))) && $j < $fields - 1) {
                                        if (trim($arr_list[26]) == "'703'") {
                                            if ($arr_list[4] == "'5'") {
                                                $spa = "EXEC spa_get_emissions_inventory s, NULL, NULL, '" . $fieldNames[$j] . "-01', '" . $fieldNames[$j] . "-01',NULL, $curve,'', NULL, $generator, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $arrayR[15], 'n', 's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', NULL, $sub, NULL, $arrayR[31]";
                                            } else {
                                                $spa = "EXEC spa_run_emissions_intensity_report $arrayR[2], $arrayR[3], '5', $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $generator, $arrayR[4], $arrayR[31]";
                                            }
                                        } elseif (trim($arr_list[26]) == "'706'") {
                                            $newStartDate = $fieldNames[$j] . '-01-01';
                                            $newEndDate = $fieldNames[$j] . '-12-31';
                                            
                                            if ($arr_list[4] == "'5'") {
                                                $spa = "EXEC spa_get_emissions_inventory s, NULL, NULL, '" . $newStartDate . "','" . $newEndDate . "', NULL, $curve, '', NULL, $generator, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $arrayR[15], 'n', 's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', NULL, $sub, NULL, $arrayR[31]";
                                            } else {
                                                $spa = "EXEC spa_run_emissions_intensity_report $arrayR[2], $arrayR[3], '5', $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $generator, $arrayR[4], $arrayR[31]";
                                            }
                                        } elseif (trim($arr_list[26]) == "'704'") {
                                            $qtr = explode("-", $fieldNames[$j]);
                                            $tmpYr = $qtr[0];

                                            if ($qtr[1] == 'Q1') {
                                                $startMth = '01';
                                                $endMth = '03';
                                            } elseif ($qtr[1] == 'Q2') {
                                                $startMth = '04';
                                                $endMth = '06';
                                            } elseif ($qtr[1] == 'Q3') {
                                                $startMth = '07';
                                                $endMth = '09';
                                            } elseif ($qtr[1] == 'Q4') {
                                                $startMth = '10';
                                                $endMth = '12';
                                            }

                                            $newStartDate = $tmpYr . '-' . $startMth . '-01';
                                            $newEndDate = $tmpYr . '-' . $endMth . '-01';

                                            if ($arr_list[4] == "'5'") {
                                                $spa = "EXEC spa_get_emissions_inventory s, NULL, NULL, '" . $newStartDate . "', '" . $newEndDate . "', NULL, $curve, '', NULL, $generator, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $arrayR[15], 'n', 's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', NULL, $sub, NULL, $arrayR[31]";
                                            } else {
                                                $spa = "EXEC spa_run_emissions_intensity_report $arrayR[2], $arrayR[3], '5', $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $generator, $arrayR[4], $arrayR[31]";
                                            }
                                        } elseif (trim($arr_list[26]) == "'705'") {
                                            //echo 'hi' . "<br>";
                                            $qtr = explode("-", $fieldNames[$j]);
                                            $tmpYr = $qtr[0];

                                            if ($qtr[1] == '1st') {
                                                $startMth = '01';
                                                $endMth = '06';
                                            } elseif ($qtr[1] == '2nd') {
                                                $startMth = '07';
                                                $endMth = '12';
                                            }

                                            $newStartDate = $tmpYr . '-' . $startMth . '-01';
                                            $newEndDate = $tmpYr . '-' . $endMth . '-01';

                                            if ($arr_list[4] == "'5'") {
                                                $spa = "EXEC spa_get_emissions_inventory s, NULL, NULL, '" . $newStartDate . "', '" . $newEndDate . "', NULL, $curve, '', NULL, $generator, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $arrayR[15], 'n', 's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', NULL, $sub, NULL, $arrayR[31]";
                                            } else {

                                                $spa = "EXEC spa_run_emissions_intensity_report $arrayR[2], $arrayR[3], '5', $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $generator, $arrayR[4], $arrayR[31]";
                                            }
                                        }

                                        $php_ref = "./spa_html.php?spa=" . $spa;
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "spa_get_emissions_inventory" && ($fields == 10 || $fields == 12 || $fields == 13 || $fields == 15 || $fields == 9) && $arrayR[2] != "'f'") {
                                $emissions_reductions = "";
                                $drill_sub = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                $drill_uom = "'" . $result[($tmpIndex - $j + 8)] . "'";
                                $drill_term = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                $drill_as_of_date = "'" . $result[($tmpIndex - $j + 4)] . "'";

                                if ($arrayR[25] == "'s'") {
                                    $drill_generator_name = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $drill_curve = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $forecast_type = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_generator_name));
                                    
                                    if (count($pieces) > 1) {
                                        $drill_generator_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                    }
                                } else {
                                    $drill_generator_name = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $drill_curve = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $forecast_type = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", $drill_generator_name));
                                    
                                    if (count($pieces) > 1) {
                                        $drill_generator_name = "'" . str_replace("<l>", "", $pieces[1]) . "'";
                                    }
                                }
                                
                                if ($j == 7) {
                                    $emissions_reductions = 'e';
                                } elseif ($j == 9) {
                                    $emissions_reductions = 'r';
                                }

                                $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory 'd', NULL, $drill_as_of_date, $arrayR[5], $arrayR[6], $arrayR[7], " . "$drill_curve, $drill_uom, $drill_term, $drill_generator_name, $emissions_reductions, $forecast_type, $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $drill_sub, NULL, $arrayR[39], 'n'";
                                
                                if ($arrayR[2] == "s" && ($j == 7)) {
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } elseif ($arrayR[2] == "'d'" && $j == 8 && strtoupper(trim($result[($tmpIndex - $j + 8)])) == "NESTED FORMULA") {
                                    $drill_formula = "'" . $result[($tmpIndex - $j + 8)] . "'";
                                    $drill_curve = "'" . $result[($tmpIndex - $j + 5)] . "'";
                                    $drill_uom = "'" . $result[($tmpIndex - $j + 6)] . "'";
                                    $drill_term = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_get_emissions_inventory 'f', $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], " . "$drill_curve, $drill_uom, $drill_term, $arrayR[11], $arrayR[12], $arrayR[13], NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $drill_sub, NULL, $arrayR[39], 'n'";
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif (($report_name == "spa_REC_Target_Report" || $report_name == "spa_REC_Target_Report_Drill") && (((($fields == 17 && $j == 9) || ($fields == 10 && $j == 6) || ($fields == 14 && $j == 10)) && ($arrayR[25] == "'n'")) || ($arrayR[25] == "'y'" && $j >= 5 && $j < $fields - 1 && $arrayR[7] != "'d'")) && $arrayR[36] == "'t'") {
                                if ($fields == 17 && $j == 9 && $arrayR[25] == "'n'") {
                                    $deal_id = $result[($tmpIndex - $j + 4)];
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", $deal_id));
                                    $deal_id = $pieces[1];
                                    $php_ref = "./spa_html.php?spa=EXEC spa_create_lifecycle_of_recs $arrayR[2], NULL, '$deal_id'";
                                } elseif ((($fields == 10 and $j == 6) || ($fields == 14 and $j == 10)) && $arrayR[25] == "'n'") {
                                    $generator = "NULL";
                                    $gen_date = "NULL";
                                    $year = "";
                                    $assignment = "";
                                    $obligation = "";
                                    $type = "";
                                    
                                    if ($fields == 10) {
                                        $state = $result[($tmpIndex - $j + 4)];
                                        $year = $result[($tmpIndex - $j + 5)];
                                        $assignment = $result[($tmpIndex - $j + 2)];
                                        $obligation = $result[($tmpIndex - $j + 1)];
                                        $type = $result[($tmpIndex - $j + 3)];
                                        
                                        if ($year == '') {
                                            $year = "NULL";
                                        }
                                    } else {
                                        $state = $result[($tmpIndex - $j + 4)];
                                        $generator = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                        $gen_date = "'" . $result[($tmpIndex - $j + 9)] . "'";
                                        $year = $result[($tmpIndex - $j + 5)];
                                        $assignment = $result[($tmpIndex - $j + 6)];
                                        $obligation = $result[($tmpIndex - $j + 7)];
                                        $type = $result[($tmpIndex - $j + 8)];
                                    }

                                    if ($state != "" && $state != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $state));
                                        $state = $pieces[1];
                                    }
                                    
                                    $included_banked = "n";
                                    $curve_id = "NULL";
                                    $generator_id = "NULL";
                                    $convert_uom_id = "NULL";
                                    $convert_assignment_type_id = "NULL";
                                    $deal_id_from = "NULL";
                                    $deal_id_to = "NULL";
                                    $gis_cert_number = "NULL";
                                    $gis_cert_number_to = "NULL";
                                    
                                    if (count($arrayR) > 10) {
                                        $included_banked = $arrayR[10];
                                        $curve_id = $arrayR[11];
                                        $generator_id = $arrayR[14];
                                        $convert_uom_id = $arrayR[15];
                                        $convert_assignment_type_id = $arrayR[16];
                                        $deal_id_from = $arrayR[17];
                                        $deal_id_to = $arrayR[18];
                                        $gis_cert_number = $arrayR[19];
                                        $gis_cert_number_to = $arrayR[20];
                                        $generation_state = $arrayR[21];
                                    }
                                    
                                    $php_ref = "./spa_html.php?spa=EXEC spa_REC_Target_Report_Drill $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[8], $arrayR[9], $included_banked, $curve_id" . ", $generator_id, $convert_uom_id, $convert_assignment_type_id, $deal_id_from, $deal_id_to,  $gis_cert_number, $gis_cert_number_to, $generation_state, $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], NULL" . ", '" . $result[($tmpIndex - $j + 0)] . "'" . ", $generator" . ", $gen_date" . ", '" . $state . "'" . ", " . $year . ", '" . $assignment . "'" . ", '" . $obligation . "'" . ", '" . $type . "'";
                                } elseif ($arrayR[25] == "'y'") {
                                    $state = $result[($tmpIndex - $j + 4)];
                                    $year = $fieldNames[$j];
                                    $assignment = $result[($tmpIndex - $j + 2)];
                                    $obligation = $result[($tmpIndex - $j + 1)];
                                    $type = $result[($tmpIndex - $j + 3)];
                                    
                                    if ($state != "" && $state != "''") {
                                        $pieces = explode("<u>", str_replace("</u>", "<u>", $state));
                                        
                                        if (count($pieces) > 1) {
                                            $state = $pieces[1];
                                        }
                                    }

                                    $php_ref = "./spa_html.php?spa=EXEC spa_REC_Target_Report_Drill $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[8], $arrayR[9], $arrayR[10],  $arrayR[11], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], 'n', $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], NULL, '" . $result[($tmpIndex - $j + 0)] . "', NULL, NULL, '" . $state . "'" . ", '" . $year . "', '" . $assignment . "'" . ", '" . $obligation . "'" . ", '" . $type . "'";
                                }

                                if ($fields == 19 && $arrayR[25] == "'y'" && $arrayR[7] == "null") {
                                    $data = encloseTD($result[$tmpIndex], $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "spa_Create_Inventory_Journal_Entry_Report" && (($fields == 9 || $fields == 7 || ($fields == 8 && $arrayR[7] != "'t'") || $fields == 10 || $fields == 11 || $fields == 6 || ($fields == 5 && $arrayR[8] == "'j'")) && $j == 1)) {
                                $as_of_date = $result[($tmpIndex - $j)];
                                $state_value_id = "NULL";

                                if (count($arrayR) > 13) {
                                    $state_value_id = $arrayR[13];
                                }

                                if ($fields == 9) {
                                    $deal_id = $result[($tmpIndex - $j + 2)];
                                    $pieces = explode("<u>", str_replace("</u>", "<u>", $deal_id));
                                    $deal_id = $pieces[1];
                                    $php_ref = "./spa_html.php?spa=EXEC spa_create_lifecycle_of_recs '$as_of_date', NULL, '$deal_id'";
                                } elseif ($fields == 10 && $arrayR[7] == "'g'") {
                                    $production_month = $result[($tmpIndex - $j + 4)] . "-01";
                                    $counterparty = "'" . $result[($tmpIndex - $j + 3)] . "'";
                                    $gl_number = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_Create_Inventory_Journal_Entry_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, '$as_of_date', '$production_month', $counterparty, $gl_number&enable_paging=true";
                                } elseif ($fields == 11 && $arrayR[7] == "'g'") {
                                    $production_month = $result[($tmpIndex - $j + 5)] . "-01";
                                    $counterparty = "'" . $result[($tmpIndex - $j + 4)] . "'";
                                    $gl_number = "'" . $result[($tmpIndex - $j + 1)] . "'";
                                    $as_of_date = "'" . $result[($tmpIndex - $j + 0)] . "'";
                                    $php_ref = "./spa_html.php?spa=EXEC spa_Create_Inventory_Journal_Entry_Report $arrayR[2], NULL, $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, $as_of_date, '$production_month', $counterparty, $gl_number&enable_paging=true";
                                } elseif ($fields == 8 || ($arrayR[8] == "'j'" && $fields == 6) || ($arrayR[8] == "'j'" && $fields == 7)) {
                                    $production_month = getStdDateFormat($result[($tmpIndex - $j + 1)]);
                                
                                    if ($arrayR[8] == "'t'" || $fields == 7 || $fields == 8) {
                                        $counterparty = "'" . $result[($tmpIndex - $j + 2)] . "'";
                                    } else{
                                        $counterparty = "NULL";
                                    }

                                    $php_ref = "./spa_html.php?call_from=" . $call_from . "&spa=exec spa_Create_Inventory_Journal_Entry_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, '" . getStdDateFormat($as_of_date) . "', '$production_month',$counterparty, NULL&enable_paging=true";
                                } else {
                                    $php_ref = "./spa_html.php?call_from=" . $call_from . "&spa=EXEC spa_Create_Inventory_Journal_Entry_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, '" . getStdDateFormat($as_of_date) . "', NULL";
                                }

                                if ($arrayR[7] != "'g'") {
                                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } elseif ($report_name == "spa_run_ghg_goal_tracking_report") {
                                if (isset($_REQUEST['level'])) {
                                    $level = trim($_REQUEST['level']);
                                } else {
                                    if ($arrayR[27] == "'1'") {
                                        $level = 1;
                                    } else {
                                        $level = 0;
                                    }
                                }

                                if (strstr($arrayR[29], '-2')) {
                                    $base = true;
                                } else {
                                    $base = false;
                                }

                                if ($level == 0) {
                                    if ($j == 0) {
                                        $tmpIndexVar = $tmpIndex;
                                    }

                                    if ($arrayR[27] > "'1'" && $base == true) {
                                        if (($j > 1 && $j <= ($fields - 3))) {
                                            $spa_old = $sql;

                                            if ($arrayR[27] == "'5'") {
                                                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                            } else {

                                                $spa_modify = $level . ",'" . $result[$tmpIndexVar] . "'";
                                                $spa_new = $spa_old . ", '" . $result[$fields - 1] . "'," . $spa_modify;
                                                $level++;
                                                $php_ref = "./spa_html.php?spa=" . urlencode($spa_new) . "&level=" . $level . "&spa_modify=" . $spa_modify;

                                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                            }
                                        } else {
                                            $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                        }
                                    } else {
                                        if (($j >= 1 && $j <= ($fields - 3)) && $base == false) {
                                            $spa_old = $sql;
                                            
                                            if ($arrayR[27] == "'5'") {
                                                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                            } else {
                                                $spa_modify = $level . ",'" . $result[$tmpIndexVar] . "'";
                                                $spa_new = $spa_old . ", '" . $result[$fields - 1] . "'," . $spa_modify;
                                                $level++;
                                                $php_ref = "./spa_html.php?spa=" . urlencode($spa_new) . "&level=" . $level . "&spa_modify=" . $spa_modify;
                                                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                            }
                                        } else {
                                            $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                        }
                                    }
                                } elseif ($level == 1 && $arrayR[27] == "'1'") {
                                    if ($j == 0) {
                                        $tmpIndexVar = $tmpIndex;
                                    }

                                    if ((($j > 1) || (($j >= 1) && $base == false) || ($j > 0 && $arrayR[27] != "'1'")) && $j < $fields - 2) {
                                        $spa_old = "./spa_html.php?spa=EXEC spa_run_ghg_goal_tracking_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], $arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], $arrayR[26], $arrayR[27], $arrayR[28], $arrayR[29], $arrayR[30], $arrayR[31], $arrayR[32], $arrayR[33], $arrayR[34], $arrayR[35], $arrayR[36], $arrayR[37], $arrayR[38], $arrayR[39], $arrayR[40], $arrayR[41], $arrayR[42], $arrayR[43], $arrayR[44], $arrayR[45], $arrayR[46], $arrayR[47], $arrayR[48], $arrayR[49], $arrayR[50], $arrayR[51], $arrayR[52], $arrayR[53], $arrayR[54], $arrayR[55], $arrayR[56], $arrayR[57], $arrayR[58], $arrayR[59]";

                                        if ($j == 1 && ($arrayR[29] == "'-2, -1'" || $arrayR[29] == "'-2'" || $arrayR[29] == "'-2, 291202, -1'" || $arrayR[29] == "'-2, 291202'")) {
                                            $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                        } elseif ($arrayR[44] == "'y'" && $j != 4) {
                                            $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                        } else {
                                            $spa_modify = $level . ", 'NULL','" . $result[$tmpIndexVar] . "','" . $fieldNames[$j] . "'";
                                            $spa_new = $spa_old . ", '" . $result[$fields - 1] . "'," . $spa_modify;
                                            $level++;
                                            $php_ref = "./spa_html.php?spa=" . ($spa_new) . "&level=" . $level . "&spa_modify=" . $spa_modify;
                                            $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                        }
                                    } else {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } elseif (($level == 1 && $arrayR[27] != "'1'")) {
                                    if ($j == 0) {
                                        $tmpIndexVar = $tmpIndex;
                                    }

                                    if ($j > 1 && $j < $fields - 2) {
                                        $spa_old = $sql;
                                        $spa_modify = stripslashes(urldecode($_REQUEST['spa_modify']));
                                        $spa_modify = $spa_modify . ", '" . $result[$tmpIndexVar] . "'";
                                        $spa_old = $spa_old . ", '" . $result[$tmpIndexVar] . "'";

                                        // Modify spa_modify for next graph level
                                        $spa_modify_explode = explode(",", $spa_modify);

                                        $spa_modify_temp = '';

                                        // Exclude $level value from spa_modify
                                        for ($iLoop = 1; $iLoop < count($spa_modify_explode); $iLoop++) {
                                            $spa_modify_temp = $spa_modify_temp . ", " . $spa_modify_explode[$iLoop];
                                        }

                                        $level = trim($_REQUEST['level']);

                                        // Concate $spa_modify_temp with new $level value and pass to $spa_modify_replace
                                        $spa_modify_replace = $level . $spa_modify_temp;
                                        // Replace matched $spa_modify string with $spa_modify_replace in $spa
                                        $spa_new = str_replace($spa_modify, $spa_modify_replace, $spa_old) . ",'" . $fieldNames[$j] . "'";
                                        $spa_modify_replace = $spa_modify_replace . ",'" . $fieldNames[$j] . "'";
                                        $level++;

                                        $php_ref = "./spa_html.php?spa=" . urlencode($spa_new) . "&level=" . $level . "&spa_modify=" . urlencode($spa_modify_replace);
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else if ($j == 1 && $j < $fields - 2 && $base == false) {
                                        $spa_old = $sql;
                                        $spa_modify = stripslashes(urldecode($_REQUEST['spa_modify']));
                                        $spa_modify = $spa_modify . ", '" . $result[$tmpIndexVar] . "'";
                                        $spa_old = $spa_old . ", '" . $result[$tmpIndexVar] . "'";

                                        // Modify spa_modify for next graph level
                                        $spa_modify_explode = explode(",", $spa_modify);
                                        $spa_modify_temp = '';
                                        
                                        // Exclude $level value from spa_modify
                                        for ($iLoop = 1; $iLoop < count($spa_modify_explode); $iLoop++) {
                                            $spa_modify_temp = $spa_modify_temp . ", " . $spa_modify_explode[$iLoop];
                                        }

                                        $level = trim($_REQUEST['level']);
                                        
                                        // Concate $spa_modify_temp with new $level value and pass to $spa_modify_replace
                                        $spa_modify_replace = $level . $spa_modify_temp;

                                        // Replace matched $spa_modify string with $spa_modify_replace in $spa
                                        $spa_new = str_replace($spa_modify, $spa_modify_replace, $spa_old) . ",'" . $fieldNames[$j] . "'";
                                        
                                        $spa_modify_replace = $spa_modify_replace . ",'" . $fieldNames[$j] . "'";

                                        $level++;

                                        $php_ref = "./spa_html.php?spa=" . urlencode($spa_new) . "&level=" . $level . "&spa_modify=" . urlencode($spa_modify_replace);
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } elseif ($level >= 1 && $level <= 4) {
                                    if ($j == 0) {
                                        $tmpIndexVar = $tmpIndex;
                                    }

                                    if ($j >= 1 && $j < $fields - 1) {
                                        $spa_old = $sql;
                                        $spa_modify = stripslashes(urldecode($_REQUEST['spa_modify']));

                                        // Add modified value to spa_modify
                                        $spa_modify = $spa_modify . ", '" . $result[$tmpIndexVar] . "'";
                                        $spa_old = $spa_old . ", '" . $result[$tmpIndexVar] . "'";

                                        // Modify spa_modify for next graph level
                                        $spa_modify_explode = explode(",", $spa_modify);

                                        $spa_modify_temp = '';

                                        // Exclude $level value from spa_modify
                                        for ($iLoop = 1; $iLoop < count($spa_modify_explode); $iLoop++) {
                                            $spa_modify_temp = $spa_modify_temp . ", " . $spa_modify_explode[$iLoop];
                                        }

                                        $level = trim($_REQUEST['level']);

                                        // Concate $spa_modify_temp with new $level value and pass to $spa_modify_replace
                                        $spa_modify_replace = $level . $spa_modify_temp;

                                        // Replace matched $spa_modify string with $spa_modify_replace in $spa
                                        $spa_new = str_replace($spa_modify, $spa_modify_replace, $spa_old);

                                        $level++;

                                        $php_ref = "./spa_html.php?spa=" . urlencode($spa_new) . "&level=" . $level . "&spa_modify=" . urlencode($spa_modify_replace);

                                        if (strstr($arrayR[29], '-2')) {
                                            $match = true;
                                        } else {
                                            $match = false;
                                        }

                                        if ($j == 1 && $match == false) {
                                            $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                        } else if ($j == 1 && $match == true) {
                                            $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                        } else {
                                            $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                        }
                                    } else {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } elseif ($level == 5) {

                                    if (strstr($arrayR[29], '-2')) {
                                        $match = true;
                                    } else {
                                        $match = false;
                                    }

                                    if ($j == 0 && $match == false) {
                                        $tmpIndexDrillGeneratorName = $tmpIndex + 0;
                                        $tmpIndexTermStart = $tmpIndex + 3;
                                        $tmpIndexTermEnd = $tmpIndex + 4;
                                        $tmpIndexForecast = $tmpIndex + 5;
                                    } else if ($j == 0 && $match == true) {
                                        $tmpIndexDrillGeneratorName = $tmpIndex + 0;
                                        $tmpIndexTermStart = $tmpIndex + 4;
                                        $tmpIndexTermEnd = $tmpIndex + 5;
                                        $tmpIndexForecast = $tmpIndex + 6;
                                    }
                                    
                                    if ($j == 1 && $match == false) {
                                        $uom_id = $arrayR[21];

                                        // Backup current spa for further purpose
                                        $spa_old = $sql;

                                        // Replace matched $spa_modify string with $spa_modify_replace in $spa
                                        $spa_new = "EXEC spa_get_emissions_inventory s, NULL, NULL, '" . $result[$tmpIndexTermStart] . "', '" . $result[$tmpIndexTermEnd] . "', '" . $result[$tmpIndexForecast] . "', NULL, NULL, NULL, '" . $result[$tmpIndexDrillGeneratorName] . "', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $arrayR[9], " . $uom_id . ", $arrayR[26], 's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, $arrayR[59]";
                                        
                                        $php_ref = "./spa_html.php?spa=" . $spa_new;
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else if ($j == 2 && $match == true) {
                                        $uom_id = $arrayR[21];

                                        // Backup current spa for further purpose
                                        $spa_old = $sql;

                                        // Replace matched $spa_modify string with $spa_modify_replace in $spa
                                        $spa_new = "EXEC spa_get_emissions_inventory s, NULL, NULL, '" . $result[$tmpIndexTermStart] . "', '" . $result[$tmpIndexTermEnd] . "', '" . $result[$tmpIndexForecast] . "', NULL, NULL, NULL, '" . $result[$tmpIndexDrillGeneratorName] . "', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $arrayR[9], " . $uom_id . ", $arrayR[26], 's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'n', NULL, NULL, NULL, $arrayR[59], 'y'";
                                        
                                        $php_ref = "./spa_html.php?spa=" . $spa_new;
                                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                                    } else {
                                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                    }
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                }
                            } else {
                                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                            }
                        } else {                
                            if ($report_name == "spa_Create_Hedges_Measurement_Report" && ($fields == 20 || $fields == 21) && $j == 4) {
                                $link_id = "";
                                
                                if (trim($result[$tmpIndex - $j + 5]) == "D") {
                                    $link_id = $result[$tmpIndex - $j + 4] . "-D";
                                } else {
                                    $link_id = $result[$tmpIndex - $j + 4];
                                }

                                $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "LINK", $link_id, "NULL", $arrayR);
            
                                $php_ref = str_replace("'", "^", $php_ref);
                                $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . $result[$tmpIndex] . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } elseif ($report_name == "spa_Create_Hedges_Measurement_Report" && ($fields == 20 || $fields == 21) && $j == 7 && trim($result[$tmpIndex - $j + 7]) != "N/A") {
                                $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "Assessment", $result[$tmpIndex - $j + 4], "NULL", $arrayR);
                                $php_ref = str_replace("'", "^", $php_ref);
                                $data = encloseTD("<A HREF=\"javascript:window.top.open_report_in_viewport('$php_ref')\">" . $result[$tmpIndex] . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                            } else {
                                $data = encloseTD($result[$tmpIndex], $clm_sub_col_span, $clm_tot_col_span);
                                
                                if (!isset($clm_total_format[$j])) {
                                    $data = encloseTD(my_number_format('N', $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                                } else {
                                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);    
                                }
                            } 
                        }
                    }
                    
                    if ($sub_total_pre_str == $sub_total_str && $show_header == 'false') {
                        if ($j == 0) {
                            $data = encloseTD("", $clm_sub_col_span, $clm_tot_col_span);
                        }
                    }

                    //keep total
                    if ($report_name != "") {
                        if ($j > $report_total_clm_start) {
                            $total_result = $result[$tmpIndex];
                            $pieces = explode("</font>", $result[$tmpIndex]);
                            
                            if (count($pieces) > 1) {
                                $pieces_1 = explode(">", $pieces[0]);
                                $total_result = $pieces_1[1];
                            }

                            if ($clm_total_format[$j] != "N") {
                                $clm_total[$j] =  ((float) ($clm_total[$j] ?? 0)) + ((float) ($total_result ?? 0));
                            } else {
                                $clm_total[$j] = "";
                            }

                            if ($sub_total_clm >= 0) {
                                if ($sub_total_pre_str == "" || $sub_total_str == $sub_total_pre_str) {

                                    if ($clm_total_format[$j] != "N") {
                                        $clm_sub_total[$j] = ((float)($clm_sub_total[$j] ?? 0)) + ((float)$total_result);
                                    } else {
                                        $clm_sub_total[$j] = "";
                                    }
                                }
                            }
                        }
                    }

                    if ($report_name1 == "spa_trader_Position_Report") {
                        if ($arrayR > 35) {
                            $round_value = $arrayR[35];
                        }

                        $round_value = str_replace("'", "", $round_value);
                        
                        if (isset($moneyFormatRow) == false) {
                            $moneyFormatRow = '-1';
                        }
                        
                        if (isset($blankRow) == false) {
                            $blankRow = '-1';
                        }
                        
                        if (isset($boldRow) == false) {
                            $boldRow = '-1';
                        }
                        
                        if (isset($round2Row) == false) {
                            $round2Row = '-1';
                        }

                        $result[$tmpIndex] = str_replace("  ", " ", $result[$tmpIndex]);

                        if ($j == 0 &&
                            (stripos($result[$tmpIndex], 'FULL LOAD UNIT COST') > -1
                                || stripos($result[$tmpIndex], 'TOTAL MTM') > -1
                                || stripos($result[$tmpIndex], 'AVG  UNIT COST') > -1
                            )
                        ) {
                            $moneyFormatRow = $i;
                        }

                        if ($j == 0 
                            && (stripos($result[$tmpIndex], 'POWER ON PEAK (std product MW)') > -1 
                                || stripos($result[$tmpIndex], 'POWER OFF PEAK (std product MW)') > -1 
                                || stripos($result[$tmpIndex], 'GAS (MMBTU/day)') > -1
                            )
                        ) {
                            $blankRow = $i;
                        }

                        if ($j == 0 
                            && (stripos($result[$tmpIndex], 'POWER ON PEAK (std product MW)') > -1 
                                || stripos($result[$tmpIndex], 'POWER OFF PEAK (std product MW)') > -1 
                                || stripos($result[$tmpIndex], 'GAS (MMBTU/day)') > -1 
                                || stripos($result[$tmpIndex], 'TOTAL MTM') > -1
                            )
                        ) {
                            $html_str .= '<tr><td bgcolor="#CCCCCC" class="side">&nbsp;</td><td colspan="1000" >&nbsp;</td></tr>';
                        }

                        if ($j == 0 
                            && (stripos($result[$tmpIndex], 'TOTAL On Peak (Price Position)') > -1
                                || stripos($result[$tmpIndex], 'TOTAL  On Peak (Physical Position)') > -1
                                || stripos($result[$tmpIndex], 'TOTAL Off Peak (Price Position)') > -1
                                || stripos($result[$tmpIndex], 'TOTAL  Off Peak (Physical Position)') > -1
                                || stripos($result[$tmpIndex], 'TOTAL  (Price Position)') > -1
                                || stripos($result[$tmpIndex], 'TOTAL  (Physical Position)') > -1
                                || stripos($result[$tmpIndex], 'TOTAL MTM') > -1
                                || stripos($result[$tmpIndex], 'FULL LOAD UNIT COST') > -1
                                || stripos($result[$tmpIndex], 'TOTAL Power (Price Position)') > -1
                                || stripos($result[$tmpIndex], 'TOTAL Power (Physical Position)') > -1
                                || stripos($result[$tmpIndex], 'eq. all-in Price position (mmbtu/d)') > -1
                                || stripos($result[$tmpIndex], 'AVG UNIT COST') > -1
                            )
                        ) {
                            $boldRow = $i;
                        }

                        if ($j == 0
                            && (stripos($result[$tmpIndex], 'FULL LOAD UNIT COST') > -1
                                || stripos($result[$tmpIndex], 'FULL LOAD  UNIT COST') > -1
                                || stripos($result[$tmpIndex], 'AVG UNIT COST') > -1
                            )
                        ) {
                            $round2Row = $i;
                        }

                        if ($j > 0) {

                            if ($i == $round2Row) {
                                $round_value = 2;
                            }

                            $val = number_format($result[$tmpIndex], $round_value);

                            if ($i == $moneyFormatRow) {
                                $val = '$ ' . $val;
                            }
                            
                            if ($i == $boldRow) {
                                $val = '<b>' . $val . '</b>';
                            }
                            
                            if ($i == $blankRow) {
                                $val = '';
                            }

                            $data = encloseTD($val, $clm_sub_col_span, $clm_tot_col_span);
                        }
                    }

                    $html_str .= "
                        $data";
                                    
                }

                $html_str .= "
                    </tr>";

                $sub_total_pre_str = $sub_total_str;
            }

            // add the last sub_total line
            if ($sub_total_clm >= 0) {

                //print the subtotal line and initilize sub total array
                if ($show_header == 'false') {
                    if ($fields == 11) {
                        $html_str .= "
                            <tr><td><td colspan=10><hr size='1'></td></tr> ";
                    } elseif ($fields == 10) {
                        $html_str .= "
                            <tr><td><td colspan=9><hr size='1'></td></tr> ";
                    } else {
                        $html_str .= "
                            <tr><td><td colspan=8><hr size='1'></td></tr> ";
                    }
                }
                
                $html_str .= "
                    <tr class='subtotal' valign='center' height='10'>";
                
                for ($j = 0; $j < $fields; $j++) {
                    if ($j > $report_total_clm_start) {

                        /* Added By Narendra Shrestha - To decentralize report */
                        if ($newFormat) {
                            $linkRef = $reportInstance->getSubTotalDrillDownRef($result, $arrayR, $fields, $noOfRows, $j, $tmpIndex);
                            
                            if ($linkRef != null) {
                                $linkRef .= $linkRef .= ($linkRef != null) ? "&rnd=" . $round_no : null;
                                $dispData = '<B>' . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . '</B>';
                                $dataString = $linkRef != null ? '<a target="_blank" href="' . $linkRef . '">' . $dispData . '</a>' : $dispData;
                                $data = encloseTD($dataString, $clm_sub_col_span, $clm_tot_col_span);
                            } else {
                                $data = "<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . "</B>";
                                $data = encloseTD("<B>" . $data . "</B>", $clm_sub_col_span, $clm_tot_col_span);
                            }
                        } else {
                            $data = "<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . "</B>";
                            $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
                        }
                    } else {
                        $data = encloseTD("<B>" . $clm_sub_total[$j] . "</B>", $clm_sub_col_span, $clm_tot_col_span);
                    }

                    $html_str .= "$data";
                }
                $html_str .= "
                            </tr>";

                if ($show_header == 'false') {
                    if ($fields == 11) {
                        $html_str .= "
                            <tr><td colspan=11><hr size='1'></td></tr>";
                    } elseif ($fields == 10) {
                        $html_str .= "
                            <tr><td colspan=10><hr size='1'></td></tr>";
                    } else {
                        $html_str .= "
                            <tr><td colspan=9><hr size='1'></td></tr>";
                    }
                }
            }

            // add total line
            if ($report_name != "" && $report_total_clm_start >= 0) {
                if ($show_header == 'true') {
                    $html_str .= "
                        <tr class='total' height='10'>";
                } else {
                    $html_str .= "
                        <tr valign='center' height='10' bgcolor='#FFFFFF'>";
                }

                for ($j = 0; $j < $fields; $j++) {
                    if ($j > $report_total_clm_start) {
                        if ($clm_total_format[$j] != "X"){
                            $data = "<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_total[$j]) . "</B>";
                        } else {
                            $data = "<B>" . my_number_format($clm_total_format[$j], $clm_total[$j]) . "</B>";
                        }
                    } else {
                        $data = "<B>" . $clm_total[$j] . "</B>";
                    }

                    //first ifs are for total needing urls
                    if ($report_name == "spa_create_rec_compliance_report" && $arrayR[9] == 1) {
                        $php_ref = "";
                        
                        if ($j == 4){
                            $php_ref = get_rec_compliance_drilldown_phpref(1, $arrayR);
                        } elseif ($j == 6){
                            $php_ref = get_rec_compliance_drilldown_phpref(2, $arrayR);
                        } elseif ($j == 7){
                            $php_ref = get_rec_compliance_drilldown_phpref(3, $arrayR);
                        }

                        if ($j == 4 || $j == 6 || $j == 7) {
                            $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
                        } else {
                            $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
                        }
                    } else { //for no url required in total line
                        $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
                    }

                    $html_str .= "$data";
                }

                $html_str .= "</tr>";
            }

            $html_str .= "</table>
                <iframe name='f1' src='blank.htm' width='0' height='0' frameborder='0'></iframe>
                </body>   
                </html>";

            //write the file
            if ($writeCSV == true) {
                // Uses PHPSpreadsheet to convert HTML to Excel
                $filename = get_random_file_name();
                $filename .= ".xlsx";

                $inputFileName = 'export.html';
                file_put_contents($inputFileName, $html_str);
                
                require_once '../components/lib/vendor/autoload.php';
                global $DECIMAL_SEPARATOR;
                global $GROUP_SEPARATOR;
                $group_separator = str_replace("\\","",$GROUP_SEPARATOR);
                $decimal_separator = $DECIMAL_SEPARATOR;
                if (empty($group_separator)) {
                    $group_separator = ',';
                }

                if (empty($decimal_separator)) {
                    $decimal_separator = '.';
                }
                $objSpreadsheet = new Spreadsheet();
                $objSpreadsheetReader = IOFactory::createReader('Html');
                $objSpreadsheet = $objSpreadsheetReader->load($inputFileName);
                $objSpreadsheetWriter = IOFactory::createWriter($objSpreadsheet, 'Xlsx');

                unlink($inputFileName);

                // Looping through each Sheet in Excel
                foreach($objSpreadsheet->getWorksheetIterator() as $spreadsheet) {
                    $worksheet_title = $spreadsheet->getTitle();
                    
                    // Getting Highest Column on Excel Sheet (Eg: E)
                    $highest_column = $spreadsheet->getHighestColumn();
                    
                    // Getting Highest Column Index of Excel Sheet (Eg: 5 For E)
                    $highest_column_index = Coordinate::columnIndexFromString($highest_column);
                    
                    // Getting Highest Row Name (Eg: 20)
                    $highest_row = $spreadsheet->getHighestRow();
                    
                    // Looping through each column in Sheet
                    for($col = 0; $col < $highest_column_index; $col++) {
                        // Looping through each row in Sheet
                        for ($row = 1; $row <= $highest_row; $row++) {
                            
                            // Taking specific cell object of Excel
                            $cell = $spreadsheet->getCellByColumnAndRow($col, $row);
                            $val = $cell->getValue();
                            
                            // Get the Column Name (Eg: A/B/C/D for Index 1/2/3/4)
                            $col_name = Coordinate::stringFromColumnIndex($col);
                            
                            // Build Cell Name: (Eg: A4)
                            $cell_name = $col_name . $row;

                            // Checking if the value which is going to be stored on a cell is numeric or not
                            if (strpos($clm_total_format[$col], '$') !== false) {
                                if (is_numeric(str_replace($group_separator, '', $val))) {
                                    $val = str_replace($group_separator, '', $val);
                                    $last_position = explode('.', $clm_total_format[$col]);
                                    
                                    /*
                                        Setting the value on a cell with type defined in farrms.client.config.ini
                                        Building the format of number like: #,##0.00
                                    */
                                    if ($last_position[1] != '' || $last_position[1] != NULL) {
                                        $format_code = '#' . $group_separator . '##0' . $decimal_separator.str_repeat('0', $last_position[1]);
                                    } else if ($round_no != '' || $round_no != NULL) {
                                        $format_code = '#' . $group_separator . '##0'. $decimal_separator.str_repeat('0', $round_no);
                                    } else {
                                        $format_code = '#' . $group_separator . '##0'. $decimal_separator.str_repeat('0', 2);
                                    }
                                    
                                    // Setting the value on the cell with type numeric
                                    $cell->setValueExplicit($val, DataType::TYPE_NUMERIC);
                                    
                                    // Changing the cell type as Number with format defined above
                                    $objSpreadsheet->getActiveSheet()->getStyle($cell_name)->getNumberFormat()->setFormatCode($format_code);
                                }
                            } else {
                                // If the value which is going to be stored on a cell is not numeric
                                $cell->setValueExplicit($val, DataType::TYPE_STRING);
                                $objSpreadsheet->getActiveSheet()->getStyle($cell_name)->getNumberFormat()->setFormatCode(NumberFormat::FORMAT_GENERAL);
                            }
                        }
                    }
                }
                
                $objSpreadsheet->setActiveSheetIndex(0);
                $objSpreadsheet->getActiveSheet()->setTitle('grid');
                
                header('Content-Type: application/xlsx');
                header('Content-Disposition: attachment;filename="' . $filename . '"');
                header('Cache-Control: max-age=0');
                
                ob_end_clean();
                $objSpreadsheetWriter->save('php://output');
                exit();

            } elseif ($writeFile == true) {
                $fileName = get_random_file_name();
                $grid_xml = generate_xml_from_table_html($html_str, $fields);
                $grid_xml = urlencode($grid_xml);
                $pdf_url = '../components/lib/adiha_dhtmlx/grid-pdf-php/generate.php?filename=' . $fileName;
                
                echo '<script language="JavaScript" type="text/JavaScript">
                        var form = document.createElement("form");
                        document.body.appendChild(form);
                        form.method = "POST";
                        form.action = "' . $pdf_url . '";
                        var grid_xml_element = document.createElement("input");
                        grid_xml_element.value = "' . $grid_xml . '";
                        grid_xml_element.name = "grid_xml";
                        grid_xml_element.type = "hidden";
                        form.appendChild(grid_xml_element);
                        form.submit();
                    </script>';
                die();
            } else {
                str_replace(".php?", ".php?session_id=$session_id&", $html_str);
            }

            if (isset($_GET['pop_up'])) {
                $html_string = '<body><div class="modal-dialog" >';
                $html_string .= '   <div class="modal-content">';
                $html_string .= '       <div class="modal-body">'.$html_str;
                $html_string .= '       </div>';
                $html_string .= '   </div>';
                $html_string .= '</div></body>';
            } else {
                $html_string = $html_str;   
            }

            $close_progress = $_GET['close_progress'] ?? '';
            if ($close_progress == 1) {
                $html_string .= '<script>parent.close_progress();</script>';
            }

            //function to extract criteria_id from hyperlinkText
            function capture_criteria_id_with_breakdown($initial_value) {
                $middle_value = strstr($initial_value, 'TRMWinHyperlink');
                $middle_value = explode(',', $middle_value);
                $middle_value = $middle_value[1];
                $middle_value = explode(')', $middle_value);
                $final_value = $middle_value[0];
                return $final_value;
            }

            if ($default_theme) {
                $theme_selected = $default_theme;
            } else {
                $theme_selected = '';
            }
        ?>

        <div class="show_msg <?php echo $theme_selected; ?>" style="height: 100%; width: 100%"><?php echo $html_string; ?></div>

        <?php
            if ($is_called_from_mobile) {
                $sql = str_replace('"',"'", $sql);
                $total_page = ceil($total_row_return/100);
                $total_page = ($total_page == 0) ? 1 : $total_page;
                    
                echo ']]>
                    </report_html>
                    <sql>' . $sql . '</sql>
                    <paging>
                        <current>' . $sel_page . '</current>
                        <total>' . $total_page . '</total>
                    </paging>
                </root>';
            } else {
                ?>
                    <script type="text/javascript">
                        var export_sp = escape("<?php echo str_replace('"',"'", $sql) ?>");
                        var writeCSV = <?php echo(int) $writeCSV; ?>;
                        
                        //This global variable is used to show SQL in F8 mode from spa_html where post is done (e.g. MTM, POS and SET reports) 
                        var _gbl_page_exec_sp = export_sp;

                        function openToolBar(php_file) {
                            var exec_call = decodeURIComponent(export_sp);
                            var rnd = <?php echo $round_no; ?>;
                            var url = js_php_path + 'dev/' + php_file;
                            var param_session = js_session_id;
                            var param_config_file = encodeURIComponent(js_config_file);
                            var sp_name = '<?php echo $spName; ?>'.toLowerCase();

                            
                            if (exec_call == null) {
                                return;
                            }
                            
                            //added post method for mtm and position
                            if (sp_name == 'spa_create_hourly_position_report' || sp_name == 'spa_create_mtm_period_report_trm') {
                                var param = {   
                                    'spa' : exec_call, 
                                    'rnd' : rnd,
                                    'enable_paging' : false, 
                                    'session_id' : param_session,
                                    'sp_name' : sp_name 
                                };
                                            
                                open_window_with_post(url, 'new_window', param, '_blank');
                            } else { //old logic for others
                                sp_url = php_file + "?spa=" + exec_call + "&" + getAppUserName() + "&session_id=" + js_session_id + "&rnd=<?php echo $round_no; ?>";
                                openHTMLWindow(sp_url);
                            }  
                        }

                        /* Added by : Santosh Manandhar - Automatically closes the popup window. */
                        if (writeCSV == true) {
                            setTimeout(function () {
                                window.parent.close();
                            }, 7000);
                        }

                        //used for mtm settlement and position report only
                        function run_exec_code(tmp_index) {     
                            <?php
                                $exec_call_php_array = json_encode($build_exec_code);
                                echo "var exec_call_array = ". $exec_call_php_array . ";\n";
                            ?>
                            
                            var exec_call = exec_call_array[tmp_index];
                            var rnd = <?php echo $round_no; ?>;
                            var url = js_php_path + 'dev/spa_html.php';
                            
                            var param = {   
                                'spa' : exec_call, 
                                'rnd' : rnd,
                                'enable_paging' : false, 
                                'session_id' : js_session_id 
                            };
                            open_window_with_post(url, 'new_window', param, '_blank');
                        }
                        
                        function paging_post(total_row_return, page_no, paging_arg) {
                            var url = js_php_path + 'dev/spa_html.php';
                            var exec_call =  '<?php echo urlencode($sql) ; ?>'
                            
                            var param = {   
                                'spa' : exec_call,
                                'rnd' : 2,
                                'enable_paging' : true, 
                                'sp_name' : 'spa_create_mtm_period_report_trm',
                                '__total_row_return__' : total_row_return,
                                'page_no' : page_no,
                                'session_id' : js_session_id,
                                'show_header' : true
                            };
                                        
                            open_window_with_post(url, 'new_window', param, '_self');
                        }

                        function TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to) {
                            window.top.TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to);
                        }

                        function openHyperLink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to) {
                            window.top.TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to);
                        }
                        
                        function second_level_drill(s) {
                            parent.second_level_drill_1(s);
                        }

                        function second_level_drill_2(report_name, exec_call, height, width) {
                            parent.second_level_drill_2(report_name, exec_call, height, width);
                        }

                        message_expand_collapse = function() {
                            var img_src = $('.message_image').attr('alt');
                            
                            if (img_src == 'plus') {
                                $('.message_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/minus.png');
                                $('.message_image').attr('alt','minus');
                                $('.report_header_new').height('auto');
                            } else {
                                $('.message_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
                                $('.message_image').attr('alt','plus');
                                $('.report_header_new').height('13px');
                            }
                        }
                    </script>
                <?php 
            } 
        ?>
    </body>
</html>