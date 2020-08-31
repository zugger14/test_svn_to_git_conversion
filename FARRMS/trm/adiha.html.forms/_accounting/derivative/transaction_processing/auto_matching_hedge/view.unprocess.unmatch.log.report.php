<?php
/**
* View unprocess unmatch log report screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<head>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0' />
    <meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1' />
</head>
<html>
    <?php
    include '../../../../../adiha.php.scripts/components/include.file.v3.php';
    $form_cell_json = "[
            {
                id:     'a',
                width:  240,
                height: 500,
                header: false
            }
        ]";
    
    $right_view_log = 10234700;
    $rights_delete_log = 10234410;
    
    list (
       $has_rights_delete_log
    ) = build_security_rights (
       $rights_delete_log
    ); 
    
    $process_id = get_sanitized_value($_REQUEST['process_id'] ?? 'NULL');

    $form_layout = new AdihaLayout();
    $layout_name = 'layout_log_report';
    $form_name_space = 'form_log_report';
    echo $form_layout->init_layout($layout_name, '', '1C', $form_cell_json, $form_name_space); 
    
    //Attaching Toolbar
    $toolbar_json = '[ {id:"refresh", img:"refresh.gif", text:"Refresh", title:"Refresh"},                                
                        {id:"t1", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]}, 
                        {id:"t2", text:"Edit", img:"edit.gif", items:[
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: 0}
                        ]}
                    ]';
    
    $toolbar = new AdihaMenu();
    echo $form_layout->attach_menu_cell('toolbar_log_report', 'a'); 
    echo $toolbar->init_by_attach('toolbar_log_report', $form_name_space);
    echo $toolbar->load_menu($toolbar_json);
    echo $toolbar->attach_event('', 'onClick', 'toolbar_log_report_click');
    //Attaching Grid 
    $grid_log_report = new AdihaGrid();
    $grid_name = 'grd_log_report';

    echo $form_layout->attach_grid_cell($grid_name, 'a');
    echo $grid_log_report->init_by_attach($grid_name, $form_name_space);
    echo $grid_log_report->set_header('Row ID,Derivative Deal ID,Derivative Ref Deal ID,Available Derivative Volume,Exposure Deal ID,Exposure Ref Deal ID,Available Exposure Volume,Exclude Option');
    echo $grid_log_report->set_widths('150,150,150,150,150,150,150,150');
    echo $grid_log_report->set_search_filter(false,"#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
    echo $grid_log_report->set_column_types('ro,ro,ro,ro,ro,ro,ro,ro');
    echo $grid_log_report->set_columns_ids('rowid,der._deal_id,der._ref._deal_id,available_der._volume,exp._deal_id,exp._ref._deal_id,available_exp._volume,exclude_option');
    echo $grid_log_report->hide_column(0);
    echo $grid_log_report->attach_event('', 'onRowSelect', 'grd_log_report_click');
    echo $grid_log_report->return_init();
    echo $form_layout->close_layout();     
?>
<script type="text/javascript">
    var has_rights_delete_log = Boolean('<?php echo $has_rights_delete_log; ?>');
    
    $(function() {
       grid_refresh();
    });
    
    function toolbar_log_report_click(args) {
        switch(args) {
            case 'refresh':
                grid_refresh();      
                break;
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                form_log_report.grd_log_report.toExcel(path);
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                form_log_report.grd_log_report.toPDF(path);
                break;
            case 'delete':
                var selected_id = form_log_report.grd_log_report.getSelectedRowId(); 
                var row_id = form_log_report.grd_log_report.cells(selected_id,'0').getValue();
                data_for_post = { 'action': 'spa_exclude_deal_auto_matching', 
                                  'flag': 'd',
                                  'rowid': row_id
                                };
                adiha_post_data('confirm', data_for_post, '', '', 'delete_row', '');
                break;
        }
    }
    
    function delete_row() {
        grid_refresh(); 
    }
    
    function grid_refresh() {
        form_log_report.toolbar_log_report.setItemDisabled('delete');
        param = { 'action': 'spa_exclude_deal_auto_matching', 
                  'flag': 's'
                }
        adiha_post_data('return_data', param, '', '', 'call_back_refresh_click', '');
        
    }
    
    function grd_log_report_click() {
        var selected_id = form_log_report.grd_log_report.getSelectedRowId(); 
        if (selected_id != '' && has_rights_delete_log == true) form_log_report.toolbar_log_report.setItemEnabled('delete');         
    }
    
    function call_back_refresh_click(result) {
        form_log_report.grd_log_report.clearAll();
        form_log_report.grd_log_report.parse(result, "js");
    }

</script>