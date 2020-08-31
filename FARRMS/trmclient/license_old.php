<?
if ($enable_session==false){
	//-------------LICENSE START--------------
	//************ LICENSE when Disable **********
	$license_session_disable="NULL"; 
	$license_not_to_static_value_id_disable="NULL"; 
}else{
	//************SESSION LICENSE
	//$_SESSION["license_func_id"]= "NULL";
	$license_func_id="NULL";
	//This session 'license_not_to_static_value_id' variable contain Value_id which will be NOT be visible eg '153,150,651'
	//$_SESSION["license_not_to_static_value_id"]="NULL";
	$license_not_to_static_value_id="NULL";
	//-------------LICENSE END--------------
}
$db_pwd="Admin2929";
$cloud_db_user = 'farrms_admin';
?>