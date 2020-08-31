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
            $name_space = 'setup_dst_data';
            $rights_setup_dst = 20004600;
            $rights_setup_dst_iu = 20004601;
            $rights_setup_dst_delete = 20004602;
            
            list (
                $has_rights_setup_dst,
                $has_rights_setup_dst_iu, 
                $has_rights_setup_dst_delete
            ) = build_security_rights (
                $rights_setup_dst,
                $rights_setup_dst_iu, 
                $rights_setup_dst_delete
            );

            $layout_json = '[
                                    {
                                        id:             "a",
                                        text:           "Setup DST",
                                        header:         false,
                                        collapse:       false,
                                        fix_size:       [true,null]
                                    }
                                ]';
            
            $toolbar_json = '[
                             {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:"' . $has_rights_setup_dst_iu . '"}
                             ]';
            
            $menu_json = '[
                          {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                              {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"' . $has_rights_setup_dst_iu . '"},
                              {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",disabled:"' . $has_rights_setup_dst_delete . '"}
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
            echo $layout_obj->attach_toolbar('setup_dst_layout_toolbar');
            $toolbar_obj = new AdihaToolbar();
            echo $toolbar_obj->init_by_attach('setup_dst_layout_toolbar', $name_space);
            echo $toolbar_obj->load_toolbar($toolbar_json);
            echo $toolbar_obj->attach_event('', 'onClick', $name_space . '.toolbar_click');

            //Attaching Menu  
            echo $layout_obj->attach_menu_cell('setup_dst_menu', 'a');     
            $menu_obj = new AdihaMenu(); 
            echo $menu_obj->init_by_attach('setup_dst_menu', $name_space);
            echo $menu_obj->load_menu($menu_json);
            echo $menu_obj->attach_event('', 'onClick', $name_space . '.menu_click');
            
            //Attching Grid table
            echo $layout_obj->attach_grid_cell('setup_dst', 'a');
            echo $layout_obj->attach_status_bar('a', true);// Attached status 
            $grid_obj = new GridTable('setup_dst');
            echo $grid_obj->init_grid_table('setup_dst', $name_space, 'n');
            echo $grid_obj->set_column_auto_size();
            echo $grid_obj->set_search_filter(true, "");
			echo $grid_obj->enable_multi_select();
            echo $grid_obj->enable_paging(50, 'pagingArea_a', 'true'); // Enable paging   
            echo $grid_obj->return_init();
            echo $grid_obj->attach_event('', 'onRowSelect', 'grid_row_click');

            echo $layout_obj->close_layout();
        ?>
<!--  <div id="pagingArea_a"></div>  -->
<script type="text/javascript">
    var has_rights_setup_dst_iu = Boolean('<?php echo $has_rights_setup_dst_iu; ?>'); 
    var has_rights_setup_dst_delete = Boolean('<?php echo $has_rights_setup_dst_delete ?>');

    
    $(function() {
        setup_dst_data.load_setup_dst_grid();        
    }); 

    setup_dst_data.toolbar_click = function(id) {
        switch(id) {
            case "save":
                save_dst_data();
            break;

            default:
            break;
        }
    }    
    function grid_row_click(id) {
    	
        if (has_rights_setup_dst_delete) {
            setup_dst_data.setup_dst_menu.setItemEnabled('delete');
        }

    }

    setup_dst_data.menu_click = function(id){
        switch(id) {
            case "add":
			var get_date = new Date();
			var set_year = get_date.getFullYear();
			    var newId = (new Date()).valueOf();
                setup_dst_data.setup_dst.addRow(newId,"");
                setup_dst_data.setup_dst.selectRowById(newId);
                setup_dst_data.setup_dst.forEachRow(function(row) {
                    setup_dst_data.setup_dst.forEachCell(row,function(cellObj,ind){
                        setup_dst_data.setup_dst.validateCell(row,ind)
						setup_dst_data.setup_dst.cells( setup_dst_data.setup_dst.getSelectedRowId(), setup_dst_data.setup_dst.getColIndexById('year')).setValue(set_year);
			    });
                });
                break;

            case 'delete' :
                delete_setup_dst();
                break;

            case 'excel':
                setup_dst_data.setup_dst.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;

            case 'pdf':
                setup_dst_data.setup_dst.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
                    
            default:
                break;
        }
    }
    
    function save_dst_data() {
        var ps_xml = '<Root>';   
        var row_ids = setup_dst_data.setup_dst.getChangedRows();
        var grid_label = "Setup DST";

        if (row_ids != "") {
            setup_dst_data.setup_dst.setSerializationLevel(false,false,true,true,true,true);
            var attached_obj = setup_dst_data.setup_dst;
            var grid_status = setup_dst_data.validate_form_grid(attached_obj,grid_label);

            var date_index = setup_dst_data.setup_dst.getColIndexById('effective_date');
            var year_index = setup_dst_data.setup_dst.getColIndexById('year');
            var hour_index = setup_dst_data.setup_dst.getColIndexById('hour');
            var insdel_index = setup_dst_data.setup_dst.getColIndexById('insert_delete'); 
            var dst_index = setup_dst_data.setup_dst.getColIndexById('dst_group_value_id');

            row_ids = row_ids.split(',');
            
            var status_ins_upd;// to either hit database or not

            if (grid_status) {
                $.each (row_ids, function(id) {
                    var date = setup_dst_data.setup_dst.cells(row_ids[id], date_index).getValue();
                    date = date.split('-');
                    var year = setup_dst_data.setup_dst.cells(row_ids[id], year_index).getValue();

                    if (date[0] != year) {
                        dhtmlx.message({
                                        type: 'alert',
                                        title: 'Error',
                                        ok: 'OK',
                                        text: 'Year must be same on Column <b>Date</b> and <b>Year</b>.'
                                    });
                        status_ins_upd = 0;
                        return;
                    } else {
                        ps_xml += '<PSRecordset ';
                        var id_value = setup_dst_data.setup_dst.cells(row_ids[id], 0).getValue();
                        ps_xml += ' id = "' + id_value + '" ';
                        ps_xml += ' effective_date = "' + setup_dst_data.setup_dst.cells(row_ids[id], date_index).getValue() + '" ';
                        ps_xml += ' year = "' + setup_dst_data.setup_dst.cells(row_ids[id], year_index).getValue() + '" ';
                        ps_xml += ' hour = "' + setup_dst_data.setup_dst.cells(row_ids[id], hour_index).getValue() + '" ';
                        ps_xml += ' insert_delete = "' + setup_dst_data.setup_dst.cells(row_ids[id], insdel_index).getValue() + '" ';
                        ps_xml += ' dst_group_value_id = "' + setup_dst_data.setup_dst.cells(row_ids[id], dst_index).getValue() + '" ';
                        ps_xml += " ></PSRecordset> ";
                        status_ins_upd = 1;
                    }                
                });
            }
            ps_xml += "</Root>";
            if (status_ins_upd == 1) {
                data = {
                        "action": "spa_dst_setup_hours",
                        "flag": "i",
                        "xml": ps_xml
                    };            
                adiha_post_data("return_array", data, "", "", "save_dst_data_callback","");
            }
        }
    }

    function save_dst_data_callback(result) {
       
         if (result[0][0] == 'Success') {
                dhtmlx.message({
                    text:'Changes have been saved successfully.',
                    expire:500
                });
                setup_dst_data.load_setup_dst_grid();
            } else if(result[0][0] == 'Error') {
                dhtmlx.message({
                    type: "alert",
                    title: "Alert",
                    text:result[0][4],
                    expire:500
                });
            }
    }
   
    setup_dst_data.validate_form_grid = function(attached_obj,grid_label) {;
        var status = true;
        for (var i = 0;i < attached_obj.getRowsNum();i++){
            var row_id = attached_obj.getRowId(i);
					
            for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
                var validation_message = attached_obj.cells(row_id,j).getAttribute("validation"); 
		
                if(validation_message != "" && validation_message != undefined){
                    var column_text = attached_obj.getColLabel(j);
				    error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                    dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                    status = false; break;
                }
                                
            }
            if(validation_message != "" && validation_message != undefined){ break;};
        } 
        return status;
    }

    function delete_setup_dst() {
        var selected_id = setup_dst_data.setup_dst.getSelectedId();
		var id_delete_concat = '';
		var selected_row_array = new Array();
			selected_row_array = selected_id.split(',');
			
			for(var i = 0; i < selected_row_array.length; i++) {
				 id_delete_concat += "," + setup_dst_data.setup_dst.cells(selected_row_array[i], 0).getValue();                                  
          }
		 
		 if(id_delete_concat.substr(0,1) == ",") {
							id_delete_concat = id_delete_concat.substr(1);
						}	
			
        if(selected_id == null) {
            show_messagebox('Please select the data you want to delete.');
            return;
        }

              
        var data = {
            "action": "spa_dst_setup_hours",
            "flag": "d",
            "id": id_delete_concat
        };
        
        var confirm_msg = 'Are you sure you want to delete?';

            dhtmlx.message({
            type: "confirm",
            title: "Confirmation",
            ok: "Confirm",
            text: confirm_msg,
            callback: function(result) {
            if (result)
                adiha_post_data("alert", data, "", "", "setup_dst_data.load_setup_dst_grid");
            }
        });
    }

    setup_dst_data.load_setup_dst_grid = function() {
        var param = {
            "action": "spa_dst_setup_hours",
            "flag": "g",
            "grid_type": "g"
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        setup_dst_data.setup_dst.clearAll();
        setup_dst_data.setup_dst.loadXML(param_url);
        setup_dst_data.setup_dst_menu.setItemDisabled('delete');
    }
      
</script>
