<?php
/**
* Manage documents screen
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
<?php 
    $notes_object_id = get_sanitized_value($_REQUEST['notes_object_id'] ?? 'NULL');
    $notes_category = get_sanitized_value($_REQUEST['notes_category'] ?? '');
    $sub_category_id = get_sanitized_value($_REQUEST['sub_category_id'] ??  '');
    $call_from = get_sanitized_value($_REQUEST['call_from'] ?? 'search_document');
    $parent_object_id = get_sanitized_value($_REQUEST['parent_object_id'] ?? 'NULL');
    $incident_id = get_sanitized_value($_REQUEST['incident_id'] ?? '');
    
    if ($notes_category == 45 || $notes_category == -26) {
        $call_from = 'match_window';
    } else if ($notes_category == 37) {
        $call_from = 'counterparty_window';
    } else if ($notes_category == 44) {
        $call_from = 'manage_approval_window';
    } else if ($notes_category == 55) {
        $call_from = 'credit_enhancement_window';
    } else if ($notes_category == 56) {
        $call_from = 'counterparty_contract_type_window';
    }

    $arr_category_filtered = array();
    if ($notes_category != '') {
        $xml_url = "EXEC spa_manage_document_search @flag='x', @object_id=$notes_category";
        $arr_category_filtered = readXMLURL2($xml_url);
    }
    
    if ($call_from == 'manage_approval_window') {
        $xml_url = "EXEC spa_manage_document_search @flag='w', @activity_id=$notes_object_id";
        $arr_category_filtered = readXMLURL2($xml_url);
    }
    
    $rights_form_manage_documents = 10102900;
    $rights_grd_manage_documents_iu = 10102910;
    $rights_grd_manage_documents_del = 10102911;
    $rights_grd_manage_documents_email = 10102900;
    $rights_grd_manage_documents_incident = 10102912;

    list (
        $has_rights_form_manage_documents,
        $has_rights_grd_manage_documents_iu,
        $has_rights_grd_manage_documents_del,
        $has_rights_grd_manage_documents_email,
        $has_rights_grd_manage_documents_incident
    ) = build_security_rights (
        $rights_form_manage_documents, 
        $rights_grd_manage_documents_iu,
        $rights_grd_manage_documents_del,
        $rights_grd_manage_documents_email,
        $rights_grd_manage_documents_incident
    );

    //rights checked for disable status (not enabled status)
    $add_edit_button_state = empty($has_rights_grd_manage_documents_iu) ? 'true' : 'false';
    $delete_button_state = empty($has_rights_grd_manage_documents_del) ? 'true' : 'false';
    $email_button_state = empty($has_rights_grd_manage_documents_email) ? 'true' : 'false';
    $incident_button_state = empty($has_rights_grd_manage_documents_incident) ? 'true' : 'false';

    $note_category_collapse = ($notes_category > 0) ? 'true' : 'false';

    $layout = new AdihaLayout();
    $json = '[{
                id:             "a", 
                text:           "Search",
                header: true,
                height: 76,
                collapse: false
            },
            {
                id:             "b", 
                text:           "Detail",
                header: true,
                collapse: false
            }]';

    $layout_name = 'layout_manage_document';
    $namespace = 'form_manage_document';
    echo $layout->init_layout($layout_name, '', '2E', $json, $namespace);
    
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

    // Attach TabBar
    $tab_name = 'document_tab';
    $document_tab_id = 'document';
    $incident_tab_id = 'incident';
    $tab_json = '[{id:"' . $document_tab_id . '", text:"Document", active:true}, {id:"' . $incident_tab_id . '", text:"Incident"}]';
    echo $layout->attach_tab_cell($tab_name, 'b', $tab_json);
    $tabbar_obj = new AdihaTab();
    echo $tabbar_obj->init_by_attach($tab_name, $namespace);
    echo $tabbar_obj->set_tab_mode('bottom');

    // Attaching Menu 
    $menu_json = '[ 
        {id:"refresh", img:"refresh.gif", img_disabled:"refresh_dis.gif", text:"Refresh", disabled:0},
        {id:"edit", img:"edit.gif", text:"Edit", items:[
            {id:"add", img:"new.gif", img_disabled:"new_dis.gif", text:"Add", title:"Add", disabled:' . $add_edit_button_state . '},
            {id:"delete", img:"delete.gif", img_disabled:"delete_dis.gif", text:"Delete", title:"Delete", disabled:true}
        ]},
        {id:"email", img:"email.gif", img_disabled:"email_dis.gif", text:"Email", disabled:true},
        {id:"export", img:"export.gif", text:"Export", items:[
            {id:"excel", img:"excel.gif", img_disabled:"excel_dis.gif", text:"Excel", title:"Excel"},
            {id:"pdf", img:"pdf.gif", img_disabled:"pdf_dis.gif", text:"PDF", title:"PDF"}
        ]},
        {id:"exp_col", img:"exp_col.gif", img_disabled:"exp_col_dis.gif", text:"Expand/Collapse", disabled:0}
    ]';
    
    $menu_obj = new AdihaMenu();
    $menu_name = 'document_menu';
    echo $tabbar_obj->attach_menu_cell($menu_name, $document_tab_id);
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', 'toolbar_click');
    
    // Attach Document Grid
    $grid_name = 'document_grid';
    echo $tabbar_obj->attach_grid_cell($grid_name, $document_tab_id);
    echo $tabbar_obj->attach_status_bar($document_tab_id, true, '');
    $document_grid = new GridTable('ManageDocuments');
    echo $document_grid->init_grid_table($grid_name, $namespace);
    echo $document_grid->set_search_filter(false, "#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#combo_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#text_filter,#numeric_filter,#numeric_filter,#text_filter");
    echo $document_grid->enable_paging(50, 'pagingArea_' . $document_tab_id, 'true');
    echo $document_grid->return_init();
    echo $document_grid->enable_multi_select();
    echo $document_grid->attach_event('', 'onRowSelect', 'fx_grid_row_select');
    echo $document_grid->attach_event('', 'onRowDblClicked', 'document_grid_row_dbl_click');
    echo $document_grid->attach_event('', 'onMouseOver', 'grid_on_mouse_over');

    $incident_menu_obj = new AdihaMenu();
    $incident_menu_name = 'incident_menu';
    echo $tabbar_obj->attach_menu_cell($incident_menu_name, $incident_tab_id);
    echo $incident_menu_obj->init_by_attach($incident_menu_name, $namespace);
    echo $incident_menu_obj->load_menu($menu_json);
    echo $incident_menu_obj->attach_event('', 'onClick', 'incident_toolbar_click');
    
    // Attach Incident Grid
    $grid_name = 'incident_grid';
    echo $tabbar_obj->attach_grid_cell($grid_name, $incident_tab_id);
    echo $tabbar_obj->attach_status_bar($incident_tab_id, true, '');
    $incident_grid = new GridTable('ManageDocumentsIncident');
    echo $incident_grid->init_grid_table($grid_name, $namespace);
    echo $incident_grid->set_search_filter(false, "#text_filter,#text_filter,#text_filter,#combo_filter,#combo_filter,#text_filter,#text_filter,#text_filter,#combo_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
    echo $incident_grid->enable_paging(50, 'pagingArea_' . $incident_tab_id, 'true');
    echo $incident_grid->return_init();
    echo $incident_grid->enable_multi_select();
    echo $incident_grid->attach_event('', 'onRowSelect', 'fx_incident_grid_row_select');
    echo $incident_grid->attach_event('', 'onRowDblClicked', 'incident_grid_row_dbl_click');
    echo $incident_grid->attach_event('', 'onMouseOver', 'grid_on_mouse_over');
    
    if ($call_from == 'search_document') {
        echo $menu_obj->disable_item('add');
        echo $incident_menu_obj->disable_item('add');
    }

    echo $layout->close_layout();

    $category_id = '';
    $category_name = '';
    if (array_key_exists(0, $arr_category_filtered)) {
        $category_id = $arr_category_filtered[0]['category_id'];
        $category_name = $arr_category_filtered[0]['category_name'];
    }
?>

<script type="text/javascript">
    var dhx_document, dhx_email_document;
    
    var call_from = '<?php echo $call_from; ?>';
    var download_url = 'force_download.php';
    var sub_category_id = '<?php echo $sub_category_id; ?>';
    var category_id = (call_from == 'search_document' ? 'NULL' : '<?php echo $category_id ?>');
    var category_name = (call_from == 'search_document' ? 'NULL' : '<?php echo $category_name; ?>');
    var notes_object_id = (call_from == 'search_document' ? 'NULL' : '<?php echo $notes_object_id; ?>');
    var parent_object_id = '<?php echo $parent_object_id; ?>';
    var incident_id = '<?php echo $incident_id; ?>';
    
    var post_data = '';
    $(function() {
        dhx_wins = new dhtmlXWindows();
        fx_refresh_grid();
        fx_refresh_incident_grid();
    });

    function search_button_click(name) {
        if (name == 'btn_search') {
            fx_search_click();
        } else if (name == 'btn_clear_search') {
            form_manage_document.form_search.setItemValue('ip_search_text', '');
            form_manage_document.form_search.setItemFocus('ip_search_text');
            fx_refresh_grid();
        }
    }
    
    function fx_search_click() {
        var search_text = form_manage_document.form_search.getItemValue('ip_search_text');
        if (search_text == '') {
            fx_refresh_grid();
            return;
        }
        
        form_manage_document.document_tab.tabs('document').progressOn();

        var sp_string = "EXEC spa_search_engine @flag='s', @searchString='" + search_text + "', @searchTables='document', @callFrom='s'"; 
        post_data = { sp_string: sp_string };
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            
            var param = {
                "flag": "g",
                "action": "spa_application_notes",
                "grid_type": "tg",
                "grouping_column": "category,sub_category,notes_subject",
                "search_result_table": (data['json'].length == 0 ? '-1' : json_data.detail_table),
                "internal_type_value_id": category_id,
                "notes_object_id": notes_object_id
            };
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            form_manage_document.document_grid.clearAndLoad(param_url, function() {
                form_manage_document.document_grid.expandAll();
                fx_highlight_searched_cell();
                
                if (call_from == 'search_document') {
                    form_manage_document.document_grid.setColumnHidden(form_manage_document.document_grid.getColIndexById('parent_object_id'), false);    
                }

                form_manage_document.document_tab.tabs('document').progressOff();
            });
        });
    }
        
    function fx_highlight_searched_cell() {
        var search_text = form_manage_document.form_search.getItemValue('ip_search_text');
        form_manage_document.document_grid.forEachRow(function(rid) {
            form_manage_document.document_grid.forEachCell(rid, function(cell_obj, cid) {
                cell_obj.setValue(cell_obj.getValue().toString().replace(new RegExp(search_text, "i"),"<span style=\"background-color:yellow;\">" + search_text + "</span>"));
            });
        });
    }

    function document_grid_row_dbl_click(row_id, cell_index) {
        fx_edit_document('u', row_id, cell_index);
    }

    function grid_on_mouse_over(row, col) {
        if (col == this.getColIndexById('notes_attachment')) {
            this.cells(row, col).cell.title = this.cells(row, this.getColIndexById('attachment_file_name')).getTitle();
        } else if (col == this.getColIndexById('parent_object_id')) {
            //no tooltip
        } else {
            this.cells(row, col).cell.title = this.cells(row, col).getTitle();
        }
    }
    
    function fx_refresh_grid() {
        form_manage_document.document_tab.tabs('document').progressOn();
        var param = {
            "flag": "g",
            "action": "spa_application_notes",
            "grid_type": "tg",
            "grouping_column": "category,sub_category,notes_subject",
            "internal_type_value_id": category_id,
            "category_value_id": sub_category_id,
            "notes_object_id": notes_object_id,
            "download_url": download_url
        };
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;

        form_manage_document.document_grid.clearAndLoad(param_url, function() {
            form_manage_document.document_grid.expandAll();
            form_manage_document.document_grid.filterByAll();

            form_manage_document.document_menu.setItemDisabled('email');
            form_manage_document.document_menu.setItemDisabled('delete');

            form_manage_document.document_tab.tabs('document').progressOff();
        });
    }
    
    function fx_edit_document(mode, rid, cid) {
        var title_text, add_mode;
        var grid_sub_cat = '';
        if (mode == 'u') {
            title_text = 'Edit Document' ;
            var notes_id = form_manage_document.document_grid.cells(rid, form_manage_document.document_grid.getColIndexById('notes_id')).getValue();
            grid_sub_cat = form_manage_document.document_grid.cells(rid, form_manage_document.document_grid.getColIndexById('sub_category_id')).getValue();

            if (rid.split('_')[0].toLowerCase() == 'incomingemail' || rid.split('_')[0].toLowerCase() == 'outgoingemail') {
                fx_open_email_item(notes_id);
                return;
            }
        } else {
            title_text = 'Add Document' ;
            add_mode = 'add';
            var notes_id = 'NULL';
        }
        
        if (grid_sub_cat == '42003') {
            return;  
        } 
       
        if (mode == 'u') {
            if (notes_id == 0 || notes_id == "") {
                return;
            }
        }
        
        var notes_object_id = '<?php echo $notes_object_id; ?>';
        var sub_category_id = '<?php echo $sub_category_id; ?>';
        var parent_object_id = '<?php echo $parent_object_id; ?>';
        if (grid_sub_cat != '') {
            sub_category_id = grid_sub_cat;
            notes_object_id = form_manage_document.document_grid.cells(rid, form_manage_document.document_grid.getColIndexById('notes_object_id')).getValue();
            parent_object_id = form_manage_document.document_grid.cells(rid, form_manage_document.document_grid.getColIndexById('parent_object_id')).cell.innerText;
        }
        
        if (sub_category_id == '') {
            sub_category_id = 'NULL'; 
        }
            
        var param = 'manage.documents.add.edit.php?mode=' + mode +
                            '&notes_id=' + notes_id + 
                            '&notes_object_id=' + notes_object_id + 
                            '&category_id=' + category_id + 
                            '&sub_category_id=' + sub_category_id +
                            '&category_name=' + category_name +
                            '&call_from=' + call_from + 
                            '&parent_object_id=' + parent_object_id + 
                            '&is_pop=true'; 
        form_manage_document.unload_document_window();
        if (!dhx_document) {
            dhx_document = new dhtmlXWindows();
        }
        
        w1 = dhx_document.createWindow("w1", 0, 0, 650, 500);
        w1.centerOnScreen();
        w1.setText(title_text);
        w1.attachURL(param, false, true);
        w1.attachEvent('onClose', function(win) {
            fx_refresh_grid();
            return true;
        })
    }

    function fx_open_email_item(notes_id) {
        var title_text = 'Email Subject';
        var param = 'email.documents.php?mode=u&call_from=manage_document&notes_id=' + notes_id;
        if (!dhx_email_document) {
            dhx_email_document = new dhtmlXWindows();
        }
        win_add_email = dhx_email_document.createWindow("w1", 0, 0, 650, 500);      
        win_add_email.setText(title_text); 
        win_add_email.centerOnScreen();
        win_add_email.attachURL(param, false, true);

        win_add_email.attachEvent('onClose', function(win) {
            fx_refresh_grid();
            return true;
        });
    }
    
    /**
     * [unload_document_window Unload document window]
     */
    form_manage_document.unload_document_window = function() {
        if (dhx_document != null && dhx_document.unload != null) {
            dhx_document.unload();
            dhx_document = w1 = null;
        }
    }

    /**
     * [unload_email_document_window Unload email document window]
     */
    form_manage_document.unload_email_document_window = function() {
        if (dhx_email_document != null && dhx_email_document.unload != null) {
            dhx_email_document.unload();
            dhx_email_document = w1 = null;
        }
    }

    function open_email_document() {
        var selected_rid = form_manage_document.document_grid.getSelectedRowId();
        
        if (selected_rid.indexOf(',') > -1) {
            show_messagebox("Please select only one item from grid.");
            return;
        }

        var notes_id = form_manage_document.document_grid.cells(selected_rid, form_manage_document.document_grid.getColIndexById('notes_id')).getValue();
        var category_id = form_manage_document.document_grid.cells(selected_rid, form_manage_document.document_grid.getColIndexById('category_id')).getValue();
        var file_attachment_name = form_manage_document.document_grid.cells(selected_rid, form_manage_document.document_grid.getColIndexById('attachment_file_name')).getValue();
        var notes_attachment_path = form_manage_document.document_grid.cells(selected_rid, form_manage_document.document_grid.getColIndexById('notes_attachment_real')).getValue();
        
        var title_text = 'Email Document';
        var param = 'email.documents.php?' +
                    'notes_id=' + notes_id +
                    '&internal_type_value_id=' + category_id +
                    '&notes_attachment_path=' + notes_attachment_path +
                    '&file_attachment_name=' + file_attachment_name + 
                    '&notes_object_id=' + notes_object_id; 
        
        form_manage_document.unload_email_document_window();
        if (!dhx_email_document) {
            dhx_email_document = new dhtmlXWindows();
        }
        
        email_document = dhx_email_document.createWindow("w1", 0, 0, 650, 500);     
        email_document.centerOnScreen();
        email_document.setText(title_text);
        email_document.attachURL(param, false, true);

        email_document.attachEvent('onClose', function(win) {
            fx_refresh_grid();
            return true;
        });
    }
    
    function fx_delete_document() {
        var only_email = false;
        var row_id = form_manage_document.document_grid.getSelectedRowId();
        if (row_id.indexOf(',') == -1) {
            var notes_id = form_manage_document.document_grid.cells(row_id, form_manage_document.document_grid.getColIndexById('notes_id')).getValue();
            var notes_category = form_manage_document.document_grid.cells(form_manage_document.document_grid.getParentId(row_id), form_manage_document.document_grid.getColIndexById('notes_subject')).getValue();
            if (notes_category == 'Outgoing Email' || notes_category == 'Incoming Email') {
                only_email = true;
            } else {
                only_email = false;
            }
        } else {
            var note_id_arr = [];
            var notes_category_arr = [];
            $.each(row_id.split(','), function(index, value) {
                if (form_manage_document.document_grid.hasChildren(value) == 0) {
                    var notes_cat_each = form_manage_document.document_grid.cells(form_manage_document.document_grid.getParentId(value), form_manage_document.document_grid.getColIndexById('notes_subject')).getValue();
                    if (notes_cat_each != 'Outgoing Email' && notes_cat_each != 'Incoming Email') {
                        note_id_arr.push(form_manage_document.document_grid.cells(value, form_manage_document.document_grid.getColIndexById('notes_id')).getValue());
                    }
                    notes_category_arr.push(notes_cat_each);
                }
            });
            var notes_id = note_id_arr.join(',');
            var notes_category = _.uniq(notes_category_arr).join(',');
            
            if (notes_category == 'Outgoing Email' || notes_category == 'Incoming Email') {
                only_email = true;
            } else {
                only_email = false;
            }
        }
        
        if (only_email) {
            show_messagebox("Email cannot be deleted. Please delete from Manage Email.");
            return;
        }
        
        form_manage_document.layout_manage_document.progressOn();
        var sp_string = "EXEC spa_application_notes @flag='d', @notes_ids='" + notes_id + "'"; 
        post_data = { sp_string: sp_string };
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if (json_data.errorcode == 'Success') {
                success_call('Changes have been saved successfully', 'error');
                fx_refresh_grid();
            } else {
                show_messagebox(json_data.recommendation);
            }
            form_manage_document.layout_manage_document.progressOff();
        });
    }
    
    function fx_grid_row_select(rowId, cellIndex) {
        var has_child = form_manage_document.document_grid.hasChildren(rowId);
        var grid_sub_cat = form_manage_document.document_grid.cells(rowId, form_manage_document.document_grid.getColIndexById('sub_category_id')).getValue();
        
        if (has_child == 0) {
            if (!(<?php echo $email_button_state; ?>)) {
                form_manage_document.document_menu.setItemEnabled('email');
            }
            
            if ((!(<?php echo $delete_button_state; ?>) && (grid_sub_cat != '42003'))) {
                form_manage_document.document_menu.setItemEnabled('delete');
            } else {
                form_manage_document.document_menu.setItemDisabled('delete');
            }
        } else {
            form_manage_document.document_menu.setItemDisabled('email');
            form_manage_document.document_menu.setItemDisabled('delete');
        }
    }

    function toolbar_click(id) {
        switch(id) {
            case "add":
                fx_edit_document('i', null, null);
                break;
            case "delete":
                confirm_messagebox('Are you sure you want to delete?', function() {
                    fx_delete_document();
                });
                break;
            case "email":
                open_email_document();
                break;
            case "pdf":
                fx_export_to_pdf();
                break;
            case "excel":
                fx_export_to_excel();
                break;
            case "refresh":
                fx_refresh_grid();
                break;
            case "exp_col":
                fx_expand_all();
                break;
            default:
                //do nothing
                break;
        }
    }
    
    function fx_export_to_pdf() {
        form_manage_document.document_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
    }

    function fx_export_to_excel() {
        form_manage_document.document_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
    }

    function fx_click_parent_object_id_link(category_id, parent_object_id) {
        var function_id = '';

        if (category_id == 27 || category_id == 26 || category_id == 25) {
            var  sp_string = "SELECT * FROM portfolio_hierarchy ph WHERE ph.entity_id = " + parent_object_id;
            post_data = {sp_string : sp_string};
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                var json_data = data['json'][0];
                function_id = 10101200;
                var label_name = '';
                if (json_data.hierarchy_level == 0) {
                    label_name = 'Book';
                } else if (json_data.hierarchy_level == 1) {
                    label_name = 'Strategy';
                } else if (json_data.hierarchy_level == 2) {
                    label_name = 'Subsidiary';
                }
                parent.parent.parent.TRMHyperlink(function_id, parent_object_id, label_name, json_data.entity_name);
            });
        } else if (category_id == 33) {
            function_id = 10131010;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id, 'n');
        } else if (category_id == 37) {
            function_id = 10105800;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id);
        } else if (category_id == 38) {
            function_id = 10221300;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id);
        } else if (category_id == 55) {
            function_id = 10101125;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id);
        } else if (category_id == 56) {  
            function_id = 10105830;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id);
        } else if (category_id == 40) {
            var sp_string = "SELECT cg.contract_type_def_id FROM contract_group cg WHERE cg.contract_id = " + parent_object_id;
            post_data = {sp_string : sp_string};
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                var json_data = data['json'][0];
                var function_id = 0;
                var call_from = '';
                if (json_data.contract_type_def_id == 38400) {
                    function_id = 10211200;
                    call_from = 'standard';
                } else if (json_data.contract_type_def_id == 38401) {
                    function_id = 10211300;
                    call_from = 'nonstandard';
                } 
                parent.parent.parent.TRMHyperlink(function_id, parent_object_id, call_from);
            });

        } else if (category_id == '-1') { //workflow
            function_id = 10106700;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id, 'manage_email');
        } else if (category_id == -26 || category_id == 45) {
            if (category_id == -26) {
                var sp_string = "EXEC spa_scheduling_workbench @flag='s', @match_group_id=" + parent_object_id; 
            } else if (category_id == 45) {
                var sp_string = "EXEC spa_scheduling_workbench @flag='s', @match_group_shipment_id=" + parent_object_id; 
            }
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
        } else if (category_id == 400141) {
            function_id = 12101700;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id);
        }
        else return;
    }
    
    function fx_download_file(file_path) {
        file_path = file_path.replace(/\+/g, '<<PLUS>>');
        file_path = file_path.replace(/\#/g, '<<HASH>>');
        file_path = file_path.replace(/\&/g, '<<AMP>>');
        window.location = js_php_path + download_url + '?path=' + file_path;
    }

    var expand_state_gbl = true;
    function fx_expand_all() {
        if (expand_state_gbl) {
            form_manage_document.document_grid.collapseAll();
            expand_state_gbl = false;
        } else {
            form_manage_document.document_grid.expandAll();
            expand_state_gbl = true;
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

    /*
     *-------------------------- INCIDENT GRID FUNCTIONS START ---------------------------*
     */
    function incident_grid_row_dbl_click(row_id, cell_index) {
        fx_open_incident('u', row_id, cell_index);
    }
    
    /*
     * [Incident Toolbar click function]
     */
    function incident_toolbar_click(id) {
        switch(id) {
            case "add":
                fx_open_incident('i', null, null);
                break;
            case "delete":
                confirm_messagebox('Are you sure you want to delete?', function() {
                    fx_delete_incident();
                });
                break;
            case "email":
                 open_email_document_incident();
                break;
            case "pdf":
                fx_export_to_pdf_incident();
                break;
            case "excel":
                fx_export_to_excel_incident();
                break;
            case "refresh":
                fx_refresh_incident_grid();
                break;
            case "exp_col":
                fx_incident_expand_all();
                break;
            default:
                //do nothing
                break;
        }
    }
    
    function fx_export_to_pdf_incident() {
        form_manage_document.incident_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
    }
    
    function fx_export_to_excel_incident() {
        form_manage_document.incident_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
    }
    
    function open_email_document_incident() {
        var selected_rid = form_manage_document.incident_grid.getSelectedRowId();
          if (selected_rid.indexOf(',') > -1) {
            show_messagebox('Please select only one item from grid.');
            return;
        }
        
        var notes_id = form_manage_document.incident_grid.cells(selected_rid, form_manage_document.incident_grid.getColIndexById('notes_id')).getValue();
        var category_id = form_manage_document.incident_grid.cells(selected_rid, form_manage_document.incident_grid.getColIndexById('category_id')).getValue();
        var file_attachment_name = form_manage_document.incident_grid.cells(selected_rid, form_manage_document.incident_grid.getColIndexById('attachment_file_name')).getValue();
       
        var title_text = 'Email Document';
        var param = 'email.documents.php?' +
                    'notes_id=' + notes_id +
                    '&internal_type_value_id=' + category_id +
                    '&file_attachment_name=' + file_attachment_name;
        
        form_manage_document.unload_email_document_window();
        if (!dhx_email_document) {
            dhx_email_document = new dhtmlXWindows();
        }
        
        email_document = dhx_email_document.createWindow("w1", 0, 0, 650, 500);     
        email_document.centerOnScreen();
        email_document.setText(title_text);
        email_document.attachURL(param, false, true);

        email_document.attachEvent('onClose', function(win) {
            fx_refresh_grid();
            return true;
        });
    }
    
    /*
     * [Open Incident window]
     */
    function fx_open_incident(mode, rowId, cellIndex) {
        var incident_log_id = '';
        if (mode == 'u') {
            var incident_log_id = form_manage_document.incident_grid.cells(rowId,form_manage_document.incident_grid.getColIndexById("incident_log_id")).getValue();
        }
        
        if (mode == 'u' && (incident_log_id == 0 || incident_log_id == "")) {
            return;
        }
        
        var incident_log_window = new dhtmlXWindows();
        
        var src = 'incident.log.php?category_id=' + category_id + '&sub_category_id=' + sub_category_id + '&notes_object_id=' + notes_object_id + '&parent_object_id=' + parent_object_id + '&incident_log_id=' + incident_log_id; 
        var incident_log_win_obj = incident_log_window.createWindow('w1', 0, 0, 1300, 700);
        incident_log_win_obj.setText("Incident");
        incident_log_win_obj.centerOnScreen();
        incident_log_win_obj.setModal(true);
        incident_log_win_obj.maximize();
        incident_log_win_obj.attachURL(src, false, true);
    }
    
    /*
     * [Delete the Incident]
     */
    function fx_delete_incident() {
        var row_id = form_manage_document.incident_grid.getSelectedRowId();
        
        if (row_id.indexOf(',') == -1) {
            var incident_log_id = form_manage_document.incident_grid.cells(row_id, form_manage_document.incident_grid.getColIndexById('incident_log_id')).getValue();
        } else {
            var incident_log_arr = [];
            $.each(row_id.split(','), function(index, value) {
                if (form_manage_document.incident_grid.hasChildren(value) == 0) {
                    incident_log_arr.push(form_manage_document.incident_grid.cells(value, form_manage_document.incident_grid.getColIndexById('incident_log_id')).getValue());
                }
            });
            var incident_log_id = incident_log_arr.join(',');
        }
        
        var post_data = {sp_string: "EXEC spa_incident_log @flag='d', @incident_log_id='" + incident_log_id + "'" };
            
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if (json_data.errorcode == 'Success') {
                success_call(json_data.message, 'error');
                fx_refresh_incident_grid();
            } else {
                show_messagebox(json_data.message);
            }
        });
    }
    
    /*
     * [Refresh the grid]
     */
    function fx_refresh_incident_grid() {
        form_manage_document.document_tab.tabs('incident').progressOn();
        var param = {
                    "flag": "g",
                    "action": "spa_incident_log",
                    "grid_type": "tg",
                    "grouping_column": "category,incident_type,incident,description",
                    "category":category_id,
                    "notes_object":notes_object_id,
                    "download_url":download_url
                };
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        
        form_manage_document.incident_grid.clearAndLoad(param_url, function() {
            form_manage_document.incident_grid.expandAll();
            form_manage_document.incident_menu.setItemDisabled('email');
            form_manage_document.incident_menu.setItemDisabled('delete');
            form_manage_document.document_tab.tabs('incident').progressOff();
        });
    }

    /*
     * [Expand/Collapse Grid]
     */
    var incident_expand_state_gbl = true;
    function fx_incident_expand_all() {
        if (incident_expand_state_gbl) {
            form_manage_document.incident_grid.collapseAll();
            incident_expand_state_gbl = false;
        } else {
            form_manage_document.incident_grid.expandAll();
            incident_expand_state_gbl = true;
        }
    }
    
    function fx_incident_grid_row_select(rowId, cellIndex) {
        var has_child = form_manage_document.incident_grid.hasChildren(rowId);
        var grid_sub_cat = form_manage_document.incident_grid.cells(rowId, form_manage_document.incident_grid.getColIndexById('sub_category_id')).getValue();
        
        if (has_child == 0) {
            if (!(<?php echo $email_button_state; ?>)) {
                form_manage_document.incident_menu.setItemEnabled('email');
            }
            
            if ((!(<?php echo $delete_button_state; ?>) && (grid_sub_cat != '42003'))) {
                form_manage_document.incident_menu.setItemEnabled('delete');
            } else {
                form_manage_document.incident_menu.setItemDisabled('delete');
            }
        } else {
            form_manage_document.incident_menu.setItemDisabled('email');
            form_manage_document.incident_menu.setItemDisabled('delete');
        }
    }
    /*
     *-------------------------- INCIDENT GRID FUNCTIONS END ---------------------------*
     */
</script>
<style type="text/css">
    .search {
        background: url('<?php echo $image_path . 'dhxform_web/search.png'; ?>') no-repeat;
        width: 32px;
        display: inline-block;
        height: 32px;    
    }

    .clear {
        background: url('<?php echo $image_path . 'dhxform_web/close.png'; ?>') no-repeat;
        width: 32px;
        display: inline-block;
        height: 32px;    
    }
    </style>
</html>