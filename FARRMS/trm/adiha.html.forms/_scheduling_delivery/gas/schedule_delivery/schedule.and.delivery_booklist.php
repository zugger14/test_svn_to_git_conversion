<?php
/**
* Schedule and delivery_booklist screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html public '-//w3c//dtd xhtml 1.0 transitional//en' 'http://www.w3.org/tr/xhtml1/dtd/xhtml1-transitional.dtd'> 
<html>
	<?php include "../../../../adiha.php.scripts/components/include.file.v3.php"; ?>
    <body>
    <title>FARRMS: Book Out</title>
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
    <img src="../../../../adiha.php.scripts/adiha_pm_html/process_controls/loading.gif"><br><br><?php echo get_locale_value('Loading...', true); ?></center>
    </span>
    
    <script>
    	document.body.style.overflow='hidden'
    </script>
    <?php     
    $php_script_loc = $app_php_script_loc;    
    $form_name = "form_schedule_and_delivery_book";    
    $flag = isset($_GET['flag']) ? $_GET['flag'] : '';
    
    if ($flag != '') { 
    	$term_start = (isset($_GET['term_start'])) ? $_GET['term_start'] : "NULL";
    	$term_end = (isset($_GET['term_end'])) ? $_GET['term_end'] : "NULL";
    	$counterparty_id = (isset($_GET['txt_counterparty_id'])) ? $_GET['txt_counterparty_id'] : "NULL";
    	$book_out = (isset($_GET['book_out'])) ? $_GET['book_out'] : "NULL";
    	$uom = (isset($_GET['uom'])) ? $_GET['uom'] : "NULL";
    	$xmlFile = $php_script_loc . "spa_schedule_n_delivery.php?flag=$flag&counterparty_id=$counterparty_id&term_start=$term_start&term_end=$term_end&book_out=$book_out&uom=$uom";
    
    	//trace_php($xmlFile);
    	$return_value = readXMLURL($xmlFile);
    	$tot_row = count($return_value);
    	
    	if ($tot_row >= 0) { 
        ?>
    		<script>
    		grid_loading.style.display='none';
    		document.body.style.overflow=''
    		</script>
    	<?php
    	}
    	
    	echo "<form name=" . $form_name . ">";
    	?>
        	
    	<body leftmargin="0" topmargin="0"> 
    	<table width=100% id="test"  cellspacing=1 cellpadding=2 border=0 bgcolor='#D4D4D4'>
    	   <tr  bgcolor='#EAEAEA'>
    	    <th>    
    		<img id="img" src="../../../../adiha.php.scripts/adiha_pm_html/process_controls/grid_img/corner.gif" style='cursor:hand' alt='zoom'  onClick="zoomIn('search');">	</th>
    	    <th align="left" nowrap><?php echo get_locale_value('Term Start', false); ?></th>
    	    <th align="left" nowrap><?php echo get_locale_value('Term End', false); ?></th>
    	    <th align="left" nowrap><?php echo get_locale_value('Counterparty', false); ?></th>
    	    <th align="left" nowrap><?php echo get_locale_value('Location', false); ?></th>
    	    <th align="left" nowrap><?php echo get_locale_value('Volume Left', false); ?></th>
    	    <th align="left" nowrap><?php echo get_locale_value('Buy/Sell', false); ?></th>
    		<th align="left" nowrap><?php echo get_locale_value('Price', false); ?></th>
    	    <th align="left" nowrap><?php echo get_locale_value('UOM', false); ?></th>
    	    <th align="left" nowrap><?php echo get_locale_value('Book Out', false); ?></th>
    	  </tr>
        <?php 
        $cnt = 0;
        $total_amt = 0;
        $total_volume = 0;
        
        while ($cnt < $tot_row) {
        	$source_deal_detail_id = $return_value[$cnt][0];
        	$term_start = $return_value[$cnt][1];
        	$term_end = $return_value[$cnt][2];
        	$counterparty = $return_value[$cnt][3];
        	$location = $return_value[$cnt][4];
        	$volume = $return_value[$cnt][5];
        	$buy_sell = $return_value[$cnt][6];
        	$price = $return_value[$cnt][7];
        	$uom = $return_value[$cnt][8];
        	$booked = $return_value[$cnt][9];
        
        	if ($book_out == 'y') {
        		$en_dis_text = false;
        		$val = $booked;
        	} else {
        		$en_dis_text = true;
        		$val = '';
        	} 
        ?>
        
          <tr class=GridClass bgcolor='#FFFFFF'>
                <td>
                    <?php
                    echo adiha_texthide($form_name, "txt_sourceDealDetail_" . $cnt, $return_value[$cnt][0]);
                    
                    if ($return_value[$cnt][0] != '') {
                        $enabledisable = true;
                    } else {
                        $enabledisable = false;
                    }
                    
                    $to_string = "" . $return_value[$cnt]['0'];
                    
                    echo adiha_check_box($form_name, "txt_select_schedule_" . $cnt, '', $return_value[$cnt][0], '', $enabledisable, '');
                    ?>
                </td>            
                <td  nowrap>
                    <?php
                    echo adiha_texthide($form_name, "txt_term_start_" . $cnt, $term_start);
                    echo $term_start;
                    ?>
                </td>
                <td  nowrap>
                    <?php
                    echo adiha_texthide($form_name, "txt_term_end_" . $cnt, $term_end);
                    echo $term_end;
                    ?>
                </td> 
                <td  nowrap>
                    <?php
                    echo adiha_texthide($form_name, "txt_counterparty_" . $cnt, $counterparty);
                    echo $counterparty;
                    ?>
                </td>
                <td  nowrap>
                    <?php 
                    echo adiha_texthide($form_name, "txt_counterparty_" . $cnt, $location); 
                    echo $location; 
                    ?>
                </td>
                <td  nowrap>
                    <?php 
                    echo adiha_texthide($form_name, "txt_volume_left_" . $cnt, $volume);
                    echo $volume; 
                    ?>
                </td>
                <td nowrap="true">
                    <?php 
                    echo adiha_texthide($form_name, "txt_volume_left_" . $cnt, $buy_sell);
                    echo $buy_sell; 
                    ?>
                </td>
                <td  nowrap>
                    <?php 
                    echo adiha_texthide($form_name, "txt_price_" . $cnt, $price); 
                    echo $price; 
                    ?>
                </td>
                <td  nowrap>
                    <?php 
                    echo adiha_texthide($form_name, "txt_uom_" . $cnt, $uom);
                    echo $uom; 
                    ?>
                </td>
                <td><span class="formlabell"><?php echo adiha_textbox($form_name, "txt_book_vol_" . $cnt, $val, $en_dis_text, 30, false); ?></span></td>
                </tr>                
                <?php 
                echo adiha_texthide($form_name, "txt_save_invoice_detail_id_" . $cnt, $return_value[$cnt][7]); 
                $total_volume = $total_volume + $volume;
                $cnt++;
                }
                ?>
        </table>
        </form> 
        </body>
        <?php 
        } 
        ?>
     <script type="text/javascript">
        var flag = ' <?php echo $flag; ?>';
        var rcount = 0;
        
        function calc_total(obj) {
        	var totrow =  <?php echo $tot_row; ?> ;
        	var row = 0;
        	var tot_amt = 0;        
        	var row_name = obj.name;
        	var row_no = row_name.split("_");        
        	var invoice_amt1 = eval('get_' + row_name + '_value()');
        
        	if (isNum(invoice_amt1) == false && invoice_amt1 != 'NULL' && invoice_amt1 != 0) {
        		myMessage = "Cash amount is invalid.";
        		adiha_CreateMessageBox("alert", myMessage, '', '');
        		return;
        	}
        
        	if (invoice_amt1 == 'NULL') {        
        		document.getElementById(row_name).value = 0;        
        	}
        
        	var t = eval(document.getElementById("deletecashsettlement_" + row_no[1]).value)
        
    		if (t == undefined) {
    			if (invoice_amt1 == 'NULL') {
    
    				document.getElementById(row_name).value = '';
    			}
    		}
    		while (row < totrow) {
    			invoice_amt = eval('get_a_' + row + '_value()');
    
    			if (invoice_amt == 'NULL')
    				invoice_amt = "0";
    			else
    				invoice_amt = invoice_amt; 
                       
				total_amt = parseFloat(invoice_amt);
				tot_amt = tot_amt + total_amt;
    			row++;
    
    		}
    
    		invoice_total.innerText = formatCurrency(tot_amt);
        	var row_name = obj.name;
        	var row_no = row_name.split("_");
        
        	calc_cash_variance(row_no[1]);
        }
        
        function calc_cash_variance(row_no) {
        	var tot_var = 0;
        	var totrow =  <?php echo $tot_row;  ?> ;
        	var row = 0;        
        	var cash_amt = eval('get_a_' + row_no + '_value()');
        	var settlement_cash = eval('get_s_' + row_no + '_value()');        
        	var ca = cash_amt;
        
        	if (ca == 'NULL') {
        		var cash_variance = '';        
        	} else {
        		var cash_variance = cash_amt - settlement_cash;
        
        	}
        
        	document.getElementById("variance_" + row_no).value = cash_variance; 
            while (row < totrow) {
    			variance_amt = eval('get_variance_' + row + '_value()');
    
    			if (variance_amt == 'NULL' || variance_amt == '%20')
    				variance_amt = "0";
    
    			tot_var = tot_var + parseFloat(variance_amt);
    			row++;
    		}
    
    		var_total.innerText = formatCurrency(tot_var);
        
        }
        
        function delete_schedule(obj) {}
        
        function get_book_detail() {
        	var totrow =  <?php echo $tot_row; ?> ;        
        	var column = 1;
        	var row = 1;
        	var xmltext = '<Root>';
        	var x = '';
        	var y = '';
        	var selected_schedule = '';
            
        	while (row <= totrow) {
        		row_id = row - 1;
        		if (document.getElementById("txt_select_schedule_" + row_id).checked == true) {        
        			var source_deal_detail_id2 = eval('get_txt_sourceDealDetail_' + row_id + '_value()');        
        			var term_start2 = eval('get_txt_term_start_' + row_id + '_value()');
        			var term_end2 = eval('get_txt_term_end_' + row_id + '_value()');
        			var counterparty2 = eval('get_txt_counterparty_' + row_id + '_value()');
        			var volume_left2 = eval('get_txt_volume_left_' + row_id + '_value()');
        			var uom2 = eval('get_txt_uom_' + row_id + '_value()');
        			var volume2 = eval('get_txt_book_vol_' + row_id + '_value()');
                    
        			if (document.getElementById("txt_select_schedule_" + row_id).checked == true) {
        				x = '<PSRecordset ';
        				x = x + ' id="' + source_deal_detail_id2 + '"';
        				x = x + ' volume="' + volume2 + '"';
        				x = x + '></PSRecordset>';
        				xmltext = xmltext + x;
        			}
        
        			rcount = rcount + 1;
        		}
        		row = row + 1;        
        	}
        
        	xmltext = xmltext + "</Root>";
        
        	return xmltext;
        }
        
        function get_settlement_cash_id() {
        	var totrow =  <?php echo $tot_row; ?> ;
        	var column = 1;
        	var row = 1;
        	var xmltext = '<Root>';
        	var x = '';
        	var y = '';
        	var settlement_id = "";
        	var comma = ',';
            
        	while (row <= totrow) {
        		row_id = row - 1;
        
        		if (document.getElementById("deletecashsettlement_" + row_id).checked == true) {
        			id = eval('document.formApplyCash.deletecashsettlement_' + row_id + '.value');
        
        		} else {
        			id = '';
                }
                
        		if (id != '') {
        			if (row == 1)        
        				settlement_id = comma + id;
        			else        
        				settlement_id = settlement_id + comma + id;
                }
                
        		row = row + 1;
        		comma = ","
        	}
            
        	var str_id = settlement_id.charAt(0);        
        	var str_id1 = settlement_id.replace(str_id, ' ');        
        	return str_id1;        
        }
        
        function test() {        
        	return alert("hello");
        }
        
        function zoomIn(obj) {        
        	l = 5;
        	t = 10;        
        	zoom_div_receipt = parent.document.getElementById('testReceipt');
        	zoom_div_delivery = parent.document.getElementById('testDelivery');
        
        	if (flag == 'r') {
        		zoom_div = zoom_div_receipt;
        		frame_name = 'receipt_frame';
        	} else {
        		zoom_div = zoom_div_delivery;
        		frame_name = 'delivery_frame';
        	}
        
        	var img_div = document.getElementById("img")
        
    		if (img_div.alt == 'zoom') {        
    			org_win_width = window.dialogWidth;
    			org_win_height = window.dialogHeight;        
    			window.dialogTop = 0;
    			window.dialogLeft = 0;        
    			w = screen.availWidth;
    			h = screen.availHeight - 30;        
    			window.dialogWidth = w + "px";
    			window.dialogHeight = h + "px";        
    			org_left = zoom_div.style.left;        
    			org_top = zoom_div.style.top;
    			org_width = zoom_div.style.width;
    			org_height = zoom_div.style.height;        
    			zoom_div.style.left = l;
    			zoom_div.style.top = t;        
    			resize_iframes(frame_name, w - 20, h - 50);
    			img_div.alt = 'undo_zoom';
    
    			if (flag == 'r') {
    				zoom_div_delivery.style.display = 'none';
    		  }	else {
    				zoom_div_receipt.style.display = 'none';
    			}        
    		} else {        
    			window.dialogTop = 40;
    			window.dialogLeft = 20;        
    			w = org_win_width;
    			h = org_win_height;        
    			window.dialogWidth = w + "px";
    			window.dialogHeight = h + "px";
    			zoom_div.style.left = org_left;
    			zoom_div.style.top = org_top;        
    			resize_iframes(frame_name, org_width, org_height);
    			img_div.alt = 'zoom';
    
    			if (flag == 'r')
    				zoom_div_delivery.style.display = 'block';
    			else {
    				zoom_div_receipt.style.display = 'block';
    			}        
    		}        
        }
        
        function resize_iframes(siframe_id, w, h) {        
        	var oDHTMLiFrame = parent.document.frames[siframe_id];
        	var oDHTMLiFrameDocument = oDHTMLiFrame.document
        	var oDOMiFrame = parent.document.getElementById(siframe_id);
        	var oDOMiFrameDocument = oDOMiFrame.document
        	var oDIVwholePage = oDHTMLiFrameDocument.all['DIVwholePage'];
        	oDOMiFrame.height = h;
        	oDOMiFrame.width = w;
        
        }
        
        function load_receipt_Xml() {
        	parent.document.getElementById("receipt_xml").value = get_schedule_detail();
        }
        
        </script>
   
</html>

