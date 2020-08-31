<?php
/**
* Report manager screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
        require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php'); 
        require_once('../report_manager_dhx/report.global.vars.php');
    ?>
</head>
<body class = "bfix2">
    <div id="div_design_area"></div>
    <?php     
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $form_function_id = 10163600;
    $rights_report_manager_dhx = 10202500;
	$rights_report_manager_dhx_iu = 10202510;
	$rights_report_manager_dhx_delete = 10202511;
    $rights_report_manager_dhx_privilege = 10201612;
    $rights_report_manager_dhx_import_export = 10201612; //to do
	    
    list (
        $has_rights_report_manager_dhx,
        $has_rights_report_manager_dhx_iu,
        $has_rights_report_manager_dhx_delete,
        $has_rights_report_manager_dhx_privilege,
        $has_rights_report_manager_dhx_import_export
    ) = build_security_rights (
        $rights_report_manager_dhx, 
        $rights_report_manager_dhx_iu, 
        $rights_report_manager_dhx_delete,
        $rights_report_manager_dhx_privilege,
        $rights_report_manager_dhx_import_export
    );
    
    $form_namespace = 'rm';
    $json = "[
                {
                    id:         'a',
                    text:       ' ',
                    header:     true,
                    collapse:   false,
                    height:     350,
                    width:      300,
                    collapsed_text: 'Reports / Datasources / Items'
                },
                {
                    id:         'b',
                    text:       'Tabs',
                    header:     false,
                    collapse:   false
                    
                    
                }

            ]";
          
    $rm_layout = new AdihaLayout();
    echo $rm_layout->init_layout('layout', '', '2U', $json, $form_namespace);
    
    $url = $app_form_path . '_reporting/report_manager_dhx/report.manager.dhx.template.php';
    echo $rm_layout->attach_url('b', $url);
    
    echo $rm_layout->close_layout();
    ?>
</body>
<style>
div#div_design_area1 {
    position: relative;
    width: 100%;
    height: 100%;
    overflow: hidden;
    padding: 5px;
}
#ifr_page {
    position: relative;
    width: 100%;
    height: 100%;
}
</style>    
<script>
    var dhx_wins = new dhtmlXWindows();
    var report_id_tmp = 1;
    var report_obj = {};
    var post_data = '';
    var has_rights_report_manager_dhx_iu =<?php echo (($has_rights_report_manager_dhx_iu) ? $has_rights_report_manager_dhx_iu : '0'); ?>;
	var has_rights_report_manager_dhx_delete =<?php echo (($has_rights_report_manager_dhx_delete) ? $has_rights_report_manager_dhx_delete : '0'); ?>;
    var has_rights_report_manager_dhx_privilege =<?php echo (($has_rights_report_manager_dhx_privilege) ? $has_rights_report_manager_dhx_privilege : '0'); ?>;
    var has_rights_report_manager_dhx_import_export =<?php echo (($has_rights_report_manager_dhx_import_export) ? $has_rights_report_manager_dhx_import_export : '0'); ?>;
    var expand_state = 0;
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    //var ifr_dhx_tem = rm.layout.cells('b').getFrame();
    $(function(){
        fx_initial_load();
        ifr_dhx = rm.layout.cells('b').getFrame().contentWindow;
    });
    //function to load initial values
    function fx_initial_load() {
        rm.fx_init_left_tabs();
        

    }
    //function to init left tabs
    rm.fx_init_left_tabs = function() {
        json_acc = [
            {
                id: "acc_report",      // tab id
                text: "Reports",
                open: true
                ,height: '*'
            },
            {
                id: "acc_sources",
                text: "Datasources/Items",
                open: true
                ,height: '*'
                 
            
            }
        ];
        
        left_acc = rm.layout.cells('a').attachAccordion({
            multi_mode: true,
            resize: true,
            items: json_acc
        });
        rm.layout.cells('a').showHeader();
        left_acc.attachEvent("onActive", function(id, state){
            
        });
        //return;
        //rm.layout.cells('a').expand();
        //left_acc.setSizes();
        
        //attaching menu
        var menu_json = [
            {id: 'refresh_tree_reports', text: 'Refresh', img: 'refresh.gif', img_disabled: 'refresh_dis.gif', enabled: true},
            {id: 'menu_action', text: 'Process', img: 'edit.gif', img_disabled: 'edit_dis.gif', enabled: 1, 
            items: [
                {id: 'add_report_item', text: 'Add', img: 'add.gif', img_disabled: 'add_dis.gif', enabled: has_rights_report_manager_dhx_iu},
                {id: 'delete_report_item', text: 'Delete', img: 'delete.gif', img_disabled: 'delete_dis.gif', enabled: 0},
                {id: 'copy_report_item', text: 'Copy', img: 'copy.gif', img_disabled: 'copy_dis.gif', enabled: 0},
                {id: 'deploy_report_item', text: 'Deploy', img: 'deploy.gif', img_disabled: 'deploy_dis.gif', enabled: 1},
                {id: 'privilege_report_item', text: 'Privilege', img: 'privilege.gif', img_disabled: 'privilege_dis.gif', enabled: 0},
                {id: 'import_export_report_item', text: 'Import/Export Report', img: 'import.gif', img_disabled: 'imp_dis.gif', enabled: 1,
                    items: [
                        {id: 'import_report_item', text: 'Import', img: 'import.gif', img_disabled: 'import_dis.gif', enabled: 1},
                        {id: 'import_as_report_item', text: 'Import As', img: 'import.gif', img_disabled: 'import_dis.gif', enabled: 1},
                        {id: 'export_report_item', text: 'Export', img: 'export.gif', img_disabled: 'export_dis.gif', enabled: 0}
                    ]
                }
            ]},
			{id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1},
			     
        ];
        left_menu = rm.layout.cells('a').attachMenu({
            icons_path: js_image_path + 'dhxmenu_web/',
            items: menu_json
        });
        left_menu.attachEvent('onClick', function(id) {
            rm.fx_menu_click(id);
        });
        
        
        
        
        rm.fx_init_tree_reports();
        rm.fx_init_tree_sources();
        
        //attach toolbar for search : report
        var tool_bar_json = [{id:"search_text", type:"buttonInput", text:"", title:"Search Report", width: 150}];
        tool_bar_reports = left_acc.cells('acc_report').attachToolbar(tool_bar_json);
        tool_bar_reports.loadStruct(tool_bar_json);
        fx_load_report_search('r');
        //attach toolbar for search : datasource
        ///*
        var tool_bar_json1 = [{id:"search_text1", type:"buttonInput", text:"", title:"Search Report", width: 150}];
        tool_bar_sources = left_acc.cells('acc_sources').attachToolbar(tool_bar_json1);
        tool_bar_sources.loadStruct(tool_bar_json1);
        fx_load_report_search('s');
        //*/
        
        
    };
    
    //load filter toolbar events
    function fx_load_report_search(type) {
        if(type == 'r') {
            search_obj = tool_bar_reports.getInput("search_text");
            dhtmlxEvent(search_obj, "focus", function(ev){
                //search_obj.value = "";
            });
    
            dhtmlxEvent(search_obj, "blur", function(ev){
                if(search_obj.value == "") {
                    filter_report();
                    search_obj.value = "";
                }
            });
    
            dhtmlxEvent(search_obj, "keyup", function(ev){
               filter_report();
            });
        } else {
            search_obj_ds = tool_bar_sources.getInput("search_text1");
            dhtmlxEvent(search_obj_ds, "focus", function(ev){
                //search_obj.value = "";
            });
    
            dhtmlxEvent(search_obj_ds, "blur", function(ev){
                if(search_obj_ds.value == "") {
                    filter_report_ds();
                    search_obj_ds.value = "";
                }
            });
    
            dhtmlxEvent(search_obj_ds, "keyup", function(ev){
               filter_report_ds();
            });
        }
        
        
    }
    
    //for filtering toolbar : report
    function filter_report() {
        var search_report = search_obj.value;
        var all_nodes = tree_reports.getAllSubItems(0);
        
        if(all_nodes.length === undefined) {
            return;
        }
        
        var all_nodes_arr = all_nodes.split(',');
        
        for (i=0; i<all_nodes.length; i++) {
            var tree_level = tree_reports.getLevel(all_nodes_arr[i]);
            if (tree_level == 1) {
                tree_reports._idpull[all_nodes_arr[i]].htmlNode.parentNode.parentNode.style.display="";
                var child_nodes = tree_reports.getAllSubItems(all_nodes_arr[i]);
                var child_nodes_arr = child_nodes.split(',');
                var child_exist_flag = 0;
                
                for (j=0; j<child_nodes_arr.length; j++) {
                    if (tree_reports.getItemText(child_nodes_arr[j]).toString().toLowerCase().indexOf(search_report.toLowerCase()) > -1){
                        child_exist_flag = 1;
                        tree_reports._idpull[child_nodes_arr[j]].htmlNode.parentNode.parentNode.style.display="";
                    } else {
                        tree_reports._idpull[child_nodes_arr[j]].htmlNode.parentNode.parentNode.style.display="none";
                    }
                }
                
                if (child_exist_flag == 0) {
                     tree_reports._idpull[all_nodes_arr[i]].htmlNode.parentNode.parentNode.style.display="none";
                }
            }
        }
        
        if(search_report == '') {
            
        } 
    }
    //for filtering toolbar : datasource
    ///*
    function filter_report_ds() {
        var search_report = search_obj_ds.value;
        var all_nodes = tree_sources.getAllSubItems('b_1');
        
        if(all_nodes.length === undefined) {
            return;
        }
        var all_nodes_arr = all_nodes.split(',');
        
        for (i=0; i<all_nodes_arr.length; i++) {
            var tree_level = tree_sources.getLevel(all_nodes_arr[i]);
            //console.log(all_nodes_arr);
            if (tree_level == 3) {
                //tree_sources._idpull[all_nodes_arr[i]].htmlNode.parentNode.style.display="";
                
                if (tree_sources.getItemText(all_nodes_arr[i]).toString().toLowerCase().indexOf(search_report.toLowerCase()) > -1){
                    tree_sources._idpull[all_nodes_arr[i]].htmlNode.parentNode.style.display="";
                } else {
                    tree_sources._idpull[all_nodes_arr[i]].htmlNode.parentNode.style.display="none";
                }
            }
        }
        
        if(search_report == '') {
            
        } 
        tree_sources.openAllItems('a_1');
    }
    //*/
    
    //function to init reports tree
    rm.fx_init_tree_reports = function () {
        
        tree_reports = left_acc.cells('acc_report').attachTree();
        tree_reports.setSkin("dhx_web");
        tree_reports.setImagePath(js_image_path + 'dhxtree_web/');
        tree_reports.enableKeyboardNavigation(true);
        tree_reports.enableKeySearch(true);
        tree_reports.enableMultiselection(true);
		//tree_reports.enableCheckBoxes(true,false);
        //alert(tree_reports.getItemIdByIndex()
        //tree_reports.enableThreeStateCheckboxes(true);
        //tree_reports.enableSmartCheckboxes(true);
        
        rm.fx_refresh_tree('r');
        
        tree_reports.attachEvent("onDblClick", function(id){
            var is_lock = tree_reports.getUserData(id,'is_lock');
            var report_id = '';
            if(id.indexOf('r_') > -1) {
                report_id = id.substr(2);
            } else if(id.indexOf('p_') > -1) {
                report_id = tree_reports.getParentId(id).substr(2);
            }
            if (is_lock != undefined && is_lock == 1) {
                var loaded_tab_ids = ifr_dhx.rm_template.rm_tabbar.getAllTabs();
                var compare_value = 'tab_' + report_id;
                var report_open = false;

                if(loaded_tab_ids.length > 0) {
                    $.each(loaded_tab_ids, function(index, data) {
                        if(compare_value == data.split(':')[0]) {
                            ifr_dhx.rm_template.rm_tabbar.tabs(data).setActive();
                            report_open = true;
                        }
                    });
                    if(report_open) {
                        return; //report is already open on tab
                    }
                }
                var param_obj = {
                    "param1"  :  'e',
                    "param2"   :  report_id
                };
                is_user_authorized('rm.fx_init_process_tables',param_obj);
            } else {
                rm.fx_init_process_tables('e',report_id);
            }
        });
        tree_reports.attachEvent("onSelect", function(id){
            if(id.indexOf('r_') > -1) {
				if(has_rights_report_manager_dhx_delete){
                    left_menu.setItemEnabled('delete_report_item');
				}
                if (has_rights_report_manager_dhx_privilege){
                    left_menu.setItemEnabled('privilege_report_item');
				}
                left_menu.setItemEnabled('deploy_report_item');

                
                if(id.indexOf(',') == -1) {
					if (has_rights_report_manager_dhx_iu){
                        left_menu.setItemEnabled('copy_report_item');
					}
                    if(has_rights_report_manager_dhx_import_export) {
                        left_menu.setItemEnabled('export_report_item');
                    }
                } else {
                    left_menu.setItemDisabled('copy_report_item');
                    left_menu.setItemDisabled('export_report_item');
                    
                }
                
            } else {
                left_menu.setItemDisabled('delete_report_item');
                //left_menu.setItemDisabled('deploy_report_item');
                left_menu.setItemDisabled('copy_report_item');
                left_menu.setItemDisabled('privilege_report_item');
            }
        });
    };


    
    
    //function to init datasources/items tree
    rm.fx_init_tree_sources = function () {
        var ds_context_menu = new dhtmlXMenuObject({
            icons_path: js_image_path + 'dhxmenu_web/',
            context: true,
            items:[
                {id:"add", text:"Add Datasource"},
				{id:"delete", text:"Delete Datasource"},
				{id:"import_datasource", text:"Import Datasource"},
				{id:"import_as_datasource", text:"Import As Datasource"},
				{id:"export_datasource", text:"Export Datasource"}
            ]
        });
        ds_context_menu.attachEvent("onClick", fx_ds_context_menu_click);
        
        tree_sources = left_acc.cells('acc_sources').attachTree();
        tree_sources.setSkin("dhx_web");
        tree_sources.setImagePath(js_image_path + 'dhxtree_web/');
        tree_sources.enableDragAndDrop(true);
        tree_sources.enableAutoTooltips(true);
        tree_sources.enableContextMenu(ds_context_menu);
        tree_sources.enableKeyboardNavigation(true);
        tree_sources.enableKeySearch(true);
        tree_sources.attachEvent('onDragIn', function(sid, tid) {
            return false; 
        });
        tree_sources.attachEvent('onBeforeDrag', function(sid, tid) {
            var loaded_tabs = ifr_dhx.rm_template.rm_tabbar.getAllTabs();
            if(sid.indexOf('report-item') != -1 && loaded_tabs.length > 0) {
                return true;
            } else {
                return false;
            }
        });
        
        tree_sources.attachEvent("onRightClick", function(id, ev){
            if (id.indexOf('c_') > -1) {
				ds_context_menu.showItem('delete');
				ds_context_menu.showItem('export_datasource');
			} else {
				ds_context_menu.hideItem('delete');
				ds_context_menu.hideItem('export_datasource');
			}
        });
        
        rm.fx_refresh_tree('s');
        
        tree_sources.attachEvent("onDblClick", function(id){
            var is_lock = tree_sources.getUserData(id,'is_lock');
            if(id.indexOf('c_') > -1) {
                var datasource_id = id.replace('c_', '');
                if (is_lock != undefined && is_lock == 1) {
                    var param_obj = {
                        "param1"  :  'u',
                        "param2"   :  datasource_id,
                        "param3" : '1'
                    };
                    is_user_authorized('fx_edit_datasource',param_obj);
                } else {
                    fx_edit_datasource('u', datasource_id,'0');
                }
            }
        });
    };
    //function for context menu item click on tree sources
    fx_ds_context_menu_click = function(item_id, type) {
        var node_id = tree_sources.contextID;
        if(item_id == 'add') {
            fx_edit_datasource('i', '','0');
        } else if(item_id == 'delete') {
            var is_lock = tree_sources.getUserData(node_id,'is_lock');
            var datasource_id = node_id.replace('c_', '');
            if (is_lock != undefined && is_lock == 1) {
                var param_obj = {
                    "param1"  :  'd',
                    "param2"   :  datasource_id,
                    "param3" : '1'
                };
                is_user_authorized('fx_edit_datasource',param_obj);
            } else {
                fx_edit_datasource('d', datasource_id,'0');
            }
        } else if(item_id == 'export_datasource') {        
            var datasource_id = node_id.replace('c_', '');
			var data = {
				"action"                : "spa_rfx_migrate_data_source_as_json",
				"flag"                  : "u",
				"data_source_id"        : datasource_id,
				"call_from"             : "UserDefinedView"
			};
			var additional_data = {
				"type": 'return_array'
			};

			data = $.param(data) + "&" + $.param(additional_data);
			$.ajax({
				type: "POST",
				dataType: "json",
				url: js_form_process_url,
				async: true,
				data: data,
				success: function(data) {
					var status =  data.json[0][0];
					var file_name = data.json[0][5];
					if (status == 'Success') {
						window.location = php_script_loc_ajax + 'force_download.php?path=dev/shared_docs/temp_Note/'+ file_name;
					} else {
						dhtmlx.alert({
							title:"Alert",
							type:"alert",
							text:'Issue while downloading file.'
						});
					}
				}
			}); // End of ajax                    
                
		} else if(item_id == 'import_datasource' || item_id == 'import_as_datasource') {
			if (rm.import_window != null && rm.import_window.unload != null) {
				rm.import_window.unload();
				rm.import_window = w2 = null;
			}
			if (!rm.import_window) {
				rm.import_window = new dhtmlXWindows();
			}

			rm.new_win = rm.import_window.createWindow('w2', 0, 0, 670, 325);

			var text = "Import Data Source";

			rm.new_win.setText(text);
			rm.new_win.setModal(true);
			
			var url = app_form_path + '_setup/setup_user_defined_view/setup.user.defined.view.import.ui.php';
			item_id =  (item_id == 'import_datasource') ? 'import_item' : 'import_as_item';
			url = url + '?call_from=UserDefinedView&import_type=' + item_id;
			rm.new_win.attachURL(url, false, true);
		} // end of if
    }
	
    //function to edit datasource
    fx_edit_datasource = function(flag, datasource_id, is_validated) {
        var args = '?mode=' + flag + '&source_id=' + datasource_id ;
        if(flag == 'd') {
            confirm_messagebox('Are  you sure you want to delete selected datasource(s)?', function() {
                var sp_string = "EXEC spa_rfx_data_source_dhx @flag='d', @source_id=" + datasource_id; 
                post_data = { sp_string: sp_string };
                //console.log(sp_string);
                $.ajax({
                    url: js_form_process_url,
                    data: post_data,
                }).done(function(data) {
                    var json_data = data['json'][0];
                    if(json_data.errorcode == 'Success'){
                        success_call(json_data.message);
                        rm.fx_refresh_tree('s');
                    } else {
                        dhtmlx.message({
                            title: 'Error',
                            type: 'alert-error',
                            text: json_data.message
                        });
                    }
                }); 
            });
        } else {

            dhx_wins.createWindow({
                id: 'window_data_source'
                ,width: 1150
                ,height: 500
                ,modal: true
                ,resize: true
                ,text: 'Datasource Detail'
                ,center: true
                ,maximize: true
            });
            var param_obj_ds ={
                ds_flag: flag,
                data_source_id: datasource_id
            };
            var post_params = {
                ds_info_obj: JSON.stringify(param_obj_ds),
                call_from: 'rfx_data_source',
                is_validated:is_validated
            };
            // var file_path = '_reporting/report_manager/report.manager.datasource.form.iu.main.php' + args;
            // open_menu_window(file_path, "windowReportManagerDatasourceListIU", "Report Datasource","10201625"); 
            // return;

            
            //console.log(post_params);
            var data_source_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.datasource.php';
            dhx_wins.window('window_data_source').attachURL(data_source_url, null, post_params);
            
            dhx_wins.window('window_data_source').maximize();
            return;


             
        }
        
    }
    //function to refresh tree
	
	rm.expand_tree_reports = function (type) {
		var tree_obj = '';        
        var param = '';
        if (type == 'r') {
            tree_obj = tree_reports;
            param = {
                'action': 'spa_rfx_report_record_dhx',
                'grid_type': 't',
                'value_list': 'paramset_id:paramset_name',
                'value_list': 'report_id:report_name:system_defined',
                'grouping_column': 'category_id:category_name,report_id:report_name',
                'grouping_column': 'category_id:category_name',
                'flag': 'z'
            };
            
            left_menu.setItemDisabled('delete_report_item');
            //left_menu.setItemDisabled('deploy_report_item');
            left_menu.setItemDisabled('copy_report_item');
            var img_path = js_image_path + 'dhxtree_web/';
            var img1 = 'leaf.gif';
            var img2 = 'book_open.gif';
            var img3 = 'book_close.gif';
            tree_obj.setImagesPath(img_path);
            tree_obj.setStdImages(img1,img2,img3);
            tree_obj.enableTreeLines(true);
        } else {
            alert('fx_refresh_tree, undefined parameter value type.');
        }        
        tree_obj.deleteChildItems(0);
        param = $.param(param);
        var data_url = js_data_collector_url + '&' + param;
        tree_obj.loadXML(data_url, function() {
			if(type == 'r') {
				if(expand_state == 0) { 
					 expand_state = 1;
					 tree_obj.openAllItems(a_1);					
					} else{
						expand_state = 0;
						tree_obj.openAllItems(0);												
					}
                
            } 
            var search_obj = tool_bar_reports.getInput("search_text");
            filter_report();
            filter_report_ds();
        });
        
    };
		
	
    rm.fx_refresh_tree = function (type) {        
        var tree_obj = '';        
        var param = '';
        if (type == 'r') {
            tree_obj = tree_reports;
            param = {
                'action': 'spa_rfx_report_record_dhx',
                'grid_type': 't',
                'value_list': 'paramset_id:paramset_name',
                'value_list': 'report_id:report_name:system_defined',
                'grouping_column': 'category_id:category_name,report_id:report_name',
                'grouping_column': 'category_id:category_name',
                'flag': 'z'
            };
            
            left_menu.setItemDisabled('delete_report_item');
            //left_menu.setItemDisabled('deploy_report_item');
            left_menu.setItemDisabled('copy_report_item');
            var img_path = js_image_path + 'dhxtree_web/';
            var img1 = 'leaf.gif';
            var img2 = 'book_open.gif';
            var img3 = 'book_close.gif';
            tree_obj.setImagesPath(img_path);
            tree_obj.setStdImages(img1,img2,img3);
            tree_obj.enableTreeLines(true);
        } else if (type == 's') {
            tree_obj = tree_sources;
            param = {
                'action': 'spa_rfx_data_source_dhx',
                'grid_type': 't',
                'value_list': 'ds_id:ds_name:system_defined',
                'grouping_column': 'root_id:root_name,ds_type_id:ds_type_name',
                'flag': 'z'
            };
        } else {
            alert('fx_refresh_tree, undefined parameter value type.');
        }
        
        tree_obj.deleteChildItems(0);
        param = $.param(param);
        var data_url = js_data_collector_url + '&' + param;
        tree_obj.loadXML(data_url, function() {
            if(type == 'r') {
                tree_obj.openAllItems(0);
                
            } else if (type == 's') {
                tree_obj.openAllItems(0);
                //tree_obj.openItem('a_2');
            }
            var search_obj = tool_bar_reports.getInput("search_text");
            // search_obj.value = "";
            filter_report();
            filter_report_ds();
        });
        left_menu.setItemDisabled('privilege_report_item');
    };
    
        
    // function for report menu click 
    rm.fx_menu_click = function(id) {
        switch(id) {
            case 'add_report_item':
                rm.fx_edit_report_item('i');
                break;
            case 'delete_report_item':
                rm.fx_edit_report_item('d');
                break;
            case 'copy_report_item':
                rm.fx_edit_report_item('c');
                break;
            case 'deploy_report_item':
                rm.fx_edit_report_item('r');
                break;
            case 'refresh_tree_reports':
                rm.fx_refresh_tree('r');
                break;
			case 'expand_collapse':
                rm.expand_tree_reports('r');
			    break;
            case 'privilege_report_item':
                rm.fx_edit_report_item('p');
                break;
            case 'export_report_item':
            case 'import_report_item':
            case 'import_as_report_item':
                rm.fx_edit_report_item(id);
                break;
        }  
    };
    // function to add/update report item 
    rm.fx_edit_report_item = function(flag) {
        switch(flag) {
            case 'i':
                rm.fx_open_report_def(flag);
                break;
            case 'd':
            case 'r':
            case 'p':
            case 'export_report_item':
            case 'import_report_item':
            case 'import_as_report_item':
                var report_id_arr = tree_reports.getSelectedItemId().split(',');
                report_id_arr = $.grep(report_id_arr, function(val) {
                    return (val.indexOf('r_') > -1); 
                });
                var report_id = report_id_arr.join(',');
                
                var find = 'r_';
                var re = new RegExp(find, 'g');
                report_id = report_id.replace(re, '');
                
                if(flag == 'd') {
                    var is_system_rule = false;
                    for(var count = 0; count < report_id_arr.length; count++){
                        var is_lock = tree_reports.getUserData(report_id_arr[count],'is_lock');
                        if (is_lock == 1 && is_lock != undefined) {
                            is_system_rule = true;
                            break;
                        }
                    }
                    if (is_system_rule) {
                        var param_obj = {
                            "param1"  :  report_id
                        };
                        is_user_authorized('rm.post_validation_delete_report',param_obj);
                    } else {
                        rm.post_validation_delete_report(report_id);
                    }
                } else if(flag == 'r' && report_id_arr.length == 0) { //deploy all reports when none selected
                    confirm_messagebox('Are you sure you want to deploy all reports?', function() {
                        report_id = tree_reports.getAllChildless().replace(re, '');
                        rm.fx_bulk_deploy_report(report_id);
                    });
                } else if(flag == 'r' && report_id_arr.length > 0){ //deploy selected reports
                    rm.fx_bulk_deploy_report(report_id);
                } else if(flag == 'p') {
                    rm.fx_maintain_privilege(report_id);
                } else if(flag == 'export_report_item' || flag == 'import_report_item' || flag == 'import_as_report_item') { //export
                    rm.fx_import_export_report(flag, report_id);
                }
                
                break;
            case 'c':
                var report_name = tree_reports.getSelectedItemText();
                rm.fx_copy_report(report_name);
                break;
        }
        
    };

    rm.fx_import_export_report = function(import_task, report_id) {
        if(import_task == 'export_report_item') {
            var sp_string = "EXEC spa_rfx_migrate_report_as_json @flag='e', @report_id='" + report_id + "'";
            post_data = { sp_string: sp_string };

            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                var json_data = data['json'][0];
                var json_file_path = js_php_path + 'dev/shared_docs/temp_Note/' + json_data.message;

                if(json_data.errorcode == 'Success') {
                    window.location = js_php_path + 'force_download.php?path=' + json_data.message;
                    success_call('Export File downloaded.');
                } else {
                    dhtmlx.message({
                        title: 'Error',
                        type: 'alert-error',
                        text: json_data.message
                    });
                }

            });
        } else if(import_task == 'import_report_item' || import_task == 'import_as_report_item') {
            window_import_report = dhx_wins.createWindow({
                id: 'window_import_report'
                ,width: 600
                ,height: 300
                ,modal: true
                ,resize: false
                ,text: 'Report Import (JSON)'
                ,center: true
                
            });
            
            //attach form on window
            var form_ip_label_width = 120;
            var hidden_import_as = true;

            if(import_task == 'import_as_report_item') {
                hidden_import_as = false;
            }

            var import_form_json = [
                {type:'settings', position: 'label-top'},
                {type:'block', blockOffset: ui_settings['block_offset'], list: [
                    {type:"input", name:"import_as", hidden: hidden_import_as, label:"Import As", width : ui_settings['field_size'], offsetLeft : ui_settings['offset_left'],required:!hidden_import_as, userdata:{"validation_message":"Required Field."}},
                    {type:'newcolumn'},
                    {type: 'fieldset', label: 'File Attachment', offsetLeft: 15, list: [
                        {type: 'upload', name: 'upload_json_file', inputWidth:'500', url:get_file_uploader_url()+'&call_form=data_import_export', autoStart:true},
                        {type: 'label', label: '* Note: The permitted file formats are JSON document.'}
                    ]}
                ]}
            ];

            form_import_report = window_import_report.attachForm(import_form_json);

            form_import_report.attachEvent("onBeforeFileAdd",function(filename) {
                // your code here
                var file_ext = filename.split('.').pop();
                if(file_ext != 'json') {
                    dhtmlx.message('Only JSON file are accepted.');
                    return false;
                } else {
                    return true;    
                }
                
            });
            
            //save button added on toolbar
            window_import_menu = window_import_report.attachToolbar({
                icon_path: js_image_path + 'dhxtoolbar_web/',
                items:[
                    {id:"import_ok", title:"Import", text:"Ok", type: "button", disabled: false, img: 'save.gif', img_disabled: 'save_dis.gif'}
                ],
                onClick:function(id){
                    switch(id) {
                        case 'import_ok':

                            if(!validate_form(form_import_report)) {
                                generate_error_message();
                                return;
                            }
                            var upload_data = form_import_report.getItemValue('upload_json_file');
                            var import_as_name = form_import_report.getItemValue('import_as');
                            
                            if(upload_data.upload_json_file_count != 1) {
                                dhtmlx.message({
                                    title: 'Error',
                                    type: 'alert-error',
                                    text: 'Invalid number of files to import. (Must be 1 file.)'
                                });
                            } else {
                                window_import_report.progressOn();
                                var json_file_name = upload_data.upload_json_file_r_0;

                                if(import_task == 'import_as_report_item') {
                                    var sp_string = "EXEC spa_rfx_migrate_report_as_json @flag='v', @json_file_name='" + json_file_name + "'" + (import_task == 'import_as_report_item' ? ", @import_as_name='" + import_as_name + "'" : "");

                                    post_data = { sp_string: sp_string };

                                    $.ajax({
                                        url: js_form_process_url,
                                        data: post_data,
                                    }).done(function(data) {
                                        var json_data = data['json'][0];
                                        
                                        if(json_data.report_exists == 1) {
                                            dhtmlx.message({
                                                type: "confirm",
                                                title: "Confirmation",
                                                ok: "Confirm",
                                                text: "Data already exist. Are you sure you want to replace data?",
                                                callback: function(result) {
                                                    if (result) {
                                                        rm.fx_import_json(import_task,json_file_name,import_as_name);
                                                    } else {
                                                        window_import_report.progressOff();
                                                    }
                                                }
                                            });
                                            
                                        } else {
                                            rm.fx_import_json(import_task,json_file_name,import_as_name);
                                        }

                                    });
                                } else if(import_task == 'import_report_item') {
                                    rm.fx_import_json(import_task,json_file_name,"");
                                }
                                
                                
                            }
                            break;
                    }  
                }
            });
        }

    }

    rm.fx_import_json = function(import_task,filename,import_as_name) {
        var flag = '';
        if(import_task == 'import_report_item') {
            flag = 'i';
        } else if(import_task == 'import_as_report_item') {
            flag = 'j';
        }
        var sp_string = "EXEC spa_rfx_migrate_report_as_json @flag='" + flag + "', @json_file_name='" + filename + "'" + (flag == 'j' ? ", @import_as_name='" + import_as_name + "'" : "");
        post_data = { sp_string: sp_string };

        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            window_import_report.progressOff();
            var json_data = data['json'][0];
            
            if(json_data.errorcode == 'Success') {
                show_messagebox(json_data.message);
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_data.message
                });
            }

        });
    }
    
    rm.post_validation_delete_report = function(report_id) {
        var sp_string = "EXEC spa_rfx_report_privilege_dhx @flag='z', @report_id='" + report_id + "'";
        post_data = { sp_string: sp_string };

        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if(json_data.allow_message == 'not_allowed') {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: 'Report can be deleted only by admin users or report owners.'
                });
            } else {
                confirm_messagebox('Are you sure you want to delete selected report(s)?', function() {
                    rm.fx_delete_report(report_id);
                });
            }

        });
    }

    //function to delete report item
    rm.fx_delete_report = function(report_id) {
        var exec_call = {
            action: 'spa_rfx_report_dhx',
            flag: 'd',
            report_id: report_id,
            process_id: 'NULL'
        };
        adiha_post_data('return_json', exec_call, '', '', 'rm.fx_delete_report_cb');
    };
    rm.fx_delete_report_cb = function(result) {
        var json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Report deleted successfully.');
            /* Close tabs of deleted reports */
            let deleted_report_id = json_obj[0].recommendation;
            if (deleted_report_id && deleted_report_id != '') {
                let reports_array = deleted_report_id.split(',');
                for (let i = 0; i < reports_array.length; i++) {
                    let loaded_tab_ids = ifr_dhx.rm_template.rm_tabbar.getAllTabs();
                    let compare_value = 'tab_' + reports_array[i];
                    if(loaded_tab_ids.length > 0) {
                        $.each(loaded_tab_ids, function(index, data) {
                            if(compare_value == data.split(':')[0]) {
                                ifr_dhx.rm_template.rm_tabbar.tabs(data).close();
                            }
                        });
                    }
                }
            }
            /* End of closing deleted tabs */
            rm.fx_refresh_tree('r');
        } else {
            dhtmlx.message({
                title: 'Error',
                type: 'alert-error',
                text: json_obj[0].recommendation
            });
        }
    };
    //function to copy the report package
    rm.fx_copy_report = function(report_name) {
        rm.layout.progressOn();
        var sp_string = "EXEC spa_rfx_export_report @mode='c', @report_name='" + report_name + "'"; 
        post_data = { sp_string: sp_string };
        // console.log(sp_string);
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            //console.log(data['json'][0].name);
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                success_call('Report copied successfully.');
                rm.fx_refresh_tree('r');
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_data.recommendation
                });
            }
            rm.layout.progressOff();
        });
    };
    //function to bulk deploy the selected reports
    rm.fx_bulk_deploy_report = function(report_id) {
        bulk_deploy_window = dhx_wins.createWindow({
            id: 'window_bulk_deploy'
            ,width: 800
            ,height: 400
            ,modal: true
            ,resize: false
            ,text: 'Report Bulk Deployment'
            ,center: true
        });
        
        var post_params = {
            report_id: report_id
        };
        //bulk_deploy_window.hide();
        // console.log(post_params);
        var rdl_maker_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.bulk.rdl.maker.php';
        bulk_deploy_window.attachEvent('onContentLoaded', function(id) {
            success_call('Bulk report deploy started.');            
        });
        bulk_deploy_window.attachURL(rdl_maker_url, true, post_params);
    };
    
    //function to open report definition window 
    
    var rep_def_flag_gbl = 'i';
    rm.fx_open_report_def = function(flag) {
        rep_def_flag_gbl = flag;
        window_rdf = dhx_wins.createWindow({
            id: 'window_rdf'
            ,width: 540
            ,height: 400
            ,modal: true
            ,resize: false
            ,text: 'Report Definition'
            ,center: true
            
        });
        
        //attach form on window
        var form_ip_label_width = 120;
        var rdf_form_json = [
            {type:'settings', position: 'label-top'},
            {type:'block', blockOffset: ui_settings['block_offset'], list: [
                {type:"input", name:'ip_id', required: false, hidden: true},
                {type:"input", name:"ip_height", hidden: true, label:"Report Height", width : ui_settings['field_size'], offsetLeft : ui_settings['offset_left'], validate: 'ValidNumeric'},
                {type:'newcolumn'},
                {type:"input", name:"ip_width", hidden: true, label:"Report Width", width : ui_settings['field_size'], offsetLeft : ui_settings['offset_left'], validate: 'ValidNumeric'},
                {type:'newcolumn'},
                {type:"input", name:'ip_name', required: true, label:'Report Name', width: ui_settings['field_size'], offsetLeft : ui_settings['offset_left'], userdata:{"validation_message":"Required Field."}},
                {type:'newcolumn'},
                {type:"combo", name:"cmb_ds", label:"Data Source", userdata:{"validation_message":"Required Field."}, options: [], width: ui_settings['field_size'], offsetLeft : ui_settings['offset_left'], filtering: true, filtering_mode: 'between'},
                 {type:'newcolumn'},
                {type:"input", rows: 4, name:'ip_desc', label:'Report Description', position: 'label-top', width: ui_settings['field_size'], offsetLeft : ui_settings['offset_left']},
                {type:'newcolumn'},
                {type:"combo", name:"cmb_cat", label:"Report Category", filtering: true, width: ui_settings['field_size'],offsetLeft : ui_settings['offset_left'], filtering_mode: 'between', options: []},
                {type:'newcolumn'},
                {type: "checkbox",name:'chk_sys', label:"System", checked:false, position: 'label-right', offsetLeft : ui_settings['offset_left'], labelWidth: ui_settings['field_size']},
                {type:'newcolumn'},
                {type: "checkbox",name:'chk_mobile', label:"Mobile", checked:false, position: 'label-right', offsetLeft : ui_settings['offset_left'], labelWidth:ui_settings['field_size']},
                {type:'newcolumn'},
                {type: "checkbox",name:'chk_excel', label:"Excel", checked:false, position: 'label-right', offsetLeft : ui_settings['offset_left'], labelWidth: ui_settings['field_size']},
                {type:'newcolumn'},
                {type: "checkbox",name:'chk_powerbi', label:"Power BI", checked:false, position: 'label-right', offsetLeft : ui_settings['offset_left'], labelWidth: ui_settings['field_size']},
                {type:'newcolumn'},
                {type: "checkbox",name:'chk_is_custom_report', label:"Custom Report", checked:false, position: 'label-right', offsetLeft : ui_settings['offset_left'], labelWidth: ui_settings['field_size']}
                //,{type:"button", name:'btn_save', className: 'btn_save_class', value:'Save', disabled: false, width: 87
//                    , offsetLeft: 65, offsetTop: 0, position: 'label-bottom'}
            ]}
        ];
        
        form_rd = window_rdf.attachForm(rdf_form_json);
        
        var cmb_cat = form_rd.getCombo('cmb_cat');
        //console.dir(cmb_cat);
        cmb_cat.clearAll();
        var cmb_cat_param = {
            "action": 'spa_StaticDataValues',
            "call_from": "form",
            "has_blank_option": "true",
            "flag": 'e',
            'type_id': '10008'
        };
        cmb_cat_param = $.param(cmb_cat_param);
        var cmb_cat_url = js_dropdown_connector_url + '&' + cmb_cat_param;
        cmb_cat.load(cmb_cat_url, function() {
            cmb_cat.sort('asc');
        });
        
        var cmb_ds = form_rd.getCombo('cmb_ds');
        //console.dir(cmb_cat);
        cmb_ds.clearAll();
        var cmb_ds_param = {
            "action": 'spa_rfx_data_source_dhx',
            "call_from": "form",
            "has_blank_option": "false",
            "flag": 'v'
        };
        cmb_ds_param = $.param(cmb_ds_param);
        var cmb_ds_url = js_dropdown_connector_url + '&' + cmb_ds_param;
        cmb_ds.load(cmb_ds_url, function() {
            cmb_ds.sort('asc');
            
        });
        
        //save button added on toolbar
        window_rdf_menu = window_rdf.attachToolbar({
            icon_path: js_image_path + 'dhxtoolbar_web/',
            items:[
                {id:"save", title:"Save", text:"Save", type: "button", disabled: false, img: 'save.gif', img_disabled: 'save_dis.gif'}
            ],
            onClick:function(id){
                switch(id) {
                    case 'save':
                        if(!validate_form(form_rd)) {
                            generate_error_message();
                            return;
                        }
                        rm.fx_init_process_tables('c', '');
                        break;
                }  
            }
        });
        
    };
    //function to initiate the process and process tables
    var process_id_gbl = '';
    rm.fx_init_process_tables = function(flag, report_id) {
        var loaded_tab_ids = ifr_dhx.rm_template.rm_tabbar.getAllTabs();
        var compare_value = 'tab_' + report_id;
        var report_open = false;
        
        if(flag == 'e' && loaded_tab_ids.length > 0) {
            $.each(loaded_tab_ids, function(index, data) {
                if(compare_value == data.split(':')[0]) {
                    ifr_dhx.rm_template.rm_tabbar.tabs(data).setActive();
                    report_open = true;
                }
                
            });
            
            if(report_open) {
                return; //report is already open on tab
            }
        }
        
        rm.layout.cells('b').progressOn();
        var exec_call = {
            action: 'spa_rfx_init_dhx',
            flag: flag,
            report_id: report_id
        }
        
        if(flag == 'c') {
            adiha_post_data('return_json', exec_call, '', '', 'rm.fx_init_process_tables_cb');
        } else {
            adiha_post_data('return_json', exec_call, '', '', 'rm.fx_get_report_def');
        }
        
    };
    rm.fx_init_process_tables_cb = function(result) {
        json_obj = $.parseJSON(result);
        // console.log(json_obj[0].recommendation);
        process_id_gbl = json_obj[0].recommendation;
        var report_category_id = (form_rd.getItemValue('cmb_cat') == '' ? 'NULL' : form_rd.getItemValue('cmb_cat'));
        var param_obj_report = {
            report_flag: 'i',
            process_id: json_obj[0].recommendation,
            report_id: form_rd.getItemValue('ip_id'),
            report_name: form_rd.getItemValue('ip_name'),
            report_category_id: report_category_id,
            is_system: form_rd.getItemValue('chk_sys'),
            is_mobile: form_rd.getItemValue('chk_mobile'),
            is_excel: form_rd.getItemValue('chk_excel'),
            report_description: form_rd.getItemValue('ip_desc'),
            is_powerbi: form_rd.getItemValue('chk_powerbi'),
			is_custom_report: form_rd.getItemValue('chk_is_custom_report'),
            
        };
        rm.fx_save_report_def(param_obj_report);
    };
    //function cb on report update
    rm.fx_get_report_def = function(result) {
        var json_obj = $.parseJSON(result);
        var recommendation = json_obj[0].recommendation.split(',');
        var process_id = recommendation[0];
        var report_id = recommendation[1];
        var sp_string = "EXEC spa_rfx_report_dhx @flag='a', @process_id='" + process_id + "', @report_id='" + report_id + "'"; 
        post_data = { sp_string: sp_string };
        //console.log(sp_string);
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            //console.log(data['json'][0].name);
            var json_data = data['json'][0];
            
            var param_obj = {
                process_id: process_id,
                report_id: report_id,
                report_name: json_data.name,
                report_category_id: json_data.category_id,
                report_description: json_data.description,
                is_system: json_data.system_report,
                is_mobile: json_data.is_mobile,
                is_excel: json_data.is_excel,
                page_id: json_data.page_id,
                page_width: json_data.page_width,
                page_height: json_data.page_height,
                dataset_id: '',
                report_owner: json_data.owner,
                is_powerbi: json_data.is_powerbi,
                is_custom_report: json_data.is_custom_report
            }
            ifr_dhx.rm_template.load_rm_detail(param_obj);
        });
        // console.log(process_id);
        
    };
    
    //function to save the report definition
    rm.fx_save_report_def = function(param_obj_report) {
        
        var exec_call = {
            'action': 'spa_rfx_report_dhx',
            'flag': param_obj_report.report_flag,
            'process_id': param_obj_report.process_id,
            'report_id': param_obj_report.report_id,
            'report_name': param_obj_report.report_name,
            'report_owner': js_user_name,
            'category_id': param_obj_report.report_category_id,
            'system_report': param_obj_report.is_system,
            'is_mobile': param_obj_report.is_mobile,
            'is_excel': param_obj_report.is_excel,
            'report_desc': param_obj_report.report_description,
            'is_powerbi': param_obj_report.is_powerbi,
            'is_custom_report': param_obj_report.is_custom_report
        }
        //console.dir(exec_call);
        adiha_post_data('return_json', exec_call, '', '', 'rm.fx_save_report_def_cb');
    };
    rm.fx_save_report_def_cb = function(result) {
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Report Definition saved successfully.', 'success');
            
            
            // console.log('**dhx.php**');
            //console.dir(report_obj);
            var recommendation = json_obj[0].recommendation.split(',');
            var process_id = recommendation[1];
            var report_id = recommendation[0];
            var report_flag = recommendation[2];
            var page_width = (form_rd.getItemValue('ip_width') == '' ? '11.5' : form_rd.getItemValue('ip_width'));
            var page_height = (form_rd.getItemValue('ip_height') == '' ? '5.5' : form_rd.getItemValue('ip_height'));
            
            //save dataset
            var sp_string = "EXEC spa_rfx_report_dataset_dhx @flag='i', @process_id='" + process_id 
                + "', @report_id='" + report_id 
                + "', @source_id='" + form_rd.getItemValue('cmb_ds') 
                + "'"; 
            post_data = { sp_string: sp_string };
            //console.log(sp_string);
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                //console.log(data['json'][0].name);
                var json_data = data['json'][0];
                //console.log(json_data.message);
                
                report_obj[process_id] = {
                    process_id: process_id,
                    report_id: report_id,
                    report_name: form_rd.getItemValue('ip_name'),
                    report_owner: js_user_name,
                    report_category_id: form_rd.getItemValue('cmb_cat'),
                    report_description: form_rd.getItemValue('ip_desc'),
                    is_system: form_rd.getItemValue('chk_sys'),
                    is_mobile: form_rd.getItemValue('chk_mobile'),
                    is_excel: form_rd.getItemValue('chk_excel'),
                    is_powerbi: form_rd.getItemValue('chk_powerbi'),
					is_custom_report: form_rd.getItemValue('chk_is_custom_report'),
                    page_id: 'NULL',
                    page_width: page_width,
                    page_height: page_height,
                    dataset_id: json_data.message
                };
                //console.log(report_obj[process_id]);
                
                
                
                var param_obj_page = {
                    page_flag: 'i',
                    report_obj: report_obj[process_id]
                };
                dhx_wins.window('window_rdf').close();
                
                fx_save_page_info(param_obj_page);
            });
        
        } else {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
            });
        }
    };
    //function to save page info
    function fx_save_page_info(param_obj_page) {
        var xml_ri = '';
        if (param_obj_page.page_flag == 'u') {
            xml_ri = ifr_dhx.ifr_tab[param_obj_page.report_obj.process_id].ifr_page.save_layout();
        }
        
        var post_url = {
            'action': 'spa_rfx_report_page_dhx',
            'flag': param_obj_page.page_flag,
            'process_id': param_obj_page.report_obj.process_id,
            'report_page_id': param_obj_page.report_obj.page_id,
            'report_id': param_obj_page.report_obj.report_id,
            'name': param_obj_page.report_obj.report_name,
            'width': param_obj_page.report_obj.page_width,
            'height': param_obj_page.report_obj.page_height,
            'xml': xml_ri
        };
        //console.dir(post_url);
        adiha_post_data('return_json', post_url, '', '', 'fx_save_page_info_cb');
    }
    function fx_save_page_info_cb(result) {
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            // console.log('***page info saved ***');
            var recommendation = json_obj[0].recommendation.split(',');
            var process_id = recommendation[2];
            var paramset_id = recommendation[1];
            var page_id = recommendation[0];
            var page_flag = recommendation[3];
            
            report_obj[process_id].page_id = page_id;
            //console.log(report_obj[process_id]);
            ifr_dhx.rm_template.load_rm_detail(report_obj[process_id]);
            
        } else {
            // console.log('##error on saving page info##');
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
            });
            //console.log('##error on saving page info##');
        }
    }
    
    //open rm privilege window
    rm.fx_maintain_privilege = function(report_id) {
        var sp_string = "EXEC spa_rfx_report_privilege_dhx @flag='z', @report_id='" + report_id + "'"; 
        post_data = { sp_string: sp_string };
        
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if(json_data.allow_message == 'not_allowed') {
                show_messagebox('Report Privilege can be assigned only by admin users or report owners.');
                return;
                
            } else {
                window_privilege = dhx_wins.createWindow({
                    id: 'window_privilege'
                    ,width: 1100
                    ,height: 500
                    ,modal: true
                    ,resize: true
                    ,text: 'Report Manager Privilege'
                    ,center: true
                    
                });
                var post_params = {
                    call_from: 'report_privilege',
                    object_id: report_id
                };
                var privilege_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.privilege.php';
                window_privilege.attachURL(privilege_url, null, post_params);
            }
            
        });
        
    };
        
    //function to popup report paramset detail window
    function fx_popup_report_paramset_detail(mode, report_paramset_id, page_id, report_id) {
        window_rp = dhx_wins.createWindow({
            id: 'window_rp'
            ,width: 1250
            ,height: 500
            ,modal: true
            ,resize: true
            ,text: 'Report Paramset Detail'
            ,center: true
            
        });
        var post_params = {
            report_paramset_id: report_paramset_id,
            process_id: process_id_gbl,
            mode: mode,
            report_id: report_id,
            page_id: page_id
        };
        var paramset_template_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.paramset.template.php';
        window_rp.attachURL(paramset_template_url, null, post_params);
    }
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
	
	/**
     * Import from file function to be called from child UI
     * @param  String   file_name File Name
     * @param  String   cpoy_as   Import As Name
     */
    function import_from_file(file_name, copy_as) {                
        var data = {"action": "spa_rfx_migrate_data_source_as_json",
            "flag": "z",
            "json_file_name": file_name,
            "import_as_name" : copy_as,
            "call_from" : "UserDefinedView"
        };
        
        adiha_post_data('return_array', data, '', '', 'rm.import_from_confirmation', '', '');                 
    }

    /**
     * Call back confirmation function for import_from_file
     * @param  Array return_value Return Data Values
     */
    rm.import_from_confirmation = function(return_value) {  
        var confirm_type = return_value[0][0];
        var message = return_value[0][4];
        if (confirm_type == 'Error') {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:message
            }); 
            return
        }
        var adiha_type = '';
        var validation = '';
        var file_name = return_value[0][1];
        var copy_as = return_value[0][2];

        if (confirm_type == 'r') {
            validation = message;
            adiha_type = 'confirm';
        } else {
            adiha_type = 'return_array';
        }
        
        rm.new_win.close();
        data = {"action": "spa_rfx_migrate_data_source_as_json",
                "flag": "y",
                "json_file_name": file_name,
                "import_as_name" : copy_as,
                "call_from" : "UserDefinedView"
            };
        
        adiha_post_data(adiha_type, data, '', '', 'rm.import_export_call_back', '', validation);                 
    }

    /**
     * Call back confirmation function for import_from_confirmation
     * @param  Array return_value Return Data Values
     */
    rm.import_export_call_back = function(result) {
        var is_success = result[0][0];
        var msg_req = 'n';

        if (is_success === undefined) {
            is_success = result[0].errorcode;
            message = result[0].message
        } else {
            message = result[0][4];
            msg_req = 'y';
        }

        if (is_success == "Success") {
            if (msg_req == 'y') {
                dhtmlx.message({
                text:message,
                expire:1000
                });    
            }
            
            rm.fx_refresh_tree('s');
        } else {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:message
            });                    
        }
    }
</script>