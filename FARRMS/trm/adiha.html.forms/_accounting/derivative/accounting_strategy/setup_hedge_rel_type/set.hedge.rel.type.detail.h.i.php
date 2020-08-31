<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <body>
        <?php 
        $eff_test_profile_id = get_sanitized_value($_POST['eff_test_profile_id']);
        $eff_test_profile_detail_id = get_sanitized_value($_POST['eff_test_profile_detail_id'] ?? 'NULL');
        $mode = ($eff_test_profile_detail_id == 'NULL') ? 'i' : 'u';
        $book_id = get_sanitized_value($_POST['book_id'] ?? 'NULL');
        $strategy_id = get_sanitized_value($_POST['strategy_id'] ?? 'NULL');
        $sub_id = get_sanitized_value($_POST['sub_id'] ?? 'NULL');
        $hedge_or_item = get_sanitized_value($_POST['hedge_or_item'] ?? 'h');
        $sub_book_name = get_sanitized_value($_POST['sub_book_name'] ?? '');
        $next_leg = get_sanitized_value($_POST['next_leg'] ?? '1');
        $next_deal_seq = get_sanitized_value($_POST['next_deal_seq'] ?? '1');
        $rights_hedges_rel_ui = 10231910;
		$rights_hedges = 10231913;
        
        if ($mode == 'u') {
            $sql = "EXEC spa_effhedgereltypedetail @flag='a', @eff_test_profile_detail_id=" . $eff_test_profile_detail_id ;
            $result = readXMLURL2($sql);
            $source_deal_type_id =  $result[0]['source_deal_type_id'];
            $deal_sub_type_id =  $result[0]['deal_sub_type_id'];
            $source_curve_def_id =  $result[0]['source_curve_def_id'];
            $deal_xfer_source_book_id =  $result[0]['deal_xfer_source_book_id'];
            $strip_month_from = $result[0]['strip_month_from'];
            $strip_month_to =  $result[0]['strip_month_to'];
            
        } else {
            $source_deal_type_id =  '';
            $deal_sub_type_id =  '';
            $source_curve_def_id =  '';
            $deal_xfer_source_book_id =  '';
            $strip_month_from = '';
            $strip_month_to =  '';
        }
        
        list (
                $has_rights_hedges_rel_ui,
				$has_rights_hedges
        ) = build_security_rights(
                 $rights_hedges_rel_ui,
				 $rights_hedges
        );
        $application_function_id = 10231913;
        
        $form_namespace = 'setup_hedge_item';
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $application_function_id . "', @template_name='SetupHedgeItem', @group_name='General', @parse_xml = '<Root><PSRecordSet eff_test_profile_detail_id=\"" . $eff_test_profile_detail_id . "\"></PSRecordSet></Root>'";
        $form_arr = readXMLURL2($form_sql);
        $form_json = $form_arr[0]['form_json'];
        $layout_obj = new AdihaLayout();
        $toolbar_obj = new AdihaToolbar();
        $form_obj = new AdihaForm();
        $layout_json = '[{id: "a", header:false}]';
        $toolbar_json = '[{id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]';

        echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
        echo $layout_obj->attach_toolbar_cell("toolbar", "a");
        echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
        echo $toolbar_obj->load_toolbar($toolbar_json);

        if(!$has_rights_hedges) {
            echo $toolbar_obj->disable_item('save');
        }

        echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

        // attach filter form
        $form_name = 'form_setup_hedge_item';
        echo $layout_obj->attach_form($form_name, 'a');
        $form_obj->init_by_attach($form_name, $form_namespace);
        echo $form_obj->load_form($form_json);
        echo $form_obj->attach_event('', 'onChange', 'item_changed');
        echo $layout_obj->close_layout();
        ?>
    </body>
    <textarea style="display:none" name="success_status" id="success_status"></textarea>
    <script type="text/javascript"> 
        var hedge_or_item = '<?php echo $hedge_or_item; ?>';
        var eff_test_profile_id = '<?php echo $eff_test_profile_id; ?>';
        var book_id = '<?php echo $book_id; ?>';
        var strategy_id = '<?php echo $strategy_id; ?>';
        var eff_test_profile_detail_id = '<?php echo $eff_test_profile_detail_id; ?>';
        var mode = (eff_test_profile_detail_id == 'NULL') ? 'i' : 'u';
        
        $(function() {
            setup_hedge_item.form_setup_hedge_item.setItemValue('hedge_or_item', hedge_or_item);
            setup_hedge_item.form_setup_hedge_item.setItemValue('eff_test_profile_id', eff_test_profile_id);
            setup_hedge_item.form_setup_hedge_item.setItemValue('label_book_deal_type_map_id', '<?php echo $sub_book_name; ?>');
            if (mode == 'i') {
                setup_hedge_item.form_setup_hedge_item.setItemValue('leg', '<?php echo $next_leg; ?>');
                setup_hedge_item.form_setup_hedge_item.setItemValue('deal_sequence_number', '<?php echo $next_deal_seq; ?>');
            }
            
            //load inter book transfer dropdow
            var cm_param = {
                        "action": "spa_source_book_maintain", 
                        "source_book_id": book_id,
						"hedge_item_flag": hedge_or_item,
                        "flag": "y"
                    };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param
            
            var combo_obj_xfer = setup_hedge_item.form_setup_hedge_item.getCombo('deal_xfer_source_book_id');
            combo_obj_xfer.load(url, function(){
                combo_obj_xfer.setComboValue('<?php echo $deal_xfer_source_book_id;?>');
            });
            
            //load deal type dropdown
            var cm_param = {
                        "action": "spa_source_deal_type_maintain", 
                        "fas_book_id": book_id,
						"flag": "y",
                        "sub_type": "n",
                        "has_blank_option": "false"
                    };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var combo_obj_dt = setup_hedge_item.form_setup_hedge_item.getCombo('source_deal_type_id');
            combo_obj_dt.load(url, function(){
                opt_index = combo_obj_dt.getIndexByValue('<?php echo $source_deal_type_id;?>');
                opt_index = (opt_index != -1) ? opt_index : 0;
                combo_obj_dt.selectOption(opt_index);
            });
            
            //load deal sub type dropdown
            var cm_param = {
                        "action": "spa_source_deal_type_maintain", 
                        "fas_book_id": book_id,
						"flag": "y",
                        "sub_type": "y",
                        "has_blank_option": "false"
                    };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param
            
            var combo_obj_sdt = setup_hedge_item.form_setup_hedge_item.getCombo('deal_sub_type_id');
            combo_obj_sdt.load(url, function(){
                combo_obj_sdt.setComboValue('<?php echo $deal_sub_type_id;?>');
            });
            //load index dropdown
            var cm_param = {
                        "action": "spa_source_price_curve_def_maintain", 
                        "flag": "m",
                        "strategy_id": book_id
                    };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param
            
            var combo_obj_idx = setup_hedge_item.form_setup_hedge_item.getCombo('source_curve_def_id');
            combo_obj_idx.load(url, function(){
                combo_obj_idx.setComboValue('<?php echo $source_curve_def_id;?>');
            });
            //attach_browse_event(form_name, '10231910', 'onchange_book_structure');
            attach_browse_event('setup_hedge_item.form_setup_hedge_item', '10231913', 'load_browser_field');
            
            //load month from to dropdown
            var cm_param = {
                        "action": "spa_execute_query",
                        "query": "[''jan'',''January''],[''feb'',''February''],[''mar'',''March''],[''apr'',''April''],[''may'',''May''],[''jun'',''June''],[''jul'',''July''],[''aug'',''August''],[''sep'',''September''],[''oct'',''October''],[''nov'',''November''],[''dec'',''December'']",
                        "has_blank_option": "false"
                    };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param
            
            combo_obj_mf = setup_hedge_item.form_setup_hedge_item.getCombo('strip_month_from');
            combo_obj_mf.load(url, function(){
                opt_index = combo_obj_mf.getIndexByValue('<?php echo $strip_month_from;?>');
                opt_index = (opt_index != -1) ? opt_index : 0;
                combo_obj_mf.selectOption(opt_index);
            });
//            
            //load month to dropdown
            combo_obj_mt = setup_hedge_item.form_setup_hedge_item.getCombo('strip_month_to');
            combo_obj_mt.load(url, function(){
                opt_index = combo_obj_mt.getIndexByValue('<?php echo $strip_month_to;?>');
                opt_index = (opt_index != -1) ? opt_index : 0;
                combo_obj_mt.selectOption(opt_index);
            });
                        
            var fixed_float = setup_hedge_item.form_setup_hedge_item.getItemValue('fixed_float_flag');
            if (fixed_float == 'f') {
                setup_hedge_item.form_setup_hedge_item.disableItem('source_curve_def_id');
                setup_hedge_item.form_setup_hedge_item.setItemValue('source_curve_def_id', '');
            }
            var sub_id = setup_hedge_item.form_setup_hedge_item.getItemValue('sub_id');
            if (sub_id == '') {
                setup_hedge_item.form_setup_hedge_item.disableItem('label_book_deal_type_map_id');
            }   
        });
    
        setup_hedge_item.save_click = function() {
            var param_list = new Array();
            var form_obj = setup_hedge_item.form_setup_hedge_item;
            var status = validate_form(form_obj);
            setup_hedge_item.validation_status = 1;
            if (status) {
                data = form_obj.getFormData();
                for (var a in data) {
                    var field_label = a;
                    
                    if (form_obj.getItemType(field_label) == 'calendar') {
                        var field_value = form_obj.getItemValue(field_label, true);
                    } else {
                        var field_value = data[field_label];
                    }

                    if (!field_value)
                        field_value = '';
                    
                    field_label = (field_label == 'book_id') ? 'fas_book_id' : field_label;
                    
                    if (field_label.indexOf('label') == -1) //ignore fields with label 
                        {
                            form_xml = " @" + field_label + "=\'" + field_value + "'";
                            param_list.push(form_xml);
                        }
                }            
            } else {
                setup_hedge_item.validation_status = 0;
            }
            
            var param_string = param_list.toString();
            param_string = param_string.replace(/''/g, 'NULL');
            
            if ((form_obj.getItemValue('fixed_float_flag') == 't') && (form_obj.getItemValue('source_curve_def_id') == '')) {
                dhtmlx.message({
                    title:'Error',
                    type:"alert-error",
                    text:"Please select an index for a Floating Leg."
                });
                return;
            }
            
            if (!setup_hedge_item.validation_status) {
                generate_error_message();
                return;
            } 
            
            var data = {
                            "action": "spa_effhedgereltypedetail @flag='" + mode + "'," + param_string
                        };
            adiha_post_data('return_array', data, '', '', 'save_callback', ''); 
        }
                
        function save_callback(result) {
            if (result[0][3] == 'Success') {
                document.getElementById("success_status").value = 'Success';
                var win_obj = window.parent.popup_window.window("w1");
                win_obj.close();
                //eval('parent.unload_window(result)');
            } else {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: result[0][4]
                });
            }
             
        }  
        
        function item_changed(id) {
            switch (id) {
                case 'fixed_float_flag':
                    var fixed_float = setup_hedge_item.form_setup_hedge_item.getItemValue('fixed_float_flag');
                
                    if (fixed_float == 'f') {
                        setup_hedge_item.form_setup_hedge_item.disableItem('source_curve_def_id');
                        setup_hedge_item.form_setup_hedge_item.setItemValue('source_curve_def_id', '');
                    } else {
                       setup_hedge_item.form_setup_hedge_item.enableItem('source_curve_def_id'); 
                    }
                    break;
                case 'sub_id':
                    var sub_id = setup_hedge_item.form_setup_hedge_item.getItemValue('sub_id');
                    if (sub_id == '') {
                        setup_hedge_item.form_setup_hedge_item.disableItem('label_book_deal_type_map_id');
                    } else {
                        setup_hedge_item.form_setup_hedge_item.enableItem('label_book_deal_type_map_id');
                    }
                    break;
            }
            if (id == 'fixed_float_flag') {
                
            }
        }
        
        function load_browser_field(result) {
            setup_hedge_item.form_setup_hedge_item.setItemValue('book_deal_type_map_id', result[0]); 
            setup_hedge_item.form_setup_hedge_item.setItemValue('label_book_deal_type_map_id', result[2]); 
        }
    </script> 
</html>