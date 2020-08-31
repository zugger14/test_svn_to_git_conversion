<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $calc_id = get_sanitized_value($_GET["calc_id"] ?? '');
    $calc_detail_id = get_sanitized_value($_GET["calc_detail_id"] ?? '');
    $as_of_date = get_sanitized_value($_GET["as_of_date"] ?? '');
    $prod_date = get_sanitized_value($_GET["prod_date"] ?? '');
    $mode = get_sanitized_value($_GET["mode"] ?? '');
    $has_rights = get_sanitized_value($_REQUEST["right_id"] ?? '');
    $form_namespace = 'manualLineItems';

    if ($has_rights != 0) {
        $rights = true;
    } else {
        $rights = false;
    }

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save", enabled: "' . $rights . '"}]';

    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10221330', @template_name='ManualLineItems', @group_name='manual_line_items', @parse_xml = '<Root><PSRecordSet calc_detail_id=\"" . $calc_detail_id . "\"></PSRecordSet></Root>'";
    $filter_arr = readXMLURL2($filter_sql);
    $form_json = $filter_arr[0]['form_json'];

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();

    echo $layout_obj->init_layout('split_invoice', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    // attach filter form
    $form_name = 'manual_line_items';
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var mode = '<?php echo $mode; ?>';
	var prod_date = '<?php echo $prod_date; ?>';

	$(function() {
        if(mode == 'x') {
            manualLineItems.manual_line_items.setItemValue('inv_prod_date', dates.convert_to_sql(prod_date));
            manualLineItems.manual_line_items.setItemValue('prod_date', dates.convert_to_sql(prod_date));
        }
	})
    
	manualLineItems.save_click = function(id) {
		if (id == 'save') {
            var calc_id = '<?php echo $calc_id; ?>';
            var as_of_date = '<?php echo $as_of_date; ?>';
            
            var status = validate_form(manualLineItems.manual_line_items);
            
            if (status) {
    			form_data = manualLineItems.manual_line_items.getFormData();
    	        var xml = '<Root><PSRecordSet';
    	        for (var a in form_data) {
    	            if (form_data[a] != '' && form_data[a] != null) {
                        if (manualLineItems.manual_line_items.getItemType(a) == 'calendar') {
    	                    value = manualLineItems.manual_line_items.getItemValue(a, true);
    	                } else {
    	                    value = form_data[a];
    	                }
    	                
    	                xml += ' ' + a + '="' + value + '"';
    	            }
    	        }
    	        xml += ' calc_id="' + calc_id + '" as_of_date="' + as_of_date + '">';
                xml += '</PSRecordSet></Root>';
                
    	        var param = {
    	            "flag": mode,
    	            "action": "spa_settlement_history",
    	            "xml": xml
    	        };
                
                adiha_post_data('return_json', param, '', '', 'save_click_callback', '');
             }
		}
	}
    
    function save_click_callback(result) {
        var return_data = JSON.parse(result);
        var status = return_data[0].status;
        
        if (status == 'Error') {
           show_messagebox(return_data[0].message);
        } else {
            if (mode == 'x') {
                mode = 'y';
                var new_id = return_data[0].recommendation;
                manualLineItems.manual_line_items.setItemValue('calc_detail_id', new_id);
            } 
            
            dhtmlx.message({
                text:return_data[0].message,
                expire:1000
            });

            setTimeout(function() {
                window.parent.manual_line_item_window.window('w1').close();
            }, 1000);
        }
    }

</script>
<style type="text/css">
html, body {
    width: 100%;
    height: 100%;
    margin: 0px;
    padding: 0px;
    background-color: #ebebeb;
    overflow: hidden;
}
</style>