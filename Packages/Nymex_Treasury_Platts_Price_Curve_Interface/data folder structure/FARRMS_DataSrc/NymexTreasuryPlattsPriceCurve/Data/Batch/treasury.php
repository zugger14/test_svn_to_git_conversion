<?php
	
	//$xml = file_get_contents("http://www.treasury.gov/offices/domestic-finance/debt-management/interest-rate/yield.xml");
	$xml = file_get_contents("http://www.treasury.gov/resource-center/data-chart-center/interest-rates/Datasets/yield.xml");
	//echo $xml;
	
	$fHandle = fopen("D:\\FARRMS_SPTFiles\\SSIS\\NymexTreasuryPlattsPriceCurve\\Data\\PriceCurves\\Temp\\Files\\Treasury.xml", "w");
	fputs($fHandle, $xml);	
	fclose($fHandle);
	
?>

