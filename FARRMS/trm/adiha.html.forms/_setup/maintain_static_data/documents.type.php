<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <body>

    <?php
    $layout = new AdihaLayout();
    $form_obj = new AdihaForm();
    
    $layout_name = 'documents_type_layout';
    
    if (isset($_POST['value_id'])) {
        $value_id = get_sanitized_value($_POST['value_id']);
        echo $xml = '<Root><PSRecordset value_id="' . $value_id . '"></PSRecordset></Root>';
    } else {
        $value_id = "null";
        $xml = '<Root><PSRecordset value_id=""></PSRecordset></Root>';
    }

    $layout_json = '[
                {
                    id:             "a",
                    text:           "Documents Type",
                    width:          720,
                    height:         160,
                    header:         false,
                    collapse:       false,
                    fix_size:       [true,true]
                },

            ]';

    $name_space = 'documents_type';
    echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);
    
    $tab_name = 'documents_type_tabs';

    $json_tab = '[
            {
                id:      "a1",
                text:    "General",
                width:   null,
                index:   null,
                active:  true,
                enabled: true,
                close:   false
            },
            {
                id:      "a2",
                text:    "Documents",
                width:   null,
                index:   null,
                active:  false,
                enabled: true,
                close:   false
            },
        ]';


    echo $layout->attach_tab_cell($tab_name, 'a', $json_tab);
    echo $name_space . "." . $tab_name . '.setTabsMode("bottom");';
    $tab_obj = new AdihaTab();
    echo $tab_obj->init_by_attach($tab_name, $name_space);

    $xml_file = "EXEC spa_create_application_ui_json 'j', 10101010, 'StaticDataIU', '$xml' ";
    $return_value1 = readXMLURL($xml_file);
    $form_structure_general = $return_value1[0][2];

    $form_name = 'documents_type';
    echo $tab_obj->attach_form($form_name, 'a1', $form_structure_general, $name_space);
    
    $grid_name = 'documents_type_grd';
    echo $tab_obj->attach_grid_cell($grid_name, 'a2');
    
    $grid_quality_obj = new GridTable('documents_type');
    echo $grid_quality_obj->init_grid_table($grid_name, $name_space);
    echo $grid_quality_obj->set_widths('100,130,130,130');
    echo $grid_quality_obj->set_search_filter(true);
    echo $grid_quality_obj->return_init();
    $grid_spa = "EXEC ('SELECT document_id, document_type_id, document_name, document_description FROM documents_type WHERE document_type_id = ''" . $value_id . "''')";
    echo $grid_quality_obj->load_grid_data($sp_grid = $grid_spa);
    echo $grid_quality_obj->load_grid_functions();

    echo $layout->close_layout();
    ?>
    
    <style type="text/css">
        body,html{
            margin:-25px !important;
            padding:0px;
        }
        .dhxform_label_nav_link{
            margin-right: 10px;
        }
        .dhxtabbar_base_dhx_web div.dhx_cell_tabbar div.dhx_cell_cont_tabbar{
            padding:0px;
        }
    </style>
    
    <script type="text/javascript">
        $(function () {
            var value_id = '<?php echo $value_id; ?>';
            var delete_grid = '';
            var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    
            grid_toolbar = documents_type.documents_type_tabs.tabs("a2").attachMenu();
            grid_toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");
            
            var constraints_toolbar = [
                {id: "t1", text: "Edit", img: "edit.gif", items: [
                        {id: "add", text: "Add", img: "new.gif", imgdis: "new_dis.gif", title: "Add"},
                        {id: "delete", text: "Delete", img: "trash.gif", imgdis: "trash_dis.gif", title: "Delete", enabled: false}
                    ]},
                {id: "t2", text: "Export", img: "export.gif", items: [
                        {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                        {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                    ]},
                {id: "save", text: "Save", img: "save.gif", imgdis: "save_dis.gif", title: "Save"}
            ];
    
            grid_toolbar.loadStruct(constraints_toolbar);
            grid_toolbar.attachEvent('onClick', function (id) {
                switch (id) {
                    case "add" :
                        var newId = (new Date()).valueOf();
                        documents_type.documents_type_grd.addRow(newId, '');
                        documents_type.documents_type_grd.selectRowById(newId);
                        
                        documents_type.documents_type_grd.forEachRow(function(row){
                            documents_type.documents_type_grd.forEachCell(row,function(cellObj,ind){
                                documents_type.documents_type_grd.validateCell(row,ind);
                            });
                        });
                        break;
                    case "delete" :
                        var del_ids = documents_type.documents_type_grd.getSelectedRowId();
                        var values_id = documents_type.documents_type_grd.cells(del_ids, 0).getValue();
                        delete_grid += '<GridRow document_id ="' + values_id + '" ></GridRow>';
                        documents_type.documents_type_grd.deleteRow(del_ids);
                        grid_toolbar.setItemDisabled("delete");
                        break;
                    case "excel":
                        documents_type.documents_type_grd.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        documents_type.documents_type_grd.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save":
                        save_documents();
                        break;
                }
            });
            
            function save_documents() {
                documents_type.documents_type_grd.clearSelection();
                var ids = documents_type.documents_type_grd.getChangedRows(true);
                var grid_status = true;
                var grid_xml = '<GridGroup>';
                
                if (delete_grid != '') {
                    grid_xml += '<GridDelete grid_id="documents_type" grid_label="Documents">' + delete_grid + '</GridDelete>';
                }
                
                if(ids != "") {
                    documents_type.documents_type_grd.setSerializationLevel(false,false,true,true,true,true);
                    var grid_status = documents_type.validate_form_grid(documents_type.documents_type_grd,'Documents');
                    var grid_id = 'documents_type'; 
                    
                    grid_xml += "<Grid grid_id=\""+ grid_id + "\">";
                    var changed_ids = new Array();
                    changed_ids = ids.split(",");
                    
                    if(grid_status){
                        $.each(changed_ids, function(index, value) {
                            grid_xml += "<GridRow ";
                            for(var cellIndex = 0; cellIndex < documents_type.documents_type_grd.getColumnsNum(); cellIndex++){
                                var desc_index = documents_type.documents_type_grd.getColIndexById('document_description');
                                var name_index = documents_type.documents_type_grd.getColIndexById('document_name');
                                
                                if(cellIndex == desc_index)
                                    grid_xml += " " + documents_type.documents_type_grd.getColumnId(cellIndex) + '="' + documents_type.documents_type_grd.cells(value,name_index).getValue() + '"';
                                else
                                    grid_xml += " " + documents_type.documents_type_grd.getColumnId(cellIndex) + '="' + documents_type.documents_type_grd.cells(value,cellIndex).getValue() + '"';
                            }
                            grid_xml += " ></GridRow> ";
                        });
                        grid_xml += "</Grid>";
                    }
                }
                
                if (grid_status) {
                    var form_xml = '<Root function_id="10101010" object_id="' + value_id + '" >';
                    var xml = form_xml + grid_xml + '</GridGroup></Root>';
    
                    data = {"action": "spa_process_form_data", "xml": xml};
                    
                    if (delete_grid != '') {
                        var delete_grid_name = 'Documents';
                        del_msg = "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                        result = adiha_post_data("confirm-warning", data, "", "", "documents_type.call_back", "", del_msg);
                    } else {
                        result = adiha_post_data("alert", data, "", "", "documents_type.call_back");
                    }
                }
            }
            
            /**
             Close the tab and open again for new data insert.
             */
    
            documents_type.call_back = function (result) {
                //if (result[0].errorcode == "Success") {
                    documents_type.refresh_grid();
                    delete_grid = "";
                //}
            }
    
            documents_type.documents_type_grd.attachEvent("onRowSelect", function doOnRowSelected(id) {
                grid_toolbar.setItemEnabled("delete");
            });
        });
    </script>