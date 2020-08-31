<?php
/**
* Report manager tab template screen
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
    ?>
</head>
<body class = "bfix2">
    <div id="div_design_area" item_id="" process_id=""></div>
    <?php     
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $form_function_id = 10163600;
    
    $form_namespace = 'rm_tab';
    $json = "[
                {
                    id:         'a',
                    header:     false
                }

            ]";
          
    $rm_layout = new AdihaLayout();
    echo $rm_layout->init_layout('layout', '', '1C', $json, $form_namespace);
           
    echo $rm_layout->close_layout();
    
    $report_id = get_sanitized_value($_POST['report_id'] ?? '');
    $report_name = get_sanitized_value($_POST['report_name'] ?? '');
    $page_id = get_sanitized_value($_POST['page_id'] ?? '');
    $page_width = get_sanitized_value($_POST['page_width'] ?? '');
    $page_height = get_sanitized_value($_POST['page_height'] ?? '');
    $process_id = get_sanitized_value($_POST['process_id'] ?? '');
    $report_flag = get_sanitized_value($_POST['report_flag'] ?? '');
    $report_obj = isset($_POST['report_obj']) ? json_decode($_POST['report_obj']) : '';

    ?>
</body>
<style>
div#div_design_area {
    position: relative;
    width: 100%;
    height: 100%;
    overflow: hidden;
    padding: 2px;
}
#ifr_page {
    position: relative;
    width: 100%;
    height: 100%;
    border: 1px solid silver;
}
</style>    
<script>
    var report_obj = $.parseJSON('<?php echo json_encode($report_obj); ?>'.replace(/\n/g, "\\n"));
    var post_data = '';
    
    // console.log('**dhx.tab.template.php**');
    //console.dir(report_obj);
    new dhtmlDragAndDropObject();
    $(function(){
        dhxWins = new dhtmlXWindows();
        fx_initial_load();
        
    });
    
    //function to load initial values
    function fx_initial_load() {
        //rm.fx_init_inner_layout();
        rm_tab.fx_init_tabs();
        //rm.fx_init_form_design();
        //rm.fx_init_process_tables();
        
    }
    
    
    rm_tab.fx_init_tabs = function() {
        json_tabs = [
            {
            id:      "tab_design",      // tab id
            text:    "Design",    // tab text
            width:   null,      // numeric for tab width or null for auto, optional
            index:   1,      // numeric for tab index or null for last position, optional
            active:  true,      // boolean, make tab active after adding, optional
            enabled: true,     // boolean, false to disable tab on init
            close:   false       // boolean, render close button on tab, optional
            },
            {
            id:      "tab_dataset",
            text:    "Datasets",
            width:   null,
            index:   2,
            active:  false,
            enabled: true,
            close:   false
            },
            {
            id:      "tab_paramset",
            text:    "Paramsets",
            width:   null,
            index:   3,
            active:  false,
            enabled: true,
            close:   false
            },
            {
            id:      "tab_preview",
            text:    "Preview",
            width:   null,
            index:   4,
            active:  false,
            enabled: true,
            close:   false
            }
        ];
        rm_tabs = rm_tab.layout.cells('a').attachTabbar({
            tabs: json_tabs
        });
        
        var preview_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.preview.php';
        var post_params = {
            process_id: report_obj.process_id
               
        };
        rm_tabs.cells('tab_preview').attachURL(preview_url, null, post_params);
        ifr_preview = rm_tabs.cells('tab_preview').getFrame().contentWindow;
        rm_tabs.cells('tab_preview').hide();
        
        rm_tabs.attachEvent('onTabClick', function(id) {
            if(id == 'tab_preview') {
                //ifr_preview.fx_get_form_json(1);
            }
        });
        
        /*
        var preview_menu_json = [{id: "refresh", img:"refresh.gif", img_disabled:"refresh_dis.gif", text:"Refresh", title:"Refresh"}];
        preview_menu = rm_tabs.cells('tab_preview').attachMenu({
            icons_path: js_image_path + 'dhxmenu_web/',
            items: preview_menu_json
        });
        
        //function when click on tab
        preview_menu.attachEvent("onClick", function(id){
            if(id == 'refresh') {
                ifr_preview.fx_preview_refresh();
            }
        });
        */
        var is_custom_report = report_obj.is_custom_report;
		if (is_custom_report == 1) {
			
			var upload_menu_json = {
                    icons_path: js_image_path + 'dhxmenu_web/',
                    items: [
                        {id: 'upload_custom_rdl', text: 'Upload/Deploy RDL', img: 'upload.gif',img_disabled: 'upload_dis.gif', enabled: 1},
						{id: 'generate_custom_rdl', text: 'Generate RDL', img: 'download.gif',img_disabled: 'download_dis.gif', enabled: 1}
                    ]};
        
			custom_rdl_upload_menu = rm_tabs.cells('tab_design').attachMenu(upload_menu_json);
			
			var upload_form_json = [  
				{"type":"settings", "position":""},
				{
					"type": "block",
					"offsetTop": 0,
					"blockOffset": 5,
					"list":[
						{"type": "fieldset", "label": "Data Source Location","offsetLeft":"30", "offsetTop":"15","list": [
							{"type": "upload", "name": "upload_file_name", "autoStart":true, "inputWidth": "440", "url": js_file_uploader_url + "&call_form=data_import_export", "mode": "html5"}
						]},
						{"type": "hidden", "value":"", "name":"file_attachment"}
					]
				}
			];
			custom_rdl_upload_form = rm_tabs.cells('tab_design').attachForm();
			custom_rdl_upload_form.load(upload_form_json);
			
			custom_rdl_upload_form.attachEvent('onUploadFile', function(realName,serverName) {
				custom_rdl_upload_form.setItemValue('file_attachment', serverName);
			});

			custom_rdl_upload_form.attachEvent('onFileRemove', function(realName,serverName){
				custom_rdl_upload_form.setItemValue('file_attachment', '');
			});
			
			custom_rdl_upload_menu.attachEvent('onClick', function(id) {
				
				if (id == 'upload_custom_rdl') {
					var report_name = custom_rdl_upload_form.getItemValue('file_attachment')
					report_name = report_name.replace('.rdl','');
					
					var exec_call = {
						action: 'spa_rfx_deploy_rdl_as_job',
						proc_desc: 'RDL Deployer',
						user_login_id: 'farrms_admin',
						job_subsystem: 'TSQL',
						report_page_id: report_obj.page_id,
						report_name: report_name
					}
					adiha_post_data('return_json', exec_call, '', '', '');
					
					dhtmlx.message({
						text: "The deploy process started.",
						expire:1000
					});
					
				} else if (id == 'generate_custom_rdl') {
					fx_generate_custom_rdl();
				}
			});
			
		} else {
			rm_tabs.cells('tab_design').attachObject('div_design_area');
        }
		
        var get_params = 'mode=u&report_id=' + report_obj.report_id + 
            '&process_id=' + report_obj.process_id +
            '&page_id=' + report_obj.page_id +
            '&report_flag=' + report_obj.report_flag +
            '&page_height=' + report_obj.page_height +
            '&page_width=' + report_obj.page_width +
            '&page_name=' + report_obj.report_name +
            '&dataset_id=' + report_obj.dataset_id +
            '&session_id=' + js_session_id +
            '';
        var url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.page.template.php?' + get_params;
        //rm_tabs.cells('tab_design').attachURL(url);
        div_obj = $('#div_design_area');
        div_obj.attr('process_id', report_obj.process_id);
        div_obj.html('<iframe id="ifr_page" src="' + url + '" scrolling="no"></iframe>');
        
        $('#ifr_page').load(function() {
            ifr_page = $('#ifr_page')[0].contentWindow;
            //parent.tab_report.progressOff();
            parent.parent.rm.layout.cells('b').progressOff();
        });
        
        //ifr_page = rm_tabs.cells('tab_design').getFrame().contentWindow;
        rm_tab.fx_init_tab_paramsets();
        rm_tab.fx_init_tab_datasets();
        
    };
    //function for preview click
    fx_preview_click = function() {
        var report_id = parent.report_deploy[report_obj.process_id].physcial_report_id;
        if(report_id == '' || report_id === undefined) {
            dhtmlx.message({
                title: 'Warning',
                type: 'alert-warning',
                text: 'Please deploy the report first.'
            });
        } else {
            ifr_preview.rm_preview.load_report_detail(report_id);
        }
        
    };
    //function to initiate paramset tab
    rm_tab.fx_init_tab_paramsets = function() {
        
        layout_paramset = rm_tabs.cells('tab_paramset').attachLayout({
            //parent: rm_tabs.cells('tab_paramset'),
            pattern: '1C',
            cells: [
                {
                    id: 'a',
                    text: 'Paramsets',
                    header: false
                }
            ]  
        });
        
        if (report_obj.is_powerbi == 1) {
        menu_json = 
            {
                icons_path: js_image_path + 'dhxmenu_web/',
                items: [
                    {id: 'refresh', text: 'Refresh', img: 'refresh.gif',img_disabled: 'refresh_dis.gif', enabled: 1},
                    {
                        id: 'edit', text: 'Edit', img: 'edit.gif',img_disabled: 'edit_dis.gif', enabled: 1,
                        items: [
                            {id: 'add', text: 'Add', img: 'add.gif',img_disabled: 'add.gif', enabled: 1},
                            {id: 'delete', text: 'Delete', img: 'delete.gif',img_disabled: 'delete_dis.gif', enabled: 0},
                            {id: 'copy', text: 'Copy', img: 'copy.gif',img_disabled: 'copy_dis.gif', enabled: 0}
                        ]
                        },
                        {
                            id: 'process', text: 'Process', img: 'process.gif',img_disabled: 'process_dis.gif', enabled: 1,
                            items: [
                                {id: 'load_powerbi', text: 'Generate PowerBI Template', img: 'gen_sample_data.gif',img_disabled: 'gen_sample_data_dis.gif', enabled: 1},
                                {id: 'upload_powerbi', text: 'Upload PBIX', img: 'upload.gif',img_disabled: 'upload_dis.gif', enabled: 1},
                                {id: 'download_powerbi', text: 'Download PBIX', img: 'download.gif',img_disabled: 'download_dis.gif', enabled: 1}
                            ]
                    }
                ]
                
            }
        ;
        } else {
            menu_json = 
                {
                    icons_path: js_image_path + 'dhxmenu_web/',
                    items: [
                        {id: 'refresh', text: 'Refresh', img: 'refresh.gif',img_disabled: 'refresh_dis.gif', enabled: 1},
                        {
                            id: 'edit', text: 'Edit', img: 'edit.gif',img_disabled: 'edit_dis.gif', enabled: 1,
                            items: [
                                {id: 'add', text: 'Add', img: 'add.gif',img_disabled: 'add.gif', enabled: 1},
                                {id: 'delete', text: 'Delete', img: 'delete.gif',img_disabled: 'delete_dis.gif', enabled: 0},
                                {id: 'copy', text: 'Copy', img: 'copy.gif',img_disabled: 'copy_dis.gif', enabled: 0}
                            ]
                        }
                    ]
                    
                }
            ;
        }
        menu_pm = layout_paramset.cells('a').attachMenu(menu_json);
        
        //on menu click
        menu_pm.attachEvent('onClick', function(id) {
            fx_menu_click_pm(id); 
        });
        
        
        grid_pm = layout_paramset.cells('a').attachGrid();
        rm_tab.fx_init_grid_paramset(grid_pm);
        
        
    };
    //function to initiate dataset tab
    rm_tab.fx_init_tab_datasets = function() {
        
        layout_dataset = rm_tabs.cells('tab_dataset').attachLayout({
            //parent: rm_tabs.cells('tab_dataset'),
            pattern: '1C',
            cells: [
                {
                    id: 'a',
                    text: 'datasets',
                    header: false
                }
            ]  
        });
        
        menu_json = 
            {
                icons_path: js_image_path + 'dhxmenu_web/',
                items: [
                    {id: 'refresh', text: 'Refresh', img: 'refresh.gif',img_disabled: 'refresh_dis.gif', enabled: 1},
                    {
                        id: 'edit', text: 'Edit', img: 'edit.gif',img_disabled: 'edit_dis.gif', enabled: 1,
                        items: [
                            {id: 'add', text: 'Add', img: 'add.gif',img_disabled: 'add_dis.gif', enabled: 1},
                            {id: 'delete', text: 'Delete', img: 'delete.gif',img_disabled: 'delete_dis.gif', enabled: 1}
                        ]
                    },
                    {
                        id: 'process', text: 'Process', img: 'process.gif',img_disabled: 'process_dis.gif', enabled: 1,
                        items: [
                            {id: 'load_csv', text: 'Generate Sample Data', img: 'gen_sample_data.gif',img_disabled: 'gen_sample_data_dis.gif', enabled: 1}
                        ]
                    }
                ]
                
            }
        ;
        menu_ds = layout_dataset.cells('a').attachMenu(menu_json);
        
        //on menu click
        menu_ds.attachEvent('onClick', function(id) {
            fx_menu_click_ds(id); 
        });
        
        
        grid_ds = layout_dataset.cells('a').attachGrid();
        rm_tab.fx_init_grid_dataset(grid_ds);
        
        
    };
    //function for menu click paramset
    fx_menu_click_pm = function(id) {
        switch(id) {
            case 'refresh':
                fx_refresh_grid('grid_pm');
                break;
            case 'add':
                fx_edit_paramset('i', '');
                break;
            case 'delete':
                confirm_messagebox('Are you sure you want to delete the selected data?', function() {
                    var paramset_id = grid_pm.cells(grid_pm.getSelectedRowId(), grid_pm.getColIndexById('paramset_id')).getValue();
                    fx_edit_paramset('d', paramset_id);
                });
                break;
            case 'copy': //sp flag = o
                confirm_messagebox('Are you sure you want to copy the selected data?', function() {
                    var paramset_id = grid_pm.cells(grid_pm.getSelectedRowId(), grid_pm.getColIndexById('paramset_id')).getValue();
                    fx_edit_paramset('o', paramset_id);
                });
                break;
            case 'load_powerbi':
                process_power_bi_report(id);
                break;
            case 'upload_powerbi':
                process_power_bi_report(id);
                break;
            case 'download_powerbi':
                process_power_bi_report(id);
                break;
        }
        
    };
    //function for menu click dataset
    fx_menu_click_ds = function(id) {
        switch(id) {
            case 'refresh':
                fx_refresh_grid('grid_ds');
                break;
            case 'add':
                fx_edit_dataset('i', '');
                break;
            case 'delete':
                confirm_messagebox('Are you sure you want to delete the selected data?', function() {
                    var dataset_id = grid_ds.cells(grid_ds.getSelectedRowId(), grid_ds.getColIndexById('dataset_id')).getValue();
                    fx_edit_dataset('d', dataset_id);
                });
                
                break;
            case 'load_csv':
                fx_load_dataset_csv();
                break;
        }
        
    };
    fx_edit_grid_pm = function(paramset_flag) {
        var exec_call = {
            action: 'spa_rfx_report_paramset_dhx',
            flag: paramset_flag,
            process_id: report_obj.process_id,
            report_id: report_obj.report_id,
            page_id: report_obj.page_id
        }
        adiha_post_data('return_json', exec_call, '', '', 'fx_edit_grid_pm_cb');
    }
    fx_edit_grid_pm_cb = function(result) {
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Paramset successfully deleted.');
        }
    }
    //function to load csv of datasets
    fx_load_dataset_csv = function() {
        var rids = (grid_ds.getSelectedRowId() === null ? grid_ds.getAllRowIds() : grid_ds.getSelectedRowId());
        var ds_ids = [];
        var src_ids = [];
        $.each(rids.split(','), function(key,val) {
            ds_ids.push(grid_ds.cells(val, grid_ds.getColIndexById('dataset_id')).getValue());
        });

        $.each(rids.split(','), function(key,val) {
            src_ids.push(grid_ds.cells(val, grid_ds.getColIndexById('source_id')).getValue());
        });
        
        win_load_csv = parent.parent.dhx_wins.createWindow({
            id: 'win_load_csv'
            ,width: 1150
            ,height: 500
            ,modal: true
            ,resize: true
            ,text: 'Generate Sample Data'
            ,center: true
            
        });
        var post_params = {
            process_id: report_obj.process_id,
            report_dataset_id: ds_ids.join(','),
            source_ids: src_ids.join(',')
        };
        //console.log(post_params);
        parent.parent.dhx_wins.window('win_load_csv').maximize();
        var win_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.dataset.load.csv.php';
        parent.parent.dhx_wins.window('win_load_csv').attachURL(win_url, null, post_params);    
    };
    //function to popup report paramset detail window
    function fx_edit_paramset(paramset_flag, paramset_id) {
        if(paramset_flag == 'i' || paramset_flag == 'u') {
            var item_id = div_obj.attr('item_id');
            var is_custom_report = report_obj.is_custom_report;
            
			if(item_id == '' && is_custom_report == 0) {
                parent.parent.dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: 'Please insert report item first.'
                });
                return;
            }
            
            parent.parent.dhx_wins.createWindow({
                id: 'window_rp'
                ,width: 1150
                ,height: 500
                ,modal: true
                ,resize: true
                ,text: 'Report Paramset Detail'
                ,center: true
                
            });
            var post_params = {
                report_paramset_id: paramset_id,
                process_id: report_obj.process_id,
                mode: paramset_flag,
                report_id: report_obj.report_id,
                page_id: report_obj.page_id
            };
            //console.log(post_params);
            parent.parent.dhx_wins.window('window_rp').maximize();
            var paramset_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.paramset.template.php';
            parent.parent.dhx_wins.window('window_rp').attachURL(paramset_url, null, post_params);
        } else if(paramset_flag == 'd' || paramset_flag == 'o') {

            layout_paramset.progressOn();
            
            var sp_string = "EXEC spa_rfx_report_paramset_dhx @flag='" + paramset_flag + "', @process_id='" + report_obj.process_id 
                + "', @report_paramset_id='" + paramset_id
                + "'"; 
            post_data = { sp_string: sp_string };
            //console.log(sp_string);
            $.ajax({
                url: js_form_process_url,
                data: post_data
            }).done(function(data) {
                layout_paramset.progressOff();
                //console.log(data['json'][0].name);
                var json_data = data['json'][0];
                if(json_data.errorcode == 'Success') {
                    success_call(json_data.message, 'error');
                    fx_refresh_grid('grid_pm');
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
    //function to init grid paramset
    rm_tab.fx_init_grid_paramset = function(grid_obj) {
        grid_obj.setHeader('paramset_id,Name,create_user,application_user,report_owner,Status');
        grid_obj.setColumnIds('paramset_id,paramset_name,create_user,application_user,report_owner,status');
        grid_obj.setColumnsVisibility('true,false,true,true,true,false');
        grid_obj.setInitWidths('100,300,100,100,100,*');
        grid_obj.setColTypes('ro_int,ro,ro,ro,ro,ro');
        grid_obj.setColSorting('int,str,str,str,str,str');
        grid_obj.init();
        grid_obj.enableHeaderMenu();
        //on grid row DbClick
        grid_obj.attachEvent('onRowDblClicked', function(rid, cid) {
            var paramset_id = grid_obj.cells(rid, grid_obj.getColIndexById('paramset_id')).getValue();
            fx_edit_paramset('u', paramset_id); 
        });
        //on grid row select
        grid_obj.attachEvent('onRowSelect', function(rid, cid) {
            menu_pm.setItemEnabled('delete');
            menu_pm.setItemEnabled('copy');
        });
        fx_refresh_grid('grid_pm');
        
        
          
    };
    //function to popup report paramset detail window
    function fx_edit_dataset(dataset_flag, dataset_id) {
        if(dataset_flag == 'i' || dataset_flag == 'u') {
            
            parent.parent.dhx_wins.createWindow({
                id: 'window_ds'
                ,width: 1150
                ,height: 500
                ,modal: true
                ,resize: true
                ,text: 'Report Dataset Detail'
                ,center: true
                ,maximize: true
            });
            var param_obj_ds ={
                ds_flag: dataset_flag,
                process_id: report_obj.process_id,
                report_id: report_obj.report_id,
                dataset_id: dataset_id
            };
            var post_params = {
                ds_info_obj: JSON.stringify(param_obj_ds),
                call_from: 'rfx_report_dataset'
            };
            
            //console.log(post_params);
            var dataset_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.dataset.php';
            parent.parent.dhx_wins.window('window_ds').attachURL(dataset_url, null, post_params);
            
            parent.parent.dhx_wins.window('window_ds').maximize();
            
            
           
        } else if(dataset_flag == 'd') {
            var sp_string = "EXEC spa_rfx_report_dataset_dhx @flag='d', @process_id='" + report_obj.process_id 
                + "', @report_dataset_id='" + dataset_id
                + "'"; 
            post_data = { sp_string: sp_string };
            //console.log(sp_string);
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                //console.log(data['json'][0].name);
                var json_data = data['json'][0];
                if(json_data.errorcode == 'Success') {
                    success_call('Dataset deleted successfully.', 'error');
                    fx_refresh_grid('grid_ds');
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
    //function to init grid dataset
    rm_tab.fx_init_grid_dataset = function(grid_obj) {
        grid_obj.setHeader('dataset_id,source_id,Name,Alias,type_id,Type');
        grid_obj.setColumnIds('dataset_id,source_id,name,alias,type_id,type');
        grid_obj.setColumnsVisibility('true,true,false,false,true,false');
        grid_obj.setInitWidths('300,300,300,300,300,*');
        grid_obj.setColTypes('ro_int,ro_int,ro,ro,ro_int,ro');
        grid_obj.setColSorting('int,int,str,str,int,str');
        grid_obj.init();
        grid_obj.enableHeaderMenu();
        grid_obj.enableMultiselect(true);
        //on grid row DbClick
        grid_obj.attachEvent('onRowDblClicked', function(rid, cid) {
            var dataset_id = grid_obj.cells(rid, grid_obj.getColIndexById('dataset_id')).getValue();
            fx_edit_dataset('u', dataset_id); 
        });
        //on grid row select
        grid_obj.attachEvent('onRowSelect', function(rid, cid) {
            
            if(grid_obj.getSelectedRowId().indexOf(',') == -1) {
                menu_ds.setItemEnabled('delete');
            } else {
                menu_ds.setItemDisabled('delete');
            }
            
        });
        fx_refresh_grid('grid_ds');
        
        
          
    };
    //function to refresh grid paramset
    window.fx_refresh_grid = function(grid_type) {
        var grid_obj = (grid_type == 'grid_pm' ? grid_pm : grid_ds);
        var param = '';
        var menu_obj;
        if(grid_type == 'grid_pm') {
            param = {
                "flag": "s",
                "action": "spa_rfx_report_paramset_dhx",
                "process_id": report_obj.process_id,
                'page_id': report_obj.page_id
            };
            menu_obj = menu_pm;
            menu_pm.setItemDisabled('copy');
        } else if(grid_type == 'grid_ds') {
            param = {
                "flag": "s",
                "action": "spa_rfx_report_dataset_dhx",
                "process_id": report_obj.process_id
            };
            menu_obj = menu_ds;
        }
        
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        grid_obj.clearAndLoad(param_url, function() {
            menu_obj.setItemDisabled('delete');

        });
    }
    function fx_ds_drag_handler(item, value) {
        if(item.indexOf('report-item') > -1) {
            alert(item);
        }
    }

    function view_report_redirect_with_post(url, template_id,file_name,report_name) {
        view_report_form = document.createElement('form');
        view_report_form.setAttribute('method', 'POST');
        view_report_form.setAttribute('action', url);

        view_report_input = document.createElement('input');
        view_report_input.setAttribute('name', 'template_id');
        view_report_input.setAttribute('type', 'hidden');
        view_report_input.setAttribute('value', template_id);
        view_report_form.appendChild(view_report_input);

        view_report_input = document.createElement('input');
        view_report_input.setAttribute('name', 'file_name');
        view_report_input.setAttribute('type', 'hidden');
        view_report_input.setAttribute('value', file_name);
        view_report_form.appendChild(view_report_input);

        view_report_input = document.createElement('input');
        view_report_input.setAttribute('name', 'report_name');
        view_report_input.setAttribute('type', 'hidden');
        view_report_input.setAttribute('value', report_name);
        view_report_form.appendChild(view_report_input);

        document.body.appendChild(view_report_form);
        view_report_form.submit(); 

    }

    // validate power bi reports
    function process_power_bi_report(process_type) {
        var selected_row_id = grid_pm.getSelectedRowId();
        if(selected_row_id == undefined) {
            parent.parent.dhtmlx.message({
                title: 'Error',
                type: 'alert-error',
                text: 'Please select report paramset first.'
            });
            return false;
        } else {
            var sp_string = "EXEC spa_power_bi_report @flag='c', @paramset_id=" + grid_pm.cells(selected_row_id, grid_pm.getColIndexById('paramset_id')).getValue() + ", @report_name='" + grid_pm.cells(selected_row_id, grid_pm.getColIndexById('paramset_name')).getValue() + "', @source_report='" + process_type + "'";
            
            post_data = { sp_string: sp_string };
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                var json_data = data['json'][0];
                if(json_data.errorcode != 'Success') {                   
                    dhtmlx.message({
                        title: 'Error',
                        type: 'alert-error',
                        text: json_data.message
                    });
                    return false
                } else {
                    var rids = grid_pm.cells(selected_row_id, grid_pm.getColIndexById('paramset_id')).getValue();        
                    var report_name = grid_pm.cells(selected_row_id, grid_pm.getColIndexById('paramset_name')).getValue();
                    
                    if (process_type == 'load_powerbi') {
                        //start load powerbi
                        win_load_powerbi = parent.parent.dhx_wins.createWindow({
                            id: 'win_load_powerbi'
                            ,width: 1150
                            ,height: 500
                            ,modal: true
                            ,resize: true
                            ,text: 'Generate PowerBI Template'
                            ,center: true
                            
                        });
                        var post_params = {
                            active_object_id:rids,
                            report_type:1,
                            report_id:report_obj.report_id,
                            report_name:report_name,
                            report_param_id:rids,
                            call_from:"report_manager_dhx_powerbi"
                        };

                        parent.parent.dhx_wins.window('win_load_powerbi').maximize();
                        var win_url = app_form_path + '_reporting/view_report/report.manager.report.template.php';
                        parent.parent.dhx_wins.window('win_load_powerbi').attachURL(win_url, null, post_params);
                    }   //END load powerbi
                    else if (process_type == 'upload_powerbi') {
                        // start upload power bi
                        var param = 'report.manager.dhx.tab.template.process.php?mode=upload&template_id=' + rids + 
                                    '&file_name=' + report_name +
                                    '&report_name=' + report_name
                                    '&call_from=report_manager&is_pop=true'; 
                        
                        var is_win = dhxWins.isWindow('w1');
                        
                        if (is_win == true) {
                            w1.close();
                        } 
                        
                        w1 = dhxWins.createWindow({
                            id:'w1'
                            ,width: 500
                            ,height: 250
                            ,modal: true
                            ,resize: true
                            ,text: 'Upload PowerBI Report'
                            ,center: false
                            
                        });
                        w1.attachURL(param, false, true);

                    }  // END upload power bi
                    else if (process_type == 'download_powerbi') {
                        // start download power bi
                        var param = 'report.manager.dhx.tab.template.process.upload.php?mode=download&report_name=' + report_name+'&paramset_id=' + rids;
                        view_report_redirect_with_post(param, rids, report_name, report_name);
                        return;
                    }   // END download power bi

                }
            });
        }
    }

    // call back function on power bi template upload
    function custom_report_upload_callback(bool_val) {
        var selected_row_id = grid_pm.getSelectedRowId()
        var report_name = grid_pm.cells(selected_row_id, grid_pm.getColIndexById('paramset_name')).getValue();
        if (bool_val) {           
            parent.parent.dhtmlx.message({
                        title:"Success",
                        type:"alert",
                        text:report_name + ' has been uploaded successfully.'
                    });     
            dhxWins.window('w1').close();
        } else {
            parent.parent.dhtmlx.message({
                        title:"Error",
                        type:"alert-error",
                        text:report_name + ' upload failed.'
                    });
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
	
	fx_generate_custom_rdl = function() {
		var rdl_name = report_obj.report_name + '_' + report_obj.report_name;
        var is_custom_report = report_obj.is_custom_report;
		
		if (is_custom_report == 0) {
			show_messagebox('Please use this option for Custom Report').
			return;
		}
        
        var exec_call = {
                            action: 'spa_download_rdl',
                            report_name: rdl_name
                        }
        adiha_post_data('return_json', exec_call, '', '', 'fx_generate_custom_rdl_callback');
    }
    
    fx_generate_custom_rdl_callback = function(result) {
        json_obj = $.parseJSON(result);
        if(json_obj[0].status == 'Success') {
            var file_path = json_obj[0].rdl_filename;
			window.location = js_php_path + 'force_download.php?path=' + file_path;
        } else {
			show_messagebox('Either the report has not been saved or not uploaded');
        }
    }
    
    /*================== FILTER SAVE LOGIC END ===============*/
</script>