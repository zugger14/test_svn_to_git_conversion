<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
<body>
<?php
	$name_space = 'ns_assign_percent_detail';
    $form_name = 'form_assign_percent_detail';
    $generator_assignment_id = get_sanitized_value($_GET['generator_assignment_id'] ?? 'NULL');
    $rights_assignment_form_iu = 12101721;
    $generator_id = get_sanitized_value($_GET['generator_id'] ?? 'NULL');

    list($has_rights_assignment_form_iu) = build_security_rights($rights_assignment_form_iu);

    $has_rights_assignment_form_iu = ($has_rights_assignment_form_iu != '') ? "true" : "false";

    if ($generator_assignment_id != 'NULL') {
	    $sp_url = "EXEC spa_rec_generator_assignment @flag='a', @generator_assignment_id='" . $generator_assignment_id . "'"; 
	    $return_value = readXMLURL($sp_url);

	    $generator_assignment_id = $return_value[0][0];
		$generator_id = $return_value[0][1];
		$assignment_type = $return_value[0][2];
		$assignment_percent = $return_value[0][3];
		$term_start = $return_value[0][4];
		$term_end = $return_value[0][5];
		$assigned_counterparty = $return_value[0][6];
		$trader = $return_value[0][7];
		$sold_price = $return_value[0][8];
		$exclude_from_inventory = $return_value[0][9];
		$max_volume_assign = $return_value[0][10];
		$uom = $return_value[0][11];
		$use_market_price = $return_value[0][12];
		$frequency = $return_value[0][13];
		$source_book_map_id = $return_value[0][14];
		$offset = $return_value[0][15];
		$contract = $return_value[0][16];
        $use_deal_price = $return_value[0][17];
	}

    $layout_json = '[   
                        {id: "a", text: "", header: "false", fix_size: [true,true]},
                        {id: "b", text: "", header: "false", height: 400, fix_size: [false,null]},
                    ]';
    $assign_percent_detail_layout = new AdihaLayout();
    echo $assign_percent_detail_layout->init_layout('renewable_source_layout', '', '2E', $layout_json, $name_space);

    $menu_name = 'assignment_percent_detail_menu';
    $menu_json = "[
            		{id:'save', text:'Save', img:'save.gif', imgdis:'save_dis.gif', enabled: '$has_rights_assignment_form_iu'},            
        		]";

    $assignment_percent_detail_toolbar = new AdihaMenu();
    echo $assign_percent_detail_layout->attach_menu_cell($menu_name, "a"); 
    echo $assignment_percent_detail_toolbar->init_by_attach($menu_name, $name_space);
    echo $assignment_percent_detail_toolbar->load_menu($menu_json);
    echo $assignment_percent_detail_toolbar->attach_event('', 'onClick', 'assignment_percent_detail_menu');

	$assignment_percent_form = new AdihaForm();
    $assignment_percent_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='12101721', @template_name='AssignmentFormDetails'";
    $filter_arr = readXMLURL($assignment_percent_sql);    
    $form_json = $filter_arr[0][2];
    echo $assign_percent_detail_layout->attach_form('filter_form', 'b');    
    $assignment_percent_form->init_by_attach('filter_form', $name_space);
    echo $assignment_percent_form->load_form($form_json);

    echo $assign_percent_detail_layout->close_layout();
?>
<script type="text/javascript">
	var generator_assignment_id = '<?php echo $generator_assignment_id; ?>';
	var date_format = '<?php echo $date_format; ?>';

	$(function() {
		if (generator_assignment_id != 'NULL'){
			var generator_assignment_id = '<?php echo $generator_assignment_id?>';
			var generator_id = '<?php echo $generator_id?>';
			var assignment_type = '<?php echo $assignment_type?>';
			var assignment_percent = '<?php echo $assignment_percent?>';
			var term_start = '<?php echo $term_start?>';
			var term_end = '<?php echo $term_end?>';
			var assigned_counterparty = '<?php echo $assigned_counterparty?>';
			var trader = '<?php echo $trader?>';
			var sold_price = '<?php echo $sold_price?>';
			var exclude_from_inventory = '<?php echo $exclude_from_inventory?>';
			var max_volume_assign = '<?php echo $max_volume_assign?>';
			var uom = '<?php echo $uom?>';
			var use_market_price = '<?php echo $use_market_price?>';
			var frequency = '<?php echo $frequency?>';
			var allocation = '<?php echo $source_book_map_id?>';
			var offset = '<?php echo $offset?>';
			var contract = '<?php echo $contract?>';
            var use_deal_price = '<?php echo $use_deal_price?>';
			
			var form_data_update = ns_assign_percent_detail.filter_form.getFormData();

			for (var a in form_data_update) {
                label = a;
                
                eval('ns_assign_percent_detail.filter_form.setItemValue("' + a + '", ' + a + ')');

                if (ns_assign_percent_detail.filter_form.getItemType(a) == 'checkbox') {
					
					if (a == 'exclude_from_inventory' && exclude_from_inventory == 'y') {
						ns_assign_percent_detail.filter_form.checkItem('exclude_from_inventory');
					}

					if (a == 'use_market_price' && use_market_price == 'y') {
						ns_assign_percent_detail.filter_form.checkItem('use_market_price');
					}

                    if (a == 'use_deal_price' && use_deal_price == 'y') {
                        ns_assign_percent_detail.filter_form.checkItem('use_deal_price');
                    }
				}
            }
		} 
	});

	function assignment_percent_detail_menu(args) {
		if (args == 'save') {
            var validate_return = validate_form(ns_assign_percent_detail.filter_form);    
                
            if (validate_return === false) {
                return;
            }

            var term_start = ns_assign_percent_detail.filter_form.getItemValue('term_start', true);
            var term_end = ns_assign_percent_detail.filter_form.getItemValue('term_end', true);
            if (term_start >= term_end) {
                show_messagebox("<b>Term End</b> date must be greater than <b>Term Start</b> date.");
                return;
            }
			var form_data_insert = ns_assign_percent_detail.filter_form.getFormData();
        	var form_xml = '<Root function_id="12101700"><FormXML ';
        	var generator_id = '<?php echo $generator_id;?>';

        	for (var a in form_data_insert) {
                    label = a;
                    data = form_data_insert[a];

                    if (data != '') {

                        if (a == 'assignment_percent' && data > 1) {
                            // show_messagebox('<b>Assignment Percent</b> cannot be more than 1 (100%).');
                            ns_assign_percent_detail.filter_form.setNote(a,{text:"Cannot be more than 1 (100%)."});
                            ns_assign_percent_detail.filter_form.setValidateCss(a, false);
                            return;
                        }

                        if (ns_assign_percent_detail.filter_form.getItemType(a) == 'calendar')
                            data = ns_assign_percent_detail.filter_form.getItemValue(a, true);

                        form_xml += a + '="' + data + '" ';
                    }
                }

            form_xml += '></FormXML></Root>';
            
            var flag = (generator_assignment_id == 'NULL') ? 'i' : 'u';

            data = {
                'action': 'spa_rec_generator_assignment',
                'flag': flag,
                'generator_assignment_id': generator_assignment_id,
                'generator_id': generator_id, 
                'form_xml': form_xml
            }

            adiha_post_data('return_json', data, '', '', 'refresh_grid');
		}
	}

	function refresh_grid(result) {
        var return_data = JSON.parse(result);
        if ((return_data[0].status).toLowerCase() == 'success') {             
            dhtmlx.message(return_data[0].message); 
            parent.refresh_grid();
            parent.new_assignment_percent_iu.close();
        } else {
            dhtmlx.alert({
                   title: 'Alert',
                   type: "alert",
                   text: return_data[0].message
                });
        }
	}

	function date_format_converter(input_date) {        
        var dd = input_date.getDate();        
        var mm = input_date.getMonth() + 1;
        var y = input_date.getFullYear();
        mm = ((mm.toString()).split('').length == 1) ? ('0' + mm) : mm;
        dd = ((dd.toString()).split('').length == 1) ? ('0' + dd) : dd;
        
        if (date_format == '%n/%j/%Y' || date_format == '%m/%d/%Y') {
            return (mm + '/'+ dd + '/'+ y);
        } else if (date_format == '%j-%n-%Y' || date_format == '%d-%m-%Y') {
            return (dd + '-'+ mm + '-'+ y);
        } else if (date_format == '%j.%n.%Y' || date_format == '%d.%m.%Y') {
            return (dd + '.'+ mm + '.'+ y);
        } else if (date_format == '%j/%n/%Y' || date_format == '%d/%m/%Y') {
            return (dd + '/'+ mm + '/'+ y);
        } else if (date_format == '%n-%j-%Y' || date_format == '%m-%d-%Y') {
            return (mm + '-'+ dd + '-'+ y);
        }
    }
</script>