<?php

/**
 * @author Narendra Shrestha
 * @copyright 2011
 */
 
class CreatePositionReport extends Report {
    private $reportSPName = 'spa_create_position_report';

    public function getReportSPName() {
        return $this->reportSPName;
    }
    
    public function getReportDefinition($fields, $arrayR = null) {
        $clm_total = array();
        $clm_total_format = array();
        $report_total_clm_start = -1;
        $clm_sub_total = array();
        $sub_total_clm = -1;

        if (count($arrayR) > 34) $round_no = $arrayR[34];
        else  $round_no = "0";

        if ($arrayR[31] == "'y'" && $arrayR[6] != "'d'" && $arrayR[6] != "'r'" && strtoupper($arrayR[18]) == "NULL") {

            $clm_total = array("Total", "");
            $clm_total_format = array("N");
            $clm_sub_total = array("<i>Sub-total</i>", "");
            $sub_total_clm = -1;

            if (count($arrayR) > 33) $round_no = $arrayR[34];
            else  $round_no = "0";

            for ($x = 0; $x < $fields - 2; $x++) {
                array_push($clm_total, "0.00");
                array_push($clm_total_format, "$.X");
                array_push($clm_sub_total, "0.00");

            }
            array_push($clm_total, "");
            array_push($clm_total_format, "N");
            array_push($clm_sub_total, "");

        } else {

            if (count($arrayR) > 33) $round_no = $arrayR[34];
            else  $round_no = "0";

            if ($round_no == 'null') $round_no = 2;
            $round_no = trim($round_no,"'");
            
            if ($fields == 5) {
                $clm_total = array("Total", "", "", "", "");
                $clm_total_format = array("N", "N", "$.$round_no", "N", "N");
                $report_total_clm_start = 1;
                $clm_sub_total = array("", "", "", "", "", "", "", "");
                $sub_total_clm = -1;
            } elseif ($fields == 11) {

                $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "");
                $clm_total_format = array("N", "N", "N", "N", "N", "N", "$.$round_no", "N", "$.$round_no", "N", "N");
                $report_total_clm_start = 1;
                $clm_sub_total = array("", "", "", "", "", "", "", "", "", "", "");
                $sub_total_clm = -1;
            } elseif ($fields == 8) {

                $clm_total = array("", "", "", "", "", "", "", "");
                //$clm_total_format = array("N", "N", "N", "N", "N", "$" , "N", "N");
                $clm_total_format = array("N", "N", "N", "N", "N", "$.$round_no", "N", "N");
                $report_total_clm_start = -1;
                $clm_sub_total = array("", "", "", "", "", "", "", "");
                $sub_total_clm = -1;

            } elseif ($fields == 13) {

                $clm_total = array("Total", "", "", "", "", "", "", "", "", "", "", "", "");
                $clm_total_format = array("N", "N", "N", "N", "N", "N", "N", "-$.$round_no", "N", "-$.$round_no", "N", "N", "N");
                $report_total_clm_start = 1;
                $clm_sub_total = array("T", "", "", "", "", "", "", "", "", "", "", "", "");
                $sub_total_clm = -1;

            }
        }
        return array('clm_total' => $clm_total, 'clm_total_format' => $clm_total_format, 'report_total_clm_start' => $report_total_clm_start, 'clm_sub_total' => $clm_sub_total, 'sub_total_clm' => $sub_total_clm);
    }

    public function getReportFilterDefinition($arrayR, $callFrom = null) {
        $reportA = array();
        $reportA[0] = "Index Position Report";
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
        $reportA[15] = "As of Date From";
        $reportA[16] = "Include Option";

        return $reportA;
    }

    function getDrillDownRef($result, $arrayR, $fields, $i, $j, $tmpIndex) {
        $phpRef = null;
		if ($fields == 5 && $j == 2 || ($arrayR[31] == "'y'" && $arrayR[6] != "'r'" && $arrayR[6] != "'d'" && strtoupper($arrayR[18]) == "NULL" && $j < $fields - 1)) {
            $volumeUOM = 'NULL';
            if (($j == 2) && ($arrayR[31] != "'y'")) {
                $index = "'" . $result[($tmpIndex - $j)] . "'";
                $contract_month = "'" . $result[($tmpIndex - $j + 1)] . "'";
                $volumeUOM = "'" . $result[($tmpIndex - $j + 4)] . "'";
            }

            if ($arrayR[31] == "'y'") {
                $index = "'" . $result[($tmpIndex - $j)] . "'";
                $contract_month = "'" . $fieldNames[$j] . "'";
                $volumeUOM = "'" . $result[$tmpIndex - $j + $fields - 1] . "'";
            }
            
            if (count($arrayR) > 43) {
                $phpRef = "./spa_html.php?spa=EXEC spa_Create_Position_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5],  $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11],$arrayR[12],$arrayR[13],$arrayR[14],$arrayR[15],$arrayR[16],$arrayR[17],$index,$contract_month,$arrayR[20],$arrayR[21],$arrayR[22],$arrayR[23],$arrayR[24],$arrayR[25],$arrayR[26],$arrayR[27],$arrayR[28],$arrayR[29],$arrayR[30],$arrayR[31],$arrayR[32],$arrayR[33],$arrayR[34],$arrayR[35],$arrayR[36],$arrayR[37],$arrayR[38],$volumeUOM,$arrayR[40],$arrayR[41],$arrayR[42],$arrayR[43],$arrayR[44]";
            } elseif (count($arrayR) > 41) {
                //echo($arrayR[40]);
                $phpRef = "./spa_html.php?spa=EXEC spa_Create_Position_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5],  $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11],$arrayR[12],$arrayR[13],$arrayR[14],$arrayR[15],$arrayR[16],$arrayR[17],$index,$contract_month,$arrayR[20],$arrayR[21],$arrayR[22],$arrayR[23],$arrayR[24],$arrayR[25],$arrayR[26],$arrayR[27],$arrayR[28],$arrayR[29],$arrayR[30],$arrayR[31],$arrayR[32],$arrayR[33],$arrayR[34],$arrayR[35],$arrayR[36],$arrayR[37],$arrayR[38],$volumeUOM,$arrayR[40],$arrayR[41],$arrayR[42]";
            } elseif (count($arrayR) > 35) {
                $phpRef = "./spa_html.php?spa=EXEC spa_Create_Position_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5],  $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11],$arrayR[12],$arrayR[13],$arrayR[14],$arrayR[15],$arrayR[16],$arrayR[17],$index,$contract_month,$arrayR[20],$arrayR[21],$arrayR[22],$arrayR[23],$arrayR[24],$arrayR[25],$arrayR[26],$arrayR[27],$arrayR[28],$arrayR[29],$arrayR[30],$arrayR[31],$arrayR[32],$arrayR[33],$arrayR[34],$arrayR[35],$arrayR[36]";
            } else {
                $phpRef = "./spa_html.php?spa=EXEC spa_Create_Position_Report $arrayR[2], $arrayR[3], $arrayR[4], $arrayR[5],  $arrayR[6], $arrayR[7], $arrayR[8], $arrayR[9], $arrayR[10], $arrayR[11],$arrayR[12],$arrayR[13],$arrayR[14],$arrayR[15],$arrayR[16],$arrayR[17],$index,$contract_month,$arrayR[20],$arrayR[21],$arrayR[22],$arrayR[23],$arrayR[24],$arrayR[25],$arrayR[26],$arrayR[27],$arrayR[28],$arrayR[29],$arrayR[30],$arrayR[31],$arrayR[32]";
            }

        }
        return $phpRef;

    }

     
}
?>