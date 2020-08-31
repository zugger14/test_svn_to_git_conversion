<?php
/**
*  @brief FileImportController File based Data Import extends REST class
*  @par Description
*  This class is used for all File based Import Operations
*  @copyright Pioneer Solutions.
*/
class FileImportController extends REST {		
	/**
	 * Import Data from File
	 *
	 * @return  JSON              Success or Failure
	 */
    public function FileImport() {
		
		global $file_import_directory;
		
		$this->checkFileName();
		
		$tmp_file = $_FILES['file_name']["tmp_name"];
		$file_name = $_FILES['file_name']["name"];
		$rule_id = $_REQUEST['rule_id'];
		$file_type = $_REQUEST['file_type'];
		
		$upload_file = $file_import_directory."/".$file_name;
		
		
		if(move_uploaded_file($tmp_file,$upload_file))
		{
				
				$return_array = DataImport::importFromFile($rule_id,$file_name,$file_type);
				$this->response($this->json($return_array));
		}
		else
		{
				$return_array = array();
				$return_array[0] = 'Error';
				$return_array[1] = 'File Upload Failed. Failed to import Data';
				$this->response($this->json($return_array));
		}
		
	 }
	
	 /**
	 * Upload Import File
	 *
	 * @return  JSON              Success or Failure
	 */
    public function FileUpload() {
        global $file_import_directory;
		
		$this->checkFileName();
		
		$tmp_file = $_FILES['file_name']["tmp_name"];
		$file_name = $_FILES['file_name']["name"];
		
		$upload_file = $file_import_directory."/".$file_name;
		
		if(move_uploaded_file($tmp_file,$upload_file))
		{
				$return_array = array();
				$return_array[0] = 'Success';
				$return_array[1] = 'File Upload successfully completed.';
				$this->response($this->json($return_array));
		}
		else
		{
				$return_array = array();
				$return_array[0] = 'Error';
				$return_array[1] = 'File Upload Failed. Failed to import Data.';
				$this->response($this->json($return_array));
		}
        
    }
	
	/**
	 * Check if uploaded file has proper key i.e. 'file_name'
	 * 
	 * @return  void | JSON		Returns json error if file key is not proper i.e. 'file_name'
	 */
	public function checkFileName() {
		if (!isset($_FILES['file_name'])) {
			$return_array['ErrorCode'] = 'Error';
			$return_array['Message'] = 'File Upload Failed. Check if file has been uploaded with key \'file_name\'';
			$this->response(json_encode($return_array), 200);
		}
	}
}
