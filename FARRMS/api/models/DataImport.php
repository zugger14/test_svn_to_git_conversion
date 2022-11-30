<?php

class DataImport {
	
    public function import($import_data, $import_function, $import_format) {
		if ($import_format == 'undefined') {
            $import_format = 'xml';
        }
        
        $rule_definition = DataImport::getRuleDefinition($import_function);
		$rule_name = $rule_definition[0]['RuleName'];
		$table_name = $rule_definition[0]['TableName'];
		$is_active = $rule_definition[0]['IsActive'];
        $has_privilege = $rule_definition[0]['HasPrivilege'];
		
		if ($rule_name == '') {
			$response_json = array('ErrorCode' => 'Error','Message' => 'Incorrect Import Function.','Recommendation' => '');
            (new DataImportController)->response((new DataImportController)->json($response_json),401);
			return;
		}
		
		$is_error = 'y';

		if ($rule_name == '' || $rule_name == 'NULL' || $rule_name == 'undefined') {
			$is_error = 'e';
			$error_message = 'Import rule is not setup for the operation.';
		} else {
            $this->rule_name = $rule_name;
		}

		if ($table_name == '' || $table_name == 'NULL' || $table_name == 'undefined') {
			$is_error = 'e';
			$error_message = 'Import rule is not setup properly.';
		} else {
            $this->table_name = $table_name;
		}
		
		$return_array = array();
		
		if ($is_error == 'n') {			
			$return_array[0] = 'Error';
			$return_array[1] = $error_message;
            (new DataImportController)->response((new DataImportController)->json($return_array));
		} else {
			$error_array = array();
            if ($import_format == 'xml') {
                $error_array = DataImport::isValidXml($import_data);
			} else {
				$error_array[0] = DataImport::validateJSON($import_data);
				$error_array[1] = '';
			} 
			
            if ($error_array[0] == 'Error') {
				$return_array[0] = 'Error';
				$return_array[1] = 'Error in Import Data. ' . $error_array[1];
				$response_json = array('ErrorCode' => 'Error','Message' => $return_array[1],'Recommendation' => '');
                (new DataImportController)->response((new DataImportController)->json($response_json),400);
			}else{
				
				if ($is_active == 0) {
					$response_json = array('ErrorCode' => 'Error','Message' => 'The import function is inactive.','Recommendation' => '');
                    (new DataImportController)->response((new DataImportController)->json($response_json),401);
					return;
				}
				
				if ($has_privilege == 0) {
					$response_json = array('ErrorCode' => 'Error','Message' => 'Insufficient Privilege to run the import function.','Recommendation' => '');
                    (new DataImportController)->response((new DataImportController)->json($response_json),401);
					return;
				}
				
				DataImport::runImportProcess($import_data, $rule_name, $table_name, $import_format);
			}
		}

	}

	public static function importFromFile($rule_id, $file_name, $file_type) {
		$process_id_array = array();

		$process_id_array = DataImport::generateProcessID();
		$process_id = $process_id_array[0]['Recommendation'];

		$temp_table_name = 'adiha_process.dbo.temp_import_data_table_' . $process_id;
		
		$run_query = "spa_ixp_rules  @flag=''t'', @process_id=''" . $process_id . "'', @ixp_rules_id=''" . $rule_id . "'', @run_table=''" . $temp_table_name . "'', @source = ''" . $file_type . "'', @run_with_custom_enable = ''n'', @server_path=''" . $file_name . "''
                    , @source_delimiter='',''
                    , @source_with_header=''y''
					, @run_in_debug_mode=''n''
                    ";
		$job_name = "File_Import_Job_".$rule_id."_".$process_id;
		$sql = "EXEC spa_run_sp_as_job '".$job_name."','".$run_query."','".$job_name."',NULL,NULL,NULL,'i'";
        DB::query($sql);
		
		$return_array = array();
		$return_array[0] = 'Success';
		$return_array[1] = 'File Uploaded Successfully. Import Process started and will complete Shortly';
		return $return_array;

	}
	
	private function getRuleDefinition($request_function) {
		$sql = "EXEC spa_ixp_soap_import 'r', 'NULL', 'NULL', 'NULL', '$request_function'";
		return DB::query($sql);
	}
	
	private function isValidXml($xml) {
		libxml_use_internal_errors(true);
		$dom = new DomDocument('1.0', 'utf-8');
		$dom->loadXML($xml);
		$errors = libxml_get_errors($dom);

		foreach ($errors as $error) {
			$return  = '';

			switch ($error->level) {
				case LIBXML_ERR_WARNING:
					$return .= "Warning. $error->code: ";
					break;
				 case LIBXML_ERR_ERROR:
					$return .= "Error. $error->code: ";
					break;
				case LIBXML_ERR_FATAL:
					$return .= "Fatal Error. $error->code: ";
					break;
			}

			$return .= trim($error->message);

			$return_array = array();
			$return_array[0] = 'Error';
			$return_array[1] = $return;
			return $return_array;
		}

		libxml_clear_errors();
	}
	
 	private function runImportProcess($import_data, $rule_name, $table_name, $import_format) {
        if ($import_format == 'xml') {
            $process_table = DataImport::parseXml($import_data);
        } else if ($import_format == 'json') {
            $process_table = DataImport::parseJSON($import_data);    
        }
		$error_array = array();
	 	$error_array = DataImport::errorChecker($process_table, $rule_name);
		$run_in_batch = 'n';
		$success_message = $error_array[0]['ErrorCode'];

		if ($success_message == 'Success') {
			$transfer_array = array();
			$transfer_array = DataImport::transferData($process_table, $rule_name, $table_name);

			$success_message_transfer = $transfer_array[0]['ErrorCode'];
			$transfer_type = $transfer_array[0]['Module'];
			$new_process_table = $transfer_array[0]['Message'];
			$process_id_rule_combo = $transfer_array[0]['Recommendation'];

			$combo_array = explode(',', $process_id_rule_combo);

			if ($success_message_transfer == 'Success') {
				$run_rule_array = array();

				$run_rule_array = DataImport::runRule($combo_array[1], $combo_array[0], $new_process_table,$run_in_batch);
                (new DataImportController)->response((new DataImportController)->json($run_rule_array));
			} else {
				$return_array_import[0] = $success_message_transfer;
				$return_array_import[1] = 'Error in transferring data to process table.';

				$return_array_import[2] = strip_tags($return_array_import[1]);
				$return_array_import[3] = $transfer_type;
				$return_array_import[5] = 'Error';
                (new DataImportController)->response((new DataImportController)->json($error_array));
			}
		} else {
            (new DataImportController)->response((new DataImportController)->json($error_array));
		}
		
	}
	
	private function parseXml($xml) {
		$sql = "EXEC spa_import_from_xml @xml_content='$xml',@suppress_result='n',@status=NULL";
	 	$result = DB::query($sql);
		foreach ($result[0] as $value) {
			$process_table = $value;
		}
		return $process_table;
	}
    
	private function parseJSON($json) {
		$json = json_encode($json);
		$sql = "EXEC spa_parse_json @flag = 'parse', @json_string = '$json'";
	 	$result = DB::query($sql);
		foreach ($result[0] as $value) {
			$process_table = $value;
		}
		return $process_table;
	}
	
	private function errorChecker($process_table, $rule_name) {
		$sql = "EXEC spa_ixp_soap_import 's', '$process_table', '$rule_name'";
	 	$result = DB::query($sql);	
	 	return $result;
	}
	
	private function transferData($process_table, $rule_name, $table_name) {
		$sql = "EXEC spa_ixp_soap_import 't', '$process_table', '$rule_name', '$table_name'";
		$result = DB::query($sql);	
		return $result;
	}
	
	private function runRule($process_id, $rule_id, $run_table,$run_in_batch) {

		if($run_in_batch == 'n')
			$run_in_debug_mode = 'y';
		else
			$run_in_debug_mode = 'n';

		$sql = "EXEC spa_ixp_rules  @flag='t', @process_id='" . $process_id. "', @ixp_rules_id=" . $rule_id . ", @run_table='". $run_table ."', @source = '21401', @run_with_custom_enable = 'n', @run_in_debug_mode = '".$run_in_debug_mode."'";
		$result = DB::query($sql);	
		
		for ($cnt = 0; $cnt < sizeof($result); $cnt++) {
			unset($result[$cnt]['Module']);
			$result[$cnt]['Recommendation'] = $result[$cnt]['Area'];
			unset($result[$cnt]['Area']);
			unset($result[$cnt]['Status']);
		}
		
		return $result;
	}
	
	private function generateProcessID() {

		$sql = "EXEC spa_ixp_init  @flag='x'";
		$result = DB::query($sql);
		return $result;
	}
    
    public static function getImportFunctionList() {
        $sql = "EXEC spa_ixp_rules  @flag='1'";
		$result = DB::query($sql);
		return $result;
    }
    
    public static function getImportFormat($import_function) {
        $sql = "EXEC spa_ixp_rules  @flag='2', @rule_name='$import_function'";
		$result = DB::query($sql);
		return $result;
    }
	
	public static function getImportStatus($import_process) {
        $sql = "EXEC spa_ixp_rules  @flag='4', @process_id='$import_process'";
		$result = DB::query($sql);
		return $result;
    }
	
	private function validateJSON($data) {
		$status = false;
		if (!empty($data)) {
			@json_decode($data);
			$status = (json_last_error() === JSON_ERROR_NONE);
		}
		if ($status == true) {
			return 'Success';
		} else {
			return 'Error';
		}
	}
    
    public static function importCollection($import_data) {
        $import_data = json_encode($import_data);
        $sql = "EXEC spa_ixp_rules_collection @flag = 'import_excel_job', @import_data = '$import_data'";
        $result = DB::query($sql);
        return $result;
    }

	public static function Getdealimportstatus($import_process) {
        $sql = "EXEC spa_ixp_rules  @flag='7', @process_id='$import_process'";
		$result = DB::query($sql);
		return $result;
    }
}
