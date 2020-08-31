<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>

<body class = "bfix"> 
    <?php 
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
        $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
        $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Deal Settlement Report",
                                header:         false
                            }
                        ]';

        $layout_name = 'gas_position_report_layout';
        $name_space = 'gas_position_report';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);

        echo $layout_obj->close_layout();
    ?> 
</body> 

<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>

<script>
    var active_object_id = '<?php echo $active_object_id; ?>';
    var report_type = '<?php echo $report_type; ?>';
    var report_id = '<?php echo $report_id; ?>';
    var report_name = '<?php echo $report_name; ?>';
    report_ui = {};

    $(function(){
        data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": report_id,
                    "template_name": report_name,
                    "parse_xml": ""
                 };
        
        adiha_post_data('return_array', data, '', '', 'load_report_detail', '');
    });

    function get_message(code) {
        switch (code) {
            case 'TERM_DATE_VALIDATION':
                return '<b>Term Start</b> cannot be greater than <b>Term End</b>.';
        }
    }

    function load_report_detail(result) {
        var result_length = result.length;
        var tab_json = '';

        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }

        tab_json = '{tabs: [' + tab_json + ']}';
        
        report_ui["report_tabs_" + active_object_id] = gas_position_report.gas_position_report_layout.cells("a").attachTabbar();
        report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);

        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
            
            if (result[j][2]) {
                report_ui["form_" + j].loadStruct(result[j][2]);
                var form_name = 'report_ui["form_" + ' + j + ']';
                attach_browse_event(form_name, report_id);
            }
        }
            
        report_ui["report_tabs_" + active_object_id].forEachTab(function(tab){
            form_obj = tab.getAttachedObject();
        });
            
        var att_obj = gas_position_report.gas_position_report_layout.cells('a');
        parent.set_apply_filter(att_obj);
    }

    function report_parameter(is_batch) {
        var inner_tab_obj = gas_position_report.gas_position_report_layout.cells("a").getAttachedObject();
        var validate_flag = 0;
        var param_list = new Array();
        var filter_list = new Array();

        inner_tab_obj.forEachTab(function(tab) {
            var tab_name = tab.getText();
            form_obj = tab.getAttachedObject();

            var status = validate_form(form_obj);

            if (status == false) {
                validate_flag = 1;
            }

            form_obj.forEachItem(function(name) {
                var item_type = form_obj.getItemType(name);

                if (item_type == 'calendar') {
                    value = form_obj.getItemValue(name, true);

                    if (value != '') { 
                        filter_list.push(form_obj.getItemLabel(name) + '="' + value + '"');
                    }
                } else if (item_type == 'combo') {
                    var combo_obj = form_obj.getCombo(name);
                    value = combo_obj.getChecked();

                    if (value == '') {
                        value = combo_obj.getSelectedValue();
                        filter_value = combo_obj.getSelectedText();
                    }

                    if (value != '') { 
                        filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                    }
                } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button') {
                    value = form_obj.getItemValue(name);
                    filter_value = form_obj.getItemValue(name);

                        if (value != '' 
                        && name != 'spa_name' 
                        && name != 'subsidiary_id'
                        && name != 'strategy_id'
                        && name != 'book_id'
                        && name != 'subbook_id') {
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                        }
                    }
            });

            subsidiary_id = form_obj.getItemValue('subsidiary_id');
            strategy_id = form_obj.getItemValue('strategy_id');
            book_entity_id = form_obj.getItemValue('book_id');
            term_start = form_obj.getItemValue('term_start', true);
            term_end = form_obj.getItemValue('term_end', true);
            commodity = form_obj.getItemValue('commodity');
            group_by = form_obj.getItemValue('group_by');
            round = form_obj.getItemValue('round');
            major_location = form_obj.getItemValue('major_location');
            minor_location = form_obj.getItemValue('minor_location');
            counterparty = form_obj.getItemValue('counterparty');
            daily_rolling = 'd';
        });

        if ((term_start !== "") && (term_end !== "") && (term_start > term_end)) {
            validate_flag = 1;
            show_messagebox(get_message('TERM_DATE_VALIDATION')); 
        }

        param_list.push("'" + subsidiary_id + "'");
        param_list.push("'" + strategy_id + "'");
        param_list.push("'" + book_entity_id + "'");
        param_list.push("'" + commodity + "'");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("'" + term_start + "'");
        param_list.push("'" + term_end + "'");
        param_list.push("'" + counterparty + "'");
        param_list.push("NULL");
        param_list.push("'" + daily_rolling + "'");
        param_list.push("'" + round + "'");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("'" + group_by + "'");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("'" + major_location + "'");
        param_list.push("'" + minor_location + "'");
        param_list.push("NULL");
        param_list.push("NULL");

        var param_string = param_list.toString();
        param_string = param_string.replace(/''/g, 'NULL');
        param_string = param_string.replace(/'%%'/g, 'NULL');
        param_string = param_string.replace(/'%/g, '');
        param_string = param_string.replace(/%'/g, '');
            
        filter_list = filter_list.join(' | ') 

        var exec_call = 'EXEC spa_position_report_sch_n_delivery ' + param_string + '&applied_filters=' + filter_list + '&gen_as_of_date=1';

        if (validate_flag == 1) {
            return false;
        }
        
        if (exec_call == null) {
            return false;
        } else {
            return exec_call
        }
    }
</script>