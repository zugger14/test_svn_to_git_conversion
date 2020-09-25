<?php
/**
* Term Mapping screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>

    <body>
        <?php
            $php_script_loc = $app_php_script_loc;
            $form_namespace = 'term_mapping';
            
            $application_function_id = 20013000;

            $mapping_code = get_sanitized_value($_GET['mapping_code'] ?? '');

            $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
            $form_obj->define_grid("TermMapping");
            $form_obj->define_layout_width(400);
            $form_obj->define_apply_filters(true, '20013003', 'FilterTermMapping', 'General');
            $form_obj->define_custom_functions('', '', '', 'form_load_complete', 'save_validation');
            echo $form_obj->init_form('Term Mapping Grid', 'Term Mapping Grid Details', 'term_mapping');
            echo $form_obj->close_form();
        ?>

        <script type="text/javascript">

            var mapping_code = '<?php echo $mapping_code; ?>';

            $(function(){
                if(mapping_code != '') {
                    term_mapping.create_tab(-1,0,0,0);
                }
            });

            term_mapping.form_load_complete = function(win,id) {
                var tab_id = term_mapping.tabbar.getActiveTab();
                var tab_text = term_mapping.tabbar.tabs(tab_id).getText();

                if (tab_text == 'New') {
                    term_mapping.manipulate_form_field('disable_radio', 'holiday_include_exclude', 'i');
                    term_mapping.manipulate_form_field('disable_radio', 'holiday_include_exclude', 'e');

                    if(mapping_code != '') {
                        term_mapping.manipulate_form_field('set_value', 'term_code', mapping_code);
                    }
                
                } else {
                    date_or_block = term_mapping.manipulate_form_field('get', 'date_or_block');
                    
                    if (date_or_block == 'd') {
                        term_mapping.manipulate_form_field('enable', 'term_start');
                        term_mapping.manipulate_form_field('enable', 'term_end');
                        term_mapping.manipulate_form_field('disable', 'working_day_id');
                        term_mapping.manipulate_form_field('disable', 'holiday_calendar_id');
                        term_mapping.manipulate_form_field('disable', 'relative_days');
                        term_mapping.manipulate_form_field('disable', 'no_of_days');
                        term_mapping.manipulate_form_field('disable_radio', 'holiday_include_exclude', 'i');
                        term_mapping.manipulate_form_field('disable_radio', 'holiday_include_exclude', 'e');
                    } else if (date_or_block == 'b') {
                        term_mapping.manipulate_form_field('disable', 'term_start');
                        term_mapping.manipulate_form_field('disable', 'term_end');
                        term_mapping.manipulate_form_field('enable', 'working_day_id');
                        term_mapping.manipulate_form_field('enable', 'holiday_calendar_id');
                        term_mapping.manipulate_form_field('enable', 'relative_days');
                        term_mapping.manipulate_form_field('enable', 'no_of_days');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'i');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'e');
                    } else if (date_or_block == 'r') {
                        term_mapping.manipulate_form_field('disable', 'term_start');
                        term_mapping.manipulate_form_field('disable', 'term_end');
                        term_mapping.manipulate_form_field('disable', 'working_day_id');
                        term_mapping.manipulate_form_field('enable', 'holiday_calendar_id');
                        term_mapping.manipulate_form_field('enable', 'relative_days');
                        term_mapping.manipulate_form_field('enable', 'no_of_days');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'i');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'e');
                    } else if (date_or_block == 'm') {
                        term_mapping.manipulate_form_field('disable', 'term_start');
                        term_mapping.manipulate_form_field('disable', 'term_end');
                        term_mapping.manipulate_form_field('enable', 'working_day_id');
                        term_mapping.manipulate_form_field('enable', 'holiday_calendar_id');
                        term_mapping.manipulate_form_field('enable', 'relative_days');
                        term_mapping.manipulate_form_field('disable', 'no_of_days');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'i');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'e');
                    }
                }

                // Action when Date/Block/Relative combo option is changed
                combo_obj = term_mapping.manipulate_form_field('return_combo_obj', 'date_or_block');
                
                combo_obj.attachEvent('onChange', function(value, text){
                    if (value == 'd') {
                        term_mapping.manipulate_form_field('enable', 'term_start');
                        term_mapping.manipulate_form_field('enable', 'term_end');
                        term_mapping.manipulate_form_field('disable', 'working_day_id');
                        term_mapping.manipulate_form_field('disable', 'holiday_calendar_id');
                        term_mapping.manipulate_form_field('disable', 'relative_days');
                        term_mapping.manipulate_form_field('disable', 'no_of_days');
                        term_mapping.manipulate_form_field('disable_radio', 'holiday_include_exclude', 'i');
                        term_mapping.manipulate_form_field('disable_radio', 'holiday_include_exclude', 'e');
                    } else if (value == 'b') {
                        term_mapping.manipulate_form_field('disable', 'term_start');
                        term_mapping.manipulate_form_field('disable', 'term_end');
                        term_mapping.manipulate_form_field('enable', 'working_day_id');
                        term_mapping.manipulate_form_field('enable', 'holiday_calendar_id');
                        term_mapping.manipulate_form_field('enable', 'relative_days');
                        term_mapping.manipulate_form_field('enable', 'no_of_days');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'i');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'e');
                    } else if (value == 'r') {
                        term_mapping.manipulate_form_field('disable', 'term_start');
                        term_mapping.manipulate_form_field('disable', 'term_end');
                        term_mapping.manipulate_form_field('disable', 'working_day_id');
                        term_mapping.manipulate_form_field('enable', 'holiday_calendar_id');
                        term_mapping.manipulate_form_field('enable', 'relative_days');
                        term_mapping.manipulate_form_field('enable', 'no_of_days');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'i');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'e');
                    } else if (value == 'm') {
                        term_mapping.manipulate_form_field('disable', 'term_start');
                        term_mapping.manipulate_form_field('disable', 'term_end');
                        term_mapping.manipulate_form_field('enable', 'working_day_id');
                        term_mapping.manipulate_form_field('enable', 'holiday_calendar_id');
                        term_mapping.manipulate_form_field('enable', 'relative_days');
                        term_mapping.manipulate_form_field('disable', 'no_of_days');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'i');
                        term_mapping.manipulate_form_field('enable_radio', 'holiday_include_exclude', 'e');
                    }
                });
            }

            term_mapping.manipulate_form_field = function(action, field_id, field_value) {
                var tab_id = term_mapping.tabbar.getActiveTab();
                var win = term_mapping.tabbar.cells(tab_id);
                var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
                object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
                var tab_obj = win.tabbar[object_id];
                var detail_tabs = tab_obj.getAllTabs();
                var return_type = false;

                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    
                    layout_obj.forEachItem(function(cell) {
                        attached_obj = cell.getAttachedObject();
                        
                        if (attached_obj instanceof dhtmlXForm) { 
                            if (action == "return_combo_obj") {
                                field_value = attached_obj.getCombo(field_id);
                                return_type = true;
                            } else if (action == "enable") {
                                attached_obj.enableItem(field_id);
                            } else if (action == "disable") {
                                attached_obj.disableItem(field_id);
                            } else if (action == "enable_radio") {
                                attached_obj.enableItem(field_id, field_value);
                            } else if (action == "disable_radio") {
                                attached_obj.disableItem(field_id, field_value);
                            } else if (action == "get") {
                                field_value = attached_obj.getItemValue(field_id);
                                return_type = true;
                            } else if (action == "get_date") {
                                field_value = attached_obj.getItemValue(field_id, true);
                                return_type = true;
                            } else if (action == 'set_value') {
                                attached_obj.setItemValue(field_id, field_value);
                            }
                        }
                    });
                });

                if (return_type == true) {
                    return field_value;
                }
            }

            term_mapping.save_validation = function() {
                var term_start = term_mapping.manipulate_form_field('get_date', 'term_start');
                var term_end =  term_mapping.manipulate_form_field('get_date', 'term_end');

                if (term_start > term_end) {
                    var message = '<b>Term Start</b> cannot be greater than <b>Term End</b>.';
                    show_messagebox(message);
                    return false;
                }
            }
        </script>
    </body>
</html>