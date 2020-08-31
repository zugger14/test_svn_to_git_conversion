<?php
/**
* View recovery rate screen
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
    <body>
        <?php
        $function_id = 20000700;
        $namespace = 'view_recovery_rate';

        /* Privilege */
        $has_rights_recovery_rates = 20000700;

        $layout_json = '[
                {
                    id:             "a",
                    text:           "Ratings",
                    header:         true,
                    collapse:       false,
                    width:          350,
                    undock:         true
                },
                {
                    id:             "b",
                    text:           "Apply Filters",
                    header:         true,
                    collapse:       true,
                    height:         100
                },
                {
                    id:             "c",
                    text:           "Filters",
                    header:         true,
                    collapse:       false,
                    height:         300
                },
                {
                    id:             "d",
                    text:           "Recovery Rates",
                    header:         true,
                    collapse:       false,
                    undoxk:         true
                }
            ]';

        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout('layout', '', '4C', $layout_json, $namespace);
        echo $layout_obj->attach_event('', 'onDock', 'view_recovery_rate.on_dock_event');
        echo $layout_obj->attach_event('', 'onUnDock', 'view_recovery_rate.on_undock_event');

        /* Left Grid Menu Section */
        $menu_a_name = 'menu_a';
        $menu_a_json = '[
                                {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                                ]},
                                {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"},
                                {id:"select_unselect", text:"Select/Unselect", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1}
                            ]';
        echo $layout_obj->attach_menu_layout_cell($menu_a_name, 'a', $menu_a_json, $namespace . '.menu_a_onclick');

        /* Main Grid Section i.e. Rating Grid */
        $grid_a_name = 'grid_a';
        echo $layout_obj->attach_status_bar("a", true);
        echo $layout_obj->attach_grid_cell($grid_a_name, 'a');
        $grid_obj_a = new GridTable('view_recovery_rate');
        echo $grid_obj_a->init_grid_table($grid_a_name, $namespace);
        echo $grid_obj_a->enable_multi_select();
        echo $grid_obj_a->set_search_filter(true);
        echo $grid_obj_a->return_init();
        echo $grid_obj_a->load_grid_data("EXEC spa_view_recovery_rate 't'");
        echo $grid_obj_a->enable_paging(100, 'pagingArea_a', 'true');

        /* Apply Filter Section */


        /* Filter Form Section */
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20000700', @template_name='View Recovery Rate', @parse_xml=''";
        $form_arr = readXMLURL2($form_sql);
        $tab_id = $form_arr[0]['tab_id'];
        $form_json = $form_arr[0]['form_json'];
        echo $layout_obj->attach_form('filter_form', 'c');
        $form_filter_obj = new AdihaForm();
        echo $form_filter_obj->init_by_attach('filter_form', $namespace);
        echo $form_filter_obj->load_form($form_json);

        /* Menu for Recovery Rates Grid Section */
        $menu_d_name = 'menu_d';
        $menu_d_json = '[
                                {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                                {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled: "'. $has_rights_recovery_rates .'"},
                                {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", enabled: "'. $has_rights_recovery_rates .'"},
                                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", enabled: "'. $has_rights_recovery_rates .'"}
                                ]},
                                {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled: 0},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled: 0},
                                    {id:"batch", text:"Batch", img:"batch.gif", imgdis:"batch_dis.gif", enabled: 0}
                                ]},
                                {id:"select_unselect_d", text:"Select/Unselect", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 0},
                                {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif", enabled: 0}
                            ]';
        echo $layout_obj->attach_menu_layout_cell($menu_d_name, 'd', $menu_d_json, $namespace . '.menu_d_onclick');

        /* Recovery Rates Grid Section */


        echo $layout_obj->close_layout();
        ?>
    </body>
    <script>
    var today = new Date();
    var new_date = new Date(today.getFullYear(), today.getMonth() , today.getDate());
    var has_rights_recovery_rates = <?php echo (($has_rights_recovery_rates) ? '1' : '0'); ?>;
    var expand_state = 0;
    var grid_d_changed_cell_arr = [[]];
    var grid_d_delete_cell_arr = [[]];
    var grid_d_delete_xml = [];
    var grid_d_save_xml = [];
    var refresh_flag = false;

    $(function() {        
        view_recovery_rate.filter_form.setItemValue('as_of_date_from', new_date);

        filter_form = view_recovery_rate.layout.cells('b').attachForm();
        layout_cell_b = view_recovery_rate.layout.cells('c');
        load_form_filter(filter_form, layout_cell_b, '20000700', 2);

        view_recovery_rate.grid_a.attachEvent("onRowSelect",function(rowId,cellIndex) {
            refresh_flag = false;
        });

        view_recovery_rate.filter_form.attachEvent("onChange", function (name, value) {
             if (name == 'show_months') {
                if(refresh_flag)
                    view_recovery_rate.refresh();
             }
        });

        view_recovery_rate.grid_a.attachEvent("onRowDblClicked", function(rId,cInd){
            view_recovery_rate.expand_curve(view_recovery_rate.grid_a);
        });
    });

    view_recovery_rate.menu_a_onclick = function(id) {
        switch(id) {
            case 'excel':
                view_recovery_rate.export('excel', view_recovery_rate.grid_a);
            break;
            case 'pdf':
                view_recovery_rate.export('pdf', view_recovery_rate.grid_a);
            break;
            case 'select_unselect':
                view_recovery_rate.select_unselect(view_recovery_rate.grid_a);
            break;
            case 'expand_collapse':
                view_recovery_rate.expand_collapse(view_recovery_rate.grid_a);
            break;
        }
    }

    view_recovery_rate.menu_d_onclick = function(id) {
        switch(id) {
            case 'refresh':
                refresh_flag = true;
                view_recovery_rate.refresh();
            break;
            case 'save':
                view_recovery_rate.on_save_click();
            break;
            case 'add':
                view_recovery_rate.on_add_click();
            break;
            case 'delete':
                view_recovery_rate.on_delete_click();
            break;
            case 'excel':
                view_recovery_rate.export('excel', view_recovery_rate.grid_d);
            break;
            case 'pdf':
                view_recovery_rate.export('pdf', view_recovery_rate.grid_d);
            break;
            case 'select_unselect_d':
                view_recovery_rate.select_unselect(view_recovery_rate.grid_d, id);
            break;
            case 'pivot':
                view_recovery_rate.on_pivot_click();
            break;
            case 'batch':
                view_recovery_rate.on_batch_click();
            break;
        }
    }

    view_recovery_rate.refresh = function() {
        grid_d_del_flag = 0;

        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'add', 1);
        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'delete', 0);
        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'save', 0);
        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'pivot', 1);

        var as_of_date = view_recovery_rate.filter_form.getItemValue('as_of_date', true);
        var round_value = view_recovery_rate.filter_form.getItemValue('round_value');
        var as_of_date_from = view_recovery_rate.filter_form.getItemValue('as_of_date_from', true);        
        var as_of_date_to = view_recovery_rate.filter_form.getItemValue('as_of_date_to', true);
        var show_months = (view_recovery_rate.filter_form.isItemChecked('show_months') ? 1 : 0);

        // if(as_of_date_from == '' || as_of_date_from == null) {
        //     view_recovery_rate.filter_form.setItemValue('as_of_date_from', new_date);
        //     as_of_date_from = view_recovery_rate.filter_form.getItemValue('as_of_date_from', true); 
        // }

        // if (as_of_date_to == '' || as_of_date_to == null) {
        //     as_of_date_to = as_of_date_from;
        // }
        
        if (as_of_date_to != '' && as_of_date_from != '' && as_of_date_from > as_of_date_to) {
            show_messagebox('As of Date To should be greater than As of Date From.');
            return;
        }

        var grid_a_selected_row = view_recovery_rate.grid_a.getSelectedId();
        if(grid_a_selected_row == null || grid_a_selected_row == '') {
            show_messagebox('Please select recovery rate.');
            return;
        }
        var grid_a_selected_row_array = grid_a_selected_row.split(',');
        var selected_value_id = [];
        $.each(grid_a_selected_row_array, function(index, value) {
            var tree_level = view_recovery_rate.grid_a.getLevel(value);
            if(tree_level == 1) {
                var col_index = view_recovery_rate.grid_a.getColIndexById('value_id');
                var value_ids = view_recovery_rate.grid_a.cells(value, col_index).getValue();
                selected_value_id.push(value_ids);
            }
        });

        var data = {
                        "action": "spa_view_recovery_rate",
                        "flag": "s",
                        "as_of_date_from": as_of_date_from,
                        "as_of_date_to": as_of_date_to,
                        "round_value": round_value,
                        "show_months" : show_months,
                        "debt_rating": selected_value_id.toString()
                    };
        
        adiha_post_data('return_json', data, '', '', 'view_recovery_rate.refresh_callback', '', '');

    }

    view_recovery_rate.refresh_callback = function(result) {
        var return_data = JSON.parse(result);
        var data_length = return_data.length;
        var process_id = return_data[0].process_id;
        var round_value = view_recovery_rate.filter_form.getItemValue('round_value');

        var grid_d_header1 = new Array();
        var grid_d_header2 = new Array();
        var grid_d_col_type = new Array();
        var grid_d_col_align = new Array();
        var grid_d_col_align_right = new Array();  
        var grid_d_col_width = new Array();
        var grid_d_col_validator = new Array();   
        var grid_d_col_rounding = new Array();
        var grid_d_col_data_type = new Array();
   
        var h1, h2;
        grid_d_h1 = [];
        grid_d_h2 = [];
        grid_d_h3 = [];
        grid_d_changed_cell_arr = [[]];
        grid_d_delete_cell_arr = [[]];
        grid_d_delete_xml = [];

        for(i=0; i<data_length; i++) {
            if(return_data[i].name == 'Effective Date') {
                grid_d_header1.push(return_data[i].name);
                grid_d_header2.push("#rspan");
                grid_d_col_type.push("dhxCalendarA");
                grid_d_col_align_right.push('"text-align:left;"');
                grid_d_col_width.push(100);
                grid_d_col_rounding.push('');
                grid_d_col_data_type.push('');
            } else {
                var temp_array = return_data[i].name.split('::');
                var temp_array_length = temp_array.length;

                if(temp_array[1] == 'Rate'){
                    grid_d_col_rounding.push(round_value);
                    grid_d_col_data_type.push('float');
                    grid_d_col_type.push("edn");
                } else {
                    grid_d_col_rounding.push('');
                    grid_d_col_data_type.push('');
                    grid_d_col_type.push("ed");
                }

                for (j=0; j<temp_array_length; j++) {
                    if(j == 0) {
                        if(h1 == temp_array[2]) {
                            grid_d_header1.push("#cspan");
                        } else {
                            grid_d_header1.push(temp_array[j]);
                        }
                        h1 = temp_array[2];
                        grid_d_h1.push(temp_array[j]);
                    } else if (j == 1) {
                        grid_d_header2.push(temp_array[j]);
                        grid_d_h2.push(temp_array[j]);
                    } else if (j == 2) {
                        grid_d_h3.push(temp_array[j]);
                    }

                    grid_d_col_align_right.push('"text-align:right;"');
                    grid_d_col_width.push(50);
                    grid_d_col_validator.push(["NotEmpty","", ""]);
                }
            }
        }
        
        var grid_d_header2_str = jQuery.parseJSON('["' + grid_d_header2.toString().replace(/,/g, '", "') + '"]');
        var grid_d_col_align_right = jQuery.parseJSON('[' + grid_d_col_align_right.toString() + ']');
        var grid_d_col_width = grid_d_col_width.toString();
        var grid_d_col_type = grid_d_col_type.toString();
        var grid_d_col_validator_str = grid_d_col_validator.toString();
        var grid_d_col_rounding = grid_d_col_rounding.toString();
        var grid_d_col_data_type = grid_d_col_data_type.toString();

        view_recovery_rate.layout.cells('d').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_d"></div>'
                            });
        
        view_recovery_rate.grid_d = view_recovery_rate.layout.cells('d').attachGrid();
        view_recovery_rate.grid_d.setImagePath(js_image_path + "dhxgrid_web/");
        view_recovery_rate.grid_d.setHeader(get_locale_value(grid_d_header1.toString(),true), null, grid_d_col_align_right);
        view_recovery_rate.grid_d.attachHeader(grid_d_header2, grid_d_col_align_right);
        view_recovery_rate.grid_d.setInitWidths(grid_d_col_width);
        view_recovery_rate.grid_d.setColTypes(grid_d_col_type);
        view_recovery_rate.grid_d.enableValidation(true);
        // view_recovery_rate.grid_d.setColValidators(grid_d_col_validator_str);
        view_recovery_rate.grid_d.enableMultiselect(true);
        view_recovery_rate.grid_d.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        view_recovery_rate.grid_d.enablePaging(true, 100, 0, 'pagingArea_d');  
        view_recovery_rate.grid_d.setPagingSkin('toolbar');
        view_recovery_rate.grid_d.init();
        view_recovery_rate.grid_d.setDateFormat(user_date_format);
        
        if (round_value && round_value != '') {
            view_recovery_rate.grid_d.enableRounding(grid_d_col_rounding);
        }
        view_recovery_rate.grid_d.attachEvent('onRowSelect', function() {
            view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'delete', 1);
            view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'save', 1);
        });
        view_recovery_rate.grid_d.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (stage == 2) {
                if (nValue != oValue && cInd >= 1) {
                    grid_d_changed_cell_arr.push([rId, cInd]);
                }
            } 
            return true;
        });

        view_recovery_rate.grid_d.attachEvent("onValidationError",function(id,ind,value){
            var message = "Invalid Data";
            view_recovery_rate.grid_d.cells(id,ind).setAttribute("validation", message);
            return true;
        });

        view_recovery_rate.grid_d.attachEvent("onValidationCorrect",function(id,ind,value){
            view_recovery_rate.grid_d.cells(id,ind).setAttribute("validation", "");
            return true;
        });

        view_recovery_rate.load_grid_d(process_id);  

        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'excel', 1);      
        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'pdf', 1);      
        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'batch', 1);      
        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'select_unselect_d', 1);      
        view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'pivot', 1);      
    }

    view_recovery_rate.on_add_click = function() {
        var new_id = (new Date()).valueOf();
        view_recovery_rate.grid_d.addRow(new_id, '');
        // view_recovery_rate.grid_d.cells(new_id, 0).setValue(new_date);
        view_recovery_rate.validate_grid_d_cell();
    }

    view_recovery_rate.build_grid_d_save_xml = function(menu_id) {
        var row_col_arr;
        var check_greater;
        var month_value;
        var grid_xml = '';

        if(menu_id == 'save') {
            row_col_arr = grid_d_changed_cell_arr;
        } else if(menu_id = 'delete') {
            row_col_arr = grid_d_delete_cell_arr;
        }

        for(i=1; i<row_col_arr.length; i+=2) {
            var row_index = row_col_arr[i][0];
            var cellIndex = row_col_arr[i][1];

            grid_xml = grid_xml + '<GridRow';            
            grid_xml = grid_xml + ' effective_date="' + dates.convert_to_sql(view_recovery_rate.grid_d.cells(row_index,0).getValue()) + '"';
            
            if (view_recovery_rate.grid_d.cells(row_index,0).getValue()  == '') {
                maturity_date_flag = 1;
            } 
            
            grid_xml = grid_xml + ' debt_rating="' + grid_d_h3[cellIndex-1] + '"';
            
            if(cellIndex > 1 && cellIndex % 2 == 0) {
                check_greater = view_recovery_rate.grid_d.cells(row_index,cellIndex-1).getValue();
                grid_xml = grid_xml + ' rate="' + check_greater + '"';
                
            } else {
                check_greater = view_recovery_rate.grid_d.cells(row_index,cellIndex).getValue();
                grid_xml = grid_xml + ' rate="' + check_greater + '"';
            }
            
            if(cellIndex > 1 && cellIndex % 2 == 0) {
                month_value = view_recovery_rate.grid_d.cells(row_index,cellIndex).getValue();
                grid_xml = grid_xml + ' months="' + month_value + '"';
            } else {
                month_value = view_recovery_rate.grid_d.cells(row_index,cellIndex+1).getValue();
                grid_xml = grid_xml + ' months="' + month_value + '"';
            } 

            if(check_greater != '') {
                if(check_greater > 1 || check_greater <= 0 ) {
                    return -1;
                } else if(isNaN(check_greater)) {
                    return -2;
                    break;
                }
            }

            if(month_value != '') {
                if(month_value === parseInt(month_value, 10) || month_value < 1 || isNaN(month_value)) {
                    return -2;
                    break;
                }
            }            

            grid_xml = grid_xml + '></GridRow>';
        }
        
        return grid_xml;
    }

    view_recovery_rate.on_delete_click = function() {
        var row_id = view_recovery_rate.grid_d.getSelectedRowId();
        var row_id_array = row_id.split(",");
        grid_d_delete_cell_arr = [[]];
        for (count = 0; count < row_id_array.length; count++) {
            for (count1 = 1; count1 < view_recovery_rate.grid_d.getColumnsNum(); count1++) {
                grid_d_delete_cell_arr.push([row_id_array[count], count1]);   
            }
        }
        var delete_xml = view_recovery_rate.build_grid_d_save_xml('delete');         
        grid_d_delete_xml = grid_d_delete_xml + delete_xml;
        
        for (count = 0; count < row_id_array.length; count++) {
            var new_check = view_recovery_rate.grid_d.cells(row_id_array[count], 1).getValue();
            if (new_check != '') { grid_d_del_flag = 1; }
            view_recovery_rate.grid_d.deleteRow(row_id_array[count]);
        }
    }

    view_recovery_rate.on_save_click = function() {
        var grid_xml = '<Root><GridGroup>';
        var grid_d_save_xml = '';

        view_recovery_rate.grid_d.clearSelection();
        view_recovery_rate.validate_grid_d_cell();

        var grid_d_status = view_recovery_rate.validate_form_grid(view_recovery_rate.grid_d, 'Recovery Rates');
        if (grid_d_status == false) {
            return;
        }

        grid_d_save_xml = view_recovery_rate.build_grid_d_save_xml('save');

        if(grid_d_save_xml == -1) {
            grid_d_changed_cell_arr = [[]];
            show_messagebox('Rate should be between 0 to 1.');
            view_recovery_rate.refresh();
            return;
        } else if(grid_d_save_xml == -2) {
            show_messagebox('Please insert valid numeric data.');
            return;
        } 
               
        if (grid_d_save_xml != '') {
            grid_xml = grid_xml + '<Grid>';
            if (grid_d_save_xml != '') {
                 grid_xml = grid_xml + grid_d_save_xml;    
            }
            grid_xml = grid_xml + '</Grid>';
        }
        
        if (grid_d_delete_xml != '') {
            grid_xml = grid_xml + '<GridDelete>';
            if (grid_d_delete_xml != '') {
                grid_xml = grid_xml + grid_d_delete_xml;
            }
            grid_xml = grid_xml + '</GridDelete>';
        }
        grid_xml = grid_xml + '</GridGroup></Root>';

        var sql = {
                    "action": "spa_view_recovery_rate",
                    "flag": "i",
                    "xml": grid_xml
                };

        if(grid_d_del_flag == 1) {
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
                text: "Some data has been deleted from recovery rates grid. Are you sure you want to save?",
                callback: function(result) {
                    if (result) {
                        adiha_post_data('alert', sql, '', '', view_recovery_rate.refresh, '', '');
                    }                    
                }
            });
        } else if (grid_xml == '<Root><GridGroup></GridGroup></Root>') {
            show_messagebox('No changes in the grid.');
            return;
        } else {
            adiha_post_data('alert', sql, '', '', view_recovery_rate.refresh, '', '');
        }

    }

    view_recovery_rate.load_grid_d = function(process_id) {
        var sql = {
                    "action": "spa_view_recovery_rate",
                    "flag": "s",
                    "process_id": process_id
                };
        var param_sql = $.param(sql);
        var param_url = js_data_collector_url + "&" + param_sql;
        view_recovery_rate.grid_d.loadXML(param_url);
    }

    view_recovery_rate.export = function(format, grid_obj) {
        switch(format) {
            case 'excel':
                grid_obj.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
            break;
            case 'pdf':
                grid_obj.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
            break;
        }
    }

    view_recovery_rate.expand_collapse = function(grid_obj) {
        if(expand_state == 0) {
            grid_obj.expandAll();
            expand_state = 1;
        } else {
            grid_obj.collapseAll();
            expand_state = 0;
        }
    }

    view_recovery_rate.select_unselect = function(grid_obj, id) {  
        var selected_id = grid_obj.getSelectedRowId();
        if(selected_id == null) {
            view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'delete', 1);
            if(id == 'select_unselect_d') { 
                var ids = grid_obj.getAllRowIds();                                            
                for (var id in ids) {
                   grid_obj.selectRow(id, true, true, false);
                }
                view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'save', 1);
            } else {  
                grid_obj.expandAll();               
                grid_obj.selectAll();
            }            
        } else {
            if(!id){
                grid_obj.collapseAll();
            }
            grid_obj.clearSelection();
            view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'delete', 0);
            view_recovery_rate.enable_disable_menu(view_recovery_rate.menu_d, 'save', 0);
        }
    }

    view_recovery_rate.on_batch_click = function() {

        var as_of_date = view_recovery_rate.filter_form.getItemValue('as_of_date', true);
        var round_value = view_recovery_rate.filter_form.getItemValue('round_value');
        var as_of_date_from = view_recovery_rate.filter_form.getItemValue('as_of_date_from', true);        
        var as_of_date_to = view_recovery_rate.filter_form.getItemValue('as_of_date_to', true);
        var show_months = (view_recovery_rate.filter_form.isItemChecked('show_months') ?1 : 0);

        if(as_of_date_from == '' || as_of_date_from == null) {
            view_recovery_rate.filter_form.setItemValue('as_of_date_from', new_date);
            as_of_date_from = view_recovery_rate.filter_form.getItemValue('as_of_date_from', true); 
        }

        if (as_of_date_to == '' || as_of_date_to == null) {
            as_of_date_to = as_of_date_from;
        }
        
        if (as_of_date_to != '' && as_of_date_from != '' && as_of_date_from > as_of_date_to) {
            show_messagebox('As of Date To should be greater than As of Date From.');
            return;
        }

        var grid_a_selected_row = view_recovery_rate.grid_a.getSelectedId();
        if(grid_a_selected_row == null || grid_a_selected_row == '') {
            show_messagebox('Please select Ratings.');
            return;
        }
        var grid_a_selected_row_array = grid_a_selected_row.split(',');
        var selected_value_id = [];
        $.each(grid_a_selected_row_array, function(index, value) {
            var tree_level = view_recovery_rate.grid_a.getLevel(value);
            if(tree_level == 1) {
                var col_index = view_recovery_rate.grid_a.getColIndexById('value_id');
                var value_ids = view_recovery_rate.grid_a.cells(value, col_index).getValue();
                selected_value_id.push(value_ids);
            }
        });
        
        var exec_call = "EXEC spa_view_recovery_rate @flag='p', @as_of_date_from='" + as_of_date_from 
                                        + "',@as_of_date_to='" + as_of_date_to 
                                        + "',@round_value='" + round_value 
                                        + "',@show_months='" + show_months 
                                        + "',@debt_rating='" + selected_value_id.toString() + "'";
        var param = 'call_from=View Recovery Rate&gen_as_of_date=1&batch_type=r&as_of_date=' + as_of_date_from; 
        adiha_run_batch_process(exec_call, param, 'View Recovery Rate');
    }

    view_recovery_rate.on_pivot_click = function() {
        var debt_rating = grid_d_h3.join(",");
        var as_of_date_from = view_recovery_rate.filter_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_recovery_rate.filter_form.getItemValue('as_of_date_to', true);
        if (as_of_date_to == '') {
            as_of_date_to = as_of_date_from;
        }
        var show_months = (view_recovery_rate.filter_form.isItemChecked('show_months') ?1 : 0);
        var pivot_exec_spa = "EXEC spa_view_recovery_rate @flag='p', @debt_rating='" + debt_rating
                                                        + "',@as_of_date_from='" + as_of_date_from 
                                                        + "',@show_months='" + show_months 
                                                        + "',@as_of_date_to='" + as_of_date_to + "'";

        if(show_months == '1') {
            open_grid_pivot('', 'view_recovery_rate_m', 1, pivot_exec_spa, 'Recovery Rate');
        } else {

        }  open_grid_pivot('', 'view_recovery_rate', 1, pivot_exec_spa, 'Recovery Rate');
    }

    /*status 1 for enabling and 0 for disabling the selected menu*/
    view_recovery_rate.enable_disable_menu = function(menu_obj, menu_id, status) {
        if(has_rights_recovery_rates) {
            if(status == 1) {
                menu_obj.setItemEnabled(menu_id);
            } else if(status == 0) {
                menu_obj.setItemDisabled(menu_id);
            }
        }
    }

    view_recovery_rate.validate_grid_d_cell = function() {
        view_recovery_rate.grid_d.forEachRow(function(row){
            view_recovery_rate.grid_d.forEachCell(row,function(cellObj,ind){
                view_recovery_rate.grid_d.validateCell(row,ind)
            });
        });
    }

    view_recovery_rate.validate_form_grid = function(grid_obj, grid_name) {
        var status = true;
        for (var i = 0;i < grid_obj.getRowsNum();i++){
            var row_id = grid_obj.getRowId(i);
            
            for (var j = 0;j < grid_obj.getColumnsNum();j++){ 
                var validation_message = grid_obj.cells(row_id,j).getAttribute("validation");
                
                if(validation_message != "" && validation_message != undefined){
                    var column_text = grid_obj.getColLabel(j);
                    error_message = "Data Error in <b>"+grid_name+"</b> grid. Please check the data in column <b>"+column_text+"</b> and save.";
                    // dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                    status = false; 
                    break;
                }
            }
            if(validation_message != "" && validation_message != undefined){ break;};
         }
        return status;
    }


    view_recovery_rate.expand_curve = function(grid_obj, r_id, col_id) {
        var selected_row = grid_obj.getSelectedRowId();
        var state = grid_obj.getOpenState(selected_row);

        if (state)
            grid_obj.closeItem(selected_row);
        else
            grid_obj.openItem(selected_row);
    }

    </script>
</html>