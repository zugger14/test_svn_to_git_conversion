<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html>  
    <?php 
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
        $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
        $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Report Template",
                                header:         false,
                                collapse:       false,
                                fix_size:       [true,true]
                            },

                        ]';

        $layout_name = 'report_template_layout';
        $name_space = 'report_template';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
        
        echo $layout_obj->close_layout();
    ?> 
    
    <script>
        var active_object_id = '<?php echo $active_object_id; ?>';
        var report_type = '<?php echo $report_type; ?>';
        var report_id = '<?php echo $report_id; ?>';
        var report_name = '<?php echo $report_name; ?>';
        var as_of_date = new Date();
        var as_of_date_to_set = '';        
        report_ui = {};
        
        $(function(){
            data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id": 10201700,
                        "template_name": "DashboardReport",
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
            
            report_ui["report_tabs_" + active_object_id] = report_template.report_template_layout.cells("a").attachTabbar();
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
                
                if (result[j][2]) {
                    report_ui["form_" + j].loadStruct(result[j][2]);
                    var form_name = 'report_ui["form_" + ' + j + ']';
                    attach_browse_event(form_name, active_object_id);
                }

                report_ui["form_" + j].forEachItem(function (name) {
                    if (name == 'as_of_date') {
                        data = {"action": "spa_rfx_group_template_group",
                                "flag": "s",
                                "report_template_name_id": report_id
                             };
                        
                        adiha_post_data('return_array', data, '', '', 'load_post_callback');
                                                                        
                        
                    }// else if (name == 'date_to') {
//                        report_ui["form_" + j].setItemValue('date_to', date_to);
//                    }
                });
            }
            
            /*privilege report only*/
            //if (report_id == '10111300') {
//                report_ui["form_" + 0].attachEvent("onChange", function (name, value) {                
//                    if (name == 'flag') {
//                        report_ui["form_" + 0].uncheckItem('enable_paging');
//                        report_ui["form_" + 0].enableItem('enable_paging');
//                        if ((value == 'f') || (value == 'e')) {
//                            report_ui["form_" + 0].checkItem('enable_paging'); 
//                            report_ui["form_" + 0].disableItem('enable_paging');                             
//                        }
//                    }
//                });
//            }


            var att_obj = report_template.report_template_layout.cells('a');
            parent.set_apply_filter(att_obj);

        }
        
        function load_post_callback(result) {
            data = {"action": "spa_rfx_group_template_group",
                    "flag": "c",
                    "report_manager_group_id": result[j][0]
                 };
            
            adiha_post_data('return_array', data, '', '', 'dashboard_report_post_callback');
        }
         
        function dashboard_report_post_callback(result) {            
            var as_of_date = rfx_override_as_of_date_t(result[0][2], '');
            report_ui["form_0"].setItemValue('as_of_date', as_of_date);            
        } 
        
        function rfx_override_as_of_date_t(report_filter, as_of_date) {
            var final_report_filter = '';
            var first_split = report_filter.split(",");
            var count = 0;
            
            first_split.forEach(function(entry) {
                var second_final = new Array();
                var second_split = entry.split("=");
                
                if (second_split[0] == 'as_of_date' || second_split[0] == 'pnl_as_of_date' || second_split[0] == 'asOfDate') {
                    as_of_date_to_set = second_split[1];
                    return as_of_date_to_set;
                }
                count++;
            });
                        
            return as_of_date_to_set;
        }
                
        /* Returns as_of_date*/
        function return_as_of_date() {
            var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();                    
            var as_of_date;
            
            inner_tab_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                 
                if(form_obj.isItem('as_of_date')) {               
                    as_of_date = form_obj.getItemValue('as_of_date', true);
                } else {
                    as_of_date = '';
                }                
             });
            
           return as_of_date; 
        }
        
        function validate_dashboard_parameter() {
            var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();
            var validation_flag = 0;
            
            inner_tab_obj.forEachTab(function(tab){
                form_obj = tab.getAttachedObject();
                
                var status = validate_form(form_obj);
                
                if (status == false) {
                    validation_flag = 1;
                }              
             });
             
             return validation_flag;
        }
    </script>