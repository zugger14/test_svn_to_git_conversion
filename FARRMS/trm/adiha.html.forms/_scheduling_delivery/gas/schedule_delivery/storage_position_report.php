<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <style type="text/css">
    .dhxform_obj_dhx_web div.dhxform_item_label_left.browse_clear, .dhxform_obj_dhx_web div.dhxform_item_label_left.browse_open {
        top: -10px!important;
    } 
    </style>
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
                                text:           "Storage Position Report",
                                header:         false
                            }
                        ]';
;
        $layout_name = 'storage_position_report_layout';
        $name_space = 'storage_position_report';
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
        var tab_json = '';
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }
        
        tab_json = '{tabs: [' + tab_json + ']}';
        
        report_ui["report_tabs_" + active_object_id] = storage_position_report.storage_position_report_layout.cells("a").attachTabbar();
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

        // setting the default value of commodity combo box
        var form_combo = report_ui["form_0"].getCombo('commodity_id');
        var commodity_obj = form_combo.getOptionByLabel('Natural Gas');
        if (commodity_obj != null) // null previlege leads to null default combo load and page doesnot load
            report_ui["form_0"].setItemValue('commodity_id', commodity_obj.value);

        var att_obj = storage_position_report.storage_position_report_layout.cells('a');
        parent.set_apply_filter(att_obj);
    }

    function report_parameter() {
            var inner_tab_obj = storage_position_report.storage_position_report_layout.cells("a").getAttachedObject();
            var validation_flag = 0;
            
            var param_list = new Array();
            var spa_name = '';
            var radio_flag = '';
            var paging_flag = 0;
            var as_of_date, to_of_date;
            var filter_list = new Array();
            
            inner_tab_obj.forEachTab(function(tab){
                form_obj = tab.getAttachedObject();
                
                var status = validate_form(form_obj);
                
                if (status == false) {
                    validation_flag = 1;
                }

                form_obj.forEachItem(function(name){
                    var item_type = form_obj.getItemType(name);

                    if (name == 'spa_name') {
                        spa_name = form_obj.getItemValue(name);
                    } else if (item_type == 'calendar') {
                        value = form_obj.getItemValue(name, true);

                        if (value != '') { 
                            param_list.push('@' + name + "='" + value + "'");
                        }

                        if (name == 'term_start') {
                            as_of_date = value;
                        } else if (name == 'term_end') {
                            to_of_date = value;
                        }

                    } else if (item_type == 'radio') {
                        value = form_obj.getCheckedValue(name);

                        if(form_obj.isItemChecked(name, value) && radio_flag != name){
                            radio_flag = name;
                            param_list.push('@' + name + '=' + value);
                        }
                    } else if (item_type == 'combo') {
                        var combo_obj = form_obj.getCombo(name);
                        value = combo_obj.getChecked();

                        if (value == '') {
                            value = combo_obj.getSelectedValue();
                        }

                        if (value != '') { 
                            param_list.push('@' + name + "='" + value + "'");
                        }
                    } else if (item_type == 'checkbox') { 
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        }
                    
                    } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button' && name!= 'book_structure') {
                        value = form_obj.getItemValue(name);

                         if (value != '') { 
                            if (name == 'subsidiary_id') {;
                                param_list.push('@sub_entity_id' + "='" + value + "'");
                            } else if (name == 'strategy_id') {
                                param_list.push('@strategy_entity_id' + "='" + value + "'");
                            } else if (name == 'book_id') {
                                param_list.push('@book_entity_id' + "='" + value + "'");
							} else if (name == 'subbook_id') {
                                param_list.push('@sub_book_id' + "='" + value + "'");
                            } else if (name == 'label_location_id') {
                                
                            } else {
                               param_list.push('@' + name + "='" + value + "'"); 
                           }                            
                        }
                    }
                });                                   
            });
            
            form_obj.forEachItem(function(name) {
                var item_type = form_obj.getItemType(name);

                if (item_type == 'calendar') {
                    value = form_obj.getItemValue(name, true);

                    if (value != '') { 
                        filter_list.push(form_obj.getItemLabel(name) + "='" + value + "'");
                    }
               
                } else if (item_type == 'combo') {
                    var combo_obj = form_obj.getCombo(name);
                    value = combo_obj.getChecked();

                    if (value == '') {
                        value = combo_obj.getSelectedValue();
                        filter_value = combo_obj.getSelectedText();
                    }

                    if (value != '') { 
                        filter_list.push(form_obj.getItemLabel(name) + "='" + filter_value + "'");
                    }

                } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button') {
                    value = form_obj.getItemValue(name);
                    filter_value = form_obj.getItemValue(name);
                    if (value != '' 
                                && name != 'spa_name' 
                                && name != 'subsidiary_id'
                                && name != 'strategy_id'
                                && name != 'book_id'
                                && name != 'subbook_id'
                                && name != 'location_id') { // for other report 
                        filter_list.push(form_obj.getItemLabel(name) + "='" + filter_value + "'");
                    }
                }
            });  
            
            filter_list = filter_list.join(' | ');
            //To bypass validation if the date is dynamic type
            as_of_date = get_static_date_value(as_of_date);
            to_of_date = get_static_date_value(to_of_date);

            if (as_of_date <= to_of_date) {
                var exec_call  = "EXEC " +  spa_name + " " + param_list + '&applied_filters=' + filter_list;;
            } else if (to_of_date < as_of_date && as_of_date != '' && to_of_date != '') {
                show_messagebox("<b>Term Start</b> should be less than <b>Term End</b>.");
            }
                        
            if (paging_flag == 1) {
                exec_call = exec_call + '&enable_paging=true&np=1&applied_filters=' + filter_list;
            }
            
            if (validation_flag == 1) {
                return false;
            }
            
            if (exec_call == null) {
                return false;
            } else {
                return exec_call
            }
        }
</script>