<?php
/**
* View correlation screen
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
    <?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    ?>
</head>

<?php 
    $function_id = 20001600;
    $namespace = 'view_correlation';

    /* Privilege */
    $has_rights_correlation = 20001600;

    $layout_json = '[
                {
                    id:             "a",
                    text:           "Risk Bucket From",
                    header:         true,
                    collapse:       false,
                    width:          350,
                    undock:         true
                },
                {
                    id:             "b",
                    text:           "Risk Bucket To",
                    header:         true,
                    collapse:       false,
                    width:          350,
                    undock:         true
                },
                {
                    id:             "c",
                    text:           "Apply Filters",
                    header:         true,
                    collapse:       true,
                    height:         100
                },
                {
                    id:             "d",
                    text:           "Filters",
                    header:         true,
                    collapse:       false,
                    height:         300
                },
                {
                    id:             "e",
                    text:           "Correlation Values",
                    header:         true,
                    collapse:       false,
                    undock:         true
                }
            ]';

    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '5S', $layout_json, $namespace);
    echo $layout_obj->attach_event('', 'onDock', 'view_correlation.on_dock_event');
    echo $layout_obj->attach_event('', 'onUnDock', 'view_correlation.on_undock_event');

    /* Left Grid Menu Section */
    $menu_a_json = '[
                            {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                                {id:"excel", text:"Excel", img:"excel.gif"},
                                {id:"pdf", text:"PDF", img:"pdf.gif"}
                            ]},
                            {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"},
                            {id:"select_unselect", text:"Select/Unselect", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1}
                        ]';
    echo $layout_obj->attach_menu_layout_cell('menu_a', 'a', $menu_a_json, $namespace . '.menu_a_onclick');
    echo $layout_obj->attach_menu_layout_cell('menu_b', 'b', $menu_a_json, $namespace . '.menu_b_onclick');

    /* Left Grid Section*/
    $grid_a_name = 'grid_a';
    echo $layout_obj->attach_status_bar("a", true);
    echo $layout_obj->attach_grid_cell($grid_a_name, 'a');
    $grid_a_obj = new GridTable('setup_price_curve');
    echo $grid_a_obj->init_grid_table($grid_a_name, $namespace);
    echo $grid_a_obj->enable_multi_select();
    echo $grid_a_obj->set_search_filter(true); 
    echo $grid_a_obj->return_init();
    echo $grid_a_obj->load_grid_data("EXEC spa_source_price_curve_def_maintain 't', @granularity = '30'");    
    echo $grid_a_obj->enable_paging(100, 'pagingArea_a', 'true');

    $grid_b_name = 'grid_b';
    echo $layout_obj->attach_status_bar("b", true);
    echo $layout_obj->attach_grid_cell($grid_b_name, 'b');
    $grid_b_obj = new GridTable('setup_price_curve');
    echo $grid_b_obj->init_grid_table($grid_b_name, $namespace);
    echo $grid_b_obj->enable_multi_select();
    echo $grid_b_obj->set_search_filter(true); 
    echo $grid_b_obj->return_init();
    echo $grid_b_obj->load_grid_data("EXEC spa_source_price_curve_def_maintain 't', @granularity = '30'");    
    echo $grid_b_obj->enable_paging(100, 'pagingArea_b', 'true');

    /* Filter Form Section */
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20001600', @template_name='View Correlation', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $tab_id = $form_arr[0]['tab_id'];
    $form_json = $form_arr[0]['form_json'];
    echo $layout_obj->attach_form('filter_form', 'd');
    $form_filter_obj = new AdihaForm();
    echo $form_filter_obj->init_by_attach('filter_form', $namespace);
    echo $form_filter_obj->load_form($form_json);

    /* Menu for Correlation Values Grid Section */
    $menu_e_name = 'menu_e';
    $menu_e_json = '[
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                        {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled: "'. $has_rights_correlation .'"},
                        {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", enabled: "'. $has_rights_correlation .'"},
                            {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", enabled: "'. $has_rights_correlation .'"}
                        ]},
                        {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled: 1},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled: 1},
                            {id:"batch", text:"Batch", img:"batch.gif", imgdis:"batch_dis.gif", enabled: "' . $has_rights_correlation . '"}
                        ]},
                        {id:"select_unselect", text:"Select/Unselect", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1},
                        {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif", enabled: 0}
                    ]';
    echo $layout_obj->attach_menu_layout_cell($menu_e_name, 'e', $menu_e_json, $namespace . '.menu_e_onclick');

    echo $layout_obj->close_layout();
?>

<script type="text/javascript" async>
    var today = new Date();
    var new_date = new Date(today.getFullYear(), today.getMonth() , today.getDate());
    var has_rights_view_correlation = <?php echo (($has_rights_correlation) ? '1' : '0'); ?>;
    var expand_state = 0;

    var grid_e_changed_cell_arr = [[]];
    var grid_e_delete_cell_arr = [[]];
    var fh1 = [];
    var fh2 = [];
    var fh3 = [];
    var grid_e_del_flag;

    $(function () {
        view_correlation.filter_form.setItemValue('as_of_date_from', new_date);
        var curve_source_combo = view_correlation.filter_form.getCombo('curve_source');
        curve_source_combo.setChecked(1, true);

        filter_form = view_correlation.layout.cells('c').attachForm();
        layout_cell_c = view_correlation.layout.cells('d');
        load_form_filter(filter_form, layout_cell_c, '20001600', 2);

        filter_form.attachEvent("onBeforeChange",function(name,oldValue,newValue){
            view_correlation.grid_a.expandAll();
            view_correlation.grid_b.expandAll();
            return true;
        });

        view_correlation.grid_a.attachEvent("onRowDblClicked", function(rId,cInd){
            view_correlation.expand_curve(view_correlation.grid_a);
        });

        view_correlation.grid_b.attachEvent("onRowDblClicked", function(rId,cInd){
            view_correlation.expand_curve(view_correlation.grid_b);
        });
    });

    view_correlation.menu_a_onclick = function(id) {
        switch(id) {
            case 'excel':
                view_correlation.export('excel', view_correlation.grid_a);
            break;
            case 'pdf':
                view_correlation.export('pdf', view_correlation.grid_a);
            break;
            case 'select_unselect':
                view_correlation.select_unselect(view_correlation.grid_a);
            break;
            case 'expand_collapse':
                view_correlation.expand_collapse(view_correlation.grid_a);
            break;
        }
    }

    view_correlation.menu_b_onclick = function(id) {
        switch(id) {
            case 'excel':
                view_correlation.export('excel', view_correlation.grid_b);
            break;
            case 'pdf':
                view_correlation.export('pdf', view_correlation.grid_b);
            break;
            case 'select_unselect':
                view_correlation.select_unselect(view_correlation.grid_b);
            break;
            case 'expand_collapse':
                view_correlation.expand_collapse(view_correlation.grid_b);
            break;
        }
    }

    view_correlation.menu_e_onclick = function(id) {
        switch(id) {
            case 'refresh':
                view_correlation.onrefresh_click();
            break;
            case 'save':
                view_correlation.on_save_click();
            break;
            case 'add':
                view_correlation.on_add_click();
            break;
            case 'delete':
                view_correlation.on_delete_click();
            break;
            case 'excel':
                view_correlation.export('excel', view_correlation.grid_e);
            break;
            case 'pdf':
                view_correlation.export('pdf', view_correlation.grid_e);
            break;
            case 'batch':
                view_correlation.on_batch_click();
            break;
            case 'select_unselect':
                view_correlation.select_unselect(view_correlation.grid_e);
            break;
            case 'pivot':
                view_correlation.on_pivot_click();
            break;
        }
    }

    view_correlation.onrefresh_click = function() {
        grid_e_del_flag = 0;
        grid_e_changed_cell_arr = [[]];
        grid_e_delete_cell_arr = [[]];
        var s_granularity_arr = [];
        var is_same_granularity = true;

        var filter_form_obj = view_correlation.filter_form;
        var status = validate_form(filter_form_obj);
        if(!status) { return; }

        /* Getting Selected Curve Id From Risk Bucket From Grid*/
        var rbf_selected_id = view_correlation.grid_a.getSelectedRowId();
        var cif_array = []; 
        if (rbf_selected_id != null) {
            var rbf_selected_id_split = rbf_selected_id.split(',');
            var s_granularity_col_a = view_correlation.grid_a.getColIndexById('s_granularity');
            for(i=0; i<rbf_selected_id_split.length; i++) {
                var a_granularity_value = view_correlation.grid_a.cells(rbf_selected_id_split[0],s_granularity_col_a).getValue();
                s_granularity_arr.push(a_granularity_value);

                var rbf_level = view_correlation.grid_a.getLevel(rbf_selected_id_split[i]);
                if (rbf_level == 1) {
                    var rbf_col_index = view_correlation.grid_a.getColIndexById('source_curve_def_id');
                    var rbf_value = view_correlation.grid_a.cells(rbf_selected_id_split[i], rbf_col_index).getValue();
                    cif_array.push(rbf_value);
                }
            }
        }
        var curve_id_from = cif_array.toString();
        if(curve_id_from == '') {
            show_messagebox('Please select Risk Bucket From curve id.');
            return;
        }
        
        /* Getting Selected Curve Id From Risk Bucket To Grid*/
        var rbt_selected_id = view_correlation.grid_b.getSelectedRowId();
        var cit_array = []; 
        if (rbt_selected_id != null) {
            var rbt_selected_id_split = rbt_selected_id.split(',');
            var s_granularity_col_b = view_correlation.grid_b.getColIndexById('s_granularity');
            for(i=0; i<rbt_selected_id_split.length; i++) {
                var b_granularity_value = view_correlation.grid_b.cells(rbt_selected_id_split[0],s_granularity_col_b).getValue();
                s_granularity_arr.push(b_granularity_value);

                var rbt_level = view_correlation.grid_b.getLevel(rbt_selected_id_split[i]);
                if (rbt_level == 1) {
                    var rbt_col_index = view_correlation.grid_b.getColIndexById('source_curve_def_id');
                    var rbt_value = view_correlation.grid_b.cells(rbt_selected_id_split[i], rbt_col_index).getValue();
                    cit_array.push(rbt_value);
                }
            }
        }
        var curve_id_to = cit_array.toString();
        if(curve_id_to == '') {
            show_messagebox('Please select Risk Bucket To curve id.');
            return;
        }

        for(i=0; i<s_granularity_arr.length-1; i++) {
            if(s_granularity_arr[i] != s_granularity_arr[i+1]) {
                is_same_granularity = false;
            }
        }

        if(!is_same_granularity) {
            show_messagebox('Please select the price curves of same granularity.');
            return;
        }

        /* Getting Filter Form Data*/
        var as_of_date_from = view_correlation.filter_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_correlation.filter_form.getItemValue('as_of_date_to', true);
        var term_from = view_correlation.filter_form.getItemValue('term_from', true);
        var term_to = view_correlation.filter_form.getItemValue('term_to', true);
        var curve_source_value_combo = view_correlation.filter_form.getCombo('curve_source');
        var curve_source_value = (curve_source_value_combo.getChecked()).toString();
        var round_value = view_correlation.filter_form.getItemValue('round_value');

        if (as_of_date_to != '' && as_of_date_from != '' && as_of_date_from > as_of_date_to) {
            show_messagebox('As of Date To should be greater than As of Date From.');
            return;
        }

        if (term_from != '' && term_to != '' && term_from > term_to) {
            show_messagebox('Term To should be greater than Term From.');
            return;
        }

        var data = {
                        "action": "spa_view_correlation",
                        "flag": "s",
                        "curve_id_from": curve_id_from,
                        "curve_id_to": curve_id_to,
                        "as_of_date_from": as_of_date_from,
                        "as_of_date_to": as_of_date_to,
                        "term_from": term_from,
                        "term_to": term_to,
                        "curve_source_value_id": curve_source_value,
                        "round_value": round_value,
                    };
        
        adiha_post_data('return_json', data, '', '', 'view_correlation.refresh_callback', '', '');
        view_correlation.grid_e.clearChangedState();
        view_correlation.enable_disable_menu(view_correlation.menu_e, 'delete', 0);
        view_correlation.enable_disable_menu(view_correlation.menu_e, 'save', 0);
    }

    view_correlation.refresh_callback = function(result) {
        var return_data = JSON.parse(result);
        var data_length = return_data.length;
        var process_id = return_data[0].process_id;
        var round_value = view_correlation.filter_form.getItemValue('round_value');

        var grid_e_header1 = new Array();
        var grid_e_header2 = new Array();
        var grid_e_header3 = new Array();
        var grid_e_col_type = new Array();
        var grid_e_cell_col_align = new Array();
        var grid_e_col_width = new Array();
        var grid_e_col_validator = new Array();
        var grid_e_col_rounding = new Array();
        var h1, h2, h3;
        fh1 = [];
        fh2 = [];
        fh3 = [];

        for(i=0; i<data_length; i++) {
            if (return_data[i].name == 'Term From' || return_data[i].name == 'Term To' ) {
                grid_e_header1.push(return_data[i].name);
                grid_e_header2.push("#rspan");
                grid_e_header3.push("#rspan");
                grid_e_col_type.push("dhxCalendarA");
                grid_e_cell_col_align.push('left');
                grid_e_col_validator.push(["NotEmpty"]);
                grid_e_col_rounding.push('');

                fh1.push(return_data[i].name);
                fh2.push(return_data[i].name);
                fh3.push(return_data[i].name);            
            } else {
                var temp_array = return_data[i].name.split(':::');
                
                for(j=0; j<temp_array.length; j++) {
                    if(j == 0) {
                        if(h1 == temp_array[j]) {
                            grid_e_header1.push("#cspan");
                        } else {
                            grid_e_header1.push(temp_array[j]);
                        }
                        h1 = temp_array[j];
                        fh1.push(temp_array[j]);
                    } else if (j == 1) {
                        if(h2 == temp_array[j] && grid_e_header1[i] == '#cspan') {
                            grid_e_header2.push('#cspan'); 
                        } else {
                            grid_e_header2.push(temp_array[j]);    
                        }
                        h2 = temp_array[j];
                        fh2.push(temp_array[j]);
                    } else {
                        if(h3 == temp_array[j] && grid_e_header3[i] == '#cspan') {
                           grid_e_header3.push('#cspan'); 
                        } else {
                           grid_e_header3.push(temp_array[j]);          
                        }
                        h3 = temp_array[j];
                        fh3.push(temp_array[j]);
                    }

                    grid_e_col_validator.push(["NotEmpty","ValidNumeric"]);
                }

                grid_e_col_rounding.push(round_value);
                grid_e_col_type.push("edn");
                grid_e_cell_col_align.push('right');            
            }

            if(i>1) grid_e_col_width.push('150'); else grid_e_col_width.push('100');
        }
        
        view_correlation.layout.cells('e').attachStatusBar({
                                    height: 30,
                                    text: '<div id="pagingArea_e"></div>'
                                });

        view_correlation.grid_e = view_correlation.layout.cells('e').attachGrid();
        view_correlation.grid_e.setImagePath(js_image_path + "dhxgrid_web/");
        view_correlation.grid_e.setHeader(get_locale_value(grid_e_header1.toString(),true), null);
        view_correlation.grid_e.attachHeader(grid_e_header2.toString());
        view_correlation.grid_e.attachHeader(grid_e_header3.toString());
        view_correlation.grid_e.setColAlign(grid_e_cell_col_align.toString());
        view_correlation.grid_e.setInitWidths(grid_e_col_width.toString());
        view_correlation.grid_e.setColTypes(grid_e_col_type.toString());
        view_correlation.grid_e.enableMultiselect(true);
        view_correlation.grid_e.enableValidation(true);
        // view_correlation.grid_e.setColValidators(grid_e_col_validator.toString());
        view_correlation.grid_e.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        view_correlation.grid_e.enablePaging(true, 100, 0, 'pagingArea_e');  
        view_correlation.grid_e.setPagingSkin('toolbar'); 
        view_correlation.grid_e.init();
        view_correlation.grid_e.setStyle("word-wrap: break-word;");
        view_correlation.grid_e.setDateFormat(user_date_format);

        view_correlation.grid_e.enableRounding(grid_e_col_rounding.toString());

        view_correlation.grid_e.attachEvent('onRowSelect', function() {
            view_correlation.enable_disable_menu(view_correlation.menu_e, 'delete', 1);
        });

        view_correlation.grid_e.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue) {
            
            if (stage == 2) {
                if (nValue != oValue) {
                    grid_e_changed_cell_arr.push([rId, cInd]);
                    view_correlation.enable_disable_menu(view_correlation.menu_e, 'save', 1);
                }
            } 
            return true;
        });

        view_correlation.grid_e.attachEvent("onValidationError",function(id,ind,value){
            var message = "Invalid Data";
            view_correlation.grid_e.cells(id,ind).setAttribute("validation", message);
            return true;
        });

        view_correlation.grid_e.attachEvent("onValidationCorrect",function(id,ind,value){
            view_correlation.grid_e.cells(id,ind).setAttribute("validation", "");
            return true;
        });


        view_correlation.load_grid_e(process_id); 
        view_correlation.enable_disable_menu(view_correlation.menu_e, 'pivot', 1);
        view_correlation.enable_disable_menu(view_correlation.menu_e, 'batch', 1);
    }

    view_correlation.load_grid_e = function(process_id) {
        var sql = {
                    "action": "spa_view_correlation",
                    "flag": "s",
                    "process_id": process_id
                };
        var param_sql = $.param(sql);
        var param_url = js_data_collector_url + "&" + param_sql; 

        view_correlation.enable_disable_menu(view_correlation.menu_e, 'add', 1);

        view_correlation.grid_e.loadXML(param_url, function(){
            var rows = view_correlation.grid_e.getRowsNum();            
            for(var i=1; i<=rows; i++) {
                var correlation_value = view_correlation.grid_e.cells(i-1,2).getValue(); 

                if (correlation_value == 1) {
                    grid_e_changed_cell_arr.push([i-1, 2]);
                    view_correlation.enable_disable_menu(view_correlation.menu_e, 'save', 1);
                }
            }
        });
    }

    view_correlation.on_save_click = function() {
        var grid_e_save_xml = '';
        var grid_xml = '<Root><GridGroup><Grid>';
        var row_col_arr = grid_e_changed_cell_arr;
        for(i=1; i<row_col_arr.length; i++) {
            var row_index = row_col_arr[i][0];
            var cellIndex = row_col_arr[i][1];
            var xml_as_of_date;
            if (fh1[cellIndex] == 'Term From' || fh1[cellIndex] == 'Term To' || cellIndex == 0 || cellIndex == 1) { 
                continue; 
            } else {
                xml_as_of_date = fh1[cellIndex];
            }
            var xml_curve_source_value_id = fh2[cellIndex];
            var xml_curve_ids = fh3[cellIndex].split(' :: ');
            var xml_curve_id_from = escapeXML(xml_curve_ids[0]);
            var xml_curve_id_to = escapeXML(xml_curve_ids[1]);
        
            var xml_term1 = view_correlation.grid_e.cells(row_index, 0).getValue();
            var xml_term2 = view_correlation.grid_e.cells(row_index, 1).getValue();
            var xml_value = view_correlation.grid_e.cells(row_index, cellIndex).getValue();

            if (xml_term1 == '' || xml_term1 == null || xml_term2 == '' || xml_term2 == null) {
                show_messagebox('<b>Term From</b> and <b>Term To</b> cannot be left blank.');
                return;
            } else if(xml_value != '') {
                if(xml_value > 1 || xml_value < -1) {
                    show_messagebox('<b>Value</b> must be between <b>-1</b> and <b>1.</b>');
                    return;
                } else if(isNaN(xml_value)) {
                    show_messagebox('Invalid Numeric Value.');
                    return;
                }
            }

            xml_as_of_date = dates.convert_to_sql(xml_as_of_date);
            xml_term1 = dates.convert_to_sql(xml_term1);
            xml_term2 = dates.convert_to_sql(xml_term2);

            grid_xml = grid_xml + '<GridRow';
            grid_xml = grid_xml + ' as_of_date="' + xml_as_of_date + '"';
            grid_xml = grid_xml + ' curve_id_from="' + xml_curve_id_from + '"';
            grid_xml = grid_xml + ' curve_id_to="' + xml_curve_id_to + '"';
            grid_xml = grid_xml + ' term1="' + xml_term1 + '"';
            grid_xml = grid_xml + ' term2="' + xml_term2 + '"';
            grid_xml = grid_xml + ' curve_source_value_id="' + xml_curve_source_value_id + '"';
            grid_xml = grid_xml + ' value="' + xml_value + '"';
            grid_xml = grid_xml + '></GridRow>';
        }    
        
        view_correlation.validate_grid_e_cell();

        var grid_e_status = view_correlation.validate_form_grid(view_correlation.grid_e, 'View Correlation');
        if (grid_e_status == false) {
            return;
        }

        grid_e_save_xml = grid_xml + '</Grid></GridGroup></Root>' ;
        //alert(grid_e_save_xml);

        grid_e_changed_cell_arr = [[]];
        grid_e_delete_cell_arr = [[]];
        
        dhtmlx.message({
            type: "confirm",
            title: "Confirmation",
            ok: "Confirm",
            text: "Are you sure you want to save the changes?",
            callback: function(result) {
                if (result == true) {
                    var insert_sql = {
                                    "action": "spa_view_correlation",
                                    "flag": "i",
                                    "xml": grid_e_save_xml
                                };
                    adiha_post_data('alert', insert_sql, '', '', view_correlation.onrefresh_click, '', '');   
                } else {
                    return;
                }
            }
        });

        view_correlation.enable_disable_menu(view_correlation.menu_e, 'delete', 0);
        view_correlation.enable_disable_menu(view_correlation.menu_e, 'save', 0);
    }

    view_correlation.on_add_click = function() {
        var new_id = (new Date()).valueOf();
        view_correlation.grid_e.addRow(new_id, '');
    }

    view_correlation.on_delete_click = function() {
        var grid_xml = '<Root><GridGroup><GridDelete>';
        //get selected row ids of all grid
        var row_id_a = view_correlation.grid_a.getSelectedRowId();
        var row_id_b = view_correlation.grid_b.getSelectedRowId();
        var row_id_e = view_correlation.grid_e.getSelectedRowId();
        //split ids and make arrays
        var row_id_array_a = row_id_a.split(",");
        var row_id_array_b = row_id_b.split(",");
        var row_id_array_e = row_id_e.split(",");
        var del_as_of_date = view_correlation.filter_form.getItemValue('as_of_date_from', true);
        //var del_curve_source = view_correlation.filter_form.getItemValue('curve_source');
        var combo_obj = view_correlation.filter_form.getCombo('curve_source');
        var del_curve_source = combo_obj.getChecked();
        
        var i = 0, j = 0, k = 0;
        for (i = 0; i < row_id_array_a.length; i++) { //for grid a
            var del_curve_id_a = view_correlation.grid_a.cells(row_id_array_a[i], 1).getValue();
            for (j = 0; j < row_id_array_b.length; j++) { //for grid b
                var del_curve_id_b = view_correlation.grid_b.cells(row_id_array_b[j], 1).getValue();
                for (k = 0; k < row_id_array_e.length; k++) { //for grid e
                    var del_term_from = view_correlation.grid_e.cells(row_id_array_e[k], 0).getValue();
                    del_term_from = dates.convert_to_sql(del_term_from);
                    var del_term_to = view_correlation.grid_e.cells(row_id_array_e[k], 1).getValue();
                    del_term_to = dates.convert_to_sql(del_term_to);
                    //build xml
                    grid_xml = grid_xml + '<GridRow';
                    grid_xml = grid_xml + ' as_of_date="' + del_as_of_date + '"';
                    grid_xml = grid_xml + ' curve_id_from="' + del_curve_id_a + '"';
                    grid_xml = grid_xml + ' curve_id_to="' + del_curve_id_b + '"';
                    grid_xml = grid_xml + ' term1="' + del_term_from + '"';
                    grid_xml = grid_xml + ' term2="' + del_term_to + '"';
                    grid_xml = grid_xml + ' curve_source_value_id="' + del_curve_source + '"';
                    grid_xml = grid_xml + '></GridRow>';
                }
            }
        }
        grid_xml = grid_xml + '</GridDelete></GridGroup></Root>';
        view_correlation.grid_e.clearSelection();
        dhtmlx.message({
            type: "confirm",
            title: "Confirmation",
            ok: "Confirm",
            text: "Are you sure you want to delete?",
            callback: function(result) {
                if (result == true) {
                    var delete_sql = {
                            "action": "spa_view_correlation",
                            "flag": "d",
                            "xml": grid_xml
                        };
                    adiha_post_data('alert', delete_sql, '', '', view_correlation.onrefresh_click, '', '');  
                } else {
                    return;
                }                
            }
        });
    }

    /*status 1 for enabling and 0 for disabling the selected menu*/
    view_correlation.enable_disable_menu = function(menu_obj, menu_id, status) {
        if(has_rights_view_correlation) {
            if(status == 1) {
                menu_obj.setItemEnabled(menu_id);
            } else if(status == 0) {
                menu_obj.setItemDisabled(menu_id);
            }
        }
    }

    view_correlation.validate_grid_e_cell = function() {
        view_correlation.grid_e.forEachRow(function(row){
            view_correlation.grid_e.forEachCell(row,function(cellObj,ind){
                view_correlation.grid_e.validateCell(row,ind)
            });
        });
    }

    view_correlation.validate_form_grid = function(grid_obj, grid_name) {
        var status = true;
        for (var i = 0;i < grid_obj.getRowsNum();i++){
            var row_id = grid_obj.getRowId(i);
            
            for (var j = 0;j < grid_obj.getColumnsNum();j++){ 
                var validation_message = grid_obj.cells(row_id,j).getAttribute("validation");
                
                if(validation_message != "" && validation_message != undefined){
                    var column_text = grid_obj.getColLabel(j);
                    error_message = "Data Error in <b>"+grid_name+"</b> grid. Please check the data in column <b>"+column_text+"</b> and save.";
                    dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                    status = false; 
                    break;
                }
            }
            if(validation_message != "" && validation_message != undefined){ break;};
         }
        return status;
    }

    view_correlation.export = function(format, grid_obj) {
        switch(format) {
            case 'excel':
                grid_obj.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
            break;
            case 'pdf':
                grid_obj.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
            break;
        }
    }

    view_correlation.select_unselect = function(grid_obj) {
        var selected_id = grid_obj.getSelectedRowId();
        if(selected_id == null) {
            grid_obj.selectAll();
            view_correlation.enable_disable_menu(view_correlation.menu_e, 'delete', 1);
        } else {
            grid_obj.clearSelection(true);
            view_correlation.enable_disable_menu(view_correlation.menu_e, 'delete', 0);
        }
    }

    view_correlation.on_batch_click = function() {
        /* Getting Selected Curve Id From Risk Bucket From Grid*/
        var rbf_selected_id = view_correlation.grid_a.getSelectedRowId();
        var cif_array = []; 
        if (rbf_selected_id != null) {
            var rbf_selected_id_split = rbf_selected_id.split(',');
            for(i=0; i<rbf_selected_id_split.length; i++) {
                var rbf_level = view_correlation.grid_a.getLevel(rbf_selected_id_split[i]);
                if (rbf_level == 1) {
                    var rbf_col_index = view_correlation.grid_a.getColIndexById('source_curve_def_id');
                    var rbf_value = view_correlation.grid_a.cells(rbf_selected_id_split[i], rbf_col_index).getValue();
                    cif_array.push(rbf_value);
                }
            }
        }
        var curve_id_from = cif_array.toString();
        if(curve_id_from == '') {
            show_messagebox('Please select Risk Bucket From curve id.');
            return;
        }
        
        /* Getting Selected Curve Id From Risk Bucket To Grid*/
        var rbt_selected_id = view_correlation.grid_b.getSelectedRowId();
        var cit_array = []; 
        if (rbt_selected_id != null) {
            var rbt_selected_id_split = rbt_selected_id.split(',');
            for(i=0; i<rbt_selected_id_split.length; i++) {
                var rbt_level = view_correlation.grid_b.getLevel(rbt_selected_id_split[i]);
                if (rbt_level == 1) {
                    var rbt_col_index = view_correlation.grid_b.getColIndexById('source_curve_def_id');
                    var rbt_value = view_correlation.grid_b.cells(rbt_selected_id_split[i], rbt_col_index).getValue();
                    cit_array.push(rbt_value);
                }
            }
        }
        var curve_id_to = cit_array.toString();
        if(curve_id_to == '') {
            show_messagebox('Please select Risk Bucket To curve id.');
            return;
        }

        /* Getting Filter Form Data*/
        var as_of_date_from = view_correlation.filter_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_correlation.filter_form.getItemValue('as_of_date_to', true);
        var term_from = view_correlation.filter_form.getItemValue('term_from', true);
        var term_to = view_correlation.filter_form.getItemValue('term_to', true);
        var curve_source_value_combo = view_correlation.filter_form.getCombo('curve_source');
        var curve_source_value = (curve_source_value_combo.getChecked()).toString();
        
        var exec_call = '';
        exec_call = exec_call + "EXEC spa_view_correlation @flag='p'";
        exec_call = exec_call + ", @curve_id_from='" + curve_id_from + "'";
        exec_call = exec_call + ", @curve_id_to='" + curve_id_to + "'";
        exec_call = exec_call + ", @as_of_date_from='" + as_of_date_from + "'";
        exec_call = exec_call + ", @as_of_date_to='" + as_of_date_to + "'";
        exec_call = exec_call + ", @term_from='" + term_from + "'";
        exec_call = exec_call + ", @term_to='" + term_to + "'";
        exec_call = exec_call + ", @curve_source_value_id='" + curve_source_value + "'";

        var param = 'call_from=View Correlation&gen_as_of_date=1&batch_type=r&as_of_date=' + as_of_date_from; 

        adiha_run_batch_process(exec_call, param, 'View Correlation');
    }

    view_correlation.on_pivot_click = function() {
        /* Getting Selected Curve Id From Risk Bucket From Grid*/
        var rbf_selected_id = view_correlation.grid_a.getSelectedRowId();
        var cif_array = []; 
        if (rbf_selected_id != null) {
            var rbf_selected_id_split = rbf_selected_id.split(',');
            for(i=0; i<rbf_selected_id_split.length; i++) {
                var rbf_level = view_correlation.grid_a.getLevel(rbf_selected_id_split[i]);
                if (rbf_level == 1) {
                    var rbf_col_index = view_correlation.grid_a.getColIndexById('source_curve_def_id');
                    var rbf_value = view_correlation.grid_a.cells(rbf_selected_id_split[i], rbf_col_index).getValue();
                    cif_array.push(rbf_value);
                }
            }
        }
        var curve_id_from = cif_array.toString();
        if(curve_id_from == '') {
            show_messagebox('Please select Risk Bucket From curve id.');
            return;
        }
        
        /* Getting Selected Curve Id From Risk Bucket To Grid*/
        var rbt_selected_id = view_correlation.grid_b.getSelectedRowId();
        var cit_array = []; 
        if (rbt_selected_id != null) {
            var rbt_selected_id_split = rbt_selected_id.split(',');
            for(i=0; i<rbt_selected_id_split.length; i++) {
                var rbt_level = view_correlation.grid_b.getLevel(rbt_selected_id_split[i]);
                if (rbt_level == 1) {
                    var rbt_col_index = view_correlation.grid_b.getColIndexById('source_curve_def_id');
                    var rbt_value = view_correlation.grid_b.cells(rbt_selected_id_split[i], rbt_col_index).getValue();
                    cit_array.push(rbt_value);
                }
            }
        }
        var curve_id_to = cit_array.toString();
        if(curve_id_to == '') {
            show_messagebox('Please select Risk Bucket To curve id.');
            return;
        }

        /* Getting Filter Form Data*/
        var as_of_date_from = view_correlation.filter_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_correlation.filter_form.getItemValue('as_of_date_to', true);
        var term_from = view_correlation.filter_form.getItemValue('term_from', true);
        var term_to = view_correlation.filter_form.getItemValue('term_to', true);
        var curve_source_value_combo = view_correlation.filter_form.getCombo('curve_source');
        var curve_source_value = (curve_source_value_combo.getChecked()).toString();
        
        var pivot_exec_spa = '';
        pivot_exec_spa = pivot_exec_spa + "EXEC spa_view_correlation @flag='p'";
        pivot_exec_spa = pivot_exec_spa + ", @curve_id_from='" + curve_id_from + "'";
        pivot_exec_spa = pivot_exec_spa + ", @curve_id_to='" + curve_id_to + "'";
        pivot_exec_spa = pivot_exec_spa + ", @as_of_date_from='" + as_of_date_from + "'";
        pivot_exec_spa = pivot_exec_spa + ", @as_of_date_to='" + as_of_date_to + "'";
        pivot_exec_spa = pivot_exec_spa + ", @term_from='" + term_from + "'";
        pivot_exec_spa = pivot_exec_spa + ", @term_to='" + term_to + "'";
        pivot_exec_spa = pivot_exec_spa + ", @curve_source_value_id='" + curve_source_value + "'";

        open_grid_pivot('', 'view_correlation_grid', 1, pivot_exec_spa, 'View Correlation');
    }

    view_correlation.expand_collapse = function(grid_obj) {
        if(expand_state == 0) {
            grid_obj.expandAll();
            expand_state = 1;
        } else {
            grid_obj.collapseAll();
            expand_state = 0;
        }
    }

    view_correlation.expand_curve = function(grid_obj, r_id, col_id) {
        var selected_row = grid_obj.getSelectedRowId();
        var state = grid_obj.getOpenState(selected_row);

        if (state)
            grid_obj.closeItem(selected_row);
        else
            grid_obj.openItem(selected_row);
    }

    view_correlation.on_dock_event = function() {
        $('.undock_cell_a').show();
    }

    view_correlation.on_undock_event = function() {
        $('.undock_cell_a').hide();
    }
</script>
<body>
</body>
</html>