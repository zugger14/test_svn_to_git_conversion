<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php'; 

    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    $source_deal_detail_id = get_sanitized_value($_GET['source_deal_detail_id'] ?? '');
    $cal_type =  get_sanitized_value($_GET['cal_type'] ?? '');
    $term =  get_sanitized_value($_GET['term'] ?? '');
    $shipment_id =  get_sanitized_value($_GET['shipment_id'] ?? '');
    $ticket_id =  get_sanitized_value($_GET['ticket_id'] ?? '');
    $as_of_date =  get_sanitized_value($_GET['as_of_date'] ?? '');

    if ($call_from == 'accrual_gl') { 
        $sp_load_grid = "EXEC spa_stmt_checkout @flag = 'accrual_final_gl', @accrual_or_final_flag = 'a', @source_deal_detail_id = '" . $source_deal_detail_id . "'" ;  
        $grid_name = 'AccrualFinalGLReport';
    } else if ($call_from == 'final_gl') { 
        $sp_load_grid = "EXEC spa_stmt_checkout @flag = 'accrual_final_gl', @accrual_or_final_flag = 'f', @source_deal_detail_id = '" . $source_deal_detail_id . "'" ;  
        $grid_name = 'AccrualFinalGLReport';
    }  else if ($call_from == 'price') {
         $sp_load_grid = "EXEC spa_stmt_checkout @flag = 'price_report', @source_deal_detail_id = '" . $source_deal_detail_id . "', @term_filter = '" . $term . "', @cal_type_filter = '" . $cal_type . "',  @filter_as_of_date = '" . $as_of_date . "', @shipment_id = " . $shipment_id . ", @ticket_id= " . $ticket_id;  
         $grid_name = 'StmtPriceReport';
    } else if ($call_from == 'volume') { 
         $sp_load_grid = "EXEC spa_stmt_checkout @flag = 'volume_report', @source_deal_detail_id = '" . $source_deal_detail_id . "'"; 
         $grid_name = 'StmtVolumeReport';
    } else if ($call_from == 'amount') {
         $sp_load_grid = "EXEC spa_stmt_checkout @flag = 'amount_report', @source_deal_detail_id = '" . $source_deal_detail_id . "'";  
         $grid_name = 'StmtAmountReport';
    } 

    $json = '[
                {
                    id:             "a",
                    text:           "Report",
                    header:         false,
                    collapse:       false,
                    width:          390,
                    height:         200
                } 
            ]';

    $namespace = 'StmtReport';
    $StmtReport_layout_obj = new AdihaLayout();
    echo $StmtReport_layout_obj->init_layout('StmtReport_layout', '', '1C', $json, $namespace);

    //Attaching Toolbar  
    $grid_toolbar_json = '[
                        {id:"excel", type: "button", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        { type: "separator" },
                        {id:"pdf", type: "button", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                     ]';

    //Attaching  grid     
    echo $StmtReport_layout_obj->attach_toolbar_cell('StmtReport_grid_toolbar', 'a');
    $StmtReport_grid_toolbar_obj = new AdihaToolbar();
    echo $StmtReport_grid_toolbar_obj->init_by_attach('StmtReport_grid_toolbar', $namespace);
    echo $StmtReport_grid_toolbar_obj->load_toolbar($grid_toolbar_json); 
    echo $StmtReport_grid_toolbar_obj->attach_event('', 'onClick', 'StmtReport_grid_toolbar_onclick');

    echo $StmtReport_layout_obj->attach_grid_cell('StmtReport_grid', 'a');
    $StmtReport_grid_obj = new GridTable($grid_name);   
    echo $StmtReport_grid_obj->init_grid_table('StmtReport_grid', $namespace); 
    echo $StmtReport_grid_obj->set_search_filter(true); 
    echo $StmtReport_grid_obj->return_init();
	if ($grid_name == 'AccrualFinalGLReport') {
		echo $StmtReport_grid_obj->load_grid_data($sp_load_grid, 'g', '', 'ReportGrid_callback');
	} else {
		echo $StmtReport_grid_obj->load_grid_data($sp_load_grid);
	}
    echo $StmtReport_grid_obj->load_grid_functions();
    
    echo $StmtReport_layout_obj->close_layout();
    ?>
    
    <script type="text/javascript">   
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>"; 
         
        
       //  $(function(){   
       //       
       // });
        
         
        function StmtReport_grid_toolbar_onclick(name, value) {             
            if (name == 'excel') {
                StmtReport.StmtReport_grid.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            } else if (name == 'pdf'){
                StmtReport.StmtReport_grid.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            } 
        }   

		ReportGrid_callback = function() {
			var show_counterparty = '';
			var show_charge = '';
			StmtReport.StmtReport_grid.forEachRow(function(id){
                    var chk_counterparty = StmtReport.StmtReport_grid.cells(id, StmtReport.StmtReport_grid.getColIndexById('counterparty')).getValue();
					var chk_charge = StmtReport.StmtReport_grid.cells(id, StmtReport.StmtReport_grid.getColIndexById('charge_type')).getValue();
					
					if (chk_counterparty == show_counterparty) {
						StmtReport.StmtReport_grid.cells(id, StmtReport.StmtReport_grid.getColIndexById('counterparty')).setValue('');
					}
					
					if (chk_charge == show_charge) {
						StmtReport.StmtReport_grid.cells(id, StmtReport.StmtReport_grid.getColIndexById('charge_type')).setValue('');
					}
					
					show_counterparty = chk_counterparty;
					show_charge = chk_charge
					
					if (chk_charge == 'Sub-Total') {
						StmtReport.StmtReport_grid.setRowColor(id,'#c9e7f2'); 
					}
            });
		}
         
        
    </script>