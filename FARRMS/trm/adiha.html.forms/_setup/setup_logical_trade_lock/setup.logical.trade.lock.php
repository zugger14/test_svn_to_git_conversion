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
            $name_space = 'logical_trade';
            $rights_deal_lock = 10101900;
            $rights_deal_lock_iu = 10101910;
            $rights_deal_lock_delete = 10101911;
            
            list (
                $has_rights_deal_lock,
                $has_rights_deal_lock_iu, 
                $has_rights_deal_lock_delete
            ) = build_security_rights (
                $rights_deal_lock,
                $rights_deal_lock_iu, 
                $rights_deal_lock_delete
            );

            $layout_json = '[
                                    {
                                        id:             "a",
                                        text:           "Setup Logical Trade Lock",
                                        header:         false,
                                        collapse:       false,
                                        fix_size:       [true,null]
                                    }
                                ]';
            
            $toolbar_json = '[
                             {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:"' . $has_rights_deal_lock_iu . '"}
                             ]';
            
            $menu_json = '[
                          {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                              {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"' . $has_rights_deal_lock_iu . '"},
                              {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",disabled:"' . $has_rights_deal_lock_delete . '"}
                          ]},
                          {id:"t2", text:"Export", img:"export.gif",imgdis:"export_dis.gif",items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                          ]}
                      ]';
            // Creating Layout
            $layout_obj = new AdihaLayout();
            echo $layout_obj->init_layout('logical_trade_layout', '', '1C', $layout_json, $name_space);
            
            //Attaching toolbar
            echo $layout_obj->attach_toolbar('logical_trade_layout_toolbar');
            $toolbar_obj = new AdihaToolbar();
            echo $toolbar_obj->init_by_attach('logical_trade_layout_toolbar', $name_space);
            echo $toolbar_obj->load_toolbar($toolbar_json);
            echo $toolbar_obj->attach_event('', 'onClick', $name_space . '.toolbar_click');

            //Attaching Menu  
            echo $layout_obj->attach_menu_cell('logical_menu', 'a');     
            $menu_obj = new AdihaMenu(); 
            echo $menu_obj->init_by_attach('logical_menu', $name_space);
            echo $menu_obj->load_menu($menu_json);
            echo $menu_obj->attach_event('', 'onClick', $name_space . '.menu_click');
            
            //Attching Grid table
            echo $layout_obj->attach_grid_cell('setup_logical_trade_lock_grid', 'a');
            echo $layout_obj->attach_status_bar('a', true);// Attached status 
            $grid_obj = new GridTable('setup_logical_trade_lock_grid');
            echo $grid_obj->init_grid_table('setup_logical_trade_lock_grid', $name_space, 'n');
            echo $grid_obj->set_column_auto_size();
            echo $grid_obj->set_search_filter(true, "");
            echo $grid_obj->enable_multi_select(true);
            echo $grid_obj->enable_paging(50, 'pagingArea_a', 'true'); // Enable paging   
            echo $grid_obj->return_init();
            echo $grid_obj->attach_event('', 'onRowSelect', 'grid_row_click');

            echo $layout_obj->close_layout();
        ?>
<!--  <div id="pagingArea_a"></div>  -->
<script type="text/javascript">
    var has_rights_deal_lock_iu = Boolean('<?php echo $has_rights_deal_lock_iu; ?>'); 
    var has_rights_deal_lock_delete = Boolean('<?php echo $has_rights_deal_lock_delete ?>');
    
    $(function() {

        logical_trade.load_setup_logical_trade_lock_grid_grid();
        
    }); 

    logical_trade.menu_click = function(id){
        switch(id) {
            case "add":
                var newId = (new Date()).valueOf();
                logical_trade.setup_logical_trade_lock_grid.addRow(newId,"");
                logical_trade.setup_logical_trade_lock_grid.selectRowById(newId);
                logical_trade.setup_logical_trade_lock_grid.forEachRow(function(row) {
                    logical_trade.setup_logical_trade_lock_grid.forEachCell(row,function(cellObj,ind){
                        logical_trade.setup_logical_trade_lock_grid.validateCell(row,ind)
                    });
                });
                break;

            case 'delete' :
                delete_logical_trade();
                break;

            case 'excel':
                logical_trade.setup_logical_trade_lock_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;

            case 'pdf':
                logical_trade.setup_logical_trade_lock_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
                    
            default:
                break;
        }
    }
    

    logical_trade.toolbar_click = function(id) {
        switch(id) {
            case "save":
                save_logical_trade();
            break;

            default:
            break;
        }

    }
    
    function grid_row_click(id) {

        if (has_rights_deal_lock_delete) {
            logical_trade.logical_menu.setItemEnabled('delete');
        }

    }
    
    function save_logical_trade() {
        var ps_xml = '<Root>';   
        var row_ids = logical_trade.setup_logical_trade_lock_grid.getChangedRows(true);
        var grid_label = "Setup Logical Trade Lock"; 

        if (row_ids != "") {
            logical_trade.setup_logical_trade_lock_grid.setSerializationLevel(false,false,true,true,true,true);
            attached_obj = logical_trade.setup_logical_trade_lock_grid;
            var grid_status = logical_trade.validate_form_grid(attached_obj,grid_label);

            if (grid_status) {
                logical_trade.setup_logical_trade_lock_grid.forEachRow(function(id) {
                ps_xml += "<PSRecordset "; 
                    for (var cellIndex = 0; cellIndex < logical_trade.setup_logical_trade_lock_grid.getColumnsNum(); cellIndex++){
                        ps_xml += " " + logical_trade.setup_logical_trade_lock_grid.getColumnId(cellIndex) + '="' + logical_trade.setup_logical_trade_lock_grid.cells(id,cellIndex).getValue() + '"';
                    }
                ps_xml += " ></PSRecordset> "; 
                //console.log(ps_xml);
                });
            }

            ps_xml += "</Root>";  

            if (grid_status) {
                data = {
                "action": "spa_setup_logical_trade_lock",
                "flag": "i",
                "xml": ps_xml
            };

            adiha_post_data("return_array", data, "", "", "save_logical_trade_callback","");
            }  
        } 

    }

    function save_logical_trade_callback(result) {
       
         if (result[0][0] == 'Success') {
                dhtmlx.message({
                    text:'Changes have been saved successfully.',
                    expire:1000
                });
                logical_trade.load_setup_logical_trade_lock_grid_grid();
            } else if(result[0][0] == 'Error') {
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text:'Duplicate data in (<b>Role Name and Deal Type</b>).',
                    expire:1000
                });
            }
    }
   
    logical_trade.validate_form_grid = function(attached_obj,grid_label) {;
        var status = true;
        for (var i = 0;i < attached_obj.getRowsNum();i++){
            var row_id = attached_obj.getRowId(i);
            for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
                var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                var hour_val = attached_obj.cells(row_id,3).getValue();
                var min_val = attached_obj.cells(row_id,4).getValue();
                if(validation_message != "" && validation_message != undefined){
                    var column_text = attached_obj.getColLabel(j);
                    error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                    dhtmlx.alert({title:"Error",type:"alert-error",text: error_message});
                    status = false; break;
                }
                if (hour_val>24 || hour_val <0){
                    var column_text = attached_obj.getColLabel(3);
                    error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                    dhtmlx.alert({title:"Error",type:"alert-error",text: error_message});
                    status = false; break;
                }
                if (min_val>60 || min_val <0){
                    var column_text = attached_obj.getColLabel(4);
                    error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                    dhtmlx.alert({title:"Error",type:"alert-error",text: error_message});
                    status = false; break;
                }
            }
            if(validation_message != "" && validation_message != undefined){ break;};
        } 
        return status;
    }

    function delete_logical_trade() {
        var selected_id = logical_trade.setup_logical_trade_lock_grid.getSelectedId();
        var count = selected_id.indexOf(",") > -1 ? selected_id.split(",").length : 1;
        selected_id = selected_id.indexOf(",") > -1 ? selected_id.split(",") : [selected_id];
        var id = '';

        if(selected_id == null) {
            show_messagebox('Please select the data you want to delete.');
            return;
        }

        for (var i = 0; i < selected_id.length; i++) {
            id += logical_trade.setup_logical_trade_lock_grid.cells(selected_id[i], 0).getValue();
            id += ',';
        }
        id = id.slice(0, -1);

        var data = {
            "action": "spa_setup_logical_trade_lock",
            "flag": "d",
            "del_ids": id
        };
        
        var confirm_msg = 'Are you sure you want to delete?';

            dhtmlx.message({
            type: "confirm",
            title: "Confirmation",
            ok: "Confirm",
            text: confirm_msg,
            callback: function(result) {
            if (result)
                adiha_post_data("alert", data, "", "", "logical_trade.load_setup_logical_trade_lock_grid_grid");
            }
        });
    }

    logical_trade.load_setup_logical_trade_lock_grid_grid = function() {
        var param = {
            "action": "spa_setup_logical_trade_lock",
            "flag": "g",
            "grid_type": "g"
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        logical_trade.setup_logical_trade_lock_grid.clearAll();
        logical_trade.setup_logical_trade_lock_grid.loadXML(param_url);
        logical_trade.logical_menu.setItemDisabled('delete');
    }
      
</script>

