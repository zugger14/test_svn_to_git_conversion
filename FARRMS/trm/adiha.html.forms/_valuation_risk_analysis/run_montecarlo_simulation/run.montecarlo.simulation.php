<?php
/**
* Run montecarlo simulation screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>

<?php
    $form_name = 'form_run_montecarlo_simulation';
    $rights_run_montecarlo_simulation = 10183100;
    
    list($has_rights_run_montecarlo_simulation) = build_security_rights($rights_run_montecarlo_simulation);
    
    $layout_json = '[
                        {
                            id:             "a",
                            header:         false,
                            collapse:       false,
                            text:           "Run Price Simulation",
                            fix_size:       [false, null]
                        },
                        {
                            id:             "b",
                            header:         false,
                            collapse:       true,
                            text:           "Apply Filters",
                            fix_size:       [false, null]
                        },
                        {
                            id:             "c",
                            header:         true,
                            collapse:       false,
                            text:           "Run Criteria",
                            fix_size:       [false, null]
                        },
                        {
                            id:             "d",     
                            header:         true, 
                            text:           "<div style=\"margin-top:0px;\"><a id= \"undock\" class=\"undock_custom\" title=\"Undock\"  onClick=\" undock_window();\"></a>Risk Factor</div>"
                        }
                    ]';
    
    $name_space = 'run_montecarlo_simulation';
    $run_montecarlo_simulation_layout = new AdihaLayout();
    echo $run_montecarlo_simulation_layout->init_layout('run_montecarlo_simulation_layout', '', '4E', $layout_json, $name_space);
    
    $toolbar_montecarlo = 'montecarlo_toolbar_run';
    $toolbar_json = '[
                        {id:"run", img:"run.gif", imgdis:"run_dis.gif", text:"Run", title:"Run"}
                    ]';
    
    $toolbar_run_montecarlo_simulation = new AdihaMenu();
    echo $run_montecarlo_simulation_layout->attach_menu_cell($toolbar_montecarlo, "a"); 
    echo $toolbar_run_montecarlo_simulation->init_by_attach($toolbar_montecarlo, $name_space);
    echo $toolbar_run_montecarlo_simulation->load_menu($toolbar_json);
    echo $toolbar_run_montecarlo_simulation->attach_event('','onClick','btn_run_click');
    
    $form_object_c = new AdihaForm();
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10183100', @template_name='RunMonteCarloSimulation', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_structure_c = $return_value1[0][2];
      
    echo $run_montecarlo_simulation_layout->attach_form($form_name, 'c');    
    echo $form_object_c->init_by_attach($form_name, $name_space);
    echo $form_object_c->load_form($form_structure_c);
    
    $grid_name = 'grd_run_montecarlo_simulation';
    echo $run_montecarlo_simulation_layout->attach_grid_cell($grid_name, 'd');
    echo $run_montecarlo_simulation_layout->attach_status_bar('d', true, '');
    $grid_add_risk_factors = new AdihaGrid('run_montecarlo_simulation');    
    echo $grid_add_risk_factors->init_by_attach($grid_name, $name_space);
    echo $grid_add_risk_factors->set_widths('180,180,180,180,180,200,200,200');
    echo $grid_add_risk_factors->set_header('Source Price Curve ID,Curve Name,Curve ID,Description,Granularity,Curve Type,Risk Factor Model');
    echo $grid_add_risk_factors->set_columns_ids('source_curve_def_id,curve_name,curve_id,curve_des,code,code,monte_carlo_model_parameter_name');
    echo $grid_add_risk_factors->set_search_filter(false,'#numeric_filter,#text_filter,#text_filter,#text_filter,#combo_filter,#combo_filter,#combo_filter');  
    echo $grid_add_risk_factors->load_grid_functions();  
    echo $grid_add_risk_factors->set_column_types('ro_int,ro,ro,ro,ro,ro,ro,ro');
    echo $grid_add_risk_factors->set_sorting_preference('int,str,str,str,str,str,str,str');
    echo $grid_add_risk_factors->enable_multi_select();
    echo $grid_add_risk_factors->hide_column(0);
    echo $grid_add_risk_factors->enable_paging('10', 'pagingArea_d', true);
    echo $grid_add_risk_factors->load_grid_data("EXEC spa_run_monte_carlo_model @flag='s'");
    echo $grid_add_risk_factors->return_init();
    
    $toolbar_montecarlo_grid = 'montecarlo_toolbar';
    $toolbar_json = '[  
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif"},
                      ]';
    
    $toolbar_run_montecarlo_simulation_grid = new AdihaMenu();
    echo $run_montecarlo_simulation_layout->attach_menu_cell($toolbar_montecarlo_grid, "d"); 
    echo $toolbar_run_montecarlo_simulation_grid->init_by_attach($toolbar_montecarlo_grid, $name_space);
    echo $toolbar_run_montecarlo_simulation_grid->load_menu($toolbar_json);
    echo $toolbar_run_montecarlo_simulation_grid->attach_event('', 'onClick', 'btn_add_toolbar_click');
    echo $run_montecarlo_simulation_layout->close_layout();
?>
<script type="text/javascript">
    $(function() {
        var curve_ids;
        var function_id  = 10183100;
        var report_type = 2;
        var filter_obj = run_montecarlo_simulation.run_montecarlo_simulation_layout.cells("b").attachForm();
        
        //Re-sizing layout cells
        var layout_a_obj = run_montecarlo_simulation.run_montecarlo_simulation_layout.cells("a");
        var layout_b_obj = run_montecarlo_simulation.run_montecarlo_simulation_layout.cells("b");
        var layout_c_obj = run_montecarlo_simulation.run_montecarlo_simulation_layout.cells("c");
        var layout_d_obj = run_montecarlo_simulation.run_montecarlo_simulation_layout.cells("d");
        
        layout_a_obj.setHeight(0);
        layout_b_obj.setHeight(100);
        layout_c_obj.setHeight(150);
//        layout_d_obj.setHeight(280);
        //End of resize

        load_form_filter(filter_obj, layout_c_obj, function_id, report_type);
        
        var default_date = new Date();
        var first_day = new Date(default_date.getFullYear(), default_date.getMonth(), 1);
        var last_day = new Date(default_date.getFullYear(), default_date.getMonth() + 1, 0);
        default_date = dates.convert_to_sql(default_date);
        first_day = dates.convert_to_sql(first_day);
        
        var as_of_date_obj = run_montecarlo_simulation.form_run_montecarlo_simulation.getForm('dt_as_of_date');
        as_of_date_obj.setItemValue('dt_as_of_date', default_date);
        
        var term_start_date_obj = run_montecarlo_simulation.form_run_montecarlo_simulation.getForm('dt_term_start');
        term_start_date_obj.setItemValue('dt_term_start', first_day);
        
        var term_end_date_obj = run_montecarlo_simulation.form_run_montecarlo_simulation.getForm('dt_term_end');
        term_end_date_obj.setItemValue('dt_term_end', last_day);
        
        dhxCombo_rfc = run_montecarlo_simulation.form_run_montecarlo_simulation.getCombo("cmb_simulation_model");
        dhxCombo_rfc.attachEvent("onClose", run_montecarlo_simulation.cmb_rfc_onclose);     
    });
    
    function btn_add_toolbar_click(args) {
        var select_rows = run_montecarlo_simulation.grd_run_montecarlo_simulation.getSelectedRowId();
        
        switch(args) {
            case 'select_unselect':
                if (select_rows == null) {
                    run_montecarlo_simulation.grd_run_montecarlo_simulation.selectAll();                    
                    run_montecarlo_simulation.montecarlo_toolbar.setItemEnabled('delete');
                } else {
                    run_montecarlo_simulation.grd_run_montecarlo_simulation.clearSelection();
                    run_montecarlo_simulation.montecarlo_toolbar.setItemDisabled('delete');
                }
                
                break;
            case 'excel':
                if (select_rows != null)
                    run_montecarlo_simulation.grd_run_montecarlo_simulation.clearSelection();            
                
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                run_montecarlo_simulation.grd_run_montecarlo_simulation.toExcel(path);
                
                break;
            case 'pdf':
                if (select_rows != null)
                    run_montecarlo_simulation.grd_run_montecarlo_simulation.clearSelection(); 
                
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                run_montecarlo_simulation.grd_run_montecarlo_simulation.toPDF(path);
                
                break;  
        }
    }
    
    function btn_run_click(args) {
        switch(args) {
            case 'run':
                var as_of_date = run_montecarlo_simulation.form_run_montecarlo_simulation.getItemValue('dt_as_of_date');
                var term_start = run_montecarlo_simulation.form_run_montecarlo_simulation.getItemValue('dt_term_start');
                var term_end = run_montecarlo_simulation.form_run_montecarlo_simulation.getItemValue('dt_term_end');
                var no_of_simulation = run_montecarlo_simulation.form_run_montecarlo_simulation.getItemValue('txt_no_of_simulation');
                var var_approach = run_montecarlo_simulation.form_run_montecarlo_simulation.getItemValue('var_approach');
                var_approach = (var_approach == '') ? 'NULL' : var_approach;
                var simulation_model = dhxCombo_rfc.getChecked();
                simulation_model = (simulation_model == '')? 'NULL' : simulation_model; 
                var run_correlation_decomposition = (run_montecarlo_simulation.form_run_montecarlo_simulation.isItemChecked('chk_run_correlation_decomposition') == true) ? 'y' : 'n';
                var purge_previous_run_value = (run_montecarlo_simulation.form_run_montecarlo_simulation.isItemChecked('chk_purge_previous_run_value') == true) ? 'y' : 'n';
                var run_all = 'NULL';
                var curve_id;
                
                var form_obj = run_montecarlo_simulation.run_montecarlo_simulation_layout.cells("c").getAttachedObject();
                var validate_return = validate_form(form_obj);
                
                if (validate_return === false) {
                    return;
                }
                
                if (run_montecarlo_simulation.grd_run_montecarlo_simulation.getSelectedRowId() != null) {
                    var row_id = run_montecarlo_simulation.grd_run_montecarlo_simulation.getSelectedRowId();
                    var selected_row_array_d = row_id.split(',');
                    
                    for(var i = 0; i < selected_row_array_d.length; i++) {                
                        if (i == 0) {
                            curve_id = run_montecarlo_simulation.grd_run_montecarlo_simulation.cells(selected_row_array_d[i], 0).getValue();
                        } else {
                            curve_id = curve_id + ',' + run_montecarlo_simulation.grd_run_montecarlo_simulation.cells(selected_row_array_d[i], 0).getValue();
                        }
                    }
                } else {
                    curve_id = '';
                }
                
                as_of_date = dates.convert_to_sql(as_of_date);
                term_start = dates.convert_to_sql(term_start);
                term_end = dates.convert_to_sql(term_end);
                
                if (term_start > term_end) {
                    show_messagebox('<b>Term End</b> should be greater than <b>Term Start</b>.');
                    return;
                }
                if (simulation_model == 'NULL' && curve_id == '') {
                    show_messagebox('Please enter either <b>Risk Factor Model</b> or <b>Risk Factor</b>.');
                    return;
                } 
                
                var exec_call = 'EXEC spa_monte_carlo_simulation ' + 
                            singleQuote(as_of_date) + ', ' + 
                            singleQuote(term_start) + ', ' + 
                            singleQuote(term_end) + ', ' + 
                            no_of_simulation + ', ' + 
                            simulation_model + ', ' + 
                            singleQuote((curve_id == '')? 'NULL' : curve_id) + ', ' + 
                            singleQuote(run_all) + ', ' + 
                            singleQuote(purge_previous_run_value) + ', ' +
                            singleQuote(run_correlation_decomposition) + ', ' +
							singleQuote('NULL') + ', ' +
                            var_approach;
               var param = 'gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
               var title = 'Run Price Simulation';
               
               adiha_run_batch_process(exec_call, param, title);
            break;            
        }
    }
    
    function undock_window() {
        var layout_obj = run_montecarlo_simulation.run_montecarlo_simulation_layout;
        
        layout_obj.cells("d").undock(300, 300, 900, 700);
        layout_obj.dhxWins.window('d').maximize();
        layout_obj.dhxWins.window("d").button("park").hide();
        $('.undock_custom').hide();
    }
    
    function fx_set_combo_text_final(cmb_obj) {
        var checked_loc_arr = cmb_obj.getChecked();
        var final_combo_text = new Array();        
        
        $.each(checked_loc_arr, function(i) {
            var opt_obj = cmb_obj.getOption(checked_loc_arr[i]);
            
            if (opt_obj.text != '')
                final_combo_text.push(opt_obj.text);            
        });
        
        cmb_obj.setComboText(final_combo_text.join(','));  
    }
    
    run_montecarlo_simulation.cmb_rfc_onclose = function() {
        fx_set_combo_text_final(dhxCombo_rfc);
    }
</script>