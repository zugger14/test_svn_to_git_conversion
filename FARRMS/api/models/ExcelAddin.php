<?php

class ExcelAddin {
    public static function QueryJson($xml_parameter) {
        global $app_user_name;
        $xml_parameter = $xml_parameter;
        $query = "EXEC spa_excel_addin @xml_parameter ='$xml_parameter', @runtime_user = '$app_user_name'";
		//var_dump(DB::query($query));die();
        return DB::query($query);
    }
	
	public static function ReportXml($xml_parameter) {
        global $app_user_name;
        $xml_parameter = $xml_parameter;
		// echo $xml_parameter;
		// die();
        $query = "EXEC spa_excel_addin @xml_parameter ='$xml_parameter', @runtime_user = '$app_user_name'";
		// var_dump(DB::query($query));die();
        return DB::query($query);
    }
}
