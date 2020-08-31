<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/dhtmlxscheduler.js" type="text/javascript"></script>
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <body>
    <?php
    $form_namespace = 'namespace';
    $function_id = 10106800;
    $layout_obj = new AdihaLayout();
    $layout_json = '[{id: "a", header:false, text: "Reminders", collapse: false},{id: "b", header:false, height: 40, fix_size:[true,true]}]';
    echo $layout_obj->init_layout('reminder_layout', '', '2E', $layout_json, $form_namespace);
    
    $menu_name = 'reminder_menu';
    $menu_json = '[
            {id:"snooze", text:"Snooze", img:"snooze.gif", imgdis:"snooze_dis.gif", enabled: false},
            {id:"dismiss", text:"Dismiss", img:"dismiss.gif", imgdis:"dismiss_dis.gif", enabled: false},
            {id:"dismiss_all", text:"Dismiss All", img:"dismiss_all.gif", imgdis:"dismiss_all_dis.gif", enabled: false}
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'a', $menu_json, 'menu_click');
    
    //Attach Grid
    $grid_name = 'reminder_grid';
    echo $layout_obj->attach_grid_cell($grid_name, 'a');
    $grid_obj = new AdihaGrid();
    //echo $layout_obj->attach_status_bar("a", true);
    echo $grid_obj->init_by_attach($grid_name, $form_namespace);
    echo $grid_obj->set_header("ID,Reminder");
    echo $grid_obj->set_columns_ids("message_id,reminder");
    echo $grid_obj->set_widths("150,420");
    echo $grid_obj->set_column_types("ro,ro");
    //echo $grid_obj->enable_multi_select();
    echo $grid_obj->set_column_visibility("true,false");
    //echo $grid_obj->enable_paging(100, 'pagingArea_a', 'true');
    echo $grid_obj->set_sorting_preference('int,str');
    echo $grid_obj->return_init();
    echo $grid_obj->attach_event('', 'onRowSelect', $form_namespace.'.grid_select');
    
    //Attach Form
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$function_id', @template_name='Calendar', @group_name='Reminder'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    echo $layout_obj->attach_form('reminder_form', 'b');
    $form_obj = new AdihaForm();
    echo $form_obj->init_by_attach('reminder_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    
    echo $layout_obj->close_layout();
    ?>
    </body>
    <script type="text/javascript" charset="utf-8">
        $(function(){
            refresh_reminder_grid();
        });
        
        function menu_click(id) {
            switch(id) {
                case "snooze":
                    var selected_row_id = namespace.reminder_grid.getSelectedRowId();
                    var message_id = namespace.reminder_grid.cells(selected_row_id, namespace.reminder_grid.getColIndexById('message_id')).getValue();
                    var snooze_time = namespace.reminder_form.getItemValue('snooze_time');
                    if (snooze_time != '') {
                        data = {"action": "spa_calendar", "flag": "v", "calendar_event_id": message_id, "snooze_time": snooze_time};
                        adiha_post_data("return_array", data, '', '', 'refresh_reminder_grid');
                    }
                    break;
                case "dismiss":
                    var selected_row_id = namespace.reminder_grid.getSelectedRowId();
                    var message_id = namespace.reminder_grid.cells(selected_row_id, namespace.reminder_grid.getColIndexById('message_id')).getValue();
                    
                    data = {"action": "spa_calendar", "flag":"x", "calendar_event_id":message_id};
                    adiha_post_data("return_array", data, '', '', 'refresh_reminder_grid');
                    break;
                case "dismiss_all":
                    var message_id = '';
                    for(var i = 0; i < namespace.reminder_grid.getRowsNum(); i++) {
                        if (i == 0) {
                            var message_id = namespace.reminder_grid.cells(i, namespace.reminder_grid.getColIndexById('message_id')).getValue();
                        } else {
                            message_id += ',' + namespace.reminder_grid.cells(i, namespace.reminder_grid.getColIndexById('message_id')).getValue();    
                        }
                    }
                    
                    data = {"action": "spa_calendar", "flag": "x", "calendar_event_id": message_id};
                    adiha_post_data("return_array", data, '', '', 'refresh_reminder_grid');
                    break;
                default:
                    break;
            }
        }
        
        namespace.grid_select = function() {
            
        }
        
        function refresh_reminder_grid() {
            //namespace.reminder_layout.cells('a').progressOn();
            
            var param = {
                "flag": "z",
                "action":"spa_calendar",
                "grid_type":"g"
            };
    
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            
            namespace.reminder_grid.clearAndLoad(param_url, function(){
                if (namespace.reminder_grid.getRowsNum() > 0) {
                    namespace.reminder_grid.selectRow(0);
                    
                    namespace.reminder_menu.setItemEnabled("dismiss");
                    namespace.reminder_menu.setItemEnabled("dismiss_all");
                    namespace.reminder_menu.setItemEnabled("snooze");    
                } else {
                    namespace.reminder_menu.setItemDisabled("dismiss");
                    namespace.reminder_menu.setItemDisabled("dismiss_all");
                    namespace.reminder_menu.setItemDisabled("snooze");
                }
                //namespace.reminder_layout.cells('a').progressOff();
            });
        }
    </script>
</html>