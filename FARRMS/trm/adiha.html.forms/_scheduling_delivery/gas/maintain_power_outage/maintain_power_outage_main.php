<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
        $form_namespace = 'maintain_power_outage';
        $form_name = 'power_outage';
        $form_obj = new AdihaStandardForm($form_namespace, 10161800);
        $form_obj->define_grid("power_outage_grid", "","t");
        $form_obj->define_custom_functions('', 'load_form', '', '', 'validate_outage_data', 'shape_volume_upset');
        echo $form_obj->init_form('Setup Plant Derate/Outage', 'Setup Plant Derate/Outage');
        echo $form_obj->close_form();
    ?>
    <body>
    </body>
    <script type="text/javascript">
        maintain_power_outage.tabs = {};
        maintain_power_outage.inner_tab_layout_form= {};
        maintain_power_outage.inner_tab_layout= {};
        // var php_script_loc = '<?php //echo $php_script_loc; ?>';
        var icon_loc = '../../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_toolbar_3.0/adiha_dhtmlxToolbar/common/icons_web/';
        var win1;
        
        
        maintain_power_outage.shape_volume_upset = function(tab_id) { 
            
            var active_tab_id = maintain_power_outage.tabbar.getActiveTab();
            
            var power_outage_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

            if (tab_id != '') {
                power_outage_id = tab_id;                
            }
            
            var param = {
                "flag": 'p',
                "action": "spa_power_outage",
                "power_outage_id": power_outage_id
            };
           
            adiha_post_data('alert', param, '', '', '','');
        }
        
        
        
        maintain_power_outage.validate_outage_data = function() { 
            var active_tab_id = maintain_power_outage.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            var tab_json = '';
            var form_obj;
            var form_obj1;
         
            form_obj1 = maintain_power_outage.inner_tab_layout_form["form_" + object_id].getForm();
         
            if (form_obj1.getItemValue('type_name')== 'd') {
                if (form_obj1.getItemValue('derate_mw') == '' && form_obj1.getItemValue('derate_percent') == '') {
                    dhtmlx.message({
                                    type: "error",
                                    title: "Error",
                                    text: "Both Derate MW and Derate % cannot be blank."
                    });
                    
                    return 0;
                }
                
            }
            return 1;
        }
        
        maintain_power_outage.load_form = function(win,tab_id, grid_obj) {
            win1 = win;
            win.progressOff();
            var is_new = win.getText();        
            var power_outage_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;        
            power_outage_id = ($.isNumeric(power_outage_id)) ? power_outage_id : ord(power_outage_id.replace(" ", ""));
       
            maintain_power_outage["inner_tab_layout_" + power_outage_id] = win.attachLayout("1C");
                    
            var xml_value =  '<Root><PSRecordset  power_outage_id ="' + power_outage_id + '"></PSRecordset></Root>';        

            data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": 10161800,
                    "template_name": "maintain_power_outage",
                    "parse_xml": xml_value
                    };

            adiha_post_data('return_array', data, '', '', 'load_form_data', '');
        }

        function load_form_data(result) { 
            var active_tab_id = maintain_power_outage.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var result_length = result.length;
            var tab_json = '';
            var form_obj;
            var form_obj1;
           
            for (i = 0; i < result_length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                    tab_json = tab_json + (result[i][1]);
            }

            tab_json = '{tabs: [' + tab_json + ']}';
         
            inner_tab_layout_tabbar =  maintain_power_outage["inner_tab_layout_" + object_id].cells("a").attachTabbar();
            win1.tabbar[object_id]=inner_tab_layout_tabbar ;
            inner_tab_layout_tabbar.loadStruct(tab_json);
            
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                maintain_power_outage.inner_tab_layout["layout_" + object_id] = inner_tab_layout_tabbar.cells(tab_id).attachLayout('1C');
                maintain_power_outage.inner_tab_layout_form["form_" + object_id] = maintain_power_outage.inner_tab_layout["layout_" + object_id].cells('a').attachForm();
                maintain_power_outage.inner_tab_layout["layout_" + object_id].cells('a').hideHeader();
                   
                if (result[j][2]) {
                    maintain_power_outage.inner_tab_layout_form["form_" + object_id].loadStruct(result[j][2]);
                }
                form_obj1 = maintain_power_outage.inner_tab_layout_form["form_" + object_id].getForm(); 
                
                var cmbTypeName = form_obj1.getCombo('type_name');
                
                cmbTypeName.attachEvent("onChange", function(value, text) {                 
                    if (value == 'o') {                          
                        form_obj1.disableItem('derate_mw');
                        form_obj1.disableItem('derate_percent');
                        return;
                    } else{
                       form_obj1.enableItem('derate_mw');
                        form_obj1.enableItem('derate_percent');
                        return; 
                    }
                        
                });

                 if (form_obj1.getItemValue('type_name') == 'o') { 
                    form_obj1.disableItem('derate_mw');
                    form_obj1.disableItem('derate_percent');
                    return;
                } else {
                    form_obj1.enableItem('derate_mw');
                    form_obj1.enableItem('derate_percent');
                    return; 
                }
            
            }      
        }       
    </script>
</html>
