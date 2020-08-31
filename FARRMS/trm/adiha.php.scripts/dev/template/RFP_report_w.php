<? 
$html_str="";
$html_str .= "<head>";
$html_str .= "<meta http-equiv='Content-Type' content='application/msword; charset=iso-8859-1' />";
$html_str .= "<title>RFP Report</title>";
$html_str .= "<style>";
$html_str .= "<!--
  body{

	font-size:8.5.0pt;
	font-family:'Arial';
	font-weight: bold;	
	margin-top: 10;
 	
 }

 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:'';
	margin:0in;
	margin-bottom:0pt;
	mso-pagination:widow-orphan;
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: bold;	
}
@page Section1
	{size:8.5in 11.0in;
	margin:0in 27.0pt 9.0pt .5in;
	mso-header-margin:.1in;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}


 /* Style Definitions */
 table.MsoNormalTable
	{
	mso-style-name:'Table Grid';
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: normal;	
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;
	border-style:none;

	}
table.MsoTableGrid
	{
	mso-style-name:'Table Grid';
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: bold;	
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;
	BORDER-BOTTOM: #000000 0.5px solid;
	border-left:  #FFFFFF 0px solid;
	border-right: #000000 0.5px solid;
	border-top: #FFFFFF 0px solid;
	border-style:solid;
	}
table.MsoTableGrid td
{
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: bold;	
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;
	BORDER-BOTTOM: #000000 0px solid;
	border-left:  #000000 1px solid;
	border-right: #000000 0px solid;
	border-top: #000000 1px solid;
	border-style:solid;

}	
style1 {font-family: 'Arial', Times, serif}
table.MsoTableGrid1 {	mso-style-name:'Table Grid';
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: bold;	
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;
	BORDER-BOTTOM: #000000 1px solid;
	border-left:  #FFFFFF 0px solid;
	border-right: #000000 1px solid;
	border-top: #FFFFFF 0px solid;
	border-style:solid;
}
table.MsoTableGrid2 {	mso-style-name:'Table Grid';
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: bold;	
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;
	BORDER-BOTTOM: #000000 1px solid;
	border-left:  #FFFFFF 0px solid;
	border-right: #000000 1px solid;
	border-top: #FFFFFF 0px solid;
	border-style:solid;
}
table.MsoTableGrid21 {mso-style-name:'Table Grid';
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: bold;	
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;
	BORDER-BOTTOM: #000000 1px solid;
	border-left:  #FFFFFF 0px solid;
	border-right: #000000 1px solid;
	border-top: #FFFFFF 0px solid;
	border-style:solid;
}
.style4 {	font-size: 12px;
	font-weight: bold;
}
.style7 {font-size: 14px; font-weight: bold; }
.style9 {font-size: 12px}
table.MsoTableGrid3 {	mso-style-name:'Table Grid';
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: bold;	
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;
	BORDER-BOTTOM: #000000 1px solid;
	border-left:  #FFFFFF 0px solid;
	border-right: #000000 1px solid;
	border-top: #FFFFFF 0px solid;
	border-style:solid;
}
table.MsoTableGrid4 {	mso-style-name:'Table Grid';
	font-size:8.5pt;
	font-family:'Arial';
	font-weight: bold;	
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;
	BORDER-BOTTOM: #000000 1px solid;
	border-left:  #FFFFFF 0px solid;
	border-right: #000000 1px solid;
	border-top: #FFFFFF 0px solid;
	border-style:solid;
}
-->
</style>";



$html_str .= "</head>";


?>

<?
//Template Header Copy these to all the template

    include "../../components/include.file.ini.php";
    include "../../adiha.ini.php";
    include "../../PHP_CLASS_EXTENSIONS/PS.Recordset.1.0.php";


$formName="refreport";
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

$img_check_name_dir = "../../adiha_pm_html/process_controls/";


$checkd_a="check_box_unchecked.jpg";
$checkd_w="check_box_unchecked.jpg";
$checkd_c="check_box_unchecked.jpg";
$checkd_m="check_box_unchecked.jpg";
$checked="check_box_checked.jpg";
$unchecked="check_box_unchecked.jpg";
$bu="";
$objacct="";	


if ($payment_mode=="a"){
	$checkd_a="check_box_checked.jpg";	
}else if($payment_mode=="w"){
	$checkd_w="check_box_checked.jpg";
}else if($payment_mode=="c"){
	$checkd_c="check_box_checked.jpg";
}else if($payment_mode=="m"){
	$checkd_m="check_box_checked.jpg";
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
                     // echo $sql_invoice; //die();
					 $odbc_connection= $recordsetObject->getConnection();
                      $recrodsetResource = odbc_exec($odbc_connection, $sql_invoice);
                      while (odbc_fetch_row($recrodsetResource))
                      {
							 $invoice_number = odbc_result($recrodsetResource, 1);
                             $contact_address = odbc_result($recrodsetResource, 32);
							 $contact_address2 = odbc_result($recrodsetResource, 33);
							 $contact_fax_email = odbc_result($recrodsetResource, 28);
							 //die($contact_address);
							 if ($payment_mode=="c"){
							 	 $bank_name="";
								 $wire_aba="";
								 $ach_aba="";
								 $account_no="";
								 $address1="";
								 $address2="";	
							 
							 }else{
								 $bank_name=odbc_result($recrodsetResource, 10);
								 $wire_aba=odbc_result($recrodsetResource, 12);
								 $ach_aba=odbc_result($recrodsetResource, 11);
								 $account_no=odbc_result($recrodsetResource,13);
								 $address1=odbc_result($recrodsetResource, 14);
								 $address2=odbc_result($recrodsetResource, 15);							 		 
							}	 
                             $term = odbc_result($recrodsetResource, 11);
                             $invoice_date = odbc_result($recrodsetResource,2);
                             $invoice_due_date = odbc_result($recrodsetResource, 3);
   							 $statement_type = odbc_result($recrodsetResource, 7);
                             $sub_id = odbc_result($recrodsetResource, 8);
                             $settle_account = odbc_result($recrodsetResource, 59);
						     $request_date=odbc_result($recrodsetResource, 4);
					 	     $counterparty=odbc_result($recrodsetResource,9 );
						     $title=odbc_result($recrodsetResource,60);
							 $emp_id=odbc_result($recrodsetResource,61);
							 $business_unit=odbc_result($recrodsetResource,62);
							 $phone=odbc_result($recrodsetResource,63);
							 $contract_specialist=odbc_result($recrodsetResource,64);
							 $contract_Title=odbc_result($recrodsetResource,65);
							 $contract_empid=odbc_result($recrodsetResource,66);
							 $contract_phone=odbc_result($recrodsetResource,67);
							 $prod_month = odbc_result($recrodsetResource, 5);
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

$checkd_NSW="check_box_unchecked.jpg";
$checkd_NSM="check_box_unchecked.jpg";
$checkd_PSC="check_box_unchecked.jpg";
$checkd_SPS="check_box_unchecked.jpg";

if ($sub_id==136){
		$checkd_NSW="check_box_checked.jpg";
}elseif($sub_id==135){
		$checkd_NSM="check_box_checked.jpg";
}elseif($sub_id==137){
		$checkd_PSC="check_box_checked.jpg";
}elseif($sub_id==138){
		$checkd_SPS="check_box_checked.jpg";
}
function my_number_format($format_str, $value)
{
        //return $value;
        //echo  "in  here";
        if ($format_str != "N" && $format_str != "X")
            if ($format_str == "L" && number_format($value) == 0)
                return "";
            else
            {
                $decimals = 0;
                $pieces = explode(".", $format_str);
                if (count( $pieces) > 1)
                    $decimals =  $pieces[1];
                //echo    $decimals;
                return number_format($value, $decimals);
            }

        else
                return $value;
}


odbc_free_result($recrodsetResource);


$html_str .="
<body>
<div class='Section1'>";

?>
<form name='<?=$formName;?>'>

<?
$html_str .="
<br><br><br>
<table width='100%' border='0' cellpadding='0' cellspacing='0' class='MsoNormalTable'>
  <tr>
  <tr>
    <td  align='left' ><font size=3><b>REQUEST FOR CHECK/FUNDS TRANSFER PAYMENT</b></font>
    <br/>
    <span><INPUT type='image' src='$img_check_name_dir$checkd_a'></span>
    &nbsp;ACH (D)&nbsp;&nbsp;&nbsp;&nbsp;
     <span style='font-weight:bold;font-size:18px'><INPUT type='image' VALUE='X' src='$img_check_name_dir$checkd_w'></span>&nbsp;Wire (W)&nbsp;&nbsp;&nbsp;&nbsp;
	 <span style='font-weight:bold;font-size:18px'><INPUT type='image' VALUE='X' src='$img_check_name_dir$checkd_c'></span>&nbsp;CHECK (C)&nbsp;&nbsp;&nbsp;&nbsp;
	 <span style='font-weight:bold;font-size:18px'><INPUT type='image' VALUE='X' src='$img_check_name_dir$checkd_m'></span>&nbsp;CTX (T)&nbsp;&nbsp;&nbsp;&nbsp;
	</td>
	<td align='right' ><INPUT type='image' VALUE='X' src='../../adiha_pm_html/process_controls/xcel_invoice_logo.jpg'></td>
  </tr>
  <tr><td colspan=2><br><b>Reminder: The Non-PO form should not be used to purchase materials and/or services. Please see Procurement Matrix for details.</b></td></tr>
</table>
<br>
<table width='100%' cellpadding='0' cellspacing='0' class='MsoTableGrid'>
  <tr>
     <td width='10%'>Date of Request:</td>
     <td width='25%'>&nbsp;$request_date</td>
	 <td width='10%'>Vendor ID:</td>
     <td width='20%'>&nbsp;</td>
	 <td width='10%'>Facility/Plant Number:</td>
	 <td width='20%'>&nbsp;</td>
    </tr>
  <tr>
    <td> Invoice Date:</td>
	<td>&nbsp;$invoice_date</td>
    <td>Scheduled Pmt Date:<br>
	<td>&nbsp;$invoice_due_date</td>	
	<td> Company Code:<br>
	<td>&nbsp;$company_code</td>
  </tr>
    <tr>
    <td>Payment is for:</td>
	<td>&nbsp;$prod_month</td>
    <td>Ref Key 1:<br>
	<td>&nbsp;$counterparty_code</td>
	<td>Paying Co:<br>
	<td>&nbsp;</td>
  </tr>
  <tr>
	<td>Invoice Number:</td>
	<td colspan=5>&nbsp;$invoice_number</td>
  </tr>
  <tr>
    <td colspan=4>If the payment is under $1,500.00 will the vendor accept credit card payment?</td>
    <td colspan='2'><span style='font-weight:bold;font-size:18px'><INPUT type='image' VALUE='X' src='../../adiha_pm_html/process_controls/check_box_unchecked.jpg''></span>&nbsp;Yes&nbsp;&nbsp;</span>
	<span style='font-weight:bold;font-size:18px'><INPUT type='image' VALUE='X' src='../../adiha_pm_html/process_controls/check_box_checked.jpg''></span>&nbsp;No&nbsp;&nbsp;</span>
	</td>
    </tr>
</table>
<div class='MsoNormal'>
<br>
<font size=2>Payee Information (Remit Info on SIF)</font>
<br>
</div>

</table>
  <br />
  <table width='100%' border='1' cellpadding='0' cellspacing='0' class='MsoTableGrid'>
  <tr>
    <td width='20%' >Payee Name </td>
    <td colspan='5' >&nbsp;$counterparty<span class='style5'><span class='style5'></td>
    </tr>
  <tr>
    <td >Payee Address </td>
    <td colspan='5' >&nbsp;$contact_address<span class='style5'><span class='style5'></td>
    </tr>
  <tr>
    <td width='20%'>Payee City:</td>
    <td width='20%'>&nbsp;$contact_city<span class='style5'><span class='style5'></td>
	<td width='15%'>Payee State:</td>
	<td width='15%'>&nbsp;$contact_state<span class='style5'><span class='style5'></td>
    <td width='15%'>Payee Zip:</td>
	<td width='15%'>&nbsp;$contact_zip<span class='style5'><span class='style5'></td>
   </tr>
  
</table>

<div class='MsoNormal'>
<br>
<font size=2>Electronic Banking Information</font>
<br>
</div>
<br>
  <table width='100%' border='1' cellpadding='0' cellspacing='0' class='MsoTableGrid'>
  
    <tr>
      <td width='30%'>Bank Name: </td>
      <td colspan='4' >&nbsp;$bank_name<span class='style5'><span class='style5'></td>
    </tr>
    <tr>
      <td width='30%' >Recipient Bank ABA(9 Digits):</td>
      <td width='20%' >&nbsp;$aba_number</td>
      <td width='30%' colspan='2' >Recipient Bank Acct Number:</td>
	  <td width='30%' >&nbsp;$account_no</td>
    </tr>
	<tr>
      <td height='29' >Added Lines:</td>
      <td colspan='4' >&nbsp;
		<span style='font-weight:bold;font-size:18px'><INPUT type='image' VALUE='X' src='../../adiha_pm_html/process_controls/check_box_unchecked.jpg''></span>&nbsp;Yes (see backup documentation)</span>
		<span style='font-weight:bold;font-size:18px'><INPUT type='image' VALUE='X' src='../../adiha_pm_html/process_controls/check_box_unchecked.jpg''></span>&nbsp&nbsp&nbsp;No</span>
	  </td>
    </tr>
	<tr>
      <td height='29' >Test/ Accounting Lines:<br>(GL Journal Entry Descriptions)</td>
	  <td colspan='4' >&nbsp;$counterparty Purchased Power</td>
	</tr>
  </table>
<div class='MsoNormal'>
<br>
<font size=2>Check Disbursement Information</font>
<br>
</div>
<br>
  <table width='100%' border='1' cellpadding='0' cellspacing='0' class='MsoTableGrid'>
    <tr>
      <td colspan =2 width='40%' height='30'>Comments to Supplier to be printed on check(50 character Maximum):</td>
      <td width='80%'></td>
    </tr>
	<tr>
      <td colspan=3>Intercounterparty routing instructions if check is to be mailed to different than vendor remit address:</td>
    </tr>
    <tr>
      <td width='20%'>Route Chekc to:</td>
      <td colspan=2>&nbsp;</td>
    </tr>
	<tr>
      <td width='20%'>Location:</td>
      <td colspan=2>&nbsp;</td>
    </tr>
  </table>
 <div class='MsoNormal'>
<br>
<font size=2>Accounting</font>
<br>
</div>
<br>
  <table width='100%' border='0' cellspacing='0' cellpadding='0'>
  <tr>
    <td><font size='2'>";
	
      
$header ="   <table width='100%'  cellspacing='0' cellpadding='0' class='MsoTableGrid'>";
$header .="   <tr><td colspan=5>Required for All Requests</td><td colspan=4>Commercial/Transmission Accounting Only</td></tr>";
$header .="      <tr>";
$header .="        <td width='9%' align=left><b>GL Account</b></td>";
$header .="        <td width='15%' align=left><b>Amount(USD)</b></td>";
$header .="        <td width='9%' align=left><b>Cost Center</b></td>";
$header .="        <td width='15%' align=left><b>Internal Order</b></td>";
$header .="        <td width='10%' align=left><b>Profit Center</b></td>";
$header .="        <td width='10%' align=left><b>Quantity</b></td>";
$header .="        <td width='10%' align=left><b>Base U of M</b></td>";
$header .="        <td width='10%' align=left><b>Production Month</b></td>";
$header .="        <td width='20%'  align=left  nowrap><b>Ref Key 3</b></td>";
$header .="      </tr>";

$html_str_add .= $header;
$html_str .= $header;


		//$sql="exec spa_create_rec_invoice_report NULL,NULL,NULL,NULL,'','10/01/2006','10/01/2006','213','d','e',NULL,'s','09/01/2006'";
		
		$sql="exec spa_create_rec_invoice_report NULL,NULL,NULL,NULL,'','$as_of_date','$as_of_date',$counterparty_id,'d','e',NULL,'f','$prod_month',$payment_ins_header_id,'y'";
		

	    $recrodsetResource = odbc_exec($odbc_connection, $sql);
		$no_of_rows = odbc_num_rows($recrodsetResource);
		$total_value=0;
		$total_vol = 0;
		$line_item = "";
        $prod_month = "";
        $volume = "";
        $uom = "";
        $rate = "";
        $value = "";
		$total_rows=0;
         while (odbc_fetch_row($recrodsetResource))
          {
		  	$total_rows++;
                             $line_item = odbc_result($recrodsetResource, 1);
                             $prod_month = odbc_result($recrodsetResource, 2);
                             $volume = odbc_result($recrodsetResource, 3);
                             $uom = odbc_result($recrodsetResource, 4);
                             $rate = odbc_result($recrodsetResource, 5);
                             $value = odbc_result($recrodsetResource, 6);
							 $gl_number=odbc_result($recrodsetResource,7);
							 $internal_order=odbc_result($recrodsetResource,30);
							 $profit_center=odbc_result($recrodsetResource,31);
							
/*
							$gl_number_array=explode(".",$gl_number);							 
							
							
							
							if($gl_number=='' || $gl_number=='NULL'){
 								 $bu="";
								 $objacct="";		
							}

							if(count($gl_number_array)>1){
							 	 $bu=$gl_number_array[0];
								 $objacct=$gl_number_array[1];
							}
*/
							 $total_value=$total_value+$value;
							 $total_vol = $total_vol + $volume;
							
							 //echo $gl_number;
                 	

	if($total_rows>6){
					
		$html_str_add .="        <tr>";
		$html_str_add .="          <td align=center nowrap>".$gl_number."&nbsp;</td>";
		$html_str_add .="          <td align='right'>$".my_number_format("$.2",$value)."</td>";
		$html_str_add .="          <td align='center'>"."&nbsp;</td>";
		$html_str_add .="          <td align='center'>"."&nbsp;".$internal_order."</td>";
		$html_str_add .="          <td align=center>"."&nbsp;".$profit_center."</td>";
		$html_str_add .="          <td align='right'>".my_number_format("$.2",$volume)."</td>";
		$html_str_add .="          <td align=center nowrap>".$uom."&nbsp;</td>";
		$html_str_add .="          <td align='center'>".$prod_month."</td>";
		$html_str_add .="          <td align=center>"."&nbsp;</td>";
		$html_str_add .="        </tr>";
		
		
	}else{	

		$html_str .="        <tr>";
		$html_str .="          <td align=center nowrap>".$gl_number."&nbsp;</td>";
		$html_str .="          <td align='right'>$".my_number_format("$.2",$value)."</td>";
		$html_str .="          <td align='center'>"."&nbsp;</td>";
		$html_str .="          <td align='center'>"."&nbsp;".$internal_order."</td>";
		$html_str .="          <td align=center>"."&nbsp;".$profit_center."</td>";
		$html_str .="          <td align='right'>".my_number_format("$.2",$volume)."</td>";
		$html_str .="          <td align=center nowrap>".$uom."&nbsp;</td>";
		$html_str .="          <td align='center'>".$prod_month."</td>";
		$html_str .="          <td align=center>"."&nbsp;</td>";
		$html_str .="        </tr>";
	}
}
	   
$total_extra_rows=($total_rows<6)? 6-$total_rows:0 ;
$count=1;

while($count<=$total_extra_rows){
	$html_str .="        <tr>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="          <td>&nbsp;</td>";
	$html_str .="        </tr>";
	$count=$count+1;
	
}
	   
$footer ="  <tr>";
$footer .="          <td align='left' colspan=5><b><font size=2>Total: &nbsp;&nbsp;&nbsp;&nbsp;$". my_number_format("$.2",$total_value)."</font></b></td>";
$footer .="          <td align='left' colspan=4><font size=2>&nbsp;&nbsp;". my_number_format("$.2",$total_vol)."</font></td>";
$footer .="        </tr>";
$footer .="        <tr><td colspan=9>Letter of understanding on file and back-up documentation filed at your office. (By Checking Yes, the approver agress to have BU documentation available for audit. &nbsp; <INPUT type='image' VALUE='X' src='$img_check_name_dir$unchecked'>Yes &nbsp;&nbsp; <INPUT type='image' VALUE='X' src='$img_check_name_dir$checked'>NO</td></tr>";
$footer .="      </table></td>";
$footer .="    </tr>";
$footer .="  </table>";


$html_str .= $footer;
$html_str_add .= '</table>';


$html_str .="
    </td>
  </tr></table>
 <div class='MsoNormal'>
<br>
<font size=2>Approval</font>
<br>
</div>
 <br>
<table width='100%' cellpadding='0' cellspacing='0' class='MsoTableGrid'>
        <tr>
           <td width='50%' align='left' colspan=2>Requestor's Information </td>
		   <td width='50%' align='left' colspan=2>Approver's Information </td>
        </tr>
        <tr>
          <td width='15%'>Print Name:</td>
          <td width='35%'>&nbsp;$settle_account</td>
		  <td width='15%'>Print Name:</td>
          <td width='35%'>&nbsp;$contract_specialist</td>
        </tr>
        <tr>
          <td width='15%'>Employee ID:</td>
          <td width='35%'>&nbsp;$emp_id</td>
		  <td width='15%'>Employee ID:</td>
          <td width='35%'>&nbsp;$contract_empid</td>
        </tr>
        <tr>
          <td width='15%'>Job Role/Title</td>
          <td width='35%'>&nbsp;$title</td>
		  <td width='15%'>Job Role/Title:</td>
          <td width='35%'>&nbsp;$contract_Title</td>
        </tr>
		<tr>
          <td width='15%'>Email(required):</td>
          <td width='35%'>&nbsp;$email</td>
		  <td width='15%'>Email(required):</td>
          <td width='35%'>&nbsp;$contract_email</td>
        </tr>
        
        <tr>
          <td width='15%'>Phone:</td>
          <td width='35%'>&nbsp;$phone</td>
		  <td width='15%'>Phone:</td>
          <td width='35%'>&nbsp;$contract_phone</td>
        </tr>
</table>";

if($total_rows > 6){
	$html_str_add = "<br><br><br><br><br><div class='MsoNormal'>
	<br>
	<font size=2>Additional Accounting Lines (if Needed)</font>
	<br>
	</div>
	 <br>".$html_str_add;
	 
	$html_str .= $html_str_add;
}

$html_str .=" 
  </form>
</body>
</html>";
//echo $html_str;
 odbc_free_result($recrodsetResource);
?>
<script>
function Savepressed(){
	<?=$formName;?>.button_press.value="p";
	<?=$formName;?>.action="template_xml_process.php";
	<?=$formName;?>.target="f1";
	//<?=$formName;?>.submit();
}
</script>
