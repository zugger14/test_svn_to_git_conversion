<html>
<?php include "../../../../adiha.php.scripts/components/include.file.v3.php"; ?>
<body>
<title>FARRMS: Receipt Detail</title>
<base target="left">
<link rel="stylesheet" href="../../../../css/adiha_style.css">

<style>
Body{
scrollbar-face-color: #AFBECF;
scrollbar-3dlight-color: #11487D;
scrollbar-arrow-color: #11487D;
scrollbar-darkshadow-color: #11487D;
}
</style>
<body bgcolor="#F5F8FA" leftmargin="2" topmargin="2">
<span class=ExportBGColor id=grid_loading style=" display:block ;width:100%;height:100%;font-family:verdana;font-weight:bold;font-size:10px">
<br><center>
<img src="../../../../adiha.php.scripts/adiha_pm_html/process_controls/loading.gif"><br><br>Loading...</center>
</span>

<script>
	//parent.hourglass.style.display='';
	document.body.style.overflow='hidden'
</script>




<?



$phpScriptLoc=$app_php_script_loc;
$img_loc=$phpScriptLoc."adiha_pm_html/process_controls/";

$form_name = "formScheduleAndDelivery";

$flag=$_GET['flag'];

//echo("<script>alert('$flag');
if ($flag){

//if(isset($_GET["book_deal_type_map_id"]))
//{
//	$book_deal_type_map_id = $_GET['book_deal_type_map_id'];
//}
//else {
//	$book_deal_type_map_id = 'null';
//}

//$entire_term_start=$_GET['entire_term_start'];
//$entire_term_end=$_GET['entire_term_end'];
//$counterparty_id=$_GET['counterparty_id'];
//$frequency=$_GET['frequency_type'];
//$commodity=$_GET['source_commodity'];

$book_deal_type_map_id = (isset($_GET['book_deal_type_map_id'])) ? $_GET['book_deal_type_map_id'] : "NULL";
$entire_term_start = (isset($_GET['entire_term_start'])) ? $_GET['entire_term_start'] : "NULL";
$entire_term_end = (isset($_GET['entire_term_end'])) ? $_GET['entire_term_end'] : "NULL";
$counterparty_id = (isset($_GET['counterparty_id'])) ? $_GET['counterparty_id'] : "NULL";

$commodity = (isset($_GET['source_commodity'])) ? $_GET['source_commodity'] : "NULL";
$frequency = (isset($_GET['frequency_type'])) ? $_GET['frequency_type'] : "NULL";
$location_id = (isset($_GET['location_id'])) ? $_GET['location_id'] : "NULL";
$subsidiary = (isset($_GET['subsidiary'])) ? $_GET['subsidiary'] : "NULL";
$strategy = (isset($_GET['strategy'])) ? $_GET['strategy'] : "NULL";
$book = (isset($_GET['book'])) ? $_GET['book'] : "NULL";
$xmlFile=$phpScriptLoc."spa_schedule_n_delivery.php?flag=$flag&counterparty_id=$counterparty_id&book_deal_type_map_id=$book_deal_type_map_id&term_start=$entire_term_start&term_end=$entire_term_end&frequency=$frequency&commodity=$commodity&location_id=$location_id&subsidiary=$subsidiary&strategy=$strategy&book=$book";
//trace_php($xmlFile);
$returnvalue=readXMLURL($xmlFile);
//		trace_php($xmlFile);
	     if(count($returnvalue)>=0){
		?>
			<script>
			grid_loading.style.display='none';
			document.body.style.overflow=''
			</script>
		<?
	    }
	//if($disabled == 'true'){
		echo "<form name=". $form_name.">";
	?>
	<body leftmargin="0" topmargin="0">
	<table width=100% id="test"  cellspacing=1 cellpadding=2 border=0 bgcolor='#D4D4D4'>
	<tr  bgcolor='#EAEAEA'>
	    <th>

		<img id="img" src="../../../../adiha.php.scripts/adiha_pm_html/process_controls/grid_img/corner.gif" style='cursor:hand' alt='zoom'  onClick="zoomIn('search');">	</th>
	    <th nowrap>Deal Date</th>

	    <th align="left" nowrap>Term Start</th>
	    <th align="left" nowrap>Term End</th>
	    <th align="left" nowrap>Commodity</th>
	    <th align="left" nowrap>Counterparty</th>

	    <th align="left" nowrap>Location</th>
	    <th align="left" nowrap>Volume</th>

	    <th align="left" nowrap>UOM</th>
	    <th align="left" nowrap>&nbsp;</th>
	  </tr>
	<?
	$tot_row=count($returnvalue);

	$cnt=0;
	$total_amt=0;
//	$total_variance=0;
//	$total_settlement_cash='';
//	$total_amt_received = 0;

	$total_volume=0;

	while ($cnt<$tot_row){

		$source_deal_detail_id=$returnvalue[$cnt][0];
		$deal_date=$returnvalue[$cnt][1];
		$term_start=$returnvalue[$cnt][2];
		$term_end=$returnvalue[$cnt][3];
		$commodity=$returnvalue[$cnt][4];
		$counterparty=$returnvalue[$cnt][5];
		$location=$returnvalue[$cnt][6];
		$volume=$returnvalue[$cnt][7];
		$uom=$returnvalue[$cnt][8];
		$booked=$returnvalue[$cnt][9];
?>

  <tr class=GridClass bgcolor='#FFFFFF'>
     <td>
       <?
//	 echo adiha_texthide($form_name,"sourceDealCashSettlement_",$returnvalue[$cnt][7]);
	echo adiha_texthide($form_name,"sourceDealDetail_",$returnvalue[$cnt][0]);
	 echo adiha_texthide($form_name,"source_deal_detail_id_".$cnt, $source_deal_detail_id);
	?>
    <?
	     if($returnvalue[$cnt][0] != ''){

		  $enabledisable = true;
		 }
		 else

		  $enabledisable = false;

		  $to_string = "".$returnvalue[$cnt]['0'];

	  echo adiha_check_box($form_name,"select_schedule_".$cnt,'',$returnvalue[$cnt][0],'',$enabledisable,'');?></td>
   <!-- <td  nowrap><?// echo adiha_texthide($form_name,"source_deal_detail_id_".$cnt, $source_deal_detail_id);?></td>-->

    <?php
    /*		
    <td nowrap><span class="formlabell">
	<?
	if($term_start =='')
	  $term_start=date("m/d/Y");
	echo adiha_date($form_name,"term_start_".$cnt,$term_start);
	?>
	</span></td>
    <td  nowrap><span class="formlabell">
	<?
	if($term_end =='')
	  $term_end=date("m/d/Y");
	echo adiha_date($form_name,"term_end_".$cnt,$term_end);
	?>
	</span></td>
	*/
	?>
	<td  nowrap><? echo adiha_texthide($form_name,"deal_date_".$cnt, $term_start);?><?=$deal_date;?></td>
    <td  nowrap><? echo adiha_texthide($form_name,"term_start_".$cnt, $term_start);?><?=$term_start;?></td>
    <td  nowrap><? echo adiha_texthide($form_name,"term_end_".$cnt, $term_end);?><?=$term_end;?></td>

    <td  nowrap><? echo adiha_texthide($form_name,"commodity_".$cnt, $commodity);?><?=$commodity;?></td>
    <td  nowrap><? echo adiha_texthide($form_name,"counterparty_".$cnt, $counterparty);?><?=$counterparty;?></td>
    <td  nowrap><? echo adiha_texthide($form_name,"location_".$cnt, $location);?><?=$location;?></td>
    <td  nowrap><? echo adiha_texthide($form_name,"volume_left_".$cnt, $volume);?><?=$volume;?></td>
    <td  nowrap><? echo adiha_texthide($form_name,"uom_".$cnt, $uom);?><?=$uom;?></td>
    <td><span class="formlabell"><? echo adiha_textbox($form_name,"volume_". $cnt,$volume,true,30,false); ?></span></td>

	<?php /* <td><span class="formlabell"><? echo adiha_textbox($form_name,"booked_". $cnt,$booked,true,30,false); ?></span></td> */ ?>
  </tr>

  <? echo adiha_texthide($form_name,"save_invoice_detail_id_".$cnt, $returnvalue[$cnt][7]);?>
  <?
	$total_volume = $total_volume + $volume;
  	$cnt++;
  }



  ?><tr class=GridClass bgcolor='#FFFFFF'>
    <td class=formlabel></td>
    <td class=formlabel>&nbsp;</td>
    <td class=formlabel>&nbsp;</td>
    <td class=formlabel>&nbsp;</td>
    <td class=formlabel>&nbsp;</td>
    <td class=formlabel>&nbsp;</td>
    <td align="left"><strong>Total Volume: </strong></td>
    <td align="left"><span ><strong>
      <?=number_format($total_volume,2)?>
    </strong></span></td>
    <td align="left" nowrap="nowrap">&nbsp;</td>
    <td align="left" nowrap="nowrap">&nbsp;</td>
    </tr>
</table>
</form>


</body>
<? } ?>
<script>
var flag = '<?=$flag; ?>';
var rcount = 0;

function calc_total(obj){

	var totrow=<?=$tot_row;?>;
	var row=0;
	tot_amt=0

	var row_name=obj.name;
	var row_no=row_name.split("_");

		invoice_amt1=eval('get_'+row_name+'_value()');


	if(isNum(invoice_amt1)==false && invoice_amt1 != 'NULL' && invoice_amt1 != 0 ){
				myMessage ="Cash amount is invalid.";
				adiha_CreateMessageBox("alert",myMessage,'','');
				return;
		}

	if(invoice_amt1 == 'NULL'){

	    document.getElementById(row_name).value = 0;

	}


	var t = eval(document.getElementById("deletecashsettlement_"+row_no[1]).value)



	if(t == undefined){
	 if(invoice_amt1 == 'NULL'){

	  document.getElementById(row_name).value = '';
	}
}

	while (row<totrow) {
		invoice_amt=eval('get_a_'+row +'_value()');

		if(invoice_amt == 'NULL')
		 invoice_amt = "0";
		else
		  invoice_amt = invoice_amt


		total_amt = parseFloat(invoice_amt)
		tot_amt=tot_amt+total_amt;
		 row++;


	}

invoice_total.innerText=formatCurrency(tot_amt);
	var row_name=obj.name;
	var row_no=row_name.split("_");

	calcCashVariance(row_no[1]);
}

function calcCashVariance(row_no){
      tot_var = 0;
	  var totrow=<?=$tot_row;?>;
	  var row=0;


      var cashAmt = eval('get_a_'+row_no +'_value()');
	 // alert(cashAmt)



	  var settlementCash = eval('get_s_'+row_no +'_value()');

	 var ca =  cashAmt;




	  if(ca == 'NULL'){
	   var cashVariance = '';

	  }

	  else {
	    var cashVariance = cashAmt - settlementCash;

	  }


	   document.getElementById("variance_" +row_no).value = cashVariance



	  while (row<totrow) {
		  variance_amt=eval('get_variance_'+row+'_value()');
		 // alert(variance_amt)

		  if(variance_amt == 'NULL' ||variance_amt == '%20')
		    variance_amt = "0";

		  tot_var=tot_var+parseFloat(variance_amt);
		  row++;
  	  }

	 var_total.innerText=formatCurrency(tot_var);

}

function deleteSchedule(obj){
}

function check_volume()
{
	var totrow=<?=$tot_row;?>;
		
	var schedule_volume = new Array();
	
	var column=1;
	var row=1;
	var rcount = 0;
	
	while (row<=totrow) 
	{
		row_id=row-1;
		
		var volume2=eval('get_volume_'+row_id+'_value()');	
		
		schedule_volume[rcount] = volume2;
		
		rcount = rcount + 1;
	
		row=row+1;
	}
	/*
	if(flag == 'r')
		document.frames["receipt_frame"].receipt_vol = schedule_volume;
	*/
	
	return schedule_volume;	
}

//check_volume();

function check_grid_row(chkIndexParam)
{
	var chk_index_tmp = chkIndexParam;
	var totrow=<?=$tot_row;?>;
	
	// uncheck all existing checked rows
	for(i=0 ; i <= totrow ; i++)
	{
		if(document.getElementById("select_schedule_" + i))
			document.getElementById("select_schedule_" + i).checked = false;
	}
	
	// check the matched rows
	for(i=0; i<=chk_index_tmp ; i++)
	{
		if(document.getElementById("select_schedule_" + i))
			document.getElementById("select_schedule_" + i).checked = true;
		
	}
}

function get_schedule_detail(){
	var totrow=<?=$tot_row;?>;
	
	var schedule_volume = new Array();

	var column=1;
	var row=1;
	var xmltext='<Root>';
	var x='';
	var y='';
	var selected_schedule = '';

//	alert('get_schedule_detail1');
	//return;
	//while ((row<=totrow) && ( document.getElementById("select_schedule_" +(row-1)).checked == true)) {
	

	while (row<=totrow) {
		row_id=row-1;

		if ( document.getElementById("select_schedule_" +row_id).checked == true){

			
			var source_deal_detail_id2=eval('get_source_deal_detail_id_'+row_id+'_value()');
			//if( document.getElementById("select_schedule_" +row_id).checked == true){
				//alert(source_deal_detail_id2);

			//}

			//selected_schedule = eval(document.getElementById("select_schedule_"+row_id).value);
			//alert(selected_schedule);

			var term_start2=eval('get_term_start_'+row_id+'_value()');
			var term_end2=eval('get_term_end_'+row_id+'_value()');

			var commodity2=eval('get_commodity_'+row_id+'_value()');
			var counterparty2=eval('get_counterparty_'+row_id+'_value()');
			var location2=eval('get_location_'+row_id+'_value()');
			var volume_left2=eval('get_volume_left_'+row_id+'_value()');
			var uom2=eval('get_uom_'+row_id+'_value()');
			var volume2=eval('get_volume_'+row_id+'_value()');
			
			

			//if (volume>volume_left){
//				alert('Volume should not be greater than volume_left');
//				return;
//			}

			if( document.getElementById("select_schedule_" +row_id).checked == true){
			//if (cash_received!='NULL' && received_date!='NULL'){
				x='<PSRecordset ';
				x=x+' id="'+source_deal_detail_id2+'"';
	//			x=x+' term_start="'+term_start+'"';
	//			x=x+' term_end="'+term_end+'"';
	//			x=x+' commodity="'+commodity+'"';
	//			x=x+' counterparty="'+counterparty+'"';
	//			x=x+' location="'+location+'"';
	//			x=x+' volume_left="'+volume_left+'"';
	//			x=x+' uom="'+uom+'"';
				x=x+' volume="'+volume2+'"';
				x=x+'></PSRecordset>';
	//			alert(x);
				xmltext=xmltext+x;
			//}
			}

			rcount = rcount + 1;
		}
		row=row+1;

	}
	
	xmltext=xmltext+"</Root>";


	if (flag == 'r')
	{
		parent.document.getElementById('receipt_count').value = rcount;
		//parent.document.formScheduleAndDelivery.receipt_xml.value = xmltext;
	}
	else if (flag == 'd'){
		parent.document.getElementById('delivery_count').value = rcount;
	}
	
	//alert(xmltext);
//	alert('get_schedule_detail2');
//alert(xmltext);return;

	//alert(schedule_volume[0]);
	return xmltext;
}


function get_settlementcash_id(){
	var totrow=<?=$tot_row;?>;
	var column=1;
	var row=1;
	var xmltext='<Root>';
	var x='';
	var y='';
	var settlement_id="";
	var comma = ',';
	while (row<=totrow) {
		row_id=row-1;

	if( document.getElementById("deletecashsettlement_" +row_id).checked == true){
		id=eval('document.formApplyCash.deletecashsettlement_'+row_id+'.value');

	}

    else
	   id = '';

		if(id!='')
			if(row==1)

				settlement_id=comma+id;
			else


				settlement_id=settlement_id+comma+id;



		row=row+1;
		comma = ","
	}
	var strId = settlement_id.charAt(0);

	var strId1 = settlement_id.replace(strId,' ');



	return strId1;

}

function test(){

return alert("hello");
}



function zoomIn(obj){

	l = 5;
	t = 10;

	zoomDivReceipt=parent.document.getElementById('testReceipt');
	zoomDivDelivery=parent.document.getElementById('testDelivery');

	if (flag=='r'){
		zoomDiv = zoomDivReceipt;
		frameName = 'receipt_frame';
	}
	else{
		zoomDiv = zoomDivDelivery;
		frameName = 'delivery_frame';
	}

	var imgDiv = document.getElementById("img")


	if(imgDiv.alt=='zoom'){

		org_win_width=window.dialogWidth;
		org_win_height=window.dialogHeight;

		window.dialogTop=0;
		window.dialogLeft=0;

		w=screen.availWidth
		h=screen.availHeight-30

		window.dialogWidth=w+"px";
		window.dialogHeight=h+"px";

		org_left=zoomDiv.style.left;


		org_top=zoomDiv.style.top;
		org_width=zoomDiv.style.width;
		org_height=zoomDiv.style.height;

		zoomDiv.style.left = l;
		zoomDiv.style.top = t



		resize_iFrames(frameName,w-20,h-50);

		imgDiv.alt='undo_zoom';

		if (flag=='r')
			zoomDivDelivery.style.display='none';
		else{
			zoomDivReceipt.style.display='none';
		}

	}

	else{



	    window.dialogTop=40;
		window.dialogLeft=20;

		w=org_win_width
		h=org_win_height

		window.dialogWidth=w+"px";
		window.dialogHeight=h+"px";
		zoomDiv.style.left = org_left;
		zoomDiv.style.top = org_top

		resize_iFrames(frameName,org_width,org_height);
		imgDiv.alt='zoom';

		if (flag=='r')
			zoomDivDelivery.style.display='block';
		else{
			zoomDivReceipt.style.display='block';
		}

	}

 }

function resize_iFrames(siFrameID,w,h){

	var oDHTMLiFrame = parent.document.frames[siFrameID];
	var oDHTMLiFrameDocument = oDHTMLiFrame.document
	var oDOMiFrame = parent.document.getElementById(siFrameID);
	var oDOMiFrameDocument = oDOMiFrame.document
	var oDIVwholePage = oDHTMLiFrameDocument.all['DIVwholePage'];
	oDOMiFrame.height = h;
	oDOMiFrame.width = w;

}

function load_receipt_Xml()
{
	parent.document.getElementById("receipt_xml").value = get_schedule_detail();
//	alert(parent.document.getElementById("receipt_xml").value);
}

////parent.document.getElementById("receipt_xml").value = get_schedule_detail();
</script>

<? //} ?>

