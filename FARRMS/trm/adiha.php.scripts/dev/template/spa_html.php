<link href="../../css/adiha_style.css" rel="stylesheet" type="text/css">
<?php
$sql = urldecode($_GET["spa"]);

if (( isset($_GET["writeFile"]) == true ) && ( $_GET["writeFile"] == "true" )) {
    $writeFile = true;
    $relationalPath = "../..";
} else {
    $writeFile = false;
    $relationalPath = "..";
}

$sql = stripslashes($sql);
$report_name = "";
$no_sum_report_name = "";
$report_total_clm_start = 0;
$sub_total_clm = -1;
$html_str = "";

include "../components/include.file.ini.php";
include "../adiha.ini.php";
include "spa_html_header.php";
include "../PHP_CLASS_EXTENSIONS/PS.Recordset.1.0.php";

$recordsetObject = new PSRecordSet(false);
$recordsetObject->connectToDatabase($odbc_DB, $odbcUser, $odbcPass);

if (isset($_GET['batch_report_param'])) {
    $sql = str_replace("''", "'", stripslashes($_GET['batch_report_param']));
} else {
    //$sql_batch_header=$sql;
}
;
//##############Customized Invoice Report 
if (strpos($sql, "spa_create_rec_invoice_report") != false) {
    include "invoice.report.php";
    die();
}
//##############END Customized Invoice Report 
$spa_html_header = get_header($sql, "100%", $app_php_script_loc, $recordsetObject->getConnection(), $arrayR, $_GET);

//##############Paging Started
$url_args = $_SERVER['QUERY_STRING'];

if (isset($_GET['page_no'])) {
    $sel_page = $_GET['page_no'];
    $total_row_return = $_GET['__total_row_return__'];
    $call_from_paging = true;

    $arr_list = Array();
    $arr_list = decode_param($sql);
    $sql = "exec $arr_list[1]";

    for ($i = 2; $i < count($arr_list); $i++) {
        if ($i == 2) {
            $existing_param = $arr_list[$i];
        } elseif ($i == count($arr_list) - 1) {
            $existing_param = $existing_param . "," . $sel_page;
        } else {
            $existing_param = $existing_param . "," . $arr_list[$i];
        }
    }
    $sql = $sql . " " . $existing_param;
} else {
    $sel_page = 1;
    $call_from_paging = false;
}

if (( isset($_GET["enable_paging"]) == true ) && ( $_GET["enable_paging"] == "true" ) && ($call_from_paging == false)) {
    $enable_paging = true;
    $arr_list = Array();
    $arr_list = decode_param($sql);
    $sql = "exec $arr_list[1]_paging";
    $existing_param = "";
    for ($i = 2; $i < count($arr_list); $i++) {
        if ($i == 2) {
            $existing_param = $arr_list[$i];
        } else {
            $existing_param = $existing_param . "," . $arr_list[$i];
        }
    }

    $sql = $sql . " " . $existing_param;
    $recordsetObject->runSQLStmt($sql);
    $result = Array();
    $result = $recordsetObject->recordsets();

    $total_row_return = $result[0];
    $process_id = $result[1];

    $paging_param = singleQuote($process_id) . ", " . $max_row_for_html . ", $sel_page ";
        
    if (strlen($existing_param) == 0) {
        $add_param = " " . $paging_param;
    } else {
        $add_param = " ," . $paging_param;
    }
        
    $sql = $sql . $add_param;
    $url_args = $url_args . "&__total_row_return__=$total_row_return";
} else {
    $enable_paging = false;
}
    
$spa_html_paging = "";
    
if (($enable_paging == true) || ($call_from_paging == true)) {
    $spa_html_paging = get_paging($total_row_return, $max_row_for_html, $sel_page, $url_args, $sql);
}
//##############Paging Ended

$recordsetObject->runSQLStmt($sql);
$fields = $recordsetObject->clms;

/* * **** code for total ************** */
$clm_total = array();
$clm_total_format = array();
$clm_sub_total = array();
$clm_tot_col_span = 0;
$clm_sub_col_span = 0;

if (strpos($sql, "spa_Create_Hedges_Measurement_Report") != false) {
    $report_name = "spa_Create_Hedges_Measurement_Report";

    //summary cash-flow
    if ($fields == 14) {
        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 2;
        $clm_tot_col_span = 3;
      } else if ($fields == 19) { //detail cash-flow
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 7;
        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $sub_total_clm = 3;
        $clm_sub_col_span = 5;
        $clm_tot_col_span = 8;
      } else if ($fields == 16) { //summary fair-value
        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 2;
        $clm_tot_col_span = 3;
    } else if ($fields == 21) {
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 7;
        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_sub_col_span = 5;
        $sub_total_clm = 3;
        $clm_tot_col_span = 8;
    }
} else if (strpos($sql, "spa_Create_AOCI_Report") != false) {
    $report_name = "spa_Create_AOCI_Report";
    
    if ($fields == 3) { //summary
        $clm_total = array("Total", "", 0.00);
        $clm_total_format = array("", "", "$");
        $report_total_clm_start = 1;
        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00);
        $sub_total_clm = 0;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    } else if ($fields == 4 && $arrayR[8] == "'t'") {   //another summary
        $clm_total = array("Total", "", "", 0.00);
        $clm_total_format = array("", "", "", "$");
        $report_total_clm_start = 2;
        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00);
        $sub_total_clm = 1;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    } else if ($fields == 4 && $arrayR[8] != "'t'") {   //another summary
        $clm_total = array("Total", "", "", 0.00);
        $clm_total_format = array("", "", "", "$");
        $report_total_clm_start = 2;
        $clm_sub_total = array("", "<i>Sub-total</i>", "", 0.00);
        $sub_total_clm = 0;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    } else if ($fields == 7) {   //detail
        $clm_total = array("Total", "", "", "", "", "", 0.00);
        $clm_total_format = array("", "", "", "", "", "", "$");
        $report_total_clm_start = 5;
        $clm_sub_total = array("", "", "", "", "<i>Sub-total</i>", "", 0.00);
        $sub_total_clm = 3;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    }
} else if (strpos($sql, "spa_drill_down_msmt_report") != false) {
    if ($fields == 26 && $arrayR[2] == "'link'") {
        $report_name = "spa_drill_down_msmt_report";
        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "", "");
        $clm_total_format = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "N", "N", "$", "$", "$", "$", "$", "$", "$", "$", "N", "N");
        $report_total_clm_start = 15;
        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "", "");
        $sub_total_clm = 1;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    }
} else if (strpos($sql, "spa_Create_MTM_Period_Report") != false) {
    $report_name = "spa_Create_MTM_Period_Report";
    if ($fields == 4 && ($arrayR[9] == "'s'" || $arrayR[9] == "'q'")) { //summary
        $clm_total = array("Total", "", "", 0.00);
        $clm_total_format = array("", "", "N", "$");
        $report_total_clm_start = 2;
        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00);
        $sub_total_clm = 1;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    } else if ($fields == 5 && $arrayR[9] = "'c'") {   //another summary
        $clm_total = array("Total", "", "", "", 0.00);
        $clm_total_format = array("", "", "", "N", "$");
        $report_total_clm_start = 3;
        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", 0.00);
        $sub_total_clm = 2;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    } else if ($fields == 3 && ($arrayR[9] == "'p'" || $arrayR[9] == "'r'")) { //summary
        $clm_total = array("Total", "", 0.00);
        $clm_total_format = array("", "", "$");
        $report_total_clm_start = 1;
        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00);
        $sub_total_clm = 0;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    } else if ($fields == 6 && $arrayR[9] == "'t'") {   //detail
        $clm_total = array("Total", "", "", "", "", 0.00);
        $clm_total_format = array("", "", "", "", "N", "$");
        $report_total_clm_start = 4;
        $clm_sub_total = array("", "", "", "", "<i>Sub-total</i>", 0.00);
        $sub_total_clm = 3;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    } else if ($fields == 8 && $arrayR[9] == "'d'") {   //detail
        $clm_total = array("Total", "", "", "", "", "", "", 0.00);
        $clm_total_format = array("", "N", "N", "N", "N", "N", "N", "$");
        $report_total_clm_start = 6;
        $clm_sub_total = array("", "", "", "", "", "", "<i>Sub-total</i>", 0.00);
        $sub_total_clm = 5;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    }
} else if ($fields != 2 && strpos($sql, "spa_get_db_measurement_trend") != false) {
    $report_name = "spa_get_db_measurement_trend";
    //summary cash-flow
    if ($fields == 12) {
        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 2;
        $clm_tot_col_span = 3;
      } else if ($fields == 21) { //detail cash-flow
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 7;
        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $sub_total_clm = 3;
        $clm_sub_col_span = 5;
        $clm_tot_col_span = 8;
      } else if ($fields == 15) { //summary fair-value
        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 2;
        $clm_tot_col_span = 3;
    } else if ($fields == 20) {
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "", "", "", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 7;
        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_sub_col_span = 5;
        $sub_total_clm = 3;
        $clm_tot_col_span = 8;
    }
} else if (strpos($sql, "spa_Create_MTM_Measurement_Report") != false) {
    $report_name = "spa_Create_MTM_Measurement_Report";
    if ($fields == 11) {
        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 2;
        $clm_tot_col_span = 3;
    } else if ($fields == 14) {
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "", "$", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 5;
        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.0, 0.000);
        $sub_total_clm = 3;
        $clm_sub_col_span = 3;
        $clm_tot_col_span = 6;
    }
} elseif (strpos($sql, "spa_Create_MTM_Journal_Entry_Report") != false) {
    $report_name = "spa_Create_MTM_Journal_Entry_Report";
    if ($fields == 4) {
        $clm_total = array("Total", "esc_td", 0.00, 0.00);
        $clm_total_format = array("", "", "$", "$");
        $report_total_clm_start = 1;
        $clm_tot_col_span = 2;
    } else if ($fields == 7) {
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "$", "$");
        $report_total_clm_start = 4;
        $clm_sub_total = array("", "", "<i>Sub-total</i>", "esc_td", "esc_td", 0.00, 0.00);
        $sub_total_clm = 2;
        $clm_sub_col_span = 3;
        $clm_tot_col_span = 5;
    }
} elseif (strpos($sql, "spa_Create_Inventory_Journal_Entry_Report") != false ||
        strpos($sql, "spa_create_inventory_journal_entry_report_paging") != false) {

    $report_name = "spa_Create_Inventory_Journal_Entry_Report";
        
    if ($fields == 4) {
        $clm_total = array("Total", "esc_td", 0.00, 0.00);
        $clm_total_format = array("", "", "$", "$");
        $report_total_clm_start = 1;
        $clm_tot_col_span = 2;
    } else if ($fields == 5 && $arrayR[8] == "'j'") {
        $clm_total = array("Total", "", "", 0.00, 0.00);
        $clm_total_format = array("Total", "N", "N", "$", "$");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00);
        $sub_total_clm = 0;
    } else if ($fields == 5 && $arrayR[8] == "'t'") {
        $clm_total = array(0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("$", "$", "$", "$", "$");
        $report_total_clm_start = -1;
        $clm_sub_total = array(0.00, 0.00, 0.00, 0.00, 0.00);
        $sub_total_clm = -1;
    } else if ($fields == 6 && $arrayR[8] == "'j'") {
        $clm_total = array("Total", "", "", "", 0.00, 0.00);
        $clm_total_format = array("Total", "N", "N", "N", "$", "$");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00);
        $sub_total_clm = 0;
    } else if ($fields == 6 && $arrayR[8] == "'t'") {
        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("Total", "$", "$", "$", "$", "$");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00);
        $sub_total_clm = 0;
    } else if ($fields == 8 && $arrayR[7] == "'t'") {
        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "$.2", "N", "$.2", "N", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0, 00, 0.00, 0.00);
        $sub_total_clm = -1;
    } else if ($fields == 8) {
        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("Total", "N", "N", "$", "$", "$", "$", "$");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0, 00, 0.00, 0.00);
        $sub_total_clm = 0;
    } else if ($fields == 7 && $arrayR[8] == "'j'") {
        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("Total", "N", "N", "N", "N", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00);
        $sub_total_clm = 0;
    } else if ($fields == 7 && $arrayR[8] == "'t'") {
        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("Total", "N", "$", "$", "$", "$", "$");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, 0.00);
        $sub_total_clm = 0;
    } else if ($fields == 14) {
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("Total", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, 0, 00, 0.00, 0.00, 0.00, 0.00);
        $sub_total_clm = 0;
    } else if ($fields == 10 && $arrayR[7] == "'g'") {        
        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        if (count($arrayR) == 17)
            $clm_total_format = array("N", "N", "$.2", "N", "N", "N", "X", "N", "N", "N");
        else
            $clm_total_format = array("N", "N", "$.2", "N", "N", "N", "N", "N", "N", "N");

        $report_total_clm_start = 0;
        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
      } else if ($fields == 11 && $arrayR[7] == "'g'") {
        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        if (count($arrayR) == 17)
            $clm_total_format = array("N", "N", "$.2", "$.2", "N", "N", "N", "X", "N", "N", "N");
        else
            $clm_total_format = array("N", "N", "$.2", "$.2", "N", "N", "N", "N", "N", "N", "N");

        $report_total_clm_start = 0;
        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
      } else if ($fields == 12 && $arrayR[7] == "'g'") {
        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        if (count($arrayR) == 17)
            $clm_total_format = array("N", "N", "N", "$.2", "$.2", "N", "N", "N", "X", "N", "N", "N");
        else
            $clm_total_format = array("N", "N", "N", "$.2", "$.2", "N", "N", "N", "N", "N", "N", "N");

        $report_total_clm_start = 0;
        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    }
} elseif (strpos($sql, "spa_Netted_Journal_Entry_Report") != false) {
    $report_name = "spa_Netted_Journal_Entry_Report";
    if ($fields == 5) {
        $clm_total = array("Total", "esc_td", "esc_td", 0.00, 0.00);
        $clm_total_format = array("", "", "", "$", "$");
        $report_total_clm_start = 2;
        $clm_tot_col_span = 3;
    } else if ($fields == 6) {
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "$", "$");
        $report_total_clm_start = 3;
        $clm_sub_total = array("", "<i>Sub-total</i>", "esc_td", "esc_td", 0.00, 0.00);
        $sub_total_clm = 1;
        $clm_sub_col_span = 3;
        $clm_tot_col_span = 4;
    }
} elseif (strpos($sql, "spa_Create_Dedesignation_Values_Report") != false) {
    $report_name = "spa_Create_Dedesignation_Values_Report";
    if ($fields == 8) {
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "$", "$", "$", "$");
        $report_total_clm_start = 3;
        $clm_tot_col_span = 4;
    } else if ($fields == 14) {
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "", "", "", "", "", "$", "$", "$", "$");
        $report_total_clm_start = 9;
        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, 0.00);
        $sub_total_clm = 3;
        $clm_sub_col_span = 7;
        $clm_tot_col_span = 10;
    }
} elseif (strpos($sql, "spa_Create_Available_Hedge_Capacity_Exception_Report") != false) {
    $report_name = "spa_Create_Available_Hedge_Capacity_Exception_Report";
    if ($fields == 11) {
        $clm_total = array("Total", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("", "", "", "", "", "", "", "", "", "", "N");
        $report_total_clm_start = 6;
        $clm_sub_total = array("", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 3;
        $clm_sub_col_span = 4;
        $clm_tot_col_span = 7;
    } else if ($fields == 13) {
        $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "", "");
        $clm_total_format = array("", "", "", "", "", "", "", "", "", "", "", "", "N");
        $report_total_clm_start = 10;
        $clm_sub_total = array("", "", "", "", "", "", "", "<i>Sub-total</i>", "esc_td", "esc_td", "esc_td", 0.00, "");
        $clm_sub_col_span = 4;
        $sub_total_clm = 7;
    }
} elseif (strpos($sql, "spa_Get_All_Notes") != false) {
    $no_sum_report_name = "spa_Get_All_Notes";
} elseif (strpos($sql, "spa_Create_Cash_Flow_Report") != false) {
    $report_name = "spa_Create_Cash_Flow_Report";
    if ($fields == 3) {
        $clm_total = array("Total", "", 0.00);
        $clm_total_format = array("", "", "$");
        $report_total_clm_start = 1;
        //$clm_sub_total =  array("", "<i>Sub-total</i>", "esc_td");
        //$sub_total_clm = 0;
        // $clm_sub_col_span=2;
        //$clm_tot_col_span = 2;
    } else if ($fields == 4) {
        $clm_total = array("Total", "", "", 0.00);
        $clm_total_format = array("", "", "", "$");
        $report_total_clm_start = 2;
        //$clm_sub_total =  array("", "<i>Sub-total</i>", "esc_td", "esc_td");
        //$sub_total_clm = 0;
        //$clm_tot_col_span = 3;
        //$clm_sub_col_span=3;
    }
} elseif (strpos($sql, "spa_drill_down_msmt_report") != false && (strtolower($arrayR[2]) == "'aoci'" ||
        strtolower($arrayR[2]) == "'pnl'")) {
    $report_name = "spa_drill_down_msmt_report";

    if ($fields == 9) {
        $clm_total = array("", "", "", "", "Total", "esc_td", 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "", "$", "$", "$");
        $report_total_clm_start = 5;
        $clm_tot_col_span = 2;
    } else if ($fields == 11) {
        $clm_total = array("", "", "", "", "Total", "esc_td", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("", "", "", "", "", "", "$", "$", "$", "$", "$");
        $report_total_clm_start = 5;
        $clm_tot_col_span = 2;
    }
} elseif (strpos($sql, "spa_Create_Disclosure_Report") != false) {
    if ($fields == 3) {
        $report_name = "spa_Create_Disclosure_Report";
        $clm_total = array("", "", "");
        $clm_total_format = array("N", "N", "");
        $report_total_clm_start = -1;
    }
} elseif (strpos($sql, "spa_Create_Reconciliation_Report") != false) {
    if ($fields == 3) {        //summary MTM
        $report_name = "spa_Create_Reconciliation_Report";
        $clm_total = array("", "", "");
        $clm_total_format = array("N", "N", "");
        $report_total_clm_start = -1;
    }

    if ($fields == 7) {   //summary cash-flow and fair value
        $report_name = "spa_Create_Reconciliation_Report";
        $clm_total = array("", "", "", "", "", "", "");
        $clm_total_format = array("N", "N", "", "", "", "", "");
        $report_total_clm_start = -1;
    }

    if ($fields == 13) { //detail cash flow and fair value
        $report_name = "spa_Create_Reconciliation_Report";
        $clm_total = array("", "", "", "", "", "", "", "", "0.00", "0.00", "0.00", "0.00", "0.00");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$", "$", "$", "$", "$");
        $report_total_clm_start = -1;
        $clm_sub_total = array("", "", "", "", "", "", "", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00);
        // $clm_sub_col_span=3;
        $sub_total_clm = 6;
    }

    if ($fields == 9) { //detail cash flow and fair value
        $report_name = "spa_Create_Reconciliation_Report";
        $clm_total = array("", "", "", "", "", "", "", "", "0.00");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "$");
        $report_total_clm_start = -1;
        $clm_sub_total = array("", "", "", "", "", "", "", "<i>Sub-total</i>", 0.00);
        // $clm_sub_col_span=3;
        $sub_total_clm = 6;
    }
} elseif (strpos($sql, "spa_Create_NetAsset_Report") != false) {
    $report_name = "spa_Create_NetAsset_Report";

    if ($fields == 2) {        //summary MTM
        $clm_total = array("", "");
        $clm_total_format = array("", "X");
        $report_total_clm_start = 0;
        // $clm_sub_total = array("", "");
        //$sub_total_clm = 2;
        //$clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }

    if ($fields == 3) {        //summary MTM
        $clm_total = array("", "", "");
        $clm_total_format = array("", "", "");
        $report_total_clm_start = 4;
        $clm_sub_total = array("", "", "");
        $sub_total_clm = 0;
        //$clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }

    if ($fields == 4 && $arrayR[7] != "'b'") {        //summary MTM
        $clm_total = array("", "", "", "");
        $clm_total_format = array("", "", "", "$");
        $report_total_clm_start = 4;
        $clm_sub_total = array("", "", "", "");
        $sub_total_clm = 1;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    }

    if ($fields == 5 && $arrayR[7] != "'b'") {        //summary MTM
        $clm_total = array("", "", "", "", "");
        $clm_total_format = array("", "", "", "", "$");
        $report_total_clm_start = 5;
        $clm_sub_total = array("", "", "", "", "");
        $sub_total_clm = 2;
        $clm_sub_col_span = 0;
        $clm_tot_col_span = 0;
    }

    if ($fields == 7 && $arrayR[7] == "'b'") {        //sumary MTM
        $clm_total = array("Total", "", "", "", "", "", 0.00);
        $clm_total_format = array("N", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 5;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00);
        // $sub_total_clm = 0;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }

    if ($fields == 8 && $arrayR[7] == "'b'") {        //sumary MTM
        $clm_total = array("Total", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 0;
        //$clm_sub_total = array("<i>Sub-total</i>","","","","","","", 0.00);
        $sub_total_clm = -1;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }

    if ($fields == 9 && $arrayR[7] == "'b'") {        //sumary MTM
        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 1;
        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", 0.00);
        $sub_total_clm = 0;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }

    if ($fields == 10 && $arrayR[7] == "'b'") {        //sumary MTM
        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "$", "$", "$", "$", "$", "$", "$");
        $report_total_clm_start = 2;
        $clm_sub_total = array("", "", "<i>Sub-total</i>", "", "", "", "", "", "", 0.00);
        $sub_total_clm = 1;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }
} elseif (strpos($sql, "spa_drill_down_jentries") != false) {
    $report_name = "spa_drill_down_jentries";

    if ($fields == 3) {        //sumary MTM
        $clm_total = array("Total", "", 0.00);
        $clm_total_format = array("N", "N", "$");
        $report_total_clm_start = 1;
        //$clm_sub_total = array("<i>Sub-total</i>",0.00,0.00,"");
        $sub_total_clm = -1;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }
} elseif (strpos($sql, "spa_Create_Reclassification_Report ") != false) {
    $report_name = "spa_Create_Reclassification_Report ";

    if ($fields == 2) {        //sumary MTM
        $report_name = "";
    }
    if ($fields == 4) {        //sumary MTM
        $clm_total = array("Total", 0.00, 0.00, "");
        $clm_total_format = array("N", "$", "$", "N");
        $report_total_clm_start = 0;
        //$clm_sub_total = array("<i>Sub-total</i>",0.00,0.00,"");
        $sub_total_clm = -1;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }
    if ($fields == 5) {        //sumary MTM
        $clm_total = array("Total", "", 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "$", "$", "N");
        $report_total_clm_start = 1;
        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, "");
        $sub_total_clm = 0;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }
    if ($fields == 6) {        //sumary MTM
        $clm_total = array("Total", "", "", 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "$", "$", "N");
        $report_total_clm_start = 2;
        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00, 0.00, "");
        $sub_total_clm = 1;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }
} elseif (strpos($sql, "spa_create_income_statement ") != false) {
    $report_name = "spa_create_income_statement ";

    if ($fields == 3) {        //sumary MTM
        $clm_total = array("Total", "", 0.00);
        $clm_total_format = array("N", "N", "$");
        $report_total_clm_start = 0;
        //$clm_sub_total = array("<i>Sub-total</i>",0.00,0.00,"");
        $sub_total_clm = -1;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }

    if ($fields == 4) {        //sumary MTM
        $clm_total = array("Total", "", "", 0.00);
        $clm_total_format = array("N", "N", "N", "$");
        $report_total_clm_start = 0;
        //$clm_sub_total = array("<i>Sub-total</i>",0.00,0.00,"");
        $sub_total_clm = -1;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }

    if ($fields == 5) {        //sumary MTM
        $clm_total = array("Total", "", "", "", 0.00);
        $clm_total_format = array("N", "N", "N", "N", "$");
        $report_total_clm_start = 1;
        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, "");
        $sub_total_clm = 1;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }
    if ($fields == 6) {        //sumary MTM
        $clm_total = array("Total", "", "", "", "", 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "$");
        $report_total_clm_start = 2;
        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00, 0.00, "");
        $sub_total_clm = 2;
        // $clm_sub_col_span = 0;
        //$clm_tot_col_span = 0;
    }
} elseif (strpos($sql, "spa_journal_entry_posting_temp") != false) {
    $report_name = "spa_journal_entry_posting_temp";
    if ($fields == 4) {
        $clm_total = array("Total", "esc_td", 0.00, 0.00);
        $clm_total_format = array("", "", "$", "$");
        $report_total_clm_start = 1;
        $clm_tot_col_span = 2;
    }
} elseif (strpos($sql, "spa_drill_down_settlement") != false) {
    $report_name = "spa_drill_down_settlement";
    if ($fields == 3) {
        $clm_total = array("Total", "esc_td", 0.00);
        $clm_total_format = array("", "", "$");
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
    $report_name = "spa_compare_msmt_values";
    if ($fields == 11) {
        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, "");
        $clm_total_format = array("", "", "", "", "$", "$", "$", "$", "$", "$", "N");
        $report_total_clm_start = 3;
        $clm_tot_col_span = 0;
        //$clm_sub_total = array("","<i>Sub-total</i>","","",0.00,0.00);
        //$sub_total_clm = 1;
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
} elseif (strpos($sql, "spa_REC_Target_Report") != false) {
    $report_name = "spa_REC_Target_Report";
    if ($fields == 10) {
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
        $report_total_clm_start = 2;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("", "", "<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 4;
    }
    if ($fields == 14) {
        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
        $report_total_clm_start = 4;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 1;
    }
    if ($fields == 15) {
        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
        $report_total_clm_start = 5;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 1;
    }
} elseif (strpos($sql, "spa_REC_Target_Report_Drill") != false || strpos($sql, "spa_rec_target_report_drill_paging") != false) {
    $report_name = "spa_REC_Target_Report_Drill";
    if ($fields == 16) {
        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "X", "X", "X", "N");
        $report_total_clm_start = 4;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 1;
    }
} elseif (strpos($sql, "spa_create_lifecycle_of_recs") != false) {
    $report_name = "spa_create_lifecycle_of_recs";
    $clm_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
    $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
    $report_total_clm_start = -1;
    //$clm_tot_col_span = 0;
    $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
    $sub_total_clm = 0;
} elseif (strpos($sql, "spa_find_gis_recon_deals") != false) {
    $report_name = "spa_find_gis_recon_deals";

    if ($fields == 10) {
        $clm_total = array("", "", "", "", "", "", "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
        $report_total_clm_start = -1;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = 1;
    }
    if ($fields == 6) {
        $clm_total = array("", "", "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N");
        $report_total_clm_start = -1;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("", "", "", "", "", "");
        $sub_total_clm = -1;
    }

    if ($fields == 9) {
        $clm_total = array("", "", "", "", "", "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N");
        $report_total_clm_start = -1;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("", "", "", "", "", "", "", "", "");
        $sub_total_clm = 1;
    }if ($fields == 11) {
        $clm_total = array("", "", "", "", "", "", "", "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N");
        $report_total_clm_start = -1;
        //$clm_tot_col_span = 0;
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
        $clm_total_format = array("N", "N", "N", "N", "N", "$.2");
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

    if ($fields == 5) { //summary
        $clm_total = array("Total", "", "", 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "$.2", "$.2", "N");
        $report_total_clm_start = 1;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, "");
        $sub_total_clm = 0;
    }

    if ($fields == 6) { //summary
        $clm_total = array("Total", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "$.2", "$.2", "$.2", "N");
        $report_total_clm_start = 1;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 0;
    }

    if ($fields == 7) { //summary

        $clm_total = array("Total", "", "", "", 0.00, "", 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "$.2", "N", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 1;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, "", 0.00, 0.00);
        $sub_total_clm = 1;
    }

    if ($fields == 8 && $arrayR[7] == "'s'" && $arrayR[43] != "'t'") { //summary
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "$.2", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 1;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
        $sub_total_clm = 1;
    }

    if ($fields == 7 && $arrayR[43] == "'t'" && $arrayR[7] == "'s'") { //summary
        $clm_total = array("Total", "", "", "", "", "", 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 1;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
        $sub_total_clm = 1;
    }

    if ($fields == 8 && $arrayR[43] == "'t'" && $arrayR[7] != "'s'") { //summary
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "N", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 1;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
        $sub_total_clm = 1;
    }

    if ($fields == 8 && $arrayR[7] == "'a'") { //summary
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 1;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, "");
        $sub_total_clm = 0;
    }


    if ($fields == 9 && $arrayR[7] == "'s'") { //summary
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 1;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 1;
    }

    if ($fields == 9 && $arrayR[7] == "'a'") { //summary
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 1;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 0;
    }

    if ($fields == 9 && $arrayR[7] == "'v'") { //obligation
        $clm_total = array("Total", "", "", "", 0.00, 0.00, 0.00, "", 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "$.2", "$.2", "$.2", "N", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 1;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", 0.00, 0.00, 0.00, "", 0.00);
        $sub_total_clm = 1;
    }

    if ($fields == 10 && $arrayR[43] == "'t'" && $arrayR[7] == "'c'") { //counterparty and transactions
        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "N", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, "", 0.00, 0.00);
        $sub_total_clm = 1;
    }

    if ($fields == 9 && $arrayR[43] == "'t'" && ($arrayR[7] == "'g'" || $arrayR[7] == "'h'" || $arrayR[7] == "'y'")) { //generator and transactions
        $clm_total = array("Total", "", "", "", "", 0.00, "", 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, "", 0.00, 0.00);
        $sub_total_clm = 1;
    }

    if ($fields == 10 && $arrayR[43] != "'t'") { //counterparty
        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "N", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, "", 0.00, 0.00);
        $sub_total_clm = 1;
    }

    if ($fields == 10 && $arrayR[43] != "'t'" && $arrayR[7] == "'y'") { //counterparty
        $clm_total = array("Total", "", "", "", "", "", 0.00, "", 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "N", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, "", 0.00, "");
        $sub_total_clm = 1;
    }

    if ($fields == 10 && $arrayR[43] == "'t'") { //generator
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 1;
    }

    if ($fields == 10 && $arrayR[43] != "'t'" && ($arrayR[7] == "'g'" || $arrayR[7] == "'h'" )) { //generator
        $clm_total = array("Total", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 1;
    }

    if ($fields == 12 && $arrayR[43] == "'t'") { //generator group and transactions
        $clm_total = array("Total", "", "", "", "", "", "", "", 0.00, "", 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "N", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 1;
    }

    if ($fields == 11 && $arrayR[43] != "'t'") { //generator group
        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $sub_total_clm = 1;
    }
    if ($fields == 13 && $arrayR[7] != "'a'") { //trader
        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N", "N", "$.2");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", 0.00);
        $sub_total_clm = 0;
    }

    if ($fields == 14 && $arrayR[43] == "'t'" && $arrayR[7] == "'p'") { //deal_detail options
        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "N", "$.2", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", 0.00, 0.00, 0.00, "", "", 0.00);
        $sub_total_clm = -1;
    }

    if ($fields == 21) { //detail
        $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0.00, 0.00, 0.00, "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "N");
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
        $clm_total_format = array("N", "N", "N", "N", "N", "$.2");
        $report_total_clm_start = 0;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("", "", "", "", 0.00, 0.00);
        $sub_total_clm = -1;
    }
} elseif (strpos($sql, "spa_create_rec_confirm_report") != false) {
    $report_name = "spa_create_rec_confirm_report";
    if ($fields == 8) {
        $clm_total = array("", "", "", "", "0.00", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "N");
        $report_total_clm_start = -1;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("", "", "", "", "", "", "", "");
        $sub_total_clm = 1;
    }
} elseif (strpos($sql, "spa_create_rec_compliance_report") != false) {
    $report_name = "spa_create_rec_compliance_report";
    if ($fields == 9) {
        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
        $report_total_clm_start = 1;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
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
        $clm_sub_total = array("", "", "<i>Sub-total</i>", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $sub_total_clm = 0;
    }
}
/*
  elseif (strpos($sql, "spa_create_rec_compliance_report") != false)
  {
  $report_name = "spa_create_rec_compliance_report";
  if ($fields == 12)
  {
  $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
  $clm_total_format = array("N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
  $report_total_clm_start = 1;
  $clm_tot_col_span = 0;
  $clm_sub_total = array("","<i>Sub-total</i>",0.00,0.00,0.00,0.00,0.00,0.00,0.00, 0.00,0.00,0.00);
  $sub_total_clm = 0;
  }
  if ($fields == 18)
  {
  $clm_total = array("Total", "", "", "", "", "", "", "", "", "","", "", "", "", 0.00, 0.00, 0.00, 0.00);
  $clm_total_format = array("N", "N", "N", "N", "N", "N", "N","N", "N", "N", "N","N", "N", "N","X", "X","X", "X");
  $report_total_clm_start =12;
  $clm_tot_col_span = 0;
  $clm_sub_total = array("","<i>Sub-total</i>","", "", "", "", "", "", "", "", "", "","", "", 0.00,0.00, 0.00,0.00);
  $sub_total_clm = -1;
  }
  if ($fields == 19)
  {
  $clm_total = array("Total", "", "","", "", "", "", "", "", "", "","", "", "", "", 0.00, 0.00, 0.00, 0.00);
  $clm_total_format = array("N", "N","N", "N", "N", "N", "N", "N","N", "N", "N", "N","N", "N", "N","X", "X","X", "X");
  $report_total_clm_start =12;
  $clm_tot_col_span = 0;
  $clm_sub_total = array("","<i>Sub-total</i>","", "", "", "", "","", "", "", "", "", "","", "", 0.00,0.00, 0.00,0.00);
  $sub_total_clm = -1;
  }
  }
 */ elseif (strpos($sql, "spa_run_wght_avg_inventory_cost_report") != false) {
    $report_name = "spa_run_wght_avg_inventory_cost_report";
    if ($fields == 7) {
        $clm_total = array("Total", "", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "$.2", ".2", "$.4");
        $report_total_clm_start = -1;
        $clm_tot_col_span = 0;
        $clm_sub_total = array("", "<i>Sub-total</i>", "", "", 0.00, 0.00, 0.00);
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
    } else if ($fields == 17) {
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
    //$clm_tot_col_span = 0;
    $clm_sub_total = array("", "", "", "");
    $sub_total_clm = -1;
} elseif (strpos($sql, "spa_get_rec_assign_log") != false) {
    $report_name = "spa_get_rec_assign_log";
    $clm_total = array("", "", "", "", "", "", "");
    $clm_total_format = array("N", "N", "N", "N", "N", "N", "N");
    $report_total_clm_start = -1;
    //$clm_tot_col_span = 0;
    $clm_sub_total = array("", "", "", "", "", "", "");
    $sub_total_clm = -1;
} elseif (strpos($sql, "spa_REC_Exposure_Report") != false) {
    $report_name = "spa_REC_Exposure_Report";
    if ($fields == 10) {
        $clm_total = array("Total", "", "", "", "", 0.00, "", "", 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "$", "N", "N", "$", "$");
        $report_total_clm_start = 0;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", 0.00, "", "", 0.00, 0.00);
        $sub_total_clm = 4;
    }
    /*        if ($fields == 12)
      {
      $clm_total = array("Total", "", "", "", "", "", "", 0.00, "", "", 0.00, 0.00);
      $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$", "N", "N", "$", "$");
      $report_total_clm_start = 0;
      //$clm_tot_col_span = 0;
      $clm_sub_total = array("<i>Sub-total</i>","","","","","","",0.00,"","",0.00,0.00);
      $sub_total_clm = 4;
      } */
} elseif (strpos($sql, "spa_find_matching_rec_deals") != false) {
    $report_name = "spa_find_matching_rec_deals";
    if ($fields == 16) {
        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "N");
        $report_total_clm_start = 0;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    } else if ($fields == 18) {
        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "N", "N", "N");
        $report_total_clm_start = 0;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    } else if ($fields == 17) {
        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "N", "N");
        $report_total_clm_start = 0;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    } else if ($fields == 15) {
        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "N", "N", "N", "N");
        $report_total_clm_start = 0;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    }
} elseif (strpos($sql, "spa_gen_invoice_variance_report") != false) {
    $report_name = "spa_gen_invoice_variance_report";

    if ($fields == 2) {
        $clm_total = array("", 0.00);
        $clm_total_format = array("N", "$.2");
        $report_total_clm_start = -1;
        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    }
        
    if ($fields == 4) {
        $clm_total = array("", 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "$.2", "$.2", "N");
        $report_total_clm_start = -1;
        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    } else if ($fields == 5) {
        $clm_total = array("", 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "$.4", "$.2");
        $report_total_clm_start = 0;
        $clm_sub_total = array("", "", "", "", "", "");
        $sub_total_clm = -1;
    } else if ($fields == 6 && count($arrayR) == 7) {
        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "$.2");
        $report_total_clm_start = -1;
        $clm_sub_total = array("", "", "", "", "", "");
        $sub_total_clm = -1;
    } else if ($fields == 6 && count($arrayR) == 8) {
        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "$.2");
        $report_total_clm_start = -1;
        $clm_sub_total = array("", "", "", "", "", "");
        $sub_total_clm = -1;
    } else if ($fields == 6 && count($arrayR) == 6) {
        $clm_total = array("", 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_sub_total = array("", "", "", "", "", "");
        $sub_total_clm = -1;
    } else if ($fields == 3) {
        $clm_total = array("", 0.00, 0.00,);
        $clm_total_format = array("N", "$.2", "N");
        $report_total_clm_start = 0;
        $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    }
} elseif (strpos($sql, "spa_get_calc_invoice_volume") != false) {
    $report_name = "spa_get_calc_invoice_volume";
    if ($fields == 10) {
        $clm_total = array("Total", "", "", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, "", "", "", "");
        $clm_total_format = array("N", "N", "N", "N", "$.2", "$.2", "$.2", "N", "N", "N");
        $report_total_clm_start = 0;
        //$clm_tot_col_span = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = -1;
    }
} elseif (strpos($sql, "spa_rec_production_report") != false) {
    $report_name = "spa_rec_production_report";

    if ($fields == 16) {
        $clm_total = array("Total", "", "", "", "", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);
        $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2", "$.2");
        $report_total_clm_start = 0;
        $clm_sub_total = array("<i>Sub-total</i>", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        $sub_total_clm = 0;
    }
}

/* * ** end of code total ************************** */

$result = Array();
$result = $recordsetObject->recordsets();

	/**
	 * Highlight cell element.
	 * @param mixed $string String.
	 * @param mixed $clm_sub_col_span Sub total column span.
	 * @param mixed $clm_tot_col_span Total column span.
	 * @return Highlighted table data.
	 */
function encloseTD($string, $clm_sub_col_span, $clm_tot_col_span) {
    if ($string == "<B><i>Sub-total</i></B>") {
        if ($clm_sub_col_span != 0)
            return( "<td valign='middle' colspan=$clm_sub_col_span><font face='arial'><b>$string</b></font></td>" );
        else
            return( "<td valign='middle'><font face='arial'><b>$string&nbsp;</b></font></td>" );

      } else if ($string == "<B>Total</B>") {
        if ($clm_tot_col_span != 0)
            return( "<td valign='middle' colspan=$clm_tot_col_span><font face='arial' ><b>$string</b></font></td>" );
        else
            return( "<td valign='middle'><font face='arial' ><b>$string&nbsp;</b></font></td>" );
    } else if ($string == "<B>esc_td</B>")
        return "";
    else
        return( "<td valign='middle'><font face='tahoma' >$string&nbsp;</font></td>" );
}

	/**
	 * Highlight table headings.
	 * @param mixed $string String.
	 * @return Highlighted table headings.
	 */
function encloseTH($string) {
    return "<th align=left><font color='#000000' face='verdana' ><b>$string</b></font></th>";
}

/* * **
  //This function is not used, can delete it later
  function addTotal($report_name, $clm_total, $clm_index, $value_to_add) {
  if ($report_name = "spa_Create_Hedges_Measurement_Report")
  {
  if ($clm_index > 2)
  {
  //echo "value to add=" . $value_to_add . " current=" . $clm_total[$clm_index] ;
  $clm_total[$clm_index] =  $clm_total[$clm_index] + $value_to_add;
  }
  }
  }
 * *** */

/**
	 * Format numbers.
	 * @param mixed $format_str Format type.
	 * @param mixed $value Value to be formated.
	 * @return Formated numbers.
	 */
function my_number_format($format_str, $value) {
    if ($format_str != "N" && $format_str != "X")
        if ($format_str == "L" && number_format($value) == 0)
            return "";
        else {
            $decimals = 0;
            $pieces = explode(".", $format_str);
            if (count($pieces) > 1)
                $decimals = $pieces[1];
            //echo    $decimals;
            return number_format($value, $decimals);
        }
    else
        return $value;
}

	/**
	 * Format Numbers.
	 * @param mixed $format_str Format type.
	 * @return Formated numbers.
	 */
function number_format_str($format_str) {
    if ($format_str != "N" && (strrpos($format_str, "$") === false) && $format_str != "X")
        return $format_str;
    else
        return "";
}

/**
	 * Get drill down PHP page.
	 * @param mixed $phpRefPath Reference path.
	 * @param mixed $clmType Cloumn type.
	 * @param mixed $sqlStmt SQL statement.
	 * @param mixed $linkId Link Id.
	 * @param mixed $termMonth Term month.
	 * @param mixed $entityName Entity name.
	 * @param mixed $strategyName Strategy name.
	 * @param mixed $bookName Book Name.
	 * @param mixed $odbcUser ODBC user.
	 * @param mixed $arrayR Array of filters.
	 * @return Drill down page.
	 */
function get_drilldown_phpref($phpRefPath, $clmType, $sqlStmt, $linkId, $termMonth, $entityName, $strategyName, $bookName, $odbcUser, $arrayR) {
    $php_ref = "";

    if (strpos($phpRefPath, "drill_down_measurement_report.php") != false) {
        /*   $php_ref = "$phpRefPath?__user_name__=$odbcUser&clm_type=$clmType&sql_stmt=" . $sqlStmt .
          "&link_id=" . $linkId .
          "&term_month=" . $termMonth .
          "&entity_name=" . $entityName .
          "&strategy_name=" . $strategyName .
          "&book_name=" . $bookName ; */

        if ($termMonth != "NULL")
            $termMonth = "'$termMonth'";
        $sql_stmt = "EXEC spa_drill_down_msmt_report '$clmType', $arrayR[6], $arrayR[2], '$linkId', $arrayR[7], $termMonth";
        $php_ref = "./spa_html.php?spa=" . $sql_stmt;
    }
    return $php_ref;
}

/**
	 * Get drill down PHP page.
	 * @param mixed $phpRefPath Reference path.
	 * @param mixed $clmType Cloumn type.
	 * @param mixed $sqlStmt SQL statement.
	 * @param mixed $linkId Link Id.
	 * @param mixed $termMonth Term month.
	 * @param mixed $entityName Entity name.
	 * @param mixed $strategyName Strategy name.
	 * @param mixed $bookName Book Name.
	 * @param mixed $odbcUser ODBC user.
	 * @param mixed $arrayR Array of filters.
	 * @return Drill down page.
	 */
function get_settlement_drilldown_phpref($phpRefPath, $clmType, $sqlStmt, $linkId, $termMonth, $entityName, $strategyName, $bookName, $odbcUser, $arrayR) {
    $php_ref = "";

    if ($termMonth != "NULL")
        $termMonth = "'$termMonth'";
            
    $sql_stmt = "EXEC spa_drill_down_settlement '$clmType', $arrayR[2], '$linkId', $arrayR[7], $termMonth";
    $php_ref = "./spa_html.php?spa=" . $sql_stmt;

    return $php_ref;
}

/**
	 * Get drill down PHP page.
	 * @param mixed $drillType Drill type.
	 * @param mixed $odbcUser ODBC user.
	 * @param mixed $arrayR Array of filters.
	 * @return PHP drill down page.
	 */
function get_rec_compliance_drilldown_phpref($drillType, $odbcUser, $arrayR) {
    global $session_id;
    //$drillType = 1 means rec sold drill down, 2 means REC complianc reqmts drilld down, 3 is RECS 100% TX
    $php_ref = "";
    $sp_name = "";
        
    if ($drillType == 1)
        $sp_name = "spa_create_rec_compliance_sold_report";
            
    if ($drillType == 2)
        $sp_name = "spa_create_rec_compliance_requirement_report";
            
    if ($drillType == 3)
        $sp_name = "spa_create_rec_compliance_exclusivegen_report";

    $sql_stmt = "EXEC $sp_name $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8]";

    $php_ref = "./spa_html.php?spa=" . $sql_stmt . "&__user_name__=$odbcUser";

    return $php_ref;
}

/**
	 * Get reference note page.
	 * @param mixed $odbcUser ODBC User.
	 * @param mixed $notesForObject  Object name.
	 * @param mixed $notesId Notes id.
	 * @param mixed $attachmentFileName Attachment name.
	 * @return
	 */
function get_notes_phpref($odbcUser, $notesForObject, $notesId, $attachmentFileName) {
    if ($attachmentFileName != "")
        $php_ref = "../vba_updateNotes.php?__user_name__=$odbcUser&flag=f" .
                "&notesForObject=$notesForObject" .
                "&notesSubject=&categoryValueId=-1&notesObjectId=-1&notesText=&attachmentChanged=0" .
                "&fileToAttachFrom=&notesId=$notesId&attachmentFileName=$attachmentFileName";
    else
        $php_ref = "";

    return $php_ref;
}

$fieldNames = Array();
$fieldNames = $recordsetObject->clmNames;

$html_str = "<html>";
$html_str .= $spa_html_header;
if ($writeFile != true) {
    $html_str .= "<table><tr><td>" . adiha_export_html("openToolBar") . "</td>";
    $html_str .= "<td>" . $spa_html_paging . "</td></tr></table>";
}
$html_str .= "
        <table align='left' border='1' cellpadding='2' cellspacing='0' width='100%' bgcolor='#CCFFFF'>
                <tr valign='middle' bgcolor='#FFFF00'>";

for ($i = 0; $i < sizeof($fieldNames); $i++) {
    $data = encloseTH($fieldNames[$i]);
    $html_str .= " $data ";
}

$html_str .= " </tr>";

$sub_total_str = "";
$sub_total_pre_str = "";
$noOfRows = sizeof($result) / $fields;

//if no records found then no need to total report and drill-down features.
if ($noOfRows == 0)
    $report_name = "";

/* * **************
  //redundant code .... delete it later
  for ($i = 0; $i < $noOfRows; $i++) {
  $sub_total_str = "";
  //        if($sub_total_clm > 0)
  if($sub_total_clm >= 0)
  {
  //build subtotal comparision string
  for ($m = 0; $m <= $sub_total_clm; $m++)
  {
  $sub_total_str = $sub_total_str .  $result[($i * $fields) + $m];
  }


  if ($sub_total_pre_str != "" && $sub_total_str != $sub_total_pre_str)
  {
  //print the subtotal line and initilize sub total array
  //echo "<tr  valign=\"center\" bgcolor=\"#EEEEFF\" height=10>";
  //echo "<tr  valign=\"center\" bgcolor=\"#3399FF\" height=10>";


  $html_str .= "
  <tr  valign=\"center\" bgcolor=\"#CCFFFF\" height=10>";


  for ($j = 0; $j < $fields; $j++)
  {
  if ($j > $report_total_clm_start)
  {
  //        $data = encloseTD("<B>" . "$" . number_format($clm_sub_total[$j]) . "</B>");
  $data = encloseTD("<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . "</B>");

  //echo $data;

  }
  else
  {
  $data = encloseTD("<B>" . $clm_sub_total[$j] . "</B>");
  }
  }
  $html_str .= "        $data";
  }
  $html_str .= "        </tr>";

  for ($k = $report_total_clm_start + 1; $k < $fields; $k++)
  {
  $clm_sub_total[$k] = 0.00;
  }
  $sub_total_pre_str = "";
  }
  }
 * ********* */
//####### Modified for Paging ##########
for ($i = 0; $i < $noOfRows; $i++) {
    $sub_total_str = "";
    if ($sub_total_clm >= 0) {
        //build subtotal comparision string
        for ($m = 0; $m <= $sub_total_clm; $m++) {
            $sub_total_str = $sub_total_str . $result[($i * $fields) + $m];
        }

        if ($sub_total_pre_str != "" && $sub_total_str != $sub_total_pre_str) {
	  $html_str .= " <tr  valign='center' height='10'>";

            for ($j = 0; $j < $fields; $j++) {
                if ($j > $report_total_clm_start) {
                    $data = "<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . "</B>";

                    if ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 19 && ($j == 14 || $j == 15 || $j == 16)) {
                        $last_row_index = ($i - 1) * $fields;
                        if ($j == 14) { //AOCI
                            $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "AOCI", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                        }
                        if ($j == 15) { //PNL
                            $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "PNL", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                        }
                        if ($j == 16) { //Settlement
                            $php_ref = get_settlement_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "Settlement", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                        }

                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . $data . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                    } else if ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 21 && ($j == 18 || $j == 19)) {
                        $last_row_index = ($i - 1) * $fields;
                        if ($j == 18) { //PNL
                            $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "PNL", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                        }
                        if ($j == 19) { //Settlement
                            $php_ref = get_settlement_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "Settlement", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                        }

                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . $data . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                    }
                    else
                        $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
                } else {
                    $data = encloseTD("<B>" . $clm_sub_total[$j] . "</B>", $clm_sub_col_span, $clm_tot_col_span);
                }
                $html_str .= "$data";
            }
            $html_str .= "</tr>";
            for ($k = $report_total_clm_start + 1; $k < $fields; $k++) {
                $clm_sub_total[$k] = 0.00;
            }
            $sub_total_pre_str = "";
        }
    }

    $html_str .= "<tr  valign='center' height=10>";

    for ($j = 0; $j < $fields; $j++) {

        $tmpIndex = ($i * $fields) + $j;

        if ($no_sum_report_name == "spa_Get_All_Notes" && $j == 3) {
            if ($result[$tmpIndex] != "") {
                $php_ref = get_notes_phpref($odbcUser, $result[$tmpIndex - $j + 5], $result[$tmpIndex - $j], $result[$tmpIndex - $j + 3]);
                $result[$tmpIndex] = "<A target=\"f1\" HREF=\"" . $php_ref . "\">" . "<IMG SRC=\"../adiha_pm_html/process_controls/doc.jpg\">" .
                        $result[$tmpIndex] . "</A>";
            }
        }

        //number format if report is known
        if ($report_name != "" && $j > $report_total_clm_start) {
            //drill down for measurement cash flow detail report only
            if ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 19 && ($j == 14 || $j == 15 || $j == 16)) {
                if ($j == 14) { //AOCI
                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "AOCI", $sql, $result[$tmpIndex - $j + 3], $result[$tmpIndex - $j + 7], $result[$tmpIndex - $j], $result[$tmpIndex - $j + 1], $result[$tmpIndex - $j + 2], $odbcUser, $arrayR);
                }
                if ($j == 15) { //PNL
                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "PNL", $sql, $result[$tmpIndex - $j + 3], $result[$tmpIndex - $j + 7], $result[$tmpIndex - $j], $result[$tmpIndex - $j + 1], $result[$tmpIndex - $j + 2], $odbcUser, $arrayR);
                }
                if ($j == 16) { //Settlement
                    $php_ref = get_settlement_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "Settlement", $sql, $result[$tmpIndex - $j + 3], $result[$tmpIndex - $j + 7], $result[$tmpIndex - $j], $result[$tmpIndex - $j + 1], $result[$tmpIndex - $j + 2], $odbcUser, $arrayR);
                }

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 21 && ($j == 18 || $j == 19)) {
                if ($j == 18) { //PNL
                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "PNL", $sql, $result[$tmpIndex - $j + 3], $result[$tmpIndex - $j + 7], $result[$tmpIndex - $j], $result[$tmpIndex - $j + 1], $result[$tmpIndex - $j + 2], $odbcUser, $arrayR);
                }
                if ($j == 19) { //PNL
                    $php_ref = get_settlement_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "Settlement", $sql, $result[$tmpIndex - $j + 3], $result[$tmpIndex - $j + 7], $result[$tmpIndex - $j], $result[$tmpIndex - $j + 1], $result[$tmpIndex - $j + 2], $odbcUser, $arrayR);
                }
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_drill_down_msmt_report" && $fields == 9 && $j == 6) {
                if ($j == 6) { //Dedesignation  AOCI
                    $php_ref = "./spa_html.php?spa=" .
                            "EXEC spa_Create_Dedesignation_Values_Report $arrayR[4], NULL, NULL, NULL, $arrayR[3], NULL, 'd', $arrayR[5]";
                }
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_drill_down_msmt_report" && $fields == 11 && $j == 7) {
                if ($j == 7) { //Dedesignation  PNL
                    $php_ref = "./spa_html.php?spa=" .
                            "EXEC spa_Create_Dedesignation_Values_Report $arrayR[4], NULL, NULL, NULL, $arrayR[3], NULL, 'd', $arrayR[5]";
                }
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_create_rec_compliance_sold_report" && $j == 2) {
                // print_r($arrayR);
                $php_ref = "./spa_html.php?spa= EXEC spa_create_rec_compliance_sold_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7],'" . $result[($tmpIndex - 1)] . "'&__user_name__=$odbcUser&enable_paging=true";

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_create_rec_margin_report" && $fields == 10 && $j == 3) {
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

                $php_ref = "./spa_html.php?spa= EXEC spa_create_rec_margin_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], 'd', $drill_sub, $drill_as_of_date, $drill_production_month, $drill_counterparty, $trader&__user_name__=$odbcUser&enable_paging=true";

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_create_rec_invoice_report" && $j == 2 && $fields != 6) {
                $save_invoice_id = "NULL";
                if (count($arrayR) > 12)
                    $save_invoice_id = $arrayR[12];
                $php_ref = "./spa_html.php?spa= EXEC spa_create_rec_invoice_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $save_invoice_id, 'd'&__user_name__=$odbcUser";

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            }
            else if ($report_name == "spa_create_rec_compliance_report" && ($j == 2 || $j == 3 || $j == 4 || $j == 6
                    || $j == 7 || $j == 8 || $j == 10 || $j == 11) && $arrayR[9] == 1) { //Report format 1
                $resource_name = $result[($tmpIndex - $j + 1)];
                $pieces = explode("<u>", str_replace("</u>", "<u>", $resource_name));
                $resource_name = $pieces[1];
                $php_ref = "./spa_html.php?spa=EXEC spa_create_rec_compliance_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7],$arrayR[8],$arrayR[9], $j, '" . $resource_name . "'&__user_name__=$odbcUser&enable_paging=true";
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_create_rec_compliance_report" && ($j == 3 || $j == 4 || $j == 5
                    || $j == 7 || $j == 8 || $j == 9) && $arrayR[9] == 3) { //Report format 2
                $resource_name = $result[($tmpIndex - $j + 1)];
                $pieces = explode("<u>", str_replace("</u>", "<u>", $resource_name));
                $resource_name = $pieces[1];
                $x = $j - 1;
                $php_ref = "./spa_html.php?spa=EXEC spa_create_rec_compliance_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7],$arrayR[8],$arrayR[9], $x, '" . $resource_name . "'&__user_name__=$odbcUser&enable_paging=true";
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_REC_Exposure_Report" && $j == 5) {
                $curve_name = $result[($tmpIndex - $j + 4)];
                $php_ref = "./spa_html.php?spa= EXEC spa_REC_Target_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], 's', $arrayR[7], $arrayR[8], 'n', $arrayR[9], '$curve_name', 'n',null,$arrayR[10],null,null,null,null,null,null&__user_name__=$odbcUser";

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_find_gis_recon_deals" && $fields == 6 && $j == 2) {
                $feeder_deal_id = $result[($tmpIndex - $j + 2)];
                $php_ref = "./spa_html.php?spa= EXEC spa_find_gis_recon_deals $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], '$feeder_deal_id'&__user_name__=$odbcUser";
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_find_gis_recon_deals" && $fields == 9 && $j == 3) {
                $feeder_deal_id = $result[($tmpIndex - $j + 3)];
                $php_ref = "./spa_html.php?spa= EXEC spa_find_gis_recon_deals $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], '$feeder_deal_id'&__user_name__=$odbcUser";
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_create_rec_settlement_report" && $j == 5 && $arrayR[10] != "'d'") {
                if ($fields == 6) {
                    $item = "'" . $result[($tmpIndex - $j)] . "'";
                    $prod_month = "'" . $result[($tmpIndex - $j + 1)] . "'";
                    $php_ref = "./spa_html.php?spa= EXEC spa_gen_invoice_variance_report $arrayR[9], $prod_month, $arrayR[4],$item,null,$arrayR[7] " . "&__user_name__=$odbcUser";
                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                }
                    
            } else if ($report_name == "spa_create_rec_settlement_report" && $j == 2 && $fields != 6 && $arrayR[10] != "'d'") { //&& count($arrayR) == 12)
                $feeder_deal_id = "";
                    
                if ($fields == 9)
                    $feeder_deal_id = "d";
                else
                    $feeder_deal_id = $result[($tmpIndex - $j + 1)];
                        
                $php_ref = "./spa_html.php?spa= EXEC spa_create_rec_settlement_report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], 'd', $arrayR[11], NULL, '$feeder_deal_id'&__user_name__=$odbcUser&enable_paging=true";
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            }
            else if ($report_name == "spa_get_rec_activity_report" && $j == 2 && $fields != 21) {
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

                if ($fields == 7) {
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

                if ($fields == 7 && $arrayR[7] == "'s'" && $arrayR[43] == "'t'") {
                    $drill_Counterparty = "null";
                    $drill_Technology = "'" . $result[($tmpIndex - $j + 0)] . "'";
                    $drill_DealDate = "null";
                    $drill_BuySell = "null";
                    $drill_State = "'" . $result[($tmpIndex - $j + 1)] . "'";
                    $drill_oblication = "'" . $result[($tmpIndex - $j + 3)] . "'";
                    $drill_UOM = "'" . $result[($tmpIndex - $j + 6)] . "'";
                    $drill_trader = "null";
                    $drill_Generator = "null";
                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 4)] . "'";

                    if ($drill_State != "''") {
                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                        $drill_State = "'" . $pieces2[1] . "'";
                    }
                }

                if ($fields == 8 && $arrayR[7] == "'a'") {
                    $drill_Counterparty = "null";
                    $drill_Technology = "'" . $result[($tmpIndex - $j + 1)] . "'";
                    $drill_DealDate = "null";
                    $drill_BuySell = "null";
                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                    $drill_oblication = "'" . $result[($tmpIndex - $j + 2)] . "'";
                    $drill_UOM = "'" . $result[($tmpIndex - $j + 7)] . "'";
                    $drill_trader = "null";
                    $drill_Generator = "null";
                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 0)] . "'";
                    $drill_Expiration = "'" . $result[($tmpIndex - $j + 4)] . "'";

                    if ($drill_State != "''") {
                        $pieces2 = explode("<u>", str_replace("</u>", "<u>", $drill_State));
                        $drill_State = "'" . $pieces2[1] . "'";
                    }
                }

                if ($fields == 8 && $arrayR[7] == "'v'") {
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


                if ($fields == 9 && $arrayR[7] == "'v'") {
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
                if ($fields == 9 && $arrayR[7] == "'s'") {
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

                if ($fields == 9 && $arrayR[7] == "'a'") {
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

                if ($fields == 10 && $arrayR[7] == "'c'") {
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

                if ($fields == 10 && $arrayR[7] == "'y'") {
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

                if ($fields == 9 && $arrayR[43] == "'t'" && ($arrayR[7] == "'g'" || $arrayR[7] == "'h'" || $arrayR[7] == "'y'" )) {
                    $drill_Counterparty = "null";
                    $drill_Technology = "null";
                    $drill_DealDate = "null";
                    $drill_BuySell = "null";
                    $drill_State = "'" . $result[($tmpIndex - $j + 3)] . "'";
                    $drill_oblication = "'" . $result[($tmpIndex - $j + 4)] . "'";
                    $drill_UOM = "'" . $result[($tmpIndex - $j + 8)] . "'";
                    $drill_trader = "null";
                    $drill_Generator = "'" . $result[($tmpIndex - $j + 0)] . "'";
                    $drill_Assignment = "'" . $result[($tmpIndex - $j + 2)] . "'";
                    if ($arrayR[7] == "'y'") {
                        $drill_Expiration = "null";
                    } else {
                        $drill_Expiration = "'" . $result[($tmpIndex - $j + 5)] . "'";
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

                if ($fields == 10 && $arrayR[43] != "'t'" && ($arrayR[7] == "'g'" || $arrayR[7] == "'h'" )) {
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

                if ($fields == 10 && $arrayR[43] == "'t'" && $arrayR[7] != "'c'") {
                    $drill_Counterparty = "null";
                    $drill_Technology = "'" . $result[($tmpIndex - $j + 2)] . "'";
                    $drill_DealDate = "null";
                    $drill_BuySell = "null";
                    $drill_State = "'" . $result[($tmpIndex - $j + 4)] . "'";
                    $drill_oblication = "'" . $result[($tmpIndex - $j + 5)] . "'";
                    $drill_UOM = "'" . $result[($tmpIndex - $j + 9)] . "'";
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

                if ($fields == 11 && $arrayR[43] != "'t'") {
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

                $php_ref = "./spa_html.php?spa= EXEC spa_get_rec_activity_report $arrayR[2], $arrayR[3], $arrayR[4], " .
                        "$arrayR[5], $arrayR[6], 'd', $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], " .
                        "$arrayR[12], $arrayR[13], $arrayR[14], $arrayR[15], $arrayR[16], $arrayR[17], $arrayR[18], " .
                        "$arrayR[19], $arrayR[20], $arrayR[21], $arrayR[22], $arrayR[23], $arrayR[24], $arrayR[25], " .
                        "$arrayR[26], $arrayR[27], $arrayR[28],$arrayR[29],$arrayR[30],$arrayR[31],$drill_Counterparty, $drill_Technology,$drill_DealDate, $drill_BuySell, " .
                        "$drill_State, $drill_oblication, $drill_UOM,$drill_trader,$drill_Generator,$drill_Assignment," .
                        "$drill_Expiration";

                if ($arrayR[43] == "'t'") {
                    $php_ref = $php_ref . ",'t'	";
                } else {
                    $php_ref = $php_ref . ",'n'";
                }

                $php_ref = $php_ref . "&__user_name__=$odbcUser";

                if (($fields == 13 && $arrayR[43] == "'t'") || ($fields == 14 && $arrayR[7] == "'p'")) {
                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                } else {
                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                }
            } else if ($report_name == "spa_gen_invoice_variance_report" && $j == 1 && $fields == 4 || $fields == 2 || $fields == 5) {

                if ($fields == 4) {
                    $item = "'" . $result[($tmpIndex - $j)] . "'";
                }

                $php_ref = "./spa_html.php?spa= EXEC spa_gen_invoice_variance_report $arrayR[2], $arrayR[3], $arrayR[4],$item,NULL,$arrayR[7] " .
                        "&__user_name__=$odbcUser";                

                if ($fields == 5) {
                    if ($j == 4) {
                        $php_ref = "./spa_html.php?spa= EXEC spa_gen_invoice_variance_report $arrayR[2], $arrayR[3], $arrayR[4],$item,'f',$arrayR[7] " .
                                "&__user_name__=$odbcUser";
                        $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                    } else {
                        $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                    }
                } else if ($item == "'Volume'" || $item == "'OnPeak Volume'" || $item == "'OffPeak Volume'" || $result[($tmpIndex)] == 0) {
                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                } else if (count($arrayR) == 7 && $arrayR[5] != "'f'") {
                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                } else if ($fields == 2 && $arrayR[5] != 'null') {
                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                } else {
                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                }
            } else if (($report_name == "spa_REC_Target_Report" || $report_name == "spa_REC_Target_Report_Drill")
                    && (($fields == 16 && $j == 9) || ($fields == 10 && $j == 6) || ($fields == 14 && $j == 10))) {
                if ($fields == 16 and $j == 9) {
                    $deal_id = $result[($tmpIndex - $j + 4)];
                    $pieces = explode("<u>", str_replace("</u>", "<u>", $deal_id));
                    $deal_id = $pieces[1];
                    $php_ref = "./spa_html.php?spa=EXEC spa_create_lifecycle_of_recs $arrayR[2], NULL, '$deal_id'&__user_name__=$odbcUser";
                } else if (($fields == 10 and $j == 6) || ($fields == 14 and $j == 10)) {
                    $generator = "NULL";
                    $gen_date = "NULL";
                    $year = "";
                    $assignment = "";
                    $obligation = "";
                    $type = "";
                    if ($fields == 10) {
                        $state = $result[($tmpIndex - $j + 1)];
                        $year = $result[($tmpIndex - $j + 2)];
                        $assignment = $result[($tmpIndex - $j + 3)];
                        $obligation = $result[($tmpIndex - $j + 4)];
                        $type = $result[($tmpIndex - $j + 5)];
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
                        
                    $php_ref = "./spa_html.php?spa=EXEC spa_REC_Target_Report_Drill $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[8], $arrayR[9], $included_banked, $curve_id" .
                            ", $generator_id, $convert_uom_id,$convert_assignment_type_id,$deal_id_from,$deal_id_to, $gis_cert_number,$gis_cert_number_to,$generation_state" .
                            ",'" . $result[($tmpIndex - $j + 0)] . "'" .
                            ",$generator" .
                            ",$gen_date" .
                            ",'" . $state . "'" .
                            "," . $year .
                            ",'" . $assignment . "'" .
                            ",'" . $obligation . "'" .
                            ",'" . $type . "'" .
                            "&__user_name__=$odbcUser";
                }

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_Create_Inventory_Journal_Entry_Report" &&
                    ($fields == 8 && $arrayR[7] == "'t'" && ($j == 2 || $j == 4 || $j == 6 ) )) {
                $state_value_id = "NULL";

                if (count($arrayR) > 13)
                    $state_value_id = $arrayR[13];

                $gl_number = "'" . $result[($tmpIndex - $j + 0)] . "'";
					
                if ($j == 4)
                    $php_ref = "./spa_html.php?spa= EXEC spa_Create_Inventory_Journal_Entry_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], 'g', $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, NULL, NULL,NULL, $gl_number&__user_name__=$odbcUser";
                else if ($j == 2) {
                    $php_ref = "./spa_html.php?spa= EXEC spa_Create_Inventory_Journal_Entry_Report '1990-01-01', $arrayR[2], $arrayR[4], $arrayR[5], $arrayR[6], 'g', $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, NULL, NULL,NULL, $gl_number&__user_name__=$odbcUser";
                } else {
                    $php_ref = "./spa_html.php?spa= EXEC spa_Create_Inventory_Journal_Entry_Report '1989-01-01', $arrayR[2], $arrayR[4], $arrayR[5], $arrayR[6], 'g', $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, NULL, NULL,NULL, $gl_number&__user_name__=$odbcUser";
                }

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else if ($report_name == "spa_Create_Inventory_Journal_Entry_Report" &&
                    (($fields == 9 || $fields == 7 || ($fields == 8 && $arrayR[7] != "'t'")
                    || $fields == 10 || $fields == 11 || $fields == 6
                    || ($fields == 5 && $arrayR[8] == "'j'")) && $j == 1)) {
                $as_of_date = $result[($tmpIndex - $j)];
                $state_value_id = "NULL";

                if (count($arrayR) > 13)
                    $state_value_id = $arrayR[13];

                if ($fields == 9) {
                    $deal_id = $result[($tmpIndex - $j + 2)];
                    $pieces = explode("<u>", str_replace("</u>", "<u>", $deal_id));
                    $deal_id = $pieces[1];
                    $php_ref = "./spa_html.php?spa=EXEC spa_create_lifecycle_of_recs '$as_of_date', NULL, '$deal_id'&__user_name__=$odbcUser";
                } else if ($fields == 10 && $arrayR[7] == "'g'") {
                    $production_month = $result[($tmpIndex - $j + 4)] . "-01";
                    $counterparty = "'" . $result[($tmpIndex - $j + 3)] . "'";
                    $gl_number = "'" . $result[($tmpIndex - $j + 0)] . "'";
                    $php_ref = "./spa_html.php?spa= EXEC spa_Create_Inventory_Journal_Entry_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, '$as_of_date', '$production_month',$counterparty, $gl_number&__user_name__=$odbcUser&enable_paging=true";
                } else if ($fields == 11 && $arrayR[7] == "'g'") {
                    $production_month = $result[($tmpIndex - $j + 5)] . "-01";
                    $counterparty = "'" . $result[($tmpIndex - $j + 4)] . "'";
                    $gl_number = "'" . $result[($tmpIndex - $j + 1)] . "'";
                    $as_of_date = "'" . $result[($tmpIndex - $j + 0)] . "'";
                    $php_ref = "./spa_html.php?spa= EXEC spa_Create_Inventory_Journal_Entry_Report $arrayR[2], NULL, $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, $as_of_date, '$production_month',$counterparty, $gl_number&__user_name__=$odbcUser&enable_paging=true";
                } else if ($fields == 8 ||
                        ($arrayR[8] == "'j'" && $fields == 6) ||
                        ($arrayR[8] == "'j'" && $fields == 7)) {  //echo 'in';
                    $production_month = $result[($tmpIndex - $j + 1)];
                        
                    if ($arrayR[8] == "'t'" || $fields == 7 || $fields == 8)
                        $counterparty = "'" . $result[($tmpIndex - $j + 2)] . "'";
                    else
                        $counterparty = "NULL";
                            
                    $php_ref = "./spa_html.php?spa= EXEC spa_Create_Inventory_Journal_Entry_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, '$as_of_date', '$production_month',$counterparty, NULL&__user_name__=$odbcUser&enable_paging=true";
                }
                else {
                    $php_ref = "./spa_html.php?spa= EXEC spa_Create_Inventory_Journal_Entry_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5], $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11], $arrayR[12], $state_value_id, '$as_of_date', NULL&__user_name__=$odbcUser";
                }
                if ($arrayR[7] != "'g'") {
                    $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . my_number_format($clm_total_format[$j], $result[$tmpIndex]) . "</A>", $clm_sub_col_span, $clm_tot_col_span);
                } else {
                    $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
                }
            }

            else
                $data = encloseTD(my_number_format($clm_total_format[$j], $result[$tmpIndex]), $clm_sub_col_span, $clm_tot_col_span);
        }
        else { // For LINK AND ASSESSMENT DRILL DOWN
            if ($report_name == "spa_Create_Hedges_Measurement_Report" && ($fields == 19 || $fields == 21) && $j == 3) {
                $link_id = "";
                if (trim($result[$tmpIndex - $j + 4]) == "D")
                    $link_id = $result[$tmpIndex - $j + 3] . "-D";
                else
                    $link_id = $result[$tmpIndex - $j + 3];                
                $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "LINK", $sql, $link_id, "NULL", $result[$tmpIndex - $j], $result[$tmpIndex - $j + 1], $result[$tmpIndex - $j + 2], $odbcUser, $arrayR);

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . $result[$tmpIndex] . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            }
            else if ($report_name == "spa_Create_Hedges_Measurement_Report" && ($fields == 19 || $fields == 21) && $j == 6) {

                $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "Assessment", $sql, $result[$tmpIndex - $j + 3], "NULL", $result[$tmpIndex - $j], $result[$tmpIndex - $j + 1], $result[$tmpIndex - $j + 2], $odbcUser, $arrayR);

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . $result[$tmpIndex] . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            } else {
                $data = encloseTD($result[$tmpIndex], $clm_sub_col_span, $clm_tot_col_span);
            }
        }

        //keep total
        if ($report_name != "") {
            if ($j > $report_total_clm_start) {
                if ($clm_total_format[$j] != "N")
                    $clm_total[$j] = $clm_total[$j] + $result[$tmpIndex];
                else
                    $clm_total[$j] = "";
                if ($sub_total_clm >= 0) {
                    if ($sub_total_pre_str == "" || $sub_total_str == $sub_total_pre_str) {
                        if ($clm_total_format[$j] != "N")
                            $clm_sub_total[$j] = $clm_sub_total[$j] + $result[$tmpIndex];
                        else
                            $clm_sub_total[$j] = "";
                    }
                }
            }
        }

        $html_str .= "$data";
    }
    $html_str .= "</tr>";
    $sub_total_pre_str = $sub_total_str;
}

// add the last sub_total line
if ($sub_total_clm >= 0) {
    $html_str .= "
                <tr  valign='center' height='10'>";
    for ($j = 0; $j < $fields; $j++) {
        if ($j > $report_total_clm_start) {
            $data = "<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_sub_total[$j]) . "</B>";

            //PNL and AOCI drill down for sub-total
            if ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 19 && ($j == 14 || $j == 15 || $j == 16)) {
                $last_row_index = ($noOfRows - 1) * $fields;
                if ($j == 14) { //AOCI
                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "AOCI", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                }
                    
                if ($j == 15) { //PNL
                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "PNL", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                }
                    
                if ($j == 16) { //Settlement
                    $php_ref = get_settlement_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "Settlement", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                }

                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . $data . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            
            } else if ($report_name == "spa_Create_Hedges_Measurement_Report" && $fields == 21 && ($j == 18 || $j == 19)) {
                $last_row_index = ($noOfRows - 1) * $fields;
                if ($j == 18) { //PNL
                    $php_ref = get_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "PNL", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                }
                if ($j == 19) { //Settlement
                    $php_ref = get_settlement_drilldown_phpref("$relationalPath/drill_down_measurement_report.php", "Settlement", $sql, $result[$last_row_index + 3], "NULL", $result[$last_row_index], $result[$last_row_index + 1], $result[$last_row_index + 2], $odbcUser, $arrayR);
                }
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . $data . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            }

            else
                $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
        }
        else {
            $data = encloseTD("<B>" . $clm_sub_total[$j] . "</B>", $clm_sub_col_span, $clm_tot_col_span);
        }

        $html_str .= "        $data";
    }
    $html_str .= "
                </tr>";
}


//add total line

if ($report_name != "" && $report_total_clm_start >= 0) {
    $html_str .= "
                <tr  valign='center' height='10' bgcolor='#EEEEFF'>";
    for ($j = 0; $j < $fields; $j++) {
        if ($j > $report_total_clm_start) {
            if ($clm_total_format[$j] != "X")
                $data = "<B>" . number_format_str($clm_total_format[$j]) . my_number_format($clm_total_format[$j], $clm_total[$j]) . "</B>";
            else
                $data = "<B>" . my_number_format($clm_total_format[$j], $clm_total[$j]) . "</B>";
        }
        else {
            $data = "<B>" . $clm_total[$j] . "</B>";
        }

        //first ifs are for total  needing urls
        if ($report_name == "spa_create_rec_compliance_report" && $arrayR[9] == 1) {
            $php_ref = "";
            if ($j == 4)
                $php_ref = get_rec_compliance_drilldown_phpref(1, $odbcUser, $arrayR);
            else if ($j == 6)
                $php_ref = get_rec_compliance_drilldown_phpref(2, $odbcUser, $arrayR);
            else if ($j == 7)
                $php_ref = get_rec_compliance_drilldown_phpref(3, $odbcUser, $arrayR);

            if ($j == 4 || $j == 6 || $j == 7)
                $data = encloseTD("<A target=\"_blank\" HREF=\"" . $php_ref . "\">" . $data . "</A>", $clm_sub_col_span, $clm_tot_col_span);
            else
                $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
        }
        else { //for no url required in total line
            $data = encloseTD($data, $clm_sub_col_span, $clm_tot_col_span);
        }
        $html_str .= "        $data";
    }

    $html_str .= "
                </tr>";
}

$html_str .= "
        </table>
<iframe name='f1' src='' width='0' height='0' frameborder='0'></iframe>
</body>
</table>
</html>";

//write the file
if ($writeFile == true) {
    $fileName = time();
    for ($i = 0; $i < 5; $i++) {
        $fileName .= chr(rand(65, 90));
    }
        
    $fileName .= ".htm";
    $myFile = fopen("html/$fileName", "w");
    fwrite($myFile, $html_str);
    fclose($myFile);

    $noOfField = $fields;
    echo( "<HTML><HEAD><META HTTP-EQUIV='refresh' content='1;url=\"adiha_convert_pdf.php?var_docname=$fileName&noOfField=$noOfField\"'></HEAD></HTML>" );
} else {
    echo str_replace(".php?", ".php?session_id=$session_id&", $html_str);
}
?>
<script type="text/javascript">
    var export_sp = "<?php echo $sql; ?>";

    /**
     * Open toolbar.
     * @param string phpFile PHP file. 
     */
    function openToolBar(phpFile) {
        execCall = export_sp;
        if (execCall == null){
            return
        }
        sp_url = phpFile + "?spa=" + execCall + "&" + getAppUserName();
        openHTMLWindow(sp_url);
    }
</script>