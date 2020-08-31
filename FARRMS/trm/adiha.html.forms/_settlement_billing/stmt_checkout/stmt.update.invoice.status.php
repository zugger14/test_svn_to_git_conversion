<?php
/**
* Stmt update invoice status screen
* @copyright Pioneer Solutions
*/
?>
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
    $xml = $_POST["xml"] ?? '';
    $form_namespace = 'updateInvoiceStatus';
    
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save"}]';

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();

    echo $layout_obj->init_layout('update_invoice', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    // attach filter form
    $form_name = 'update_invoice_status';
    $sp_url_invoice_status = "EXEC spa_staticdatavalues @flag='h', @type_id=20700";
    echo "invoice_status_dropdown = ".  $form_obj->adiha_form_dropdown($sp_url_invoice_status, 0, 1, false, '20706', 2) . ";"."\n";
    
    $form_json = '[  
                    {  
                      "type":"settings",
                      "position":"label-top"
                    },
                    {  
                      type:"block",
                      blockOffset:'.$ui_settings['block_offset'].',
                      list:[  
                         {  
                            "type":"combo",
                            "name":"invoice_status",
                            "label":"Workflow Status",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"'.$ui_settings['offset_left'].'",
                            "labelWidth":"auto",
                            "inputWidth":"'.$ui_settings['field_size'].'",
                            "tooltip":"Workflow Status",
                            "filtering":"true",
                            "options": invoice_status_dropdown
                         },
                         {  
                            "type":"newcolumn"
                         }
                      ]
                    }
                ]';
                
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
	updateInvoiceStatus.save_click = function(id) {
		if (id == 'save') {
            var xml = '<?php echo $xml; ?>';
			form_data = updateInvoiceStatus.update_invoice_status.getFormData();
   
	        var param = {
	            "flag": "w",
	            "action": "spa_stmt_invoice",
	            "xml": xml
	        };
            
	        for (var a in form_data) {
	            if (form_data[a] != '' && form_data[a] != null) {
	                if (updateInvoiceStatus.update_invoice_status.getItemType(a) == 'calendar') {
	                    value = updateInvoiceStatus.update_invoice_status.getItemValue(a, true);
	                } else {
	                    value = form_data[a];
	                }

	                param[a] = value;
	            }
	        }

            adiha_post_data('alert', param, '', '', 'updateInvoiceStatus.save_callback');
		}
	}

    updateInvoiceStatus.save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            setTimeout(function() { 
                parent.win.close(); 
            }, 1000);
        }
    }
    function alert_hyperlink(report_name, exec_call, height, width) {
        dhtmlx.modalbox.hide(box);
        parent.maximize_window();
        open_spa_html_window(report_name, exec_call, height, width);
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