<?php
/**
*  @brief Report Report Information
*  @par Description
*  This class is used to get Report Information
*  @copyright Pioneer Solutions.
*/
class Report {
    /**
     * Get List of All available Mobile Enabled Reports
     *
     * @return  Array  List of Reports
     */
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_view_report @flag='m', @report_type = 1, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    /**
     * Get Report Info based on Report ID
     *
     * @param   String  $report_id  Report ID
     *
     * @return  Array                Report Detail Information
     */
    public static function findOne($report_id) {
        global $app_user_name;
        $report_id = (int)$report_id;
        $query = "EXEC spa_view_report @flag='m', @report_id= $report_id,  @report_type = 1, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * Get Report Filter Parameters
     *
     * @param   Integer  $report_param_id  Paramset ID
     *
     * @return  Array                    Filter List
     */
    public static function reportfilter($report_param_id) {
        global $app_user_name;
        $report_param_id = (int)$report_param_id;
        $query = "EXEC spa_view_report  @flag='k', @report_param_id='$report_param_id', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }  
    
    /**
     *  Get Report Filter Parameters
     *
     * @param   Integer  $report_param_id  Paramset ID
     * @param   Integer  $report_id        Report ID
     *
     * @return  Array                    Filter List
     */
    public static function getApplyFilter($report_param_id, $report_id) {
        global $app_user_name;
        $report_param_id = (int)$report_param_id;
        // $report_id = (int)$report_id;
        $query = "EXEC spa_view_report  @flag='f', @report_param_id='$report_param_id', @report_id = '$report_id', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    /**
     * Get Book Structure
     *
     * @return  Array List of Book Structure
     */
    public static function getBookStructure() {
        global $app_user_name;
        $query = "EXEC spa_getPortfolioHierarchy 10101200, 'm', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    /**
     * Get Excel Snapshot Info
     *
     * @param   Integer  $excel_sheet_id  Sheet ID
     * @param   String  $refresh_type    Synchronize or Refresh
     *
     * @return  Array                   Snapshot Detail
     */
    public static function getExcelSnapshot($excel_sheet_id, $refresh_type) {
        global $app_user_name;
        $query = "EXEC spa_view_report @flag = '$refresh_type', @report_id = " . $excel_sheet_id . ", @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    /**
     * get Report View Port
     *
     * @param   String  $report_name   Report Name
     * @param   String  $parameters    Report Parameters
     * @param   XML  $device_info   Device Information
     * @param   String  $sorting       Sorting order
     * @param   String  $toggle_item   Items to be toggled
     * @param   String  $execution_id  Execution ID
     * @param   String  $export_type   Export Type E.g HTML
     *
     * @return  Array                 Report View
     */
    public static function getViewReport($report_name, $parameters, $device_info, $sorting, $toggle_item, $execution_id, $export_type) {
        global $app_user_name;
        $query = "EXEC spa_ssrs_html @report_name = '$report_name', @parameters = '$parameters', @device_info = '$device_info', @sorting = '$sorting', @toggle_item = '$toggle_item', @execution_id = '$execution_id', @export_type = '$export_type'";
        return DB::query($query);
    }   

    /**
     * Get Power BI Report and Run
     *
     * @param   Integer  $power_bi_report_id     Power BI Report ID
     * @param   String  $report_filter          Report Filters
     * @param   String  $sec_filter_process_id  Process ID
     *
     * @return  Array                          Run and Return Success with Information
     */
    public static function getPowerBIReport($power_bi_report_id, $report_filter, $sec_filter_process_id) {
        global $app_user_name;
        $query = "EXEC spa_power_bi_report @flag = 'r', @report_filter = '" . $report_filter . "', @power_bi_report_id='" . $power_bi_report_id . "', @sec_filter_process_id='" . $sec_filter_process_id . "', @runtime_user='". $app_user_name ."'";
        return DB::query($query);
    }
    
    /**
     * Get List of Reports
     *
     * @return  Array  List of Reports
     */
    public static function getReportList() {
        $query = "EXEC spa_view_report @flag = 'g'";
        return DB::query($query);
    }
    
    /**
     *  Get Report Parameters
     *
     * @param   String  $report_name  Report Name
     * @param   String  $report_hash  Report Hash
     *
     * @return  Array                Parameters List
     */
    public static function getReportParameter($report_name, $report_hash) {
        $privilege_result = Report::getReportPrivilege($report_hash);
        $has_privilege = $privilege_result[0]['PrivilegeStatus'];
        
        if ($has_privilege == 0) {
            return 'not_privilege';
		} else if ($has_privilege == 2) {
            return 'invalid_hash';
        }
        
        $query = "EXEC spa_view_report @flag = 'l', @report_name = '" . $report_name . "', @paramset_hash = '" . $report_hash . "'";
        return DB::query($query);
    }
    
    /**
     * Get Report Data using API Service
     *
     * @param   String  $report_hash        Report Hash
     * @param   String  $report_parameters  Report Parameters
     *
     * @return  Array                      Report Data
     */
    public function getReportData($report_hash, $report_parameters) {
        $privilege_result = Report::getReportPrivilege($report_hash);
        $has_privilege = $privilege_result[0]['PrivilegeStatus'];
        
		if ($has_privilege == 0) {
            return 'not_privilege';
		} else if ($has_privilege == 2) {
            return 'invalid_hash';
        }
        
        $report_parameters = json_encode($report_parameters);
		$query = "EXEC spa_view_report @flag = 'q', @paramset_hash = '" . $report_hash . "', @view_report_filter_xml='" . $report_parameters . "'";
		return DB::query($query);
    }
    
    /**
     * Check Report Privilege
     *
     * @param   String  $report_hash  Report Hash
     *
     * @return  Array                Success or Failure
     */
    public static function getReportPrivilege($report_hash) {
        $query = "EXEC spa_view_report @flag = 'w', @paramset_hash = '" . $report_hash . "'";
		return DB::query($query);
    }
}
