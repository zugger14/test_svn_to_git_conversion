<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php 
    $form_namespace = 'dealRemarks';
    $deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : '';
    $process_id = (isset($_POST["process_id"]) && $_POST["process_id"] != '') ? get_sanitized_value($_POST["process_id"]) : '';
    
    if ($type != 'leg') {
        $sp_term = "EXEC spa_deal_update @flag='m', @from_date='" . $max_date . "', @source_deal_header_id=" . $deal_id;
        $data = readXMLURL2($sp_term);

        $from_date = $data[0]['from_date'];
        $to_date = $data[0]['to_date'];
    }

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $grid_obj = new AdihaGrid();
    $toolbar_obj = new AdihaToolbar();

    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_grid_cell('deal_remarks', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');

    echo $grid_obj->init_by_attach('deal_remarks', $form_namespace);
    echo $grid_obj->set_header("ID,Remarks");
    echo $grid_obj->set_columns_ids("id,name");
    echo $grid_obj->set_widths("*,*");
    echo $grid_obj->set_column_visibility('true,false');
    echo $grid_obj->set_column_types("ro,ro");
    echo $grid_obj->set_search_filter(true, "");
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->return_init();
    $sql = "SELECT value_id, description FROM static_data_value WHERE type_id = 40500 ORDER BY description";
    echo $grid_obj->load_grid_data($sql, 'g', '', true);
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_list_remarks" id="txt_list_remarks"></textarea>
<script type="text/javascript">
    dealRemarks.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var selected_remarks = dealRemarks.deal_remarks.getColumnValues(0);
                var deal_id = '<?php echo $deal_id; ?>';
                var process_id = '<?php echo $process_id; ?>'
                 var data = {
                    "action":"spa_deal_update_new",
                    "flag":'r',
                    "source_deal_header_id":deal_id,
                    "pricing_process_id":process_id,
                    "remarks_list":selected_remarks

                }  
                adiha_post_data("alert", data, '', '', 'dealRemarks.ok_callback');
                break;
            case "cancel":
                document.getElementById("txt_list_remarks").value = '';
                var win_obj = window.parent.dhx_remarks.window("w1");
                win_obj.close();
                break;
        }
    }

    dealRemarks.ok_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var win_obj = window.parent.dhx_remarks.window("w1");
            win_obj.close();
        }
    }
</script>
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
</html>