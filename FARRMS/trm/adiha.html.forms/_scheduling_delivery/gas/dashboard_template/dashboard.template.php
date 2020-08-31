<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    <?php
        include '../../../../adiha.php.scripts/components/include.file.v3.php';
        
        $form_namespace = 'dashboard';
        $filter_form_obj = new AdihaForm();
        $owner_dropdown = $filter_form_obj->adiha_form_dropdown('EXEC spa_application_users "s"', '0', '0', false);
        
        $form_json = '[{
                            "type": "settings",
                            "position": "label-top"
                        }, {
                            type: "block",
                            blockOffset: 10,
                            list: [{
                                "type": "combo",
                                "name": "owner",
                                "label": "Owner",
                                "validate": "ValidInteger",
                                "position": "label-top",
                                "offsetLeft": "10",
                                "labelWidth": "auto",
                                "inputWidth": "150",
                                "tooltip": "Owner",
                                "required": "true",
                                "filtering": "true",
                                "options": '.$owner_dropdown.'
                            }]
                        }]';

        $layout_json = '[
                            {id: "a", text: "Filter",height:70,width:400, header: false},
                            {id: "b", text: "Template Details"},
                            {id: "c", text: "Template"}
                        ]';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout('template_layout', '', '3J', $layout_json, $form_namespace);
        
        $menu_name = 'dashboard_menu';
        $menu_json = '[
                {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                {id:"t", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                    {id:"add", text:"Add", img:"new.gif"},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis: "delete_dis.gif", disabled: true}
                ]},
                {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif"},
                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                ]},
                
                ]';
//{id:"privilege", text:"Privilege", img:"action.gif", imgdis:"action_dis.gif", disabled: true},
        echo $layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $form_namespace.'.menu_click');
        
        $filter_form_name = 'filter_form';
        echo $layout_obj->attach_form($filter_form_name, 'a');
        
        
        $filter_form_obj->init_by_attach($filter_form_name, $form_namespace);
        echo $filter_form_obj->load_form($form_json);
        echo $filter_form_obj->attach_event('', 'onChange', 'dashboard.owner_on_change');
        
        $template_grid_name = 'template_grid';
        echo $layout_obj->attach_grid_cell($template_grid_name, 'c');
        $template_grid_obj = new AdihaGrid();
        echo $layout_obj->attach_status_bar("c", true);
        echo $template_grid_obj->init_by_attach($template_grid_name, $form_namespace);
        echo $template_grid_obj->set_header("Template ID,Template Name,Template Description, Owner, System Defined");
        echo $template_grid_obj->set_columns_ids("template_id,template_name,template_description,owner,system_defined");
        echo $template_grid_obj->set_widths("100,200,200,100,100");
        echo $template_grid_obj->set_column_types("ro,ro,ro,ro,ro");
        //echo $template_grid_obj->enable_multi_select();
        echo $template_grid_obj->set_column_visibility("true,false,false,true,true");
        echo $template_grid_obj->enable_paging(100, 'pagingArea_c', 'true');
        echo $template_grid_obj->enable_column_move('false,true,true,true,true');
        echo $template_grid_obj->set_sorting_preference('str,str,str,str,str');
        echo $template_grid_obj->set_search_filter(true);
        echo $template_grid_obj->return_init();
        echo $template_grid_obj->enable_header_menu();
        echo $template_grid_obj->attach_event('', 'onRowDblClicked', $form_namespace.'.create_template_detail_tab');
        echo $template_grid_obj->attach_event('', 'onRowSelect', $form_namespace.'.template_grid_select');
        //attach grid ends
        
        $tabbar_name = 'template_details';
        echo $layout_obj->attach_tab_cell($tabbar_name, 'b');
        $tabbar_obj = new AdihaTab();
        echo $tabbar_obj->init_by_attach($tabbar_name, $form_namespace);
        echo $tabbar_obj->enable_tab_close();
        echo $tabbar_obj->attach_event('', "onTabClose", 'dashboard.template_details_close');

        echo $layout_obj->close_layout();
    ?>
    <!-- Invoice Summary Template -->
    <script id="form_template" type="text/template">
        [{"type": "settings", "position": "label-top", "offsetLeft": 10,"labelWidth":130, "inputWidth":120},                
        {"type": "input", "name": "template_id", "label": "Template ID", "value": "<%= template_id %>","readonly":true,"hidden":true, "inputWidth":220},
        {"type": "newcolumn", "offset":20},
        {"type": "input", "name": "template_name", "label": "Template Name", "required":"true", "value": "<%= template_name %>", "inputWidth":220},
        {"type": "newcolumn", "offset":20},
        {"type": "input", "name": "template_description", "label": "Template Description", "required":"true", "value": "<%= template_description %>", "inputWidth":220, "labelWidth":200},
        {"type": "newcolumn", "offset":20},
        {"type": "checkbox", "name":"system_defined", "label": "System Defined", "value": "<%= system_defined %>","position":"label-right","offsetTop":30},
        {"type": "newcolumn", "offset":20},
        {"type": "input", "name": "owner", "label": "Owner","readonly":true,"hidden":true, "required":"true", "value": "<%= owner %>", "inputWidth":220}
        ]
    </script>   
    <!-- Invoice Summary Template -->
    <script type="text/javascript">
        $(document).ready(function(){
            dashboard.refresh_template_grid();
        });
        
        templateDetails = {};
        templateDetails.toolbar = {};
        templateDetails.layout = {};
        templateDetails.form = {};
        templateDetails.menu = {};
        
        dashboard.template_details_close = function(id) {
            delete dashboard.pages[id];
            delete templateDetails.toolbar[id];;
            delete templateDetails.layout[id];
            delete templateDetails.form[id];
            delete templateDetails.menu[id];
            
            return true;
        };
        
        var filters_window;
        /**
         * [unload_options_window Unload Options window.]
         */
        function unload_filters_window() {        
            if (filters_window != null && filters_window.unload != null) {
                filters_window.unload();
                filters_window = w1 = null;
            }
        }
        
        dashboard.template_grid_select = function(row_id,ind) {
            //if(has_rights_dashboard_template_delete)
                dashboard.dashboard_menu.setItemEnabled("delete");
            //if(has_rights_dashboard_template_privilege)
                //dashboard.dashboard_menu.setItemEnabled("privilege");
        }
        
        dashboard.menu_click = function(id, zoneId, cas) {
            switch(id) {
                case "refresh":
                    dashboard.refresh_template_grid();
                    break;
                case "pdf":
                    dashboard.template_grid.toPDF(js_php_path +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case "excel":
                    dashboard.template_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "add":
                    dashboard.create_template_detail_tab(-1,-1);
                    break;
                case "delete":
                    var select_id = dashboard.template_grid.getSelectedRowId();
                    if (select_id != null) {
                        dhtmlx.message({
                            type: "confirm",
                            title: "Confirmation",
                            ok: "Confirm",
                            text: "Are you sure you want to delete?",
                            callback: function(result) {
                                if (result) {
                                    var dashboard_template_id = dashboard.template_grid.cells(select_id, dashboard.template_grid.getColIndexById('template_id')).getValue();
                                    
                                    data = {
                                        "action": "spa_dashboard_template", 
                                        "dashboard_template_id": dashboard_template_id, 
                                        "flag": "d"
                                    }
                                    adiha_post_data("alert", data, "", "","delete_post_callback");
                                }
                            }
                        });
                    }

                    break;
                case "privilege":
                    show_messagebox("Under Construction");
                    break;
            }
        }
        
        function delete_post_callback(result) {
            if (result[0]['errorcode'] == 'Success') {
                var select_id = dashboard.template_grid.getSelectedRowId();
                var template_id = dashboard.template_grid.cells(select_id, dashboard.template_grid.getColIndexById('template_id')).getValue();
                
                if (dashboard.pages[template_id]) {
                    dashboard.template_details.tabs(template_id).close(false);
                }
                
                dashboard.refresh_template_grid();
            }
        }
        
        dashboard.owner_on_change = function() {
            dashboard.refresh_template_grid();
        }
        
        dashboard.refresh_template_grid = function(callback_function) {
            dashboard.dashboard_menu.setItemDisabled("delete");
            //dashboard.dashboard_menu.setItemDisabled("privilege");
                
            var owner = dashboard.filter_form.getItemValue('owner');
            var filter_param = '&owner_filter=' + owner;
            
            var param = {
                "flag": "s",
                "action":"spa_dashboard_template",
                "grid_type":"g"
            };
    
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param + filter_param;
            var grid_cell = dashboard.template_layout.cells("c");
            
            if (callback_function != '' && callback_function != undefined) {
                dashboard.template_grid.clearAndLoad(param_url, callback_function);
            } else {
                dashboard.template_grid.clearAndLoad(param_url);
            }
        }
        
        function open_tab() {
            var prev_id = dashboard.template_details.getActiveTab();
            var system_id = dashboard.template_details.tabs(prev_id).getText();
            var primary_value = dashboard.template_grid.findCell(system_id, 0, true, true);
            
            if (primary_value != "") {
                if (dashboard.pages[prev_id]) {
                    delete dashboard.pages[prev_id];
                    dashboard.template_details.cells(prev_id).close(false);
                    dashboard.template_details.tabs(prev_id).close(false);
                }
                var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                dashboard.template_grid.selectRowById(r_id,false,true,true);
                dashboard.create_template_detail_tab(r_id, 0);
            } 
        }
        
        function refresh_tab() {
            var prev_id = dashboard.template_details.getActiveTab();
            var primary_value = dashboard.template_grid.findCell(prev_id, 0, true, true);
            
            if (primary_value != "") {
                if (dashboard.pages[prev_id]) {
                    delete dashboard.pages[prev_id];
                    dashboard.template_details.cells(prev_id).close(false);
                    dashboard.template_details.tabs(prev_id).close(false);
                }
                var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                dashboard.template_grid.selectRowById(r_id,false,true,true);
                dashboard.create_template_detail_tab(r_id, 0);
            } 
        }
        
        dashboard.create_template_detail_tab = function(r_id, col_id) {
            if (r_id == -1 && col_id == -1) {
                var template_id = (new Date()).valueOf().toString();
                var template_name = "New";
                mode = 'i';
            } else {
                var template_id = dashboard.template_grid.cells(r_id, dashboard.template_grid.getColIndexById('template_id')).getValue();
                var template_name = dashboard.template_grid.cells(r_id, dashboard.template_grid.getColIndexById('template_name')).getValue();
                mode = 'u';
            }
            
            if (!dashboard.pages[template_id]) {
                // add tab
                dashboard.template_details.addTab(template_id, template_name);
                dashboard.template_details.cells(template_id).setActive();
    
                // treat tab cell as window
                win = dashboard.template_details.cells(template_id);
                dashboard.pages[template_id] = win;
                
                templateDetails.toolbar[template_id] = dashboard.template_details.cells(template_id).attachMenu({
                    icons_path: js_image_path + "dhxmenu_web/",
                    items:[
                            {id:"save", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}
                        ]
                });
                
                var object_id = template_id;
                
                toolbar_obj = templateDetails.toolbar[template_id];
                
                templateDetails.toolbar[template_id].attachEvent("onClick", function(id) {
                    switch(id) {
                        case "save":
                            save_template();
                            break;
                        default:
                            break;
                    }
                });
                
                // attach layout for invoice tab
                templateDetails.layout[template_id] = dashboard.template_details.tabs(template_id).attachLayout({
                    pattern:'2E',
                    cells:[
                        {id: "a", text: "Summary",height:70, header: false},
                        {id: "b", text: "Template Details"}
                    ]
                });
                
                var form_json = null;
                form_json = dashboard.get_form_data(r_id);
                
                // attach form for invoice tab
                templateDetails.form[template_id] = templateDetails.layout[template_id].cells("a").attachForm();
                templateDetails.form[template_id].loadStruct(form_json);
                
                templateDetails.menu[template_id] = templateDetails.layout[template_id].cells("b").attachMenu({
                    icons_path: js_image_path + "dhxmenu_web/",
                    items:[
                            {id: "edit", text: "Edit", img: "edit.gif", imgdis: "edit_dis.gif", items: [
                                    {id: "category", text: "Add Category", img: "add.gif", imgdis: "add_dis.gif"},
                                    {id: "sub_total", text: "Add Sub Total", img: "add.gif", imgdis: "add_dis.gif"},
                                    {id: "delete", text: "Delete", img: "delete.gif", imgdis: "delete_dis.gif" }
                                ]},
                            {id: "action", text: "Actions", img:"action.gif", imgdis:"action_dis.gif", items: [
                                    {id: "options", text: "Options", img: "options.gif",imgdis: "options_dis.gif"},
                                    {id: "filter", text: "Filter", img: "filter.gif", imgdis: "filter_dis.gif"}
                                ]}
                        ]
                });
                
                templateDetails.menu[template_id].attachEvent("onClick", function(id){
                    var ifr_dashboard = templateDetails.layout[template_id].cells("b").getFrame();
                    
                    switch(id) {
                        case "category":
                            ifr_dashboard.contentWindow.add_category();
                            break;
                        case "sub_total":
                            ifr_dashboard.contentWindow.add_sub_total();
                            break;
                        case "delete":
                            ifr_dashboard.contentWindow.delete_selected_item();
                            break;
                        case "options":
                            ifr_dashboard.contentWindow.btn_options_click();
                            break;
                        case "filter":
                            var return_array = ifr_dashboard.contentWindow.btn_filter_click();
                            var dashboard_template_detail_id = return_array['dashboard_template_detail_id'];
                            var template_datatype = return_array['template_datatype'];
                            
                            unload_filters_window();
                            if (!filters_window) {
                                filters_window = new dhtmlXWindows();
                            }
                            
                            var win = filters_window.createWindow('w1', 0, 0, 375, 280);
                            win.setText("Filters");
                            win.centerOnScreen();
                            win.maximize();
                            win.setModal(true);
                            win.attachURL('dashboard.template.detail.filters.php?callfrom=' + template_datatype + '&dashboard_template_detail_id=' + dashboard_template_detail_id, false, true);
                            break;
                        default:
                            break;
                    }
                });
                
                var post_data = {
                                    "template_id":  template_id == '' ? 'NULL' : template_id
                                }
                
                var url = app_form_path  + '_scheduling_delivery/gas/dashboard_template/dashboard.detail.template.php?dashboard_template_id=' + template_id;
                
                templateDetails.layout[template_id].cells('b').attachURL(url, null, post_data);
                
            } else {
                dashboard.template_details.cells(template_id).setActive();
            }
        }
        
        dashboard.get_form_data = function(r_id) {
            var form_template = _.template($('#form_template').text());
            var template_id = '';
            var template_name = '';
            var template_description = '';
            var system_defined = '';
            var owner = dashboard.filter_form.getItemValue("owner");
            
            if(r_id != -1) {
                var template_id = dashboard.template_grid.cells(r_id, dashboard.template_grid.getColIndexById('template_id')).getValue();
                var template_name = dashboard.template_grid.cells(r_id, dashboard.template_grid.getColIndexById('template_name')).getValue();
                var template_description = dashboard.template_grid.cells(r_id, dashboard.template_grid.getColIndexById('template_description')).getValue();
                var system_defined = dashboard.template_grid.cells(r_id, dashboard.template_grid.getColIndexById('system_defined')).getValue();
                var owner = dashboard.template_grid.cells(r_id, dashboard.template_grid.getColIndexById('owner')).getValue();
            }
            
            formData = form_template({
                            template_id: template_id,
                            template_name: template_name,
                            template_description: template_description,
                            system_defined: system_defined,
                            owner:owner
                       });
            
            formData = jQuery.parseJSON(formData);
            
            return formData;
        }
        
        function undock_detail_window(template_id) {
            templateDetails.layout[template_id].cells('b').undock(300, 300, 900, 700);
            templateDetails.layout[template_id].dhxWins.window('b').maximize();
            templateDetails.layout[template_id].dhxWins.window("b").button("park").hide();
        }
        
        function save_template() {
            var template_id = dashboard.template_details.getActiveTab();
            dashboard_template_id = template_id;
            var ifr_dashboard = templateDetails.layout[template_id].cells("b").getFrame();
                
            var dashboard_template_name = templateDetails.form[template_id].getItemValue("template_name");
            var dashboard_template_desc = templateDetails.form[template_id].getItemValue("template_description");
            var dashboard_template_owner = templateDetails.form[template_id].getItemValue("owner");
            var system_defined = (templateDetails.form[template_id].getItemValue("template_description") == 1) ? 'y' : 'n';
            var duplicate_flag = 0;
             
            if(dashboard_template_name == 'NULL' || dashboard_template_name == '') {
                var message = ifr_dashboard.contentWindow.get_message('EMPTY_DASHBOARD_NAME');
                show_messagebox(message);
                return;
            } 
            
            if(dashboard_template_desc == 'NULL' || dashboard_template_desc == '') {
                var message = ifr_dashboard.contentWindow.get_message('EMPTY_DASHBOARD_DESC');
                show_messagebox(message);
                return;
            }        
            
            var category_check = new Array();
            $('#destination_content_ul li.category').each(function(){
                category_check.push($(this).find('.category_div a').text()); 
                if ($(this).find('.category_div a').text().length < 1) {
                    var message = ifr_dashboard.contentWindow.get_message('EMPTY_CATEGORY_NAME');
                    show_messagebox(message);
                    duplicate_flag = 1;
                    return;
                }
            });
            
            if(has_duplicate(category_check)) {
                var message = ifr_dashboard.contentWindow.get_message('DUBLICATE_CATEGORY');
                show_messagebox(message);
                duplicate_flag = 1;
                return;
            }
             
            if(duplicate_flag == 1) return;
            
            //Validation to check if the same data type name consist in the category
            $('#destination_content_ul li.category').each(function(){
                var datatype_check = new Array();
                $(this).find('ul li').each(function(){                   
                   datatype_check.push(trim($(this).find('.forhover a').text())); 
                   if ($(this).find('.forhover a').text().length < 1) {
                        var message = ifr_dashboard.contentWindow.get_message('EMPTY_DATA_TYPE_NAME');
                        show_messagebox(message);
                        duplicate_flag = 1;
                        return;
                }
                });
                
                if(has_duplicate(datatype_check)) {
                    var message = ifr_dashboard.contentWindow.get_message('SAME_DATA_IN_CATEGORY');
                    show_messagebox(message);
                    duplicate_flag = 1;
                    return;
                } 
            });
            
            if(duplicate_flag == 1) return;
            
            //Inserting the header data 
            data = {"action": "spa_dashboard_template",
                    "flag": mode,
                    "dashboard_template_id": dashboard_template_id,
                    "dashboard_template_name": dashboard_template_name,
                    "dashboard_template_desc": dashboard_template_desc,
                    "system_defined": system_defined,
                    "dashboard_template_owner": dashboard_template_owner
                    };
            
            if (mode == 'u') {
                adiha_post_data('return_array', data, '', '', 'save_template_details', '', '');
            } else {
               result = adiha_post_data('alert', data, '', '', 'refresh_destination_grid', '', '');
            }
        }
        
        function save_template_details(return_value) {
            if(dashboard_template_id == 'NULL')
                dashboard_template_id = return_value[5];
               
            dashboard_template = dashboard_template_id;
            
            var xml = '<Root>';    
            var ifr_dashboard = templateDetails.layout[dashboard_template_id].cells("b").getFrame();
            xml = xml + ifr_dashboard.contentWindow.get_data_type_xml(dashboard_template_id);
            xml = xml + '</Root>';
            
            //Inserting the detail data
            data = {"action": "spa_dashboard_template_detail",
                    "flag": mode,
                    "dashboard_template_id": dashboard_template_id,
                    "xmltext": xml
                    };
        
            result = adiha_post_data('alert', data, '', '', 'refresh_destination_grid', '', '');
        }
        
        function refresh_destination_grid(result) {
            var ifr_dashboard = templateDetails.layout[dashboard_template_id].cells("b").getFrame();
            ifr_dashboard.contentWindow.refresh_destination_grid(dashboard_template_id);
            
            if (result[0].errorcode == 'Success') {             
                var tab_id = dashboard.template_details.getActiveTab();
                var previous_text = dashboard.template_details.tabs(tab_id).getText();
                if (previous_text == "New") {
                    var tab_text = new Array();
                    if (result[0].recommendation.indexOf(",") != -1) { 
                        tab_text = result[0].recommendation.split(",") 
                    } else { 
                        tab_text.push(0, result[0].recommendation); 
                    }
                    
                    dashboard.template_details.tabs(tab_id).setText(tab_text[1]);
                    dashboard.refresh_template_grid(open_tab);
                } else {
                    dashboard.refresh_template_grid(refresh_tab);
                }
            }
        }
        
        
        //Function to check if there is dublicate data in the array
        function has_duplicate(array) {
            var valuesSoFar = [];
            for (var i = 0; i < array.length; ++i) {
                var value = array[i];
                if (valuesSoFar.indexOf(value) !== -1) {
                    return true;
                }
                valuesSoFar.push(value);
            }
            return false;
        }
        
    </script>
<body class = "bfix2">
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
</html>