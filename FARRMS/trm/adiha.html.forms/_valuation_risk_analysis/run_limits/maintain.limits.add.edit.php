<?php
/**
* Maintain limits add edit screen
* @copyright Pioneer Solutions
*/
?>
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

    $rights_limit_iu = 10181316;
    $layout_name = 'layout';
    $layout_json = '[{id:"a", header: false}]';
    $name_space = 'limits';
    
    list (
        $has_right_limit_iu
    ) = build_security_rights(
        $rights_limit_iu
    );

    $save_button_state = empty($has_right_limit_iu) ? 'true' : 'false';
    $mode = get_sanitized_value($_GET['mode'] ?? 'i');
    $limit_id = get_sanitized_value($_GET['limit_id'] ?? 'NULL');
    $maintain_limit_id = get_sanitized_value($_GET['maintain_limit_id'] ?? 'NULL');

    //Creating Layout
    $limits_iu_layout = new AdihaLayout();
    echo $limits_iu_layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

    // Attaching Toolbar 
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar_limits';

    $toolbar_json = '[ {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled:' . $save_button_state . '}]';

    echo $limits_iu_layout->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'save_form');

    $form_obj = new AdihaForm();
    $form_name = 'limits_form';
    echo $limits_iu_layout->attach_form($form_name, 'a');
    
    $form_structure = "[
        {type:'combo', label:'Limit Type', name:'limit_type', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', required: true, userdata:{'validation_message':'Required Field'}, offsetLeft:" . $ui_settings['offset_left'] . "},
        {type:'newcolumn'},
        {type:'numeric', label:'Min Limit Value', name:'min_limit_value', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', required: false, userdata:{'validation_message':'Invalid Number'}, validate: 'ValidNumeric', offsetLeft:" . $ui_settings['offset_left'] . "},
        {type:'newcolumn'},
        {type:'numeric', label:'Max Limit Value', name:'limit_value', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', required: true, userdata:{'validation_message':'Invalid Number'}, validate: 'ValidNumeric', offsetLeft:" . $ui_settings['offset_left'] . "},
        {type:'newcolumn'},
        {type:'input', label:'Limit Percentage', name:'limit_percentage', hidden : true, width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', required: false, userdata:{'validation_message':'Invalid Number'}, validate: 'ValidNumeric', offsetLeft:" . $ui_settings['offset_left'] . "},
        {type:'newcolumn'},
        {type:'combo', label:'Limit UOM', name:'limit_uom', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
        {type:'newcolumn'},
        {type:'combo', label:'Limit Currency', name:'limit_currency', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
        {type:'newcolumn'},
        {type:'combo', label:'Deal Type', name:'deal_type', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
        {type:'newcolumn'},
        {type:'combo', label:'Index', name:'curve_id', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
        {type:'newcolumn'},
        {type:'combo', label:'At Risk Criteria', name:'var_criteria_det_id', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
        {type:'newcolumn'},
        {type:'combo', label:'Tenor Granularity', name:'tenor_granularity', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
        {type:'newcolumn'},
        {type:'input', label:'Tenor From', name:'tenor_month_from', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth:'auto', offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Number'}},
        {type:'newcolumn'},
        {type:'input', label:'Tenor To', name:'tenor_month_to', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Number'}},
        {type:'newcolumn'},
        {type:'input', label:'Tenor Duration', name:'tenor_duration', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', hidden: true, offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Number'}},
        {type:'newcolumn'},
        {type:'input', label:'Delivery Duration', name:'delivery_duration', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth:'auto', hidden :true , offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Number'}},
        {type:'newcolumn'},
        {type:'input', name:'limit_id', hidden:true, value:'$limit_id'},
        {type:'input', name:'maintain_limit_id', hidden:true, value:'$maintain_limit_id'},
        {type:'newcolumn'},
        {type:'combo', label:'Deal SubType', name:'deal_subtype', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft:" . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
        {type:'newcolumn'},
        {type:'calendar', label:'Effective Date', name:'effective_date' ,dateFormat:'". $date_format . "',serverDateFormat: '%Y-%m-%d', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . "},
        {type:'newcolumn'},
        {type:'input', label:'Logical Description', name:'logical_description', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . ", rows: 3},
        {type:'newcolumn'},
        {type:'checkbox', label:'Active', name:'is_active', width:" . $ui_settings['field_size'] . ", position: 'label-right', offsetLeft:" . $ui_settings['offset_left'] . ", offsetTop:'30', checked:true}

    ]";
    echo $form_obj->init_by_attach($form_name, $name_space);
    echo $form_obj->load_form($form_structure);
    echo $limits_iu_layout->close_layout();
    ?>
</body>

<script type="text/javascript">
    var mode = '<?php echo $mode;?>';
    var limit_id = '<?php echo $limit_id;?>';
    var maintain_limit_id = '<?php echo $maintain_limit_id;?>';
    var save_button_state = '<?php echo $save_button_state;?>';
    var has_right_limit_iu = '<?php echo $has_right_limit_iu;?>';
    dhxWins = new dhtmlXWindows();

    $(function () {
        var form_name = limits.limits_form;
        limits.layout.progressOn();

        var combo_limit_type = form_name.getCombo("limit_type");
        var combo_var_criteria_det_id = form_name.getCombo("var_criteria_det_id");
        var combo_deal_type = form_name.getCombo("deal_type");
        var combo_index = form_name.getCombo("curve_id");
        var combo_limit_uom = form_name.getCombo("limit_uom");
        var combo_limit_currency = form_name.getCombo("limit_currency");
        var combo_tenor_granularity = form_name.getCombo("tenor_granularity");
        var limit_value = form_name.getInput('limit_value');
        var tenor_month_from = form_name.getInput('tenor_month_from');
        var tenor_month_to = form_name.getInput('tenor_month_to');
        
        load_options(1);
        combo_limit_type.selectOption(0);
        
        combo_limit_type.attachEvent("onChange", function(value, text) {  
            switch(value) 
            {
                case '1585':
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.showItem('var_criteria_det_id');
                    form_name.hideItem('deal_type');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('limit_uom');
                    form_name.showItem('limit_currency');
                    form_name.hideItem('tenor_granularity');
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                break;
                case '1586':
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.showItem('var_criteria_det_id');
                    form_name.hideItem('deal_type');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('limit_uom');
                    form_name.showItem('limit_currency');
                    form_name.hideItem('tenor_granularity');
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                    form_name.showItem('deal_subtype');
                break;
                case '1580':
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.hideItem('var_criteria_det_id');
                    form_name.showItem('deal_type');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('limit_uom');
                    form_name.showItem('limit_currency');
                    form_name.hideItem('tenor_granularity');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                    form_name.showItem('deal_subtype');
                break;
                case '1581':
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.showItem('tenor_month_from');
                    form_name.showItem('tenor_month_to');
                    form_name.hideItem('var_criteria_det_id');
                    form_name.showItem('deal_type');
                    form_name.showItem('curve_id');
                    form_name.showItem('limit_uom');
                    form_name.hideItem('limit_currency');
                    form_name.showItem('tenor_granularity');
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                    form_name.showItem('deal_subtype');

                    form_name.setRequired('tenor_month_from', true);
                    form_name.setValidation('tenor_month_from', "ValidInteger");
                    form_name.setRequired('tenor_month_to', true);
                    form_name.setValidation('tenor_month_to', "ValidInteger");
                    form_name.setRequired('tenor_granularity', true);
                    form_name.setValidation('tenor_granularity', "ValidInteger");
                break;
                case '1588':
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.hideItem('var_criteria_det_id');
                    form_name.showItem('deal_type');
                    form_name.showItem('curve_id');
                    form_name.showItem('limit_uom');
                    form_name.hideItem('limit_currency');
                    form_name.hideItem('tenor_granularity');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                    form_name.showItem('deal_subtype');
                break;
                case '1583':
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.showItem('var_criteria_det_id');
                    form_name.hideItem('deal_type');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('limit_uom');
                    form_name.hideItem('limit_currency');
                    form_name.hideItem('tenor_granularity');
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                    form_name.showItem('deal_subtype');
                break;
                case '1582':
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.showItem('var_criteria_det_id');
                    form_name.hideItem('deal_type');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('limit_uom');
                    form_name.hideItem('limit_currency');
                    form_name.hideItem('tenor_granularity');
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                    form_name.showItem('deal_subtype');
                break;
                case '1587':
                    form_name.hideItem('limit_value');
                    form_name.setRequired("limit_value", false);
                    form_name.showItem('tenor_month_from');
                    form_name.showItem('tenor_month_to');
                    form_name.hideItem('var_criteria_det_id');
                    form_name.showItem('deal_type');
                    form_name.showItem('curve_id');
                    form_name.hideItem('limit_uom');
                    form_name.hideItem('limit_currency');
                    form_name.showItem('tenor_granularity');
                    form_name.hideItem('limit_percentage');
                    form_name.hideItem('min_limit_value');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('limit_percentage');
                    form_name.showItem('deal_subtype');

                    form_name.setRequired('tenor_month_from', true);
                    form_name.setValidation('tenor_month_from', 'ValidInteger');
                    form_name.setRequired('tenor_month_to', true);
                    form_name.setValidation('tenor_month_to', "ValidInteger");
                    form_name.setRequired('tenor_granularity', true);
                    form_name.setValidation('tenor_granularity', "ValidInteger");
                break;
                case '1584':
                    form_name.showItem('deal_subtype');
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.showItem('var_criteria_det_id');
                    form_name.hideItem('deal_type');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('limit_uom');
                    form_name.showItem('limit_currency');
                    form_name.hideItem('tenor_granularity');
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                break;
                case '1596':
                    form_name.hideItem('limit_uom');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('var_criteria_det_id');
                    form_name.hideItem('tenor_granularity');
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.showItem('deal_subtype');
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.showItem('min_limit_value');
                    form_name.showItem('limit_currency');
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('limit_percentage');
                    form_name.showItem('deal_type');
                    break;
                case '1597':
                    form_name.showItem('limit_percentage');
                    form_name.showItem('limit_currency');
                    form_name.hideItem('limit_uom');
                    form_name.hideItem('var_criteria_det_id');
                    form_name.hideItem('tenor_granularity');
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.hideItem('deal_subtype');
                    form_name.showItem('curve_id');
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('tenor_duration');
                    break;
                case '1598':
                    form_name.showItem('deal_type');
                    form_name.showItem('tenor_granularity');
                    form_name.setRequired('tenor_granularity', true);
                    form_name.showItem('tenor_duration');
                    form_name.setRequired('tenor_duration', true);
                    form_name.setValidation('tenor_duration', 'ValidInteger');
                    form_name.showItem('delivery_duration');
                    form_name.setRequired('delivery_duration', true);
                    form_name.setValidation('delivery_duration', 'ValidInteger');
                    form_name.showItem('deal_subtype');
                    form_name.setRequired('limit_value',false);

                    form_name.hideItem('limit_percentage');
                    form_name.hideItem('limit_value');
                    form_name.hideItem('min_limit_value');
                    form_name.hideItem('limit_uom');
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.hideItem('limit_currency');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('var_criteria_det_id');
                break;
                case '1599':
                    form_name.showItem('deal_type');
                    form_name.hideItem('tenor_granularity');
                    form_name.hideItem('tenor_duration');
                    form_name.hideItem('delivery_duration');
                    form_name.hideItem('deal_subtype');
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);

                    form_name.hideItem('limit_percentage');
                    form_name.showItem('min_limit_value');
                    form_name.hideItem('limit_uom');
                    form_name.hideItem('tenor_month_from');
                    form_name.hideItem('tenor_month_to');
                    form_name.showItem('limit_currency');
                    form_name.hideItem('curve_id');
                    form_name.hideItem('var_criteria_det_id');
                break;   
                default:
                    form_name.showItem('limit_value');
                    form_name.setRequired("limit_value", true);
                    form_name.showItem('tenor_month_from');
                    form_name.showItem('tenor_month_to');
                    form_name.showItem('var_criteria_det_id');
                    form_name.showItem('deal_type');
                    form_name.showItem('curve_id');
                    form_name.showItem('limit_uom');
                    form_name.showItem('limit_currency');
                    form_name.showItem('tenor_granularity');
                break;
            }
        });
    });
    /**
     * [Saves using merge]
     */
    function save_form(id) {
        var form_name = limits.limits_form;
        var form_xml = '<Root function_id=""><FormXML ';
        var validation_status = true;
        var status = validate_form(form_name);

        if (!status) {
            generate_error_message();
            validation_status = false;
        }
        
        data = form_name.getFormData();

        for (var a in data) {
            field_label = a;
            if (form_name.isItemHidden(field_label) && field_label != 'limit_id' && field_label != 'maintain_limit_id') {
                field_value = '';
                form_name.setItemValue(field_label, '');
            } else {
            if (form_name.getItemType(field_label) == 'calendar') {
                field_value = form_name.getItemValue(field_label, true);
            }
            else {
            field_value = data[a];
            }
            }
            if(field_label == 'tenor_month_to')
                tenor_month_to_value = field_value;
            if(field_label == 'tenor_month_from')
                tenor_month_from_value = field_value;
            if (field_value == 0 &&  field_label != 'logical_description' && field_label != 'tenor_month_to' && field_label != 'tenor_month_from' && field_label != 'tenor_duration' && field_label != 'delivery_duration') {
                field_value = null;
            }
            if (field_value == null && field_label == 'effective_date'){
                field_value = '';
            }
            form_xml += " " + field_label + "=\"" + field_value + "\"";    
        }
        form_xml += "></FormXML></Root>";
        if (tenor_month_from_value != '' && tenor_month_to_value != '' && parseInt(tenor_month_from_value) > parseInt(tenor_month_to_value)) {
            validation_status = false;
            show_messagebox('<strong>Tenor To</strong> should be greater than <strong>Tenor From</strong>.');
        }
        
        if(validation_status){  
            load_options(0); // Reload all the combo except Limit Type.
            limits.toolbar_limits.disableItem('save');
            data = {"action": "spa_maintain_limit", flag: mode, "xml": form_xml};
            adiha_post_data("alert", data, "", "", "save_callback");
        }
    }
    /**
     *
     */
    function save_callback(result) {
        if(has_right_limit_iu) {
            limits.toolbar_limits.enableItem('save');
        }
        if (result[0].errorcode == 'Success') {
            if (result[0].recommendation != '') {
                limits.limits_form.setItemValue("maintain_limit_id", result[0].recommendation);
                mode = 'u';
            }
            parent.limit_grid_refresh();
        }
        after_save();
    }
    /**
     *
     */

    function after_save() {
        setTimeout('parent.pop_win.close()', 1000);
     }

    function load_options(status) {        
        var form_name = limits.limits_form;
        var combo_limit_type = form_name.getCombo("limit_type");
        var combo_var_criteria_det_id = form_name.getCombo("var_criteria_det_id");
        var combo_deal_type = form_name.getCombo("deal_type");
        var combo_index = form_name.getCombo("curve_id");
        var combo_limit_uom = form_name.getCombo("limit_uom");
        var combo_limit_currency = form_name.getCombo("limit_currency");
        var combo_tenor_granularity = form_name.getCombo("tenor_granularity");
        var combo_sub_dealtype = form_name.getCombo("deal_subtype");

        var combo_limit_type_sql = {"action":"spa_staticdatavalues", "flag":"h", "type_id":1580 };
        var combo_var_criteria_det_id_sql = {"action":"spa_var_measurement_criteria_detail", "flag":"n"};
        var combo_deal_type_sql = {"action":"spa_source_deal_type_maintain", "flag":"x"};
        var combo_index_sql = {"action":"spa_source_price_curve_def_maintain", "flag":"l"};
        var combo_limit_uom_sql = {"action":"spa_source_uom_maintain", "flag":"s"};
        var combo_limit_currency_sql = {"action":"spa_source_currency_maintain", "flag":"b"};
        var combo_tenor_granularity_sql = {"action":"spa_staticdatavalues", "flag":"h", "type_id":978};
        var combo_sub_dealtype_sql = {"action":"spa_source_deal_type_maintain", "flag":"x", "sub_type":"y"};
            
        if(mode == 'i'){
            if(status){
                load_combo(combo_limit_type, combo_limit_type_sql, 0, false);
            }
            load_combo(combo_var_criteria_det_id, combo_var_criteria_det_id_sql, 0, true); 
            load_combo(combo_deal_type, combo_deal_type_sql, 0, true); 
            load_combo(combo_index, combo_index_sql, 0, true);  
            load_combo(combo_limit_uom, combo_limit_uom_sql, 0, true); 
            load_combo(combo_limit_currency, combo_limit_currency_sql, 0, true); 
            load_combo(combo_sub_dealtype , combo_sub_dealtype_sql , 0 , true );
            load_combo(combo_tenor_granularity, combo_tenor_granularity_sql, 0, false, '', 1);   
        }
        else if(mode == 'u'){
            var data =  { "sp_string": "EXEC spa_maintain_limit @flag = 'a', @maintain_limit_id = " + maintain_limit_id};
            adiha_post_data('return_array', data, '', '', function(result) {
                if(status) {
                    if (mode == 'u') {
                    load_combo(combo_limit_type, combo_limit_type_sql, 0, false, result[0][3]);
                    }
                }
                
                form_name.setItemValue('limit_value', result[0][7]);

                if(result[0][10] != null && result[0][10] != '' && result[0][3] == '1598' ) {
                    form_name.setItemValue('tenor_duration', result[0][10].toString());
                } else if(result[0][10] != null && result[0][10] != '') {
                    form_name.setItemValue('tenor_month_from', result[0][10].toString());
                }
            
                if(result[0][11] != null && result[0][11] != '' && result[0][3] == '1598' ){
                    form_name.setItemValue('delivery_duration', result[0][11].toString());
                } else if (result[0][11] != null && result[0][11] != '' ) {
                    form_name.setItemValue('tenor_month_to', result[0][11].toString());
                }

                if (result[0][14] != null && result[0][14] != '' ) {
                    form_name.setItemValue('effective_date', result[0][14]);
                } else {
                    form_name.setItemValue('effective_date', '');
                }

                form_name.setItemValue('limit_percentage', result[0][17]);         
                form_name.setItemValue('min_limit_value', result[0][16]);
                form_name.setItemValue('logical_description', result[0][1]);
                load_combo(combo_var_criteria_det_id, combo_var_criteria_det_id_sql, 0, true, result[0][4]); 
                load_combo(combo_deal_type, combo_deal_type_sql, 0, true, result[0][5]);  
                load_combo(combo_index, combo_index_sql, 0, true, result[0][6]);  
                load_combo(combo_limit_uom, combo_limit_uom_sql, 0, true,result[0][8]); 
                load_combo(combo_limit_currency, combo_limit_currency_sql, 0, true,result[0][9]); 
                load_combo(combo_sub_dealtype, combo_sub_dealtype_sql ,0, true,result[0][15] );   
                load_combo(combo_tenor_granularity, combo_tenor_granularity_sql, 0, false, result[0][12] , 1);
                var is_active = result[0][13];
                if (is_active == 'y') {
                    form_name.checkItem('is_active');
                } else {
                    form_name.uncheckItem('is_active');
                } 
            });
        
        }
        
    }

    /**
     *
     */
    function load_combo(combo_obj, combo_sql, selected_index, has_blank_option, selected_value, progress_off) {
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data + '&has_blank_option=' + has_blank_option;
        
        combo_obj.load(url, function() {
            if (typeof selected_value !== 'undefined' && selected_value != '') {
                selected_index = combo_obj.getIndexByValue(selected_value);
                combo_obj.selectOption(selected_index);
            } else if (has_blank_option == false) {
                combo_obj.selectOption(selected_index);
            }

            if (typeof progress_off !== 'undefined') {
                limits.layout.progressOff();
            }
        });
        combo_obj.enableFilteringMode(true);
    }
</script>
</html>