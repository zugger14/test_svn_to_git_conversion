<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>     
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $theme_path = '../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' . 'dhtmlx_'. $default_theme . '/imgs/customize_icons/';
    $workflow_menu_id = get_sanitized_value($_REQUEST['workflow_menu_id'] ?? 'null');
    ///*
    $namespace = 'ns_customize_icon';
    $layout_obj = new AdihaLayout();    
    $layout_json = '[{id: "a", header:false}]';    
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
    
    $menu_json = '[{id:"ok", text:"Ok", img: "tick.gif", imgdis: "tick_dis.gif", title: "Ok"}]';
    echo $layout_obj->attach_menu_cell('customize_icon_menu', 'a');
    $menu_object = new AdihaMenu();
    echo $menu_object->init_by_attach('customize_icon_menu', $namespace);
    echo $menu_object->load_menu($menu_json);
    echo $menu_object->attach_event('', 'onClick', $namespace . '.customize_icon_menu_click');
    echo $layout_obj->close_layout();
    //*/
    ?>         
    <div id="data_container" style="width:100%;height:300px;"></div>
     
    <script type="text/javascript">
    var theme_path = '<?php echo $theme_path; ?>';
    
    $(function() {
        var data = {'action': 'spa_workflow_icons',
                    'flag': 's' 
                    };
        result = adiha_post_data('json', data, '', '', 'load_form_data', false);
    });
              
    function load_form_data(return_array) {                  
        var view = ns_customize_icon.layout.cells('a').attachDataView({
        container : 'data_container',
        type : {
                template : "<img src='" + theme_path + "#name#' id='#id#'>",
                width: 35,
                height : 35
            } 
        });
         
        view.parse(return_array, 'json');           
        view.attachEvent('onItemDblClick', function (id, ev, html) {
            var image_id = id; //static_data_value
            set_temp_image(image_id);
        });
    }
    
    ns_customize_icon.customize_icon_menu_click = function (id) {
        switch(id) {
            case 'ok':
                dataview_obj = ns_customize_icon.layout.cells('a').getAttachedObject();
                if (dataview_obj instanceof dhtmlXDataView) {
                    var image_id = dataview_obj.getSelected();
                }
                
                set_temp_image(image_id);
                break;                      
        }
    }    
    
    function set_temp_image(image_id) {
        var workflow_menu_id = '<?php echo $workflow_menu_id; ?>';
        var image_id = image_id; 
        
        var data = {
                            "action" : "spa_workflow_icons",
                            "flag" : "t",
                            "workflow_menu_id" : workflow_menu_id,
                            "image_id" : image_id
                    };
    
        adiha_post_data('return_array', data, '', '', 'set_temp_image_callback', '', '');
    } 
    
    function set_temp_image_callback(return_value) { 
        var workflow_menu_id = '<?php echo $workflow_menu_id; ?>';
//        dhtmlx.message({
//                text : 'Changes has been saved successfully.',
//                expire : 1000
//            });
            
        parent.change_image(return_value[0][0], workflow_menu_id, return_value[0][1]);
        setTimeout('close_window()', 1000);             
    }
    
   // function get_image_name(return_value) {
//        var workflow_menu_id = '<?php echo $workflow_menu_id; ?>';
//        dhtmlx.message({
//                text : 'Changes has been saved successfully.',
//                expire : 1000
//            });
//            
//        parent.change_image(return_value[0][2], workflow_menu_id, return_value[0][3]);
//        setTimeout('close_window()', 1000); 
//    }
    
    function close_window() {    
        var win_obj = window.parent.create_change_icon_window.window('w2');
        win_obj.close();
    }
    </script> 
 </html>
 