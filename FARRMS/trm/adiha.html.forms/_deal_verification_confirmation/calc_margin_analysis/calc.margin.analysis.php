<!DOCTYPE html>
<html> 
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
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
    $form_name = 'form_margin_analysis';

    $rights_margin_analysis = 10183700;
    
    $has_rights_margin_analysis = build_security_rights($rights_margin_analysis);
    
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Calculate Margin Analysis",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            height:         75
                        },
                        {
                            id:             "b",
                            text:           "",
                            width:          720,
                            header:         false,
                            height:         600,
                            fix_size:       [true,null]
                        }
                    ]';
    
    $name_space = 'ns_margin_analysis';
    $ns_margin_analysis_layout = new AdihaLayout();
    echo $ns_margin_analysis_layout->init_layout('ns_margin_analysis_layout', '', '2E', $layout_json, $name_space);
    
    $toolbar_margin_analysiss = 'margin_analysis_toolbar';
    $toolbar_json = '[{id:"Run", img:"run.gif", imgdis:"run_dis.gif", text:"Run", title:"Run"}]';
    
    $toolbar_ns_margin_analysis = new AdihaMenu();
    echo $ns_margin_analysis_layout->attach_menu_cell($toolbar_margin_analysiss, "a"); 
    echo $toolbar_ns_margin_analysis->init_by_attach($toolbar_margin_analysiss, $name_space);
    echo $toolbar_ns_margin_analysis->load_menu($toolbar_json);
    echo $toolbar_ns_margin_analysis->attach_event('', 'onClick', 'btn_save_click');
    
    $form_object = new AdihaForm();

    $sp_url_cpty = "EXEC spa_source_counterparty_maintain @flag = 'c', @is_active = 'y'";
    echo "cpty_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_cpty, 0, 1, false, '', 2) . ";"."\n";

    $sp_url_contract = "EXEC spa_contract_group 'n'";
    echo "contract_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_contract, 0, 1, false, '', 2) . ";"."\n";

    $general_form_structure = "[
        {type: 'combo', name: 'clearing_counterparty', label: 'Clearing Counterparty', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, options: cpty_dropdown, position: 'label-top', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left']."},
        {type : 'newcolumn'},
        {type: 'combo', name: 'margin_contract', label: 'Margin Contract', value: '', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, options: contract_dropdown, position: 'label-top', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left']."}, 
        {type : 'newcolumn'},       
        {type: 'calendar', name: 'as_of_date_from', label: 'As Of Date From', value: '', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, position: 'label-top', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left']."},
        {type : 'newcolumn'},
        {type: 'calendar', name: 'as_of_date_to', label: 'As Of Date To', position: 'label-top', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left']."},
    ]";   
    
    echo $ns_margin_analysis_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($general_form_structure);

    $toolbar_margin_analysiss = 'margin_analysis_grid_toolbar';
    $toolbar_json = '[
                        {id:"Refresh", img:"Refresh.gif", imgdis:"Refresh_dis.gif", text:"Refresh", title:"Refresh"},                             
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]}
                    ]';
    
    $toolbar_b_margin_analysis = new AdihaMenu();
    echo $ns_margin_analysis_layout->attach_menu_cell($toolbar_margin_analysiss, "b"); 
    echo $toolbar_b_margin_analysis->init_by_attach($toolbar_margin_analysiss, $name_space);
    echo $toolbar_b_margin_analysis->load_menu($toolbar_json);
    echo $toolbar_b_margin_analysis->attach_event('', 'onClick', 'btn_refresh_click');

    $margin_analysis_grid = 'grd_margin_analysis';
    echo $ns_margin_analysis_layout->attach_grid_cell($margin_analysis_grid, 'b');
    $margin_analysis_obj = new AdihaGrid();
    echo $ns_margin_analysis_layout->attach_status_bar("b", true);
    echo $margin_analysis_obj->init_by_attach($margin_analysis_grid, $name_space);
    echo $margin_analysis_obj->set_header("ID,As Of Date,Counterparty,Contract,Margin Account,MTM t0,MTM t1,Delta MTM,Margin Call Price,Maintenance Margin Amount,Additional Margin,Current Portfolio Value,Maintenance Margin Required,Margin Call,Margin Excess");
    echo $margin_analysis_obj->set_columns_ids("source_counterparty_margin_id,as_of_date,counterparty_name,contract_name,margin_account,mtmt_t0,mtmt_t1,delta_mtm,margin_call_price,maintenance_margin_amount,additional_margin,current_portfolio_value,maintenance_margin_required,margin_call,margin_excess");
    echo $margin_analysis_obj->set_widths("150,150,150,150,150,150,150,150,150,150,150,150,150,150,150");
    echo $margin_analysis_obj->set_column_types("ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
    echo $margin_analysis_obj->set_column_visibility("true,false,false,false,false,false,false,false,false,false,false,false,false,false,false");
    echo $margin_analysis_obj->enable_paging(25, 'pagingArea_b', 'true');
    echo $margin_analysis_obj->enable_column_move('true,true,true,true,true,true,true,true,true,true,true,true,true,true,true');
    echo $margin_analysis_obj->set_sorting_preference('str,str,str,str,str,str,str,str,str,str,str,str,str,str,str');
    echo $margin_analysis_obj->set_search_filter(true);
    echo $margin_analysis_obj->return_init();
    echo $margin_analysis_obj->enable_header_menu();

    echo $ns_margin_analysis_layout->close_layout();       
        
?>
<script type="text/javascript">
    $(function() {
        var clearing_counterparty_obj = ns_margin_analysis.form_margin_analysis.getCombo('clearing_counterparty');
        clearing_counterparty_obj.enableFilteringMode('between');
        var margin_contract_obj = ns_margin_analysis.form_margin_analysis.getCombo('margin_contract');
        margin_contract_obj.enableFilteringMode('between');
    });

    function get_filter_value() {
        form_data_insert = ns_margin_analysis.form_margin_analysis.getFormData();
        form_xml = '<Root function_id="12101700"><FormXML ';
        
        for (var a in form_data_insert) {
                label = a;
                data = form_data_insert[a];

                if (data != '') {
                    if (ns_margin_analysis.form_margin_analysis.getItemType(a) == 'calendar')
                        data = ns_margin_analysis.form_margin_analysis.getItemValue(a, true);

                    form_xml += a + '="' + data + '" ';
                }
            }

        form_xml += '></FormXML></Root>';

        validate_return = validate_form(ns_margin_analysis.form_margin_analysis);        
    }

    function btn_save_click() {
        get_filter_value();

        if (validate_return === false) {
            return;
        }
        
        data = {
            'action': 'spa_calc_margin',
            'flag': 'i',
            'form_xml': form_xml
        }

        adiha_post_data('alert', data, '', '', '');
    }

    function btn_refresh_click(args) {
        if (args == 'Refresh') {
            get_filter_value();

            if (validate_return === false) {
                return;
            }

            var sp_url_param = {                    
                'action': 'spa_calc_margin',
                'flag': 's',
                'form_xml': form_xml
            };
        
            sp_url_param  = $.param(sp_url_param );
            var sp_url  = js_data_collector_url + "&" + sp_url_param ;
            ns_margin_analysis.grd_margin_analysis.clearAll();
            ns_margin_analysis.grd_margin_analysis.loadXML(sp_url);
        } else if (args == 'excel') {
            path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
            ns_margin_analysis.grd_margin_analysis.toExcel(path);
        } else if (args == 'pdf') {
            path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
            ns_margin_analysis.grd_margin_analysis.toPDF(path);
        }
    }
</script>
</html>