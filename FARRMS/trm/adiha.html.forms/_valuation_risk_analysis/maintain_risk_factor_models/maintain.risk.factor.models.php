<?php
/**
* Maintain risk factor models screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
    </head>
    <body>
    <?php
        $function_id = 10183000;
		
		$rights_monte_carlo_iu = 10183010;
		$rights_monte_carlo_delete = 10183011;
		$rights_monte_carlo_curve_iu = 10183012;
		$rights_monte_carlo_curve_delete = 10183013;
		
    	list (
    		$has_rights_monte_carlo_iu,
    		$has_rights_monte_carlo_delete,
    		$has_rights_monte_carlo_curve_iu,
    		$has_rights_monte_carlo_curve_delete
    		
        ) = build_security_rights(
    		$rights_monte_carlo_iu,
    		$rights_monte_carlo_delete,
    		$rights_monte_carlo_curve_iu,
    		$rights_monte_carlo_curve_delete                
        );
		
        $form_namespace = 'risk_factor';
        $template_name = 'MaintainRiskFactorModel';
        
        $form_obj = new AdihaStandardForm($form_namespace, $function_id);
        $form_obj2 = new AdihaForm();   
        
        $grid_name = "monte_carlo_model_parameter";
        $grid_sp = "EXEC spa_monte_carlo_model @flag='s'";
        
        $form_obj->define_grid($grid_name,  $grid_sp);
        $form_obj->define_custom_functions('save_form', 'load_form', 'delete_risk_factor');   
        echo $form_obj->init_form('Risk Factor Models', 'Maintain Risk Factor Models');   
        echo $form_obj->close_form();

        //Grid parameters
        $table_name = 'grid_source_price_curve_def';
        $grid_def = "EXEC spa_adiha_grid 's', '" . $table_name . "'";
        $def = readXMLURL2($grid_def);
        $grid_id = $def[0]['grid_id'];
        $table_name = $def[0]['grid_name'];
        $grid_columns = $def[0]['column_name_list'];
        $grid_col_labels = $def[0]['column_label_list'];
        $grid_col_types = $def[0]['column_type_list'];
        $grid_sorting_preference = $def[0]['sorting_preference'];
        $grid_set_visibility = $def[0]['set_visibility'];
        $grid_column_width = $def[0]['column_width'];
        //End of Grid

        /* JSON for grid toolbar */
        $button_grid_json = '[
              {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                  {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"' . $rights_monte_carlo_iu . '"},
                  {id:"remove", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: false}
              ]},
              {id:"t2", text:"Export", img:"export.gif",imgdis:"export_dis.gif",items:[
                  {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                  {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
              ]}
              ]';
        /* END */

        $sp_url_data_series = "exec spa_staticdatavalues @flag='h', @type_id=1560, @license_not_to_static_value_id='1560, 1561'";
        $cmb_data_series = $form_obj2->adiha_form_dropdown($sp_url_data_series, 0, 1, false, '', 2);

        $sp_url_vol_data_series = "exec spa_staticdatavalues @flag='h', @type_id=1560";
        $cmb_vol_data_series = $form_obj2->adiha_form_dropdown($sp_url_vol_data_series, 0, 1, false, '', 2);

        $sp_url_curve_source = "exec spa_staticdatavalues @flag='h', @type_id=10007";
        $cmb_curve_source= $form_obj2->adiha_form_dropdown($sp_url_curve_source, 0, 1, false, '', 2);

        $sp_url_volatility_source = "exec spa_staticdatavalues @flag='h', @type_id=10007";
        $cmb_volatility_source= $form_obj2->adiha_form_dropdown($sp_url_volatility_source, 0, 1, false, '', 2);

        $sp_url_approach = "exec('select ''e'', ''Equally Weighted'' union all select ''x'', ''Exponentially Weighted'' union all select ''g'', ''GARCH (1,1)''')";
        $cmb_approach = $form_obj2->adiha_form_dropdown($sp_url_approach, 0, 1);
    ?>
    </body>
<script>
    var php_script_loc = "<?php echo $app_php_script_loc; ?>";
    var grid_toolbar_json =<?php echo $button_grid_json; ?>;
    var cmb_data_series = <?php echo $cmb_data_series; ?>;
    var cmb_vol_data_series = <?php echo $cmb_vol_data_series; ?>;
    var cmb_curve_source = <?php echo $cmb_curve_source; ?>;
    var cmb_volatility_source = <?php echo $cmb_volatility_source; ?>;
    var cmb_approach = <?php echo $cmb_approach; ?>;
    var function_id = <?php echo $function_id; ?>;
    var template_name = '<?php echo $template_name; ?>';
	
	var	has_rights_monte_carlo_iu = <?php echo (($has_rights_monte_carlo_iu) ? $has_rights_monte_carlo_iu : '0'); ?>;
	var	has_rights_monte_carlo_delete = <?php echo (($has_rights_monte_carlo_delete) ? $has_rights_monte_carlo_delete : '0'); ?>;
	var	has_rights_monte_carlo_curve_iu = <?php echo (($has_rights_monte_carlo_curve_iu) ? $has_rights_monte_carlo_curve_iu : '0'); ?>;
	var	has_rights_monte_carlo_curve_delete = <?php echo (($has_rights_monte_carlo_curve_delete) ? $has_rights_monte_carlo_curve_delete : '0'); ?>;
		
    dhxWins = new dhtmlXWindows();
	var theme_selected = 'dhtmlx_' + default_theme;
    
    risk_factor.load_form = function(win, full_id){
        win.progressOff();
        var object_id = (full_id.indexOf("tab_") != -1) ? full_id.replace("tab_", "") : full_id;
        var inner_layout = [
            {
                id: "a",
                header: false,
                collapse: false,
                height: 110,
                fix_size: [true, null]
            }
        ];
        /*layout_obj*/
        risk_factor["risk_factor_tabs_" + object_id] = win.attachLayout({pattern: "1C", cells: inner_layout});
        layout_obj = risk_factor["risk_factor_tabs_" + object_id];

        var additional_data = {"action": "spa_create_application_ui_json",
            "parse_xml": "<Root><PSRecordset monte_carlo_model_parameter_id=" + '"' + object_id + '"' + "></PSRecordset></Root>",
            "application_function_id": function_id,
            "template_name": template_name,
            "flag": "j"
        };
        adiha_post_data('return_array', additional_data, '', '', 'risk_factor.load_tab_and_forms');      
    }
    risk_factor.load_tab_and_forms = function(result) {
        var active_tab_id = risk_factor.tabbar.getActiveTab();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        risk_factor["risk_factor_tabs_" + object_id] = risk_factor["risk_factor_tabs_" + object_id].cells("a").attachTabbar({mode:"bottom", arrows_mode:"auto"});
        var tab_json = '{mode: "bottom", arrows_mode: "auto", tabs: [' + result[0][1] + ',' + result[1][1] + ', ' + result[2][1] + ']}';
        risk_factor["risk_factor_tabs_" + object_id].loadStruct(tab_json);
        
        var i = 0;
        var tab_id = [];
        risk_factor["risk_factor_tabs_" + object_id].forEachTab(function(tab){
            tab_id[i] = tab.getId();
            i++;
        })
        
        //Third tab, attach grid menu
        risk_factor["toolbar_grid_" + object_id] = risk_factor["risk_factor_tabs_" + object_id].tabs(tab_id[2]).attachMenu();
        risk_factor["toolbar_grid_" + object_id].setIconsPath(php_script_loc + 'components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/');
        risk_factor["toolbar_grid_" + object_id].loadStruct(grid_toolbar_json);
        risk_factor["toolbar_grid_" + object_id].attachEvent('onClick', risk_factor.curve_grid_toolbar_click);
        if(has_rights_monte_carlo_curve_iu){ //right
            risk_factor["toolbar_grid_" + object_id].setItemEnabled("add");
        }
				
		if(has_rights_monte_carlo_curve_delete == 0){ //right
		    risk_factor["toolbar_grid_" + object_id].setItemDisabled("remove");
		}
			
		
        //end of menu
        risk_factor["risk_factor_tabs_" + object_id].tabs(tab_id[2]).attachStatusBar({
                                height: 30,
                                text: '<div id="pagingAreaGrid_b"></div>'
                            });
        var curve_mapping_grid = risk_factor["risk_factor_tabs_" + object_id].tabs(tab_id[2]).attachGrid();
        curve_mapping_grid.setImagePath("<?php echo $image_path;?>dhxtoolbar_web/");
        curve_mapping_grid.setHeader("<?php echo $grid_col_labels;?>");
        curve_mapping_grid.setColumnIds("<?php echo $grid_columns;?>");
        curve_mapping_grid.setColTypes("<?php echo $grid_col_types;?>");
        curve_mapping_grid.setInitWidths("<?php echo $grid_column_width;?>");
        curve_mapping_grid.setColumnsVisibility("<?php echo $grid_set_visibility;?>");
        curve_mapping_grid.attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
        curve_mapping_grid.setColSorting("<?php echo $grid_sorting_preference;?>"); 
        curve_mapping_grid.enableStableSorting(true);
        curve_mapping_grid.init();
        //curve_mapping_grid.enableDragAndDrop(true);
        curve_mapping_grid.enableMultiselect(true);
        curve_mapping_grid.enablePaging(true, 10, 0, 'pagingAreaGrid_b');
        curve_mapping_grid.attachEvent("onRowSelect", function(id) {
        
    		if(has_rights_monte_carlo_curve_delete == 0){
                risk_factor["toolbar_grid_" + object_id].setItemDisabled("remove");
    		} else {
                risk_factor["toolbar_grid_" + object_id].setItemEnabled("remove");
            } 
        });
        curve_mapping_grid.enablePaging(true, 10, 0, 'pagingAreaGrid_b');
        curve_mapping_grid.setPagingSkin('toolbar');
        curve_mapping_grid.setPagingWTMode(true, true, true, true);
        
        var grid_sql_param = {
            "sql": "EXEC spa_monte_carlo_model @flag='x', @monte_carlo_model_parameter_id="+ object_id,
            "grid_type": 'g'
        };
        
        grid_sql_param = $.param(grid_sql_param);
        var sql_url = js_data_collector_url + "&" + grid_sql_param;
        curve_mapping_grid.load(sql_url);

        fetch_form_data();
    }
    /**
     *
     */
    function fetch_form_data() {
        var active_tab_id = risk_factor.tabbar.getActiveTab();
        var is_new = risk_factor.tabbar.tabs(active_tab_id).getText();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        sql_param = {"action": "spa_monte_carlo_model",
                "flag": "f",
                "monte_carlo_model_parameter_id": (is_new == 'New' ? 'NULL' : object_id)
        };
        adiha_post_data('', sql_param, '', '', 'risk_factor.load_form_data'); 
    }
    /**
     *
     */
    risk_factor.load_form_data = function(data){
        var mean_reversion_type_a = true;
        var mean_reversion_type_g = false;
        var apply_mean_reversion_flag  = false;
        var mean_reversion_level_rdo = true;
        var mean_reversion_rate_rdo = true;

        var volatility_date = '';
        var drift_date = '';
        var seed_date = '';

        var volatility_exist_rdo = false;
        var drift_exist_rdo = false;
        var seed_exist_rdo = false;

        var volatility_calc_rdo = false;
        var drift_calc_rdo = false;
        var seed_calc_rdo = false;

        var volatility_date_rdo = false;
        var drift_date_rdo = false;
        var seed_date_rdo = false;
        var apply_mean_reversion_chk_box = false;

        var mean_reversion_level_e = false;
        var mean_reversion_level_c = false;
        var mean_reversion_rate_e = false;
        var mean_reversion_rate_c = false;
        
        if (data.length == 0) {
            var monte_carlo_model_parameter_name = '';
            var monte_carlo_model_parameter_id = '';
            var volatility = '';
            var drift = '';
            var seed = '';
            var data_series = '';
            var curve_source = '';
            var volatility_source = '';
            var vol_data_series = '';
            var vol_data_points = 30;
            var volatility_method = '';
            var vol_long_run_volatility = '';
            var vol_alpha = '';
            var vol_beta = '';
            var vol_gamma = '';
            var lambda = '';
            var mean_reversion_level = '';
            var mean_reversion_rate = '';
            var apply_mean_reversion = null;
        } else {
            var monte_carlo_model_parameter_name = data[0]['monte_carlo_model_parameter_name'];
            var monte_carlo_model_parameter_id = data[0]['monte_carlo_model_parameter_id'];
            
            volatility = (data[0]['volatility'] == null) ? '': data[0]['volatility'];
            if(volatility.indexOf('/') != -1) { //volatility instanceof Date is not working
                volatility_date = volatility;
                volatility = '';
                volatility_date_rdo = true;
            }
            if (volatility == 'e') {
                volatility_exist_rdo = true;
                volatility = '';
            }
            if (volatility == 'c') {
                volatility_calc_rdo = true;
                volatility = ''; 
            }

            drift = (data[0]['drift'] == null) ? '': data[0]['drift'];
            if (drift.indexOf('/') != -1) {
                drift_date = drift;
                drift = '';
                drift_date_rdo = true;
            }
            if (drift == 'e') {
                drift_exist_rdo = true;
                drift = '';
            }
            if (drift == 'c') {
                drift_calc_rdo = true;
                drift = '';
            }

            seed = (data[0]['seed'] == null) ? '': data[0]['seed'];
            if (seed.indexOf('/') != -1) {
                seed_date = seed;
                seed = '';
                seed_date_rdo = true;
            } 
            if (seed == 'c') {
                seed_calc_rdo = true;
                seed = '';
            }
            if (seed == 'e') {
                seed_exist_rdo = true;
                seed = '';
            }

            var data_series = data[0]['data_series'];
            var curve_source = data[0]['curve_source'];
            var volatility_source = data[0]['volatility_source'];
            var vol_data_series = data[0]['vol_data_series'];
            var vol_data_points = data[0]['vol_data_points'];
            var volatility_method = data[0]['volatility_method'];

            var vol_long_run_volatility = data[0]['vol_long_run_volatility'];
            var vol_alpha = data[0]['vol_alpha'];
            var vol_beta = data[0]['vol_beta'];
            var vol_gamma = data[0]['vol_gamma'];
            var relative_volatility = (data[0]['relative_volatility'] == 'y') ? "true" : "false";
            var lambda = data[0]['lambda'];
            var mean_reversion_type = data[0]['mean_reversion_type'];

            if (mean_reversion_type == 'a') {
                mean_reversion_type_a = true;
                mean_reversion_type_g = false;
            } else {
                mean_reversion_type_g = true;
                mean_reversion_type_a = false;
            }
            
            var mean_reversion_rate = (data[0]['mean_reversion_rate'] == null) ? '' : data[0]['mean_reversion_rate'];
            
            switch(mean_reversion_rate) {
                case 'e':
                    mean_reversion_rate_e = true;
                    mean_reversion_rate = '';
                    break;
                case 'c':
                    mean_reversion_rate_c = true;
                    mean_reversion_rate = '';
                default:
                    mean_reversion_rate_rdo = true;
                    break;
            }

            var mean_reversion_level = (data[0]['mean_reversion_level'] == null) ? '' : data[0]['mean_reversion_level'];
            
            switch(mean_reversion_level) {
                case 'e':
                    mean_reversion_level_e = true;
                    mean_reversion_level = '';
                    break;
                case 'c':
                    mean_reversion_level_c = true;
                    mean_reversion_level = '';
                default:
                    mean_reversion_level_rdo = true;
                    break;
            }

            var apply_mean_reversion = data[0]['apply_mean_reversion'];
            
            if(apply_mean_reversion == 'y') {
                apply_mean_reversion_flag = true;
                apply_mean_reversion_chk_box = true;
            } else {
                apply_mean_reversion_flag = false;   
                apply_mean_reversion_chk_box = false;
            }
        }
        if (apply_mean_reversion_chk_box == true) {
            apply_mean_reversion_flag = true;
        }
        var active_tab_id = risk_factor.tabbar.getActiveTab();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var inner_tab_layout_json = [
            {
                id: "a",  
                text: "Name",                        
                height: 150,
                header: true,
                collapse: false
            },
            {
                id: "b",
                text: "Parameters",
                header: true,
                height: 250,
                collapse: false,
                fix_size: [true, null]
            },
            {
                id: "c",
                text: "Mean Reversion",
                header: true,
                collapse: true,
                fix_size: [true, null]
            },
        ];

        var i = 0;
        var tab_id = [];
        risk_factor["risk_factor_tabs_" + object_id].forEachTab(function(tab){
            tab_id[i] = tab.getId();
            i++;
        });
        risk_factor["inner_tabs_" + object_id] = risk_factor["risk_factor_tabs_" + object_id].tabs(tab_id[0]).attachLayout({pattern: "3E", cells: inner_tab_layout_json});
        
        //Simulation tab
        var form_1 = '[{"type":"settings","position":"label-top" },';
        form_1 += '{"type":"input","name":"monte_carlo_model_parameter_name","label":"Name","value":"' + monte_carlo_model_parameter_name + '","userdata":{"validation_message":"Required Field"}, "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","inputWidth":"'+ ui_settings["field_size"] + '","tooltip":"Name","required":"true"},';
        form_1 += '{"type":"newcolumn"},';
        form_1 += '{"type":"combo","name":"data_series","label":"Data Series","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '","tooltip":"Data Series","required":"true","userdata":{"validation_message":"Invalid Selection"},"options": '+JSON.stringify(cmb_data_series)+'},';
        form_1 += '{"type":"newcolumn"},';
        form_1 += '{"type":"combo","name":"curve_source","label":"Curve Source", "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '","tooltip":"Curve Source","required":"true","filtering":"true","userdata":{"validation_message":"Invalid Selection"},"options":'+JSON.stringify(cmb_curve_source)+'},';
        form_1 += '{"type":"newcolumn"},';
        form_1 += '{"type":"combo","name":"volatility_source","label":"Volatility Source", "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '","tooltip":"Volatility Source","required":"true","filtering":"true","userdata":{"validation_message":"Invalid Selection"},"options": '+JSON.stringify(cmb_volatility_source)+' },';
        form_1 += '{"type":"input","name":"monte_carlo_model_parameter_id", "hidden":"true","disabled":"true","value":"'+monte_carlo_model_parameter_id+'"}';
        form_1 += ']';   
        
        risk_factor["form_1" + object_id] = risk_factor["inner_tabs_" + object_id].cells("a").attachForm();
        risk_factor["form_1" + object_id].loadStruct(get_form_json_locale($.parseJSON(form_1)));

        var form_2 = '[{"type":"settings","position":"label-top"},';
        form_2 += '{"type":"fieldset","label":"Volatility *","offsetLeft":"'+ ui_settings['offset_left'] +'","offsettop":"'+ ui_settings["fieldset_offset_top"] + '","width":"900","list":[';
        form_2 += '{"type": "block", "blockOffset": "'+ ui_settings+['block_offset'] +'", "list": [';
        form_2 += '{"type":"radio","name":"use_value1","value":"1","checked": "true", "label":"Use Value","position":"label-right","offsetLeft":"0", "validate": "ValidNumeric", "labelWidth":"auto","Width":"'+ ui_settings["field_size"] + '", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"numeric","name":"volatility","label":"","value":"' + volatility + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","inputWidth":"180","tooltip":"Volatility"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value1", "value": "e","checked": "' + volatility_exist_rdo + '", "label":"Use Recent Value","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"auto", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value1","value":"2","checked": "' + volatility_date_rdo + '", "label":"Use From As of Date","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"'+ ui_settings["field_size"] + '", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"calendar","name":"volatility_date","value":"' + volatility_date + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"180", "inputWidth":"180","dateFormat": "%m/%d/%Y"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value1", "value": "c","checked": "' + volatility_calc_rdo + '", "label":"Calculate","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"'+ ui_settings["field_size"] + '", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"}]}]},';
        
        form_2 += '{"type":"fieldset","label":"Drift *","offsetLeft":"'+ ui_settings['offset_left'] +'","offsettop":"'+ ui_settings["fieldset_offset_top"] + '","width":"900","list":';
        form_2 += '[{"type": "block", "blockOffset": "'+ ui_settings+['block_offset'] +'", "list":[';
        form_2 += '{"type":"radio","name":"use_value2","value":"5","label":"Use Value","checked":"true","position":"label-right","offsetLeft":"0", "labelWidth":"auto","Width":"100", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"numeric","name":"drift","label":"","value":"' + drift + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","validate": "ValidNumeric", "inputWidth":"180"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value2","value": "e","checked": "' + drift_exist_rdo + '","label":"Use Recent Value","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"100", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value2","value":"6","checked": "' + drift_date_rdo + '","label":"Use From As of Date","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"100", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"calendar","name":"drift_date","value":"' + drift_date + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"180", "inputWidth":180,"dateFormat": "%m/%d/%Y"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value2","value": "c","checked": "' + drift_calc_rdo + '","label":"Calculate","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"}]}]},';
        form_2 += '{"type":"newcolumn"},';

        form_2 += '{"type":"fieldset","label":"Seed *","offsetLeft":"'+ ui_settings['offset_left'] +'","offsettop":"'+ ui_settings["fieldset_offset_top"] + '","width":"900","list":';
        form_2 += '[{"type": "block", "blockOffset": "'+ ui_settings+['block_offset'] +'", "list":[';
        form_2 += '{"type":"radio","name":"use_value3","value": "9","label":"Use Value","checked":"true", "position":"label-right","offsetLeft":"0","labelWidth":"auto","Width":"100", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"numeric","name":"seed","label":"","value":"' + seed + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","validate": "ValidNumeric", "inputWidth":"180"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value3","value":"e","checked": "' + seed_exist_rdo + '","label":"Use Recent Value","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","Width":"100", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value3","value":"'+ ui_settings['offset_left'] +'","checked": "' + seed_date_rdo + '","label":"Use From As of Date","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"100", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"calendar","name":"seed_date","value":"' + seed_date + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"180", "inputWidth":180,"dateFormat": "%m/%d/%Y"},';
        form_2 += '{"type":"newcolumn"},';
        form_2 += '{"type":"radio","name":"use_value3","value": "c","checked": "' + seed_calc_rdo + '","label":"Calculate","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'", "offsetTop":"15"},';
        form_2 += '{"type":"newcolumn"}]}]}]';

        risk_factor["form_2" + object_id] = risk_factor["inner_tabs_" + object_id].cells("b").attachForm();
        risk_factor["form_2" + object_id].loadStruct(get_form_json_locale($.parseJSON(form_2)));
        

        risk_factor["form_2" + object_id].attachEvent("onChange", function(){
            //volality
            if (risk_factor["form_2" + object_id].getCheckedValue('use_value1') == 1) {
                risk_factor["form_2" + object_id].enableItem('volatility');
            } else {
                risk_factor["form_2" + object_id].disableItem('volatility');
                risk_factor["form_2" + object_id].setItemValue('volatility', '');
            }
            //volality date
            if (risk_factor["form_2" + object_id].getCheckedValue('use_value1') == 2) {
                risk_factor["form_2" + object_id].enableItem('volatility_date');
            } else {
                risk_factor["form_2" + object_id].disableItem('volatility_date');
                risk_factor["form_2" + object_id].setItemValue('volatility_date', '');
            }
            //drift
            if (risk_factor["form_2" + object_id].getCheckedValue('use_value2') == 5) {
                risk_factor["form_2" + object_id].enableItem('drift');
            } else {
                risk_factor["form_2" + object_id].disableItem('drift');
                risk_factor["form_2" + object_id].setItemValue('drift', '');
            }
            //drift date
            if (risk_factor["form_2" + object_id].getCheckedValue('use_value2') == 6) {
                risk_factor["form_2" + object_id].enableItem('drift_date');
            } else {
                risk_factor["form_2" + object_id].disableItem('drift_date');
                risk_factor["form_2" + object_id].setItemValue('drift_date', '');
            }

            //seed
            if (risk_factor["form_2" + object_id].getCheckedValue('use_value3') == 9) {
                risk_factor["form_2" + object_id].enableItem('seed');
            } else {
                risk_factor["form_2" + object_id].disableItem('seed');
                risk_factor["form_2" + object_id].setItemValue('seed', '');
            }
            //seed date
            if (risk_factor["form_2" + object_id].getCheckedValue('use_value3') == 15) {
                risk_factor["form_2" + object_id].enableItem('seed_date');
            } else {
                risk_factor["form_2" + object_id].disableItem('seed_date');
                risk_factor["form_2" + object_id].setItemValue('seed_date', '');
            }
        });
        var cmb_data_series_obj = risk_factor["form_1" + object_id].getCombo('data_series');
        cmb_data_series_obj.setComboValue(data_series);
        cmb_data_series_obj.enableFilteringMode(true);
        //load Geometric as default
        if (curve_source  == '') {
            setTimeout(function() {
                cmb_data_series_obj.selectOption(3);
            }, 100);    
        }
        //

        var cmb_curve_source_obj = risk_factor["form_1" + object_id].getCombo('curve_source');
        cmb_curve_source_obj.setComboValue(curve_source);
        //load Master as default
        if (curve_source  == '') {
            setTimeout(function() {
                var curve_source_index = cmb_curve_source_obj.getIndexByValue(4500);
                cmb_curve_source_obj.selectOption(curve_source_index);
            }, 100);    
        }
        //

        var cmb_volatility_source_obj = risk_factor["form_1" + object_id].getCombo('volatility_source');
        cmb_volatility_source_obj.setComboValue(volatility_source);

        var form_3 = '[{"type":"settings","position":"label-top"},';
        form_3 += '{"type":"checkbox","name":"apply_mean_reversion","value":"y","label":"Apply Mean Reversion","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"550", "checked":"' + apply_mean_reversion_chk_box + '"},';
        form_3 += '{"type": "fieldset", "name":"mean_reversion_type_f", "label":"Mean Reversion Type","enabled":"'+apply_mean_reversion_flag+'","width":"750", "offsetLeft":"'+ ui_settings['offset_left'] +'", "offsettop":"'+ ui_settings["fieldset_offset_top"] + '", "list": [';
        form_3 += '{"type":"radio","name":"mean_reversion_type","label":"Use Arithmetic Mean Reversion","value":"a","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"'+ ui_settings["field_size"] + '","Width":"'+ ui_settings["field_size"] + '", "checked":"' + mean_reversion_type_a + '", "offsetTop":"15"},';
        form_3 += '{"type":"newcolumn"},';
        form_3 += '{"type":"radio","name":"mean_reversion_type","label":"Use Geometric Mean Reversion","value":"g","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"'+ ui_settings["field_size"] + '","Width":"'+ ui_settings["field_size"] + '", "checked":"' + mean_reversion_type_g + '", "offsetTop":"15"},';
        form_3 += '{"type":"newcolumn"}]},';
        
        form_3 += '{"type": "fieldset",  "name":"mean_reversion_type_r", "label":"Mean Reversion Rate *", "disabled":"' + apply_mean_reversion_flag + '", "width":"750", "offsetLeft":"'+ ui_settings['offset_left'] +'", "offsettop":"'+ ui_settings["fieldset_offset_top"] + '","list": [';
        form_3 += '{"type":"radio","name":"use_value4","label":"Use Value","value":"12", "checked":"' + mean_reversion_rate_rdo + '","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"100", "offsetTop":"15"},';
        form_3 += '{"type":"newcolumn"},';       
        form_3 += '{"type":"input","name":"mean_reversion_rate","label":"","value":"' + mean_reversion_rate + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"135"},';
        form_3 += '{"type":"newcolumn"},';
        form_3 += '{"type":"radio","name":"use_value4","label":"Use Recent Value","value":"e","checked": "' + mean_reversion_rate_e + '", "position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"'+ ui_settings["field_size"] + '","Width":"'+ ui_settings["field_size"] + '", "offsetTop":"15"},';
        form_3 += '{"type":"newcolumn"},';
        form_3 += '{"type":"radio","name":"use_value4","label":"Calculate","value":"c", "checked": "' + mean_reversion_rate_c + '", "position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"'+ ui_settings["field_size"] + '", "offsetTop":"15"}';
        form_3 += ']},';

        form_3 += '{"type": "fieldset",  "name":"mean_reversion_type_v", "label":"Mean Reversion Value *", "disabled":"' + apply_mean_reversion_flag + '", "width":"750", "offsetLeft":"'+ ui_settings['offset_left'] +'", "offsettop":"'+ ui_settings["fieldset_offset_top"] + '", "list":[';
        form_3 += '{"type":"radio","name":"use_value5","label":"Use Value","checked":"' + mean_reversion_level_rdo + '","value":"13","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","Width":"100", "offsetTop":"15"},';
        form_3 += '{"type":"newcolumn"},';
        form_3 += '{"type":"input","name":"mean_reversion_level","label":"","value":"' + mean_reversion_level + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"135"},';
        form_3 += '{"type":"newcolumn"},';
        form_3 += '{"type":"radio","name":"use_value5","label":"Use Recent Value", "value":"e", "checked": "' + mean_reversion_level_e + '", "position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"'+ ui_settings["field_size"] + '", "offsetTop":"15","Width":"'+ ui_settings["field_size"] + '"},';'+ ui_settings["field_size"] + '
        form_3 += '{"type":"newcolumn"},';
        form_3 += '{"type":"radio","name":"use_value5","label":"Calculate","value":"c", "checked":"' + mean_reversion_level_c + '", "position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"'+ ui_settings["field_size"] + '", "offsetTop":"15"},';
        form_3 += '{"type":"newcolumn"}';
        form_3 += ']}]'; 

        risk_factor["form_3" + object_id] = risk_factor["inner_tabs_" + object_id].cells("c").attachForm();
        risk_factor["form_3" + object_id].loadStruct(get_form_json_locale($.parseJSON(form_3)));

        //
        if(risk_factor["form_3" + object_id].isItemChecked('apply_mean_reversion')){
            risk_factor["form_3" + object_id].enableItem('mean_reversion_type_f');
            risk_factor["form_3" + object_id].enableItem('mean_reversion_type_r');
            risk_factor["form_3" + object_id].enableItem('mean_reversion_type_v');
            risk_factor["form_3" + object_id].enableItem('mean_reversion_level');
            risk_factor["form_3" + object_id].enableItem('mean_reversion_rate');
            risk_factor["form_3" + object_id].enableItem('mean_reversion_type');
        } else {
            risk_factor["form_3" + object_id].disableItem('mean_reversion_type_f');
            risk_factor["form_3" + object_id].disableItem('mean_reversion_type_r');
            risk_factor["form_3" + object_id].disableItem('mean_reversion_type_v');
            risk_factor["form_3" + object_id].disableItem('mean_reversion_level');
            risk_factor["form_3" + object_id].disableItem('mean_reversion_rate');
            risk_factor["form_3" + object_id].disableItem('mean_reversion_type');
        }
        if (risk_factor["form_3" + object_id].isItemChecked('use_value4', 12)) {
            risk_factor["form_3" + object_id].enableItem('mean_reversion_rate');
        } else {
            risk_factor["form_3" + object_id].disableItem('mean_reversion_rate');
            risk_factor["form_3" + object_id].setItemValue('mean_reversion_rate', '');
        }
        
        if (risk_factor["form_3" + object_id].isItemChecked('use_value5', 13)) {
            risk_factor["form_3" + object_id].enableItem('mean_reversion_level');
        } else {
            risk_factor["form_3" + object_id].disableItem('mean_reversion_level');
            risk_factor["form_3" + object_id].setItemValue('mean_reversion_level', '');
        }
        //////
        risk_factor["form_3" + object_id].attachEvent("onChange", function(){
            if(risk_factor["form_3" + object_id].isItemChecked('apply_mean_reversion')){
                risk_factor["form_3" + object_id].enableItem('mean_reversion_type_f');
                risk_factor["form_3" + object_id].enableItem('mean_reversion_type_r');
                risk_factor["form_3" + object_id].enableItem('mean_reversion_type_v');
                risk_factor["form_3" + object_id].enableItem('mean_reversion_level');
                risk_factor["form_3" + object_id].enableItem('mean_reversion_rate');
                risk_factor["form_3" + object_id].enableItem('mean_reversion_type');
            } else {
                risk_factor["form_3" + object_id].disableItem('mean_reversion_type_f');
                risk_factor["form_3" + object_id].disableItem('mean_reversion_type_r');
                risk_factor["form_3" + object_id].disableItem('mean_reversion_type_v');
                risk_factor["form_3" + object_id].disableItem('mean_reversion_level');
                risk_factor["form_3" + object_id].disableItem('mean_reversion_rate');
                risk_factor["form_3" + object_id].disableItem('mean_reversion_type');
            }
            if (risk_factor["form_3" + object_id].isItemChecked('use_value4', 12)) {
                risk_factor["form_3" + object_id].enableItem('mean_reversion_rate');
            } else {
                risk_factor["form_3" + object_id].disableItem('mean_reversion_rate');
                risk_factor["form_3" + object_id].setItemValue('mean_reversion_rate', '');
            }
            
            if (risk_factor["form_3" + object_id].isItemChecked('use_value5', 13)) {
                risk_factor["form_3" + object_id].enableItem('mean_reversion_level');
            } else {
                risk_factor["form_3" + object_id].disableItem('mean_reversion_level');
                risk_factor["form_3" + object_id].setItemValue('mean_reversion_level', '');
            }
        });

        //Volatility tab
        var form_4 = '[{"type":"settings","position":"label-top"},';
        form_4 += '{"type": "block", "blockOffset": "'+ ui_settings+['block_offset'] +'","list": [';
            form_4 += '{"type":"combo","name":"vol_data_series","label":"Data Series", "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '","userdata":{"validation_message":"Invalid Selection"},"required":true,"options": '+JSON.stringify(cmb_vol_data_series)+'},';
            form_4 += '{"type":"newcolumn"},';
            form_4 += '{"type":"input","name":"vol_data_points","label":"Data Points","value":"' + vol_data_points + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '","required":true, "validate":"NotEmpty,ValidNumeric", "userdata":{"validation_message":"Invalid Number"}},';
            form_4 += '{"type":"newcolumn"},';
            form_4 += '{"type":"combo","name":"volatility_method","label":"Approach", "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '","userdata":{"validation_message":"Invalid Selection"},"required":true,"options": '+JSON.stringify(cmb_approach)+'},';
           
        // form_4 += ']},';
        // form_4 += '{type: "block", blockOffset: 10, name:"volatility_fieldset", label:"", inputWidth:"auto","width":"750",list: [';
            form_4 += '{"type":"newcolumn"},';
            form_4 += '{"type":"numeric","name":"vol_long_run_volatility","label":"Long Run Volatility","value":"' + vol_long_run_volatility + '", "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '", "hidden": true},';
            form_4 += '{"type":"numeric","name":"lambda","label":"Decay Factor","value":"' + lambda + '", "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '", "hidden": true},';

            form_4 += '{"type":"newcolumn"},';
            form_4 += '{"type":"numeric","name":"vol_alpha","label":"Alpha","value":"' + vol_alpha + '","position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '", "hidden": true},';
            form_4 += '{"type":"newcolumn"},';
            form_4 += '{"type":"numeric","name":"vol_beta","label":"Beta","value":"' + vol_beta + '", "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '", "hidden": true},';
            form_4 += '{"type":"newcolumn"},';
            form_4 += '{"type":"numeric","name":"vol_gamma","label":"Gamma","value":"' + vol_gamma + '", "position":"label-top","offsetLeft":"'+ ui_settings['offset_left'] +'","labelWidth":"auto","inputWidth":"'+ ui_settings["field_size"] + '", "hidden": true},';
             form_4 += '{"type":"newcolumn"},';
            form_4 += '{"type":"checkbox","name":"relative_volatility","label":"Use Relative Data Points","value":"e","position":"label-right","offsetLeft":"'+ ui_settings['offset_left'] +'","offsetTop":"'+ ui_settings["checkbox_offset_top"] +'","labelWidth":"'+ ui_settings["field_size"] + '", "checked":"' + relative_volatility + '"}';
            // form_4 += '{"type":"newcolumn"},';
        form_4 += ']}]';
        
        risk_factor["form_4" + object_id] = risk_factor["risk_factor_tabs_" + object_id].tabs(tab_id[1]).attachForm();
        risk_factor["form_4" + object_id].loadStruct(get_form_json_locale($.parseJSON(form_4)));
        //risk_factor["form_4" + object_id].loadStruct(form_4);
        
        var cmb_vol_data_series_obj = risk_factor["form_4" + object_id].getCombo('vol_data_series');
        var data_series_index = cmb_vol_data_series_obj.getIndexByValue(vol_data_series);
        cmb_vol_data_series_obj.selectOption(data_series_index);
        //load Geometric as default
        if (vol_data_series  == '') {
            setTimeout(function() {
                cmb_vol_data_series_obj.selectOption(3);
            }, 100);    
        }
        //

        var cmb_volatility_method_obj = risk_factor["form_4" + object_id].getCombo('volatility_method');
        var volatility_method_index = cmb_volatility_method_obj.getIndexByValue(volatility_method);
        cmb_volatility_method_obj.selectOption(volatility_method_index);
        
        switch(volatility_method) {
            case 'e':
                //Equally Weighted
                risk_factor["form_4" + object_id].hideItem('vol_long_run_volatility');
                risk_factor["form_4" + object_id].hideItem('vol_alpha');
                risk_factor["form_4" + object_id].hideItem('vol_beta');
                risk_factor["form_4" + object_id].hideItem('vol_gamma');
                risk_factor["form_4" + object_id].hideItem('lambda');

                //set required false
                risk_factor["form_4" + object_id].setRequired("vol_long_run_volatility", false);
                risk_factor["form_4" + object_id].setRequired("vol_alpha", false);
                risk_factor["form_4" + object_id].setRequired("vol_beta", false);
                risk_factor["form_4" + object_id].setRequired("vol_gamma", false);
                risk_factor["form_4" + object_id].setRequired("lambda", false);
            break;
            case 'x':
                //Exponentially Weighted
                risk_factor["form_4" + object_id].showItem('lambda');
                //validation
                risk_factor["form_4" + object_id].setRequired("lambda", true);

                risk_factor["form_4" + object_id].setValidation('lambda', "ValidNumeric");
                risk_factor["form_4" + object_id].setUserData('lambda','validation_message','Invalid Number');
                //
                risk_factor["form_4" + object_id].hideItem('vol_long_run_volatility');
                risk_factor["form_4" + object_id].hideItem('vol_alpha');
                risk_factor["form_4" + object_id].hideItem('vol_beta');
                risk_factor["form_4" + object_id].hideItem('vol_gamma');

                //set required false
                risk_factor["form_4" + object_id].setRequired("vol_long_run_volatility", false);
                risk_factor["form_4" + object_id].setRequired("vol_alpha", false);
                risk_factor["form_4" + object_id].setRequired("vol_beta", false);
                risk_factor["form_4" + object_id].setRequired("vol_gamma", false);
            break;
            case 'g':
                //Garch
                risk_factor["form_4" + object_id].showItem('vol_long_run_volatility');
                //validation
                risk_factor["form_4" + object_id].setRequired("vol_long_run_volatility", true);
                risk_factor["form_4" + object_id].setValidation('vol_long_run_volatility', "ValidNumeric");
                risk_factor["form_4" + object_id].setUserData('vol_long_run_volatility','validation_message','Invalid Number');
                //
                risk_factor["form_4" + object_id].showItem('vol_alpha');
                //validation
                risk_factor["form_4" + object_id].setRequired("vol_alpha", true);
                risk_factor["form_4" + object_id].setValidation('vol_alpha', "ValidNumeric");
                risk_factor["form_4" + object_id].setUserData('vol_alpha','validation_message','Invalid Number');
                //
                risk_factor["form_4" + object_id].showItem('vol_beta');
                //validation
                risk_factor["form_4" + object_id].setRequired("vol_beta", true);
                risk_factor["form_4" + object_id].setValidation('vol_beta', "ValidNumeric");
                risk_factor["form_4" + object_id].setUserData('vol_beta','validation_message','Invalid Number');
                //
                risk_factor["form_4" + object_id].showItem('vol_gamma');
                //validation
                risk_factor["form_4" + object_id].setRequired("vol_gamma", true);
                risk_factor["form_4" + object_id].setValidation('vol_gamma', "ValidNumeric");
                risk_factor["form_4" + object_id].setUserData('vol_gamma','validation_message','Invalid Number');
                //
                risk_factor["form_4" + object_id].hideItem('lambda');
                //validation
                risk_factor["form_4" + object_id].setRequired("lambda", false);
            break;
            default:
                risk_factor["form_4" + object_id].hideItem('vol_long_run_volatility');
                risk_factor["form_4" + object_id].hideItem('vol_alpha');
                risk_factor["form_4" + object_id].hideItem('vol_beta');
                risk_factor["form_4" + object_id].hideItem('vol_gamma');
                risk_factor["form_4" + object_id].hideItem('lambda');

                //validation
                risk_factor["form_4" + object_id].setRequired("vol_long_run_volatility", false);
                risk_factor["form_4" + object_id].setRequired("vol_alpha", false);
                risk_factor["form_4" + object_id].setRequired("vol_beta", false);
                risk_factor["form_4" + object_id].setRequired("vol_gamma", false);
                risk_factor["form_4" + object_id].setRequired("lambda", false);
            break;
        }

        var approach_obj = risk_factor["form_4" + object_id].getCombo('volatility_method');
        approach_obj.enableFilteringMode(true);
        approach_obj.attachEvent("onChange", function(){
            var approach_val = approach_obj.getSelectedValue('volatility_method');

            switch(approach_val) {
                case 'e':
                    //Equally Weighted
                    risk_factor["form_4" + object_id].hideItem('vol_long_run_volatility');
                    risk_factor["form_4" + object_id].hideItem('vol_alpha');
                    risk_factor["form_4" + object_id].hideItem('vol_beta');
                    risk_factor["form_4" + object_id].hideItem('vol_gamma');
                    risk_factor["form_4" + object_id].hideItem('lambda');

                    //
                    risk_factor["form_4" + object_id].setItemValue('vol_long_run_volatility', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_alpha', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_beta', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_gamma', '');
                    risk_factor["form_4" + object_id].setItemValue('lambda', '');

                    //set required false
                    risk_factor["form_4" + object_id].setRequired("vol_long_run_volatility", false);
                    risk_factor["form_4" + object_id].setRequired("vol_alpha", false);
                    risk_factor["form_4" + object_id].setRequired("vol_beta", false);
                    risk_factor["form_4" + object_id].setRequired("vol_gamma", false);
                    risk_factor["form_4" + object_id].setRequired("lambda", false);
                break;
                case 'x':
                    //Exponentially Weighted
                    risk_factor["form_4" + object_id].showItem('lambda');
                    //validation
                    risk_factor["form_4" + object_id].setRequired("lambda", true);
                    risk_factor["form_4" + object_id].setValidation('lambda', "ValidNumeric");
                    risk_factor["form_4" + object_id].setUserData('lambda','validation_message','Invalid Number');
                    risk_factor["form_4" + object_id].setItemValue('lambda', '');
                    //
                    risk_factor["form_4" + object_id].hideItem('vol_long_run_volatility');
                    risk_factor["form_4" + object_id].hideItem('vol_alpha');
                    risk_factor["form_4" + object_id].hideItem('vol_beta');
                    risk_factor["form_4" + object_id].hideItem('vol_gamma');

                    //
                    risk_factor["form_4" + object_id].setItemValue('vol_long_run_volatility', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_alpha', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_beta', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_gamma', '');

                    //set required false
                    risk_factor["form_4" + object_id].setRequired("vol_long_run_volatility", false);
                    risk_factor["form_4" + object_id].setRequired("vol_alpha", false);
                    risk_factor["form_4" + object_id].setRequired("vol_beta", false);
                    risk_factor["form_4" + object_id].setRequired("vol_gamma", false);
                break;
                case 'g':
                    //Garch
                    risk_factor["form_4" + object_id].showItem('vol_long_run_volatility');
                    //validation
                    risk_factor["form_4" + object_id].setRequired("vol_long_run_volatility", true);
                    risk_factor["form_4" + object_id].setValidation('vol_long_run_volatility', "ValidNumeric");
                    risk_factor["form_4" + object_id].setUserData('vol_long_run_volatility','validation_message','Invalid Number');
                    //
                    risk_factor["form_4" + object_id].showItem('vol_alpha');
                    //validation
                    risk_factor["form_4" + object_id].setRequired("vol_alpha", true);
                    risk_factor["form_4" + object_id].setValidation('vol_alpha', "ValidNumeric");
                    risk_factor["form_4" + object_id].setUserData('vol_alpha','validation_message','Invalid Number');
                    //
                    risk_factor["form_4" + object_id].showItem('vol_beta');
                    //validation
                    risk_factor["form_4" + object_id].setRequired("vol_beta", true);
                    risk_factor["form_4" + object_id].setValidation('vol_beta', "ValidNumeric");
                    risk_factor["form_4" + object_id].setUserData('vol_beta','validation_message','Invalid Number');
                    //
                    risk_factor["form_4" + object_id].showItem('vol_gamma');
                    //validation
                    risk_factor["form_4" + object_id].setRequired("vol_gamma", true);
                    risk_factor["form_4" + object_id].setValidation('vol_gamma', "ValidNumeric");
                    risk_factor["form_4" + object_id].setUserData('vol_gamma','validation_message','Invalid Number');
                    //
                    risk_factor["form_4" + object_id].hideItem('lambda');

                    //
                    risk_factor["form_4" + object_id].setItemValue('lambda', '');
                    //set required false
                    risk_factor["form_4" + object_id].setRequired("lambda", false);
                break;
                default:
                    risk_factor["form_4" + object_id].hideItem('vol_long_run_volatility');
                    risk_factor["form_4" + object_id].hideItem('vol_alpha');
                    risk_factor["form_4" + object_id].hideItem('vol_beta');
                    risk_factor["form_4" + object_id].hideItem('vol_gamma');
                    risk_factor["form_4" + object_id].hideItem('lambda');

                    //
                    risk_factor["form_4" + object_id].setItemValue('vol_long_run_volatility', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_alpha', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_beta', '');
                    risk_factor["form_4" + object_id].setItemValue('vol_gamma');
                    risk_factor["form_4" + object_id].setItemValue('lambda', '');

                    //set required false
                    risk_factor["form_4" + object_id].setRequired("vol_long_run_volatility", false);
                    risk_factor["form_4" + object_id].setRequired("vol_alpha", false);
                    risk_factor["form_4" + object_id].setRequired("vol_beta", false);
                    risk_factor["form_4" + object_id].setRequired("vol_gamma", false);
                    risk_factor["form_4" + object_id].setRequired("lambda", false);
                break;
            }
        });
    }
    /**
     *
     */
    risk_factor.curve_grid_toolbar_click = function(id) {
        var active_tab_id = risk_factor.tabbar.getActiveTab();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        
        var detail_tabs;
        var tab_id = [];
        risk_factor.tabbar.forEachTab(function(tab){
            if (tab.getId() == active_tab_id) {
                var att_lay_obj = tab.getAttachedObject();
                var att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                detail_tabs = att_tabbar_obj.getAllTabs();
                
                var i = 0;
                att_tabbar_obj.forEachTab(function(tab){
                    tab_id[i] = tab.getId();
                    i++;
                });
            }
        });
        
        switch(id){
            case 'add':
                if(active_tab_id.indexOf("tab_") == -1){
                    dhtmlx.alert({
                        title:"Alert",
                        type:"alert",
                        text:"Please save <b>Risk Factor Model</b> first."
                    });
                    return false;
                }
                param = 'curve.grid.php?parameter_id=' + object_id + '&is_pop=true';

                var is_win = dhxWins.isWindow('w3');
                if (is_win == true) {
                    w3.close();
                }
                w3 = dhxWins.createWindow("w3", 320, 0, 710, 430);
                w3.setText("Maintain Risk Factor Model - Add Curve");
                w3.setModal(true);
                w3.attachURL(param, false, true);

                w3.attachEvent("onClose", function(win) {
                    return true;
                });
            break;
            case 'remove':
                var curve_ids = '';
                var selected_row_id = '';
                var selected_row_array = '';

                var att_tabbar_obj;
                risk_factor.tabbar.forEachTab(function(tab){
                    if (tab.getId() == active_tab_id) {
                        var att_lay_obj = tab.getAttachedObject();
                        att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                    }
                });
                
                $.each(detail_tabs, function(index,value) {
                    layout_obj = att_tabbar_obj.cells(value).getAttachedObject();
                    
                    if (layout_obj instanceof dhtmlXGridObject) {
                        selected_row_id = layout_obj.getSelectedRowId();
                        selected_row_array = selected_row_id.split(',');
                        for(var i = 0; i < selected_row_array.length; i++) {
                           if (i == 0) {
                                curve_ids = layout_obj.cells(selected_row_array[i], 0).getValue();
                            } else {
                                curve_ids = curve_ids + ',' + layout_obj.cells(selected_row_array[i], 0).getValue();
                            }
                        }
                        data = {"action": "spa_risk_factor_model",
                                "flag": "r",
                                "curve_ids": curve_ids,
                                "monte_carlo_model_parameter_id": object_id
                            };
                        adiha_post_data('confirm', data, '', '', 'risk_factor.curve_grid_refresh');
                    }
                });
                
            break;
            case 'pdf':
                var att_tabbar_obj;
                risk_factor.tabbar.forEachTab(function(tab){
                    if (tab.getId() == active_tab_id) {
                        var att_lay_obj = tab.getAttachedObject();
                        att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                    }
                });
                
                $.each(detail_tabs, function(index,value) {
                    layout_obj = att_tabbar_obj.cells(value).getAttachedObject();
                    
                    if (layout_obj instanceof dhtmlXGridObject) {
                        layout_obj.toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    }
                });
            break;
            case 'excel':
                var att_tabbar_obj;
                risk_factor.tabbar.forEachTab(function(tab){
                    if (tab.getId() == active_tab_id) {
                        var att_lay_obj = tab.getAttachedObject();
                        att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                    }
                });
                
                $.each(detail_tabs, function(index,value) {
                    layout_obj = att_tabbar_obj.cells(value).getAttachedObject();
                    
                    if (layout_obj instanceof dhtmlXGridObject) {
                        layout_obj.toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    }
                });
            break;
            default:
                 dhtmlx.alert({title: "Information!", type: "alert-error", text: "Not implemented"});
            break;
        }
    }
    /**
     *
     */
    risk_factor.save_form = function(){
        var active_tab_id = risk_factor.tabbar.getActiveTab();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var form_status = true;
        var first_err_tab;
        var detail_tabs;
        var tab_id = [];
         var tabsCount;
        var att_tabbar_obj;
        risk_factor.tabbar.forEachTab(function(tab){
            if (tab.getId() == active_tab_id) {
                var att_lay_obj = tab.getAttachedObject();
                att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                detail_tabs = att_tabbar_obj.getAllTabs();
                tabsCount = att_tabbar_obj.getNumberOfTabs();
            }
        });
        var form_xml = '<Root function_id="' + function_id + '"><FormXML';
        var valid_flag = true;
        var validation_status = true;
        var flag = '';
        $.each(detail_tabs, function(index,value) {
            layout_obj = att_tabbar_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                
                if (attached_obj instanceof dhtmlXForm) {
                    data = attached_obj.getFormData();
                    for (var a in data) {
                        field_label = a;
                        field_value = data[a];    
                        
                        flag = (active_tab_id.indexOf("tab_") == 0) ? 'u': 'i';
                        
                        if ((active_tab_id.indexOf("tab_") == -1) && (field_label == 'monte_carlo_model_parameter_id')) {
                            field_value = '';
                        }

                        if (field_label == 'use_value1') {
                            field_label =  'volatility';
                            switch(field_value) {
                                case '1':
                                    field_value = '';
                                    if(field_value == '') {
                                        attached_obj.setRequired("volatility", true);
                                        validation_status = attached_obj.validateItem('volatility');
                                        attached_obj.setValidation('volatility', "ValidNumeric");
                                        attached_obj.setUserData('volatility','validation_message','Invalid Number');
                                    }
                                break;
                                case '2':
                                    field_value = attached_obj.getItemValue('volatility_date', true);
                                    if(field_value == '') {
                                        attached_obj.setRequired("volatility_date", true);
                                        attached_obj.setValidation('volatility_date', "NotEmpty");
                                        attached_obj.setUserData('volatility_date','validation_message','Invalid Date');
                                        validation_status = attached_obj.validateItem('volatility_date');
                                    }
                                break;
                                case 'e':
                                    field_value = 'e';
                                break;
                                default:
                                case 'c':
                                    field_value = 'c';
                                break;
                            }
                        }
                        
                        if (field_label == 'use_value2') {
                            field_label =  'drift';
                            switch(field_value) {
                                case '5':
                                    field_value = '';
                                    if(field_value == '') {
                                        attached_obj.setRequired("drift", true);
                                        attached_obj.setValidation('drift', "ValidNumeric");
                                        attached_obj.setUserData('drift','validation_message','Invalid Number');
                                        validation_status = attached_obj.validateItem('drift');
                                    }
                                break;
                                case '6':
                                    field_value = attached_obj.getItemValue('drift_date', true);
                                    if(field_value == '') {
                                        attached_obj.setRequired("drift_date", true);
                                        attached_obj.setValidation('drift_date', "NotEmpty");
                                        attached_obj.setUserData('drift_date','validation_message','Invalid Date');
                                        validation_status = attached_obj.validateItem('drift_date');
                                    }
                                break;
                                case 'e':
                                    field_value = 'e';
                                break;
                                case 'c':
                                    field_value = 'c';
                                break;
                            }
                        }
                        
                        if (field_label == 'use_value3') {
                            field_label =  'seed';
                            switch(field_value) {
                                case '9':
                                    field_value = '';
                                    if(field_value == '') {
                                        attached_obj.setRequired("seed", true);
                                        attached_obj.setValidation('seed', "ValidNumeric");
                                        attached_obj.setUserData('seed','validation_message','Invalid Number');
                                        validation_status = attached_obj.validateItem('seed');
                                    }
                                break;
                                case '15':
                                    field_value = attached_obj.getItemValue('seed_date', true);
                                    if(field_value == '') {
                                        attached_obj.setRequired("seed_date", true);
                                        attached_obj.setValidation('seed_date', "NotEmpty");
                                        attached_obj.setUserData('seed_date','validation_message','Invalid Date');
                                        validation_status = attached_obj.validateItem('seed_date');
                                    }
                                break;
                                case 'e':
                                    field_value = 'e';
                                break;
                            }
                        }
                        //mean reversion level
                        if (field_label == 'use_value5') {
                            field_label =  'mean_reversion_level';
                            switch(field_value) {
                                case '13':
                                    field_value = '';
                                    if((attached_obj.isItemChecked('apply_mean_reversion')) && (field_value == '')) {
                                        attached_obj.setRequired("mean_reversion_level", true);
                                        attached_obj.setValidation('mean_reversion_level', "ValidNumeric");
                                        attached_obj.setUserData('mean_reversion_level','validation_message','Invalid Number');
                                        validation_status = attached_obj.validateItem('mean_reversion_level');
                                    }
                                break;
                                default:
                                    attached_obj.getItemValue('use_value5');
                                break;
                            }
                        }
                        //mean reversion value
                        if (field_label == 'use_value4') {
                            field_label =  'mean_reversion_rate';
                            switch(field_value) {
                                case '12':
                                    field_value = '';
                                    if((attached_obj.isItemChecked('apply_mean_reversion')) && (field_value == '')) {
                                        attached_obj.setRequired("mean_reversion_rate", true);
                                        attached_obj.setValidation('mean_reversion_rate', "ValidNumeric");
                                        attached_obj.setUserData('mean_reversion_rate','validation_message','Invalid Number');
                                        validation_status = attached_obj.validateItem('mean_reversion_rate');
                                    }
                                break;
                                default:
                                    attached_obj.getItemValue('use_value4');
                                break;
                            }
                        }

                        if (field_label != 'use_value1' && field_label != 'use_value2' && field_label != 'use_value3' && field_label != 'use_value4' && field_label != 'use_value5' && field_label != 'volatility_date' && field_label != 'drift_date' && field_label != 'seed_date') {
                            if (field_value != '') {
                                form_xml += " " + field_label + "=\"" + field_value + "\"";    
                            }
                        }

                        if (field_label == 'monte_carlo_model_parameter_name') {
                            risk_factor.grid.setUserData("", "monte_carlo_model_parameter_name", data[a]);
                        }
                    }
                }
            });
            //tab 2 form
            

            data = risk_factor["form_4" + object_id].getFormData();
            for (var a in data) { 
                field_label = a;
                field_value = data[a];
                form_xml += " " + field_label + "=\"" + field_value + "\"";
            }
            form_xml += "></FormXML></Root>"; 
          

            var check_array_size = detail_tabs.toString().indexOf(",");
            if(check_array_size != -1){
                var arr = detail_tabs.toString().split(",");
            } else {
                arr [0] = detail_tabs;
            }
            
            var status1 = validate_form(risk_factor["form_1" + object_id]);
            
            var status2 = validate_form(risk_factor["form_2" + object_id]);
           
            var status3 = validate_form(risk_factor["form_3" + object_id]);
            

            var status4 = validate_form(risk_factor["form_4" + object_id]);


            if (status1 == false || status2 == false || status3 == false && (!first_err_tab)) {
                 first_err_tab = risk_factor["risk_factor_tabs_" + object_id].tabs(arr[0]);
                 validation_status = false;
               /* display_erro_message();
                risk_factor["risk_factor_tabs_" + object_id].tabs(arr[0]).setActive();*/
            } else if (status4 == false && (!first_err_tab)) {
                first_err_tab = risk_factor["risk_factor_tabs_" + object_id].tabs(arr[1]);
                validation_status = false;
                /*display_erro_message();
                risk_factor["risk_factor_tabs_" + object_id].tabs(arr[1]).setActive();*/
            }
           /* if (status1 == false || status2 == false || status3 == false || status4 == false) {
                validation_status = false;
                return;
            }*/
            
            if(validation_status){ 
                risk_factor.tabbar.cells(risk_factor.tabbar.getActiveTab()).getAttachedToolbar().disableItem('save');
                data = {"action": "spa_risk_factor_model",
                        "flag": flag,
                        "xml": form_xml
                };
                adiha_post_data("alert", data, "", "", "risk_factor.post_callback");
            }

            if(!validation_status) {
                generate_error_message(first_err_tab);
                return;
            }
        });
    }
    /**
     *
     */
    risk_factor.post_callback = function(result) {
        var active_tab_id = risk_factor.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var risk_factor_name = risk_factor.grid.getUserData("", "monte_carlo_model_parameter_name");
        if (has_rights_monte_carlo_iu) {
            risk_factor.tabbar.cells(active_tab_id).getAttachedToolbar().enableItem('save');
        };

        if (result[0].errorcode == 'Success') {
            if(result[0].recommendation == ''){
                risk_factor.refresh_grid("", risk_factor.refresh_tab_properties);
            } else {
                tab_id = 'tab_' + result[0].recommendation;
                risk_factor.refresh_grid("", refresh_grid_callback);
                risk_factor.create_tab_custom(tab_id, risk_factor_name);
                risk_factor.tabbar.tabs(active_tab_id).close(true);
            }
        }
        risk_factor.refresh_grid();
        risk_factor.menu.setItemDisabled("delete"); 
    }
    /**
     *
     */
    function refresh_grid_callback() {
        var col_type = risk_factor.grid.getColType(0);
        var prev_id = risk_factor.tabbar.getActiveTab();
        var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;
        if (col_type == "tree") {
            risk_factor.grid.loadOpenStates();
            var primary_value = risk_factor.grid.findCell(system_id, 1, true, true);
        } else {
            var primary_value = risk_factor.grid.findCell(system_id, 0, true, true);
        }
        risk_factor.grid.filterByAll(); 
        if (primary_value != "") {
            var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
            var tab_text = risk_factor.get_text(risk_factor.grid, r_id);
            risk_factor.tabbar.tabs(prev_id).setText(tab_text);
            risk_factor.grid.selectRowById(r_id,false,true,true);
        }
    }
    /**
     *
     */
    risk_factor.create_tab_custom = function(full_id,text) {
        risk_factor.refresh_grid();
        
        if (!risk_factor.pages[full_id]) {
            risk_factor.tabbar.addTab(full_id, text, null, null, true, true);
            var win = risk_factor.tabbar.cells(full_id);
            win.progressOn();
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath("<?php echo $app_php_script_loc;?>components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxtoolbar_web/");
            toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
            toolbar.attachEvent("onClick", function(){
                risk_factor.save_form();
            });
            risk_factor.tabbar.cells(full_id).setActive();
            risk_factor.tabbar.cells(full_id).setText(text);
            risk_factor.load_form(win, full_id);
            risk_factor.pages[full_id] = win;
        }
        else {
            risk_factor.tabbar.cells(full_id).setText(text);
            risk_factor.tabbar.cells(full_id).setActive();
        }
    };
    /**
     *
     */
    risk_factor.delete_risk_factor = function() {
        var selectedId = risk_factor.grid.getSelectedRowId();
        var count = selectedId.indexOf(",") > -1 ? selectedId.split(",").length : 1;
        selectedId = selectedId.indexOf(",") > -1 ? selectedId.split(",") : [selectedId];

        var object_id = '';
        for (var i = 0; i < count; i++) {
            object_id += risk_factor.grid.cells(selectedId[i], 0).getValue() + ',';
        }
        object_id = object_id.slice(0, -1);

        if(!object_id) {
            return;
        }

        dhtmlx.message({
            title:"Confirmation",
            type:"confirm",
            ok: "Confirm",
            text: 'Are you sure you want to delete?',
            callback: function(result) {
                if (result) {
                    data = {"action": "spa_risk_factor_model",
                            "flag": "d",
                            "del_monte_carlo_model_parameter_id": object_id
                    };
                    adiha_post_data("alert", data, "", "", "risk_factor.delete_callback");
                } else {
                    return;
                }
            }
        });
    }
    /**
     *
     */
    risk_factor.delete_callback = function(result) {   
        if(result[0].errorcode == 'Success') {
            risk_factor.refresh_grid();
        }
        risk_factor.menu.setItemDisabled("delete");
        
        if (result[0].errorcode == 'Success') {
            if (result[0].recommendation.indexOf(",") > -1) {
                var ids = result[0].recommendation.split(",");
                var count_ids = ids.length;
                for (var i = 0; i < count_ids; i++ ) {
                    full_id = 'tab_' + ids[i];
                    if (risk_factor.pages[full_id]) {
                        risk_factor.tabbar.cells(full_id).close();
        }
    }
            } else {
                full_id = 'tab_' + result[0].recommendation;
                if (risk_factor.pages[full_id]) {
                    risk_factor.tabbar.cells(full_id).close();
                }
            }
        }
    }
    /**
     * [refreshes curve mapping grid]
     */
    risk_factor.curve_grid_refresh = function(result) {
        var active_tab_id = risk_factor.tabbar.getActiveTab();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        var is_win = dhxWins.isWindow('w3');
        if (is_win == true) {
            setTimeout(function(){
                w3.close();
            }, 2000);
        }

        var att_tabbar_obj;
        var detail_tabs;
        var tab_id = [];
        risk_factor.tabbar.forEachTab(function(tab){
            if (tab.getId() == active_tab_id) {
                var att_lay_obj = tab.getAttachedObject();
                att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                detail_tabs = att_tabbar_obj.getAllTabs();

                var i = 0;
                att_tabbar_obj.forEachTab(function(tab){
                    tab_id[i] = tab.getId();
                    i++;
                });
            }
        });
        
        if (result[0].errorcode == 'Success') {
            $.each(detail_tabs, function(index,value) {
                layout_obj = att_tabbar_obj.cells(tab_id[2]).getAttachedObject();
                
                if (layout_obj instanceof dhtmlXGridObject) {
                    var param = {
                        "action": "spa_monte_carlo_model",
                        "flag": "x",
                        "monte_carlo_model_parameter_id":object_id,
                        "grid_type": "g"
                    };
                    
                    param = $.param(param);
                    var param_url = js_data_collector_url + "&" + param;
                    
                    layout_obj.clearAll();
                    layout_obj.loadXML(param_url);
                    risk_factor["toolbar_grid_" + object_id].setItemDisabled('remove');
                }
            });
        }
    }
    
    /**
     *
     */
    risk_factor.refresh_tab_properties = function() {
        var prev_id = risk_factor.tabbar.getActiveTab();
        var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;
        var primary_value = risk_factor.grid.findCell(system_id, 0, true, true);

        if (primary_value != "") {
            var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
            var tab_text = risk_factor.get_text(risk_factor.grid, r_id);
            risk_factor.tabbar.tabs(prev_id).setText(tab_text);
            risk_factor.grid.selectRowById(r_id,false,true,true);
        } 
        var win = risk_factor.tabbar.cells(prev_id);
        var tab_obj = win.tabbar[system_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    attached_obj.clearSelection();
                    var grid_obj = attached_obj.getUserData("","grid_obj");
                    eval(grid_obj + ".refresh_grid()");
                }
            });
        });
    }
</script>
</html>