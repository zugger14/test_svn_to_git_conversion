<?php
/**
* Load forecast report screen
* @copyright Pioneer Solutions
*/
?>
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
                                text:           "Load Forecast Report.",
                                header:         false
                            }
                        ]';

        $layout_name = 'load_forecast_report_layout';
        $name_space = 'load_forecast_report';
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
            report_ui["report_tabs_" + active_object_id] = load_forecast_report.load_forecast_report_layout.cells("a").attachTabbar();
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            tab_id = 'detail_tab_' + result[0][0];
            report_ui["form_" + active_object_id] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
            report_ui["form_" + active_object_id].loadStruct(result[0][2]);
           
            report_ui["form_" + active_object_id].attachEvent("onChange", function (name, value){
               if (name == 'grouping_option' && (value == 'd')){
                    report_ui["form_" + active_object_id].checkItem('enable_paging');
                }
                if (name == 'grouping_option' && (value == 's')){
                    report_ui["form_" + active_object_id].uncheckItem('enable_paging');
                } 
			});
            
            var form_name = 'report_ui["form_" + ' + active_object_id + ']';
            attach_browse_event(form_name);
                     
            var att_obj = load_forecast_report.load_forecast_report_layout.cells('a');
            parent.set_apply_filter(att_obj);
            
           }
        
        function report_parameter() {
            var inner_tab_obj = load_forecast_report.load_forecast_report_layout.cells("a").getAttachedObject();
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
            if (status == false){
                return false;
            } 

            if(status){
                var validation_status = true;
                for (var a in data) {
                    field_label = a;
                    field_value = data[a];
                    label = form_obj.getItemLabel(a);
                    value = form_obj.getItemValue(a);
     		
                    if(field_label == "profile_id") {
                        profile_id_value = field_value;
                       //if(profile_id_value > 0){
                         profile_id_value_length = profile_id_value.length;
                      // } else{
                       //show_messagebox('Please Select Single <strong>//Profile</strong>.');
                       //return false;
                       //}
                    }
                    if(field_label == "location_id") {
                        location_id_value = field_value;
                        location_id_value_lenght = location_id_value.length;
                    }
                    if(field_label == "prod_month_from") {
                       date_from_val = form_obj.getItemValue('prod_month_from', true);
                        
                    }
                    if(field_label == "prod_month_to") {
                       date_to_val = form_obj.getItemValue('prod_month_to', true);
                                              
                    }
                    if(field_label == "hour_from") {
                        hour_from_val = parseInt(field_value);
                        }
                    if(field_label == "hour_to") {
                        hour_to_val = parseInt(field_value);
                        }
                }

                //To bypass validation if the date is dynamic type
                date_to_val = get_static_date_value(date_to_val);
                date_from_val = get_static_date_value(date_from_val);

                if (date_to_val < date_from_val && date_to_val != '' && date_from_val != '' ){
                    validation_status = false;
                    show_messagebox('<strong>Date From</strong> cannot be greater than <strong> Date To</strong>.');
                    //show_messagebox ('Date From cannot be greater than Date To.');
                    return false;
                }
                if (profile_id_value_length == 0 && location_id_value_lenght == 0) {
                    validation_status = false;
                    show_messagebox ('Please select either Profile or Location.');
                    return false;
                }
                if(hour_from_val > hour_to_val) {
                    validation_status = false;
                    show_messagebox('<strong>Hour From</strong> cannot be greater than <strong> Hour To</strong>.');
                    //show_messagebox ('Hour From cannot be greater than Hour To.');
                    return false;
                }
                
        }
        else{
            validation_status = false;   
            }
        }
                        
        var param_list = new Array();
        spa_name = 'spa_load_forecast_report';
        profile_id = form_obj.getItemValue('profile_id');
        location_id = form_obj.getItemValue('location_id');
        term_start = form_obj.getItemValue('prod_month_from', true);
        term_end = form_obj.getItemValue('prod_month_to', true);
        hour_from = form_obj.getItemValue('hour_from');
        hour_to = form_obj.getItemValue('hour_to');
        grouping_option = form_obj.getItemValue('grouping_option');
        format = form_obj.getItemValue('format');
        round_value = form_obj.getItemValue('round_value');
        
        //param_list.push
        param_list.push("'" + profile_id + "'");
        param_list.push("'" + location_id + "'");
        param_list.push("'" + term_start + "'");
        param_list.push("'" + term_end + "'");
        param_list.push("'" + hour_from + "'");
        param_list.push("'" + hour_to + "'");
        param_list.push("'" + grouping_option + "'");
        param_list.push("'" + format + "'");
        param_list.push("'" + round_value + "'");
        param_list.push("NULL");
                     
        var enable_paging = form_obj.isItemChecked('enable_paging');
        enable_paging = (enable_paging == true) ? '1' : '0';
    
        
        var param_string = param_list.toString();
        param_string = param_string.replace(/""/g, 'NULL');
        param_string = param_string.replace(/''/g, 'NULL');
       
        filter_list = filter_list.join(' | ')   
       
        if(validation_status == true) {
        if(enable_paging == 1){
            var exec_call  = "EXEC " + spa_name + " " + param_string + '&enable_paging=true&np=1&applied_filters=' + filter_list;
        } else{
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