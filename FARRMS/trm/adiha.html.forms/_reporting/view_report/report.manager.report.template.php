<?php
/**
* Report manager report template screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html>  
    <?php 
    //print '<pre>';print_r($_REQUEST);print '</pre>';
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        
        //for hedging position report
        $call_from = get_sanitized_value($_POST['call_from'] ?? '');
        $link_id = get_sanitized_value($_POST['link_id'] ?? '');
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
        $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');
        $report_param_id = get_sanitized_value($_POST['report_param_id'] ?? 'NULL');
        $view_id = get_sanitized_value($_POST['view_id'] ?? 'NULL');
        $report_unique_identifier = get_sanitized_value($_POST['report_unique_identifier'] ?? '');
        $link_id_from = get_sanitized_value($_POST['link_id_from'] ?? '');
        $link_id_to = get_sanitized_value($_POST['link_id_to'] ?? '');
        $effective_date_from = get_sanitized_value($_POST['effective_date_from'] ?? '');
        $effective_date_to = get_sanitized_value($_POST['effective_date_to'] ?? '');

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Report Template",
                                header:         false,
                                collapse:       false,
                                fix_size:       [true,true]
                            },

                        ]';

        $layout_name = 'report_template_layout';
        $name_space = 'report_template';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);

        if ($call_from == 'report_manager_dhx_powerbi') {
            $toolbar_json = '[
                                    {id:"generate", text:"Generate", img:"gen_sample_data.gif", imgdis:"gen_sample_data_dis.gif", title: "Generate",disabled: false}
                             ]';

            $toolbar_obj = new AdihaMenu();
            echo $layout_obj->attach_menu_cell("generate_toolbar", "a"); 
            echo $toolbar_obj->init_by_attach("generate_toolbar", $name_space);
            echo $toolbar_obj->load_menu($toolbar_json);
            echo $toolbar_obj->attach_event('', 'onClick', $name_space . '.generate_toolbar_click');
        }

        echo $layout_obj->close_layout();
        
        /** datasource view privilege logic **/
        $xml_file = "EXEC spa_rfx_report_record_dhx @flag=a, @report_paramset_id='" . $report_param_id . "'";
        $paramsets = readXMLURL2($xml_file);
        //data_source_type
        $datasource_id = $paramsets[0]['source_id'] ?? 0;
        
        
        /** taking datasource UI form application ID and sending it making -ve to spa_getportfoliohierarchy, so that when
         * report is to be run from report manager that has the data source as sql, all portfolio structure is now displayed.
         * Previously no portfolio was displayed while trying to run report that has sql datasource from report manager with non-admin users,
         * Because the we only had a feature to give privilege to views but no sql data sources.
         * 
         * **/
        $data_source_sql_function_id = -10201625;
        $is_data_source_sql = (($paramsets[0]['data_source_type'] ?? '') == 2) ? 1 : 0; //DATA SOURCE TYPE SQL => 2
        

        //if (empty($report_table_id))
//            $function_or_view_id = $sf_report_writer;
//        else
        /* for SQL based reports, view id is not available, use function id of 'Report Writer' application function.
         * Same parameter @function_id is used to pass both Application Function ID
         * or Report Writer View ID. So to differentiate between the two, a base no.
         * of 100000000 is added in every Report Writer View ID
         */
            $function_or_view_id = $datasource_id + 100000000;
            
        /** Pass negative value (f10 datasource UI function ID) so that the handling on spa_getportfolioheierarchy
         * for this will allow to display all portfolio structure. While running report with sql data source from report manager
         * , with non-admin users, portfolio structure should be full displayed.
         * 
         */
         
        if ($is_data_source_sql == 1) {
            $function_or_view_id =  $data_source_sql_function_id;//<FUNCTION ID OF F10 Funtion SQL data source>    
        }
    ?> 
    
    <script>
        var post_data = '';
        var secondary_filters_process_id_gbl = '';

        var active_object_id = '<?php echo $active_object_id; ?>';
        var report_type = '<?php echo $report_type; ?>';
        var report_name = '<?php echo $report_name; ?>';
        var report_param_id = '<?php echo $report_param_id; ?>';
        var call_from = '<?php echo $call_from;?>';
        var view_id = '<?php echo $view_id;?>';
        var report_unique_identifier = '<?php echo $report_unique_identifier; ?>';
        //RM and Power BI use same paramset hash.
        var key_prefix = (report_type == 1 || report_type == 5) ? 'RptRM' : (report_type == 4) ? 'RptExcel' : '';
        
        /*
        Report Type 1 = Report Manager Reports, 2 = Standard Reports, 3 = Dashboard Reports, 4 = Excel Reports
        RptRM is the identifier for Report Manager reports. It is used as keyprefix while generating unique cache key.
        */
        report_ui = {};
        
        $(function(){
            data = {"action": "spa_view_report",
                        "flag": "c",
                        "report_name" : '',
                        "report_param_id": report_param_id,
						"call_from":(report_type == 4 ? 'report_manager_dhx_excel' : call_from),
						"view_id":view_id,
                        "key_prefix": (report_unique_identifier != '') ? key_prefix + '_' + report_unique_identifier : '',   
                        "key_suffix": '',
                        "append_user_name": 1
                     };

            adiha_post_data('return_array', data, '', '', 'load_report_detail', '');
        });
        
        function load_report_detail(result) {
            //var active_tab_id = report_ui.tabbar.getActiveTab();
            //var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            

            var result_length = result.length;
            var tab_json = '';
            for (i = 0; i < result_length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);
            }
            
            tab_json = '{tabs: [' + tab_json + ']}';

            report_ui["report_tabs_" + active_object_id] = report_template.report_template_layout.cells("a").attachTabbar();

            if (call_from == 'report_manager_dhx_powerbi') {
                report_ui["report_tabs_" + active_object_id].setTabsMode("bottom");
            }

            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];

                report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
                
                if (result[j][2]) {
                    report_ui["form_" + j].loadStruct(result[j][2], function() {
                        var form_obj = report_ui["form_" + j];
                        form_obj.forEachItem(function(name) {
                            var item_type = form_obj.getItemType(name);
                            if (item_type == 'dyn_calendar') {
                                var dyn_cal_obj = form_obj.getCalendar(name);
                                var dyn_cal_form_obj = dyn_cal_obj.form;
                                if (report_type != 4) { //if not excel report
                                    dyn_cal_form_obj.getCombo('dynamic_value').deleteOption('45610');
                                }
                            }
                        });
                    });
                    var form_name = 'report_ui["form_" + ' + j + ']';
                    attach_browse_event(form_name, '<?php echo $function_or_view_id; ?>');
                }


                //Deal Match Report
                if (call_from == 'rec_match_report') {
                    var link_id_from = '<?php echo $link_id_from;?>';
                    var link_id_to = '<?php echo $link_id_to;?>';
                    var effective_date_from = '<?php echo $effective_date_from;?>';
                    var effective_date_to = '<?php echo $effective_date_to;?>';
                 
                    report_ui["form_" + j].setItemValue('link_id_from', link_id_from);
                    report_ui["form_" + j].setItemValue('link_id_to', link_id_to);
                    report_ui["form_" + j].setItemValue('effective_date_from', effective_date_from);
                    report_ui["form_" + j].setItemValue('effective_date_to', effective_date_to);
                }
                
                //Hedge Position Report
                if (call_from == 'view_from_grid') {
                    var link_id = '<?php echo $link_id;?>';                    
                    report_ui["form_" + j].setItemValue('LinkId', link_id);
                }

                //store secondary filters process id, it is used to build report filter string appending secondary filters (duplicate removed filters)
                secondary_filters_process_id_gbl = result[j][3];
				// Added logic to get combo object and get checked values..
                report_ui["form_" + j].forEachItem(function(name) {
                    var item_type = report_ui["form_" + j].getItemType(name);
                    if (item_type == 'combo') {
                        var dropdown_obj = report_ui["form_" + j].getCombo(name);
                        if (dropdown_obj.conf.opts_type == 'custom_checkbox') {
                            var checked_ids = dropdown_obj.getChecked();
                            $.each(checked_ids, function(id, value) {
                                var ids = dropdown_obj.getIndexByValue(value);
                                dropdown_obj.setChecked(ids, true);
                            });
                        } else {
                            var selected_ids = dropdown_obj.getSelectedValue();
                            dropdown_obj.setComboValue(selected_ids);
                        }
                    }
                });
            }
            
            var att_obj = report_template.report_template_layout.cells('a');

            if (parent.show_pivot_button) { 
				if(report_type != 4) {
                	parent.show_pivot_button(att_obj);
				}
            }
            if (parent.set_apply_filter) parent.set_apply_filter(att_obj);  
            
            if (call_from == 'view_from_grid') 
                if (parent.set_apply_filter) parent.call_back_report_refresh();   

            if (call_from == 'rec_match_report') 
                parent.call_back_report_refresh();           
        }
        
        /**
         Return custom as_of_date 
        **/
        function return_as_of_date() {
            var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();
            var custom_as_of_date = '';
            inner_tab_obj.forEachTab(function(tab){
                form_obj = tab.getAttachedObject();

                if (form_obj.isItem('as_of_date')) {
                    custom_as_of_date = form_obj.getItemValue('as_of_date', true);
                 } else if (form_obj.isItem('as_of_date_to')) {
                    custom_as_of_date = form_obj.getItemValue('as_of_date_to', true);
                 } else if (form_obj.isItem('to_as_of_date')) {
                    custom_as_of_date = form_obj.getItemValue('to_as_of_date', true);
                 } else if (form_obj.isItem('as_of_date') && form_obj.isItem('as_of_date_to')) {
                    custom_as_of_date = form_obj.getItemValue('as_of_date_to', true);
                 } else if (form_obj.isItem('as_of_date') && form_obj.isItem('to_as_of_date')) {
                    custom_as_of_date = form_obj.getItemValue('to_as_of_date', true);
                 } else if (form_obj.isItem('pnl_as_of_date')) {
                    custom_as_of_date = form_obj.getItemValue('pnl_as_of_date', true);
                 } else {
                    custom_as_of_date= '';
                 }  

            });

            return custom_as_of_date;
        }
        
        function report_parameter(batch_flag, return_type) {
            var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();
            
            inner_tab_obj.forEachTab(function(tab){
               form_obj = tab.getAttachedObject();
            });
            
            var report_filter_list = new Array();
            var report_name = '';
            var items_combined = '';
            var paramset_id = '';
            var paramset_hash = '';
            var report_path = '';
			var c_as_of_date = '';
            
            var status = validate_form(form_obj);
            if (status == false) {
                return false;
            }
            
            form_obj.forEachItem(function(name){
                var item_type = form_obj.getItemType(name);
                if (name == 'report_name') {
                    value = form_obj.getItemValue(name);
                    report_name = value;
                } else if (name == 'items_combined') {
                    value = form_obj.getItemValue(name);
                    items_combined = value;
                } else if (name == 'report_paramset_id') {
                    value = form_obj.getItemValue(name);
                    paramset_id = value;
                }  else if (name == 'paramset_hash') {
                    value = form_obj.getItemValue(name);
                    paramset_hash = value;
                } else if (name == 'report_path') {
                    value = form_obj.getItemValue(name);
                    report_path = value;
                } else if (item_type != 'fieldset' && item_type != 'block' && item_type != 'button' && name!= 'book_structure') {
                   if (item_type == 'calendar') {
                        var date_obj = form_obj.getCalendar(name);
                        var value = date_obj.getFormatedDate("%Y-%m-%d");
						if(batch_flag && call_from != 'report_manager_dhx_powerbi') {
                            //else if used for priority ordering of dates
							if(name == 'as_of_date') {
                                if(c_as_of_date == '') {
                                    c_as_of_date = value;
                                    value = '$AS_OF_DATE$';
                                }
                                } else if(name == 'pnl_as_of_date') {
                                    if(c_as_of_date == '') {
                                        c_as_of_date = value;
                                        value = '$AS_OF_DATE$';
                                    }
                                } else if(name == 'to_as_of_date') {
    								if(c_as_of_date == '') {
                                        c_as_of_date = value;
                                        value = '$AS_OF_DATE$';
                                    }
                                } else if(name == 'from_as_of_date') {
								    if(c_as_of_date == '') {
                                        c_as_of_date = value;
                                        value = '$AS_OF_DATE$';
                                    }
                                }
                            }
					// Added logic to replace comma with ! to pass for report querying...
                    } else if (item_type == 'combo') {
                        var combo_obj = form_obj.getCombo(name);
                        if (combo_obj.conf.opts_type == 'custom_checkbox') {
                            value = combo_obj.getChecked();
                            if (typeof(value) == 'object') {
                                value = (value.toString()).replace(/,/g, "!");
                            } else {
                                value = value.replace(/,/g, "!");
                            }
                        } else {
                            value = combo_obj.getSelectedValue();
                        }
                    }  else {
                        value = form_obj.getItemValue(name);

                        if (typeof(value) == 'object') {
                            value = (value.toString()).replace(/,/g, "!");
                        } else {
                            value = value.replace(/,/g, "!");
                        }
                    }
                    
                    if (name == 'subsidiary_id') { name = 'sub_id'; }
                    if (name == 'strategy_id') { name = 'stra_id'; }
                    if (name == 'subbook_id') { name = 'sub_book_id'; }
                    
                    if (name.indexOf('label_') == -1) {
                        if (value == '') { 
                            report_filter_list.push(name + '=NULL');
                        } else {
                            //if ((name == 'sub_id') || (name == 'stra_id') || (name == 'sub_book_id') || (name == 'book_id')) { value = "'" + value + "'";}
                            report_filter_list.push(name + '=' + value);
                        }
                    }
                }
            });

            
            // var report_filter_final = report_filter_list.join(',');
            // var sp_string = "EXEC spa_rfx_report_paramset_dhx @flag='q'"
            //     + ", @xml='" + report_filter_list.join(',') + "'"
            //     + ", @process_id='" + secondary_filters_process_id_gbl + "'"
                
            //     + ""; 
            // post_data = { sp_string: sp_string };
            
            // $.ajax({
            //     url: ajax_url,
            //     data: post_data,
            //     async: false
            // }).done(function(data) {
                
            //     var json_data = data['json'][0];
            //     report_filter_final = json_data.report_filter;
                

            // });
            
            if (batch_flag == true) {
                var param_array = new Array();
                param_array.push(report_filter_list);
                param_array.push(items_combined);
                param_array.push(paramset_id);
                param_array.push(paramset_hash);
                param_array.push(report_path);
                param_array.push(secondary_filters_process_id_gbl);
				param_array.push(c_as_of_date);
				param_array.push(c_as_of_date != '');
                
                return param_array;
            } else {
                if (return_type == 1) {
                    var item_id = items_combined.split(':');
                    var report_name = '<?php echo $report_name; ?>';
                    var return_obj = {
                        paramset_id:paramset_id,
                        report_filter:report_filter_list,
                        items_combined:item_id[1],
                        report_name:report_name,
                        paramset_hash:paramset_hash
                    }

                    return return_obj;
                } else {
                    report_name = '?report_name=' + report_name; 
                    report_filter = '&report_filter=' + report_filter_list;
                    is_refresh = '&is_refresh=1';
                    items_combined = '&items_combined=' + items_combined; 
                    paramset_id = '&paramset_id=' + paramset_id;

                    var parameters = [];

                    parameters[0] = report_name + report_filter + is_refresh + items_combined + paramset_id;
                    parameters[1] = report_filter_list + '_-_' + secondary_filters_process_id_gbl;
                    
                    return parameters;
            }
                
            }
        }
        
        // Geneerate power bi button click function
        report_template.generate_toolbar_click = function(id) {
            if (id == "generate") {
                var parameters = report_parameter(true, 2);
                if (parameters != false) {
                    var timestamp = Date.now().toString();
                    var paramset_id = parameters[2];
                    var process_id = parameters[3];
                    var tablix_id = parameters[1].split(':')[1];
                    var report_filter = parameters[0].join(',');
                    var farrms_client_dir = '<?php echo $farrms_client_dir;?>';


                    var sp_string = "EXEC spa_run_sp_as_job @run_job_name='RFX Generate Sample PowerBI (" + process_id + "^" + timestamp + ")'" +
                            ", @spa='spa_power_bi_report @flag=''b''" + 
                                    ", @paramset_id=''" + paramset_id + "''" + 
                                    ", @param_tablix_id=''" + tablix_id + "''" + 
                                    ", @batch_process_id=''" + process_id + "''" + 
                                    ", @runtime_user=''" + js_user_name + "''" + 
                                    ", @report_name=''" + report_name + "''" + 
                                    ", @report_filter=''" + report_filter + "''" + 
                                    ", @sec_filter_process_id=''" + parameters[5] + "''" + 
                                    ", @client_folder=''" + farrms_client_dir + "'''" +
                            ", @proc_desc='Generate Sample PowerBI.'" +
                            ", @user_login_id='" + js_user_name + "'" +
                            ", @job_subsystem='TSQL'"

                    //console.group(sp_string);return;
                    post_data = { sp_string: sp_string };
                    
                    $.ajax({
                        url: js_form_process_url,
                        data: post_data,
                    }).done(function(data) {
                        parent.success_call('Job for Generate sample PowerBI started.');
                        parent.dhx_wins.window('win_load_powerbi').close();
                    });
                }
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