<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
<?php
    $form_name = 'form_subsidiary_book';
    $form_namespace = 'subsidiary_book';
    $subsidiary_function_id = '10101216';
    $strategy_function_id = '10101217';
    $book_function_id = '10101210';
    $book_mapping_function_id = '10101213';
    $grid_counter = 0;
  
    $rights_book_structure_iu = 10101210; 
        
    list (
        $has_rights_book_structure_iu      
    ) = build_security_rights (
        $rights_book_structure_iu
    );
    $enable_data_ui = ($has_rights_book_structure_iu) ? 'false' : 'true';
    
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            width:          250,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                    
                    ]';

    $subsidiary_book_layout = new AdihaLayout();
    echo $subsidiary_book_layout->init_layout('subsidiary_book_layout', '', '1C', $layout_json, $form_namespace);
    
    $subsidiary_book_toolbar = new AdihaToolbar();
    $toolbar_name =  'Save_from_toolbar';
    $toolbar_json = '[
                        { id: "save", type: "button", img: "save.gif", text:"Save", title: "Add", disabled : ' . $enable_data_ui . '},
                        { type: "separator" }
                     
                     ]';
               
    echo $subsidiary_book_layout->attach_toolbar_cell($toolbar_name, 'a'); 
    echo $subsidiary_book_toolbar-> init_by_attach($toolbar_name, $form_namespace);
    echo $subsidiary_book_toolbar-> load_toolbar($toolbar_json);
    echo $subsidiary_book_toolbar->attach_event('', 'onClick', 'property_toolbar_click');
    
    $entity_id = get_sanitized_value($_GET['entity_id']);
    $entity_id_arr = explode("_", $entity_id);
    
    if ($entity_id_arr[0] == 'a')
        $form_sp = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=" . $subsidiary_function_id . ", @template_name='setup_book_subsidiary', @parse_xml = '<Root><PSRecordSet fas_subsidiary_id=\"" . $entity_id_arr[1] . "\"></PSRecordSet></Root>'";
    else if ($entity_id_arr[0] == 'b')
        $form_sp = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=" . $strategy_function_id . ", @template_name='setup_book_strategy', @parse_xml = '<Root><PSRecordSet fas_strategy_id=\"" . $entity_id_arr[1] . "\"></PSRecordSet></Root>'";
    else if ($entity_id_arr[0] == 'c')
        $form_sp = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=" . $book_function_id . ", @template_name='setup_book_option', @parse_xml = '<Root><PSRecordSet fas_book_id=\"" . $entity_id_arr[1] . "\"></PSRecordSet></Root>'";
    else if ($entity_id_arr[0] == 'd')
        $form_sp = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=" . $book_mapping_function_id . ", @template_name='setup_sub_book_mapping', @parse_xml = '<Root><PSRecordSet book_deal_type_map_id=\"" . $entity_id_arr[1] . "\"></PSRecordSet></Root>'";
    
    $form_data = readXMLURL2($form_sp);
    $return_string = '';

	if (is_array($form_data) && sizeof($form_data) > 0) {
        $return_string .= 'tabbar_detail = subsidiary_book.subsidiary_book_layout.cells("a").attachTabbar({mode:"bottom",arrows_mode:"auto"});' . "\n";
        
        $flattened_form_data = array();
        $tab_data = array();
        
        foreach ($form_data as $data) {
        	if (!array_key_exists($data['tab_id'], $flattened_form_data))
                $flattened_form_data[$data['tab_id']] = array();
        
            $tab_id = 'detail_tab_' . $data['tab_id'];
        	array_push($flattened_form_data[$data['tab_id']], array($tab_id, $data['tab_id'], $data['layout_pattern'], $data['form_json'], $data['grid_json'], $data['seq'], $data['dependent_combos'] ?? ''));
        	array_push($tab_data, $data['tab_json']);
        }
        
        $combined_tab_data = '{tabs: [' . implode(",", $tab_data) . ']};';
        
        $return_string .= 'tabbar_data = ' . $combined_tab_data . "\n";
        $return_string .= 'tabbar_detail.loadStruct(tabbar_data);' . "\n"; 
        
        foreach ($flattened_form_data as $key => $value) {
			$return_string .= 'details_layout_' . $key . ' = tabbar_detail.cells("' . $value[0][0] . '").attachLayout("' . $value[0][2] . '");' . "\n";

			$grid_json = array();
			$pre = strpos($value[0][4], '[');
			if ($pre === false) {
				$value[0][4] = '[' .  $value[0][4] . ']';
			}

			$grid_json = json_decode($value[0][4], true);

			foreach($grid_json as $obj) {
				// if form
				if ($obj['grid_id'] == 'FORM') {
					$return_string .= ' details_layout_' . $key . '.cells("' . $obj['layout_cell'] . '").hideHeader();';
					$return_string .= '	details_form_' . $key . ' = details_layout_' . $key . '.cells("' . $obj['layout_cell'] . '").attachForm();' . "\n";
					$return_string .= '	details_form_' . $key . '.loadStruct(' . $value[0][3] . ');' . "\n";
                    
                    $return_string .= ' var form_name = "details_form_' . $key . '";';
                    $return_string .= ' attach_browse_event(form_name);';
                    
                    $return_string .= ' details_form_' . $key . '.attachEvent("onChange", function (name, value) { '. "\n";
                    $return_string .= '     if (name == "mismatch_tenor_value_id") { '. "\n";
                    $return_string .= '         var rolling_hedge_forward = details_form_' . $key . '.getCombo("mismatch_tenor_value_id");'. "\n";
                                            
                    $return_string .= '         if (rolling_hedge_forward != null) { '. "\n";
                    $return_string .= '             combo_option = rolling_hedge_forward.getSelectedValue();'. "\n";
                                                
                    $return_string .= '             if (combo_option == 252) {//Apply Hedge/Item Term Mismatch'. "\n";
                    $return_string .= '                 details_form_' . $key . '.enableItem("rollout_per_type");'. "\n";
                    $return_string .= '             } else { '. "\n";
                    $return_string .= '                 details_form_' . $key . '.disableItem("rollout_per_type"); '. "\n";
                    $return_string .= '             } '. "\n";      
                    $return_string .= '         } '. "\n";            
                    $return_string .= '     }'. "\n";
                                        
                    $return_string .= '     if (name == "gl_grouping_value_id") {' . "\n";
                    $return_string .= '         var gl_entry_grouping = details_form_' . $key . '.getCombo("gl_grouping_value_id");' . "\n";
                                            
                    $return_string .= '         if (gl_entry_grouping != null) {' . "\n";
                    $return_string .= '             var combo_option = gl_entry_grouping.getSelectedValue();' . "\n";
                    $return_string .= '             enable_combos = (combo_option == 350) ? true : false;//Grouped at Strategy' . "\n";
                    $return_string .= '             enable_disable_gl_code_objects(enable_combos)' . "\n";
                    $return_string .= '         }'. "\n";
                    $return_string .= '     } '. "\n";
                                        
                    $return_string .= '     if (name == "hedge_type_value_id") {' . "\n";
                    $return_string .= '         var accounting_type = details_form_' . $key . '.getCombo("hedge_type_value_id");' . "\n";
                                            
                    $return_string .= '         if (accounting_type != null) {' . "\n";
                    $return_string .= '             var combo_option = accounting_type.getSelectedValue();' . "\n";
                    $return_string .= '             on_change_accounting_type(combo_option);' . "\n";
                    $return_string .= '             show_hide_gl_code_objects(combo_option);' . "\n";
                    $return_string .= '         }' . "\n";
                    $return_string .= '     } ' . "\n";   
                                        
                    $return_string .= ' });';
                    
                    if ($value[0][6] != NULL && $value[0][6] != '') {
						$dependent_combo_array = array();
						$dependent_combo_array = explode(',', $value[0][6]);

						if (sizeof($dependent_combo_array) > 0) {
							foreach ($dependent_combo_array as $combo_prop) {
								$column_array = array();
					            $column_array = explode('->', $combo_prop);
					            $parent_column = $column_array[0];
					            $dep_column = $column_array[1];

								$return_string = ' dhx' . $parent_column . '_' . $key . ' = details_form_' . $key . '.getCombo("' . $parent_column . '"); '. "\n"; 
						        $return_string .= 'dhx' . $dep_column . '_' . $key . ' = details_form_' . $key . '.getCombo("' . $dep_column . '"); '. "\n"; 

						        $return_string .= 'dhx' . $dep_column . '_' . $key . '.clearAll();' . "\n";
						        $return_string .= 'var value = details_form_' . $key . '.getItemValue("' . $parent_column . '");' . "\n";
						        
						        $return_string .= 'application_field_id = details_form_' . $key . '.getUserData("' . $dep_column . '", "application_field_id");' ."\n";
						        $return_string .= 'url = "' . $app_php_script_loc . 'dependent.columns.connector.php?value="+value+"&application_field_id="+application_field_id+"&parent_column=' . $parent_column . '";' ."\n";
						        $return_string .= 'dhx' . $dep_column . '_' . $key . '.load(url);' . "\n";

						        $return_string .= 'dhx' . $parent_column . '_' . $key . '.attachEvent("onChange", function(value){'. "\n";
						        $return_string .= '   dhx' . $dep_column . '_' . $key . '.clearAll();' . "\n";
						        $return_string .= '   dhx' . $dep_column . '_' . $key . '.setComboValue(null);' . "\n";
						        $return_string .= '   dhx' . $dep_column . '_' . $key . '.setComboText(null);' . "\n";
						        $return_string .= '   application_field_id = details_form_' . $key . '.getUserData("' . $dep_column . '", "application_field_id");' ."\n";
						        $return_string .= '   url = "' . $app_php_script_loc . 'dependent.columns.connector.php?value="+value+"&application_field_id="+application_field_id+"&parent_column=' . $parent_column . '";' ."\n";
						        $return_string .= '   dhx' . $dep_column . '_' . $key . '.load(url);' . "\n";
						        $return_string .= '});'. "\n";
							}
						}
					}
				} else {
				    //if Grid					
					$paging_div = 'detail_' . $obj['layout_cell'] .'_' . $key;
					$return_string .= "details_layout_" . $key . ".cells('" . $obj['layout_cell'] . "').attachStatusBar({
                                height: 30,
                                text: '<div id=\'" . $paging_div . "\'></div>'
                            });";
                    $return_string .= 'details_layout_' . $key . '.cells("' . $obj['layout_cell'] . '").setText("' . $obj['grid_label'] . '");';
                    
                    $grid_obj = 'grid_' . $key;
					$menu_obj = 'menu_' . $key;
					$return_string .= $obj['grid_id'] . '= {};';
					$grid_obj_withnamespace = $obj['grid_id'] .  '.' . $grid_obj;
					$menu_obj_withnamespace = $obj['grid_id'] .  '_' . $menu_obj;
					
					// grid menu definition
					$return_string .= $menu_obj_withnamespace . '= details_layout_' . $key . '.cells("' . $obj['layout_cell'] . '").attachMenu({
							icons_path: "'. $image_path . 'dhxmenu_web/",' . "\n";
					
                    $return_string .= '		json:[
                            {id:"refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", text:"Refresh", title:"Refresh", enabled: true},
                            {id:"t1", text:"Edit", img:"edit.gif", items:[
                                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                            ]},
                            {id:"t2", text:"Export", img:"export.gif", items:[
                                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                            ]}' . "\n";
                    
		            $return_string .= ' ]' . "\n";
					$return_string .= '});' . "\n";
                    
                    // menu click function		
					$return_string .= $menu_obj_withnamespace . '.attachEvent("onClick", function(id) {' . "\n";    				 	
                    $return_string .= '		switch(id) {' . "\n";
    				
                    $return_string .= '         case "refresh":' . "\n";
                    $return_string .= '             refresh_source_book_mapping();' . "\n";
                    $return_string .= '             break;'. "\n";
                    $return_string .= '			case "add":' . "\n";
					/*$return_string .= '			var newId = (new Date()).valueOf();' . "\n";
					$return_string .= 				$grid_obj_withnamespace . '.addRow(newId,"");' . "\n";
					$return_string .= 				$grid_obj_withnamespace . '.selectRowById(newId);' . "\n";
					$return_string .= 				$grid_obj_withnamespace . '.forEachRow(function(row){'. "\n";	
					$return_string .= 					$grid_obj_withnamespace . '.forEachCell(row,function(cellObj,ind){'. "\n";	
					$return_string .= 						$grid_obj_withnamespace . '.validateCell(row,ind)'. "\n";	
					$return_string .= '					});'. "\n";	
					$return_string .= '				});'. "\n";	
                    $return_string .= 				$menu_obj_withnamespace.'.setItemDisabled("delete");' . "\n";    
                    */
                    $return_string .= '             sub_book_property(null);' . "\n";
                    $return_string .= '             break;'. "\n";
        			$return_string .= '        	case "delete":'. "\n";
                    $return_string .= '             var row_id = ' . $grid_obj_withnamespace. '.getSelectedRowId();' . "\n";
                    $return_string .= '             var book_deal_type_map_id = ' . $grid_obj_withnamespace. '.cells(row_id, 0).getValue();' . "\n";

                    $return_string .= '             var param = {
                                                        "action": "spa_sourcesystembookmap",
                                                        "flag": "d",
                                                        "book_deal_type_map_id": book_deal_type_map_id
                                                    };
                                                    adiha_post_data("confirm", param, "", "", "refresh_source_book_mapping");' . "\n";
        			/*$return_string .= '				var del_ids = ' . $grid_obj_withnamespace . '.getSelectedRowId();';
        			$return_string .= '				var previously_xml = ' . $grid_obj_withnamespace.'.getUserData("", "deleted_xml");';
        			$return_string .= '             var grid_xml = "";';
        			$return_string .= '				if (previously_xml != null) {';
        			$return_string .= '					grid_xml += previously_xml';
        			$return_string .= '				}';
        			$return_string .= '             var del_array = new Array();';
        			$return_string .= '             del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();';
        			
        			$return_string .= '             $.each(del_array, function(index, value) {'. "\n";
			        $return_string .= '             	if(('.$grid_obj_withnamespace . '.cells(value,0).getValue() != "") || (' . $grid_obj_withnamespace . '.getUserData(value,"row_status") != "")){';
					$return_string .= '             			grid_xml += "<GridRow ";';
			        $return_string .= '                 		for(var cellIndex = 0; cellIndex < ' . $grid_obj_withnamespace . '.getColumnsNum(); cellIndex++){';
			        $return_string .= '                     		grid_xml += " " + ' . $grid_obj_withnamespace . '.getColumnId(cellIndex) + \'="\' + ' . $grid_obj_withnamespace . '.cells(value,cellIndex).getValue() + \'"\';';
			        $return_string .= '                     	}';
			        $return_string .= '                 	grid_xml += " ></GridRow> ";';
					$return_string .= '                 }';
			        $return_string .= '             });'. "\n";

        			$return_string .= 				$grid_obj_withnamespace.'.setUserData("", "deleted_xml", grid_xml);';
        			
					$return_string .= 				$grid_obj_withnamespace . '.deleteSelectedRows();' . "\n";
					*/
					$return_string .= 				$menu_obj_withnamespace.'.setItemDisabled("delete");' . "\n";
					$return_string .= '             break;'. "\n";
                    //excel export
                    $return_string .= '        case "excel":'. "\n";
                    $return_string .=               $grid_obj_withnamespace .   '.toExcel("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php");'. "\n";
                    $return_string .= '             break;'. "\n";
                    
                    // pdf export
                    $return_string .= '        case "pdf":'. "\n";
                    $return_string .=               $grid_obj_withnamespace .   '.toPDF("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");'. "\n";
                    $return_string .= '             break;'. "\n";
                    
					$return_string .= '		}' . "\n";
					$return_string .= '});' . "\n";
                    
                    $return_string .= $grid_obj_withnamespace . '= details_layout_' . $key . '.cells("' . $obj['layout_cell'] . '").attachGrid();';
	
					//START OF GRID ATTACH
					// create grid using definition in adiha_grid_definition
					$$grid_obj = new GridTable($obj['grid_id']);
    				$return_string .= $$grid_obj->init_grid_table($grid_obj, $obj['grid_id']);
    				$return_string .= $$grid_obj->enable_multi_select();
                    $return_string .= $$grid_obj->set_search_filter(true, ""); //for inline filter.
    				$return_string .= $$grid_obj->enable_paging(100, $paging_div, 'true');
    				$return_string .= $$grid_obj->submit_added_rows();
    				$return_string .= $$grid_obj->set_user_data("", "grid_id", $obj['grid_id']);
    				$return_string .= $$grid_obj->set_user_data("", "grid_obj", $obj['grid_id']);
					$return_string .= $$grid_obj->set_user_data("", "grid_label", $obj['grid_label']);
    				$return_string .= $$grid_obj->return_init();
    				$return_string .= $$grid_obj->load_grid_data('', $entity_id_arr[0]);
    				$return_string .= $$grid_obj->load_grid_functions('', $entity_id_arr[0]);
                    $return_string .= $$grid_obj->attach_event('', 'onRowDblClicked', 'sub_book_property');
                    
                    $return_string .= $grid_obj_withnamespace.'.attachEvent("onRowSelect", function(id){';
                    $return_string .=          $menu_obj_withnamespace .'.setItemEnabled("delete");' . "\n";
                    $return_string .= '     });' . "\n";            
                    
                    
                    /*$return_string .= $grid_obj_withnamespace.'.attachEvent("onRowDblClicked", function(id,ind){';
					$return_string .= '         var selected_row = '.$grid_obj_withnamespace.'.getSelectedRowId();' . "\n";
                    $return_string .= '         var column_type = '.$grid_obj_withnamespace.'.getColType(0);' . "\n";
                    $return_string .= '         if (column_type == "tree") { ' . "\n";
                    $return_string .=               $grid_obj_withnamespace.'.enableTreeCellEdit(false);' . "\n";
                    $return_string .= '             var no_of_children = '.$grid_obj_withnamespace.'.hasChildren(selected_row);' . "\n";
                    $return_string .= '             if (no_of_children != 0) { ' . "\n";
                    $return_string .= '                 var state = '.$grid_obj_withnamespace.'.getOpenState(selected_row);' . "\n";
                    $return_string .= '                 if (state)' . "\n";
                    $return_string .= '                     '.$grid_obj_withnamespace.'.closeItem(selected_row);'. "\n";
                    $return_string .= '                 else '. "\n";
                    $return_string .= '                     '.$grid_obj_withnamespace.'.openItem(selected_row);;'. "\n";
					$return_string .= '            }';
                    $return_string .= '         }';
                    $return_string .=           $grid_obj_withnamespace.'.editCell();';
                    $return_string .= ' 	});';            
                    */
    				$permission_array = array();
    				$permission_array = $$grid_obj->return_permission();
                    /*if (!$permission_array['edit']) {
    					$return_string .= $menu_obj_withnamespace . '.setItemDisabled("add");';
                                            $return_string .= $$grid_obj->disable_grid();
    				}
                    
					if ($permission_array['delete']) {
						$return_string .= $grid_obj_withnamespace.'.attachEvent("onRowSelect", function(id,ind){';
						$return_string .= 				$menu_obj_withnamespace.'.setItemEnabled("delete");';
						$return_string .= ' 	});';
                    }*/
                    //END OF GRID ATTACH
                    
                    $grid_counter++;
				}
            }
        }  
	}
    
    echo $return_string;
    
    echo $subsidiary_book_layout->close_layout();
?>
<script>
    var entity_id = '<?php echo $entity_id; ?>';
    var setup_book_structure_id = '10101200'
    var subsidiary_function_id = '<?php echo $subsidiary_function_id; ?>';
    var strategy_function_id = '<?php echo $strategy_function_id; ?>';
    var book_function_id = '<?php echo $book_function_id; ?>';
    var book_mapping_function_id = '<?php echo $book_mapping_function_id; ?>';
    var validation_status = true;
    
    var fas_book_id = <?php echo isset($entity_id_arr[1]) ? $entity_id_arr[1] : 0;?>;



    var SHOW_SUBBOOK_IN_BS = <?php echo $SHOW_SUBBOOK_IN_BS;?>;//show hide parameter for sub book in book structure
    $(function() {
        dhxWins = new dhtmlXWindows();
    })

    $(function() {
        var grid_obj = '<?php echo $grid_obj_withnamespace ?? '';?>';
        tabbar_detail.forEachTab(function(tab){
            layout_obj = tab.getAttachedObject();
            layout_obj.forEachItem(function(cell) {
            attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXForm) {
                    var gl_entry_grouping = attached_obj.getCombo('gl_grouping_value_id');     
                                   
                    if (gl_entry_grouping != null) {
                        attached_obj.attachEvent('onOptionsLoaded', function(name) {
                        if (name == 'gl_grouping_value_id') {
                            var combo_option = gl_entry_grouping.getSelectedValue();
                            enable_combos = (combo_option == 350) ? true : false; //Grouped at Strategy
                            enable_disable_gl_code_objects(enable_combos) // to disable GL Code Mapping tab objects and Roll Per Type combo in update case for Strategy
                        }
                    })
                        
                    }
                    
                    var accounting_type = attached_obj.getCombo('hedge_type_value_id');
                                            
                    if (accounting_type != null) {
                        attached_obj.attachEvent('onOptionsLoaded', function(name) {
                            if (name == 'hedge_type_value_id') {
                                var combo_option = accounting_type.getSelectedValue();
                                on_change_accounting_type(combo_option);   // to be used to disable : Rolling Hedge Forward, Rolling Per Type, Measurement Values,  OCI Rollout of Detail tab When Accounting Type "Fair Value Hedges" is selected, 
                                show_hide_gl_code_objects(combo_option); 
                            }
                        });                    
                    }                    
                }
                
                if (attached_obj instanceof dhtmlXGridObject) {
                    grid_obj = attached_obj;
                    var load_value_sql = {
                        "action": "spa_book_tag_name", 
                        "flag": "s"
                    };
                    var load_value_result = adiha_post_data('return_array', load_value_sql, '', '', function(load_value_result) {
                        var tag1_index = grid_obj.getColIndexById('tag1');
                        var tag2_index = grid_obj.getColIndexById('tag2');
                        var tag3_index = grid_obj.getColIndexById('tag3');
                        var tag4_index = grid_obj.getColIndexById('tag4');

                        grid_obj.setColLabel(tag1_index, load_value_result[0][0]);
                        grid_obj.setColLabel(tag2_index, load_value_result[0][1]);
                        grid_obj.setColLabel(tag3_index, load_value_result[0][2]);
                        grid_obj.setColLabel(tag4_index, load_value_result[0][3]);
                    });
                }
            }); 
         });
         
         node_id_array = entity_id.split('_');
         if (node_id_array[0] == 'c') {
            var param = {
                        "action": "spa_books",
                        "flag": "g",
                        "fas_book_id": node_id_array[1],
                    };
            param = $.param(param);

            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: param,
                success: function(data) {
                            response_data = data["json"];
                            enable_combos = (response_data[0].gl_entry_grouping == 351) ? true : false; // 'Grouped at Book'
                            enable_disable_gl_code_objects(enable_combos);
                            combo_option = response_data[0].accounting_type;
                            show_hide_gl_code_objects(combo_option);
                        }
            });
        }
        
        if (node_id_array[0] == 'd') {
            var param = {
                        "action": "spa_sourcesystembookmap",
                        "flag": "g",
                        "book_deal_type_map_id": node_id_array[1],
                    };
            param = $.param(param);

            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: param,
                success: function(data) {
                            response_data = data["json"];
                            enable_combos = (response_data[0].gl_entry_grouping == 352) ? true : false;// 'Grouped at SBM'
                            enable_disable_gl_code_objects(enable_combos);
                            combo_option = response_data[0].accounting_type;
                            show_hide_gl_code_objects(combo_option);
                        }
            });
        }
        if (node_id_array[0] == 'c' && SHOW_SUBBOOK_IN_BS == 1) {
            tabbar_detail.forEachTab(function(tab) {
                if (tab.getText() == 'Source Book Mapping') {
                    tab.hide();
                }
            });
        }
        //
        if (SHOW_SUBBOOK_IN_BS == 0) {
            var data =  {"sp_string": "EXEC spa_sourcesystembookmap @flag = 'm', @fas_book_id = " + fas_book_id};
            adiha_post_data('return_json', data, '', '', 'load_source_book_mapping');      
        }                   
    });
    /**
     *
     */
    sub_book_property = function(row_id){
        var fas_book_id = 'NULL';
        node_id_array = entity_id.split('_');
        
        if (row_id != null) {
            fas_book_id = grid_obj.cells(row_id, 0).getValue();
        }
        
        var mode = (row_id != null) ? 'u' : 'i';
        
        var title_text = 'Sub Book Property';
        var param = 'sub.book.property.php?mode=' + mode +
                    '&sub_book_id=' + node_id_array[1] + 
                    '&fas_book_id=' + fas_book_id +
                    '&mode=' + mode + 
                    '&is_pop=true';

        if (!dhxWins) {
            dhxWins = new dhtmlXWindows();
        }

        pop_win = dhxWins.createWindow("pop_win", 0, 0, 490, 320);
        pop_win.setText(title_text);
        pop_win.attachURL(param, false, true);
        pop_win.attachEvent('onClose', function() {
            return true;
        });
    }
    /**
     *
     */
    refresh_source_book_mapping = function(){
        var is_win = dhxWins.isWindow('pop_win');
        node_id_array = entity_id.split('_');

        if (is_win == true) {
            pop_win.close();
        }
        
        
        var param = {
                    "action": "spa_sourcesystembookmap",
                    "flag": "m",
                    "fas_book_id": node_id_array[1],
                    "grid_type": "g"
                };
                
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;

        tabbar_detail.forEachTab(function(tab) {
            attached_obj = tab.getAttachedObject();
            attached_obj.forEachItem(function(cell) {
                grid_obj = cell.getAttachedObject();
                if (grid_obj instanceof dhtmlXGridObject) {
                    grid_obj.clearAndLoad(param_url);
                }
            });
        });
    }
    /**
     *
     */
    load_source_book_mapping = function(result){
        var json_obj = $.parseJSON(result);
        var json_data = {"total_count":json_obj.length, "pos":0, "data":json_obj};
                                  
        tabbar_detail.forEachTab(function(tab) {
            attached_obj = tab.getAttachedObject();
            attached_obj.forEachItem(function(cell) {
                grid_obj = cell.getAttachedObject();
                if (grid_obj instanceof dhtmlXGridObject) {                    
                    grid_obj.parse(json_data, "js");                    
                }
            });
        });
    }
     
    property_toolbar_click = function(id) {
        node_id_array = entity_id.split('_');
        
        switch(id) {
            case "save":
                var validation_status = true;
                
                if(node_id_array[0] == 'a') {
                    hierarchy_function_id = subsidiary_function_id;
                } else if(node_id_array[0] == 'b') {
                    hierarchy_function_id = strategy_function_id;
                } else if(node_id_array[0] == 'c') {
                    hierarchy_function_id = book_function_id;
                } else if(node_id_array[0] == 'd') {
                    hierarchy_function_id = book_mapping_function_id;
                }
                
                var grid_xml = '';
                var form_xml = '<Root function_id="' + hierarchy_function_id  + '"><FormXML ID="' + node_id_array[1] + '"';
                var tabsCount = tabbar_detail.getNumberOfTabs();
                var form_status = true;
                var first_err_tab;
                tabbar_detail.forEachTab(function(tab){

                    var tab_text = tab.getText();
                    if (tab_text == 'Program Affilation') {
                        layout_obj = tab.getAttachedObject();
                        tabbar_detail = program_affilation_layout.cells('a').getAttachedObject();
                        if (tabbar_detail instanceof dhtmlXForm) {
                            data = tabbar_detail.getFormData();
                            for (var a in data) {
                            field_label = a;
                            field_value = data[a];
                            if (!field_value)
                                field_value = '';
                                form_xml += " " + field_label + "=\" " + field_value + "\"";

                            }
                        }
                        grid_xml = "<GridGroup><Grid grid_id = \"program_affilation_grid\">";
                        for (var row_index=0; row_index < setup_book_structure["grd_inner_obj_" + active_object_id].getRowsNum(); row_index++) {
                            grid_xml = grid_xml + "<GridRow ";
                        for(var cellIndex = 0; cellIndex < setup_book_structure["grd_inner_obj_" + active_object_id].getColumnsNum(); cellIndex++){
                                grid_xml = grid_xml + " " + setup_book_structure["grd_inner_obj_" + active_object_id].getColumnId(cellIndex) + '="' + setup_book_structure["grd_inner_obj_" + active_object_id].cells2(row_index,cellIndex).getValue() + '"';
                        }
                        grid_xml += '></GridRow>'
                        }
                        grid_xml += '</Grid></GridGroup>'

                    } else {
                            layout_obj = tab.getAttachedObject();
                            layout_obj.forEachItem(function(cell) {
                                attached_obj = cell.getAttachedObject();
                                if (attached_obj instanceof dhtmlXForm) {
                                    var lbl = null;
                                    var sdv_data = null;
                                    var lbl_value = null;
                                    var entity_name = attached_obj.getItemValue('entity_name');
                                    data = attached_obj.getFormData();
                                     var status = validate_form(attached_obj);
                                      form_status = form_status && status; 
                                        if (tabsCount == 1 && !status) {
                                             first_err_tab = "";
                                        } else if ((!first_err_tab) && !status) {
                                            first_err_tab = tab;
                                        }
                                    
                                    if(status){
                                        for (var a in data) {
                                            field_label = a;
                                            field_value = data[a];
                                            var lbl = attached_obj.getItemLabel(a);
                                            var lbl_value = attached_obj.getItemValue(a);
    
                                            if(lbl == 'Name'){
                                                updated_label = lbl_value;
                                                var patt = /\S/
                                                var result = lbl_value.match(patt);
                                                if(lbl_value!==""){
                                                    if(!result){
                                                        validation_status = false;
                                                        attached_obj.setNote(field_label,{text:"Please enter the proper value"});
                                                        attached_obj.attachEvent("onchange",function(field_label, lbl_value){
                                                                attached_obj.setNote(field_label,{text:""});
                                                        });
                                                    }
                                                }
                                            }
    
                                            if(field_label == 'effective_start_date'){
                                                var effective_start_date_value = field_value;
                                            }
                                            if(field_label == 'end_date'){
                                                var end_date_value = field_value;
                                            }
    
                                            if (lbl== 'Tax Percentage' || lbl == 'Percentage Included') {
                                               // var patt = /^(0(\.\d+)?|1(\.0+)?)$/;                                                
                                                //var result = lbl_value.match(patt);
                                                if(lbl_value != ""){
                                                    if(lbl_value < 0 || lbl_value > 1){
                                                        validation_status = false;
                                                        attached_obj.setNote(field_label,{text:"Please input the valid " + lbl.toLowerCase() + "(0-1)."});
                                                        attached_obj.attachEvent("onchange",function(field_label, lbl_value){
                                                                attached_obj.setNote(field_label,{text:""});
                                                        });
                                                    }
                                                }
                                            }
    
                                            if (attached_obj.getItemType(a) == "calendar") {
                                                field_value = attached_obj.getItemValue(a, true);
                                            }
                                            if (attached_obj.getItemType(a) == "browser") {
                                                field_value = '';
                                            }
                                            
                                            if (a == 'entity_name' || a == 'logical_name') {
                                                updated_label = data[a];
                                            }
                                            
                                            if (!field_value)
                                                field_value = '';
                                                form_xml += " " + field_label + "=\"" + field_value + "\"";
                                        } 
                                    } else {
                                            validation_status = false;
                                    }
    
                                    if((effective_start_date_value !== null) && (end_date_value !== null) && (effective_start_date_value > end_date_value)){
                                        validation_status = false;
                                        show_messagebox('End Date should not be less than Effective date.');
                                    }
    
                                }
                            });
                        }
                });

                if (!form_status) {
                    generate_error_message(first_err_tab);
                }

                form_xml += "></FormXML></Root>";
                
                if (validation_status == true) {
                    if (node_id_array[0] == 'd' ) {
                        data = {"action": "spa_sub_book_xml", "xml": form_xml, "flag":"u", 'function_id': book_mapping_function_id};
                        result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
                    } else if (node_id_array[0] == 'b') {
                        data = {"action": "spa_BookStrategyXml","flag": 'u', "xml": form_xml};
                        result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
                    } else if (node_id_array[0] == 'c') {
                        data = {"action": "spa_UpdateBookOptionXml","flag": 'u', "xml": form_xml};
                        result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
                    } else if (node_id_array[0] == 'a') {
                        data = {"action": "spa_BookSubsidiaryXml","flag": 'u', "xml": form_xml};
                        result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
                    } else if (node_id_array[0] == 'x') {
                        data = {"action": "spa_BookSubsidiaryXml","flag": 'u', "xml": form_xml};
                        result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
                    }
                } else {
                    return;
                }
                break;
            default:
                break;
        }
    }
    
    function refresh_bookstructure(result) {
        if (result[0].errorcode == 'Success') {
            parent.update_tree_node_text(entity_id, updated_label);    
        }
    }
    
    function on_change_accounting_type(combo_option) {
        if (combo_option == 151) { // Fair-value Hedges
            tabbar_detail.forEachTab(function(tab){
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        attached_obj.disableItem('mismatch_tenor_value_id');
                        attached_obj.disableItem('mes_cfv_value_id');  
                        attached_obj.disableItem('oci_rollout_approach_value_id');
                        attached_obj.disableItem('rollout_per_type');

                        attached_obj.enableItem('mes_gran_value_id');//Measurement Granularity
                        attached_obj.enableItem('gl_grouping_value_id');
                        attached_obj.enableItem('strip_trans_value_id');
                        attached_obj.enableItem('mes_cfv_values_value_id');
                        attached_obj.enableItem('test_range_from');
                        attached_obj.enableItem('additional_test_range_from');
                        attached_obj.enableItem('test_range_to');
                        attached_obj.enableItem('additional_test_range_to');
                        attached_obj.enableItem('test_range_from2');
                        attached_obj.enableItem('test_range_to2');
                        attached_obj.enableItem('include_unlinked_hedges');
                        attached_obj.enableItem('include_unlinked_items');
                        attached_obj.enableItem('fx_hedge_flag');
                    }   
                })
            }) 
            
        } else if (combo_option == 152) {//'MTM (Fair Value)'
            tabbar_detail.forEachTab(function(tab){
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        attached_obj.enableItem('gl_grouping_value_id');
                        attached_obj.disableItem('mes_gran_value_id');
                        attached_obj.disableItem('mismatch_tenor_value_id');
                        attached_obj.disableItem('rollout_per_type');
                        attached_obj.disableItem('mes_cfv_value_id');
                        attached_obj.disableItem('strip_trans_value_id');
                        attached_obj.disableItem('mes_cfv_values_value_id');
                        attached_obj.disableItem('oci_rollout_approach_value_id');
                        attached_obj.disableItem('test_range_from');
                        attached_obj.disableItem('additional_test_range_from');
                        attached_obj.disableItem('test_range_to');
                        attached_obj.disableItem('additional_test_range_to');
                        attached_obj.disableItem('test_range_from2');
                        attached_obj.disableItem('test_range_to2');
                        attached_obj.disableItem('include_unlinked_hedges');
                        attached_obj.disableItem('include_unlinked_items');
                        attached_obj.disableItem('fx_hedge_flag');
                    }   
                })
            })           
        } else if (combo_option == 155 || combo_option == 154) { //Accrual Accounting OR Inventory Accounting
            tabbar_detail.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {        
                        attached_obj.disableItem('mes_gran_value_id');//Measurement Granularity

                        attached_obj.enableItem('mismatch_tenor_value_id');
                        var rolling_hedge_forward = attached_obj.getCombo('mismatch_tenor_value_id');
                        
                        if (rolling_hedge_forward != null) {
                            attached_obj.attachEvent('onOptionsLoaded', function(name) {
                                if (name == 'mismatch_tenor_value_id') {
                                    var combo_option = rolling_hedge_forward.getSelectedValue();
                            
                                    if (combo_option == 252) {//Apply Hedge/Item Term Mismatch
                                        attached_obj.enableItem('rollout_per_type');
                                    } else {
                                        attached_obj.disableItem('rollout_per_type');
                                    }  
                                }
                            })      

                            var combo_option = rolling_hedge_forward.getSelectedValue();
                
                            if (combo_option == 252) {//Apply Hedge/Item Term Mismatch
                                attached_obj.enableItem('rollout_per_type');
                            } else {
                                attached_obj.disableItem('rollout_per_type');
                            }       
                        }

                        attached_obj.enableItem('gl_grouping_value_id');
                        attached_obj.enableItem('mes_cfv_value_id');
                        attached_obj.enableItem('strip_trans_value_id');
                        attached_obj.enableItem('mes_cfv_values_value_id');
                        attached_obj.enableItem('oci_rollout_approach_value_id');
                        attached_obj.enableItem('test_range_from');
                        attached_obj.enableItem('additional_test_range_from');
                        attached_obj.enableItem('test_range_to');
                        attached_obj.enableItem('additional_test_range_to');
                        attached_obj.enableItem('test_range_from2');
                        attached_obj.enableItem('test_range_to2');
                        attached_obj.enableItem('include_unlinked_hedges');
                        attached_obj.enableItem('include_unlinked_items');
                        attached_obj.enableItem('fx_hedge_flag');
                    }
                });
            });
        } else if (combo_option == 153) { //Normal Purchase/Sales (Out of Scope)
            tabbar_detail.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {  
                        attached_obj.enableItem('fx_hedge_flag');

                        attached_obj.disableItem('mes_gran_value_id');
                        attached_obj.disableItem('gl_grouping_value_id');
                        attached_obj.disableItem('mismatch_tenor_value_id');
                        attached_obj.disableItem('rollout_per_type');
                        attached_obj.disableItem('mes_cfv_value_id');
                        attached_obj.disableItem('strip_trans_value_id');
                        attached_obj.disableItem('mes_cfv_values_value_id');
                        attached_obj.disableItem('oci_rollout_approach_value_id');
                        attached_obj.disableItem('test_range_from');
                        attached_obj.disableItem('additional_test_range_from');
                        attached_obj.disableItem('test_range_to');
                        attached_obj.disableItem('additional_test_range_to');
                        attached_obj.disableItem('test_range_from2');
                        attached_obj.disableItem('test_range_to2');
                        attached_obj.disableItem('test_range_to2');
                        attached_obj.disableItem('include_unlinked_hedges');
                        attached_obj.disableItem('include_unlinked_items'); 
                    }
                });
            });
        } else {
            tabbar_detail.forEachTab(function(tab){
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        attached_obj.enableItem('mismatch_tenor_value_id');
                        var rolling_hedge_forward = attached_obj.getCombo('mismatch_tenor_value_id');
                        
                        if (rolling_hedge_forward != null) {
                            attached_obj.attachEvent('onOptionsLoaded', function(name) {
                                if (name == 'mismatch_tenor_value_id') {
                                    var combo_option = rolling_hedge_forward.getSelectedValue();
                            
                            if (combo_option == 252) {//Apply Hedge/Item Term Mismatch
                                attached_obj.enableItem('rollout_per_type');
                            } else {
                                attached_obj.disableItem('rollout_per_type');
                            }      
                        }
                            })                                

                            var combo_option = rolling_hedge_forward.getSelectedValue();
                
                            if (combo_option == 252) {//Apply Hedge/Item Term Mismatch
                                attached_obj.enableItem('rollout_per_type');
                            } else {
                                attached_obj.disableItem('rollout_per_type');
                            }                                  
                        }
                        
                        attached_obj.enableItem('gl_grouping_value_id');
                        attached_obj.enableItem('mes_gran_value_id');
                        attached_obj.enableItem('mes_cfv_value_id');
                        attached_obj.enableItem('strip_trans_value_id');
                        attached_obj.enableItem('mes_cfv_values_value_id');
                        attached_obj.enableItem('oci_rollout_approach_value_id');
                        attached_obj.enableItem('test_range_from');
                        attached_obj.enableItem('additional_test_range_from');
                        attached_obj.enableItem('test_range_to');
                        attached_obj.enableItem('additional_test_range_to');
                        attached_obj.enableItem('test_range_from2');
                        attached_obj.enableItem('test_range_to2');
                        attached_obj.enableItem('include_unlinked_hedges');
                        attached_obj.enableItem('include_unlinked_items');
                        attached_obj.enableItem('fx_hedge_flag');
                    }   
                })
            })    
            
        }
    }
    
    function enable_disable_gl_code_objects(enable_combos) {
        if (enable_combos == true) {
            tabbar_detail.forEachTab(function(tab){
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                    
                    if (attached_obj instanceof dhtmlXForm) {
                        attached_obj.enableItem('gl_number_id_st_asset');
                        attached_obj.enableItem('gl_number_id_lt_asset');  
                        attached_obj.enableItem('gl_number_id_lt_liab');
                        attached_obj.enableItem('gl_number_id_st_liab');
                        attached_obj.enableItem('gl_id_st_tax_asset');
                        attached_obj.enableItem('gl_id_lt_tax_asset');
                        attached_obj.enableItem('gl_id_st_tax_liab');
                        attached_obj.enableItem('gl_id_lt_tax_liab');
                        attached_obj.enableItem('gl_id_tax_reserve');
                        attached_obj.enableItem('gl_number_id_aoci');
                        attached_obj.enableItem('gl_number_id_inventory');
                        attached_obj.enableItem('gl_number_id_pnl');
                        attached_obj.enableItem('gl_number_id_set');
                        attached_obj.enableItem('gl_number_id_cash');
                        attached_obj.enableItem('gl_number_id_gross_set');
                        attached_obj.enableItem('gl_number_id_item_st_asset');
                        attached_obj.enableItem('gl_number_id_item_st_liab');
                        attached_obj.enableItem('gl_number_id_item_lt_asset');
                        attached_obj.enableItem('gl_number_id_item_lt_liab');
                        attached_obj.enableItem('gl_number_unhedged_der_st_asset');
                        attached_obj.enableItem('gl_number_unhedged_der_lt_asset');
                        attached_obj.enableItem('gl_number_unhedged_der_st_liab');
                        attached_obj.enableItem('gl_number_unhedged_der_lt_liab');
                        attached_obj.enableItem('gl_id_amortization');
                        attached_obj.enableItem('gl_id_interest');
                        attached_obj.enableItem('gl_number_id_expense');
                    }   
                })
            })                                 
                                               
        } else {
            tabbar_detail.forEachTab(function(tab){
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                    
                    if (attached_obj instanceof dhtmlXForm) {
                        attached_obj.disableItem('gl_number_id_st_asset')
                        attached_obj.disableItem('gl_number_id_lt_asset');  
                        attached_obj.disableItem('gl_number_id_lt_liab');
                        attached_obj.disableItem('gl_number_id_st_liab');
                        attached_obj.disableItem('gl_id_st_tax_asset');
                        attached_obj.disableItem('gl_id_lt_tax_asset');
                        attached_obj.disableItem('gl_id_st_tax_liab');
                        attached_obj.disableItem('gl_id_lt_tax_liab');
                        attached_obj.disableItem('gl_id_tax_reserve');
                        attached_obj.disableItem('gl_number_id_aoci');
                        attached_obj.disableItem('gl_number_id_inventory');
                        attached_obj.disableItem('gl_number_id_pnl');
                        attached_obj.disableItem('gl_number_id_set');
                        attached_obj.disableItem('gl_number_id_cash');
                        attached_obj.disableItem('gl_number_id_gross_set');
                        attached_obj.disableItem('gl_number_id_item_st_asset');
                        attached_obj.disableItem('gl_number_id_item_st_liab');
                        attached_obj.disableItem('gl_number_id_item_lt_asset');
                        attached_obj.disableItem('gl_number_id_item_lt_liab');
                        attached_obj.disableItem('gl_number_unhedged_der_st_asset');
                        attached_obj.disableItem('gl_number_unhedged_der_lt_asset');
                        attached_obj.disableItem('gl_number_unhedged_der_st_liab');
                        attached_obj.disableItem('gl_number_unhedged_der_lt_liab');
                        attached_obj.disableItem('gl_id_amortization');
                        attached_obj.disableItem('gl_id_interest');
                        attached_obj.disableItem('gl_number_id_expense');
                    }   
                })
            }) 
        }
    }
    
    function show_hide_gl_code_objects(combo_option) {
        var array_cash_flow_show = [  'gl_number_id_st_asset'
                                    ,'gl_number_id_lt_asset'
                                    ,'gl_number_id_st_liab'
                                    ,'gl_number_id_lt_liab'
                                    ,'gl_number_unhedged_der_st_asset'
                                    ,'gl_number_unhedged_der_lt_asset'
                                    ,'gl_number_unhedged_der_st_liab'
                                    ,'gl_number_unhedged_der_lt_liab'
                                    ,'gl_id_st_tax_asset'
                                    ,'gl_id_lt_tax_asset'
                                    ,'gl_id_st_tax_liab'
                                    ,'gl_id_lt_tax_liab'
                                    ,'gl_id_tax_reserve'
                                    ,'gl_number_id_aoci'
                                    ,'gl_number_id_inventory'
                                    ,'gl_number_id_pnl'
                                    ,'gl_number_id_set'
                                    ,'gl_number_id_cash'
                                    ,'gl_number_id_gross_set'
                                    ,'gl_number_id_item_st_asset'
                                    ,'gl_number_id_item_st_liab'
                                    ,'gl_number_id_item_lt_asset'
                                    ,'gl_number_id_item_lt_liab'
                                   ];
        var array_cash_flow_hide = [ 'gl_id_amortization'
                                     ,'gl_number_id_expense'
                                     ,'gl_id_interest'  
                                    ];
        var array_fair_value_hedges_hide = [ 'gl_number_id_inventory'
                                            ,'gl_id_st_tax_asset'
                                            ,'gl_id_lt_tax_asset'
                                            ,'gl_id_st_tax_liab'
                                            ,'gl_id_lt_tax_liab'
                                            ,'gl_id_tax_reserve'
                                            ,'gl_number_id_aoci'
                                            ,'gl_number_unhedged_der_st_asset'
                                            ,'gl_number_unhedged_der_lt_asset'
                                            ,'gl_number_unhedged_der_st_liab'
                                            ,'gl_number_unhedged_der_lt_liab'
                                            ];
       var array_fair_value_hedges_show = [ 
                                            'gl_number_id_st_asset'
                                            ,'gl_number_id_lt_asset'
                                            ,'gl_number_id_st_liab'
                                            ,'gl_number_id_lt_liab'
                                            ,'gl_number_id_item_st_asset'
                                            ,'gl_number_id_item_st_liab'
                                            ,'gl_number_id_item_lt_asset'
                                            ,'gl_number_id_item_lt_liab'
                                            ,'gl_id_amortization'
                                            ,'gl_number_id_expense'
                                            ,'gl_id_interest' 
                                            ,'gl_number_id_pnl'
                                            ,'gl_number_id_set'
                                            ,'gl_number_id_cash'
                                            ,'gl_number_id_gross_set'
                                            ]
        var array_mtm_fair_value_hide = [ 'gl_number_id_item_st_asset'
                                        ,'gl_number_id_item_st_liab'
                                        ,'gl_number_id_item_lt_asset'
                                        ,'gl_number_id_item_lt_liab'
                                        ,'gl_id_amortization'
                                        ,'gl_id_interest'
                                        ,'gl_number_id_expense'
                                        ,'gl_id_st_tax_asset'
                                        ,'gl_id_lt_tax_asset'
                                        ,'gl_id_st_tax_liab'
                                        ,'gl_id_lt_tax_liab'
                                        ,'gl_id_tax_reserve'
                                        ,'gl_number_id_aoci'
                                        ,'gl_number_id_inventory'    
                                        ,'gl_number_unhedged_der_st_asset'
                                        ,'gl_number_unhedged_der_lt_asset'
                                        ,'gl_number_unhedged_der_st_liab'
                                        ,'gl_number_unhedged_der_lt_liab'
                                        ];

         if (combo_option == 150) {// 'Cash-flow Hedges'
            tabbar_detail.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    
                    if (attached_obj instanceof dhtmlXForm) {
                        for (i = 0; i < array_cash_flow_show.length; i++) {
                           attached_obj.showItem(array_cash_flow_show[i]);
                        }
                        
                        for (i = 0; i < array_cash_flow_hide.length; i++) {
                           attached_obj.hideItem(array_cash_flow_hide[i]);
                        }
                        
                        attached_obj.setItemLabel('gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness CR</a>');
                        attached_obj.setItemLabel('gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness DR</a>');
                        attached_obj.setItemLabel('gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness DR</a>');
                        attached_obj.setItemLabel('gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness CR</a>');
                        
                        attached_obj.setItemLabel('gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Asset</a>');
                        attached_obj.setItemLabel('gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Asset</a>');
                        attached_obj.setItemLabel('gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Liability</a>');
                        attached_obj.setItemLabel('gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Liability</a>');
     
                    }   
                })
            })         
            
        } else if (combo_option == 151) {// 'Fair-value Hedges'
            tabbar_detail.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    
                    if (attached_obj instanceof dhtmlXForm) {
                        for (i = 0; i < array_fair_value_hedges_hide.length; i++) {
                            attached_obj.hideItem(array_fair_value_hedges_hide[i]);
                        }
                        
                        for (i = 0; i < array_fair_value_hedges_show.length; i++) {
                            attached_obj.showItem(array_fair_value_hedges_show[i]);
                        }
                        
                       attached_obj.setItemLabel('gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item ST Liability</a>');
                        attached_obj.setItemLabel('gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item ST Asset</a>');
                        attached_obj.setItemLabel('gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item LT Asset</a>');
                        attached_obj.setItemLabel('gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item Liability</a>');
                        
                    }   
                })
            })      
            
        } else if (combo_option == 152) { // MTM (Fair Value)
            tabbar_detail.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    
                    if (attached_obj instanceof dhtmlXForm) {
                        for (i = 0; i < array_cash_flow_show.length; i++) {
                            attached_obj.showItem(array_cash_flow_show[i]);
                        }
                                    
                        for (i = 0; i < array_mtm_fair_value_hide.length; i++) {
                            attached_obj.hideItem(array_mtm_fair_value_hide[i]);
                        }
                        
                          attached_obj.setItemLabel('gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM ST Asset</a>');
                        attached_obj.setItemLabel('gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM LT Asset</a>');
                        attached_obj.setItemLabel('gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM ST Liability</a>');
                        attached_obj.setItemLabel('gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM LT Liability</a>');
                    }   
                })
            })            
        } else if (combo_option == 153) {// 'Normal Purchase/Sales (Out of Scope)'
            tabbar_detail.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    
                    if (attached_obj instanceof dhtmlXForm) {
                        for (i = 0; i < array_cash_flow_show.length; i++) {
                            attached_obj.hideItem(array_cash_flow_show[i]);
                        } 
                                    
                        for (i = 0; i < array_cash_flow_hide.length; i++) {
                            attached_obj.hideItem(array_cash_flow_hide[i]);
                        }                       
                    }   
                })
            })   
        } else {
            tabbar_detail.forEachTab(function(tab){
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    
                    if (attached_obj instanceof dhtmlXForm) {
                        for (i = 0; i < array_cash_flow_show.length; i++) {
                            attached_obj.showItem(array_cash_flow_show[i]);
                        }  
                                    
                        for (i = 0; i < array_cash_flow_hide.length; i++) {
                            attached_obj.showItem(array_cash_flow_hide[i]);
                        } 
                         
                         attached_obj.setItemLabel('gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness CR</a>');
                        attached_obj.setItemLabel('gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness DR</a>');
                        attached_obj.setItemLabel('gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness DR</a>');
                        attached_obj.setItemLabel('gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness CR</a>');
                        
                        attached_obj.setItemLabel('gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Asset</a>');
                        attached_obj.setItemLabel('gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Asset</a>');
                        attached_obj.setItemLabel('gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Liability</a>');
                        attached_obj.setItemLabel('gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Liability</a>');
                                          
                    }                       
                     
                })
            }) 
        }
    }   
                               
</script>
</html>