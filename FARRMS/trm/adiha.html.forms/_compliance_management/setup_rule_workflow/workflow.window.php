<?php
/**
* Workflow window screen
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
    include "../../../adiha.php.scripts/components/include.file.v3.php";
    $module_events_id = get_sanitized_value($_GET['module_events_id'] ?? '');
    $workflow_name = get_sanitized_value($_GET['workflow_name'] ?? '');
    $module_id = get_sanitized_value($_GET['module_id'] ?? '');
    $event_id = get_sanitized_value($_GET['event_id'] ?? '');
    $rule_table_id = get_sanitized_value($_GET['rule_table_id'] ?? '');
    $parent_id = get_sanitized_value($_GET['parent_id'] ?? '');
    $task_id = get_sanitized_value($_GET['task_id'] ?? '');
    $workflow_option = get_sanitized_value($_GET['workflow_option'] ?? '');
	$is_active = get_sanitized_value($_GET['is_active'] ?? '');
	$eod_as_of_date = get_sanitized_value($_GET['eod_as_of_date'] ?? '');
    $rights_save = 10106610;

    list (
        $has_rights_save
    ) = build_security_rights(
        $rights_save
    );

    $has_rights_save = ($has_rights_save=='')?'false':'true';
    
    $theme_selected = 'dhtmlx_'.$default_theme;
    
    $namespace = 'workflow';
    $form_name = 'workflow_form';
    $toolbar_name = 'workflow_toolbar';
    
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();
    
    $layout_json = '[{id: "a", header:false, height:220}, {id:"b", header:false}]';
    echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $namespace);
    
    $toolbar_json = '[ {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:' . $has_rights_save . '}]';
    
    echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'workflow_save');
    
    $sp_module_id = "EXEC spa_setup_rule_workflow @flag='2'";
    $opt_module_id = $form_obj->adiha_form_dropdown($sp_module_id, 0, 1, false, $module_id);
    
    $sp_template_workflow_table = "EXEC spa_workflow_schedule @flag = 'p'";
    $opt_template_workflow = $form_obj->adiha_form_dropdown($sp_template_workflow_table, 0, 1, false, $module_events_id);

    $sp_eod_as_of_date = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 45600";
    $opt_eod_as_of_date = $form_obj->adiha_form_dropdown($sp_eod_as_of_date, 0, 1, true);
    
    $sql = "EXEC('SELECT report_param_operator_id [operator_id], [description] FROM report_param_operator')";
    $operator_val = readXMLURL2($sql);
    
    $sql = "EXEC spa_workflow_schedule @flag='q', @task_parent='" . $parent_id . "', @task_id='" . $module_events_id . "'";
    $workflow_link_list = readXMLURL2($sql);
    
    $form_json = "[{
                        type: 'block',
                        blockOffset: ".$ui_settings['block_offset'].",
                        list: [
                            {
                                'type': 'combo',
                                'name': 'workflow_option',
                                'label': 'Option',
                                'position': 'label-top',
                                'validate': 'NotEmpty',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'filtering': true,
                                'filtering_mode': 'between',
                                'offsetLeft':".$ui_settings['offset_left'].",
                                'tooltip': 'Event',
                                'options': [{text:'Workflow',value:'w',selected:true}]
                            },{'type': 'newcolumn'},{
                                'type': 'combo',
                                'name': 'template_workflow',
                                'label': 'Workflow Template',
                                'position': 'label-top',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'filtering': true,
                                'filtering_mode': 'between',
                                'tooltip': 'Workflow Template',
                                'offsetLeft':".$ui_settings['offset_left'].",
                                'options': $opt_template_workflow
                            },{'type': 'newcolumn'},{
                                'type': 'input',
                                'name': 'workflow_name',
                                'label': 'Workflow Name',
                                'position': 'label-top',
                                'validate': 'NotEmpty',
								'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'filtering': true,
                                'filtering_mode': 'between',
								'required': true,
                                'tooltip': 'Rule',
                                'offsetLeft':".$ui_settings['offset_left'].",
                                'userdata': {
                                    'validation_message': 'Required Field'
                                },
								'value':'$workflow_name'
                            }, {'type': 'newcolumn'},{
                                'type': 'combo',
                                'name': 'module_id',
                                'label': 'Module',
                                'position': 'label-top',
                                'validate': 'NotEmpty',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'required': true,
                                'filtering': true,
                                'filtering_mode': 'between',
                                'userdata': {
                                    'validation_message': 'Required Field'
                                },
                                'tooltip': 'Module',
                                'offsetLeft':".$ui_settings['offset_left'].",
                                'options': $opt_module_id
                            },{'type': 'newcolumn'},{
                                'type': 'combo',
                                'name': 'rule_table_id',
                                'label': 'Rule Table',
                                'position': 'label-top',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'filtering': true,
                                'hidden': 'true',
								'filtering_mode': 'between',
                                'tooltip': 'Module',
                                'offsetLeft':".$ui_settings['offset_left'].",
                                'options': ''
                            },{'type': 'newcolumn'},{
                                'type': 'combo',
                                'name': 'event_id',
                                'label': 'Event',
                                'position': 'label-top',
                                'validate': 'NotEmpty',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'required': true,
                                'filtering': true,
                                'filtering_mode': 'between',
                                'comboType':'custom_checkbox',
                                'offsetLeft':".$ui_settings['offset_left'].",
                                'userdata': {
                                    'validation_message': 'Required Field'
                                },
                                'tooltip': 'Event',
                                'options': ''
                            }, {'type': 'newcolumn'},{
								'type': 'checkbox',
								'name': 'is_active',
								'label': 'Active',
								'position': 'label-right',
								'labelWidth': 'auto',
                                'offsetLeft':".$ui_settings['offset_left'].",
								'offsetTop':ui_settings['checkbox_offset_top'],
								'tooltip': 'Active',
								'checked':'$is_active'
							}]}
							,{ type: 'block',
                                blockOffset: ".$ui_settings['block_offset'].",
                                list: [{
                                'type': 'dyn_calendar',
                                'name': 'eod_as_of_date',
                                'label': 'As of Date',
                                'position': 'label-top',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'required': false,
                                'offsetLeft':".$ui_settings['offset_left'].",
                                'tooltip': 'As of Date',
                                'dateFormat': '$date_format',
                                 'serverdateFormat': '%Y-%m-%d'
                            }]}
							]";
    echo $layout_obj->attach_form($form_name, 'a', $form_json);
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->attach_event('', 'onChange', 'workflow_form_onchange');
    
    echo $layout_obj->close_layout();
    ?>
    
    <style type="text/css">
        #data_container_ul, .workflow_link_list_ul, .workflow_link_condition_ul {
            list-style-type: none;
        }
        
        #where_clause {
            height: inherit;
            overflow-y: scroll;
        }
        
        .conditions, .link_condition {
            margin: 8px;
            padding: 3px;
            height: 70px;
            width: 490px;
            border-radius: 10px;
        }
        
        .and_conditions {
            background-color: #ace1ec;
        }
        
        .link_condition {
            margin: 2px!important;
            padding: 9px!important;
            background-color: #c5dcca;
        }
        
        .or_conditions {
            background-color: #f9f1d2;
        }
        
        .condition_group {
            background-color: #ffe5cc!important;
            height:40px!important;
            margin-left: -10px!important;
        }
        
        .hidden_item {
            display: none!important;
        }
        
        .float_left {
            float: left;
        }
        
        .labels_small, .inputs_small  {
            width:130px!important;
            margin-right: 15px;
        }
        
        .checkoption {
            float:left;
            height: inherit;
            margin-right: 5px;
            margin-left: 5px;
        }
        
        label {
            font-weight: normal!important;
        }
        
        #where_clause input[type='text'], .workflow_link input[type='text'] {
            height: 30px!important;
        }
        
        .double_value {
            width:70px!important;
        }
        
        .message_image {
            margin-right: 5px;
        }
        
        .labels_large, .inputs_large  {
            width:260px!important;
            margin-right: 15px;
        }

        div.dhxcombo_dhx_web {
            height: 23px!important;
        }

        input[type='text'] {
            height: 13px!important;
        }

    </style>
    
    <body id='content_body'>
        <div id="where_clause">
            <div id="add_buttons" style="display:none">
                <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/add_and_condition.png" alt="plus" height="18" width="18" title="<?php echo get_locale_value('Add AND Condition'); ?>" onclick="add_where_clause(1)"/>
                <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/add_or_condition.png" alt="plus" height="16" width="16" title="<?php echo get_locale_value('Add OR Condition'); ?>" onclick="add_where_clause(2)"/>
                <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/add_condition_group.png" alt="plus" height="16" width="16" title="<?php echo get_locale_value('Add Condition Group'); ?>" onclick="add_where_clause(3)"/>
                <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/close.gif" alt="plus" height="16" width="16" title="<?php echo get_locale_value('Delete'); ?>" onclick="delete_where_clause()"/>
                <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/add_tab.png" alt="plus" height="18" width="18" title="<?php echo get_locale_value('Add Tab'); ?>" onclick="add_link_condition_tab('','','')"/>
            </div>        
            <div id="where_clause_list">
                <ul id="data_container_ul">
                </ul>
            </div>
        </div>
        <div>
            <ul id="for_clone" style="display:none">
                <li class="and_or_conditions conditions">
                    <div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                    <div class="contents">
                        <input type="text" name="alert_where_clause_id" class="txt_workflow_where_clause_id hidden_item"/>
                        <input type="text" name="hdn_cmb_columns" class="hdn_cmb_columns hidden_item"/>
                        <label class="float_left labels_small"><?php echo get_locale_value('Columns'); ?></label>
                        <label class="float_left labels_small operators_label"><?php echo get_locale_value('Operator'); ?></label>
                        <label class="labels_small values_label"><?php echo get_locale_value('Values'); ?></label><br/>
                        <select class="cmb_columns form-control input-sm inputs_small float_left" onchange="columns_onchange(this)">
                        </select>
                        <select class="cmb_operators form-control input-sm inputs_small float_left" onchange="operator_onchange(this)">
                            <?php foreach($operator_val as $val) { ?>
                               <option value=<?php echo $val['operator_id']; ?>><?php echo $val['description']; ?></option>
                            <?php } ?>
                        </select>
                        <select class="cmb_values form-control input-sm inputs_small hidden_item float_left">
                        </select>
                        <select class="cmb_values1 form-control input-sm inputs_small hidden_item">
                        </select>
                        <input type="text" name="values"  placeholder="<?php echo get_locale_value('Values'); ?>" class="txt_values form-control input-sm inputs_small float_left"/>
                        <input type="text" name="values1"  placeholder="<?php echo get_locale_value('Values'); ?>" class="txt_values1 form-control input-sm inputs_small hidden_item float_left"/>
                        <select class="txt_values2 form-control input-sm inputs_small hidden_item">
                            <option value=1>Calendar Days</option>
                            <option value=2>Working Days</option>
                        </select>
                        <input type="text" name="widget_type"  placeholder="<?php echo get_locale_value('Widget Type'); ?>" class="widget_type form-control input-sm inputs_small hidden_item float_left"/>
                     </div>
                </li>
                <li class="condition_group conditions">
                    <div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                    <div class="contents">
                        <input type="text" name="alert_where_clause_id" class="txt_workflow_where_clause_id hidden_item"/>
                        <label class="float_left labels_small"><?php echo get_locale_value('Condition Group'); ?></label>
                        <select class="cmb_clause_type form-control input-sm inputs_small float_left">
                            <option value=3>AND</option>
                            <option value=4>OR</option>
                        </select>
                    </div>
                </li>
            </ul>
        </div>
        
        <div id="workflow_link_tenplate">
            <div class="workflow_link">
                <div class="link_add_buttons">
                    <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/add_and_condition.png" alt="plus" height="18" width="18" title="<?php echo get_locale_value('Add AND Condition'); ?>" onclick="add_link_where_clause(1)"/>
                    <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/add_or_condition.png" alt="plus" height="16" width="16" title="<?php echo get_locale_value('Add OR Condition'); ?>" onclick="add_link_where_clause(2)"/>
                    <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/add_condition_group.png" alt="plus" height="16" width="16" title="<?php echo get_locale_value('Add Condition Group'); ?>" onclick="add_link_where_clause(3)"/>
                    <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/close.gif" alt="plus" height="16" width="16" title="<?php echo get_locale_value('Delete'); ?>" onclick="delete_where_clause()"/>
                    <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/add_tab.png" alt="plus" height="18" width="18" title="<?php echo get_locale_value('Add Tab'); ?>" onclick="add_link_condition_tab('','','')"/>
                </div>        
                <div class="workflow_link_list">
                    <ul class="workflow_link_list_ul">
                        <li class="link_condition">
                            <div class="contents">
                                <input type="text" name="workflow_link_id" class="txt_workflow_link_id hidden_item"/>
                                <label class="float_left labels_large"><?php echo get_locale_value('Desciption'); ?></label>
                                <label class="float_left labels_small"><?php echo get_locale_value('Workflow'); ?></label>
                                <input type="text" name="description" placeholder="<?php echo get_locale_value('Description'); ?>" class="txt_description form-control input-sm inputs_large float_left"/>
                                <select class="cmb_workflow_list form-control input-sm inputs_small float_left">
                                    <?php foreach($workflow_link_list as $val) { ?>
                                       <option value=<?php echo $val['module_events_id']; ?>><?php echo $val['workflow_name']; ?></option>
                                    <?php } ?>
                                </select>
                             </div>
                        </li>
                    </ul>
                    <hr>
                </div>
                <div class="workflow_link_condition">
                    <ul class="workflow_link_condition_ul">
                    </ul>
                </div>
            </div>
        </div>
    </body>
    
    <link href="<?php echo $main_menu_path; ?>bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.css"/>
    <script src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.js"></script>
    <script type="text/javascript">

    var has_rights_save = Boolean(<?php echo $has_rights_save ?>);

        var modules_event_id = '<?php echo $module_events_id; ?>';
        var task_id = '<?php echo $task_id; ?>';
        var eod_as_of_date = '<?php echo $eod_as_of_date; ?>';

        $(function(){
            /*
            if (task_id != '') {
                workflow.workflow_form.disableItem('workflow_option');
            }*/
            workflow.workflow_form.hideItem('workflow_option');
            
            load_where_clause();
            load_workflow_link();
            workflow.tabbar = workflow.layout.cells('b').attachTabbar({
                                        tabs: [{id: "a1", text: get_locale_value("Condition"), active: true}]
                                    });
            
            workflow.tabbar.tabs('a1').attachObject("where_clause");
            workflow_option_change();
            
            workflow.tabbar.attachEvent("onTabClick", function(id, lastId){
                if($('input[name="rdo_template_datatype"]:checked').val() != undefined) {
                    $('input[name="rdo_template_datatype"]:checked').removeAttr("checked");
                } 
            });
            
            var workflow_option = '<?php echo $workflow_option; ?>';
            if (workflow_option != '') {
                var form_obj = workflow.layout.cells('a').getAttachedObject();
                form_obj.setItemValue('workflow_option',workflow_option);
            }
            workflow_option_change();
            
            var event_id = '<?php echo $event_id; ?>';
            var rule_table_id = '<?php echo $rule_table_id; ?>';
            reload_events(event_id);
            reload_rule_tables(rule_table_id);
            var module_id = workflow.workflow_form.getItemValue('module_id');
            if (module_id != 20619)
                workflow.workflow_form.hideItem('eod_as_of_date');
            workflow.workflow_form.setItemValue('eod_as_of_date',eod_as_of_date);
        })
        
        workflow_save = function() {
            var form_obj = workflow.layout.cells('a').getAttachedObject();
            var status = validate_form(form_obj);
            if (status) {
                
                var parent_id = '<?php echo $parent_id; ?>';
                
                var workflow_name = form_obj.getItemValue("workflow_name");
                var module_id = form_obj.getItemValue("module_id");
                
                var event_id_obj = form_obj.getCombo('event_id');
                var event_id = event_id_obj.getChecked();
                event_id = event_id.toString();
                
                var rule_table_id = form_obj.getItemValue("rule_table_id");
                var template_workflow = form_obj.getItemValue("template_workflow");
                var workflow_option = form_obj.getItemValue("workflow_option");
				var is_active = (form_obj.isItemChecked('is_active')) ? 'y' : 'n';
				var eod_as_of_date = form_obj.getItemValue("eod_as_of_date",true);
                if (eod_as_of_date.indexOf('|') === -1 && eod_as_of_date && eod_as_of_date != '') {
                    eod_as_of_date = dates.convert_to_sql(eod_as_of_date);
                }
                if (workflow_option == 'w') {
                    if (workflow_name == '') {
                        show_messagebox('Workflow name is required for new workflow.');
                        return;
                    }
                    template_workflow = ''; 
                } else if (workflow_option == 't') {
                    workflow_name = '';
                    module_id = '';
                    event_id = '';
                }
                
                var condition_flag = 0;
                var module_event_flag = 0;
                var where_clause_xml = '';
                var workflow_link_xml = '';
                var workflow_link_condition_xml = '';
                
                var sequence_no = 1;
                $('.conditions', '#where_clause').each(function() {
                    var alert_where_clause_id = $('.txt_workflow_where_clause_id', this).val();

                    if (($(this).hasClass('and_conditions')) == true) {
                        var clause_type = 1;    
                    } else if (($(this).hasClass('or_conditions')) == true) { 
                        var clause_type = 2 ;
                    } 

                    if (($(this).hasClass('and_conditions')) == true || ($(this).hasClass('or_conditions')) == true) {
                        var column_id = $('.cmb_columns', this).val();
                        var operator_id = $('.cmb_operators', this).val();
                        var widget_type1 = $('.widget_type', this).val(); 
                        var column_value = (widget_type1=='DROPDOWN') ? $('.cmb_values', this).val() : $('.txt_values', this).val();
                        if (operator_id == 8) {
                            var column_value2 = $('.txt_values1', this).val();
                        } else if (operator_id > 13) {
                            var column_value2 = $('.txt_values2', this).val();
                        } else {
                            var column_value2 = ''
                        }
                    } else {
                        var clause_type = $('.cmb_clause_type', this).val();
                        var column_id = '';
                        var operator_id = '';
                        var column_value = '';
                        var column_value2 = ''
                    }
                    

                    where_clause_xml += '<WhereClause workflow_next_where_clause_id="' + alert_where_clause_id 
                                                        + '" task_id="' + task_id 
                                                        + '" table_id="' + rule_table_id 
                                                        + '" column_id="' + column_id 
                                                        + '" operator_id="' + operator_id 
                                                        + '" column_value="' + column_value 
                                                        + '" column_value2="' + column_value2 
                                                        + '" sequence_no="' + sequence_no 
                                                        + '" clause_type="' + clause_type + '" />';
                    sequence_no++;
                });
                
                workflow.tabbar.forEachTab(function(tab){
                    var tab_id = tab.getId();
                    var html_id = '#' + tab_id;
                    if (tab_id != 'a1') {
                        var workflow_link_id = $('.txt_workflow_link_id', html_id).val();
                        var description = $('.txt_description', html_id).val();
                        var modules_event_id_link = $('.cmb_workflow_list', html_id).val();

                        if (modules_event_id_link == '' || modules_event_id_link == null) {
                            module_event_flag = 1;
                        }
                        
                        workflow_link_xml += '<WorkflowLink workflow_link_id="' + workflow_link_id 
                                                        + '" description="' + description 
                                                        + '" task_id="' + task_id 
                                                        + '" modules_event_id="' + modules_event_id_link
                                                        + '" link_tab_id="' + tab_id + '" />';
                        
                        
                        $('.conditions', html_id).each(function() {
                            var alert_where_clause_id = $('.txt_workflow_where_clause_id', this).val();

                            if (($(this).hasClass('and_conditions')) == true) {
                                var clause_type = 1;    
                            } else if (($(this).hasClass('or_conditions')) == true) { 
                                var clause_type = 2 ;
                            } 

                            if (($(this).hasClass('and_conditions')) == true || ($(this).hasClass('or_conditions')) == true) {
                                var column_id = $('.cmb_columns', this).val();
                                var operator_id = $('.cmb_operators', this).val();
                                var widget_type = $('.widget_type', this).val();
                                
                                if (widget_type == 'DROPDOWN') {
                                    var column_value = $('.cmb_values', this).val();
                                } else {
                                    var column_value = $('.txt_values', this).val();
                                }
                                if (operator_id == 8) {
                                    if (widget_type == 'DROPDOWN') {
                                        var column_value2 = $('.cmb_values2', this).val();
                                    } else {
                                        var column_value2 = $('.txt_values2', this).val();
                                    }
                                } else if (operator_id > 13) {
                                    var column_value2 = $('.txt_values2', this).val();
                                } else {
                                    var column_value2 = ''
                                }
                            } else {
                                var clause_type = $('.cmb_clause_type', this).val();
                                var column_id = '';
                                var operator_id = '';
                                var column_value = '';
                                var column_value2 = ''
                            }


                            workflow_link_condition_xml += '<LinkWhereClause workflow_Link_where_clause_id="' + alert_where_clause_id 
                                                                + '" workflow_link_id="' + workflow_link_id 
                                                                + '" table_id="' + rule_table_id 
                                                                + '" column_id="' + column_id 
                                                                + '" operator_id="' + operator_id 
                                                                + '" column_value="' + column_value 
                                                                + '" column_value2="' + column_value2 
                                                                + '" sequence_no="' + sequence_no 
                                                                + '" clause_type="' + clause_type 
                                                                + '" link_tab_id="' + tab_id + '" />';
                            sequence_no++;
                        });
                    }
                });
                

                var xml = '<Root>'
                xml = xml + '<FormXML modules_event_id="' + modules_event_id + '" workflow_name="' + workflow_name + '" module_id="' + module_id + '" event_id="' + event_id + '" rule_table_id="' + rule_table_id + '"  template_workflow="' + template_workflow + '" is_active="' + is_active + '" eod_as_of_date="' + eod_as_of_date + '"></FormXML>';
                xml = xml + '<TaskXML start_date="2015-01-02" duration="2" workflow_id_type="1" parent_id="' + parent_id + '" task_id="' + task_id + '"></TaskXML>';
                xml = xml + where_clause_xml;
                xml = xml + workflow_link_xml;
                xml = xml + workflow_link_condition_xml;
                xml = xml + '</Root>';
                
                if (condition_flag == 1) {
                    show_messagebox('Value is empty');
                    return;
                }
                
                if (module_event_flag == 1) {
                    show_messagebox('The workflow in link tab should not be empty.');
                    return;
                }
                
                data = {
                        "action": "spa_workflow_schedule", 
                        "flag": 'w',
                        "xml": xml
                    }
                result = adiha_post_data("alert", data, "", "", "workflow_save_callback");
            } 
        } 
        
        workflow_save_callback = function(result) {
            if (result[0].recommendation != null) {
                var ids_string = result[0].recommendation;
                var ids_array = ids_string.split(',');
                modules_event_id = ids_array[0];
                task_id = ids_array[1];
            }
        }
        
        load_where_clause = function() {
            $("#data_container_ul" ).sortable();
            $("#add_buttons").show();
            
            if (modules_event_id != '' && task_id !='') {
                load_where_clause_data();
            }
        }
        
        add_where_clause = function(condition) {
            if(condition == 1) {
                var condition_obj = $('.and_or_conditions','#for_clone').clone();
                $(condition_obj).addClass('and_conditions');
            } else if (condition == 2) {
                var condition_obj = $('.and_or_conditions','#for_clone').clone();
                $(condition_obj).addClass('or_conditions');
            } else if (condition == 3) {
                var condition_obj = $('.condition_group','#for_clone').clone();
            }
            
            $('#where_clause_list ul', '#where_clause').append(condition_obj);
        }
        
        workflow_form_onchange = function(name, value) {
            switch(name) {
                case 'rule_table_id':
                    reload_table_columns();
                    break;
                case 'workflow_option':
                    workflow_option_change();
                    break;
                case 'module_id':
                    reload_events('');
                    reload_rule_tables('');
                    var form_obj = workflow.layout.cells('a').getAttachedObject();
                    if (value == 20619) {
                        form_obj.showItem('eod_as_of_date');
                    } else {
                        form_obj.hideItem('eod_as_of_date');
                        form_obj.setItemValue('eod_as_of_date','');
                    }
                    break;
            }
        }
        
        reload_events = function(event_id) {
            var module_id = workflow.workflow_form.getItemValue('module_id');
            
            var cm_param = {
                            "action": "spa_setup_rule_workflow", 
                            "flag": "3",
                            "call_from": "form",
                            "module_id": module_id,
                            "has_blank_option": false
                        };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var combo_obj = workflow.workflow_form.getCombo('event_id');
            combo_obj.load(url, function() {
                if (event_id == '') {
                    combo_obj.selectOption(0);    
                } else {
                    var event_id_arr = event_id.split(',');
                    for (cnt = 0; cnt < event_id_arr.length; cnt++) {
                        var indx = combo_obj.getIndexByValue(event_id_arr[cnt]);
                        combo_obj.setChecked(indx, true);
                    }
                }
                
            });
        }
        
        reload_rule_tables = function(rule_table_id) {
            var module_id = workflow.workflow_form.getItemValue('module_id');
            
            var cm_param = {
                            "action": "spa_setup_rule_workflow", 
                            "flag": "4",
                            "call_from": "form",
                            "module_id": module_id,
                            "has_blank_option": false
                        };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var combo_obj = workflow.workflow_form.getCombo('rule_table_id');
            combo_obj.load(url, function() {
                combo_obj.setComboText('');
                if (rule_table_id == '') {
                    combo_obj.selectOption(0);    
                } else {
                    combo_obj.setComboValue(rule_table_id);
                }
            });
        }
        
        reload_table_columns = function() {
            var rule_table_id = workflow.workflow_form.getItemValue('rule_table_id'); 
            data = {
                        "action": "('SELECT dsc.data_source_column_id, ISNULL(dsc.alias,dsc.name) value FROM alert_table_definition atd INNER JOIN data_source ds ON atd.data_source_id = ds.data_source_id INNER JOIN data_source_column dsc ON dsc.source_id = ds.data_source_id WHERE atd.alert_table_definition_id = " + rule_table_id  +" ORDER BY [value]')"
                    };
            adiha_post_data("return_array", data, "", "", "reload_table_columns_callback");
        }
        
        reload_table_columns_callback = function(return_value) {
            $('.cmb_columns').empty();
            var option_string = '';
            for(cnt = 0; cnt < return_value.length; cnt++) {
                option_string = option_string + '<option value="' + return_value[cnt][0] + '">' + return_value[cnt][1] + '</option>';
            }

            $('.cmb_columns').append(option_string);

            $('.cmb_columns', '#where_clause').each(function() {
                var parent_obj = $(this).parent();
                var cmb_val = $('.hdn_cmb_columns', parent_obj).val();
                if (cmb_val != '') {
                    $('.cmb_columns', parent_obj).val(cmb_val);
                }
            })
        }
        
        load_where_clause_data = function() {
            data = {
                        "action": "spa_setup_rule_workflow",
                        "flag":"o",
                        "module_id": modules_event_id,
                        "workflow_id": task_id
                    };
            adiha_post_data("return_array", data, "", "", "load_where_clause_data_callback");
        }
        
        load_where_clause_data_callback = function(return_value) {
           for(cnt = 0; cnt < return_value.length; cnt++) {
                if (return_value[cnt][4] == 1 || return_value[cnt][4] == 2) {
                    var condition_obj = $('.and_or_conditions','#for_clone').clone();
                    if (return_value[cnt][4] == 1) {
                        $(condition_obj).addClass('and_conditions');
                    } else {
                        $(condition_obj).addClass('or_conditions');
                    }
                    
                    $('#where_clause_list ul', '#where_clause').append(condition_obj);
                    $('.txt_workflow_where_clause_id', condition_obj).val(return_value[cnt][0]);
                    $('.hdn_cmb_columns', condition_obj).val(return_value[cnt][1]);
                    $('.cmb_operators', condition_obj).val(return_value[cnt][2]);
                    $('.txt_values', condition_obj).val(return_value[cnt][3]);
                    $('.cmd_values', condition_obj).val(return_value[cnt][3]);

                    if (return_value[cnt][2] == 8) {
                        $('.txt_values1', condition_obj).val(return_value[cnt][5]);
                        $('.cmd_values1', condition_obj).val(return_value[cnt][5]);
                    } else if (return_value[cnt][2] > 13) {
                        $('.txt_values2', condition_obj).val(return_value[cnt][5]);
                    }
                    var obj = $('.hdn_cmb_columns', condition_obj);
                    columns_onchange(obj);
                }  else if (return_value[cnt][4] > 2) {
                    var condition_obj = $('.condition_group','#for_clone').clone();
                    $('#where_clause_list ul', '#where_clause').append(condition_obj);
                    $('.txt_workflow_where_clause_id', condition_obj).val(return_value[cnt][1]);
                    $('.cmb_clause_type', condition_obj).val(return_value[cnt][4]);
                }
            }      
            reload_table_columns();
        }
        
        delete_where_clause = function() {
            if($('input[name="rdo_template_datatype"]:checked').val() == undefined) {
                show_messagebox('Please select the components to delete');
                return;
            }
            $('input[name="rdo_template_datatype"]:checked').parent('div').parent('li').remove();
        }
        
        operator_onchange = function(obj) {
            var context_obj = $(obj).parent();
            var operator_id = $('.cmb_operators',context_obj).val();
            var widget_type = $('.widget_type', context_obj).val();

            if (operator_id == 8) {
                if (widget_type == 'DROPDOWN') {
                    $('.cmb_values', context_obj).removeClass('hidden_item');
                    $('.cmb_values1', context_obj).removeClass('hidden_item');
                    $('.cmb_values', context_obj).addClass('double_value');
                    $('.cmb_values1', context_obj).addClass('double_value');
                    $('.txt_values', context_obj).addClass('hidden_item');
                    $('.txt_values1', context_obj).addClass('hidden_item');
                } else {
                    $('.txt_values', context_obj).removeClass('hidden_item');
                    $('.txt_values1', context_obj).removeClass('hidden_item');
                    $('.txt_values', context_obj).addClass('double_value');
                    $('.txt_values1', context_obj).addClass('double_value');
                    $('.cmb_values', context_obj).addClass('hidden_item');
                    $('.cmb_values1', context_obj).addClass('hidden_item');
                }

                $('.txt_values2', context_obj).addClass('hidden_item');
                $('.txt_values2', context_obj).removeClass('double_value');

                $('.values_label', context_obj).removeClass('hidden_item');
                $('.operators_label', context_obj).addClass('float_left');
            } else if (operator_id > 13) {
                $('.txt_values', context_obj).removeClass('hidden_item');
                $('.txt_values1', context_obj).addClass('hidden_item');
                $('.txt_values2', context_obj).removeClass('hidden_item');
                $('.txt_values', context_obj).addClass('double_value');
                $('.txt_values1', context_obj).removeClass('double_value');
                $('.txt_values2', context_obj).addClass('double_value');

                $('.values_label', context_obj).removeClass('hidden_item');
                $('.operators_label', context_obj).addClass('float_left');
            } else if (operator_id == 6 || operator_id == 7) {
                $('.txt_values', context_obj).addClass('hidden_item');
                $('.txt_values1', context_obj).addClass('hidden_item');
                $('.txt_values2', context_obj).addClass('hidden_item');
                $('.cmb_values', context_obj).addClass('hidden_item');
                $('.cmb_values1', context_obj).addClass('hidden_item');

                $('.values_label', context_obj).addClass('hidden_item');
                $('.operators_label', context_obj).removeClass('float_left');
            } else {
                if (widget_type == 'DROPDOWN') {
                    $('.cmb_values', context_obj).removeClass('hidden_item');
                    $('.txt_values', context_obj).addClass('hidden_item');
                } else {
                    $('.txt_values', context_obj).removeClass('hidden_item');
                    $('.cmb_values', context_obj).addClass('hidden_item');
                }
                $('.cmb_values1', context_obj).addClass('hidden_item');
                $('.txt_values1', context_obj).addClass('hidden_item');
                $('.txt_values2', context_obj).addClass('hidden_item');
                $('.txt_values', context_obj).removeClass('double_value');
                $('.txt_values1', context_obj).removeClass('double_value');
                $('.cmb_values', context_obj).removeClass('double_value');
                $('.cmb_values1', context_obj).removeClass('double_value');
                $('.txt_values2', context_obj).removeClass('double_value');

                $('.values_label', context_obj).removeClass('hidden_item');
                $('.operators_label', context_obj).addClass('float_left');
            }
        }
        
        workflow_option_change = function() {
            var form_obj = workflow.layout.cells('a').getAttachedObject();
            var workflow_option = form_obj.getItemValue('workflow_option');
            
            if (workflow_option == 't') {
                form_obj.hideItem('workflow_name');
                form_obj.hideItem('module_id');
                form_obj.hideItem('event_id');
                form_obj.showItem('template_workflow');
                
            } else if (workflow_option == 'w') {
                form_obj.showItem('workflow_name');
                form_obj.showItem('module_id');
                form_obj.showItem('event_id');
                form_obj.hideItem('template_workflow');
                
            }
        }
        
        load_workflow_link = function() {
            $(".workflow_link_condition_ul" ).sortable();
            $(".link_add_buttons").show();
            
            if (task_id !='') {
                load_workflow_link_data();
            }
        }
        
        load_workflow_link_data = function() {
            data = {
                        "action": "spa_setup_rule_workflow",
                        "flag":"i",
                        "workflow_id": task_id
                    };
            adiha_post_data("return_array", data, "", "", "load_workflow_link_data_callback");
        }
        
        load_workflow_link_data_callback = function(return_value) {
            for(cnt = 0; cnt < return_value.length; cnt++) {
                var workflow_link_id = return_value[cnt][0];
                if (cnt ==  return_value.length - 1)
                    var final_tab = 1;
                else    
                    var final_tab = 2;
                add_link_condition_tab(workflow_link_id, return_value, final_tab);
            } 
        }
        
        add_link_condition_tab = function(tab_id, return_value, is_final_tab) {
            if(tab_id == '') {
                var new_tab_id = "a" + (new Date()).valueOf();
                var new_tab_name = "New Link";
            } else {
                var new_tab_id = tab_id;
                var new_tab_name = "Link";
            }
            workflow.tabbar.addTab(new_tab_id, get_locale_value(new_tab_name), null, null, true, true);
            
            var html_content = $('#workflow_link_tenplate').html();
            var html_string = "<div id='" + new_tab_id + "' style='height: inherit;overflow-y: scroll;'>" + html_content + "</div>";
            
            workflow.tabbar.tabs(new_tab_id).attachHTMLString(html_string);
            $(".workflow_link_condition_ul" ).sortable();
            
            if (tab_id != '') {
                var workflow_link_id = return_value[cnt][0];
                var description = return_value[cnt][1];
                var workflow_list = return_value[cnt][2];
                $('.txt_workflow_link_id', '#'+new_tab_id).val(workflow_link_id);
                $('.txt_description', '#'+new_tab_id).val(description);
                $('.cmb_workflow_list', '#'+new_tab_id).val(workflow_list);
                
                workflow.tabbar.tabs('a1').setActive();
                
                if (is_final_tab == 1) {
                    data_link = {
                        "action": "spa_setup_rule_workflow",
                        "flag":"1",
                        "workflow_id": task_id
                    };
                    setTimeout(function() {
                        adiha_post_data("return_array", data_link, "", "", "reload_link_where_clause");
                    }, 500);
                }
            }
        }
        
        
        reload_link_where_clause = function(return_value) {
            workflow.tabbar.forEachTab(function(tab){
                var tab_id = tab.getId();
                
                for(cnt = 0; cnt < return_value.length; cnt++) {
                     if (return_value[cnt][7] == tab_id) {
                        var context_obj = '#'+tab_id;
                        
                         if (return_value[cnt][4] == 1 || return_value[cnt][4] == 2) {
                            var condition_obj = $('.and_or_conditions','#for_clone').clone();
                            if (return_value[cnt][4] == 1) {
                                $(condition_obj).addClass('and_conditions');
                            } else {
                                $(condition_obj).addClass('or_conditions');
                            }
                            
                            $('.workflow_link_condition ul', context_obj).append(condition_obj);
                            $('.txt_workflow_where_clause_id', condition_obj).val(return_value[cnt][0]);
                            $('.hdn_cmb_columns', condition_obj).val(return_value[cnt][1]);
							$('.cmb_columns', condition_obj).val(return_value[cnt][1]);
                            $('.cmb_operators', condition_obj).val(return_value[cnt][2]);
                            $('.txt_values', condition_obj).val(return_value[cnt][3]);
                            $('.cmd_values', condition_obj).val(return_value[cnt][3]);

                            if (return_value[cnt][2] == 8) {
                                $('.txt_values1', condition_obj).val(return_value[cnt][5]);
                                $('.cmd_values1', condition_obj).val(return_value[cnt][5]);
                            } else if (return_value[cnt][2] > 13) {
                                $('.txt_values2', condition_obj).val(return_value[cnt][5]);
                            }
                            var obj = $('.hdn_cmb_columns', condition_obj);
                            columns_onchange(obj);
                        }  else if (return_value[cnt][4] > 2) {
                            var condition_obj = $('.condition_group','#for_clone').clone();
                            $('#workflow_link_condition ul', context_obj).append(condition_obj);
                            $('.txt_workflow_where_clause_id', condition_obj).val(return_value[cnt][1]);
                            $('.cmb_clause_type', condition_obj).val(return_value[cnt][4]);
                        }
                    }
                }
            });
        }
        
        add_link_where_clause = function(condition) {
            var active_tab_id =  workflow.tabbar.getActiveTab();
            var new_html_id = '#' + active_tab_id;
            
            if(condition == 1) {
                var condition_obj = $('.and_or_conditions','#for_clone').clone();
                $(condition_obj).addClass('and_conditions');
            } else if (condition == 2) {
                var condition_obj = $('.and_or_conditions','#for_clone').clone();
                $(condition_obj).addClass('or_conditions');
            } else if (condition == 3) {
                var condition_obj = $('.condition_group','#for_clone').clone();
            }
            
            $('.workflow_link_condition ul', new_html_id).append(condition_obj);
        }
        
        
    columns_onchange = function(obj) {
        var column_id = $(obj).val();
        var glb_context_obj = $(obj).parent();
        var glb_col_obj = obj;
        var data = {
                    "action": "spa_workflow_schedule",
                    "flag": "1",
                    "column_id": column_id
                };
        
        data = $.param(data);
        
        $.ajax({
            type: "POST",
            dataType: "json",
            url: js_form_process_url,
            async: false,
            data: data,
            success: function(data) {
                response_data = data["json"];
                reload_columns_widgets(response_data, glb_context_obj, glb_col_obj);
            }
        });
        
    }
    
    reload_columns_widgets = function(return_value, glb_context_obj, glb_col_obj) {
        $('.cmb_values', glb_context_obj).children().remove();
        $('.cmb_values1', glb_context_obj).children().remove();
        var widget_type = response_data[0].column_widgets;
        
        if (widget_type == 'DROPDOWN') {
            var dropdown_value = response_data[0].dropdown_options;
            var dropdown_value = $('<textarea/>').html(dropdown_value).text();
            $('.cmb_values', glb_context_obj).append(dropdown_value);
            $('.cmb_values1', glb_context_obj).append(dropdown_value);
            $('.cmb_values', glb_context_obj).removeClass('hidden_item');
            $('.txt_values', glb_context_obj).addClass('hidden_item');
            $('.txt_values1', glb_context_obj).addClass('hidden_item');
            $('.widget_type', glb_context_obj).val('DROPDOWN');
            var val1 = $('.txt_values', glb_context_obj).val();
            var val2 = $('.txt_values', glb_context_obj).val();
            $('.cmb_values', glb_context_obj).val(val1);
            $('.cmb_values1', glb_context_obj).val(val2);
        } else if (widget_type == 'DATETIME') {
            $('.txt_values', glb_context_obj).attr('type','date');
            $('.txt_values1', glb_context_obj).attr('type','date');
            $('.cmb_values', glb_context_obj).addClass('hidden_item');
            $('.cmb_values1', glb_context_obj).addClass('hidden_item');
            $('.txt_values', glb_context_obj).removeClass('hidden_item');
            $('.widget_type', glb_context_obj).val('DATETIME');
        } else {
            $('.cmb_values', glb_context_obj).append(dropdown_value);
            $('.cmb_values1', glb_context_obj).append(dropdown_value);
            $('.txt_values', glb_context_obj).attr('type','text');
            $('.txt_values1', glb_context_obj).attr('type','text');
            $('.cmb_values', glb_context_obj).addClass('hidden_item');
            $('.cmb_values1', glb_context_obj).addClass('hidden_item');
            $('.txt_values', glb_context_obj).removeClass('hidden_item');
            $('.widget_type', glb_context_obj).val('TEXTBOX');
        }
        operator_onchange(glb_col_obj);
    }
    </script>