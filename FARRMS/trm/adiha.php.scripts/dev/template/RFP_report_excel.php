<? 

    include "../../components/include.file.ini.php";
    include "../../adiha.ini.php";
    include "../../PHP_CLASS_EXTENSIONS/PS.Recordset.1.0.php";

	include "../../components/lib/PHPExcel/PHPExcel.php";
	
	
	
	
	$recordsetObject = new PSRecordSet(false);
	$recordsetObject->connectToDatabase($odbc_DB, $odbcUser, $odbcPass);
	$invoice_number='NULL';

	$counterparty_id = $_GET['counterparty_id'];
	$prod_month = $_GET['prod_month'];
	$payment_mode = $_GET['payment_modes'];
	$counterparty_name = $_GET['counterparty_name'];
	$approver = $_GET['approver'];
	$as_of_date = $_GET['as_of_date'];
	$payment_ins_header_id = $_GET['payment_ins_header_id'];
	$contract_id = $_GET['contract_id'];
	$invoice_type = $_GET['invoice_type'];
	$addenda_line = $_GET['addenda_line'];
	
	$img_check_name_dir = "upload/";

	$logo = 'image/xcel_invoice_logo.jpg';
	$checkd_a="image/check_box_unchecked.jpg";
	$checkd_w="image/check_box_unchecked.jpg";
	$checkd_c="image/check_box_unchecked.jpg";
	$checkd_m="image/check_box_unchecked.jpg";
	$checked="image/check_box_checked.jpg";
	$unchecked="image/check_box_unchecked.jpg";
	$checked_al_n = "image/check_box_unchecked.jpg";
	$checked_al_y = "image/check_box_unchecked.jpg";
	$bu="";
	$objacct="";	


	if ($payment_mode=="a"){
		$checkd_a="image/check_box_checked.jpg";	
	}else if($payment_mode=="w"){
		$checkd_w="image/check_box_checked.jpg";
	}else if($payment_mode=="c"){
		$checkd_c="image/check_box_checked.jpg";
	}else if($payment_mode=="m"){
		$checkd_m="image/check_box_checked.jpg";
	}

	if ($addenda_line == 'y'){
		$checked_al_y="image/check_box_checked.jpg";
	}else{
		$checked_al_n="image/check_box_checked.jpg";
	}	
	$sql_invoice =  "exec spa_get_invoice_info $invoice_number, $counterparty_id , '$prod_month','$approver','$as_of_date','$contract_id','$invoice_type'";

	   $invoice_number = "";
       $bill_to = "";
       $remit_to = "";
       $term ="";
       $invoice_date = "";	
       $invoice_due_date = "";
	   $statement_type="";
	   $sub_id=""; 					 
	   $settle_account="";
	   $counterparty="";
	   $request_date="";
	   $payment_info="";
	   $title="";	
	   $contact_address = "";
       $contact_address2 = "";
	   $contact_fax_email = "";
	   $bank_name="";
       $wire_aba="";
	   $ach_aba="";
	   $account_no="";
       $address1="";
	   $address2="";
	   $business_unit="";
	   $phone="";
	   $contract_specialist="";
	   $contract_Title="";
	   $contract_empid="";
	   $contract_phone="";	
	   $emp_id="";
	   $counterparty_code = "";
	   $company_code = "";	   
	   $email = "";
	   $contract_email = "";
	   $external_reference_number = "";

	 $odbc_connection= $recordsetObject->getConnection();
	  $recrodsetResource = odbc_exec($odbc_connection, $sql_invoice);
	  while (odbc_fetch_row($recrodsetResource))
	  {
			 $invoice_number = odbc_result($recrodsetResource, 1);
			 $contact_address = odbc_result($recrodsetResource, 32);
			 $contact_address2 = odbc_result($recrodsetResource, 33);
			 $contact_fax_email = odbc_result($recrodsetResource, 28);
			 //die($contact_address);
			 /*
			 if ($payment_mode=="c"){
				 $bank_name="";
				 $wire_aba="";
				 $ach_aba="";
				 $account_no="";
				 $address1="";
				 $address2="";	
			 
			 }else{
				 */
			 $bank_name=odbc_result($recrodsetResource, 10);
			 $wire_aba=odbc_result($recrodsetResource, 12);
			 $ach_aba=odbc_result($recrodsetResource, 11);
			 $account_no=odbc_result($recrodsetResource,13);
			 $address1=odbc_result($recrodsetResource, 14);
			 $address2=odbc_result($recrodsetResource, 15);							 		 
			//}	 
			 $term = odbc_result($recrodsetResource, 11);
			 $invoice_date = odbc_result($recrodsetResource,2);
			 $invoice_due_date = odbc_result($recrodsetResource, 3);
			 $statement_type = odbc_result($recrodsetResource, 7);
			 $sub_id = odbc_result($recrodsetResource, 8);
			 $settle_account = odbc_result($recrodsetResource, 59);
			 $request_date=odbc_result($recrodsetResource, 4);
			 $counterparty=odbc_result($recrodsetResource,9 );
			 $external_reference_number=odbc_result($recrodsetResource,58);
			 $title=odbc_result($recrodsetResource,60);
			 $emp_id=odbc_result($recrodsetResource,61);
			 $business_unit=odbc_result($recrodsetResource,62);
			 $phone=odbc_result($recrodsetResource,63);
			 $contract_specialist=odbc_result($recrodsetResource,64);
			 $contract_Title=odbc_result($recrodsetResource,65);
			 $contract_empid=odbc_result($recrodsetResource,66);
			 $contract_phone=odbc_result($recrodsetResource,67);
			 //$prod_month = odbc_result($recrodsetResource, 5);
			 $counterparty_code = odbc_result($recrodsetResource, 110);
			 $company_code = odbc_result($recrodsetResource, 88);
			 $email = odbc_result($recrodsetResource, 111);
			 $contract_email = odbc_result($recrodsetResource, 112); 
			 $contact_city = odbc_result($recrodsetResource, 22);
			 $contact_state = odbc_result($recrodsetResource, 23);
			 $contact_zip = odbc_result($recrodsetResource, 24);

	 }
					 
	if ($payment_mode=="a"){
		$aba_number=$ach_aba;
	}else if($payment_mode=="w"){
		$aba_number=$wire_aba;
	}else{
		$aba_number="";
	}				 

	$aba_number=$wire_aba;
	function my_number_format($format_str, $value)
	{
		if ($format_str != "N" && $format_str != "X")
			if ($format_str == "L" && number_format($value) == 0)
				return "";
			else
			{
				$decimals = 0;
				$pieces = explode(".", $format_str);
				if (count( $pieces) > 1)
					$decimals =  $pieces[1];
				return number_format($value, $decimals);
			}

		else
				return $value;
	}


	odbc_free_result($recrodsetResource);
	
	ob_clean();
	
	$objPHPExcel = new PHPExcel();
	//$objPHPExcel = PHPExcel_IOFactory::createReader('Excel5');
	//$objPHPExcel = $excel2->load('RFP_template.xls'); // Empty Sheet

	$FontHeaderArray = array(
	'font'  => array(
		'bold'  => true,
		'size'  => 12,
		'name'  => 'Calibri'
		)
	);
	
	$FontstyleArray = array(
	'font'  => array(
		'bold'  => true,
		'size'  => 11,
		'name'  => 'Calibri'
		)
	);
	
	// Set properties
	$objPHPExcel->getProperties()->setCreator("RecTracker");
	$objPHPExcel->getProperties()->setLastModifiedBy("RecTracker");
	$objPHPExcel->getProperties()->setTitle("RFP Document");
	$objPHPExcel->getProperties()->setSubject("RFP Document");
	$objPHPExcel->getProperties()->setDescription("RFP Document.");
	$objPHPExcel->setActiveSheetIndex(0);
	$objPHPExcel->getActiveSheet()->getColumnDimension('A')->setWidth(12);
	$objPHPExcel->getActiveSheet()->getColumnDimension('B')->setWidth(12);
	$objPHPExcel->getActiveSheet()->getColumnDimension('C')->setWidth(12);
	$objPHPExcel->getActiveSheet()->getColumnDimension('D')->setWidth(12);
	$objPHPExcel->getActiveSheet()->getColumnDimension('I')->setWidth(12);
	$objPHPExcel->getActiveSheet()->getColumnDimension('J')->setWidth(12);
	$objPHPExcel->getActiveSheet()->getColumnDimension('K')->setWidth(12);
	$objPHPExcel->getActiveSheet()->getRowDimension(8)->setRowHeight(-1);
	$objPHPExcel->getActiveSheet()->getPageSetup()->setPrintArea('A1:N57');
	$objPHPExcel->getActiveSheet()->getPageSetup()->setFitToWidth(1);   
	
	$objPHPExcel->getActiveSheet()->mergeCells('A1:G1');
	$objPHPExcel->getActiveSheet()->getCell('A1')->setValue('REQUEST FOR CHECK/FUNDS TRANSFER PAYMENT');
	$objPHPExcel->getActiveSheet()->getStyle('A1')->applyFromArray($FontHeaderArray);
	$objPHPExcel->getActiveSheet()->getStyle('A2:N47')->applyFromArray($FontstyleArray);

	$objPHPExcel->getActiveSheet()->setTitle('RFP Document');
	$gdImage = imagecreatefromjpeg($logo);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setName('Logo');
	$objDrawing->setDescription('Logo');
	$objDrawing->setImageResource($gdImage);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('M2');
	$objDrawing->setOffsetX(5);
	$objDrawing->setOffsetY(5);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	
	$objPHPExcel->getActiveSheet()->getStyle('A3')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
	$gdImage1 = imagecreatefromjpeg($checkd_a);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setImageResource($gdImage1);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('A3');	
	$objDrawing->setOffsetX(5);
	$objDrawing->setOffsetY(5);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	$objPHPExcel->getActiveSheet()->getCell('A3')->setValue('ACH (D)');
	

	
	$gdImage1 = imagecreatefromjpeg($checkd_w);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setImageResource($gdImage1);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('B3');	
	$objDrawing->setOffsetX(5);
	$objDrawing->setOffsetY(5);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	$objPHPExcel->getActiveSheet()->getCell('B3')->setValue('Wire (W)');
	$objPHPExcel->getActiveSheet()->getStyle('B3')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
	
	$gdImage1 = imagecreatefromjpeg($checkd_c);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setImageResource($gdImage1);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('C3');	
	$objDrawing->setOffsetX(5);
	$objDrawing->setOffsetY(5);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	$objPHPExcel->getActiveSheet()->getCell('C3')->setValue('CHECK (C)');
	$objPHPExcel->getActiveSheet()->getStyle('C3')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
	
	$gdImage1 = imagecreatefromjpeg($checkd_m);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setImageResource($gdImage1);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('D3');	
	$objDrawing->setOffsetX(5);
	$objDrawing->setOffsetY(5);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	$objPHPExcel->getActiveSheet()->getCell('D3')->setValue('CTX (T)');
	$objPHPExcel->getActiveSheet()->getStyle('D3')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
	
	$objPHPExcel->getActiveSheet()->getCell('A5')->setValue('Reminder: The Non-PO form should not be used to purchase materials and/or services. Please see Procurement Matrix for details.');
	

		
	$styleArray = array(
      'borders' => array(
          'allborders' => array(
              'style' => PHPExcel_Style_Border::BORDER_THIN
          )
      ),
	  'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_LEFT,
			'wrap'       => true
        )
	);
	
	$objPHPExcel->getActiveSheet()->getRowDimension(7)->setRowHeight(30);
	$objPHPExcel->getActiveSheet()->getRowDimension(8)->setRowHeight(30);
	$objPHPExcel->getActiveSheet()->getRowDimension(9)->setRowHeight(30);
	$objPHPExcel->getActiveSheet()->getRowDimension(10)->setRowHeight(30);
	$objPHPExcel->getActiveSheet()->getRowDimension(11)->setRowHeight(30);
	$objPHPExcel->getActiveSheet()->mergeCells('A7:B7');
	$objPHPExcel->getActiveSheet()->getCell('A7')->setValue('Date of Request:');
	$objPHPExcel->getActiveSheet()->mergeCells('C7:E7');
	$objPHPExcel->getActiveSheet()->getCell('C7')->setValue($request_date);
	$objPHPExcel->getActiveSheet()->mergeCells('F7:G7');
	$objPHPExcel->getActiveSheet()->getCell('F7')->setValue('Vendor ID:');
	$objPHPExcel->getActiveSheet()->mergeCells('H7:I7');
	$objPHPExcel->getActiveSheet()->getCell('H7')->setValue($external_reference_number);
	$objPHPExcel->getActiveSheet()->mergeCells('J7:K7');
	$objPHPExcel->getActiveSheet()->getCell('J7')->setValue('Facility/Plant Number:');
	$objPHPExcel->getActiveSheet()->mergeCells('L7:N7');
	$objPHPExcel->getActiveSheet()->getCell('L7')->setValue('');
	
	$objPHPExcel->getActiveSheet()->mergeCells('A8:B8');
	$objPHPExcel->getActiveSheet()->getCell('A8')->setValue('Invoice Date:');
	$objPHPExcel->getActiveSheet()->mergeCells('C8:E8');
	$objPHPExcel->getActiveSheet()->getCell('C8')->setValue($invoice_date);
	$objPHPExcel->getActiveSheet()->mergeCells('F8:G8');
	$objPHPExcel->getActiveSheet()->getCell('F8')->setValue('Scheduled Pymt Date:');
	$objPHPExcel->getActiveSheet()->mergeCells('H8:I8');
	$objPHPExcel->getActiveSheet()->getCell('H8')->setValue($invoice_due_date);
	$objPHPExcel->getActiveSheet()->mergeCells('J8:K8');
	$objPHPExcel->getActiveSheet()->getCell('J8')->setValue('Company Code:');
	$objPHPExcel->getActiveSheet()->mergeCells('L8:N8');
	$objPHPExcel->getActiveSheet()->getStyle('L8')->getNumberFormat()->setFormatCode( '@');
	$objPHPExcel->getActiveSheet()->getCell('L8')->setValue(' '.$company_code);
	
	
	$objPHPExcel->getActiveSheet()->mergeCells('A9:B9');
	$objPHPExcel->getActiveSheet()->getCell('A9')->setValue('Payment is for:');
	$objPHPExcel->getActiveSheet()->mergeCells('C9:E9');
	$objPHPExcel->getActiveSheet()->getCell('C9')->setValue($prod_month);
	$objPHPExcel->getActiveSheet()->mergeCells('F9:G9');
	$objPHPExcel->getActiveSheet()->getCell('F9')->setValue('');
	$objPHPExcel->getActiveSheet()->mergeCells('H9:I9');
	$objPHPExcel->getActiveSheet()->getCell('H9')->setValue('');
	$objPHPExcel->getActiveSheet()->mergeCells('J9:K9');
	$objPHPExcel->getActiveSheet()->getCell('J9')->setValue('Paying Co:');
	$objPHPExcel->getActiveSheet()->mergeCells('L9:N9');
	$objPHPExcel->getActiveSheet()->getCell('L9')->setValue('');
	
	$objPHPExcel->getActiveSheet()->mergeCells('A10:B10');
	$objPHPExcel->getActiveSheet()->getCell('A10')->setValue('Invoice Number:');
	$objPHPExcel->getActiveSheet()->mergeCells('C10:N10');
	$objPHPExcel->getActiveSheet()->getCell('C10')->setValue($invoice_number);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A11:I11');
	$objPHPExcel->getActiveSheet()->getCell('A11')->setValue('If the payment is under $1,500.00 will the vendor accept a credit card payment?');
	
	$objPHPExcel->getActiveSheet()->getStyle('A7:N11')->applyFromArray($styleArray);
	//unset($styleArray);
		
	$gdImage1 = imagecreatefromjpeg($unchecked);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setImageResource($gdImage1);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('J11');
	$objDrawing->setOffsetX(5);
	$objDrawing->setOffsetY(25);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	$objPHPExcel->getActiveSheet()->getCell('J11')->setValue('Yes');
	$objPHPExcel->getActiveSheet()->getStyle('J11')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
	
	//$objPHPExcel->getActiveSheet()->mergeCells('K11:N11');
	$gdImage1 = imagecreatefromjpeg($checked);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setImageResource($gdImage1);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('K11');	
	$objDrawing->setOffsetX(5);
	$objDrawing->setOffsetY(25);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	$objPHPExcel->getActiveSheet()->getCell('K11')->setValue('No');
	$objPHPExcel->getActiveSheet()->getStyle('K11')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);


	$objPHPExcel->getActiveSheet()->mergeCells('A13:D13');
	$objPHPExcel->getActiveSheet()->getCell('A13')->setValue('Payee Information (Remit Info on SIF)');
	$objPHPExcel->getActiveSheet()->getStyle('A13')->applyFromArray($FontHeaderArray);
	

	$objPHPExcel->getActiveSheet()->mergeCells('A15:B15');
	$objPHPExcel->getActiveSheet()->getCell('A15')->setValue('Payee Name:');
	$objPHPExcel->getActiveSheet()->mergeCells('C15:N15');
	$objPHPExcel->getActiveSheet()->getCell('C15')->setValue($counterparty);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A16:B16');
	$objPHPExcel->getActiveSheet()->getCell('A16')->setValue('Payee Address:');
	$objPHPExcel->getActiveSheet()->mergeCells('C16:N16');
	$objPHPExcel->getActiveSheet()->getCell('C16')->setValue($contact_address);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A17:B17');
	$objPHPExcel->getActiveSheet()->getCell('A17')->setValue('Payee City:');
	$objPHPExcel->getActiveSheet()->mergeCells('C17:E17');
	$objPHPExcel->getActiveSheet()->getCell('C17')->setValue($contact_city);
	$objPHPExcel->getActiveSheet()->mergeCells('F17:G17');
	$objPHPExcel->getActiveSheet()->getCell('F17')->setValue('Payee State:');
	$objPHPExcel->getActiveSheet()->mergeCells('H17:I17');
	$objPHPExcel->getActiveSheet()->getCell('H17')->setValue($contact_state);
	$objPHPExcel->getActiveSheet()->mergeCells('J17:L17');
	$objPHPExcel->getActiveSheet()->getCell('J17')->setValue('Payee Zip:');
	$objPHPExcel->getActiveSheet()->mergeCells('M17:N17');
	$objPHPExcel->getActiveSheet()->getCell('M17')->setValue($contact_zip);
	$objPHPExcel->getActiveSheet()->getStyle('A15:N17')->applyFromArray($styleArray);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A19:D19');
	$objPHPExcel->getActiveSheet()->getCell('A19')->setValue('Electronic Banking Information)');
	$objPHPExcel->getActiveSheet()->getStyle('A19')->applyFromArray($FontHeaderArray);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A21:D21');
	$objPHPExcel->getActiveSheet()->getCell('A21')->setValue('Bank Name:');
	$objPHPExcel->getActiveSheet()->mergeCells('E21:N21');
	$objPHPExcel->getActiveSheet()->getCell('E21')->setValue($bank_name);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A22:D22');
	$objPHPExcel->getActiveSheet()->getCell('A22')->setValue('Recipient Bank ABA (9Digits):');
	$objPHPExcel->getActiveSheet()->mergeCells('E22:F22');
	$objPHPExcel->getActiveSheet()->getStyle('E22')->getNumberFormat()->setFormatCode( '@');
	$objPHPExcel->getActiveSheet()->getCell('E22')->setValue(' '.$aba_number);
	$objPHPExcel->getActiveSheet()->mergeCells('G22:J22');
	$objPHPExcel->getActiveSheet()->getCell('G22')->setValue('Recipient Bank Acct Number:');
	$objPHPExcel->getActiveSheet()->mergeCells('K22:N22');
	$objPHPExcel->getActiveSheet()->getStyle('K22')->getNumberFormat()->setFormatCode( '@');
	$objPHPExcel->getActiveSheet()->getCell('K22')->setValue(' '.$account_no);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A23:D23');
	$objPHPExcel->getActiveSheet()->getCell('A23')->setValue('Addenda Lines:');
	$objPHPExcel->getActiveSheet()->mergeCells('E23:H23');
	
	$objPHPExcel->getActiveSheet()->getStyle('A21:N24')->applyFromArray($styleArray);

	$gdImage1 = imagecreatefromjpeg($checked_al_n);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setImageResource($gdImage1);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('E23');
	$objDrawing->setOffsetX(5);
	$objDrawing->setOffsetY(5);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	$objPHPExcel->getActiveSheet()->getCell('E23')->setValue('');
	$objPHPExcel->getActiveSheet()->getStyle('E23')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
	
	$gdImage1 = imagecreatefromjpeg($checked_al_y);
	$objDrawing = new PHPExcel_Worksheet_MemoryDrawing();
	$objDrawing->setImageResource($gdImage1);
	$objDrawing->setRenderingFunction(PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG);
	$objDrawing->setMimeType(PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_DEFAULT);
	$objDrawing->setCoordinates('E23');
	$objDrawing->setOffsetX(62);
	$objDrawing->setOffsetY(5);
	$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
	$objPHPExcel->getActiveSheet()->getCell('E23')->setValue('      No             Yes');
	$objPHPExcel->getActiveSheet()->getStyle('E23')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
	$objPHPExcel->getActiveSheet()->mergeCells('I23:N23');

	
	$objPHPExcel->getActiveSheet()->mergeCells('A24:D24');
	$objPHPExcel->getActiveSheet()->getCell('A24')->setValue('Text/Accounting Lines: (GL Journal Entry/Descriptions)');
	$objPHPExcel->getActiveSheet()->mergeCells('E24:N24');
	$counterparty_text = 'Purchased Power';
	$objPHPExcel->getActiveSheet()->getCell('E24')->setValue($counterparty_text);
	$objPHPExcel->getActiveSheet()->getRowDimension(24)->setRowHeight(30);
		
	$objPHPExcel->getActiveSheet()->mergeCells('A26:D26');
	$objPHPExcel->getActiveSheet()->getCell('A26')->setValue('Check Disbursement Information');
	$objPHPExcel->getActiveSheet()->getStyle('A26')->applyFromArray($FontHeaderArray);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A28:D28');
	$objPHPExcel->getActiveSheet()->getCell('A28')->setValue('Comments to Supplier to be printed on check (50 Character Maximum):');
	$objPHPExcel->getActiveSheet()->mergeCells('E28:N28');
	$objPHPExcel->getActiveSheet()->getCell('E28')->setValue('');
	
	$objPHPExcel->getActiveSheet()->mergeCells('A29:N29');
	$objPHPExcel->getActiveSheet()->getCell('E28')->setValue('Intercompany routing instructions if check is to be mailed to different than vendor remit address:');

	$objPHPExcel->getActiveSheet()->mergeCells('A30:B30');
	$objPHPExcel->getActiveSheet()->getCell('A30')->setValue('Route Check to:');
	
	$objPHPExcel->getActiveSheet()->mergeCells('C30:N30');
	$objPHPExcel->getActiveSheet()->getCell('C30')->setValue('');
	
	$objPHPExcel->getActiveSheet()->mergeCells('A31:B31');
	$objPHPExcel->getActiveSheet()->getCell('A31')->setValue('Location:');

	$objPHPExcel->getActiveSheet()->mergeCells('C31:N31');
	$objPHPExcel->getActiveSheet()->getCell('C31')->setValue('');
	$objPHPExcel->getActiveSheet()->getStyle('A28:N31')->applyFromArray($styleArray);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A33:D33');
	$objPHPExcel->getActiveSheet()->getCell('A33')->setValue('Accounting');
	$objPHPExcel->getActiveSheet()->getStyle('A33')->applyFromArray($FontHeaderArray);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A35:F35');
	$objPHPExcel->getActiveSheet()->getCell('A35')->setValue('Required for All Requests');
	$objPHPExcel->getActiveSheet()->mergeCells('G35:N35');
	$objPHPExcel->getActiveSheet()->getCell('G35')->setValue('Commercial/Transmission Accounting Only');
	
	$objPHPExcel->getActiveSheet()->getCell('A36')->setValue('GL Account');
	$objPHPExcel->getActiveSheet()->mergeCells('B36:C36');
	$objPHPExcel->getActiveSheet()->getCell('B36')->setValue('Amount (USD)');
	$objPHPExcel->getActiveSheet()->mergeCells('D36:E36');
	$objPHPExcel->getActiveSheet()->getCell('D36')->setValue('Quantity');
	$objPHPExcel->getActiveSheet()->getCell('F36')->setValue('Unit of Measure');
	$objPHPExcel->getActiveSheet()->mergeCells('G36:H36');
	$objPHPExcel->getActiveSheet()->getCell('G36')->setValue('Text');
	$objPHPExcel->getActiveSheet()->getCell('I36')->setValue('Internal Order');
	$objPHPExcel->getActiveSheet()->getCell('J36')->setValue('Profit Center');
	$objPHPExcel->getActiveSheet()->getCell('K36')->setValue('Ref 1');
	$objPHPExcel->getActiveSheet()->getCell('L36')->setValue('Ref 2');
	$objPHPExcel->getActiveSheet()->getCell('M36')->setValue('REF 3');
	$objPHPExcel->getActiveSheet()->getCell('N36')->setValue('Prod Month');
	
		
		$sql="exec spa_create_rec_invoice_report NULL,NULL,NULL,NULL,'','$as_of_date','$as_of_date',$counterparty_id,'d','e',NULL,'f','$prod_month',$payment_ins_header_id,'y'";

	    $recrodsetResource = odbc_exec($odbc_connection, $sql);
		$no_of_rows = odbc_num_rows($recrodsetResource);
		$total_value=0;
		$total_vol = 0;
		$line_item = "";
        $prod_month = "";
        $volume = 0;
        $uom = "";
        $rate = "";
        $value = "";
		$total_rows=0;
        $row_no = 37;
		$count = 0;
		while (odbc_fetch_row($recrodsetResource))
          {
			 $total_rows++;
			 
			 $line_item = odbc_result($recrodsetResource, 1);
		
			 $prod_month = odbc_result($recrodsetResource, 2);
			 $volume = odbc_result($recrodsetResource, 12);
			
			 $uom = odbc_result($recrodsetResource, 11);
			 $rate = odbc_result($recrodsetResource, 5);
			 $value = odbc_result($recrodsetResource, 6);
			 $gl_number=odbc_result($recrodsetResource,7);
			 $internal_order=odbc_result($recrodsetResource,9);
			 $profit_center=odbc_result($recrodsetResource,10);						
			 $total_value=$total_value + $value;
			 $total_vol = $total_vol + $volume;
			 $internal_order = ($internal_order == false)?'' : $internal_order;
			 $profit_center = ($profit_center == false)?'' : $profit_center;

			$objPHPExcel->getActiveSheet()->getStyle('A'.$row_no)->getNumberFormat()->setFormatCode( '@');
			$objPHPExcel->getActiveSheet()->getCell('A'.$row_no)->setValue(' '.$gl_number);
			$objPHPExcel->getActiveSheet()->mergeCells('B'.$row_no.':C'.$row_no);
			$objPHPExcel->getActiveSheet()->getCell('B'.$row_no)->setValue('$'.my_number_format('$.2',$value).'');
			$objPHPExcel->getActiveSheet()->mergeCells('D'.$row_no.':E'.$row_no);
			$objPHPExcel->getActiveSheet()->getCell('D'.$row_no)->setValue(($volume == 0)?'':''.my_number_format('.3',$volume).'');
			$objPHPExcel->getActiveSheet()->getCell('F'.$row_no)->setValue($uom);
			$objPHPExcel->getActiveSheet()->mergeCells('G'.$row_no.':H'.$row_no);
			$objPHPExcel->getActiveSheet()->getCell('G'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->getStyle('I'.$row_no)->getNumberFormat()->setFormatCode( '@');
			$objPHPExcel->getActiveSheet()->getCell('I'.$row_no)->setValue(' '.$internal_order);
			$objPHPExcel->getActiveSheet()->getStyle('J'.$row_no)->getNumberFormat()->setFormatCode( '@');
			$objPHPExcel->getActiveSheet()->getCell('J'.$row_no)->setValue(''.$profit_center);
			$objPHPExcel->getActiveSheet()->getCell('K'.$row_no)->setValue($counterparty_code);
			$objPHPExcel->getActiveSheet()->getCell('L'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->getCell('M'.$row_no)->setValue('');
			//$objPHPExcel->getActiveSheet()->mergeCells('M'.$row_no.':N'.$row_no);
			$objPHPExcel->getActiveSheet()->getCell('N'.$row_no)->setValue($prod_month);

			$row_no = $row_no + 1;
			$count = $count+1;								
			
		}


		$total_extra_rows = ($total_rows < 10)? 10-$total_rows:0 ;
		$count=0;
		
	$row_no = $row_no -1;
	while($count <= $total_extra_rows){
			$row_no = $row_no + 1;
			$objPHPExcel->getActiveSheet()->getCell('A'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->mergeCells('B'.$row_no.':C'.$row_no);
			$objPHPExcel->getActiveSheet()->getCell('B'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->mergeCells('D'.$row_no.':E'.$row_no);
			$objPHPExcel->getActiveSheet()->getCell('D'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->getCell('F'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->mergeCells('G'.$row_no.':H'.$row_no);
			$objPHPExcel->getActiveSheet()->getCell('I'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->getCell('J'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->getCell('K'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->getCell('L'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->getCell('M'.$row_no)->setValue('');
			$objPHPExcel->getActiveSheet()->getCell('N'.$row_no)->setValue('');
			//$objPHPExcel->getActiveSheet()->mergeCells('N'.$row_no.':O'.$row_no);
			//$objPHPExcel->getActiveSheet()->getCell('N'.$row_no)->setValue('');
			$count = $count+1;
			
			
		}

	
	
	$objPHPExcel->getActiveSheet()->getCell('A47')->setValue('Total:');
	$objPHPExcel->getActiveSheet()->mergeCells('B47:C47');
	$objPHPExcel->getActiveSheet()->getCell('B47')->setValue('$'. my_number_format('$.2',$total_value).'');
	$objPHPExcel->getActiveSheet()->getCell('D47')->setValue(''. my_number_format('.3',$total_vol).'');
	$objPHPExcel->getActiveSheet()->mergeCells('M47:N47');
	$objPHPExcel->getActiveSheet()->getCell('M47')->setValue('');
	$objPHPExcel->getActiveSheet()->getStyle('A35:N47')->applyFromArray($styleArray);
	
	$objPHPExcel->getActiveSheet()
		->getStyle('D37:D47')
		->getAlignment()
		->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
	
	$objPHPExcel->getActiveSheet()
		->getStyle('B37:B47')
		->getAlignment()
		->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
		
	$styleArray_s = array(
    'font'  => array(
        'bold'  => true,
        'size'  => 10,
        'name'  => 'Calibri'
    ));
	
	$objPHPExcel->getActiveSheet()->mergeCells('A48:N48');
	$objPHPExcel->getActiveSheet()->getCell('A48')->setValue('Letter of understanding on file and back-up documentation filed at your office. (By checking “Yes”, the approver agrees to have BU documentation available for audit. ☒ Yes ☐ No');
	$objPHPExcel->getActiveSheet()->getStyle('A48:N48')->applyFromArray($styleArray_s);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A50:D50');
	$objPHPExcel->getActiveSheet()->getCell('A50')->setValue('Approval');
	$objPHPExcel->getActiveSheet()->getStyle('A50')->applyFromArray($FontHeaderArray);
	
	$objPHPExcel->getActiveSheet()->mergeCells('A52:F52');
	$objPHPExcel->getActiveSheet()->getCell('A52')->setValue("Requester's Information");
	$objPHPExcel->getActiveSheet()->mergeCells('G52:N52');
	$objPHPExcel->getActiveSheet()->getCell('G52')->setValue("Approver's Information");
	
	$objPHPExcel->getActiveSheet()->mergeCells('A53:B53');
	$objPHPExcel->getActiveSheet()->getCell('A53')->setValue("Print Name:");
	$objPHPExcel->getActiveSheet()->mergeCells('C53:F53');
	$objPHPExcel->getActiveSheet()->getCell('C53')->setValue($settle_account);
	$objPHPExcel->getActiveSheet()->mergeCells('G53:I53');
	$objPHPExcel->getActiveSheet()->getCell('G53')->setValue("Print Name:");
	$objPHPExcel->getActiveSheet()->mergeCells('J53:N53');
	$objPHPExcel->getActiveSheet()->getCell('J53')->setValue($contract_specialist);

	$objPHPExcel->getActiveSheet()->mergeCells('A54:B54');
	$objPHPExcel->getActiveSheet()->getCell('A54')->setValue("Employee ID:");
	$objPHPExcel->getActiveSheet()->mergeCells('C54:F54');
	$objPHPExcel->getActiveSheet()->getCell('C54')->setValue(' '.$emp_id);
	$objPHPExcel->getActiveSheet()->mergeCells('G54:I54');
	$objPHPExcel->getActiveSheet()->getCell('G54')->setValue("Employee ID:");
	$objPHPExcel->getActiveSheet()->mergeCells('J54:N54');
	$objPHPExcel->getActiveSheet()->getCell('J54')->setValue(' '.$contract_empid);

	$objPHPExcel->getActiveSheet()->mergeCells('A55:B55');
	$objPHPExcel->getActiveSheet()->getCell('A55')->setValue("Job Role/Title:");
	$objPHPExcel->getActiveSheet()->mergeCells('C55:F55');
	$objPHPExcel->getActiveSheet()->getCell('C55')->setValue($title);
	$objPHPExcel->getActiveSheet()->mergeCells('G55:I55');
	$objPHPExcel->getActiveSheet()->getCell('G55')->setValue("Job Role/Title:");
	$objPHPExcel->getActiveSheet()->mergeCells('J55:N55');
	$objPHPExcel->getActiveSheet()->getCell('J55')->setValue($contract_Title);

	$objPHPExcel->getActiveSheet()->mergeCells('A56:B56');
	$objPHPExcel->getActiveSheet()->getCell('A56')->setValue("Email (required):");
	$objPHPExcel->getActiveSheet()->mergeCells('C56:F56');
	$objPHPExcel->getActiveSheet()->getCell('C56')->setValue($email);
	$objPHPExcel->getActiveSheet()->mergeCells('G56:I56');
	$objPHPExcel->getActiveSheet()->getCell('G56')->setValue("Email (required):");
	$objPHPExcel->getActiveSheet()->mergeCells('J56:N56');
	$objPHPExcel->getActiveSheet()->getCell('J56')->setValue($contract_email);

	$objPHPExcel->getActiveSheet()->mergeCells('A57:B57');
	$objPHPExcel->getActiveSheet()->getCell('A57')->setValue("Phone:");
	$objPHPExcel->getActiveSheet()->mergeCells('C57:F57');
	$objPHPExcel->getActiveSheet()->getCell('C57')->setValue($phone);
	$objPHPExcel->getActiveSheet()->mergeCells('G57:I57');
	$objPHPExcel->getActiveSheet()->getCell('G57')->setValue("Phone:");
	$objPHPExcel->getActiveSheet()->mergeCells('J57:N57');
	$objPHPExcel->getActiveSheet()->getCell('J57')->setValue($contract_phone);
	$objPHPExcel->getActiveSheet()->getStyle('A52:N57')->applyFromArray($styleArray);
	$objPHPExcel->getActiveSheet()->getStyle('A50:N57')->applyFromArray($FontstyleArray);
	
	
	$filename=mt_rand(1,100000).'.xls'; //just some random filename
	header('Content-Type: application/vnd.ms-excel');
	header('Content-Disposition: attachment;filename="'.$filename.'"');
	header('Cache-Control: max-age=0');
 
	$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
	//$objWriter->save(str_replace('.php', '.xlsx', __FILE__));
	$objWriter->save('php://output');

?>
