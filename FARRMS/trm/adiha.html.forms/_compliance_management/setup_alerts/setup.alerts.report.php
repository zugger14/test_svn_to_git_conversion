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
    
    $mode = get_sanitized_value($_GET["mode"] ?? '');
    $alert_sql_id = get_sanitized_value($_GET["alert_sql_id"] ?? '');
    $alert_report_id = get_sanitized_value($_GET["alert_report_id"] ?? '');
    $main_table_id = get_sanitized_value($_GET["main_table_id"] ?? '');
    $has_rights = get_sanitized_value($_REQUEST["right_id"] ?? '');

    if ($has_rights != 0) {
        $rights = true;
    } else {
        $rights = false;
    }
    
    if ($mode == 'u') {
        $sql = "EXEC spa_alert_reports @flag='a', @alert_report_id=$alert_report_id";
        $return_value = readXMLURL2($sql);
        $alert_report_id = $return_value[0]['alert_reports_id'];
        $alert_sql_id = $return_value[0]['alert_sql_id'];
        $is_report_writer = $return_value[0]['report_writer'];
        $paramset_hash = $return_value[0]['paramset_hash'];
        $my_report_name = $return_value[0][4];
        $report_param = $return_value[0]['report_param'];
        $report_desc = $return_value[0]['report_desc'];
        $table_prefix = $return_value[0]['table_prefix'];
        $table_suffix = $return_value[0]['table_postfix'];
    } else {
        $is_report_writer = 'n';
        $paramset_hash = '';
        $report_param = '';
        $report_desc = '';
        $table_prefix = '';
        $table_suffix = '';
    }
    
    $form_namespace = 'alert_report';

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save", enabled: "'.$rights.'"}]';
    
    $form_json = '[{
                    "type": "settings",
                    "position": "label-top"
                },{
                    type: "block",
                    blockOffset: 10,
                    list: [{
                        "type": "checkbox",
                        "name": "report_writer",
                        "label": "Report Writer",
                        "position": "label-right",
                        "offsetLeft": "10",
                        "labelWidth": "auto",
                        "inputWidth": "auto",
                        "tooltip": "Report Writer",
                        "value": "'.$is_report_writer.'"
                    }, {
                        "type": "newcolumn"
                    }]
                }, {
                    type: "block",
                    blockOffset: 10,
                    list: [{
                        "type": "input",
                        "name": "report_desc",
                        "label": "Report Description",
                        "validate": "NotEmptywithSpace",
                        "position": "label-top",
                        "offsetLeft": "10",
                        "labelWidth": "auto",
                        "inputWidth": "310",
                        "tooltip": "Report Description",
                        "value": "'.$report_desc.'"
                    }, {
                        "type": "newcolumn"
                    }]
                }, {
                    type: "block",
                    blockOffset: 10,
                    list: [{
                        "type": "input",
                        "name": "table_prefix",
                        "label": "Report Table Prefix",
                        "validate": "",
                        "position": "label-top",
                        "offsetLeft": "10",
                        "labelWidth": "auto",
                        "inputWidth": "150",
                        "tooltip": "Workflow Only",
                        "required": "false",
                        "checked": "false",
                        "offsetTop": "10",
                        "value": "'.$table_prefix.'"
                    }, {
                        "type": "newcolumn"
                    }, {
                        "type": "input",
                        "name": "table_suffix",
                        "label": "Report Table Suffix",
                        "validate": "",
                        "position": "label-top",
                        "offsetLeft": "10",
                        "labelWidth": "auto",
                        "inputWidth": "150",
                        "tooltip": "Workflow Only",
                        "required": "false",
                        "checked": "false",
                        "offsetTop": "10",
                        "value": "'.$table_suffix.'"
                    }, {
                        "type": "newcolumn"
                    }]
                }]';

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();

    echo $layout_obj->init_layout('report', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    // attach filter form
    $form_name = 'frm_alert_report';
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var mode = '<?php echo $mode; ?>';
    var alert_sql_id = '<?php echo $alert_sql_id; ?>';
    var alert_report_id = '<?php echo $alert_report_id; ?>';
    var main_table_id = '<?php echo $main_table_id; ?>';
    
    alert_report.save_click = function(id) {
        switch(id) {
            case "save":
                var report_writer = (alert_report.frm_alert_report.isItemChecked('workflow_only')) ? 'y' : 'n';
                var paramset_hash = 'NULL';
                var report_parameter = 'NULL';
        		var report_description = 'NULL';
        		var table_prefix = 'NULL';
        		var table_suffix = 'NULL';
                var report_params = 'NULL';
        
                if (report_writer == 'y') {
                    report_parameter    = 'NULL';
                    paramset_hash       = 'NULL';
                    report_params       = 'NULL';
                }
        		if (report_writer == 'n') {
        			report_description = alert_report.frm_alert_report.getItemValue('report_desc');
        			table_prefix       = alert_report.frm_alert_report.getItemValue('table_prefix');
        			table_suffix       = alert_report.frm_alert_report.getItemValue('table_suffix');
        		}
                
                data = {
                            "action": "spa_alert_reports", 
                            "flag": mode, 
                            "alert_report_id" : alert_report_id,
                            "alert_sql_id": alert_sql_id,
                            "report_writer": report_writer,
                            "paramset_hash": paramset_hash,
                            "report_parameter": report_parameter,
                            "report_description": report_description,
                            "table_prefix": table_prefix,
                            "table_suffix": table_suffix,
                            "main_table_id": main_table_id,
                            "report_params": report_params
                        };
                adiha_post_data("alert", data, "", "", "");
                break;
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