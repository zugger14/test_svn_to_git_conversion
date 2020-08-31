<?php 
	/** 
	 *  Generic file to generate the script to prepare the forms. Script is generated according to the definition defiend in application_ui.. tables
	 *  @copyright Pioneer Solutions.
	 */

	include 'components/include.file.v3.php';

	if (isset($_POST["function_id"]) && !empty($_POST["function_id"])) {
		$function_id = $_POST["function_id"];
	} else {
		die('Authorization failed.');
	}

	$template_name = (isset($_POST["template_name"]) && !empty($_POST["template_name"])) ? $_POST["template_name"] : '';
	$primary_field = (isset($_POST["primary_field"]) && !empty($_POST["primary_field"])) ? $_POST["primary_field"] : '';
	$object_id_with_dot = (isset($_POST["object_id"]) && !empty($_POST["object_id"])) ? $_POST["object_id"] : 0;
	$parent_object = (isset($_POST["parent_object"]) && !empty($_POST["parent_object"])) ? $_POST["parent_object"] : '';
	$menu_json_array = (isset($_POST["menu_json_array"])) ? $_POST["menu_json_array"] : array();
    $hide_originals = (isset($_POST["hide_originals"])) ? (($_POST["hide_originals"] == "true") ? true : false) : false;
    $enable_pivot = (isset($_POST["enable_pivot"])) ? (($_POST["enable_pivot"] == "true") ? true : false) : false;
    $type_id = (isset($_POST["type_id"])) ? $_POST["type_id"] : '';
    $privilege_active = (isset($_POST["privilege_active"])) ? $_POST["privilege_active"] : 0;

    $grid_counter = 0;

	//to create a object name 
	//do not remove dot (.) to pass in db as login name can contain dots.
	$object_id_with_dot = preg_replace('/[^a-zA-Z0-9_.-]/', '', $object_id_with_dot);
	//but dot(.) gives issues in creating new tab, so remove it for further processing
	$object_id = preg_replace('/[.-]/', '', $object_id_with_dot);

	$array_object_id = (is_numeric($object_id_with_dot)) ? $object_id : ord($object_id_with_dot);
	$xml_obj = '<Root><PSRecordset ' . $primary_field . '="' . $object_id_with_dot . '"></PSRecordset></Root>';
	$form_sp = "EXEC spa_create_application_ui_json 'j', '" . $function_id . "', '" . $template_name . "', '" . $xml_obj . "'";

	$form_data = readXMLURL2($form_sp);
	$return_string = '';
    
    /*
    *   Check Data Level Privilege and Disable save button 
    *   If privilege is active and no privilege is assigned
    */
    if ($privilege_active == 1) {
        $data_privilege_sp = "EXEC spa_static_data_privilege @flag = 'c', @type_id = '$type_id', @value_id = '$object_id_with_dot'";
        $data_privilege = readXMLURL2($data_privilege_sp);
        $privilege_status = $data_privilege[0]['privilege_status'];
        
        if ($privilege_status == 'false') {
            $return_string .= ' var toolbar = win.getAttachedToolbar();' ."\n";
            $return_string .= ' toolbar.disableItem("save");' . "\n";
        }
    }
    
	if (is_array($form_data) && sizeof($form_data) > 0) {
		$return_string .= 'win = ' . $parent_object . ";\n";
		$return_string .= 'tabbar_' . $object_id . ' = win.tabbar[' . $array_object_id  . '] = win.attachTabbar({mode:"bottom",arrows_mode:"auto"});' . "\n";

		$flattened_form_data = array();
		$tab_data = array();

		foreach ($form_data as $data) {
			if (!array_key_exists($data['tab_id'], $flattened_form_data))
                $flattened_form_data[$data['tab_id']] = array();

            $tab_id = 'detail_tab_' . $data['tab_id'];
			array_push($flattened_form_data[$data['tab_id']], array($tab_id, $data['tab_id'], $data['layout_pattern'], $data['form_json'], $data['grid_json'], $data['seq'], $data['dependent_combo']));
			array_push($tab_data, $data['tab_json']);
		}

		$combined_tab_data = '{tabs: [' . implode(",", $tab_data) . ']};';

		$return_string .= 'tabbar_data = ' . $combined_tab_data . "\n";
		$return_string .= 'tabbar_' . $object_id . '.loadStruct(tabbar_data);' . "\n";

		foreach ($flattened_form_data as $key => $value) {
			$layout_namespace = $value[0][0] .  '_' . $object_id;
			$return_string .= $layout_namespace . '= {};' . "\n";
			$return_string .= $layout_namespace . '.details_layout = tabbar_' . $object_id . '.cells("' . $value[0][0] . '").attachLayout("' . $value[0][2] . '");' . "\n";

			$grid_json = array();
			$pre = strpos($value[0][4], '[');
			if ($pre === false) {
				$value[0][4] = '[' .  $value[0][4] . ']';
			}

			$grid_json = json_decode($value[0][4], true); 
			$grid_json[0]['layout_pattern'] = $value[0][2];

			foreach($grid_json as $obj) {
				if ($obj['grid_id'] == '' || $obj['grid_id'] == null) { continue; }
				// if form
				if ($obj['grid_id'] == 'FORM') {
					$return_string .= $layout_namespace . '.details_layout.cells("' . $obj['layout_cell'] . '").hideHeader();';
					if (array_key_exists('layout_cell_height', $obj)) {
						$return_string .= $layout_namespace . '.details_layout.cells("' . $obj['layout_cell'] . '").setHeight("' . $obj['layout_cell_height'] . '");';
					}					
					$return_string .= '	details_form_' . $object_id . '_' . $key . ' = ' . $layout_namespace. '.details_layout.cells("' . $obj['layout_cell'] . '").attachForm();' . "\n";

					$dependent_string = '';
					if ($value[0][6] != NULL && $value[0][6] != '') {
						$dependent_combo_array = array();
						$dependent_combo_array = explode(',', $value[0][6]);
						if (sizeof($dependent_combo_array) > 0) {
                            $dependent_string = ' load_dependent_combo("' . $value[0][6] .'", 0, details_form_' . $object_id . '_'  . $key.'); ';
                        }

					}

					$return_string .= '	details_form_' . $object_id . '_'  . $key . '.loadStruct(' . $value[0][3] . ', function() {'.
						$dependent_string
					.'});' . "\n";
						        

					//$return_string .= '	details_form_' . $key . '.attachEvent("onXLE", function(){alert(77777);});' . "\n";


					$return_string .= ' var form_name = "details_form_' . $object_id . '_'  . $key . '";';
                    $return_string .= ' var single_selected_fields = "";';
					$return_string .= ' var form_data =  details_form_' . $object_id . '_'  . $key . '.getFormData();';
					$return_string .= ' for(var a in form_data){';
					$return_string .= ' var type =  details_form_' . $object_id . '_'  . $key . '.getItemType(a);';
					$return_string .= ' if(type == "input"){';
					$return_string .= ' single_select = details_form_' . $object_id . '_'  . $key . '.getUserData(a,"enable_single_select");';
					$return_string .= ' if(single_select == 1){';
					$return_string .= ' single_selected_fields += "," + a; ';
					$return_string .= ' } ';
					$return_string .= ' } ';
					$return_string .= ' } ';
					$return_string .= ' var single_selected_fields = single_selected_fields.substring(1);' ;
					

                    $return_string .= ' attach_browse_event(form_name, ' . $function_id . ' , "","","single_selected_fields="+single_selected_fields);';

					
				} else {
					//if Grid					
					$paging_div = 'detail_' . $obj['layout_cell'] .'_' . $key .'_' . $object_id;
					$return_string .= $layout_namespace . ".details_layout.cells('" . $obj['layout_cell'] . "').attachStatusBar({
                                height: 30,
                                text: '<div id=\'" . $paging_div . "\'></div>'
                            });";
					
					$return_string .= $layout_namespace . '.details_layout.cells("' . $obj['layout_cell'] . '").setText(get_locale_value("' . $obj['grid_label'] . '"));';

					if (($obj['layout_pattern'] ?? '') != '1C') {
						// Undocking logic
						$return_string .= $layout_namespace . '.details_layout.cells("' . $obj['layout_cell'] . '").showUndockArrow();';
					}
					
					$grid_obj = 'grid_' . $key;
					$menu_obj = 'menu_' . $key;
					$return_string .= $obj['grid_id'] .  '_' . $object_id . '= {};';
					$grid_obj_withnamespace = $obj['grid_id'] .  '_' . $object_id . '.' . $grid_obj;
					$menu_obj_withnamespace = $obj['grid_id'] .  '_' . $object_id . '.' . $menu_obj;
					
					// // grid menu definition
					$return_string .= $menu_obj_withnamespace . '= ' . $layout_namespace. '.details_layout.cells("' . $obj['layout_cell'] . '").attachMenu({
							icons_path: "'. $image_path . 'dhxmenu_web/",' . "\n";
					if ($hide_originals) {
					   $return_string .= '		json:[' . "\n";
					} else {
                        $return_string .= '		json:[
                                {id:"t1", text:"Edit", img:"edit.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                                ]},
                                {id:"t2", text:"Export", img:"export.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                ]}' . "\n";
                        
                        if ($enable_pivot) {
                             $return_string .= ',{id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif", title: "Pivot"}';
                        }
                    }
                    
                    if (sizeof($menu_json_array) > 0) {
	                    if ($menu_json_array[$grid_counter]['json'] != '' && $menu_json_array[$grid_counter]['json'] != null) {
	                    	if (!$hide_originals) {
	                    	      $return_string .= ','  . "\n";
                            }
                            $return_string .= $menu_json_array[$grid_counter]['json'] . "\n";
	                    }
                    }

		            $return_string .= ' ]' . "\n";
					$return_string .= '});' . "\n";
					
                   
					// menu click function		
					$return_string .= $menu_obj_withnamespace . '.attachEvent("onClick", function(id) {' . "\n";    				 	
                    $return_string .= '		switch(id) {' . "\n";
    				if (!$hide_originals) {
                        $return_string .= '			case "add":' . "\n";
    					$return_string .= '				var newId = (new Date()).valueOf();' . "\n";
    					$return_string .= 				$grid_obj_withnamespace . '.addRow(newId,"");' . "\n";
    					$return_string .= 				$grid_obj_withnamespace . '.selectRowById(newId);' . "\n";
						$return_string .= 				$grid_obj_withnamespace . '.forEachRow(function(row){'. "\n";	
						$return_string .= 					$grid_obj_withnamespace . '.forEachCell(row,function(cellObj,ind){'. "\n";	
						$return_string .= 						$grid_obj_withnamespace . '.validateCell(row,ind)'. "\n";	
						$return_string .= '					});'. "\n";	
						$return_string .= '				});'. "\n";	
                        $return_string .= 				$menu_obj_withnamespace.'.setItemDisabled("delete");' . "\n";    
                        $return_string .= '             break;'. "\n";
            			$return_string .= '        	case "delete":'. "\n";
            			$return_string .= '				var del_ids = ' . $grid_obj_withnamespace . '.getSelectedRowId();';
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
                        
                        // Grid Pivot
                        $return_string .= '        case "pivot":'. "\n";
                        $return_string .= '             var grid_name = "' . $obj['grid_id'] .   '";' . "\n";
                        $return_string .= '             var grid_obj = ' . $grid_obj_withnamespace .   ';' . "\n";
                        $return_string .= '             var primary_key = ' . $object_id_with_dot .   ';' . "\n";
                        $return_string .= '             open_grid_pivot(grid_obj, grid_name, -1,"","", primary_key);' . "\n";
                        $return_string .= '             break;'. "\n";
                    }
					if (sizeof($menu_json_array) > 0) {
						if ($menu_json_array[$grid_counter]['on_click'] != '' && $menu_json_array[$grid_counter]['on_click'] != null) {
							$return_string .= '        	default:'. "\n";
							$return_string .= '				var selected_ids = ' . $grid_obj_withnamespace . '.getSelectedRowId();';
							$return_string .= 				$menu_json_array[$grid_counter]['on_click'] . '(id, ' . $grid_obj_withnamespace . ', selected_ids,'.$menu_obj_withnamespace.');' . "\n";
							$return_string .= '             break;'. "\n";
						}
					}

					$return_string .= '		}' . "\n";
					$return_string .= '});' . "\n";
                    

					$return_string .= $grid_obj_withnamespace . '= ' . $layout_namespace. '.details_layout.cells("' . $obj['layout_cell'] . '").attachGrid();';
	
					// create grid using definition in adiha_grid_definition
					$$grid_obj = new GridTable($obj['grid_id']);
    				$return_string .= $$grid_obj->init_grid_table($grid_obj, $obj['grid_id'] .  '_' . $object_id);
    				$return_string .= $$grid_obj->enable_multi_select();
                    $return_string .= $$grid_obj->set_search_filter(true, ""); //for inline filter.
    				$return_string .= $$grid_obj->enable_paging(100, $paging_div, 'true');
    				$return_string .= $$grid_obj->submit_added_rows();
    				$return_string .= $$grid_obj->set_user_data("", "grid_id", $obj['grid_id']);
    				$return_string .= $$grid_obj->set_user_data("", "grid_obj", $obj['grid_id'] .  '_' . $object_id);
					$return_string .= $$grid_obj->set_user_data("", "grid_label", $obj['grid_label']);
    				$return_string .= $$grid_obj->return_init();
    				$return_string .= $$grid_obj->load_grid_data('', $object_id_with_dot,false,'',$farrms_product_id);
    				$return_string .= $$grid_obj->load_grid_functions('', $object_id_with_dot);
                    
                    $return_string .= $grid_obj_withnamespace.'.attachEvent("onRowDblClicked", function(id,ind){';
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
                    
                    if (!$hide_originals) {
        				$permission_array = array();
        				$permission_array = $$grid_obj->return_permission();
        				if (!$permission_array['edit']) {
        					$return_string .= $menu_obj_withnamespace . '.setItemDisabled("add");';
                                                $return_string .= $$grid_obj->disable_grid();
        				}
        				/*
						if (!$permission_array[delete]) {
        					$return_string .= $menu_obj_withnamespace . '.setItemDisabled("delete");';
        				}
						*/
						if ($permission_array['delete']) {
							$return_string .= $grid_obj_withnamespace.'.attachEvent("onRowSelect", function(id,ind){';
							$return_string .= 				$menu_obj_withnamespace.'.setItemEnabled("delete");';
							$return_string .= ' 	});';
						}			

                    }
                        
                    if (sizeof($menu_json_array) > 0) {
	                    if ($menu_json_array[$grid_counter]['on_select'] != '' && $menu_json_array[$grid_counter]['on_select'] != null) {
	                    	
                            $menu_onselect_json_array = explode(",", $menu_json_array[$grid_counter]['on_select']);
                            
                            $return_string .= $grid_obj_withnamespace.'.attachEvent("onRowSelect", function(id,ind){';
                            for($i = 0; $i < sizeof($menu_onselect_json_array); $i++) {
                                $menu_onselect_single_json_array = explode("|", $menu_onselect_json_array[$i]);
                                if ($menu_onselect_single_json_array[1] == 'true') {
                                    $return_string .= $menu_obj_withnamespace.'.setItemDisabled("' . $menu_onselect_single_json_array[0] . '");';
                                } else {
                                    $return_string .= $menu_obj_withnamespace.'.setItemEnabled("' . $menu_onselect_single_json_array[0] . '");';
                                }
                            }
                            $return_string .= ' 	});';
	                    }
                    }
                        
    				$grid_counter++;
				}	
			}
		}
	}
?>

<script type="text/javascript" class="form_script">
	<?php 
	echo $return_string;
	?>
</script>