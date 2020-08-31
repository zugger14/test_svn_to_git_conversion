<?php
/**
* Compliance group screen
* @copyright Pioneer Solutions
*/
?>
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
    $rights_static_data_iu = 10101010; // main Save
    $rights_compliance_group_delete = 10101011; // delete grid data
    $rights_compliance_group_grid_iu = 10101010; // insert update grid

    list (
        $has_rights_static_data_iu,
        $has_rights_compliance_group_iu,
        $has_rights_compliance_group_delete
        ) = build_security_rights(
        $rights_static_data_iu,
        $rights_compliance_group_grid_iu,
        $rights_compliance_group_delete
    );

	$layout = new AdihaLayout();
    $form_obj = new AdihaForm();

    $layout_name = 'compliance_group_layout';        

    if (isset($_POST['value_id'])) {
        $value_id = get_sanitized_value($_POST['value_id']);
        $xml = '<Root><PSRecordset value_id="' . $value_id . '"></PSRecordset></Root>';
    } else {
        $value_id = "null";
        $xml = '<Root><PSRecordset value_id=""></PSRecordset></Root>';
    }

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Compliance Group",
                            width:          720,
                            height:         160,
                            header:         false,
                            collapse:       false,
                            fix_size:       [true,true]
                        },

                    ]';

	$name_space = 'compliance_group';
    echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

    $toolbar_name = 'compliance_group_toolbar';
    echo $layout->attach_toolbar_cell($toolbar_name, 'a');

    $toolbar_obj = new AdihaToolbar();
    echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);

    echo $toolbar_obj->load_toolbar('[{id: "save", type: "button", text:"Save", img: "save.gif", title:"Save",imgdis: "save_dis.gif", action: "compliance_group",  }]');     
    //Save button Privilege
    if($value_id != 'null') {
        echo $toolbar_obj->save_privilege(get_sanitized_value($_POST['type_id']), $value_id);
    }
    // Groups

    $tab_name = 'compliance_group_tabs';

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
                        text:    "Properties",
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

    $xml_file = "EXEC spa_create_application_ui_json 'j', 10101010, 'StaticDataIU','$xml' ";
    $return_value1 = readXMLURL($xml_file);
    $form_structure_general = $return_value1[0][2];      

    $form_name = 'compliance_group_form';
    echo $tab_obj->attach_form($form_name, 'a1', $form_structure_general, $name_space);

     //for grid
    $grid_name = 'compliance_group_grid';
    echo 'compliance_group.compliance_group_grid= compliance_group.compliance_group_tabs.tabs("a2").attachGrid();';
    $grid = new AdihaGrid();
    echo $grid->init_by_attach($grid_name, $name_space);
    echo $grid->set_header('ID,Assignment Type,Assignment State,Compliance Year,Commit Type');
    echo $grid->set_widths('100,130,130,130,130');
    echo $grid->set_columns_ids('id,ass_type,ass_state,compliance_year,commit_type');
    echo $grid->hide_column('0');
    echo $grid->set_column_types('ro,combo,combo,combo,combo');
    echo $grid->set_sorting_preference('int,str,str,int,str');
    echo $grid->set_search_filter('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
    echo $grid->enable_multi_select();
    echo $grid ->load_grid_functions();
    echo $grid->attach_event('','onRowSelect','on_grid_select');
    echo $grid->return_init();
    echo $layout->close_layout();
?>
</body>

<script type="text/javascript">
	var has_rights_static_data_iu;
    var has_rights_compliance_group_iu;
    var has_rights_compliance_group_grid_delete;

    $(function() {
    	// loading combo of grid column
    	// Assignment Type
    	var ass_type_combo = compliance_group.compliance_group_grid.getColumnCombo(1);
        var ass_type_combo_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id" :"10013", "has_blank_option" : "true"};
        load_combo(ass_type_combo, ass_type_combo_sql);

        // Assigned State
        var ass_state_combo = compliance_group.compliance_group_grid.getColumnCombo(2);
        var ass_state_combo_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id" :"10002", "has_blank_option" : "true"};
        load_combo(ass_state_combo, ass_state_combo_sql);

        // Compliance Year
        var compliance_year_combo = compliance_group.compliance_group_grid.getColumnCombo(3);
        var compliance_year_combo_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id" :"10092", "has_blank_option" : "true"};
        load_combo(compliance_year_combo, compliance_year_combo_sql);

        // Commit Type
        var commit_type_combo = compliance_group.compliance_group_grid.getColumnCombo(4);
        var commit_type_combo_sql = {"action":"('SELECT ''a'' AS [value], ''Aggregate'' AS [option] UNION ALL SELECT ''d'' AS [value], ''Detail'' AS [option] ORDER BY [option]' )", "has_blank_option" : "true"};
        load_combo(commit_type_combo, commit_type_combo_sql);

    	// loading grid data
        setTimeout(function() {
            refresh_grid();
        }, 200);

    	// applying privileges
    	has_rights_static_data_iu = <?php echo (($has_rights_static_data_iu) ? $has_rights_static_data_iu : '0'); ?>;
        has_rights_compliance_group_iu = <?php echo (($has_rights_compliance_group_iu) ? $has_rights_compliance_group_iu : '0'); ?>;
        has_rights_compliance_group_grid_delete = <?php echo (($has_rights_compliance_group_delete) ? $has_rights_compliance_group_delete : '0'); ?>;

        if (has_rights_static_data_iu == 0) {
            compliance_group.compliance_group_toolbar.disableItem("save");
            compliance_group.compliance_group_toolbar.clearItemImage("save");
        }

        var general_Form = compliance_group.compliance_group_form.getForm();
        value_id = '<?php echo $value_id; ?>';
        var delete_grid = "";

        if(value_id == "") {
            value_id = general_Form.getItemValue('value_id');
            general_Form.setItemValue('type_id', 28000);
        }

        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        grid_toolbar = compliance_group.compliance_group_tabs.tabs("a2").attachMenu();
        grid_toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");

        // Menu for the Grid
        var constraints_toolbar =   [
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: has_rights_static_data_iu},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: false }
            ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]},
        ];

        grid_toolbar.loadStruct(constraints_toolbar);

        if( has_rights_compliance_group_iu == 0 ) {
            grid_toolbar.setItemDisabled("add");
        }

        grid_toolbar.attachEvent('onClick', function(id) {
        	switch(id) {
	    		case 'add':
	    			var newId = (new Date()).valueOf();
	                compliance_group.compliance_group_grid.addRow(newId, '', '');
	    		break;

	    		case 'delete':
	    			var del_ids = compliance_group.compliance_group_grid.getSelectedRowId();
                    var id = compliance_group.compliance_group_grid.cells(del_ids, 0).getValue();
                    delete_grid += '<GridDelete  id ="' + id + '"  logical_name="' + value_id + '" ></GridDelete>';
                    compliance_group.compliance_group_grid.deleteRow(del_ids);  
                    grid_toolbar.setItemDisabled("delete");
	    		break;

	    		case 'excel':
	    			compliance_group.compliance_group_grid.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
	    		break;

	    		case 'pdf':
	    			compliance_group.compliance_group_grid.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
	    		break;
	    	}
        });

        compliance_group.compliance_group_toolbar.attachEvent('onClick', function (id) {
        	var validation = 0;
	        var blank_value = 0;
	        var blank_label = '';
	        var form_xml;
	        var grid_xml; 

	        generalForm = compliance_group.compliance_group_form.getForm();
	        var code = generalForm.getItemValue('code'); 
	        var description = generalForm.getItemValue('description') 

	        var status = validate_form(generalForm);
	        compliance_group.compliance_group_grid.clearSelection();

	        if (status == 'false' ) {
	            return;
	        }

	        if (code != '') {
	        	if(description == '') {
                    description = code;
                    generalForm.setItemValue('description', code);
                }

                // Form XML
                form_xml = '<Root><PSRecordset type_id = "28000" value_id= "' + value_id + '" code = "' + code + '" description = "' + description + '"></PSRecordset></Root>';

                // Grid XML
                grid_xml = '<GridGroup><Grid grid_id = "compliance_group_grid">';
                grid_xml += delete_grid;
                compliance_group.compliance_group_grid.forEachRow(function (id) {
                	grid_xml += "<GridRow ";
                	compliance_group.compliance_group_grid.forEachCell(id, function (cellObj, ind) {
                		grid_index = compliance_group.compliance_group_grid.getColumnId(ind);
                        grid_value = cellObj.getValue(ind);
                        grid_xml += " " + grid_index + '="' + grid_value + '"';
                	});

                	grid_xml = grid_xml + ' logical_name ="' + value_id +'"';
                	grid_xml += '></GridRow>';
                });

                grid_xml += '</Grid></GridGroup>';

                data = {
                    "action": "spa_compliance_group",
                    "flag": "i",
                    "xmlValue": form_xml,
                    "xmlValue2": grid_xml
                };

                
                if (delete_grid != "") {
                    confirm_messagebox("Some data has been deleted from grid. Are you sure you want to save?", function() {
                        result = adiha_post_data("alert", data, "", "", "save_callback");
                        delete_grid = '';
                    }, function() {
                        refresh_grid(value_id);
                    });
                } else {
                    result = adiha_post_data("alert", data, "", "", "save_callback");
                } 
                
	        }

        });

    });

	function on_grid_select() {
		if (has_rights_static_data_iu) 
            grid_toolbar.setItemEnabled('delete');
	}

	function refresh_grid(id) {
		var param = {
                "action": "spa_compliance_group",
                "flag": "s",
                "logical_name": value_id
            };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        compliance_group.compliance_group_grid.clearAll();
        compliance_group.compliance_group_grid.loadXML(param_url);
	}

	function save_callback(result) {
		var message_error;
        if (result[0].status == 'Success') {
            var new_id = result[0].recommendation;
            if(result[0].recommendation == '' ) {
                new_id = '<?php echo $value_id; ?>';
            }
            generalForm.setItemValue('value_id', new_id);
            var code = generalForm.getItemValue('code');
            refresh_grid(new_id);
            parent.setup_static_data.special_menu_case(result, code,'compliance_group');
        }
	}

    function load_combo(combo_obj, combo_sql) {
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj.load(url);
        combo_obj.enableFilteringMode(true);
    }
</script>