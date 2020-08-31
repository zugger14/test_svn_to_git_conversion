<?php
/**
* Update wellhead volume screen
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
<?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    
    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    
    $term_start = date('Y-m-d', strtotime("+1 days"));
    $term_end = date('Y-m-d', strtotime("+7 days"));
    
    if($call_from == 'shutin') {
        $meter_ids = get_sanitized_value($_GET['meter_ids'] ?? '');
        $term_start = get_sanitized_value($_GET['term_start'] ?? '');
        $term_end = get_sanitized_value($_GET['term_end'] ?? '');
        
    }
    
    $form_namespace = 'wellhead_volume';
    //Layout
    $layout_json = '[
                        {id: "a", height:90, text: "Apply Filters",header: true, collapse: true, fix_size: [false,null]},
                        {id: "b", height:180,  text: "Criteria",header: true, collapse: false, fix_size: [false,null]},
                        {id: "c", text: "Wellhead Volume", header: false}
                    ]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('wellhead_volume_layout', '', '3E', $layout_json, $form_namespace);
    //Filter Form
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10164000', @template_name='UpdateWellheadVolume', @group_name='General'";
    $filter_arr = readXMLURL2($filter_sql);
    
    $tab_id = $filter_arr[0]['tab_id'];
    $form_json = $filter_arr[0]['form_json'];
    
    $filter_form_name = 'filter_form';
    $filter_form_obj = new AdihaForm();
    echo $layout_obj->attach_form($filter_form_name, 'b');
    $filter_form_obj->init_by_attach($filter_form_name, $form_namespace);
    echo $filter_form_obj->load_form($form_json);
    $form_name = $form_namespace.'.'.$filter_form_name;
    echo $filter_form_obj->set_input_value($form_name, 'term_start', $term_start);
    echo $filter_form_obj->set_input_value($form_name, 'term_end', $term_end);
    
    
    if($call_from == 'shutin') {
        echo $filter_form_obj->set_input_value($form_name, 'channel', 2);
        echo $filter_form_obj->set_input_value($form_name, 'meter_id', $meter_ids);
        echo $filter_form_obj->set_input_value($form_name, 'label_meter_id', $meter_ids);
    }
    
    //Grid Menu
    $menu_json = '[
                    {id:"refresh", text:"Refresh", img:"refresh.gif"},
                    {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ], disabled:true},
                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", disabled:true},
                    {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"}
                ]';
    echo $layout_obj->attach_menu_layout_cell("wellhead_grid_menu", "c", $menu_json, $form_namespace.'.menu_click');
    echo $layout_obj->close_layout();
    
    $rights_wellhead_iu = 10164010;
    
    list (
        $has_right_wellhead_iu
    ) = build_security_rights (
        $rights_wellhead_iu
    );
?>
<body>
</body>
<script>
    var has_right_wellhead_iu = Boolean('<?php echo $has_right_wellhead_iu; ?>');
    var filter_function_id = '10164000';
    $(function() {
        filter_obj = wellhead_volume.wellhead_volume_layout.cells('a').attachForm();
        var layout_cell_obj = wellhead_volume.wellhead_volume_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, filter_function_id, 2);
        filter_form_obj = 'wellhead_volume.filter_form';
        attach_browse_event(filter_form_obj, filter_function_id, '', 'n');
             
    });

    /**
     * [menu_click Menu click function for invoice grid]
     * @param  {[type]} id     [Menu id]
     */
    wellhead_volume.menu_click = function(id) {
        switch(id) {
            case "refresh":
                refresh_wellhead_volume_grid("y");
                break;
            case "excel":
                wellhead_volume.wellhead_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                wellhead_volume.wellhead_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "save":
                save_wellhead_volume_grid();
                break;
            case 'pivot':
                var grid_obj = wellhead_volume.wellhead_grid;
                open_grid_pivot(grid_obj, 'wellhead_grid', 1, pivot_exec_spa, 'Wellhead Volume');
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
    
    function refresh_wellhead_volume_grid(reload_btn) {
        reload_btns = (reload_btn == 'y') ? 'y' : 'n';
        if (reload_btns == 'y') {
             term_start =  wellhead_volume.filter_form.getItemValue('term_start', true);
             term_end =  wellhead_volume.filter_form.getItemValue('term_end', true);
        } else {
             term_start = attached_obj.getUserData("","term_start_date");
             term_end = attached_obj.getUserData("","term_end_date");
        }
        
        data = {"action": "spa_update_wellhead_volume",
                    "flag": "h",
                    "term_start": term_start,
                    "term_end": term_end
                };

        adiha_post_data('return_array', data, 's', 'e', 'wellhead_volume.create_grid', '', '');
    }
    
    wellhead_volume.create_grid = function(result) {
        if (reload_btns == 'y') {
            if (validate_filter() == false) {
                return;
            }
        }
        
        wellhead_volume.wellhead_volume_layout.cells('a').collapse();
        wellhead_volume.wellhead_volume_layout.cells('b').collapse();
        wellhead_volume.wellhead_volume_layout.cells("c").progressOn();
        var meter_ids = wellhead_volume.filter_form.getItemValue('meter_id');
        meter_ids = meter_ids.toString();
        var channel =  wellhead_volume.filter_form.getItemValue('channel');
        
        //Create Grid
        var header_name = result[0][0];
        var header_id = result[0][1];
        var column_type = result[0][2];
        var column_widths = result[0][3];
        var column_visibility = result[0][4];
        
        wellhead_volume.wellhead_grid = wellhead_volume.wellhead_volume_layout.cells('c').attachGrid();
        wellhead_volume.wellhead_volume_layout.cells('c').attachStatusBar({
                                        height: 30,
                                        text: '<div id="pagingArea_c"></div>'
                                    });
        wellhead_volume.wellhead_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
        wellhead_volume.wellhead_grid.setPagingWTMode(true,true,true,true);
        wellhead_volume.wellhead_grid.enablePaging(true, 100, 0, 'pagingArea_c'); 
        wellhead_volume.wellhead_grid.setPagingSkin('toolbar'); 
        wellhead_volume.wellhead_grid.setHeader(get_locale_value(header_name,true));
        wellhead_volume.wellhead_grid.setColumnIds(header_id);
        wellhead_volume.wellhead_grid.setColTypes(column_type);
        wellhead_volume.wellhead_grid.setColumnsVisibility(column_visibility);
        wellhead_volume.wellhead_grid.setInitWidths(column_widths);
        wellhead_volume.wellhead_grid.init();
        
        var param = {
                    "flag": "g",
                    "action": "spa_update_wellhead_volume",
                    "grid_type": "g",
                    "meter_ids": meter_ids,
                    "channel": channel,
                    "term_start": term_start,
                    "term_end": term_end
                };

        pivot_exec_spa = "EXEC spa_update_wellhead_volume @flag='g', @meter_ids='" +  meter_ids 
                + "', @channel='" +  channel
                + "', @term_start='" +  term_start
                + "', @term_end='" +  term_end + "'";

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        wellhead_volume.wellhead_grid.clearAll();
        wellhead_volume.wellhead_grid.load(param_url);
        wellhead_volume.wellhead_grid.setUserData('', 'term_start_date', term_start);
        wellhead_volume.wellhead_grid.setUserData('', 'term_end_date', term_end);
        wellhead_volume.wellhead_grid.setUserData('', 'channel', channel);
        wellhead_volume.wellhead_volume_layout.cells("c").progressOff();
        
        if (has_right_wellhead_iu) {
            wellhead_volume.wellhead_grid_menu.setItemEnabled("save");
        }
        
        wellhead_volume.wellhead_grid_menu.setItemEnabled("export");
        wellhead_volume.wellhead_grid_menu.setItemEnabled('pivot');
    }
    
    function save_wellhead_volume_grid() {
        attached_obj = wellhead_volume.wellhead_volume_layout.cells("c").getAttachedObject();
        var grid_xml = "";
        if (attached_obj instanceof dhtmlXGridObject) {
            attached_obj.clearSelection();
            var ids = attached_obj.getChangedRows(true);
            term_start = attached_obj.getUserData("","term_start_date");
            term_end = attached_obj.getUserData("","term_end_date");
            channel = attached_obj.getUserData("","channel");
            
            if(ids != "") {
                attached_obj.setSerializationLevel(false,false,true,true,true,true);
                grid_xml += "<Grid term_start=\"" + term_start + "\" term_end=\"" + term_end + "\" channel=\"" + channel + "\">";
                
                var changed_ids = new Array();
                changed_ids = ids.split(",");
                $.each(changed_ids, function(index, value) {
                    grid_xml += "<GridRow ";
                    for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){
                        if (cellIndex == 0 || cellIndex == 1 || cellIndex == 2) {
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
        //alert(grid_xml);
        data = {"action": "spa_update_wellhead_volume", "flag": "u", "xml": grid_xml};
        adiha_post_data("alert", data, "", "", "refresh_wellhead_volume_grid");
    }
    
    function validate_filter() {
        var meter_ids = wellhead_volume.filter_form.getItemValue('meter_id');
        meter_ids = meter_ids.toString();
        var channel =  wellhead_volume.filter_form.getItemValue('channel');
        
        var term_start =  wellhead_volume.filter_form.getItemValue('term_start', true);
        var term_end =  wellhead_volume.filter_form.getItemValue('term_end', true);    
        
        var status = validate_form(wellhead_volume.filter_form);
        if (status) {
            if (meter_ids == '') {
                show_messagebox('Meter/Wellhead should not be blank.');
                return false;
            }
                    
            if (term_start > term_end) {
                show_messagebox('Term End should not be less than Term Start.');
                return false;
            }
            term_end_date = new Date(term_end);
            term_start_date = new Date(term_start);
            var time_difference = Math.abs(term_end_date.getTime() - term_start_date.getTime());
            var days_difference = Math.ceil(time_difference / (1000 * 3600 * 24));
            
            if (days_difference > 30) {
                show_messagebox('The gap between Term Start and Term End should not be more than 31 days.');
                return false;
            }
        } else {
            return false;    
        }
    }
    
    
    /****************************************************END of Form Filer logic*******************************************************************/

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