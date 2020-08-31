<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <style type="text/css">
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            padding: 0px;
            background-color: #ebebeb;
            overflow: hidden;
        }

        div.simple_link {
            text-decoration: underline;
            color: blue;
        }
    </style>
</head>
<body>
<?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $deal_id = (isset($_REQUEST["deal_id"]) && $_REQUEST["deal_id"] != '') ? get_sanitized_value($_REQUEST["deal_id"]) : 'NULL';

    $sp_deal = "EXEC spa_deal_summary_report @flag='s', @deal_id=" . $deal_id;
    $form_data = readXMLURL2($sp_deal);

    $form_namespace = 'dealSummaryReport';

    $layout_json = '[{id: "a", header:false}]';
    $layout_obj = new AdihaLayout();
    $tab_obj = new AdihaTab();
    $form_obj = new AdihaForm();
    $deal_link = '<a style=\"margin-top:0px; display:block;\" href=\"#\" onclick=dealSummaryReport.open_link(\"deal\")>Deal ID</a>';
    $form_json = '[
                    {type: "settings", position: "label-top"},
                    {type: "block", blockOffset: 10, list:[
                        {type: "input", name: "deal_id", label: "' . $deal_link . '", value: "' . $form_data[0]['deal_id'] . '", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "auto"},
                        {type:"newcolumn"},
                        {type: "input", name: "ref_id", label: "REF ID", value: "' . $form_data[0]['ref_id'] . '", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "auto"},
                        {type:"newcolumn"},
                        {type: "input", name: "counterparty", label:"Counterparty", value: "' . $form_data[0]['counterparty'] . '", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "auto"},
                        {type:"newcolumn"},
                        {type: "input", name: "trader", label: "Trader", value: "' . $form_data[0]['trader'] . '", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "auto"},
                        {type:"newcolumn"},
                        {type: "input", name: "period", label: "Period", value: "' . $form_data[0]['period'] . '", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "auto"},
                        {type:"newcolumn"},
                        {type: "input", name: "deal_type", label: "Deal Type", value: "' . $form_data[0]['deal_type'] . '", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "auto"},
                    ]},
                    {type: "block", blockOffset: 10, offsetTop:80, list:[                        
                        {type: "template", name:"workflow", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "150", format:format_hyperlink},
                        {type:"newcolumn"},
                        {type: "template",  name:"document", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "150", format:format_hyperlink},
                        {type:"newcolumn"},
                        {type: "template", name:"audit", "offsetLeft": "20", "inputWidth": "150", "labelWidth": "150", format:format_hyperlink}
                    ]}
                ]';

    // init layout
    echo $layout_obj->init_layout('summary_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_tab_cell('summary_tabs', 'a', '');
    echo $tab_obj->init_by_attach('summary_tabs', $form_namespace);
    echo $tab_obj->add_tab('deal', 'Deal', 'null', 'null', 'true');
    echo $tab_obj->attach_form('deal_summary_form', 'deal');

    $form_obj->init_by_attach('deal_summary_form', $form_namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout();


?>

</body>
<script type="text/javascript">
    /**
     * [format_hyperlink Format hyperlink]
     * @param  {[type]} name  [name]
     * @param  {[type]} value [value of item]
     */
    format_hyperlink = function(name, value) {
        if (name == 'workflow') {
            return '<a style="margin-top:0px; display:block;" href="#" onclick=dealSummaryReport.open_link("workflow")>Workflow Report</a>';
        } else if (name == 'document') {
            return '<a style="margin-top:0px; display:block;" href="#" onclick=dealSummaryReport.open_link("document")>Document</a>';
        } else {
            return '<a style="margin-top:0px; display:block;" href="#" onclick=dealSummaryReport.open_link("audit")>Audit</a>';
        }
    }

    var deaL_summary_child_win;
    /**
     * [open_link Open links]
     * @param  {[type]} win_type [window type]
     */
    dealSummaryReport.open_link = function(win_type) {
        var deal_id = '<?php echo $deal_id; ?>';
        var deleted_checked = 'n';

        if (win_type == 'audit') {
            var exec_call = 'EXEC spa_Create_Deal_Audit_Report '
                            + singleQuote('c') + ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '
                            + singleQuote(deal_id) + ', NULL, NULL, '
                            + ' NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,' + singleQuote(deleted_checked);
            var sp_url = js_php_path + 'dev/spa_html.php?spa=' + exec_call + '&' + getAppUserName();
            openHTMLWindow(sp_url);
        } else {
            if (typeof(deaL_summary_child_win) === "undefined" || !deaL_summary_child_win) {
                deaL_summary_child_win = new dhtmlXWindows();
            } 

            var win_obj;

            if (deaL_summary_child_win.isWindow(win_type)) {
                if (deaL_summary_child_win.window(win_type).isParked()) {
                    deaL_summary_child_win._winButtonClick(win_type, "minmax");
                }
                win_obj = deaL_summary_child_win.window(win_type);        
                win_obj.bringToTop();

            } else {
                win_obj = deaL_summary_child_win.createWindow(win_type, 0, 300, 800, 600);   
                win_obj.centerOnScreen();
            }

            if (win_type == 'document') {
                var win_title = 'Deal Document - ' + deal_id;
                var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?notes_object_id=' + deal_id + '&notes_category=33&is_pop=true';
            } else if (win_type == 'deal') {
                var win_title = 'Deal Detail - ' + deal_id;
                var win_url = 'deal.detail.new.php?deal_id=' + deal_id + '&view_deleted=n';
            } else {
                var win_title = 'Deal Workflow Progress Report - ' + deal_id;
				var process_table_xml = 'source_deal_header_id:' + deal_id;
				var filter_string = 'Deal ID = <i>' + deal_id +  '</i>';
                var win_url = app_form_path + '_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + deal_id + '&source_column=source_deal_header_id&module_id=20601&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
            }

            win_obj.setText(win_title);
            win_obj.centerOnScreen();
            win_obj.maximize();
            win_obj.attachURL(win_url, false, {deal_id:deal_id});

            win_obj.attachEvent('onClose', function(w) {            
                return true;
            });
        }        
    }
</script>