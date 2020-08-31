<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" /> 
    </head>

    <body>
        <?php
            require('../../../adiha.php.scripts/components/include.file.v3.php');
        
            $source_deal_header_id = (isset($_REQUEST["source_deal_header_id"]) && $_REQUEST["source_deal_header_id"] != '') ? get_sanitized_value($_REQUEST["source_deal_header_id"]) : 'NULL';
            $rights_product_info = 10131044;
            $rights_product_info_delete = 10131045;
            $environment_process_id = (isset($_REQUEST["environment_process_id"]) && $_REQUEST["environment_process_id"] != '') ? get_sanitized_value($_REQUEST["environment_process_id"]) : 'NULL';
            
            $php_script_loc = $app_php_script_loc;
        
            list (
                $has_rights_product_info,
                $has_rights_product_info_delete
            ) = build_security_rights(
                $rights_product_info,
                $rights_product_info_delete
            );
        
            $form_namespace = 'product_info';
        
            $layout_json = '
                [
                    {
                        id:             "a",
                        text:           "Product Info",
                        width:          500,
                        height:         500,
                        header:         false,
                        collapse:       false,
                        fix_size:       [false,null]
                    }
                ]
            ';
         
       
            $menu_json = '
                [
                    {id: "save", img: "tick.gif", imgdis:"tick_dis.gif", enabled:' . $has_rights_product_info . ', text: "OK"},
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"insert", text:"Insert Using Eligibility Mapping Template", img:"new.gif", imgdis:"new_dis.gif", title: "Insert Using Eligibility Mapping Template", enabled:"' . $has_rights_product_info . '"},
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"' . $has_rights_product_info . '"},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:0}
                    ]}
                  ]
            ';

            //dropdown query
            $jurisdiction_combo_sql = "EXEC('Select null, ''''  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 10002')";
            $jurisdiction_combo_array =  readXMLURL($jurisdiction_combo_sql);
            $combo['options'] = $jurisdiction_combo_array;
            $jurisdiction_combo = json_encode($combo);    

            $state_combo_sql = "EXEC('Select null, ''''  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 10016')";
            $state_combo_array =  readXMLURL($state_combo_sql);
            $combo['options'] = $state_combo_array;
            $state_combo = json_encode($combo);   

            $tier_combo_sql = "EXEC('Select null, ''''  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 15000')";
            $tier_combo_array =  readXMLURL($tier_combo_sql);
            $combo['options'] = $tier_combo_array;
            $tier_combo = json_encode($combo);  

            $technology_combo_sql = "EXEC('Select null, ''''  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 10009')";
            $technology_combo_array =  readXMLURL($technology_combo_sql);
            $combo['options'] = $technology_combo_array;
            $technology_combo = json_encode($combo);  


            $in_not_combo_sql = "EXEC('Select 1, ''IN''  UNION ALL   SELECT 0, ''NOT''')";
            $in_not_combo_array =  readXMLURL($in_not_combo_sql);
            $combo['options'] = $in_not_combo_array;
            $in_not_combo = json_encode($combo);      


            $vintage_combo_sql = "EXEC('Select null, ''''  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 10092')";
            $vintage_combo_array =  readXMLURL($vintage_combo_sql);
            $combo['options'] = $vintage_combo_array;
            $vintage_combo = json_encode($combo);       

            $certification_combo_sql = "EXEC('Select null, ''''  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 10011')";
            $certification_combo_array =  readXMLURL($certification_combo_sql);
            $combo['options'] = $certification_combo_array;
            $certification_combo = json_encode($combo);     
            
            $region_combo_sql = "EXEC('SELECT NULL, ''''  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 11150')";     
            $region_combo_array =  readXMLURL($region_combo_sql);
            $combo['options'] = $region_combo_array;
            $region_combo = json_encode($combo);

            //Creating Layout
            $layout_obj = new AdihaLayout();
            echo $layout_obj->init_layout('product_info_layout', '', '1C', $layout_json, $form_namespace);
                                 
            //Attach Menu
            $menu_object = new AdihaMenu();
            echo $layout_obj->attach_menu_cell("product_info_menu", "a"); 
            echo $menu_object->init_by_attach("product_info_menu", $form_namespace);
            echo $menu_object->load_menu($menu_json);
            echo $menu_object->attach_event('', 'onClick', $form_namespace . '.product_info_menu_click');
            
            //Attach grid
            $grid_table_obj = new AdihaGrid();
            $grid_name = 'setup_product_info';
            echo $layout_obj->attach_grid_cell($grid_name, 'a');
            // $sp_url = $spa_certificate_detail;
            echo $grid_table_obj->init_by_attach($grid_name, $form_namespace);
            echo $grid_table_obj->set_header('Source Product Number,Source Deal Header ID,IN/NOT,Region ,Jurisdiction,Tier,Technology,Vintage');
            echo $grid_table_obj->set_widths('200,200,200,200,200,200,200,200');
            echo $grid_table_obj->set_column_types('ro,ro,combo,combo,combo,combo,combo,combo');
            echo $grid_table_obj->set_columns_ids('source_product_number,source_deal_header_id,in_or_not,region_id,jurisdiction,tier_id,technology_id,vintage');
            echo $grid_table_obj->set_column_visibility('true,true,false,false,false,false,false,false');
			echo $grid_table_obj->set_sorting_preference('int,int,str,str,str,str,str,str');
            echo $grid_table_obj->attach_event('', 'onRowSelect', $form_namespace . '.grid_row_click'); 
            echo $grid_table_obj->set_search_filter(true, "");
            echo $grid_table_obj->return_init();
            echo $grid_table_obj->load_combo('jurisdiction', $jurisdiction_combo);
            echo $grid_table_obj->load_combo('tier_id', $tier_combo);
            echo $grid_table_obj->load_combo('technology_id', $technology_combo);
            echo $grid_table_obj->load_combo('in_or_not', $in_not_combo);
            echo $grid_table_obj->load_combo('vintage', $vintage_combo);
            echo $grid_table_obj->load_combo('region_id', $region_combo);
            echo $layout_obj->close_layout();                
        ?>

        <script type="text/javascript">
            var has_rights_product_info_delete = '<?php echo $has_rights_product_info_delete ?>';
            var source_deal_header_id = '<?php echo $source_deal_header_id ?>';
	        var environment_process_id = '<?php echo $environment_process_id ?>'

	        $(function() {
                dhxWins = new dhtmlXWindows();
                var grid_obj = product_info.setup_product_info;
				
                grid_obj.attachEvent("onXLE", function() {
                    grid_obj.attachEvent("onEditCell", function(stage, rId, cInd, nValue, oValue) {
                        if (stage == 2) {
                            var juri_index = grid_obj.getColIndexById('jurisdiction');
                            var tier_ind = grid_obj.getColIndexById('tier_id');
                            if (cInd == juri_index || cInd == tier_ind) {
                                product_info.change_grid_cell_value(rId, cInd, nValue);
                            }
                            return true;
                        }    
                    });
                    grid_obj.forEachRow(function(r_id) {
                        grid_obj.forEachCell(r_id, function(cellObj, ind) {
                            var juri_index = grid_obj.getColIndexById('jurisdiction');
                            var tier_ind = grid_obj.getColIndexById('tier_id');
                            if (ind == juri_index) {
                                nValue = grid_obj.cells(r_id, juri_index).getValue();
                                product_info.load_column_combo(grid_obj, nValue, r_id, ind, false, true);
                            } else if (ind == tier_ind) {
                                nValue = grid_obj.cells(r_id, tier_ind).getValue();
                                product_info.load_column_combo(grid_obj, nValue, r_id, ind, true, true);
                            }
                        });
                    });
                });

                product_info.grd_product_refresh();
            });

            product_info.grd_product_refresh = function(id, msg, rec) {

                var grid_obj = product_info.setup_product_info;

                if(id == undefined || id == '') {
                    id = null;
                } 
                if (msg != undefined) {
                    dhtmlx.message({ text: msg, expire:1500 });
                }

                var param = {
                    'action': 'spa_gis_product_detail',
                    'flag': 's',
                    'source_deal_header_id': source_deal_header_id,
                    'template_id' : id,
    		        'environment_process_id': environment_process_id
    			};

                var del_source_product_numbers = grid_obj.getUserData("", "del_source_product_numbers");

                grid_obj.setUserData("", "del_source_product_numbers", '');

                param = $.param(param);   
                var param_url = js_data_collector_url + "&" + param;
                grid_obj.clearAndLoad(param_url);
                product_info.product_info_menu.setItemDisabled('delete');

                if (del_source_product_numbers != '') {
                    grid_obj.attachEvent("onXLE", function() {
                        grid_obj.forEachRow(function(e) {
                            var prod_num = grid_obj.cells(e,0).getValue();

                            var should_delete = del_source_product_numbers.split(',').filter(function(del_source_product_number) {
                                return del_source_product_number == prod_num;
                            }).length > 0

                            if (should_delete) {
                                grid_obj.setSelectedRow(e)
                                product_info.delete_grid_row(grid_obj)
                            }
                        })
                    });
                }

                grid_obj.setColValidators(["", "", "NotEmpty,ValidInteger", "", "", "", ""]);
                
                grid_obj.attachEvent("onValidationError", function(id, ind, value) {
                    var message = "Invalid Data";
                    grid_obj.cells(id, ind).setAttribute("validation", message);
                    return true;
                });

                grid_obj.attachEvent("onValidationCorrect", function(id, ind, value){
                    grid_obj.cells(id, ind).setAttribute("validation", "");
                    return true;
                });
            }


            product_info.product_info_menu_click = function(id){
                var grid_obj = product_info.setup_product_info;
                switch(id){
                    case 'save': 
                        product_info.save_product_detail();
                        break;
                    case 'insert':
                        product_info.eligibility_mapping_template_details();
                        break
                    case 'add': 
                        var new_id = (new Date()).valueOf();
                        product_info.setup_product_info.addRow(new_id, '');
                        product_info.setup_product_info.selectRowById(new_id);
                        product_info.setup_product_info.cells(new_id, 2).setValue(1);
                        break;
                    case 'delete': 
                        product_info.delete_grid_row(grid_obj);
                        break;
                    default:
                        break;
                }
            }

            product_info.delete_grid_row = function(grid_obj) {
                var del_ids = product_info.setup_product_info.getSelectedRowId();
                var previously_xml = grid_obj.getUserData("", "deleted_xml");
                var grid_xml = "";

                if (previously_xml != null) {
                    grid_xml += previously_xml
                }

                var del_array = new Array();
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();

                var del_source_product_numbers = (grid_obj.getUserData("", "del_source_product_numbers") != '') 
                    ? grid_obj.getUserData("", "del_source_product_numbers").split(',')
                    : [];
                

                $.each(del_array, function(index, value) {
                    if ((grid_obj.cells(value,0).getValue() != "") || (grid_obj.getUserData(value,"row_status") != "")) {
                        grid_xml += "<GridRow ";

                        for (var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {
                            grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + grid_obj.cells(value,cellIndex).getValue() + '"';
                            
                            if (grid_obj.getColumnId(cellIndex) == "source_product_number"){
                                del_source_product_numbers.push(grid_obj.cells(value,cellIndex).getValue())
                            }
                        }

                        grid_xml += " ></GridRow> ";
                    }
                });

                grid_obj.setUserData("", "deleted_xml", grid_xml);
                grid_obj.setUserData("", "del_source_product_numbers", del_source_product_numbers.join(','));
                grid_obj.deleteSelectedRows(); 
				product_info.product_info_menu.setItemDisabled('delete');
            }
        
            product_info.eligibility_mapping_template_details = function() {
                var source_deal_header_id = '<?php echo $source_deal_header_id; ?>';
                var param = app_form_path +  '_deal_capture/maintain_deals/eligibility.mapping.template.details.php?&source_deal_header_id=' + source_deal_header_id;
                var is_win = dhxWins.isWindow('w11');
                
                if (is_win == true) {
                    w11.close();
                }
                
                w11 = dhxWins.createWindow("w11", 100, 38, 500, 300);
                w11.setText("Eligibility Mapping Template Details");
                w11.setModal(true);
                w11.maximize();
                
                w11.attachURL(param, false, true)
                    w11.attachEvent('onClose', function(win) {
                    return true;
                });
                
            }
       
            product_info.grid_row_click = function() { 
                var selected = product_info.setup_product_info.getSelectedRowId();
                
                if (selected == null) {
                    product_info.product_info_menu.setItemDisabled('delete');
                } else {       
                    if (has_rights_product_info_delete) {
                        product_info.product_info_menu.setItemEnabled('delete');
                    }    
                }
            } 

            product_info.change_grid_cell_value = function(rId, cInd, nValue) {
                var grid_obj = product_info.setup_product_info;

                juri_index = grid_obj.getColIndexById('jurisdiction'); 
                juri_combo_obj = grid_obj.getColumnCombo(juri_index); //Get Jurisdiction combo obj
                var tier_index = grid_obj.getColIndexById('tier_id');

                if (juri_index == cInd) { 
                    product_info.load_column_combo(grid_obj, nValue, rId, cInd, false, false);
                    var tech_index = grid_obj.getColIndexById('technology_id');
                    grid_obj.cells(rId, tech_index).setValue('');
                } else if (tier_index == cInd) {
                    product_info.load_column_combo(grid_obj, nValue, rId, cInd, true, false);
                }
            }

            product_info.load_column_combo = function(grid_obj, nValue, rId, cInd, is_tier, is_load) {
                //TODO load individual Column Combo Options Regarding with parent column
                var child_c_id = (is_tier) ? 'technology_id' : 'tier_id';
                var child_c_index = grid_obj.getColIndexById(child_c_id);

                var patt = /^[0-9]/g;
                var is_num = patt.test(nValue);

                var combo_obj = grid_obj.cells(rId, child_c_index).getCellCombo();
                var first_value = grid_obj.cells(rId, cInd).getValue();
                var new_c_changed_value = new_state_value_id = '';

                if (is_num == false) {
                    new_state_value_id = new_c_changed_value = first_value;  //global variable to set value of jurisdiction
                } else {
                    new_state_value_id = new_c_changed_value = nValue;
                }

                if (is_tier) {
                    var juri_index = grid_obj.getColIndexById('jurisdiction');
                    new_state_value_id = grid_obj.cells(rId, juri_index).getValue();
                }

                if (!is_tier) {
                    var cm_params = {
                        'action' : 'spa_save_custom_form_data',
                        'flag': 'j',
                        'state_value_id': new_state_value_id,
                        'has_blank_option': 'false'
                    };
                } else {
                    var cm_params = {
                        'action': 'spa_save_custom_form_data',
                        'flag': 't',
                        'state_value_id': new_state_value_id,
                        'selected_tier_value': new_c_changed_value,
                        'has_blank_option': 'false'
                    };
                }
                
                cm_params = $.param(cm_params);
                var urls = js_dropdown_connector_url + '&' + cm_params;
                var old_value = grid_obj.cells(rId, child_c_index).getValue();
                combo_obj.clearAll();

                combo_obj.load(urls, function() {
                    combo_obj.show();

                    if (is_load) {
                        grid_obj.cells(rId, child_c_index).setValue(old_value);
                    } else {
                        grid_obj.cells(rId, child_c_index).setValue('');
                    }
                });
            }

            product_info.save_product_detail = function () {
                var grid_node = 'ProductDetail';
                var delete_grid_name = "";
                var grid_xml = "<GridGroup>";
                var changed_ids = new Array();
                var grid_obj = product_info.setup_product_info;
                var grid_status = null; // needs to be changed
                var valid_status = 1;

                grid_obj.clearSelection(); 

                var ids = grid_obj.getChangedRows(true); //not used
                var all_ids = grid_obj.getAllRowIds();
                grid_id = grid_obj.getUserData("", "grid_id");
                grid_label = 'Product Detail'
                deleted_xml = grid_obj.getUserData("", "deleted_xml");

                if (deleted_xml != null && deleted_xml != "") {
                    grid_xml += "<GridDelete grid_id=\"" + grid_id + "\" grid_label=\"" + grid_label + "\">";
                    grid_xml += deleted_xml;
                    grid_xml += "</GridDelete>";

                    if (delete_grid_name == "") {
                        delete_grid_name = grid_label
                    } else {
                        delete_grid_name += "," + grid_label
                    }
                }

                if (all_ids != "") {
                    grid_obj.setSerializationLevel(false, false, true, true, true, true);
                    grid_status = product_info.validate_form_grid(grid_obj, grid_label);
                    
                    changed_ids = all_ids.split(",");

                    if (grid_status) {
                        $.each(changed_ids, function(index, value) {
                            grid_obj.setUserData(value, "row_status", "new row");
                            grid_xml += "<GridRow ";

                            for(var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {
                                if (grid_obj.cells(value, cellIndex).getValue() == 'undefined') {  
                                    grid_xml += " " + grid_obj.getColumnId(cellIndex) + '= "NULL"';
                                    continue;
                                }

                                if (grid_obj.getColumnId(cellIndex) == 'source_deal_header_id') {
                                    grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + source_deal_header_id + '"';
                                } else {
                                    grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + (grid_obj.cells(value,cellIndex).getValue()) + '"';
                                }                        
                            }
                            grid_xml += " ></GridRow> ";
                        });

                    } else {
                        valid_status = 0;
                        return;
                    }
                }

                grid_xml += "</GridGroup>";
                var xml = "<Root>";
                xml += grid_xml;
                xml += "</Root>";
                xml = xml.replace(/'/g, "\"");
            
                var flag = 'i';
                
                data = {"action": "spa_gis_product_detail", "flag":flag, "xml":xml, "environment_process_id": environment_process_id}

                if (delete_grid_name != "") {
                    del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                    result = adiha_post_data("confirm-warning", data, "", "", "product_info.save_callback", "", del_msg);
                } else {
                    result = adiha_post_data("return_json", data, "", "", "product_info.save_callback");
                }
                delete_grid_name = "";
                deleted_xml = grid_obj.setUserData("", "deleted_xml", ""); 
            }

            product_info.save_callback = function(result) {
                if (typeof(result) == 'string') {
                    result = JSON.parse(result);
                    if (result[0].errorcode == "Error") {
                        msg = result[0].message;
                        dhtmlx.message({
                            type: "alert",
                            title: "Alert",
                            text: msg
                        });
                    } else
    				    rec = result[0].recommendation;
    				    msg = result[0].message;
    				    parent.env_process_id = rec;
    				    setTimeout(function(){parent.dhxWins.window('w11').close()}, 500);  
                    }
                else{
    				rec = result[0].recommendation;	
    				parent.env_process_id = rec;
    				setTimeout(function(){parent.dhxWins.window('w11').close()}, 0);
    			}
            }

            product_info.validate_form_grid = function(attached_obj, grid_label) {
                var status = true;

                for (var i = 0; i < attached_obj.getRowsNum(); i++){
                    var row_id = attached_obj.getRowId(i);
                    for (var j = 0; j < attached_obj.getColumnsNum(); j++){ 
                        var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                        
                        if (validation_message != "" && validation_message != undefined) {
                            var column_text = attached_obj.getColLabel(j);
                            error_message = "Data Error in <b>" + grid_label + "</b> grid. Please check the data in column <b>" + column_text + "</b> and resave.";
                            dhtmlx.alert({title:"Alert", type:"alert", text: error_message});
                            status = false; break;
                        }
                    }

                    if (validation_message != "" && validation_message != undefined) {
                        break;
                    };
                }

                return status;
            }
        </script>
    </body>
</html>