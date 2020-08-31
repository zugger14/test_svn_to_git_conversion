<?php
/**
* Workflow approval screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';

    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    $workflow_activity_id = get_sanitized_value($_GET['workflow_activity_id'] ?? '');
    
    $form_namespace = 'approval_form_namespace';
    $application_function_id = 10106700;
    $rights_approval_approve = 10106710;
    $rights_approval_delete = 10106712;
    
    list (
        $has_rights_approval_approve,
        $has_rights_approval_delete                
    ) = build_security_rights(
        $rights_approval_approve,
        $rights_approval_delete                
    );
    
    $layout_json = '[
                        {id: "a", text: "Apply Filters",height:100},
                        {id: "b", text: "Filters Criteria",height:100},
                        {id: "c", text: "Approvals"}
                    ]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('approval_layout', '', '3E', $layout_json, $form_namespace);
    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$application_function_id', @template_name='ManageApproval', @group_name='General'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    echo $layout_obj->attach_form('filter_form', 'b');
    $form_obj = new AdihaForm();
    echo $form_obj->init_by_attach('filter_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    
    $menu_name = 'approval_menu';
    $menu_json = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
            {id:"t1", text:"Action", img:"action.gif", imgdis:"action_dis.gif", items:[
                {id:"approve", text:"Approve", img:"match.gif", imgdis:"match_dis.gif", disabled:true},
                {id:"unapprove", text:"Unapprove", img:"unmatch.gif", imgdis:"unmatch_dis.gif", disabled:true},
                {id:"complete", text:"Complete", img:"tick.png", imgdis:"tick_dis.png", disabled:true},
                {id:"recall", text:"Recall", img:"undo.gif", imgdis:"redo_dis.gif", disabled:true},
                {id:"audit", text:"Audit Log", img:"audit.gif", imgdis:"audit_dis.gif", disabled:true},
                {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", disabled:true}
            ]},
            {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", disabled:false, items:[
                {id:"excel", text:"Excel", img:"excel.gif"},
                {id:"pdf", text:"PDF", img:"pdf.gif"}
            ]},
            {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"},
            //{id:"select_unselect", text:"Select/Unselect", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif"}
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $form_namespace.'.menu_click');
    
    //attach grid
    $grid_name = 'approval_grid';
    echo $layout_obj->attach_grid_cell($grid_name, 'c');
    $grid_obj = new AdihaGrid();
    echo $layout_obj->attach_status_bar("c", true);
    echo $grid_obj->init_by_attach($grid_name, $form_namespace);
    echo $grid_obj->set_header("Module/Message,Activity ID,ID,Status,Created Date,Comment,Document (Count), Action, Action ID, Comment Required");
    echo $grid_obj->set_columns_ids("message,activity_id,source_id,status,created_date,comment,document,action,action_id, comment_required");
    echo $grid_obj->set_widths("500,150,150,150,150,150,150,250,0,150");
    echo $grid_obj->set_column_types("tree,ro_int,ro_int,ro,ro,ro,ro,ro,ro,ro");
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->set_column_visibility("false,true,false,false,false,false,false,false,true,true");
    echo $grid_obj->enable_paging(100, 'pagingArea_c', 'true');
    echo $grid_obj->enable_column_move('false,true,true,true,true,true,true,true,false,false');
    echo $grid_obj->set_sorting_preference('str,int,int,str,date,str,str,str,str,str');
    echo $grid_obj->set_search_filter(true);
    echo $grid_obj->split_grid(1);
    echo $grid_obj->return_init();
    echo $grid_obj->enable_header_menu();
    echo $grid_obj->attach_event('', 'onRowSelect', $form_namespace.'.grid_select');
    echo $grid_obj->attach_event('', 'onRowDblClicked', $form_namespace.'.grid_dbl_click');
    
    echo $layout_obj->close_layout();
?>
<body class = "bfix2">
</body>
<script type="text/javascript">
    var has_rights_approval_approve = <?php echo (($has_rights_approval_approve) ? $has_rights_approval_approve : '0'); ?>;
    var has_rights_approval_delete = <?php echo (($has_rights_approval_delete) ? $has_rights_approval_delete : '0'); ?>;

    var workflow_activity_id_gbl = '<?php echo $workflow_activity_id; ?>';
    var call_from_gbl = '<?php echo $call_from; ?>';
    
    var expand_state = 0;
    var audit_report_window;
    var document_window;
    var load_count = 0;
    /**
     * [unload_audit_report_window Unload Audit Log window.]
     */
    function unload_audit_report_window() {        
        if (audit_report_window != null && audit_report_window.unload != null) {
            audit_report_window.unload();
            audit_report_window = w1 = null;
        }
    }
    
    var comment_window;
    /**
     * [unload_comment_window Unload Comment window.]
     */
    function unload_comment_window() {        
        if (comment_window != null && comment_window.unload != null) {
            comment_window.unload();
            comment_window = w1 = null;
        }
    }
    
    $(function(){
        filter_obj = approval_form_namespace.approval_layout.cells('a').attachForm();
        var layout_cell_obj = approval_form_namespace.approval_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '10106700', 2);

        combo_obj = approval_form_namespace.filter_form.getCombo('user_login_id');
        combo_obj.setChecked(combo_obj.getIndexByValue(js_user_name), true);
        

        if(call_from_gbl == 'manage_email') {
            combo_obj = approval_form_namespace.filter_form.getCombo('status_id');
            combo_obj.unSelectOption();
        }
        context_menu_match = new dhtmlXMenuObject();
			context_menu_match.renderAsContextMenu();
			context_menu_match.setIconsPath(js_image_path  + "dhxtoolbar_web/");
			var menu_obj = [{id:"add", text:"Add Comment", enabled:true, img:"add.gif", imgdis:"add_dis.gif"}];
			context_menu_match.loadStruct(menu_obj);
            approval_form_namespace.approval_grid.enableContextMenu(context_menu_match);

            context_menu_match.attachEvent('onClick', function(id){
                if(id == 'add') {
                    open_approve_comment_window(-1);
                }
            });
        refresh_approval_grid();
    });
    
    function refresh_approval_grid() {
        approval_form_namespace.approval_layout.cells('a').collapse();
        approval_form_namespace.approval_layout.cells('b').collapse();
        approval_form_namespace.approval_layout.cells('c').progressOn();
        
        form_data = approval_form_namespace.filter_form.getFormData();
        var filter_param = '';
        for (var a in form_data) {
            if (form_data[a] != '' && form_data[a] != null) {

                if (approval_form_namespace.filter_form.getItemType(a) == 'calendar') {
                    value = approval_form_namespace.filter_form.getItemValue(a, true);
                } else {
                    value = form_data[a];
                }
                
                if (a != 'apply_filters') {
                        filter_param += "&" + a + '=' + value;    
                }
            }
        }
        
        var param = {
            "flag": "b",
            "action":"spa_setup_rule_workflow",
            "grid_type":"tg",
            "activity_id": workflow_activity_id_gbl,
            "grouping_column":"module,group,message"
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param + filter_param;
        approval_form_namespace.approval_grid.clearAll();
        // approval_form_namespace.approval_grid.clearAndLoad(param_url, openAllRows);
        approval_form_namespace.approval_grid.loadXML(param_url, function(){
            approval_form_namespace.approval_grid.expandAll();
            approval_form_namespace.approval_grid.filterByAll();
        });
       
        approval_form_namespace.approval_layout.cells('c').progressOff();
        approval_form_namespace.approval_menu.setItemDisabled("approve");
        approval_form_namespace.approval_menu.setItemDisabled("unapprove");
        approval_form_namespace.approval_menu.setItemDisabled("audit");
        approval_form_namespace.approval_menu.setItemDisabled("delete");
        approval_form_namespace.approval_menu.setItemDisabled("complete");
        approval_form_namespace.approval_menu.setItemDisabled("recall");
    }
    
    
    approval_form_namespace.menu_click = function(id, zoneId, cas) {
        var selected_row_id = approval_form_namespace.approval_grid.getSelectedRowId();
        
        switch(id) {
            case "refresh":
                // approval_form_namespace.approval_menu.setItemDisabled("refresh");
                refresh_approval_grid();
                break;
            case "expand_collapse":
                if (expand_state == 0) 
                    openAllRows();
                else
                    closeAllRows();
                break;
            case "pdf":
                approval_form_namespace.approval_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "excel":
                approval_form_namespace.approval_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "select_unselect":
                if (selected_row_id == null) {
                    openAllRows();
                    approval_form_namespace.approval_grid.selectAll();
                    if (has_rights_approval_approve)
                        approval_form_namespace.approval_menu.setItemEnabled("approve");
                    if (has_rights_approval_approve)
                        approval_form_namespace.approval_menu.setItemEnabled("unapprove");
                    
                    approval_form_namespace.approval_menu.setItemEnabled("audit");
                    
                    if (has_rights_approval_delete)
                        approval_form_namespace.approval_menu.setItemEnabled("delete");
                } else {
                    approval_form_namespace.approval_grid.clearSelection();
                    approval_form_namespace.approval_menu.setItemDisabled("approve");
                    
                    if (has_rights_approval_approve)
                        approval_form_namespace.approval_menu.setItemEnabled("unapprove");
                    
                    approval_form_namespace.approval_menu.setItemEnabled("audit");
                    
                    if (has_rights_approval_delete)
                        approval_form_namespace.approval_menu.setItemEnabled("delete");
                }
                break;
            case "approve":
                var approved = 1;
                workflow_approval_comment(approved);
                break;
            case "unapprove":
                var approved = 0;
                workflow_approval_comment(approved);
                break;
            case "complete":
                var approved = 2;
                workflow_approval_comment(approved);
                break;
            case "recall":
                var approved = 4;
                workflow_approval_comment(approved);
                break;
            case "audit":
                var selected_row_array = selected_row_id.split(',');
                var activity_id = '';
                for(var i = 0; i < selected_row_array.length; i++) {
                    if (i == 0) {
                        var activity_id = approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();
                    } else {
                        activity_id += ',' + approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();    
                    }
                }
                
                call_audit_report(activity_id);
                break;
            case "delete":
                delete_activity();
                break;
          /*  case "approve_with_exception":
                open_comment_window(1, 'y');
                break;*/
            default:
                break;
        }
    }
    
    function delete_activity() {
        var msg = "Are you sure you want to delete the selected activity from all users?";
        
        dhtmlx.message({
            type: "confirm",
            text: msg,
            callback: function(result) {
                if (result) {
                    var selected_id = approval_form_namespace.approval_grid.getSelectedRowId();
                    var selected_row_array = selected_id.split(',');
                    var activity_id = '';
                    for(var i = 0; i < selected_row_array.length; i++) {
                        if (i == 0) {
                            var activity_id = approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();
                        } else {
                            activity_id += ',' + approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();    
                        }
                    }
                    
                    data = {"action": "spa_setup_rule_workflow", "flag":"y", "activity_id":activity_id};
                    adiha_post_data("return_array", data, '', '', 'refresh_approval_grid');
                }
            }
        });
    }
    
    function call_audit_report(activity_id) {
        unload_audit_report_window();
        if (!audit_report_window) {
            audit_report_window = new dhtmlXWindows();
        }

        var new_win = audit_report_window.createWindow('w1', 0, 0, 800, 500);
        new_win.setText("Audit Log");
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.maximize();
        
        var url = js_php_path + "dev/spa_html.php?exec=EXEC spa_setup_rule_workflow @flag='f',@activity_id='" + activity_id + "'";
        new_win.attachURL(url, false, true);
    }
    
    openAllRows = function() {
       approval_form_namespace.approval_grid.expandAll();
       approval_form_namespace.approval_menu.setItemEnabled("refresh");
       expand_state = 1;
    }
    
    closeAllRows = function() {
       approval_form_namespace.approval_grid.collapseAll();
       expand_state = 0;
    }
    
    approval_form_namespace.grid_dbl_click = function(r_id) {
        var source_id = approval_form_namespace.approval_grid.cells(r_id, approval_form_namespace.approval_grid.getColIndexById('source_id')).getValue();
        if (source_id == '') {
            var selected_row = approval_form_namespace.approval_grid.getSelectedRowId();
            var state = approval_form_namespace.approval_grid.getOpenState(selected_row);
            
            if (state)
                approval_form_namespace.approval_grid.closeItem(selected_row);
            else
                approval_form_namespace.approval_grid.openItem(selected_row);
        }
    }
    
    approval_form_namespace.grid_select = function() {
        var selected_id = approval_form_namespace.approval_grid.getSelectedRowId();
        var tree_level =  approval_form_namespace.approval_grid.getLevel(selected_id);
        
        if (selected_id != null) {
            var has_child = approval_form_namespace.approval_grid.hasChildren(selected_id);
            var status_col_index = approval_form_namespace.approval_grid.getColIndexById('status');
            var status = approval_form_namespace.approval_grid.cells(selected_id, status_col_index).getValue();
            
            if ((has_child == 0 && (status == 'Outstanding' || status == 'Exceeds Threshold Days')) || (tree_level == 1 && has_child > 0)) {
                approval_form_namespace.approval_menu.setItemDisabled("approve");
                approval_form_namespace.approval_menu.setItemDisabled("unapprove");
                approval_form_namespace.approval_menu.setItemDisabled("complete");
                
                if (tree_level == 1 && has_child > 0) {
                    var all_child = approval_form_namespace.approval_grid.getSubItems(selected_id);
                    var all_child_arr = all_child.split(',');
                    var action_ids = approval_form_namespace.approval_grid.cells(all_child_arr[0], approval_form_namespace.approval_grid.getColIndexById('action_id')).getValue();
                } else {
                    var action_ids = approval_form_namespace.approval_grid.cells(selected_id, approval_form_namespace.approval_grid.getColIndexById('action_id')).getValue();
                }
                
                if (action_ids != '') {
                    var action_ids_arr = action_ids.split(',');
                }
                
                for (cnt = 0; cnt < action_ids_arr.length; cnt++) {
                    if (action_ids_arr[cnt] == 729 && has_rights_approval_approve) {
                        approval_form_namespace.approval_menu.setItemEnabled("approve");
                    }

                    
                    if (action_ids_arr[cnt] == 726 && has_rights_approval_approve)
                        approval_form_namespace.approval_menu.setItemEnabled("unapprove");
                    
                    if (action_ids_arr[cnt] == 728 && has_rights_approval_approve)
                        approval_form_namespace.approval_menu.setItemEnabled("complete");
                }
             } else if(has_child == 0 && status == 'Approved'){
                approval_form_namespace.approval_menu.setItemDisabled("approve");
                approval_form_namespace.approval_menu.setItemDisabled("complete");
                if (has_rights_approval_approve)
                    approval_form_namespace.approval_menu.setItemEnabled("unapprove");
            } else if(has_child == 0 && status == 'Unapproved'){
                if (has_rights_approval_approve) {
                    approval_form_namespace.approval_menu.setItemEnabled("approve");
                }
                approval_form_namespace.approval_menu.setItemDisabled("unapprove");
                approval_form_namespace.approval_menu.setItemDisabled("complete");
            } else if (has_child == 0 && status == 'Completed') {
                approval_form_namespace.approval_menu.setItemDisabled("complete");
                approval_form_namespace.approval_menu.setItemDisabled("unapprove");
                approval_form_namespace.approval_menu.setItemDisabled("approve");
            }
            
            if (has_child == 0) {
                if (status != 'Outstanding')
                    approval_form_namespace.approval_menu.setItemEnabled("recall");
                else
                    approval_form_namespace.approval_menu.setItemDisabled("recall");
                
                approval_form_namespace.approval_menu.setItemEnabled("audit");
                if (has_rights_approval_delete)
                    approval_form_namespace.approval_menu.setItemEnabled("delete");
            } else if (tree_level == 1 && has_child > 0){
                approval_form_namespace.approval_menu.setItemDisabled("audit");
                approval_form_namespace.approval_menu.setItemDisabled("delete");
                approval_form_namespace.approval_menu.setItemDisabled("recall");
            } else {
                approval_form_namespace.approval_menu.setItemDisabled("audit");
                approval_form_namespace.approval_menu.setItemDisabled("delete");
                approval_form_namespace.approval_menu.setItemDisabled("recall");
                approval_form_namespace.approval_menu.setItemDisabled("unapprove");
                approval_form_namespace.approval_menu.setItemDisabled("approve");
            }
        }
    }
    function workflow_approval_comment(approved) {
        var selected_id = approval_form_namespace.approval_grid.getSelectedRowId();
        var selected_row_array = selected_id.split(',');
        if (approved == 1 || approved == 0) {
            var comment_required_arr = [];
            var comment_required;
            for(var i = 0; i < selected_row_array.length; i++) {
                comment_required_arr.push(approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('comment_required')).getValue());
            if(jQuery.inArray("y", comment_required_arr) != -1) {
                comment_required = 'y';
            } else {
                comment_required = 'n';
            }
            if(comment_required == 'y') {
                open_approve_comment_window(approved);   
                return;
                
            } else {
                if(approved == 1) {
                    var msg = "Are you sure you want to approve the selected activity?";
                } else {
                    var msg = "Are you sure you want to unapprove the selected activity?";
                }
            }
            }
        } else if (approved == 2) {
            var msg = "Are you sure you want to complete the selected activity?";
        } else if (approved == 4) {
            var msg = "Are you sure you want to recall the selected activity?";
        }
        run_approval_process(approved, msg, selected_row_array);
    }
    /**
     * Open Approval Window
     */
    function open_approve_comment_window(approved) {
        unload_comment_window();
        if (!comment_window) {
            comment_window = new dhtmlXWindows();
        }
        
        var win = comment_window.createWindow('w1', 0, 0, 600, 300);
        win.setText("Comment");
        win.centerOnScreen();
        win.setModal(true);
        win.button('minmax').hide();
        win.button('park').hide();
        var pre_comment= approval_form_namespace.approval_grid.cells(approval_form_namespace.approval_grid.getSelectedRowId().split(',')[0], approval_form_namespace.approval_grid.getColIndexById('comment')).getValue();
        var params = {call_from:"approval_click", approved:approved, pre_comment:pre_comment};
        win.attachURL('workflow.approval.comment.php', false, params);

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            action_status = $('textarea[name="action_status"]', ifrDocument).val();
            if (action_status == 'cancel' || !action_status || action_status == '' || action_status == null) {
                return true;
            }
        });
    }
    /**
     * Save Comment Form Approvel Window
     */
    function save_comment_fromapprove_window(approved, comments) {
        if(comments) {
            var sel_row_array = approval_form_namespace.approval_grid.getSelectedRowId().split(',')
            var workflow_activity_id;
            for(var i = 0; i < sel_row_array.length; i++) {
                if (i == 0) {
                    workflow_activity_id = approval_form_namespace.approval_grid.cells(sel_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();
                } else {
                    workflow_activity_id += ',' + approval_form_namespace.approval_grid.cells(sel_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();    
                }
            }
            if(approved == 1) {
                var msg = "Are you sure you want to approve the selected activity?";
            } else {
                var msg = "Are you sure you want to unapprove the selected activity?";
            }

            var xml = '<Root><FormXML workflow_activity_id="' + workflow_activity_id + '" comment ="' + comments +'"></FormXML></Root>';
            var cm_param = {"action": "spa_setup_rule_workflow", "flag": "11", "xml": xml};
            adiha_post_data("return_array", cm_param, '', '', function(return_rarray) {
                        if (return_rarray.length > 0 && return_rarray[0][3] == 'Success') {
                            if(approved == 1 || approved == 0) {
                                var data = {"action": "spa_setup_rule_workflow", "flag":"x", "activity_id":workflow_activity_id, "approved": approved};
                                adiha_post_data("return_array", data, '', '', function(result) {
                                    if (return_rarray.length > 0 && return_rarray[0][3] == 'Success') {
                                        run_approval_process(approved, msg, sel_row_array);
                                    }
                                });
                            } else {
                                refresh_approval_grid();
                            } 
                        }
            });
        } else  {
            run_approval_process(approved, msg, sel_row_array);
        }
    }
    /**
     * Run Approval Process
     */
    function run_approval_process(approved, msg, selected_row_array) {
        dhtmlx.message({
            type: "confirm",
            title: "Confirmation",
            text: msg,
            callback: function(result) {
                if (result) {
                    var activity_id = '';
                    for(var i = 0; i < selected_row_array.length; i++) {
                        if (i == 0) {
                            var activity_id = approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();
                        } else {
                            activity_id += ',' + approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();    
                        }
                    }
                    data = {"action": "spa_setup_rule_workflow", "flag":"x", "activity_id":activity_id, "approved": approved};
                    adiha_post_data("return_array", data, '', '', 'check_workflow_callback'); 
                    
                } 
            }    
            });
    }
    
    function check_workflow_callback(result) {
        open_comment_window(result[0][0], result[0][1]);
    }

    function open_comment_window(approved, comment_required) {
        if (comment_required == 'y' && approved != 0 && approved !=1) {
            unload_comment_window();
            if (!comment_window) {
                comment_window = new dhtmlXWindows();
            }
            
            var win = comment_window.createWindow('w1', 0, 0, 600, 300);
            win.setText("Comment");
            win.centerOnScreen();
            win.setModal(true);
            win.button('minmax').hide();
            win.button('park').hide();
            win.attachURL('workflow.approval.comment.php', false, true);
    
            win.attachEvent('onClose', function(w) {
                var ifr = w.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                action_status = $('textarea[name="action_status"]', ifrDocument).val();
                if (action_status == 'cancel' || !action_status || action_status == '' || action_status == null) {
                    return true;
                }
                comments = $('textarea[name="action_comments"]', ifrDocument).val();
                workflow_approval_action(approved, comments);
                return true;
            });
        } else {
            workflow_approval_action(approved, '');
        }
    }
    
    function workflow_approval_action(approved, comments) {
        var selected_id = approval_form_namespace.approval_grid.getSelectedRowId();
        var selected_row_array = selected_id.split(',');
        var activity_id = '';
        
        for(var i = 0; i < selected_row_array.length; i++) {
            var tree_level =  approval_form_namespace.approval_grid.getLevel(selected_row_array[i]);
            var has_children = approval_form_namespace.approval_grid.hasChildren(selected_row_array[i]);
            
            if (tree_level == 1 && has_children > 0) {
                var all_child = approval_form_namespace.approval_grid.getSubItems(selected_row_array[i]);
                var all_child_arr = all_child.split(',');
                selected_row_array = selected_row_array.concat(all_child_arr);
            }
        }
        
        for(var i = 0; i < selected_row_array.length; i++) {
            if (i == 0) {
                var activity_id = approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();
            } else {
                activity_id += ',' + approval_form_namespace.approval_grid.cells(selected_row_array[i], approval_form_namespace.approval_grid.getColIndexById('activity_id')).getValue();    
            }
        }
        
        var data = {
                "action": "spa_setup_rule_workflow",
                "flag": "c",
                "activity_id": activity_id,
                "approved": approved,
                "comments": comments
            }

        adiha_post_data("alert", data, '', '', 'approval_callback');
        approval_form_namespace.approval_layout.cells('c').progressOn();
    }
    
    approval_callback = function(result) {
        approval_form_namespace.approval_layout.cells('c').progressOff();
        refresh_approval_grid();
    }
    
    /**
     * [open_document Open Document window]
     */
    function open_workflow_document(activity_id) {
        approval_form_namespace.unload_document_window();

        if (!document_window) {
            document_window = new dhtmlXWindows();
        }

        var win_title = 'Document';
        var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?notes_object_id=' + activity_id + '&is_pop=true';

        var win = document_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {notes_category:44,call_from:'manage_approval_window',sub_category_id:42005});

        win.attachEvent('onClose', function(w) {
            return true;
        });
    }
    
    /**
     * [unload_document_window Unload Document Window]
     */
    approval_form_namespace.unload_document_window = function() {
        if (document_window != null && document_window.unload != null) {
            document_window.unload();
            document_window = w1 = null;
        }
    }
    
    function message_pop_up_drill(message_id, url_or_desc) {
        var url = '../../../adiha.php.scripts/dev/spa_html.php?message_id=' + message_id + '&pop_up=true&url_or_desc=' + url_or_desc;
        open_message_dhtmlx(url, 'drill1')
    }

    function open_message_dhtmlx(url, window_name) {
        var message_model_state = $('#messageModal').css('display');
        var alert_model_state = $('#alertModal').css('display');

        $('#messageModal').css('display', 'none');
        $('#alertModal').css('display', 'none');

        var message_board_window = new dhtmlXWindows();
        
        var win = message_board_window.createWindow(window_name, 0, 300, 800, 600);
        win.setText('Message Board Report');
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        message_board_window.window(window_name).addUserButton("dock", 3, "Undock", "Undock");
        win.attachURL(url);
    }
</script>

<style>
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