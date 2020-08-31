<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
    $form_namespace = 'ns_portfolio_group';
    $application_function_id = 10183200;
    $rights_setup_portfolio_iu = 10183210;
    $rights_setup_portfolio_del = 10183211;
    
    list(
        $has_right_setup_portfolio_iu,
        $has_right_setup_portfolio_del
    ) = build_security_rights(
        $rights_setup_portfolio_iu,
        $rights_setup_portfolio_del
    );
    
    $sp_url_trader = "EXEC spa_source_traders_maintain @flag='s', @source_system_id=2";
    $sp_url_counterparty = "EXEC spa_source_counterparty_maintain @flag='s'";
    $sp_url_deal_type = "EXEC spa_source_deal_type_maintain @flag='s'";
    $sp_url_commodity = "EXEC spa_source_commodity_maintain @flag='s'";
    
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("grid_portfolio_group", "EXEC spa_maintain_portfolio_group 'a', NULL, NULL, NULL, NULL, NULL", 'g');
    $form_obj->define_custom_functions('data_save', 'load_form', 'data_delete');
    echo $form_obj->init_form('Portfolio Groups', 'Portfolio Group Details');
    $form_obj_combo = new AdihaForm();
    echo $form_obj->close_form();
    ?>
</html>
<script type="text/javascript">
    var function_id = <?php echo $application_function_id;?>;
    var has_right_setup_portfolio_iu = Boolean('<?php echo $has_right_setup_portfolio_iu; ?>');
    var has_right_setup_portfolio_del = Boolean('<?php echo $has_right_setup_portfolio_del; ?>');
	var theme_selected = 'dhtmlx_' + default_theme;
    
    function fx_set_combo_text(cmb_obj) {
        var checked_loc_arr = cmb_obj.getChecked();
        var final_combo_text = new Array();        
        
        $.each(checked_loc_arr, function(i) {
            var opt_obj = cmb_obj.getOption(checked_loc_arr[i]);
            
            if (opt_obj.text != '')
                final_combo_text.push(opt_obj.text);            
        });
        
        cmb_obj.setComboText(final_combo_text.join(','));
        console.log(JSON.stringify(cmb_obj));            
    }
    
    ns_portfolio_group.load_form = function(win, tab_id) {
        var is_new = win.getText();
        var tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        ns_portfolio_group["inner_tab_layout_" + tab_id] = win.attachLayout("1C");
        
        win.progressOff();
        
        var portfolio_group_id;
        if (is_new == 'New') {
            portfolio_group_id = '';
        } else {
            portfolio_group_id = tab_id;
        }
        
        var template_name = 'MaintainPortfolioGroup';
        var xml_value =  '<Root><PSRecordset portfolio_group_id ="' + portfolio_group_id + '"></PSRecordset></Root>';
        
        data = {"action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": function_id,
                "template_name": template_name,
                "parse_xml": xml_value
             };
             
        result = adiha_post_data('return_array', data, '', '', 'load_form_data', '');
    }
    
    function load_form_data(result) {        
        var active_tab_id = ns_portfolio_group.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var result_length = result.length;
        var tab_json = '';
        var flag = (active_tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
        
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
                           
            tab_json = tab_json + (result[i][1]);       
        }
        
        tab_json = '{tabs: [' + tab_json + ']}';
        
        ns_portfolio_group["ns_portfolio_group_tabs" + active_object_id] = ns_portfolio_group["inner_tab_layout_" + active_object_id].cells("a").attachTabbar();
        ns_portfolio_group["ns_portfolio_group_tabs" + active_object_id].loadStruct(tab_json);
        ns_portfolio_group["ns_portfolio_group_tabs" + active_object_id].setTabsMode("bottom");
          
        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            ns_portfolio_group["form" + j] = ns_portfolio_group["ns_portfolio_group_tabs" + active_object_id].cells(tab_id).attachForm();
            ns_portfolio_group["form" + j].loadStruct(result[0][2]);
            if (j == 1) {
                var portfolio_group_id = (flag == 'u') ? active_object_id : null;            
                var sub_book_query = "EXEC spa_portfolio_group_book @flag = 'f', @mapping_source_usage_id = " + portfolio_group_id + "," + "@mapping_source_value_id = 23202"; // sdv for limit
                var deal_query = "EXEC spa_portfolio_mapping_deal @flag='x', @mapping_source_usage_id=" + portfolio_group_id + "," + "@mapping_source_value_id = 23202"; ;
                var filter_query =  "EXEC spa_portfolio_group_book @flag = 's', @mapping_source_usage_id = " + portfolio_group_id + "," + "@mapping_source_value_id = 23202";

                ns_portfolio_group["ns_portfolio_group_tabs" + active_object_id].tabs(tab_id).attachURL("../run_at_risk/generic.portfolio.mapping.template.php", null, {sub_book: sub_book_query, deals: deal_query, book_filter: filter_query, func_id: function_id, is_tenor_enable: true});
            }
        }
    }
    
    ns_portfolio_group.data_delete = function(tab_id) {
        var portfolio_group_id_row = ns_portfolio_group.grid.getSelectedRowId();
        var count = portfolio_group_id_row.indexOf(",") > -1 ? portfolio_group_id_row.split(",").length : 1;
        portfolio_group_id_row = portfolio_group_id_row.indexOf(",") > -1 ? portfolio_group_id_row.split(",") : [portfolio_group_id_row];

        var portfolio_group_id = '';
        for (var i = 0; i < count; i++) {
            portfolio_group_id += ns_portfolio_group.grid.cells(portfolio_group_id_row[i], 0).getValue() + ',';
        }
        portfolio_group_id = portfolio_group_id.slice(0, -1);       
        
        data = {"action": "spa_maintain_portfolio_group", "flag": 'd', "del_portfolio_group_id": portfolio_group_id};
        result = adiha_post_data("confirm", data, "", "", "ns_portfolio_group.post_callback_delete");
    }
    
    ns_portfolio_group.data_save = function(tab_id) {
        var portfolio_xml = '';
        var active_tab_id = ns_portfolio_group.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var flag = (active_tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
        
        var tab_obj = ns_portfolio_group["inner_tab_layout_" + tab_id].cells('a').getAttachedObject();
        var inner_tab_obj = tab_obj;
        var detail_tabs = inner_tab_obj.getAllTabs();
        var tabsCount = inner_tab_obj.getNumberOfTabs();
        var form_status = true;
        var first_err_tab;

        var form_xml = '<Root function_id="<?php echo $application_function_id;?>"><FormXML ';
        var validation_status = 1;
        $.each(detail_tabs, function(index, value) {
            var tab_text = inner_tab_obj.tabs(value).getText();
            if (tab_text != 'Portfolio') {
                layout_obj = tab_obj.cells(value).getAttachedObject();

                if (layout_obj instanceof dhtmlXForm) {
                    attached_obj=layout_obj;
                    var status = validate_form(attached_obj);
                    form_status = form_status && status; 
                    if (tabsCount == 1 && !status) {
                        first_err_tab = "";
                    } else if ((!first_err_tab) && !status) {
                        first_err_tab = tab_obj.cells(value);
                    }
                    if (status == false) {
                        validation_status = 0;
                    }
                    data = layout_obj.getFormData();
                    for (var a in data) {
                        field_label = a;
                        field_value = data[a];
                        
                        if (a == 'portfolio_group_name') {
                            ns_portfolio_group["form" + 0].setUserData("", "portfolio_group_name", field_value);
                        }
                        
                        form_xml += " " + field_label + "=\"" + field_value + "\"";
                    }
                }
            } else {
                var ifr = tab_obj.cells(value).getFrame();
                portfolio_xml = ifr.contentWindow.generic_portfolio.get_portfolio_form_data();
                if (!portfolio_xml) {
                    validation_status = 0;
                }    
            }
        });
        
        form_xml += "></FormXML></Root>";
        
        //alert(portfolio_xml)
        
        if(validation_status) {
           //  console.log(toolbar);
           // attached_obj.disableItem("save");
           ns_portfolio_group.tabbar.tabs(active_tab_id).getAttachedToolbar().disableItem('save');
            data = {"action": "spa_maintain_portfolio_group", 
                    "flag": flag, 
                    "form_xml": form_xml, 
                    "portfolio_xml" : portfolio_xml
                };
            result = adiha_post_data("alert", data, "", "", "ns_portfolio_group.post_callback");
        }

        if (!form_status) {
                generate_error_message(first_err_tab);
            }
    }
    
    ns_portfolio_group.post_callback_delete = function(result) {
        if (result[0].recommendation.indexOf(",") > -1) {
            var ids = result[0].recommendation.split(",");
            var count_ids = ids.length;
            for (var i = 0; i < count_ids; i++ ) {
                full_id = 'tab_' + ids[i];
                if (ns_portfolio_group.pages[full_id]) {
                    ns_portfolio_group.tabbar.cells(full_id).close();
                }
            }
        } else {
            full_id = 'tab_' + result[0].recommendation;
            if (ns_portfolio_group.pages[full_id]) {
                ns_portfolio_group.tabbar.cells(full_id).close();
            }
        }        
        ns_portfolio_group.refresh_grid();
        
        if (has_right_setup_portfolio_del)  
            ns_portfolio_group.menu.setItemDisabled("delete");                 
    }
    
    ns_portfolio_group.post_callback = function(result) {
        var active_tab_id = ns_portfolio_group.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var ns_portfolio_group_name = ns_portfolio_group["form" + 0].getUserData("", "portfolio_group_name");
        if (has_right_setup_portfolio_iu) {
            ns_portfolio_group.tabbar.tabs(active_tab_id).getAttachedToolbar().enableItem('save');
        };

        if (result[0].errorcode == 'Success') {     
           if (result[0].recommendation == ''){
                ns_portfolio_group.tabbar.tabs(active_tab_id).setText(ns_portfolio_group_name);
            } else { 
                tab_id = 'tab_' + result[0].recommendation;
                ns_portfolio_group.create_tab_custom(tab_id, ns_portfolio_group_name);
                ns_portfolio_group.tabbar.tabs(active_tab_id).close(true);                
            }            
        }
        
        ns_portfolio_group.refresh_grid();
        ns_portfolio_group.menu.setItemDisabled("delete"); 
    }
    
    ns_portfolio_group.create_tab_custom = function(full_id,text) {
        ns_portfolio_group.refresh_grid();
        
        if (!ns_portfolio_group.pages[full_id]) {
            ns_portfolio_group.tabbar.addTab(full_id, text, null, null, true, true);
            var win = ns_portfolio_group.tabbar.cells(full_id);
            win.progressOn();
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath("<?php echo $app_php_script_loc;?>components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxtoolbar_web/");
            toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
            
            toolbar.attachEvent("onClick", function(){
                ns_portfolio_group.data_save();
            });
            
            ns_portfolio_group.tabbar.cells(full_id).setActive();
            ns_portfolio_group.tabbar.cells(full_id).setText(text);
            ns_portfolio_group.load_form(win, full_id);
            ns_portfolio_group.pages[full_id] = win;
        }
        else {
            ns_portfolio_group.tabbar.cells("'" + full_id + "'").setActive();
        }
    };
        
    function collapse_on() {
        global_layout_object.cells('a').collapse();
        portfolio_layout.cells('a').collapse();
        tab2_layout_obj.cells('b').collapse();       
    }
    
    function collapse_off() {
        global_layout_object.cells('a').expand();
        portfolio_layout.cells('a').expand();
        tab2_layout_obj.cells('b').expand(); 
    }
</script>