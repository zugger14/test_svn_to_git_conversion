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
                                text:           "Transactions Report",
                                header:         false
                            }
                        ]';

        $layout_name = 'transaction_report_layout';
        $name_space = 'transaction_report';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
        
        echo $layout_obj->close_layout();
    ?> 
</body>
<script type="text/javascript">
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

    function load_report_detail(result) {
        var result_length = result.length;
        var tab_json = '';
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }
        tab_json = '{tabs: [' + tab_json + ']}';
        
        report_ui["report_tabs_" + active_object_id] = transaction_report.transaction_report_layout.cells("a").attachTabbar();
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
        
        var att_obj = transaction_report.transaction_report_layout.cells('a');
        parent.set_apply_filter(att_obj);
        var today = new Date(); 
        var inner_tab_obj = transaction_report.transaction_report_layout.cells("a").getAttachedObject();
        inner_tab_obj.forEachTab(function(tab){
            var form_obj = tab.getAttachedObject();
            form_obj.setItemValue('as_of_date',today);
            form_obj.attachEvent("onInputChange", function (name, value, form) {
                if (value && name == 'deal_id_from' || name == 'deal_id_to') {
                    var deal_id_from = form_obj.getItemValue('deal_id_from');
                    var deal_id_to = form_obj.getItemValue('deal_id_to');
                    if(deal_id_from && deal_id_to && deal_id_from > deal_id_to) {
                        show_messagebox("ID From should be less than ID To.");
                        form_obj.setItemValue(name, null);
                    }
                } else if (value && name == 'gis_cert_number' || name == 'gis_cert_number_to') {
                    var gis_cert_number = form_obj.getItemValue('gis_cert_number');
                    var gis_cert_number_to = form_obj.getItemValue('gis_cert_number_to');
                    if(gis_cert_number && gis_cert_number_to && gis_cert_number > gis_cert_number_to) {
                        show_messagebox("Cert.# From should be less than Cert.# To.");
                        form_obj.setItemValue(name, null);
                    }
                } else if (value && name == 'gen_date_from' || name == 'gen_date_to') {
                    var gen_date_from = form_obj.getItemValue('gen_date_from');
                    var gen_date_to = form_obj.getItemValue('gen_date_to');
                    if(gen_date_from && gen_date_to && gen_date_from > gen_date_to) {
                        show_messagebox("Vintage From cannot be greater than Vintage To.");
                        form_obj.setItemValue(name, null);
                    }
                } else if (value && name == 'deal_date_from' || name == 'deal_date_to') {
                    var deal_date_from = form_obj.getItemValue('deal_date_from');
                    var deal_date_to = form_obj.getItemValue('deal_date_to');
                    if(deal_date_from && deal_date_to && deal_date_from > deal_date_to) {
                        show_messagebox("Deal Date From cannot be greater than Deal Date To.");
                        form_obj.setItemValue(name, null);
                    }
                } else if (value && name == 'expiration_from' || name == 'expiration_to') {
                    var expiration_from = form_obj.getItemValue('expiration_from');
                    var expiration_to = form_obj.getItemValue('expiration_to');
                    if(expiration_from && expiration_to && expiration_from > expiration_to) {
                        show_messagebox("Expiration From cannot be greater than Expiration To.");
                        form_obj.setItemValue(name, null);
                    }
                }
                return false;
            });
        });
    }

    function report_parameter(is_batch) {
        var inner_tab_obj = transaction_report.transaction_report_layout.cells("a").getAttachedObject();
        var validate_flag = 0;
        
        var is_assigned_state_blank = false;
        var filter_list = new Array();
        var param = '';
        
        inner_tab_obj.forEachTab(function(tab){
            var tab_name = tab.getText();
            form_obj = tab.getAttachedObject();
            
            var status = validate_form(form_obj);
            var radio_flag = '';
            
            if (status == false) {
                validate_flag = 1;
            }

            var form_data = form_obj.getFormData();
            
            if ((form_data.summary_option == 'x' || form_data.summary_option == 'e') && form_data.assigned_state === '' && tab.getText() == 'General') {
                is_assigned_state_blank = true;
            }

            form_obj.forEachItem(function(name) {
                if (name.substr(0, 6) == 'dhxId_') {
                    return true;
                }

                var item_type = form_obj.getItemType(name);
                var item_value;

                if (item_type == 'calendar') {
                    item_value = form_obj.getItemValue(name, true);
                } else if (item_type == 'combo' && name == 'program_scope') {
                    item_value = ((form_obj.getCombo(name)).getChecked()).join(',');
                } else if (item_type == 'radio') {
                    var radio_checked_value = form_obj.getCheckedValue(name);
                    if(form_obj.isItemChecked(name, radio_checked_value) && radio_flag != name){
                        radio_flag = name;
                        item_value = radio_checked_value;
                    } else {
                        return true;
                    }
                } else if (name == 'book_structure' || name == 'browse_book_structure' || name == 'clear_book_structure') {
                    return true;
                } else {
                    item_value = form_obj.getItemValue(name);
                }

                if (item_value.length > 0) {
                    param += ', @' + name + '=' + '\'' + item_value + '\'';
                    var item_label;
                    if (name == 'summary_option') {
                        item_label = 'Report Group Type';
                    } else {

                        var lbl = form_obj.getItemLabel(name);
                        
                        item_label = $(lbl).is('a')? $(lbl).text(): lbl;
                    }
                    
                    filter_list.push(item_label + '="' + item_value + '"');
                }
                
            });
        });

        if (is_assigned_state_blank) {
            validate_flag = 1;
            show_messagebox('Select Assigned Jurisdiction.');
        }

        var param_len = param.length;
        var param_string = (param.trim()).substr(1, param_len-1);

        filter_list = filter_list.join(' | ');
        var exec_call = 'EXEC spa_get_rec_activity_report' + param_string + '&applied_filters=' + filter_list;

        if (validate_flag == 1) {
            return false;
        }
        
        if (exec_call == null) {
            return false;
        } else {
            return exec_call;
        }
    }
</script>