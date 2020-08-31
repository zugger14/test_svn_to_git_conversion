<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
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
</head>
<body>
<?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');

    $deal_id = (isset($_REQUEST["deal_id"]) && $_REQUEST["deal_id"] != '') ? get_sanitized_value($_REQUEST["deal_id"]) : 'NULL';
    $view_deleted = (isset($_REQUEST["view_deleted"]) && $_REQUEST["view_deleted"] != '') ? get_sanitized_value($_REQUEST["view_deleted"]) : 'n';
    $sp_deal_lock = "EXEC spa_deal_update @flag='l', @source_deal_header_id=" . $deal_id;
    $sp_deal_header = "EXEC spa_deal_update @flag='h', @source_deal_header_id=" . $deal_id . ", @view_deleted='" . $view_deleted . "'";
    $sp_deal_detail = "EXEC spa_deal_update @flag='d', @source_deal_header_id=" . $deal_id . ", @view_deleted='" . $view_deleted . "'";
    $rights_deal_edit = 10131010;
    $rights_document = 10102900;
	$rights_schedule_deal = 10131028;

    $disable_term = 'false';
    list (
         $has_rights_deal_edit,
         $has_document_rights,
         $has_schedule_deal
    ) = build_security_rights(
         $rights_deal_edit,
         $rights_document,
         $rights_schedule_deal
    );

    $lock_data = readXMLURL2($sp_deal_lock);
    $header_data = readXMLURL2($sp_deal_header);
    $detail_data = readXMLURL2($sp_deal_detail);

    $is_locked = $lock_data[0]['deal_locked'];
    $disable_term = ($lock_data[0]['disable_term'] == 'n') ? true : false;
    $deal_date = $lock_data[0]['deal_date'];

    if($is_locked == 'y') $has_rights_deal_edit = 'false';
    if ($view_deleted == 'y') {
        $has_rights_deal_edit = 'false';
    }

    $term_edit_privilege = $has_rights_deal_edit;
    if ($has_rights_deal_edit && !$disable_term) $term_edit_privilege = 'false';

    $tab_data = array();
    $form_data = array();

    if (is_array($header_data) && sizeof($header_data) > 0) {
        foreach ($header_data as $data) {
            array_push($tab_data, $data['tab_json']);
            if (!is_array($form_data[$data['tab_id']]))
                $form_data[$data['tab_id']] = array();

            array_push($form_data[$data['tab_id']], $data['form_json']);
        }
    }
    $header_tab_data = '[' . implode(",", $tab_data) . ']';
    
    $form_namespace = 'dealDetail';
    $layout_json = '[{id: "a", text: "Deal", header:true}, {id: "b", text:"<div><a class=\"undock_detail undock_custom\" title=\"Undock\" onClick=\"dealDetail.undock_details()\"></a>Details</div>", header:true}]';
    $page_toolbar_json = '[{id:"save", type: "button", img:"save.gif", imgdis:"save_dis.gif", enabled:'. (int)($has_rights_deal_edit) . ', text:"Save", title: "Save"}]';
    
    $layout_obj = new AdihaLayout();
    $page_toolbar = new AdihaToolbar();
    $tab_obj = new AdihaTab();

    echo $layout_obj->init_layout('deal_detail', '', '2E', $layout_json, $form_namespace);
    
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $page_toolbar->init_by_attach('toolbar', $form_namespace);
    echo $page_toolbar->load_toolbar($page_toolbar_json);
    echo $page_toolbar->attach_event('', 'onClick', $form_namespace . '.page_toolbar_click');
    echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_detail_event');
    echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_detail_event');
    echo $layout_obj->attach_tab_cell('deal_tab', 'a', $header_tab_data);
    echo $tab_obj->init_by_attach('deal_tab', $form_namespace);

    if (is_array($form_data) && sizeof($form_data) > 0) {
        foreach ($form_data as $tab_id => $form_json) {
            $form_obj[$tab_id] = new AdihaForm();
            echo $tab_obj->attach_form_cell('form_' . $tab_id, $tab_id);
            echo $form_obj[$tab_id]->init_by_attach('form_' . $tab_id, $form_namespace);
            echo $form_obj[$tab_id]->load_form($form_json[0]);
            echo $form_obj[$tab_id]->attach_event('', 'onChange', $form_namespace . '.form_change');
        }
    }

    // attach Menu
    echo $layout_obj->attach_menu_cell('deal_detail_menu', 'b');
    $menu_object = new AdihaMenu();
    $menu_json = '[  
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id:"export", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]},
                    {id:"edit", enabled:'. (int)$has_rights_deal_edit . ', text:"Edit", img:"edit.gif", items:[
                        {id:"undo_cell", text:"Undo Cell Edit", img:"undo.gif", imgdis:"undo_dis.gif", title: "Undo Cell Edit"},
                        {id:"redo_cell", text:"Redo Cell Edit", img:"redo.gif", imgdis:"redo_dis.gif", title: "Redo Cell Edit"}
                    ]},
                    {id:"actions", text:"Actions", img:"action.gif", imgdis:"action_dis.gif", enabled:'. (int)$has_rights_deal_edit . ', items:[
                        {id:"add_term", text:"Add Term", img:"add.gif", imgdis:"add_dis.gif", title: "Add Term", enabled:false},
                        {id:"add_leg", text:"Add Leg", img:"add.gif", imgdis:"add_dis.gif", title: "Add Leg", enabled:false},
                        {id:"update_volume", text:"Update Volume", img:"update_volume.gif", imgdis:"update_volume_dis.gif", title: "Update Volume", enabled:false},
                        {id:"schedule_deal", text:"Schedule Deal", img:"run_view_schedule.gif", imgdis:"run_view_schedule_dis.gif", title: "Schedule Deal", enabled:false}
                    ]}
                    ]';
    echo $menu_object->init_by_attach('deal_detail_menu', $form_namespace);
    echo $menu_object->load_menu($menu_json);
    echo $menu_object->attach_event('', 'onClick', $form_namespace . '.deal_menu_click');

    //attach grid
    $grid_obj = new AdihaGrid();
    echo $layout_obj->attach_grid_cell('grid', 'b');
    echo $layout_obj->attach_status_bar("b", true);

    echo $grid_obj->init_by_attach('grid', $form_namespace);
    echo $grid_obj->enable_column_move();
    echo $grid_obj->enable_multi_select(true);
    echo $grid_obj->enable_paging(25, 'pagingArea_b'); 
    echo $grid_obj->attach_event('', 'onEditCell', $form_namespace . '.deal_detail_edit');
    echo $grid_obj->load_config_json($detail_data[0]['config_json']);
    echo $grid_obj->set_column_auto_size();
    echo $grid_obj->set_search_filter(false, $detail_data[0]['filter_list']);
    echo $grid_obj->set_validation_rule($detail_data[0]['validation_rule']);
    echo $grid_obj->attach_event("", "onSelectStateChanged", $form_namespace . '.grid_row_selection');

    $combo_fields = array();
    $combo_fields = explode("||||", $detail_data[0]['combo_list']);
    
    foreach ($combo_fields as $combo_column) {
        $json_array = array();
        $json_array = explode("::::", $combo_column);
        echo $grid_obj->load_combo($json_array[0], $json_array[1]);
    }

    $context_menu_json = '[{id:"apply_to", text:"Apply to..", title: "Apply to.."}]';
    $context_menu = new AdihaMenu();
    echo $context_menu->init_menu('context_menu', $form_namespace);
    echo $context_menu->render_as_context_menu();
    echo $context_menu->attach_event('', 'onClick', $form_namespace . '.context_menu_click');
    echo $context_menu->load_menu($context_menu_json);

    echo $grid_obj->enable_context_menu($form_namespace . '.context_menu');
    //echo $grid_obj->load_grid_data($detail_data[0][data_sp], 'g', '', false);
    echo $grid_obj->load_grid_functions();
    echo $layout_obj->close_layout();

    $category_name = 'Deal';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);
?>
</body>
<script type="text/javascript">
    var category_id = '<?php echo $category_data[0]['value_id'];?>';
    var apply_to_window;
    var document_window;

    $(function() {
        var has_document_rights = '<?php echo (int)$has_document_rights;?>';
        var deal_id = '<?php echo $deal_id; ?>';
        add_manage_document_button(deal_id, dealDetail.toolbar, has_document_rights);
        dealDetail.grid.enableEditEvents(true,false,true);
        dealDetail.grid.setDateFormat(user_date_format, "%Y-%m-%d");
        dealDetail.grid.setUserData("", 'formula_id', 10211093);
        dealDetail.grid.enableColumnMove(true); 
        dealDetail.grid.attachEvent("onBeforeCMove",function(cInd, newPos){
            var col_type = dealDetail.grid.getColType(0);
                if (col_type == "tree") {
                    if (cInd < 3 || newPos < 3) return false;
                    else return true;
                } else {
                    if (cInd < 2 || newPos < 2) return false;
                    else return true;
                }
        });
        dealDetail.grid.enableUndoRedo();
        dealDetail.deal_menu_click('refresh');
        dealDetail.resize_layout();
    });    

    /**
     * [resize_layout Resize the layout cells]
     */
    dealDetail.resize_layout = function() {  
        var h = 0;
        dealDetail.deal_detail.forEachItem(function(item){
            h += item.getHeight();
        });
        dealDetail.deal_detail.cells("a").setHeight(h * 0.3);
    }

    /**
     * [context_menu_click description]
     * @param  {[string]} menuitemId [menuitemId]
     * @param  {[string]} type       [type]
     */
    dealDetail.context_menu_click = function(menuitemId,type) {
        var data = dealDetail.grid.contextID.split("_"); //rowId_colInd
        var row_id = data[0];
        var column_index = data[1];
        var deal_id = '<?php echo $deal_id; ?>';       

        var col_label = dealDetail.grid.getColLabel(column_index);
        var col_type = dealDetail.grid.getColType(column_index);
        var col_value = dealDetail.grid.cells(row_id, column_index).getValue();
        var selected_leg = dealDetail.grid.cells(row_id, 0).getValue();

        if (col_type == 'combo' || 'win_link') {
            var col_text = dealDetail.grid.cells(row_id, column_index).getTitle();
        } else {
            var col_text = col_value;
        }        

        if (col_type == 'win_link') {
            col_value = col_value + '^' + col_text;
        }

        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var min_max_term = dealDetail.grid.collectValues(term_start_index); 
        min_max_term.sort(function(a, b){
            return Date.parse(a) - Date.parse(b);
        });
        var max_date = min_max_term[min_max_term.length-1];
        var min_date = min_max_term[0];

        var legs = dealDetail.grid.collectValues(0);
        var max_leg = Math.max.apply(null, legs);
        
        dealDetail.unload_apply_to_window();
        if (!apply_to_window) {
            apply_to_window = new dhtmlXWindows();
        }

        var win_title = "Apply To Column - " + col_label;
        var win_url = 'apply.to.rows.php';

        var win = apply_to_window.createWindow('w1', 0, 0, 500, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL(win_url, false, {deal_id:deal_id,term_start:min_date,term_end:max_date,col_label:col_label,col_text:col_text,max_leg:max_leg,selected_leg:selected_leg});

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var from_date = $('textarea[name="txt_from_date"]', ifrDocument).val();
            var to_date = $('textarea[name="txt_to_date"]', ifrDocument).val();
            var legs = $('textarea[name="txt_legs"]', ifrDocument).val();
            var leg_array = legs.split(',');
            if (from_date != 'Cancel' && from_date != '') {
                $.each(leg_array, function(index, value){
                    var legs_rows = dealDetail.grid.findCell(value, 0, false, true);
                    $.each(legs_rows, function(i, v){
                        var t_start = dealDetail.grid.cells(v[0], term_start_index).getValue();

                        var compare_start = '';
                        var compare_end = '';
                        compare_start = dates.compare(t_start, from_date);
                        compare_end = dates.compare(t_start, to_date);
                        if (compare_start == 0 || compare_start == 1) {
                            if (compare_end == 0 || compare_end == -1) {
                                dealDetail.grid.cells(v[0], column_index).setValue(col_value);
                                dealDetail.grid.cells(v[0], column_index).cell.wasChanged=true;
                            }
                        }
                    });
                });

            }
            return true;
        });
    }

    /**
     * [grid_row_selection Grid rows select/unselect event function]
     * @param  {[string]} row_ids [row ids]
     */
    dealDetail.grid_row_selection = function(row_ids) {
        var count = row_ids.split(',');
        var count = count.length;
        var has_rights_deal_edit = Boolean('<?php echo $has_rights_deal_edit; ?>');
        var has_term_edit_right = Boolean('<?php echo $term_edit_privilege;?>');
        var has_schedule_deal = Boolean('<?php echo $has_schedule_deal;?>');
        if (row_ids != null) {
            if (count == 1) {
                if (has_rights_deal_edit) dealDetail.deal_detail_menu.setItemEnabled('add_leg');
                if (has_term_edit_right) dealDetail.deal_detail_menu.setItemEnabled('add_term');
				if (has_schedule_deal) dealDetail.deal_detail_menu.setItemEnabled('schedule_deal');
            } else {
                dealDetail.deal_detail_menu.setItemDisabled('add_term');
                dealDetail.deal_detail_menu.setItemDisabled('add_leg');
				dealDetail.deal_detail_menu.setItemDisabled('schedule_deal');
            }
            if (has_rights_deal_edit) dealDetail.deal_detail_menu.setItemEnabled('update_volume');
        } else {
            dealDetail.deal_detail_menu.setItemDisabled('add_term');
            dealDetail.deal_detail_menu.setItemDisabled('add_leg');
            dealDetail.deal_detail_menu.setItemDisabled('update_volume');
			dealDetail.deal_detail_menu.setItemDisabled('schedule_deal');
        }
    }

    /**
     * [deal_detail_edit Grid cell on edit function]
     * @param  {[type]} stage  [stage of edit 0 - edit open, 1 - on edit, 2 - on edit close]
     * @param  {[type]} rId    [row_id]
     * @param  {[type]} cInd   [column index]
     * @param  {[type]} nValue [new value]
     * @param  {[type]} oValue [old value]
     */
    dealDetail.deal_detail_edit = function(stage,rId,cInd,nValue,oValue) {
        if (stage == 2) {
            var column_id = dealDetail.grid.getColumnId(cInd);
            if (column_id == 'term_start' || column_id == 'term_end') {
                var term_start_index = dealDetail.grid.getColIndexById('term_start');
                var term_end_index = dealDetail.grid.getColIndexById('term_end');
                var term_start = dealDetail.grid.cells(rId, term_start_index).getValue();
                var term_end = dealDetail.grid.cells(rId, term_end_index).getValue();

                if (dates.compare(term_end, term_start) == -1) {
                    var term_start_label = dealDetail.grid.getColLabel(term_start_index);
                    var term_end_label = dealDetail.grid.getColLabel(term_end_index);
                    if (cInd == term_start_index) {
                        var message = term_start_label + ' cannot be greater than ' + term_end_label;
                    } else {
                        var message = term_end_label + ' cannot be less than ' + term_start_label;
                    }

                    dhtmlx.alert({
                        title:"Error",
                        type:"alert-error",
                        text:message,
                        callback: function(result){
                            if (oValue.replace('&nbsp;', '') != '' && oValue.replace('&nbsp;', '') != null) {
                                dealDetail.grid.cells(rId, cInd).setFormattedValue(oValue);
                                return true;
                            } else {
                                dealDetail.grid.cells(rId, cInd).setFormattedValue('');
                                return false;
                            }
                        }
                    });
                }
            }
            return true;
        }
    }

    /**
     * [undock_details Undock detail layout]
     */
    dealDetail.undock_details = function() {
        var deal_id = '<?php echo $deal_id; ?>';
        var layout_obj = dealDetail.deal_detail;
        layout_obj.cells("b").undock(300, 300, 900, 700);
        layout_obj.dhxWins.window("b").button("park").hide();
        layout_obj.dhxWins.window("b").maximize();
        layout_obj.dhxWins.window("b").centerOnScreen();
        layout_obj.dhxWins.window("b").setText('Details - ' + deal_id);
    }

    /**
     * [on_dock_detail_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    dealDetail.on_dock_detail_event = function(id) {
        if (id == 'b') {            
            $(".undock_detail").show();
        }
    }
    /**
     * [on_undock_detail_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    dealDetail.on_undock_detail_event = function(id) {
        if (id == 'b') {
            $(".undock_detail").hide();            
        }            
    }

    /**
     * [deal_menu_click Grid menu click]
     * @param  {[type]} id [Menu id]
     */
    dealDetail.deal_menu_click = function(id) {
        switch(id) {
            case "refresh":
                var deal_id = '<?php echo $deal_id; ?>';
                var view_deleted = '<?php echo $view_deleted; ?>';
                var data = {
                    "action":"spa_deal_update",
                    "flag":"e",
                    "source_deal_header_id":deal_id,
                    "view_deleted":view_deleted,
                    "grid_type":"g"
                }

                var changed_rows = dealDetail.grid.getChangedRows(true);
                if (changed_rows != '') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to refresh grid?",
                        callback: function(result) {
                            if (result) {
                                dealDetail.refresh_grid(data);
                                dealDetail.grid.setUserData("", 'formula_id', 10211093);
                            }
                        }
                     });
                } else {
                    dealDetail.refresh_grid(data);
                    dealDetail.grid.setUserData("", 'formula_id', 10211093);
                }
                break;
            case "add_term":
                dealDetail.open_term_window('term');
                break;
            case "add_leg":
                dealDetail.open_term_window('leg');
                break;
            case "undo_cell":
                dealDetail.grid.doUndo();
                break;
            case "redo_cell":
                dealDetail.grid.doRedo();
                break;
            case "pdf":
                dealDetail.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                dealDetail.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case "update_volume":
                dealDetail.open_update_volume();
                break;
			case 'schedule_deal':
                dealDetail.open_schedule_deal();
                break;            default:
                dhtmlx.message({
                    title:'Error',
                    type:"alert-error",
                    text:"Under Maintainence! We will be back soon!"
                });
                break;
        }
    }
	
	
	/**
     * [open_schedule_deal Schedule Deal]
     */
    dealDetail.open_schedule_deal = function() {
        var row_id = dealDetail.grid.getSelectedRowId();
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var source_deal_detail_id = dealDetail.grid.cells(row_id, source_deal_detail_index).getValue();

        if (row_id.indexOf(',') > -1) {
            dhtmlx.alert({
                title: 'Error',
                type: 'alert-error',
                text: 'Please select one record to process.'
            });
            return;
        }
        //dealDetail.unload_deals_window();
        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }

        var win_title = 'Schedule Deal';
        var win_url = 'schedule.deal.php';


        var param = {};
        var cols = new Array();
        dealDetail.grid.forEachCell(0, function(cell_obj, ind) {
            cols.push(dealDetail.grid.getColumnId(ind));
        })



        param.term_start = dates.convert_to_sql(dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('term_start')).getValue());
        param.term_end = dates.convert_to_sql(dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('term_end')).getValue());
        //param.leg = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('Leg')).getValue();
        //param.location_id = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('location_id')).getValue();
        param.volume = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('deal_volume')).getValue();


      //param.location_id = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('location_index')).getValue();
        //param.counterparty_id = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('counterparty')).getValue();

        //param.term = dates.convert_to_sql(dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('term_start')).getValue());
        // param.term_end = dates.convert_to_sql(dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('term_end')).getValue());
        // param.source_deal_header_id = selected_ids;
        param.group_by = 'Deal';
        //
        var deal_id = '<?php echo $deal_id; ?>';
        win_url += '?term=' + param.term_start + '&term_end=' + param.term_end + '&group_by=' + param.group_by + '&source_deal_header_id=' + deal_id + '&source_deal_detail_id=' + source_deal_detail_id;


        var win = volume_window.createWindow('w1', 0, 0, 400, 400);
        win.progressOn();
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.addUserButton("reload", 0, "Reload", "Reload");
        win.maximize();

        win.attachURL(win_url, null);
        
        win.attachEvent("onContentLoaded", function(win){
            win.progressOff();
        });


    }

	
    var volume_window;
    dealDetail.open_update_volume = function() {
        dealDetail.unload_deals_window();
        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }
        var selected_ids = dealDetail.grid.getColumnValues(1);
 
        data = {"action": "spa_shaped_deal", "flag":"c", "source_deal_detail_id":selected_ids};
        adiha_post_data("return_array", data, '', '', 'dealDetail.open_update_volume_post');
    }
    
    dealDetail.unload_deals_window = function() {        
        if (volume_window != null && volume_window.unload != null) {
            volume_window.unload();
            volume_window = w1 = null;
        }
    }
    
    dealDetail.open_update_volume_post = function(return_value) { 
        if (return_value[0][0] == 'Success') {
            var win_title = 'Update Volume';
            var win_url = 'update.demand.shaped.volume.php?header_detail=d';
            var selected_ids = dealDetail.grid.getColumnValues(1);
            var win = volume_window.createWindow('w1', 0, 0, 400, 400);
            
            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.maximize();
            win.attachURL(win_url, false, {detail_ids:selected_ids, profile_type:return_value[0][5]});
        } else  {
            dealDetail.profile_type_mismatch(return_value[0][4]);
            return;
        }                
    } 
    
    /**
     * [profile_type_mismatch Display msg for mismatch deals profile type]
     * @param  {[string]} message [Failed message]
     */
    dealDetail.profile_type_mismatch = function(message) {
        dhtmlx.alert({
            title:"Error",
            type:"alert-error",
            text:message
        });
    }
    
    var term_window;
    /**
     * [open_term_window Open term Window to add leg and term]
     * @param  {[type]} type [description]
     * @return {[type]}      [description]
     */
    dealDetail.open_term_window = function(type) {
        var deal_id = '<?php echo $deal_id; ?>';
        var deal_date = '<?php echo $deal_date;?>';
        var term_start = '';
        var term_end = '';
        
        dealDetail.unload_term_window();
        if (!term_window) {
            term_window = new dhtmlXWindows();
        }

        var win_title = (type == 'term') ? "Add Term" : "Add leg";
        var win_url = 'add.terms.php';
        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var min_max_term = dealDetail.grid.collectValues(term_start_index); 
        min_max_term.sort(function(a, b){
            return Date.parse(a) - Date.parse(b);
        });
        if (type == 'leg') {
            var max_date = min_max_term[min_max_term.length-1];
            var min_date = min_max_term[0];
        } else {
            min_date = deal_date;
            max_date = min_max_term[min_max_term.length-1];
        }

        var win = term_window.createWindow('w1', 0, 0, 500, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL(win_url, false, {deal_id:deal_id,term_start:term_start,term_end:term_end,min_date:min_date,max_date:max_date,type:type});

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var from_date = $('textarea[name="txt_from_date"]', ifrDocument).val();
            var to_date = $('textarea[name="txt_to_date"]', ifrDocument).val();

            if (from_date != 'Cancel' && from_date != '') {
                data = {"action": "spa_deal_update", "flag":"t", "source_deal_header_id":deal_id, "from_date":from_date, "to_date":to_date};
                if (type == 'term') {
                    adiha_post_data("return", data, '', '', 'dealDetail.add_term');
                } else {
                    adiha_post_data("return", data, '', '', 'dealDetail.add_leg');
                }
            }
            return true;
        });
    }

    /**
     * [unload_term_window Unload Terms]
     */
    dealDetail.unload_term_window = function() {
        if (term_window != null && term_window.unload != null) {
            term_window.unload();
            term_window = w1 = null;
        }
    }

    /**
     * [unload_apply_to_window Unload Apply To Window]
     */
    dealDetail.unload_apply_to_window = function() {
        if (apply_to_window != null && apply_to_window.unload != null) {
            apply_to_window.unload();
            apply_to_window = w1 = null;
        }
    }

    /**
     * [unload_document_window Unload Document Window]
     */
    dealDetail.unload_document_window = function() {
        if (document_window != null && document_window.unload != null) {
            document_window.unload();
            document_window = w1 = null;
        }
    }


    /**
     * [add_term Add term]
     * @param {[array]} result [result array for terms]
     */
    dealDetail.add_term = function(result) {
        var legs = dealDetail.grid.collectValues(0);
        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        
        $.each(legs, function(index, value){
            var i = 0;
            $.each(result, function(term_index, term_value) {
                var new_id = (new Date()).valueOf();
                var values_array = new Array();
                values_array.push(value);
                var row_id = dealDetail.grid.getSelectedRowId();

                for(var cellIndex = 1; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                    if (cellIndex == term_start_index) {
                        values_array.push(result[term_index].term_start);
                    } else if (cellIndex == term_end_index) {
                        values_array.push(result[term_index].term_end);
                    } else if (cellIndex == source_deal_detail_index) {
                        values_array.push("NEW_" + new_id);
                    } else {
                        if (row_id != null) {
                            var val = dealDetail.grid.cells(row_id, cellIndex).getValue();
                            var type = dealDetail.grid.getColType(cellIndex);

                            if (type == 'win_link') {
                                val = val + '^' + dealDetail.grid.cells(row_id, cellIndex).getTitle();
                            }
                            values_array.push(val);
                        } else {
                            values_array.push('');
                        } 
                    }            
                }

                dealDetail.grid.addRow(new_id, values_array);
                if (i == 0) {
                    dealDetail.grid.selectRowById(new_id);
                }
                i++;
            });            
        });
    }

    /**
     * [add_leg add leg]
     * @param {[array]} result [result array for terms]
     */
    dealDetail.add_leg = function(result) {
        var legs = dealDetail.grid.collectValues(0);
        var max_leg = Math.max.apply(null, legs);
		var leg_index = dealDetail.grid.getColIndexById('Leg');

        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var row_id = dealDetail.grid.getSelectedRowId();
        if (row_id != null) {
            var selected_leg = dealDetail.grid.cells(row_id, 0).getValue();
        } else {
            var selected_leg =  max_leg;
        }
        var i = 0;
        $.each(result, function(term_index, term_value) {
            var new_id = (new Date()).valueOf();
            var values_array = new Array();
            values_array.push(max_leg+1);

            for(var cellIndex = 1; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                if (source_deal_detail_index == cellIndex) {
                    values_array.push("NEW_" + new_id);
                } else if (cellIndex == term_start_index) {
                    values_array.push(result[term_index].term_start);
                } else if (cellIndex == term_end_index) {
                    values_array.push(result[term_index].term_end);
                } else {
                    if (row_id != null) {
                        var val = dealDetail.grid.cells(row_id, cellIndex).getValue();
                        var type = dealDetail.grid.getColType(cellIndex);

                        if (type == 'win_link') {
                            val = val + '^' + dealDetail.grid.cells(row_id, cellIndex).getTitle();
                        }
						
						if (leg_index != undefined && leg_index != '' && leg_index != null) {							
							if (cellIndex == leg_index) {
								val = max_leg+1;
							}
						}
                        values_array.push(val);
                    } else {
                        values_array.push('');
                    }
                }
            }
            dealDetail.grid.addRow(new_id,values_array);
            if (i == 0) {
                dealDetail.grid.selectRowById(new_id);
            }
            i++;
        });
    }

    /**
     * [page_toolbar_click Page Menu Click]
     * @param  {[type]} id [Menu id]
     */
    dealDetail.page_toolbar_click = function(id) {
        switch(id) {
            case "save":
                var final_status = true;
                var grid_status = dealDetail.validate_form_grid(dealDetail.grid, 'Deal Detail');
                if (grid_status) {
                    var deal_id = '<?php echo $deal_id; ?>';
                    var tab_obj = dealDetail.deal_tab;
                    var header_xml = '<Root><FormXML ';
                    var grid_xml = "";

                    tab_obj.forEachTab(function(tab) {
                        var form_obj = tab.getAttachedObject();
                        var form_status = validate_form(form_obj);
                        if (form_status) {
                            data = form_obj.getFormData();

                            for (var a in data) {
                                var field_label = a;

                                if (form_obj.getItemType(field_label) == 'calendar') {
                                    var field_value = form_obj.getItemValue(field_label, true);
                                } else {
                                    var field_value = data[field_label];
                                }

                                header_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        } else {
                            final_status = false;
                        }
                    });

                    header_xml += "></FormXML></Root>";

                    if (final_status) {
                        dealDetail.grid.setSerializationLevel(false,false,true,false,true,true);
                        detail_xml = dealDetail.grid.serialize();
                        detail_xml = detail_xml.replace(/='/g, '="');
                        detail_xml = detail_xml.replace(/' /g, '" ');
                        detail_xml = detail_xml.replace(/'>/g, '">');
                        
                        data = {"action": "spa_deal_update", "flag":"s", "source_deal_header_id":deal_id, "header_xml":header_xml, "detail_xml":detail_xml};
                        adiha_post_data("alert", data, '', '', 'dealDetail.save_callback');
                    }                    
                }
                break;
            case 'documents':
                dealDetail.open_document();
        }
    }

    /**
     * [open_document Open Document window]
     */
    dealDetail.open_document = function() {
        dealDetail.unload_document_window();
        var deal_id = '<?php echo $deal_id; ?>';

        if (!document_window) {
            document_window = new dhtmlXWindows();
        }

        var win_title = 'Document';
        var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?notes_object_id=' + deal_id + '&is_pop=true';

        var win = document_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {notes_category:33});

        win.attachEvent('onClose', function(w) {
            update_document_counter(deal_id, dealDetail.toolbar);
            return true;
        });
    }

    /**
     * [save_callback Save callback]
     * @param  {[array]} result [callback array]
     */
    dealDetail.save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var deal_id = '<?php echo $deal_id; ?>';
            var view_deleted = '<?php echo $view_deleted; ?>';
            var data = {
                "action":"spa_deal_update",
                "flag":"e",
                "source_deal_header_id":deal_id,
                "view_deleted":view_deleted,
                "grid_type":"g"
            }
            dealDetail.refresh_grid(data, false);
            dealDetail.grid.setUserData("", 'formula_id', 10211093);
        }
    }

    /**
     * [form_change description]
     * @param  {[type]} name  [description]
     * @param  {[type]} value [description]
     * @return {[type]}       [description]
     */
    dealDetail.form_change = function(name, value) {
        if (name == 'counterparty_id') {
            dealDetail.load_dependent_dropdown(value);
        }
    }

    /**
     * [load_counterparty_combo Load counterparty dropdown as defined in deal field mapping]
     * @return {[type]} [description]
     */
    dealDetail.load_counterparty_combo = function() {
        var deal_id = '<?php echo $deal_id; ?>';
        var tab_obj = dealDetail.deal_tab;
        tab_obj.forEachTab(function(tab) {
            var form_obj = tab.getAttachedObject();

            var counterparty_combo = form_obj.getCombo('counterparty_id');            
            if (counterparty_combo) {
                var default_value = form_obj.getItemValue('counterparty_id');
                counterparty_combo.setComboValue('');
                counterparty_combo.setComboText('');
                counterparty_combo.enableFilteringMode(true);
                var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "deal_fields": "counterparty_id", "default_value":default_value};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                counterparty_combo.load(url);
            }
        });
    }

    /**
     * [load_dependent_dropdown Load dependent columns as defined in deal fields mapping]
     * @param  {[type]} counterparty_id [Counterparty Id]
     */
    dealDetail.load_dependent_dropdown = function(counterparty_id) {
        var deal_id = '<?php echo $deal_id; ?>';
        var tab_obj = dealDetail.deal_tab;
        tab_obj.forEachTab(function(tab) {
            var form_obj = tab.getAttachedObject();
            var contract_combo = form_obj.getCombo('contract_id');   
            if (contract_combo) {                
                var default_value = form_obj.getItemValue('contract_id');           
                contract_combo.setComboValue('');
                contract_combo.setComboText('');
                contract_combo.clearAll();
                contract_combo.enableFilteringMode(true);
                var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "contract_id", "default_value":default_value};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                contract_combo.clearAll();
                contract_combo.load(url);
            }
        });

        var curve_index = dealDetail.grid.getColIndexById('curve_id');
        if (typeof curve_index != 'undefined') {
            var curve_combo = dealDetail.grid.getColumnCombo(curve_index);
            curve_combo.setComboValue('');
            curve_combo.setComboText('');
            curve_combo.clearAll();
            curve_combo.enableFilteringMode(true);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "curve_id"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            curve_combo.clearAll();
            curve_combo.load(url);
        }

        var formula_curve_index = dealDetail.grid.getColIndexById('formula_curve_id');
        if (typeof formula_curve_index != 'undefined') {
            var formula_curve_combo = dealDetail.grid.getColumnCombo(formula_curve_index);
            formula_curve_combo.setComboValue('');
            formula_curve_combo.setComboText('');
            formula_curve_combo.clearAll();
            formula_curve_combo.enableFilteringMode(true);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "formula_curve_id"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            formula_curve_combo.clearAll();
            formula_curve_combo.load(url);
        }

        var location_index = dealDetail.grid.getColIndexById('location_id');
        if (typeof location_index != 'undefined') {
            var location_combo = dealDetail.grid.getColumnCombo(location_index);
            location_combo.setComboValue('');
            location_combo.setComboText('');
            location_combo.clearAll();
            location_combo.enableFilteringMode(true);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "location_id"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            location_combo.clearAll();
            location_combo.load(url);
        }
    }
</script>
</html>