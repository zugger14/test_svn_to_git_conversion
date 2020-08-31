<?php
/**
* Setup regression testing configuration screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
   
    <body>
        <?php 
            $function_id =  20013600;
            $form_namespace = 'setup_regression_testing_configuration';
            $template_name = "SetupRegressionConfiguration";
            $form_obj = new AdihaStandardForm($form_namespace,  20013600);
            $form_obj->define_grid("regression_module_header");
            $form_obj->define_layout_width(300);
            echo $form_obj->init_form('Setup Regression Configuration');
            echo $form_obj->define_custom_functions('', '', '', 'after_form_load', 'before_save');
            echo $form_obj->close_form();
        ?>
    </body>
    <script type="text/javascript">
        var ___browse_table_columns_window;
        var browser_name;
        var win_len = 550;
        var win_width = 400;
        var type;
        var table_report_id;

        setup_regression_testing_configuration.after_form_load = function(win, id) {

            //var form_obj = 
            
            var obj_collection = setup_regression_testing_configuration.get_detail_grid_object('detail');
            var detail_grid_obj= obj_collection['dtl_grd_obj'];

            var header_form_obj = obj_collection['hdr_frm_obj'];
            //console.log(detail_grid_obj, header_form_obj);
            

            // detail_grid_obj.attachEvent("onXLE", function(grid_obj,count){
            //     detail_grid_obj.attachEvent("onCellChanged", function(rId,cInd,nValue){
            //         var table_name_index = detail_grid_obj.getColIndexById("table_name");
            //         var report_column_index = detail_grid_obj.getColIndexById("regg_rpt_paramset_hash");
            //         // if(nValue.split('^')[1] == detail_grid_obj.cells(rId,table_name_index).getValue().split('^')[0]) {
            //         //     return;
            //         // }
                   
            //         if(report_column_index == cInd) {
            //              //console.log(detail_grid_obj.cells(rId, table_name_index))
            //             var browser_tbl_lbl = detail_grid_obj.cells2(rId, table_name_index).cell.innerText;
            //             //alert(browser_tbl_lbl);
            //             if( browser_tbl_lbl ==''){
            //                 var new_report_name = nValue.split('^')[1];
            //                 detail_grid_obj.cells(rId,table_name_index).setValue(new_report_name + '^');
            //             }

            //         }
            //     });
            // });
            

            if(detail_grid_obj) {
                detail_grid_obj.attachEvent("onRowDblClicked", function(rid, cid) {
                    var unique_columns = detail_grid_obj.getColIndexById("unique_columns");
                    var compare_columns = detail_grid_obj.getColIndexById("compare_columns");
                    var display_columns = detail_grid_obj.getColIndexById("display_columns");

                    //alert(unique_columns + ' ' + cid)
                    var table_index=detail_grid_obj.getColIndexById("table_name"); 
                    var report_index=detail_grid_obj.getColIndexById("regg_rpt_paramset_hash"); 

                    var table_value = detail_grid_obj.cells(rid, table_index).getValue();
                    var report_value = detail_grid_obj.cells(rid, report_index).getValue();
                    var browser_lbl = '';
                    var system_id = header_form_obj.getItemValue('regression_module_header_id');
                    browser_lbl = detail_grid_obj.cells(rid, report_index).getTitle();
                    
                    //if((table_value !='' && report_value != '') && browser_lbl != table_value) {
                    if(((table_value !='' && report_value != '') && browser_lbl != table_value) || (table_value != '' && report_value == '')) {
                        type = 't';
                        table_report_id = table_value;
                    } else {
                        type = 'r';
                        table_report_id = report_value;
                    } 

                    if(unique_columns == cid || compare_columns == cid || display_columns == cid) {
                        var selected_column_value = detail_grid_obj.cells(rid, cid).getValue();


                        if(unique_columns == cid) {
                            browser_name = "Unique Columns";
                        } else if(display_columns == cid) {
                            browser_name = "Display Columns";
                        } else if(compare_columns == cid) {
                            browser_name = "Compare Columns";
                        }

                        if(!___browse_table_columns_window) {
                             ___browse_table_columns_window = new dhtmlXWindows();
                        }
                        new_browse = ___browse_table_columns_window.createWindow('w1', 0, 0, win_len, win_width);
                        new_browse.setText("Browse " + browser_name);
                        new_browse.centerOnScreen();
                        new_browse.setModal(true);
                        var params = {};
                        //alert(js_php_path);
                        var src = js_php_path + 'adiha.html.forms/_setup/setup_regression_testing_configuration/browse.table.columns.php'; 

                        src = src.replace("adiha.php.scripts/", ""); 
                        //alert(11)
                        // return;
                        params = {
                            "id": table_report_id,
                            "type": type,
                            "selected_column_value": selected_column_value,
                            "row_id": rid,
                            "col_id": cid
                        }

                        new_browse.attachURL(src, false, params);
                    }

                });
            }

            detail_grid_obj_dependencies = setup_regression_testing_configuration.get_detail_grid_object('dependencies')['dp_grd_obj'];
            if (detail_grid_obj_dependencies) {
                detail_grid_obj_dependencies.copyFromExcel(true);
            }
        }

        setup_regression_testing_configuration.set_cell_data = function(value,row_id,col_id) {
            var detail_grid_obj = setup_regression_testing_configuration.get_detail_grid_object('detail')['dtl_grd_obj'];
            detail_grid_obj.cells(row_id,col_id).setValue(value.join(','));
            detail_grid_obj.cells(row_id,col_id).cell.wasChanged = true;
            //alert(value+ row_id +  col_id)

        }

        setup_regression_testing_configuration.get_detail_grid_object = function(grid_name) {
            var tab_obj = setup_regression_testing_configuration.layout.cells('b').getAttachedObject();
            var active_tab_id = setup_regression_testing_configuration.layout.cells('b').getAttachedObject().getActiveTab();
            var inner_tab_obj = tab_obj.tabs(active_tab_id).getAttachedObject();
            var detail_grid_obj, header_form_object;
            var form_grid_obj = {};
            inner_tab_obj.getAllTabs().forEach(function(id) {
                if(inner_tab_obj.tabs(id).getText() == "General" && grid_name == 'detail')  {
                    detail_grid_obj = inner_tab_obj.tabs(id).getAttachedObject().cells('b').getAttachedObject();
                    header_form_object = inner_tab_obj.tabs(id).getAttachedObject().cells('a').getAttachedObject();
                    form_grid_obj.dtl_grd_obj = detail_grid_obj;
                    form_grid_obj.hdr_frm_obj = header_form_object;
                } else  if(inner_tab_obj.tabs(id).getText() == "Dependencies" && grid_name == 'dependencies')  {
                    detail_grid_obj = inner_tab_obj.tabs(id).getAttachedObject().cells('a').getAttachedObject();
                    form_grid_obj.dp_grd_obj = detail_grid_obj;
                }
            }); 
        
            //console.log(form_grid_obj);
            return form_grid_obj;  
        }

        setup_regression_testing_configuration.before_save = function() {
            var detail_grid = setup_regression_testing_configuration.get_detail_grid_object('detail')['dtl_grd_obj'];
            var unique_col_index = detail_grid.getColIndexById('unique_columns');
            var display_col_index = detail_grid.getColIndexById('display_columns');
            var compare_col_index = detail_grid.getColIndexById('compare_columns');
            var is_valid = true;

            detail_grid.forEachRow(function(row_id) {
                var unique_col_value = detail_grid.cells(row_id, unique_col_index).getValue();
                var display_col_value = detail_grid.cells(row_id, display_col_index).getValue();
                var compare_col_value = detail_grid.cells(row_id, compare_col_index).getValue();

                display_col_value = display_col_value.split(',');
                unique_col_value = unique_col_value.split(',');
                compare_col_value = compare_col_value.split(',');

                var common_data_ud = display_col_value.filter(element => unique_col_value.includes(element));
                var common_data_dc = display_col_value.filter(element => compare_col_value.includes(element));
                var common_data_uc = unique_col_value.filter(element => compare_col_value.includes(element));

                if (common_data_ud.length > 0 || common_data_dc.length > 0 || common_data_uc.length > 0) {
                    var com_dat = '';
                    if (common_data_ud.length > 0) {
                        com_dat += common_data_ud.toString()
                    }
                    if (common_data_dc.length > 0) {
                        com_dat += common_data_dc.toString()
                    }
                    if (common_data_uc.length > 0) {
                        com_dat += common_data_uc.toString()
                    }
                    
                    var msg = "Same column(s) <b>" + com_dat + "</b> cannot be used in <b>Unique Column</b>, <b>Compare Columns</b> and <b>Display Column</b>."
                    show_messagebox(msg)
                    is_valid = false;
                }
            });
            return is_valid;
        }

    </script>
</html>