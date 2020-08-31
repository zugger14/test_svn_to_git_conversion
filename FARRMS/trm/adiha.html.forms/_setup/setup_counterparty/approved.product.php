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
        $approved_counterparty_id = ($_GET['approved_counterparty_id']) ? get_sanitized_value($_GET['approved_counterparty_id']) : -1;

        $rights_approve_counterparty_product_iu = 10105903;
        list (
            $has_rights_approve_counterparty_product_iu
        ) = build_security_rights(
            $rights_approve_counterparty_product_iu
        );
        
        $sql = "SELECT approved_counterparty FROM approved_counterparty WHERE approved_counterparty_id = " . $approved_counterparty_id;
        $approved_counterparty_array = readXMLURL2($sql);
        $approved_counterparty = $approved_counterparty_array[0]['approved_counterparty'];
        
        $form_namespace = 'approveProducts';
        $layout_obj = new AdihaLayout();
        $toolbar_obj = new AdihaToolbar();
        $layout_json = '[{id: "a", header:false}]';
        $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", disabled: "true", title: "Save"}]';

        echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
        echo $layout_obj->attach_toolbar_cell("toolbar", "a");
        echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
        echo $toolbar_obj->load_toolbar($toolbar_json);
        echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');
        
        $grid_name = 'approve_products';
        echo $layout_obj->attach_grid_cell($grid_name, 'a');
        $grid_obj = new GridTable($grid_name);
        echo $layout_obj->attach_status_bar("a", true);
        echo $grid_obj->init_grid_table($grid_name, $form_namespace, 'n');
        echo $grid_obj->return_init();
        echo $grid_obj->load_grid_data("EXEC spa_approved_counterparty 'y', @counterparty_id = " . $approved_counterparty . ", @approved_counterparty_id = " . $approved_counterparty_id, 'g', '', '');
        echo $grid_obj->enable_multi_select();
        echo $grid_obj->set_search_filter(true, '');
        echo $grid_obj->enable_paging(25, 'pagingArea_a', 'true');
        echo $grid_obj->attach_event('', 'onSelectStateChanged', $form_namespace.'.grid_select');
        
        echo $layout_obj->close_layout();
        ?>
    </body>
    <script type="text/javascript">
        var approved_counterparty_id = '<?php echo $approved_counterparty_id; ?>';
        var has_rights_approve_counterparty_product_iu = <?php echo (($has_rights_approve_counterparty_product_iu) ? $has_rights_approve_counterparty_product_iu : '0'); ?>;
        var popup_window;
        var setup_counterparty = approveProducts;
        approveProducts.save_click = function(id) {
            switch (id) {
                case 'save':
                    var selected_row = approveProducts.approve_products.getSelectedRowId();
                    var col_index = approveProducts.approve_products.getColIndexById('counterparty_product_id');
                    var partsOfStr = selected_row.split(',');
                    grid_xml = '<Root>';
                    for (i = 0; i < partsOfStr.length; i++) {
                        var primary_column_value = approveProducts.approve_products.cells(partsOfStr[i], col_index).getValue();
                        grid_xml += '<Grid approved_counterparty_id ="' + approved_counterparty_id + '" approved_product_id="' + primary_column_value + '"></Grid>';
                    }
                    grid_xml += '</Root>';
                    
                    var data = {
                        "action": "spa_approved_counterparty",
                        "flag": "p",
                        "xml": grid_xml
                    };
                    
                    adiha_post_data('alert', data, '', '', 'approveProducts.post_callback', '');
                    break;
            }
        }
        
        approveProducts.grid_select = function(id) {
            if (id == null) {
                approveProducts.toolbar.disableItem('save');
            } else {
                if (has_rights_approve_counterparty_product_iu)
                    approveProducts.toolbar.enableItem('save');
            }
        }
        
        approveProducts.post_callback = function(result) {
            parent.new_win.setModal(false);
            parent.new_win.close();
        }
        
        setup_counterparty.open_popup_window = function(counterparty_id, id, win_type, sql_stmt, grid_obj, grid_type) {
            unload_window();
            var win_text = 'Contact';
            var param = 'counterparty.contacts.php?counterparty_id='+''+'&counterparty_contact_id=' + id;
            var width = 700;
            var height = 550;
            
            if (!popup_window) {
                popup_window = new dhtmlXWindows();
            }
            
            new_win = popup_window.createWindow('w1', 0, 0, width, height);
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.setText(win_text);
            new_win.attachURL(param, false, true);
        }
        
        function unload_window(win_type) {
            if (popup_window != null && popup_window.unload != null) {
                popup_window.unload();
                popup_window = w1 = null;
            }
        }
    </script>

</html>