<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
    <?php 
    $source_deal_header_id = get_sanitized_value($_GET['source_deal_header_id'] ?? '');
    
    $rights_setup_generation = 10131029;
   
    list (
        $has_rights_setup_generation
    ) = build_security_rights(
        $rights_setup_generation
    );
    
    $sql_query = "EXEC spa_setup_generator @flag = 'n', @source_deal_header_id = " . $source_deal_header_id;
    $sql_result = readXMLURL2($sql_query);
    $generator_name = $sql_result[0]['generator'];
    
    $json = '[
                {
                    id:             "a",
                    text:           "Generation",
                    header:         true,
                    width:          350
                }
            ]';
    
    $namespace = 'setup_generation';
    $setup_generation_layout_obj = new AdihaLayout();
    echo $setup_generation_layout_obj->init_layout('setup_generation_layout', '', '1C', $json, $namespace);
    
    $save_menu_json = '[{id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif"}]';
    echo $setup_generation_layout_obj->attach_menu_cell('setup_generation_menu','a');
    $setup_generation_menu_obj = new AdihaMenu();
    echo $setup_generation_menu_obj->init_by_attach('setup_generation_menu', $namespace);
    echo $setup_generation_menu_obj->load_menu($save_menu_json);
    echo $setup_generation_menu_obj->attach_event('', 'onClick', $namespace . '.setup_generation_menu_onclick');
    
    $tab_json = '[{"id":"a","text":"General","active":"true"},{"id":"b","text":"Data"},{"id":"c","text":"Owner"},{"id":"d","text":"Outage/Derate"},{"id":"e","text":"Operation Unit Configuration"}]';
    echo $setup_generation_layout_obj->attach_tab_cell('setup_generation_tab', 'a', $tab_json);
    $setup_generation_tab_obj = new AdihaTab();
    echo $setup_generation_tab_obj->init_by_attach('setup_generation_tab', $namespace);
    
    $tab_layout_json = "[{id: 'a', text: 'Apply Filter', width: 250, header:true}, {id: 'b', text: 'Filter', height: 130, header:true},{id: 'c', text: 'Grid', header:false}]";
    
    $tab_menu_json = '[
						{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
							{id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif"},
							{id:"delete", text:"Delete", img:"delete.gif",imgdis:"delete_dis.gif",enabled:"false"}
						]},
						{id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
							{id:"excel", text:"Excel", img:"excel.gif"},
							{id:"pdf", text:"PDF", img:"pdf.gif"}
						]}
					]';
    
    $tab_menu_json_with_refresh = '[
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
						{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
							{id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif"},
							{id:"delete", text:"Delete", img:"delete.gif",imgdis:"delete_dis.gif",enabled:"false"}
						]},
						{id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
							{id:"excel", text:"Excel", img:"excel.gif"},
							{id:"pdf", text:"PDF", img:"pdf.gif"}
						]}
					]';
    
    /* General Tab Start */
    $general_grid_obj = new GridTable('setup_generation_general');
    echo $setup_generation_tab_obj->attach_grid_cell('general_grid','a');
    echo $general_grid_obj->init_grid_table('general_grid', $namespace);
    echo $general_grid_obj->set_search_filter(true,'');
    echo $general_grid_obj->enable_multi_select();
    echo $general_grid_obj->return_init();
    echo $general_grid_obj->load_grid_functions();
    echo $general_grid_obj->attach_event('','onRowSelect', "function() { setup_generation.general_menu.setItemEnabled('delete'); }");
    
    echo $setup_generation_tab_obj->attach_menu_cell('general_menu','a');
    $general_menu_obj = new AdihaMenu();
    echo $general_menu_obj->init_by_attach('general_menu', $namespace);
    echo $general_menu_obj->load_menu($tab_menu_json);
    echo $general_menu_obj->attach_event('', 'onClick', $namespace . '.general_menu_onclick');
    /* General Tab End */
    
    
    /* Data Tab Start */
    $data_tab_layout_obj = new AdihaLayout();
    $data_tab_layout_obj->init_by_attach('data_tab_layout', $namespace);
    echo $setup_generation_tab_obj->attach_layout_cell($namespace, 'data_tab_layout', $namespace.'.setup_generation_tab', 'b', '3U',$tab_layout_json);
    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10131029', @template_name='Setup Generation', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $data_tab_layout_obj->attach_form('data_filter_form', 'b');
    $data_filter_form_obj = new AdihaForm();
    echo $data_filter_form_obj->init_by_attach('data_filter_form', $namespace);
    echo $data_filter_form_obj->load_form($form_json);
    
    $data_grid_obj = new GridTable('setup_generation_data');
    echo $data_tab_layout_obj->attach_grid_cell('data_grid','c');
    echo $data_grid_obj->init_grid_table('data_grid', $namespace);
    echo $data_grid_obj->set_search_filter(true,'');
    echo $data_grid_obj->enable_multi_select();
    echo $data_grid_obj->return_init();
    echo $data_grid_obj->load_grid_functions();
    echo $data_grid_obj->attach_event('','onRowSelect', "function() { setup_generation.data_menu.setItemEnabled('delete'); }");
    
    echo $data_tab_layout_obj->attach_menu_cell('data_menu','c');
    $data_menu_obj = new AdihaMenu();
    echo $data_menu_obj->init_by_attach('data_menu', $namespace);
    echo $data_menu_obj->load_menu($tab_menu_json_with_refresh);
    echo $data_menu_obj->attach_event('', 'onClick', $namespace . '.data_menu_onclick');
    /* Data Tab End */
    
    
    /* Owner Tab Start */
    $owner_grid_obj = new GridTable('setup_generation_owner');
    echo $setup_generation_tab_obj->attach_grid_cell('owner_grid','c');
    echo $owner_grid_obj->init_grid_table('owner_grid', $namespace);
    echo $owner_grid_obj->set_search_filter(true,'');
    echo $owner_grid_obj->enable_multi_select();
    echo $owner_grid_obj->return_init();
    echo $owner_grid_obj->load_grid_functions();
    echo $owner_grid_obj->attach_event('','onRowSelect', "function() { setup_generation.owner_menu.setItemEnabled('delete'); }");
    
    echo $setup_generation_tab_obj->attach_menu_cell('owner_menu','c');
    $owner_menu_obj = new AdihaMenu();
    echo $owner_menu_obj->init_by_attach('owner_menu', $namespace);
    echo $owner_menu_obj->load_menu($tab_menu_json);
    echo $owner_menu_obj->attach_event('', 'onClick', $namespace . '.owner_menu_onclick');
    /* Owner Tab End */
    
    
    /* Owner Tab Start */
    $outage_derate_grid_obj = new GridTable('setup_generation_outage_derate');
    echo $setup_generation_tab_obj->attach_grid_cell('outage_derate_grid','d');
    echo $outage_derate_grid_obj->init_grid_table('outage_derate_grid', $namespace);
    echo $outage_derate_grid_obj->set_search_filter(true,'');
    echo $outage_derate_grid_obj->enable_multi_select();
    echo $outage_derate_grid_obj->return_init();
    echo $outage_derate_grid_obj->load_grid_functions();
    echo $outage_derate_grid_obj->attach_event('','onRowSelect', "function() { setup_generation.outage_derate_menu.setItemEnabled('delete'); }");
    
    echo $setup_generation_tab_obj->attach_menu_cell('outage_derate_menu','d');
    $outage_derate_menu_obj = new AdihaMenu();
    echo $outage_derate_menu_obj->init_by_attach('outage_derate_menu', $namespace);
    echo $outage_derate_menu_obj->load_menu($tab_menu_json);
    echo $outage_derate_menu_obj->attach_event('', 'onClick', $namespace . '.outage_derate_menu_onclick');
    /* Owner Tab End */
    
    /* Operational Unit Configuration Tab Start */
    $configuration_grid_obj = new GridTable('setup_generation_configuration');
    echo $setup_generation_tab_obj->attach_grid_cell('configuration_grid','e');
    echo $configuration_grid_obj->init_grid_table('configuration_grid', $namespace);
    echo $configuration_grid_obj->set_search_filter(true,'');
    echo $configuration_grid_obj->enable_multi_select();
    echo $configuration_grid_obj->return_init();
    echo $configuration_grid_obj->load_grid_functions();
    echo $configuration_grid_obj->attach_event('','onRowSelect', "function() { setup_generation.configuration_menu.setItemEnabled('delete'); }");
    
    echo $setup_generation_tab_obj->attach_menu_cell('configuration_menu','e');
    $configuration_menu_obj = new AdihaMenu();
    echo $configuration_menu_obj->init_by_attach('configuration_menu', $namespace);
    echo $configuration_menu_obj->load_menu($tab_menu_json);
    echo $configuration_menu_obj->attach_event('', 'onClick', $namespace . '.configuration_menu_onclick');
    /* Operational Unit Configuration Tab End */
    
    echo $setup_generation_layout_obj->close_layout();
    ?> 
    
    
</body>


<script type="application/javascript">
    var source_deal_header_id = '<?php echo $source_deal_header_id; ?>';
    var general_deleted = new Array();
    var data_deleted = new Array();
    var owner_deleted = new Array();
    var outage_derate_deleted = new Array();
    var  configuration_deleted = new Array();
    
    $(function() {
        var generator_name = '<?php echo $generator_name; ?>';
        parent.setup_generation_win.setText(generator_name);
        
        filter_obj = setup_generation.data_tab_layout.cells('a').attachForm();
        var layout_cell_obj = setup_generation.data_tab_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '10183412', 2);
        
        refresh_general_grid();
        refresh_owner_grid();
        refresh_outage_derate_grid();
        refresh_configuration_grid();
        
        setup_generation.outage_derate_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (stage == 2 && cInd == 1) {
                if (nValue == 'o') {
                    setup_generation.outage_derate_grid.cells(rId,setup_generation.outage_derate_grid.getColIndexById('derate_mw')).setValue('');
                    setup_generation.outage_derate_grid.cells(rId,setup_generation.outage_derate_grid.getColIndexById('derate_percent')).setValue('');
                    setup_generation.outage_derate_grid.cells(rId,setup_generation.outage_derate_grid.getColIndexById('derate_mw')).setDisabled(true);
                    setup_generation.outage_derate_grid.cells(rId,setup_generation.outage_derate_grid.getColIndexById('derate_percent')).setDisabled(true);
                } else {
                    setup_generation.outage_derate_grid.cells(rId,setup_generation.outage_derate_grid.getColIndexById('derate_mw')).setDisabled(false);
                    setup_generation.outage_derate_grid.cells(rId,setup_generation.outage_derate_grid.getColIndexById('derate_percent')).setDisabled(false);
                }            
                
            }
            return true;
        });
    });
    
    
    /* 
     * Menu functions of General Tab 
     */
    setup_generation.general_menu_onclick = function(id, zoneId, cas) {
        switch(id) {
            case 'add':
                var new_id = (new Date()).valueOf();
                setup_generation.general_grid.addRow(new_id, '');
                setup_generation.general_grid.forEachRow(function(row){
                    setup_generation.general_grid.forEachCell(row,function(cellObj,ind){
                        setup_generation.general_grid.validateCell(row,ind)
                    });
                });
                break;
            case 'delete':
                var selected_row = setup_generation.general_grid.getSelectedRowId();
                var selected_row_arr = selected_row.split(',');
                for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                    var id = setup_generation.general_grid.cells(selected_row_arr[cnt], 0).getValue();
                    if(id != '')  general_deleted.push(id);
                    
                    setup_generation.general_grid.deleteRow(selected_row_arr[cnt]);
                    setup_generation.general_menu.setItemDisabled('delete');
                }
                break;
            case 'pdf':
                setup_generation.general_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case 'excel':
                setup_generation.general_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
        } 
    }
    
    
    /* 
     * Menu functions of Data Tab 
     */
    setup_generation.data_menu_onclick = function(id, zoneId, cas) {
        switch(id) {
            case 'refresh':
                refresh_data_grid();
                break;                
            case 'add':
                var new_id = (new Date()).valueOf();
                setup_generation.data_grid.addRow(new_id, '');
                setup_generation.data_grid.forEachRow(function(row){
                    setup_generation.data_grid.forEachCell(row,function(cellObj,ind){
                        setup_generation.data_grid.validateCell(row,ind)
                    });
                });
                break;
            case 'delete':
                var selected_row = setup_generation.data_grid.getSelectedRowId();
                var selected_row_arr = selected_row.split(',');
                for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                    var id = setup_generation.data_grid.cells(selected_row_arr[cnt], 0).getValue();
                    if(id != '')  data_deleted.push(id);
                    
                    setup_generation.data_grid.deleteRow(selected_row_arr[cnt]);
                    setup_generation.data_menu.setItemDisabled('delete');
                }
                break;
            case 'pdf':
                setup_generation.data_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case 'excel':
                setup_generation.data_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
        } 
    }
    
    
    /* 
     * Menu functions of Owner Tab 
     */
    setup_generation.owner_menu_onclick = function(id, zoneId, cas) {
        switch(id) {
            case 'add':
                var new_id = (new Date()).valueOf();
                setup_generation.owner_grid.addRow(new_id, '');
                setup_generation.owner_grid.forEachRow(function(row){
                    setup_generation.owner_grid.forEachCell(row,function(cellObj,ind){
                        setup_generation.owner_grid.validateCell(row,ind)
                    });
                });
                break;
            case 'delete':
                var selected_row = setup_generation.owner_grid.getSelectedRowId();
                var selected_row_arr = selected_row.split(',');
                for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                    var id = setup_generation.owner_grid.cells(selected_row_arr[cnt], 0).getValue();
                    if(id != '')  owner_deleted.push(id);
                    
                    setup_generation.owner_grid.deleteRow(selected_row_arr[cnt]);
                    setup_generation.owner_menu.setItemDisabled('delete');
                }
                break;
            case 'pdf':
                setup_generation.owner_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case 'excel':
                setup_generation.owner_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
        } 
    }
    
    
    /* 
     * Menu functions of Outage/Derage Tab 
     */
    setup_generation.outage_derate_menu_onclick = function(id, zoneId, cas) {
        switch(id) {
            case 'add':
                var new_id = (new Date()).valueOf();
                setup_generation.outage_derate_grid.addRow(new_id, '');
                setup_generation.outage_derate_grid.forEachRow(function(row){
                    setup_generation.outage_derate_grid.forEachCell(row,function(cellObj,ind){
                        setup_generation.outage_derate_grid.validateCell(row,ind)
                    });
                });
                break;
            case 'delete':
                var selected_row = setup_generation.outage_derate_grid.getSelectedRowId();
                var selected_row_arr = selected_row.split(',');
                for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                    var id = setup_generation.outage_derate_grid.cells(selected_row_arr[cnt], 0).getValue();
                    if(id != '')  outage_derate_deleted.push(id);
                    
                    setup_generation.outage_derate_grid.deleteRow(selected_row_arr[cnt]);
                    setup_generation.outage_derate_menu.setItemDisabled('delete');
                }
                break;
            case 'pdf':
                setup_generation.outage_derate_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case 'excel':
                setup_generation.outage_derate_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
        } 
    }
    
    
    /* 
     * Menu functions of Operational Unit Configuration Tab 
     */
    setup_generation.configuration_menu_onclick = function(id, zoneId, cas) {
        switch(id) {
            case 'add':
                var new_id = (new Date()).valueOf();
                setup_generation.configuration_grid.addRow(new_id, '');
                setup_generation.configuration_grid.forEachRow(function(row){
                    setup_generation.configuration_grid.forEachCell(row,function(cellObj,ind){
                        setup_generation.configuration_grid.validateCell(row,ind)
                    });
                });
                break;
            case 'delete':
                var selected_row = setup_generation.configuration_grid.getSelectedRowId();
                var selected_row_arr = selected_row.split(',');
                for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                    var id = setup_generation.configuration_grid.cells(selected_row_arr[cnt], 0).getValue();
                    if(id != '')  configuration_deleted.push(id);
                    
                    setup_generation.configuration_grid.deleteRow(selected_row_arr[cnt]);
                    setup_generation.configuration_menu.setItemDisabled('delete');
                }
                break;
            case 'pdf':
                setup_generation.configuration_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case 'excel':
                setup_generation.configuration_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
        } 
    }
    
    /* 
     * Save Function
     */
    setup_generation.setup_generation_menu_onclick = function(id, zoneId, cas) {
        var general_grid_xml = build_general_grid_xml();
        if (general_grid_xml == -1) return;
        
        var data_grid_xml = build_data_grid_xml();
        if (data_grid_xml == -1) return;
        
        var owner_grid_xml = build_owner_grid_xml();
        if (owner_grid_xml == -1) return;
        
        var outage_derate_xml = build_outage_derate_grid_xml();
        if (outage_derate_xml == -1) return;
        
        var configuration_xml = build_configuration_grid_xml();
        if (configuration_xml == -1) return;
        
        var delete_grid_xml = build_deleted_grid_xml();
        
        
        var save_xml = '<Root>' + general_grid_xml + data_grid_xml + owner_grid_xml + outage_derate_xml + configuration_xml + delete_grid_xml + '</Root>';
        var data = {
                        "action": "spa_setup_generator",
                        "flag": 'i',
                        "source_deal_header_id": source_deal_header_id, 
                        "xml_data": save_xml
                    };

        adiha_post_data('alert', data, '', '', 'setup_generation_save_callback', '');
    }
    
    
    setup_generation_save_callback = function(result) {
        refresh_general_grid();
        refresh_data_grid();
        refresh_owner_grid();
        refresh_configuration_grid();
        refresh_outage_derate_grid();
    }
    
    
    /* 
     * Returns the XML data of General Tab's grid to save
     */
    build_general_grid_xml = function() {
        setup_generation.general_grid.clearSelection();
        
        var grid_status = setup_generation.validate_form_grid(setup_generation.general_grid, 'General');
        if (grid_status == false) {
            return -1;
        }
        
        var changed_row_ids = setup_generation.general_grid.getChangedRows(true);
        if (changed_row_ids == '') {
            var changed_row_ids_arr = new Array();
        } else {
            var changed_row_ids_arr = changed_row_ids.split(',');
        }
        
        var xml_data = '';
        for (cnt = 0; cnt < changed_row_ids_arr.length; cnt++) {
            var id = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('id')).getValue();
            var effective_date = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('effective_date')).getValue();
			if(effective_date != '')  effective_date = dates.convert_to_sql(effective_date);
			var config = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('config')).getValue();
            var fuel = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('fuel')).getValue();
            var fuel_curve = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('fuel_curve')).getValue();
            var coeff_a = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('coeff_a')).getValue();
            var coeff_b = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('coeff_b')).getValue();
            var coeff_c = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('coeff_c')).getValue();
            var heat_rate = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('heat_rate')).getValue();
            var unit_min = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('unit_min')).getValue();
            var unit_max = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('unit_max')).getValue();
            var is_default = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('default')).getValue();
            var comments = setup_generation.general_grid.cells(changed_row_ids_arr[cnt], setup_generation.general_grid.getColIndexById('comments')).getValue();
            if (coeff_a == '' && coeff_b == '' && coeff_c == '' && heat_rate == '') {
                var msg = 'Data Error in <strong>General Grid</strong>. Either one of <strong>Coeff A, Coeff B, Coeff C or Heat Rate</strong> should have value.';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
            }
            
            xml_data += '<GeneralGrid id="' + id + '"' +
                            ' effective_date="' + effective_date + '"' +
                            ' config="' + config + '"' +
                            ' fuel="' + fuel + '"' +
                            ' fuel_curve="' + fuel_curve + '"' +
                            ' coeff_a="' + coeff_a + '"' +
                            ' coeff_b="' + coeff_b + '"' +
                            ' coeff_c="' + coeff_c + '"' +
                            ' heat_rate="' + heat_rate + '"' +
                            ' unit_min="' + unit_min + '"' +
                            ' unit_max="' + unit_max + '"' +
                            ' default="' + is_default + '"' +
                            ' comments="' + comments + '" />';
        }
        return xml_data;
    }
    
    /* 
     * Returns the XML data of Data Tab's grid to save
     */
    build_data_grid_xml = function() {
        setup_generation.data_grid.clearSelection();
        
        var grid_status = setup_generation.validate_form_grid(setup_generation.data_grid, 'Data');
        if (grid_status == false) {
            return -1;
        }
        
        var changed_row_ids = setup_generation.data_grid.getChangedRows(true);
        if (changed_row_ids == '') {
            var changed_row_ids_arr = new Array();
        } else {
            var changed_row_ids_arr = changed_row_ids.split(',');
        }
        
        var xml_data = '';
        for (cnt = 0; cnt < changed_row_ids_arr.length; cnt++) {
            var id = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('id')).getValue();
            var effective_date = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('effective_date')).getValue();
			if(effective_date != '')  effective_date = dates.convert_to_sql(effective_date);
            var end_date = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('end_date')).getValue();
			if(end_date != '') end_date = dates.convert_to_sql(end_date);
            var tou = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('tou')).getValue();
            var hour_start = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('hour_start')).getValue();
            var hour_end = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('hour_end')).getValue();
            var type = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('type')).getValue();
            var period = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('period')).getValue();
            var value = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('value')).getValue();
			var config = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('config')).getValue();
            var comments = setup_generation.data_grid.cells(changed_row_ids_arr[cnt], setup_generation.data_grid.getColIndexById('comments')).getValue();

            if ((effective_date > end_date) && end_date != '') {
                 var msg = '<b>Effective Date</b> should not be greater than <b>End Date</b>';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
            };
            if (tou == '' && hour_start == '' && hour_end == '') {
                var msg = 'Data Error in <strong>Data Grid</strong>. Either one of <strong>TOU, Hour Start or Hour End</strong> should have value.';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
            }
            
			if ((hour_start < 1 || hour_start > 24) && hour_start != '') {
				var msg = 'Data Error in <strong>Data Grid</strong>. <strong>Hour Start</strong> value should be between 1 and 24.';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
			}
			
			if ((hour_end < 1 || hour_end > 24) && hour_end != '') {
				var msg = 'Data Error in <strong>Data Grid</strong>. <strong>Hour End</strong> value should be between 1 and 24.';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
			}
			
            xml_data += '<DataGrid id="' + id + '"' +
                            ' effective_date="' + effective_date + '"' +
                            ' end_date="' + end_date + '"' +
                            ' tou="' + tou + '"' +
                            ' hour_start="' + hour_start + '"' +
                            ' hour_end="' + hour_end + '"' +
                            ' type="' + type + '"' +
                            ' period="' + period + '"' +
                            ' value="' + value + '"' +
							' config="' + config + '"'+
                            ' comments="' + comments + '" />';
        }
        return xml_data;
    }
    
    /* 
     * Returns the XML data of Owner Tab's grid to save
     */
    build_owner_grid_xml = function() {
        setup_generation.owner_grid.clearSelection();
        
        var grid_status = setup_generation.validate_form_grid(setup_generation.owner_grid, 'Owner');
        if (grid_status == false) {
            return -1;
        }
        
        var changed_row_ids = setup_generation.owner_grid.getChangedRows(true);
        if (changed_row_ids == '') {
            var changed_row_ids_arr = new Array();
        } else {
            var changed_row_ids_arr = changed_row_ids.split(',');
        }
        
        var total_percent = 0;
        var negative_percent = 0;
        setup_generation.owner_grid.forEachRow(function(id){
            var owner_percent = setup_generation.owner_grid.cells(id, setup_generation.owner_grid.getColIndexById('owner_percent')).getValue();
            if (owner_percent < 0) negative_percent = 1;
            total_percent += parseFloat(owner_percent);
        });
        
        if (negative_percent == 1) {
            var msg = 'Data Error in <strong>Owner Grid</strong>. Total Owner cannot be negative.';
            dhtmlx.message({
                type: "alert-error",
                title: "Error",
                text: msg
            });
            return -1;
        }
        
        if (total_percent > 100) {
            var msg = 'Data Error in <strong>Owner Grid</strong>. Total Owner percent cannot exceed 100%.';
            dhtmlx.message({
                type: "alert-error",
                title: "Error",
                text: msg
            });
            return -1;
        }
        
        var xml_data = '';
        for (cnt = 0; cnt < changed_row_ids_arr.length; cnt++) {
            var id = setup_generation.owner_grid.cells(changed_row_ids_arr[cnt], setup_generation.owner_grid.getColIndexById('id')).getValue();
            var effective_date = setup_generation.owner_grid.cells(changed_row_ids_arr[cnt], setup_generation.owner_grid.getColIndexById('effective_date')).getValue();
            if(effective_date != '')  effective_date = dates.convert_to_sql(effective_date);
			var owner = setup_generation.owner_grid.cells(changed_row_ids_arr[cnt], setup_generation.owner_grid.getColIndexById('owner')).getValue();
            var owner_per = setup_generation.owner_grid.cells(changed_row_ids_arr[cnt], setup_generation.owner_grid.getColIndexById('owner_percent')).getValue();
            var comments = setup_generation.owner_grid.cells(changed_row_ids_arr[cnt], setup_generation.owner_grid.getColIndexById('comments')).getValue();
            
            xml_data += '<OwnerGrid id="' + id + '"' +
                            ' effective_date="' + effective_date + '"' +
                            ' owner="' + owner + '"' +
                            ' owner_per="' + owner_per + '"'+
                            ' comments="' + comments + '" />';
        }
        return xml_data;
    }
    
    /* 
     * Returns the XML data of Outage/Derate Tab's grid to save
     */
    build_outage_derate_grid_xml = function() {
        setup_generation.outage_derate_grid.clearSelection();
        
        var grid_status = setup_generation.validate_form_grid(setup_generation.outage_derate_grid, 'Outage/Derate');
        if (grid_status == false) {
            return -1;
        }
        
        var changed_row_ids = setup_generation.outage_derate_grid.getChangedRows(true);
        if (changed_row_ids == '') {
            var changed_row_ids_arr = new Array();
        } else {
            var changed_row_ids_arr = changed_row_ids.split(',');
        }
        
        var xml_data = '';
        for (cnt = 0; cnt < changed_row_ids_arr.length; cnt++) {
            var id = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('id')).getValue();
            var type = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('type')).getValue();
            var planned_start = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('planned_start')).getValue();
			//if(planned_start != '')  planned_start = dates.convert_to_sql_with_time(planned_start);
			var palnned_end = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('planned_end')).getValue();
			//if(palnned_end != '')  palnned_end = dates.convert_to_sql_with_time(palnned_end);
            var actual_start = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('actual_start')).getValue();
			//if(actual_start != '')  actual_start = dates.convert_to_sql_with_time(actual_start);
            var actual_end = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('actual_end')).getValue();
			//if(actual_end != '')  actual_end = dates.convert_to_sql_with_time(actual_end);
            var status = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('status')).getValue();
            var request_type = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('request_type')).getValue();
            var derate_mw = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('derate_mw')).getValue();
            var derate_per = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('derate_percent')).getValue();
            var comments = setup_generation.outage_derate_grid.cells(changed_row_ids_arr[cnt], setup_generation.outage_derate_grid.getColIndexById('comments')).getValue();

            if ((planned_start > palnned_end) && palnned_end != '') {
                 var msg = '<b>Planned Start Date</b> should not be greater than <b>Planned End Date</b>';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
            }

              if ((actual_start > actual_end) && actual_end != '') {
                 var msg = '<b>Actual Start Date</b> should not be greater than <b>Actual End Date</b>';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
            }
            xml_data += '<OutageDerateGrid id="' + id + '"' +
                            ' type="' + type + '"' +
                            ' planned_start="' + planned_start + '"' +
                            ' planned_end="' + palnned_end + '"' +
                            ' actual_start="' + actual_start + '"' +
                            ' actual_end="' + actual_end + '"' +
                            ' status="' + status + '"' +
                            ' request_type="' + request_type + '"' +
                            ' derate_mw="' + derate_mw + '"' +
                            ' derate_per="' + derate_per + '"' +
                            ' comments="' + comments + '" />';
                            
            
        }
        return xml_data;
    }
    
    /* 
     * Returns the XML data of Operation Unit Configuration Tab's grid to save
     */
    build_configuration_grid_xml = function() {
        setup_generation.configuration_grid.clearSelection();
        
        var grid_status = setup_generation.validate_form_grid(setup_generation.configuration_grid, 'Operation Unit Configuration');
        if (grid_status == false) {
            return -1;
        }
        
        var changed_row_ids = setup_generation.configuration_grid.getChangedRows(true);
        if (changed_row_ids == '') {
            var changed_row_ids_arr = new Array();
        } else {
            var changed_row_ids_arr = changed_row_ids.split(',');
        }
        
        var xml_data = '';
        for (cnt = 0; cnt < changed_row_ids_arr.length; cnt++) {
            var id = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('id')).getValue();
            var effective_date = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('effective_date')).getValue();
            if(effective_date != '') effective_date = dates.convert_to_sql(effective_date);
			var end_date = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('end_date')).getValue();
            if(end_date != '') end_date = dates.convert_to_sql(end_date);
			var config = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('config')).getValue();
            var period = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('period')).getValue();
            var fuel = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('fuel')).getValue();
            var tou = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('tou')).getValue();
            var hour_start = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('hour_start')).getValue();
            var hour_end = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('hour_end')).getValue();
            var from_mw = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('from_mw')).getValue();
            var to_mw = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('to_mw')).getValue();
            var comments = setup_generation.configuration_grid.cells(changed_row_ids_arr[cnt], setup_generation.configuration_grid.getColIndexById('comments')).getValue();
            
            /*
            if (hour_start == '' && hour_end == '') {
                var msg = 'Data Error in <strong>Operation Uni Configuration Grid</strong>. Either one of <strong>Hour Start or Hour End</strong> should have value.';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
            }*/
             if ((effective_date > end_date) && end_date != '') {
                 var msg = '<b>Effective Date</b> should not be greater than <b>End Date</b>';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
            }
            
			if ((hour_start < 1 || hour_start > 24) && hour_start != '') {
				var msg = 'Data Error in <strong>Operation Unit Configuration Grid</strong>. <strong>Hour Start</strong> value should be between 1 and 24.';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
			}
			
			if ((hour_end < 1 || hour_end > 24) && hour_end != '') {
				var msg = 'Data Error in <strong>Operation Unit Configuration Grid</strong>. <strong>Hour End</strong> value should be between 1 and 24.';
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text: msg
                });
                return -1;
			}
			
            xml_data += '<ConfigurationGrid id="' + id + '"' +
                            ' effective_date="' + effective_date + '"' +
                            ' end_date="' + end_date + '"' +
                            ' config="' + config + '"' +
                            ' period="' + period + '"' +
                            ' fuel="' + fuel + '"' +
                            ' tou="' + tou + '"' +
                            ' hour_start="' + hour_start + '"' +
                            ' hour_end="' + hour_end + '"' +
                            ' from_mw="' + from_mw + '"' +
                            ' to_mw="' + to_mw + '"'+
                            ' comments="' + comments + '" />';
                            
            
        }
        return xml_data;
    }
    
    
    build_deleted_grid_xml = function() {
        var xml_data = '';
        
        for (cnt = 0; cnt < general_deleted.length; cnt++) {
            xml_data += '<DeletedGridData id="' + general_deleted[cnt] + '" grid_name="General" />'
        }
        for (cnt = 0; cnt < data_deleted.length; cnt++) {
            xml_data += '<DeletedGridData id="' + data_deleted[cnt] + '" grid_name="Data" />'
        }
        for (cnt = 0; cnt < owner_deleted.length; cnt++) {
            xml_data += '<DeletedGridData id="' + owner_deleted[cnt] + '" grid_name="Owner" />'
        }
        for (cnt = 0; cnt < outage_derate_deleted.length; cnt++) {
            xml_data += '<DeletedGridData id="' + outage_derate_deleted[cnt] + '" grid_name="OutageDerate" />'
        }
        for (cnt = 0; cnt < configuration_deleted.length; cnt++) {
            xml_data += '<DeletedGridData id="' + configuration_deleted[cnt] + '" grid_name="Configuration" />'
        }
        
        return xml_data;
    }
    
    /* 
     * Function to refresh grid of General Tab
     */
    refresh_general_grid = function() {
        general_deleted = [];
        var param = {
                        "action": "spa_setup_generator",
                        "flag": "g",
                        "source_deal_header_id": source_deal_header_id
                    };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        setup_generation.general_grid.clearAll();
        setup_generation.general_grid.loadXML(param_url);
    }
    
    
    /* 
     * Function to refresh grid of Data Tab
     */
    refresh_data_grid = function() {
        data_deleted = [];
        var effective_date = setup_generation.data_filter_form.getItemValue('effective_date', true);
        var end_date = setup_generation.data_filter_form.getItemValue('end_date', true);
        var tou = setup_generation.data_filter_form.getItemValue('tou');
        var hour_start = setup_generation.data_filter_form.getItemValue('hour_start');
        var hour_end = setup_generation.data_filter_form.getItemValue('hour_end');
        var type = setup_generation.data_filter_form.getItemValue('type');
        var period = setup_generation.data_filter_form.getItemValue('period');
        var value = setup_generation.data_filter_form.getItemValue('value');
            
        var param = {
                        "action": "spa_setup_generator",
                        "flag": "s",
                        "source_deal_header_id": source_deal_header_id,
                        "effective_date": effective_date,
                        "end_date": end_date,
                        "tou": tou,
                        "hour_start": hour_start,
                        "hour_end": hour_end,
                        "type": type,
                        "value": value,
                        "period": period
                    };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        setup_generation.data_grid.clearAll();
        setup_generation.data_grid.loadXML(param_url);
    }
    
    
    /* 
     * Function to refresh grid of Owner Tab
     */
    refresh_owner_grid = function() {
        owner_deleted = [];
        var param = {
                        "action": "spa_setup_generator",
                        "flag": "o",
                        "source_deal_header_id": source_deal_header_id
                    };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        setup_generation.owner_grid.clearAll();
        setup_generation.owner_grid.loadXML(param_url);
    }
    
    
    /* 
     * Function to refresh grid of Outage/Derage Tab
     */
    refresh_outage_derate_grid = function() {
        outage_derate_deleted = [];
        var param = {
                        "action": "spa_setup_generator",
                        "flag": "p",
                        "source_deal_header_id": source_deal_header_id
                    };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        setup_generation.outage_derate_grid.clearAll();
        setup_generation.outage_derate_grid.loadXML(param_url, function() {
            refresh_outage_derate_grid_callback();
        });
    }
    
    refresh_outage_derate_grid_callback = function() {
        setup_generation.outage_derate_grid.forEachRow(function(id){
            var outage_derate = setup_generation.outage_derate_grid.cells(id, 1).getValue();
            
            if (outage_derate == 'o') {
                setup_generation.outage_derate_grid.cells(id,setup_generation.outage_derate_grid.getColIndexById('derate_mw')).setDisabled(true);
                setup_generation.outage_derate_grid.cells(id,setup_generation.outage_derate_grid.getColIndexById('derate_percent')).setDisabled(true);
            } else {
                setup_generation.outage_derate_grid.cells(id,setup_generation.outage_derate_grid.getColIndexById('derate_mw')).setDisabled(false);
                setup_generation.outage_derate_grid.cells(id,setup_generation.outage_derate_grid.getColIndexById('derate_percent')).setDisabled(false);
            }
        });
    }
    
    
    /* 
     * Function to refresh grid of Operation Unit Configuration Tab
     */
    refresh_configuration_grid = function() {
        configuration_deleted = [];
        var param = {
                        "action": "spa_setup_generator",
                        "flag": "c",
                        "source_deal_header_id": source_deal_header_id
                    };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        setup_generation.configuration_grid.clearAll();
        setup_generation.configuration_grid.loadXML(param_url);
    }
    
    
</script>