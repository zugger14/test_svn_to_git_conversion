<?php
ob_start();
include '../../../adiha.php.scripts/components/include.file.v3.php';
ob_clean();
/*

HTML5/FLASH MODE

(MODE will detected on client side automaticaly. Working mode will passed to server as GET param "mode")

response format

if upload was good, you need to specify state=true and name - will passed in form.send() as serverName param
{state: 'true', name: 'filename'}

*/

$template_type = get_sanitized_value($_GET['template_type']);
$mode = get_sanitized_value(@$_REQUEST["mode"]);
$action = get_sanitized_value(@$_REQUEST["action"]);

if ($mode == "html5" || $mode == "flash") {
	$state = 'false';
	$filename = ($_GET['filename'] != '') ? get_sanitized_value($_GET['filename']) . '.rdl' : $_FILES["file"]["name"]; 
	
    $extension = explode('.', $_FILES["file"]["name"]);
    $extension = $extension[1];
    $filetype = $_FILES["file"]["type"];
    
	if (validate_file_extension($filetype, $extension)) {
		$state = 'true';
        $upload_sts = move_uploaded_file($_FILES["file"]["tmp_name"], $temp_path . "/" . $filename);
		
		if (!$upload_sts) {
			$state = 'false';
		}	
    
        /*****RDL Deployment************************************************************************************/
        //Directory in report server where report has to be pushed
        $rdl_deploy_path_name = $ssrs_config['REPORT_TARGET_FOLDER']."/custom_reports";
        
        if ($template_type == 4301) {
            $doc_filename = 'Invoice Report Collection.rdl'; 
        } else if ($template_type == 4305) {
            $doc_filename = 'Confirm Replacement Report Collection.rdl';
        } else if ($template_type == 4306) {
            $doc_filename = 'Trade Ticket Collection.rdl';
        } else {
            $doc_filename = $filename;
        }
            
         //print_r($doc_filename);
        $doc_name = explode('.',$doc_filename);
        $doc_type = array_pop($doc_name);
        $doc_name = implode('.',$doc_name);
        
        $new_rdl = $ssrs_config['RDL_DIR_LOCAL'] .'\\'. $doc_filename;
            
        //overwrite datasource
        $file_handler = fopen($new_rdl,'r');
        $content = fread($file_handler,filesize($new_rdl));
        fclose($file_handler);
        $native_datasource = "<DataSources>
                                <DataSource Name=\"".$ssrs_config['DATA_SOURCE']."\">
                                    <DataSourceReference>".$database_name."</DataSourceReference>
                                    <rd:DataSourceID></rd:DataSourceID>
                                </DataSource>
                            </DataSources>";
        //Replace Main Tag First
        $pattern = '/<DataSources[^>]*>.*?<\/DataSources>/s';
        $content = preg_replace($pattern, $native_datasource, $content);
        //Now the Individual <Query> block must have new Datasource Name
        $pattern = '/<DataSourceName[^>]*>.*?<\/DataSourceName>/s';
        $native_datasource_name = "<DataSourceName>".$ssrs_config['DATA_SOURCE']."</DataSourceName>";
        $content = preg_replace($pattern, $native_datasource_name, $content);
        //Now save file
        $file_handler = fopen($new_rdl,'w');
        $write_status = fwrite($file_handler, $content);
        fclose($file_handler);
        //overwrite datasource END
		
		$rdl_deployer_job = "EXEC [spa_rfx_deploy_rdl_as_job] 'RDL Deployer', 'farrms_admin', 'TSQL', NULL, '" . $doc_name . "', '/custom_reports'" ;
		
        $return_value = readXMLURL($rdl_deployer_job);
        
        /************************************************************************/
    }
    ob_clean();	
	header("Content-Type: text/json");
	print_r("{state: " . $state . ", rdl_return: '', name:'" . str_replace("'", "\\'", $filename) . "'}");
}

/*

HTML4 MODE

response format:

to cancel uploading
{state: 'cancelled'}

if upload was good, you need to specify state=true, name - will passed in form.send() as serverName param, size - filesize to update in list
{state: 'true', name: 'filename', size: 1234}

*/

if ($mode == "html4") {
	header("Content-Type: text/html");
    
	if ($action == "cancel") {
		print_r("{state:'cancelled'}");
	} else {
		$state = 'false';
        $filename = ($_GET['filename'] != '') ? get_sanitized_value($_GET['filename']) . '.rdl' : $_FILES["file"]["name"]; 
        $extension = explode('.', $_FILES["file"]["name"]);
        $extension = $extension[1];
        $filetype = $_FILES["file"]["type"];
        
    	if (validate_file_extension($filetype, $extension)) {
    		$state = 'true';
            move_uploaded_file($_FILES["file"]["tmp_name"], $temp_path . "/" . $filename);
    	}
		print_r("{state: " . $state . ", name:'" . str_replace("'", "\\'", $filename) . "', size:" . $_FILES["file"]["size"] . "}");
	}
}

function validate_file_extension($filetype, $extension) {
    
    if ($extension == 'rdl') {
		return true;
	} else {
	   return false;
	}
}
