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
     
    $rights_unprocess_unmatch = 10234610; 
    
    list (
       $has_rights_unprocess_unmatch
    ) = build_security_rights (
       $rights_unprocess_unmatch
    ); 
    
    $row_id = get_sanitized_value($_REQUEST['row_id'] ?? 'NULL');
    $process_id = get_sanitized_value($_REQUEST['process_id'] ?? 'NULL');
    $xml_file = "EXEC spa_get_dedesignate_data @flag=1, @IDs='" . $row_id . "', @process_id='" . $process_id . "'";
    $return_value = readXMLURL($xml_file);
    $der_deal_id = isset($return_value[0][0]) ? $return_value[0][0] : '';
    $exp_deal_id = isset($return_value[0][1]) ? $return_value[0][1] : '';
    $der_ref_id = isset($return_value[0][2]) ? $return_value[0][2] : '';
    $exp_ref_id = isset($return_value[0][3]) ? $return_value[0][3] : '';
    
    $form_layout = new AdihaLayout();
    $layout_name = 'layout_unprocess_unmatch';
    $form_name_space = 'form_unprocess_unmatch';
    echo $form_layout->init_layout($layout_name, '', '1C', $form_cell_json, $form_name_space); 
    
    //Attaching Toolbar
    $toolbar_json = "[ {id:'tick', img:'tick.gif', imgdis:'tick_dis.gif', text:'Ok', title:'Ok', disabled:$rights_unprocess_unmatch} ]";
    
    $toolbar = new AdihaMenu();
    echo $form_layout->attach_menu_cell('toolbar_unprocess_unmatch', 'a'); 
    echo $toolbar->init_by_attach('toolbar_unprocess_unmatch', $form_name_space);
    echo $toolbar->load_menu($toolbar_json);
    echo $toolbar->attach_event('', 'onClick', 'btn_ok_click');
    $type_dropdown = "[{text: 'Do Not Match' , value: 'm'}, {text: 'Do Not Process', value: 'r'}]";
    $form_json = "[
        {type: 'label', name: 'derivative', label: 'Derivative', position: 'absolute', labelLeft: 2, labelTop: 20, labelWidth: 160},
        {type: 'input', name: 'deal_id', label: 'Deal ID', width: 150, disabled: 1, value: '$der_deal_id', position: 'absolute', inputLeft: 5, inputTop: 70, labelLeft: 5, labelTop: 50, labelWidth: 160},
        {type: 'input', name: 'ref_id', label: 'Reference ID', disabled: 1, width: 150, value: '$der_ref_id', position: 'absolute', inputLeft: 250, inputTop: 70, labelLeft: 250, labelTop: 50, labelWidth: 160},
        {type: 'label', name: 'exposure', label: 'Exposure', position: 'absolute', labelLeft: 2, labelTop: 120, labelWidth: 160},
        {type: 'input', name: 'deal_id_exp', label: 'Deal ID', disabled: 1, width: 150, value: '$exp_deal_id', position: 'absolute', inputLeft: 5, inputTop: 170, labelLeft: 5, labelTop: 150, labelWidth: 160},
        {type: 'input', name: 'ref_id_exp', label: 'Reference ID', disabled: 1, width: 150, value: '$exp_ref_id', position: 'absolute', inputLeft: 250, inputTop: 170, labelLeft: 250, labelTop: 150, labelWidth: 160},
        {type: 'combo', name: 'type', label: 'Type', width: 150, disabled: 1, options: $type_dropdown, position: 'absolute', inputLeft: 5, inputTop: 245, labelLeft: 5, labelTop: 220, labelWidth: 160}
    ]";    
    
    $form_object = new AdihaForm();
    echo $form_layout->attach_form('unprocess_unmatch', 'a');    
    echo $form_object->init_by_attach('unprocess_unmatch', $form_name_space);
    echo $form_object->load_form($form_json);
    echo $form_layout->close_layout();     
?>
<script type="text/javascript">
    $(function(){
        var der_deal_id = form_unprocess_unmatch.unprocess_unmatch.getItemValue('deal_id');
        var exp_deal_id = form_unprocess_unmatch.unprocess_unmatch.getItemValue('deal_id_exp');
        
        if (exp_deal_id != '' && der_deal_id != '') 
            form_unprocess_unmatch.unprocess_unmatch.setItemValue('type', 'm');
        else 
            form_unprocess_unmatch.unprocess_unmatch.setItemValue('type', 'r');    
    });
    
    function btn_ok_click() {
        var der_deal_id = form_unprocess_unmatch.unprocess_unmatch.getItemValue('deal_id');
        var der_ref_id = form_unprocess_unmatch.unprocess_unmatch.getItemValue('ref_id');
        var exp_deal_id = form_unprocess_unmatch.unprocess_unmatch.getItemValue('deal_id_exp');
        var exp_ref_id = form_unprocess_unmatch.unprocess_unmatch.getItemValue('ref_id_exp');
        var type = form_unprocess_unmatch.unprocess_unmatch.getItemValue('type');
          
        var param = { "action": "spa_exclude_deal_auto_matching", 
                     "flag": "i", 
                     "source_deal_header_id1": der_deal_id,
                     "source_deal_header_id2": exp_deal_id,
                     "exclude_flag": type
                     }
                     
        adiha_post_data('return_array', param, '', '', 'ok_success_callback');  
    }
    
    function ok_success_callback(result) {
        if (result[0][0] == 'Success') {
            dhtmlx.alert({
                text: result[0][4],
                callback: function() {parent.win_unprocess_unmatch.close();}
            });
        } else {
            dhtmlx.alert({
                text: result[0][4]
            });
        }
    }
</script>


