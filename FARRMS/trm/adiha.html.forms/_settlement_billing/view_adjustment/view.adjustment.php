<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    
</head>
    
<body class = "bfix">
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $rights_view_adjustment = 20007300;
    $rights_view_adjustment_delete = 20007301;

    list (
        $has_rights_view_adjustment,
        $has_rights_view_adjustment_delete,
    ) = build_security_rights(
        $rights_view_adjustment,
        $rights_view_adjustment_delete
    );
    
    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filter",
                    header:         true,
                    collapse:       true,
                    height:         100
                },
                {
                    id:             "b",
                    text:           "Filter Criteria",
                    header:         true,
                    collapse:       false,
                    height:         170
                },
                {
                    id:             "c",
                    text:           "View Adjustment",
                    header:         true,
                    collapse:       false
                }  
            ]';
    
    $namespace = 'view_adjustment';
    $view_adjustment_layout_obj = new AdihaLayout();
    echo $view_adjustment_layout_obj->init_layout('view_adjustment_layout', '', '3E', $json, $namespace);
 
    //Attaching Filter
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20007300', @template_name='ViewAdjustment'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $view_adjustment_layout_obj->attach_form('view_adjustment_form', 'b');
    $view_adjustment_form = new AdihaForm();
    echo $view_adjustment_form->init_by_attach('view_adjustment_form', $namespace);
    echo $view_adjustment_form->load_form($form_json);

     //Attaching Menu in cell c
    $menu_obj = new AdihaMenu();
    $menu_name = 'left_menu';
    $menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh"},
                    {id: "edit", img:"edit.gif", imgdis: "edit_dis.gif", text: "Edit", items:[
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", enabled:false}
                        ]
                    },
                    {id:"process", text:"Process", img:"process.gif", imgdis:"process_dis.gif", items:[
                            {id:"adjust", text:"Adjust", img:"run.gif", imgdis:"run_dis.gif", enabled:false}
                        ]
                    },
                    {id: "export", img:"export.gif", imgdis: "export_dis.gif", text: "Export", items:[
                            {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                            {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true}
                        ]
                    },
                    {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"}
                ]';
    echo $view_adjustment_layout_obj->attach_menu_cell($menu_name, 'c');
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.grid_menu_click');


    //Attaching grid in cell 'c'
    $grid_obj = new AdihaGrid();
    $grid_name = 'view_adjustment_grid';
    echo $view_adjustment_layout_obj->attach_grid_cell($grid_name, 'c');
    
    $xml_file = "EXEC spa_adiha_grid 's','ViewAdjustment'";
    $resultset = readXMLURL2($xml_file);

    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($resultset[0]['column_label_list']);
    echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset[0]['column_width']);
    echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
    echo $grid_obj->enable_multi_select(false);
    echo $grid_obj->set_search_filter(true);
    echo $grid_obj->return_init();
    echo $grid_obj->attach_event('', 'onRowSelect', $namespace . '.enable_menu_item');
    echo $grid_obj->load_grid_functions();
    echo $view_adjustment_layout_obj->close_layout();  
    
    ?> 
    
</body>
    
<script type="text/javascript">  
    var has_rights_view_adjustment_delete = <?php echo (($has_rights_view_adjustment_delete) ? $has_rights_view_adjustment_delete : '0'); ?>;
    var php_script_loc = '<?php echo $php_script_loc; ?>';
    var check_show_adjusted_value

    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth();
    var yyyy = today.getFullYear();

    $(function(){
        filter_obj = view_adjustment.view_adjustment_layout.cells('a').attachForm();
        var layout_cell_obj = view_adjustment.view_adjustment_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '20007300', 2);

        var date_from = new Date(yyyy, mm -1 , 1);
        var date_to = new Date(yyyy, mm, 0);
        date_from = formatDate(date_from);
        date_to = formatDate(date_to);       

        view_adjustment.view_adjustment_form.setItemValue('production_month_from', date_from);
        view_adjustment.view_adjustment_form.setItemValue('production_month_to', date_to);

        view_adjustment.view_adjustment_form.attachEvent("onChange", function(name,value,is_checked){
            if (name == 'production_month_from') {
                var date_from = view_adjustment.view_adjustment_form.getItemValue(name, true);
                var split = date_from.split('-');
                var year =  +split[0];
                var month = +split[1];
                var day = +split[2];

                var date = new Date(year, month-1, day);
                var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                date_end = formatDate(lastDay);
                
                var to_name = name.replace("from", "to");
                view_adjustment.view_adjustment_form.setItemValue(to_name, date_end);
            } 
            // else if (name == 'show_adjusted_value'){
            //     view_adjustment_refresh();
            // }   
        });
    });

     view_adjustment.grid_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case "refresh":
                view_adjustment_refresh('i');
                break;
            case "delete":
                delete_data();
                break;
            case "excel":
                view_adjustment.view_adjustment_grid.toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case "pdf":
                 view_adjustment.view_adjustment_grid.toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "adjust":
                create_invoice();
                break;
            // case "finalize":
            //     finalize_unfinalize_invoice('a');
            //     break;
            // case "unfinalize":
            //     finalize_unfinalize_invoice('b');
            //     break;
            case "pivot":
                view_adjustment_refresh('p');
                break;
        }
    }

    function view_adjustment_refresh(flag) {
        view_adjustment.left_menu.setItemDisabled('delete');
        view_adjustment.left_menu.setItemDisabled('adjust');
        view_adjustment.left_menu.setItemEnabled('pivot');
        // view_adjustment.left_menu.setItemDisabled('finalize');
        // view_adjustment.left_menu.setItemDisabled('unfinalize');
        var status = validate_form(view_adjustment.view_adjustment_form);
        if (status == false) { 
            view_adjustment.view_adjustment_layout.cells('c').progressOff();
            return; 
        }
        view_adjustment.view_adjustment_layout.cells('a').collapse();
        view_adjustment.view_adjustment_layout.cells('b').collapse();

        var counterparty_obj = view_adjustment.view_adjustment_form.getCombo('counterparty_id');
        var counterparty_id = counterparty_obj.getChecked();
        counterparty_id = counterparty_id.toString();

        var contract_obj = view_adjustment.view_adjustment_form.getCombo('contract_id');
        var contract_id = contract_obj.getChecked('contract_id');
        contract_id = contract_id.toString();

        var created_by_obj = view_adjustment.view_adjustment_form.getCombo('created_by');
        var created_by = created_by_obj.getChecked('created_by');
        created_by = created_by.toString();
        
        var production_month_from = view_adjustment.view_adjustment_form.getItemValue('production_month_from', true);
        var production_month_to = view_adjustment.view_adjustment_form.getItemValue('production_month_to', true);
        var created_time = view_adjustment.view_adjustment_form.getItemValue('created_time', true);

        var show_adjusted_value = view_adjustment.view_adjustment_form.isItemChecked('show_adjusted_value');
        if (show_adjusted_value == true) { 
            show_adjusted_value = 'y'; 
            check_show_adjusted_value = true;
        } else {
            show_adjusted_value = 'n';
            check_show_adjusted_value = false;
        }

        // alert(counterparty_id, contract_id, created_by, production_month_from, production_month_to, created_time);

        if(flag == 'p') {
            var pivot_exec_spa = "EXEC spa_invoice_adjustment @flag='s', @counterparty_id='" + counterparty_id 
                                    + "',@contract_id='" + contract_id 
                                    + "',@prod_date_from='" + production_month_from 
                                    + "',@prod_date_to='" + production_month_to 
                                    + "',@created_time='" + created_time 
                                    + "',@created_by='" + created_by 
                                    + "',@show_adjusted_value='" + show_adjusted_value + "'";

            open_grid_pivot(view_adjustment.view_adjustment_grid, 'view_adjustment', 1, pivot_exec_spa, 'View Adjustment');
            return
        }

        var param = {
                "action": "spa_invoice_adjustment",
                "flag": "s",
                "counterparty_id": counterparty_id,
                "contract_id": contract_id,
                "prod_date_from": production_month_from,
                "prod_date_to": production_month_to,
                "created_time": created_time,
                "created_by": created_by,
                "show_adjusted_value" : show_adjusted_value
        }
              
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        view_adjustment.view_adjustment_grid.clearAll();
        view_adjustment.view_adjustment_grid.loadXML(param_url, function(){
            view_adjustment.view_adjustment_grid.filterByAll();
        });
    }

    function delete_data() {
        var select_id = view_adjustment.view_adjustment_grid.getSelectedRowId();
        
        if (select_id != null) {
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
                text: "Are you sure you want to delete?",
                callback: function(result) {
                    if (result) {
                        true_up_id = get_selected_ids(view_adjustment.view_adjustment_grid, 'true_up_id');
                        data = {
                            "action": "spa_invoice_adjustment", 
                            "true_up_id": true_up_id, 
                            "flag": "d"
                        }
                        result = adiha_post_data("return_array", data, "", "","view_adjustment.post_delete_callback");
                    }
                }
            });
        }
    }

    view_adjustment.post_delete_callback = function(result) { 
        if (result[0][0] == "Success") {     
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });
            view_adjustment.view_adjustment_form.uncheckItem('show_adjusted_value');
            view_adjustment_refresh();
        } else {
            dhtmlx.message({
                title:"Error",
                type:"alert-error",
                text:result[0][4]
            });
        }
    };

    function get_selected_ids(grid_obj, column_name) {
        var rid = grid_obj.getSelectedRowId();
        if (rid == '' || rid == null) {
            return false;
        }
        var rid_array = new Array();
        if (rid.indexOf(",") != -1) {
            rid_array = rid.split(',');
        } else {
            rid_array.push(rid);
        }
        
        var cid = grid_obj.getColIndexById(column_name);
        var selected_ids = new Array();
        $.each(rid_array, function( index, value ) {
            if(selected_ids.indexOf(grid_obj.cells(value,cid).getValue()) == -1){
                selected_ids.push(grid_obj.cells(value,cid).getValue());
            }
          
        });
        selected_ids = selected_ids.toString();
        return selected_ids;
    }

    view_adjustment.enable_menu_item = function() {
        // view_adjustment.left_menu.setItemEnabled('finalize');
        // view_adjustment.left_menu.setItemEnabled('unfinalize');
        if(!check_show_adjusted_value) {
            view_adjustment.left_menu.setItemEnabled('adjust');
        }
        if (has_rights_view_adjustment_delete) {
            view_adjustment.left_menu.setItemEnabled('delete');
        }
    }


    function create_invoice() {
        var has_rights_adjustment_iu = '1';

        true_up_id = get_selected_ids(view_adjustment.view_adjustment_grid, 'true_up_id');
        calc_id = get_selected_ids(view_adjustment.view_adjustment_grid, 'calc_id');
        
        var prod_date = new Date(yyyy, mm, dd);
        prod_date = formatDate(prod_date); 

        var adjust_invoice_window;
        if (!adjust_invoice_window) {
            adjust_invoice_window = new dhtmlXWindows();
        }

        var win = adjust_invoice_window.createWindow('w1', 0, 0, 300, 350);
        win.setText("Adjust Invoice");
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL('adjust.invoice.php?mode=y&true_up_id=' + true_up_id + '&calc_id=' + calc_id + '&prod_date=' + prod_date + '&right_id=' + has_rights_adjustment_iu,  false, true);

        win.attachEvent("onClose", function(win){
            view_adjustment_refresh();
            return true;
        });

    }

    // function finalize_unfinalize_invoice(flag) {
    //     true_up_id = get_selected_ids(view_adjustment.view_adjustment_grid, 'true_up_id');
    //     calc_id = get_selected_ids(view_adjustment.view_adjustment_grid, 'calc_id');
    //     prod_date = formatDate(get_selected_ids(view_adjustment.view_adjustment_grid, 'production_month'));

    //     var param = {
    //                 "flag": flag,
    //                 "action": "spa_invoice_adjustment",
    //                 "calc_id":calc_id,
    //                 "true_up_id":true_up_id,
    //                 "prod_date":prod_date
    //             };
                
    //     adiha_post_data('return_json', param, '', '', 'save_click_callback', '');
    // }

    // function save_click_callback(result) {
    //     var return_data = JSON.parse(result);
    //     var status = return_data[0].status;
        
    //     if (status == 'Error') {
    //        show_messagebox(return_data[0].message);
    //     } else {
    //         dhtmlx.message({
    //             text:return_data[0].message,
    //             expire:1000
    //         });
    //         view_adjustment_refresh();
    //     }
    // }

    //function to formatDate
    function formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;

        return [year, month, day].join('-');
    }

</script> 