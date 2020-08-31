<?php
/**
* Regulatory submission screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<?php
$report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
$create_date_from = get_sanitized_value($_POST['create_date_from'] ?? 'NULL');
$create_date_to = get_sanitized_value($_POST['create_date_to'] ?? 'NULL');

$php_script_loc = $app_php_script_loc;
$app_user_loc = $app_user_name;
$form_namespace = 'remit_submission';
$function_id = 10164500;
$rights_remit_file_edit = 10164510;
$rights_remit_file_delete = 10164511;
$rights_remit_file_submit = 10164512;

$module_type = '';
list($default_as_of_date_to, $default_as_of_date_from) = getDefaultAsOfDate($module_type);

list (
    $has_rights_remit_file_edit,
    $has_rights_remit_file_delete,
    $has_rights_remit_file_submit
    ) = build_security_rights (
    $rights_remit_file_edit,
    $rights_remit_file_delete,
    $rights_remit_file_submit
);

$layout_json = '[
                        {id: "a", text: "Apply Filter", collapse: true, height: 100},
                        {id: "b", text: "", collapse: false}
                    ]';

$layout_obj = new AdihaLayout();
echo $layout_obj->init_layout('remit_layout', '', '2E', $layout_json, $form_namespace);

$form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10164500', @template_name='RemitSubmission'";
$form_data = readXMLURL($form_sql);
$tab_json = $form_data[0][1] . ',' . $form_data[1][1];
$general_form_json = $form_data[0][2];
$view_form_json = $form_data[1][2];

echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var force_process = 0;
    var has_rights_remit_file_edit = Boolean (<?php echo $has_rights_remit_file_edit ?>);
    var has_rights_remit_file_delete = Boolean (<?php echo $has_rights_remit_file_delete ?>);
    var has_rights_remit_file_submit = Boolean (<?php echo $has_rights_remit_file_submit ?>);
    var date_format = '<?php echo $date_format; ?>';
    var theme_selected = '<?php echo isset($_SESSION['dhtmlx_theme']) ? 'dhtmlx_'.$_SESSION['dhtmlx_theme'] : 'dhtmlx_default'; ?>';
    var php_script_loc = '<?php echo $app_php_script_loc; ?>';

    $(function() {
        load_tabs();

        var function_id  = 10164500;
        var filter_obj = remit_submission.remit_layout.cells("a").attachForm();

        var layout_a_obj = remit_submission.remit_layout.cells("b");
        load_form_filter(filter_obj, layout_a_obj, function_id, 2);
    });

    function after_load_tabs() {
        var cell_c = remit_submission.remit_layout.cells('b');
        var submission_type_obj = general_tab_form.getCombo('submission_type');

        general_tab_form.setItemValue('level', '');
        general_tab_form.setItemValue('action_type', '');

        general_tab_form.setItemValue('level_mifid', '');
        general_tab_form.setItemValue('action_type_mifid', '');
        general_tab_form.setItemValue('deal_date_from', '');
        general_tab_form.setItemValue('deal_date_to', '');
        general_tab_form.setItemValue('valuation_date', '');

        submission_type_obj.attachEvent('onChange', function(id) {
            if (id == 44701) { //ICE Trade Vault
                general_tab_form.disableItem('action_type');
                general_tab_form.disableItem('level');
                general_tab_form.disableItem('level_mifid');
                general_tab_form.disableItem('action_type_mifid');
                general_tab_form.disableItem('report_type');
                general_tab_form.disableItem('action_type_error');
                general_tab_form.disableItem('generate_uti');
                general_tab_form.setItemValue('generate_uti', false);
                general_tab_form.hideItem('valuation_date');
                general_tab_form.setItemValue('valuation_date', '');
                general_tab_form.disableItem('include_bfi');
                general_tab_form.setItemValue('include_bfi', false);
                general_tab_form.setItemValue('level', '');
                general_tab_form.setItemValue('action_type', '');
                general_tab_form.setItemValue('level_mifid', '');
                general_tab_form.setItemValue('action_type_mifid', '');
                general_tab_form.setItemValue('valuation_date', '');
            } else if (id == 44702) { //Remit
                general_tab_form.disableItem('action_type');
                general_tab_form.disableItem('level');
                general_tab_form.disableItem('level_mifid');
                general_tab_form.disableItem('action_type_mifid');
                general_tab_form.enableItem('report_type');
                general_tab_form.enableItem('action_type_error');
                general_tab_form.enableItem('generate_uti');
                general_tab_form.setItemValue('generate_uti', true);
                general_tab_form.hideItem('valuation_date');
                general_tab_form.setItemValue('valuation_date', '');
                general_tab_form.disableItem('include_bfi');
                general_tab_form.setItemValue('include_bfi', false);
                general_tab_form.setItemValue('level', '');
                general_tab_form.setItemValue('action_type', '');
                general_tab_form.setItemValue('level_mifid', '');
                general_tab_form.setItemValue('action_type_mifid', '');
                general_tab_form.setItemValue('valuation_date', '');
            } else if (id == 44703) { //EMIR
                general_tab_form.enableItem('action_type');
                general_tab_form.enableItem('level');
                general_tab_form.disableItem('report_type');
                general_tab_form.disableItem('action_type_error');
                general_tab_form.disableItem('generate_uti');
                general_tab_form.disableItem('action_type_mifid');
                general_tab_form.disableItem('level_mifid');
                general_tab_form.setItemValue('action_type_error', false);
                general_tab_form.setItemValue('generate_uti', false);
                general_tab_form.getCombo('action_type').setComboValue('N');
                general_tab_form.getCombo('level').setComboValue('P');
                general_tab_form.disableItem('include_bfi');
                general_tab_form.setItemValue('include_bfi', false);
                general_tab_form.setItemValue('level', 'P');
                general_tab_form.setItemValue('action_type', 'NEWT');
                general_tab_form.setItemValue('level_mifid', '');
                general_tab_form.setItemValue('action_type_mifid', '');
                general_tab_form.setItemValue('valuation_date', '');
            } else if (id == 44704) { //MiFID II
                general_tab_form.disableItem('action_type');
                general_tab_form.disableItem('level');
                general_tab_form.enableItem('action_type_mifid');
                general_tab_form.enableItem('level_mifid');
                general_tab_form.disableItem('report_type');
                general_tab_form.disableItem('action_type_error');
                general_tab_form.disableItem('generate_uti');
                general_tab_form.setItemValue('action_type_error', false);
                general_tab_form.setItemValue('generate_uti', false);
                general_tab_form.getCombo('level_mifid').setComboValue('X');
                general_tab_form.getCombo('action_type_mifid').setComboValue('');
                general_tab_form.hideItem('valuation_date');
                general_tab_form.disableItem('include_bfi');
                general_tab_form.setItemValue('include_bfi', false);
                general_tab_form.setItemValue('level', '');
                general_tab_form.setItemValue('action_type', '');
                general_tab_form.setItemValue('level_mifid', 'T');
                general_tab_form.setItemValue('action_type_mifid', 'NEWT');
                general_tab_form.setItemValue('valuation_date', '');
            } else if (id == 44705) { //ECM
                general_tab_form.disableItem('action_type');
                general_tab_form.disableItem('level');
                general_tab_form.disableItem('level_mifid');
                general_tab_form.disableItem('action_type_mifid');
                general_tab_form.enableItem('report_type');
                general_tab_form.disableItem('report_type');
                general_tab_form.disableItem('action_type_error');
                general_tab_form.disableItem('generate_uti');
                general_tab_form.setItemValue('generate_uti', false);
                general_tab_form.hideItem('valuation_date');
                general_tab_form.enableItem('include_bfi');
                general_tab_form.setItemValue('include_bfi', true);
                general_tab_form.setItemValue('level', '');
                general_tab_form.setItemValue('action_type', '');
                general_tab_form.setItemValue('level_mifid', '');
                general_tab_form.setItemValue('action_type_mifid', '');
                general_tab_form.setItemValue('valuation_date', '');
            }
        });

        var report_type_obj = general_tab_form.getCombo('report_type');
        var report_type_c = general_tab_form.getItemValue('report_type');

        var vw_submission_type_obj = view_tab_form.getCombo('view_submission_type');

        vw_submission_type_obj.attachEvent('onChange', function(id){
            if (id != 44702) {
                view_tab_form.disableItem('view_report_type');
            } else {
                view_tab_form.enableItem('view_report_type');
            }

            if (id == 44704) {
                view_tab_form.enableItem('level_mifid_view');
            } else {
                view_tab_form.disableItem('level_mifid_view');
            }

            if (id == 44703) {
                view_tab_form.enableItem('level_view');
            } else {
                view_tab_form.disableItem('level_view');
            }
        });

        var mifid_action_type_obj = general_tab_form.getCombo('action_type_mifid');
        mifid_action_type_obj.deleteOption('MDFY');

        var level_mifid_obj = general_tab_form.getCombo('level_mifid');
        level_mifid_obj.attachEvent('onChange', function(id) {
            mifid_action_type_obj.setComboValue('');

            if (id == 'T') {
                mifid_action_type_obj.addOption([['MDFY','Modify']]);
            } else {
                mifid_action_type_obj.deleteOption('MDFY');
            }
        });

        var level_obj = general_tab_form.getCombo('level');

        level_obj.attachEvent('onChange', function(id) {
            if (id == 'M') {
                general_tab_form.showItem('valuation_date');
            } else {
                general_tab_form.hideItem('valuation_date');
                general_tab_form.setItemValue('valuation_date', '');
            }
        });
        attach_browse_event('general_tab_form',10164500,'','','');
    }

    function load_tabs() {
        tab_object = remit_submission.remit_layout.cells('b').attachTabbar();
        tab_object.addTab("general", "General", null, null, true, false);
        tab_object.addTab("view", "View", null, null, false, false);

        general_tab = tab_object.cells("general");
        general_tab_layout = general_tab.attachLayout({
            pattern : '2E',
            cells : [
                {id: "a", text: "", header: false, height: 10},
                {id: "b", text: "General", header: false}
            ]
        });

        generate_menu_json = [{id:"generate", text:"Generate", img:"run.gif", imgdis:"run_dis.gif", title:"Generate"}];

        generate_menu = general_tab_layout.cells("a").attachMenu({
            icons_path : js_image_path + "dhxmenu_web/",
            json : generate_menu_json
        });

        var general_tab_form_json = <?php echo $general_form_json;?>;
        general_tab_form = general_tab_layout.cells("b").attachForm(general_tab_form_json);

        view_tab = tab_object.cells("view");
        view_tab_layout = view_tab.attachLayout({
            pattern : '2E',
            cells : [
                {id: "a", text: "View Filter", header: false, height: 150},
                {id: "b", text:"Report Summary", header: true, undock:true}
            ]
        });

        var view_tab_form_json = <?php echo $view_form_json;?>;
        view_tab_form = view_tab_layout.cells("a").attachForm(view_tab_form_json);

        remit_menu = view_tab_layout.cells('b').attachMenu({
            icons_path: js_image_path + "dhxmenu_web/"
        });

        remit_menu.loadStruct([
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
            {id:"edit", text:"Edit", img:"edit.gif", items:[
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", title: "Delete", disabled:true}
                ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"t21", text:"Summary", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                        ]},
                    {id:"t22", text:"Detail", items:[
                            {id:"excel_detail", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"xml_detail", text:"XML", img:"xml.gif", imgdis:"xml_dis.gif", title: "XML"}
                        ]}
                ]},
            {id:"process", text:"Process", img:"action.gif", items:[
                    {id:"submit", text:"Submit", img:"save.gif", imgdis:"save_dis.gif", title: "Submit", disabled:true}
                ]}
        ]);

        remit_menu.attachEvent('onClick', remit_submission.remit_menu_click);

        SourceRemitSummary = view_tab_layout.cells('b').attachGrid();
        view_tab_layout.cells('b').attachStatusBar({height : 30, text : '<div id="pagingArea_c"></div>' });
        SourceRemitSummary.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + js_dhtmlx_theme + "/imgs/dhxgrid_web/");
        SourceRemitSummary.setHeader('Create Date From,Create Date To,Report Type,User,Generate TS,Status,Process ID, Report Type ID', ["text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;"]);
        SourceRemitSummary.setColAlign('left,left,left,left,left,left,left');
        SourceRemitSummary.setColumnIds("Create_date_from,create_date_to,report_type,user,create_time,status,process_id,report_type_id".replace(/, */g , ","));
        SourceRemitSummary.setColTypes("ro,ro,ro,ro,ro,ro,ro,ro,ro".replace(/, */g , ","));
        SourceRemitSummary.setInitWidths('160,160,160,160,160,160,400,160');
        SourceRemitSummary.setColSorting('str,str,str,str,str,str,str,str');
        SourceRemitSummary.setDateFormat(date_format,'%Y-%m-%d');
        SourceRemitSummary.enableColumnAutoSize(true);
        SourceRemitSummary.attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
        SourceRemitSummary.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        SourceRemitSummary.enablePaging(true, 50, 0, 'pagingArea_c');
        SourceRemitSummary.setPagingSkin('toolbar');
        SourceRemitSummary.enableColumnMove(true);
        SourceRemitSummary.enableMultiselect(true);
        SourceRemitSummary.init();
        SourceRemitSummary.setColumnsVisibility('false,false,false,false,false,false,false,true');
        SourceRemitSummary.enableHeaderMenu();
        SourceRemitSummary.attachEvent('onRowSelect', function() {
            remit_submission.summary_grid_click();
        });
        SourceRemitSummary.attachEvent('onSelectStateChanged', function() {
            remit_submission.summary_grid_state_change();
        });
        SourceRemitSummary.attachEvent('onRowDblClicked', function() {
            remit_submission.remit_menu_click('excel_detail');
        });

        generate_menu.attachEvent('onClick', function(arg){
            generate_report();
        });

        after_load_tabs();
    }

    function generate_report() {
        var form_data_gen_tab = general_tab_form.getFormData();
        var form_xml = '<Root><FormXML  ';

        var validate_return = validate_form(general_tab_form);

        if (validate_return === false) {
            return;
        }

        for (var a in form_data_gen_tab) {
            label = a;
            data = form_data_gen_tab[a];

            if (general_tab_form.getItemType(a) == 'calendar') {
                data = general_tab_form.getItemValue(a, true);
                ///data = (data == '') ? '' : dates.convert_to_sql(data);

                if (label == 'create_date_from')
                    var create_date_from = data;

                if (label == 'create_date_to')
                    var create_date_to = data;

                if (label == 'deal_date_from')
                    var deal_date_from = data;

                if (label == 'deal_date_to')
                    var deal_date_to = data;

                if (create_date_from > create_date_to) {
                    show_messagebox('Create Date From cannot be greater than Create Date To.');
                    return;
                }

                if (deal_date_from > deal_date_to) {
                    show_messagebox('Deal Date From cannot be greater than Deal Date To.');
                    return;
                }
            }

            form_xml += a + '="' + data + '" ';
        }

        form_xml += '></FormXML></Root>';

        var sp_url_param = {
            "flag": "GEN",
            "form_xml": form_xml,
            "action": "spa_regulatory_reporting"
        };

        adiha_post_data('return_array', sp_url_param, '', '', 'remit_submission.post_generate');
        general_tab_layout.cells("b").progressOn();
    }


    remit_submission.summary_grid_state_change = function() {
        var selected_row_id = SourceRemitSummary.getSelectedRowId();

        if (selected_row_id.indexOf(',') == 1) {
            remit_menu.setItemDisabled('submit');
        } else {
            remit_menu.setItemEnabled('submit');
        }
    }

    remit_submission.summary_grid_click = function() {
        var selected_row_id = SourceRemitSummary.getSelectedRowId();

        if (selected_row_id.indexOf(',') == 1) {
            remit_menu.setItemDisabled('submit');
            return;
        }

        var idx_status = SourceRemitSummary.getColIndexById('status');
        var status = SourceRemitSummary.cells(selected_row_id, idx_status).getValue();
        var submission_status = view_tab_form.getItemValue('view_status');

        if (has_rights_remit_file_submit && status == 'Outstanding') {
            remit_menu.setItemEnabled('delete');
        } else {
            remit_menu.setItemDisabled('delete');
        }

        if (has_rights_remit_file_submit && status == 'Outstanding') {
            remit_menu.setItemEnabled('submit');
        } else {
            remit_menu.setItemDisabled('submit');
        }

        if (selected_row_id == null || selected_row_id.indexOf(',') != -1) {
            remit_menu.setItemDisabled('excel_detail');
        } else {
            remit_menu.setItemEnabled('excel_detail');

            if (has_rights_remit_file_submit && status == 'Outstanding') {
                remit_menu.setItemEnabled('submit');
            } else {
                remit_menu.setItemDisabled('submit');
            }
        }
    }

    remit_submission.remit_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'refresh':
                remit_submission.refresh_grid();
                break;
            case 'excel':
                var path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                SourceRemitSummary.toExcel(path);
                break;
            case 'excel_detail':
                var submission_type =  view_tab_form.getItemValue('view_submission_type');
                var level_mifid_view = view_tab_form.getItemValue('level_mifid_view');
                var level_emir_view = view_tab_form.getItemValue('level_view');
                var selected_row_id = SourceRemitSummary.getSelectedRowId();
                var col_create_time = SourceRemitSummary.getColIndexById('create_time');
                var create_time = SourceRemitSummary.cells(selected_row_id,col_create_time).getValue();
                var file_name = view_tab_form.getCombo('view_submission_type').getComboText();
                file_name +=  (submission_type == 44702)? ' ' +  view_tab_form.getCombo('view_report_type').getComboText() + ' ' :  ' ';
                file_name += create_time.replace(/:/g,'').replace(/[^\w\s]/gi, '_');
                file_name = file_name.replace(/\s/g,'_');
                export_detail_to_excel(submission_type, level_mifid_view, level_emir_view,file_name);
                break;
            case 'xml_detail':
                export_detail_to_xml();
                break;
            case 'pdf':
                var path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                SourceRemitSummary.toPDF(path);
                break;
            case 'delete':
                var idx_report_id = SourceRemitSummary.getColIndexById('report_id');
                var idx_process_id = SourceRemitSummary.getColIndexById('process_id');
                var selected_row_id = SourceRemitSummary.getSelectedRowId();
                var report_id = ''
                var process_id = '';
                var report_type = view_tab_form.getItemValue('view_report_type');;
                var selected_row_array_id = selected_row_id.split(',');

                for (var i = 0; i < selected_row_array_id.length; i++) {
                    if (i == 0) {
                        process_id = SourceRemitSummary.cells(selected_row_array_id[i],idx_process_id).getValue();
                    } else {
                        process_id = process_id + "','" + SourceRemitSummary.cells(selected_row_array_id[i], idx_process_id).getValue();
                    }
                }

                process_id = "'" + process_id + "'";
                var selected_ids = SourceRemitSummary.getColumnValues(0);
                var submission_type =  view_tab_form.getItemValue('view_submission_type');
                var level_mifid = view_tab_form.getItemValue('level_mifid_view');
                var level_emir_v = view_tab_form.getItemValue('level_view');

                if (submission_type == 44703 || submission_type == 44704) {
                    var data = {
                        "submission_type": submission_type,
                        "process_id": process_id,
                        "action": "spa_source_emir",
                        "level_mifid": level_mifid,
                        "level": level_emir_v,
                        "flag": "d"
                    };
                } else {
                    var data = {
                        "process_id": process_id,
                        "action": "spa_remit",
                        "flag": "d",
                        "submission_type": submission_type,
                        "report_type": report_type
                    };
                }

                adiha_post_data('confirm', data, '', '', 'remit_submission.delete_callback_refresh_grid');
                break;
            case 'submit':
                submit_regulatory_report();
                break;
        }
    }

    function submit_regulatory_report() {
        var selected_row_id = SourceRemitSummary.getSelectedRowId();
        var idx_process_id = SourceRemitSummary.getColIndexById('process_id');
        var process_id = SourceRemitSummary.cells(selected_row_id, idx_process_id).getValue();

        var level_emir_view = view_tab_form.getItemValue('level_view');
        var submission_type =  view_tab_form.getItemValue('view_submission_type');
        var level_mifid_view = view_tab_form.getItemValue('level_mifid_view');
        var mirror_reporting = (view_tab_form.isItemChecked('mirror_reporting') === true) ? 1 : 0;

        if (submission_type == 44701) {
            var exec_call = "EXEC spa_ice_trade_vault @flag='g', @process_id='" + process_id + "'";
            var title = 'Submit ICE Trade Vault'
            var param = 'gen_as_of_date=0&batch_type=r&default_export_format=.xml';
        } else if (submission_type == 44703 || submission_type == 44704) {
            var exec_call = "EXEC spa_source_emir @process_id='" + process_id + "', @flag='g', @submission_type=" + submission_type + ", @level_mifid='" + level_mifid_view + "', @level = '" + level_emir_view + "'";

            var param = 'gen_as_of_date=0&batch_type=r&default_export_format=.xml';

            if (submission_type == 44704 && level_mifid_view == 'X') {
                param = param + '&batch_type=r&xml_default_format=-100002';
            }

            var title = (submission_type == 44703) ? 'Submit EMIR Report' : 'Submit MiFID Report';
        } else {
            var report_type =  view_tab_form.getItemValue('view_report_type');
            report_type = (submission_type == 44705) ? 'NULL' : report_type;

            var exec_call = "EXEC spa_convert_xml NULL, NULL, NULL, NULL, NULL, NULL,'" + process_id + "'," + report_type + ",'" + mirror_reporting + "'";
            var param = 'gen_as_of_date=0&batch_type=remit';
            var title = (submission_type == 44702) ? 'Submit REMIT Report' : 'Submit ECM Report';
        }

        adiha_run_batch_process(exec_call, param, title);
    }

    remit_submission.refresh_grid = function() {
        var submission_status = view_tab_form.getItemValue('view_status');
        var create_date_from = view_tab_form.getItemValue('view_create_date_from', true);
        var create_date_to = view_tab_form.getItemValue('view_create_date_to', true);
        var report_type = view_tab_form.getItemValue('view_report_type');
        var level_mifid = view_tab_form.getItemValue('level_mifid_view');
        var level_view = view_tab_form.getItemValue('level_view');
        var submission_type =  view_tab_form.getItemValue('view_submission_type');
        report_type = (report_type =='') ? 'NULL' : report_type;

        if (create_date_from == 'NULL' || create_date_from == '' || create_date_from == 'null') {
            show_messagebox('Please select Create Date From.');
            return;
        }

        if (create_date_to == 'NULL' || create_date_to == '' || create_date_to == 'null') {
            show_messagebox('Please select Create Date To.');
            return;
        }

        if (create_date_from > create_date_to) {
            show_messagebox('Create Date From cannot be greater than Create Date To.');
            return;
        }

        if (submission_type == 44703 || submission_type == 44704) {
            var sp_url_param = {
                "create_date_from": create_date_from,
                "create_date_to": create_date_to,
                "status": submission_status,
                "flag": "s",
                "submission_type": submission_type,
                "level_mifid": level_mifid,
                "level": level_view,
                "action": "spa_source_emir"
            };
        } else {
            var sp_url_param = {
                "create_date_from": create_date_from,
                "create_date_to": create_date_to,
                "flag": "s",
                "report_type" : report_type,
                "submission_type": submission_type,
                "submission_status": submission_status,
                "action": "spa_remit"
            };
        }

        sp_url_param  = $.param(sp_url_param);

        SourceRemitSummary.clearAll();
        SourceRemitSummary.post(js_data_collector_url, sp_url_param, function(){
            SourceRemitSummary.filterByAll();
        });

        remit_menu.setItemDisabled('delete');
        remit_menu.setItemDisabled('submit');
    }

    remit_submission.post_generate = function(result) {
        force_process = 0;
        general_tab_layout.cells("b").progressOff();

        if (result[0][0] == 'Success' || result[0][5] == 'Success') {
            if (result[0][0] == 'Success') {
                dhtmlx.message(result[0][4]);
            } else if (result[0][5] == 'Success') {
                dhtmlx.alert({
                    title: 'Alert',
                    type: "alert",
                    text: result[0][4]
                });
            }
            var create_date_from = general_tab_form.getItemValue('create_date_from');
            view_tab_form.setItemValue('view_create_date_from', create_date_from);
            var create_date_to = general_tab_form.getItemValue('create_date_to');
            view_tab_form.setItemValue('view_create_date_to', create_date_to);
            var report_type = general_tab_form.getItemValue('report_type');
            view_tab_form.setItemValue('view_report_type', report_type);
            var submission_type = general_tab_form.getItemValue('submission_type');
            var action_type_mifid = general_tab_form.getItemValue('action_type_mifid');
            var level_mifid = general_tab_form.getItemValue('level_mifid');
            var level = general_tab_form.getItemValue('level');

            view_tab_form.setItemValue('view_submission_type', submission_type);
            view_tab_form.setItemValue('view_status', 39500);

            if (submission_type == 44704) {
                view_tab_form.setItemValue('level_mifid_view', level_mifid);
            }

            if (submission_type == 44703) {
                view_tab_form.setItemValue('level_view', level);
            }

            if (submission_type != 44702) {
                view_tab_form.disableItem('view_report_type');
            } else {
                view_tab_form.enableItem('view_report_type');
            }

            if ((action_type_mifid == 'CANC' && submission_type == 44704) || submission_type != 44704) {
                view_tab_form.disableItem('level_mifid_view');
            } else {
                view_tab_form.enableItem('level_mifid_view');
            }

            view_tab_form.enableItem('view_status');
            view_tab.setActive();
            remit_submission.refresh_grid();
        } else {
            if (result[0][5] == 'confirm') {
                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Proceed",
                    cancel: "Cancel",
                    text: result[0][4],
                    callback: function(result) {
                        if (result) {
                            force_process = 1;
                            remit_submission.remit_menu_click('generate');
                        } else {
                            force_process = 0;
                        }
                    }
                });
            } else {
                dhtmlx.alert({
                    title: 'Alert',
                    type: "alert",
                    text: result[0][4]
                });
            }
        }
    }

    remit_submission.delete_callback_refresh_grid = function() {
        remit_submission.refresh_grid();
    }

    function export_detail_to_excel(submission_type, level_mifid_view, level_emir_view,file_name) {
        var selected_row_id = SourceRemitSummary.getSelectedRowId();

        if (selected_row_id == null || selected_row_id.indexOf(',') != -1) {
            dhtmlx.alert({
                title: 'Alert',
                type: "alert",
                text: "Please select any one row from summary report grid."
            });
            return;
        }


        var idx_process_id = SourceRemitSummary.getColIndexById('process_id');
        var process_id = SourceRemitSummary.cells(selected_row_id,idx_process_id).getValue();
        var idx_report_type = SourceRemitSummary.getColIndexById('report_type_id')
        var report_type = SourceRemitSummary.cells(selected_row_id,idx_report_type).getValue();
        var mirror_reporting = (view_tab_form.isItemChecked('mirror_reporting') === true) ? 1 : 0;
        var title = '';

        if (submission_type == 44703) {
            if (level_emir_view == 'P' || level_emir_view == 'T') {
                title = 'Detail EMIR';

                var sp_url_param = {
                    "action": "spa_source_emir",
                    "process_id": process_id,
                    "filename": file_name,
                    "worksheet_title": title,
                    "flag": 'e'
                };
            } else if (level_emir_view == 'M') {
                title = 'Detail EMIR MTM';

                var sp_url_param = {
                    "action": "spa_source_emir",
                    "process_id": process_id,
                    "filename": file_name,
                    "worksheet_title": title,
                    "flag": 'm'
                };
            } else if (level_emir_view = 'C') {
                title = 'Detail EMIR Collateral';

                var sp_url_param = {
                    "action": "spa_source_emir",
                    "process_id": process_id,
                    "filename": file_name,
                    "worksheet_title": title,
                    "flag": 'c'
                };
            }
        } else if (submission_type == 44704 && level_mifid_view == 'X') {
            title = 'Detail MiFID Transaction';

            var sp_url_param = {
                "action": "spa_source_emir",
                "process_id": process_id,
                "filename": file_name,
                "worksheet_title": title,
                "flag": 'f'
            };
        } else if (submission_type == 44704 && level_mifid_view == 'T') {
            title = 'Detail MiFID Trade';

            var sp_url_param = {
                "action": "spa_source_emir",
                "process_id": process_id,
                "filename": file_name,
                "worksheet_title": title,
                "flag": 'h'
            };
        } else if (submission_type == 44701) {
            title = 'Detail Ice Trade Vault';

            var sp_url_param = {
                "action": "spa_ice_trade_vault",
                "process_id": process_id,
                "filename": file_name,
                "worksheet_title": title,
                "flag": 'd'
            };
        } else {
            title = 'Detail Remit';

            var sp_url_param = {
                "action": "spa_remit",
                "filename": file_name,
                "worksheet_title": title,
                "process_id": process_id,
                "report_type": report_type,
                "mirror_reporting": mirror_reporting
            };
        }

        sp_url_param  = $.param(sp_url_param);
        var url = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/export_sql_to_excel.php?' + sp_url_param;
        export_sql_to_excel(url);
    }

    function export_detail_to_xml() {
        var selected_row_id = SourceRemitSummary.getSelectedRowId();
        var idx_process_id = SourceRemitSummary.getColIndexById('process_id');
        var process_id = SourceRemitSummary.cells(selected_row_id,idx_process_id).getValue();
        var idx_report_type = SourceRemitSummary.getColIndexById('report_type_id')
        var report_type = SourceRemitSummary.cells(selected_row_id,idx_report_type).getValue();
        var mirror_reporting = (view_tab_form.isItemChecked('mirror_reporting') === true) ? 1 : 0;
        var intra_group = (view_tab_form.isItemChecked('intra_group') == 'y') ? 1 : 0;
        var submission_type =  view_tab_form.getItemValue('view_submission_type');
        var mifid_level = view_tab_form.getItemValue('level_mifid_view');
        var emir_level = view_tab_form.getItemValue('level_view');

        var sp_url_param = {
            "flag": "XML",
            "submission_type": submission_type,
            "report_type" : report_type,
            "mirror_reporting": mirror_reporting,
            "intragroup": intra_group,
            "process_id": process_id,
            "mifid_level": mifid_level,
            "emir_level": emir_level,
            "action": "spa_regulatory_reporting"
        };

        adiha_post_data('return_array', sp_url_param, '', '', 'remit_submission.export_detail_to_xml_post');
    }

    remit_submission.export_detail_to_xml_post = function (result) {
        if (result[0][0] != 'Error') {
            var file_path = "dev/shared_docs/temp_Note/" + result[0][5] + ".xml";
            fx_download_file(file_path);
            // window.open(file_path);
        } else {
            show_messagebox(result[0][4])
        }
    }

    function fx_download_file(file_path) {
        window.location = php_script_loc + '/force_download.php?path=' + file_path;
    }
</script>