<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $deal_ref_ids = (isset($_POST["deal_ref_ids"]) && $_POST["deal_ref_ids"] != '') ? get_sanitized_value($_POST["deal_ref_ids"]) : 'NULL';
    $term_start = (isset($_POST["term_start"]) && $_POST["term_start"] != '') ? get_sanitized_value($_POST["term_start"]) : 'NULL';
    $term_end = date('Y-m-d', strtotime($term_start. ' + 7 days'));

    $form_namespace = 'demand_volume';
    //Layout
    $layout_json = '[
                        {id: "a", text: "Filters", header: true, height:100, fix_size:[true,true]},
                        {id: "b", text: "Demand Volume", header: false}
                    ]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('demand_volume_layout', '', '2E', $layout_json, $form_namespace);
    //Filter Form
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10131018', @template_name='UpdateDemandVolume', @group_name='General'";
    $filter_arr = readXMLURL2($filter_sql);
    $tab_id = $filter_arr[0]['tab_id'];
    $form_json = $filter_arr[0]['form_json'];
    
    $filter_form_name = 'filter_form';
    $filter_form_obj = new AdihaForm();
    echo $layout_obj->attach_form($filter_form_name, 'a');
    $filter_form_obj->init_by_attach($filter_form_name, $form_namespace);
    echo $filter_form_obj->load_form($form_json);
    $form_name = $form_namespace.'.'.$filter_form_name;
    echo $filter_form_obj->set_input_value($form_name, 'term_start', $term_start);
    echo $filter_form_obj->set_input_value($form_name, 'term_end', $term_end);
    
    //Grid Menu
    $menu_json = '[
                    {id:"refresh", text:"Refresh", img:"refresh.gif"},
                    {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ], disabled:true},
                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", disabled:true}
                ]';
    echo $layout_obj->attach_menu_layout_cell("demand_grid_menu", "b", $menu_json, $form_namespace.'.menu_click');
    echo $layout_obj->close_layout();
    
    $rights_demand_iu = 10131018;
    
    list (
        $has_right_demand_iu
    ) = build_security_rights (
        $rights_demand_iu
    );
?>
<body class = "bfix2">
</body>
<script>
    var has_right_demand_iu = Boolean('<?php echo $has_right_demand_iu; ?>');
    
    $(function() {
        refresh_demand_volume_grid("y");
    });
    
    /**
     * [menu_click Menu click function for invoice grid]
     * @param  {[type]} id     [Menu id]
     */
    demand_volume.menu_click = function(id) {
        switch(id) {
            case "refresh":
                refresh_demand_volume_grid("y");
                break;
            case "excel":
                demand_volume.demand_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                demand_volume.demand_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "save":
                save_demand_volume_grid();
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
    
    function refresh_demand_volume_grid(reload_btn) {
        reload_btns = (reload_btn == 'y') ? 'y' : 'n';
        if (reload_btns == 'y') {
             term_start =  demand_volume.filter_form.getItemValue('term_start', true);
             term_end =  demand_volume.filter_form.getItemValue('term_end', true);
             volume_type = demand_volume.filter_form.getItemValue('volume_type');
        } else {
             term_start = attached_obj.getUserData("","term_start_date");
             term_end = attached_obj.getUserData("","term_end_date");
             volume_type = demand_volume.filter_form.getItemValue('volume_type');
        }
        
        data = {"action": "spa_update_demand_volume",
                    "flag": "h",
                    "term_start": term_start,
                    "term_end": term_end,
                    "volume_type": volume_type
                };

        adiha_post_data('return_array', data, 's', 'e', 'demand_volume.create_grid', '', '');
    }
    
    demand_volume.create_grid = function(result) {
        if (reload_btns == 'y') {
            if (validate_filter() == false) {
                return;
            }
        }
        
        demand_volume.demand_volume_layout.cells("b").progressOn();
        var deal_ref_ids = '<?php echo $deal_ref_ids; ?>';
        
        //Create Grid
        var header_name = result[0][0];
        var header_id = result[0][1];
        var column_type = result[0][2];
        var column_widths = result[0][3];
        var column_visibility = result[0][4];
        var column_sorting = result[0][5];
       
        
        demand_volume.demand_grid = demand_volume.demand_volume_layout.cells('b').attachGrid();
        demand_volume.demand_volume_layout.cells('b').attachStatusBar({
                                        height: 30,
                                        text: '<div id="pagingArea_b"></div>'
                                    });
        demand_volume.demand_grid.setImagePath(js_image_path + "dhxgrid_web/");
        demand_volume.demand_grid.setPagingWTMode(true,true,true,true);
        demand_volume.demand_grid.enablePaging(true, 100, 0, 'pagingArea_b'); 
        demand_volume.demand_grid.setPagingSkin('toolbar'); 
        demand_volume.demand_grid.setHeader(header_name);
        demand_volume.demand_grid.setColumnIds(header_id);
        demand_volume.demand_grid.setColTypes(column_type);
        demand_volume.demand_grid.setColumnsVisibility(column_visibility);
        demand_volume.demand_grid.setColSorting(column_sorting);
        demand_volume.demand_grid.setInitWidths(column_widths);
        demand_volume.demand_grid.init();
        
        var param = {
                        "flag": "g",
                        "action": "spa_update_demand_volume",
                        "grid_type": "g",
                        "deal_ref_ids": deal_ref_ids,
                        "term_start": term_start,
                        "term_end": term_end,
                        "volume_type": volume_type
                    };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        demand_volume.demand_grid.clearAll();
        demand_volume.demand_grid.loadXML(param_url);
        demand_volume.demand_grid.setUserData('', 'term_start_date', term_start);
        demand_volume.demand_grid.setUserData('', 'term_end_date', term_end);
        demand_volume.demand_volume_layout.cells("b").progressOff();
        
        if (has_right_demand_iu) {
            demand_volume.demand_grid_menu.setItemEnabled("save");
        }
        demand_volume.demand_grid_menu.setItemEnabled("export");
    }
    
    function save_demand_volume_grid() {
        attached_obj = demand_volume.demand_volume_layout.cells("b").getAttachedObject();
        var grid_xml = "";
        if (attached_obj instanceof dhtmlXGridObject) {
            attached_obj.clearSelection();
            var ids = attached_obj.getChangedRows(true);
            term_start = attached_obj.getUserData("","term_start_date");
            term_end = attached_obj.getUserData("","term_end_date");
            
            if(ids != "") {
                attached_obj.setSerializationLevel(false,false,true,true,true,true);
                grid_xml += "<Grid term_start=\"" + term_start + "\" term_end=\"" + term_end + "\">";
                
                var changed_ids = new Array();
                changed_ids = ids.split(",");
                $.each(changed_ids, function(index, value) {
                    grid_xml += "<GridRow ";
                    for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){
                        if (cellIndex == 0 || cellIndex == 1 || cellIndex == 2 || cellIndex == 3 || cellIndex == 4 || cellIndex == 5 || cellIndex == 6) {
                            grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value,cellIndex).getValue() + '"';
                        } else {
                            var cell_value = attached_obj.cells(value,cellIndex).getValue();
                            if (cell_value == '') {
                                cell_value = '-1';
                            }
                            grid_xml += " _" + attached_obj.getColumnId(cellIndex) + '="' + cell_value + '"';
                        }
                    }
                    grid_xml += " ></GridRow> ";
                });
                grid_xml += "</Grid>";
            }
        }
        
        data = {"action": "spa_update_demand_volume", "flag": "u", "xml": grid_xml};
        adiha_post_data("alert", data, "", "", "refresh_demand_volume_grid");
    }
    
    function validate_filter() {
        var term_start =  demand_volume.filter_form.getItemValue('term_start', true);
        var term_end =  demand_volume.filter_form.getItemValue('term_end', true);
        
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

</script>
<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>