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
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $mode = get_sanitized_value($_GET['mode'] ?? 'rw');
    $link_id = isset($_GET['link_id']) ? get_sanitized_value($_GET['link_id']) : 0;

    
    $filter_application_function_id = 20007900;

    $rights_deal_match = 20007900;
    $rights_deal_match_iu = 20007901;
    $rights_deal_match_delete = 20007902;
    
    list (
        $has_rights_deal_match,
        $has_rights_deal_match_iu,
        $has_rights_deal_match_delete
    ) = build_security_rights(
        $rights_deal_match,
        $rights_deal_match_iu,
        $rights_deal_match_delete
    );
        
    $namespace = 'buy_sell_link_ui';
    $layout_obj = new AdihaLayout();
    
    
    $enable = 'true';

    $layout_json = '[
                        {id: "a", width:380, text: "Filter Criteria",header: true, collapse: false, fix_size: [false,null]},
                        {id: "b", text: "Form",header: false, collapse: false, hidden:true, fix_size: [false,null]},                      
                    ]';
    
    $patterns = '2U';

    $layout_name = 'layout_link_ui';
    echo $layout_obj->init_layout($layout_name, '', $patterns, $layout_json, $namespace);

    $layout_json_inner = '[
                    {id: "a", text: "Filter", header: true, collapse: false, height: 100},
                    {id: "b", height:255, text: "Filter Criteria",header: true, collapse: false, fix_size: [false,null]},
                    {id: "c", text: "Matches",header: true, collapse: false, fix_size: [false,null]}
                ]';
    
    $patterns_inner = '3E';
    $grid_cell = 'c';

    $layout_name_inner = 'layout_link_ui_inner';
    $inner_layout_obj = new AdihaLayout();
    echo $layout_obj->attach_layout_cell($layout_name_inner, 'a', $patterns_inner, $layout_json_inner);
    echo $inner_layout_obj->init_by_attach($layout_name_inner, $namespace);
    

    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_deal_match . ", @template_name='BuySellMatch', @group_name='Filter'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $filter_name = 'filter_form';
    echo $inner_layout_obj->attach_form($filter_name, 'b');
    $filter_obj = new AdihaForm();
    echo $filter_obj->init_by_attach($filter_name, $namespace);
    echo $filter_obj->load_form($form_json);

    $filter_name = 'apply_filter';
    $filter_obj = new AdihaForm();
    echo $inner_layout_obj->attach_form($filter_name, 'a');        
    echo $filter_obj->init_by_attach($filter_name, $namespace);
    echo $filter_obj->load_form_filter($namespace, $filter_name, $layout_name_inner, 'b', $filter_application_function_id, 2);
    

    $menu_obj = new AdihaMenu();
    $menu_name = 'link_menu';
    $menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id: "edit", enabled:'. $enable . ', img:"edit.gif", imgdis: "edit_dis.gif", text: "Edit", items:[
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", enabled:false},
                        ]
                    },
                    {id: "export", enabled:'. $enable . ', img:"export.gif", imgdis: "export_dis.gif", text: "Export", items:[
                            {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                            {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true},
                        ]
                    },
                    {id: "report", text: "Report", img:"report.gif", imgdis:"report_dis.gif", enabled:true}
                ]';


	echo $menu_obj->attach_menu_layout_header($namespace, $layout_name_inner, 'c', $menu_name, $menu_json, $namespace . '.onclick_menu');


    //Attaching grid in cell 'c'
    $grid_obj = new AdihaGrid();
    $grid_name = 'link_grid';
    echo $inner_layout_obj->attach_grid_cell($grid_name, $grid_cell);
    echo $inner_layout_obj->attach_status_bar($grid_cell, true); 
    
    $xml_file = "EXEC spa_adiha_grid 's','BuySellMatch'";
    $resultset = readXMLURL2($xml_file);
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($resultset[0]['column_label_list']);
    echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset[0]['column_width']);
    echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);   
    //echo $grid_obj->enable_multi_select(false);
    echo $grid_obj->set_search_filter(true);
    echo $grid_obj->enable_paging(100, 'pagingArea_'. $grid_cell); 
    echo $grid_obj->return_init();
    echo $grid_obj->enable_filter_auto_hide();
	
    echo $grid_obj->attach_event('', 'onRowDblClicked', $namespace . '.load_template_detail');
    
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.set_privileges');
    //echo $grid_obj->load_grid_functions();
    
    $url = $app_adiha_loc . 'adiha.html.forms/_deal_capture/buy_sell/buysell.match.template.php?link_id=' . $link_id;
    echo $layout_obj->attach_url('b', $url);

    echo $layout_obj->close_layout(); 

    //Fetched Deal Match Report details
    $xml_file = "EXEC spa_view_report @flag='a', @report_name='Match Report'";
    $return_value = readXMLURL($xml_file);
    $deal_match_report_id = $return_value[0][0];
    $deal_match_paramset_id = $return_value[0][1];
    ?>
</body>
<script>
    var filter_application_function_id = '<?php echo $filter_application_function_id;?>';

    var has_rights_deal_match_iu = Boolean(<?php echo $has_rights_deal_match_iu; ?>);
    var has_rights_deal_match_delete = Boolean(<?php echo $has_rights_deal_match_delete; ?>);
    var link_id = <?php echo $link_id; ?>;

    $(function() {
        attach_browse_event('buy_sell_link_ui.filter_form',filter_application_function_id);

        buy_sell_link_ui.refresh_link_grid();
        
        buy_sell_link_ui.link_grid.attachEvent("onMouseOver", function(id,ind){
            var link_id_index = this.getColIndexById("link_id");
            var total_matched_volume_index = this.getColIndexById("total_matched_volume");
            var price_index = this.getColIndexById("price");
            var currency_index = this.getColIndexById("currency_id");
             this.cells(id,ind).cell.title = 'Match ID : ' + this.cells(id,link_id_index).getValue() + '\nMatched Volume : ' + this.cells(id,total_matched_volume_index).getValue() + '\nPrice : ' + this.cells(id,price_index).getValue() + ' ' + this.cells(id,currency_index).getValue();
        });
    })

   
    /**
     *
     */
    buy_sell_link_ui.load_template_detail = function(id) {
        show_hide_left_panel(true);
        var link_id = -1;
        if (id != '') link_id = id;
        var link_name = 'New'; 
        var selected_row = buy_sell_link_ui.link_grid.getSelectedRowId();
             
        if (id != 'add' && selected_row != null) {
            link_id = buy_sell_link_ui.link_grid.cells(selected_row, 0).getValue();
            link_name = buy_sell_link_ui.link_grid.cells(selected_row, 1).getValue();
            //allow_change = get_allow_change(buy_sell_link_ui.link_grid, 'allow_change');  
        }
         
        var frame_obj = buy_sell_link_ui.layout_link_ui.cells("b").getFrame();
        //console.log(frame_obj);
        frame_obj.contentWindow.buy_sell_link_ui_template.load_link_detail(link_id,link_name,'');
        
    } 

    /**
     *
     */
    buy_sell_link_ui.onclick_menu = function(id) {
        switch (id) {
            case 'refresh':
                buy_sell_link_ui.refresh_link_grid_clicked();
                break;

            case 'add':
                buy_sell_link_ui.load_template_detail('add');
                break;

            case 'delete':
                buy_sell_link_ui.delete_deal_match();
                break;
            case "excel":
                    //Excel Export codes here
                buy_sell_link_ui.link_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
                
            case "pdf":
                //PDF Export codes here
                buy_sell_link_ui.link_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "report":
                buy_sell_link_ui.generate_match_report();
                break;       
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    /**
    *
    */
    buy_sell_link_ui.delete_deal_match = function() {
        var confirm_msg = 'Please confirm  to delete the deal match.';
        dhtmlx.confirm({
                title:"Confirmation",
                ok: "Confirm",
                text: confirm_msg,
                callback:function(result){
                    if (result) {
                        var link_id = get_selected_ids(buy_sell_link_ui.link_grid, 'link_id');
                        data = {
                                    "action": "spa_buy_sell_match",
                                    "flag" : "d",
                                    "link_id": link_id
                                }
                        result = adiha_post_data("return_array", data, "", "","post_delete_deal_match");
                    }
                }
        });
    }

    /**
     *
     */
    function post_delete_deal_match(result) {
        if (result[0][0] == 'Success') {
            var link_id = get_selected_ids(buy_sell_link_ui.link_grid, 'link_id');
            buy_sell_link_ui.link_grid.deleteSelectedRows();
            dhtmlx.message({
                        text: result[0][4],
                        expire: 1000
                    });
             //refresh deal match tab gris
            
            var frame_obj = buy_sell_link_ui.layout_link_ui.cells("b").getFrame();   
            //buy_sell_link_ui_template.link_ui_tabbar.cells(active_tab_id).close();

            

            frame_obj.contentWindow.buy_sell_link_ui_template.refresh_match_grids(-1);
            frame_obj.contentWindow.buy_sell_link_ui_template.close_tabs('tab_' + link_id);
           buy_sell_link_ui.link_menu.setItemDisabled('delete');
        } else {
            dhtmlx.message({
                type: "alert-error",
                title: "Error",
                text: result[0][4]
            });
        }
    }


    /**
    *
    */
    buy_sell_link_ui.refresh_link_grid_clicked = function() {
        buy_sell_link_ui.layout_link_ui_inner.progressOn();
        var status = validate_form(buy_sell_link_ui.filter_form);

        var eff_date_from = buy_sell_link_ui.filter_form.getItemValue('effective_date_from', true);
        
        var eff_date_to = buy_sell_link_ui.filter_form.getItemValue('effective_date_to', true);
        var link_id_from = buy_sell_link_ui.filter_form.getItemValue('link_id_from');
        var link_id_to = buy_sell_link_ui.filter_form.getItemValue('link_id_to');
        if (eff_date_from > eff_date_to) {
            buy_sell_link_ui.filter_form.setValidateCss('effective_date_from', false);
            buy_sell_link_ui.filter_form.setValidateCss('effective_date_to', false);
            show_messagebox('<b>Effective Date To</b> should be greater than <b>Effective Date From</b> on <b>Filter Criteria</b>.');
            buy_sell_link_ui.layout_link_ui_inner.progressOff();
            return false;
        } else if(parseInt(link_id_to) < parseInt(link_id_from)) {
            show_messagebox("<b>Match ID To</b> should be greater than <b>Match ID From</b> on Filter Criteria.");
            buy_sell_link_ui.layout_link_ui_inner.progressOff();            
            return false;
        }
        
        if (!status) {
            buy_sell_link_ui.layout_link_ui_inner.progressOff();
            return false;
        }

        buy_sell_link_ui.refresh_link_grid();

    }

    buy_sell_link_ui.refresh_link_grid = function() {
        var filter_xml = "<Root><FormXML ";

        var filter_data = buy_sell_link_ui.filter_form.getFormData();

        for (var a in filter_data) {
            field_label = a;
            if (field_label == 'apply_filters') {
                continue;
             }
                field_value = filter_data[a];
                if (buy_sell_link_ui.filter_form.getItemType(a) == 'calendar') {
                    field_value = buy_sell_link_ui.filter_form.getItemValue(a, true);
                }
                filter_xml += " " + field_label + "=\"" + field_value + "\"";
            
        }
        filter_xml += "></FormXML></Root>";

        var sql_param = {
                "sql":"EXEC spa_buy_sell_match @flag = 's', @xmlValue = ' " + filter_xml + "'",
                "grid_type":"g"
            };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        buy_sell_link_ui.link_grid.clearAndLoad(sql_url, function() {
            buy_sell_link_ui.layout_link_ui_inner.progressOff();
			buy_sell_link_ui.layout_link_ui_inner.cells('b').collapse();
			buy_sell_link_ui.layout_link_ui_inner.cells('a').collapse();
        });
    }

    buy_sell_link_ui.set_privileges = function(id) {

        if (has_rights_deal_match_delete && id != null)    
            buy_sell_link_ui.link_menu.setItemEnabled('delete');
        else
            buy_sell_link_ui.link_menu.setItemDisabled('delete');
        
    }

    /**
     *
     */
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
          selected_ids.push(grid_obj.cells(value,cid).getValue());
        });
        selected_ids = selected_ids.toString();
        return selected_ids;
    }

    function show_hide_left_panel(state) {
        if (state)
            buy_sell_link_ui.layout_link_ui.cells("a").collapse();

    }

    /**
    * Generates the Margin Report
    */
    buy_sell_link_ui.generate_match_report = function() {
        var link_id_from = buy_sell_link_ui.filter_form.getItemValue('link_id_from');
        var link_id_to = buy_sell_link_ui.filter_form.getItemValue('link_id_to');
        var effective_date_from = buy_sell_link_ui.filter_form.getItemValue('effective_date_from', true);
        var effective_date_to = buy_sell_link_ui.filter_form.getItemValue('effective_date_to', true);

        var url = '../../_reporting/view_report/view.report.php';

        var params = {flag:2, 
                     active_object_id:'<?php echo $deal_match_report_id;?>',
                     report_type:1,
                     report_id:'<?php echo $deal_match_report_id;?>',
                     report_param_id:'<?php echo $deal_match_paramset_id;?>',
                     report_name:'Match Report',
                     link_id_from:link_id_from, 
                     link_id_to:link_id_to, 
                     effective_date_from:effective_date_from, 
                     effective_date_to:effective_date_to
                 };

        report_win_obj = new dhtmlXWindows();
        w3 = report_win_obj.createWindow("w3", 0, 0, 1200, 500);
        w3.centerOnScreen();
        w3.maximize();
        w3.setText('View Report');
        w3.attachURL(url, false, params);
        w3.attachEvent("onClose", function(win) {
            return true;
        });
    }
</script>
</html>