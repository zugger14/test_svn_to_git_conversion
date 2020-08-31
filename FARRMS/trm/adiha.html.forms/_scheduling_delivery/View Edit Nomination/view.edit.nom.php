<?php
/**
* View edit nom screen
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
</head>
<body >
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $form_function_id = 10164400;
	$rights_save = 10164410;
    $rights_send_confirmation = 10164412;
    $rights_send_scheduled_qty = 10164413;
    $rights_send_allocated_qty = 10164414;

    list (
        $has_right_form_function_id,
        $has_rights_save,
        $has_rights_send_confirmation,
        $has_rights_send_scheduled_qty,
        $has_rights_send_allocated_qty
    ) = build_security_rights(
        $form_function_id,
        $rights_save,
        $rights_send_confirmation,
        $rights_send_scheduled_qty,
        $rights_send_allocated_qty
    );

    $has_rights_save = ($has_rights_save != '') ? "true" : "false";
    $has_rights_send_confirmation = ($has_rights_send_confirmation != '') ? "true" : "false";
    $has_rights_send_scheduled_qty = ($has_rights_send_scheduled_qty != '') ? "true" : "false";
    $has_rights_send_allocated_qty = ($has_rights_send_allocated_qty != '') ? "true" : "false";

    $form_namespace = 'view_edit_nom';
    //Layout
    $layout_json = '[
        //{id: "a", text: " ", header: true, height: 0, collapse: true},
        {id: "a", text: "Filters", header: true, height:145},
        {id: "b", text: "Nominations", header: true}
    ]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('view_edit_nom_layout', '', '2E', $layout_json, $form_namespace);
    //Filter Form
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=$form_function_id, @template_name='ViewEditNom', @group_name='General'";
    $filter_arr = readXMLURL2($filter_sql);
    $tab_id = $filter_arr[0]['tab_id'];
    $form_json = $filter_arr[0]['form_json'];
    
    $filter_form_name = 'filter_form';
    $filter_form_obj = new AdihaForm();
    echo $layout_obj->attach_form($filter_form_name, 'a');
    $filter_form_obj->init_by_attach($filter_form_name, $form_namespace);
    echo $filter_form_obj->load_form($form_json);
    echo $filter_form_obj->attach_event('', 'onChange', 'filter_form_onchange');
        
    //Grid Menu
    $menu_json = "[
                    {id:'refresh', text:'Refresh', img:'refresh.gif'},
                    {id:'export', text:'Export', img:'export.gif', imgdis:'export_dis.gif', items:[
                        {id:'excel', text:'Excel', img:'excel.gif', imgdis:'excel_dis.gif', title: 'Excel'},
                        {id:'pdf', text:'PDF', img:'pdf.gif', imgdis:'pdf_dis.gif', title: 'PDF'}
                    ], disabled:false},
                    //{id:'save', text:'Save', img:'save.gif', imgdis:'save_dis.gif', enabled: '$has_rights_save'},
                    {id:'action', text:'Action', img:'action.gif', imgdis:'action_dis.gif', disabled:false, items:[
                        {id:'save', text:'Save', img:'save.gif', imgdis:'save_dis.gif', title: 'Save', enabled: '$has_rights_save'},
                        {id:'send_confirmation', text:'Send Confirmation', img:'send_confirmation.gif', imgdis:'send_confirmation_dis.gif', title: 'Send Confirmation', enabled: '$has_rights_send_confirmation'},
                        {id:'send_sch_qty', text:'Send Scheduled Qty', img:'send_schedule_qty.gif', imgdis:'send_schedule_qty_dis.gif', title: 'Send Scheduled Qty', enabled: '$has_rights_send_scheduled_qty'},
                        {id:'send_allc_qty', text:'Send Allocated Qty', img:'send_allocate_qty.gif', imgdis:'send_allocate_qty_dis.gif', title: 'Send Allocated Qty', enabled: '$has_rights_send_allocated_qty'}
                    ]},
                    {id:'pivot', text:'Pivot', img:'pivot.gif', imgdis:'pivot_dis.gif',enabled:'false'}
                ]";
    echo $layout_obj->attach_menu_layout_cell("view_edit_nom_menu", "b", $menu_json, $form_namespace.'.menu_click');
    echo $layout_obj->close_layout();
    
?>

</body>
<script>
    
    $(function() {
        view_edit_nom.fx_attach_events();
        date_obj = new Date();
        date_obj_week = new Date();
        date_obj_week.setDate(date_obj.getDate() + 7);
        view_edit_nom.fx_initial_load(); 

    });
   
    //function to be load on start
    view_edit_nom.fx_initial_load = function() {
        //view_edit_nom.view_edit_nom_layout.cells('a').hideArrow();
        view_edit_nom.filter_form.setItemValue('term_start', date_obj);
        term_start = view_edit_nom.filter_form.getItemValue('term_start');
        view_edit_nom.filter_form.setItemValue('term_end', dates.getTermEnd(term_start, 'm'));
        //view_edit_nom.filter_form.setItemValue('term_end', '2015-10-01');
        view_edit_nom.cmb_contract_onclose();
        view_edit_nom.refresh_view_edit_nom_grid();        
    }
    //function to attach events on form fields.
    view_edit_nom.fx_attach_events = function () {
        dhxCombo_contract = view_edit_nom.filter_form.getCombo("contract");
        dhxCombo_contract.attachEvent("onClose", view_edit_nom.cmb_contract_onclose);
        //console.dir(dhxCombo_contract);
    };
    //function to set comma separated selected options on combo text.
    function fx_set_combo_text_final(cmb_obj) {
        var checked_loc_arr = cmb_obj.getChecked();
        var final_combo_text = new Array();
        var final_combo_value = new Array();
        $.each(checked_loc_arr, function(i) {
            var opt_obj = cmb_obj.getOption(checked_loc_arr[i]);
            final_combo_text.push(opt_obj.text);
            final_combo_value.push(opt_obj.value);  
        });
        cmb_obj.setComboText(final_combo_text.join(','));
        
    }
    //event on onClose of contract dropdown
    view_edit_nom.cmb_contract_onclose = function() {
        fx_set_combo_text_final(dhxCombo_contract);
    };
    
    /**
     * [menu_click Menu click function for invoice grid]
     * @param  {[type]} id     [Menu id]
     */
    view_edit_nom.menu_click = function(id) {
        switch(id) {
            case "refresh":
                view_edit_nom.refresh_view_edit_nom_grid();
                break;
            case "excel":
                view_edit_nom.view_edit_nom_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                view_edit_nom.view_edit_nom_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "save":
                view_edit_nom.save_grid_data();
                break;
            case "send_confirmation":
                view_edit_nom.send_confirmation();
                break;
			case "send_sch_qty":
                view_edit_nom.send_quantity('s');
                break;
			case "send_allc_qty":
                view_edit_nom.send_quantity('a');
                break;
            case 'pivot':
                var grid_obj = view_edit_nom.view_edit_nom_grid;
                open_grid_pivot(grid_obj, 'view_edit_nom_grid', 1, pivot_exec_spa, 'View and Edit Nominations');
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Under Maintainence! We will be back soon!"
                });
                break;
        }
    }
    
    view_edit_nom.refresh_view_edit_nom_grid = function() {
        
        var term_start = view_edit_nom.filter_form.getItemValue('term_start', true);
        var term_end = view_edit_nom.filter_form.getItemValue('term_end', true);
        var pipeline = view_edit_nom.filter_form.getItemValue('pipeline');
        var shipper = view_edit_nom.filter_form.getItemValue('shipper'); 
        var contract_id = dhxCombo_contract.getChecked().join(',');
        //assign null when value is blank
        term_start = term_start == '' ? 'NULL' : term_start;
        term_end = term_end == '' ? 'NULL' : term_end;
        pipeline = pipeline == '' ? 'NULL' : pipeline;
        shipper = shipper == '' ? 'NULL' : shipper;
        contract_id = contract_id == '' ? 'NULL' : contract_id;

        if(term_end != 'NULL' && term_start != 'NULL') {
            if ( term_end < term_start ) {
                show_messagebox("'<strong>Flow Date From</strong> should be less than <strong>Flow Date To</strong>.'");
                return;
            }    
        }
        
        /*
        data = {"action": "spa_view_edit_nom",
                    "flag": "h",
                    "term_start": term_start,
                    "term_end": term_end
                };
                */
        view_edit_nom.view_edit_nom_layout.cells("b").progressOn();
        data = {"action": "spa_view_edit_nom",
                    "flag": "x",
                    "term_start": term_start,
                    "term_end": term_end,
                    "pipeline": pipeline,
                    "shipper": shipper,
                    "contract_id": contract_id
                };                
        adiha_post_data('return_json', data, '', '', 'view_edit_nom.create_grid', '', '');
    }
    json_grid_info_gbl = {};
    view_edit_nom.create_grid = function(result) {
        grid_creation_status.status = 0;
        var json_obj = $.parseJSON(result);
        json_grid_info_gbl = json_obj;       
        //alert('[' + json_obj[0].header_row_groupby + ']');return;
        //view_edit_nom.view_edit_nom_layout.cells('a').collapse();        
        
        //Create Grid
        var grid_type = json_obj[0].grid_type;
        var process_id = json_obj[0].process_id;
                
        view_edit_nom.view_edit_nom_grid = view_edit_nom.view_edit_nom_layout.cells('b').attachGrid();
        //view_edit_nom.view_edit_nom_layout.cells('b').attachStatusBar({
//                                        height: 30,
//                                        text: '<div id="pagingArea_b"></div>'
//                                    });
        view_edit_nom.view_edit_nom_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
        view_edit_nom.view_edit_nom_grid.setHeader(get_locale_value(json_obj[0].header_col_name, true));
        view_edit_nom.view_edit_nom_grid.setColTypes(json_obj[0].header_col_type);
        view_edit_nom.view_edit_nom_grid.setColSorting(json_obj[0].header_col_sorting);
        view_edit_nom.view_edit_nom_grid.setColumnIds(json_obj[0].header_col_id);
        view_edit_nom.view_edit_nom_grid.setColumnsVisibility(json_obj[0].header_col_visibility);
        view_edit_nom.view_edit_nom_grid.setInitWidths(json_obj[0].header_col_width);
        view_edit_nom.view_edit_nom_grid.attachHeader(json_obj[0].header_col_filter);
        
        var i = 1;
        while(i <= json_obj[0].no_of_terms) {
            view_edit_nom.view_edit_nom_grid.setNumberFormat("0,000", view_edit_nom.view_edit_nom_grid.getColIndexById('vol_type') + i, ".", ",");
            i++;
        }
                
        view_edit_nom.view_edit_nom_grid.init();
        view_edit_nom.view_edit_nom_grid.enableHeaderMenu();
        
        view_edit_nom.view_edit_nom_grid.attachEvent('onEditCell', function(stage, rid, cid, n_val, o_val) {
            if(stage == 2) {
                if(isNaN(n_val) || n_val == '') {
                    return false;
                } else {
                    if((view_edit_nom.view_edit_nom_grid.getColumnId(cid) == 'rank' || view_edit_nom.view_edit_nom_grid.getColumnId(cid) == 'package_id'
                        || (cid > view_edit_nom.view_edit_nom_grid.getColIndexById('vol_type')))) 
                    {
                        if(cid > view_edit_nom.view_edit_nom_grid.getColIndexById('vol_type')
                            && view_edit_nom.view_edit_nom_grid.cells(rid,view_edit_nom.view_edit_nom_grid.getColIndexById('receipt_delivery')).getValue() == 'Del') 
                        {
                            var sg_obj = view_edit_nom.view_edit_nom_grid.cells(rid,view_edit_nom.view_edit_nom_grid.getColIndexById('source_deal_header_id')).getSubGrid();
                            var fnom_calculated = n_val * (1-parseFloat(view_edit_nom.view_edit_nom_grid.cells(rid,view_edit_nom.view_edit_nom_grid.getColIndexById('fuel')).getValue()));
                            sg_obj.cells(0,sg_obj.getColIndexById(view_edit_nom.view_edit_nom_grid.getColumnId(cid))).setValue(Math.round(fnom_calculated));
                        }
                    }
                    
                    return true;
                }
            }
            
        });
        
        load_dropdown("EXEC spa_source_counterparty_maintain @flag=''c'', @type_of_entity=301994", view_edit_nom.view_edit_nom_grid.getColIndexById('pipeline'), '');
        load_dropdown("EXEC spa_contract_group @flag=''r''", view_edit_nom.view_edit_nom_grid.getColIndexById('contract'), '');
        load_dropdown("EXEC spa_source_counterparty_maintain @flag=''c''", view_edit_nom.view_edit_nom_grid.getColIndexById('up_dn_counterparty'), '');
        load_dropdown("EXEC spa_source_minor_location ''o''", view_edit_nom.view_edit_nom_grid.getColIndexById('location'), '');
        
        var param = {
                        "flag": "y",
                        "action": "spa_view_edit_nom",
                        "process_id": process_id,
                        "call_from": 'main_grid'
                    };

        pivot_exec_spa = "EXEC spa_view_edit_nom @flag='y', @process_id='" +  process_id
                    + "', @call_from=main_grid";

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        view_edit_nom.view_edit_nom_grid.clearAll();
        view_edit_nom.view_edit_nom_menu.setItemEnabled('pivot');
        //LOAD GRID DATA
        view_edit_nom.view_edit_nom_grid.load(param_url, function() {
            view_edit_nom.view_edit_nom_layout.cells("b").progressOff();
            
            //remove sub grid from net row
            view_edit_nom.view_edit_nom_grid.forEachRow(function(rid) {
                if(this.cells(rid, this.getColIndexById('receipt_delivery')).getValue() == 'Net') {
                    this.setCellExcellType(rid, this.getColIndexById('source_deal_header_id'), 'ro');
                    //console.log(this.cells(rid, this.getColIndexById('source_deal_header_id')).getValue());
                    if(this.cells(rid, this.getColIndexById('source_deal_header_id')).getValue() == -2) {
                        this.cells(rid, this.getColIndexById('receipt_delivery')).setValue('Fuel');
                    } else {
                        this.cells(rid, this.getColIndexById('receipt_delivery')).setValue('Net Volume');
                    }
                    
                }
            });
            
            //remove sub grid while location is blank and also made volume cell readonly
            view_edit_nom.view_edit_nom_grid.forEachRow(function(rid){
                if(this.cells(rid, this.getColIndexById('location')).getValue() == '') {
                    this.setCellExcellType(rid, this.getColIndexById('source_deal_header_id'), 'ro');
                    this.cells(rid, this.getColIndexById('source_deal_header_id')).setValue('');
                    
                    this.forEachCell(rid, function(cell_obj, cid) {
                        if(cid > view_edit_nom.view_edit_nom_grid.getColIndexById('vol_type')) {
                            view_edit_nom.view_edit_nom_grid.setCellExcellType(rid, cid, 'ro');
                        }
                    });
                }
            });
            
            
            
        });
        view_edit_nom.view_edit_nom_grid.customGroupFormat = function(name, count){
            switch(name) {
                case 'Receipt':
                    return 'Receipt Total';
                case 'Del':
                    return 'Delivery Total';
                case 'Net':
                    return 'Net';
                default: 
                    return 'None';
            }
        }
        eval("view_edit_nom.view_edit_nom_grid.groupBy(view_edit_nom.view_edit_nom_grid.getColIndexById('receipt_delivery'),[" + 
            json_obj[0].header_row_groupby + "]);"); 
        //view_edit_nom.view_edit_nom_grid.collapseAllGroups();
        //view_edit_nom.view_edit_nom_grid.collapseGroup('Net');
        //view_edit_nom.view_edit_nom_grid.collapseGroup('Net');
        
        
        
        if(json_obj[0].no_of_terms > 0) {
            create_sub_grids(json_obj);
        } else {
            view_edit_nom.view_edit_nom_layout.cells("b").progressOff();
        }
        
        
    }
    
    function load_dropdown(sql_stmt, column_index, callback_function) {
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": sql_stmt,
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = view_edit_nom.view_edit_nom_grid.getColumnCombo(column_index);                
        if (callback_function != '')
            combo_obj.load(url, callback_function);
        else 
            combo_obj.load(url);
    }
    
    grid_creation_status = {};
    grid_creation_status.status = 0;
    function create_sub_grids(json_obj) {
        if ((grid_creation_status.status) == 0) {
            grid_creation_status.status = 1;
            view_edit_nom.view_edit_nom_grid.callEvent("onGridReconstructed", []);

            view_edit_nom.view_edit_nom_grid.attachEvent("onSubGridCreated", function(view_edit_nom_sub_grid, id, ind) {
                
                view_edit_nom_sub_grid.setImagePath(js_php_path + "components/dhtmlxSuite/codebase/imgs/");
                view_edit_nom_sub_grid.setHeader(get_locale_value(json_obj[1].header_col_name,true));
                view_edit_nom_sub_grid.setColumnIds(json_obj[1].header_col_id);
                view_edit_nom_sub_grid.setColTypes(json_obj[1].header_col_type);
                view_edit_nom_sub_grid.setColSorting(json_obj[1].header_col_sorting);
                view_edit_nom_sub_grid.setColumnsVisibility(json_obj[1].header_col_visibility);
                view_edit_nom_sub_grid.setInitWidths(json_obj[1].header_col_width);
                view_edit_nom_sub_grid.setNoHeader(true);
                //view_edit_nom_sub_grid.setRowExcellType(1,"ro");
                
                var i = 1;
                while(i <= json_obj[1].no_of_terms) {
                    view_edit_nom_sub_grid.setNumberFormat("0,000", view_edit_nom.view_edit_nom_grid.getColIndexById('vol_type') + i, ".", ",");
                    i++;
                }
                view_edit_nom_sub_grid.setStyle('','background-color:#F8E8B8','','background-color:#F7D97E !important');
                
                view_edit_nom_sub_grid.init();
                
                view_edit_nom_sub_grid.attachEvent('onEditCell', function(stage, rid, cid, n_val, o_val) {
                    if(stage == 2) {
                        if(isNaN(n_val) || n_val == '' || n_val == o_val) {
                            return false;
                        } else {
                            return true;
                        }
                        
                        
                    }
                });
                
                var param = {
                    "flag": "y",
                    "action": "spa_view_edit_nom",
                    "process_id": json_obj[1].process_id,
                    "source_deal_header_id": view_edit_nom.view_edit_nom_grid.cells(id, view_edit_nom.view_edit_nom_grid.getColIndexById('source_deal_header_id')).getValue(),
                    "call_from": 'sub_grid',
                    "receipt_delivery": view_edit_nom.view_edit_nom_grid.cells(id, view_edit_nom.view_edit_nom_grid.getColIndexById('receipt_delivery')).getValue()
                };
                //console.dir(param);
        
                param = $.param(param);
                
                var param_url = js_data_collector_url + "&" + param;
                view_edit_nom_sub_grid.clearAll();
                
                //after finished loading the data, fire sub grid reconstruct event so that the height of the parent grid is maintained when expanded.
                view_edit_nom_sub_grid.load(param_url, function() {
                    
                    view_edit_nom_sub_grid.callEvent("onGridReconstructed", []);
                    
                    view_edit_nom_sub_grid.forEachRow(function(rid) {
                        if(view_edit_nom_sub_grid.cells(rid, view_edit_nom_sub_grid.getColIndexById('vol_type')).getValue() == 'FNOM') {
                            view_edit_nom_sub_grid.forEachCell(rid, function(cell_obj, cid) {
                                if(cid > view_edit_nom_sub_grid.getColIndexById('vol_type')) {
                                    view_edit_nom_sub_grid.setCellExcellType(rid, cid, 'ro');
                                }
                            });
                        }
                    });
                    
                });
                return true;
                
            });
            
        }
        
    }
    //save click on menu
    view_edit_nom.save_grid_data = function() {
        var grid_xml = "";
        if (view_edit_nom.view_edit_nom_grid instanceof dhtmlXGridObject) {
            view_edit_nom.view_edit_nom_grid.clearSelection();
            var ids = view_edit_nom.view_edit_nom_grid.getChangedRows(true);
            term_start = json_grid_info_gbl[0].term_start_range;
            term_end = json_grid_info_gbl[0].term_end_range;
            
            if(ids != "") {
                grid_xml += "<Grid term_start=\"" + term_start + "\" term_end=\"" + term_end + "\">";
                
                var changed_ids = new Array();
                changed_ids = ids.split(",");
                var col_count = view_edit_nom.view_edit_nom_grid.getColumnsNum();
                $.each(changed_ids, function(index, value) {
                    grid_xml += '<GridRow deal_ref_id="' + view_edit_nom.view_edit_nom_grid.cells(value, view_edit_nom.view_edit_nom_grid.getColIndexById('source_deal_header_id')).getValue() + 
                        '" location_id="' + view_edit_nom.view_edit_nom_grid.cells(value, view_edit_nom.view_edit_nom_grid.getColIndexById('location_id')).getValue() +
                        '" deal_ref="' + view_edit_nom.view_edit_nom_grid.cells(value, view_edit_nom.view_edit_nom_grid.getColIndexById('ref_id')).getValue() +
                        '" location="' + view_edit_nom.view_edit_nom_grid.cells(value, view_edit_nom.view_edit_nom_grid.getColIndexById('location')).getValue() +
                        '" bom="0"';
                    for(var cellIndex = view_edit_nom.view_edit_nom_grid.getColIndexById('vol_type') + 1; cellIndex < col_count; cellIndex++){
                        var cell_value = view_edit_nom.view_edit_nom_grid.cells(value,cellIndex).getValue();
                        var subgrid_obj = view_edit_nom.view_edit_nom_grid.cells(value,view_edit_nom.view_edit_nom_grid.getColIndexById('source_deal_header_id')).getSubGrid();
                        var vol_del = subgrid_obj.cells(0,subgrid_obj.getColIndexById(view_edit_nom.view_edit_nom_grid.getColumnId(cellIndex))).getValue();
                        
                        if(view_edit_nom.view_edit_nom_grid.cells(value, view_edit_nom.view_edit_nom_grid.getColIndexById('receipt_delivery')).getValue() == 'Del') {
                            cell_value = vol_del;
                        }
                        
                        if (cell_value == '') {
                            cell_value = '-1';
                        }
                        grid_xml += " _" + view_edit_nom.view_edit_nom_grid.getColumnId(cellIndex) + '="' + cell_value + '"';
                    }
                    grid_xml += " ></GridRow> ";
                });
                grid_xml += "</Grid>";
            }
            
        }
        data = {"action": "spa_update_demand_volume", "flag": "u", "xml": grid_xml};
        //console.dir(data);
        adiha_post_data("return_json", data, "", "", "view_edit_nom.save_grid_data_ajx");
        
    }
    view_edit_nom.save_grid_data_ajx = function(result) {
        var json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Deal Volume updated successfully.', 'error');
            view_edit_nom.refresh_view_edit_nom_grid();
        } else {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: 'Error on deal volume update. (SQL Error)'
            });
        }
    };
    function validate_filter() {
        var term_start =  view_edit_nom.filter_form.getItemValue('term_start', true);
        var term_end =  view_edit_nom.filter_form.getItemValue('term_end', true);
        
        if (term_start > term_end) {
            show_messagebox('Term End should not be less than Term Start.');
            return false;
        }
        term_end_date = new Date(term_end);
        term_start_date = new Date(term_start);
        var time_difference = Math.abs(term_start_date.getTime() - term_end_date.getTime());
        var days_difference = Math.ceil(time_difference / (1000 * 3600 * 24));
        
        if (days_difference > 29) {
            show_messagebox('The gap between Term Start and Term End should not be more than 30 days.');
            return false;
        }
    }
	
	view_edit_nom.send_confirmation = function() {
		var selected_row = view_edit_nom.view_edit_nom_grid.getSelectedRowId();
		var term_start = view_edit_nom.filter_form.getItemValue('term_start', true);
        var term_end = view_edit_nom.filter_form.getItemValue('term_end', true);
		grid_xml = "<GridXML><GridRow";
		for(var cellIndex = 0; cellIndex < view_edit_nom.view_edit_nom_grid.getColIndexById('vol_type'); cellIndex++){
			var column_id = view_edit_nom.view_edit_nom_grid.getColumnId(cellIndex);						
			var cell_value = view_edit_nom.view_edit_nom_grid.cells(selected_row, cellIndex).getValue();
			
			grid_xml += ' ' + column_id + '="' + cell_value + '"';
		}
		grid_xml += " ></GridRow></GridXML>";
		
		data = {"action": "spa_view_edit_nom", "flag":"z", "term_start":term_start, "term_end":term_end, "xml":grid_xml};
		adiha_post_data("alert", data, '', '');		
	}
	
	view_edit_nom.send_quantity = function(type) {
		var flag = (type == 's') ? 'v' : 'w';
		var term_start = view_edit_nom.filter_form.getItemValue('term_start', true);
		var shipper = view_edit_nom.filter_form.getItemValue('shipper');
        var term_end = view_edit_nom.filter_form.getItemValue('term_end', true);
		var process_id_index = view_edit_nom.view_edit_nom_grid.getColIndexById('process_id');
        var process_ids = view_edit_nom.view_edit_nom_grid.collectValues(process_id_index); 
        var process_id = process_ids[0];
		var temp_csv_path = <?php echo "'" . addslashes(addslashes($BATCH_FILE_EXPORT_PATH)) . "'"; ?> ;
		temp_csv_path = temp_csv_path.replace(/\\\\/g, '\\');
		
		data = {"action": "spa_view_edit_nom", "flag":flag, "term_start":term_start, "term_end":term_end, "process_id":process_id, "shipper":shipper, "folder_path":temp_csv_path};
		adiha_post_data("alert", data, '', '');	
	}
    
    function filter_form_onchange(name, value, is_checked) {
        if (name == 'term_start') {
            term_start = view_edit_nom.filter_form.getItemValue('term_start');
            view_edit_nom.filter_form.setItemValue('term_end', dates.getTermEnd(term_start, 'm'));
        }
    }

</script>
