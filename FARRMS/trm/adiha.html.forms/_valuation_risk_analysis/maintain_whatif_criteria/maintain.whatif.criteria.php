<?php
/**
* Maintain whatif criteria screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <?php  include '../../../adiha.php.scripts/components/include.file.v3.php'; ?>
    </head>
    
<?php
    $php_script_loc = $app_php_script_loc;
    $form_namespace = 'Setup_What_If_criteria';
    $function_id = 10183400;
    $rights_maintain_whatif_criteria_iu = 10183410;
    $rights_maintain_whatif_criteria_del = 10183411;
    $rights_maintain_whatif_criteria_run = 10183412;
    $rights_maintain_whatif_criteria_hypothetical = 10183414;
    $rights_maintain_whatif_criteria_hypothetical_del = 10183415;
    $application_function_id = 10183400; 
     
    $has_right_maintain_whatif_criteria_iu = false;
    $has_right_maintain_whatif_criteria_del = false;
      
    list(
        $has_right_maintain_whatif_criteria_iu,
        $has_right_maintain_whatif_criteria_del,
        $has_rights_maintain_whatif_criteria_run,
        $has_rights_maintain_whatif_criteria_hypothetical,
        $has_rights_maintain_whatif_criteria_hypothetical_del
    ) = build_security_rights (
        $rights_maintain_whatif_criteria_iu,
        $rights_maintain_whatif_criteria_del,
        $rights_maintain_whatif_criteria_run,
        $rights_maintain_whatif_criteria_hypothetical,
        $rights_maintain_whatif_criteria_hypothetical_del
    );

    $whatif_criteria_id = get_sanitized_value($_GET['whatif_criteria_id'] ?? '');

    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("maintain_criteria_grid", "EXEC spa_maintain_criteria_dhx @flag = 'g'");
    $form_obj->enable_multiple_select();
    // $form_obj->define_layout_width(300);
    $form_obj->define_custom_functions('pre_save_criteria', 'load_criteria', 'delete_criteria', '');
    echo $form_obj->init_form('What If Criteria', 'What If Criteria Details', $whatif_criteria_id);
    echo $form_obj->close_form();
?>
<body>
    <script type="text/javascript">
    var _window = {};
    var function_id = <?php echo $function_id; ?>;
    var has_right_maintain_whatif_criteria_iu =<?php echo (($has_right_maintain_whatif_criteria_iu) ? $has_right_maintain_whatif_criteria_iu : '0'); ?>;
    var has_rights_maintain_whatif_criteria_del =<?php echo (($has_right_maintain_whatif_criteria_del) ? $has_right_maintain_whatif_criteria_del : '0'); ?>;
    var has_rights_maintain_whatif_criteria_run =<?php echo (($has_rights_maintain_whatif_criteria_run) ? $has_rights_maintain_whatif_criteria_run : '0'); ?>;
    var has_rights_maintain_whatif_criteria_hypothetical =<?php echo (($has_rights_maintain_whatif_criteria_hypothetical) ? $has_rights_maintain_whatif_criteria_hypothetical : '0'); ?>;
    var has_rights_maintain_whatif_criteria_hypothetical_del =<?php echo (($has_rights_maintain_whatif_criteria_hypothetical_del) ? $has_rights_maintain_whatif_criteria_hypothetical_del : '0'); ?>;
    var current_date = 0;
    var criteria_id = null;

        $(function() {
            if(!has_right_maintain_whatif_criteria_iu){
                Setup_What_If_criteria.menu.setItemDisabled('add');
            }
            Setup_What_If_criteria.menu.addNewSibling('t2','run','Run',true, 'run.gif','run_dis.gif');
            
            Setup_What_If_criteria.grid.attachEvent("onRowSelect", function(id,ind) {
                if(!has_rights_maintain_whatif_criteria_run) {
                    Setup_What_If_criteria.menu.setItemDisabled('run');
                } else {
                    Setup_What_If_criteria.menu.setItemEnabled('run');
                }
                if(!has_rights_maintain_whatif_criteria_del) {
                    Setup_What_If_criteria.menu.setItemDisabled('delete');
                }
            });
            
            Setup_What_If_criteria.menu.attachEvent("onClick", function(id, zoneId, cas){
                if(id == 'run') {
                    Setup_What_If_criteria.run_criteria();
                }
            });
        })
        
        /*
         * Load Function - Called when double clicked on critera grid.
         */
        Setup_What_If_criteria.load_criteria = function(win, tab_id, grid_obj) {
            win.progressOff();
            var active_object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            
            Setup_What_If_criteria["inner_layout_" + active_object_id] = win.attachLayout('1C');
            
            data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": function_id,
                    "template_name": "Setup_What_If_criteria",
                    "parse_xml": "<Root><PSRecordSet criteria_id=\"" + active_object_id + "\"></PSRecordSet></Root>"
                 };

            adiha_post_data('return_array', data, '', '', 'load_criteria_callback', '');
        }
        
        /*
         * Callback function of load_criteria. Create the tab and load tab contents.
         */
        load_criteria_callback = function(result) {
            var criteria_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (criteria_tab_id.indexOf("tab_") != -1) ? criteria_tab_id.replace("tab_", "") : criteria_tab_id;
            
            var result_length = result.length;
            var tab_json = '';
            for (i = 0; i < result_length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);
            }
            tab_json = '{tabs: [' + tab_json + ']}';
            
            Setup_What_If_criteria["criteria_tab_" + active_object_id] = Setup_What_If_criteria["inner_layout_" + active_object_id].cells('a').attachTabbar({mode:"top",arrows_mode:"auto"});
            var a = Setup_What_If_criteria["criteria_tab_" + active_object_id];
            Setup_What_If_criteria["criteria_tab_" + active_object_id].loadStruct(tab_json);
            var cnt = 0;
            Setup_What_If_criteria["criteria_tab_" + active_object_id].forEachTab(function(tab){
                var tab_name = tab.getText();
                switch(tab_name) {
                    case "General":
                        load_general_tab(tab, active_object_id, result[cnt][2]);
                        break;
                    case "Portfolio":
                        load_portfolio_tab(tab);
                        break;
                    case "Scenario":
                        load_scenario_tab(tab, active_object_id, result[cnt][2]);
                        break;
                     case "Migration":
                        load_migration_tab(tab, active_object_id, result[cnt][2]);
                        break;  
                    case "Measure":
                        load_measure_tab(tab, active_object_id, '');
                        break;
                }
                cnt++;
            });
        }
        
        /*
         * load the form of the general tab
         */
        load_general_tab = function(tab_obj, active_object_id, form_json) {
            Setup_What_If_criteria["general_form" + active_object_id] = tab_obj.attachForm();
            if (form_json) {
                Setup_What_If_criteria["general_form" + active_object_id].loadStruct(form_json);
            }
        }
        
        load_migration_tab = function(tab_obj, active_object_id, form_json) {
            Setup_What_If_criteria["migration_layout_" + active_object_id] = tab_obj.attachLayout({
                pattern:'1C',
                cells: [{id: "a",text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\" ></a>Migration"}]
            });

            // Setup_What_If_criteria["migration_form_" + active_object_id] = Setup_What_If_criteria["migration_layout_" + active_object_id].cells('a').attachForm();
            
            load_migration_tab_menu(active_object_id);
            load_migration_tab_grid(active_object_id);
        }
        
        /* ===================== Portfolio Tab Starts =================== */
        
        /*
         * load the content of the portfolio tab
         */
        load_portfolio_tab = function(tab_obj, portfolio_tab_id) {
            var criteria_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (criteria_tab_id.indexOf("tab_") != -1) ? criteria_tab_id.replace("tab_", "") : criteria_tab_id;
            
            var portfolio_tab_json = '{tabs: [{"id":"portfolio_deals_' + active_object_id + '","text":"Deals","active":"true"}, {"id":"portfolio_hypothetical_' + active_object_id + '","text":"Hypothetical"}]}'
            Setup_What_If_criteria["portfolio_tab_" + active_object_id] = tab_obj.attachTabbar({mode:"bottom",arrows_mode:"auto"});
            Setup_What_If_criteria["portfolio_tab_" + active_object_id].loadStruct(portfolio_tab_json);
            
            Setup_What_If_criteria["portfolio_tab_" + active_object_id].forEachTab(function(tab){
                var tab_name = tab.getText();
                switch(tab_name) {
                    case "Deals":
                        load_portfolio_tab_deals(tab, active_object_id);
                        break;
                    case "Hypothetical":
                        load_portfolio_tab_hypothetical(tab, active_object_id);
                        break;
                }
            });
        }
        
        /*
         * Attach the portfolio template to the Deal tab
         */
        load_portfolio_tab_deals = function(tab_obj, active_object_id) {
            criteria_id = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_id');
            if(!criteria_id) {
                criteria_id = null;
            }
            
            var sub_book_query = "EXEC spa_portfolio_group_book @flag = 'f', @mapping_source_usage_id = " + criteria_id + "," + "@mapping_source_value_id = 23201"; // sdv for limit
            var deal_query = "EXEC spa_portfolio_mapping_deal @flag='x', @mapping_source_usage_id=" + criteria_id + "," + "@mapping_source_value_id = 23201"; ;
            var filter_query =  "EXEC spa_portfolio_group_book @flag = 's', @mapping_source_usage_id = " + criteria_id + "," + "@mapping_source_value_id = 23201";
            
            tab_obj.attachURL("../run_at_risk/generic.portfolio.mapping.template.php", null, {sub_book: sub_book_query, deals: deal_query, book_filter: filter_query, is_tenor_enable:true, req_portfolio_group: true, func_id: function_id});
        }
        
        /*
         * Load the hypothetical tab
         */
        load_portfolio_tab_hypothetical = function(tab_obj, active_object_id) {
            load_portfolio_hypothetical_menu(tab_obj, active_object_id);
            load_portfolio_hypothetical_grid(tab_obj, active_object_id);
        } 
        
        /*
         * Load the menu of hypothetical tab
         */
        load_portfolio_hypothetical_menu = function(tab_obj, active_object_id) {
            criteria_id = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_id');
            var add_enable_status = true;
            if (criteria_id == '') {
                add_enable_status = false;
            }
            if(has_rights_maintain_whatif_criteria_hypothetical)
                has_rights_maintain_whatif_criteria_hypothetical = true;
            else 
                has_rights_maintain_whatif_criteria_hypothetical = false;
            
            var hypothetical_menu_json = [
                {id:"t1", text:"Edit", img:"edit.gif", items:[
                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:has_rights_maintain_whatif_criteria_hypothetical},
                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                ]},
                {id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:true},
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:true}
                ]}
            ];
            
            Setup_What_If_criteria["hypothetical_menu_" + active_object_id] = tab_obj.attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : hypothetical_menu_json
            }); 
            
            Setup_What_If_criteria["hypothetical_menu_" + active_object_id].attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
                        open_portfolio_hypothetical('', active_object_id);
                        break;
                    case 'delete':
                        delete_portfolio_hypothetical(active_object_id);
                        break;
                    case 'pdf':
                        Setup_What_If_criteria["hypothetical_grid_" + active_object_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case 'excel':
                        Setup_What_If_criteria["hypothetical_grid_" + active_object_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                }
            });
        }
        
        /*
         * Open the hypothetical UI window on add or grid double click.
         */
        open_portfolio_hypothetical = function(whatif_criteria_other_id, active_object_id) {
            criteria_id = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_id');
            var height = Setup_What_If_criteria["inner_layout_" + active_object_id].cells('a').getHeight();
            hypothetical_window = new dhtmlXWindows();
            var win = hypothetical_window.createWindow('w1', 0, 0, 800, height);
            win.setText("Hypothetical Deal");
            win.centerOnScreen();
            win.setModal(true);
            win.attachURL('maintain.whatif.criteria.hypothetical.php?whatif_criteria_other_id=' + whatif_criteria_other_id + '&criteria_id=' + criteria_id);
            win.attachEvent("onClose", function(win){
                refresh_portfolio_hypothetical_grid();
                return true;
            });
        }
        
        /*
         * Delete the hypothetical grid data.
         */
        delete_portfolio_hypothetical = function(active_object_id) {
            var selected_id = Setup_What_If_criteria["hypothetical_grid_" + active_object_id].getSelectedId();
            var selected_row_arr = selected_id.split(',');

            if(selected_id == null) {
                show_messagebox('Please select the data you want to delete.');
                return;
            }
            
            whatif_other_id_arr = new Array();
            for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                var id = Setup_What_If_criteria["hypothetical_grid_" + active_object_id].cells(selected_row_arr[cnt], Setup_What_If_criteria["hypothetical_grid_" + active_object_id].getColIndexById('id')).getValue();
                whatif_other_id_arr.push(id);
            }
            var whatif_other_id = whatif_other_id_arr.toString();
            
            var data = {
                        "action": "spa_maintain_criteria_dhx",
                        "flag": "o",
                        "whatif_criteria_other_id": whatif_other_id
                    };

            adiha_post_data('confirm', data, '', '', 'refresh_portfolio_hypothetical_grid', '');
            
        }
        
        /*
         * Load the grid hypothetical tab
         */
        load_portfolio_hypothetical_grid = function(tab_obj, active_object_id) {
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id] = tab_obj.attachGrid();
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");    
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setHeader("ID,Sub Book,Template,Block Defintion,Counterparty,Buy Index,Buy Price,Buy Pricing Index,Buy Volume,Buy Total Volume,Buy Term Start,Buy Term End,Sell Index,Sell Price,Sell Pricing Index,Sell Volume,Sell Total Volume,Sell Term Start,Sell Term End",null,["text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:right;","text-align:left;","text-align:right;","text-align:right;","text-align:left;","text-align:left;","text-align:left;","text-align:right;","text-align:left;","text-align:right;","text-align:right;","text-align:left;","text-align:left;"]);
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setColumnIds("id,sub_book,template,block_definition,counterparty,buy_index,buy_price,buy_pricing_index,buy_volume,buy_total_volume,buy_term_start,buy_term_end,sell_index,sell_price,sell_price_index,sell_volume,sell_total_volume,sell_term_start,sell_term_end");
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setColTypes("ro,ro,ro,ro,ro,ro,ro_p,ro,ro_v,ro_v,ro,ro,ro,ro_p,ro,ro_v,ro_v,ro,ro");
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setColAlign(",,,,,,right,,right,right,,,,right,,right,right,,");
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setColSorting("str,str,str,str,str,str,int,str,int,int,date,date,str,int,str,int,int,date,date");
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setColumnsVisibility("true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false");
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setInitWidths('0,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120');
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].enableMultiselect(true);
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].setPagingWTMode(true,true,true,[5,10,20,30,40,50,60,70,80,90,100,200]);
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].init();
            
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].attachEvent("onRowSelect", function(id,ind){
                if(has_rights_maintain_whatif_criteria_hypothetical_del)
                    Setup_What_If_criteria["hypothetical_menu_" + active_object_id].setItemEnabled('delete');
                else 
                    Setup_What_If_criteria["hypothetical_menu_" + active_object_id].setItemDisabled('delete');
            });
            
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].attachEvent("onRowDblClicked", function(rId,cInd){
                if(has_rights_maintain_whatif_criteria_hypothetical){
                whatif_criteria_other_id = Setup_What_If_criteria["hypothetical_grid_" + active_object_id].cells(rId, Setup_What_If_criteria["hypothetical_grid_" + active_object_id].getColIndexById('id')).getValue();
                open_portfolio_hypothetical(whatif_criteria_other_id, active_object_id);
                }
            });
            
            refresh_portfolio_hypothetical_grid();
        }
        
        /*
         * Refresh the grid of the hypothetical tab
         */
        refresh_portfolio_hypothetical_grid = function() {
            var criteria_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (criteria_tab_id.indexOf("tab_") != -1) ? criteria_tab_id.replace("tab_", "") : criteria_tab_id;
            criteria_id = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_id');
            
            var param = {
                            "action": "spa_maintain_criteria_dhx",
                            "flag": "h",
                            "criteria_id": criteria_id
                     };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].clearAll();
            Setup_What_If_criteria["hypothetical_grid_" + active_object_id].loadXML(param_url);
            Setup_What_If_criteria["hypothetical_menu_" + active_object_id].setItemDisabled('delete');
        }
        
        /* ================ Portfolio Tab Ends =================== */
        
        /*================= Scenario Tab Starts ==================*/
        
        /*
         * load the content of the scenario tab.
         */
        load_scenario_tab = function(tab_obj, active_object_id, form_json) {
            Setup_What_If_criteria["scenario_layout_" + active_object_id] = tab_obj.attachLayout({
                pattern:'2E',
                cells: [{id: "a",text: "Form", header: false, height: 120}, {id: "b",text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\"undock_scenario_grid();\"></a>Scenario"}]
            });
            
            load_scenario_tab_form(active_object_id, form_json);
            load_scenario_tab_menu(active_object_id);
            load_scenario_tab_grid(active_object_id);
        }
        
        load_migration_tab_menu = function(active_object_id) {
            if(has_right_maintain_whatif_criteria_iu) {
                has_right_maintain_whatif_criteria_iu = true;
            } else {
                has_right_maintain_whatif_criteria_iu = false;
            }
            var migration_menu_json = [
                {id:"t1", text:"Edit", img:"edit.gif", items:[
                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:has_right_maintain_whatif_criteria_iu},
                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                ]},
                {id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:true},
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:true}
                ]}
            ];
            Setup_What_If_criteria["migration_menu_" + active_object_id] = Setup_What_If_criteria["migration_layout_" + active_object_id].cells('a').attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : migration_menu_json
            }); 

            Setup_What_If_criteria["migration_menu_" + active_object_id].attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
                        var new_id = (new Date()).valueOf();

                        Setup_What_If_criteria["migration_grid_" + active_object_id].addRow(new_id,['','','','','','']);
                        Setup_What_If_criteria["migration_grid_" + active_object_id].forEachRow(function(row){
                            Setup_What_If_criteria["migration_grid_" + active_object_id].forEachCell(row,function(cellObj,ind){
                                Setup_What_If_criteria["migration_grid_" + active_object_id].validateCell(row,ind)
                            });
                        });
                        break;
                    case 'delete':
                        var selected_row = Setup_What_If_criteria["migration_grid_" + active_object_id].getSelectedRowId();
                        var selected_row_arr = selected_row.split(',');
                        for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                            var migration_id = Setup_What_If_criteria["migration_grid_" + active_object_id].cells(selected_row_arr[cnt], 0).getValue();
                            Setup_What_If_criteria["migration_grid_" + active_object_id].deleteRow(selected_row_arr[cnt]);
                            Setup_What_If_criteria["migration_menu_" + active_object_id].setItemDisabled('delete');
                            if (migration_id != '') {
                                Setup_What_If_criteria["migration_grid_" + active_object_id].setUserData("","deleted_xml", "deleted");
                            }
                        }
                        break;
                    case 'pdf':
                        Setup_What_If_criteria["migration_grid_" + active_object_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case 'excel':
                        Setup_What_If_criteria["migration_grid_" + active_object_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    
                }
            });

        }
        
        /*
         * load the form of the scenario tab.
         */
        load_scenario_tab_form = function(active_object_id, form_json) {
            Setup_What_If_criteria["scenario_form_" + active_object_id] = Setup_What_If_criteria["scenario_layout_" + active_object_id].cells('a').attachForm();
            if (form_json) {
                Setup_What_If_criteria["scenario_form_" + active_object_id].loadStruct(form_json);
            }
            
            Setup_What_If_criteria["scenario_form_" + active_object_id].attachEvent('onChange', function (name, value) {
                if (name == 'scenario_type') {
                    switch_scenario_grid();
                } 
            });
        }
        
        /*
         * load the menu of the scenario tab.
         */
        load_scenario_tab_menu = function(active_object_id) {
            if(has_right_maintain_whatif_criteria_iu) {
                has_right_maintain_whatif_criteria_iu = true;
            } else {
                has_right_maintain_whatif_criteria_iu = false;
            }
            var scenario_menu_json = [
                {id:"t1", text:"Edit", img:"edit.gif", items:[
                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:has_right_maintain_whatif_criteria_iu},
                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                ]},
                {id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:true},
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:true}
                ]}
            ];
            Setup_What_If_criteria["scenario_menu_" + active_object_id] = Setup_What_If_criteria["scenario_layout_" + active_object_id].cells('b').attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : scenario_menu_json
            }); 
            
            Setup_What_If_criteria["scenario_menu_" + active_object_id].attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
                        var new_id = (new Date()).valueOf();
                        var scenario_type = Setup_What_If_criteria["scenario_form_" + active_object_id].getItemValue('scenario_type');
                        if (scenario_type == 'i') {
                            Setup_What_If_criteria["scenario_grid_" + active_object_id].addRow(new_id,['','p','','','','','','','1','','','','','','','','','','']);
                            use_existing_oncheck(new_id, true);
                        } else {
                            Setup_What_If_criteria["scenario_grid_" + active_object_id].addRow(new_id,['','p','','','','','','','0','','','','','','','','','','']);
                            use_existing_oncheck(new_id, false);
                        }
                        Setup_What_If_criteria["scenario_grid_" + active_object_id].forEachRow(function(row){
                            Setup_What_If_criteria["scenario_grid_" + active_object_id].forEachCell(row,function(cellObj,ind){
                                Setup_What_If_criteria["scenario_grid_" + active_object_id].validateCell(row,ind)
                            });
                        });
                        break;
                    case 'delete':
                        var selected_row = Setup_What_If_criteria["scenario_grid_" + active_object_id].getSelectedRowId();
                        var selected_row_arr = selected_row.split(',');
                        for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                            var scenario_id = Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(selected_row_arr[cnt], 0).getValue();
                            Setup_What_If_criteria["scenario_grid_" + active_object_id].deleteRow(selected_row_arr[cnt]);
                            Setup_What_If_criteria["scenario_menu_" + active_object_id].setItemDisabled('delete');
                            if (scenario_id != '') {
                                Setup_What_If_criteria["scenario_grid_" + active_object_id].setUserData("","deleted_xml", "deleted");
                            }
                        }
                        break;
                    case 'pdf':
                        Setup_What_If_criteria["scenario_grid_" + active_object_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case 'excel':
                        Setup_What_If_criteria["scenario_grid_" + active_object_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    
                }
            });
        }
        
        /*
         * load the grid of the scenario tab.
         */
        load_scenario_tab_grid = function(active_object_id) {
            Setup_What_If_criteria["scenario_grid_" + active_object_id] = Setup_What_If_criteria["scenario_layout_" + active_object_id].cells('b').attachGrid();
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setImagePath(js_image_path + "dhxgrid_web/"); 
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setHeader("ID,Risk Factor,Shift,Shift Item,Shift By, Shift Value, Months From, Months To, Use Existing,Shifts - 1,2,3,4,5,6,7,8,9,10");
            Setup_What_If_criteria["scenario_grid_" + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnIds("id,risk_factor,shift,shift_item,shift_by,shift_value,month_from,month_to,use_existing,shift1,shift2,shift3,shift4,shift5,shift6,shift7,shift8,shift9,shift10");
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setColTypes("ro,combo,combo,combo,combo,combo,ed,ed,ch,ed,ed,ed,ed,ed,ed,ed,ed,ed,ed");
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setColSorting("str,str,str,str,str,str,str,str,str,int,int,int,int,int,int,int,int,int,int");
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnsVisibility("true,false,false,false,false,false,true,true,false,false,false,false,false,false,false,false,false,false,false");
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setInitWidths('0,120,120,120,120,120,120,120,120,80,60,60,60,60,60,60,60,60,60');
            Setup_What_If_criteria["scenario_grid_" + active_object_id].enableMultiselect(true);
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setPagingWTMode(true,true,true,[5,10,20,30,40,50,60,70,80,90,100,200]);
            Setup_What_If_criteria["scenario_grid_" + active_object_id].init();
            Setup_What_If_criteria["scenario_grid_" + active_object_id].enableValidation(true);
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setColValidators(",NotEmpty,NotEmpty,NotEmpty,,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric"); 
            
            Setup_What_If_criteria["scenario_grid_" + active_object_id].attachEvent("onValidationError",function(id,ind,value){
                var message = "Invalid Data";
                Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(id,ind).setAttribute("validation", message);
                return true;
            });
            Setup_What_If_criteria["scenario_grid_" + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
                Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(id,ind).setAttribute("validation", "");
                return true;
            });
            
            Setup_What_If_criteria["scenario_grid_" + active_object_id].attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
                shift_onchange(stage,rId,cInd,'');
                return true;
            });
            
            Setup_What_If_criteria["scenario_grid_" + active_object_id].attachEvent("onCheck", function(rId,cInd,state){
                use_existing_oncheck(rId, state)
            });

            Setup_What_If_criteria["scenario_grid_" + active_object_id].attachEvent("onRowSelect", function(id,ind){
                if(has_right_maintain_whatif_criteria_iu)
                    Setup_What_If_criteria["scenario_menu_" + active_object_id].setItemEnabled('delete');
            });
            
            //Loading dropdown for grid
            var combo_obj = Setup_What_If_criteria["scenario_grid_" + active_object_id].getColumnCombo(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('risk_factor'));                
            var cm_param = {"action": "('SELECT ''p'' [id], ''Price Curve'' [value]')", "has_blank_option": false};
            combo_obj.enableFilteringMode(true);
            load_combo(combo_obj, cm_param);
            
            var combo_obj = Setup_What_If_criteria["scenario_grid_" + active_object_id].getColumnCombo(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift'));                
            var cm_param = {"action": "('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 24000')", "has_blank_option": false};
            combo_obj.enableFilteringMode(true);
            load_combo(combo_obj, cm_param);
            
            var combo_obj = Setup_What_If_criteria["scenario_grid_" + active_object_id].getColumnCombo(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_by'));                
            var cm_param = {"action": "('SELECT ''p'' [id], ''Percentage'' [value] UNION ALL SELECT ''c'' [id], ''Percentage Index'' [value] UNION ALL SELECT ''v'' [id], ''Value'' [value] UNION ALL SELECT ''u'' [id], ''Value Index'' [value]')", "has_blank_option": false};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            combo_obj.enableFilteringMode(true);
            combo_obj.load(url, function() {
                switch_scenario_grid();
            });
        }
        
         /*
         * load the grid of the scenario tab.
         */
        load_migration_tab_grid = function(active_object_id) {
            Setup_What_If_criteria["migration_grid_" + active_object_id] = Setup_What_If_criteria["migration_layout_" + active_object_id].cells('a').attachGrid();
            Setup_What_If_criteria["migration_grid_" + active_object_id].setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");    
            Setup_What_If_criteria["migration_grid_" + active_object_id].setHeader("ID,Counterparty,Internal Counterparty,Contract,Risk Rating,Migration");
            Setup_What_If_criteria["migration_grid_" + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
            Setup_What_If_criteria["migration_grid_" + active_object_id].setColumnIds("whatif_criteria_migration_id,counterparty_id,internal_counterparty_id,contract_id,risk_rating,migration");
            Setup_What_If_criteria["migration_grid_" + active_object_id].setColTypes("ro,combo,combo,combo,combo,combo");
            Setup_What_If_criteria["migration_grid_" + active_object_id].setColSorting("str,str,str,str,str,str");
            Setup_What_If_criteria["migration_grid_" + active_object_id].enableMultiselect(true);
            Setup_What_If_criteria["migration_grid_" + active_object_id].init();
            Setup_What_If_criteria["migration_grid_" + active_object_id].setColumnsVisibility('true,false,false,false,false,false'); 
            Setup_What_If_criteria["migration_grid_" + active_object_id].enableHeaderMenu();
            Setup_What_If_criteria["migration_grid_" + active_object_id].enableValidation(true);
            Setup_What_If_criteria["migration_grid_" + active_object_id].setColValidators(",NotEmpty,,,,,");
            Setup_What_If_criteria["migration_grid_" + active_object_id].attachEvent("onValidationError",function(id,ind,value){
                var message = "Invalid Data";
                Setup_What_If_criteria["migration_grid_" + active_object_id].cells(id,ind).setAttribute("validation", message);
                return true;
            });
            Setup_What_If_criteria["migration_grid_" + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
                Setup_What_If_criteria["migration_grid_" + active_object_id].cells(id,ind).setAttribute("validation", "");
                return true;
            });
            Setup_What_If_criteria["migration_grid_" + active_object_id].attachEvent("onRowSelect", function(id,ind){
                Setup_What_If_criteria["migration_menu_" + active_object_id].setItemEnabled('delete');
            });
            
            //Loading dropdown for grid
            var combo_obj = Setup_What_If_criteria["migration_grid_" + active_object_id].getColumnCombo(Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('counterparty_id'));    
            var cm_param = {"action": "[spa_getsourcecounterparty]", "flag": "s", "has_blank_option": false};
            combo_obj.enableFilteringMode(true);
            load_combo(combo_obj, cm_param);
            
            var combo_obj_rating = Setup_What_If_criteria["migration_grid_" + active_object_id].getColumnCombo(Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('risk_rating'));
            var cm_param = {"action": "[spa_get_combo_value]", "flag": "r", "has_blank_option": false};
            combo_obj_rating.enableFilteringMode(true);
            load_combo(combo_obj_rating, cm_param);   

            var combo_obj_internal_cpty = Setup_What_If_criteria["migration_grid_" + active_object_id].getColumnCombo(Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('internal_counterparty_id'));
            var cm_param = {"action": "[spa_source_counterparty_maintain]", "flag": "m", "counterparty_type":"i", "has_blank_option": true};
            combo_obj_internal_cpty.enableFilteringMode(true);
            load_combo(combo_obj_internal_cpty, cm_param);

            var combo_obj_contract = Setup_What_If_criteria["migration_grid_" + active_object_id].getColumnCombo(Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('contract_id'));
            var cm_param = {"action": "spa_source_contract_detail", "flag": "r", "has_blank_option": true};
            combo_obj_contract.enableFilteringMode(true);
            // combo_obj_contract.load(cm_param, function(){
                
            // });
            load_combo(combo_obj_contract, cm_param);

            var combo_obj_migration = Setup_What_If_criteria["migration_grid_" + active_object_id].getColumnCombo(Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('migration'));

            Setup_What_If_criteria["migration_grid_" + active_object_id].attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
                var risk_rating_clm_idx_id =  Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('risk_rating');

                var migration_clm_idx_id =  Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('migration');

                if (cInd == risk_rating_clm_idx_id && stage == 2 && nValue !== oValue) {
                    Setup_What_If_criteria["migration_grid_" + active_object_id].cells(rId, migration_clm_idx_id).setValue('');
                    var cm_param = {"action": "[spa_get_combo_value]", 
                                "flag": "m",
                                "combo_id": nValue
                                }; 

                    var migration_combo = Setup_What_If_criteria["migration_grid_" + active_object_id].cells(rId, migration_clm_idx_id).getCellCombo();
                    migration_combo.setComboValue(null);
                    migration_combo.setComboText(null);    
                    var data = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + data;
                    migration_combo.clearAll();

                    migration_combo.load(url);          
                    //load_combo(combo_obj_migration, cm_param);  
                    return true;
                }
                return true;
            });
            criteria_id = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_id');

            var param = {
                            "action": "spa_maintain_criteria_dhx",
                            "flag": "z",
                            "criteria_id": criteria_id
                        };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            
            Setup_What_If_criteria["migration_grid_" + active_object_id].load(param_url, function() {
                Setup_What_If_criteria["migration_grid_" + active_object_id].forEachRow(function(id){
                    var risk_rating_clm_idx_id =  Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('risk_rating');
                    var migration_clm_idx_id =  Setup_What_If_criteria["migration_grid_" + active_object_id].getColIndexById('migration');
                    
                    var risk_rating_id = Setup_What_If_criteria["migration_grid_" + active_object_id].cells(id, risk_rating_clm_idx_id).getValue();
                    var migration_id = Setup_What_If_criteria["migration_grid_" + active_object_id].cells(id, migration_clm_idx_id).getValue();

                    var cell_combo = Setup_What_If_criteria["migration_grid_" + active_object_id].cells(id, migration_clm_idx_id).getCellCombo();
                    
                    var cm_param = {"action": "[spa_get_combo_value]", 
                                "flag": "m",
                                "combo_id": risk_rating_id
                                };

                    cell_combo.setComboValue('');
                    cell_combo.setComboText('');
                    
                    var data = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + data;
                    cell_combo.clearAll();

                    cell_combo.load(url, function() {
                        Setup_What_If_criteria["migration_grid_" + active_object_id].cells(id, migration_clm_idx_id).setValue(migration_id);
                        //cell_combo.setComboValue(migration_id); 
                    });                
                });
            });
        }
        
        /*
         * Change the columns according to scenario type and load the grid data.
         */
        switch_scenario_grid = function() {
            var criteria_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (criteria_tab_id.indexOf("tab_") != -1) ? criteria_tab_id.replace("tab_", "") : criteria_tab_id;
            criteria_id = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_id');
            
            Setup_What_If_criteria["scenario_menu_" + active_object_id].setItemDisabled('delete');
            var scenario_type = Setup_What_If_criteria["scenario_form_" + active_object_id].getItemValue('scenario_type');
            
            if (scenario_type == 'i') {
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift1'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift2'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift3'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift4'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift5'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift6'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift7'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift8'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift9'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift10'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('use_existing'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_value'),false);
            } else {
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift1'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift2'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift3'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift4'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift5'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift6'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift7'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift8'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift9'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift10'),false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('use_existing'),true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].setColumnHidden(Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_value'),true);
            }
            
            var param = {
                            "action": "spa_maintain_criteria_dhx",
                            "flag": "s",
                            "criteria_id": criteria_id,
                            "scenario_type": scenario_type
                        };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            Setup_What_If_criteria["scenario_grid_" + active_object_id].clearAll();
            Setup_What_If_criteria["scenario_grid_" + active_object_id].loadXML(param_url, function() {
                check_shift_use_existing();
            });
        }
        
        /*
         * function to load combos in update mode
         */
        check_shift_use_existing = function() {
            var scenario_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            var scenario_type = Setup_What_If_criteria["scenario_form_" + active_object_id].getItemValue('scenario_type');
            
            Setup_What_If_criteria["scenario_grid_" + active_object_id].forEachRow(function(id){
                var shift_col_ind = Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift');
                var shift_item_val = Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(id,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_item')).getValue();
                var shift_by_ind = Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_by');
                var shift_value_val = Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(id,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_value')).getValue();
                shift_onchange(2, id, shift_col_ind, shift_item_val);
                shift_onchange(2, id, shift_by_ind, shift_value_val);
                var use_existance_val = Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(id,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('use_existing')).getValue();
                use_existing_oncheck(id, use_existance_val);
            });
        }
        
        /*
         * Function to disble shift by and shift value when use existing is checked.
         */
        use_existing_oncheck = function(rId, state) {
            var scenario_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
            if (state == true) {
                Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(rId,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_by')).setValue('');
                Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(rId,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_value')).setValue('');
                Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(rId,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_by')).setDisabled(true);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(rId,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_value')).setDisabled(true);
            } else {
                Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(rId,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_by')).setDisabled(false);
                Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(rId,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_value')).setDisabled(false);
            }
        }
        
        /*
         * Function to load the shift item according to the selected shift.
         */
        shift_onchange = function(stage,rId,cInd,set_val) {
            var scenario_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            var grid_obj = Setup_What_If_criteria["scenario_grid_" + active_object_id];

            var shift_col_ind = grid_obj.getColIndexById('shift');
            var shift_col_val = grid_obj.cells(rId,shift_col_ind).getValue();
            var shift_by_ind = grid_obj.getColIndexById('shift_by');
            var shift_by_val = grid_obj.cells(rId,shift_by_ind).getValue();
            var use_existing_col_ind = grid_obj.getColIndexById('shift');
            var shift_value_ind = grid_obj.getColIndexById('shift_value');

            if (stage == 2 && shift_col_ind == cInd) {
                var shift_item_row_cmb = grid_obj.cells(rId,grid_obj.getColIndexById('shift_item')).getCellCombo();

                var cm_param = '';
                if (shift_col_val == 24001) {
                    cm_param = {"action": "spa_source_price_curve_def_maintain", "flag":"l", "has_blank_option": false};
                } else if (shift_col_val == 24002) {
                    cm_param = {"action": "('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15100')", "has_blank_option": false};
                } else if (shift_col_val == 24003) {
                    cm_param = {"action": "spa_source_commodity_maintain", "flag":"a", "has_blank_option": false};
                }

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                grid_obj.cells(rId,grid_obj.getColIndexById('shift_item')).setValue('');
                shift_item_row_cmb.enableFilteringMode(true);
                shift_item_row_cmb.load(url, function() {
                    if (set_val != '') {
                         grid_obj.cells(rId,grid_obj.getColIndexById('shift_item')).setValue(set_val);
                    }
                });
            } else if (stage == 2 && shift_by_ind == cInd) {  
                if (shift_by_val == 'p' || shift_by_val == 'v') {
                    grid_obj.editStop();
                    grid_obj.setCellExcellType(rId, shift_value_ind, 'ed_no');
                    
                    if (set_val != '') {
                        grid_obj.cells(rId,grid_obj.getColIndexById('shift_value')).setValue(set_val);
                    } else {
                        grid_obj.cells(rId,grid_obj.getColIndexById('shift_value')).setValue('');
                    }
                } else if (shift_by_val == 'c' || shift_by_val == 'u') {
                    grid_obj.setColumnExcellType(grid_obj.getColIndexById('shift_value'), 'combo');
                    var shift_by_row_cmb = grid_obj.cells(rId,grid_obj.getColIndexById('shift_value')).getCellCombo();
                    shift_by_row_cmb.enableFilteringMode(true) 
                    var cm_param = {"action": "('EXEC spa_source_price_curve_def_maintain @flag = ''l'', @source_curve_type_value_id = 578')", "has_blank_option": false};
                    var data = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + data;
                    grid_obj.cells(rId,grid_obj.getColIndexById('shift_value')).setValue('');
                    shift_by_row_cmb.load(url, function() {
                        if (set_val != '') {
                             grid_obj.cells(rId,grid_obj.getColIndexById('shift_value')).setValue(set_val);
                        }
                    });
                }
            }
        }
        
        function undock_scenario_grid() {
            var scenario_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
            Setup_What_If_criteria["scenario_layout_" + active_object_id].cells('b').undock(300, 300, 900, 700);
            Setup_What_If_criteria["scenario_layout_" + active_object_id].dhxWins.window('b').maximize();
            Setup_What_If_criteria["scenario_layout_" + active_object_id].dhxWins.window("b").button("park").hide();
            $('.undock_a').hide();
        }
        
        /*===================== Scenario Tab Ends ====================*/
        
        /*===================== Measure Tab Starts ====================*/
        
        /*
         * Create the form in the measure tab.
         */
        load_measure_tab = function(tab_obj, active_object_id, form_json) {
            var measure_form_json = [           
                {type:"checkbox", label:"Position", name:"position", value:1, checked:true, offsetLeft: ui_settings['offset_left'] ,position : "label-right"},
                {type: "newcolumn"},
                {type:"checkbox", label:"MTM", name:"mtm", value:2, offsetLeft: ui_settings['offset_left'] ,position : "label-right"},
                {type: "newcolumn"},
                {type:"checkbox", label:"VaR", name:"v_var", value:3, offsetLeft: ui_settings['offset_left'] ,position : "label-right"},
                {type: "newcolumn"},
                {type:"checkbox", label:"CFaR", name:"cfar", value:4, offsetLeft: ui_settings['offset_left'] ,position : "label-right"},
                {type: "newcolumn"},
                {type:"checkbox", label:"Ear", name:"ear", value:5, offsetLeft: ui_settings['offset_left'] ,position : "label-right"},
                {type: "newcolumn"},
                {type:"checkbox", label:"PFE", name:"pfe", value:6, offsetLeft: ui_settings['offset_left'] ,position : "label-right"},
                {type: "newcolumn"},
                {type:"checkbox", label:"GMaR", name:"gmar", value:7, offsetLeft: ui_settings['offset_left'] ,position : "label-right"},
                {type: "newcolumn"},
                {type:"checkbox", label:"Credit", name:"credit", value:7,offsetLeft: ui_settings['offset_left'] ,position : "label-right"},
                {type: "newcolumn"},

                {type:"fieldset", name:"risk_parameters", label:"At Risk Parameters", offsetLeft: ui_settings['offset_left'], width : 800, list:[
                        {type:"combo", label:"Approach", name:"var_approach", position:"label-top", width:ui_settings['field_size'], "userdata":{"validation_message":"Required Field "},"required":"true", offsetLeft: ui_settings['offset_left']},                    
                        {type: "newcolumn"},                        
                        {type:"combo", label:"Confidence Interval", name:"confidence_interval", position:"label-top", width:ui_settings['field_size'], "userdata":{"validation_message":"Required Field "},"required":"true", offsetLeft: ui_settings['offset_left']},                      
                        {type: "newcolumn"},                        
                        {type:"input", label:"Holding Days", name:"holding_days", position:"label-top", width:ui_settings['field_size'], "userdata":{"validation_message":"Invalid Number"},"required":"true",validate: "ValidInteger", offsetLeft: ui_settings['offset_left']},                        
                        {type: "newcolumn"},                        
                        {type:"input", label:"No of Simulations", name:"no_of_simulations", position:"label-top", width:ui_settings['field_size'], "userdata":{"validation_message":"Invalid Number"},"required":"true",validate: "ValidInteger", offsetLeft: ui_settings['offset_left']},                      
                        {type: "newcolumn"},
                        {type:"checkbox", label:"Hold To Maturity", name:"hold_to_maturity", position : "label-right", value:"maturity", offsetLeft: ui_settings['offset_left'], offsetTop : ui_settings['checkbox_offset_top'], labelWidth : ui_settings['field_size']},
                        {type: "newcolumn"},
                        {type:"checkbox", label:"Use Discounted Value", name:"use_discounted_value", position : "label-right", value:"use_discounted_value", offsetLeft: ui_settings['offset_left'], offsetTop : ui_settings['checkbox_offset_top'], labelWidth : ui_settings['field_size']},
						{type: "newcolumn"},
                        {type:"checkbox", label:"Use Market Value", name:"use_market_value", position : "label-right", value:"use_market_value", offsetLeft: ui_settings['offset_left'], offsetTop : ui_settings['checkbox_offset_top'], labelWidth : ui_settings['field_size']} 
                ]}

            ];

            Setup_What_If_criteria["measure_form" + active_object_id] = tab_obj.attachForm();
            Setup_What_If_criteria["measure_form" + active_object_id].loadStruct(measure_form_json);
            Setup_What_If_criteria["measure_form" + active_object_id].hideItem("risk_parameters");
            
            Setup_What_If_criteria["measure_form" + active_object_id].attachEvent("onChange", function (name, value, state){
                 if(name == 'v_var' || name == 'cfar' || name == 'ear' || name == 'pfe' || name == 'hold_to_maturity' ||  name == 'gmar') {
                     show_hide_risk_parameters();
                 } else if (name == 'var_approach') {
                     show_hide_simulations();
                 }
            });
            
            //Filling Measure Combo Option
            var approach_combo = Setup_What_If_criteria["measure_form" + active_object_id].getCombo("var_approach");
            var confidence_interval_combo = Setup_What_If_criteria["measure_form" + active_object_id].getCombo("confidence_interval");
            var approach_combo_sql = {"action":"('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 1520')", "has_blank_option": false};
            var data = $.param(approach_combo_sql);
            var url = js_dropdown_connector_url + '&' + data;
            approach_combo.clearAll();
            approach_combo.enableFilteringMode(true);
            confidence_interval_combo.enableFilteringMode(true);
            approach_combo.load(url, function() {
                var approach_combo1 = Setup_What_If_criteria["measure_form" + active_object_id].getCombo("confidence_interval");
                var approach_combo_sql1 = {"action":"('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 1500, @license_not_to_static_value_id = ''1500,1501''')", "has_blank_option": false};
                var data1 = $.param(approach_combo_sql1);
                var url1 = js_dropdown_connector_url + '&' + data1;
                approach_combo1.clearAll();
                approach_combo1.load(url1, function() {
                    load_measure_tab_data(active_object_id);
                });
                
            });
        }
        
        /*
         * Load the data in meassure tab.
         */
        load_measure_tab_data = function(active_object_id) {
            criteria_id = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_id');

            var data = {"action": "spa_maintain_criteria_dhx", "flag": "m", "criteria_id": criteria_id};
            adiha_post_data('return_json', data, '', '', 'load_measure_tab_data_callback', '');
        }
        
        /*
         * Callback function of loading data in measure tab.
         */
        load_measure_tab_data_callback = function(result) {
            var scenario_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
            var response_data = JSON.parse(result);
            if (response_data == '') {
                show_hide_risk_parameters();
                return;
            }
            var position = (response_data[0].position == 'y') ? true : false;
            var mtm = (response_data[0].mtm == 'y') ? true : false;
            var v_var = (response_data[0].var == 'y') ? true : false;
            var cfar = (response_data[0].cfar == 'y') ? true : false;
            var ear = (response_data[0].ear == 'y') ? true : false;
            var pfe = (response_data[0].pfe == 'y') ? true : false;
            var gmar = (response_data[0].gmar == 'y') ? true : false;
            var credit = (response_data[0].credit == 'y') ? true : false;
            var var_approach = response_data[0].var_approach;
            var confidence_interval = response_data[0].confidence_interval;
            var holding_days = response_data[0].holding_days;
            var no_of_simulations = response_data[0].no_of_simulations;

            if (holding_days == 0) {
                holding_days = '';
            }
            if (no_of_simulations == 0) {
                no_of_simulations = '';
            }
            var hold_to_maturity = (response_data[0].hold_to_maturity == 'y') ? true : false;
            var use_market_value = (response_data[0].use_market_value == 'y') ? true : false;
            var use_discounted_value = (response_data[0].use_discounted_value == 'y') ? true : false;
            
            Setup_What_If_criteria["measure_form" + active_object_id].setFormData({                      
                position: position,
                mtm: mtm,
                v_var: v_var,
                cfar: cfar,
                ear: ear,
                pfe: pfe,
                gmar: gmar,
                credit: credit,
                var_approach: var_approach,
                confidence_interval: confidence_interval,
                holding_days: holding_days,
                no_of_simulations: no_of_simulations,
                hold_to_maturity: hold_to_maturity,
                use_market_value: use_market_value,
                use_discounted_value: use_discounted_value
            });
            show_hide_risk_parameters();
            if (var_approach == 1520) {
                Setup_What_If_criteria["measure_form" + active_object_id].disableItem('no_of_simulations');
            }
        }
        
        /*
         * Function to show and hide the Risk Parameters fieldset in Measure tab.
         */
        show_hide_risk_parameters = function() {
            var scenario_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
            var v_var = Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('v_var');
            var cfar = Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('cfar');
            var ear = Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('ear');
            var pfe = Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('pfe');
            var gmar = Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('gmar');
            if (v_var == true || cfar == true || ear == true || pfe == true || gmar == true) {
                Setup_What_If_criteria["measure_form" + active_object_id].showItem("risk_parameters");
                
                var hold_to_maturity = Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('hold_to_maturity');
                if (hold_to_maturity == true) {
                    Setup_What_If_criteria["measure_form" + active_object_id].disableItem('holding_days');
                } else {
                    Setup_What_If_criteria["measure_form" + active_object_id].enableItem('holding_days');
                }
                
                var approach_combo = Setup_What_If_criteria["measure_form" + active_object_id].getCombo("var_approach");
                var approach_combo_sql;

                if (v_var == true) {
                    approach_combo_sql = {"action":"('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 1520')", "has_blank_option": false};
                } else if (cfar == true || ear == true || pfe == true || gmar == true) {
                    approach_combo_sql = {"action":"('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 1520, @license_not_to_static_value_id = ''1520''')", "has_blank_option": false};
                } else if (v_var == true || cfar == true || ear == true || pfe == true || gmar == true){
                    approach_combo_sql = {"action":"('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 1520')", "has_blank_option": false};
                } else {
                    approach_combo_sql = {"action":"('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 1520, @license_not_to_static_value_id = ''1520''')", "has_blank_option": false};
                }

                var appr = Setup_What_If_criteria["measure_form" + active_object_id].getItemValue('var_approach');
                var data = $.param(approach_combo_sql);
                var url = js_dropdown_connector_url + '&' + data;
                approach_combo.clearAll();
                approach_combo.load(url, function() {
                    if (cfar == true || ear == true || pfe == true) {
                        if (appr != 1521) {
                            appr = 1522;
                            Setup_What_If_criteria["measure_form" + active_object_id].enableItem('no_of_simulations');
                        }
                    }
                    Setup_What_If_criteria["measure_form" + active_object_id].setItemValue("var_approach", appr);                   
                });
            } else {
                Setup_What_If_criteria["measure_form" + active_object_id].hideItem("risk_parameters");
            }
        }
        
        show_hide_simulations = function() {
            var scenario_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
            var var_approach = Setup_What_If_criteria["measure_form" + active_object_id].getItemValue('var_approach');
            if (var_approach == 1520) {
                Setup_What_If_criteria["measure_form" + active_object_id].disableItem('no_of_simulations');
            } else {
                Setup_What_If_criteria["measure_form" + active_object_id].enableItem('no_of_simulations');
            }
        }
        
        /*===================== Measure Tab Ends ====================*/
        
        Setup_What_If_criteria.pre_save_criteria = function(tab_id) {
            var active_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            
            var del_flag = Setup_What_If_criteria["scenario_grid_" + active_tab_id].getUserData("", "deleted_xml");
            var migration_del_flag = Setup_What_If_criteria["migration_grid_" + active_tab_id].getUserData("", "deleted_xml");
            
            if (del_flag == 'deleted') {
                del_msg =  "Some data has been deleted from <strong>Scenario</strong> grid. Are you sure you want to save?";
                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    text: del_msg,
                    callback: function(result) {
                        if (result)
                            Setup_What_If_criteria.save_criteria(active_tab_id);                
                    }
                });
            }  else if (migration_del_flag == 'deleted') {
                del_msg =  "Some data has been deleted from <strong>Migration</strong> grid. Are you sure you want to save?";
                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    text: del_msg,
                    callback: function(result) {
                        if (result)
                            Setup_What_If_criteria.save_criteria(active_tab_id);                
                    }
                });
            } else {
                Setup_What_If_criteria.save_criteria(active_tab_id);                     
            }
        }
        
        /*
         * Save function
         */
        Setup_What_If_criteria.save_criteria = function(tab_id) {
            var criteria_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var final_status = true;
            var first_err_tab;
            var active_object_id = (criteria_tab_id.indexOf("tab_") != -1) ? criteria_tab_id.replace("tab_", "") : criteria_tab_id;
            var tab_ids = Setup_What_If_criteria["criteria_tab_" + active_object_id].getAllTabs();
            var tabsCount = Setup_What_If_criteria["criteria_tab_" + active_object_id].getNumberOfTabs();
            Setup_What_If_criteria["scenario_grid_" + active_object_id].clearSelection();
            var status = validate_form(Setup_What_If_criteria["general_form" + active_object_id]);
            if (status == false) {

                if (tabsCount == 1) {
                     first_err_tab = "";
                } else if ((!first_err_tab)) {
                    first_err_tab = Setup_What_If_criteria["criteria_tab_" + active_object_id].tabs(tab_ids[0]);
                }
                // Setup_What_If_criteria["criteria_tab_" + active_object_id].forEachTab(function(tab){
                //     var tab_name = tab.getText();
                //     if (tab_name == "General") {
                //         tab.setActive();
                //     };
                // });
            final_status = false;
            }
            
            var status1 = validate_form(Setup_What_If_criteria["scenario_form_" + active_object_id]);
            if (status1 == false) {        
                    // Setup_What_If_criteria["criteria_tab_" + active_object_id].forEachTab(function(tab){
                    // var tab_name = tab.getText();
                    //     if (tab_name == "Scenario") {
                    //         tab.setActive();
                    //     };
                    // });
                    if (tabsCount == 1) {
                     first_err_tab = "";
                    } else if ((!first_err_tab)) {
                        first_err_tab = Setup_What_If_criteria["criteria_tab_" + active_object_id].tabs(tab_ids[2]);
                    }
                    final_status = false;
            }
            
            var grid_status = Setup_What_If_criteria.validate_form_grid(Setup_What_If_criteria["scenario_grid_" + active_object_id], 'Scenario');
            if (grid_status == false) {
                // Setup_What_If_criteria["criteria_tab_" + active_object_id].forEachTab(function(tab){
                //     var tab_name = tab.getText();
                //     if (tab_name == "Scenario") {
                //         tab.setActive();
                //     };
                // });
                Setup_What_If_criteria["criteria_tab_" + active_object_id].tabs(tab_ids[2]).setActive();
                return;
            }
            
            var grid_status = Setup_What_If_criteria.validate_form_grid(Setup_What_If_criteria["migration_grid_" + active_object_id], 'Migration');
            
            if (grid_status == false) {
                
                Setup_What_If_criteria["migration_grid_" + active_object_id].tabs(tab_ids[3]).setActive();
                return;
            }

            if(!final_status) {
                generate_error_message(first_err_tab);
                return;
            }
            //Portfolio value to be saved.
            var portfolio_ifrm = Setup_What_If_criteria["portfolio_tab_" + active_object_id].tabs('portfolio_deals_' + active_object_id).getFrame();
            var portfolio_xml = portfolio_ifrm.contentWindow.generic_portfolio.get_portfolio_form_data();
            
            //Values to be saved in maintain_whatif_criteria
            criteria_id = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_id');
            criteria_name = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_name');
            var criteria_description = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('criteria_description');
            var role = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('role');
            var user = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('user');
            var active = (Setup_What_If_criteria["general_form" + active_object_id].isItemChecked('active') == 1) ? 'y' : 'n';
            var public = (Setup_What_If_criteria["general_form" + active_object_id].isItemChecked('public') == 1) ? 'y' : 'n';
            var revaluation = (Setup_What_If_criteria["scenario_form_" + active_object_id].isItemChecked('revaluation') == 1) ? 'y' : 'n';
            var source = Setup_What_If_criteria["scenario_form_" + active_object_id].getItemValue('source');
            var Volatility_source = Setup_What_If_criteria["scenario_form_" + active_object_id].getItemValue('Volatility_source');
            var scenario_type = Setup_What_If_criteria["scenario_form_" + active_object_id].getItemValue('scenario_type');
            var scenario_group_id = Setup_What_If_criteria["scenario_form_" + active_object_id].getItemValue('scenario_group_id');
            var hold_to_maturity = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('hold_to_maturity') == 1) ? 'y' : 'n';
            var use_market_value = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('use_market_value') == 1) ? 'y' : 'n';
            var use_discounted_value = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('use_discounted_value') == 1) ? 'y' : 'n';
            var scenario_criteria_group = Setup_What_If_criteria["general_form" + active_object_id].getItemValue('scenario_criteria_group');
            
            var definition_xml = '<CriteriaDefinition ';
            definition_xml += ' criteria_id="' + criteria_id + '"';
            definition_xml += ' criteria_name="' + criteria_name + '"';
            definition_xml += ' criteria_description="' + criteria_description + '"';
            definition_xml += ' role="' + role + '"';
            definition_xml += ' user="' + user + '"';
            definition_xml += ' active="' + active + '"';
            definition_xml += ' public="' + public + '"';
            definition_xml += ' scenario_type="' + scenario_type + '"';
            definition_xml += ' source="' + source + '"';
            definition_xml += ' revaluation="' + revaluation + '"';
            definition_xml += ' Volatility_source="' + Volatility_source + '"';
            definition_xml += ' scenario_group_id="' + scenario_group_id + '"';
            definition_xml += ' hold_to_maturity="' + hold_to_maturity + '"';
            definition_xml += ' use_market_value="' + use_market_value + '"';
            definition_xml += ' use_discounted_value="' + use_discounted_value + '"';
            definition_xml += ' scenario_criteria_group="' + scenario_criteria_group + '"/>';
            
            //Values to be saved on whatif_criteria_measure
            var position = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('position') == 1) ? 'y' : 'n';
            var mtm = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('mtm') == 1) ? 'y' : 'n';
            var v_var = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('v_var') == 1) ? 'y' : 'n';
            var cfar = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('cfar') == 1) ? 'y' : 'n';
            var ear = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('ear') == 1) ? 'y' : 'n';
            var pfe = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('pfe') == 1) ? 'y' : 'n';
            var gmar = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('gmar') == 1) ? 'y' : 'n';
            var credit = (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('credit') == 1) ? 'y' : 'n';
            var var_approach = Setup_What_If_criteria["measure_form" + active_object_id].getItemValue('var_approach');
            var confidence_interval = Setup_What_If_criteria["measure_form" + active_object_id].getItemValue('confidence_interval');
            var holding_days = Setup_What_If_criteria["measure_form" + active_object_id].getItemValue('holding_days');
            var no_of_simulations = Setup_What_If_criteria["measure_form" + active_object_id].getItemValue('no_of_simulations');
            
            var holding_days;
            if (Setup_What_If_criteria["measure_form" + active_object_id].isItemChecked('hold_to_maturity') != 1) {
                holding_days = Setup_What_If_criteria["measure_form" + active_object_id].getItemValue('holding_days');
            } else {
                holding_days = 'NULL';
            }

            var measure_val_status;
            if(v_var == 'y' || cfar == 'y' || ear == 'y' || pfe == 'y' || gmar == 'y') {
                measure_val_status = validate_form(Setup_What_If_criteria["measure_form" + active_object_id], Setup_What_If_criteria["criteria_tab_" + active_object_id].tabs(tab_ids[3]));
            } else {
                measure_val_status= true;
                var_approach = '';
                confidence_interval = '';
                holding_days = '';
                no_of_simulations = '';
            }
            
            if (measure_val_status == false) {
               /* Setup_What_If_criteria["criteria_tab_" + active_object_id].forEachTab(function(tab){
                    var tab_name = tab.getText();
                    if (tab_name == "Measure") {
                        tab.setActive();
                    };
                });*/
                return;
            }
            
            if (position == 'n' && mtm == 'n' && v_var == 'n' && cfar == 'n' && ear == 'n' && pfe == 'n' && gmar == 'n') {
                show_messagebox('Please check atleast one measure.');
                return;
            }
            
            var measure_xml = '<CriteriaMeasure ';
            measure_xml += ' position="' + position + '"';
            measure_xml += ' mtm="' + mtm + '"';
            measure_xml += ' var="' + v_var + '"';
            measure_xml += ' cfar="' + cfar + '"';
            measure_xml += ' ear="' + ear + '"';
            measure_xml += ' pfe="' + pfe + '"';
            measure_xml += ' gmar="' + gmar + '"';
            measure_xml += ' credit="' + credit + '"';
            measure_xml += ' var_approach="' + var_approach + '"';
            measure_xml += ' confidence_interval="' + confidence_interval + '"';
            measure_xml += ' holding_days="' + holding_days + '"';
            measure_xml += ' no_of_simulations="' + no_of_simulations + '"/>';
            
            //Values to be saved in whatif_criteria_scenario
            var detail_xml = '';
            Setup_What_If_criteria["scenario_grid_" + active_object_id].forEachRow(function(id){
                detail_xml += '<CriteriaDetail ';
                Setup_What_If_criteria["scenario_grid_" + active_object_id].forEachCell(id,function(cellObj,ind){
                    detail_xml += ' ' + Setup_What_If_criteria["scenario_grid_" + active_object_id].getColumnId(ind) + '="' + Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(id,ind).getValue() + '"';
                });
                detail_xml += ' scenario_type="' + scenario_type + '"'; 
                detail_xml += '/>';
            });
            
             //Values to be saved in whatif_criteria_migration
            var migration_xml = '';
            Setup_What_If_criteria["migration_grid_" + active_object_id].forEachRow(function(id){
                migration_xml += '<CriteriaMigration ';
                Setup_What_If_criteria["migration_grid_" + active_object_id].forEachCell(id,function(cellObj,ind){
                    migration_xml += ' ' + Setup_What_If_criteria["migration_grid_" + active_object_id].getColumnId(ind) + '="' + Setup_What_If_criteria["migration_grid_" + active_object_id].cells(id,ind).getValue() + '"';
                });
                migration_xml += '/>';
            });
            
            flag = 'u';
            if (criteria_id == '') {
                flag = 'i'; 
            }
            var final_xml = '<Root>' + definition_xml + detail_xml + measure_xml + migration_xml + '</Root>';
            
            // Setup_What_If_criteria.tabbar.cells(Setup_What_If_criteria.tabbar.getActiveTab()).getAttachedToolbar().disableItem('save');
            
            if (portfolio_xml) {
                var data = {
                                "action": "spa_maintain_criteria_dhx",
                                "flag": flag,
                                "criteria_id": criteria_id, 
                                "xml": final_xml,
                                "scenario_type": scenario_type,
                                "portfolio_xml": portfolio_xml
                            };
            }

            adiha_post_data('alert', data, '', '', 'save_criteria_callback', '');
        }
        /*
         * Call back function of save_criteria. Changes the tab id and tab name and reload the grids.
         */
        save_criteria_callback = function(result) {
            var criteria_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var active_object_id = (criteria_tab_id.indexOf("tab_") != -1) ? criteria_tab_id.replace("tab_", "") : criteria_tab_id;
            if (has_right_maintain_whatif_criteria_iu) {
               Setup_What_If_criteria.tabbar.cells(criteria_tab_id).getAttachedToolbar().enableItem('save'); 
            };
            
            Setup_What_If_criteria["scenario_grid_" + active_object_id].setUserData("","deleted_xml", "");
            Setup_What_If_criteria["migration_grid_" + active_object_id].setUserData("","deleted_xml", "");
            Setup_What_If_criteria["scenario_menu_" + active_object_id].setItemDisabled('delete');
            Setup_What_If_criteria["migration_menu_" + active_object_id].setItemDisabled('delete');
            
            var return_data = result;
            
            if (flag == 'i') {
                var new_id = return_data[0].recommendation;
                Setup_What_If_criteria["general_form" + active_object_id].setItemValue('criteria_id', new_id);
                Setup_What_If_criteria.tabbar.tabs(active_object_id).setText(criteria_name);
                if (has_rights_maintain_whatif_criteria_hypothetical){
                Setup_What_If_criteria["hypothetical_menu_" + active_object_id].setItemEnabled('add');
                }
            } else if (flag == 'u') {
                Setup_What_If_criteria.tabbar.tabs(criteria_tab_id).setText(criteria_name);
            }

            
            if (result[0].errorcode == 'Success') {
                Setup_What_If_criteria.refresh_grid("", refresh_grid_callback);
                Setup_What_If_criteria.menu.setItemDisabled("delete");
            }
            switch_scenario_grid();
            
        }
        
        /*
         * Delete the criteria
         */
        Setup_What_If_criteria.delete_criteria = function() {
            var selected_id = Setup_What_If_criteria.grid.getSelectedId();
            var selected_row_arr = selected_id.split(',');

            if(selected_id == null) {
                show_messagebox('Please select the data you want to delete.');
                return;
            }
            
            criteria_id_arr = new Array();
            criteria_name_arr = new Array();
            for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                var id = Setup_What_If_criteria.grid.cells(selected_row_arr[cnt], Setup_What_If_criteria.grid.getColIndexById('Id')).getValue();
                criteria_id_arr.push(id);
                var name = Setup_What_If_criteria.grid.cells(selected_row_arr[cnt], Setup_What_If_criteria.grid.getColIndexById('criteria_name')).getValue();
                criteria_name_arr.push(name);
            }
            criteria_id = criteria_id_arr.toString();
            var criteria_name = criteria_name_arr.toString();
            
            var data = {
                        "action": "spa_maintain_criteria_dhx",
                        "flag": "d",
                        "criteria_id": criteria_id
                    };

            adiha_post_data('confirm', data, '', '', 'delete_criteria_callback', '');
        }
        
        /*
         * Delete callback function. Close the delete tab if it is in open state.
         */
        delete_criteria_callback = function(result) {
            if (result[0].errorcode == 'Success') {
                Setup_What_If_criteria.tabbar.forEachTab(function(tab){
                    for(cnt = 0; cnt < criteria_id_arr.length; cnt++) {
                        if (tab.getId() == criteria_id_arr[cnt] || tab.getText() == criteria_name_arr[cnt]) {
                            tab.close();
                        }
                    }
                });
                Setup_What_If_criteria.refresh_grid();
                Setup_What_If_criteria.menu.setItemDisabled("delete");
                Setup_What_If_criteria.menu.setItemDisabled("run");
            }
        }
        
        /**
         *
         */
         function refresh_grid_callback() {
            var col_type = Setup_What_If_criteria.grid.getColType(0);
            var prev_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;
            var primary_value = Setup_What_If_criteria.grid.findCell(system_id, 0, true, true);
            Setup_What_If_criteria.grid.filterByAll(); 
            if (primary_value != "") {
                var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                var tab_text = Setup_What_If_criteria.get_text(Setup_What_If_criteria.grid, r_id);
                Setup_What_If_criteria.tabbar.tabs(prev_id).setText(tab_text);
                Setup_What_If_criteria.grid.selectRowById(r_id,false,true,true);
            }
        }
        /*
         * Run the criteria
         */
        Setup_What_If_criteria.run_criteria = function() {
            var selected_row = Setup_What_If_criteria.grid.getSelectedRowId();
            var selected_row_arr = selected_row.split(',');
            
            var criteria_id_arr = new Array();
            for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                var id = Setup_What_If_criteria.grid.cells(selected_row_arr[cnt], Setup_What_If_criteria.grid.getColIndexById('Id')).getValue();
                criteria_id_arr.push(id);
            }
            criteria_id = criteria_id_arr.toString();
            var client_date_format = '<?php echo $date_format; ?>';
            
            criteria_popup = new dhtmlXPopup();
            criteria_popup_form = criteria_popup.attachForm(
                [
                    {type: "calendar", label: "As of Date", name: "as_of_date", "dateFormat": client_date_format, "serverDateFormat":"%Y-%m-%d", position: "label-top", required: true, userdata:{'validation_message':'Required Field'}},
                    {type: "button", value: "Ok"}
                ]);
            criteria_popup.show(150,20,50,50);
            if(current_date != 0) {
                criteria_popup_form.setItemValue('as_of_date', current_date);
            } else {
                criteria_popup_form.setItemValue('as_of_date', new Date());
            }
                        
            criteria_popup_form.attachEvent('onChange', function(name, value) {
                current_date = value;
            });
            
            criteria_popup_form.attachEvent("onButtonClick", function(name){
                if (!validate_form(criteria_popup_form)) {
                    return;
                }
                var as_of_date = criteria_popup_form.getItemValue('as_of_date', true);
                var exec_call = "EXEC spa_calc_mtm_whatif @flag = 'c', @whatif_criteria_id = '" + criteria_id + "', @as_of_date = '" + as_of_date + "'";
                var param = 'call_from=Run_Settlement_Process_Job&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date; 
                adiha_run_batch_process(exec_call, param, 'Run What if Analysis');
                criteria_popup.hide();  
            });
        }
        
        Setup_What_If_criteria.validate_form_grid = function(attached_obj,grid_label) {;
            var status = true;
            
            for (var i = 0;i < attached_obj.getRowsNum();i++){
                var row_id = attached_obj.getRowId(i);
                for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
                    var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                    
                    if(validation_message != "" && validation_message != undefined){
                        var column_text = attached_obj.getColLabel(j);
                        error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and save.";
                        dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                        status = false; break;
                    }
                }
                if(validation_message != "" && validation_message != undefined){ break;};
             }
            return status;
        }
        
        function load_combo(combo_obj, combo_sql, selected_id) {
            var data = $.param(combo_sql);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.setComboValue(null);
            combo_obj.setComboText(null);
            combo_obj.clearAll();
            combo_obj.load(url, function() {
                if(selected_id != undefined && selected_id != null) {                
                    combo_obj.setComboValue(selected_id); 
                }
            });
                  
        }
        
        dhtmlxValidation.isEmptyOrNumeric=function(data){
            if (data=="") {
                return true;
            } else if (isNaN(data) == false) {
                return true;
            } else {
                return false;
            }
        }


            function get_tab_id(j) {
            var tab_id = [];
            var i = 0;
            var inner_tab_obj = get_inner_tab_obj();   
            console.log(inner_tab_obj);         
            inner_tab_obj.forEachTab(function(tab) {
                tab_id[i] = tab.getId();
                i++;
            }); 
            return tab_id[j];
        }
            
        function get_inner_tab_obj() {
            var active_tab_id = Setup_What_If_criteria.tabbar.getActiveTab();
            var detail_tabs, att_tabbar_obj;            
            Setup_What_If_criteria.tabbar.forEachTab(function(tab) {                
                if(tab.getId() == active_tab_id) {
                    att_lay_obj = tab.getAttachedObject();
                    //var att_lay_obj = tab.getAttachedObject();
                    //att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                }
            });            
            //return att_tabbar_obj;
            return att_lay_obj;
        }
    </script>
</body>
</html>