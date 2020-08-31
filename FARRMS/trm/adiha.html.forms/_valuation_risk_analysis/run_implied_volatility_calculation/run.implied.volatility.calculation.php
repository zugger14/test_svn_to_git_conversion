<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
     <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
<?php
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

    $rights_run_volatility_calucalation = 10181800;
    list (
       $has_right_run_volatility_calucalation
    ) = build_security_rights (
       $rights_run_volatility_calucalation
    );

    $namespace = 'run_volatility_calucalation';
    $form_name = 'run_volatility_calucalation_form';

    $json = '[
                {
                    id:             "a",
                    text:           "Criteria",
                    header:         false,
                    collapse:       false,
                    height:         100
                },{
                    id:             "b",
                    text:           "Grid",
                    header:         false,
                    collapse:       false
                }
            ]';
    $toolbar_json = '[{ id: "Run", type: "button", img: "run.gif", imgdis:"run_dis.gif", text:"Run", title: "Run"}]';
    
    $volatility_calc_layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    echo $volatility_calc_layout_obj->init_layout('volatility_calc_layout', '', '2E', $json, $namespace);
    echo $volatility_calc_layout_obj->attach_toolbar_cell('toolbar', 'a');//attach_toolbar("toolbar");  
    echo $toolbar_obj->init_by_attach("toolbar", $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'run_button_click');
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10181800', @template_name='ImpliedVolatilityCalculation', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    echo $volatility_calc_layout_obj->attach_form($form_name, 'a');
    $volatility_calc_form_obj = new AdihaForm();
    echo $volatility_calc_form_obj->init_by_attach($form_name, $namespace);
    echo $volatility_calc_form_obj->load_form($form_json);
    
    $menu_name = 'grid_menu';
    $menu_json = '[
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                        {id:"t", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                            {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif"},
                            {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif",disabled:true},
							{id:"csv", text:"Load Data from CSV", img:"add.gif", imgdis:"add_dis.gif"}

                        ]},
                        {id:"export", img:"export.gif", text:"Export", items:[
                            {id:"excel", text:"Excel", img:"excel.gif"},
                            {id:"pdf", text:"PDF", img:"pdf.gif"}
                        ]},
                        //{id: "run", img: "process.gif", imgdis:"process_dis.gif", text: "Run", title: "Run"},
                        {id: "select_unselect", img: "select_unselect.gif", imgdis:"select_unselect_dis.gif", text: "Select/Unselect All", title: "Select/Unselect All"}
                     ]';

    echo $volatility_calc_layout_obj->attach_menu_layout_cell($menu_name, 'b', $menu_json, $namespace.'.menu_click');
    
    //attach grid
    $grid_name = 'ImpliedVolatilityCalculation';
    echo $volatility_calc_layout_obj->attach_grid_cell($grid_name, 'b');
    $grid_obj = new GridTable($grid_name);
    echo $volatility_calc_layout_obj->attach_status_bar("b", true);
    echo $grid_obj->init_grid_table($grid_name, $namespace, 'n');
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_data('', '', '', '');
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->enable_paging(25, 'pagingArea_b', 'true');
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace.'.grid_select');
    echo $grid_obj->attach_event('', 'onCellChanged', $namespace.'.grid_cell_change'); // Disabled for populating data from csv file.
    
    echo $volatility_calc_layout_obj->close_layout();
	
	$custom_rule_name = 'Implied Volatility Run Param';
	$get_custom_rule_id = "SELECT ixp_rules_id FROM ixp_rules where ixp_rules_name = '$custom_rule_name'";
	$custom_rule = readXMLURL2($get_custom_rule_id);
    $custom_rule_id = $custom_rule[0]['ixp_rules_id'] ?? '';
	
	
?>
</body>
    
<script>    
	
	var commodity_array = [];	
	data = {"action": "spa_source_commodity_maintain","flag": 'c'}
	result = adiha_post_data('return_json', data, "", "", "get_commodity_array");	
	
    $(function(){
        var has_right_run_volatility_calucalation = Boolean('<?php echo $has_right_run_volatility_calucalation; ?>');

        if (has_right_run_volatility_calucalation == false){
            run_volatility_calucalation.run_volatility_calucalation_form.disableItem('btn_run');
        } else {
            run_volatility_calucalation.run_volatility_calucalation_form.enableItem('btn_run');
        }

        refresh_grid();		 
    });

    function get_commodity_array(result) {
        commodity_array = JSON.parse(result);       
    }
    
    function get_commodity(commodity_name) {        
        var len = commodity_array.length;
        for (i = 0; i<len; i++){
            if (commodity_array[i].commodity_name == commodity_name) {
                return commodity_array[i].source_commodity_id;              
            }
        }       
    }    

    function run_button_click(args) {
        var status = validate_form(run_volatility_calucalation.run_volatility_calucalation_form);
        validate_rivc_grid();

        if (status) {
            attached_obj = run_volatility_calucalation.ImpliedVolatilityCalculation;
            var num_rows = attached_obj.getRowsNum();
            
            if (num_rows == 0) {
                var error_message = '<b>Criteria</b> Grid cannot be empty.';
                dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                return;
            } else {
                attached_obj.clearSelection(true);
                run_volatility_calucalation.grid_menu.setItemDisabled("delete");
                var status = run_volatility_calucalation.validate_form_grid(attached_obj, 'Criteria');
                
                if(status) {
                    var no_of_days = run_volatility_calucalation.run_volatility_calucalation_form.getItemValue('no_of_days');
                    var col_index_options = attached_obj.getColIndexById("options");
                    var col_index_idx = attached_obj.getColIndexById("index");
                    var col_index_exercise_type = attached_obj.getColIndexById("exercise_type");
                    var col_index_commodity = attached_obj.getColIndexById("commodity");
                    var col_index = attached_obj.getColIndexById("expiration");
                   
                    attached_obj.forEachRow(function(id){
                        var idx_options = attached_obj.cells(id, col_index_options).getValue();
                        var idx = attached_obj.cells(id, col_index_idx).getValue();
                        var idx_exercise_type = attached_obj.cells(id, col_index_exercise_type).getValue();
                        var idx_commodity = attached_obj.cells(id, col_index_commodity).getValue();

                        var is_options_opt = check_option_value(id, col_index_options, idx_options);
                        var is_inx_opt = check_option_value(id, col_index_idx, idx);
                        var is_exercise_type_opt = check_option_value(id, col_index_exercise_type, idx_exercise_type);
                        var is_commodity_otp = check_option_value(id, col_index_commodity, idx_commodity);

                        if(!is_options_opt) {
                            status = false;
                            var error_message = 'Data Error in <b>Criteria</b> grid. Please check the data in column <b>Options</b> and re-run.';
                            dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                            return;
                        } else if(!is_exercise_type_opt) {
                            status = false;
                            var error_message = 'Data Error in <b>Criteria</b> grid. Please check the data in column <b>Exercise Type</b> and re-run.';
                            dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                            return;
                        } else if(!is_commodity_otp) {
                            status = false;
                            var error_message = 'Data Error in <b>Criteria</b> grid. Please check the data in column <b>Commodity</b> and re-run.';
                            dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                            return;
                        } else if(!is_inx_opt) {
                            status = false;
                            var error_message = 'Data Error in <b>Criteria</b> grid. Please check the data in column <b>Index</b> and re-run.';
                            dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                            return;
                        } 

                        if(idx == '') {
                            status = false;
                            var error_message = 'Data Error in <b>Criteria</b> grid. Please check the data in column <b>Index</b> and re-run.';
                            dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                            return;
                        }
                    });

                    attached_obj.forEachRow(function(id){
                        var expiration = attached_obj.cells(id, col_index).getValue();
                        
                        if(expiration == '' && no_of_days == '') {
                            status = false;
                            var error_message = 'Please enter data in <b>No of Days</b> or <b>Expiration</b>.';
                            dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                            return;
                        }
                    });
                }
            }
        }
        
        if(status) {
            var risk_free_rate = run_volatility_calucalation.run_volatility_calucalation_form.getItemValue('risk_free_rate');
            var no_of_days = run_volatility_calucalation.run_volatility_calucalation_form.getItemValue('no_of_days');
            var curve_source = run_volatility_calucalation.run_volatility_calucalation_form.getItemValue('curve_source');
            var as_of_date = run_volatility_calucalation.run_volatility_calucalation_form.getItemValue('as_of_date', true);
            var grid_xml = '';
            
            var grid_xml = "<Root>";
            run_volatility_calucalation.ImpliedVolatilityCalculation.forEachRow(function(id) {
                grid_xml += "<PSRecordset ";
                for(var cellIndex = 0; cellIndex < run_volatility_calucalation.ImpliedVolatilityCalculation.getColumnsNum(); cellIndex++){
                    grid_xml += " " + run_volatility_calucalation.ImpliedVolatilityCalculation.getColumnId(cellIndex) + '="' + run_volatility_calucalation.ImpliedVolatilityCalculation.cells(id,cellIndex).getValue() + '"';
                }
                grid_xml += " ></PSRecordset> ";
            });
            grid_xml += "</Root>";         
            
            var param = 'call_from=run_implied_volatility_calculation&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
            var title = 'Run Implied Volatility Calculation';
            var exec_call = 'EXEC spa_curve_volatility_imp ' + singleQuote(grid_xml)+ ', ' +
                        		singleQuote(risk_free_rate) + ', ' + 
                        		singleQuote(as_of_date) + ', ' + 
                        		singleQuote(no_of_days) + ', ' + 
                        		singleQuote(curve_source) + ', 2';
    
            adiha_run_batch_process(exec_call, param, title);
        }
    }
        
	function current_date() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();

        dd = (dd < 10)?('0' + dd): dd
        mm = (mm < 10)?('0' + mm): mm

        var current_date = yyyy + '-' + mm + '-' + dd;
        return current_date;
    }

    function refresh_relation_grid(process_id,relation_alias) {
        //alert(process_id)
        run_volatility_calucalation.volatility_calc_layout.cells('b').progressOn()
        var param = {
                        'action': 'spa_import_source_list',
                        'flag': 'a',
                        'process_id': process_id,
                        'data_source_alias':relation_alias
                    }
                                            
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        // run_volatility_calucalation.ImpliedVolatilityCalculation.clearAll();
       
        run_volatility_calucalation.ImpliedVolatilityCalculation.clearAndLoad(param_url,function(){
            run_volatility_calucalation.volatility_calc_layout.cells('b').progressOff()
        });
        
    }

    function refresh_grid() {
        var grid_obj = run_volatility_calucalation.ImpliedVolatilityCalculation;
        grid_obj.clearAll();
        run_volatility_calucalation.grid_menu.setItemDisabled("delete");
        add_grid_row();
    }
    
    function add_grid_row() {
        var newId = (new Date()).valueOf();
        run_volatility_calucalation.ImpliedVolatilityCalculation.addRow(newId,"c,e,,,,,,,,");
        // run_volatility_calucalation.ImpliedVolatilityCalculation.selectRowById(newId);
        run_volatility_calucalation.grid_menu.setItemEnabled("delete");
    }

    function check_option_value(rId, cInd, cValue) {
        var combo_obj = run_volatility_calucalation.ImpliedVolatilityCalculation.getColumnCombo(cInd); 
        var opt_ind = combo_obj.getOption(cValue);

        if (opt_ind == null)
            return false;
        else
            return true;
    }

    function validate_rivc_grid() {
        run_volatility_calucalation.ImpliedVolatilityCalculation.forEachRow(function(row){
            run_volatility_calucalation.ImpliedVolatilityCalculation.forEachCell(row,function(cellObj,ind){
                run_volatility_calucalation.ImpliedVolatilityCalculation.validateCell(row,ind)
            });
        });
    }

	run_volatility_calucalation.open_run_wizard = function() {

		var ixp_name = '<?php echo $custom_rule_name; ?>'
		var ixp_id = '<?php echo $custom_rule_id; ?>'
		//	unload_run_window();
		if (!run_volatility_calucalation.run_window) {
			run_volatility_calucalation.run_window = new dhtmlXWindows();
		}
		run_volatility_calucalation.new_run_win = run_volatility_calucalation.run_window.createWindow('w2', 0, 0, 780, 320);

		var text = "Run Rule -" + ixp_name;

		run_volatility_calucalation.new_run_win.setText(text);
		//run_volatility_calucalation.new_run_win.maximize();
		run_volatility_calucalation.new_run_win.setModal(true);

		var url = '../../_setup/data_import_export/data.relations.php';
		url = url + '?rules_id=' + ixp_id + '&call_from=immediate_run&mode=r&from_custom_form=y';
		run_volatility_calucalation.new_run_win.attachURL(url, false, true);
	}	
    
    run_volatility_calucalation.menu_click = function(id) {
        switch(id) {
            case "add":
                add_grid_row();
                break;
            case "delete":
                var del_ids = run_volatility_calucalation.ImpliedVolatilityCalculation.getSelectedRowId();
                var previously_xml = run_volatility_calucalation.ImpliedVolatilityCalculation.getUserData("", "deleted_xml_events");
                var grid_xml = "";
                if (previously_xml != null) {
                    grid_xml += previously_xml
                }             
                var del_array = new Array();             
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                $.each(del_array, function(index, value) {
                    if((run_volatility_calucalation.ImpliedVolatilityCalculation.cells(value,0).getValue() != "") || (run_volatility_calucalation.ImpliedVolatilityCalculation.getUserData(value,"row_status") != "")){             			
                        grid_xml += "<GridRow ";                 		
                        for(var cellIndex = 0; cellIndex < run_volatility_calucalation.ImpliedVolatilityCalculation.getColumnsNum(); cellIndex++){
                            grid_xml += " " + run_volatility_calucalation.ImpliedVolatilityCalculation.getColumnId(cellIndex) + '="' + run_volatility_calucalation.ImpliedVolatilityCalculation.cells(value,cellIndex).getValue() + '"';                     	
                        }                 	
                        grid_xml += " ></GridRow> ";                 
                    }             
                });
                run_volatility_calucalation.ImpliedVolatilityCalculation.setUserData("", "deleted_xml_events", grid_xml);
                run_volatility_calucalation.ImpliedVolatilityCalculation.deleteSelectedRows();
                run_volatility_calucalation.grid_menu.setItemDisabled("delete");
                break;
			case "csv":
                run_volatility_calucalation.open_run_wizard()
				break;	
            case "excel":
                run_volatility_calucalation.ImpliedVolatilityCalculation.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                run_volatility_calucalation.ImpliedVolatilityCalculation.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "select_unselect":
                var grid_obj = run_volatility_calucalation.ImpliedVolatilityCalculation;
                var selected_id = grid_obj.getSelectedRowId();
                
                if (selected_id == null) {
                    var ids = grid_obj.getAllRowIds();
                    
                    for (var id in ids) {
                       grid_obj.selectRow(id, true, true, false);
                    }
                } else {
                    grid_obj.clearSelection(true);
                    run_volatility_calucalation.grid_menu.setItemDisabled("delete");
                }
                break;
            case "refresh":
                refresh_grid();
                break;
        }
    }
    
    run_volatility_calucalation.grid_select = function() {
        if (run_volatility_calucalation.ImpliedVolatilityCalculation.getSelectedRowId() == null) {
            run_volatility_calucalation.grid_menu.setItemDisabled("delete");
        } else {
            run_volatility_calucalation.grid_menu.setItemEnabled("delete");
        }
    }
    
    run_volatility_calucalation.grid_cell_change = function(rId,cInd,nValue) {
        if(cInd == 2) {
            var sql_stmt = "EXEC spa_source_price_curve_def_maintain @flag = l,  @source_system_id = 2"
            if(nValue != '' && nValue != '&nbsp;'&& nValue != null) {
				var commodity_id = get_commodity(nValue);
				if (commodity_id == undefined) {
					commodity_id = nValue;
				}
				
				sql_stmt += ", @commodity_id="+commodity_id;//nValue;
            }

            var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": sql_stmt,
                            "call_from": "grid"
                        };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            
            var combo_obj = run_volatility_calucalation.ImpliedVolatilityCalculation.cells(rId,3).getCellCombo(); 
            combo_obj.clearAll();      
            combo_obj.load(url);
            combo_obj.enableFilteringMode("between");
			
			combo_obj.attachEvent("onXLE", function() {
				var column_id = run_volatility_calucalation.ImpliedVolatilityCalculation.cells(rId,3).getValue();
				var is_exist = combo_obj.getIndexByValue(column_id);
				
				if (is_exist != -1)
					run_volatility_calucalation.ImpliedVolatilityCalculation.cells(rId,3).setValue(column_id);
				else
					run_volatility_calucalation.ImpliedVolatilityCalculation.cells(rId,3).setValue('');
			});
        }
    }
    
    run_volatility_calucalation.validate_form_grid = function(attached_obj,grid_label) {;
 		var status = true;
		for (var i = 0;i < attached_obj.getRowsNum();i++){
 			var row_id = attached_obj.getRowId(i);
 			for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
 				var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
 				if(validation_message != "" && validation_message != undefined){
 					var column_text = attached_obj.getColLabel(j);
					error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and re-run.";
					dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
 					status = false; break;
 				}
     	}
    		// if(validation_message != "" && validation_message != undefined){ break;};
     	}
        return status;
    }

    
 </script>