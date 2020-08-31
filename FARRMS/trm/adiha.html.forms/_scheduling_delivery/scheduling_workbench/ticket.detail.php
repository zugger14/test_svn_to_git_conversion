<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php');
            require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
        ?>

    </head>
<?php
    $form_name = 'form_ticket';
    $form_namespace = 'ticket';
    $ticket_function_id = '10166612';
    $grid_counter = 0;

/*    $rights_ticket_UI = 10166610;
    $rights_ticket_delete = 10166611;
    $rights_document = 10102900;

    list (
        $has_rights_ticket_UI,
        $has_rights_ticket_delete,
        $has_rights_document
    ) = build_security_rights (
        $rights_ticket_UI,
        $rights_ticket_delete,
        $rights_document
    );

    $has_rights_ticket_UI = ($has_rights_ticket_UI != 1) ? "false" : "true";
    $has_rights_ticket_delete = ($has_rights_ticket_delete != 1) ? "false" : "true";
    $has_rights_document = ($has_rights_document != 1) ? "false" : "true";
   */
    $ticket_id = (isset($_GET['ticket_id'])) ? trim($_GET['ticket_id']) : '';
    $ticket_detail_id = (isset($_GET['ticket_detail_id'])) ? trim($_GET['ticket_detail_id']) : '';
    $mode = ($ticket_detail_id == '') ? 'i' : 'u';
    $schedule_match_id = (isset($_GET['schedule_match_id'])) ? trim($_GET['schedule_match_id']) : '';
    $is_matched = (isset($_GET['is_matched'])) ? trim($_GET['is_matched']) : '';
    $ticket_location = (isset($_GET['location'])) ? trim($_GET['location']) : '';
    $commodity = (isset($_GET['commodity'])) ? trim($_GET['commodity']) : '';
    $volume_uom = (isset($_GET['volume_uom'])) ? trim($_GET['volume_uom']) : '';

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

    $ticket_layout = new AdihaLayout();
    echo $ticket_layout->init_layout('ticket_layout', '', '1C', $layout_json, $form_namespace);

    $ticket_toolbar = new AdihaToolbar();
    $toolbar_name =  'ticket_toolbar';
    $toolbar_json = '[
                        { id: "save", type: "button", img: "save.gif", text:"Save", title: "Add", enabled: 1},

                     ]';

    echo $ticket_layout->attach_toolbar_cell($toolbar_name, 'a');
    echo $ticket_toolbar-> init_by_attach($toolbar_name, $form_namespace);
    echo $ticket_toolbar-> load_toolbar($toolbar_json);
    echo $ticket_toolbar->attach_event('', 'onClick', 'ticket_toolbar_click');

    $form_sp = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=" . $ticket_function_id . ", @template_name='TicketDetail', @parse_xml = '<Root><PSRecordSet ticket_detail_id=\"" . $ticket_detail_id . "\"></PSRecordSet></Root>'";

    $form_data = readXMLURL2($form_sp);

    $return_string = '';

//print_r($form_data); die();

	if (is_array($form_data) && sizeof($form_data) > 0) {
        $return_string .= ' tabbar_detail = ticket.ticket_layout.cells("a").attachTabbar({mode:"bottom",arrows_mode:"auto"});' . "\n";

        $flattened_form_data = array();
        $tab_data = array();

        foreach ($form_data as $data) {
        	if (!is_array($flattened_form_data[$data[tab_id]]))
                $flattened_form_data[$data[tab_id]] = array();

            $tab_id = 'detail_tab_' . $data[tab_id];
        	array_push($flattened_form_data[$data[tab_id]], array($tab_id, $data[tab_id], $data[layout_pattern], $data[form_json], $data[grid_json], $data[seq], $data[dependent_combo]));
        	array_push($tab_data, $data[tab_json]);
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
				if ($obj[grid_id] == 'FORM') {
					$return_string .= ' details_layout_' . $key . '.cells("' . $obj[layout_cell] . '").hideHeader();';
					$return_string .= '	details_form_' . $key . ' = details_layout_' . $key . '.cells("' . $obj[layout_cell] . '").attachForm();' . "\n";
					$return_string .= '	details_form_' . $key . '.loadStruct(' . $value[0][3] . ');' . "\n";

                    $return_string .= '  var form_name = "details_form_' . $key . '";';
                    $return_string .= '  attach_browse_event(form_name);';

                    if ($value[0][6] != NULL && $value[0][6] != '') {
						$dependent_combo_array = array();
						$dependent_combo_array = explode(',', $value[0][6]);
//print_r($value[0][6]);
						if (sizeof($dependent_combo_array) > 0) { 
							foreach ($dependent_combo_array as $combo_prop) {
								$column_array = array();
					            $column_array = explode('->', $combo_prop);
					            $parent_column = $column_array[0];
					            $dep_column = $column_array[1];
					            $value = $column_array[3];

								$return_string .= ' dhx' . $parent_column . '_' . $key . ' = details_form_' . $key . '.getCombo("' . $parent_column . '"); '. "\n";
						        $return_string .= 'dhx' . $dep_column . '_' . $key . ' = details_form_' . $key . '.getCombo("' . $dep_column . '"); '. "\n";

			        		    $return_string .= 'dhx' . $parent_column . '_' . $key . '.attachEvent("onChange", function(value){'. "\n";
						        $return_string .= '   dhx' . $dep_column . '_' . $key . '.clearAll();' . "\n";
						        $return_string .= '   dhx' . $dep_column . '_' . $key . '.setComboValue(null);' . "\n";
						        $return_string .= '   dhx' . $dep_column . '_' . $key . '.setComboText(null);' . "\n";
						        $return_string .= '   application_field_id = details_form_' . $key . '.getUserData("' . $dep_column . '", "application_field_id");' ."\n";
						        $return_string .= '   url = "' . $app_php_script_loc . 'dropdown.connector.php?call_from=dependent&value="+value+"&application_field_id="+application_field_id+"&parent_column=' . $parent_column . '";' ."\n";
						        $return_string .= '   dhx' . $dep_column . '_' . $key . '.load(url);' . "\n";
						        $return_string .= '});'. "\n";


						        $return_string .= 'dhx' . $dep_column . '_' . $key . '.clearAll();' . "\n";
						        $return_string .= 'var value = details_form_' . $key . '.getItemValue("' . $parent_column . '"); ' . "\n";

						        $return_string .= 'application_field_id = details_form_' . $key . '.getUserData("' . $dep_column . '", "application_field_id");' ."\n";
						        $return_string .= 'url = "' . $app_php_script_loc . 'dropdown.connector.php?call_from=dependent&value="+value+"&application_field_id="+application_field_id+"&parent_column=' . $parent_column . '";' ."\n";
						        $return_string .= 'dhx' . $dep_column . '_' . $key . '.load(url, function(){
																						   dhx' . $dep_column . '_' . $key . '.setComboValue(' . $value . '); 
																						});' . "\n";
						        
							}
						}
					}


				} else {
				    //if Grid
					$paging_div = 'detail_' . $obj[layout_cell] .'_' . $key;
					$return_string .= "details_layout_" . $key . ".cells('" . $obj[layout_cell] . "').attachStatusBar({
                                height: 30,
                                text: '<div id=\'" . $paging_div . "\'></div>'
                            });";
                    $return_string .= 'details_layout_' . $key . '.cells("' . $obj[layout_cell] . '").setText("' . $obj[grid_label] . '");';

                    $grid_obj = 'grid_' . $key;
					$menu_obj = 'menu_' . $key;
					$return_string .= $obj[grid_id] . '= {};';
					$grid_obj_withnamespace = $obj[grid_id] .  '.' . $grid_obj;
					$menu_obj_withnamespace = $obj[grid_id] .  '_' . $menu_obj;

					// grid menu definition
					$return_string .= $menu_obj_withnamespace . '= details_layout_' . $key . '.cells("' . $obj[layout_cell] . '").attachMenu({
							icons_path: "'. $image_path . 'dhxmenu_web/",' . "\n";

                    $return_string .= '		json:[
                            {id:"t1", text:"Edit", img:"edit.gif", items:[
                                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"}
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

                    $return_string .= '			case "add":' . "\n";
					$return_string .= '				var newId = (new Date()).valueOf();' . "\n";

                    
					$return_string .= 				$grid_obj_withnamespace . '.addRow(newId,"");' . "\n";
					$return_string .= 				$grid_obj_withnamespace . '.selectRowById(newId);' . "\n";
					$return_string .= 				$grid_obj_withnamespace . '.forEachRow(function(row){'. "\n";
					$return_string .= 					$grid_obj_withnamespace . '.forEachCell(row,function(cellObj,ind){'. "\n";
					$return_string .= 						$grid_obj_withnamespace . '.validateCell(row,ind)'. "\n";
                    $return_string .= '					});'. "\n";
					$return_string .= '				});'. "\n";
                    
                   // $return_string .= 				$menu_obj_withnamespace.'.setItemDisabled("delete");' . "\n";
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

					$return_string .= '		}' . "\n";
					$return_string .= '});' . "\n";

                    $return_string .= $grid_obj_withnamespace . '= details_layout_' . $key . '.cells("' . $obj[layout_cell] . '").attachGrid();';

					// create grid using definition in adiha_grid_definition
					$$grid_obj = new GridTable($obj[grid_id]);
    				$return_string .= $$grid_obj->init_grid_table($grid_obj, $obj[grid_id]);
    				$return_string .= $$grid_obj->enable_multi_select();
                    $return_string .= $$grid_obj->set_search_filter(true, ""); //for inline filter.
    				$return_string .= $$grid_obj->enable_paging(100, $paging_div, 'true');
    				$return_string .= $$grid_obj->submit_added_rows();
    				$return_string .= $$grid_obj->set_user_data("", "grid_id", $obj[grid_id]);
    				$return_string .= $$grid_obj->set_user_data("", "grid_obj", $obj[grid_id]);
					$return_string .= $$grid_obj->set_user_data("", "grid_label", $obj[grid_label]);

                    $return_string .= $$grid_obj->return_init();
    				$return_string .= $$grid_obj->load_grid_data('', $ticket_detail_id);
    				$return_string .= $$grid_obj->load_grid_functions('', $ticket_detail_id);

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

    				$permission_array = array();
    				$permission_array = $$grid_obj->return_permission();
    			/*	if (!$permission_array[edit]) {
    					$return_string .= $menu_obj_withnamespace . '.setItemDisabled("add");';
                                            $return_string .= $$grid_obj->disable_grid();
    				}

					if ($permission_array[delete]) {
						$return_string .= $grid_obj_withnamespace.'.attachEvent("onRowSelect", function(id,ind){';
						$return_string .= 				$menu_obj_withnamespace.'.setItemEnabled("delete");';
						$return_string .= ' 	});';
					}
                  */
                    $grid_counter++;
				}
            }
        }
	}

    echo $return_string;

    echo $ticket_layout->close_layout();
    $category_name = 'ticket';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = 'ticket'";
    $category_data = readXMLURL2($category_sql);

?>
<script>
    var category_id = "<?php echo $category_data[0][value_id];?>";
    var entity_id = '<?php echo $entity_id; ?>';
    var document_window;
    //var setup_book_structure_id = '10101200'
    var ticket_function_id = '<?php echo $ticket_function_id; ?>';
    var strategy_function_id = '<?php echo $strategy_function_id; ?>';
    var book_function_id = '<?php echo $book_function_id; ?>';
    var book_mapping_function_id = '<?php echo $book_mapping_function_id; ?>';
    var validation_status = true;
    var mode = '<?php echo $mode; ?>';
    var ticket_id = '<? echo $ticket_id; ?>' ;
    var ticket_detail_id = '<? echo $ticket_detail_id; ?>' ;
    var schedule_match_id = '<?php echo $schedule_match_id;?>';
    var is_matched = '<?php echo $is_matched;?>';
    var ticket_location = '<?php echo $ticket_location;?>';
    var commodity = '<?php echo $commodity;?>';
    var volume_uom = '<?php echo $volume_uom;?>';
    var has_document_rights = '<?php echo (int)$has_document_rights;?>';


    //alert(ticket_location + ' ' + commodity + ' ' + volume_uom);

    $(function() {
        // if (ticket_id) {
        //     add_manage_document_button(ticket_id, ticket.ticket_toolbar, has_document_rights);
        // }
        attach_edit_event();
        //load_default_value();
    });

    function open_ticket() {

        ticket_window = new dhtmlXWindows();
         var src = 'ticket.detail.php';// + '&generator_assignment_id=' + generator_assignment_id;

        new_win = ticket_window.createWindow('w1', 0, 0, 900, 400);
        new_win.setText("Ticket Detail");
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.attachURL(src, false);

    }

   /* function load_default_value(){
        //ticket.filters.setItemValue('quantity_uom', ticket.filters.getCombo('quantity_uom').getOptionByLabel('BBL')['value']);
        tabbar_detail.forEachTab(function(tab){
            var tab_text = tab.getText();
            if (tab_text == 'General' ) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();

                    // attached_obj.setItemValue('location_id', ticket_location);
                    // attached_obj.setItemValue('product_commodity', attached_obj.getCombo('product_commodity').getOptionByLabel(commodity)['value']);
                    // attached_obj.setItemValue('volume_uom', attached_obj.getCombo('volume_uom').getOptionByLabel(volume_uom)['value']);



                });
            }
        });
    }
*/
    function attach_edit_event() {
       tabbar_detail.forEachTab(function(tab){
            var tab_text = tab.getText();
            if (tab_text == 'Quality' ) {
                layout_obj = tab.getAttachedObject();
                ticket_grid_obj = layout_obj.cells('a').getAttachedObject();

                if (ticket_grid_obj instanceof dhtmlXGridObject) {
                    ticket_grid_obj.attachEvent("onEditCell",
                        function (stage, rId, cInd, nValue, oValue) {
                            if (stage == 2 && cInd == 2) {
                                var data = {
                                    "action": "spa_source_commodity_maintain",
                                    "flag": "q",
                                    "source_commodity_id": nValue,
                                    "row_id": rId
                                };
                                adiha_post_data('return_array', data, '', '', 'set_quality_type');

                                set_quality_type = function(result) {
                                   ticket_grid_obj.cells(result[0][1], ticket_grid_obj.getColIndexById('type')).setValue(result[0][0]);
                                }
                            }
                            return true;
                        }
                    );
                }

            }

        });
    }

   /* if (tab_text == 'General' ){
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        if (is_matched != '') {
                            attached_obj.getCombo('product_commodity').disable();
                            attached_obj.getCombo('location_id').disable();
                        }
                    }
                });
            }*/

    ticket_toolbar_click = function(id) {
        switch(id) {
            case "save":


                var validation_status = true;
                var grid_xml = '';
                var form_xml = '<Root><FormXML ';// '<Root function_id="' + ticket_function_id  + '"><FormXML ID="' + node_id_array[1] + '"';

                tabbar_detail.forEachTab(function(tab){
                    var tab_text = tab.getText();

                    if (tab_text == 'Quality') {
                        layout_obj = tab.getAttachedObject();
                        ticket_grid_obj = layout_obj.cells('a').getAttachedObject();

                        grid_xml += "<Grid grid_id = \""+ tab_text +"\">";
                        ticket_grid_obj.forEachRow(function(id){
                            if (ticket_grid_obj instanceof dhtmlXGridObject) {
                                if (ticket_grid_obj.cells(id,ticket_grid_obj.getColIndexById('value')).getValue() != '') {
                                    grid_xml = grid_xml + "<GridRow ";
                                    ticket_grid_obj.forEachCell(id,function(cellObj, ind){
                                         grid_xml = grid_xml + ticket_grid_obj.getColumnId(ind) + '="' + ticket_grid_obj.cells(id,ind).getValue() + '" ';

                                    });
                                    grid_xml = grid_xml + '></GridRow>';
                                }
                            }
                        });
                        grid_xml += '</Grid>'
                    } else if (tab_text == 'Detail' || tab_text == 'Additional' || tab_text == 'Product'){
                            layout_obj = tab.getAttachedObject();
                            layout_obj.forEachItem(function(cell) {
                                attached_obj = cell.getAttachedObject();
                                if (attached_obj instanceof dhtmlXForm) {
                                    var lbl = null;
                                    var sdv_data = null;
                                    var lbl_value = null;
                                    var entity_name = attached_obj.getItemValue('entity_name');
                                    data = attached_obj.getFormData();

                                    for (var a in data) {
                                        var status = validate_form(attached_obj);
                                        if(status){
                                            field_label = a;
                                            field_value = data[a];
                                            var lbl = attached_obj.getItemLabel(a);
                                            var lbl_value = attached_obj.getItemValue(a);

                                            if(lbl == 'Name'){
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

                                            if (attached_obj.getItemType(a) == "calendar") {
                                                field_value = attached_obj.getItemValue(a, true);
                                            }
                                            if (attached_obj.getItemType(a) == "browser") {
                                                field_value = '';
                                            }

                                            if (!field_value) {
                                                field_value = '';
                                            }

                                            form_xml += " " + field_label + "=\"" + field_value + "\"";
                                        } else {
                                            validation_status = false;
                                        }
                                    }
                                    /*
                                        if((effective_start_date_value !== null) && (end_date_value !== null) && (effective_start_date_value > end_date_value)){
                                            validation_status = false;
                                            show_messagebox('End Date should not be less than Effective date.');
                                        }
                                    */
                                }
                            });
                        }
                });               

                form_xml += "></FormXML>";

             	grid_xml = "<GridGroup>" + grid_xml + "</GridGroup></Root>";

             	ticket_detail_xml = form_xml + grid_xml;


                if (validation_status == true) {                	
                    data = {"action": "spa_ticket","flag": mode, "ticket_header_xml": '', "ticket_detail_xml": ticket_detail_xml, "ticket_header_id": ticket_id, "ticket_detail_ids": ticket_detail_id};
                    result = adiha_post_data('alert', data, "", "", "after_save");
                }
                break;
            case 'documents':
                ticket.open_document();
            default:
                break;
        }
    }

  //   /**
 	// * [open_document Open Document window]
 	// */
  //   ticket.open_document = function() {
  //       ticket.unload_document_window();


  //       if (!document_window) {
  //           document_window = new dhtmlXWindows();
  //       }

  //       var win_title = 'Document';
  //       var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?notes_category= '+category_id +'&notes_object_id=' + ticket_id + '&is_pop=true';

  //       var win = document_window.createWindow('w1', 0, 0, 400, 400);
  //       win.setText(win_title);
  //       win.centerOnScreen();
  //       win.setModal(true);
  //       win.maximize();
  //       win.attachURL(win_url, false, {notes_category:category_id});

  //       win.attachEvent('onClose', function(w) {
  //           update_document_counter(ticket_id, ticket.ticket_toolbar);
  //           return true;
  //       });
  //   }

  //    /**
  //    * [unload_document_window Unload Document Window]
  //    */
  //   ticket.unload_document_window = function() {
  //       if (document_window != null && document_window.unload != null) {
  //           document_window.unload();
  //           document_window = w1 = null;
  //       }
  //   }



    function after_save() {
        //return;
        setTimeout('parent.new_win.close()', 1000);
    }
</script>
</html>
