<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require('../../../adiha.php.scripts/components/include.file.v3.php'); 
    ?>
    
</head>
<body>
    <?php
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;

         $rights_deal_match = 20004700;
        $rights_deal_match_iu = 20004701;
        $rights_deal_match_delete = 20004702;

        list (
            $has_rights_deal_match,
            $has_rights_deal_match_iu,
            $has_rights_deal_match_delete
        ) = build_security_rights(
            $rights_deal_match,
            $rights_deal_match_iu,
            $rights_deal_match__delete
        );

        $filter_application_function_id = 20004700;

        $enable = 'true';

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
        var has_rights_deal_match_iu = Boolean(<?php echo $has_rights_deal_match_iu; ?>);
        var has_rights_deal_match_delete = Boolean(<?php echo $has_rights_deal_match_delete; ?>);

        link_ui_template = {};
        inner_menu_obj = {};

        undock_state = 0;
        progress_on = 0;
        var volume_window;
        var session_id = '<?php echo $session_id; ?>';

        $(function() {
            // load Deal Match Tab
            link_ui_template.load_link_detail(-1)
        })
        
        /**
         * [Load function when the grid is double clicked]
         * link_id = -1 : Deal Match Tab
         * link_id =-2 : New Tab ELSE Link Tab (update)
         */
        link_ui_template.load_link_detail = function(link_id, link_name, data) {
            var params = '';
            inner_active_tab = '';
            
            if (link_id == -1) {
                //full_id = (new Date()).valueOf();
                full_id = -1;
                full_id = full_id.toString();
                tab_text = "Deal Match"; 
            } else if (link_id == -2) {
                //full_id = (new Date()).valueOf();
                full_id = (new Date()).valueOf();
                full_id = full_id.toString();
                tab_text = "New"; 
                link_id  = full_id;
            } else {
                full_id = 'tab_' + link_id;
                tab_text = 'Deal Match : ' + link_id;   
            }
            
                link_name = tab_text
                params = {active_object_id:full_id, link_name:link_name,data:data};  
            
            
            var all_tab_id = link_ui_template.link_ui_tabbar.getAllTabs();
            
            if (jQuery.inArray(full_id, all_tab_id ) != -1) {
                link_ui_template.link_ui_tabbar.tabs(full_id).setActive();
                return;
            }
            
            link_ui_template.link_ui_tabbar.addTab(full_id, link_name, null, null, true, (link_id == -1) ? false : true);
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

            inner_menu_obj[link_ui_tab_id] = inner_layout_obj.cells('a').attachToolbar();

            inner_menu_obj[link_ui_tab_id].setIconsPath(js_image_path + "dhxtoolbar_web/");

            if (link_id == -1) {
                inner_menu_obj[link_ui_tab_id].loadStruct([{ id: "match", type: "button", img: "match.gif", imgdis: "match_dis.gif", text: "Match", title: "Match"},
                                            { id: "refresh", type: "button", img: "refresh.gif", imgdis: "refresh_dis.gif", text: "Refresh", title: "Refresh"},
                                            {id: "process", type: "button", img:"process.gif", imgdis: "process_dis.gif", text: "Process",title: "Process"}
                                        ]);
            } else {
                inner_menu_obj[link_ui_tab_id].loadStruct([{id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save", enabled: has_rights_deal_match_iu}]);
            }
            inner_menu_obj[link_ui_tab_id].attachEvent('onClick', link_ui_template.onclick_menu);

            inner_layout_obj.attachEvent("onContentLoaded", function(name){
                //inner_layout_obj.cells('a').progressOff();
                win.progressOff();
            });
            var template_name = (link_id == -1) ? 'deal.match.insert.php' : 'deal.match.iu.php';        
            var php_path = '<?php echo $app_adiha_loc; ?>';
            var url = php_path + 'adiha.html.forms/_deal_capture/deal_match/' + template_name;
            
            inner_layout_obj.cells('a').attachURL(url, null, params);
            
        }

        /**
         *
         */
        link_ui_template.onclick_menu = function(id) {
            switch (id) {
                case 'refresh':
                    parent.show_hide_left_panel(true);
                    link_ui_template.refresh_match_grids();
                    break;

                case 'match':
                    parent.show_hide_left_panel(true);
                    link_ui_template.match_deal_grids();
                    break;

                case 'process':
                    link_ui_template.process_deal_grids();
                    break;

                case 'save':
                    link_ui_template.save_deal_match_ui();
                    break;
                        
                default:
                    dhtmlx.alert({
                        title:'Sorry! <font size="5">&#x2639 </font>',
                        type:"alert-error",
                        text:"Event not defined."
                    });
                    break;
            }
        }

        /**
        * Refresh left and right grid for Deal Match Tab
        */
        link_ui_template.refresh_match_grids = function(tab_id){
            if (tab_id) {
                var active_tab_id = tab_id;
            } else {
                var active_tab_id = get_active_tab_id();    
            }
			enable_disable_deal_match_menu('refresh',false);
            enable_disable_deal_match_menu('match',false);
            enable_disable_deal_match_menu('process',false);
            var frame_obj = link_ui_template["inner_tab_layout_" + active_tab_id].cells("a").getFrame();
            frame_obj.contentWindow.link_ui_insert.load_match_grids();

        }

        /**
        * Matched left and right grid for insert mode at Deal Match Tab
        */
        link_ui_template.match_deal_grids = function(tab_id){
            if (tab_id) {
                var active_tab_id = tab_id;
            } else {
                var active_tab_id = get_active_tab_id();    
            }
            
            var frame_obj = link_ui_template["inner_tab_layout_" + active_tab_id].cells("a").getFrame();
            var return_result = frame_obj.contentWindow.link_ui_insert.get_match_grids();
            if (!return_result) {
                return;
            } else if (return_result.type == 'alert-error' || return_result.type == 'alert') {
                dhtmlx.alert({
                    title:return_result.title,
                    type:return_result.type,
                    text: return_result.text,
                });
                return false;
             } else {

                link_ui_template.load_link_detail(-2,'',return_result);   
            }
        }

        /**
        * Matched left and right grid for insert mode at Deal Match Tab
        */
        link_ui_template.process_deal_grids = function(){
            var active_tab_id = get_active_tab_id(); 
            
            var frame_obj = link_ui_template["inner_tab_layout_" + active_tab_id].cells("a").getFrame();
            var return_result = frame_obj.contentWindow.link_ui_insert.open_update_book();
            if (!return_result) {
                return;
            } else if (return_result.type != 'Success') {
                dhtmlx.alert({
                    title:return_result.title,
                    type:return_result.type,
                    text: return_result.text,
                });
             } else {

                link_ui_template.load_link_detail(-2,'',return_result);   
            }
        }

        /**
        * Saved matched deals data
        */
        link_ui_template.save_deal_match_ui = function(){
            var active_tab_id = get_active_tab_id();
            //console.log(active_tab_id);
            var frame_obj = link_ui_template["inner_tab_layout_" + active_tab_id].cells("a").getFrame();
            var return_result = frame_obj.contentWindow.deal_match_ui.save_matched_deals(active_tab_id);
            if (!return_result) {
                return;
            } else if (return_result.type == 'alert-error' || return_result.type == 'alert') {
                dhtmlx.alert({
                    title:return_result.title,
                    type:return_result.type,
                    text: return_result.text,
                });
                return false;
             }
            
        }

        /**
         * Parent function to be called after deal match saved from deal.match.ui.php
         */
         link_ui_template.save_matched_deals_callback_parent = function(mode,type,msg,link_id) {
            if (type == 'Success') {
                dhtmlx.message({
                    text:msg,
                    expire:1000
                });
            } else {
                dhtmlx.message({
                    title:'Error',
                    type:"alert-error",
                    text:msg
                });
                return
            }

            if (mode == 'i') {
                var closing_tab_id = get_active_tab_id();

                //refresh parent deal.match.php grid
                parent.link_ui.refresh_link_grid();

                //refresh deal match tab gris
                link_ui_template.refresh_match_grids(-1);

                //create update tab
                link_ui_template.load_link_detail(link_id);

                link_ui_template.link_ui_tabbar.cells(closing_tab_id).close();



            } else {
                var active_tab_id = get_active_tab_id();
                //refresh parent deal.match.php grid
                parent.link_ui.refresh_link_grid();

                //refresh deal match tab gris
                //link_ui_template.refresh_match_grids(-1);

            }
         }

        function get_active_tab_id() {
            var active_tab_id = link_ui_template.link_ui_tabbar.getActiveTab(); 
            active_tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            return active_tab_id;
        } 

        link_ui_template.close_tabs = function(tab_id) {
            if (link_ui_template.link_ui_tabbar.cells(tab_id))
                link_ui_template.link_ui_tabbar.cells(tab_id).close();
        }
      
        
        function enable_disable_menu(itemId,is_enable) {
            var active_tab_id = get_active_tab_id();
            if (is_enable) {               
               inner_menu_obj[active_tab_id].enableItem(itemId);
            } else {
                //console.log(itemId);
                inner_menu_obj[active_tab_id].disableItem(itemId);
            }
        }
		
		function enable_disable_deal_match_menu(itemId,is_enable) {
            var active_tab_id = '-1';
            if (is_enable) {               
               inner_menu_obj[active_tab_id].enableItem(itemId);
            } else {
                //console.log(itemId);
                inner_menu_obj[active_tab_id].disableItem(itemId);
            }
        }
    </script>