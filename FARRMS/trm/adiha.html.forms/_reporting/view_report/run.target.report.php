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
                                text:           "Run Targer Report.",
                                header:         false
                            }
                        ]';

        $layout_name = 'run_target_report_layout';
        $name_space = 'run_target_report';
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
        
        function load_report_detail(result) {
            var result_length = result.length;
            var num = 1;
            var tab_json = '';
            for (i = 0; i < result_length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);
            }
            
            tab_json = '{tabs: [' + tab_json + ']}';
            report_ui["report_tabs_" + active_object_id] = run_target_report.run_target_report_layout.cells("a").attachTabbar();
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            tab_id = 'detail_tab_' + result[0][0];
            report_ui["form_" + active_object_id] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
            report_ui["form_" + active_object_id].loadStruct(result[0][2]);
            
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
                
                if (result[j][2]) {
                    report_ui["form_" + j].loadStruct(result[j][2], function(){
                        var jurisdiction_combo = report_ui["form_" + j].getCombo('jurisdiction');
                        jurisdiction_combo.setChecked(0, true);
                    });
                    var form_name = 'report_ui["form_" + ' + j + ']';
                    attach_browse_event(form_name, report_id);
                }
            }
                  
            var att_obj = run_target_report.run_target_report_layout.cells('a');
            parent.set_apply_filter(att_obj);
            
        }
        
        function report_parameter() {

            var inner_tab_obj = run_target_report.run_target_report_layout.cells("a").getAttachedObject();
            var filter_list = new Array(); 
            
            inner_tab_obj.forEachTab(function(tab){
                form_obj = tab.getAttachedObject();
                var tab_name = tab.getText();
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
                    } else if (item_type == 'checkbox') { 
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        }  
                    } 
                  
                });
                 
               });
        
            /*--Validation for required fields and custom validation for date fields--*/
            if (form_obj instanceof dhtmlXForm) {                
                data = form_obj.getFormData();
                var status = validate_form(form_obj);
                if (status == false) {
                    return false 
                } 

                if(status) {
                    var validation_status = true;
                    for (var a in data) {
                        field_label = a;
                        field_value = data[a];
                        label = form_obj.getItemLabel(a);
                        value = form_obj.getItemValue(a);
                
                  /*      if(field_label == "jurisdiction") {
                            cmb_jurisdiction_obj = form_obj.getCombo("jurisdiction");
                            jurisdiction = cmb_jurisdiction_obj.getChecked().join(',');
                            jurisdiction_length = jurisdiction.length;
                        
                            if (jurisdiction_length == 0) {
                                show_messagebox('Please select at least one <strong>jurisdiction</strong>.');  
                                return 
                            }
                        }*/
                    }
                    
                } else {
                    validation_status = false;   
                }
            }
                        
            var param_list = new Array();
            //spa_name = 'spa_target_report';
            spa_name = 'spa_view_target_report';
            grouping_option = form_obj.getItemValue('grouping_option');
            subsidiary_id = form_obj.getItemValue('subsidiary_id');
            strategy_id = form_obj.getItemValue('strategy_id');
            book_entity_id = form_obj.getItemValue('book_id');
            
            compliance_year_from = form_obj.getItemValue('compliance_year_from');
            compliance_year_to = form_obj.getItemValue('compliance_year_to');

            if(compliance_year_from > compliance_year_to) {
                show_messagebox('<strong>Compliance Year From</strong> cannot be greater than <strong>Compliance Year To</strong>.');
                return
            }

            assignment_type = form_obj.getItemValue('assignment_type');
            report_type = form_obj.getItemValue('report_type');
            round_value = form_obj.getItemValue('round_value');

           /*cmb_jurisdiction_obj = form_obj.getCombo("jurisdiction");
            jurisdiction = cmb_jurisdiction_obj.getChecked().join(',');*/
            jurisdiction = form_obj.getItemValue('jurisdiction');
            cmb_deal_status_obj = form_obj.getCombo("deal_status");
            deal_status = cmb_deal_status_obj.getChecked().join(',');

            cmb_tier_type_obj = form_obj.getCombo("tier_type");
            tier_type = cmb_tier_type_obj.getChecked().join(',');

            var enable_paging = form_obj.isItemChecked('enable_paging');
            enable_paging = (enable_paging == true) ? '1' : '0';

            var assignment_priority = form_obj.getItemValue('assignment_priority');
            var target_report = form_obj.getItemValue('target_report');
            
            //param_list.push
            param_list.push("'" + grouping_option + "'");
            param_list.push("'" + subsidiary_id + "'");
            param_list.push("'" + strategy_id + "'");
            param_list.push("'" + book_entity_id + "'");

            param_list.push("'" + compliance_year_from + "'");
            param_list.push("'" + compliance_year_to + "'");
            param_list.push("'" + assignment_type + "'");
            param_list.push("'" + jurisdiction + "'");

            param_list.push("'" + report_type + "'");
           
            param_list.push("'" + assignment_priority + "'");
            param_list.push("'" + target_report + "'");
            param_list.push("'" + tier_type + "'");
            param_list.push("'" + round_value + "'");
                         
            var param_string = param_list.toString();
            param_string = param_string.replace(/""/g, 'NULL');
            param_string = param_string.replace(/''/g, 'NULL');
           
            filter_list = filter_list.join(' | ')   
           
            if(validation_status) {
                if(enable_paging == 1){
                    var exec_call  = "EXEC " + spa_name + " " + param_string + '&enable_paging=true&np=1&applied_filters=' + filter_list;
                } else {
                    var exec_call  = "EXEC " + spa_name + " " + param_string + '&applied_filters=' + filter_list;
                }    
            }   
                
            if (exec_call == null) {
                return false;
            } else {
                return exec_call
            }
        }
    
    </script>