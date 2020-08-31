<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
    require('../../../adiha.php.scripts/components/include.file.v3.php'); 
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
    ?>
</head>
<body>
<?php 
	$form_namespace = 'confirmationHistory';
    $deal_ids = (isset($_POST["deal_ids"]) && $_POST["deal_ids"] != '') ? get_sanitized_value($_POST["deal_ids"]) : 'NULL';

	$layout_json = '[{id: "a", header:false}]';
	
    $toolbar_obj = new AdihaToolbar();
    $layout_obj = new AdihaLayout();
    $menu_obj = new AdihaMenu();
    $grid_obj = new GridTable('confirmation_history');
    $permission = $grid_obj->return_permission();
    $edit_permission = ($permission['edit'] == true) ? 'true' : 'false';
    $delete_permission = ($permission['delete'] == true) ? 'true' : 'false';

    $category_name = 'Deal';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);

    $sub_category_name = 'Deal Confirm';
    $sub_category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 42000 AND code = '" . $sub_category_name . "'";
    $sub_category_data = readXMLURL2($sub_category_sql);

    $menu_json = '[  
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                        {id:"new", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:' . $edit_permission .'},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title:"Delete", enabled:false},
                    ]},
                    {id:"t2", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]}                     
                    ]';

    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_menu_cell('menu', 'a');

    echo $menu_obj->init_by_attach('menu', $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');

    echo $layout_obj->attach_toolbar('toolbar');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');

    echo $layout_obj->attach_grid_cell('grid', 'a');
    echo $layout_obj->attach_status_bar("a", true);
    
    echo $grid_obj->init_grid_table('grid', $form_namespace);
    echo $grid_obj->set_column_auto_size();
    echo $grid_obj->set_search_filter(true, "");
    echo $grid_obj->enable_paging(50, 'pagingArea_a', 'true');       
    echo $grid_obj->enable_column_move();
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_data('', $deal_ids);
    echo $grid_obj->attach_event("", "onSelectStateChanged", $form_namespace . '.grid_row_selection');
    echo $grid_obj->load_grid_functions();

    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
<script type="text/javascript">
    $(function (){
        var object_id = "<?php echo $deal_ids; ?>";
        add_manage_document_button(object_id, confirmationHistory.toolbar, true);
    });

    confirmationHistory.toolbar_click = function(id) {
        if (id == 'documents') {
            open_document();
        }
    }
    /**
     * [menu_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    confirmationHistory.menu_click = function(id) {
        switch(id) {
            case "refresh":
                var changed_rows = confirmationHistory.grid.getChangedRows(true);
                if (changed_rows != '') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to refresh grid?",
                        callback: function(result) {
                            if (result) {
                                confirmationHistory.refresh_grid();
                                confirmationHistory.grid_row_selection(null);
                            }
                        }
                     });
                } else {
                    confirmationHistory.refresh_grid();
                    confirmationHistory.grid_row_selection(null);
                }
                break;
            case "new":
                confirmationHistory.add_confirmation_status();
                break;
            case "pdf":
                confirmationHistory.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                confirmationHistory.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case "delete":
                confirmationHistory.delete_data();
                break;
            case "cancel":
                document.getElementById("success_status").value = 'Cancel';
                break;
        }
    }

    /**
     * [grid_row_selection Grid rows select/unselect event function]
     * @param  {[string]} row_ids [row ids]
     */
    confirmationHistory.grid_row_selection = function(row_ids) {
        var has_delete_rights = Boolean('<?php echo $delete_permission; ?>');
        var has_edit_rights = Boolean('<?php echo $edit_permission; ?>');

        if (row_ids != null) {
            if (has_delete_rights) confirmationHistory.menu.setItemEnabled('delete');
        } else {
            confirmationHistory.menu.setItemDisabled('delete');
        }
    }

    function open_document() {
        var deal_ids = "<?php echo $deal_ids; ?>";
        var category_id = '<?php echo $category_data[0]['value_id'];?>';
        var sub_category_id = '<?php echo $sub_category_data[0]['value_id'] ?? '';?>';
        var category_info = {};
        category_info.category_id = category_id;
        category_info.sub_category_id = sub_category_id;
        document_window = new dhtmlXWindows();
        
        var win_title = 'Document';
        var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?call_from=deal&sub_category_id=' + sub_category_id + '&notes_object_id=' + deal_ids + '&is_pop=true';

        var win = document_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {notes_category:category_id});

        win.attachEvent('onClose', function(w) {
            update_document_counter(deal_ids, confirmationHistory.toolbar, category_info);
            return true;
        });
    }

    /**
     * [save_callback Save callback]
     * @param  {[array]} result [return array]
     */
    confirmationHistory.save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            cstatus_doc.close();
            confirmationHistory.refresh_grid();
            confirmationHistory.grid_row_selection(null);
            document.getElementById("success_status").value = 'Success';
        }
        cstatus_doc.progressOff();
    }

    /**
     * [delete_callback Delete callback]
     * @param  {[array]} result [return array]
     */
    confirmationHistory.delete_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            confirmationHistory.refresh_grid();
            confirmationHistory.grid_row_selection(null);
            document.getElementById("success_status").value = 'Success';
        }
    }

    /**
     * [delete_data Delete Data]
     */
    confirmationHistory.delete_data = function() {
        var new_ids = confirmationHistory.grid.getColumnValues(0);
        data = {"action": "spa_confirm_status", "flag":"d", "confirm_status_ids":new_ids};
        adiha_post_data("alert", data, '', '', 'confirmationHistory.delete_callback');
    }
    
    confirmationHistory.add_confirmation_status = function() {
        var client_date_format = '<?php echo $date_format; ?>';
        var today = new Date();
        today = dates.convert_to_sql(today);
        var cstatus_form_data = [
                                {type: "settings", labelWidth: 'auto', inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft:ui_settings['offset_left']}, 
                                {type: "combo", name: "confirm_status", label: "Confirm Status",filtering:"true",required:"true","userdata":{"validation_message":"Required Field"}},
                                {type: 'newcolumn'},
                                {type: "calendar", name: "as_of_date", label: "As of Date",value: today, "dateFormat": client_date_format,"serverDateFormat":"%Y-%m-%d"},          
                                {type: 'newcolumn'},                                                
                                {type: "input", name: "confirm_id", label: "Confirm ID"},                                       
                                {type: "input", name: "comment2", label: "Comment2",rows:4},
                                {type: 'newcolumn'},
                                {type: "input", name: "comment1", label: "Comment1",rows:4}

                            ];
        var cstatus_window = new dhtmlXWindows();
        cstatus_doc = cstatus_window.createWindow('w1', 0, 0, 540, 300);
        cstatus_doc.setText("Confirm Status");
        cstatus_doc.centerOnScreen();
        cstatus_doc.setModal(true);
        cstatus_form = cstatus_doc.attachForm(cstatus_form_data, true);
        
        var cstatus_menu = cstatus_doc.attachMenu({
            icons_path: js_image_path + "dhxmenu_web/",
            json: '[{id:"save", text:"Save", img:"save.gif", imgdis:"new_save.gif", title: "Save", enabled: 1}]'
        });
        
       
        var comfirm_status_cmb = cstatus_form.getCombo('confirm_status');
        var cm_param = {
                            "action": "spa_StaticDataValues",
                            "flag":"h",
                            "type_id": "17200", 
                            "call_from": "form",
                            "has_blank_option": false
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        comfirm_status_cmb.load(url, function(){
            comfirm_status_cmb.selectOption(0);
        });

        
        cstatus_menu.attachEvent("onClick", function(id, zoneId, cas){
             if (id == 'save') {
                cstatus_doc.progressOn();
                var status = validate_form(cstatus_form);
                if (status == false) {
                    return;
                }
                var deal_id = '<?php echo $deal_ids;?>';
                var grid_xml = '<Grid><GridRow '
                grid_xml += ' id="New_123"';
                grid_xml += ' deal_id="' + deal_id + '"';
                grid_xml += ' confirm_status="' + cstatus_form.getItemValue('confirm_status') + '"';
                grid_xml += ' as_of_date="' + cstatus_form.getItemValue('as_of_date', true) + '"';
                grid_xml += ' comment1="' + cstatus_form.getItemValue('comment1') + '"';
                grid_xml += ' comment2="' + cstatus_form.getItemValue('comment2') + '"';
                grid_xml += ' confirm_id="' + cstatus_form.getItemValue('confirm_id') + '"';
                grid_xml += ' user_id=""';
                grid_xml += ' time_stamp=""';
                grid_xml += '></GridRow></Grid>';
                data = {
                            "action": "spa_confirm_status", 
                            "flag": 'i',
                            "xml": grid_xml
                        }
                result = adiha_post_data("alert", data, "", "", "confirmationHistory.save_callback");
             }
        });
    }
</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>