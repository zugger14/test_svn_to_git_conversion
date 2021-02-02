<?php
/**
* Report manager template screen
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
<body>
    <?php
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        
        $rights_report_manager_dhx = 10202500;
        $rights_report_manager_dhx_iu = 10202510;
        $rights_report_manager_dhx_power_bi = 10202512;
    	    
        list (
            $has_rights_report_manager_dhx,
            $has_rights_report_manager_dhx_iu,
            $has_rights_report_manager_dhx_power_bi
        ) = build_security_rights (
            $rights_report_manager_dhx, 
            $rights_report_manager_dhx_iu,
            $rights_report_manager_dhx_power_bi
        );
      
        $form_namespace = 'rm_template';
        $json = '[
                    {
                        id:             "a",
                        text:           "Reports",
                        header:         false,
                        offsetTop:0
                    }
                ]';
        $rm_layout = new AdihaLayout();
        echo $rm_layout->init_layout('rm_layout', '', '1C', $json, $form_namespace);
        

        echo $rm_layout->attach_tab_cell('rm_tabbar', 'a', '');
        echo $rm_layout->close_layout();
    ?>
</body>   
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
<script>
    var has_rights_report_manager_dhx_iu =<?php echo (($has_rights_report_manager_dhx_iu) ? $has_rights_report_manager_dhx_iu : '0'); ?>;
    var has_rights_report_manager_dhx_power_bi =<?php echo (($has_rights_report_manager_dhx_power_bi) ? $has_rights_report_manager_dhx_power_bi : '0'); ?>;

    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    
    $(function() {
        //function to register the component events
        rm_template.rm_tabbar.attachEvent('onTabClose', function(tab_id) {
            //var is_close = false;
            parent.dhtmlx.message({
                type: "confirm",
                title: 'Confirmation',
                ok: "Confirm",
                text: 'There might be unsaved changes. Do you want to close the window without saving?',
                callback: function(result) {
                    
                    //*
                    if (result) {
                        //*
                        var process_id = tab_id.split(':')[1];
                        var sp_string = "EXEC spa_rfx_init_dhx @flag='d', @process_id='" + process_id + "'"; 
                        post_data = { sp_string: sp_string };
                        //console.log(post_data);
                        $.ajax({
                            url: js_form_process_url,
                            data: post_data
                            //,async: false
                        }).done(function(data) {
                            //console.log(data['json'][0].name);
                            var json_data = data['json'][0];
                            console.log(json_data.message);
                            is_close = result;
                            
                        });
                        
                        rm_template.rm_tabbar.tabs(tab_id).close();
                        //return true;
                    } 
                    return result;
                          
                }
             });
             
             //return is_close;
            
        }); 
    });
    var session_id = '<?php echo $session_id; ?>';
    new dhtmlDragAndDropObject();
    
    report_obj = {};
    report_deploy = {};
    form_rd = {};
    ifr_tab = {};
    tab_report = {};
    
    var post_data = '';
    
    //function to load report details
    rm_template.load_rm_detail = function(param_obj) {
        //console.log(param_obj);
        var default_is_system =  0;
        if (param_obj.report_id != 1) {
            default_is_system =  param_obj.is_system;
        }
        report_obj[param_obj.process_id] = param_obj;
        report_deploy[param_obj.process_id] = {};
        
        var full_id = "tab_" + param_obj.report_id + ':' + param_obj.process_id;
        var all_tab_id = rm_template.rm_tabbar.getAllTabs();
        var report_name = param_obj.report_name;

        if (default_is_system == 1)
            report_name += ' [Locked]';


        rm_template.rm_tabbar.addTab(full_id,report_name, null, null, true, true);
        tab_report[param_obj.process_id] = rm_template.rm_tabbar.tabs(full_id);
        //tab_report.progressOn();
        
        
		
        var rm_tab_id = param_obj.report_id;
        //report_type_arr[report_id] = report_type;
        
        rm_template["inner_tab_layout_" + rm_tab_id] = tab_report[param_obj.process_id].attachLayout({
            pattern:"2E",
            cells: [
                {
                    id: "a", 
                    header: true,
                    /*collapse: true,*/
                    text: 'Report Definition',
                    height: 145
                },
                {
                    id: "b", 
                    header:false
                }
            ]
        });
        
        //init form on layout right
        var form_ip_label_width = 120;
        var rdf_form_json = [
            {type: 'settings', offsetLeft: ui_settings['offset_left'] },
            {type: 'input', name: 'ip_report_id', value: param_obj.report_id, hidden: true, position: 'label-top'},{type: 'newcolumn'},
            {type: 'input', name: 'ip_report_owner', value: param_obj.report_owner, hidden: true, position: 'label-top'},{type: 'newcolumn'},
            {type: 'input', name: 'ip_page_width', value: param_obj.page_width, hidden: true, position: 'label-top'},{type: 'newcolumn'},
            {type: 'input', name: 'ip_page_height', value: param_obj.page_height, hidden: true, position: 'label-top'},{type: 'newcolumn'},
            {type: 'input', name: 'ip_name', value: param_obj.report_name, inputWidth: ui_settings['field_size'], required: true, label: 'Report Name', position: 'label-top'},{type: 'newcolumn'},
            {type: 'combo', name: 'cmb_cat', label:'Report Category',width: ui_settings['field_size'], position: 'label-top', labelWidth:'auto' }, {type: 'newcolumn'},
             {type: 'input', name: 'ip_desc', value: param_obj.report_description, label:'Report Description', inputWidth: ui_settings['field_size'], rows: 2, position: 'label-top', position: 'label-top'}, {type: 'newcolumn'},   
            {type: 'checkbox', name:'chk_mobile', label: 'Mobile', checked: param_obj.is_mobile, offsetTop: ui_settings['checkbox_offset_top'],  labelWidth: ui_settings['field_size'], position: 'label-right'},{type: 'newcolumn'},
            {type: 'checkbox', name:'chk_excel', label: 'Excel', checked: param_obj.is_excel, offsetTop: ui_settings['checkbox_offset_top'], labelWidth: ui_settings['field_size'],position: 'label-right'},{type: 'newcolumn'},
            {type: 'checkbox', name:'chk_sys', label: 'System', checked: param_obj.is_system, offsetTop: ui_settings['checkbox_offset_top'], labelWidth: ui_settings['field_size'],position: 'label-right'},
            {type: 'newcolumn'},
            {type: 'checkbox', name:'chk_powerbi', label: 'Power BI', checked: param_obj.is_powerbi, offsetTop: ui_settings['checkbox_offset_top'],  labelWidth: ui_settings['field_size'], position: 'label-right'},{type: 'newcolumn'},
            {type: 'checkbox', name:'chk_is_custom_report', label: 'Custom Report', checked: param_obj.is_custom_report, offsetTop: ui_settings['checkbox_offset_top'],  labelWidth: ui_settings['field_size'], position: 'label-right'},{type: 'newcolumn'}
                     
            
           
        ];
        
        form_rd[param_obj.process_id] = rm_template["inner_tab_layout_" + rm_tab_id].cells('a').attachForm(rdf_form_json);
         rm_template["inner_tab_layout_" + rm_tab_id].cells('a').collapse();
        var cmb_cat = form_rd[param_obj.process_id].getCombo('cmb_cat');
        cmb_cat.enableFilteringMode(true);
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
            cmb_cat.setComboValue(param_obj.report_category_id);
            cmb_cat.sort('asc');
        });
        
        //disable power bi checkbox if privilege is not assigned
        if(has_rights_report_manager_dhx_power_bi == 0)
        {
            form_rd[param_obj.process_id].disableItem('chk_powerbi');
        }

        //attaching menu
        /*
        var menu_json = [
            {id: 'preview', text: 'Preview', img: 'deploy.gif', img_disabled: 'deploy_dis.gif', enabled: true},
            {id: 'save_deploy', text: 'Save/Deploy', img: 'save.gif', img_disabled: 'save_dis.gif', enabled: has_rights_report_manager_dhx_iu}
        ];
        menu_rd = rm_template["inner_tab_layout_" + rm_tab_id].cells('a').attachMenu({
            icons_path: js_image_path + 'dhxtoolbar_web/',
            items: menu_json
        });
        */
        
        
        //attaching toolbar
        
        var menu_json = [
            {id: 'save_deploy', type: "button", text: 'Save/Deploy', img: 'save.gif', img_disabled: 'save_dis.gif', enabled: has_rights_report_manager_dhx_iu},
            {id: 'preview', type: "button", text: 'Preview', img: 'view_all.gif', img_disabled: 'view_all_dis.gif', enabled: true, hidden: true}
        ];
        menu_rd = rm_template["inner_tab_layout_" + rm_tab_id].attachToolbar({
            icons_path: js_image_path + 'dhxtoolbar_web/',
            items: menu_json
        });
        
        menu_rd.attachEvent('onClick', function(id) {
            var current_form_rd = form_rd[param_obj.process_id];
            if(id == 'preview') {
                var report_category_id = (current_form_rd.getItemValue('cmb_cat') == '' ? 'NULL' : current_form_rd.getItemValue('cmb_cat'));
                var param_obj_report = {
                    report_flag: 'u',
                    process_id: param_obj.process_id,
                    report_id: param_obj.report_id,
                    report_name: current_form_rd.getItemValue('ip_name'),
                    report_owner: param_obj.report_owner,
                    pege_id: param_obj.page_id,
                    report_category_id: report_category_id,
                    is_system: current_form_rd.getItemValue('chk_sys'),
                    is_mobile: current_form_rd.getItemValue('chk_mobile'),
                    is_excel: current_form_rd.getItemValue('chk_excel'),
                    is_powerbi: current_form_rd.getItemValue('chk_powerbi'),
					is_custom_report: current_form_rd.getItemValue('chk_is_custom_report'),
                    report_description: current_form_rd.getItemValue('ip_desc'),
                    save_type: 'save_process'
                    
                };
                //rm_template.rm_tabbar.cells(full_id).progressOn();
                parent.rm.layout.cells('b').progressOn();
                fx_save_report_process(param_obj_report);
                
            } else if(id == 'save_deploy') {

                //rm_template.rm_tabbar.cells(full_id).progressOn();
                var report_category_id = (current_form_rd.getItemValue('cmb_cat') == '' ? 'NULL' : current_form_rd.getItemValue('cmb_cat'));
                //getItemValue escapes html characters hence used dom parse and get original content for special character validation for windows file name
                if(!fx_is_valid_windows_filename((new DOMParser()).parseFromString(current_form_rd.getItemValue('ip_name'), "text/html").documentElement.textContent)) {
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: "Invalid characters/string on report name.",
                    });
                    return;
                }
                var param_obj_report = {
                    report_flag: 'u',
                    process_id: param_obj.process_id,
                    report_id: param_obj.report_id,
                    report_name: current_form_rd.getItemValue('ip_name'),
                    report_owner: param_obj.report_owner,
                    pege_id: param_obj.page_id,
                    report_category_id: report_category_id,
                    is_system: current_form_rd.getItemValue('chk_sys'),
                    is_mobile: current_form_rd.getItemValue('chk_mobile'),
                    is_excel: current_form_rd.getItemValue('chk_excel'),
                    is_powerbi: current_form_rd.getItemValue('chk_powerbi'),
                    is_custom_report: current_form_rd.getItemValue('chk_is_custom_report'),
                    report_description: current_form_rd.getItemValue('ip_desc'),
                    save_type: 'save_final'
                    
                };
                if (default_is_system != 1 && current_form_rd.getItemValue('chk_sys') == 1) {
                    var param_obj1 = {
                        "param1"  :  JSON.stringify(param_obj_report)
                    };
                    is_user_authorized('rm_template.user_authorized',param_obj1);
                } else {
                    parent.rm.layout.cells('b').progressOn();
                    fx_save_report_process(param_obj_report);
                }
                //fx_pre_deploy_report(param_obj.process_id);
            }
        });
                
        var url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.tab.template.php?session_id=' + js_session_id;
        
        // console.log('**dhx.template.php**');
        //console.dir(param_obj);
        rm_template["inner_tab_layout_" + rm_tab_id].cells('b').attachURL(url, null, 
            {
                report_obj: JSON.stringify(param_obj)
            }
        );
        
        ifr_tab[param_obj.process_id] = rm_template["inner_tab_layout_" + rm_tab_id].cells('b').getFrame().contentWindow;
        //console.log(ifr_tab);
        
    };

    rm_template.user_authorized = function(param_obj_report){
        parent.rm.layout.cells('b').progressOn();
        param_obj_report = JSON.parse(param_obj_report);
        fx_save_report_process(param_obj_report);
    }
    
    //function to save report process
    fx_save_report_process = function(param_obj_report) {
        save_type_gbl = param_obj_report.save_type;
        var exec_call = {
            'action': 'spa_rfx_report_dhx',
            'flag': param_obj_report.report_flag,
            'process_id': param_obj_report.process_id,
            'report_id': param_obj_report.report_id,
            'report_name': param_obj_report.report_name,
            'report_owner': param_obj_report.report_owner,
            'category_id': param_obj_report.report_category_id,
            'system_report': param_obj_report.is_system,
            'is_mobile': param_obj_report.is_mobile,
            'is_excel': param_obj_report.is_excel,
            'is_powerbi': param_obj_report.is_powerbi,
			'is_custom_report': param_obj_report.is_custom_report,
            'system_report': param_obj_report.is_system,
            'report_desc': param_obj_report.report_description,
        }
        //console.dir(exec_call);
        //return;
        adiha_post_data('return_json', exec_call, '', '', 'fx_save_report_process_cb');
    };
    fx_save_report_process_cb = function(result) {
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Report Definition saved successfully.', 'success');
            
            //console.dir(report_obj);
            var recommendation = json_obj[0].recommendation.split(',');
            var process_id = recommendation[1];
            var report_id = recommendation[0];
            var report_flag = recommendation[2];
            var current_form_rd = form_rd[process_id];
            report_obj[process_id] = {
                process_id: process_id,
                report_id: report_id,
                report_name: current_form_rd.getItemValue('ip_name'),
                report_category_id: current_form_rd.getItemValue('cmb_cat'),
                is_system: current_form_rd.getItemValue('chk_sys'),
				is_custom_report: current_form_rd.getItemValue('chk_is_custom_report'),
                page_id: report_obj[process_id].page_id,
                page_width: current_form_rd.getItemValue('ip_page_width'),
                page_height: current_form_rd.getItemValue('ip_page_height')
            };
            //console.log(report_obj);
            
            var param_obj_page = {
                page_flag: report_flag,
                report_obj: report_obj[process_id]
            };
            //console.log(param_obj_page);
            fx_save_page_info(param_obj_page);
            
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
            //console.log(ifr_tab);
            //console.log(param_obj_page);
            xml_ri = ifr_tab[param_obj_page.report_obj.process_id].ifr_page.save_layout();
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
            console.log('***page info saved ***');
            var recommendation = json_obj[0].recommendation.split(',');
            var process_id = recommendation[2];
            var paramset_id = recommendation[1];
            var page_id = recommendation[0];
            var page_flag = recommendation[3];
            
            if(page_flag == 'i') {
                report_obj[process_id].page_id = page_id;
            
                //var ifr_obj = rm.layout.cells('b').getFrame(); 
                //ifr_obj.contentWindow.rm_template.load_rm_detail(report_obj[process_id]);
                rm_template.load_rm_detail(report_obj[process_id]);
            } else if(page_flag == 'u') {
                //deploy rdl from process tables.
                if(save_type_gbl == 'save_final') {
                    fx_pre_deploy_report(process_id);
                } else {
                    fx_deploy_report(report_obj[process_id].report_id, process_id, 'deploy_preview');
                }
            }
            
        } else {
            alert('##error on saving page info##');
            //console.log('##error on saving page info##');
        }
    }
    //function to save report on physical tables
    fx_pre_deploy_report = function(process_id) {
        var item_id = ifr_tab[process_id].div_obj.attr('item_id');
        var is_custom_report = report_obj[process_id].is_custom_report;
		
		var exec_call = {
			action: 'spa_rfx_save_dhx',
			process_id: process_id  
		};
		
		if (is_custom_report == 1) {
			adiha_post_data('return_json', exec_call, '', '', 'fx_pre_deploy_custom_report');
		} else {
			if(item_id == '') {
				parent.parent.dhtmlx.message({
					title: 'Error',
					type: 'alert-warning',
					text: 'Please insert report item first.'
				});
				parent.rm.layout.cells('b').progressOff();
				return;
			} else {
				var exec_call = {
					action: 'spa_rfx_save_dhx',
					process_id: process_id  
				};
				adiha_post_data('return_json', exec_call, '', '', 'fx_pre_deploy_report_cb');
			}
		}        
    };
	
	// Function to close progress when custom report is saved.
	fx_pre_deploy_custom_report = function(result) {
		json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
			var recommendation = json_obj[0].recommendation.split(',');
            var process_id = recommendation[1];
            var physical_report_id = recommendation[0];
            var rdl_name = report_obj[process_id].report_name + '_' + report_obj[process_id].report_name;
            
            var exec_call = {
                action: 'spa_rfx_report_dhx',
                report_name: rdl_name,
				flag: 'r',
				process_id: ''
            };
            
            $.ajax({
                url: js_form_process_url,
                data: exec_call
            }).done(function(data) {
                //console.log(data['json'][0].name);
                var json_data = data['json'][0];
                if(json_data.status == 0) {
                     fx_deploy_report(physical_report_id, process_id, 'deploy_custom_report');
                } else {
					fx_deploy_report_error(physical_report_id, process_id, 'deploy_custom_report');
				}
            });
        }
    }
    
	
    fx_pre_deploy_report_cb = function(result) {
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            var recommendation = json_obj[0].recommendation.split(',');
            var physical_report_id = recommendation[0];
            var process_id = recommendation[1];
            fx_deploy_report(physical_report_id, process_id, 'deploy_final');
        } else {
            alert('error on fx_pre_deploy_report_cb(report.manager.dhx.template.php)');
        }
    };
	
	 fx_deploy_report_error = function(report_id, process_id, call_from) {
		success_call('Custom Report already Exists.', 'error');
    	tab_report[process_id].close();
		parent.rm.layout.cells('a').expand();
		parent.rm.fx_refresh_tree('r');
		parent.rm.layout.cells('b').progressOff();		 
	 }	
	
    //function to deploy the report
    fx_deploy_report = function(report_id, process_id, call_from) {
        report_deploy[process_id].report_id = report_id;
        deploy_window = parent.dhx_wins.createWindow({
            id: 'window_deploy'
            ,width: 615
            ,height: 190
            ,modal: false
            ,resize: false
            ,text: 'Report Deployment'
            ,center: true
        });
        
		if (call_from == 'deploy_custom_report') {
			call_from1 = 'deploy_final';
			is_custom_report = 1;
		} else {
			call_from1 = call_from;
			is_custom_report = 0;
		}
		
        var post_params = {
            report_id: report_id,
            process_id: process_id,
            call_from: call_from1,
			is_custom_report:is_custom_report
        };
        deploy_window.hide();
        //console.log(post_params);
        var rdl_maker_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.rdl.maker.php';
        deploy_window.attachEvent('onContentLoaded', function(id) {
            var full_id = "tab_" + report_id + ':' + process_id;
            
            if(call_from == 'deploy_final') {
                success_call('Report saved and deployed.', 'error');
                //call to delete the process tables
                
                var sp_string = "EXEC spa_rfx_init_dhx @flag='d', @process_id='" + process_id + "'"; 
                post_data = { sp_string: sp_string };
                $.ajax({
                    url: js_form_process_url,
                    data: post_data,
                }).done(function(data) {
                    //console.log(data['json'][0].name);
                    var json_data = data['json'][0];
                    console.log(json_data.message);
                    
                });
                tab_report[process_id].close();
                parent.rm.layout.cells('a').expand();
                parent.rm.fx_refresh_tree('r');
                //rm_template.rm_tabbar.cells(full_id).progressOff();
                parent.rm.layout.cells('b').progressOff();
            } else if (call_from == 'deploy_preview') {
                ifr_tab[process_id].ifr_preview.fx_preview_refresh(); 
            } else if (call_from = 'deploy_custom_report') {
				tab_report[process_id].close();
                parent.rm.layout.cells('a').expand();
                parent.rm.fx_refresh_tree('r');
                parent.rm.layout.cells('b').progressOff();
			}
        });
        deploy_window.attachURL(rdl_maker_url, true, post_params);
    };
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
    
</script>