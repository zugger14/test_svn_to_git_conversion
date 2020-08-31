<?php
ob_start();
error_reporting(0);

require_once '../adiha_dhtmlx/grid-excel-php/lib/PHPExcel.php';
require_once '../adiha_dhtmlx/grid-excel-php/lib/PHPExcel/IOFactory.php';
include '../../../../adiha.php.scripts/components/include.file.v3.php';
    
$action = (isset($_REQUEST["action"])) ? $_REQUEST["action"] : '';
$sql = (isset($_REQUEST["sql"])) ? $_REQUEST["sql"] : '';
$filename = (isset($_REQUEST['filename'])) ? $_REQUEST['filename'] : 'grid';
$ws_title = (isset($_REQUEST['worksheet_title'])) ? $_REQUEST['worksheet_title'] : 'Sheet1';
$headers = (isset($_REQUEST['headers'])) ? $_REQUEST['headers'] : '';

$filename = ($filename == '') ? 'grid' : $filename;
$filename = $filename . '.xlsx';

if ($sql == '') {
	if ($action == '') die();
	$i = 0;
	$param = "";
	foreach ($_REQUEST as $name => $value) {
		$pos = strpos($name, 'dhx');
		if ($pos === false) {
	    	if ($name != "action" && $name != "PHPSESSID" && $name != "filename"  && $name != "worksheet_title" ) {
	    		$param .= ($i==0) ? "" : ",";

                if ($value == 'NULL') {
	    		     $param .= "@" . $name . "=NULL";
                } else {
                    $param .= "@" . $name . "='" . htmlspecialchars_decode($value) . "'";
                }
                $i++;
	    	}
	    }
	}

	$sql = "EXEC " . $action . " " . $param;
}

$recordsets = readXMLURL2($sql, true);
$key_names = (array_keys($recordsets[0]));

// Instantiate a new PHPExcel object
$obj_php_excel = new PHPExcel(); 
    
// Set the active Excel worksheet to sheet 0
$obj_php_excel->setActiveSheetIndex(0);
 
// Initialise the Excel row number
$row_header = 1;
$total_rcount = count($recordsets);
$total_col = count($key_names);
$cell_arr = getCellName($total_col);
$col_width = 20;
$header_style_array = array(
    'font'  => array(
        'bold'  => true,
        'color' => array('rgb' => '000000'),
        'size'  => 9,
        'name'  => 'Helvetica'
    ));
    
$header_array = array();
$header_array = explode(',', $headers);
    
for ($i = 0; $i < $total_rcount; $i++) {
    for($j = 0; $j < $total_col; $j++) {
        $col_idx = $i+1;   // Frist row for header info
        $excel_columns_cell = $cell_arr[$j] . $col_idx ;
        //Set column header
        if ($row_header == 1) {
            $obj_php_excel->getActiveSheet()->getColumnDimension($cell_arr[$j])->setWidth($col_width);
            $obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
			$obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_CENTER);
			$obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->applyFromArray($header_style_array);
			$obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->getAlignment()->setWrapText(true);
            $obj_php_excel->getActiveSheet()->freezePane( "A2" );
            if(sizeof($header_array) > 1) {
                $obj_php_excel->getActiveSheet()->setCellValue($excel_columns_cell, $header_array[$j]);
            } else {
            $obj_php_excel->getActiveSheet()->setCellValue($excel_columns_cell, $key_names[$j]);
        } 
        } 
        $col_idx = $i+2; //Start data from second row
        $excel_columns_cell = $cell_arr[$j] . $col_idx ;
        $excel_columns_cell = $cell_arr[$j] . $col_idx ;
        $obj_php_excel->getActiveSheet()->setCellValue($excel_columns_cell, strip_tags($recordsets[$i][$key_names[$j]]));
    }
       
  $row_header = 0;
} 

ob_end_clean();

$obj_php_excel->getActiveSheet()->setTitle($ws_title);
$obj_php_excel->setActiveSheetIndex(0);
$objWriter = PHPExcel_IOFactory::createWriter($obj_php_excel, 'Excel2007');
header('Content-Type: application/xlsx');
header("Content-Disposition: attachment;filename=".$filename);
header('Cache-Control: max-age=0');
$objWriter->save('php://output'); 
                

function getCellName($num) {
    $cell_arr = array();
    for ($i = 1; $i <= $num; $i++) {
        $col = getNameFromNumber($i);
        array_push($cell_arr, $col);
    }
    
    return $cell_arr;
}

function getNameFromNumber($num) {
    $numeric = ($num - 1) % 26;
    $letter = chr(65 + $numeric);
    $num2 = intval(($num - 1) / 26);
    //echo $letter . $numeric . '<br>';
    if ($num2 > 0) {
        return getNameFromNumber($num2) . $letter;
    } else {
        return $letter;
    }
}

?>