<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
        
        <style type="text/css">
            html, body {
                width: 100%;
                height: 100%;
                margin: 0px;
                padding: 0px;
                background-color: #ebebeb;
                overflow: hidden;
            }
        </style>
    </head>
    <body>
        <?php
        $counterparty_id = get_sanitized_value($_GET['counterparty_id']);
        $approved_counterparty_id = ($_GET['approved_counterparty_id']) ? get_sanitized_value($_GET['approved_counterparty_id']) : -1;

        $function_id = 10105900;
        $rights_approved_conterparty_iu = 10105901;
        list (
            $has_rights_approved_conterparty_iu
        ) = build_security_rights(
            $rights_approved_conterparty_iu            
        );
        
        $form_namespace = 'approveCounterparty';
        $layout_obj = new AdihaLayout();
        $toolbar_obj = new AdihaToolbar();
        
        $layout_json = '[{id: "a", header:false}]';
        $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", disabled: "true", title: "Save"}]';

        echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
        echo $layout_obj->attach_toolbar_cell("toolbar", "a");
        echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
        echo $toolbar_obj->load_toolbar($toolbar_json);
        echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');
        
        $grid_name = 'approve_counterparty';
        echo $layout_obj->attach_grid_cell($grid_name, 'a');
        $grid_obj = new GridTable($grid_name);
        echo $layout_obj->attach_status_bar("a", true);
        echo $grid_obj->init_grid_table($grid_name, $form_namespace, 'n');
        echo $grid_obj->return_init();
        echo $grid_obj->load_grid_data("EXEC spa_approved_counterparty 'z', " . $counterparty_id, 'g', '', '');
        echo $grid_obj->enable_multi_select();
        echo $grid_obj->set_search_filter(true, '');
        echo $grid_obj->enable_paging(25, 'pagingArea_a', 'true');
        echo $grid_obj->attach_event('', 'onSelectStateChanged', $form_namespace.'.grid_select');
        echo $grid_obj->attach_event('', 'onBeforeSelect', 'grid_before_select');
        
        echo $layout_obj->close_layout();
        
        ?>
    </body>
    <script type="text/javascript">
        var counterparty_id = '<?php echo $counterparty_id; ?>';
        
        approveCounterparty.save_click = function(id) {
            switch (id) {
                case 'save':
                    var selected_row = approveCounterparty.approve_counterparty.getSelectedRowId();
                    var col_index = approveCounterparty.approve_counterparty.getColIndexById('source_counterparty_id');
                    var partsOfStr = selected_row.split(',');
                    grid_xml = '<Root>';
                    for (i = 0; i < partsOfStr.length; i++) {
                        var primary_column_value = approveCounterparty.approve_counterparty.cells(partsOfStr[i], col_index).getValue();
                        grid_xml += '<Grid approved_counterparty_id ="' + primary_column_value + '" counterparty_id="' + counterparty_id + '"></Grid>';
                    }
                    grid_xml += '</Root>';
                    
                    var data = {
                        "action": "spa_approved_counterparty",
                        "flag": "c",
                        "xml": grid_xml
                    };
                    
                    adiha_post_data('alert', data, '', '', 'approveCounterparty.post_callback', '');
                    break;
            }
        }
        
        approveCounterparty.grid_select = function(id) {
            if (id == null) {
                approveCounterparty.toolbar.disableItem('save');
            } else {
                approveCounterparty.toolbar.enableItem('save');
            }
        }
        
        approveCounterparty.post_callback = function(result) {
            parent.new_win.setModal(false);
            parent.new_win.close();
        }

        function grid_before_select(new_row, old_row, new_col_index) {
            var obj = approveCounterparty.layout.cells('a').getAttachedObject();
            
            var status_index = obj.getColIndexById("status");
            if (status_index != undefined) {
                var status = obj.cells(new_row, status_index).getValue();
                if (status.toLowerCase() == 'disable')
                    return false;
                else
                    return true;
            } else {
                return true;
            }
        }
    </script>

</html>