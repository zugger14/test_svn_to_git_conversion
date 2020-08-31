<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
     <?php 
    include "../../../adiha.php.scripts/components/include.file.v3.php";
    $report_paramset_hash = get_sanitized_value($_GET['report_paramset_hash'] ?? '');
    $report_filter_id = get_sanitized_value($_GET['report_filter_id'] ?? '');

    //getting report param set id
    $xml_file1 = "EXEC spa_workflow_schedule  @flag='t', @paramset_hash='" . $report_paramset_hash . "'";
    $return_value1 = readXMLURL($xml_file1);
    $report_paramset_id = $return_value1[0][0]; 
 
    $form_namespace = 'eod_parameters';
    
    $layout_json = '[
                        {id: "a", text: "Apply Filters", height:100,header: true},
						{id: "b", text: "Parameters", header: true}
                    ]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('eod_parameters_layout', '', '2E', $layout_json, $form_namespace);
    

	$xml_file = "EXEC spa_view_report  @flag='c',@report_name='',@report_id='',@report_param_id='" . $report_paramset_id . "',@call_from='report_manager_dhx',@view_id=NULL";
	$return_value = readXMLURL($xml_file);
	$form_json = $return_value[0][2];
    
    echo $layout_obj->attach_form('parameter_form', 'b');
    $form_obj = new AdihaForm();
    echo $form_obj->init_by_attach('parameter_form', $form_namespace);
    echo $form_obj->load_form($form_json);
	
	echo $layout_obj->close_layout();
    ?>
	
	<script type="text/javascript">
		 $(function(){
			attach_browse_event('eod_parameters.parameter_form');
			
			var filter_obj = eod_parameters.eod_parameters_layout.cells('a').attachForm();
			var layout_cell_obj = eod_parameters.eod_parameters_layout.cells('b');
			var report_id = '<?php echo $report_paramset_id; ?>';
            var report_filter_id = '<?php echo $report_filter_id; ?>';  
			var report_type = 1;
			load_form_filter(filter_obj, layout_cell_obj, report_id, report_type);
            var filter_cmb_obj = filter_obj.getCombo('apply_filters');

            setTimeout(function(){ 
                  filter_obj.setItemValue('apply_filters',report_filter_id);  
                  apply_filter_change(filter_obj, layout_cell_obj, report_id, report_type);
            },300); 
            
		 });
		 
	</script>
    
    