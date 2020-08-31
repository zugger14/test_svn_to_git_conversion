<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>    
    <?php
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $time_series_definition_id = get_sanitized_value($_GET["time_series_definition_id"] ?? '');
    $series_type = get_sanitized_value($_GET["series_type"] ?? '');
    $save_permission = get_sanitized_value($_GET["save_permission"] ?? '');

    $xml_file = "EXEC spa_time_series @flag='c', @time_series_definition_id='" . $time_series_definition_id . "'";
    $return_value = readXMLURL($xml_file);
    $data_check = $return_value[0][0] ?? '';

    $json = '[
                {
                    id:             "a",
                    text:           "Series Definition",
                    header:         true,
                    collapse:       false
                }
            ]';
    
    $namespace = 'time_series_ui';
    $time_series_ui_layout_obj = new AdihaLayout();
    echo $time_series_ui_layout_obj->init_layout('time_series_ui_layout', '', '1C', $json, $namespace);
    
    $menu_name = 'time_series_ui_menu';
    $menu_json = '[
                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled:' . $save_permission . '}
                ]';

    echo $time_series_ui_layout_obj->attach_menu_layout_cell($menu_name, 'a', $menu_json, $namespace.'.save_click');

    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10106110', @template_name='time series', @parse_xml = '<Root><PSRecordSet time_series_definition_id=\"" . $time_series_definition_id . "\"></PSRecordSet></Root>'";
    //$xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10106110', @template_name='time series'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $time_series_ui_layout_obj->attach_form('time_series_form', 'a');
    $time_series_form = new AdihaForm();
    echo $time_series_form->init_by_attach('time_series_form', $namespace);
    echo $time_series_form->load_form($form_json);

    echo $time_series_ui_layout_obj->close_layout();
    ?>

</body>
</html>

<script>
    var save_permission = '<?php echo $save_permission;?>';
    $(function() {
        var is_checked = time_series_ui.time_series_form.isItemChecked('maturity_applicable');
        var data_check = '<?php echo $data_check; ?>';
        var series_type = '<?php echo $series_type; ?>';
        
        if (is_checked == true) {
            time_series_ui.time_series_form.enableItem('granulalrity');
        } 
        time_series_ui.time_series_form.attachEvent("onChange", function (name, value){
             if (name == 'maturity_applicable') {
                var is_checked = time_series_ui.time_series_form.isItemChecked(name);
                if (is_checked == false) {
                    time_series_ui.time_series_form.setItemValue('granulalrity', '');
                    time_series_ui.time_series_form.disableItem('granulalrity');
                } else {
                    time_series_ui.time_series_form.enableItem('granulalrity');
                }
             }
        });
        
        if (data_check == '0') {
            time_series_ui.time_series_form.disableItem('maturity_applicable');
            time_series_ui.time_series_form.disableItem('effective_date_applicable');
            time_series_ui.time_series_form.disableItem('granulalrity');
        } else {
            if (series_type == '39003') {
                time_series_ui.time_series_form.setItemValue('maturity_applicable', false);
                time_series_ui.time_series_form.setItemValue('effective_date_applicable', true);
                time_series_ui.time_series_form.setItemValue('granulalrity', '');
                time_series_ui.time_series_form.disableItem('granulalrity');
            }
        }
        
        if (series_type != '') {
            time_series_ui.time_series_form.setItemValue('time_series_type_value_id', series_type);
            time_series_ui.time_series_form.disableItem('time_series_type_value_id');
        }
    })
    
    /*
     * time_series_ui.save_click    [Save the time series definition]
     */
    time_series_ui.save_click = function() {
        var status = validate_form(time_series_ui.time_series_form);
        var name;
        if (status) {
            var maturity_checked = time_series_ui.time_series_form.isItemChecked('maturity_applicable');
            var granularity = time_series_ui.time_series_form.getItemValue('granulalrity');
            if (maturity_checked == true && granularity == '') {
                show_messagebox('Please select the granularity.');
                return;
            }
            time_series_ui.time_series_ui_menu.setItemDisabled('save');

            form_data = time_series_ui.time_series_form.getFormData();
            var xml = '<Root><FormXML';
            for (var a in form_data) {
                if (form_data[a] != '' && form_data[a] != null) {
                    if (time_series_ui.time_series_form.getItemType(a) == 'calendar') {
                        value = time_series_ui.time_series_form.getItemValue(a, true);
                    } else {
                        value = form_data[a];
                    }
                    
                    if (a == 'time_series_name') {
                        name = value;
                    }
                    xml += ' ' + a + '="' + value + '"';
                } else {
                    if (a == 'time_series_description') {
                        value = name;
                        time_series_ui.time_series_form.setItemValue(a, value);
                        xml += ' ' + a + '="' + value + '"';
                    }
                    
                    if (a == 'time_series_id') {
                        value = name;
                        time_series_ui.time_series_form.setItemValue(a, value);
                        xml += ' ' + a + '="' + value + '"';
                    }
                }
            }
            xml += '>';
            xml += '</FormXML></Root>';
            time_series_ui.time_series_ui_menu.setItemDisabled('save');
            var param = {
                "flag": "i",
                "action": "spa_time_series",
                "xml": xml
            };

            adiha_post_data('return_json', param, '', '', 'save_click_callback', '');
         } else {
            generate_error_message();
            return;
         }
    }
    
    save_click_callback = function(result) {
        if (save_permission) {
            time_series_ui.time_series_ui_menu.setItemEnabled('save');
        };
        var return_data = JSON.parse(result);
        var status = return_data[0].status;
        if (save_permission) {
            time_series_ui.time_series_ui_menu.setItemEnabled('save');
        };
        
        if (status == 'Error') {
            dhtmlx.message({
                title:"Error",
                type:"alert-error",
                text:return_data[0].message
            });
        } else {
            var new_id = return_data[0].recommendation;
            if (new_id != '') { 
                time_series_ui.time_series_form.setItemValue('time_series_definition_id', new_id);
            }
           
            dhtmlx.message({
                text:return_data[0].message,
                expire:1000
            });
            setTimeout('parent.time_series_window.window("w1").close()', 1000);
        }
    }
    
    
</script>