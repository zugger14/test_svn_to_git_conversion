<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../../../adiha.php.scripts/components/include.file.v3.php');?>
</head>
<body>
  
<?php
    $application_function_id = 10101215;
    $form_name = 'form_book_transfer';
    $form_namespace = 'transfer_book';
    $layout_name = 'book_transfer_layout';
    
    $sub_book_name = get_sanitized_value($_GET['sub_book_name'] ?? '');
    $transfer_book = get_sanitized_value($_GET['trans_book'] ?? '');
    $fas_book_id = get_sanitized_value($_GET['fas_book_id'] ?? 'NULL');
    $book_deal_type_map_id = get_sanitized_value($_GET['book_deal_type_map_id'] ?? 'NULL');
    
    $sql = "EXEC spa_sourcesystembookmap @flag='b', @fas_book_id = $fas_book_id";
    $current_book = readXMLURL($sql); 
    $current_book = isset($current_book[0][0]) ? $current_book[0][0] : '0';
    
    $sql = "EXEC spa_sourcesystembookmap @flag='s', @book_deal_type_map_id=$book_deal_type_map_id";
    $return_value = readXMLURL($sql);  
    
    //$book_deal_type_map_id = $return_value[0][0];
    //$fas_book_id = $return_value[0][1];
    $source_system_book_id1 = isset($return_value[0][2]) ? $return_value[0][2] : 'null';
    $source_system_book_id2 = isset($return_value[0][3]) ? $return_value[0][3] : 'null';
    $source_system_book_id3 = isset($return_value[0][4]) ? $return_value[0][4] : 'null';
    $source_system_book_id4 = isset($return_value[0][5]) ? $return_value[0][5] : 'null';
    $fas_deal_type_value_id = isset($return_value[0][6]) ? $return_value[0][6] : 'null';

    $effective_start_date = isset($return_value[0][8]) ? $return_value[0][8] : '';
    $end_date = isset($return_value[0][10]) ? $return_value[0][10] : '';

    //$percentage_included = $return_value[0][7];
    //$effective_start_date = $return_value[0][8];
    //$fas_deal_sub_type_value_id = $return_value[0][9];
    //$end_date = $return_value[0][10];
    //
    
    $layout_json = '[{
                        id:             "a",
                        width:          250,
                        header:         false,
                        collapse:       false,
                        fix_size:       [false,null]
                    }]';
    $layout = new AdihaLayout();
    echo $layout->init_layout('book_transfer_layout', '', '1C', $layout_json, $form_namespace); 
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'transfer_toolbar';

    $toolbar_json = '[{id:"ok", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Ok", title:"Ok", disabled:false}]';

    echo $layout->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'transfer_button_click');
    
    $xml_ui = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10101215', @template_name='SubBookTransferProperty'";
    $return_value_ui = readXMLURL($xml_ui);
    $form_obj = new AdihaForm();
    
    $form_struct = $return_value_ui[0][2];
    echo $layout->attach_form($form_name,'a');   
    echo $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_struct);
    echo $layout->close_layout();
?>
<script type="text/javascript">
    var current_book = '<?php echo $current_book;?>';

    var effective_start_date = '<?php echo $effective_start_date;?>';
    var end_date = '<?php echo $end_date;?>';
    var fas_deal_type_value_id = '<?php echo $fas_deal_type_value_id;?>';
    var sub_book_name = "<?php echo $sub_book_name . ' - ' . 'Transferred';?>";

    $(function(){
        transfer_book.form_book_transfer.setItemValue('fas_book_id', current_book);
        transfer_book.form_book_transfer.setItemValue('effective_start_date', effective_start_date);
        
        transfer_book.form_book_transfer.checkItem('no_link')

        transfer_book.form_book_transfer.setItemValue('end_date', end_date);
        //transfer_book.form_book_transfer.disableItem('end_date');

        attach_browse_event('transfer_book.form_book_transfer', 10231910, '', 'n');

        transfer_book.form_book_transfer.attachEvent("onChange", function(name,value){
            if (name == 'no_link') {
                var transfer_incrementally = transfer_book.form_book_transfer.isItemChecked('no_link');
                
                if (transfer_incrementally) {
                    transfer_book.form_book_transfer.enableItem('end_date');
                    //transfer_book.form_book_transfer.setItemValue('end_date', end_date);
                } else {
                    transfer_book.form_book_transfer.disableItem('end_date');
                    //transfer_book.form_book_transfer.setItemValue('end_date', '');
                }
            }  
        });
    });
    function transfer_button_click() {
        var status = validate_form(transfer_book.form_book_transfer);
        
        var fas_book_id = transfer_book.form_book_transfer.getItemValue('book_id'); //transfer book_id
        var effective_start_date = transfer_book.form_book_transfer.getItemValue('effective_start_date', true);
        var end_date = transfer_book.form_book_transfer.getItemValue('end_date', true);
        var percentage_included = transfer_book.form_book_transfer.getItemValue('percentage_included');
        var transfer_incrementally = (transfer_book.form_book_transfer.isItemChecked('no_link')) ? 'y' : 'n';
        var book_deal_type_map_id = <?php echo $book_deal_type_map_id;?>;
        //var ret_book_name = transfer_book.form_book_transfer.getItemValue('book_id');//transfer book_id

        var source_system_book_id1 = <?php echo $source_system_book_id1;?>;
        var source_system_book_id2 = <?php echo $source_system_book_id2;?>;
        var source_system_book_id3 = <?php echo $source_system_book_id3;?>;
        var source_system_book_id4 = <?php echo $source_system_book_id4;?>;
        
        if(transfer_incrementally == 'y' && end_date == "") {
            dhtmlx.alert({title: "Information!", type: "alert-error", text: "End date is required when Transfer Incrementally is checked."});
            status = false;
        }

        if(effective_start_date > end_date && end_date != "") {
            dhtmlx.alert({title: "Information!", type: "alert-error", text: "End Date must be greater than Effective Date."});
            status = false;
        }
        if(percentage_included < 0 || percentage_included > 1 ) {
            dhtmlx.alert({title: "Information!", type: "alert-error", text: "Please input the valid percentage included(0-1)."});
            status = false;
        }
        var flag = (transfer_incrementally == 'y') ? 'v' : 't';
        
        var data = {"action": "spa_sourcesystembookmap",
                    "flag": flag,
                    "logicalName": sub_book_name,
                    "fas_book_id": fas_book_id,
                    "source_system_book_id1": source_system_book_id1,
                    "source_system_book_id2": source_system_book_id2,
                    "source_system_book_id3": source_system_book_id3,
                    "source_system_book_id4": source_system_book_id4,
                    "book_deal_type_map_id": book_deal_type_map_id,
                    "percentage_included": percentage_included,
                    "effective_start_date": effective_start_date,
                    "fas_deal_type_value_id": fas_deal_type_value_id,
                    "end_date": end_date,
                   }
        //var msg = "Successfully transfered book to " + ret_book_name;
        if (status) {
            adiha_post_data('alert', data, '', '', '');
        }
    }
</script>
 
