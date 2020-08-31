<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require('../../../../../adiha.php.scripts/components/include.file.v3.php'); 
    ?>
    
</head>
<body>
    <?php
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;

        $form_namespace = 'link_ui_template';
        $json = '[
                    {
                        id:             "a",
                        text:           "Links",
                        header:         true,
                        offsetTop:0
                    }
                ]';
        $report_template_layout_obj = new AdihaLayout();
        echo $report_template_layout_obj->init_layout('template_layout', '', '1C', $json, $form_namespace);
        echo $report_template_layout_obj->attach_tab_cell('link_ui_tabbar', 'a', '');
        echo $report_template_layout_obj->close_layout();       
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
        link_ui = {};
        undock_state = 0;
        progress_on = 0;
        var volume_window;
        var session_id = '<?php echo $session_id; ?>';
        
        /**
         * [Load function when the grid is double clicked]
         */
        link_ui_template.load_link_detail = function(link_id, link_name, function_id,allow_change,assessment_result, param1) {
            var params = '';
            inner_active_tab = '';
            param1 = (param1 == undefined) ? 'New' : param1;
            
            if (link_id == -1) {
                full_id = (new Date()).valueOf();
                full_id = full_id.toString();
                tab_text = "New"; 
            } else {
                full_id = 'tab_' + link_id;
                tab_text = 'Link ID : ' + link_id;   
            }
            
            if (function_id == 10237300) {
                full_id = link_id;//(active_object_id.indexOf("tab_") != -1) ? active_object_id.replace("tab_", "") : full_id;
              params = {active_object_id:full_id, function_id:function_id, link_name:link_name};  
            } else if (function_id == 10233700) {
                link_name = (link_id == -1 && param1 == 'New') ? 'Deal Match' : tab_text;
                full_id = (link_id == -1 && param1 == 'New') ? 'deal_match' : full_id;
                params = {active_object_id:full_id, function_id:function_id, link_name:link_name,allow_change:allow_change,assessment_result:assessment_result, deal_match_param:param1};  
            }
            
            var all_tab_id = link_ui_template.link_ui_tabbar.getAllTabs();
            
            if (jQuery.inArray(full_id, all_tab_id ) != -1) {
                link_ui_template.link_ui_tabbar.tabs(full_id).setActive();
                return;
            }
            
            if (tab_text == "New") {
                link_ui_template.link_ui_tabbar.addTab(full_id, link_name, null, null, true, true);
            } else {
                link_ui_template.link_ui_tabbar.addTab(full_id, link_id, null, null, true, true);
            }
            
            var win = link_ui_template.link_ui_tabbar.cells(full_id);
            win.progressOn();
            
            var link_ui_tab_id = link_id;
            
            link_ui_template["inner_tab_layout_" + link_ui_tab_id] = win.attachLayout({
                pattern:"1C",
                cells: [
                    {
                        id: "a", 
                        text: "test",
                        header:false,
                        height:100,
                        collapse:false
                    }
                ]
            });
            
            var inner_layout_obj = link_ui_template["inner_tab_layout_" + link_ui_tab_id];
            inner_layout_obj.attachEvent("onContentLoaded", function(name){
                //inner_layout_obj.cells('a').progressOff();
                win.progressOff();
            });
            var template_name = get_report_template(function_id);            
            var php_path = '<?php echo $app_adiha_loc; ?>';
            var url = php_path + 'adiha.html.forms/_accounting/derivative/' + template_name;
            
            inner_layout_obj.cells('a').attachURL(url, null, params);
            
        }
      
        /**
         * [Returns the template name for the report]
         * @param function_id [Function ID for page to open]
         */
        function get_report_template(function_id) {
            
            if (function_id == 10237300) {
                template_name = 'hedge_effectiveness_test/view_assmt_results/view.update.cum.pnl.series.php';
            } else if (function_id == 10233700) {
                template_name = 'transaction_processing/des_of_a_hedge/des.of.a.hedge.php';
            } 
            
            return template_name;
        }
        
        function post_link_update(tab_name,active_tab_id) {
            if (tab_name != '') {               
               link_ui_template.link_ui_tabbar.cells(active_tab_id).setText(tab_name); 
            }
           
            if (link_ui_template.link_ui_tabbar.cells('deal_match') != null) {
                var inner_layout_obj = link_ui_template.link_ui_tabbar.cells('deal_match').getAttachedObject();
              
                //Deal match tab/Designation of hedge menu/Hedge Item tab/ Deal match page
                var inner_tab = inner_layout_obj.cells('a').getAttachedObject()
                            .contentWindow.ns_des_hedge.layout_des_hedge.cells("a")
                            .getAttachedObject()
                            .cells("a").getAttachedObject();

                inner_tab.forEachTab(function(cell) { 
                    if(cell.getText() == "Hedges/Items") { 
                        cell.getAttachedObject().contentWindow.link_ui_insert.load_match_grids();
                    } 
                })
            }
                        
           parent.post_link_update();
        }
    </script>