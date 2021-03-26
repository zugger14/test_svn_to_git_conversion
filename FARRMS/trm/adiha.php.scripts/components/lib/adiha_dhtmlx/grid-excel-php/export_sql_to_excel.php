<?php
/**
 * Exports SQL Query data to Excelsheet
 * 
 * @copyright Pioneer Solutions
 */

ob_start();

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Style\Alignment;

require_once '../../vendor/autoload.php';
include '../../../include.file.v3.php';
    
$action = (isset($_REQUEST["action"])) ? $_REQUEST["action"] : '';
$sql = (isset($_REQUEST["sql"])) ? $_REQUEST["sql"] : '';
$filename = (isset($_REQUEST['filename'])) ? $_REQUEST['filename'] : 'grid';
$ws_title = (isset($_REQUEST['worksheet_title'])) ? $_REQUEST['worksheet_title'] : 'Sheet1';
$headers = (isset($_REQUEST['headers'])) ? $_REQUEST['headers'] : '';
$format_code = (isset($_REQUEST['format_code'])) ? $_REQUEST['format_code'] : '';

$filename = ($filename == '') ? 'grid' : $filename;
$filename = $filename . '.xlsx';

// Build SQL Query
if ($sql == '') {
	if ($action == '') {
        die();
    }

	$i = 0;
    $param = "";
    $param_values = array();
	foreach ($_REQUEST as $name => $value) {
        $pos = strpos($name, 'dhx');
        $names_to_avoid = array('action', 'PHPSESSID', 'filename', 'worksheet_title');
		if (!$pos && !in_array($name, $names_to_avoid)) {
	    	$param .= ($i == 0) ? "" : ",";

            $param .= "@" . $name . "=?";
            array_push($param_values, ($value == 'NULL') ? NULL : htmlspecialchars_decode($value));
            $i++;
	    }
	}

	$sql = "EXEC " . $action . " " . $param;
}

$recordsets = readXMLURL2($sql, true, $param_values);
$key_names = (array_keys($recordsets[0]));

// Instantiate a new Spreadsheet object
$obj_php_excel = new Spreadsheet(); 
    
// Set the active Excel worksheet to sheet 0
$obj_php_excel->setActiveSheetIndex(0);
 
// Initialise the Excel row number
$row_header = 1;
$total_rcount = count($recordsets);
$total_col = count($key_names);
$cell_arr = getCellName($total_col);
$col_width = 20;
// Headers
$header_style_array = array(
    'font'  => array(
        'bold'  => true,
        'color' => array('rgb' => '000000'),
        'size'  => 9,
        'name'  => 'Helvetica'
    )
);
$header_array = array();
$header_array = explode(',', $headers);
$format_code_array = explode('|', $format_code);
$header_array_size = sizeof($header_array);
$format_code_array_size = sizeof($format_code_array);

// Fill Spreadsheet cells with data
for ($i = 0; $i < $total_rcount; $i++) {
    for ($j = 0; $j < $total_col; $j++) {
        // Frist row for header info
        $col_idx = $i + 1;
        $excell_column_name = $cell_arr[$j];
        $excel_columns_cell = $excell_column_name . $col_idx ;
        //Set column header
        if ($row_header == 1) {
            $obj_php_excel->getActiveSheet()->getColumnDimension($excell_column_name)->setWidth($col_width);
            $obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
			$obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->getAlignment()->setVertical(Alignment::VERTICAL_CENTER);
			$obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->applyFromArray($header_style_array);
			$obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->getAlignment()->setWrapText(true);
            $obj_php_excel->getActiveSheet()->freezePane("A2");
            if ($header_array_size > 1) {
                $obj_php_excel->getActiveSheet()->setCellValue($excel_columns_cell, $header_array[$j]);
            } else {
                $obj_php_excel->getActiveSheet()->setCellValue($excel_columns_cell, $key_names[$j]);
            }
        }
        //Start data from second row
        $col_idx = $i + 2;
        $excel_columns_cell = $excell_column_name . $col_idx ;
        $obj_php_excel->getActiveSheet()->setCellValue($excel_columns_cell, strip_tags($recordsets[$i][$key_names[$j]]));

        if ($format_code_array_size > 1) {
            if ($format_code_array[$j] && $format_code_array[$j] != '') {
                $obj_php_excel->getActiveSheet()->getStyle($excel_columns_cell)->getNumberFormat()->setFormatCode($format_code_array[$j]);
            }
        }

    }
    $row_header = 0;
} 

ob_end_clean();

// Set sheet title
$obj_php_excel->getActiveSheet()->setTitle($ws_title);
$obj_php_excel->setActiveSheetIndex(0);
// Write spreadsheet object to Xlsx file
$objWriter = IOFactory::createWriter($obj_php_excel, 'Xlsx');
header('Content-Type: application/xlsx');
header("Content-Disposition: attachment;filename=".$filename);
header('Cache-Control: max-age=0');
$objWriter->save('php://output'); 

/**
 * Get cell names
 *
 * @param   Integer  $num  Number
 *
 * @return  Array          Cell names
 */
function getCellName($num) {
    $cell_arr = array();
    for ($i = 1; $i <= $num; $i++) {
        $col = getNameFromNumber($i);
        array_push($cell_arr, $col);
    }
    
    return $cell_arr;
}

/**
 * Get column name from number
 *
 * @param   Integer  $num  Number
 *
 * @return  String         Column Name
 */
function getNameFromNumber($num) {
    $numeric = ($num - 1) % 26;
    $letter = chr(65 + $numeric);
    $num2 = intval(($num - 1) / 26);
    
    if ($num2 > 0) {
        return getNameFromNumber($num2) . $letter;
    } else {
        return $letter;
    }
}
?>