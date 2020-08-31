<?php
/**
 * Generic logic to call the import process store procedures
 * @copyright Pioneer Solutions
 */

ob_start();
# Used for generic import.
# Create a process table by reading first 3 rows of the files.
# For header less file - [column (counter)] is used as the table columns
# For file with header - table is created using delimited value of first row of file.


require 'components/include.file.v3.php';
//include 'adiha.jobs.ini.php';
//$file_path = realpath('.//dev//attach_docs//');
$file_path = $temp_path;
//$file_path = $temp_path . '\\';
//$file_name = trim(strtolower($_FILES["file"]["name"]));
$file_name = $_POST['file_name'];
$m_file_name = $_POST['m_file_name'];
$m_file_name = str_replace("xlsx","csv",$m_file_name);
$m_file_name = str_replace("xls","csv",$m_file_name);
$process_id = $_POST['process_id'];
$delim = $_POST['delim'];
$alias = isset($_POST['alias']) ? $_POST['alias'] : '';
$is_header_less = isset($_POST['is_header_less']) ? $_POST['is_header_less'] : 'n';
$no_of_columns = isset($_POST['no_of_columns']) ? $_POST['no_of_columns'] : '0';
$call_from = isset($_POST['call_from']) ? $_POST['call_from'] : '';
$custom_enabled = isset($_POST['custom_enabled']) ? $_POST['custom_enabled'] : 'n';
$rules_id = isset($_POST['rules_id']) ? $_POST['rules_id'] : '';
$server_path = $BATCH_FILE_EXPORT_PATH;
$excel_sheet = isset($_POST['excel_sheet']) ? $_POST['excel_sheet'] : '';
$enable_ftp = isset($_POST['enable_ftp']) ? $_POST['enable_ftp'] : '0';

if (isset($_POST['xml_parameters']) && $_POST['xml_parameters'] != '') {
    $xml_parameters = $_POST['xml_parameters'];
    $xml_parameters = urldecode($xml_parameters);
}

$upload_process = 'y';

if ($call_from == 'run') {
    $connection_string = isset($_POST['connection_string']) ? $_POST['connection_string'] : '';
    $relation_source = isset($_POST['relation_source']) ? $_POST['relation_source'] : '';
    $upload_process = (($relation_source == 21401 || $relation_source == 21403 || $relation_source == 21404 || $relation_source == 21407)) ? 'n' : 'y';
}

if ($upload_process == 'y') {
    $full_file_name = $file_path . '/' . $file_name;
    echo '</br>';
    $path_parts = pathinfo($full_file_name);
    echo '</br>';
    $file_name_without_ext = $path_parts['filename'];
    echo '</br>';
    $full_file_name_without_ext = $file_path . '\\' . $file_name_without_ext;
    echo '</br>';
    $extension = $path_parts['extension'];
    echo '</br>';
    $server_file_path = $server_path . '\\' . $file_name;
    echo '</br>';

    if ($alias != '')
        $temp_table_name = 'adiha_process.dbo.temp_import_data_table_' . $alias . '_' . $process_id;
    else
        $temp_table_name = 'adiha_process.dbo.temp_import_data_table_' . $process_id;
    
    $source_with_header = ($is_header_less == 'y') ? 'n' : 'y';        
    if ($extension !='lse' && $call_from!='run') {        
        $run_query = "EXEC spa_ixp_rules  @flag='c', @process_id='" . $process_id . "', @ixp_rules_id='" . $rules_id . "', @run_table='" . $temp_table_name . "', @source = '" . $relation_source . "', @run_with_custom_enable = '" . $custom_enabled . "', @server_path='" . $file_name . "', @source_delimiter='" . $delim . "', @source_with_header='" . $source_with_header . "', @excel_sheet_name='" . $excel_sheet . "'";

        $result = readXMLURL2($run_query);
                           
    }  else if ($extension =='lse'){
        $run_query = "EXEC spa_ixp_rules  @flag='w', @process_id='" . $process_id . "', @ixp_rules_id='" . $rules_id . "', @run_table='" . $temp_table_name . "', @source = '" . $relation_source . "', @server_path='" . $file_name . "', @excel_sheet_name='" . $excel_sheet . "'";
        
        $result = readXMLURL2($run_query);
    } 

    /*  it seems that other ext like csv,prn,txt may used by flat file extension source data is populated to process table before hand. But this is handled in spa_ixp_rules flag t.  
    else if ($extension != 'xml') {
            $sql_query = "EXEC spa_ixp_insert_data  @file_path='" . $server_path . "', @temp_process_table='" . $temp_table_name . "', @file_name='" . $m_file_name . "', @delimiter='" . $delim . "', @header='" . $is_header_less . "'";
            //echo_text($sql_query);
            $result = readXMLURL2($sql_query);          
        }
    */
    
    if ($call_from == 'run') {
        $file_name = str_replace("'", "''''", htmlspecialchars_decode($file_name, ENT_QUOTES)); //Escaped single quote
        $run_query = "spa_ixp_rules  @flag=''t'', @process_id=''" . $process_id . "'', @ixp_rules_id=''" . $rules_id . "'', @run_table=''" . $temp_table_name . "'', @source = ''" . $relation_source . "'', @run_with_custom_enable = ''" . $custom_enabled . "'', @server_path=''" . $file_name . "'', @source_delimiter=''" . $delim . "'' , @source_with_header=''" . $source_with_header . "'', @enable_ftp=" . $enable_ftp;
              
    }

} else {
    $run_query = "spa_ixp_rules  @flag=''t'', @process_id=''" . $process_id . "'', @ixp_rules_id=" . $rules_id . ", @run_table=''" . $connection_string . "'', @source = ''" . $relation_source . "'', @run_with_custom_enable = ''" . $custom_enabled . "'', @parameter_xml=''" . $xml_parameters . "'', @enable_ftp=" . $enable_ftp;
}

$job_name = 'Import_Excel_Job_' . $rules_id . '_' . $process_id . '_' . uniqid();
$run_query1 = "EXEC spa_run_sp_as_job '".$job_name."','".$run_query."','".$job_name."',NULL,NULL,NULL,'i'";

$rows = array();
$rows = readXMLURL2($run_query1);
$data['message'] = $rows[0]['message'];

ob_end_clean();
$data['status'] = "Success";
echo json_encode($data);

function build_error($errmsg) {
    $return_xml = "<?xml version = '1.0'?>*";
    $return_xml .= "  <PSRecordSet records = '1' columns = '2'>*";
    $return_xml .= "    <record0>*";
    $return_xml .= "   <clm0>";
    $return_xml .= "   Error";
    $return_xml .= "   </clm0>*";
    $return_xml .= "   <clm1>";
    $return_xml .= "   $errmsg";
    $return_xml .= "   </clm1>*";
    $return_xml .= "    </record0>*";
    $return_xml .= "  </PSRecordSet>*";
    return $return_xml;
}

function show_error($msg) {
    ob_get_clean();
    $data['status'] = "Error";
    $data['json'] = str_replace("'", "\'", $msg);
    echo json_encode($data);
    ?>
<?php } ?>