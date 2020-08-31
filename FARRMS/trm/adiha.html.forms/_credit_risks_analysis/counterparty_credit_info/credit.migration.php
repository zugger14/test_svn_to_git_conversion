<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <html>
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $function_id = 10101132;
    $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? 'NULL');
    $counterparty_credit_info_id = get_sanitized_value($_GET['counterparty_credit_info_id'] ?? 'NULL');
    $counterparty_credit_migration_id = isset($_GET['counterparty_credit_migration_id']) ? get_sanitized_value($_GET['counterparty_credit_migration_id']) : NULL;
    $internal_counterparty_id = get_sanitized_value($_GET['internal_counterparty_id'] ?? '');
    $mode = get_sanitized_value($_GET['mode']);

    $tab_json = '';

    //Loads data for form from backend.
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10101132', @template_name='CounterpartyCreditInfoMigrate', @parse_xml='<Root><PSRecordset counterparty_credit_migration_id=" . '"' . $counterparty_credit_migration_id . '"' . "></PSRecordset></Root>'";
    $return_value1 = readXMLURL($xml_file);
    
    //creating main layout for the form
    $form_namespace = 'cci_migrate';
    $layout = new AdihaLayout();

    //json for main layout.
    $json = '[
        {
            id:             "a",
            text:           "Counterparty Credit Info - Migration",
            header:         false,
            collapse:       false,
            width:          200,
            fix_size:       [true,null]
        }
    ]';
    
    echo $layout->init_layout('new_layout', '', '1C', $json, $form_namespace);

    //json for toolbar.
    $save_button_json = '[
        {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"}
    ]';
    
    //Attaching a toolbar to save button
    $toolbar_name = 'toolbar';
    echo $layout->attach_toolbar_cell($toolbar_name, 'a');
    $toolbar_obj = new AdihaToolbar();
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($save_button_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'cci_migrate.save_cci_migrate_detail');
    
    //attaching form to main layout
    
    foreach ($return_value1 as $temp1) {
        $form_json = $temp1[2];
        $form_name = 'cci_migrate_form';
        if ($form_json) {
            echo $layout->attach_form($form_name, 'a');
            $form_obj = new AdihaForm();
            echo $form_obj->init_by_attach($form_name, $form_namespace);
            echo $form_obj->load_form($form_json);
        }
    }
    echo $layout->close_layout();
    ?>
    <form name="<?php echo $form_name; ?>">
        <textarea id='xml_ids' name="xml_ids" style="display:none;"></textarea>
        <input type="hidden" id="dropdown" name="dropdown">
        <div id="layoutObj"></div>
    </form>
    <script>
    var session = "<?php echo $session_id; ?>";
    var php_script_loc = "<?php echo $php_script_loc; ?>";
    var mode = "<?php echo $mode;?>";
    var function_id = <?php echo $function_id;?>;
    dhxWins = new dhtmlXWindows();

    if (mode == 'i') {
        var counterparty_credit_info_id = <?php echo $counterparty_credit_info_id;?>;
    }

    var counterparty_id = <?php echo $counterparty_id; ?>;

    var internal_counterparty_id = '<?php echo $internal_counterparty_id; ?>';

    dhxWins = new dhtmlXWindows();

    $(function() {
        var combo_internal_counterparty = cci_migrate.cci_migrate_form.getCombo('internal_counterparty');
        var combo_counterparty = cci_migrate.cci_migrate_form.getCombo('counterparty');
        var combo_contract = cci_migrate.cci_migrate_form.getCombo('contract');  
        // var default_format = cci_migrate.cci_migrate_form.getUserData("internal_counterparty", "default_format");

        var counterparty_combo_value, counterparty_index, contract_combo_value, contract_index, internal_counterparty_combo_value, internal_counterparty_index;
        if (mode == 'u') {
            contract_combo_value = combo_contract.getSelectedValue();
            counterparty_combo_value = combo_counterparty.getSelectedValue();
            internal_counterparty_combo_value = combo_internal_counterparty.getSelectedValue();
        }   

        // Initial internal_counterparty_id combo option
        var ici_sql = {
            "action"            : "spa_getsourcecounterparty",
            "flag"              : "s"
        }
        combo_counterparty.clearAll();
        cci_migrate.load_combo(combo_counterparty, ici_sql);


        // Initial internal_counterparty_id combo option
        var ici_sql = {
            "action"            : "spa_getsourcecounterparty",
            "flag"              : "o",
            "counterparty_type" : "i",
            "counterparty_id"   : counterparty_id
        }
        combo_internal_counterparty.clearAll();
        cci_migrate.load_combo(combo_internal_counterparty, ici_sql);

        // Initial contract_id combo option
        var combo_sql = {
            "action"            : "spa_source_contract_detail",
            "flag"              : "r",
            "counterparty_id"   : counterparty_id
        }
        combo_contract.clearAll();
        cci_migrate.load_combo(combo_contract, combo_sql);

        setTimeout(function() {
            counterparty_index = combo_counterparty.getIndexByValue(counterparty_combo_value);

            combo_counterparty.forEachOption(function(optId){
                if (optId.value == counterparty_id) {
                    combo_counterparty.selectOption(optId.index);
                }
            });

            combo_internal_counterparty.forEachOption(function(optId){
                if (trim(optId.text) == internal_counterparty_id) {
                    combo_internal_counterparty.selectOption(optId.index);
                }
            });

            combo_internal_counterparty.forEachOption(function(optId){
                if (optId.value == internal_counterparty_combo_value && mode == 'u') {
                    combo_internal_counterparty.selectOption(optId.index);
                } else if(optId.value == '') {
                    combo_internal_counterparty.selectOption(optId.index);
                }
            });
			
			combo_contract.forEachOption(function(optId){
            	if (optId.value == contract_combo_value && mode == 'u') {
            		combo_contract.selectOption(optId.index);
            	} else if(optId.value == '') {
            		combo_contract.selectOption(optId.index);
            	}
			});
			cci_migrate.cci_migrate_form.disableItem('counterparty');
        }, 1000);

    });

    cci_migrate.load_combo = function(combo_obj, combo_sql) {
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj.load(url);
    }

    cci_migrate.save_cci_migrate_detail = function(id) {
        if (id == 'save') {
            var form_xml = '<Root function_id="10101132"><FormXML ';
            data = cci_migrate.cci_migrate_form.getFormData();
            var validation_status = true;
            var status = validate_form(cci_migrate.cci_migrate_form);
            if (status == false) {
                validation_status = false;
                return false;
            }

            for (var a in data) {
                field_label = a;
                
                if (mode == 'i' && field_label == 'counterparty_credit_info_id') {
                    field_value = counterparty_credit_info_id;
                } else if (cci_migrate.cci_migrate_form.getItemType(a) == "calendar") {
                    field_value = cci_migrate.cci_migrate_form.getItemValue(a, true);
                }  else {
                    field_value = data[a];
                }
                if (mode == 'i') {
                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                }
                if (mode == 'u' && field_label != 'counterparty_credit_info_id') {
                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                }
            }
            form_xml += "></FormXML></Root>";
            
            if(validation_status){  
                data = {"action": "spa_process_form_data", flag: "u", "xml": form_xml};
                adiha_post_data("alert", data, "", "", "parent.cci_namespace.callback_migration_grid_refresh");
            }
        }
    }
    </script>
<div id="myToolbar1"></div>


        
        


