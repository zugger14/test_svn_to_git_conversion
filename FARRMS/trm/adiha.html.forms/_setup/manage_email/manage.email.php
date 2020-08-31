<?php
/**
* Manage email screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body><div id="import_context_menu" style="display: none;"><div id="import_rules" text="<span style='color:red'>Import Rules:</span>"></div></div></body>
<?php
	$notes_object_id = (isset($_REQUEST['notes_object_id'])) ? get_sanitized_value($_REQUEST['notes_object_id']) : 0;
	$notes_category = get_sanitized_value($_REQUEST['notes_category'] ?? '');
	
    $call_from = get_sanitized_value($_REQUEST['call_from'] ?? 'search_document');
    $parent_object_id = get_sanitized_value($_REQUEST['parent_object_id'] ?? 'NULL');
    
    if ($notes_category == 45) {
        $call_from = 'match_window';
    }

	$rights_form_manage_emails = 10106900;
	$rights_grd_manage_emails_iu = 10106910;
	$rights_grd_manage_emails_del = 10106911;
	$rights_grd_manage_emails_map = 10106920;

	list (
	    $has_rights_form_manage_emails,
	    $has_rights_grd_manage_emails_iu,
	    $has_rights_grd_manage_emails_del,
	    $has_rights_grd_manage_emails_map
	) = build_security_rights (
	    $rights_form_manage_emails, 
	    $rights_grd_manage_emails_iu,
	    $rights_grd_manage_emails_del,
	    $rights_grd_manage_emails_map
	);

	//rights checked for disable status (not enabled status)
	$add_edit_button_state = empty($has_rights_grd_manage_emails_iu) ? 'true' : 'false';
	$delete_button_state = empty($has_rights_grd_manage_emails_del) ? 'true' : 'false';
	$map_button_state = empty($has_rights_grd_manage_emails_map) ? 'true' : 'false';

	$note_category_collapse = ($notes_category > 0) ? 'true' : 'false';

	$layout = new AdihaLayout();
	$json = '[{
                id:             "a", 
                text:           "Search",
                header:         true,
                height:         76,
                collapse:       false
            },
            {
                id:             "b", 
                text:           "Folders/Domain",
                header:         true,
                width:          250,
                collapse:       false
            },
            {
                id:             "c", 
                text:           "Email",
                header:         false,
                collapse:       false
            }]';

	$layout_name = 'layout';
	$namespace = 'manage_email';
	echo $layout->init_layout($layout_name, '', '3T', $json, $namespace);
    
    // Attach Search Form
    $search_form_json = '[{type:"settings", offsetLeft:3, offsetTop: 2, labelWidth: 100, position: "label-top"},
            {type:"block", list: [
                {type:"input", name:"ip_search_text", hidden: false, label:""},
                {type:"newcolumn"},
                {type:"button", offsetLeft:0, offsetTop: 5, name:"btn_search", hidden: false, width: 35, title: "Search", tooltip:"Search" , value:"<span class=\'search\'></span>" },
                {type:"newcolumn"},
                {type:"button", offsetLeft:0, offsetTop: 5, name:"btn_clear_search", hidden: false, width: 35, title: "Clear Search", tooltip:"Clear Search", value:"<span class=\'clear\'></span>" }
            ]}
        ]';
    
    $form_name = 'form_search';
    $search_form = new AdihaForm();
    echo $layout->attach_form($form_name, 'a', $search_form_json);
    echo $search_form->init_by_attach($form_name, $namespace);
    echo $search_form->attach_event('', 'onButtonClick', 'search_button_click');

    // Attach Folder/Domain Tree
    $grid_name = 'grid_folders';
    echo $layout->attach_grid_cell($grid_name, 'b');
    $folder_tree_grid = new GridTable('ManageEmailFolders');
    echo $folder_tree_grid->init_grid_table($grid_name, $namespace, 'n');
    echo $folder_tree_grid->set_no_header();
    echo $folder_tree_grid->return_init();
    echo $folder_tree_grid->load_grid_data('', '', false, 'grid_folders_load_callback');
    echo $folder_tree_grid->attach_event('', 'onRowSelect', 'grid_folders_select');
    echo $folder_tree_grid->attach_event('', 'onRowDblClicked', 'function(row_id, cell_index) {}');
    
	// Menu json
	$menu_detail_json = '[ 
        {id:"refresh", img:"refresh.gif", img_disabled:"refresh_dis.gif", text:"Refresh", disabled:0},
        {id:"edit", img:"edit.gif", text:"Edit", items:[
            {id:"add", img:"add.gif", img_disabled:"add_dis.gif", text:"Add", title:"Add", disabled:0},
            {id:"delete", img:"delete.gif", img_disabled:"delete_dis.gif", text:"Delete", title:"Delete", disabled:1}
        ]},
        {id:"actions", img:"action.gif", text:"Actions", items:[
            {id:"map", img:"map.png", img_disabled:"map_dis.png", text:"Map", title:"Map", disabled:1},
            {id:"unmap", img:"unmap.png", img_disabled:"unmap_dis.png", text:"Unmap", title:"Unmap", disabled:1}
        ]},
        {id:"view", img:"view.gif", text:"View", disabled:0, items:[
            {id: "view_mapped", type: "radio", group: "view_map", text: "View Mapped", checked: 0, disabled:0},
            {id: "view_unmapped", type: "radio", group: "view_map", text: "View Unmapped", checked: 0, disabled:0},
            {id: "view_both", type: "radio", group: "view_map", text: "View Both", checked: 1, disabled:0}
        ]},
        {id:"export", img:"export.gif", text:"Export", items:[
            {id:"excel", img:"excel.gif", img_disabled:"excel_dis.gif", text:"Excel", title:"Excel"},
            {id:"pdf", img:"pdf.gif", img_disabled:"pdf_dis.gif", text:"PDF", title:"PDF"}
        ]}
    ]';
    $menu_name = 'menu_detail';
    $menu_detail = new AdihaMenu();
    echo $layout->attach_menu_cell($menu_name, 'c');
    echo $menu_detail->init_by_attach($menu_name, $namespace);
    echo $menu_detail->load_menu($menu_detail_json);
    echo $menu_detail->attach_event('', 'onClick', 'fx_menu_detail_click');
    
    // Attach Detail Grid
    $grid_name = 'grid_detail';
    echo $layout->attach_grid_cell($grid_name, 'c');
    echo $layout->attach_status_bar('c', true);
    $grid_detail = new GridTable('ManageEmail');
    echo $grid_detail->init_grid_table($grid_name, $namespace, 'y');
    echo $grid_detail->set_search_filter(false, "#numeric_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#text_filter");
    echo $grid_detail->enable_paging(50, 'pagingArea_c', 'true');
    echo $grid_detail->return_init();
    echo $grid_detail->enable_multi_select();
    echo $grid_detail->attach_event('', 'onRowSelect', 'grid_detail_select');
    echo $grid_detail->attach_event('', 'onRowDblClicked', 'grid_detail_row_dbl_click');
    
    // Close Layout
	echo $layout->close_layout();
    
    $image_path = $image_path . '/dhxform_web/';
    $search_img = $image_path . 'search.png';
    $clear_img = $image_path . 'close.png';
    
    $sp_url = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10106920', @template_name='ManageEmailMap', @group_name='General'";
    $result = readXMLURL($sp_url);
    $email_map_form_json = $result[0][2];
?>

<script type="text/javascript">
	var php_script_loc = '<?php echo $app_php_script_loc; ?>';
    var call_from = '<?php echo $call_from; ?>';
	
	var dhx_document, dhx_email_document;
    
    var notes_object_id = (call_from == 'search_document' ? 'NULL' : '<?php echo $notes_object_id; ?>');
    var parent_object_id = '<?php echo $parent_object_id; ?>';
    
    var view_mapped_gbl = 'b';
    var email_type_gbl = 'i';
    var domain_gbl = 'NULL';
    var search_result_table_gbl = '';
    
    var has_rights_grd_manage_emails_iu = Boolean('<?php echo $has_rights_grd_manage_emails_iu; ?>');
    var has_rights_grd_manage_emails_del = Boolean('<?php echo $has_rights_grd_manage_emails_del; ?>');
    var has_rights_grd_manage_emails_map = Boolean('<?php echo $has_rights_grd_manage_emails_map; ?>');
    
    var post_data = '';
    $(function() {
        dhx_email_document = new dhtmlXWindows();
		fx_load_import_rules();
    });

    function fx_search_click() {
        var search_text = manage_email.form_search.getItemValue('ip_search_text');
        if (search_text == '') {
            fx_refresh_grid('grid_detail');
            return;
        }
        
        var sp_string = "EXEC spa_search_engine @flag='s', @searchString='" + search_text + "', @searchTables='email', @callFrom='s'"; 
        post_data = { sp_string: sp_string };
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            
            var param = {
                "flag": "r",
                "action": "spa_manage_email",
                "grid_type": "g",
                "email_type": email_type_gbl,
                "view_mapped": view_mapped_gbl,
                "domain": domain_gbl,
                "search_result_table": (data['json'].length == 0 ? '-1' : json_data.detail_table)
            };
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            manage_email.grid_detail.clearAll();
            manage_email.grid_detail.loadXML(param_url, function() {
                fx_highlight_searched_cell();
                manage_email.layout.progressOff();
            });
        });
    }

    function search_button_click(name) {
        manage_email.layout.progressOn();
        if (name == 'btn_search') {
            fx_search_click();
        } else if (name == 'btn_clear_search') {            
            manage_email.form_search.setItemFocus('ip_search_text');
            fx_refresh_grid('grid_detail');
        }
    }

    function grid_folders_load_callback() {
        if (email_type_gbl == 'i') {
            var selected_rid = manage_email.grid_folders.getRowId(0);
        } else if (email_type_gbl == 'o') {
            var selected_rid = manage_email.grid_folders.getRowId(1);
        } else {
            var selected_rid = manage_email.grid_folders.getRowId(2);
        }

        manage_email.grid_folders.selectRowById(selected_rid, false, false, false);
        manage_email.grid_folders.expandAll();
        fx_refresh_grid('grid_detail');
    }

    function grid_folders_select(row_id, cell_index) {
        fx_grid_select(row_id, cell_index, 'grid_folders');
    }

    function grid_detail_select(row_id, cell_index) {
        fx_grid_select(row_id, cell_index, 'grid_detail');
    }

    function grid_detail_row_dbl_click(row_id, cell_index) {
        fx_edit_email('u', row_id);
    }

    function fx_refresh_grid(grid_name) {
        if (grid_name == 'grid_folders') {
            var param = {
                "flag": "l",
                "action": "spa_manage_email",
                "grid_type": "tg",
                "grouping_column": 'folder_name,domain'
            };
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            manage_email.grid_folders.clearAll();
            manage_email.grid_folders.loadXML(param_url, function() {
                if (email_type_gbl == 'i') {
                    var selected_rid = manage_email.grid_folders.getRowId(0);
                } else if (email_type_gbl == 'o') {
                    var selected_rid = manage_email.grid_folders.getRowId(1);
                } else {
                    var selected_rid = manage_email.grid_folders.getRowId(2);
                }
                manage_email.grid_folders.selectRowById(selected_rid, false, false, false);
                manage_email.grid_folders.expandAll();
                fx_refresh_grid('grid_detail');
            });
        } else if (grid_name == 'grid_detail') {
            manage_email.form_search.setItemValue('ip_search_text', '');
            search_result_table_gbl = ''; //setting search table blank once refresh clicked
            var param = {
                "flag": "r",
                "action": "spa_manage_email",
                "grid_type": "g",
                "email_type": email_type_gbl,
                "view_mapped": view_mapped_gbl,
                "domain": domain_gbl
            };
            
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            manage_email.grid_detail.clearAll();
            manage_email.grid_detail.loadXML(param_url, function() {
                if (email_type_gbl == 'i') {
                    manage_email.grid_detail.setColumnHidden(manage_email.grid_detail.getColIndexById('send_to'), true);
                    manage_email.grid_detail.setColumnHidden(manage_email.grid_detail.getColIndexById('send_from'), false);
                } else {
                    manage_email.grid_detail.setColumnHidden(manage_email.grid_detail.getColIndexById('send_from'), true);
                    manage_email.grid_detail.setColumnHidden(manage_email.grid_detail.getColIndexById('send_to'), false);
                }
                fx_enable_menu_items(false);
                manage_email.grid_detail.filterByAll();
                manage_email.layout.progressOff();
            });
        }
    }

    function fx_grid_select(row_id, cell_index, grid_name) {
        if (grid_name == 'grid_folders') {
            manage_email.layout.progressOn();
            if (row_id.indexOf('Incoming') > -1) {
                email_type_gbl = 'i';
            } else if (row_id.indexOf('Outgoing') > -1) {
                email_type_gbl = 'o';
            } else if (row_id.indexOf('Failed') > -1) {
                email_type_gbl = 'f';
            }
            
            var tree_lvl = manage_email.grid_folders.getLevel(row_id);
            if (tree_lvl == 1) {
                domain_gbl = manage_email.grid_folders.cells(row_id, manage_email.grid_folders.getColIndexById('domain')).getValue();
            } else {
                domain_gbl = 'NULL';
            }

            var search_text = manage_email.form_search.getItemValue('ip_search_text');
            if (search_text != '' && search_result_table_gbl != '') {                
                var param = {
                    "flag": "r",
                    "action": "spa_manage_email",
                    "grid_type": "g",
                    "email_type": email_type_gbl,
                    "view_mapped": view_mapped_gbl,
                    "domain": domain_gbl,
                    "search_result_table": search_result_table_gbl
                };
                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                manage_email.grid_detail.clearAll();
                manage_email.grid_detail.loadXML(param_url, function() {
                    fx_highlight_searched_cell();
                });
            } else {
                fx_refresh_grid('grid_detail');
            }            
        } else if(grid_name == 'grid_detail') {
            fx_enable_menu_items(true);
        }        
    }
    
    function fx_menu_detail_click(id) {
        switch(id) {
            case 'add':
                fx_edit_email('i');
                break;
            case "delete":
                confirm_messagebox('Are you sure you want to delete?', function() {
                    fx_delete_email();
                });
            	break;
            case 'view_mapped':
            case 'view_unmapped':
            case 'view_both':
                view_mapped_gbl = (id == 'view_mapped' ? 'm' : (id == 'view_unmapped' ? 'u' : 'b'));
                fx_refresh_grid('grid_detail');
                break;
            case 'map':
                fx_map_email();
                break;
            case 'unmap':
                var selected_row_id = manage_email.grid_detail.getSelectedRowId();
                if(selected_row_id.indexOf(',') == -1) {
                    var notes_id = manage_email.grid_detail.cells(selected_row_id, manage_email.grid_detail.getColIndexById('notes_id')).getValue();
                } else {
                    var notes_id_arr = [];
                    $.each(selected_row_id.split(','), function(rid) {
                        notes_id_arr.push(manage_email.grid_detail.cells(rid, manage_email.grid_detail.getColIndexById('notes_id')).getValue());
                    });
                    var notes_id = notes_id_arr.join(',');
                }
                fx_save_map('n', notes_id);
                break;
            case 'refresh':
                fx_refresh_grid('grid_detail');
                break;
            case "pdf":
            	fx_export_to_pdf();
            	break;
            case "excel":
            	fx_export_to_excel();
            	break;
        }
    }
    
    function fx_edit_email(mode, row_id) {
        if (mode == 'i') {
            var title_text = 'Email - New';
    		var param = app_form_path + '_setup/manage_documents/' + 'email.documents.php?mode=i&call_from=manage_email';
            
            win_add_email = dhx_email_document.createWindow("w1", 0, 0, 670, 500);		
    		win_add_email.setText(title_text);           
            win_add_email.centerOnScreen();
    		win_add_email.attachURL(param, false, true);
    
    		win_add_email.attachEvent('onClose', function(win) {
                manage_email.layout.progressOn();
                fx_refresh_grid('grid_folders');
    			return true;
    		});
        } else if (mode == 'u') {
            var notes_id = manage_email.grid_detail.cells(row_id, manage_email.grid_detail.getColIndexById('notes_id')).getValue();
            var title_text = 'Email Subject : ' + manage_email.grid_detail.cells(row_id, manage_email.grid_detail.getColIndexById('subject')).getValue();
    		var param = app_form_path + '_setup/manage_documents/' + 'email.documents.php?mode=u&call_from=manage_email&notes_id=' + notes_id;
            
            win_add_email = dhx_email_document.createWindow("w1", 0, 0, 670, 500);		
    		win_add_email.setText(title_text);
            win_add_email.centerOnScreen();
    		win_add_email.attachURL(param, false, true);
            
    		win_add_email.attachEvent('onClose', function(win) {
                manage_email.layout.progressOn();
    			fx_refresh_grid('grid_detail');
    			return true;
    		});
        }
    }

    function fx_map_email() {
        var selected_row_id = manage_email.grid_detail.getSelectedRowId();
        if (selected_row_id.indexOf(',') == -1) {
            var notes_id = manage_email.grid_detail.cells(selected_row_id, manage_email.grid_detail.getColIndexById('notes_id')).getValue();
        } else {
            var notes_id_arr = [];
            $.each(selected_row_id.split(','), function(rid) {
                notes_id_arr.push(manage_email.grid_detail.cells(rid, manage_email.grid_detail.getColIndexById('notes_id')).getValue());
            });
            var notes_id = notes_id_arr.join(',');
        }
        win_map_email = dhx_email_document.createWindow("win_map", 0, 0, 700, 300);		
		win_map_email.setText('Map Email');
        win_map_email.center();
        win_map_layout = win_map_email.attachLayout({
            pattern: '1C',
            cells: [{id: 'a', text: 'cell a', collapse: false, header: false}]
        });
        
        var form_json_map = <?php echo $email_map_form_json; ?>;
        
        win_map_form = win_map_layout.cells('a').attachForm(form_json_map);
        win_map_form.attachEvent('onChange', function(name, value) {
            fx_object_cmb_change();
        });
        attach_browse_event('win_map_form');
        win_map_menu = win_map_layout.cells('a').attachMenu();
        win_map_menu.setIconsPath(js_image_path + "dhxmenu_web/");  
		win_map_menu.loadStruct(
            [ 
                {id:"save", img:"save.gif", img_disabled:"save_dis.gif", text: get_locale_value("Save"), disabled:0}
            ]
        );
		win_map_menu.attachEvent("onClick", function(id){
		    switch(id) {
                case 'save':
                    if (!validate_form(win_map_form)) {
                        return;
                    }
                    var notes_id = win_map_form.getItemValue('notes_id');
                    fx_save_map('m', notes_id);
                    break;
            }
		});
        win_map_menu.attachEvent('onClose', function(win) {
			fx_refresh_grid('grid_detail');
			return true;
		});

        fx_object_cmb_change();        
    }

    function fx_save_map(flag, notes_id) {        
        if (flag == 'm') {
            var internal_type_value_id = win_map_form.getItemValue('object');
            var notes_object_id = win_map_form.getItemValue('object_id');
            if (internal_type_value_id == 33 || internal_type_value_id == 37 || internal_type_value_id == 45)
                notes_object_id = win_map_form.getItemValue('object_id_second');
            
            var sp_string = "EXEC spa_manage_email @flag='" + flag + "', @notes_id='" + notes_id + "', @internal_type_value_id=" + internal_type_value_id + ", @notes_object_id=" + notes_object_id;
        } else {
            var sp_string = "EXEC spa_manage_email @flag='" + flag + "', @notes_id='" + notes_id + "'";
        }
                 
        post_data = { sp_string: sp_string };
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                success_call(json_data.message);
                fx_refresh_grid('grid_detail');
            } else {
                show_messagebox(json_data.message);
            }
        });        
    }

    function fx_delete_email() {
        manage_email.layout.progressOn();
        var row_id = manage_email.grid_detail.getSelectedRowId();
        if (row_id.indexOf(',') == -1) {
            var notes_id = manage_email.grid_detail.cells(row_id, manage_email.grid_detail.getColIndexById('notes_id')).getValue();
        } else {
            var note_id_arr = [];
            $.each(row_id.split(','), function(index, value) {
                note_id_arr.push(manage_email.grid_detail.cells(value, manage_email.grid_detail.getColIndexById('notes_id')).getValue());
            });
            var notes_id = note_id_arr.join(',');
        }
        
        var sp_string = "EXEC spa_manage_email @flag='d', @notes_id='" + notes_id + "'"; 
        post_data = { sp_string: sp_string };
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if (json_data.errorcode == 'Success') {
                success_call('Changes have been saved successfully', 'error');
                fx_refresh_grid('grid_folders');
                manage_email.layout.progressOff();
            } else {
                show_messagebox(json_data.message);
                manage_email.layout.progressOff();
            }
        });
    }
    
    function fx_object_cmb_change() {
        var value = win_map_form.getItemValue('object');
        var combo_obj = win_map_form.getCombo('object');
        combo_obj.allowFreeText(false);
        
        switch(value) {
            case '33':
                win_map_form.setUserData('object_id_second', 'grid_name', 'deal_filter');
                win_map_form.setUserData('object_id_second', 'grid_label', 'Deal'); 
                win_map_form.hideItem('object_id');
                win_map_form.showItem('label_object_id_second');
                break;
            case '37':
                win_map_form.setUserData('object_id_second', 'grid_name', 'browse_counterparty');
                win_map_form.setUserData('object_id_second', 'grid_label', 'Counterparty'); 
                win_map_form.hideItem('object_id');
                win_map_form.showItem('label_object_id_second');
                break;
            case '45':
                win_map_form.setUserData('object_id_second', 'grid_name', 'browse_shipment');
                win_map_form.setUserData('object_id_second', 'grid_label', 'Shipment'); 
                win_map_form.hideItem('object_id');
                win_map_form.showItem('label_object_id_second');
                break;
            default:
                win_map_form.hideItem('label_object_id_second');
                win_map_form.hideItem('clear_object_id_second');
                win_map_form.showItem('object_id');
        }        
    }
    
    function fx_highlight_searched_cell() {
        var search_text = manage_email.form_search.getItemValue('ip_search_text');
        manage_email.grid_detail.forEachRow(function(rid) {
            manage_email.grid_detail.forEachCell(rid, function(cell_obj, cid) {
                cell_obj.setValue(cell_obj.getValue().toString().replace(new RegExp(search_text, "i"), "<span style=\"background-color:yellow;\">" + search_text + "</span>"));
            });
        });
    }

    function fx_download_file(file_path, filename) {
        window.location = php_script_loc + 'force_download.php?path=' + file_path + '&name=' + filename;
    }

    function fx_click_parent_object_id_link(category_id, parent_object_id) {
        var function_id = '';
        if (category_id == 33) { //deal
            function_id = 10131010;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id, 'n');
        } else if (category_id == 37) { //counterparty
            function_id = 10105800;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
        } else if (category_id == '-1') { //workflow
            function_id = 10106700;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id, 'manage_email');
        } else if (category_id == 45) { //match
            var sp_string = "EXEC spa_scheduling_workbench @flag='s', @match_group_shipment_id=" + parent_object_id; 
            post_data = { sp_string: sp_string };
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                var json_data = data['json'][0];
                var process_id_generated = json_data.process_id;
                parent_object_id = json_data.parent_object_id;
                sp_string = "EXEC spa_scheduling_workbench @flag='s',@buy_sell_flag=NULL,@process_id='" + process_id_generated + "'"; 
                post_data = { sp_string: sp_string };
                $.ajax({
                    url: js_form_process_url,
                    data: post_data,
                }).done(function(data) {
                    //var json_data1 = data['json'][0];
                    sp_string = "EXEC spa_scheduling_workbench @flag = 'v', @process_id = '" + process_id_generated + "', @buy_deals = '', @sell_deals = '', @convert_uom = 1082, @convert_frequency=703, @mode = 'u', @get_group_id = 1, @bookout_match = 'm', @match_group_id = " + parent_object_id; 
                    post_data = { sp_string: sp_string };
                    $.ajax({
                        url: js_form_process_url,
                        data: post_data,
                    }).done(function(data) {
                        //var json_data2 = data['json'][0];
                        sp_string = "EXEC spa_scheduling_workbench  @flag='q',@process_id='" + process_id_generated + "',@buy_deals='',@sell_deals='',@convert_uom='1082',@convert_frequency='703',,@mode='u',@location_id=NULL,@bookout_match='m',@contract_id=NULL,@commodity_name=NULL,@location_contract_commodity=NULL,@match_group_id=" + parent_object_id; 
                        post_data = { sp_string: sp_string };
                        $.ajax({
                            url: js_form_process_url,
                            data: post_data,
                        }).done(function(data) {
                            //var json_data3 = data['json'][0];
                            var url_param = '?receipt_detail_ids=&delivery_detail_ids=&process_id=' + process_id_generated + '&convert_uom=1082&convert_frequency=703&mode=u&contract_id=NULL&bookout_match=m&location_id=NULL&shipment_name=&match_id=&match_group_id=' + parent_object_id;
                            
                            function_id = 10163710;
                            parent.parent.parent.TRMHyperlink(function_id,url_param);
                            return;
                            var url_match = app_form_path + '_scheduling_delivery/scheduling_workbench/match.php' + url_param;
                            match_win = dhx_wins.createWindow("w2", 0, 0, 650, 500);	
                            match_win.setText('Match');
                            match_win.maximize();
                            match_win.attachURL(url_match, false, true);
                            return;
                        });                        
                    });                    
                });
            });
        }
        else return;        
    }

    function fx_enable_menu_items(state) {
		if (has_rights_grd_manage_emails_iu == 0) {
			manage_email.menu_detail.setItemDisabled('add');
        }
        
        if (state) {
            if (has_rights_grd_manage_emails_del) {
                manage_email.menu_detail.setItemEnabled('delete');
            }
            
            if (has_rights_grd_manage_emails_map) {
                manage_email.menu_detail.setItemEnabled('map');
                var row_id = manage_email.grid_detail.getSelectedRowId();
                if (row_id.indexOf(',') == -1) {
                    var mapped_id = manage_email.grid_detail.cells(row_id, manage_email.grid_detail.getColIndexById('mapped_object')).getValue();
                } else {
                    var mapped_id_arr = [];
                    $.each(row_id.split(','), function(index, value) {
                        mapped_id_arr.push(manage_email.grid_detail.cells(value, manage_email.grid_detail.getColIndexById('mapped_object')).getValue());
                    });
                    var mapped_id = mapped_id_arr.join(',');
                }
                
                if (mapped_id != '' && mapped_id != null) {
                    manage_email.menu_detail.setItemEnabled('unmap');
                    manage_email.menu_detail.setItemDisabled('map');
                } else {
                    manage_email.menu_detail.setItemDisabled('unmap');
                    manage_email.menu_detail.setItemEnabled('map');
                }
            }  
        }        
    }

    //function to open attachment list on popup
    var att_popup_obj_gbl;
    function fx_open_attachment_list(email_id, obj) {        
        var att_list_template = 'filename,filesize';
        var att_list = [];
        var sp_string = "EXEC spa_attachment_detail_info @flag='a', @email_id=" + email_id; 
        post_data = { sp_string: sp_string };

        if (!att_popup_obj_gbl) {
            att_popup_obj_gbl = new dhtmlXPopup();
            att_popup_obj_gbl.attachEvent('onClick', function(id) {
                var list_data = att_popup_obj_gbl.getItemData(id);
                fx_download_file(list_data.filepath, list_data.filename);
            });
        }
           
        var x = window.dhx4.absLeft(obj);
        var y = window.dhx4.absTop(obj);
        var w = obj.offsetWidth;
        var h = obj.offsetHeight;
        att_popup_obj_gbl.show(x,y,w,h);

        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'];
            $.each(json_data, function(key,val) {
                att_list.push({
                    id:val.attachment_detail_info_id, 
                    filename:val.attachment_file_name, 
                    filesize:val.attachment_file_size,
                    filepath:val.attachment_file_path
                },att_popup_obj_gbl.separator);
            });
            att_list.pop();
            att_popup_obj_gbl.attachList(att_list_template, att_list);
        });
    }

    function fx_export_to_pdf() {
		manage_email.grid_detail.toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
	}

	function fx_export_to_excel() {
		manage_email.grid_detail.toExcel(php_script_loc +'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
	}
    
	fx_load_import_rules = function() {
		var email_notes_id;
		import_context_menu = new dhtmlXMenuObject();
		import_context_menu.renderAsContextMenu();
		import_context_menu.loadFromHTML("import_context_menu", false);
		manage_email.grid_detail.enableContextMenu(import_context_menu);
		
		import_context_menu.setItemDisabled('import_rules');
		
		data = {
					"action": "spa_ixp_rules",
					"flag": "6"
				};
		adiha_post_data('return_array', data, '', '', 'fx_load_import_rules_callback', '', '');
		
		manage_email.grid_detail.attachEvent("onBeforeContextMenu", function(rowId, celInd, grid) {
        	var email_type = manage_email.grid_detail.cells(rowId, '7').getValue();
			var attachment = manage_email.grid_detail.cells(rowId, '5').getValue();
			email_notes_id = manage_email.grid_detail.cells(rowId, '0').getValue();
			
			if (email_type == 'Incoming' && attachment != '') 
				return true
			else
				return false;
		});
		
        import_context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
			var exec_call = "EXEC spa_ixp_rules @flag = 'r', @source = '21409', @ixp_rules_id = '" + menuitemId + "', @email_notes_id = " + email_notes_id;
			var param = 'call_from=Import from Email&gen_as_of_date=1&batch_type=c'; 
            adiha_run_batch_process(exec_call, param, 'Import from Email');
		});
	}
	
	fx_load_import_rules_callback = function(return_array) {
		for (var cnt = 0; cnt < return_array.length; cnt++) {
			import_context_menu.addNewChild('dhxWebMenuTopId', cnt+1, return_array[cnt][0], return_array[cnt][1], false, '', '');
		}
	}
    
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
</script>
<style type="text/css" media="screen">
    .highlight 
    {
        background: #D3E18A;
    }

    .light
    {
        background-color: yellow;
    }

    .search {
        background: url('<?php echo $search_img; ?>') no-repeat;
        width: 32px;
        display: inline-block;
        height: 32px;    
    }

    .clear {
        background: url('<?php echo $clear_img; ?>') no-repeat;
        width: 32px;
        display: inline-block;
        height: 32px;    
    }
    .attachment_list_link {
        text-decoration: underline;
        cursor: pointer;
        color: blue;
    }
</style>
</html>