<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
        require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php'); 
    ?>
</head>
<body class = "bfix2">
    <div id="div_design_area"></div>
    <?php     
    $rights_report_manager_privilege_detail = 10201612;
        
    list (
        $has_right_report_manager_privilege_detail
    ) = build_security_rights (
        $rights_report_manager_privilege_detail 
    );
    
    $call_from = get_sanitized_value($_POST['call_from'] ?? 'NULL');
    $object_id = get_sanitized_value($_POST['object_id'] ?? 'NULL');

    $form_namespace = 'rp';
    $json = "[
                {
                    id:         'a',
                    header: false
                }
            ]";
          
    $rp_layout = new AdihaLayout();
    echo $rp_layout->init_layout('layout', '', '1C', $json, $form_namespace);
    
    $context_menu = new AdihaMenu();
    $context_menu_json = '[{id:"add", text:"Apply to All Report(s)", img:"new.gif", imgdis:"new_dis.gif", title: "Apply to All Report(s)"}]';
    echo $context_menu->init_menu('context_menu_report', $form_namespace);
    echo $context_menu->render_as_context_menu();
    echo $context_menu->attach_event('', 'onClick', 'context_menu_report_click');
    echo $context_menu->load_menu($context_menu_json);
    
    $context_menu_paramset = new AdihaMenu();
    $context_menu_json = '[{id:"add", text:"Apply to All Paramset(s)", img:"new.gif", imgdis:"new_dis.gif", title: "Apply to All Paramset(s)"}]';
    echo $context_menu_paramset->init_menu('context_menu_paramset', $form_namespace);
    echo $context_menu_paramset->render_as_context_menu();
    echo $context_menu_paramset->attach_event('', 'onClick', 'context_menu_paramset_click');
    echo $context_menu_paramset->load_menu($context_menu_json);
    
    // attach menu
    $menu_json = '[{id: "save", img:"save.gif", img_disabled:"save.gif", text:"Save", title:"Save"}]';
    $menu_obj = new AdihaMenu();
    echo $rp_layout->attach_menu_cell("privilege_menu", "a");  
    echo $menu_obj->init_by_attach("privilege_menu", $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');
    //print '<pre>';print_r($_POST);print '</pre>';die();
    
    
    echo $rp_layout->close_layout();
    ?>
</body>  
<script>
    var dhx_wins = new dhtmlXWindows();
        
    var post_data = '';
    var has_right_report_manager_privilege_detail = <?php echo (($has_right_report_manager_privilege_detail) ? $has_right_report_manager_privilege_detail : '0'); ?>;
	var object_id = '<?php echo $object_id; ?>';
    var call_from = '<?php echo $call_from; ?>';
    var privilege_type = 'e';
    var subgrid_pv = {};
    
    var context_subgrid_pv = new Array();
    
    //var ifr_dhx_tem = rm.layout.cells('b').getFrame();
    $(function(){
        rp.layout.cells('a').progressOn();
        rp.fx_init_privilege_grid()
    });
    
    rp.fx_init_privilege_grid = function() {
        grid_pv = rp.layout.cells('a').attachGrid();
        if(call_from == 'report_privilege') {
            
            grid_pv.setColumnIds('subgrid,hash,report_name,type,user_ids,role_names,user_ap,role_ap,role_ids');
            grid_pv.setHeader('&nbsp,Report Hash,Report Name,Type,Users,Roles,User (Add Paramset),Role (Add Paramset),role_ids');
            grid_pv.setColumnsVisibility('false,true,false,false,false,false,true,true,true');
            grid_pv.setInitWidths('40,100,400,60,300,*,*,*,*');
            grid_pv.setColTypes('sub_row_grid,ro,ro,ro,ro,ro,ro,ro,ro');
            grid_pv.setColSorting('str,str,str,str,str,str,str,str,str');
            grid_pv.setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
            grid_pv.init();
            grid_pv.enableHeaderMenu();
            
            grid_pv.enableContextMenu(rp.context_menu_report);
            grid_pv.attachEvent("onBeforeContextMenu",context_report_pre_func);
            
            //on grid row DbClick
            grid_pv.attachEvent('onRowDblClicked', function(rid, cid) {
                var report_hash = grid_pv.cells(rid, grid_pv.getColIndexById('hash')).getValue();
                rp.fx_open_assign_privilege(report_hash, rid, 'report_privilege', grid_pv);
            });
            //on grid row select
            grid_pv.attachEvent('onRowSelect', function(rid, cid) {
            });
            
            grid_pv.attachEvent("onSubRowOpen", function(id,state){
                if (state) {
                    rp.layout.cells('a').progressOff();
                }
            })
            
            
            grid_pv.attachEvent("onSubGridCreated", function(subgrid, id, ind) {
                subgrid_pv[id] = subgrid;
                subgrid_pv[id].setColumnIds('hash,paramset_name,type,user_ids,role_ids,role_names');
                subgrid_pv[id].setHeader('Paramset Hash,Paramset,Type,Users,role_ids,Roles');
                subgrid_pv[id].setColumnsVisibility('true,false,false,false,true,false');
                subgrid_pv[id].setInitWidths('100,396,60,300,*,*');
                subgrid_pv[id].setColTypes('ro,ro,ro,ro,ro,ro');
                subgrid_pv[id].setColSorting('str,str,str,str,str,str');
                subgrid_pv[id].setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
                subgrid_pv[id].setStyle('','background-color:#F8E8B8','','background-color:#F7D97E !important');
                subgrid_pv[id].enableAutoWidth(true);
                subgrid_pv[id].init();
                subgrid_pv[id].enableHeaderMenu();
                
                
                subgrid_pv[id].detachHeader(0);
                
                subgrid_pv[id].enableContextMenu(rp.context_menu_paramset); 
                
                subgrid_pv[id].attachEvent("onBeforeContextMenu",context_paramset_pre_func);
                                
                subgrid_pv[id].attachEvent('onRowSelect', function(srid, scid) {
                    grid_pv.forEachRow(function(rid) {                     
                        if (id != rid) { 
                            subgrid_pv[rid].setStyle('','background-color:#F8E8B8','','background-color:#F8E8B8 !important');
                            subgrid_pv[id].setStyle('','background-color:#F8E8B8','','background-color:#F7D97E !important');
                        }
                    });
                }); 
                
                var param = {
                    "action" : "spa_rfx_report_privilege_dhx",
                    "flag" : "h",
                    "report_hash" : grid_pv.cells(id, grid_pv.getColIndexById('hash')).getValue()
                };
    
                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                subgrid_pv[id].clearAll();
    
                //LOAD GRID DATA
                subgrid_pv[id].load(param_url, function(){
                    subgrid_pv[id].callEvent("onGridReconstructed", []);
    
                });
                
                subgrid_pv[id].attachEvent('onRowDblClicked', function(rid, cid) {
                    var paramset_hash = subgrid_pv[id].cells(rid, subgrid_pv[id].getColIndexById('hash')).getValue();
                    rp.fx_open_assign_privilege(paramset_hash, rid, 'paramset_privilege', subgrid_pv[id]);
                    grid_pv.setUserData('', 'parent_rid', id);
                });
                
            });
             
            rp.fx_refresh_grid();
        }
        
    };
    
    //function to refresh grid paramset
    rp.fx_refresh_grid = function() {
        var grid_obj = grid_pv;
        var param = '';
        
        if(call_from == 'report_privilege') {
            param = {
                "flag": "g",
                "action": "spa_rfx_report_privilege_dhx",
                "report_id": object_id,
                "report_privilege_type": privilege_type
            };
            
        }
        
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        grid_obj.clearAndLoad(param_url, function() {
            //menu_obj.setItemDisabled('delete');
            grid_obj.forEachRow(function(rid) {
                grid_obj.cellById(rid, 0).open();
                
            });
        });
    }
    
    
    rp.fx_open_assign_privilege = function(hash, rid, call_from, grid_obj) {
        var win_title = (call_from == 'report_privilege' ? 'Report Manager Privilege Assign' : 'Report Paramset Privilege Assign');
        var grid_obj = grid_obj;
        window_assign_privilege = dhx_wins.createWindow({
            id: 'window_assign_privilege'
            ,width: 800
            ,height: 380
            ,modal: true
            ,resize: true
            ,text: win_title
            ,center: true
            
        });
        var post_params = {
            call_from: call_from,
            hash: hash,
            grid_row_id: rid,
            user_ids: grid_obj.cells(rid, grid_obj.getColIndexById('user_ids')).getValue(),
            role_ids: grid_obj.cells(rid, grid_obj.getColIndexById('role_ids')).getValue()
        };
        var privilege_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.privilege.assign.php';
        window_assign_privilege.attachURL(privilege_url, null, post_params);
    };
    
    rp.fx_set_user_role = function(selected_values, rid, call_from) {
        
        if (call_from == 'report_privilege') {
            var grid_obj = grid_pv;
        } else {
            var grid_obj = subgrid_pv[grid_pv.getUserData('', 'parent_rid')]; 
        }
        grid_obj.cells(rid, grid_obj.getColIndexById('user_ids')).setValue(selected_values.assigned_users_values);
        grid_obj.cells(rid, grid_obj.getColIndexById('role_ids')).setValue(selected_values.assigned_roles_values);
        grid_obj.cells(rid, grid_obj.getColIndexById('role_names')).setValue(selected_values.assigned_roles_labels);
        window_assign_privilege.close();
    };
    
    rp.menu_click = function(id) {
        if(id == 'save') {
            var sp_string = ""; 
            var sp_string_sub = "";
            
            if(call_from == 'report_privilege') {
                var xml_data = rp.fx_get_xml_data('report_privilege');
                sp_string = "EXEC spa_rfx_report_privilege_dhx @flag='i', @xml='" + xml_data + "'";
                var xml_data = rp.fx_get_xml_data('paramset_privilege');
                sp_string_sub = "EXEC spa_rfx_report_paramset_privilege_dhx @flag='i', @xml='" + xml_data + "'";
            }
            
            post_data = { sp_string: sp_string };
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                //console.log(data['json'][0].name);
                var json_data = data['json'][0];
                if(json_data.errorcode == 'Success') {
                    
                    if (call_from == 'report_privilege') {
                         post_data = { sp_string: sp_string_sub };
                          $.ajax({
                            url: js_form_process_url,
                            data: post_data,
                        }).done(function(data) {
                            var json_data = data['json'][0];
                            if(json_data.errorcode == 'Success') {
                                success_call(json_data.message, 'error');
                            } else {
                                dhtmlx.message({
                                    title: 'Error',
                                    type: 'alert-error',
                                    text: json_data.message
                                });
                            }
                        });
                            
                    }
                    
                } else {
                    dhtmlx.message({
                        title: 'Error',
                        type: 'alert-error',
                        text: json_data.message
                    });
                }
            });
        }
    }
    rp.fx_get_xml_data = function(call_from) {
        var xml_data = '<Root>';
        
        if(call_from == 'report_privilege') {
            grid_pv.forEachRow(function(rid) {
                    xml_data += '<PSRecordset hash="' + grid_pv.cells(rid, grid_pv.getColIndexById('hash')).getValue() + 
                                    '" user_id="' + grid_pv.cells(rid, grid_pv.getColIndexById('user_ids')).getValue() +
                                    '" role_id="' + grid_pv.cells(rid, grid_pv.getColIndexById('role_ids')).getValue() +
                                    '"></PSRecordset>';
            });
        } else {
            grid_pv.forEachRow(function(rid) {
                if (subgrid_pv[rid] instanceof dhtmlXGridObject) {
                    subgrid_pv[rid].forEachRow(function(srid) {
                        xml_data += '<PSRecordset hash="' + subgrid_pv[rid].cells(srid, subgrid_pv[rid].getColIndexById('hash')).getValue() + 
                                        '" user_id="' + subgrid_pv[rid].cells(srid, subgrid_pv[rid].getColIndexById('user_ids')).getValue() +
                                        '" role_id="' + subgrid_pv[rid].cells(srid, subgrid_pv[rid].getColIndexById('role_ids')).getValue() +
                                        '"></PSRecordset>'; 
                    });
                }
            });
        }
        
        
        xml_data += '</Root>';
        return xml_data;
    }
    
    //Apply to All for report grid
    function context_menu_report_click(menu_id, type) {
        var data = grid_pv.contextID.split("_"); //rowId_colInd
        var row_id = data[0];
        var col_id = data[1];        
        var val = grid_pv.cells(row_id,col_id).getValue();
        if(val == '')
            return false;
        
        if (grid_pv.getColIndexById('role_names') == col_id) {
            var rol_col_id = grid_pv.getColIndexById('role_ids');
            var role_val = grid_pv.cells(row_id,rol_col_id).getValue();
            
        }
        grid_pv.forEachRow(function(rid) {
            grid_pv.cells(rid,data[1]).setValue(val);
            if(role_val) {
                grid_pv.cells(rid,rol_col_id).setValue(role_val);
            }
        });
    }
    
    //Apply to All for paramset grid
    function context_menu_paramset_click(menu_id, type) {
        if(context_subgrid_pv[3] == '')
            return false;
        
        grid_pv.forEachRow(function(rid) {
            subgrid_pv[rid].forEachRow(function(srid) { 
                if (context_subgrid_pv[0] != '')
                    subgrid_pv[rid].cells(srid,subgrid_pv[rid].getColIndexById('user_ids')).setValue(context_subgrid_pv[0]);
                if(context_subgrid_pv[1] != '') {
                    subgrid_pv[rid].cells(srid,subgrid_pv[rid].getColIndexById('role_names')).setValue(context_subgrid_pv[1]);
                    subgrid_pv[rid].cells(srid,subgrid_pv[rid].getColIndexById('role_ids')).setValue(context_subgrid_pv[2]);
                }
            });
        });
    }
    
    function context_paramset_pre_func(rowId,celInd,grid){
        rp.context_menu_report.hideContextMenu();
		if (celInd==grid.getColIndexById('user_ids')) {
            context_subgrid_pv[0] = grid.cells(rowId,grid.getColIndexById('user_ids')).getValue();
            context_subgrid_pv[1] = '';
            context_subgrid_pv[2] = '';
            context_subgrid_pv[3] = 'All';
            return true;
        }
        
        if(celInd ==grid.getColIndexById('role_names')) {
            context_subgrid_pv[0] = '';
            context_subgrid_pv[1] = grid.cells(rowId,grid.getColIndexById('role_names')).getValue();
            context_subgrid_pv[2] = grid.cells(rowId,grid.getColIndexById('role_ids')).getValue();
            context_subgrid_pv[3] = 'All';
            return true; 
		}
		return false;
	}
    
    function context_report_pre_func(rowId,celInd,grid){
        rp.context_menu_paramset.hideContextMenu();
		if (celInd==grid.getColIndexById('user_ids') || celInd ==grid.getColIndexById('role_names')) {
		  return true; 
		}
		return false;
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