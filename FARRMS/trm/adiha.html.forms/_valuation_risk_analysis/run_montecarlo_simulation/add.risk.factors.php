<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
</style>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $popup = new AdihaPopup();
    $form_name = 'form_add_risk_factors';

    $rights_scheduled_job_edit = 10101601;
    $rights_scheduled_job_del = 10101610;
    $rights_scheduled_job_run = 10101611;

    list(
        $has_rights_scheduled_job_edit,
        $has_rights_scheduled_job_del,
        $has_rights_scheduled_job_run
        ) = build_security_rights(
        $rights_scheduled_job_edit,
        $rights_scheduled_job_del,
        $rights_scheduled_job_run
        );
    
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "View Scheduled Job",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $name_space = 'add_risk_factors';
    $add_risk_factors_layout = new AdihaLayout();
    echo $add_risk_factors_layout->init_layout('add_risk_factors_layout', '', '1C', $layout_json, $name_space);
    
    $grid_name = 'grd_add_risk_factors';
    echo $add_risk_factors_layout->attach_grid_cell($grid_name, 'a');
    $grid_add_risk_factors = new AdihaGrid('add_risk_factors');
    echo $grid_add_risk_factors->init_by_attach($grid_name, $name_space);
    echo $grid_add_risk_factors->set_widths('150,150,150,150,150,150,150');
    echo $grid_add_risk_factors->set_header('Source Price Curve ID,Curve Name,Curve ID,Description,Granularity,Risk Factor Model');
    echo $grid_add_risk_factors->set_columns_ids('source_curve_def_id,curve_name,curve_id,curve_des,code,monte_carlo_model_parameter_name');
    echo $grid_add_risk_factors->set_search_filter(false, '#text_filter,#text_filter,#text_filter,#text_filter,#combo_filter,#combo_filter');    
    echo $grid_add_risk_factors->load_grid_functions();  
    echo $grid_add_risk_factors->set_column_types('ro,ro,ro,ro,ro,ro,ro');
    echo $grid_add_risk_factors->hide_column(0);
    echo $grid_add_risk_factors->enable_multi_select();
    echo $grid_add_risk_factors->load_grid_data("EXEC spa_monte_carlo_model @flag='r'");
    echo $grid_add_risk_factors->return_init();
    
    //echo $grid_add_risk_factors->attach_event('', 'onRowSelect', 'grd_add_risk_factors_click');
    echo $grid_add_risk_factors->attach_event('', 'onSelectStateChanged', 'state_change');
    $toolbar_add_risk_factors_name = 'add_risk_factors_toolbar';
    $toolbar_json = '[{id:"save", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled: true}]';
    
    $toolbar_add_risk_factors = new AdihaMenu();
    echo $add_risk_factors_layout->attach_menu_cell($toolbar_add_risk_factors_name, "a"); 
    echo $toolbar_add_risk_factors->init_by_attach($toolbar_add_risk_factors_name, $name_space);
    echo $toolbar_add_risk_factors->load_menu($toolbar_json);
    echo $toolbar_add_risk_factors->attach_event('', 'onClick', 'run_toolbar_click');
    
    echo $add_risk_factors_layout->close_layout();       
        
?>
<script type="text/javascript">
    function state_change(args) {
        var row_id = add_risk_factors.grd_add_risk_factors.getSelectedRowId();   
        
        if (row_id == null) {
            add_risk_factors.add_risk_factors_toolbar.setItemDisabled('save');
        } else {
            add_risk_factors.add_risk_factors_toolbar.setItemEnabled('save');
        }
    }
    
    function run_toolbar_click(args) {    
        switch(args) {
            case 'save':
                var row_id = add_risk_factors.grd_add_risk_factors.getSelectedRowId();
                var curve_id;
                
               
                if (add_risk_factors.grd_add_risk_factors.getSelectedRowId() != null) {
                    var row_id = add_risk_factors.grd_add_risk_factors.getSelectedRowId();
                    var selected_row_array_d = row_id.split(',');
                    
                    for(var i = 0; i < selected_row_array_d.length; i++) {                
                        if (i == 0) {
                            curve_id = add_risk_factors.grd_add_risk_factors.cells(selected_row_array_d[i], 0).getValue();
                        } else {
                            curve_id = curve_id + ',' + add_risk_factors.grd_add_risk_factors.cells(selected_row_array_d[i], 0).getValue();
                        }
                    }
                } else {
                    curve_id = '';
                }
            
                var parent_form = parent.run_montecarlo_simulation.form_run_montecarlo_simulation.getForm()
                parent.curve_ids = curve_id;
                //parent_form.setItemValue('curve_ids', curve_id);
                setTimeout('parent.callback_grid_refresh();', 1000);
                setTimeout('parent.risk_factor.close();', 1000);
                break;           
        }
    }    
    //case 'add':              
//            var add_risk_factor = new dhtmlXWindows();
//            var src = '../run_montecarlo_simulation/add.risk.factors.php'; 
//            
//            risk_factor = add_risk_factor.createWindow('w1', 50, 165, 800, 400);
//            risk_factor.setText('Risk Factors');
//            risk_factor.attachURL(src, false, true);
//            
//            break;


//function callback_grid_refresh() {  
//    run_montecarlo_simulation.grd_run_montecarlo_simulation = run_montecarlo_simulation.run_montecarlo_simulation_layout.cells('d').attachGrid();
//    run_montecarlo_simulation.grd_run_montecarlo_simulation.setImagePath(js_image_path + "dhxgrid_web/");
//    run_montecarlo_simulation.grd_run_montecarlo_simulation.setHeader('source_curve_def_id,Curve Name,Description,Granularity,Risk Factor Model'); 
//    run_montecarlo_simulation.grd_run_montecarlo_simulation.setColumnIds('source_curve_def_id,curve_name,curve_des,code,monte_carlo_model_parameter_name');
//    run_montecarlo_simulation.grd_run_montecarlo_simulation.setColTypes('ro,ro,ro,ro,ro');
//    run_montecarlo_simulation.grd_run_montecarlo_simulation.setColumnsVisibility('true,false,false,false,false');
//    run_montecarlo_simulation.grd_run_montecarlo_simulation.init();    
//
//    
//    var sp_url_param = {                    
//                    "flag": 's',                    
//                    "curve_ids": curve_ids,
//                    "action": "spa_run_monte_carlo_model"
//    };
//
//    sp_url_param  = $.param(sp_url_param);
//    var sp_url = js_data_collector_url + "&" + sp_url_param ;
//    run_montecarlo_simulation.grd_run_montecarlo_simulation.loadXML(sp_url);
//}
</script>