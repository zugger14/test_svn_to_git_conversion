<!DOCTYPE html>
<html> 
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>

	<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_copy_price';
    $name_space = 'copy_price';
    $rights_view_price_copy = 10151011;
    $curve_id = get_sanitized_value($_GET['curve_id'] ?? 'NULL');
    $curve_name = get_sanitized_value($_GET['curve_name'] ?? 'NULL');
    
    $has_rights_view_price_copy = build_security_rights($rights_view_price_copy);
    
    $layout_json = '[
                        {id: "a", text: "Apply Filter", collapse: true, height: 100},
                        {id: "b", text: "Price Criteria", header: true, height: 500}
                    ]';

    $copy_price_layout = new AdihaLayout();
    echo $copy_price_layout->init_layout('copy_price_layout', '', '2E', $layout_json, $name_space);

    $menu_name = 'menu_price_copy';
    $menu_json = "[
            {id:'ok', text:'Ok', img:'tick.gif', imgdis:'tick_dis.gif'},
        ]";

    $copy_price_menu = new AdihaMenu();
    echo $copy_price_layout->attach_menu_cell($menu_name, "b"); 
    echo $copy_price_menu->init_by_attach($menu_name, $name_space);
    echo $copy_price_menu->load_menu($menu_json);
    echo $copy_price_menu->attach_event('', 'onClick', 'btn_ok_click');

    $form_obj = new AdihaForm();
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10151011', @template_name='CopyPrice'";
    $form_data = readXMLURL($form_sql);
    $form_json = $form_data[0][2];

    echo $copy_price_layout->attach_form($form_name, 'b');
    $form_obj->init_by_attach($form_name, $name_space);
    echo $form_obj->load_form($form_json);

    echo $copy_price_layout->close_layout();
?>
<script type="text/javascript">
    $(function(){
        var function_id  = '<?php echo $rights_view_price_copy; ?>';
        var filter_obj = copy_price.copy_price_layout.cells("a").attachForm();
        
        var layout_a_obj = copy_price.copy_price_layout.cells("b");
        load_form_filter(filter_obj, layout_a_obj, function_id, 2);
        attach_browse_event('copy_price.form_copy_price', function_id);


        var curve_id = '<?php echo $curve_id; ?>';
        var curve_name = '<?php echo $curve_name; ?>';

        if (curve_id != 'NULL' && curve_name != 'NULL') {
            copy_price.form_copy_price.setItemValue('price_curve_from', curve_id);
            copy_price.form_copy_price.setItemValue('label_price_curve_from', curve_name);
        }
    });

    function btn_ok_click() {
        var form_data = copy_price.form_copy_price.getFormData();
        var validate_return = validate_form(copy_price.form_copy_price);
       
        if (validate_return === false) {
            return;
        }

        var from_source = copy_price.form_copy_price.getItemValue('from_source');
        var price_curve_from = copy_price.form_copy_price.getItemValue('price_curve_from');
        var as_of_date_from = copy_price.form_copy_price.getItemValue('as_of_date_from', true);
        var as_of_date_to = copy_price.form_copy_price.getItemValue('as_of_date_to', true);
        var tenor_from = copy_price.form_copy_price.getItemValue('tenor_from', true);
        var tenor_to = copy_price.form_copy_price.getItemValue('tenor_to', true);
        var forward_only = copy_price.form_copy_price.getItemValue('forward_only');
        var to_source = copy_price.form_copy_price.getItemValue('to_source');
        var price_curve_to = copy_price.form_copy_price.getItemValue('price_curve_to');
        var dest_as_of_date_from = copy_price.form_copy_price.getItemValue('dest_as_of_date_from', true);
        var dest_as_of_date_to = copy_price.form_copy_price.getItemValue('dest_as_of_date_to', true);
        var shift_price_by = copy_price.form_copy_price.getItemValue('shift_price_by');
        var shift_value = copy_price.form_copy_price.getItemValue('shift_value');
        var shift_tenor_by = copy_price.form_copy_price.getItemValue('shift_tenor_by');
        
        if (as_of_date_to < as_of_date_from || dest_as_of_date_to < dest_as_of_date_from) {
            show_messagebox('<b>As of Date To</b> should be greater than <b>As of Date From</b>');
            return;
        }

        if (tenor_to < tenor_from) {
            show_messagebox('<b>Tenor To</b> should be greater than <b>Tenor From</b>');
            return;
        }
       
        if (price_curve_from.split(',').length > 1 || price_curve_to.split(',').length > 1) {
            show_messagebox('Please select only one Price Curve');
            return;
        }

        if (price_curve_from == price_curve_to) {
            show_messagebox('Please select different Price Curves in source and destination.');
            return;
        }
        copy_price.copy_price_layout.progressOn();
        var data = {
                    'action': 'spa_source_price_curve_copy',
                    'from_source': from_source,
                    'price_curve_from': price_curve_from,
                    'as_of_date_from': as_of_date_from,
                    'as_of_date_to': as_of_date_to,
                    'tenor_from': tenor_from,
                    'tenor_to': tenor_to,
                    'forward_only': forward_only,
                    'to_source': to_source,
                    'price_curve_to': price_curve_to,
                    'dest_as_of_date_from': dest_as_of_date_from,
                    'dest_as_of_date_to': dest_as_of_date_to,
                    'shift_price_by': shift_price_by,
                    'shift_value': shift_value,
                    'shift_tenor_by': shift_tenor_by,
                    'flag': 'c'
                }

        adiha_post_data('alert', data, '', '', 'callback');
    }

    function callback(result) {
        copy_price.copy_price_layout.progressOff();
    }
</script>>
</html>