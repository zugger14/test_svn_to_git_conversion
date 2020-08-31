<?php
/**
* Regression filter screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <body>
        <?php
            $namespace = 'regression_filter';

            $layout_obj = new AdihaLayout();
            $layout_json = '[{id: "a", text: "Report Filter"}]';
            echo $layout_obj->init_layout('regression_filter_layout', '', '1C', $layout_json, $namespace);

            // Sanitization
            $filter_parameters = get_sanitized_value($_POST['filter_parameters'] ?? '');
            $regg_module_header_id = get_sanitized_value($_POST['regg_module_header_id'] ?? '');
            $report_param_id = get_sanitized_value($_POST['report_param_id'] ?? '');

            $ui_sql = "EXEC spa_regression_testing 
                @flag='h', 
                @regression_module_header_id=" . $regg_module_header_id . ",
                @report_param_id='" . $report_param_id . "',
                @load_default_filter=" . ($filter_parameters == '' || strtoupper($filter_parameters) == 'NULL' ? '1' : '0' ) . ",
                @is_combined_tab='y'
            ";
            $ui_data = readXMLURL2($ui_sql);

            /** datasource view privilege logic **/
            $xml_file = "EXEC spa_rfx_report_record_dhx @flag=a, @report_paramset_id='" . $report_param_id . "'";
            $paramsets = readXMLURL2($xml_file);
            //data_source_type
            $datasource_id = $paramsets[0]['source_id'];
            
            /** taking datasource UI form application ID and sending it making -ve to spa_getportfoliohierarchy, so that when
            * report is to be run from report manager that has the data source as sql, all portfolio structure is now displayed.
            * Previously no portfolio was displayed while trying to run report that has sql datasource from report manager with non-admin users,
            * Because the we only had a feature to give privilege to views but no sql data sources.
            * 
            * **/
            $data_source_sql_function_id = -10201625;
            $is_data_source_sql = ($paramsets[0]['data_source_type'] == 2) ? 1 : 0; //DATA SOURCE TYPE SQL => 2
            
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
            echo $layout_obj->close_layout();
        ?>
        
        <script>
            var process_id = '';
            var tab_json = <?php echo json_encode($ui_data)?>;
            var function_id = '<?php echo $function_or_view_id; ?>';
            var filter_parameters = '<?php echo $filter_parameters ?>';
            var loaded_tabs = [];
            var regg_module_header_id = '<?php echo $regg_module_header_id ?>';
            var report_param_id = '<?php echo $report_param_id; ?>';
            var filter_parameters = '<?php echo $filter_parameters; ?>';

            $(function() {
                // Render Tabs at the Bottom First.
                regression_filter.tabbar = regression_filter.regression_filter_layout.cells('a').attachTabbar({
                    mode: "bottom",
                    tabs: tab_json.map(function(e){ return JSON.parse(e.tab_json)})
                });

                process_id = tab_json[0]['process_id']

                regression_filter.tabbar.attachEvent("onTabClick", function(id, last_id) {
                    // Only if the content of tab is not loaded with forms.
                    if (loaded_tabs.indexOf(id) == -1) {
                        var active_tab_form_json = regression_filter.get_form_json(id);
                    }
                });

                regression_filter.tabbar._setTabActive('combined_filter');
                var active_tab = regression_filter.tabbar.getActiveTab();

                var combined_tab_form_json = tab_json.filter(function(e) {
                    return 'combined_filter' == e.tab_id;
                });

                // If the JSON exists...
                if (combined_tab_form_json.length > 0) {
                    var form_json = combined_tab_form_json[0]['form_json'];

                    regression_filter.load_form(active_tab, form_json);
                }

                regression_filter.tool_bar = regression_filter.regression_filter_layout.cells('a').attachToolbar();
                regression_filter.tool_bar.setIconsPath(js_image_path + "dhxtoolbar_web/");
                regression_filter.tool_bar.loadStruct([{id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save", enabled: true}]);
                regression_filter.tool_bar.attachEvent('onClick', function(id) {
                    switch(id) {
                        case "save":
                            regression_filter.tabbar.forEachTab(function(tab) {
                                if(tab.getText() == 'Combined Filter') {
                                    var parameters = regression_filter.get_report_parameter();

                                    if(!parameters)
                                        return;

                                    parameters = parameters.join(',')
                                    data = {
                                        "action": "spa_rfx_report_paramset_dhx",
                                        "flag": 'q',
                                        "xml": parameters,
                                        "process_id": process_id
                                    }
                                    adiha_post_data('return_array', data, '', '', 'regression_filter.after_save', '');
                                }
                            })
                        break;
                    }
                });
            });

            //copyed from report.manager.report.template.php function name report_parameter
            regression_filter.get_report_parameter = function() {
                var form_obj = regression_filter["form_combined_filter"];
                
                var report_filter_list = new Array();
                var status = validate_form(form_obj);
                if (status == false) {
                    generate_error_message();
                    return false;
                }
                
                form_obj.forEachItem(function(name) {
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
                    } else if (item_type != 'fieldset' && item_type != 'block' && item_type != 'button') {
                        if (item_type == 'calendar') {
                            var date_obj = form_obj.getCalendar(name);
                            var value = date_obj.getFormatedDate("%Y-%m-%d");
                        
                        // Added logic to replace comma with ! to pass for report querying...
                        } else if (item_type == 'combo') {
                            var combo_obj = form_obj.getCombo(name);
                            if(combo_obj.conf.opts_type == 'custom_checkbox') {
                                value = combo_obj.getChecked();
                                if (typeof(value) == 'object') {
                                    value = (value.toString()).replace(/,/g, "!");
                                } else {
                                    value = value.replace(/,/g, "!");
                                } 
                            } else {
                                value = combo_obj.getSelectedValue();
                            }
                            
                        } else if(item_type == 'dyn_calendar') {
                            //value = form_obj.getItemValue(name,true); //call this way to get object
                            value = form_obj.getItemValue(name).join('|');
                            
                            // if(value[0] != '') {
                            //     value = value[0];
                            // } else {
                            //     value = value[1].toString() + '|' + value[2].toString();
                            // }
                        } else {
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
                        
                        //if (name.indexOf('label_') == -1) {
                            if (value == '') { 
                                report_filter_list.push(name + '=NULL');
                            } else {
                                //if ((name == 'sub_id') || (name == 'stra_id') || (name == 'sub_book_id') || (name == 'book_id')) { value = "'" + value + "'";}
                                report_filter_list.push(name + '=' + value);
                            }
                        }
                    //}
                });
                
                var param_array = new Array();
                param_array.push(report_filter_list);
                return param_array;
            }

            regression_filter.after_save = function (result) {
                var tab_id = parent.setup_regression_testing.tabbar.getActiveTab();
                var inner_tab = parent.setup_regression_testing.tabbar.tabs(tab_id).getAttachedObject().getAllTabs()[0];
                var parent_form_obj = parent.setup_regression_testing.tabbar.tabs(tab_id).getAttachedObject().tabs(inner_tab).getAttachedObject().cells('a').getAttachedObject();
                parent_form_obj.setItemValue('label_filter', result[0].join(','));
                parent_form_obj.setItemValue('filter', result[0].join(','));
                parent.new_browse.close();
            }

            regression_filter.load_form = function(tab_id, form_json, disable_all_fields) {
                if (typeof form_json == 'string') {
                    form_json = JSON.parse(form_json);
                } else {
                    form_json = form_json;
                }

                var tab_object = regression_filter.tabbar.tabs(tab_id);

                regression_filter["form_" + tab_id] = tab_object.attachForm(form_json);

                // Mark combined filter tab as loaded.
                loaded_tabs.push(tab_id);

                var form_obj = regression_filter["form_" + tab_id];

                // Only the combined tab is enabled. So, only the forms in that field has browse event.
                attach_browse_event("regression_filter.form_combined_filter", function_id);

                if(filter_parameters != 'NULL') {
                    var field_value_obj = {};
                    filter_parameters.split(',').forEach(function(e) {
                        var key_value_array = e.split('=');
                        var key = key_value_array[0];
                        var val = key_value_array[1] === 'NULL' ? '' : key_value_array[1].replace(/!/g, ",");
                        field_value_obj[key] = val;
                    });

                    Object.keys(field_value_obj).forEach(function(e) {
                        if(form_obj.getItemType(e) == 'combo') {
                            var combo_obj = form_obj.getCombo(e);
                            if(combo_obj.conf.opts_type == 'custom_checkbox') {
                                field_value_obj[e].split(",").forEach(function(val) {
                                    var index = combo_obj.getIndexByValue(val);
                                    combo_obj.setChecked(index,true);
                                });
                            } else {
                                combo_obj.setComboValue(field_value_obj[e]);
                            }
                        } else {
                            var name = '';
                            if (e == 'sub_id') { name = 'subsidiary_id'; }
                            if (e == 'stra_id') { name = 'strategy_id'; }
                            if (e == 'sub_book_id') { name = 'subbook_id'; }

                            if(e == 'sub_id' || e== 'stra_id' || e == 'sub_book_id')
                                form_obj.setItemValue(name, field_value_obj[e]);
                            else 
                                form_obj.setItemValue(e, field_value_obj[e]);
                        }
                    });
                }

                if (disable_all_fields == 'y') {
                    form_obj.forEachItem(function(name) {
                        form_obj.disableItem(name);
                        form_obj.setRequired(name, false);
                    });
                }
            }

            regression_filter.get_form_json = function(tab_id) {
                var load_default_filter = (filter_parameters=='')?1:0;
                regression_filter.tabbar.tabs(tab_id).progressOn();

                var data = {
                    "action": "spa_regression_testing",
                    "flag": "h",
                    "regression_module_header_id": regg_module_header_id,
                    "report_param_id": tab_id.split('_')[0],
                    "load_default_filter": load_default_filter,
                    "is_combined_tab": 'n'
                }

                adiha_post_data('return_json', data, '', '', function(result) {
                    var tab_form_json = JSON.parse(result);
                    tab_form_json = tab_form_json[0]['form_json'];
                    regression_filter.load_form(tab_id, tab_form_json, 'y');
                    regression_filter.tabbar.tabs(tab_id).progressOff();
                });
            }
        </script>
    </body>
</html>