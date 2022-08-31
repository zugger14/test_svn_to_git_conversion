<?php
/**
* View volatility screen
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
    
<body>
    <?php   
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $rights_view_volatility = 20000600;
    $rights_view_volatility_edit = 20000600;

    list (
        $has_rights_view_volatility,
        $has_rights_view_volatility_edit
    )  = build_security_rights(
        $rights_view_volatility,
        $rights_view_volatility_edit
    );

    $namespace = 'view_volatility';
    $json = '[
                {
                    id:             "a",
                    text:           "Risk Buckets",
                    header:         true,
                    collapse:       false,
                    width:          350,
                    height:         125,
                    undock:         true
                },
                {
                    id:             "b",
                    height:         100,
                    header:         true,
                    collapse:       true,
                    text:           "Apply Filters",
                    fix_size:       [false,null]
                },
                {
                    id:             "c",
                    text:           "Filters",
                    header:         true,
                    collapse:       false,
                    text:           "Filters",
                    height:         145
                },
                {
                    id:             "d",
                    text:            "",
                    undock:          true,
                    header:         false,
                    collapse:       false
                }
            ]';
    $view_volatility_layout_obj = new AdihaLayout();
    echo $view_volatility_layout_obj->init_layout('view_volatility_layout', '', '4C', $json, $namespace);
    echo $view_volatility_layout_obj->attach_event('', 'onDock', 'view_volatility.on_dock_event');
    echo $view_volatility_layout_obj->attach_event('', 'onUnDock', 'view_volatility.on_undock_event');
    
    $view_volatility_menu = 'view_volatility_menu';
    $view_volatility_menu_json = '[
                                {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                                ]},
                                {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"},
                                {id:"select_unselect", text:"Select/Unselect", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1}
                            ]';

    echo $view_volatility_layout_obj->attach_menu_layout_cell($view_volatility_menu, 'a', $view_volatility_menu_json, $namespace.'.view_volatility_menu_click');

    //attach grid
    $curve_grid_name = 'curve_grid';
    echo $view_volatility_layout_obj->attach_status_bar("a", true);
    echo $view_volatility_layout_obj->attach_grid_cell($curve_grid_name, 'a');
    $curve_grid_obj = new GridTable('setup_price_curve');
    echo $curve_grid_obj->init_grid_table($curve_grid_name, $namespace);
    echo $curve_grid_obj->enable_multi_select();
    echo $curve_grid_obj->set_search_filter(true); 
    echo $curve_grid_obj->return_init();
    echo $curve_grid_obj->load_grid_data("EXEC spa_source_price_curve_def_maintain 't', @granularity = '30' , @is_active = 'y'");
    
    echo $curve_grid_obj->enable_paging(100, 'pagingArea_a', 'true');
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20000600', @template_name='view volatility', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $tab_id = $form_arr[0]['tab_id'];
    $form_json = $form_arr[0]['form_json'];
    echo $view_volatility_layout_obj->attach_form('view_volatility_filter_form', 'c');
    $view_volatility_filter_form_obj = new AdihaForm();
    echo $view_volatility_filter_form_obj->init_by_attach('view_volatility_filter_form', $namespace);
    echo $view_volatility_filter_form_obj->load_form($form_json);

    $volatility_values_menu = 'volatility_values_menu';
    $volatility_values_menu_json = '[
                                {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                                {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled: "'. $has_rights_view_volatility_edit .'"},
                                {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", enabled: "'. $has_rights_view_volatility_edit .'"},
                                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", enabled: "'. $has_rights_view_volatility_edit .'"}
                                ]},
                                {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled: 1},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled: 1},
                                    {id:"batch", text:"Batch", img:"batch.gif", imgdis:"batch_dis.gif", enabled: "' . $has_rights_view_volatility_edit . '"}
                                ]},
                                {id:"select_unselect", text:"Select/Unselect", img:"select_unselect.gif", imgdis:"exp_col_dis.gif", enabled: 1},
                                {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif", enabled: 1}
                            ]';
    echo $view_volatility_layout_obj->attach_menu_layout_cell($volatility_values_menu, 'd', $volatility_values_menu_json, $namespace.'.volatility_value_menu_click');
    echo $view_volatility_layout_obj->close_layout();
    ?>
</body>
    
<script>
    var has_rights_view_volatility_edit = <?php echo (($has_rights_view_volatility_edit) ? $has_rights_view_volatility_edit : '0'); ?>;
    var expand_state = 0;
    var forward_header_level_cnt, forward_fxd_header;
    var forward_delete_xml;
    var forward_settlement_status;
    var client_date_format = '<?php echo $date_format; ?>';
    
    $(function() {      
        view_volatility.volatility_values_menu.setItemDisabled('delete');
        view_volatility.volatility_values_menu.setItemDisabled('save');   
        view_volatility.volatility_values_menu.setItemDisabled('add');  
        view_volatility.volatility_values_menu.setItemDisabled('export');   
        view_volatility.volatility_values_menu.setItemDisabled('excel');   
        view_volatility.volatility_values_menu.setItemDisabled('pdf');  
        view_volatility.volatility_values_menu.setItemDisabled('batch');
        view_volatility.volatility_values_menu.setItemDisabled('select_unselect');   
        view_volatility.volatility_values_menu.setItemDisabled('pivot');  
        view_volatility.volatility_values_menu.setItemDisabled('edit');

        var curve_source_obj = view_volatility.view_volatility_filter_form.getCombo('curve_source');
        curve_source_obj.setChecked(1, true);
        curve_source_obj.setComboValue(4500);
                
        var today = new Date();
        var as_of_date = new Date(today.getFullYear(), today.getMonth() , today.getDate());
        view_volatility.view_volatility_filter_form.setItemValue('as_of_date_from', as_of_date);

        var filter_obj = view_volatility.view_volatility_layout.cells('b').attachForm();
        var layout_cell_obj = view_volatility.view_volatility_layout.cells('c');
        var function_id =  '<?php echo $rights_view_volatility; ?>';
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', view_volatility); 

        filter_obj.attachEvent("onBeforeChange",function(name,oldValue,newValue){
			view_volatility.curve_grid.expandAll();
            return true;
        });

        view_volatility.curve_grid.attachEvent("onRowDblClicked", function(rId,cInd){
            view_volatility.expand_price_curve(rId,cInd);
        });
    });

    view_volatility.view_volatility_menu_click = function(id) {
        switch(id) {
            case 'excel':
                view_volatility.export('excel', view_volatility.curve_grid);
            break;
            case 'pdf':
                view_volatility.export('pdf', view_volatility.curve_grid);
            break;
            case 'select_unselect':
                view_volatility.select_unselect(view_volatility.curve_grid);
            break;
            case 'expand_collapse':
                view_volatility.expand_collapse(view_volatility.curve_grid);
            break;
        }
    }
    
    view_volatility.volatility_value_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'refresh':
                volatility_values_refresh();
                break;
            case 'save':
                if (forward_del_flag == 1) {
                    var gname;
                    if (forward_del_flag == 1) { gname = 'Volatility Values'; }
                    del_msg =  "Some data has been deleted from " + gname + " grid. Are you sure you want to save?";
                    dhtmlx.message({
                        type: "confirm",
                        title: "Confirmation",
                        ok: "Confirm",
                        text: del_msg,
                        callback: function(result) {
                            if (result)
                                volatility_values_save();                
                        }
                    });
                } else {
                    volatility_values_save();
                }
                break;
            case 'add':
                var new_id = (new Date()).valueOf();
                forward_grid.addRow(new_id, '');
                forward_grid.cells(new_id, 0).setValue(new_date);
                break;
            case 'delete':
                volatility_value_delete();
                break;
            case 'excel':
                view_volatility.export('excel', forward_grid);
                break;
            case 'pdf':
                view_volatility.export('pdf', forward_grid);
                break;  
            case 'select_unselect':
                view_volatility.select_unselect(forward_grid);
                break;
            case 'pivot':
                view_volatility.click_pivot();
                break;
             case 'batch':
                volatility_value_batch();
                break;
        }
    }
    
    volatility_values_refresh = function() {
        var form_obj = view_volatility.view_volatility_layout.cells('c').getAttachedObject();
        var status = validate_form(form_obj);
        if (status == false) { return; }
        
        var source_price_curve_arr = new Array();
        var selected_row = view_volatility.curve_grid.getSelectedId();
        var granularity_check = 0;
        granularity = '';
        var granularity_id = '';

        if (selected_row != null) {
            var selected_row_arr = selected_row.split(',');
            for(i = 0; i < selected_row_arr.length; i++) {
                if ((view_volatility.curve_grid.cells(selected_row_arr[i],view_volatility.curve_grid.getColIndexById('s_granularity')).getValue()) != (view_volatility.curve_grid.cells(selected_row_arr[0],view_volatility.curve_grid.getColIndexById('s_granularity')).getValue())) {
                    granularity_check = 1;
                }
                var tree_level = view_volatility.curve_grid.getLevel(selected_row_arr[i]);
                
                if (tree_level == 1) {
                    
                    var value = view_volatility.curve_grid.cells(selected_row_arr[i], view_volatility.curve_grid.getColIndexById('source_curve_def_id')).getValue();
                    source_price_curve_arr.push(value);
                }
                granularity = view_volatility.curve_grid.cells(selected_row_arr[0],view_volatility.curve_grid.getColIndexById('s_granularity')).getValue();
                granularity_id = view_volatility.curve_grid.cells(selected_row_arr[0],view_volatility.curve_grid.getColIndexById('s_granularity_id')).getValue();
            }
        }
        
        var source_price_curve = source_price_curve_arr.toString();
        if (source_price_curve == '') {
            show_messagebox('Please select a price curve.');
            return;
        }

        if (granularity_check == 1) {
            show_messagebox('Please select the price curves of same granularity.');
            return;
        }

        var as_of_date_from = view_volatility.view_volatility_filter_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_volatility.view_volatility_filter_form.getItemValue('as_of_date_to', true);
        
        if (as_of_date_to == '') {
            as_of_date_to = as_of_date_from;
        }
        
        if (as_of_date_to != '' && as_of_date_from != '' && as_of_date_from > as_of_date_to) {
            show_messagebox('As of Date To should be greater than As of Date From.');
            return;
        }
        
        var tenor_from = view_volatility.view_volatility_filter_form.getItemValue('tenor_from', true);
        var tenor_to = view_volatility.view_volatility_filter_form.getItemValue('tenor_to', true);

        if(tenor_from != '') { // Showing first day of month by default.
            var m_date = new Date(tenor_from);
            y = m_date.getFullYear();
            m = m_date.getMonth();
            var t_from = new Date(y, m, 1);
            tenor_from = dates.convert_to_sql(t_from);
        }
           
        if (tenor_to == '') {
            tenor_to = tenor_from;
        }
        
        if (tenor_from != '' && tenor_to != '' && tenor_from > tenor_to) {
            show_messagebox('Tenor To should be greater than Tenor From.');
            return;
        }
        
        var curve_source_value_obj = view_volatility.view_volatility_filter_form.getCombo('curve_source');
        var curve_source_value = curve_source_value_obj.getChecked();
        curve_source_value = curve_source_value.toString();
        
        if (curve_source_value == '') {
            show_messagebox('Please select a curve source.');
            return;
        }
        var round_value = view_volatility.view_volatility_filter_form.getItemValue('round_value');
        
        var data = {
                        "action": "spa_view_volatility",
                        "flag": "s",
                        "source_price_curve": source_price_curve,
                        "as_of_date_from": as_of_date_from,
                        "as_of_date_to": as_of_date_to,
                        "tenor_from": tenor_from,
                        "tenor_to": tenor_to,
                        "curve_source_value": curve_source_value,
                        "round_value": round_value,
                        "forward_settle": "f",
                        "granularity":granularity,
                        "granularity_id":granularity_id
                    };
        
        adiha_post_data('return_json', data, '', '', 'volatility_values_refresh_callback', '', '');
        
    }
    
    function volatility_values_refresh_callback(result) {
        forward_del_flag = 0;
        view_volatility.view_volatility_layout.cells('d').progressOn();
        
        view_volatility.volatility_values_menu.setItemDisabled('delete');
        var return_data = JSON.parse(result);
        var data_length = return_data.length;
        var process_id = return_data[0].process_id;
        var round_value = view_volatility.view_volatility_filter_form.getItemValue('round_value');
        
        //Variable to store header information, used while building XML
        fh1 = [];
        fh2 = [];
        fh3 = [];
        fh4 = [];
        
        var forward_header1 = new Array();
        var forward_header2 = new Array();
        var forward_header3 = new Array();
        var forward_header4 = new Array();
        var forward_col_width = new Array();
        var forward_col_type = new Array();
        var forward_col_visibility = new Array();
        var for_val1, for_val2, for_val3, for_val4;
        var forward_col_align = new Array();
        var forward_col = new Array();
        var forward_cell_col_align = new Array();
        var forward_col_validator = new Array();
        var forward_col_rounding = new Array();
        var forward_col_data_type = new Array();
        
        
        forward_changed_cell_arr = [[]];
        forward_delete_cell_arr = [[]];
        forward_delete_xml = '';

        var for_count = 0;
        //Building the multiline header information
        forward_fxd_header = 0;
        for(i=0; i<data_length; i++) {
                if (return_data[i].name == 'Maturity Date' || return_data[i].name == 'forward_settle' || return_data[i].name == 'is_dst' ) {
                    
                    if (return_data[i].name == 'Maturity Date') {
                        forward_col_type.push('dhxCalendarA');
                        forward_col_validator.push(["NotEmpty"]);
                    }
                    
                    forward_header1.push(return_data[i].name);
                    forward_header2.push('#rspan');
                    forward_header3.push('#rspan');
                    forward_header4.push('#rspan');
                    forward_col_rounding.push('');
                    forward_col_data_type.push('');
                    
                    fh1.push(return_data[i].name);
                    fh2.push(return_data[i].name);
                    fh3.push(return_data[i].name);
                    fh4.push(return_data[i].name);
                    forward_cell_col_align.push('left');
                    forward_col_align.push('"text-align:left;"');
                    forward_fxd_header++;
                } else {
                    var temp_array = return_data[i].name.split('::');
                    forward_header_level_cnt = temp_array.length;

                    if(temp_array[2] == 'Historical'){
                        forward_col_rounding.push(round_value);
                        forward_col_data_type.push('float');
                        forward_col_type.push("edn");
                    } else {
                        forward_col_rounding.push('');
                        forward_col_data_type.push('');
                        forward_col_type.push("ed");
                    }

                    for(j=0; j<temp_array.length; j++) {
                        if (j == 0) {
                            if(for_val1 == temp_array[j]) {
                                forward_header1.push('#cspan'); 
                            } else {
                                forward_header1.push(temp_array[j]);       
                            }
                            for_val1 = temp_array[j];
                            fh1.push(temp_array[j]);
                        } else if (j == 1) {
                            if(for_val2 == temp_array[j] && forward_header1[i] == '#cspan') {
                                forward_header2.push('#cspan'); 
                            } else {
                                forward_header2.push(temp_array[j]);    
                            }
                            for_val2 = temp_array[j];
                            fh2.push(temp_array[j]);
                        } else if (j == 2) {
                            if(for_val3 == temp_array[j] && forward_header2[i] == '#cspan') {
                               forward_header3.push('#cspan'); 
                            } else {
                               forward_header3.push(temp_array[j]);          
                            }
                            for_val3 = temp_array[j];
                            fh3.push(temp_array[j]);
                        } else if (j == 3) {
                            if(for_val4 == temp_array[j] && forward_header3[i] == '#cspan') {
                                forward_header4.push('#cspan'); 
                            } else {
                                forward_header4.push(temp_array[j]);    
                            }
                            for_val4 = temp_array[j];
                            fh4.push(temp_array[j]);
                        } 
                    }
                    forward_col_visibility.push('false');
                    forward_cell_col_align.push('right');
                    // forward_col_validator.push(["NotEmpty",""]);
                    forward_col_align.push('"text-align:right;"');
                }
                forward_col_width.push('100');                
                for_count++;
        }
        //End of building the multiline header information
        
        var forward_header2_str = jQuery.parseJSON('["' + forward_header2.toString().replace(/,/g, '", "') + '"]');
        var forward_header3_str = jQuery.parseJSON('["' + forward_header3.toString().replace(/,/g, '", "') + '"]');
        var forward_header4_str = jQuery.parseJSON('["' + forward_header4.toString().replace(/,/g, '", "') + '"]');
        var forward_col_type_str = forward_col_type.toString();
        var forward_col_width_str = forward_col_width.toString();
        var forward_col_visibility_str = forward_col_visibility.toString();
        var forward_col_align = jQuery.parseJSON('[' + forward_col_align.toString() + ']');
        var forward_cell_col_align_str = forward_cell_col_align.toString();
        var forward_col_validator_str = forward_col_validator.toString();

        view_volatility.view_volatility_layout.cells('d').attachStatusBar({
            height: 30,
            text: '<div id="pagingArea_d"></div>'
        });

        forward_grid = view_volatility.view_volatility_layout.cells('d').attachGrid();
        forward_grid.setImagePath(js_image_path + "dhxgrid_web/");
        forward_grid.setHeader(get_locale_value(forward_header1.toString(),true), null, forward_col_align);
        
        forward_grid.attachHeader(forward_header2_str,forward_col_align);
        if (forward_header_level_cnt > 2) {
            forward_grid.attachHeader(forward_header3_str,forward_col_align);
        }
        forward_grid.setColAlign(forward_cell_col_align_str);
        if (forward_header_level_cnt > 3) {
            forward_grid.attachHeader(forward_header4_str,forward_col_align);
        }
        forward_grid.setInitWidths(forward_col_width_str);
        forward_grid.setColTypes(forward_col_type_str);
        forward_grid.setColumnsVisibility(forward_col_visibility_str);
        forward_grid.enableValidation(true);
        forward_grid.setColValidators(forward_col_validator_str); 

        forward_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        forward_grid.enablePaging(true, 100, 0, 'pagingArea_d');  
        forward_grid.setPagingSkin('toolbar'); 
        forward_grid.enableRounding(forward_col_rounding.toString());

        forward_grid.init();
        forward_grid.enableMultiselect(true);
        // forward_grid.enableEditEvents(true,false,true);
        forward_grid.setDateFormat(user_date_format);
        
        forward_grid.attachEvent("onRowSelect", function(id,ind){
            if (has_rights_view_volatility_edit) {
                view_volatility.volatility_values_menu.setItemEnabled('delete');
                view_volatility.volatility_values_menu.setItemEnabled('save');
            }
        });
        
        forward_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (stage == 2) {
                if (nValue != oValue && cInd >= forward_fxd_header) {
                    forward_changed_cell_arr.push([rId, cInd]);
                }
                
            } 
            return true;
        });
        
        forward_grid.attachEvent("onValidationError",function(id,ind,value){
            var message = "Invalid Data";
            forward_grid.cells(id,ind).setAttribute("validation", message);
            return true;
        });
        forward_grid.attachEvent("onValidationCorrect",function(id,ind,value){
            forward_grid.cells(id,ind).setAttribute("validation", "");
            return true;
        });
        
        load_forward_grid(process_id);
        enable_menu_items();
    }
    

    load_forward_grid = function(process_id) {
        var forward_param = {
                                "action": "spa_view_volatility",
                                "flag": "s",
                                "process_id": process_id
                            };

        forward_param = $.param(forward_param);
        var forward_url = js_data_collector_url + "&" + forward_param;

        forward_grid.loadXML(forward_url, function() {
            view_volatility.view_volatility_layout.cells('d').progressOff();
        });

    }
    
    volatility_values_save = function() {
        maturity_date_flag = 0;
        
        forward_grid.clearSelection();
        cell_validation();
        
        var f_grid_status = view_volatility.validate_form_grid(forward_grid, 'Volatility');
        if (f_grid_status == false) {
            return;
        }
        
        var grid_xml = '<Root><GridGroup>';
        var forward_grid_xml = '';
        
        forward_grid_xml = build_forward_xml('save'); 
        if(forward_grid_xml == 'err')
            return
        
        if (forward_grid_xml != '') {
            grid_xml = grid_xml + '<Grid>';
            if (forward_grid_xml != '') {
                 grid_xml = grid_xml + forward_grid_xml;    
            }
            grid_xml = grid_xml + '</Grid>';
        }
        
        if (forward_delete_xml != '') {
            grid_xml = grid_xml + '<GridDelete>';
            if (forward_delete_xml != '') {
                grid_xml = grid_xml + forward_delete_xml;
            }
            grid_xml = grid_xml + '</GridDelete>';
        }
        grid_xml = grid_xml + '</GridGroup></Root>';
        
        if (maturity_date_flag == 1) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Volatility Values</strong> grid. Please check the data in column <strong>Maturity Date</strong> and resave."
            }); 
            return;
        }
                
        if (grid_xml == '<Root><GridGroup></GridGroup></Root>') {
            show_messagebox('No changes in the grid.');
            return;
        }
        
        forward_del_flag = 0;

        var data = {
                        "action": "spa_view_volatility",
                        "flag": "i",
                        "xml": grid_xml,
                    };
        
        adiha_post_data('alert', data, '', '', '', '', '');
        volatility_values_refresh();
        view_volatility.volatility_values_menu.setItemDisabled('save'); 
    }
    
    /*
     * volatility_value_delete [Build the XML of deleted data]
     */
    volatility_value_delete = function() {
        var row_id = forward_grid.getSelectedRowId();
        var row_id_array = row_id.split(",");
        forward_changed_cell_arr = [[]];
        forward_delete_cell_arr = [[]];
        for (count = 0; count < row_id_array.length; count++) {
            for (count1 = forward_fxd_header; count1 < forward_grid.getColumnsNum(); count1++) {
                forward_delete_cell_arr.push([row_id_array[count], count1]);   
            }
        }
        var delete_xml = build_forward_xml('delete'); 
        forward_delete_xml = forward_delete_xml + delete_xml;
        
        for (count = 0; count < row_id_array.length; count++) {
            var new_check = forward_grid.cells(row_id_array[count], 1).getValue();
            if (new_check != '') { forward_del_flag = 1; }
            forward_grid.deleteRow(row_id_array[count]);
        }

        view_volatility.volatility_values_menu.setItemDisabled('delete');
        if (has_rights_view_volatility_edit) {
            view_volatility.volatility_values_menu.setItemEnabled('save'); 
        }
    }
    
    /*
     * build_forward_xml    [Build the XML of the forward grid]
     * @param   save_delete - 'save' for XML of insert/update, 'delere' for XML of delete
     */
    build_forward_xml = function(save_delete) { 
        var grid_xml = '';
        var curve_source_value_obj = view_volatility.view_volatility_filter_form.getCombo('curve_source');
        var curve_source_text = curve_source_value_obj.getChecked();

        if (save_delete == 'save') {
            var row_col_arr = forward_changed_cell_arr;
        } else {
            var row_col_arr = forward_delete_cell_arr;
        }
        
        for (count =1; count < row_col_arr.length; count++) {

            var row_index = row_col_arr[count][0];
            var cellIndex = row_col_arr[count][1];
            grid_xml = grid_xml + '<GridRow';

            var maturity_date = dates.convert_to_sql(forward_grid.cells(row_index,0).getValue());

            grid_xml = grid_xml + ' maturity_date="' + maturity_date + '"';
            
            if (forward_grid.cells(row_index,0).getValue()  == '') {
                maturity_date_flag = 1;
            } 
            
            grid_xml = grid_xml + ' as_of_date="' + dates.convert_to_sql(fh1[cellIndex]) + '"';
            grid_xml = grid_xml + ' source_price_curve="' + encodeXml(fh2[cellIndex]) + '"';
            
            var nan_status = isNaN(forward_grid.cells(row_index,cellIndex).getValue());
            if(nan_status && save_delete == 'save') {
                show_messagebox('Please insert valid numeric data.');
                return 'err';
            }

            grid_xml = grid_xml + ' curve_source="' + fh3[cellIndex] + '"';
            grid_xml = grid_xml + ' value="' + forward_grid.cells(row_index,cellIndex).getValue() + '"';
            grid_xml = grid_xml + ' forward_settle="f"';
            grid_xml = grid_xml + '></GridRow>';
        }
        return grid_xml;
    }
     
    
    
    /*
     * enable_menu_items    [Enables the menu items when the grid is loaded]
     */
    enable_menu_items = function() {
        if (has_rights_view_volatility_edit) {
            // view_volatility.volatility_values_menu.setItemEnabled("save");
            view_volatility.volatility_values_menu.setItemEnabled("add");
            view_volatility.volatility_values_menu.setItemEnabled('edit');
        } else {
            view_volatility.volatility_values_menu.setItemDisabled("save");
            view_volatility.volatility_values_menu.setItemDisabled("add");
            view_volatility.volatility_values_menu.setItemDisabled("delete");
            view_volatility.volatility_values_menu.setItemDisabled('edit');
        }
        view_volatility.volatility_values_menu.setItemEnabled('export');   
        view_volatility.volatility_values_menu.setItemEnabled('excel');   
        view_volatility.volatility_values_menu.setItemEnabled('pdf');  
        view_volatility.volatility_values_menu.setItemEnabled('batch');
        view_volatility.volatility_values_menu.setItemEnabled('select_unselect');   
        view_volatility.volatility_values_menu.setItemEnabled('pivot');   
    }
    
    /**
     * [Function to expand/collapse price curve Grid when double clicked]
     */
    view_volatility.expand_price_curve = function(r_id, col_id) {
        var selected_row = view_volatility.curve_grid.getSelectedRowId();
        var state = view_volatility.curve_grid.getOpenState(selected_row);

        if (state)
            view_volatility.curve_grid.closeItem(selected_row);
        else
            view_volatility.curve_grid.openItem(selected_row);
    }   
    
    
    view_volatility.validate_form_grid = function(attached_obj,grid_label) {
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

    volatility_value_batch = function() {
        var selected_row = view_volatility.curve_grid.getSelectedId();
        var curve_id_arr = new Array();
        
        if (selected_row != null) {
            var selected_row_arr = selected_row.split(',');
            for(i = 0; i < selected_row_arr.length; i++) {
                var tree_level = view_volatility.curve_grid.getLevel(selected_row_arr[i]);

                if (tree_level == 1) {
                    var value = view_volatility.curve_grid.cells(selected_row_arr[i], view_volatility.curve_grid.getColIndexById('source_curve_def_id')).getValue();
                    curve_id_arr.push(value);
                }
            }
        }
        
        var curve_id = curve_id_arr.toString();
        
        var curve_source_value_obj = view_volatility.view_volatility_filter_form.getCombo('curve_source');
        var curve_source = curve_source_value_obj.getChecked();
        curve_source = curve_source.toString();
        
        var from_date = view_volatility.view_volatility_filter_form.getItemValue('as_of_date_from', true);
        var to_date = view_volatility.view_volatility_filter_form.getItemValue('as_of_date_to', true);
        
        if (to_date == '') {
            to_date = from_date;
        }
        
        var tenor_from = view_volatility.view_volatility_filter_form.getItemValue('tenor_from', true);
        var tenor_to =  view_volatility.view_volatility_filter_form.getItemValue('tenor_to', true);
        
        var ind_con_month = 'NULL';
        var mode = 's';   
        var copy_curve_id = 'NULL';
        var curve_type = 77;

        if (curve_id == '') {
            show_messagebox('Please select a price curve.');
            return;
        }
        
        if (tenor_from == '' && forward_settlement_status == 's') {
            show_messagebox('Please select Tenor From.');
            return;
        }
        
        if (from_date == '') 
            from_date = tenor_from;
        
        var exec_call = "EXEC spa_view_volatility @flag='p', @source_price_curve='" + curve_id 
                                        + "',@curve_source_value='" + curve_source 
                                        + "',@as_of_date_from='" + from_date 
                                        + "',@as_of_date_to='" + to_date 
                                        + "',@tenor_from='" + tenor_from 
                                        + "',@tenor_to='" + tenor_to + "'";
        var from_date = view_volatility.view_volatility_filter_form.getItemValue('as_of_date_from',true);
        var param = 'call_from=Price Batch Import&gen_as_of_date=1&batch_type=r&as_of_date=' + from_date; 
        adiha_run_batch_process(exec_call, param, 'View Volatility');
    }

    cell_validation = function() {
        forward_grid.forEachRow(function(row){
            forward_grid.forEachCell(row,function(cellObj,ind){
                 forward_grid.validateCell(row,ind)
            });
        });
    }

    view_volatility.export = function(format, grid_obj) {
        switch(format) {
            case 'excel':
                grid_obj.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
            break;
            case 'pdf':
                grid_obj.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
            break;
        }
    }

    view_volatility.expand_collapse = function(grid_obj) {
        if(expand_state == 0) {
            grid_obj.expandAll();
            expand_state = 1;
        } else {
            grid_obj.collapseAll();
            expand_state = 0;
        }
    }

    view_volatility.select_unselect = function(grid_obj) {
        var selected_id = grid_obj.getSelectedRowId();
        if(selected_id == null) {
            grid_obj.selectAll();
        } else {
            grid_obj.clearSelection(true);
        }
        var selected_id = grid_obj.getSelectedRowId();
        if(selected_id) {
            if (has_rights_view_volatility_edit)
                view_volatility.volatility_values_menu.setItemEnabled('delete'); 
        } else {
            view_volatility.volatility_values_menu.setItemDisabled('delete'); 
        }
    }

    view_volatility.click_pivot = function() {
        var selected_row = view_volatility.curve_grid.getSelectedId();
        var source_price_curve_arr = new Array();
        
        if (selected_row != null) {
            var selected_row_arr = selected_row.split(',');
            for(i = 0; i < selected_row_arr.length; i++) {
                var tree_level = view_volatility.curve_grid.getLevel(selected_row_arr[i]);

                if (tree_level == 1) {
                    var value = view_volatility.curve_grid.cells(selected_row_arr[i], view_volatility.curve_grid.getColIndexById('source_curve_def_id')).getValue();
                    source_price_curve_arr.push(value);
                }
            }
        }
        
        var source_price_curve = source_price_curve_arr.toString();
        if (source_price_curve == '') {
            show_messagebox('Please select a price curve.');
            return;
        }

        var curve_source_value_obj = view_volatility.view_volatility_filter_form.getCombo('curve_source');
        var curve_source_value = curve_source_value_obj.getChecked();
        curve_source_value = curve_source_value.toString();
        var as_of_date_from = view_volatility.view_volatility_filter_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_volatility.view_volatility_filter_form.getItemValue('as_of_date_to', true);
        var tenor_from = view_volatility.view_volatility_filter_form.getItemValue('tenor_from', true);
        var tenor_to = view_volatility.view_volatility_filter_form.getItemValue('tenor_to', true);
        
        var pivot_exec_spa = "EXEC spa_view_volatility @flag='p', @source_price_curve='" + source_price_curve 
                                                + "',@curve_source_value='" + curve_source_value 
                                                + "',@as_of_date_from='" + as_of_date_from 
                                                + "',@as_of_date_to='" + as_of_date_to 
                                                + "',@tenor_from='" + tenor_from 
                                                + "',@tenor_to='" + tenor_to + "'";
        
        open_grid_pivot('', 'view_volatility_grid', 1, pivot_exec_spa, 'View Volatility');
    }
    
    var xml_special_to_escaped_one_map = {
        '&': '&amp;',
        '"': '&quot;',
        '<': '&lt;',
        '>': '&gt;'
    };

    function encodeXml(string) {
        return string.replace(/([\&"<>])/g, function(str, item) {
            return xml_special_to_escaped_one_map[item];
        });
    };

</script>
    
    