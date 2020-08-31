<?php
	//$as_of_date = '02/11/2010'  ;
	//$as_of_date = date('m/d/Y');  
	$as_of_date  = date("m/d/Y",mktime (00, 00, 00, date("m"), date("d")-1, date("Y")));
//$as_of_date  = date("m/d/Y",mktime (00, 00, 00, date("m"), date("d"), date("Y")));
	$target_url = "http://www.cmegroup.com/CmeWS/mvc/xsltTransformer.do?xlstDoc=/XSLT/da/DailySettlement.xsl&url=/da/DailySettlement/V1/DSReport/ProductCode/NG/FOI/FUT/EXCHANGE/XNYM/Underlying/NG/ProductId/444?tradeDate=".$as_of_date;	
        echo $target_url;
	
	$userAgent = 'Googlebot/2.1 (http://www.googlebot.com/bot.html)';


	//Make the cURL request to $target_url.
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
	curl_setopt($ch, CURLOPT_USERAGENT, $userAgent);
	curl_setopt($ch, CURLOPT_URL,$target_url);
	curl_setopt($ch, CURLOPT_FAILONERROR, true);
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_AUTOREFERER, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER,true);
	curl_setopt($ch, CURLOPT_TIMEOUT, 60);
	$html= curl_exec($ch);

	if (!$html) {
		echo "<br />cURL error number:" .curl_errno($ch);
		echo "<br />cURL error:" . curl_error($ch);
		exit;
	}
	
	// Parse the html into a DOMDocument
	$dom = new DOMDocument();
	@$dom->loadHTML($html);

  	// Create a DOM Document Object. 
    $dom = new domDocument; 

    // Load the html into the object. 
    @$dom->loadHTML($html); 

    // Discard white space.
	$dom->preserveWhiteSpace = false; 

    // Get the table by its tag name .
    $tables = $dom->getElementsByTagName('table'); 

	// Get all rows from the table 
    $rows = $tables->item(0)->getElementsByTagName('tr'); 

    $output = NULL;
    // Loop over the table rows. 
    foreach ($rows as $row) 
    { 
        // Get each column by tag name. 
        $cols = $row->getElementsByTagName('td'); 
        
        // Output the values.
       $output=$output . trim(@$cols->item(0)->nodeValue).'|'. 
	         		   trim(@$cols->item(1)->nodeValue).'|'.
	         		   trim(@$cols->item(2)->nodeValue).'|'.
	         		   trim(@$cols->item(3)->nodeValue).'|'.	         
			           trim(@$cols->item(4)->nodeValue).'|'.
			           trim(@$cols->item(5)->nodeValue).'|'.
			           trim(@$cols->item(6)->nodeValue).'|'.
			           trim(@$cols->item(7)->nodeValue).'|'.
			           trim(@$cols->item(8)->nodeValue);
			 	       $output .= "\n";                 
    }         
//    echo $output;
      $fHandle = fopen("E:\\FARRMS_DataSrc\\TRMTracker_LADWP\\NymexTreasuryPlattsPriceCurve\\Data\\PriceCurves\\Temp\\Files\\nymex.txt", "w");

	fputs($fHandle, $output);
	
	fclose($fHandle);
    
?>
