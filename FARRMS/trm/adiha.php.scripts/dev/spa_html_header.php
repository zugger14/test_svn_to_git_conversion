<?php
/**
 * Decodes params from stored proc sql to array
 * Params:
 * $ostr: SQL String
 *      eg: exec spa_run_sql  97,'sub_id=32!92,stra_id=NULL,book_id=NULL' - Report Writer Reports
 *          exec spa_create_power_position_report 's','l','92', '94', '96,133', '2010-05-12', '2010-04-01',... - Normal report
 * $extract_rw_params: boolean - to check whether to extract report writer params or not
 *      For report headers (to show applied filters), we need to extract report writer params
 *      as normal report approach won't work
 */
function decode_param($o_str, $extract_rw_params = false) {
    global $is_report_writer;

    //echo '<br/>', $o_str, ' - ', (int) $extract_rw_params;
    $sql_stmt_name = trim($o_str);

    // echo $sql_stmt_name;
    $arrayR = array();
    
    if (strtolower(substr($sql_stmt_name, 0, 4)) != "exec") {
        $arrayR[0] = "Error";
        $arrayR[1] = "<font color=\"red\" font=\"tahoma\" size=3><b>ERROR - Could not locate report name (1).</b></font>";
        return $arrayR;
    }

    //eg: exec spa_Create_Position_Report '2010-04-21', '29,7', NULL, NULL, 't', null, 'f', 35, 10, NULL, NULL,'401,400,407',NULL,..
    //exec spa_run_sql 2, 'ID=789,as_of_date=2010-04-21'
    $is_report_writer = (stripos($sql_stmt_name, 'spa_run_sql') !== false);

    //gives the str after EXE
    $sql_stmt_name = trim(substr($sql_stmt_name, 4));

    $pointLoc = strpos($sql_stmt_name, " ");

    $arrayR[0] = "Success";
    
    if ($pointLoc < 1 && $sql_stmt_name != "") {
        $arrayR[1] = $sql_stmt_name;
        $sql_stmt_name = "";
    } else if ($pointLoc > 1)
        $arrayR[1] = trim(substr($sql_stmt_name, 0, $pointLoc));
    else {
        $arrayR[0] = "Error";
        $arrayR[1] = "";
    }

    if ($arrayR[0] == "Error") {
        $arrayR[0] = "Error";
        $arrayR[1] = "ERROR - Could not locate report name (2)";
        return $arrayR;
    }

    //gives the parameters after the sp name
    $sql_stmt_name = trim(substr($sql_stmt_name, $pointLoc));
    //echo '<br/>', $sql_stmt_name, ' - ', (int) $persist_param_structure;
    $arrayP = explode(",", $sql_stmt_name);
    $count = count($arrayP);

    $nextIndex = 0;
    $tmp_str = "";
    
    for ($i = 0; $i < $count; $i++) {
        $tmp_str = "";
        if ($is_report_writer && $extract_rw_params) {
            //eg: exec spa_run_sql 2, 'ID=789,as_of_date=2010-04-21,sub_id=34!56,stra_id=45!65,book_id=89!90'
            //first param is report id
            if ($i == 0) {
                global $report_writer_report_id;
                $report_writer_report_id = trim($arrayP[$i]);
                continue;
            }

            //get the = separated name value in array
            $arr_name_value = explode('=', trim($arrayP[$i]));
            //read the last value
            $param_value = $arr_name_value[count($arr_name_value) - 1];
            //replace the last (') eg; 89!90'
            if (stripos($param_value, "'") === strlen($param_value) - 1)
                $param_value = substr($param_value, 0, strlen($param_value) - 1);

            //replace (!) with (,) (in case of book structure)
            if (stripos($param_value, "!") !== false)
                $param_value = "'" . str_replace('!', ',', $param_value) . "'";

            //if it is date field, wrap with (') as it is necessary while formatting
            if (substr_count($param_value, '-') == 2)
                $param_value = "'" . $param_value . "'";

            $arrayR[2 + $nextIndex] = $param_value;

            $nextIndex = $nextIndex + 1;
        } else if (substr_count($arrayP[$i], "'") == 1) {   // split varchar found with "," seperated
            $tmp_str = $arrayP[$i];
            for ($k = $i + 1; $k < $count; $k++) {
                $tmp_str = $tmp_str . ", " . trim($arrayP[$k]);
                if (substr_count($arrayP[$k], "'") != 0) {
                    $arrayR[2 + $nextIndex] = $tmp_str;
                    $nextIndex = $nextIndex + 1;
                    $i = $k;
                    break;
                }
            }
        } else { // number found or a varchar with '' found
            $arrayR[2 + $nextIndex] = trim($arrayP[$i]);
            $nextIndex = $nextIndex + 1;
        }
    }

    return $arrayR;
}

/**
 * Gets Database connection link
 * @return  Resource  Database connection
 */
function get_db_connection() {
	global $db_servername, $connection_info;
	$db_connect = @sqlsrv_connect($db_servername, $connection_info);
	return $db_connect;
}

/**
 * Gets Report Definition
 * @param   String      $sp_name            SP Name
 * @param   Array       $arrayR             [$arrayR description]
 * @param   Resource    $odbc_connection    ODBC conneciton link
 * @param   Array       $REQUEST            Request data
 * @param   Object      $reportInstance     Report instance
 * @return  Array                           Report Definition array
 */
function get_report_def($sp_name, $arrayR, $odbc_connection, $REQUEST, $reportInstance = null) {
    $DB_CONNECT = get_db_connection();
    $reportA = array();
    $reportA[0] = "Error"; //Report Def not found
    $call_from = "";
    
    if (isset($REQUEST['call_from'])) {
        $call_from = $REQUEST['call_from'];
    }
   
    if ($reportInstance != null) {
        $call_from = isset($REQUEST['report_name']) ? $REQUEST['report_name'] : null;
        $reportA = $reportInstance->getReportFilterDefinition($arrayR, $call_from);
    } else {

        if ($sp_name == strtolower("spa_settlement_production_report")) {

            if ($arrayR[13] == "'s'") {
                $reportA[0] = "Settlement Production Data Report";
            } else if ($arrayR[13] == "'m'") {
                $reportA[0] = "Missing Production Data Report";
            } else if ($arrayR[13] == "'p'") {
                $reportA[0] = "Estimated Production Data Report";
            } else if ($arrayR[13] == "'z'") {
                $reportA[0] = "Raw Production Data Report";
            } else if ($arrayR[13] == "'y'") {
                $reportA[0] = "Production Data Report";
            }

            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Generator";
            $reportA[5] = "Technology";
            $reportA[6] = "Counterparty";
            $reportA[7] = "Buy Sell Flag";
            $reportA[8] = "Gen State";
            $reportA[9] = "As of Date";
            $reportA[10] = "Term Start";
            $reportA[11] = "Term End";
            $reportA[12] = "Report";
        } else if ($sp_name == strtolower("spa_create_fx_exposure_report")) {
            $reportA[0] = "FX Exposure Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Curve Source ID";
            $reportA[6] = "Group By";
            $reportA[7] = "Deal Status";
            $reportA[8] = "Source Deal Header Id";
            $reportA[9] = "Deal Id";
            $reportA[10] = "Round Value";
            $reportA[11] = "NULL";
        } else if ($sp_name == strtolower("spa_calc_explain_position")) {

            if ($arrayR[12] == "'m'") {
                $reportA[0] = "MTM Explain Report";
            } else if ($arrayR[13] == "'f'") {
                //TODO: remove this comment when Report 'Forward vs Actual Explain Report' is finished. 
                //Report 'Forward vs Actual Explain Report' is not finished yet(2011-11-16). 
                //It was added just to avoid error while selecting this report type in form
                $reportA[0] = "Forward vs Actual Explain Report";
            } else {
                $reportA[0] = "Position Explain Report";
            }

            $reportA[1] = "As of Date From";
            $reportA[2] = "As of Date To";
            $reportA[3] = "Term Start";
            $reportA[4] = "Term End";
            $reportA[5] = "Subsidiary";
            $reportA[6] = "Strategy";
            $reportA[7] = "Book";
            $reportA[8] = "Source Deal Header Id";
            $reportA[9] = "Deal Id";
            $reportA[10] = "NULL";
            $reportA[11] = "NULL";
            $reportA[12] = "NULL";
            $reportA[13] = "Commodity";
            //$reportA[14] = "Location";
            $reportA[14] = "Index";
            //$reportA[16] = "Hour From";
            //$reportA[17] = "Hour To";
        } else if ($sp_name == strtolower("spa_counterparty_mtm_report")) {
            $reportA[0] = "Counterparty MTM Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Prior As of Date";
            $reportA[3] = "Subsidiary";
            $reportA[4] = "Strategy";
            $reportA[5] = "Book";
            $reportA[6] = "Settlement Option";
            $reportA[7] = "Summary Option";
            $reportA[8] = "counterparty";
            $reportA[9] = "Tenor from";
            $reportA[10] = "Tenor to";
        } else if ($sp_name == strtolower("spa_Create_MTM_Period_Report_TRM")) {

            if ($arrayR[46] == "'y'") {
                if ($arrayR[9] == "'16'") {
                    $reportA[0] = "CashFlow Report";
                } else if ($arrayR[9] == "'17'") {
                    $reportA[0] = "Deal Settlement Report";
                } else if ($arrayR[9] == "'18'") {
                    $reportA[0] = "PNL Report";
                } else {
                    $reportA[0] = "Deal Settlement Report";
                }
            } else {
                $reportA[0] = "MTM Report";
            }
//
//            $reportA[1] = "As of Date";
//            $reportA[2] = "Subsidiary";
//            $reportA[3] = "Strategy";
//            $reportA[4] = "Book";
//            //$reportA[5] = "Discount Option";
//            //$reportA[6] = "Settlement Option";
//            //$reportA[7] = "Report Type";
//            $reportA[5] = "NULL";
//            $reportA[6] = "NULL";
//            $reportA[7] = "NULL";
//            $reportA[8] = "Summary Option";
//            $reportA[9] = "Counterparty";
//            //$reportA[10] = "Tenor from";       
//            //$reportA[11] = "Tenor to";
//            $reportA[10] = "NULL";
//            $reportA[11] = "NULL";
//            //$reportA[12] = "Previous As of Date";
//            $reportA[12] = "NULL";
//            $reportA[13] = "Trader";
//            //$reportA[14] = "Include Item";
//            $reportA[14] = "NULL";
//            $reportA[15] = "Source System book1";
//            $reportA[16] = "Source System book2";
//            $reportA[17] = "Source System book3";
//            $reportA[18] = "Source System book4";
//            $reportA[19] = "Show Firstday Gain Loss";
//            $reportA[20] = "Transaction Type";
//            $reportA[21] = "Deal ID From";
//            $reportA[22] = "Deal ID To";
//            $reportA[23] = "Deal ID";
//            //$reportA[24] = "Threshold";
//            $reportA[24] = "NULL";
//            $reportA[25] = "NULL";
//            //$reportA[26] = "Exceed Threshold";
//            $reportA[26] = "NULL";
//            $reportA[27] = "NULL";
//            //$reportA[28] = "Use Create Date";
//            $reportA[28] = "NULL";
//            $reportA[29] = "Round Value";
//            $reportA[30] = "Counterparty Type";
//            $reportA[31] = "Mapped";
//            //$reportA[32] = "Match ID";
//            $reportA[32] = "NULL";
//            //$reportA[33] = "Counterparty Type ID";
//            $reportA[33] = "NULL";
//            $reportA[34] = "Curve Source ID";
//            //$reportA[35] = "Deal Sub Type";
//            $reportA[35] = "NULL";
//            $reportA[36] = "Deal Date From";
//            $reportA[37] = "Deal Date To";
//            $reportA[38] = "Physical Financial";
//            $reportA[39] = "Deal Type ID";
//            //$reportA[40] = "Period Report";
//            $reportA[40] = "NULL";
//            $reportA[41] = "Term Start";
//            $reportA[42] = "Term End";
//            $reportA[43] = "Settlement Date From";
//            $reportA[44] = "Settlement Date To";
//            //$reportA[45] = "Settlement Only";        
//            //$reportA[46] = "Risk Bucket Header ID";
//            //$reportA[47] = "Risk Bucket Detail ID";    
//            //$reportA[48] = "Commodity ID";
//            //$reportA[49] = "Graph";
//            $reportA[45] = "NULL";
//            $reportA[46] = "NULL";
//            $reportA[47] = "NULL";
//            $reportA[48] = "NULL";
//            $reportA[49] = "NULL";
//        $reportA[50] = "Show By";
//        $reportA[51] = "Convert UOM";
            
        } else if ($sp_name == strtolower("spa_virtual_storage_constraints")) {
            $reportA[0] = "Constraints Report";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
        } else if ($sp_name == strtolower("spa_create_withdrawal_schedule")) {
            $reportA[0] = "Hourly Position Report";
            if ($arrayR[12] == 21) {
                $reportA[0] = 'Schedule Report';
            } else if ($arrayR[12] == 20) {
                $reportA[0] = 'Nomination Report';
            } else {
                $reportA[0] = 'Actual Report';
            }
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "Book";
            $reportA[4] = "As of date";
            $reportA[5] = "Term start";
            $reportA[6] = "Term End";
            $reportA[7] = "Granularity";
            $reportA[8] = "Group By";
            $reportA[9] = "Location";
            $reportA[10] = "Format";
            $reportA[11] = "NULL";
        } else if ($sp_name == strtolower("spa_pratos_mapping_index")) {
            $reportA[0] = "Pratos Mapping Report (Index)";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
        } else if ($sp_name == strtolower("spa_pratos_mapping_book")) {
            $reportA[0] = "Pratos Mapping Report (Book)";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
        } else if ($sp_name == strtolower("spa_pratos_mapping_formula")) {
            $reportA[0] = "Pratos Mapping Report (Formula)";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
        } else if ($sp_name == strtolower("spa_Create_Hedge_Rel_Audit_Report")) {

            if (trim($arrayR[6], "'") == 's')
                $reportA[0] = "Hedging Relationship Audit Report (Summary)";
            else if (trim($arrayR[6], "'") == 'd')
                $reportA[0] = "Hedging Relationship Audit Report (Detail)";
            else if (trim($arrayR[6], "'") == 'c')
                $reportA[0] = "Hedging Relationship Audit Report (Change Summary)";

            $reportA[1] = "Hedge Rel ID From";
            $reportA[2] = "Hedge Rel ID To";
            $reportA[3] = "Effective Date From";
            $reportA[4] = "Effective Date To";
            $reportA[5] = "NULL";
            $reportA[6] = "Relationship Type";
            $reportA[7] = "Active";
            $reportA[8] = "Prior Update Date";
            $reportA[9] = "Update Date From";
            $reportA[10] = "Update Date To";
            $reportA[11] = "Update By";
            $reportA[12] = "User Action";
            $reportA[13] = "Sort Order";
        }

        else if (stristr($sp_name, 'spa_run_sql') !== FALSE) {
            //get report name and params
            load_report_writer_report_fields($reportA);
        } else if ($sp_name == strtolower("spa_create_hedges_measurement_report") ||
                $sp_name == strtolower("spa_create_mtm_measurement_report")) {
            $reportA[0] = "Measurement Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "Settlement Option";
            $reportA[7] = "Hedge Type";
            $reportA[8] = "Summary Option";
            $reportA[9] = "Rel ID";
    		$reportA[10] = "Round Value";
    		$reportA[11] = "Legal Entity";
    		$reportA[12] = "Hypothetical";
    		$reportA[13] = "SourceDealID";
    		$reportA[14] = "Deal ID";
    		$reportA[15] = "Term Start";
    		$reportA[16] = "Term End";
        } else if ($sp_name == strtolower("spa_auto_matching_report")) {
            $reportA[0] = "Automate matching of Hedges";
        } else if ($sp_name == strtolower("spa_create_Tagging_Export")) {
            $reportA[0] = "Tagging Report";
        } else if ($sp_name == strtolower("spa_risk_control_activities")) {
            $reportA[0] = "Compliance Activities Report";
            ($arrayR[2] != 'null') ? $reportA[1] = "Group1 Process" : $reportA[1] = "NULL";
            ($arrayR[3] != 'null') ? $reportA[2] = "NULL" : $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            ($arrayR[6] != 'null') ? $reportA[5] = "Group2 Risk" : $reportA[5] = "NULL";
            ($arrayR[7] != 'null') ? $reportA[6] = "Activity Category" : $reportA[6] = "NULL";
            ($arrayR[8] != 'null') ? $reportA[7] = "Who For" : $reportA[7] = "NULL";
            ($arrayR[9] != 'null') ? $reportA[8] = "Where" : $reportA[8] = "NULL";
            ($arrayR[10] != 'null') ? $reportA[9] = "Why" : $reportA[9] = "NULL";
            ($arrayR[11] != 'null') ? $reportA[10] = "Activity Area" : $reportA[10] = "NULL";
            ($arrayR[12] != 'null') ? $reportA[11] = "Activity Sub Area" : $reportA[11] = "NULL";
            ($arrayR[13] != 'null') ? $reportA[12] = "Activity Action" : $reportA[12] = "NULL";
            ($arrayR[14] != 'null') ? $reportA[13] = "Activity Description" : $reportA[13] = "NULL";
            ($arrayR[15] != 'null') ? $reportA[14] = "Control Type" : $reportA[14] = "NULL";
            ($arrayR[16] != 'null') ? $reportA[15] = "Monetary value defined" : $reportA[15] = "NULL";
            ($arrayR[17] != 'null') ? $reportA[16] = "Group1(Process Owner)" : $reportA[16] = "NULL";
            ($arrayR[18] != 'null') ? $reportA[17] = "Group2(Risk Owner)" : $reportA[17] = "NULL";
        } else if ($sp_name == strtolower("spa_Get_Risk_Control_activities_Audit")) {
                $reportA[0] = "Compliance Activity Audit Report";
                $reportA[1] = "NULL";
                ($arrayR[3] != 'null') ? $reportA[2] = "Who By" : $reportA[2] = "NULL";
                ($arrayR[4] != 'null') ? $reportA[3] = "As of Date From" : $reportA[3] = "NULL";                
                ($arrayR[5] != 'null') ? $reportA[4] = "As of Date To" : $reportA[4] = "NULL";
                ($arrayR[6] != 'null') ? $reportA[5] = "Run Frequency" : $reportA[5] = "NULL";
                ($arrayR[7] != 'null') ? $reportA[6] = "Risk Priority" : $reportA[6] = "NULL";
                $reportA[7] = "NULL";
                ($arrayR[8] != 'null') ? $reportA[8] = "Group1 Process" : $reportA[8] = "NULL";
                ($arrayR[9] != 'null') ? $reportA[9] = "Group2 Risk" : $reportA[9] = "NULL";
                ($arrayR[11] != 'null') ? $reportA[10] = "Activity Category" : $reportA[10] = "NULL";
                ($arrayR[12] != 'null') ? $reportA[11] = "Who For" : $reportA[11] = "NULL";
                ($arrayR[13] != 'null') ? $reportA[12] = "Where" : $reportA[12] = "NULL";
                ($arrayR[14] != 'null') ? $reportA[13] = "Why" : $reportA[13] = "NULL";
                ($arrayR[15] != 'null') ? $reportA[14] = "Activity Area" : $reportA[14] = "NULL";
                ($arrayR[16] != 'null') ? $reportA[15] = "Activity Sub Area" : $reportA[15] = "NULL";
                ($arrayR[17] != 'null') ? $reportA[16] = "Activity Action" : $reportA[16] = "NULL";
                ($arrayR[18] != 'null') ? $reportA[17] = "Activity Description" : $reportA[17] = "NULL";
                ($arrayR[19] != 'null') ? $reportA[18] = "Control Type" : $reportA[18] = "NULL";
                ($arrayR[20] != 'null') ? $reportA[19] = "Monetary Value Defined" : $reportA[19] = "NULL";
                ($arrayR[21] != 'null') ? $reportA[20] = "Group1 Process Owner" : $reportA[20] = "NULL";
                ($arrayR[22] != 'null') ? $reportA[21] = "Group2 Risk Owner" : $reportA[21] = "NULL";
                ($arrayR[23] != 'null') ? $reportA[22] = "Memo" : $reportA[22] = "NULL";
        } else if ($sp_name == strtolower("spa_process_exceptions_trend_report")) {
            $reportA[0] = "Compliance Trend Report";
            ($arrayR[2] != 'null') ? $reportA[1] = "Who By" : $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            ($arrayR[8] != 'null') ? $reportA[7] = "Run Frequency" : $reportA[7] = "NULL";
            ($arrayR[9] != 'null') ? $reportA[8] = "Priority" : $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            ($arrayR[11] != 'null') ? $reportA[10] = "Activity Status" : $reportA[10] = "NULL";
            ($arrayR[12] != 'null') ? $reportA[11] = "Group1 Process" : $reportA[11] = "NULL";
            ($arrayR[13] != 'null') ? $reportA[12] = "Group2 Risk" : $reportA[12] = "NULL";
            ($arrayR[14] != 'null') ? $reportA[13] = "Activity Category" : $reportA[13] = "NULL";
            ($arrayR[15] != 'null') ? $reportA[14] = "Who For" : $reportA[14] = "NULL";
            ($arrayR[16] != 'null') ? $reportA[15] = "Where" : $reportA[15] = "NULL";
            ($arrayR[17] != 'null') ? $reportA[16] = "Why" : $reportA[16] = "NULL";
            ($arrayR[18] != 'null') ? $reportA[17] = "Activity Area" : $reportA[17] = "NULL";
            ($arrayR[19] != 'null') ? $reportA[18] = "Activity Sub Area" : $reportA[18] = "NULL";
            ($arrayR[20] != 'null') ? $reportA[19] = "Activity Action" : $reportA[19] = "NULL";
            ($arrayR[21] != 'null') ? $reportA[20] = "Activity Description" : $reportA[20] = "NULL";
            ($arrayR[22] != 'null') ? $reportA[21] = "Control Type" : $reportA[21] = "NULL";
            $reportA[22] = "NULL";
            ($arrayR[24] != 'null') ? $reportA[23] = "Group1 Process Owner" : $reportA[23] = "NULL";
            ($arrayR[25] != 'null') ? $reportA[24] = "Group2 Risk Owner" : $reportA[24] = "NULL";
            $reportA[25] = "NULL";
            $reportA[26] = "NULL";
            $reportA[27] = "NULL";
            ($arrayR[29] != 'null') ? $reportA[28] = "Frequency" : $reportA[28] = "NULL";
            $reportA[29] = "NULL";
        } else if ($sp_name == strtolower("spa_process_exceptions_pie_report")) {
            $reportA[0] = "Run Compliance Graph Report";
            ($arrayR[2] != 'null') ? $reportA[1] = "Who By" : $reportA[1] = "NULL";
            ($arrayR[3] != 'null') ? $reportA[2] = "As of Date" : $reportA[2] = "NULL";
            ($arrayR[4] != 'null') ? $reportA[3] = "As of Date To" : $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            ($arrayR[8] != 'null') ? $reportA[7] = "Run Frequency" : $reportA[7] = "NULL";
            ($arrayR[9] != 'null') ? $reportA[8] = "Priority" : $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            ($arrayR[11] != 'null') ? $reportA[10] = "Activity Status" : $reportA[10] = "NULL";
            ($arrayR[12] != 'null') ? $reportA[11] = "Group1 Process" : $reportA[11] = "NULL";
            ($arrayR[13] != 'null') ? $reportA[12] = "Group2 Risk" : $reportA[12] = "NULL";
            ($arrayR[14] != 'null') ? $reportA[13] = "Activity Category" : $reportA[13] = "NULL";
            ($arrayR[15] != 'null') ? $reportA[14] = "Who For" : $reportA[14] = "NULL";
            ($arrayR[16] != 'null') ? $reportA[15] = "Where" : $reportA[15] = "NULL";
            ($arrayR[17] != 'null') ? $reportA[16] = "Why" : $reportA[16] = "NULL";
            ($arrayR[18] != 'null') ? $reportA[17] = "Activity Area" : $reportA[17] = "NULL";
            ($arrayR[19] != 'null') ? $reportA[18] = "Activity Sub Area" : $reportA[18] = "NULL";
            ($arrayR[20] != 'null') ? $reportA[19] = "Activity Action" : $reportA[19] = "NULL";
            ($arrayR[21] != 'null') ? $reportA[20] = "Activity Description" : $reportA[20] = "NULL";
            ($arrayR[22] != 'null') ? $reportA[21] = "Control Type" : $reportA[21] = "NULL";
            $reportA[22] = "NULL";
            ($arrayR[24] != 'null') ? $reportA[23] = "Group1 Process Owner" : $reportA[23] = "NULL";
            ($arrayR[25] != 'null') ? $reportA[24] = "Group2 Risk Owner" : $reportA[24] = "NULL";
            $reportA[25] = "NULL";
            ($arrayR[27] != 'null') ? $reportA[26] = "Monetary value defined" : $reportA[26] = "NULL";
            ($arrayR[28] != 'null') ? $reportA[27] = "Report By" : $reportA[27] = "NULL";
        } else if ($sp_name == strtolower("spa_process_exceptions_status_report")) {
            $reportA[0] = "Run Compliance Status Graph Report";
            ($arrayR[2] != 'null') ? $reportA[1] = "Who By" : $reportA[1] = "NULL";
            ($arrayR[3] != 'null') ? $reportA[2] = "As of Date" : $reportA[2] = "NULL";
            ($arrayR[4] != 'null') ? $reportA[3] = "As of Date To" : $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            ($arrayR[8] != 'null') ? $reportA[7] = "Run Frequency" : $reportA[7] = "NULL";
            ($arrayR[9] != 'null') ? $reportA[8] = "Priority" : $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            ($arrayR[11] != 'null') ? $reportA[10] = "Activity Status" : $reportA[10] = "NULL";
            ($arrayR[12] != 'null') ? $reportA[11] = "Group1 Process" : $reportA[11] = "NULL";
            ($arrayR[13] != 'null') ? $reportA[12] = "Group2 Risk" : $reportA[12] = "NULL";
            ($arrayR[14] != 'null') ? $reportA[13] = "Activity Category" : $reportA[13] = "NULL";
            ($arrayR[15] != 'null') ? $reportA[14] = "Who For" : $reportA[14] = "NULL";
            ($arrayR[16] != 'null') ? $reportA[15] = "Where" : $reportA[15] = "NULL";
            ($arrayR[17] != 'null') ? $reportA[16] = "Why" : $reportA[16] = "NULL";
            ($arrayR[18] != 'null') ? $reportA[17] = "Activity Area" : $reportA[17] = "NULL";
            ($arrayR[19] != 'null') ? $reportA[18] = "Activity Sub Area" : $reportA[18] = "NULL";
            ($arrayR[20] != 'null') ? $reportA[19] = "Activity Action" : $reportA[19] = "NULL";
            ($arrayR[21] != 'null') ? $reportA[20] = "Activity Description" : $reportA[20] = "NULL";
            ($arrayR[22] != 'null') ? $reportA[21] = "Control Type" : $reportA[21] = "NULL";
            ($arrayR[23] != 'null') ? $reportA[22] = "Monetary value defined" : $reportA[22] = "NULL";
            ($arrayR[24] != 'null') ? $reportA[23] = "Group1 Process Owner" : $reportA[23] = "NULL";
            ($arrayR[25] != 'null') ? $reportA[24] = "Group2 Risk Owner" : $reportA[24] = "NULL";
            $reportA[25] = "NULL";
            $reportA[26] = "NULL";
            ($arrayR[28] != 'null') ? $reportA[27] = "Report By" : $reportA[27] = "NULL";
            $reportA[28] = "NULL";
            ($arrayR[30] != 'null') ? $reportA[29] = "Threshold" : $reportA[29] = "NULL";
        } else if ($sp_name == strtolower("spa_read_status_control_activities")) {

            $reportA[0] = "Status on Compliance Activities Report";
            ($arrayR[2] != 'null') ? $reportA[1] = "Who By" : $reportA[1] = "NULL";
            ($arrayR[3] != 'null') ? $reportA[2] = "As of Date" : $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            ($arrayR[5] != 'null') ? $reportA[4] = "Run Frequency" : $reportA[4] = "NULL";
            ($arrayR[6] != 'null') ? $reportA[5] = "Priority" : $reportA[5] = "NULL";
            ($arrayR[7] != 'null') ? $reportA[6] = "NULL" : $reportA[6] = "NULL";
            ($arrayR[8] != 'null') ? $reportA[7] = "Activity Status" : $reportA[7] = "NULL";
            ($arrayR[9] != 'null') ? $reportA[8] = "Group1 Process" : $reportA[8] = "NULL";
            ($arrayR[10] != 'null') ? $reportA[9] = "Group2 Risk" : $reportA[9] = "NULL";
            ($arrayR[11] != 'null') ? $reportA[10] = "Activity Category" : $reportA[10] = "NULL";
            ($arrayR[12] != 'null') ? $reportA[11] = "Who For" : $reportA[11] = "NULL";
            ($arrayR[13] != 'null') ? $reportA[12] = "Where" : $reportA[12] = "NULL";
            ($arrayR[14] != 'null') ? $reportA[13] = "Why" : $reportA[13] = "NULL";
            ($arrayR[15] != 'null') ? $reportA[14] = "Activity Area" : $reportA[14] = "NULL";
            ($arrayR[16] != 'null') ? $reportA[15] = "Activity Sub Area" : $reportA[15] = "NULL";
            ($arrayR[17] != 'null') ? $reportA[16] = "Activity Action" : $reportA[16] = "NULL";
            ($arrayR[18] != 'null') ? $reportA[17] = "Activity Description" : $reportA[17] = "NULL";
            ($arrayR[19] != 'null') ? $reportA[18] = "Control Type" : $reportA[18] = "NULL";
            ($arrayR[20] != 'null') ? $reportA[19] = "Monetary value defined" : $reportA[19] = "NULL";
            ($arrayR[21] != 'null') ? $reportA[20] = "Group1 Process Owner" : $reportA[20] = "NULL";
            ($arrayR[22] != 'null') ? $reportA[21] = "Group2 Risk Owner" : $reportA[21] = "NULL";
            $reportA[22] = "NULL";
            $reportA[23] = "NULL";
            $reportA[24] = "NULL";
            ($arrayR[26] != 'null') ? $reportA[25] = "As of Date To" : $reportA[25] = "NULL";
        }

        /* Added By Pawan 
          Compliance Reporting Header Definitions
         */ else if ($sp_name == strtolower("spa_process_standard_revisions")) {
            $reportA[0] = "Maintain Compliance Standards/Rules Revisions Report";
        } else if ($sp_name == strtolower("spa_maintain_compliance_process")) {
            //$reportA[0] = "Maintain Compliance Group Group1 (Process) Report";
            $reportA[0] = "Groups Process Report";
        } else if ($sp_name == strtolower("spa_maintain_compliance_risks")) {
            //$reportA[0] = "Maintain Compliance Group Group2 (Risks) Report";
            $reportA[0] = "Compliance Groups Risk Report";
        } else if ($sp_name == strtolower("spa_process_risk_controls")) {
            //$reportA[0] = "Maintain Compliance Activities Activities Report";
            $reportA[0] = "Compliance Activities Report";
        } else if ($sp_name == strtolower("spa_compliance_steps")) {
            //$reportA[0] = "Maintain Compliance Activities Steps Report";
            $reportA[0] = "Compliance Activities Steps Report";
        } else if ($sp_name == strtolower("spa_read_control_activities_complete")) {
            $reportA[0] = "Perform Compliance Activities Report";
        } else if ($sp_name == strtolower("spa_approve_status_control_activities_all")) {
            $reportA[0] = "Approve Compliance Activities Report";
        } else if ($sp_name == strtolower("spa_counterparty_limits_report")) {
            $reportA[0] = "Counterparty Credit Availability Report";
            $reportA[1] = "Summary Option";
            $reportA[2] = "As of Date";
            $reportA[3] = "Counterparty";
            $reportA[4] = "Risk Bucket Header";
            $reportA[5] = "Risk Bucket Detail";
            $reportA[6] = "Group Option";
        } else if ($sp_name == strtolower("spa_create_dedesignation_values_report")) {
            $reportA[0] = "De-Designation Values Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "Hedge Type";
            $reportA[7] = "Summary Option";
            $reportA[8] = "Rel ID";
            $reportA[9] = "Round Value";
    		$reportA[10] = "Term Start";
    		$reportA[11] = "Term End";
        } else if ($sp_name == strtolower("spa_netted_journal_entry_report")) {
            $reportA[0] = "Netted Journal Entry Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Discount Option";
            $reportA[3] = "Summary Option";
            $reportA[4] = "Netting Group Parent Id";
        } else if ($sp_name == strtolower("spa_process_functions_listing_detail")) {
            //$reportA[0] = "Process Activity Report";
            //$reportA[0] = "Activity Process Report";
            $reportA[0] = "Activity Process Map Report";
        } else if ($sp_name == strtolower("spa_Create_Inventory_Journal_Entry_Report") || $sp_name == strtolower("spa_Create_Inventory_Journal_Entry_Report_paging")) {

            if (isset($REQUEST['call_from'])) {
                $call = $REQUEST['call_from'];
                if ($call == 'acc') {
                    $reportHeaderTitle = "Accrual Journal Entry Report";
                } else if ($call == 'inv') {
                    $reportHeaderTitle = "Inventory Journal Entry Report";
                } else {
                    $reportHeaderTitle = "Inventory Journal Entry Report";
                }
            }
 
            if ($arrayR[7] == "'t'")
                $reportA[0] = "Trial Balance";
            else if ($arrayR[7] == "'g'" && count($arrayR) == 18)
                if ($arrayR[2] == "'1990-01-01'")
                    $reportA[0] = "T-Account - Period Before as of " . $arrayR[3];
                else if ($arrayR[2] == "'1989-01-01'")
                    $reportA[0] = "T-Account - Current Cumulative as of " . $arrayR[3];
                else
                    $reportA[0] = "T-Account - Current Period as of " . $arrayR[2];
            else
                $reportA[0] = $reportHeaderTitle;

            $reportA[1] = "As of Date";
            $reportA[2] = "As of Date To";
            $reportA[3] = "Subsidiary";
            $reportA[4] = "Strategy";
            $reportA[5] = "Book";
            $reportA[6] = "Grouping Option";
            $reportA[7] = "Type";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
        } else if ($sp_name == strtolower("spa_deal_schedule_report")) {            
            switch ($arrayR['2']) {
                case "'t'":
                    $reportA[0] = "Schedule Summary Report";
                    break;
                case "'d'":
                    $reportA[0] = "Schedule Detail Report";
                    $reportA[1] = "NULL";
                    $reportA[2] = "NULL";
                    $reportA[3] = "Flow Date From";
                    $reportA[4] = "Flow Date To";
                    break;                    
            }
        } else if ($sp_name == strtolower("spa_create_disclosure_report")) {
            $reportA[0] = "Accounting Disclosure Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "Hedge Type";
            $reportA[7] = "NULL";
            $reportA[8] = "Prior Months";
        } else if ($sp_name == strtolower("spa_run_ghg_goal_tracking_report")) {

            switch ($arrayR['11']) {
                case 1:
                    $reportCase = "Run Emissions Tracking Report";
                    break;
                case 2:
                    $reportCase = "Reductions Tracking  Report";
                    break;
                case 3:
                    $reportCase = "Emissions & Reductions Tracking Report";
                    break;
                case 4:
                    $reportCase = "Emissions & Reductions Tracking Report";
                    break;
            }

            if ($arrayR[44] == "'n'") {
                $reportCase = "Benchmark Emission Input/Output data";
            } else if ($arrayR[44] == "'y'") {

                $reportCase = "Control Chart";
            }


            $reportA[0] = $reportCase;
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Base Year From";
            $reportA[5] = "Base Year To";
            $reportA[6] = "Term Start";
            $reportA[7] = "Term End";
            $reportA[8] = "Gas";
            $reportA[9] = "Frequency";
            $reportA[10] = "GHG Type";
            $reportA[11] = "NULL";
            $reportA[12] = "NULL";
            $reportA[13] = "Source Sink Type";
            $reportA[14] = "Reduction Type";
            $reportA[15] = "Reduction Sub Type";
            $reportA[16] = "Absolute Ratio Flag";
            $reportA[17] = "NULL";
            $reportA[18] = "NULL";
            $reportA[19] = "NULL";
            $reportA[20] = "UOM";
            $reportA[21] = "Reporting Year";
            $reportA[22] = "NULL";
            $reportA[23] = "Scale Factor";
            $reportA[24] = "Forecast Separate";
            $reportA[25] = "Show C02";
            $reportA[26] = "GHG Group By";
            $reportA[27] = "Reporting Month";
            $reportA[28] = "Series Type";
            $reportA[29] = "Technology";
            $reportA[30] = "Reduction Sub Type";
            $reportA[31] = "Primary Fuel";
            $reportA[32] = "Fuel Type";
            $reportA[33] = "Udf Source Sink Group";
            $reportA[34] = "Udf Group1";
            $reportA[35] = "Udf Group2";
            $reportA[36] = "Udf Group3";
            $reportA[37] = "Include Hypothetical";
            $reportA[38] = "Show Target";
            $reportA[39] = "NULL";
            $reportA[40] = "Drill Level";
            $reportA[41] = "Drill Sub";
            $reportA[42] = "Drill Term";
            $reportA[43] = "Drill Type";
            $reportA[44] = "Level1";
            $reportA[45] = "Level2";
            $reportA[46] = "Level3";
        } else if ($sp_name == strtolower("spa_sourcedealheader_reconcile_cash")) {
            $reportA[0] = "Cash Reconcillation for Derivatives";
            $reportA[1] = "NULL";
            $reportA[2] = "Deal ID From";
            $reportA[3] = "Deal ID To";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "NULL";
            $reportA[12] = "Counterparty";
            $reportA[13] = "Term Start";
            $reportA[14] = "Term End";
        } else if ($sp_name == strtolower("spa_get_assessment_results")) {
            $reportA[0] = "Assessment Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Hedge Relationship Id";
            $reportA[5] = "Date From";
            $reportA[6] = "Date To";
            $reportA[7] = "Assessment Type";
        } else if ($sp_name == strtolower("spa_ems_exceptions_report")) {
            $reportA[0] = "Run Exceptions Report";
            /* $reportA[1] = "Subsidiary";
              $reportA[2] = "Strategy";
              $reportA[3] = "Book";
              $reportA[4] = "Hedge Relationship Id";
              $reportA[5] = "Date From";
              $reportA[6] = "Date To";
              $reportA[7] = "Assessment Type"; */
        } else if ($sp_name == strtolower("spa_create_deal_report") || $sp_name == strtolower("spa_create_deal_report_paging")) {
            $reportA[0] = "Deal Report";
            $reportA[1] = "Source Book Mapping Id";
            $reportA[2] = "Deal Id From";
            $reportA[3] = "Deal Id To";
            $reportA[4] = "Date From";
            $reportA[5] = "Date To";
        } else if ($sp_name == strtolower("spa_Create_Not_Mapped_Deal_Report") || $sp_name == strtolower("spa_Create_Not_Mapped_Deal_Report_paging")) {
            //echo print_r($arrayR);die();
            if ($arrayR[8] == 'm') {
                $reportA[0] = "Mapped Deal Report";
            } else if ($arrayR[8] == 'n') {
                $reportA[0] = "Not Mapped Deal Report";
            } else {
                $reportA[0] = "Not Mapped Transaction Report";
            }
            $reportA[1] = "Group1";
            $reportA[2] = "Group2";
            $reportA[3] = "Group3";
            $reportA[4] = "Group4";
            $reportA[5] = "Date From";
            $reportA[6] = "Date To";
        } else if ($sp_name == strtolower("spa_create_tagging_audit_report") || $sp_name == strtolower("spa_create_tagging_audit_report_paging")) {
            $reportA[0] = "Tagging Audit Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Date From";
            $reportA[5] = "Date To";
            $reportA[6] = "Group1";
            $reportA[7] = "Group2";
            $reportA[8] = "Group3";
            $reportA[9] = "Group4";
            $reportA[10] = "Deal ID From";
            $reportA[11] = "Deal ID To";
            $reportA[12] = "Deal ID";
            $reportA[13] = "Counterparty";
        } else if ($sp_name == strtolower("spa_create_hedging_relationship_exception_report")) {
            $reportA[0] = "Unapproved Hedging Relationship Exception Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Used Option";
        } else if ($sp_name == strtolower("spa_Create_Missing_Assessment_Values_Exception_Report")) {
            $reportA[0] = "Missing Assessment Values Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "As of Date";
            $reportA[5] = "Quarter Threshold Date";
            $reportA[6] = "Assessment Type";
            $reportA[7] = "Show Option";
        } else if ($sp_name == strtolower("spa_Create_Available_Hedge_Capacity_Exception_Report")) {
            $reportA[0] = "Available Hedge Capacity Exception Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Hedge Type";
            $reportA[6] = "Tenor Summary";
            $reportA[7] = "NULL";
            $reportA[8] = "Exception Flag";
            $reportA[9] = "Asset Type";
            $reportA[10] = "Settlement Option";
            $reportA[11] = "Include Outstanding Forecasetd Transactions";
        } else if ($sp_name == strtolower("spa_Create_Hedge_Item_Matching_Report")) {
            $reportA[0] = "Hedge and Item Position Matching Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Match Type";
            $reportA[6] = "Settlement Option";
            $reportA[7] = "Include Outstanding Forecasetd Transactions";
            $reportA[8] = "Commodity/Index";
            $reportA[9] = "Delivery Month";
            $reportA[10] = "NULL";
            $reportA[11] = "Hedge Rel ID";
        } else if ($sp_name == strtolower("spa_Create_Pending_Transaction_Exception_Report")) {
            $reportA[0] = "Pending Transaction Exception Report";
            $reportA[1] = "Date From";
            $reportA[2] = "Date To";
            $reportA[3] = "Subsidiary";
            $reportA[4] = "Strategy";
            $reportA[5] = "Book";
        } else if ($sp_name == strtolower("spa_system_access_log")) {
            $reportA[0] = "System Access Log Report";
            $reportA[1] = "NULL";
            $reportA[2] = "User";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "Date From";
            $reportA[7] = "Date To";
            $reportA[8] = "Invalid User";
        } else if ($sp_name == strtolower("spa_my_application_log")) {
            $reportA[0] = "My Log Report";
            $reportA[1] = "NULL";
            $reportA[2] = "Log-IN";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "Log-IN From";
            $reportA[10] = "Log-IN To";
        } else if ($sp_name == strtolower("spa_Create_Source_System_Report")) {
            $reportA[0] = "Source System Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
        } else if ($sp_name == strtolower("spa_close_measurement_books")) {
            $reportA[0] = "Close Measurment Books";
        } else if ($sp_name == strtolower("spa_trader_Position_Report")) {
            $reportA[0] = "Trader Position Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "NULL";
            $reportA[4] = "Book";
            $reportA[5] = "Tenor Summary";
            $reportA[6] = "NULL";
            $reportA[7] = "Settlement Option";
            $reportA[8] = "Portfolio Name";
            $reportA[9] = "NULL";
            $reportA[10] = "Commodity Balance";
            $reportA[11] = "Transfer";
            $reportA[12] = "Transaction Type";
            $reportA[13] = "Deal ID";
            $reportA[14] = "Ref ID";
            $reportA[15] = "Include Option";
        } else if ($sp_name == strtolower("spa_get_run_measurement_process_status")) {
            $reportA[0] = "Run Measurement Process Status";
            // $reportA[1] = "Process Id";
        } else if ($sp_name == strtolower("spa_get_locked_values")) {
            $reportA[0] = "De-designation Locked Values";
            $reportA[1] = "NULL";
            $reportA[2] = "Book";
            $reportA[3] = "Date From";
            $reportA[4] = "Date To";
            $reportA[5] = "Deal ID From";
            $reportA[6] = "Deal ID To";
        } else if ($sp_name == strtolower("spa_ems_source_model_report")) {
            $reportA[0] = "Emissions Source Model Report";
            /* $reportA[1] = "NULL";
              $reportA[2] = "Book";
              $reportA[3] = "Date From";
              $reportA[4] = "Date To";
              $reportA[5] = "Deal ID From";
              $reportA[6] = "Deal ID To"; */
        } else if ($sp_name == strtolower("spa_create_lifecycle_of_hedges")) {
            $reportA[0] = "Life Cycle of Hedges";
            $reportA[1] = "Book";
            $reportA[2] = "As of Date";
            $reportA[3] = "Deal ID From";
            $reportA[4] = "Deal ID To";
            $reportA[5] = "Source Book Mapping Id";
        } else if ($sp_name == strtolower("spa_GetAllDealsbySourceBookId")) {
            $reportA[0] = "Hedges Not Designated";
            $reportA[1] = "Source Book Mapping Id";
            $reportA[2] = "Date From";
            $reportA[3] = "Date To";
        } else if ($sp_name == strtolower("spa_genhedgegroupdetail")) {
            $reportA[0] = "Generation Hedge Group Detail";
            $reportA[1] = "NULL";
            $reportA[2] = "Gen Hedge Group Detail Id";
            $reportA[3] = "Gen Hedge Group Id";
        } else if ($sp_name == strtolower("spa_genhedgegroup")) {
            $reportA[0] = "Generation Hedge Group Detail";
            $reportA[1] = "NULL";
            $reportA[2] = "Gen Hedge Group Id";
        } else if ($sp_name == strtolower("spa_get_assessment_results_curves_plot")) {
            $reportA[0] = "Regression Price Series";
            $reportA[1] = "Result ID";
        } else if ($sp_name == strtolower("spa_fas_eff_ass_test_results_profile")) {
            $reportA[0] = "Regression Hedge/Item Profile";
            $reportA[1] = "NULL";
            $reportA[2] = "Result ID";
        } else if ($sp_name == strtolower("spa_get_transaction_gen_status")) {
            $reportA[0] = "Forecasted Transaction Generation Status";
            $reportA[1] = "Gen Hedge Group Id";
        } else if ($sp_name == strtolower("spa_GetAllUnapprovedItemGen")) {
            $reportA[0] = "Outstanding Generation Hedge Group";
            $reportA[1] = "Book";
            $reportA[2] = "Date From";
            $reportA[3] = "Date To";
        } else if ($sp_name == strtolower("spa_GetAllUnapprovedLinkGen")) {
            $reportA[0] = "Outstanding Generation Hedge Group";
            $reportA[1] = "Generation Hedge Group";
        } else if ($sp_name == strtolower("spa_GetAllGenTransactions")) {
            $reportA[0] = "Outstanding Generation Hedge Group";
            $reportA[1] = "Flag";
            $reportA[2] = "Generation Hedge Group";
        } else if ($sp_name == strtolower("spa_faslinkheader")) {
            $reportA[0] = "Hedging Relationships";
            $reportA[1] = "NULL";
            $reportA[2] = "Relationship Id";
            $reportA[3] = "Book";
            $reportA[4] = "Dedesignated Flag";
            $reportA[5] = "Link Active";
            $reportA[6] = "Date From";
            $reportA[7] = "Date To";
        } else if ($sp_name == strtolower("spa_faslinkdetail")) {
            $reportA[0] = "Hedging Relationship Detail";
            $reportA[1] = "Flag1";
            $reportA[2] = "Flag2";
            $reportA[3] = "Relationship Id";
        } else if ($sp_name == strtolower("spa_faslinkdetaildedesignation")) {
            $reportA[0] = "Hedging Relationship Detail";
            $reportA[1] = "NULL";
            $reportA[2] = "Relationship Id";
        } else if ($sp_name == strtolower("spa_Get_Price_Curves")) {
            $reportA[0] = "Price Curves";
            $reportA[1] = "Curve Id";
            $reportA[2] = "Curve Type";
            $reportA[3] = "Curve Source";
            $reportA[4] = "Date From";
            $reportA[5] = "Date To";
            $reportA[6] = "Tenor From";
            $reportA[7] = "Tenor To";
        } else if ($sp_name == strtolower("spa_get_eff_ass_test_run_log")) {
            $reportA[0] = "Assessment Run Results Log";
        } else if ($sp_name == strtolower("spa_netting_groups")) {
            $reportA[0] = "Netting Groups";
            $reportA[1] = "NULL";
            $reportA[2] = "Netting Parent Group Id";
        } else if ($sp_name == strtolower("spa_netting_parent_groups")) {
            $reportA[0] = "Parent Netting Groups";
            $reportA[1] = "NULL";
        } else if ($sp_name == strtolower("spa_create_hedge_relationship_report")) {
            $reportA[0] = "Hedging Relationship Report";
            $reportA[1] = "Date From";
            $reportA[2] = "Date To";
            $reportA[3] = "Subsidiary";
            $reportA[4] = "Strategy";
            $reportA[5] = "Book";
            $reportA[6] = "Relationship Id";
        } else if ($sp_name == strtolower("spa_netting_group_detail")) {
            $reportA[0] = "Netting Group Applies To";
            $reportA[1] = "NULL";
            $reportA[2] = "Netting Group Id";
        } else if ($sp_name == strtolower("spa_get_db_measurement_trend")) {
            $reportA[0] = "Measurement Trend Report";
            $reportA[1] = "Drill Down Level";
            $reportA[2] = "Report Type";
            $reportA[3] = "Subsidiary";
            $reportA[4] = "Drill Down Param";
            $reportA[5] = "Date From";

            $reportA[6] = "Date To";
            $reportA[7] = "Discount Option";
            $reportA[8] = "Strategy";
            $reportA[9] = "Book";
        } else if ($sp_name == strtolower("spa_create_failed_assessment_reports")) {
            $reportA[0] = "Failed Assessment Values Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "As of Date";
            $reportA[5] = "Show Option";
        } else if ($sp_name == strtolower("spa_Create_Cash_Flow_Report")) {
            $reportA[0] = "Cashflow/Earnings Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "Granularity Type";
            $reportA[7] = "Report Type";
            $reportA[8] = "Summary Option";
        } else if ($sp_name == strtolower("spa_msmt_excp_eff_pnl")) {
            $reportA[0] = "Measurement Process Exceptions: Missing PNL As of Hedge Effective Date";
        } else if ($sp_name == strtolower("spa_msmt_excp_pnl")) {
            $reportA[0] = "Measurement Process Exceptions: Missing PNL As of Run Date";
        } else if ($sp_name == strtolower("spa_drill_down_msmt_report")) {
            $reportA[0] = "Measurement Report Drilldown";
            $reportA[1] = "Drilldown On";
            $reportA[2] = "Discount Option";
            $reportA[3] = "As of Date";
            $reportA[4] = "Hedging Relationship ID";
            $reportA[5] = "Settlement Option";
            $reportA[6] = "Term";
        } else if ($sp_name == strtolower("spa_get_deal_for_mtm")) {
        $reportA[0] = "Run Deal Settlement";//MTM Of Forcasted Transactions
            $reportA[1] = "ID";
            $reportA[2] = "As of Date";
        } else if ($sp_name == strtolower('spa_monte_carlo_model')) {
            $reportA[0] = 'Maintain Risk Factor Models'; //Maintain Risk Factor Model export report
            $reportA[1] = 'NULL';
            $reportA[2] = 'NULL';
            $reportA[3] = 'As of Date';
        } else if ($sp_name == strtolower('spa_limit_header')) {
            $reportA[0] = 'Maintain Limits'; //Maintain Limits export report
        } else if ($sp_name == strtolower('spa_maintain_portfolio_group')) {
            $reportA[0] = 'Maintain Portfolio Group'; //Maintain Portfolio Group
            $reportA[1] = 'NULL';
            $reportA[2] = 'NULL';
            $reportA[3] = 'NULL';
            $reportA[4] = 'NULL';
            $reportA[5] = 'User';
            $reportA[6] = 'Role';
            $reportA[7] = 'Public';
            $reportA[8] = 'Active';
        } else if ($sp_name == strtolower('spa_maintain_scenario')) {
            $reportA[0] = 'Maintain Scenario'; //Maintain Scenario
            $reportA[1] = 'NULL';
            $reportA[2] = 'NULL';
            $reportA[3] = 'NULL';
            $reportA[4] = 'NULL';
            $reportA[5] = 'User';
            $reportA[6] = 'Role';
            $reportA[7] = 'Active';
            $reportA[8] = 'Public';
            $reportA[9] = 'NULL';
            $reportA[10] = 'NULL';
            $reportA[11] = 'NULL';
            $reportA[12] = 'NULL';
            $reportA[13] = 'Group ID';
        } else if ($sp_name == strtolower('spa_maintain_scenario_group')) {
            $reportA[0] = 'Maintain Scenario Group'; //Maintain Scenario Group
            $reportA[1] = 'NULL';
            $reportA[2] = 'NULL';
            $reportA[3] = 'NULL';
            $reportA[4] = 'NULL';
            $reportA[5] = 'User';
            $reportA[6] = 'Role';
            $reportA[7] = 'Active';
            $reportA[8] = 'Public';
        } else if ($sp_name == strtolower('spa_maintain_whatif_criteria')) {
            $reportA[0] = ($arrayR[8] == 'null') ? 'Maintain What-If Criteria' : 'Run What-If Analysis Report'; //Maintain What-If Criteria, Run What-If Analysis Report
            $reportA[1] = 'NULL';
            $reportA[2] = 'NULL';
            $reportA[3] = 'NULL';
            $reportA[4] = 'NULL';
            $reportA[5] = 'User';
            $reportA[6] = 'Role';
            $reportA[7] = ($arrayR[8] == 'null') ? 'NULL' : 'What-If Criteria Group';
            $reportA[8] = 'Active';
            $reportA[9] = 'Public';
        } else if ($sp_name == strtolower('spa_Report_record')) {
            $reportA[0] = 'Report Writer'; //Report Writer
        } else if ($sp_name == strtolower("spa_get_assessment_trend")) {
            $reportA[0] = "Assessment Trend Graph";
            $reportA[1] = "Relationship ID";
            $reportA[2] = "Assessment Type";
            $reportA[3] = "Date From";
            $reportA[4] = "Date To";
        } else if ($sp_name == strtolower("spa_effhedgereltypewhatif")) {
        $reportA[0] = "What-If Effectiveness Analysis";
            $reportA[1] = "NULL";
            $reportA[2] = "Book";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "NULL";
            $reportA[12] = "NULL";
            $reportA[13] = "NULL";
            $reportA[14] = "NULL";
            $reportA[15] = "NULL";
            $reportA[16] = "NULL";
            $reportA[17] = "NULL";
            $reportA[18] = "User ID";
        } else if ($sp_name == strtolower("spa_StaticDataValues")) {
            $reportA[0] = "Maintain Static Data";
            $reportA[1] = "NULL";
            $reportA[2] = "Type ID";
        } else if ($sp_name == strtolower("spa_source_book_maintain")) {
            $reportA[0] = "Maintain Definition Book Attribute";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_brokers_maintain")) {
            $reportA[0] = "Maintain Definition Broker";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_commodity_maintain")) {
            $reportA[0] = "Maintain Definition Commodity";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_contract_detail")) {
            $reportA[0] = "Maintain Definition Contract";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_currency_maintain")) {
            $reportA[0] = "Maintain Definition Currency";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_price_curve_def_maintain")) {
            $reportA[0] = "Setup Price Curves";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_deal_type_maintain")) {
            $reportA[0] = "Maintain Definition Deal Type";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_internal_desk")) {
            $reportA[0] = "Maintain Definition Internal Desk";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_internal_portfolio")) {
            $reportA[0] = "Maintain Definition Internal Portfolio";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_legal_entity_maintain")) {
            $reportA[0] = "Maintain Definition Legal Entity";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_minor_location")) {
            $reportA[0] = "Setup Location";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_major_location")) {
            $reportA[0] = "Maintain Definition Location Group";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_product")) {
            $reportA[0] = "Maintain Definition Product";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_traders_maintain")) {
            $reportA[0] = "Maintain Definition Trader";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_uom_maintain")) {
            $reportA[0] = "Maintain Definition UOM";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_rec_volume_unit_conversion")) {
            $reportA[0] = "Maintain Definition UOM Conversion";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_source_counterparty_maintain")) {
            $reportA[0] = "Maintain Definition Counterparty";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
        } else if ($sp_name == strtolower("spa_gl_system_mapping")) {
            $reportA[0] = "Map GL Codes";
            $reportA[1] = "NULL";
            $reportA[2] = "Accounting Code 1";
            $reportA[3] = "Accounting Code 2";
            $reportA[4] = "Accounting Code 3";
            $reportA[5] = "NULL";
            $reportA[6] = "Subsidiary";
        } else if ($sp_name == strtolower("spa_Get_All_Notes")) {
            $reportA[0] = "Manage Document";
            $reportA[1] = "Notes For";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "Notes Category ID";
            $reportA[5] = "Date From";
            $reportA[6] = "Date To";
            $reportA[7] = "Subsidiary";
        } else if ($sp_name == strtolower("spa_effhedgereltype")) {
            $reportA[0] = "Hedging Relationship Types";
            $reportA[1] = "NULL";
            $reportA[2] = "Book";
            $reportA[3] = "Approved";
            $reportA[4] = "Active";
        } else if ($sp_name == strtolower("spa_create_hedge_rel_type_report")) {
            $reportA[0] = "Hedging Relationship Types Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Rel Type ID";
            $reportA[5] = "Approved";
            $reportA[6] = "Active";
        } else if ($sp_name == strtolower("spa_effhedgereltypewhatifdetail")) {
            $reportA[0] = "What-If Analysis";
            $reportA[1] = "NULL";
            $reportA[2] = "Flag";
            $reportA[3] = "AssmtTypeID";
        } else if ($sp_name == strtolower("spa_Get_Whatif_Assessment_Results")) {
            $reportA[0] = "What-If Analysis";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "AssmtTypeID";
            $reportA[5] = "Date From";
            $reportA[6] = "Date To";
            $reportA[7] = "Assessment Type";
        } else if ($sp_name == strtolower("spa_create_roll_forward_inventory_report")) {
            $reportA[0] = "Roll Forward Inventory Report";
            $reportA[1] = "Summary Option";
            $reportA[2] = "As of Date From";
            $reportA[3] = "As of Date To";
            $reportA[4] = "Account Name";
            $reportA[5] = "GL Code";
        } else if ($sp_name == strtolower("spa_get_fifo_lifo_links")) {
        $reportA[0] = "De-Designation of Hedge by FIFO/LIFO";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "Book";
            $reportA[4] = "Term Start";
            $reportA[5] = "Term End";
            $reportA[6] = "Term Match";
            $reportA[7] = "Total Volume";
            $reportA[8] = "Convert UOM";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "Volume Match";
            $reportA[12] = "Sort Order";
            $reportA[13] = "Dedesignate Date";

            /**
             * $reportA[0] = "De-Designation of a Hedge";
             * $reportA[1] = "Book";
             * $reportA[2] = "Sort Order";
             * $reportA[3] = "Dedesignate Date";
             * $reportA[4] = "Term Match";
             * $reportA[5] = "Volume Match";
             * $reportA[6] = "NULL";
             * $reportA[7] = "Hedge Start";
             * $reportA[8] = "Hedge End";
             * $reportA[9] = "Item Start";
             * $reportA[10] = "Item End";
             * $reportA[11] = "Total Volume";
             * $reportA[12] = "Convert UOM";
             */
        } else if ($sp_name == strtolower("spa_get_dummy_link")) {
            $reportA[0] = "De-Designation of a Hedge";
        } else if ($sp_name == strtolower("spa_create_hedge_effectiveness_report")) {
            $reportA[0] = "Hedge Ineffectiveness Report";
            $reportA[1] = "Subsidy";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "As of Date";
            $reportA[5] = "Link Id";
            $reportA[6] = "Hedge MTM";

            $reportA[7] = "Present/Future";
            $reportA[8] = "Rounding value";
            $reportA[9] = "Summary Detail";
            $reportA[10] = "Source Deal Header Id";
            $reportA[11] = "Deal Id";
        } else if ($sp_name == strtolower("spa_compare_msmt_values")) {
        $reportA[0] = "What-If Measurement Analysis";
            $reportA[1] = "ID";
            $reportA[2] = "As of Date";
            $reportA[3] = "Re-Measure";
            $reportA[4] = "As of Date";
            $reportA[5] = "Re-Measure";
            $reportA[6] = "";
            $reportA[7] = "Discount Option";
        } else if ($sp_name == strtolower("spa_drill_down_jentries")) {

            $reportA[0] = "Drill-down on Journal Entry Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Rel ID";
            $reportA[3] = "Reverse Option";
            $reportA[4] = "GL Number";
            $reportA[5] = "Account Name";
        } else if ($sp_name == strtolower("spa_Create_MTM_Journal_Entry_Report_Reverse")) {

            $reportA[0] = "Journal Entry Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "Settlement Option";
            $reportA[7] = "Hedge Type";
            $reportA[8] = "Summary Option";
            $reportA[9] = "Reverse Option";
            $reportA[10] = "Rel ID";
        } else if ($sp_name == strtolower("spa_netted_journal_entry_report_Reverse")) {
            $reportA[0] = "Netted Journal Entry Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Discount Option";
            $reportA[3] = "Summary Option";
            $reportA[4] = "Netting Group Parent Id";
            $reportA[5] = "Reverse Option";
        } else if ($sp_name == strtolower("spa_Create_MTM_Period_Report") || ($sp_name == strtolower("spa_Create_MTM_Period_Report_Paging"))) {
            //print_r($reportA);        
            if (isset($REQUEST['report_name'])) {
                $report_name = ltrim(rtrim($REQUEST['report_name'],"'"),"'");
                $reportA[0] = $report_name;
            } else {
                if($call_from == 'm' || $call_from == "'m'") {
                    $reportA[0] = "Run MTM Report";
                } else if($call_from == "'t'" || $call_from == '"t"' || $call_from == 't') {
                    $reportA[0] = "Run FDGL Treatment Report";
                } else {
                    $reportA[0] = "Run Settlement Report";
                }
            }
    
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Present Value Option";
            $reportA[6] = "Tenor Option";
            $reportA[7] = "Hedge Type";
            $reportA[8] = "Group By";
        } else if ($sp_name == strtolower("spa_Create_AOCI_Report")) {
            $reportA[0] = "AOCI Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Tenor Option";
            $reportA[6] = "Present Value Option";
            $reportA[7] = "Summary By";
            $reportA[8] = "Round Value";
            $reportA[9] = "Term Start";
            $reportA[10] = "Term End";
        } else if ($sp_name == strtolower("spa_Create_Reconciliation_Report")) {
            $reportA[0] = "Period Change Values Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Present Value Option";
            $reportA[6] = "Hedge Type";
            $reportA[7] = "Summary Option";
            $reportA[8] = "Prior Months";
        } else if ($sp_name == strtolower("spa_Create_Reclassification_Report")) {
            $reportA[0] = "Cash Flow Hedges Included in AOCI on the Balance Sheet";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "NULL";
            $reportA[7] = "Summary Group";
            $reportA[8] = "Tax";
        } else if ($sp_name == strtolower("spa_Create_NetAsset_Report")) {
            if ($arrayR[7] == "'a'")
                $reportA[0] = "Roll-Forward of MTM Energy Contract Net Assets";
            else
                $reportA[0] = "Maturity and Source of Fair Value of MTM Energy Contract Net Assets";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "NULL";
            $reportA[7] = "Summary Group";
            $reportA[8] = "Prior Months";
        } else if ($sp_name == strtolower("spa_privilege_report") || $sp_name == strtolower("spa_privilege_report_paging")) {
            $reportA[0] = "Security Privilege Report";
            $reportA[1] = "Privilege Report Type";
            $reportA[2] = "User";
            $reportA[3] = "Role";
        } else if ($sp_name == strtolower("spa_Curve_value_report")) {
            $reportA[0] = "Curve Value Report";
        } else if ($sp_name == strtolower("spa_journal_entry_posting")) {
            $reportA[0] = "Journal Entry Posting Exception Report";
            $reportA[1] = "NULL";
            $reportA[2] = "Exception Option";
            $reportA[3] = "NULL";
            $reportA[4] = "As of Date";
        } else if ($sp_name == strtolower("spa_create_income_statement")) {
            $reportA[0] = "Income Statement Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "Summary Group";
            $reportA[7] = "Prior Months";
        } else if ($sp_name == strtolower("spa_journal_entry_posting_temp")) {
            $reportA[0] = "Journal Entry Posting";
            $reportA[1] = "NULL";
            $reportA[2] = "As of Date";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "NULL";
            $reportA[12] = "Report Type";
        } else if ($sp_name == strtolower("spa_REC_State_Allocation_Report")) {
            $reportA[0] = "Generator/Credit Source Allocation by Jurisdiction Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Summary Option";
            $reportA[3] = "Compliance Year";
            $reportA[4] = "Jurisdiction";
            $reportA[5] = "Generator or Credit Source";
        } else if ($sp_name == strtolower("spa_getemissionprofile")) {
            $reportA[0] = "Emissions Profile/Credit Requirements";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "Type";
            $reportA[4] = "Subsidiary";
            $reportA[5] = "Strategy";
            $reportA[6] = "Book";
            $reportA[7] = "Year";
        } else if ($sp_name == strtolower("spa_Create_fas157_Disclosure_Report")) {
            $reportA[0] = "Fair Value Disclosure Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Discount Option";
            $reportA[6] = "Summary Option";
            $reportA[7] = "Asset Liability";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "Drill By";
        } else if ($sp_name == strtolower("spa_gen_invoice_variance_report")) {
            if ($call_from == 'm')
                $reportA[0] = "Financial Model Report";
            else
            $reportA[0] = "Contract Settlement Report";
            $reportA[1] = "Counterparty";
            $reportA[2] = "Production Month";
            $reportA[3] = "Contract";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "As Of Date";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "Line Item";
            $reportA[12] = "NULL";
            $reportA[13] = "NULL";
            $reportA[14] = "NULL";
            $reportA[15] = "NULL";
            $reportA[16] = "NULL";
            $reportA[17] = "NULL";
            $reportA[18] = "NULL";
            $reportA[19] = "Invoice Number";
        } else if ($sp_name == strtolower("spa_REC_Target_Report") || $sp_name == strtolower("spa_create_target_position_report")) {
            $reportA[0] = "Target Position Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Assignment Type";
            $reportA[6] = "Summary Option";
            $reportA[7] = "Compliance Year";
            $reportA[8] = "Jurisdiction";
            $reportA[9] = "Include Banked Transactions";
            $reportA[10] = "Env Product";
		} else if ($sp_name == strtolower("spa_Target_Report") || $sp_name == strtolower("spa_create_target_position_report")) {
            $reportA[0] = "Target Position Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Assignment Type";
            $reportA[6] = "Summary Option";
            $reportA[7] = "Compliance Year";
            $reportA[8] = "Jurisdiction";
            $reportA[9] = "Include Banked Transactions";
            $reportA[10] = "Env Product";
        } else if ($sp_name == strtolower("spa_view_target_report")) {
            $reportA[0] = "Target Position Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Assignment Type";
            $reportA[6] = "Summary Option";
            $reportA[7] = "Compliance Year";
            $reportA[8] = "Jurisdiction";
            $reportA[9] = "Include Banked Transactions";
            $reportA[10] = "Env Product";
        } else if ($sp_name == strtolower("spa_REC_Target_Report_Drill") || $sp_name == strtolower("spa_REC_Target_Report_Drill_paging")) {
            $reportA[0] = "Target Position Report - Details";
            $reportA[1] = "As of Date";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "Sub";
            $reportA[11] = "Str";
            $reportA[12] = "Books";
            $reportA[13] = "Assigned Jurisdiction";
            $reportA[14] = "Year";
            $reportA[15] = "Type";
            $reportA[16] = "Env Product";
            $reportA[17] = "Type";
        } else if ($sp_name == strtolower("spa_create_lifecycle_of_recs") || $sp_name == strtolower("spa_create_lifecycle_of_recs_paging")) {
            $reportA[0] = "Lifecycle of Transaction";
            $reportA[1] = "As of Date";
            $reportA[2] = "Book Map";
            $reportA[3] = "IDs";
        } else if ($sp_name == strtolower("spa_run_wght_avg_inventory_cost_report")) {
            $reportA[0] = "Inventory Wght Avg Cost Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "As of Date From";
            $reportA[3] = "As of Date To";
            $reportA[4] = "Jurisdiction";
            $reportA[5] = "Technology";
        } else if ($sp_name == strtolower("spa_find_gis_recon_deals") || $sp_name == strtolower("spa_find_gis_recon_deals_paging")) {
            $reportA[0] = "Certificate Reconcillation Report";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "Vintage From";
            $reportA[4] = "Vintage To";
            $reportA[5] = "Generator or Credit Source";
            $reportA[6] = "Certification Entity";
            $reportA[7] = "Status";
            $reportA[8] = "User Action";
            $reportA[9] = "Feeder Deal ID";
        } else if ($sp_name == strtolower("spa_create_rec_settlement_report") || $sp_name == strtolower("spa_create_rec_settlement_report_paging")) {
            $reportA[0] = "Counterparty Settlement Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Book Map";
            $reportA[5] = "Deal ID";
            $reportA[6] = "Deal Date From";
            $reportA[7] = "Deal Date To";
            $reportA[8] = "Counterparty";
            $reportA[9] = "Summary Option";
            $reportA[10] = "Internal External";
            $reportA[11] = "Type";
            $reportA[12] = "Feeder Deal ID";
        } else if ($sp_name == strtolower("spa_create_rec_margin_report") || $sp_name == strtolower("spa_create_rec_margin_report_paging")) {
            if ($arrayR[11] == "'d'")
                $reportA[0] = "Margin Report - Detail";
            else if ($arrayR[11] == "'t'")
                $reportA[0] = "Margin Report - By Trader";
            else
                $reportA[0] = "Margin Report - Summary";

            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "As of Date From";
            $reportA[5] = "As of Date To";
            $reportA[6] = "Counterparty";
            $reportA[7] = "Trader";
            $reportA[8] = "Technology";
            $reportA[9] = "Generator or Credit Source";
            $reportA[10] = "Summary Option";
        }


        else if ($sp_name == strtolower("spa_get_implied_volatility_report") || $sp_name == strtolower("spa_get_implied_volatility_report")) {

            $reportA[0] = "Implied Volatility Report";
            $reportA[1] = "Report Type";
            $reportA[2] = "As of Date";
            $reportA[3] = "Curve Id";
            $reportA[4] = "Term Start";
            $reportA[5] = "Term End";
        } else if ($sp_name == strtolower("spa_get_counterparty_exposure_report") || $sp_name == strtolower("spa_get_counterparty_exposure_report")) {

            if ($arrayR[2] == "'e'")
                $reportA[0] = "Counterparty Exposure Report";
            else if ($arrayR[2] == "'f'")
                $reportA[0] = "Fixed/MTM Exposure Report";
            else if ($arrayR[2] == "'c'")
                $reportA[0] = "Concentration Exposure Report";
            else if ($arrayR[2] == "'r'")
                $reportA[0] = "Credit Reserve Report";
            else if ($arrayR[2] == "'a'")
                $reportA[0] = "Aged A/R Report";



            $reportA[1] = "Report type";
            $reportA[2] = "Summary Option";
//					$reportA[3] = "What if group";
            $reportA[3] = "Group By";
            $reportA[4] = "As of Date";
            $reportA[5] = "Subsidiary";
            $reportA[6] = "Strategy";
            $reportA[7] = "Book";
            $reportA[8] = "Counterparty";
            $reportA[9] = "Term Start";
            $reportA[10] = "Term End";
// Commenetd 12 to 16 against the Feature Request 310 by Vishwas
//					$reportA[12] = "Book Map1";
//					$reportA[13] = "Book Map2";
//					$reportA[14] = "Book Map3";
//					$reportA[15] = "Book Map4";
//					$reportA[16] = "Trader";
            $reportA[11] = "Entity Type";
            $reportA[12] = "Counterparty Type";
            $reportA[13] = "Risk Rating";
            $reportA[14] = "Debt Rating";
            $reportA[15] = "Industry Type1";
            $reportA[16] = "Industry Type2";
            $reportA[17] = "SIC Code";
            $reportA[18] = "Include Potential";
            $reportA[19] = "Show Exceptions";
            $reportA[20] = "Block Trading";
            $reportA[21] = "Watch List";
// Added 22 to 27 against the Feature Request 310 by Vishwas
            $reportA[22] = "Tenor Option";
            $reportA[23] = "Round Value";
            $reportA[24] = "Apply Paging";
            $reportA[25] = "Curve Source";
            $reportA[26] = "Netting Parent Group";
            $reportA[27] = "Present Future";
        }



        else if ($sp_name == strtolower("spa_get_rec_activity_report") || $sp_name == strtolower("spa_get_rec_activity_report_paging")) {
            //print_r($arrayR[8]);
            if ($arrayR[43] == "'t'") {
                $report_name = "Position Report";
            } else {
                $report_name = "Transactions Report";
            }
            if ($arrayR[8] == "'s'")
                $reportA[0] = $report_name . " - Summary";
            else if ($arrayR[8] == "'t'")
                $reportA[0] = $report_name . " - Trader";
            else if ($arrayR[8] == "'g'")
                $reportA[0] = $report_name . " - Generator";
            else if ($arrayR[8] == "'c'")
                $reportA[0] = $report_name . " - Counterparty";
            else if ($arrayR[8] == "'o'")
                $reportA[0] = $report_name . " - Env Product & Vintage";
            else if ($arrayR[8] == "'v'")
                $reportA[0] = $report_name . " - Trader & Vintage";
            else if ($arrayR[8] == "'z'")
                $reportA[0] = $report_name . " - Counterparty & Vintage";
            else if ($arrayR[8] == "'y'")
                $reportA[0] = $report_name . " - Generator By Year";
            else if ($arrayR[8] == "'h'")
                $reportA[0] = $report_name . " - Generator/Credit Source Group";
            else if ($arrayR[8] == "'i'")
                $reportA[0] = $report_name . " - Generator/Credit Source By Group ";
            else if ($arrayR[8] == "'a'")
                $reportA[0] = $report_name . " - Assigned Group ";
            else if ($arrayR[8] == "'p'")
                $reportA[0] = $report_name . " - Detail Options Deals ";
            else if ($arrayR[8] == "'b'")
                $reportA[0] = $report_name . " - Activity By Year ";
            else if ($arrayR[8] == "'e'")
                $reportA[0] = $report_name . " - Expiration ";
            else if ($arrayR[8] == "'x'")
                $reportA[0] = $report_name . " - Tier Type ";
            else
                $reportA[0] = $report_name . " - Detail";

            $reportA[1] = "As Of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Assignment type";
            $reportA[6] = "Report Option";
            $reportA[7] = "Compliance Year";
            $reportA[8] = "Jurisdiction";
            $reportA[9] = "Env Product";
            $reportA[10] = "Generator or Credit Source";
            $reportA[11] = "Convert UOM";
            $reportA[12] = "Convert Assignment Type";
            $reportA[13] = "ID From";
            $reportA[14] = "ID To";
            $reportA[15] = "Cert From";
            $reportA[16] = "Cert To";
            $reportA[17] = "Vintage From";
            $reportA[18] = "Vintage To";
            $reportA[19] = "Deal Date From";
            $reportA[20] = "Deal Date To";
            $reportA[21] = "Technology";
            $reportA[22] = "BuySell";
            $reportA[23] = "Status";
            $reportA[24] = "GIS";
            $reportA[25] = "Counterparty";
            $reportA[26] = "TransactionType";
            $reportA[27] = "To be Assigned";
            $reportA[28] = "Deal Sub Type ID";

            if (count($arrayR) > 30) {
                $reportA[29] = "Drill Counterparty";
                $reportA[30] = "Drill Technology";
                $reportA[31] = "Drill Deal Date";
                $reportA[32] = "Drill Buy Sell";
                $reportA[33] = "Drill State";
                $reportA[34] = "Drill Env Product";
                $reportA[35] = "Drill UOM";
                $reportA[36] = "Drill Trader";
                $reportA[37] = "Drill Generator or Credit Source";
                $reportA[38] = "Drill Assignment";
                $reportA[39] = "Drill Expiration";
            }
        } else if ($sp_name == strtolower("spa_create_rec_invoice_report")) {
            //print_r($arrayR);
            //echo count($arrayR)   ;
            $report_name = "Transactions Invoice";
            //echo $REQUEST['invoice_remittance'] ;
            //if(isset($REQUEST['invoice_remittance']) && ($REQUEST['invoice_remittance'] == "r"))
            //	$report_name = "REC Transactions Remittance";
            //if negative it would be Remittance Report else it would be Invoice report
            $save_invoice_id = "NULL";
            if (count($arrayR) > 12)
                $save_invoice_id = $arrayR[12];

            if (count($arrayR) > 13) {
                $sqlH = "EXEC spa_create_rec_invoice_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $save_invoice_id, 't',$arrayR[14]";
            } else {
                $sqlH = "EXEC spa_create_rec_invoice_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $save_invoice_id, 't',$arrayR[12]";
            }
            $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
            while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
                $total_amount = $row[1];
                if ($total_amount < 0)
                    $report_name = "Transactions Remittance";
            }

            if (count($arrayR) == 13)
                $invoice_number = $arrayR[12];
            else
                $invoice_number = 'XXXXXXX';
            $bill_to = "<b>Bill To: Company Name</b><br>Phone: 202-321-2321<br>Fax: 232-232-2322";
            $bill_from = "<b>Bill From: Xcel Energy</b><br>1099 18th St., Suite 3000<br>Denver, CO 80202<br>Contact: Mike Smith";
            $term = "Term:<b> Net 30 days";
            $payment_instruction = "<b>Instructions: </b>Please wire payment to 'The Account of Xcel Energy' Norwest Bank ABA 1023103123 / Account # 90232943234.
                                Please contact Mike Smith at 303-308-9011 for any questions related to this invoice.";
            $invoice_date = $arrayR[7];

            if (count($arrayR) == 13) {
                $sql = "EXEC spa_get_invoice_info $invoice_number";
                //echo $sql; die();

                $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
                while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
                    $invoice_number = $row[1];
                    $bill_to =  $row[2];
                    $bill_from = $row[3];
                    $term = $row[4];
                    $payment_instruction = $row[5];
                    $invoice_date = $row[6];
                }
            }


            $reportA[0] = "<center>$report_name</center>
                                <table align='left' border='0' cellpadding='2' cellspacing='6' width='100%' bgcolor='#f8fbfe'>
                               <tr>
                               <td align='left' width='80%'>$bill_to</td>
                               <td align='right' width='20%'>$bill_from</td>
                               <br>
                               </tr>
                               <tr>
                               <td align='left'><b>Invoice #:</b> $invoice_number</td>
                               <td align='right'><b>$term</td>
                               </tr>
                               <tr>
                               <td rowspan='2' align='left'>$payment_instruction</td>
                                <td align='right'><b>Invoice Date:</b> $invoice_date</td>
                               </tr>
                                </table>
                ";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
        } else if ($sp_name == strtolower("spa_create_rec_confirm_report")) {
            if (count($arrayR) == 13)
                $confirm_id = $arrayR[12];
            else
                $confirm_id = 'XXXXXXX';
            $from_text = "<b>From: Xcel Energy</b><br>1099 18th St., Suite 3000<br>Denver, CO 80202<br>Contact: Mike Smith";
            $to_text = "<b>To: Company Name</b><br>Phone: 202-321-2321<br>Fax: 232-232-2322";
            $confirm_instruction = "This is a confirmation of the following transactions
                               entered into pursuant to a telephone conversation on the deal dates specified below.";
            $confirm_date = $arrayR[7];

            if (count($arrayR) == 13) {
                $sql = "EXEC spa_get_confirm_info $confirm_id";
                //echo $sql; die();

                $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
                while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
                    $confirm_id = $row[1];
                    $from_text = $row[2];
                    $to_text = $row[3];
                    $confirm_instruction = $row[4];
                    $confirm_date = $row[5];;
                }
            }


            $reportA[0] = "<center>Transactions Confirm</center>
                                <table align='left' border='0' cellpadding='2' cellspacing='6' width='100%' bgcolor='#f8fbfe'>
                               <tr>
                               <td align='left' width='80%'>$to_text</td>
                               <td align='right' width='20%'>$from_text</td>
                               <br>
                               </tr>
                               <tr>
                               <td align='left'><b>Reference #:</b> $confirm_id</td>
                               <td align='right'><b>Date:</b> $confirm_date</td>
                               </tr>

                               <td rowspan='2' align='left'>$confirm_instruction</td>
                               </tr>
                                </table>
                ";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
        } else if ($sp_name == strtolower("spa_create_rec_compliance_report") || $sp_name == strtolower("spa_create_rec_compliance_report_paging")) {
            // print_r($arrayR);
            $sql = "EXEC spa_get_assignment_default_uom $arrayR[7], $arrayR[5]";
            //echo $sql; die();

            $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
            $uom = "";
           while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
                $uom = $row[1];
            }

//                     $reportA[0] = "Credits Tracking Report<br>Southwestern Public Service Company<br>Jurisdiction: Texas<br><i>Beginning REC Balance - Details</i>";
            if ($arrayR[7] == 2)
                $reportA[0] = "Credits Tracking Report<br><i>Beginning Balance - Details</i><br>$uom";
            else if ($arrayR[7] == 3)
                $reportA[0] = "Credits Tracking Report<br><i>Compliance Year Credits Received - Details</i><br>$uom";
            else if ($arrayR[7] == 4)
                $reportA[0] = "Credits Tracking Report<br><i>Credits Sold - Details</i><br>$uom";
            else if ($arrayR[7] == 6)
                $reportA[0] = "Credits Tracking Report<br><i>Credits Retired for Compliance - Details</i><br>$uom";
            else if ($arrayR[7] == 7)
                $reportA[0] = "Credits Tracking Report<br><i>Credits Retired for Other Jurisdictions - Details</i><br>$uom";
            else if ($arrayR[7] == 8)
                $reportA[0] = "Credits Tracking Report<br><i>Credits Expiring Year End - Details</i><br>$uom";
            else if ($arrayR[7] == 10)
                $reportA[0] = "Credits Tracking Report<br><i>Eligibility Ends Year+1 - Details</i><br>$uom";
            else if ($arrayR[7] == 11)
                $reportA[0] = "Credits Tracking Report<br><i>Eligibility Ends Year+2 - Details</i><br>$uom";
            else if ($arrayR[9] == 3)
                $reportA[0] = "Credits Tracking Report<br>$uom";
            //$reportA[0] = "REC Sold Transfer<br>$uom";
            else
                $reportA[0] = "Credits Tracking Report<br>$uom";
            $reportA[1] = "Company";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "Jurisdiction";
            $reportA[5] = "Compliance Year";
            $reportA[6] = "Assignment Type";
        }
        else if ($sp_name == strtolower("spa_create_rec_compliance_sold_report") || $sp_name == strtolower("spa_create_rec_compliance_sold_report_paging")) {
            $sql = "EXEC spa_get_assignment_default_uom $arrayR[7], $arrayR[5]";
            //echo $sql; die();

            $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
            $uom = "";
          while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
                $uom = $row[1];
            }

            if ($arrayR[7] != "")
                $reportA[0] = "Credits Tracking Report<br><i>Credits Sold Detail - Details</i><br>$uom";
            else
                $reportA[0] = "Credits Tracking Report<br><i>Credits Sold Detail</i><br>$uom";

            $reportA[1] = "Company";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "Jurisdiction";
            $reportA[5] = "Compliance Year";
            $reportA[6] = "Assignment Type";
        }
        else if ($sp_name == strtolower("spa_create_rec_compliance_exclusivegen_report")) {
            //print_r($arrayR);
            $reportA[0] = "Credits Tracking Report<br><i>Listed Resources Credits currently assigned 100% to Jurisdiction for compliance purposes</i>";
            $reportA[1] = "Company";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "Jurisdiction";
            $reportA[5] = "Compliance Year";
            $reportA[6] = "Assignment Type";
        } else if ($sp_name == strtolower("spa_create_rec_compliance_requirement_report")) {
            $reportA[0] = "Credits Tracking Report<br><i>Credits Compliance Requirement</i>";
            $reportA[1] = "Company";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "Jurisdiction";
            $reportA[5] = "Compliance Year";
            $reportA[6] = "Assignment Type";
        } else if ($sp_name == strtolower("spa_create_rec_compliance_summary_report")) {
            $reportA[0] = "Compliance Summary Report";
            $reportA[1] = "Company";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "Jurisdiction";
            $reportA[5] = "Compliance Year";
            $reportA[6] = "Assignment Type";
        } else if ($sp_name == strtolower("spa_get_rec_assign_log") || $sp_name == strtolower("spa_get_rec_assign_log_paging")) {
            $reportA[0] = "Transactions Assign Log";
            $reportA[1] = "Process ID";
        } else if ($sp_name == strtolower("spa_find_matching_rec_deals")) {

            $reportA[0] = "Matched Credits for Assignment";
            $reportA[1] = "flag";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Assignment Type";
            $reportA[6] = "Jurisdiction";
            $reportA[7] = "Compliance Year";
            $reportA[8] = "Assignment Date";
            $reportA[9] = "Sort Order";
            $reportA[10] = "Volume";
            $reportA[11] = "Env Product";
            $reportA[12] = "NULL";
            $reportA[13] = "Action Type";
            $reportA[14] = "UOM";
        } else if ($sp_name == strtolower("spa_REC_Exposure_Report")) {
            if ($arrayR[2] == "'m'") {
                $reportA[0] = "Market Value Report";
            } else {
                $reportA[0] = "Exposure Report";
            }
            $reportA[1] = "flag";
            $reportA[2] = "As of Date";
            $reportA[3] = "Subsidiary";
            $reportA[4] = "Strategy";
            $reportA[5] = "Book";
            $reportA[6] = "Assignment Type";
            $reportA[7] = "Compliance Year";
            $reportA[8] = "Jurisdiction";
            $reportA[9] = "Env Product";
            $reportA[10] = "UOM";
        } else if ($sp_name == strtolower("spa_rec_production_report")) {
            $reportA[0] = "Rec Production Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Assignment Type";
            $reportA[5] = "Assigned State";
            $reportA[6] = "Generator";
            $reportA[7] = "Technology";
            $reportA[8] = "Buy Sell Flag";
            $reportA[9] = "Jurisdiction";
            $reportA[10] = "Reporting Year";
        }
        /* by dinesh 30/3/2010 */ else if (($sp_name == strtolower("spa_Counterparty_MTM_Report")) || ($sp_name == strtolower("spa_Counterparty_MTM_Report_Paging"))) {
            $reportA[0] = "Counterparty MTM Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Prior As of Date";
            $reportA[3] = "Subsidiary";
            $reportA[4] = "Strategy";
            $reportA[5] = "Book";
            $reportA[6] = "Tenor Option";
            $reportA[7] = "Summary/Detail Report";
            $reportA[8] = "Sub Type";
            $reportA[9] = "Grouping";
        } else if ($sp_name == strtolower("spa_wind_pur_power_report")) {
            $reportA[0] = "Wind Purchase Power Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "As of Date";
            $reportA[5] = "Counterparty";
            $reportA[6] = "Technology";
        } else if ($sp_name == strtolower("spa_create_rec_transaction_report")) {
            $reportA[0] = "Allowance Reconciliation Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Assignment State";
            $reportA[5] = "Jurisdiction";
            $reportA[6] = "Assignment Type";
            $reportA[7] = "Technology";
            $reportA[8] = "Buy Sell Flag";
            $reportA[9] = "Generator";
            $reportA[10] = "Vintage From";
            $reportA[11] = "Vintage To";
            $reportA[12] = "Certificate Number From";
            $reportA[13] = "Certificate Number To";
        } else if ($sp_name == strtolower("spa_rec_generator_report")) {
            $reportA[0] = "Rec Generator Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "Generator";
            $reportA[5] = "Technology";
            $reportA[6] = "Generation State";
            $reportA[7] = "Jurisdiction";
            $reportA[8] = "Vintage From";
            $reportA[9] = "Vintage To";
        } else if ($sp_name == strtolower("spa_generator_info_report")) {
            $reportA[0] = "Source/Sink Info Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Generator";
            $reportA[3] = "Technology";
            $reportA[4] = "Generation State";
            $reportA[5] = "Jurisdiction";
        } else if ($sp_name == strtolower("spa_create_hourly_position_report") || ($sp_name == strtolower("spa_create_hourly_position_report_paging"))) {
            $reportA[0] = "Run Position Report";
            $reportA[1] = "Summary Option";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Counterparty";
            $reportA[6] = "As of Date";
            $reportA[7] = "Term Start";
            $reportA[8] = "Term End";
            $reportA[9] = "Frequency";
            $reportA[10] = "Group By";
            $reportA[11] = "NULL";
            $reportA[12] = "NULL";
            $reportA[13] = "NULL";
            $reportA[14] = "NULL";
            $reportA[15] = "NULL";
            $reportA[16] = "NULL";
            $reportA[17] = "NULL";
            $reportA[18] = "NULL";
            $reportA[19] = "NULL";
            $reportA[20] = "NULL";
            $reportA[21] = "NULL";
            $reportA[22] = "NULL";
            $reportA[23] = "NULL";
            $reportA[24] = "NULL";
            $reportA[25] = "NULL";
            $reportA[26] = "NULL";
            $reportA[27] = "NULL";
            $reportA[28] = "NULL";
            $reportA[29] = "NULL";
            $reportA[30] = "NULL";
            $reportA[31] = "NULL";
            $reportA[32] = "NULL";
            $reportA[33] = "NULL";
            $reportA[34] = "NULL";
            $reportA[35] = "NULL";
            $reportA[36] = "NULL";
            $reportA[37] = "NULL";
            $reportA[38] = "NULL";
            $reportA[39] = "NULL";
            $reportA[40] = "NULL";
            $reportA[41] = "NULL";
            $reportA[42] = "NULL";
            $reportA[43] = "NULL";
            $reportA[44] = "NULL";
            $reportA[45] = "NULL";
            $reportA[46] = "Criteria ID";
        } else if ($sp_name == strtolower("spa_get_emissions_inventory_report")) {

            if (strtolower($arrayR[6]) == "'i.2.a.1'") {
                $reportA[0] = "Aggregated Emissions by Gas";
            } else if (strtolower($arrayR[6]) == "'i.2.b.1.a'") {
                $reportA[0] = "Inventory of Emissions and Carbon Flux - Stationary Combustion";
            } else if (strtolower($arrayR[6]) == "'i.2.b.1.b'") {
                $reportA[0] = "Inventory of Emissions and Carbon Flux - Mobile Sources";
            } else if (strtolower($arrayR[6]) == "'i.2.b.2.a'") {
                $reportA[0] = "Indirect Emissions from Purchased Energy	- Physical Quantities of Energy Purchased";
            } else if (strtolower($arrayR[6]) == "'i.2.b.2.b'") {
                $reportA[0] = "Indirect Emissions from Purchased Energy	- Emissions from Purchased Energy";
            } else if (strtolower($arrayR[6]) == "'i.2.b.1.e'") {
                $reportA[0] = "Inventory of Emissions and Carbon Flux	- Fugitive Emissions Associated with Geologic Reservoir";
            } else if (strtolower($arrayR[6]) == "'i.2.b.2.c'") {
                $reportA[0] = "Indirect Emissions from Purchased Energy	- for calculating Emissions Reductions";
            } else if (strtolower($arrayR[6]) == "'i.2.b.4.a'") {
                $reportA[0] = "Terestrial Carbon Fluxes and Stocks - Forestry Activities";
            } else if (strtolower($arrayR[6]) == "'i.2.b.4.h'") {
                $reportA[0] = "Terestrial Carbon Fluxes Summary";
            } else if (strtolower($arrayR[6]) == "'i.2.b.5'") {
                $reportA[0] = "Identify and De Minimis Emissions Sources";
            } else if (strtolower($arrayR[6]) == "'i.2.c'") {
                $reportA[0] = "Total Emissions and Carbon Fluxes";
            } else if (strtolower($arrayR[6]) == "'i.2.d.1'") {
                $reportA[0] = "Emissions Inventory Rating Summary - Base Period Data";
            } else if (strtolower($arrayR[6]) == "'i.2.d.2'") {
                $reportA[0] = "Emissions Inventory Rating Summary - Reporting Year Data";
            } else if (strtolower($arrayR[6]) == "'iii.i.a'") {
                $reportA[0] = "Emissions Reductions -  Domestic Net Entity Level Reported Reductions and Carbon Storage";
            } else if (strtolower($arrayR[6]) == "'iii.i.b'") {
                $reportA[0] = "Emissions Reductions -  Foreign Net Entity Level Reported Reductions and Carbon Storage";
            } else if (strtolower($arrayR[6]) == "'a1.a.1'") {
                $reportA[0] = "Changes in Emissions Intensity -  Output";
            } else if (strtolower($arrayR[6]) == "'a1.b.1'") {
                $reportA[0] = "Emissions, Emissions Intensity and Emission Reductions";
            } else if (strtolower($arrayR[6]) == "'a1.c.1'") {
                $reportA[0] = "Distribution of Emission Reductions to Other Reporters";
            } else if (strtolower($arrayR[6]) == "'a2.a.1'") {
                $reportA[0] = "Change in Absolute Emissions";
            } else if (strtolower($arrayR[6]) == "'a2.b.1'") {
                $reportA[0] = "Distribution of Emission Reductions to Other Reporters";
            } else if (strtolower($arrayR[6]) == "'a2.c.1'") {
                $reportA[0] = "Distribution of Emission Reductions to Other Reporters";
            } else if (strtolower($arrayR[6]) == "'a3.a.1'") {
                $reportA[0] = "Changes in Carbon Storage - Terrestrial Carbon Flux";
            } else if (strtolower($arrayR[6]) == "'a3.a.1'") {
                $reportA[0] = "Changes in Carbon Storage - Terrestrial Carbon Flux";
            } else if (strtolower($arrayR[6]) == "'a3.b.1'") {
                $reportA[0] = "Distribution of Emissions Reductions to Other Reporters";
            } else if (strtolower($arrayR[6]) == "'a8.a.1'") {
                $reportA[0] = "Geological Sequestration - Action Identification";
            } else if (strtolower($arrayR[6]) == "'a8.b.1'") {
                $reportA[0] = "Action Quantification - Source of Carbon Dioxide Sequestered in Current Reporting Year";
            } else if (strtolower($arrayR[6]) == "'a8.b.2'") {
                $reportA[0] = "Action Quantification - Amount Sequestered in Current Reporting Year";
            } else if (strtolower($arrayR[6]) == "'a8.b.3'") {
                $reportA[0] = "Amount Sequestered in Base Year";
            } else if (strtolower($arrayR[6]) == "'a8.b.3'") {
                $reportA[0] = "Amount Sequestered in Base Year";
            } else if (strtolower($arrayR[6]) == "'a8.c.1'") {
                $reportA[0] = "Emissions Reductions";
            }
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Reporting Year";
            $reportA[5] = "Section";
        } else if ($sp_name == strtolower("spa_run_emissions_intensity_report")) {


            // print($arrayR['3']);
            switch ($arrayR['3']) {

                case "'1'":
                    $reportCase = "Emissions Inventory Report";
                    break;
                case "'2'":
                    $reportCase = "Intensity Report";
                    break;
                case "'4'":
                    $reportCase = "Net Mwh Report";
                    break;
                case "'3'":
                    $reportCase = "Heat Input Report";
                    break;

                case "'5'":
                    $reportCase = "Emissions Inventory Report";
                    break;

                case "'6'":
                    $reportCase = "Action Specific Reductions Report";
                    break;
            }


            $reportA[0] = $reportCase;
            $reportA[1] = "Report Option";
            $reportA[2] = "Ems Report Type";
            $reportA[3] = "Ems Group By";
            $reportA[4] = "Subsidiary";
            $reportA[5] = "Strategy";
            $reportA[6] = "Book";
            $reportA[7] = "As of Date"; //"Forcast";
            $reportA[8] = "Term Start"; //"Curve";
            $reportA[9] = "Term End"; //"UMO";
            $reportA[10] = "Technology"; //"Term";
            $reportA[11] = "Fuel Type"; //"Generator name";
            $reportA[12] = "NULL"; //"Ems Book ID";
            $reportA[13] = "Gas"; //"Curve ID ";
            $reportA[14] = "Convert UOM";
            $reportA[15] = "Show C02";
            $reportA[16] = "Technology Sub Type";
            $reportA[17] = "Primary Fuel";
            $reportA[18] = "Source Sink Type";
            $reportA[19] = "Reduction Type";
            $reportA[20] = "Reduction Sub Type";
            $reportA[21] = "UDF Source Sink Group";
            $reportA[22] = "UDF Group1";
            $reportA[23] = "UDF Group2";
            $reportA[24] = "UDF Group3";
            $reportA[25] = "Frequency";
        } else if ($sp_name == strtolower("spa_run_emissions_whatif_report")) {


            $reportA[0] = "Emissions What-if Report";
            $reportA[1] = "Report Option";
            $reportA[2] = "Ems Report Type";
            $reportA[3] = "Ems Group By";
            $reportA[4] = "Subsidiary";
            $reportA[5] = "Strategy";
            $reportA[6] = "Book";
            $reportA[7] = "As of Date"; //"Forcast";
            $reportA[8] = "Term Start"; //"Curve";
            $reportA[9] = "Term End"; //"UMO";
            $reportA[10] = "Technology"; //"Term";
            $reportA[11] = "Fuel Type"; //"Generator name";
            $reportA[12] = "NULL"; //"Ems Book ID";
            $reportA[13] = "Gas"; //"Curve ID ";
            $reportA[14] = "Convert UOM";
            $reportA[15] = "Show C02";
            $reportA[16] = "Technology Sub Type";
            $reportA[17] = "Primary Fuel";
            $reportA[18] = "Source Sink Type";
            $reportA[19] = "Reduction Type";
            $reportA[20] = "Reduction Sub Type";
            $reportA[21] = "UDF Source Sink Group";
            $reportA[22] = "UDF Group1";
            $reportA[23] = "UDF Group2";
            $reportA[24] = "UDF Group3";
            $reportA[25] = "Frequency";
        } else if ($sp_name == strtolower("spa_Create_Position_Report") || ($sp_name == strtolower("spa_Create_Position_Report_Paging"))) {
            $reportA[0] = "Index Position Report";
            $reportA[15] = "As of Date From";
            $reportA[1] = "As of Date To";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "NULL";
            $reportA[4] = "Book";
            $reportA[5] = "Tenor Summary";
            $reportA[6] = "NULL";
            $reportA[7] = "Settlement Option";
            $reportA[8] = "Portfolio Name";
            $reportA[9] = "NULL";
            $reportA[10] = "Commodity Balance";
            $reportA[11] = "Transfer";
            $reportA[12] = "Transaction Type";
            $reportA[13] = "Deal ID";
            $reportA[14] = "Ref ID";
            $reportA[16] = "Include Option";
        } else if ($sp_name == strtolower("spa_get_emissions_inventory") || $sp_name == strtolower("spa_get_emissions_inventory_paging")) {
            $reportA[0] = "Emissions Inventory Report";
            $reportA[1] = "Report Option";
            $reportA[2] = "Generator";
            $reportA[3] = "As of Date";
            $reportA[4] = "Term Start";
            $reportA[5] = "Term End";
            $reportA[6] = "NULL"; //"Forcast";
            $reportA[7] = "NULL"; //"Curve";
            $reportA[8] = "NULL"; //"UMO";
            $reportA[9] = "NULL"; //"Term";
            $reportA[10] = "NULL"; //"Generator name";
            $reportA[11] = "NULL"; //"Emission Reduction";
            $reportA[12] = "NULL"; //"Forcast Type ";
            $reportA[13] = "Series Type";
            $reportA[14] = "Book";
            $reportA[15] = "Technology";
            $reportA[16] = "Primary Fuel";
            $reportA[17] = "Generator Group";
            $reportA[18] = "NULL";
            $reportA[19] = "Subsidiary";
            $reportA[20] = "Strategy";
            $reportA[21] = "Gas";
            $reportA[22] = "Convert UOM";
            $reportA[23] = "Show C02";
            $reportA[24] = "Report Type";
            $reportA[25] = "Technology Sub Type";
            $reportA[26] = "Fuel Type";
            $reportA[27] = "Source Sink Type";
            $reportA[28] = "Reduction Type";
            $reportA[29] = "Reduction Sub Type";
            $reportA[30] = "UDF Source Sink Group";
            $reportA[31] = "UDF Group1";
            $reportA[32] = "UDF Group2";
            $reportA[33] = "UDF Group3";
            $reportA[34] = "Transpose Report";
            $reportA[35] = "Frequency";
        } else if ($sp_name == strtolower("spa_storage_position_report") || $sp_name == strtolower("spa_storage_position_report_rw")) {
            $reportA[0] = "Storage Position Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "commodity";
            $reportA[5] = "index";
            $reportA[6] = "contract";
            $reportA[7] = "location";
            $reportA[8] = "Term Start";
            $reportA[9] = "Term End";

            //$reportA[6] = "Production Month";
        } else if ($sp_name == strtolower("spa_create_storage_position_report") || $sp_name == strtolower("spa_create_storage_position_report")) {

            $reportA[0] = "Gas Storage Position Report";
            $reportA[1] = "Subsidiary";
            $reportA[2] = "Strategy";
            $reportA[3] = "Book";
            $reportA[4] = "commodity";
            $reportA[5] = "index";
            $reportA[6] = "contract";
            $reportA[7] = "location";
            $reportA[8] = "Term Start";
            $reportA[9] = "Term End";

            //$reportA[6] = "Production Month";
        } else if ($sp_name == strtolower("spa_create_power_position_report") || ($sp_name == strtolower("spa_create_power_position_report_paging"))) {

            $reportA[0] = "Power Position Report";
            $reportA[1] = "Summary Option";
            $reportA[2] = "Group By";
            $reportA[3] = "Subsidiary";
            $reportA[4] = "Strategy";
            $reportA[5] = "Book";
            $reportA[6] = "As of Date";
            $reportA[7] = "Term Start";
            $reportA[8] = "Term End";
            $reportA[9] = "Granularity";
            $reportA[10] = "Counterparty";
            $reportA[11] = "Commodity";
        } else if ($sp_name == strtolower("spa_create_detailed_aoci_schedule")) {
            $reportA[0] = "Detailed AOCI Release Schedule";
            $reportA[1] = "As of Date";
            $reportA[2] = "Rel ID";
            $reportA[3] = "Delivery Month";
            $reportA[4] = "Discount Option";
            $reportA[5] = "Subsidiary";
            $reportA[6] = "Strategy";
            $reportA[7] = "Book";
        } else if ($sp_name == strtolower("spa_drill_down_settlement")) {
            $reportA[0] = "Detailed Earnings Schedule";
            $reportA[1] = "NULL";
            $reportA[2] = "As of Date";
            $reportA[3] = "Rel ID";
            $reportA[4] = "Settlement Option";
            $reportA[5] = "Delivery Month";
        } else if ($sp_name == strtolower("spa_import_data_files_audit")) {
            $reportA[0] = "Import Data Audit Log";
            $reportA[1] = "NULL";
            $reportA[2] = "As of Date";
            $reportA[3] = "As of Date";
        }
//Added by Mukesh For Limits Report
        else if ($sp_name == strtolower("spa_get_limits_report") || $sp_name == strtolower("spa_get_limits_report")) {
            $reportA[0] = "Limits Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Limit For";
            $reportA[3] = "Limit Type";
            $reportA[4] = "Limit ID";
            $reportA[5] = "Show Exception";
            $reportA[6] = "Trader";
            $reportA[7] = "Commodity";
            $reportA[8] = "Role";
            $reportA[9] = "NULL";
        }
//Added by Mukesh For Lock/Unlock Report
//New
        else if ($sp_name == strtolower("spa_sourcedealheader") || $sp_name == strtolower("spa_sourcedealheader") || $sp_name == strtolower("spa_sourcedealheader_paging")) {
            if ($arrayR[2] == "'e'")
                $reportA[0] = "Run Options Report";
            if ($arrayR[2] == "'s'") {
                if ($call_from == "'t'")
                    $reportA[0] = "Transaction Audit Log Report";
                else if ($call_from == "'p'")
                    $reportA[0] = "Position Explain Report";
                else
                    //$reportA[0] = "Deal Lock/Unlock Report";
                    $reportA[0] = "Maintain Transactions Report";
            }
            else if ($arrayR[2] == "'g'")
                $reportA[0] = "Run Options Greeks Report";
            else if ($arrayR[2] == "'n'" || $arrayR[2] == "'c'")
                $reportA[0] = "Transaction Audit Log Report";
            else if ($arrayR[2] == "'t'")
                $reportA[0] = "Maintain Transactions Report";

            // $reportA[0] = "Lock/Unlock Report";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "Book ID";
            $reportA[3] = "Deal From";
            $reportA[4] = "Deal To";
            $reportA[5] = "Deal Date From";
            $reportA[6] = "Deal Date To";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "NULL";
            $reportA[12] = "Structured Deal Id";
            $reportA[11] = "Counterparty";
            $reportA[12] = "Physical/Financial/Both";
            $reportA[13] = "NULL";
            $reportA[14] = "Source Deal Type Id";
            $reportA[15] = "Term Start";
            $reportA[16] = "Term End";
            $reportA[17] = "Deal Type";
            $reportA[18] = "Sub Deal Type";
        } else if ($sp_name == strtolower('spa_sourcedealheader_lock')) {
            $reportA[0] = 'Lock/Unlock Deal';
        }


//Added by Mukesh For Unconfirmed Exception Report
        else if ($sp_name == strtolower("spa_confirm_status") || $sp_name == strtolower("spa_confirm_status")) {
            $reportA[0] = "Deal Confirm Status";
            $reportA[1] = "NULL";
            $reportA[2] = "Confirm Type";
            $reportA[3] = "Deal From";
            $reportA[4] = "Deal To";
            $reportA[5] = "As of Date From";
            $reportA[6] = "As of Date To";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "NULL";
            $reportA[12] = "Structured Deal Id";
            $reportA[11] = "Counterparty";
            $reportA[12] = "Physical/Financial/Both";
            $reportA[13] = "NULL";
            $reportA[14] = "Source Deal Type Id";
            $reportA[15] = "Term Start";
            $reportA[16] = "Term End";
            $reportA[17] = "Deal Type";
            $reportA[18] = "Sub Deal Type";
        }
//Added by Mukesh For VaR Report
        else if ($sp_name == strtolower("spa_get_var_report") || $sp_name == strtolower("spa_get_var_report")) {
            $reportA[0] = "At Risk Report";
            $reportA[1] = "NULL";
            $reportA[3] = "Measure";
            $reportA[2] = "Report Options";
            $reportA[4] = "As of Date";
        }
//Added by Mukesh For var_measurement_criteria
        else if ($sp_name == strtolower("spa_var_measurement_criteria_detail") || $sp_name == strtolower("spa_var_measurement_criteria_detail")) {
            $reportA[0] = "VaR measurement Criteria";
            $reportA[1] = "NULL";
            $reportA[2] = "Category";
            $reportA[3] = "Role";
            $reportA[4] = "Active";
        }

        //Added by Sudeep Lamsal For Emmission Input Limit Report
        else if ($sp_name == strtolower("spa_get_emmission_input_report")) {
            if (strtolower($arrayR[2]) == "'n'") {
                $reportA[0] = "Emission Limit Report";
            } else if (strtolower($arrayR[2]) == "'h'") {
                $reportA[0] = "Emission Limit Violation Count Report";
            } else if (strtolower($arrayR[2]) == "'v'") {
                $reportA[0] = "Emission Limit Exception Report";
            }
//			$reportA[0] = "Emission Input Limit Report";
            $reportA[1] = "NULL";
            $reportA[2] = "Generator";
            $reportA[3] = "Gas";
            $reportA[4] = "Convert UOM";
            $reportA[5] = "As of Date";
            $reportA[6] = "Term Start";
            $reportA[7] = "Term End";
            $reportA[8] = "Subsidiary";
            $reportA[9] = "Strategy";
            $reportA[10] = "NULL";
            $reportA[11] = "Generator Group";
            $reportA[12] = "Technology Type";
            $reportA[13] = "Primary Fuel";
            $reportA[14] = "Technology Sub Type";
            $reportA[15] = "Fuel Type";
            $reportA[16] = "Source/Sink";
            $reportA[17] = "Method";
            $reportA[18] = "Action Specific Method";
            $reportA[19] = "UD Source Sink Group";
            $reportA[20] = "UDF Group1";
            $reportA[21] = "UDF Group2";
            $reportA[22] = "UDF Group3";
            $reportA[23] = "NULL";
            $reportA[24] = "NULL";
            $reportA[25] = "Emission Limit";
            $reportA[26] = "Series Type";
        }

//Added by Mukesh For limit_tracking
        else if ($sp_name == strtolower("spa_limit_tracking") || $sp_name == strtolower("spa_limit_tracking")) {
            $reportA[0] = "Setup/Limit Tracking Report";
            $reportA[1] = "NULL";
            $reportA[2] = "Trader";
            $reportA[3] = "Limit Type";
        }
//Added by Mukesh For  Run Options_Report
        else if ($sp_name == strtolower("spa_Create_Options_Report") || $sp_name == strtolower("spa_Create_Options_Report") || $sp_name == strtolower("spa_Create_Options_Report_Paging")) { //echo $arrayR[2];
            if ($arrayR[2] == "'e'")
                $reportA[0] = "Run Options Report";
            else if ($arrayR[2] == "'g'")
                $reportA[0] = "Run Options Greeks Report";

            $reportA[1] = "Report Type";
            $reportA[2] = "Summary Option";
            $reportA[3] = "As of Date";
            $reportA[4] = "Transfer";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "Counterparty";
            $reportA[9] = "Tenor To";
            $reportA[8] = "Tenor From";
            $reportA[10] = "NULL";
            $reportA[11] = "Trader";
            $reportA[12] = "Strategy Name";
            $reportA[13] = "Commodity Balance";
            $reportA[14] = "NULL";
            $reportA[15] = "Deal From";
            $reportA[16] = "Deal To";
            $reportA[17] = "Deal ID";
            $reportA[18] = "Round value";
            $reportA[19] = "Option Status";
        }

//Added by Mukesh For Confirm Transaction
        else if ($sp_name == strtolower("spa_sourcedealheader_confirm") || $sp_name == strtolower("spa_sourcedealheader_confirm")) {

            $reportA[0] = "Deal Confirm Report";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "Deal From";
            $reportA[4] = "Deal To";
            $reportA[5] = "As of Date From";
            $reportA[6] = "As of Date To";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
            $reportA[11] = "NULL";
            $reportA[12] = "NULL";
            $reportA[13] = "Structured Deal Id";
            $reportA[14] = "Counterparty";
            $reportA[15] = "Term Start";
            $reportA[16] = "Term End";
            $reportA[12] = "Physical/Financial/Both";
            $reportA[17] = "NULL";
            $reportA[18] = "NULL";
            $reportA[19] = "NULL";
            $reportA[20] = "NULL";
            $reportA[21] = "NULL";
            $reportA[22] = "NULL";
            $reportA[23] = "NULL";
            $reportA[24] = "NULL";
            $reportA[25] = "NULL";
            $reportA[26] = "NULL";
            $reportA[27] = "NULL";
            $reportA[28] = "NULL";
            $reportA[29] = "NULL";
            $reportA[30] = "NULL";
            $reportA[31] = "NULL";
            $reportA[32] = "NULL";
            $reportA[33] = "NULL";
            $reportA[34] = "NULL";
            $reportA[35] = "NULL";
            $reportA[36] = "NULL";
            $reportA[37] = "NULL";
            $reportA[38] = "NULL";
            $reportA[39] = "NULL";
            $reportA[40] = "NULL";
            $reportA[41] = "NULL";
            $reportA[42] = "NULL";
            $reportA[43] = "NULL";
            $reportA[44] = "NULL";
            $reportA[45] = "NULL";
            $reportA[46] = "NULL";
            $reportA[47] = "NULL";
            $reportA[48] = "NULL";
            $reportA[49] = "NULL";
            $reportA[50] = "NULL";
            $reportA[51] = "Confirm Status";
        }
        else if ($sp_name == strtolower("spa_deal_match")) {
            $reportA[0] = "Deal Match Report";
        }
//Added by Mukesh For Transaction Audit Report
         else if ($sp_name == strtolower("spa_Create_Deal_Audit_Report")||$sp_name == strtolower("spa_Create_Deal_Audit_Report")) {
            $reportA[0] = "Transaction Audit Log Report";
         // if(trim($arrayR[2],"'")=='s')
//          $reportA[0] = "Transaction Audit Log Report (Summary)";
//          else if (trim($arrayR[2],"'")=='d')
//          $reportA[0] = "Transaction Audit Log Report (Detail)";
//          else if (trim($arrayR[2],"'")=='c')
//          $reportA[0] = "Transaction Audit Log Report (Change Summary)";

          //$reportA[1] = "Deal Date From";
//          $reportA[2] = "Deal Date To";
//          $reportA[3] = "Update By";
//          $reportA[4] = "Update Date From";
//          $reportA[5] = "Update Date To";
//          $reportA[6] = "Counterparty";
//          $reportA[7] = "Trader";
//          $reportA[8] = "NULL";
//          $reportA[9] = "NULL";
//          $reportA[10] = "NULL";
//          $reportA[11] = "NULL";
//          $reportA[12] = "Deal From";
//          $reportA[13] = "Deal To";
//          $reportA[14] = "NULL";
//          $reportA[15] = "Tenor Date From";
//          $reportA[16] = "Tenor Date To";
//          $reportA[17] = "NULL";
//          $reportA[18] = "Subsidiary";

          } 



//Added by Mukesh For Export Credit Data
        else if ($sp_name == strtolower("spa_get_counterparty_credit_report") || $sp_name == strtolower("spa_get_counterparty_credit_report")) {
            $reportA[0] = "Counterparty Credit Report";
            $reportA[1] = "Report Type";
            $reportA[2] = "Counterparty";
            $reportA[3] = "Parent Counterparty";
            $reportA[4] = "Limit Expiration";
            $reportA[5] = "Industry Type 1";
            $reportA[6] = "Industry Type 2";
            $reportA[7] = "SIC Code";
            $reportA[8] = "Risk Rating";
            $reportA[9] = "Debt Rating";
            $reportA[10] = "Report Type";
        }
//Added by Mukesh For Export Contract Data
        else if ($sp_name == strtolower("spa_contract_group") || $sp_name == strtolower("spa_contract_group")) {
            $reportA[0] = "Export Contract Data";
            $reportA[1] = "NULL";
            $reportA[2] = "Sunsidiary";
            $reportA[3] = "NULL";
            $reportA[4] = "Contract name";
        }
//Added by Mukesh For Run Settlement Process
        else if ($sp_name == strtolower("spa_get_counterparty_settlement") || $sp_name == strtolower("spa_get_counterparty_settlement")) {
            $reportA[0] = "Run Contract Settlement";
            $reportA[1] = "NULL";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "As of Date";
            $reportA[4] = "Production Month";
            $reportA[5] = "No MV90 Data";
            $reportA[6] = "No Shadow Calc";
            $reportA[7] = "One Meter Multiple Counterparty";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "Broker";
            $reportA[11] = "Counterparty";
        }
//Added by Mukesh For Broker Fee Report
        else if ($sp_name == strtolower("spa_run_settlement_invoice_report") || $sp_name == strtolower("spa_run_settlement_invoice_report")) {
            if ($call_from == 'm')
                $reportA[0] = "Financial Model Report";
            else
                $reportA[0] = "Contract Settlement Report";
            // $reportA[1] = "Summary Option";
            // $reportA[2] = "Counterparty";
            // $reportA[3] = "Contract";
            // $reportA[4] = "As of Date From";
            // $reportA[5] = "As of Date To";
            // $reportA[6] = "Prod Date From";
            // $reportA[7] = "Prod Date To";
        }
//Added by Mukesh For Settlement Claculation History
        else if ($sp_name == strtolower("spa_get_calc_invoice_volume") || $sp_name == strtolower("spa_get_calc_invoice_volume")) {
            $reportA[0] = "Settlement Calculation History";
            $reportA[1] = "NULL";
            $reportA[6] = "Subsidiary";
            $reportA[3] = "Counterparty";
            $reportA[4] = "Production Month";
            $reportA[5] = "As of Date";
            $reportA[8] = "Invoice From";
            $reportA[7] = "Invoice To";
            $reportA[2] = "Ref No.";
        }
//Added by Mukesh For View Volatility and Correlations Report
        else if ($sp_name == strtolower("spa_view_volatility_and_correlation") || $sp_name == strtolower("spa_view_volatility_and_correlation")) {
            //echo $arrayR[9];

            if ($arrayR[2] == "'v'")
                $reportA[0] = "Volatility Report";
            else if ($arrayR[2] == "'b'")
                $reportA[0] = "Correlation Report";
            else if ($arrayR[2] == "'c'")
                $reportA[0] = "Covariance Report";
            else if ($arrayR[2] == "'r'")
                $reportA[0] = "Expected Return Report";

            $reportA[1] = "Report Type";
            $reportA[2] = "Index From";
            $reportA[3] = "Index To";
            $reportA[4] = "Term Date From";
            $reportA[5] = "Term Date To";
            $reportA[6] = "As of Date";
            //$reportA[7] = "Commodity";
        }

//Added by Mukesh For Schedule n delivery--> position Report
        else if ($sp_name == strtolower("spa_position_report_sch_n_delivery") || $sp_name == strtolower("spa_position_report_sch_n_delivery")) {
            $reportA[0] = "Daily Gas Position Report";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "Commodity";
            $reportA[5] = "Delivery Path";
            $reportA[9] = "Counterparty";
            $reportA[6] = "Frequency Term";
            $reportA[7] = "Term Start";
            $reportA[8] = "Term End";
            $reportA[10] = "Location";
            $reportA[11] = "View";
            $reportA[12] = "Group Position By";
        }

//Added by Mukesh For Post JE Report
        else if ($sp_name == strtolower("spa_post_je_report") || $sp_name == strtolower("spa_post_je_report")) {
            $reportA[0] = "Post JE Report";
            $reportA[1] = "NULL";
            $reportA[4] = "Subsidiary";
            $reportA[2] = "As of Date";
            $reportA[3] = "Production Month";
            //$reportA[6] = "Production Month";
        }

//Added by Mukesh For Post JE Report
        else if ($sp_name == strtolower("spa_get_market_variance_report") || $sp_name == strtolower("spa_get_market_variance_report")) { 
            $chargeType = "";
            
            if ($arrayR[5] == '2')
                $chargeType = "Line Rental Fees";
            else
                $chargeType = "Trading Amount";

            if ($arrayR[5] == "null") {
                $chargeType = $arrayR[12];
            }

            $reportA[0] = "Market Variance Report" . " - " . $chargeType;
            $reportA[1] = "As of Date";
            $reportA[2] = "Production Date From";
            $reportA[3] = "Production Date To";
            $reportA[4] = $chargeType;
            $reportA[5] = "Hour From";
            $reportA[6] = "Hour To";
            $reportA[7] = "Resource Type";
            $reportA[8] = "NULL";
            $reportA[9] = "Summary Detail";
            $reportA[10] = "Threshold %";
        } else if ($sp_name == strtolower("spa_power_outage")) {
            $reportA[0] = "Power Outage Report";
        } else if ($sp_name == strtolower("spa_cum_pnl_series")) {
            $reportA[0] = "Cum PNL Series Report";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "Hedge Relationships";
            $reportA[4] = "As of Date From";
            $reportA[5] = "As of Date To";
        } else if ($sp_name == strtolower("spa_get_mtm_series_for_link")) {
            $reportA[0] = "Detailed Cum PNL Series Report";
            $reportA[1] = "Hedge Relationships";
            $reportA[2] = "As of Date";
            //$reportA[3] = "As of Date To";
        } else if ($sp_name == strtolower("spa_run_whatif_scenario_report")) {
            $reportA[0] = "What-if Analysis Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Report Type";
            $reportA[3] = "Criteria ID";
            $reportA[4] = "NULL";
            $reportA[5] = "Criteria Group";
        } else if ($sp_name == strtolower('spa_get_cva_report')) { //cva data report
            $reportA[0] = "Credit Value Adjustment Report";
        } else if ($sp_name == strtolower("spa_run_cashflow_earnings_report")) {
            $reportA[0] = "Financial Forecast Report";
            $reportA[1] = "As of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Report Option";
        } else if ($sp_name == strtolower("spa_create_imbalance_report")) {
            $reportA[0] = "Pipeline Imbalance Report";
            $reportA[1] = "Summary Option";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Term Start";
            $reportA[6] = "Term End";
        } else if ($sp_name == strtolower("spa_run_pnl_report")) {
            $reportA[0] = "Run PNL Report";
            $reportA[1] = "Summary Option";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Commodity";
            $reportA[6] = "Delivery Path";
            $reportA[7] = "Term Start";
            $reportA[8] = "Term End";
            $reportA[9] = "Counterparty";
            $reportA[10] = "Pipeline Counterparty";
            $reportA[11] = "Location";
        } else if ($sp_name == strtolower("spa_Create_Hedges_PNL_Deferral_Report")) {
            $reportA[0] = "Run Hedge Cashflow Deferral Report";
            $reportA[1] = "As Of Date";
            $reportA[2] = "Subsidiary";
            $reportA[3] = "Strategy";
            $reportA[4] = "Book";
            $reportA[5] = "Term Start";
            $reportA[6] = "Term End";
            $reportA[7] = "Discount Option";
            $reportA[8] = "Summary Option";
            $reportA[9] = "Round Value";
        } else if ($sp_name == strtolower("spa_virtual_storage")) {
            $reportA[0] = "General Asset Report";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "NULL";
            $reportA[10] = "NULL";
        } else if ($sp_name == strtolower("spa_meter_data_report")) {
            $reportA[0] = "Meter Data Report";
            $reportA[1] = "Meter ID";
            $reportA[2] = "Location";
            $reportA[3] = "Granularity";
            $reportA[4] = "Production Month From";
            $reportA[5] = "Production Month To";
            $reportA[6] = "Hour From";
            $reportA[7] = "Hour To";
            $reportA[8] = "Grouping Option";
            $reportA[9] = "Format";
            $reportA[10] = "NULL";
            $reportA[11] = "Counterparty";
            $reportA[12] = 'Mapped';
        } else if ($sp_name == strtolower("spa_search_engines")) {
            $reportA[0] = "Search Results";
            $reportA[1] = "Word/Phrase";
            $reportA[2] = "Search Object";
            $reportA[3] = "Search Columns";
        } else if ($sp_name == strtolower("spa_counterparty_limit")) {
            $reportA[0] = "Maintain Counterparty Limit";            
        } else if  ($sp_name == strtolower("spa_get_inventory_accounting_log")) {
             $reportA[0] = "Run Emission Invetory Calc";           
        } else if  ($sp_name == strtolower("spa_ems_publish_report")) {
             $reportA[0] = "Publish Report";           
        } else if ($sp_name == strtolower('spa_view_validation_log')) { //title of report is table name of process table.
            $reportA[0] = ucwords(str_replace('_', ' ', str_replace("'", '', $arrayR[2])));
        } else if ($sp_name == strtolower("spa_message_board_log_report")) {
            $reportA[0] = "Message Board Log Report";
            $reportA[1] = "User";
            $reportA[2] = "As of Date From";
            $reportA[3] = "As of Date To";
            $reportA[4] = "Type";
            $reportA[5] = "Source";
        } else if ($sp_name == strtolower("spa_static_data_audit")){
            $reportA[0] = "Static Data Audit Report";
            $reportA[1] = "Static Data Name";
            $reportA[2] = "As of Date From";
            $reportA[3] = "As of Date To";
        } else if ($sp_name == strtolower("spa_user_application_log")){
            $reportA[0] = "User Activity Log Report";
            $reportA[1] = "Module";
            $reportA[2] = "User";
            $reportA[3] = "As of Date From";
            $reportA[4] = "As of Date To";
        } else if ($sp_name == strtolower("spa_ixp_data_audit_report")){
            $reportA[0] = "Data Import Audit Report";
            $reportA[1] = "Module";
            $reportA[2] = "User";
            $reportA[3] = "As of Date From";
            $reportA[4] = "As of Date To";
        } else if($sp_name == strtolower('spa_flow_optimization')) {
            $reportA[0] = "Optimizer Position Report";
            $reportA[1] = "NULL";
            $reportA[2] = "NULL";
            $reportA[3] = "NULL";
            $reportA[4] = "NULL";
            $reportA[5] = "NULL";
            $reportA[6] = "NULL";
            $reportA[7] = "NULL";
            $reportA[8] = "NULL";
            $reportA[9] = "Flow Date";
            $reportA[10] = "NULL";
            $reportA[11] = "NULL";
            $reportA[12] = "Location";
        }
    }
    
    $return_array = internationalize_array($reportA);
    @sqlsrv_close($DB_CONNECT);

    return $return_array;
}

/**
 * Internationalize
 * @param   Array  $reportA  Reports
 * @return  Array            Internationalize reports
 */
function internationalize_array($reportA) {// For Internationalization support of header 
    $final_array = array();
  
    for($i = 0; $i < sizeof($reportA); $i++) {
        $final_array[$i] = get_locale_value($reportA[$i], false);
    }

    return $final_array;
}

/**
 * Gets parameter descriptions
 * @param   String      $name             Name
 * @param   String      $value            Value
 * @param   Resource    $odbc_connection  ODBC connection link
 * @param   String      $param            Parameters
 * @return  String                        Parameter descriptions
 */
function get_param_description($name, $value, $odbc_connection, $param = '') {
    $DB_CONNECT = get_db_connection();
    
    if (strpos($value, '|'))
        list($rn, $value) = explode('|', $value);
    if ($param != '') {
        $sp_array = explode("|", $param);
        if ($sp_array[0] == 'spa_view_volatility_and_correlation' && $name == 'Index From')
            return $sp_array[1];
        else if ($sp_array[0] == 'spa_view_volatility_and_correlation' && $name == 'Index To')
            return $sp_array[2];
    }

    if ($value != "" && $name == "Company" || $name == "Subsidiary" || $name == "Strategy" || $name == "Book") {
        $portfolio_hierarchy = 2;
        if ($name == "Strategy")
            $portfolio_hierarchy = 1;
        if ($name == "Book")
            $portfolio_hierarchy = 0;

        $sql = "EXEC spa_get_entity_description " . $value . ", " . $portfolio_hierarchy;
        //echo $sql; die();

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

      while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)){
            return $row[1];
        }
    } else if ($value != "" && $name == "Tenor Option") {
        if (strtolower($value) == "'s'")
            return "Settlement Values";
        if (strtolower($value) == "'c'")
            return "Current and Forward Months";
        if (strtolower($value) == "'f'")
            return "Forward Month";
        if (strtolower($value) == "'a'")
            return "Show All";
    } else if ($value != "" && $name == "Present Value Option") {
        if (strtolower($value) == "'d'")
            return "Present Value";
        if (strtolower($value) == "'u'")
            return "Show Future Value";
    } else if ($value != "" && $name == "Privilege Report Type") {
        if (strtolower($value) == "a")
            return "Show Roles";
        if (strtolower($value) == "b")
            return "Show Users";
        if (strtolower($value) == "c")
            return "Show Users by Roles";
        if (strtolower($value) == "d")
            return "Show Roles by Users";
        if (strtolower($value) == "e")
            return "Show Privileges by Roles";
        if (strtolower($value) == "f")
            return "Show Privileges by Users";
        if (strtolower($value) == "g")
            return "Show Application Functions";
    } else if ($value != "" && $name == "Summary By") {
        if (strtolower($value) == "'s'")
            return "Sub,Strategy,Book";
        if (strtolower($value) == "'p'")
            return "Sub,Tenor";
        if (strtolower($value) == "'r'")
            return "Sub,Strategy,Rollout";
        if (strtolower($value) == "'t'")
            return "Sub,Rollout,Tenor";
        if (strtolower($value) == "'u'")
            return "Sub,Rollout";
        if (strtolower($value) == "'d'")
            return "Detail";
    } else if ($value != "" && $name == "Report Option") {
        if (strtolower($value) == "'s'")
            return "Summary";
        if (strtolower($value) == "'t'")
            return "Trader";
        if (strtolower($value) == "'g'")
            return "Generator or Credit Source";
        if (strtolower($value) == "'c'")
            return "Counterparty";
    } else if ($value != "" && $name == "Group By") {
        if (strtolower($value) == "'s'")
            return "Sub,Strategy,Book";
        if (strtolower($value) == "'c'")
            return "Sub,Strategy,Book,Counterparty";
        if (strtolower($value) == "'t'")
            return "Sub,Strategy,Book,Counterparty,Tenor";
        if (strtolower($value) == "'p'")
            return "Sub,Counterparty";
        if (strtolower($value) == "'q'")
            return "Sub,Counterparty,Tenor";
        if (strtolower($value) == "'r'")
            return "Sub,Tenor";
        if (strtolower($value) == "'d'")
            return "Detail";
        if (strtolower($value) == "'i'")
            return "Index";
        if (strtolower($value) == "'l'")
            return "Location";
        if (strtolower($value) == "'1'")
            return "Sub";
        if (strtolower($value) == "'2'")
            return "Sub, Strategy";
        if (strtolower($value) == "'3'")
            return "Sub, Strategy, Book";
        if (strtolower($value) == "'4'")
            return "Sub, Strategy, Book, Index";
        if (strtolower($value) == "'5'")
            return "Detailed";
    } else if ($value != "" && $name == "Hedge Type") {
        //if (strtolower($value) == "'a'") return "All";
        if (strtolower($value) == "'c'")
            return "Cash Flow";
        if (strtolower($value) == "'f'")
            return "Fair Value";
        if (strtolower($value) == "'m'")
            return "MTM";
    } else if ($value != "" && $name == "Exception Option") {
        if (strtolower($value) == "'p'")
            return "Show not posted";
    } else if ($value != "" && $name == "Reverse Option") {
        //if (strtolower($value) == "'a'") return "All";
        if (strtolower($value) == "'y'")
            return "Cumulative entries";
        if (strtolower($value) == "'p'")
            return "Period entries";
        if (strtolower($value) == "'n'")
            return "None";
    } else if ($value != "" && $name == "Settlement Option") {
        if (strtolower($value) == "'s'")
            return "Settled";
        if (strtolower($value) == "'c'")
            return "Current & Forward";
        if (strtolower($value) == "'f'")
            return "Forward";
        if (strtolower($value) == "'a'")
            return "All";
    } else if ($value != "" && $name == "Discount Option") {
        if (strtolower($value) == "'d'")
            return "Present Value";
        if (strtolower($value) == "'u'")
            return "Future Value";
    } else if ($value != "" && $name == "Summary Group") {
        if (strtolower($value) == "'a'")
            return "Subsidiary";
        if (strtolower($value) == "'t'")
            return "Subsidiary,Strategy";
        if (strtolower($value) == "'b'")
            return "Subsidiary,Strategy,Book";
    } else if ($value != "" && $name == "Summary Option") {
        if (strtolower($value) == "s")
            return "Summary";
        if (strtolower($value) == "'s'")
            return "Summary";
        if (strtolower($value) == "'d'") {
            return (isset($rn) && ($rn == 'Hourly Position Report' || $rn == 'Hourly Position Report')) ? 'Summary By Day' : "Detail";
        }

        if (strtolower($value) == "'m'")
            return "Summary By Month";
        if (strtolower($value) == "'h'")
            return "Detail By Hour";

        if (strtolower($value) == "'1'")
            return "Summary by Sub/Strategy/Book";
        if (strtolower($value) == "'2'")
            return "Summary by Sub/Strategy/Book/Counterparty ";
        if (strtolower($value) == "'3'")
            return "Summary Sub/Strategy/Book/Counterparty/Expiration";
        if (strtolower($value) == "'4'")
            return "Summary by Sub/Counterparty/Expiration ";
        if (strtolower($value) == "'5'")
            return "Summary by Sub/Counterparty ";
        if (strtolower($value) == "'6'")
            return "Summary by Counterparty";
        if (strtolower($value) == "'7'")
            return "Summary by Counterparty/Expiration";
        if (strtolower($value) == "'8'")
            return "Summary by Sub/Expiration";
        if (strtolower($value) == "'9'")
            return "Summary by Sub/Trader";
        if (strtolower($value) == "'10'")
            return "Summary by Sub/Trader/Expiration";
        if (strtolower($value) == "'11'")
            return "Summary by Trader";
        if (strtolower($value) == "'12'")
            return "Summary by Trader/Expiration";
        if (strtolower($value) == "'13'")
            return "Summary by Deal";
        if (strtolower($value) == "'14'")
            return "Summary by Deal/Expiration";
        if (strtolower($value) == "'15'")
            return "Detailed";
    } else if ($value != "" && $name == "Type") {
        if (strtolower($value) == "'t'")
            return "Tabular Report";
        if (strtolower($value) == "'j'")
            return "Journal Entry";
    } else if ($value != "" && $name == "Grouping Option") {
        if (strtolower($value) == "'c'")
            return "Cumulative";
        if (strtolower($value) == "'e'")
            return "Period Summary";
        if (strtolower($value) == "'d'")
            return "Period Summary by Production Month";
        if (strtolower($value) == "'p'")
            return "Prior Adjustements Only";
        if (strtolower($value) == "'g'")
            return "Export to GL System";
        if (strtolower($value) == "'t'")
            return "Trial Balance";
    } else if ($value != '' && $name == 'Grouping Options') { // Added By Narendra For Run Load Forecast Report
        if (strtolower($value) == "'d'")
            return 'Detail';
        if (strtolower($value) == "'s'")
            return 'Summary';
    } else if ($value != '' && $name == 'Format') { // Added By Narendra For Run Load Forecast Report
        if (strtolower($value) == "'c'")
            return 'Cross Tab Format';
        if (strtolower($value) == "'r'")
            return 'Regular Format';
    } else if ($value != "" && $name == "Granularity Type") {
        if (strtolower($value) == "'m'")
            return "Monthly";
        if (strtolower($value) == "'q'")
            return "Quarterly";
        if (strtolower($value) == "'s'")
            return "Semi-annualy";
        if (strtolower($value) == "'a'")
            return "Annualy";
    }

    /** by sangam ligal, 7/12/2012
     * for report type in run at risk report 
     * */
    else if ($value != "" && $name == "Report Options") {
        if (strtolower($value) == "'m'")
            return "Market Risks";
        if (strtolower($value) == "'c'")
            return "Credit Risks";
        if (strtolower($value) == "'i'")
            return "Integrated Risks";
        if (strtolower($value) == "'a'")
            return "All";
    } else if ($value != "" && $name == "Limit For") {
        if (strtolower($value) == "'20203'")
            return "Commodity";
        if (strtolower($value) == "'20201'")
            return "Trader";
        if (strtolower($value) == "'20202'")
            return "Trading Role";
        if (strtolower($value) == "'20200'")
            return "Others";
    } else if ($value != "" && $name == "Limit Type") {
        if (strtolower($value) == "1580")
            return "MTM Limit";
        if (strtolower($value) == "1581")
            return "Position and Tenor limit";
        if (strtolower($value) == "1582")
            return "RAROC limit";
        if (strtolower($value) == "1583")
            return "RAROC Integrated limit";
        if (strtolower($value) == "1584")
            return "VaR limit";
        if (strtolower($value) == "1585")
            return "Default VaR limit";
        if (strtolower($value) == "1586")
            return "Integrated VaR limit";
    } else if ($value != "" && $name == "Trader") {
        if (strtolower($value) == "1")
            return "Bianca Blom";
        if (strtolower($value) == "2")
            return "Ellen Poels";
        if (strtolower($value) == "3")
            return "Gerard Koops";
        if (strtolower($value) == "4")
            return "Steven Hommes";
        if (strtolower($value) == "5")
            return "Tim Steenbergen ";
        if (strtolower($value) == "6")
            return "Berend Julsing";
        if (strtolower($value) == "7")
            return "Michiel Rutgers";
        if (strtolower($value) == "8")
            return "Ron Hilkes (oud)";
        if (strtolower($value) == "9")
            return "Ron Hilkes";
        if (strtolower($value) == "10")
            return "Valerio Serrotti";
        if (strtolower($value) == "11")
            return "Maarten Tielen";
        if (strtolower($value) == "12")
            return "PS and F";
        if (strtolower($value) == "15")
            return "Patricia Platen";
        if (strtolower($value) == "16")
            return "Paul Akass";
        if (strtolower($value) == "17")
            return "Lea Prudencio";
    } else if ($value != "" && $name == "Report Type") {     /* by dinesh 31-03-2010 */
        if (strtolower($value) == "'v'")
            return "Volatility";
        if (strtolower($value) == "'b'")
            return "Correlation";
        if (strtolower($value) == "'c'")
            return "Covariance";
        if (strtolower($value) == "'r'")
            return "Expected Return";
        if (strtolower($value) == "'m'")
            return "MTM";  //This flag used for only MTM 
    } else if ($value != "" && $name == "Tenor Summary") { /* by dinesh 31-03-2010 */
        if (strtolower($value) == "'m'")
            return "Summary By Monthly";
        if (strtolower($value) == "'q'")
            return "Summary By Quarterly";
        if (strtolower($value) == "'s'")
            return "Summary By Semi-annualy";
        if (strtolower($value) == "'a'")
            return "Summary By Annualy";
        if (strtolower($value) == "'d'")
            return "Detail";
    } else if ($value != "" && $name == "Report Type") {
        if (strtolower($value) == "'c'")
            return "Credit Risks Var";
        if (strtolower($value) == "'m'")
            return "Market Risks Var";
        if (strtolower($value) == "'i'")
            return "Integrated Risks Var";
    } else if ($value != "" && $name == "Activity Status") {
        if (strtolower($value) == "'a'")
            return "All Activities";
        if (strtolower($value) == "'n'")
            return "Not Completed Activities";
        if (strtolower($value) == "'u'")
            return "Unapproved Activities";
        if (strtolower($value) == "'c'")
            return "Completed Activities";
    } else if ($value != "" && $name == "Report By") {
        if (strtolower($value) == "'m'")
            return "Monetary Value";
        if (strtolower($value) == "'c'")
            return "Count";
    } else if ($value != "" && $name == "Group1 Process") {
        $sql = "EXEC spa_maintain_compliance_process a, " . $value;

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[4];
        }
    } else if ($value != "" && $name == "Run Frequency") {
        $sql = "EXEC spa_StaticDataValues s, 700, NULL, " . $value;

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)){
            return $row[3];
        }
    } else if ($value != "" && $name == "Priority") {
        $sql = "EXEC spa_StaticDataValues s, 675, NULL, " . $value;

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[3];
        }
    } else if ($value != "" && $name == "Group2 Risk") {
        $sql = "EXEC spa_maintain_compliance_risks s, " . $value;

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[2];
        }
    } else if ($value != "" && $name == "Activity Category") {
        $sql = "EXEC spa_staticDataValues s, 10085, NULL, " . $value;

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            $row[3];
        }
    } else if ($value != "" && $name == "Where") {
        $sql = "EXEC spa_staticDataValues s, 10087, NULL, " . $value;

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
           $row[3];
        }
    } else if ($value != "" && $name == "Why") {
        $sql = "EXEC spa_staticDataValues s, 5003, NULL, " . $value;

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            $row[3];
        }
    } else if ($value != "" && $name == "Activity Area") {
        $sql = "EXEC spa_staticDataValues s, 10088, NULL, " . $value;

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            $row[3];
        }
    } else if ($value != "" && $name == "Activity Sub Area") {
        $sql = "EXEC spa_staticDataValues s, 10089, NULL, " . $value;

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            $row[3];
        }
    } else if ($value != "" && $name == "Activity Action") {
        $sql = "EXEC spa_staticDataValues s, 10090, NULL, " . $value;

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            $row[3];
        }
    } else if ($value != "" && $name == "Control Type") {
        $sql = "EXEC spa_staticDataValues s, 5002, NULL, " . $value;

       $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            $row[3];
        }
    } else if ($value != "" && $name == "Who For") {
        $sql = "EXEC spa_staticDataValues s, 10086, NULL, " . $value;

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource)) {
            $row[3];
        }
    } else if ($value != "" && $name == "Report Type") {
        if (strtolower($value) == "'c'")
            return "Cash Flow";
        if (strtolower($value) == "'e'")
            return "Earning";
        if (strtolower($value) == "'s'")
            return "Production Data";
        if (strtolower($value) == "'m'")
            return "Missing Data";
        if (strtolower($value) == "'p'")
            return "Estimated Production Data";
    } else if ($value != "" && $name == "Match Type") {
        if (strtolower($value) == "'a'")
            return "All Transactions";
        if (strtolower($value) == "'m'")
            return "Matched Transactions";
        if (strtolower($value) == "'u'")
            return "Unmatched Transactions";
    } else if ($value != "" && $name == "Action Type") {
        if (strtolower($value) == "0")
            return "Assign Credits";
        if (strtolower($value) == "1")
            return "UnAssign Credits";
    } else if ($value != "" && $name == "Show Option" || $name == "Exception Flag") {
        if (strtolower($value) == "'e'")
            return "Exceptions";
        if (strtolower($value) == "'a'")
            return "All";
    } else if ($value != "" && $name == "Flag2" || $name == "Flag") {
        if (strtolower($value) == "'h'")
            return "Hedge";
        if (strtolower($value) == "'i'")
            return "Hedged Items";
    } else if ($value != "" && $name == "Asset Type") {
        if (strtolower($value) == "'402'")
            return "Forecast";
        if (strtolower($value) == "'404'")
            return "Realized";
    } else if ($value != "" && $name == "Convert UOM") {
        $sql = "EXEC spa_get_uom_description " . $value;
        //echo $sql; die();

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            $row[1];
        }
    } else if ($value != "" && $name == "Assessment Type") {
        if (strtolower($value) == "'i'")
            return "Initial";
        if (strtolower($value) == "'o'")
            return "Ongoing";
    } else if ($value != "" && $name == "Reverse Option") {
        if (strtolower($value) == "'y'")
            return "Yes";
        if (strtolower($value) == "'n'")
            return "No";
    } else if ($value != "" && $name == "Status") {
        if (strtolower($value) == "'c'")
            return "Completed";
        if (strtolower($value) == "'p'")
            return "Pending";
    } else if ($value != "" && $name == "User Action") {
        if (strtolower($value) == "'a'")
            return "Accepted";
        if (strtolower($value) == "'d'")
            return "Declined";
        if (strtolower($value) == "'p'")
            return "Pending";
    } else if ($value != "" && $name == "Netting Group Parent Id") {
        $sql = "EXEC spa_get_netting_group_name " . $value;
        //echo $sql; die();

         $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[1];
        }
    } else if ($value != "" && $name == "Term Date From" || $name == "Term Date To") {
        $date = str_replace("'", "", $value);
        $defaultDate = getClientDateFormat($date);
        return("'" . $defaultDate . "'");
    } else if ($value != "" && $name == 'As of Date') {
        if ($param == 'spa_create_hourly_position_report') {
            $pieces = explode(",", $value);
            $max = max($pieces);
            $value = str_replace("'", "", trim($max));    
        }
         
        $date = str_replace("'", "", $value);
        $defaultDate = getClientDateFormat($date);
        return("'" . $defaultDate . "'");
    } else if ($value != "" && $name == 'As of Date' && $name != "Date From") {
        $date = str_replace("'", "", $value);
        $defaultDate = getClientDateFormat($date);
        return("'" . $defaultDate . "'");
    } else if ($value != "" && $name == 'As of Date To') {

        $date = str_replace("'", "", $value);
        $defaultDate = getClientDateFormat($date);
        return("'" . $defaultDate . "'");
    } else if ($value != "" && $name == "Include Outstanding Forecasetd Transactions") {
        if (strtolower($value) == "'n'")
            return "None";
        if (strtolower($value) == "'a'")
            return "Include Approved";
        if (strtolower($value) == "'u'")
            return "Include Outstanding";
        if (strtolower($value) == "'b'")
            return "Include Approved and Outstanding";
    }
//    else if  ($value != "" && $name == "As of Date" || $name == "Prior As of Date" || $name == "Date From" || $name == "Date To"
//            || $name == "Quarter Threshold Date" || $name == "Tenor From" || $name == "Tenor To"
//            || $name == "Hedge Start" || $name == "Hedge End" || $name == "Item Start" || $name == "Item End"
//            || $name == "Dedesignate Date" || $name == "Gen Date From" || $name == "Gen Date To"
//            || $name == "TermStart" || $name == "TermEnd" || $name == "Term Start" || $name == "Term End") {
    else if (isSQLDate(str_replace("'", "", $value))) {
        $sql = "select dbo.FNAGetGenericDate(" . $value . ", dbo.FNADBUSER())";
        //echo $sql; die();

       $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return "'" . ($row[1] ?? '') . "'";
        }
    } else if ($value != "" && ($name == "Sort Order" || $name == "FifO")) {
        if (strtolower($value) == "'f'")
            return "FifO";
        if (strtolower($value) == "'l'")
            return "LifO";
    } else if ($value != "" && $name == "Term Match") {
        if (strtolower($value) == "'w'")
            return "Within Term";
        if (strtolower($value) == "'y'")
            return "Perfect Term";
    } else if ($value != "" && $name == "Volume Match") {
        if (strtolower($value) == "'y'")
            return "Unsplit";
        if (strtolower($value) == "'n'")
            return "Split";
    } else if ($value != "" && $name == "Include Banked Transactions") {
        if (strtolower($value) == "'y'")
            return "Yes";
        if (strtolower($value) == "'n'")
            return "No";
    } else if ($value != "" && $name == "Notes For") {
        if (strtolower($value) == "'1'")
            return "General Usage";
        if (strtolower($value) == "'2'")
            return "Subsidiary";
        if (strtolower($value) == "'3'")
            return "Strategy";
        if (strtolower($value) == "'4'")
            return "Book";
        if (strtolower($value) == "'5'")
            return "Hedging Relationship Types";
        if (strtolower($value) == "'6'")
            return "Hedging Relationship";
        if (strtolower($value) == "'7'")
            return "Process Control";
    } else if ($value != "" && $name == "Internal External") {
        if (strtolower($value) == "'i'")
            return "Internal";
        if (strtolower($value) == "'e'")
            return "External";
    } else if ($value != "" && $name == "Group Position By") {
        $value = str_replace('@group_by=', '', $value);
        $value = str_replace('\'', '', $value);
        switch ($value) {
            case 'location':
                $value = "Location";
                break;
            case 'meter':
                $value = "Meter ID";
                break;
            case 'counterparty':
                $value = "Counterparty";
                break;
        }
        return $value;
    } else if ($value != "" && $name == "View") {
        if (strtolower($value) == "'d'")
            return "Daily View";
        if (strtolower($value) == "'r'")
            return "Rolling Sum View";
    } else if ($value != "" && ($name == "Term Start" || $name == "Term End")) {
        $value = str_replace("'", "", $value);
        $value = getClientDateFormat($value);
        $value = "'" . $value . "'";
        return $value;
    } else if ($value != "" && ($name == "Assignment Type" || $name == "State" || $name == "Jurisdiction")) {
        //echo $value;
        $sql = "EXEC spa_StaticDataValues 'a', NULL, NULL, " . $value;
        //echo $sql; die();
        
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
                return $row[4];
        }
                                         
       // while (odbc_fetch_row($recrodsetResource)) {
        //    return odbc_result($recrodsetResource, 4);
       // }
        
                        
    } else if ($value != "" && $name == "Counterparty") {
        $sql = "EXEC spa_source_counterparty_maintain 'r', " . $value;
        //echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

      while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return ($row[1] ?? '');
        }
    } else if ($value != "" && $name == "Line Item") {
        $sql = "EXEC spa_StaticDataValues 'a', NULL, NULL, " . $value;
        //echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[3];
        }
    } else if ($value != "" && $name == "Contract") {
        $sql = "EXEC spa_contract_group 'a', NULL, " . $value;
        //echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[2];
        }
    } else if ($value != "" && $name == "Commodity") {
        $sql = "EXEC spa_source_commodity_maintain 'a', " . $value;
        //echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[4];
        }
    } else if ($value != "" && $name == "Delivery Path") {
        $sql = "EXEC spa_delivery_path 'a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL," . $value;
        //echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[2];
        }
    } else if ($value != "" && $name == "Location") {
        $sql = "EXEC spa_source_minor_location 'a', " . $value;
        //echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[4]; 
        }
    } else if ($value != "" && $name == "Profile") { // Added By Narendra For Run Load Forecast Report to get profile name at header
        $sql = "EXEC spa_forecast_profile 'a',$value";
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
        $row = sqlsrv_fetch_array($recrodsetResource, SQLSRV_FETCH_NUMERIC);
        return $row[2];
    } else if ($value != "" && $name == "EAN") {
        //$value is always returning single quoted lowercase string for EAN
        $sql = "EXEC spa_forecast_profile 's'";
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            if (strtolower($fpValue = $row[3]) == str_replace("'", "", $value)) {
                return $fpValue; //returns the actual value of EAN from forecast profile
            }
        }
        return $value;
    } else if ($value != "" && $name == "Trader") {
        $sql = "EXEC spa_source_traders_maintain 'a', " . $value;
        //echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[4];
        }
    } else if ($value != "" && $name == "Frequency Term") {
        $sql = "EXEC spa_getVolumeFrequency " . $value;
        //echo $sql; die();
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[2];
        }
    } else if ($value != "" && ( $name == "Update Date From" || $name == "Update Date To" || $name == "Deal Date From" || $name == "Deal Date To" || $name == "Tenor Date From" || $name == "Tenor Date To")) {
        $date = str_replace("'", "", $value);

        //list($year, $month, $day ) = explode('-', $date);
        //$new_date=$month.'/'.$day.'/'.$year ;
        $new_date = $date;
        return("'" . $new_date . "'");
    } else if ($value != "" && ($name == "Env Product" || $name == "Index")) {
        $sql = "SELECT curve_name FROM source_price_curve_def WHERE source_curve_def_id = " . $value;
        //echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[1];
        }
    } else if ($value != "" && ($name == "Portfolio Name" || $name == "Commodity Balance" || $name == "Transfer")) {
        $sql = "SELECT b.source_book_name  +'.'+ Source_System_name BookName
				FROM 	source_book b join source_system_description ssd
				    on b.source_system_id=ssd.source_system_id
				WHERE b.source_book_id in (select * from dbo.SplitCommaSeperatedValues(" . $value . "))";
        // echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[1];
        }
    } else if ($value != "" && $name == "Transaction Type") {
        //$sql = 'SELECT code FROM static_data_value WHERE type_id=400 AND value_id IN ('.str_replace('\'','',$value).')';
        $sql = "spa_StaticDataValues 'o', 400, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, " . $value;
        // echo $sql; die();

        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);

        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[1];
        }
    } else if ($value != "" && $name == "Present/Future") {
        if (strtolower($value) == "'d'")
            return "Present value";
        if (strtolower($value) == "'f'")
            return "Future value";
    } else if ($value != "" && $name == "Hedge MTM") {
        if (strtolower($value) == "'h'")
            return "Hedge Only";
        if (strtolower($value) == "'m'")
            return "MTM Only";
        if (strtolower($value) == "'b'")
            return "Both";
    } else if ($value != "" && $name == "Summary Detail") {
        if (strtolower($value) == "'s'")
            return "Summary";
        if (strtolower($value) == "'d'")
            return "Detail";
    } else if ($value != "" && ($name == "Frequency" || $name == "Granularity")) {
        $sql = "spa_StaticDataValues 'o', 978, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, " . $value;
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[0];
        }
    } else if ($value != "" && $name == "Show Firstday Gain Loss") {
        if (strtolower($value) == "'n'") {
            return "No";
        } else {
            return "Yes";
        }
    } else if ($value != "" && $name == "Show Prior Processed") {
        if (strtolower($value) == "'n'") {
            return "No";
        } else {
            return "Yes";
        }
    } else if ($value != "" && $name == "Show Only For Deal Date") {
        if (strtolower($value) == "'n'") {
            return "No";
        } else {
            return "Yes";
        }
    } else if ($value != "" && $name == "Use Create Date") {
        if (strtolower($value) == "'n'") {
            return "No";
        } else {
            return "Yes";
        }
    } else if ($value != "" && $name == "Mapped") {
        if (strtolower($value) == "'m'") {
            return "Yes";
        } else {
            return "No";
        }
    } else if ($value != "" && $name == "Deal Type ID") {
        if ($value) {
            $sql = "EXEC spa_getsourcedealtype 's', NULL, NULL ," . $value;
            $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
            while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
                return $row[2];
            }
        } else {
            return "No";
        }
    } else if ($value != "" && $name == "Physical Financial") {
        if (strtolower($value) == "'p'") {
            return "Physical ";
        } else if (strtolower($value) == "'f'") {
            return "Financial";
        } else if (strtolower($value) == "'b'") {
            return "Both";
        }
    } else if ($value != "" && $name == "Counterparty Type") {

        if (strtolower($value) == "'i'") {
            return "Physical ";
        } else if (strtolower($value) == "'e'") {
            return "Financial";
        } else if (strtolower($value) == "'a'") {
            return "Both";
        }
    }
    //Source System book1
    else if ($value != "" && ($name == "Source System book1" || 
                            $name == "Source System book2" || 
                            $name == "Source System book3" || 
                            $name == "Source System book4")) {
        if ($value) {
            $sql = "SELECT 
                    	b.source_book_name + CASE 
                    							WHEN ssd.source_system_id = 2 THEN '' 
                    							ELSE '.' + Source_System_name 
                    	                     END AS BookName
                    FROM   source_book b JOIN source_system_description ssd 
                        ON  b.source_system_id = ssd.source_system_id
                    WHERE  source_book_id =" . $value;

            $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
           while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
                return $row[1];
            }
        } else {
            return "No";
        }
    } else if ($value != "" && $name == "Curve Source ID") {
        $sql = "spa_StaticDataValues 'o', 10007, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, " . $value;
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[1];
        }
    } else if ($value != "" && $name == "Meter ID") {
        $sql = 'EXEC spa_meter_id \'r\', NULL, NULL, NULL, NULL, NULL, NULL, ' . $value;
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[1];
        }
    } else if ($value != "" && $name == "Confirm Status") {
        $sql = "EXEC spa_StaticDataValues 'a', NULL, NULL, " . $value;
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return "'" . $row[3] . "'";
            //echo $a;
        }
    } else if ($value != "" && $name == "Static Data Name") {
        $sql = "spa_StaticDataValues 'o', 19900, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, " . $value;
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
        while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return ($row[1] ?? '');
        }
    } else if ($value != "" && $name == "Source System Name") {
        $sql = "SELECT source_system_name FROM   source_system_description WHERE  source_system_id = " . $value;
        $recrodsetResource = sqlsrv_query($DB_CONNECT, $sql);
       while ($row = sqlsrv_fetch_array($recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            return $row[1];
        }
    }

    @sqlsrv_close($DB_CONNECT);


    return $value;
}

/**
 * Gets Report Name
 * @param   String  $sql_stmt         SQL statement
 * @param   [type]  $width            Unused
 * @param   String  &$report_title     Report title
 * @param   Resource  $odbc_connection  Unused
 * @param   Array  &$arrayR           Report
 * @param   Array  $REQUEST           Arguments
 * @param   Object  $reportInstance   Report instance
 * @return  String                    Report name html
 */
function get_report_name($sql_stmt, $width, &$report_title, $odbc_connection, &$arrayR, $REQUEST, $reportInstance = null) {
    $DB_CONNECT = get_db_connection();
    
    $return_html = "";
    $report_title = "";

    // This decodes the sql statement into array of parameters. First item is "Success" or "Error"
    // Second item is the name of the procedures, Remaining items are input parameters to the SP
    $arrayR = decode_param($sql_stmt, true);

    if ($arrayR[0] == "Error")
        return "";

    $reportDef = get_report_def($arrayR[1], $arrayR, $DB_CONNECT, $REQUEST, $reportInstance);
    //echo '<pre>';
//    print_r($arrayR);
//    echo '</pre>';

    if ($reportDef[0] == "Error")
        return "";

    $return_html = "
        <table width='98%' class='report_header'>";

    /*
      if ($arrayR[0] == "spa_create_rec_invoice_report")
      $return_html .= "" .
      "<table>
      <tr>
      <td>To:  XXXX<br>Phone: 202-321-2321<br>Fax: 232-232-2322</td
      <td>REC Transactions Invoice</td
      <td>Xcel Energy<br>1099 18th St., Suite 3000<br>Denver, CO 80202<br>Contact: Mike Smith</td
      </tr>
      </table>"; */

    if ($arrayR[0] == "Error") {

        $return_html .= "" .
                "                <tr>
                        <td align='left' width='100%'>" . $arrayR[1] . "</td>
                </tr>";
        $report_title = "";
    } else {
        $countDef = count($reportDef);
        $countParam = count($arrayR) - 2;
        $report_name = $reportDef[0];
        $report_title = $reportDef[0];
        //echo $report_name;
        $report_param = "";
        if (isset($REQUEST['labels'])) {
            $param = $arrayR[1] . "|" . $REQUEST['labels'];  //SP | ..
        } else {
            $param = '';
        }

        for ($i = 1; $i < $countDef; $i++) {
            if ($reportDef[$i] != "NULL") {

                if ($report_name == "Transaction Audit Log Report" || $report_name == "Transaction Audit Log Report (Summary)"
                        || $report_name == "Transaction Audit Log Report (Detail)" || $report_name == "Transaction Audit Log Report (Change Summary)") {

                    if ($countParam < $i || strtoupper($arrayR[$i + 2]) == "NULL")
                        $report_param = $report_param . $reportDef[$i] . " = ";
                    else
                        $report_param = $report_param . $reportDef[$i] . " = " . get_locale_value(get_param_description($reportDef[$i], $arrayR[$i + 2], $DB_CONNECT), false);
                }
                else {
                    if ($countParam < $i || strtoupper($arrayR[$i + 2] ?? '') == "NULL")
                        $report_param = $report_param . $reportDef[$i] . " = ";
                    else {

                        //build the drill down measurement report for journal entry when links is run
                        //if ($report_name == "Journal Entry Report" && $reportDef[$i] == "Rel ID")
                        //$arrayR[$i+1] = "<a target=\"_blank\" href=\"./spa_html.php?spa=exec spa_Create_Hedges_Measurement_Report " .$arrayR[2] . ", 					NULL,NULL,NULL, " . $arrayR[6] . ", " . $arrayR[7] . ", " . $arrayR[8] . ", " . "'d'" . ", " . $arrayR[$i+1] . ", 0\">" . $arrayR[$i+1] .  "</a>";
                        $param_value = $arrayR[$i + 1];
                        if (($report_name == 'Hourly Position Report' || $report_name == 'Hourly Position Report') && $i == 1) {
                            $param_value = $report_name . '|' . $param_value;
                        }
                        global $is_report_writer, $arr_rw_look_up_columns;
                        if ($is_report_writer && array_key_exists($reportDef[$i], $arr_rw_look_up_columns)) {
                            $param_value = get_report_writer_column_lookup_name($arr_rw_look_up_columns[$reportDef[$i]], $param_value);
                        }
                        
                        $param = ($arrayR[1] == 'spa_create_hourly_position_report') ? 'spa_create_hourly_position_report' : $param;
                        $report_param = $report_param . $reportDef[$i] . " = " .  get_locale_value(get_param_description($reportDef[$i], $param_value, $DB_CONNECT, $param), false);

                        //$report_param =  $report_param . $reportDef[$i] . " = " . $arrayR[$i+1];
                        //echo                 $reportDef[$i] ;  echo $arrayR[$i+1];
                    }
                }

                if ($i + 1 < $countDef)
                    $report_param = $report_param . " | ";
            }
        }
    
    $return_html .= "
                <tr class='report_name'>
                        <td align='left' width='95%'>$report_name</td>
                </tr>
                <tr class='report_detail'>
                        <td class='report_param' align='left' width='95%'>$report_param</td>
                </tr>";
    }

    $return_html .= "
        </table>";
    @sqlsrv_close($DB_CONNECT);

    return $return_html;
}

/**
 * Get reports header
 * @param   String  $sql_stmt            SQL statement
 * @param   [type]  $table_width         Unused
 * @param   String  $app_php_script_loc  PHP scripts location
 * @param   [type]  $odbc_connection     Unused
 * @param   Array  &$arrayR              Reports
 * @param   Array  $REQUEST              Arguments
 * @param   Boolean  $show_logo           Show logo
 * @param   Object  $reportInstance      Report instance
 * @return  String                       Report header html
 */
function get_header($sql_stmt, $table_width, $app_php_script_loc, $odbc_connection, &$arrayR, $REQUEST, $show_logo, $reportInstance) {
	$DB_CONNECT = get_db_connection();
    /*
      //if create file is true, then the html to be created is one level higher
      if( $createFile == true ){
      $relativePath = "../..";
      } else {
      $relativePath = "..";
      }
     */
    $relativePath = $app_php_script_loc;

    //$arrayR = decode_param($sql_stmt);
    $report_title = "";
    $return_report_title = get_report_name($sql_stmt, "75%", $report_title, $DB_CONNECT, $arrayR, $REQUEST, $reportInstance);

    if ($report_title == "")
        $report_title = "FARRMS - Adiha Data Export";

    global $clientImageFile, $hide_ps_logo_in_report;

    $clientImageFile=$_SESSION["clientImageFile"];

    if ($hide_ps_logo_in_report == true) {
        $ps_logo = "&nbsp;";
    } else {
        $ps_logo = "<IMG SRC='$relativePath/adiha_pm_html/process_controls/PioneerSolutionsLogoHTMLHeader.jpg'>";
    }
    $return_html = "" .
            "<head>
                    <title>$report_title</title>
            </head>
            <body style='background-color:#f8fbfe;'>";

    if ($show_logo == 'true') {
        $return_html .= "<div style='margin-left: 10px;'>	
                    <table width='95%'>
                        <tr>
                            <td align='left' width='65%'><IMG SRC='" . $relativePath . "adiha_pm_html/process_controls/$clientImageFile'></td>
    						<td align='left' width='25%'>$ps_logo</td>
                        </tr>
                    </table> </div>";

        $return_html = $return_html . $return_report_title;
    }

    @sqlsrv_close($DB_CONNECT);

    return $return_html;
}

/**
 * Get paging
 * To use this pass: use the following format. defind $sql_stmt and call get_header function
 * $sql_stmt = "EXEC  spa_Create_Hedges_Measurement_Report ";
 * $sql_stmt = "EXEC  spa_Create_Hedges_Measurement_Report '7/31/2003', '1,3', NULL, '2', 'd', 'f', 'c', 'd'";
 * $sql_stmt = "EXEC   sPA_Call  's',          '2,4, 3',  '7/31/2003', '540, 12, 30', 123";
 * $spa_html_header = get_header($sql_stmt, "80%");
 * @param   Integer  $noOfRows  Number of rows
 * @param   Integer  $max_row   Maximum number of rows
 * @param   Integer  $sel_page  Selected page
 * @param   Array    $args        Arguments
 * @param   String   $sql        Description
 * @return  String              Paging script
 */
function get_paging($noOfRows, $max_row, $sel_page, $args, $sql) {
    global $app_php_script_loc;
    $relativePath = $app_php_script_loc;

    //echo "noOfRows: .$noOfRows / Max Row:. $max_row / Sel Page: .$sel_page / Max Link:.$max_link";
    $return_html = "";
    
    if ($noOfRows <= $max_row) {
        return $return_html;
    }
    
    $url_arg = "";
    $arr_arg = explode("&", $args);
    
    for ($j = 0; $j < count($arr_arg); $j++) {
        if (substr($arr_arg[$j], 0, 3) == "spa") {
            if ($j == 0) {
                $url_arg .= "spa=" . $sql;
            } else {
                $url_arg .= "&spa=" . $sql;
            }
        } else if (substr($arr_arg[$j], 0, 7) != "page_no") {
            if ($j == 0) {
                $url_arg .= $arr_arg[$j];
            } else {
                $url_arg .= "&" . $arr_arg[$j];
            }
        }
    }

    $total_page = intval(($noOfRows - 1) / $max_row) + 1;
    $prev_no = $sel_page - 1;



    $total_row_returned = explode('__total_row_return__=', $url_arg);
    $total_row_returned_final = isset($total_row_returned[1]) ? $total_row_returned[1] : null;
    
    if (isset($_POST['__total_row_return__'] )) {
        $total_row_returned_final = $_POST['__total_row_return__'];
    }
    
    if ($sel_page > 1) {
        $move_first = "<a href= \"javascript:void(0);\" onclick=\"paging_post($total_row_returned_final, 1)\"><IMG SRC='$relativePath/adiha_pm_html/process_controls/paging/move_first.gif' title='" . get_locale_value('First Page') . "' border=0></a>";
        $move_prev = "<a href= \"javascript:void(0);\" onclick=\"paging_post($total_row_returned_final, $prev_no)\"><IMG SRC='$relativePath/adiha_pm_html/process_controls/paging/move_prev.gif' title='" . get_locale_value('Previous Page') . "' border=0></a>";
    } else {
        $move_prev = "<IMG SRC='$relativePath/adiha_pm_html/process_controls/paging/move_prev_disable.gif' border=0>";
        $move_first = "<IMG SRC='$relativePath/adiha_pm_html/process_controls/paging/move_first_disable.gif' title='" . get_locale_value('First Page') . "' border=0>";
    }
    $next_no = $sel_page + 1;
    
    if ($next_no <= $total_page) {
        $move_next = "<a href= \"javascript:void(0);\" onclick=\"paging_post($total_row_returned_final, $next_no)\" ><IMG SRC='$relativePath/adiha_pm_html/process_controls/paging/move_next.gif' title='" . get_locale_value('Next Page') . "' border=0></a>";
        $move_last = "<a href= \"javascript:void(0);\" onclick=\"paging_post($total_row_returned_final, $total_page)\"><IMG SRC='$relativePath/adiha_pm_html/process_controls/paging/move_last.gif' title='" . get_locale_value('Last Page') . "' border=0  style='bordercolor:black'></a>";
    } else {
        $move_next = "<IMG SRC='$relativePath/adiha_pm_html/process_controls/paging/move_next_disable.gif' border=0>";
        $move_last = "<IMG SRC='$relativePath/adiha_pm_html/process_controls/paging/move_last_disable.gif' title='" . get_locale_value('Last Page') . "' border=0 style='bordercolor:black'>";
    }
    
    $ctr = 1;
    $sel = "<select name=curr_page_no_id onchange=\"paging_post($total_row_returned_final, this.value)\" style='font-size:10px'>";
    while ($ctr <= $total_page) {
        $def = "";
        if ($ctr == $sel_page) {
            $def = " selected ";
        }
        $sel = $sel . "<option value='$ctr' $def> $ctr </option>";
        $ctr++;
    }
    $sel = $sel . "</select>";

    $page_label = " ";
    $page_label.= $sel_page . " " . get_locale_value('of') . " " . $total_page;
    $page_label.= " " . get_locale_value('Pages') . " ";

    $return_html.="<table><tr><Td>&nbsp;</td><td>$move_first</td><td>$move_prev</td><td>$page_label</td><td>$move_next</td><td>$move_last</td><Td>&nbsp;&nbsp;</td><td>$sel</td></tr></table>";
    $return_html.="<Script>";
    $return_html.=" function gotopage(obj) { ";
    $return_html.="	var pageno = obj.options[obj.selectedIndex].value;";
    $return_html.="	document.location.href = \"?$url_arg&page_no=\"+pageno";
    $return_html.="}</Script>";
    return $return_html;
}

/**
 * loads report name & applied filter names for Report Writer Reports
 * @param   Array  &$reportA  Report array
 */
function load_report_writer_report_fields(&$reportA) {
    global $app_php_script_loc, $app_user_name, $report_writer_report_id, $arr_rw_look_up_columns;
    $arr_rw_look_up_columns = array();

    if (isset($report_writer_report_id) && $report_writer_report_id != '') {
        if (ctype_digit($report_writer_report_id)) {
            $xmlFile = $app_php_script_loc . "spa_Report_record.php?flag=f&report_id=$report_writer_report_id&use_grid_labels=false&__user_name__=" . $app_user_name;
            $return_value = readXMLURL($xmlFile);
            $cnt = count($return_value);

            if ($cnt > 0) {
                //report name
                $reportA[0] = 'Report Writer - ' . $return_value[0][1];
                for ($i = 0; $i < $cnt; $i++) {
                    $filter_column_name = $return_value[$i][4];
                    //report filters (in the same order they are presented in criteria window)
                    if (!empty($filter_column_name))
                        $reportA[$i + 1] = resolve_predefined_param_names($return_value[$i][4], $return_value[$i][6]);

                    //if the column is DROPDOWN, we need to look up for its values, mark such columns
                    if (!empty($return_value[$i][5]) && $return_value[$i][5] == 'DROPDOWN')
                        $arr_rw_look_up_columns["$filter_column_name"] = $return_value[$i][2];
                }
            }
        } else {
            $reportA[0] = 'Report Writer - ' . $report_writer_report_id;
        }
    }
}

/**
 * format pre-defined param names (if available)
 * @param   String  $entity_name_alias  Entity name
 * @param   String  $data_source        Data source name
 * @return  String                      Entity name alias
 */
function resolve_predefined_param_names($entity_name_alias, $data_source) {
    switch (strtolower($data_source)) {
        case 'subsidiary':
            return 'Subsidiary';

        case 'strategy':
            return 'Strategy';

        case 'book':
            return 'Book';
    }

    return $entity_name_alias;
}

/**
 * get report writer column lookup name for dropdown filters
 * eg. if UOM ID: 528, then return 'BTU' using lookup query defined for that column
 * @param   String  $report_column_id  Column Id
 * @param   String  $value             Value
 * @return  Array                     Column lookup array
 */
function get_report_writer_column_lookup_name($report_column_id, $value) {
    global $app_php_script_loc, $app_user_name;

    $xml_file = $app_php_script_loc . "spa_get_report_writer_column_lookup_name.php?report_column_id=$report_column_id&value=$value&use_grid_labels=false&__user_name__=" . $app_user_name;
    $return_value = readXMLURL($xml_file);
    return (count($return_value) > 0 ? $return_value[0][1] : $value);
}

?>