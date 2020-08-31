
<?php
/**
* setup_conversion_factor screen
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
            $function_id =  20016600;
            $form_namespace = 'conversion_factor';
            $template_name = "setup_conversion_factor";
            $form_obj = new AdihaStandardForm($form_namespace,  20016600);
            $form_obj->define_grid('ConversionFactor', '', 'g', false, '', false);
            $form_obj->define_custom_functions('','','', 'form_load_complete');
            $form_obj->define_layout_width(350);
            echo $form_obj->init_form('Conversion Factor');
            echo $form_obj->close_form();
        ?>
    </body>
    <script type="text/javascript">
        conversion_factor.form_load_complete = function(win, tab_id) {
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id =  object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
           
            $.each(detail_tabs, function(index,value) {
                var tab_text = tab_obj.cells(value).getText();
                if(tab_text == 'General') {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    menu_obj =  layout_obj.cells("b").getAttachedMenu();
                    menu_obj.addNewSibling('t1', "refresh", 'Refresh', false, "refresh.gif", "refresh_dis.gif");
                    menu_obj.attachEvent("onClick",conversion_factor.conversion_factor_menu_onclick);
                    
                    layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                        
                        attached_obj.detachHeader(1);
                        attached_obj.attachHeader('#text_filter,#text_filter,#daterange_filter,#text_filter,#combo_filter');
                        }
                    }); 
                }    
            });
            
        }

        conversion_factor.conversion_factor_menu_onclick = function(id) {
            switch(id) {
                case "refresh":
                    conversion_factor.refresh_converion_factor_grid()
                break;
            }       
        }

       conversion_factor.refresh_converion_factor_grid = function() {
            var active_tab = conversion_factor.tabbar.getActiveTab();
            var active_tab_cell = conversion_factor.tabbar.tabs(active_tab);
            var innertabbar = active_tab_cell.getAttachedObject();

            innertabbar.forEachTab(function(tab) {
                if(tab.getText() == 'General') {
                    var innertabcell = tab.getAttachedObject()
                    var gridobject = innertabcell.cells('b').getAttachedObject()
                    var form_object = innertabcell.cells('a').getAttachedObject()

                   var sql_param = {
                       "action": 'spa_conversion_factor',
                       "flag": 'g',
                       "conversion_factor_id": form_object.getItemValue('conversion_factor_id')
                   };

                   sql_param = $.param(sql_param);
                   var sql_url = js_data_collector_url + "&" + sql_param;
                   gridobject.clearAll();
                   gridobject.load(sql_url);

                }

            })

        }
   
    </script>
</html>
