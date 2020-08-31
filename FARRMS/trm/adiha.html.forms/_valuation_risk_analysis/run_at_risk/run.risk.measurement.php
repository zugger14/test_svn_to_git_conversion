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
    <?php

    $rights_run_at_risk_measurement_run = 10181213; 
    $rights_run_at_risk_measurement_IU = 10181210; //////added by me
    list (
        $has_rights_run_at_risk_measurement_run,  
        $has_rights_run_at_risk_measurement_IU

    ) = build_security_rights (
        $rights_run_at_risk_measurement_run,
        $rights_run_at_risk_measurement_IU

    );

    $function_id = 10181200;
    $criteria_id = get_sanitized_value($_GET['criteria_id'] ?? ''); 
    $form_namespace = 'RiskMeasure';
    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $grid_name = "risk_measure";
    $grid_sp = "EXEC spa_var_measurement_criteria_detail 'x'";
    $form_obj->define_grid($grid_name,  $grid_sp);
    $form_obj->define_custom_functions('save_risk', 'load_form', 'delete_risk_criteria');
    echo $form_obj->init_form('At Risk Measurement Criteria', 'At Risk Measurement Criteria', $criteria_id);
    echo $form_obj->close_form(); 

    $frm_obj = new AdihaForm();
    $sp = "EXEC spa_getsourcecounterparty @flag = 's'";
    $process_dropdown = $frm_obj->adiha_form_dropdown($sp);
    $query_date = date('Y-m-d'); 
    
    $process_form_structure = '[
                                {type:"settings","position":"label-top"},
                                {type: "block", blockOffset: 5, list: [
                                       {type: "calendar", "validate":"NotEmptywithSpace", required:true,"offsetLeft":"10","labelWidth":140
                                            ,"inputWidth":120, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '"
                                            , "serverDateFormat": "%Y-%m-%d", "name": "as_of_date", "label": "As of Date", "value": "' . $query_date . '"},
                                       {type:"combo",name:"process_counterparty",required:true,label:"Counterparty","tooltip":"","offsetLeft":"10"
                                            ,"labelWidth":140,"inputWidth":"120",options:' . $process_dropdown . ',disabled:false,hidden:false, filtering:true},
                                       {type: "button", value: "Ok", img: "tick.png", "offsetLeft":"10"}
                                   ]
                                }
                            ]';  
    ?>
<body>
</body>

<script type="text/javascript">
    var has_rights_run_at_risk_measurement_run =<?php echo (($has_rights_run_at_risk_measurement_run) ? $has_rights_run_at_risk_measurement_run : '0'); ?>;
    var has_rights_run_at_risk_measurement_IU =<?php echo (($has_rights_run_at_risk_measurement_IU) ? $has_rights_run_at_risk_measurement_IU : '0'); ?>;
    var theme_selected = default_theme;
    var process_form_structure = <?php echo $process_form_structure; ?>;
    var php_script_loc_ajax = "<?php echo $php_script_loc ?? ''; ?>";
    var function_id = <?php echo $function_id;?>;
    var id, measure_val;
    
    //popup form
    var run_assessment_popup = new dhtmlXPopup();
    var run_assessment_form_data = run_assessment_popup.attachForm(process_form_structure);
    
    run_assessment_form_data.attachEvent("onButtonClick", function() {    
        var status = validate_form(run_assessment_form_data); 
        if(status) {
            run_risk_calculation();
            toggle_run_risk_calc_popup();
        }
    });
    /** 
     *
     */  
    $(function() {
        RiskMeasure.layout.cells('a').setWidth(305);
        RiskMeasure.menu.addNewSibling('t2', 'run', 'Run', true, 'run.gif', 'run_dis.gif');
        RiskMeasure.menu.attachEvent('onClick', RiskMeasure.process_click);

        RiskMeasure.grid.attachEvent("onRowSelect", function(id,ind){
            var grid_obj = RiskMeasure.grid;
            var rid = grid_obj.getSelectedRowId();
            
            if (rid.indexOf(',') != -1 || rid == '') {
               RiskMeasure.menu.setItemDisabled('run');
            } else {
                if(has_rights_run_at_risk_measurement_run)
                    RiskMeasure.menu.setItemEnabled('run'); 
            }
        });
    });
    /** 
     *
     */  
    RiskMeasure.load_form = function(win, tab_id) {        
        var is_new = win.getText();
        win.progressOff();
        var tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        RiskMeasure["inner_tab_layout_" + tab_id] = win.attachLayout("1C");
        
        if (is_new == 'New') {
            id = '';
        } else {
            id = tab_id;
        }
        
        var xml_value = '<Root><PSRecordset id="' + id + '"></PSRecordset></Root>';
            data = {"action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": function_id,
                "template_name": 'RiskMeasure',
                "parse_xml": xml_value
            };
            result = adiha_post_data('return_array', data, '', '', 'RiskMeasure.load_form_data', false);

    }
    /** 
     *
     */  
    RiskMeasure.load_form_data = function(result) {
        var active_tab_id = RiskMeasure.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var result_length = result.length;
        var tab_json = '';

        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }

        tab_json = '{tabs: [' + tab_json + ']}';
        RiskMeasure["risk_measure_tabs_" + active_object_id] = RiskMeasure["inner_tab_layout_" + active_object_id].cells("a").attachTabbar();
        RiskMeasure["risk_measure_tabs_" + active_object_id].loadStruct(tab_json);
        RiskMeasure["risk_measure_tabs_" + active_object_id].setTabsMode("bottom");
        
        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            if (j == 0) {
				RiskMeasure["form" + active_object_id] = RiskMeasure["risk_measure_tabs_" + active_object_id].cells(tab_id).attachForm();
				if (result[j][2]) {
					RiskMeasure["form" + active_object_id].loadStruct(result[j][2]);
				} 
						
				RiskMeasure["form" + active_object_id].attachEvent('onChange', function(name, value) {              
					if (name == 'var_approach') {                  
						hide_show_components(value);                    
					} else if (name == 'measure') { 
					   set_approach();
					} else if (name == 'hold_to_maturity') {
						var is_chk = RiskMeasure["form" + active_object_id].isItemChecked('hold_to_maturity');
						if (is_chk == true) {
							RiskMeasure["form" + active_object_id].disableItem('holding_period');
						} else {
							RiskMeasure["form" + active_object_id].enableItem('holding_period');
						}
					}
				});
            }
        }
        
        if (active_tab_id.indexOf("tab_") == -1) {            
            RiskMeasure["form" + active_object_id].setItemValue('measure',17351); 
        }        
	
        set_approach();
        
		var is_chk = RiskMeasure["form" + active_object_id].isItemChecked('hold_to_maturity');
		if (is_chk == true) {
			RiskMeasure["form" + active_object_id].disableItem('holding_period');
		} else {
			RiskMeasure["form" + active_object_id].enableItem('holding_period');
		}
    }
    /** 
     *
     */  
    function set_approach() {   
		var active_tab_id = RiskMeasure.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
		var measure = RiskMeasure["form" + active_object_id].getItemValue('measure');
        var approach = RiskMeasure["form" + active_object_id].getItemValue('var_approach');
        
        if (measure == '17352' || measure == '17353' || measure == '17355') {
           approach = 1522;
           RiskMeasure["form" + active_object_id].disableItem('var_approach');
        } else {
           RiskMeasure["form" + active_object_id].enableItem('var_approach');                       
        }
        
        if (measure == 17355) { //17355 is PFE
            RiskMeasure["risk_measure_tabs_" + active_object_id].cells(tab_id).hide();
        } else {
            var sub_book_query = "EXEC spa_portfolio_group_book @flag = 'f', @mapping_source_usage_id = '" + id + "'," + "@mapping_source_value_id = 23203";
            var deal_query = "EXEC spa_portfolio_mapping_deal @flag='x', @mapping_source_usage_id='" + id + "'," + "@mapping_source_value_id = 23203"; ;
            var filter_query =  "EXEC spa_portfolio_group_book @flag = 's', @mapping_source_usage_id = '" + id + "'," + "@mapping_source_value_id = 23203";
                
            RiskMeasure["risk_measure_tabs_" + active_object_id].cells(tab_id).show();
            RiskMeasure["risk_measure_tabs_" + active_object_id].cells(tab_id).attachURL("../run_at_risk/generic.portfolio.mapping.template.php", null, {sub_book: sub_book_query, deals: deal_query, book_filter: filter_query, func_id: function_id, is_tenor_enable:true, req_portfolio_group: true});              
        }

        RiskMeasure["form" + active_object_id].setItemValue('var_approach',approach);
        hide_show_components(approach);
    }
    /** 
     *
     */  
    function hide_show_components(approach) {
        var active_tab_id = RiskMeasure.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
		
        if (approach == '1520') {
             RiskMeasure["form" + active_object_id].hideItem('daily_return_data_series');
             RiskMeasure["form" + active_object_id].setRequired('simulation_days',false);
             RiskMeasure["form" + active_object_id].clearNote('simulation_days');
             RiskMeasure["form" + active_object_id].hideItem('simulation_days');
             RiskMeasure["form" + active_object_id].setItemValue('simulation_days', '');
             RiskMeasure["form" + active_object_id].enableItem('vol_cor','r'); 
             RiskMeasure["form" + active_object_id].enableItem('vol_cor','d'); 
             RiskMeasure["form" + active_object_id].showItem('volatility_source');
        } else if (approach == '1521') {
             RiskMeasure["form" + active_object_id].showItem('daily_return_data_series');
             RiskMeasure["form" + active_object_id].showItem('simulation_days');
             RiskMeasure["form" + active_object_id].setRequired('simulation_days',true);
             RiskMeasure["form" + active_object_id].setValidation('simulation_days', "ValidInteger");
             RiskMeasure["form" + active_object_id].clearNote('simulation_days');
             RiskMeasure["form" + active_object_id].disableItem('vol_cor','r'); 
             RiskMeasure["form" + active_object_id].disableItem('vol_cor','d');
             RiskMeasure["form" + active_object_id].hideItem('volatility_source');
             RiskMeasure["form" + active_object_id].hideItem('daily_return_data_series');
        } else if (approach == '1522') {
             RiskMeasure["form" + active_object_id].hideItem('daily_return_data_series');
             RiskMeasure["form" + active_object_id].showItem('simulation_days');
             RiskMeasure["form" + active_object_id].setRequired('simulation_days',true);
             RiskMeasure["form" + active_object_id].setValidation('simulation_days', "ValidInteger");
             RiskMeasure["form" + active_object_id].clearNote('simulation_days');
             RiskMeasure["form" + active_object_id].disableItem('vol_cor','r'); 
             RiskMeasure["form" + active_object_id].disableItem('vol_cor','d');
             RiskMeasure["form" + active_object_id].showItem('volatility_source');
        } 
    }
    /** 
     *
     */  
    RiskMeasure.save_risk = function(tab_id) {
        var active_tab_id = RiskMeasure.tabbar.getActiveTab();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;        
        var tab_obj = RiskMeasure["inner_tab_layout_" + object_id].cells('a').getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();
        var form_xml = '<Root function_id="<?php echo $function_id;?>"><FormXML ';
        var measure_var;
        var portfolio_xml;
        var tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var criteria_id = '';
        var del_flag;
        var validation_status = true;
        var tabsCount = tab_obj.getNumberOfTabs();
        var form_status = true;
        var first_err_tab;
        
        $.each(detail_tabs, function(index, value) {
            var tab_text = RiskMeasure["risk_measure_tabs_" + object_id].tabs(value).getText();

            layout_obj = tab_obj.cells(value).getAttachedObject();
            attached_obj = layout_obj;
            if (attached_obj instanceof dhtmlXForm) {
                attached_obj = layout_obj;
                var inner_tab_id = get_tab_id(0);
                var status = validate_form(attached_obj );
                form_status = form_status && status; 
                if (tabsCount == 1 && !status) {
                     first_err_tab = "";
                } else if ((!first_err_tab) && !status) {
                    first_err_tab = RiskMeasure["risk_measure_tabs_" + tab_id].cells(inner_tab_id);
                }
                
                if (status == false) {
                    validation_status = false;
                    var sim_days = attached_obj.getItemValue('simulation_days');
                    if (isNaN(sim_days) || sim_days == '') {
                        attached_obj.setNote('simulation_days', { text: "Invalid Number", width:150});
                    }
                }

                data = attached_obj.getFormData();
                for (var a in data) {
                    field_label = a;                            
                    field_value = data[a];                            
                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                    
                    if (field_label == 'id') {
                        criteria_id = field_value;
                    }

                    if (field_label == 'measure'){
                        measure_var = field_value;
                    }
                }
            } 
            
            if (measure_var != 17355 && tab_text == 'Portfolio') {  //17355 is PFE
                var ifr = RiskMeasure["risk_measure_tabs_" + object_id].cells(value).getFrame();
                var deal_ifr = ifr.contentWindow.generic_portfolio.get_deal_frame();
                del_flag = deal_ifr.contentWindow.deal_selection.grd_deal_selection.getUserData("", "deleted_xml");
                deal_ifr.contentWindow.deal_selection.grd_deal_selection.setUserData("","deleted_xml", "");
                portfolio_xml = ifr.contentWindow.generic_portfolio.get_portfolio_form_data();
            }
        });
        form_xml += "></FormXML></Root>";
        var mode = (criteria_id == '') ? 'i' : 'u';
        
        if (del_flag == 'deleted') {
            del_msg =  "Some data has been deleted from <b>Deals</b> grid. Are you sure you want to save?";
            dhtmlx.message({
                type: "confirm",
                title: "Warning",
                text: del_msg,
                callback: function(result) {
                    if (result) {
                        //in case of del_flag set and ok clicked
                        if (validation_status == true) {  
                            data = {"action": "spa_risk_measurement_criteria", 
                                    "flag": "" + mode + "",
                                    "form_xml": form_xml,
                                    "portfolio_xml" : portfolio_xml
                            };
                            adiha_post_data("alert", data, "", "", "post_save_data");
                        }
                    }
                }
            });
        } else {
            //in case of no del_flag set
            if (validation_status == true && portfolio_xml != false) {  
                 RiskMeasure.tabbar.tabs(active_tab_id).getAttachedToolbar().disableItem('save');
                data = {"action": "spa_risk_measurement_criteria", 
                        "flag": "" + mode + "",
                        "form_xml": form_xml,
                        "portfolio_xml" : portfolio_xml
                };
                adiha_post_data("alert", data, "", "", "post_save_data");
            }
            if (!form_status) {
                generate_error_message(first_err_tab);
            }
        }
    }
    /**
     *
     */     
    function post_save_data(result) {
        var active_tab_id = RiskMeasure.tabbar.getActiveTab();
        if (has_rights_run_at_risk_measurement_IU) {
            RiskMeasure.tabbar.tabs(active_tab_id).getAttachedToolbar().enableItem('save');
        };

		var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;      
        var criteria_name = RiskMeasure["form" + object_id].getItemValue('name');
        
        if (result[0].errorcode == 'Success') {
            if(result[0].recommendation != ''){
                tab_id = 'tab_' + result[0].recommendation;
                RiskMeasure.create_tab_custom(tab_id, criteria_name);
                RiskMeasure.tabbar.tabs(active_tab_id).close(true);
            } else {
               RiskMeasure.tabbar.tabs(active_tab_id).setText(criteria_name);
            }
            RiskMeasure.refresh_grid("", refresh_grid_callback);
            RiskMeasure.menu.setItemDisabled("delete");
        }
    }
    /**
     *
     */ 
    function refresh_grid_callback() {
        var col_type = RiskMeasure.grid.getColType(0);
        var prev_id = RiskMeasure.tabbar.getActiveTab();
        var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;
        var primary_value = RiskMeasure.grid.findCell(system_id, 0, true, true);
        RiskMeasure.grid.filterByAll(); 
        if (primary_value != "") {
            var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
            var tab_text = RiskMeasure.get_text(RiskMeasure.grid, r_id);
            RiskMeasure.tabbar.tabs(prev_id).setText(tab_text);
            RiskMeasure.grid.selectRowById(r_id,false,true,true);
        }
    }
    /**
     *
     */    
    RiskMeasure.create_tab_custom = function(full_id,text) {
        if (!RiskMeasure.pages[full_id]) {
            RiskMeasure.tabbar.addTab(full_id, text, null, null, true, true);
            var win = RiskMeasure.tabbar.cells(full_id);
            win.progressOn();
            //using window instead of tab 
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath(js_image_path +"dhxtoolbar_web/");
            toolbar.attachEvent("onClick", RiskMeasure.save_risk);
            toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
            RiskMeasure.tabbar.cells(full_id).setActive();
            RiskMeasure.tabbar.cells(full_id).setText(text);
            RiskMeasure.load_form(win, full_id);
            RiskMeasure.pages[full_id] = win;
        }
        else {
            RiskMeasure.tabbar.cells(full_id).setActive();
        }
    }   
    /**
     * [Delete Risk Criteria]
     */
    RiskMeasure.delete_risk_criteria = function() {
        var row_id = RiskMeasure.grid.getSelectedRowId();
        var count = row_id.indexOf(",") > -1 ? row_id.split(",").length : 1;
        row_id = row_id.indexOf(",") > -1 ? row_id.split(",") : [row_id];
        var criteria_id = '';
        for (var i = 0; i < count; i++) {
            criteria_id += RiskMeasure.grid.cells(row_id[i], 0).getValue() + ',';
        }
        criteria_id = criteria_id.slice(0, -1);
        
        if (criteria_id != 0 && criteria_id != '') {
            var delete_sp_string = "EXEC spa_risk_measurement_criteria @flag='d', @del_criteria_id= '" + criteria_id + "'";
            var data = {"sp_string": delete_sp_string};
            adiha_post_data('confirm', data, '', '', 'delete_callback', '');
        }         
    }
    /**
     *
     */
    function delete_callback(result) {
        if (result[0].errorcode == 'Success') {
            if (result[0].recommendation.indexOf(",") > -1) {
                var ids = result[0].recommendation.split(",");
                var count_ids = ids.length;
                for (var i = 0; i < count_ids; i++ ) {
                    full_id = 'tab_' + ids[i];
                    if (RiskMeasure.pages[full_id]) {
                        RiskMeasure.tabbar.cells(full_id).close();
            }
                }
            } else {
                full_id = 'tab_' + result[0].recommendation;
                if (RiskMeasure.pages[full_id]) {
                    RiskMeasure.tabbar.cells(full_id).close();
                }
            }
            RiskMeasure.refresh_grid();
            RiskMeasure.menu.setItemDisabled("delete");
            RiskMeasure.menu.setItemDisabled("run");
        }
    }
    /**
     *
     */
    RiskMeasure.process_click = function(args) {
         switch(args) {
            case 'run':
                toggle_run_risk_calc_popup();
                break;
         }
    } 
    /**
     *
     */
    function toggle_run_risk_calc_popup() {        
        if (run_assessment_popup.isVisible()) {
            run_assessment_popup.hide();
        } else {
            var grid_obj = RiskMeasure.grid;
            var rid = grid_obj.getSelectedRowId();
            var cid_measure = grid_obj.getColIndexById('measure');
            var var_measure = grid_obj.cells(rid,cid_measure).getValue();
            
            if (var_measure == 'PFE') {
                run_assessment_form_data.showItem('process_counterparty');
            } else {
                run_assessment_form_data.hideItem('process_counterparty');
            }
            
            run_assessment_popup.show(190, 60, 40, 5);   //60 height, 40 width       
        }
    }
    /**
     *
     */    

    function get_tab_id(j) {
        var tab_id = [];
        var i = 0;
        var inner_tab_obj = get_inner_tab_obj();
        inner_tab_obj.forEachTab(function(tab){
            tab_id[i] = tab.getId();
            i++;
        });
        return tab_id[j];
    }
    /**
     *
     */
    function get_inner_tab_obj() {
        var active_tab_id = RiskMeasure.tabbar.getActiveTab();
        var detail_tabs, att_tabbar_obj;
        RiskMeasure.tabbar.forEachTab(function(tab){
            if (tab.getId() == active_tab_id) {
                var att_lay_obj = tab.getAttachedObject();
                att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                detail_tabs = att_tabbar_obj.getAllTabs();
            }
        });
        return att_tabbar_obj;
    }



    function run_risk_calculation() {  
        var as_of_date = run_assessment_form_data.getItemValue('as_of_date',true);       
        var counterparty = 'NULL';
        var grid_obj = RiskMeasure.grid;
        var rid = grid_obj.getSelectedRowId();
        var cid = grid_obj.getColIndexById('risk_measure_id');
        var var_criteria_id = grid_obj.cells(rid,cid).getValue(); 
        var cid_measure = grid_obj.getColIndexById('measure');
        var var_measure = grid_obj.cells(rid,cid_measure).getValue();
        var cid_approach = grid_obj.getColIndexById('approach'); 
        var var_approach = grid_obj.cells(rid,cid_approach).getValue(); 
        var param = 'call_from=Run Risk Calculation&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
        var title = 'Run Risk Calculation';
        
        if (var_measure == 'PFE') {
            counterparty = run_assessment_form_data.getItemValue('process_counterparty')
        }
                      
        var exec_common = singleQuote(as_of_date)+ ', ' 
                        + var_criteria_id + ', ' 
                        + 'NULL' + ', ' 
                        + 'NULL' + ', NULL, NULL, NULL, NULL, NULL, NULL';
        
        
        var exec_call = (var_approach == 'Variance/Covariance Approach') 
                        ? 'EXEC spa_calc_var_job ' + exec_common 
                        : 'EXEC spa_calc_var_simulation_job ' + exec_common + ', ' + counterparty;
        
        if (exec_call == null) {
            return;
        } 
        adiha_run_batch_process(exec_call, param, title);       
    }
    </script>