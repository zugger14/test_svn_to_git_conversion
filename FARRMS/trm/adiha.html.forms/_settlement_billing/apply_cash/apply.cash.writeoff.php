<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
</head>

<body>
<?php
	require('../../../adiha.php.scripts/components/include.file.v3.php');

    $get_calc_id = get_sanitized_value($_GET['calc_id'] ?? 'NULL');
    $get_as_of_date = get_sanitized_value($_GET['as_of_date'] ?? 'NULL');
    $get_prod_date = get_sanitized_value($_GET['prod_date'] ?? 'NULL');
    $get_save_invoice_detail_id = get_sanitized_value($_GET['save_invoice_detail_id'] ?? 'NULL');
    $get_amount = get_sanitized_value($_GET['amount'] ?? 'NULL');
    $get_invoice_line_item_id = get_sanitized_value($_GET['invoice_line_item_id'] ?? 'NULL');

    $namespace = 'applyCash_writeOff';

    // Layout
    $layout_json = '[
        {
            id        : "a",
            text      : "Apply Cash Write Off",
            width     : 500,
            height    : 250,
            header    : false,
            collapse  : false,
            fix_size  : [false, null]
        }
    ]';

    $writeOff_layout = new AdihaLayout();
    echo $writeOff_layout->init_layout('writeOff_layout', '', '1C', $layout_json, $namespace); 

    $menu_json = '[{id:"save", img:"save.gif", title:"Save"}]';

    $writeOff_menu = new AdihaMenu();
    echo $writeOff_layout->attach_menu_cell("apply_cash_menu", "a"); 
    echo $writeOff_menu->init_by_attach("apply_cash_menu", $namespace);
    echo $writeOff_menu->load_menu($menu_json);
    echo $writeOff_menu->attach_event("", "onClick", "on_save_click");

    /*Form*/
    $form_name = 'writeOff_form';
    echo $writeOff_layout->attach_form($form_name, 'a');
    $writeOff_form = new AdihaForm();

    $form_json = '[
        {type: "settings", position: "label-top"},
        {type: "block", list: [
            {type: "calendar", name: "as_of_date", label: "As of Date", width: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].'},
            {type: "newcolumn"},
            {type: "calendar", name: "production_month", label: "Production Month", width: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].'},
            {type: "newcolumn"},
            {type: "combo", name: "contract_components", label: "Contract Components", width: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].', options: [], userdata:{\'validation_message\':\'Invalid Selection\'}},
            {type: "newcolumn"},
            {type: "calendar", name: "invoice_production_month", label: "Invoice Production Month", width: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].'},
            {type: "newcolumn"},
            {type: "combo", name: "gl_account_estimates", label: "GL Account Estimates", width: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].', options: [], required: true, userdata:{\'validation_message\':\'Invalid Selection\'}},
            {type: "newcolumn"},
            {type: "combo", name: "gl_account_actual", label: "GL Account Actual", width: '.$ui_settings['field_size'].', options: [], required: true, offsetLeft: '.$ui_settings['offset_left'].', userdata:{\'validation_message\':\'Invalid Selection\'}},
            {type: "newcolumn"},
            {type: "input", name: "volume", label: "Volume", width: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].' , validate: "ValidNumeric", userdata:{\'validation_message\':\'Invalid Number\'}},
            {type: "newcolumn"},
            {type: "combo", name: "uom", label: "UOM", width: '.$ui_settings['field_size'].', options: [], offsetLeft: '.$ui_settings['offset_left'].', userdata:{\'validation_message\':\'Invalid Selection\'}},
            {type: "newcolumn"},
            {type: "input", name: "value", label: "Value", width: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].', validate: "ValidNumeric", userdata:{\'validation_message\':\'Invalid Number\'}},
             {type: "newcolumn"},
            {type: "input", name: "remarks", label: "Remarks", width: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].'},
            {type: "newcolumn"},
            {type: "checkbox", name: "volume_include", label: "Include volume in report", position: "label-right",labelWidth: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].', offsetTop: '. $ui_settings['checkbox_offset_top'] .'},
            {type: "newcolumn"},
            {type: "checkbox", name: "inventory", label: "Inventory", position: "label-right",labelWidth: '.$ui_settings['field_size'].', offsetLeft: '.$ui_settings['offset_left'].', offsetTop: '. $ui_settings['checkbox_offset_top'] .'}
        ]}
    ]';

    
    echo $writeOff_form->init_by_attach($form_name, $namespace);
    echo $writeOff_form->load_form($form_json);

    echo $writeOff_layout->close_layout();

    ?>

    <script type="text/javascript">
    dhxWins = new dhtmlXWindows();
        
    $(function() {
        var as_of_date = new Date('<?php echo $get_as_of_date; ?>');
        var prod_date = new Date('<?php echo $get_prod_date; ?>'); 
        var amount = '<?php echo $get_amount; ?>'; 
        var user_date_fromat = '<?= $date_format; ?>';

        var contract_components_obj = applyCash_writeOff.writeOff_form.getCombo('contract_components');
        contract_components_obj.enableFilteringMode(true);
        var gl_account_estimates_obj = applyCash_writeOff.writeOff_form.getCombo('gl_account_estimates');
        gl_account_estimates_obj.enableFilteringMode(true);
        var gl_account_actual_obj = applyCash_writeOff.writeOff_form.getCombo('gl_account_actual');
        gl_account_actual_obj.enableFilteringMode(true);
        var uom_obj = applyCash_writeOff.writeOff_form.getCombo('uom');
        uom_obj.enableFilteringMode(true);

        applyCash_writeOff.writeOff_form.setCalendarDateFormat('as_of_date', user_date_format);
        applyCash_writeOff.writeOff_form.setCalendarDateFormat('production_month', user_date_format);
        applyCash_writeOff.writeOff_form.setCalendarDateFormat('invoice_production_month', user_date_format);

        applyCash_writeOff.writeOff_form.setItemValue('as_of_date', as_of_date);
        applyCash_writeOff.writeOff_form.setItemValue('production_month', prod_date);
        applyCash_writeOff.writeOff_form.setItemValue('invoice_production_month', prod_date);
        applyCash_writeOff.writeOff_form.setItemValue('value', amount);

        var sql_contract_components = {
            "action" : "('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10019')"
        };

        var url_sql_contract_components = js_dropdown_connector_url + '&' + $.param(sql_contract_components) + "&has_blank_option=false";
        var combo_contract_components = applyCash_writeOff.writeOff_form.getCombo('contract_components');
        combo_contract_components.load(url_sql_contract_components, function() {
            combo_contract_components.selectOption(0);
        });

        var sql_gl_account_estimates = {
            "action"            : "spa_get_adjustment_defaultGLCode",
            "flag"              : "c",
            "estimated_actual"  : "e"
        };

        var url_sql_gl_account_estimates = js_dropdown_connector_url + '&' + $.param(sql_gl_account_estimates) + "&has_blank_option=false";
        var combo_gl_account_estimates = applyCash_writeOff.writeOff_form.getCombo('gl_account_estimates');
        combo_gl_account_estimates.load(url_sql_gl_account_estimates, function() {
            combo_gl_account_estimates.selectOption(0);            
        });

        var sql_gl_account_actual = {
            "action"            : "spa_get_adjustment_defaultGLCode",
            "flag"              : "c",
            "estimated_actual"  : "a"
        };

        var url_sql_gl_account_actual = js_dropdown_connector_url + '&' + $.param(sql_gl_account_actual) + "&has_blank_option=false";
        var combo_gl_account_actual = applyCash_writeOff.writeOff_form.getCombo('gl_account_actual');
        combo_gl_account_actual.load(url_sql_gl_account_actual, function() {
            combo_gl_account_actual.selectOption(0);
        });

        var sql_uom = {
            "action"                : "spa_getsourceuom",
            "flag"                  : "s",
            "eff_test_profile_id"   : "NULL"
        };

        var url_sql_uom = js_dropdown_connector_url + '&' + $.param(sql_uom) + "&has_blank_option=false";
        var combo_uom = applyCash_writeOff.writeOff_form.getCombo('uom');
        combo_uom.load(url_sql_uom, function() {
            combo_uom.selectOption(0);
        });

    });

    function on_save_click(id) {

        var calc_id = '<?php echo $get_calc_id; ?>'; 
        var save_invoice_detail_id = '<?php echo $get_save_invoice_detail_id; ?>'; 
        var invoice_line_item_id = '<?php echo $get_invoice_line_item_id; ?>';

        var as_of_date = applyCash_writeOff.writeOff_form.getItemValue('as_of_date', true);
        var invoice_production_month = applyCash_writeOff.writeOff_form.getItemValue('invoice_production_month', true);
        var production_month = applyCash_writeOff.writeOff_form.getItemValue('production_month', true);

        writeOff_data = applyCash_writeOff.writeOff_form.getFormData();

        var is_validated = validate_form(applyCash_writeOff.writeOff_form);

        if(!is_validated) {
            return;
        }

        var sql_save = {
            "action" : "spa_calc_invoice_volume_input",
            "flag"   : "i",
            "counterparty_id" : "NULL",
            "calc_detail_id" : "NULL",
            "calc_id" : calc_id,
            "invoice_line_item_id" : invoice_line_item_id,
            "prod_date" : production_month,
            "value" : writeOff_data['value'],
            "volume" : writeOff_data['volume'],
            "default_gl_id" : writeOff_data['gl_account_actual'],
            "uom_id" : writeOff_data['uom'],
            "sub_id" : writeOff_data['contract_components'],
            "remarks" : writeOff_data['remarks'],
            "as_of_date" : as_of_date,
            "finalized" : 'y',
            "adjustment_type" : 'NULL',
            "finalized_id" : 'NULL',
            "inv_prod_date" : invoice_production_month,
            "include_volume" : writeOff_data['volume_include'],
            "default_gl_id_estimate" : writeOff_data['gl_account_estimates'],
            "inventory" : writeOff_data['inventory'],
            "invoice_type" : 'NULL',
            "contract_id" : 'NULL',
            "apply_cash_calc_detail_id" : save_invoice_detail_id
        }

        // var res = adiha_post_data("return_json", sql_save, '', '', 'parent.on_writeOff_success');
        var res = adiha_post_data("return_json", sql_save, '', '', 'after_save_onclick');
    }

    function after_save_onclick(result) {
        var result = JSON.parse(result);
        var response = result[0];

        if(response["errorcode"] == 'Success') {
            var save_invoice_detail_id = '<?php echo $get_save_invoice_detail_id; ?>'; 
            var sql = {
                        "action" : "spa_apply_cash_module",
                        "flag"   : "x",
                        "counterparty_id" : "NULL",
                        "save_invoice_detail_id" : save_invoice_detail_id
                    };
            adiha_post_data("return_json", sql, '', '', 'parent.on_writeOff_success');
        } else {
            dhtmlx.alert({
                        title:"Error",
                        type:"alert-error",
                        text:response['message']
                    }); 
        }

    }

    </script>



