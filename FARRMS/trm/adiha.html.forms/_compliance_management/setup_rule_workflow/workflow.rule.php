<?php
/**
* Workflow rule screen
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

$call_from = get_sanitized_value($_GET['call_from'] ?? '');
$alert_id = get_sanitized_value($_GET['alert_id'] ?? '');
$module_event_id = get_sanitized_value($_GET['module_event_id'] ?? '');
$event_trigger_id = get_sanitized_value($_GET['event_trigger_id'] ?? '');
$parent_id = get_sanitized_value($_GET['parent_id'] ?? '');
$rights_ui = get_sanitized_value($_GET['rights_ui'] ?? '1');
$add_save_right = get_sanitized_value($_GET['add_save_right'] ?? '1');
$add_save_right = ($add_save_right == '') ? '0' : '1';
$parent_module_id = get_sanitized_value($_GET['parent_module_id'] ?? '');
$rule_from = get_sanitized_value($_GET['rule_from'] ?? '');

$theme_selected = 'dhtmlx_'.$default_theme;

$sql = "EXEC spa_setup_rule_workflow @flag='2'";
$modules_val = readXMLURL2($sql);

if ($parent_module_id == 0 || $parent_module_id == '') {
    $sql = "EXEC spa_setup_rule_workflow @flag='5'";
    $rule_category = readXMLURL2($sql);
} else {
    $sql = "EXEC spa_setup_rule_workflow @flag='5',@module_id=" . $parent_module_id;
    $rule_category = readXMLURL2($sql);
}

$sql = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 750";
$notification_type_val = readXMLURL2($sql);
$sql = "EXEC spa_setup_rule_workflow @flag='6'";
$alert_table_val = readXMLURL2($sql);
$sql = "EXEC('SELECT report_param_operator_id [operator_id], [description] FROM report_param_operator')";
$operator_val = readXMLURL2($sql);
$sql = "EXEC spa_application_users @flag='a'";
$user_val = readXMLURL2($sql);
$sql = "EXEC spa_application_security_role @flag='s'";
$role_val = readXMLURL2($sql);
$sql = "EXEC('SELECT DISTINCT value_id, code FROM static_data_value INNER JOIN Contract_report_template ON value_id = template_type WHERE type_id = 25 ORDER BY code')";
$document_type_val = readXMLURL2($sql);
$sql = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 20600";
$document_category_val = readXMLURL2($sql);
$sql = "EXEC ('SELECT paramset_hash, name FROM report_paramset ORDER BY name')";
$report_val = readXMLURL2($sql);

$sql = "EXEC spa_setup_rule_workflow @flag = '9'";
$report_writer_val = readXMLURL2($sql);

$sql = "EXEC spa_setup_rule_workflow @flag = '10'";
$file_type_val = readXMLURL2($sql);

$form_namespace = 'workflow_alert';
$layout_json = '[
                        {id: "a", text: "Rule", header:false}
                    ]';
$layout_obj = new AdihaLayout();
echo $layout_obj->init_layout('workflow_alert_layout', '', '1C', $layout_json, $form_namespace);

$menu_json = '[
                    {id:"save", type: "button", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save", enabled: ' . $add_save_right . '},
                    {id:"delete",type: "button", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", title: "Delete", enabled: ' . $add_save_right . '},
                    {id:"schedule",type: "button", text:"Schedule", img:"run_view_schedule.gif", imgdis:"run_view_schedule_dis.gif", title: "Schedule", enabled: ' . $add_save_right . '}
                  ]';
////echo $layout_obj->attach_menu_layout_cell("alert_menu", "a", $menu_json, 'menu_click');
//
echo $layout_obj->attach_toolbar_cell('alert_menu','a');
$menu_object = new AdihaToolbar();
echo $menu_object->init_by_attach('alert_menu', $form_namespace);
echo $menu_object->load_toolbar($menu_json);
echo $menu_object->attach_event('', 'onClick', 'menu_click');
echo $layout_obj->close_layout();


?>


<style>

    #source_content {
        height: 545px;
        width: 20%;
        background-color: white;
        padding-top: 5px;
        float: left;
    }

    #source_content ul, #destination_content ul {
        list-style-type: none;
    }

    #source_content ul {
        margin-top: 60px;
    }

    #source_content li {
        height: 30px;
        margin: 8px;
        padding: 5px 0 0 15px;
    }

    #source_content .checkoption, #source_content .contents, #source_content input[type='text'], #destination_content .contents_label {
        display:none!important;
    }

    #source_content a {
        display:block!important;
    }

    #rule_div {
        height: 100%;
    }

    #destination_content {
        height: 100%;
        width: 80%;
        background-color: white;
        overflow-y: scroll;
        z-index:2000;
    }

    #destination_content li {
        margin: 8px;
        padding: 3px;
        height: 70px!important;
    }

    #destination_content .checkoption {
        float:left;
        height: inherit;
        margin-right: 5px;
        margin-left: 5px;
    }

    #destination_content .drop_item {
        margin-left: 10px;
        vertical-align: middle;
        line-height: 20px;
        width: 600px!important;
    }

    #destination_content input[type='text'] {
        width: 150px;
    }

    #source_content li:hover, .category li:hover, .category .labels:hover, .category_div:hover {
        cursor: move;
    }

    .drop_item {
        height:25px;
        border-radius: 3px;
    }

    .category_div {
        height: 27px;
        padding-left: 5px;
        padding-top: 3px;
        /*background-color: #94ACEB;*/
    }

    .data_container_ul{
        min-height:100px;
    }

    .hidden_item {
        display:none!important;
    }

    .object_42101 {
        background-color: #c2f0c2!important;
    }

    .object_42102 {
        background-color: #ace1ec!important;
    }

    .object_42103 {
        background-color: #becdf3!important;
    }

    .object_42104 {
        background-color: #ffffcc!important;
    }

    #destination_content .object_42103, #destination_content .object_42106 , #destination_content .object_42109 {
        margin-left: 60px!important;
    }

    #destination_content .object_42104, #destination_content .object_42105 {
        margin-left: 100px!important;
    }

    .object_42105 {
        background-color: #acffee!important;
    }

    .object_42106 {
        background-color: #d9f1c2!important;
    }

    .object_42107 {
        background-color: #ffe6e6!important;
    }

    .object_42108 {
        background-color: #ffe5cc !important;
    }

    .object_42109 {
        background-color: #ffe5ff!important;
    }

    #destination_content .object_42107 {
        height: 130px!important;
    }

    #destination_content .object_42108 {
        height:40px!important;
        margin-left: 80px!important;
    }

    #destination_content .object_42109 {
        height:95px!important;
    }

    .float_left {
        float:left;
    }

    .inputs, .labels {
        width:200px!important;
        margin-right: 15px;
    }

    .labels_small, .inputs_small  {
        width:130px!important;
        margin-right: 15px;
    }

    .labels_very_small {
        width:40px!important;
        margin-right: 15px;
    }

    .labels, .labels_small, .labels_very_small {
        font-weight: normal;
    }

    .label_btn {
        font-weight: normal;
        margin-right:8px;
        margin-top: 5px;
    }

    .inputs_large {
        width: 410px!important;
    }

    .message_image, .message_document_image, .message_report_image {
        cursor: pointer;
        float:left;
        margin-top: 8px;
        margin-right: 5px;
    }

    .message_privilege, .message_document, .message_report {
        width:inherit;
        display:none;
        padding-left: 25px;
        background-color: #ffe6e6!important;
        padding-bottom: 20px;
    }

    .checkbox_small {
        margin-top: 10px!important;
        margin-right: 5px!important;
    }

    .input_select {
        width: 180px!important;
        height:90px!important;
    }

    .privilege_btn {
        margin-left: 20px;
        margin-right: 20px;
    }

    .priv_btn {
        background-color: inherit!important;
    }

    .no_radio_content {
        width: 14px;
    }

    .double_value {
        width:70px!important;
    }

    /*to show cursor in ie-11*/
    input[type=checkbox], input[type=radio]{
        cursor: auto;
    }

</style>


<div id="rule_div">
    <div class="component-container">
        <div id="source_content">
            <ul id="source_content_ul" class="list-group">
                <?php
                if ($call_from == 'workflow') {
                    $xml_file = "EXEC('SELECT * FROM static_data_value WHERE type_id = 42100 AND value_id NOT IN (42101,42107) ORDER BY CASE WHEN value_id = 42108 THEN 42105.1 
																	WHEN value_id = 42109 THEN 42106.1
																	ELSE value_id END')";
                    $return_value1 = readXMLURL2($xml_file);
                } else if ($call_from == 'alert') {
                    $xml_file = "EXEC('SELECT * FROM static_data_value WHERE type_id = 42100 ORDER BY CASE WHEN value_id = 42108 THEN 42105.1 
																	WHEN value_id = 42109 THEN 42106.1
																	ELSE value_id END')";
                    $return_value1 = readXMLURL2($xml_file);
                } else if ($call_from == 'calendar') {
                    $xml_file = "EXEC('SELECT * FROM static_data_value WHERE type_id = 42100 AND value_id IN (42102,42107) ORDER BY CASE WHEN value_id = 42108 THEN 42105.1 
																	WHEN value_id = 42109 THEN 42106.1
																	ELSE value_id END')";
                    $return_value1 = readXMLURL2($xml_file);
                }

                foreach($return_value1 as $value) { ?>
                    <li class=" list-group_item drop_item <?php echo 'object_'.$value['value_id']; ?>">
                        <div class="hidden_item"><?php echo $value['value_id']; ?></div>
                        <div class="contents_label"><?php echo get_locale_value($value['code']); ?></div>

                        <?php if($value['value_id'] == 42101) { ?>
                            <div class="checkoption"></div>
                            <div class="contents">
                                <input type="text" name="module_event_id" class="txt_module_event_id hidden_item"/>
                                <input type="text" name="event_trigger_id" class="txt_event_trigger_id hidden_item"/>
                                <input type="text" name="hdn_cmb_events" class="hdn_cmb_events hidden_item"/>
                                <label class="float_left labels labels_small"><?php echo get_locale_value('Modules'); ?></label>
                                <label class="labels labels_small"><?php echo get_locale_value('Events'); ?></label><br/>
                                <select class="cmb_modules form-control input-sm float_left inputs inputs_small" onchange="modules_onchange(this)">
                                    <?php foreach($modules_val as $val) { ?>
                                        <option <?php if ($val['state'] ?? 'enable' == 'disable') {echo 'disabled=""';}?> value=<?php echo $val['value_id']; ?>><?php echo $val['code']; ?></option>
                                    <?php } ?>
                                </select>
                                <select class="cmb_events form-control input-sm inputs inputs float_left">
                                </select>
                                <input type="checkbox" value="" class="chk_active checkbox_small" checked><label class="labels labels_very_small"><?php echo get_locale_value('Active'); ?></label>
                            </div>
                        <?php } else if($value['value_id'] == 42102) { ?>
                            <div class="checkoption no_radio_content"></div>
                            <div class="contents">
                                <input type="text" name="rule_id" class="txt_rule_id hidden_item"/>
                                <label class="labels"><?php echo get_locale_value('Name'); ?></label>
                                <label class="labels hidden_item"><?php echo get_locale_value('Rule Category'); ?></label><br/>
                                <input type="text" name="rule_name"  placeholder="<?php echo get_locale_value('Name'); ?>" class="txt_rule_name form-control input-sm inputs"/>
                                <select class="cmb_notification_type form-control input-sm inputs hidden_item">
                                    <?php foreach($rule_category as $val) { ?>
                                        <option <?php if ($val['state'] ?? 'enable' == 'disable') {echo 'disabled=""';}?> value=<?php echo $val['value_id']; ?>><?php echo $val['code']; ?></option>
                                    <?php } ?> 
                                </select>
                            </div>

                        <?php } else if($value['value_id'] == 42103) { ?>
                            <div class="checkoption no_radio_content"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                            <div class="contents">
                                <input type="text" name="alert_rule_table_id" class="txt_alert_rule_table_id hidden_item"/>
                                <input type="text" name="alert_condition_id" class="txt_alert_condition_id hidden_item"/>
                                <input type="text" name="hdn_cmb_table_name" class="hdn_cmb_table_name hidden_item"/>
                                <label class="labels"><?php echo get_locale_value('Data View'); ?></label>
                                <label class="labels hidden_item"><?php echo get_locale_value('Table Alias'); ?></label><br/>
                                <select class="cmb_table_name form-control input-sm inputs" onchange="table_object_onchange(this)">
                                    <option value=''></option>
                                    <?php foreach($alert_table_val as $val) { ?>
                                        <option value=<?php echo $val['alert_table_definition_id']; ?>><?php echo $val['logical_table_name']; ?></option>
                                    <?php } ?>
                                </select>
                                <input type="text" name="table_alias"  placeholder="<?php echo get_locale_value('Alias'); ?>" class="txt_table_alias form-control input-sm inputs hidden_item"/>
                            </div>

                        <?php } else if($value['value_id'] == 42104 || $value['value_id'] == 42105) { ?>
                            <div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                            <div class="contents">
                                <input type="text" name="alert_where_clause_id" class="txt_alert_where_clause_id hidden_item"/>
                                <input type="text" name="hdn_cmb_columns" class="hdn_cmb_columns hidden_item"/>
                                <label class="float_left labels_small"><?php echo get_locale_value('Columns'); ?></label>
                                <label class="float_left labels_small operators_label"><?php echo get_locale_value('Operator'); ?></label>
                                <label class="labels_small values_label"><?php echo get_locale_value('Values'); ?></label><br/>
                                <select class="cmb_columns form-control input-sm inputs_small float_left" onchange="columns_onchange(this, 0)">
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
                                <input type="text" name="widget_type"  placeholder="Widget Type" class="widget_type form-control input-sm inputs_small hidden_item float_left"/>
                            </div>

                        <?php } else if($value['value_id'] == 42106) { ?>
                            <div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                            <div class="contents">
                                <input type="text" name="alert_action_id" class="txt_alert_action_id hidden_item"/>
                                <input type="text" name="hdn_cmb_columns" class="hdn_cmb_columns hidden_item"/>
                                <label class="float_left labels"><?php echo get_locale_value('Columns'); ?></label>
                                <label class="labels"><?php echo get_locale_value('Values'); ?></label><br/>
                                <select class="cmb_columns form-control input-sm inputs float_left" onchange="columns_onchange(this, 1)">
                                </select>
                                <select class="cmb_values form-control input-sm inputs_small hidden_item float_left">
                                </select>
                                <input type="text" name="values"  placeholder="<?php echo get_locale_value('Values'); ?>" class="txt_values form-control input-sm inputs"/>
                                <input type="text" name="widget_type"  placeholder="<?php echo get_locale_value('Widget Type'); ?>" class="widget_type form-control input-sm inputs_small hidden_item float_left"/>
                            </div>

                        <?php } else if($value['value_id'] == 42107) { ?>
                            <div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                            <div class="contents">
                                <input type="checkbox" value="" class="chk_alert checkbox_small"><label class="labels_very_small"><?php echo get_locale_value('Alert'); ?></label>
                                <input type="checkbox" value="" class="chk_email checkbox_small"><label class="labels_very_small"><?php echo get_locale_value('Email'); ?></label>
                                <input type="checkbox" value="" class="chk_message_board checkbox_small"><label class="labels_small"><?php echo get_locale_value('Message Board'); ?></label>
                                <br/>

                                <input type="text" name="workflow_message_id" class="txt_workflow_message_id hidden_item"/>
                                <textarea name="message"  placeholder = "" class="txt_message form-control input-sm inputs_large"></textarea>
                                <div class="float_left">
                                    <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/plus.png" alt="plus" height="16" width="16"  onclick="message_click()"/>
                                    <label class="float_left label_btn"><?php echo get_locale_value('Users'); ?></label>
                                </div>
                                <div class="float_left">
                                    <img class="message_document_image" src="<?php echo $image_path; ?>dhxtoolbar_web/plus.png" alt="plus" height="16" width="16"  onclick="message_document_click()"/>
                                    <label class="float_left label_btn"><?php echo get_locale_value('Documents'); ?></label>
                                </div>
                                <div class="float_left">
                                    <img class="message_report_image" src="<?php echo $image_path; ?>dhxtoolbar_web/plus.png" alt="plus" height="16" width="16"  onclick="message_report_click()"/>
                                    <label class="float_left label_btn"><?php echo get_locale_value('Reports'); ?></label>
                                </div>
                                <input type="checkbox" value="" class="chk_self_notify checkbox_small"><label class="labels"><?php echo get_locale_value('Do not Self-Notify'); ?></label><br/>

                                <div class="message_privilege">
                                    <label class="labels_small"><?php echo get_locale_value('Users'); ?></label><br/>
                                    <select multiple name="user_from" class="user_from form-control input-sm input_select float_left" ondblclick="change_states(this, 'user_from', 'user_to')">
                                        <?php foreach($user_val as $val) { ?>
                                            <option value="<?php echo $val['user_login_id']; ?>"><?php echo $val['name']; ?></option>
                                        <?php } ?>
                                    </select>
                                    <div class="privilege_btn float_left">
                                        <button type="button" class="btn btn-default priv_btn" onclick="change_states(this, 'user_from', 'user_to')">>></button><br/>
                                        <button type="button" class="btn btn-default priv_btn" onclick="change_states(this, 'user_to', 'user_from')"><<</button>
                                    </div>
                                    <select multiple name="user_to" class="user_to form-control input-sm input_select" ondblclick="change_states(this, 'user_to', 'user_from')">
                                    </select>
                                    <br/>
                                    <label class="labels_small"><?php echo get_locale_value('Roles'); ?></label><br/>
                                    <select multiple name="role_from" class="role_from form-control input-sm input_select float_left" ondblclick="change_states(this, 'role_from', 'role_to')">
                                        <?php foreach($role_val as $val) { ?>
                                            <option value="<?php echo $val['role_id']; ?>"><?php echo $val['role_name']; ?></option>
                                        <?php } ?>
                                    </select>
                                    <div class="privilege_btn float_left">
                                        <button type="button" class="btn btn-default priv_btn" onclick="change_states(this, 'role_from', 'role_to')">>></button><br/>
                                        <button type="button" class="btn btn-default priv_btn" onclick="change_states(this, 'role_to', 'role_from')"><<</button>
                                    </div>
                                    <select multiple name="role_to" class="role_to form-control input-sm input_select" ondblclick="change_states(this, 'role_to', 'role_from')">
                                    </select>
                                </div>
                                <div class="message_document">
                                    <input type="text" name="hdn_cmb_document_category" class="hdn_cmb_document_category hidden_item"/>
                                    <label class="float_left labels"><?php echo get_locale_value('Document Type'); ?></label>
                                    <label class="labels"><?php echo get_locale_value('Document Category'); ?></label><br/>
                                    <select class="cmb_document_type form-control input-sm float_left inputs"  onchange="document_type_onchange(this)">
                                        <option value=''></option>
                                        <?php foreach($document_type_val as $val) { ?>
                                            <option value=<?php echo $val['value_id']; ?>><?php echo $val['code']; ?></option>
                                        <?php } ?>
                                    </select>
                                    <select class="cmb_document_category form-control input-sm inputs">
                                    </select>
                                </div>
                                <div class="message_report">
                                    <!--                                    <input type="checkbox" value="" class="cmb_report_writer checkbox_small" onchange="report_writer_onchange(this)"><label class="labels">Report Manager</label><br/>-->
                                    <label class="label_report_writer labels" ><?php echo get_locale_value('Report Type'); ?></label>
                                    <select class="cmb_report_writer form-control input-sm inputs" onchange="report_writer_onchange(this)">
                                        <option value=''></option>
                                        <?php foreach($report_writer_val as $val) { ?>
                                            <option value=<?php echo $val['value']; ?>><?php echo $val['code']; ?></option>
                                        <?php } ?>
                                    </select>
                                    <label class="label_report_description float_left labels_small"><?php echo get_locale_value('Report Description'); ?></label>
                                    <label class="label_report_sufix float_left labels_small operators_label"><?php echo get_locale_value('Report Sufix'); ?></label>
                                    <label class="label_report_prefix labels_small values_label"><?php echo get_locale_value('Report Prefix'); ?></label><br/>

                                    <input type="text" style="clear:left" name="report_description"  placeholder="<?php echo get_locale_value('Description'); ?>" class="txt_report_description float_left form-control input-sm inputs_small"/>
                                    <input type="text" name="report_sufix"  placeholder="<?php echo get_locale_value('Sufix'); ?>" class="txt_report_sufix float_left form-control input-sm inputs_small"/>
                                    <input type="text" name="report_prefix"  placeholder="<?php echo get_locale_value('prefix'); ?>" class="txt_report_prefix form-control input-sm inputs_small"/>


                                    <label class="label_report labels hidden_item"><?php echo get_locale_value('Report'); ?></label>
                                    <select class="cmb_report form-control input-sm inputs hidden_item">
                                        <option value=''></option>
                                        <?php foreach($report_val as $val) { ?>
                                            <option value=<?php echo $val['paramset_hash']; ?>><?php echo $val['name']; ?></option>
                                        <?php } ?>
                                    </select>
                                    <div style="clear:left"></div>
                                    <label class="label_file_option_type labels" ><?php echo get_locale_value('File Option Type'); ?></label>
                                    <select class="cmb_file_option_type form-control input-sm inputs">
                                        <option value=''></option>
                                        <?php foreach($file_type_val as $val) { ?>
                                            <option value=<?php echo $val['value']; ?>><?php echo $val['code']; ?></option>
                                        <?php } ?>
                                    </select>
                                </div>
                            </div>
                        <?php } else if($value['value_id'] == 42108) { ?>
                            <div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                            <div class="contents">
                                <input type="text" name="alert_where_clause_id" class="txt_alert_where_clause_id hidden_item"/>
                                <label class="float_left labels_small"><?php echo get_locale_value('Condition Group'); ?></label>
                                <select class="cmb_clause_type form-control input-sm inputs_small float_left">
                                    <option value=3>AND</option>
                                    <option value=4>OR</option>
                                </select>
                            </div>

                        <?php } else if($value['value_id'] == 42109) { ?>
                            <div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                            <div class="contents">
                                <input type="text" name="alert_sql_id" class="txt_alert_sql_id hidden_item"/>
                                <textarea name="sql_statement" placeholder = "" class="txt_sql_statement form-control input-sm inputs_large" rows="4"></textarea>
                            </div>

                        <?php } ?>
                    </li>
                <?php } ?>
            </ul>
        </div>
    </div>
    <div class="component-container" style="height:100%">
        <div id="destination_content">
            <ul id="destination_content_ul" class="list-group">
                <li class="category">
                    <div class="category_div"></div>
                    <ul class="data_container_ul">
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</div>

<link href="<?php echo $main_menu_path; ?>bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.css"/>
<script src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.js"></script>
<script type="text/javascript">
    var alert_id = '<?php echo $alert_id; ?>';
    var call_from = '<?php echo $call_from; ?>';
    var module_event_id = '<?php echo $module_event_id; ?>';
    var event_trigger_id = '<?php echo $event_trigger_id ?>';
    var parent_id = '<?php echo $parent_id; ?>';
    var w_module_id = '<?php echo $parent_module_id; ?>';
    var client_date_format = '<?php echo $date_format; ?>';
    $(function() {
        workflow_alert.workflow_alert_layout.cells("a").attachObject("rule_div");
        if (call_from == 'workflow') {
            workflow_alert.alert_menu.hideItem('schedule');
        }
        attach_popup_to_schedule_button();
    })

    $(document).ready(function(){
        $("#source_content li").draggable({
            cursor: 'move',
            connectToSortable: '.category ul',
            helper: 'clone',
            start: function(event, ui) {
                var flag = 0;
                if (($(this).hasClass('object_42101') ==  true) && ($('.object_42101', '#destination_content').html() != undefined)) {
                    flag = 1;
                } else if (($(this).hasClass('object_42102') ==  true) && ($('.object_42102', '#destination_content').html() != undefined)) {
                    flag = 1;
                } else if (($(this).hasClass('object_42103') ==  true) && ($('.object_42103', '#destination_content').html() != undefined)) {
                    flag = 1;
                } else if (($(this).hasClass('object_42107') ==  true) && ($('.object_42107', '#destination_content').html() != undefined)) {
                    flag = 1;
                } else if (($(this).hasClass('object_42109') ==  true) && ($('.object_42109', '#destination_content').html() != undefined)) {
                    flag = 1;
                }

                if (flag == 1) {
                    var obj_name = $('.contents_label', this).text();
                    success_call(obj_name + ' cannot be dragged multiple times.');

                    return false;
                } else {
                    return true;
                }
            },
            stop: function(event, ui) {
                var module_obj = $('.cmb_modules', '#destination_content')
                var module_id = module_obj.val();
                if (($(this).hasClass('object_42101') ==  true)) {
                    var module_obj = $('.cmb_modules', '#source_content');
                    modules_onchange(module_obj);
                } else if (($(this).hasClass('object_42107') ==  true)) {
                    add_context_zone();
                } else if (($(this).hasClass('object_42103') ==  true) && module_id == 20610) {
                    var t_obj = $('.cmb_table_name', '#destination_content');
                    table_object_onchange(t_obj);
                }
                position_message_div();
                $('.txt_sql_statement', '#destination_content').attr("placeholder", get_locale_value("SQL statement"));
                $('.txt_message', '#destination_content').attr("placeholder", get_locale_value("Message"));
            }
        });
        sort_item();
        default_table_load();

        if (alert_id == '') {
            load_init_alert_components();
        } else {
            load_alert_components(alert_id);
        }
        position_message_div();
    });

    function sort_item() {
        $("#destination_content ul").sortable({
            items: "li:not(.object_42107)" //Removes draggable for message box
        });
    }

    function position_message_div() {
        /*Always put message at the bottom*/
        var total_list_element = $('#destination_content ul li').length - 1;
        var message_position = $('.object_42107', '#destination_content').index() + 1;
        if ($('.object_42107', '#destination_content').html() != undefined) {
            $('#destination_content ul li:eq('+message_position+')').insertAfter($('#destination_content ul li:eq('+total_list_element+')'));
        }
    }

    message_click = function() {
        var img_src = $('.message_image').attr('alt');
        if (img_src == 'plus') {
            $('.message_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/minus.png');
            $(".message_privilege").css({display: "block"});
            $('.message_image').attr('alt','minus');

            $('.message_document_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_document").css({display: "none"});
            $('.message_document_image').attr('alt','plus');

            $('.message_report_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_report").css({display: "none"});
            $('.message_report_image').attr('alt','plus');
        } else {
            $('.message_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_privilege").css({display: "none"});
            $('.message_image').attr('alt','plus');
        }
    }

    message_document_click = function() {
        var img_src = $('.message_document_image').attr('alt');
        if (img_src == 'plus') {
            $('.message_document_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/minus.png');
            $(".message_document").css({display: "block"});
            $('.message_document_image').attr('alt','minus');

            $('.message_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_privilege").css({display: "none"});
            $('.message_image').attr('alt','plus');

            $('.message_report_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_report").css({display: "none"});
            $('.message_report_image').attr('alt','plus');
        } else {
            $('.message_document_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_document").css({display: "none"});
            $('.message_document_image').attr('alt','plus');
        }
    }

    message_report_click = function() {
        var img_src = $('.message_report_image').attr('alt');
        if (img_src == 'plus') {
            $('.message_report_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/minus.png');
            $(".message_report").css({display: "block"});
            $('.message_report_image').attr('alt','minus');

            $('.message_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_privilege").css({display: "none"});
            $('.message_image').attr('alt','plus');

            $('.message_document_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_document").css({display: "none"});
            $('.message_document_image').attr('alt','plus');
        } else {
            $('.message_report_image').attr('src', '<?php echo $image_path; ?>dhxtoolbar_web/plus.png');
            $(".message_report").css({display: "none"});
            $('.message_report_image').attr('alt','plus');
        }
    }

    table_object_onchange = function(obj) {
        var table_id = $(obj).val();
        if (!table_id || table_id == '' || table_id == undefined) {
            var context_obj = '#destination_content';
            var module_id = '';
            $('.object_42101', context_obj).each(function() {
                module_id = $('.cmb_modules', this).val();
            });

            if (module_id == '') {
                module_id = w_module_id;
            }
            table_id = "(SELECT MAX(atd.alert_table_definition_id) FROM workflow_module_rule_table_mapping wm INNER JOIN alert_table_definition atd ON wm.rule_table_id = atd.alert_table_definition_id  WHERE wm.module_id = " + module_id + " AND wm.is_active = 1 AND atd.is_action_view = ''y'')";
        }
        data = {
            "action": "('SELECT dsc.data_source_column_id, ISNULL(dsc.alias,dsc.name) value FROM alert_table_definition atd INNER JOIN data_source ds ON atd.data_source_id = ds.data_source_id INNER JOIN data_source_column dsc ON dsc.source_id = ds.data_source_id WHERE atd.alert_table_definition_id = " + table_id  +" ORDER BY [value]')"
        };
        adiha_post_data("return_array", data, "", "", "reload_table_columns");
    }

    default_table_load = function() {
        var module_id = w_module_id;
        var table_id = "(SELECT MAX(atd.alert_table_definition_id) FROM workflow_module_rule_table_mapping wm INNER JOIN alert_table_definition atd ON wm.rule_table_id = atd.alert_table_definition_id  WHERE wm.module_id = " + module_id + " AND wm.is_active = 1 AND atd.is_action_view = ''y'')";

        data = {
            "action": "('SELECT dsc.data_source_column_id, ISNULL(dsc.alias,dsc.name) value FROM alert_table_definition atd INNER JOIN data_source ds ON atd.data_source_id = ds.data_source_id INNER JOIN data_source_column dsc ON dsc.source_id = ds.data_source_id WHERE atd.alert_table_definition_id = " + table_id  +" ORDER BY [value]')"
        };
        adiha_post_data("return_array", data, "", "", "reload_table_columns");
    }

    reload_table_columns = function(return_value) {
        $('.cmb_columns').empty();
        var option_string = '';
        for(cnt = 0; cnt < return_value.length; cnt++) {
            option_string = option_string + '<option value="' + return_value[cnt][0] + '">' + return_value[cnt][1] + '</option>';
        }

        $('.cmb_columns').append(option_string);

        $('.cmb_columns', '#destination_content').each(function() {
            var parent_obj = $(this).parent();
            var cmb_val = $('.hdn_cmb_columns', parent_obj).val();
            if (cmb_val != '') {
                $('.cmb_columns', parent_obj).val(cmb_val);
            }
        })
    }

    report_writer_onchange = function(obj) {
        var report_writer_val = $('.cmb_report_writer', '#destination_content').val();
        if (report_writer_val == 'y') {
            $('.txt_report_description', '#destination_content').addClass('hidden_item');
            $('.txt_report_sufix', '#destination_content').addClass('hidden_item');
            $('.txt_report_prefix', '#destination_content').addClass('hidden_item');
            $('.txt_report_description', '#destination_content').val('');
            $('.txt_report_sufix', '#destination_content').val('');
            $('.txt_report_prefix', '#destination_content').val('');
            $('.label_report_description', '#destination_content').addClass('hidden_item');
            $('.label_report_sufix', '#destination_content').addClass('hidden_item');
            $('.label_report_prefix', '#destination_content').addClass('hidden_item');
            $('.label_report', '#destination_content').removeClass('hidden_item');
            $('.cmb_report', '#destination_content').removeClass('hidden_item');
        } else if (report_writer_val == 'n') {
            $('.txt_report_description', '#destination_content').removeClass('hidden_item');
            $('.txt_report_description', '#destination_content').addClass('inputs_small');
            $('.txt_report_description', '#destination_content').removeClass('inputs');
            $('.txt_report_sufix', '#destination_content').removeClass('hidden_item');
            $('.txt_report_prefix', '#destination_content').removeClass('hidden_item');
            $('.label_report_description', '#destination_content').removeClass('hidden_item');
            $('.label_report_sufix', '#destination_content').removeClass('hidden_item');
            $('.label_report_prefix', '#destination_content').removeClass('hidden_item');
            $('.label_report', '#destination_content').addClass('hidden_item');
            $('.cmb_report', '#destination_content').addClass('hidden_item');
            $('.cmb_report', '#destination_content').val('');
        } else if (report_writer_val == 'a') {
            $('.txt_report_description', '#destination_content').removeClass('hidden_item');
            $('.txt_report_description', '#destination_content').removeClass('inputs_small');
            $('.txt_report_description', '#destination_content').addClass('inputs');
            $('.txt_report_sufix', '#destination_content').addClass('hidden_item');
            $('.txt_report_prefix', '#destination_content').addClass('hidden_item');
            $('.label_report_description', '#destination_content').removeClass('hidden_item');
            $('.label_report_sufix', '#destination_content').addClass('hidden_item');
            $('.label_report_prefix', '#destination_content').addClass('hidden_item');
            $('.label_report', '#destination_content').addClass('hidden_item');
            $('.cmb_report', '#destination_content').addClass('hidden_item');
            $('.cmb_report', '#destination_content').val('');
        } else {
            $('.txt_report_description', '#destination_content').addClass('hidden_item');
            $('.txt_report_sufix', '#destination_content').addClass('hidden_item');
            $('.txt_report_prefix', '#destination_content').addClass('hidden_item');
            $('.txt_report_description', '#destination_content').val('');
            $('.txt_report_sufix', '#destination_content').val('');
            $('.txt_report_prefix', '#destination_content').val('');
            $('.label_report_description', '#destination_content').addClass('hidden_item');
            $('.label_report_sufix', '#destination_content').addClass('hidden_item');
            $('.label_report_prefix', '#destination_content').addClass('hidden_item');
            $('.label_report', '#destination_content').addClass('hidden_item');
            $('.cmb_report', '#destination_content').addClass('hidden_item');
            $('.cmb_report', '#destination_content').val('');
        }
    }

    document_type_onchange = function(obj) {
        var document_type = $(obj).val();
        data = {
            "action": "('SELECT DISTINCT value_id, code FROM static_data_value  INNER JOIN Contract_report_template ON value_id = template_category  WHERE type_id = 42000 AND category_id = " + document_type + " ORDER BY code')"
        };
        adiha_post_data("return_array", data, "", "", "reload_document_category");
    }

    reload_document_category = function(return_value) {
        $('.cmb_document_category').empty();
        var option_string = '';
        for(cnt = 0; cnt < return_value.length; cnt++) {
            option_string = option_string + '<option value="' + return_value[cnt][0] + '">' + return_value[cnt][1] + '</option>';
        }

        $('.cmb_document_category').append(option_string);

        $('.cmb_document_category', '#destination_content').each(function() {
            var parent_obj = $(this).parent();
            var cmb_val = $('.hdn_cmb_document_category', parent_obj).val();
            if (cmb_val != '') {
                $('.cmb_document_category', parent_obj).val(cmb_val);
            }
        })
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

    columns_onchange = function(obj, flag) {
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
                if (flag == 0) {
                    reload_columns_widgets(response_data, glb_context_obj, glb_col_obj);
                } else {
                    reload_columns_widgets_actions(response_data, glb_context_obj);
                }
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

    reload_columns_widgets_actions = function(return_value, glb_context_obj) {
        $('.cmb_values', glb_context_obj).children().remove();
        var widget_type = response_data[0].column_widgets;

        if (widget_type == 'DROPDOWN') {
            var dropdown_value = response_data[0].dropdown_options;
            var dropdown_value = $('<textarea/>').html(dropdown_value).text();
            $('.cmb_values', glb_context_obj).append(dropdown_value);
            $('.cmb_values', glb_context_obj).removeClass('hidden_item');
            $('.txt_values', glb_context_obj).addClass('hidden_item');
            $('.widget_type', glb_context_obj).val('DROPDOWN');
            var val1 = $('.txt_values', glb_context_obj).val();
            $('.cmb_values', glb_context_obj).val(val1);
        } else if (widget_type == 'DATETIME') {
            $('.txt_values', glb_context_obj).attr('type','date');
            $('.cmb_values', glb_context_obj).addClass('hidden_item');
            $('.txt_values', glb_context_obj).removeClass('hidden_item');
            $('.widget_type', glb_context_obj).val('DATETIME');
        } else {
            $('.txt_values', glb_context_obj).attr('type','text');
            $('.cmb_values', glb_context_obj).addClass('hidden_item');
            $('.txt_values', glb_context_obj).removeClass('hidden_item');
            $('.widget_type', glb_context_obj).val('TEXTBOX');
        }
    }

    function change_states(block, from, to) {
        var context_obj =$(block).closest('.message_privilege');
        var sel_val = $('.'+from, context_obj).val();
        var optns = $('.' + from + ' option', context_obj);

        var option_string = '';
        $.map(optns ,function(option) {
            if (jQuery.inArray(option.value, sel_val) > -1) {
                option_string += '<option value="' + option.value + '">' + option.text + '</option>';
                $('.'+from+' option[value="' +  option.value + '"]', context_obj).remove();
            }
        });
        $('.' + to, context_obj).append(option_string);
    }
    attach_popup_to_schedule_button = function() {
        var current_date = new Date();
        var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
        var schedule_form_data = [
            {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
            {type: "calendar","required":"true", name: "schedule_date", label: "Schedule Date", "dateFormat":"%Y-%m-%d %H:%i","serverDateFormat":"%Y-%m-%d %H:%i", "value":'',"calendarPosition":"bottom","enableTime":"true",
                "userdata":{"default_format":"t","validation_message":"Required Field"}
            },
            // {"type":"calendar","name":"udt_name","label":"User Defined Table Name","validate":"NotEmptywithSpace","hidden":"false","disabled":"false","readonly":"false","value":"","userdata":{"application_field_id":88345,"default_format":"t","is_dependent":"0","validation_message":"Required Field "},"position":"label-top","offsetLeft":"15","labelWidth":"auto","inputWidth":"230","tooltip":"User Defined Table Name","required":"true","dateFormat":"%Y-%m-%d %H:%i","serverDateFormat":"%Y-%m-%d %H:%i","calendarPosition":"bottom","enableTime":"true"},
            {type: "button", value: "Ok", img: "tick.png"}
        ];
        var schedule_popup = new dhtmlXPopup({
            toolbar : workflow_alert.alert_menu,
            id : ["schedule"]
        });
        var schedule_form = schedule_popup.attachForm(schedule_form_data);
        schedule_form.setItemValue('schedule_date',current_date);
        schedule_form.attachEvent("onButtonClick", function(){
            var status = validate_form(schedule_form);
            if (!status) {
                show_messagebox('Enter date');
                return;
            }
            var schedule_date = schedule_form.getItemValue('schedule_date', true);
            var schedule_date_end = new Date(schedule_date.replace(' ','T'));
            schedule_date_end.setMinutes(schedule_date_end.getMinutes()+5);
            schedule_date_end = schedule_date_end.toISOString().slice(0, 19).replace('T', ' ');
            save_schedule(schedule_date,schedule_date_end);
        });

        schedule_popup.attachEvent("onBeforeHide", function(type, ev, id){
            if (type == 'click' || type == 'esc') {
                schedule_popup.hide();
                return true;
            }
        });
    }
    menu_click = function(id) {
        if (id == 'save') {
            save_alert_components();
        } else if (id == 'delete') {
            delete_alert_components();
        }
    }

    save_alert_components = function() {
        var context_obj = '#destination_content';

        var rule_xml = '';
        var table_xml = '';
        var condition_xml = '';
        var condition_detail_xml = '';
        var action_xml = '';
        var module_event_xml = '';
        var event_trigger_xml = '';
        var message_xml = '';
        var user_role_xml = '';
        var message_document_xml = '';
        var message_report_xml = '';
        var sql_statement_xml = '';

        var alert_rule_id = '';
        var alert_rule_name = '';
        var alert_rule_table_id = '';
        var alert_condition_id = '';
        var event_trigger_id = '';
        var alert_category = 's';

        var rule_flag = 0;
        var table_flag = 0;
        var condition_flag = 0;
        var action_flag = 0;
        var message_flag = 0;
        var empty_check = new Array();;
        var glb_module_id = w_module_id;
        var sql_statement_flag = 0;
        var sql_statement = '';

        //Workflow Information
        $('.object_42101', context_obj).each(function() {
            alert_category = 'w';
        });

        if (call_from == 'calendar')
            alert_category = 'w';

        //Rule/Alert Information
        $('.object_42102', context_obj).each(function() {
            rule_flag = 1;
            alert_rule_id = $('.txt_rule_id', this).val();
            alert_rule_name = $('.txt_rule_name', this).val();
            var rule_category = $('.cmb_notification_type', this).val();

            if (alert_rule_name == '') {
                empty_check.push('Rule Name');

            }

            rule_xml += '<Rule alert_sql_id="' + alert_rule_id
                + '" alert_sql_name="' + alert_rule_name
                + '" rule_category="' + rule_category
                + '" notification_type="757" alert_category="' + alert_category
                + '" alert_type="r" is_active="y" system_rule="n" workflow_only="n" />';
                
        });

        //Table Information
        $('.object_42103', context_obj).each(function() {
            table_flag = 1;
            alert_rule_table_id = $('.txt_alert_rule_table_id', this).val();
            var table_name = $('.cmb_table_name', this).val();
            var table_alias = $('.txt_table_alias', this).val();

            if (table_alias == '') {
                table_alis = 'df';
            }

            alert_condition_id = $('.txt_alert_condition_id', this).val();

            table_xml += '<Table alert_rule_table_id="' + alert_rule_table_id
                + '" table_id="' + table_name
                + '" table_alias="' + table_alias
                + '" alert_id="' + alert_rule_id + '" />';

            condition_xml += '<Condition alert_condition_id="' + alert_condition_id
                + '" rule_id="' + alert_rule_id
                + '" alert_condition_name="' + alert_rule_name + '" />';
        });

        var sequence_no = 1;
        //AND and OR Condition Information
        $('.object_42104,.object_42105,.object_42108', context_obj).each(function() {
            condition_flag = 1;
            var alert_where_clause_id = $('.txt_alert_where_clause_id', this).val();

            if (($(this).hasClass('object_42104')) == true) {
                var clause_type = 1;
            } else if (($(this).hasClass('object_42105')) == true) {
                var clause_type = 2 ;
            }

            if (($(this).hasClass('object_42104')) == true || ($(this).hasClass('object_42105')) == true) {
                var widget_type = $('.widget_type', this).val();
                var column_id = $('.cmb_columns', this).val();
                var operator_id = $('.cmb_operators', this).val();

                if (widget_type == 'DROPDOWN') {
                    var column_value = $('.cmb_values', this).val();
                } else {
                    var column_value = $('.txt_values', this).val();
                }
                if (operator_id == 8) {
                    if (widget_type == 'DROPDOWN') {
                        var column_value2 = $('.cmb_values2', this).val();
                    } else {
                        var column_value2 = $('.txt_values1', this).val();
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

            condition_detail_xml += '<ConditionDetail alert_table_where_clause_id="' + alert_where_clause_id
                + '" table_id="' + alert_rule_table_id
                + '" column_id="' + column_id
                + '" operator_id="' + operator_id
                + '" column_value="' + column_value
                + '" column_value2="' + column_value2
                + '" alert_id="' + alert_rule_id
                + '" condition_id="' + alert_condition_id
                + '" sequence_no="' + sequence_no
                + '" clause_type="' + clause_type + '" />';
            sequence_no++;
        });

        //Action Information
        $('.object_42106', context_obj).each(function() {
            action_flag = 1;
            var alert_action_id = $('.txt_alert_action_id', this).val();
            var column_id = $('.cmb_columns', this).val();
            var widget_type = $('.widget_type', this).val();

            if (widget_type == 'DROPDOWN') {
                var column_value = $('.cmb_values', this).val();
            } else {
                var column_value = $('.txt_values', this).val();
            }

            action_xml += '<Action alert_action_id="' + alert_action_id
                + '" table_id="' + alert_rule_table_id
                + '" column_id="' + column_id
                + '" column_value="' + column_value
                + '" alert_id="' + alert_rule_id
                + '" condition_id="' + alert_condition_id + '" />';
        });

        $('.object_42101', context_obj).each(function() {
            var module_event_id = $('.txt_module_event_id', this).val();
            event_trigger_id = $('.txt_event_trigger_id', this).val();
            var module_id = $('.cmb_modules', this).val();
            glb_module_id = module_id;
            var event_id = $('.cmb_events', this).val();

            var is_active = $('.chk_active', this).is(":checked");
            if (is_active == true) {
                is_active = 'y';
            } else {
                is_active = 'n';
            }

            module_event_xml += '<ModuleEvent module_event_id="' + module_event_id
                + '" modules_id="' + module_id
                + '" event_id="' + event_id
                + '" workflow_name="' + alert_rule_name
                + '" is_active ="' + is_active + '" />';
            event_trigger_xml += '<EventTrigger event_trigger_id="' + event_trigger_id
                + '" module_event_id="' + module_event_id
                + '" alert_id="' + alert_rule_id + '" />';
        });

        $('.object_42107', context_obj).each(function() {
            message_flag = 1;
            var workflow_message_id = $('.txt_workflow_message_id', this).val();
            var message = $('.txt_message', this).val();

            if (message == '') {
                empty_check.push(' Message');
            }

            var self_notify = $('.chk_self_notify', this).is(":checked");
            if (self_notify == true) {
                self_notify = 'n';
            } else {
                self_notify = 'y';
            }

            var context_obj =$(this).find('.message_privilege');
            var user_to_options = $('.user_to option', context_obj);
            var role_to_options = $('.role_to option', context_obj);
            var noti_type_arr = new Array();

            var chk_alert = $('.chk_alert', this).is(":checked");
            if (chk_alert == true)
                noti_type_arr.push(757);
            var chk_email = $('.chk_email', this).is(":checked");
            if (chk_email == true)
                noti_type_arr.push(750);
            var chk_message_board = $('.chk_message_board', this).is(":checked");
            if (chk_message_board == true)
                noti_type_arr.push(751);
            var noti_type = noti_type_arr.toString();

            message_xml += '<Message event_message_id="' + workflow_message_id
                + '" event_message_name="' + alert_rule_name
                + '" event_trigger_id="' + event_trigger_id
                + '" message_template_id="0" message="' + escapeXML(message)
                + '" self_notify="' + self_notify
                + '" notification_type="' + noti_type
                + '" mult_approval_required="n" comment_required="n" approval_action_required="n" trader_notify="n" />';

            $.map(user_to_options ,function(option) {
                user_role_xml += '<UserRole event_message_id="' + workflow_message_id
                    + '" user_login_id="' + option.value
                    + '" role_id="" />';
            });

            $.map(role_to_options ,function(option) {
                user_role_xml += '<UserRole event_message_id="' + workflow_message_id + '" user_login_id="" role_id="' + option.value + '" />';
            });

            var document_template_id = $('.cmb_document_type', this).val();
            var document_category = $('.cmb_document_category', this).val();
            document_category = (document_category == null ? '' : document_category);

            if (document_template_id != '' && document_template_id != null) {
                message_document_xml = '<MessageDocument event_message_id = "' + workflow_message_id
                    + '" document_template_id="' + document_template_id
                    + '" document_category="' + document_category + '" />';
            }

            var report_description = $('.txt_report_description', this).val();
            var report_prefix = $('.txt_report_prefix', this).val();
            var report_sufix = $('.txt_report_sufix', this).val();
            var report = $('.cmb_report', this).val();
            var report_writer = $('.cmb_report_writer', this).val();
            var file_option_type = $('.cmb_file_option_type', this).val();
            if ((report != '' && report_writer == 'y') || (report_description != '' && report_writer == 'n') || (report_writer == 'a' && report_description != '')) {
                message_report_xml = '<MessageReport event_message_id = "' + workflow_message_id
                    + '" report_description="' + report_description
                    + '" report_prefix="' + report_prefix
                    + '" report_sufix="' + report_sufix
                    + '" report_writer="' + report_writer
                    + '" report_paramset="' + report 
                    + '" file_option_type="' + file_option_type
                    + '" />';
            }

        });

        $('.object_42109', context_obj).each(function() {
            sql_statement_flag = 1;
            var alert_sql_id = alert_rule_id;
            sql_statement = $('.txt_sql_statement', this).val().trim();
            sql_statement = unescape(sql_statement.replace(/'/g,"''"));
            if (!sql_statement || sql_statement == '' || sql_statement == null) {
                empty_check.push('SQL Statement');
            }
            sql_statement_xml += '<SqlStatement alert_sql_id="' + alert_sql_id
                + '" alert_sql_statement="' + sql_statement
                + '" />';
        });

        if (call_from == 'calendar') {
            module_event_xml += '<ModuleEvent module_event_id="" modules_id="20610" event_id="20535" workflow_name="' + alert_rule_name + '" />';
            event_trigger_xml += '<EventTrigger event_trigger_id="' + event_trigger_id + '" module_event_id="" alert_id="' + alert_rule_id + '" />';
        }

        var save_xml = '<Root>' + rule_xml + table_xml + condition_xml + condition_detail_xml + action_xml + module_event_xml + event_trigger_xml + message_xml + user_role_xml + message_document_xml + message_report_xml + sql_statement_xml + '</Root>';

        if (rule_flag == 0) {
            show_messagebox('Rule is not defined.');
            return;
        }

        if (alert_category == 's' && message_flag == 1) {
            show_messagebox('Event Trigger is not defined');
            return;
        }

        if (empty_check.length > 0) {
            show_messagebox(empty_check.toString() + ' cannot be blank.');
            return;
        }

        if (sql_statement_flag == 1) {
            data = {"action": "spa_alert_sql",
                "flag": "x",
                "tsql": sql_statement
            };
            adiha_post_data("return_array", data, "", "", function(result){
                if (result[0][0] == 'Success') {
                    data = {"action": "spa_workflow_schedule",
                        "flag": "i",
                        "xml": save_xml,
                        "module_id": glb_module_id
                    };

                    var result_array = adiha_post_data('alert', data, '', '', 'save_alert_components_callback');
                } else {
                    show_messagebox(result[0][4]);
                }
            });
        } else {
            data = {"action": "spa_workflow_schedule",
                "flag": "i",
                "xml": save_xml,
                "module_id": glb_module_id
            };
            var result_array = adiha_post_data('alert', data, '', '', 'save_alert_components_callback');
        }
    }

    save_alert_components_callback = function(result) {
        var glb_alert_id = '<?php echo $alert_id; ?>';
        if (result[0].errorcode == 'Success') {
            var alert_id = result[0].recommendation;
            if (call_from == 'alert') {
                // parent.setup_alert.reload_rule_alert(alert_id);
                parent.setup_alert.post_callback(result);
            } else if (call_from == 'workflow' && glb_alert_id == '') {
                parent.gantt_task_rule_save(module_event_id, alert_id,event_trigger_id, parent_id, 'n','n','n','','');
            } else if (call_from == 'calendar') {
                workflow_alert.alert_menu.setItemDisabled('save');
                setTimeout(function(){
                    parent.win.close();
                },300);
            }
        }
    }

    delete_alert_components = function() {
        if($('input[name="rdo_template_datatype"]:checked').val() == undefined) {
            show_messagebox('Please select the components to delete');
            return;
        }
        $('input[name="rdo_template_datatype"]:checked').parent('div').parent('li').remove();
    }


    load_init_alert_components = function() {
        var event_obj = $('.object_42101', '#source_content').clone();
        $('.category ul', '#destination_content').append(event_obj);
        var rule_obj = $('.object_42102', '#source_content').clone();
        $('.category ul', '#destination_content').append(rule_obj);
        if (call_from == 'alert') {
            var and_condition_obj = $('.object_42104', '#source_content').clone();
            $('.category ul', '#destination_content').append(and_condition_obj);
        }
        var message_obj = $('.object_42107', '#source_content').clone();
        $('.category ul', '#destination_content').append(message_obj);
        /*Using placeholder property in texarea field was causing issue*/
        $('.txt_message', '#destination_content').attr("placeholder", "Message");
        var module_obj = $('.cmb_modules', '#destination_content');
        if (call_from != 'workflow') {
            modules_onchange(module_obj);
            report_writer_onchange(message_obj);
        }

    }

    load_alert_components = function(alert_id) {
        data = {
            "action": "spa_workflow_schedule",
            "flag":"h",
            "alert_sql_id": alert_id
        };
        adiha_post_data("return_array", data, "", "", "load_alert_components_callback");
    }

    load_alert_components_callback = function(return_value) {
        var msg_obj;
        var has_modules_obj = 0;
        var table_obj;
        for(cnt = 0; cnt < return_value.length; cnt++) {
            var c_obj = $('.object_' + return_value[cnt][0], '#source_content').clone();
            $('.category ul', '#destination_content').append(c_obj);

            if (return_value[cnt][0] == 42101) {
                $('.txt_module_event_id', c_obj).val(return_value[cnt][1]);
                $('.txt_event_trigger_id', c_obj).val(return_value[cnt][2]);
                $('.cmb_modules', c_obj).val(return_value[cnt][3]);
                $('.hdn_cmb_events', c_obj).val(return_value[cnt][4]);
                $('.cmb_events', c_obj).val(return_value[cnt][4]);
                if (return_value[cnt][5] == 'y') {
                    $('.chk_active', c_obj).prop("checked",true);
                } else {
                    $('.chk_active', c_obj).prop("checked",false);
                }
                $('.me_radio', c_obj).hide();
                $('.checkoption', c_obj).addClass('no_radio_content');
                modules_obj = $('.cmb_modules', c_obj);
                has_modules_obj = 1;
                if (return_value[cnt][1] == 20610) {
                    workflow_alert.alert_menu.showItem('schedule');
                } else {
                    workflow_alert.alert_menu.hideItem('schedule');
                }
            } else if (return_value[cnt][0] == 42102) {
                $('.txt_rule_id', c_obj).val(return_value[cnt][1]);
                $('.txt_rule_name', c_obj).val(return_value[cnt][2]);
                $('.cmb_notification_type', c_obj).val(return_value[cnt][3]);
            } else if (return_value[cnt][0] == 42103) {
                $('.txt_alert_rule_table_id', c_obj).val(return_value[cnt][1]);
                $('.hdn_cmb_table_name', c_obj).val(return_value[cnt][2]);
                $('.cmb_table_name', c_obj).val(return_value[cnt][2]);
                $('.txt_table_alias', c_obj).val(return_value[cnt][3]);
                $('.txt_alert_condition_id', c_obj).val(return_value[cnt][4]);
                table_obj = $('.cmb_table_name', c_obj);
            } else if (return_value[cnt][0] == 42104 || return_value[cnt][0] == 42105) {
                $('.txt_alert_where_clause_id', c_obj).val(return_value[cnt][1]);
                $('.hdn_cmb_columns', c_obj).val(return_value[cnt][2]);
                $('.cmb_operators', c_obj).val(return_value[cnt][3]);
                $('.txt_values', c_obj).val(return_value[cnt][4]);
                $('.cmd_values', c_obj).val(return_value[cnt][4]);

                if (return_value[cnt][3] == 8) {
                    $('.txt_values1', c_obj).val(return_value[cnt][5]);
                    $('.cmd_values1', c_obj).val(return_value[cnt][5]);
                } else if (return_value[cnt][3] > 13) {
                    $('.txt_values2', c_obj).val(return_value[cnt][5]);
                }

                var obj = $('.hdn_cmb_columns', c_obj);
                columns_onchange(obj, 0);
            } else if (return_value[cnt][0] == 42106) {
                $('.txt_alert_action_id', c_obj).val(return_value[cnt][1]);
                $('.hdn_cmb_columns', c_obj).val(return_value[cnt][2]);
                $('.txt_values', c_obj).val(return_value[cnt][3]);
                $('.cmd_values', c_obj).val(return_value[cnt][3]);
                var obj = $('.hdn_cmb_columns', c_obj);
                columns_onchange(obj, 1);
            } else if (return_value[cnt][0] == 42107) {
                $('.txt_workflow_message_id', c_obj).val(return_value[cnt][1]);
                $('.txt_message', c_obj).val(return_value[cnt][2]);
                if (return_value[cnt][3] == 'n') {
                    $('.chk_self_notify', c_obj).prop("checked",true);
                } else {
                    $('.chk_self_notify', c_obj).prop("checked",false);
                }

                if (return_value[cnt][4] && return_value[cnt][4] != '') {
                    var user_login_arr = return_value[cnt][4].split(',');
                } else {
                    var user_login_arr = new Array();
                }

                if (return_value[cnt][5] && return_value[cnt][5] != '') {
                    var role_arr = return_value[cnt][5].split(',');
                } else {
                    var role_arr = new Array();
                }

                var user_from_options = $('.user_from option', c_obj);
                var role_from_options = $('.role_from option', c_obj);

                var user_from = '';
                $.map(user_from_options ,function(option) {
                    if (jQuery.inArray(option.value, user_login_arr) > -1) {
                        user_from += '<option value="' + option.value + '">' + option.text + '</option>';
                        $('.user_from option[value="' + option.value + '"]', c_obj).remove();
                    }
                });
                $('.user_to', c_obj).append(user_from);

                var role_from = '';
                $.map(role_from_options ,function(option) {
                    if (jQuery.inArray(option.value, role_arr) > -1) {
                        role_from += '<option value="' + option.value + '">' + option.text + '</option>';
                        $('.role_from option[value="' + option.value + '"]', c_obj).remove();
                    }
                });
                $('.role_to', c_obj).append(role_from);

                var noti_type = return_value[cnt][6];
                var noti_type_arr = noti_type.split(',');

                for (n_cnt = 0; n_cnt < noti_type_arr.length; n_cnt++) {
                    if (noti_type_arr[n_cnt] == 757) {
                        $('.chk_alert', c_obj).prop("checked",true);
                    } else if (noti_type_arr[n_cnt] == 750) {
                        $('.chk_email', c_obj).prop("checked",true);
                    } else if (noti_type_arr[n_cnt] == 751) {
                        $('.chk_message_board', c_obj).prop("checked",true);
                    }
                }

                msg_obj = c_obj;
                add_context_zone();
            } else if (return_value[cnt][0] == 42108) {
                $('.txt_alert_where_clause_id', c_obj).val(return_value[cnt][1]);
                $('.cmb_clause_type', c_obj).val(return_value[cnt][2]);
            }  else if (return_value[cnt][0] == 42199) {
                $('.cmb_document_type', msg_obj).val(return_value[cnt][1]);
                $('.hdn_cmb_document_category', msg_obj).val(return_value[cnt][2]);
                $('.cmb_report', msg_obj).val(return_value[cnt][3]);
                $('.txt_report_description', msg_obj).val(return_value[cnt][4]);
                var prefix_sufix_arr = return_value[cnt][5].split('||');
                $('.txt_report_prefix', msg_obj).val(prefix_sufix_arr[0]);
                $('.txt_report_sufix', msg_obj).val(prefix_sufix_arr[1]);
                $('.cmb_report_writer', msg_obj).val(return_value[cnt][6]);
                $('.cmb_file_option_type', msg_obj).val(return_value[cnt][7]);
                var obj = $('.cmb_document_type', msg_obj);
                document_type_onchange(obj);
                report_writer_onchange(obj);

            } else if (return_value[cnt][0] == 42109) {
                $('.txt_alert_sql_id', c_obj).val(return_value[cnt][1]);
                $('.txt_sql_statement', c_obj).val(return_value[cnt][2]);
            }
        }
        if (has_modules_obj == 1) {
            modules_onchange(modules_obj);
        }
        table_object_onchange(table_obj);
    }

    modules_onchange = function(obj) {
        var module_id = $(obj).val();
        data = {
            "action": "spa_setup_rule_workflow",
            "flag": "3",
            "module_id": module_id,
            "call_from" : "simple_alert"
        };
        adiha_post_data("return_array", data, "", "", "reload_events");

        data = {
            "action": "spa_setup_rule_workflow",
            "flag": "6",
            "module_id": module_id
        };
        adiha_post_data("return_array", data, "", "", "reload_rule_table");
        var parent_obj = $(this).parent();
        $('.cmb_notification_type', '#destination_content').val(module_id);
        add_context_zone();
        if (module_id == 20610) {
            workflow_alert.alert_menu.showItem('schedule');
        } else {
            workflow_alert.alert_menu.hideItem('schedule');
        }
    }

    reload_events = function(return_value) {
        $('.cmb_events').empty();
        var option_string = '';
        for(cnt = 0; cnt < return_value.length; cnt++) {
            option_string = option_string + '<option value="' + return_value[cnt][0] + '">' + return_value[cnt][1] + '</option>';
        }

        $('.cmb_events').append(option_string);

        $('.cmb_events', '#destination_content').each(function() {
            var parent_obj = $(this).parent();
            var cmb_val = $('.hdn_cmb_events', parent_obj).val();
            if (cmb_val != '') {
                $('.cmb_events', parent_obj).val(cmb_val);
            }
        })
    }

    reload_rule_table = function(return_value) {
        $('.cmb_table_name').empty();
        var option_string = "<option value=''></option>";
        for(cnt = 0; cnt < return_value.length; cnt++) {
            option_string = option_string + '<option value="' + return_value[cnt][0] + '">' + return_value[cnt][1] + '</option>';
        }

        $('.cmb_table_name').append(option_string);

        $('.cmb_table_name', '#destination_content').each(function() {
            var parent_obj = $(this).parent();
            var cmb_val = $('.hdn_cmb_table_name', parent_obj).val();
            if (cmb_val != '') {
                $('.cmb_table_name', parent_obj).val(cmb_val);
            }
        })
        var t_obj = $('.cmb_table_name', '#destination_content');
        table_object_onchange(t_obj);
    }

    add_context_zone = function() {
        var module_event_id = $('.category ul', '#destination_content').find('.cmb_modules').val();
        data = {
            "action": "spa_setup_rule_workflow",
            "flag": "7",
            "module_id": module_event_id
        };
        adiha_post_data("return_json", data, "", "", function(return_json){
            return_json = JSON.parse(return_json);
            tag_options = return_json[0].tag_options;
            var tag_zones = {};
            var message_textarea_obj =  $("#destination_content").find(".txt_message");
            if (message_textarea_obj.length == 0) // If message box not present
                return;
            message_textarea_obj.attr('id', 'context_message');
            message_context_menu = new dhtmlXMenuObject();
            message_context_menu.renderAsContextMenu();
            message_context_menu.removeContextZone('context_message');
            message_context_menu.attachEvent("onBeforeContextMenu", function(zoneId){
                var tag_menu_items = JSON.parse(tag_options);
                message_context_menu.clearAll();
                if (tag_menu_items) {
                    for (var q=0; q<tag_menu_items['message'].length; q++) {
                        var tag_id = tag_menu_items['message'][q].id;
                        message_context_menu.addNewChild(message_context_menu.topId, q, tag_menu_items['message'][q].id, tag_menu_items['message'][q].text, false, tag_menu_items['message'][q].icon);
                        message_context_menu.setUserData(tag_menu_items['message'][q].id, 'tag_structure', tag_menu_items['message'][q].tag_structure);
                        tag_zones[tag_id] = tag_menu_items['message'][q].tag_structure;
                    }
                    return true;
                } else {
                    return false;
                }

            });
            message_context_menu.addContextZone('context_message');

            message_context_menu.attachEvent("onClick", function(id, zoneId){
                var workflow_message_tag = message_context_menu.getUserData(id, "tag_structure");
                message_textarea_obj.insert_at_caret(workflow_message_tag);
            });

        });
    }

    $.fn.extend({
        insert_at_caret: function(myValue) {
            this.each(function() {
                if (document.selection) {
                    this.focus();
                    var sel = document.selection.createRange();
                    sel.text = myValue;
                    this.focus();
                } else if (this.selectionStart || this.selectionStart == '0') {
                    var startPos = this.selectionStart;
                    var endPos = this.selectionEnd;
                    var scrollTop = this.scrollTop;
                    this.value = this.value.substring(0, startPos) +
                        myValue + this.value.substring(endPos,this.value.length);
                    this.focus();
                    this.selectionStart = startPos + myValue.length;
                    this.selectionEnd = startPos + myValue.length;
                    this.scrollTop = scrollTop;
                } else {
                    this.value += myValue;
                    this.focus();
                }
            });
            return this;
        }
    });

    function save_schedule(schedule_date,schedule_date_end) {
        var calendar_event_id = new Date().valueOf();
        var name = $('.txt_rule_name', '#destination_content').val();
        var description = $(".cmb_events option:selected", '#destination_content').text();
        var workflow_id = $('.txt_module_event_id', '#destination_content').val();
        if (!workflow_id || workflow_id == '' || workflow_id == null) {
            show_messagebox('Alert has not been saved.');
            return;
        }
        var alert_id = 0;
        var include_holiday = 'n';
        var reminder = -1;
        var rec_type = '';
        var start_date = schedule_date;
        var end_date = schedule_date_end;
        var event_parent_id = '0';
        var event_length = '300';
        confirm_messagebox("Are you sure you want to schedule the event?", function() {
            var xml = '<Root calendar_event_id="' + calendar_event_id + '" name="' + name + '" description="' + description +
                '" workflow_id="' +  workflow_id + '" alert_id="' + alert_id + '" include_holiday="' + include_holiday + '" reminder="' + reminder +
                '" rec_type="' + rec_type + '" start_date="' + start_date + '" end_date="' + end_date +
                '" event_parent_id="' +  event_parent_id + '" event_length="' + event_length + '"></Root>';
            var data = {
                "action": "spa_calendar",
                "flag": 'i',
                "xml": xml
            };
            adiha_post_data('alert', data, '', '', '', '');
        });
    }



</script>