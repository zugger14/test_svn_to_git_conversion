<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
        <style type="text/css">
            .dhxform_obj_dhx_web div.disabled div.dhxform_btn {
                border: none;
                background-color: #DFDFDF;
            }
        </style>
</head>
<body>
<?php
    $function_id = 10101210;
    $application_function_id = 10101213;
    $sub_book_id = get_sanitized_value($_GET['sub_book_id'] ?? '0');
    $fas_book_id = get_sanitized_value($_GET['fas_book_id'] ?? '0');
    $mode = get_sanitized_value($_GET['mode'] ?? 'i');
    
    $sql_stmt = "EXEC spa_sourcesystembookmap @flag='j', @book_deal_type_map_id=". $sub_book_id;
    $return_value = readXMLURL($sql_stmt);
    $gl_entry_grouping = isset($return_value[0][0]) ? $return_value[0][0] : 0;
    $accounting_type = isset($return_value[0][1]) ? $return_value[0][1] : 0;

    $layout_name = 'layout';
    $layout_json = '[{id:"a", header: false}]';
    $name_space = 'sub_book_property';
    
    list (
        $has_right_iu
    ) = build_security_rights(
        $function_id
    );

    $save_button_state = empty($has_right_iu) ? 'true' : 'false';
    $mode = get_sanitized_value($_GET['mode'] ?? 'i');
    
    $layout = new AdihaLayout();
    echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar';

    $toolbar_json = '[ {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled:' . $save_button_state . '}]';

    echo $layout->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'save_form');

    //$form_obj = new AdihaForm();
    //$form_name = 'sub_book_property_form';
    echo $layout->close_layout();
    ?>
</body>

<script type="text/javascript">
    dhxWins = new dhtmlXWindows();
    
    var mode = '<?php echo $mode;?>';
    var application_function_id = <?php echo $application_function_id;?>;
    var sub_book_id = "<?php echo $sub_book_id;?>";
    var fas_book_id = "<?php echo $fas_book_id;?>";

    var gl_entry_grouping = <?php echo $gl_entry_grouping;?>;
    var accounting_type = <?php echo $accounting_type;?>;

    sub_book_property.sub_book_property_form = {};

    $(function(){
        var data = {
                    "action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": application_function_id,
                    "template_name": 'setup_sub_book_mapping',
                    "parse_xml": "<Root><PSRecordSet book_deal_type_map_id=\"" + fas_book_id + "\"></PSRecordSet></Root>"
                }
        adiha_post_data('return_array',data, '', '', 'book_structure_details', '');
    })

    /**
     *
     */
    function book_structure_details(result) {
        var result_length = result.length;
        var tab_json = '';
        
        for (i = 0; i < result_length; i++) {
            if (i > 0) {
                tab_json = tab_json + ",";
            }
            tab_json = tab_json + (result[i][1]);
        }

        tab_json = '{tabs: [' + tab_json + ']}';
        inner_tab_layout_tabbar =  sub_book_property.layout.cells("a").attachTabbar({mode:"bottom",arrows_mode:"auto"});
        inner_tab_layout_tabbar.loadStruct(tab_json);
        
        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            sub_book_property.sub_book_property_form['form_' + j + '_' + sub_book_id] = inner_tab_layout_tabbar.cells(tab_id).attachForm();
            if (result[j][2]) {
                sub_book_property.sub_book_property_form['form_' + j + '_' + sub_book_id].loadStruct(result[j][2]);
                sub_book_property.sub_book_property_form['form_' + j + '_' + sub_book_id].disableItem('fas_deal_sub_type_value_id');
                
                if (j == 0) {
                    sub_book_property.sub_book_property_form['form_' + j + '_' + sub_book_id].setItemValue('fas_book_id', sub_book_id);
                }
            }
        }
        /*****************************/
        inner_tab_layout_tabbar.forEachTab(function(tab) {
            
            if (tab.getAttachedObject() instanceof dhtmlXForm) {
                form_obj = tab.getAttachedObject();
                var id = tab.getIndex();
                var form_id ="form_" + id + '_' + sub_book_id;
                var form_name = 'sub_book_property.sub_book_property_form["' + form_id + '"]';
                attach_browse_event(form_name,10101210,'', '', 'false');
            } else {
                return false;
            }
            
            enable_combos = (gl_entry_grouping == 350 || gl_entry_grouping == 351) ? false : true;//Grouped at Strategy
            enable_disable_gl_code_objects(enable_combos);
 
            show_hide_gl_code_objects(accounting_type);
        });
        /****************************************/
    }
    /**
     * [Save Function]
     */
    function save_form(id) {
        var hierarchy_function_id = application_function_id;
        var active_object_id = sub_book_id;//(active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var validation_status = true;
        var grid_xml = '';
        var inner_tab_obj = sub_book_property.layout.cells("a").getAttachedObject();
        var form_xml = '<Root function_id="' + hierarchy_function_id  + '"><FormXML ID="' + sub_book_id + '"';
        
        inner_tab_obj.forEachTab(function(tab){
            var tab_text = tab.getText();
            
            attached_obj = tab.getAttachedObject();
            if (attached_obj instanceof dhtmlXForm) {
                var lbl = null;
                var sdv_data = null;
                var lbl_value = null;
                var entity_name = attached_obj.getItemValue('entity_name');
                data = attached_obj.getFormData();

                for (var a in data) {
                var status = validate_form(attached_obj);
                    if(status){
                        field_label = a;
                        field_value = data[a];
                        var lbl = attached_obj.getItemLabel(a);
                        var lbl_value = attached_obj.getItemValue(a);
                        /*if (lbl.indexOf('Portfolio') != -1) {
                            alert(field_label)
                        }*/
                        if(lbl == 'Name'){
                        var patt = /\S/
                        var result = lbl_value.match(patt);
                            if(lbl_value!==""){
                                if(!result){
                                    validation_status = false;
                                    attached_obj.setNote(field_label,{text:"Please enter the proper value"});
                                    attached_obj.attachEvent("onchange",function(field_label, lbl_value){
                                            attached_obj.setNote(field_label,{text:""});
                                    });
                                }
                            }
                        }

                        if(field_label == 'effective_start_date'){
                            var effective_start_date_value = field_value;
                        }
                        if(field_label == 'end_date'){
                            var end_date_value = field_value;
                        }

                        if (lbl== 'Tax Percentage' || lbl == 'Percentage Included') {
                            if(lbl_value != ""){
                                if(lbl_value < 0 || lbl_value > 1){
                                    validation_status = false;
                                    attached_obj.setNote(field_label,{text:"Please input the valid " + lbl.toLowerCase() + "(0-1)."});
                                    attached_obj.attachEvent("onchange",function(field_label, lbl_value){
                                            attached_obj.setNote(field_label,{text:""});
                                    });
                                }
                            }
                        }

                        if (attached_obj.getItemType(a) == "calendar") {
                            field_value = attached_obj.getItemValue(a, true);
                        }
                        if (attached_obj.getItemType(a) == "browser") {
                            field_value = '';
                        }
                        if (a == 'entity_name') {
                            sub_book_property.sub_book_property_form['form_' + 0 + '_' + sub_book_id].setUserData("", "entity_name", data[a]);
                        }
                        
                        if(a =='logical_name') {
                            sub_book_property.sub_book_property_form['form_' + 0 + '_' + sub_book_id].setUserData("", "logical_name", data[a]);
                        }
                        
                        if (!field_value)
                            field_value = '';
                            form_xml += " " + field_label + "=\"" + field_value + "\"";
                    } else {
                        validation_status = false;
                    }
                }

                if((effective_start_date_value !== null) && (end_date_value !== null) && (effective_start_date_value > end_date_value)){
                    validation_status = false;
                    show_messagebox('Effective Date should not be less than End date.');
                }
            }
        });

        form_xml += "></FormXML></Root>";
        
        if (validation_status == true) {
            data = {"action": "spa_sub_book_xml", "xml": form_xml, "flag":"" + mode + "", 'function_id': application_function_id};
            adiha_post_data("alert", data, "", "", "parent.setup_book_structure.refresh_source_book_mapping");//"save_callback");//"refresh_bookstructure");
        }
    }

    function show_hide_gl_code_objects(combo_option) {
        inner_tab_layout_tabbar.forEachTab(function(tab) {
            if (tab.getAttachedObject() instanceof dhtmlXForm) {
                form_object = tab.getAttachedObject();
            } else {
                return false;
            }
            
            var array_cash_flow_show = ['browser_gl_number_id_st_asset','browser_gl_number_id_lt_asset','browser_gl_number_id_st_liab','browser_gl_number_id_lt_liab','browser_gl_number_unhedged_der_st_asset','browser_gl_number_unhedged_der_lt_asset','browser_gl_number_unhedged_der_st_liab','browser_gl_number_unhedged_der_lt_liab','browser_gl_id_st_tax_asset','browser_gl_id_lt_tax_asset','browser_gl_id_st_tax_liab','browser_gl_id_lt_tax_liab','browser_gl_id_tax_reserve','browser_gl_number_id_aoci','browser_gl_number_id_inventory','browser_gl_number_id_pnl','browser_gl_number_id_set','browser_gl_number_id_cash','browser_gl_number_id_gross_set','browser_gl_number_id_item_st_asset','browser_gl_number_id_item_st_liab','browser_gl_number_id_item_lt_asset','browser_gl_number_id_item_lt_liab',

            'clear_gl_number_id_st_asset','clear_gl_number_id_lt_asset','clear_gl_number_id_st_liab','clear_gl_number_id_lt_liab','clear_gl_number_unhedged_der_st_asset','clear_gl_number_unhedged_der_lt_asset','clear_gl_number_unhedged_der_st_liab','clear_gl_number_unhedged_der_lt_liab','clear_gl_id_st_tax_asset','clear_gl_id_lt_tax_asset','clear_gl_id_st_tax_liab','clear_gl_id_lt_tax_liab','clear_gl_id_tax_reserve','clear_gl_number_id_aoci','clear_gl_number_id_inventory','clear_gl_number_id_pnl','clear_gl_number_id_set','clear_gl_number_id_cash','clear_gl_number_id_gross_set','clear_gl_number_id_item_st_asset','clear_gl_number_id_item_st_liab','clear_gl_number_id_item_lt_asset','clear_gl_number_id_item_lt_liab',


            'label_gl_number_id_st_asset','label_gl_number_id_lt_asset','label_gl_number_id_st_liab','label_gl_number_id_lt_liab','label_gl_number_unhedged_der_st_asset','label_gl_number_unhedged_der_lt_asset','label_gl_number_unhedged_der_st_liab','label_gl_number_unhedged_der_lt_liab','label_gl_id_st_tax_asset','label_gl_id_lt_tax_asset','label_gl_id_st_tax_liab','label_gl_id_lt_tax_liab','label_gl_id_tax_reserve','label_gl_number_id_aoci','label_gl_number_id_inventory','label_gl_number_id_pnl','label_gl_number_id_set','label_gl_number_id_cash','label_gl_number_id_gross_set','label_gl_number_id_item_st_asset','label_gl_number_id_item_st_liab','label_gl_number_id_item_lt_asset','label_gl_number_id_item_lt_liab'

            ];
            




            var array_cash_flow_hide = ['browse_gl_id_amortization', 'browse_gl_number_id_expense', 'browse_gl_id_interest',

            'clear_gl_id_amortization', 'clear_gl_number_id_expense', 'clear_gl_id_interest',

            'label_gl_id_amortization', 'label_gl_number_id_expense', 'label_gl_id_interest',




            ];
            var array_fair_value_hedges_hide = ['browse_gl_number_id_inventory','browse_gl_id_st_tax_asset','browse_gl_id_lt_tax_asset','browse_gl_id_st_tax_liab','browse_gl_id_lt_tax_liab','browse_gl_id_tax_reserve','browse_gl_number_id_aoci','browse_gl_number_unhedged_der_st_asset','browse_gl_number_unhedged_der_lt_asset','browse_gl_number_unhedged_der_st_liab','browse_gl_number_unhedged_der_lt_liab',

            'clear_gl_number_id_inventory','clear_gl_id_st_tax_asset','clear_gl_id_lt_tax_asset','clear_gl_id_st_tax_liab','clear_gl_id_lt_tax_liab','clear_gl_id_tax_reserve','clear_gl_number_id_aoci','clear_gl_number_unhedged_der_st_asset','clear_gl_number_unhedged_der_lt_asset','clear_gl_number_unhedged_der_st_liab','clear_gl_number_unhedged_der_lt_liab',

              'label_gl_number_id_inventory','label_gl_id_st_tax_asset','label_gl_id_lt_tax_asset','label_gl_id_st_tax_liab','label_gl_id_lt_tax_liab','label_gl_id_tax_reserve','label_gl_number_id_aoci','label_gl_number_unhedged_der_st_asset','label_gl_number_unhedged_der_lt_asset','label_gl_number_unhedged_der_st_liab','label_gl_number_unhedged_der_lt_liab'

                
            ];
           


           
            var array_fair_value_hedges_show = ['browse_gl_number_id_st_asset','browse_gl_number_id_lt_asset','browse_gl_number_id_st_liab','browse_gl_number_id_lt_liab','browse_gl_number_id_item_st_asset','browse_gl_number_id_item_st_liab','browse_gl_number_id_item_lt_asset','browse_gl_number_id_item_lt_liab','browse_gl_id_amortization','browse_gl_number_id_expense','browse_gl_id_interest' ,'browse_gl_number_id_pnl','browse_gl_number_id_set','browse_gl_number_id_cash','browse_gl_number_id_gross_set',

            'clear_gl_number_id_st_asset','clear_gl_number_id_lt_asset','clear_gl_number_id_st_liab','clear_gl_number_id_lt_liab','clear_gl_number_id_item_st_asset','clear_gl_number_id_item_st_liab','clear_gl_number_id_item_lt_asset','clear_gl_number_id_item_lt_liab','clear_gl_id_amortization','clear_gl_number_id_expense','clear_gl_id_interest' ,'clear_gl_number_id_pnl','clear_gl_number_id_set','clear_gl_number_id_cash','clear_gl_number_id_gross_set',

            'label_gl_number_id_st_asset','label_gl_number_id_lt_asset','label_gl_number_id_st_liab','label_gl_number_id_lt_liab','label_gl_number_id_item_st_asset','label_gl_number_id_item_st_liab','label_gl_number_id_item_lt_asset','label_gl_number_id_item_lt_liab','label_gl_id_amortization','label_gl_number_id_expense','label_gl_id_interest' ,'label_gl_number_id_pnl','label_gl_number_id_set','label_gl_number_id_cash','label_gl_number_id_gross_set',
            



            ];
            




            var array_mtm_fair_value_hide = [ 'browse_gl_number_id_item_st_asset','browse_gl_number_id_item_st_liab','browse_gl_number_id_item_lt_asset','browse_gl_number_id_item_lt_liab','browse_gl_id_amortization','browse_gl_id_interest','browse_gl_number_id_expense','browse_gl_id_st_tax_asset','browse_gl_id_lt_tax_asset','browse_gl_id_st_tax_liab','browse_gl_id_lt_tax_liab','browse_gl_id_tax_reserve','browse_gl_number_id_aoci','browse_gl_number_id_inventory','browse_gl_number_unhedged_der_st_asset','browse_gl_number_unhedged_der_lt_asset','browse_gl_number_unhedged_der_st_liab','browse_gl_number_unhedged_der_lt_liab',

            'clear_gl_number_id_item_st_asset','clear_gl_number_id_item_st_liab','clear_gl_number_id_item_lt_asset','clear_gl_number_id_item_lt_liab','clear_gl_id_amortization','clear_gl_id_interest','clear_gl_number_id_expense','clear_gl_id_st_tax_asset','clear_gl_id_lt_tax_asset','clear_gl_id_st_tax_liab','clear_gl_id_lt_tax_liab','clear_gl_id_tax_reserve','clear_gl_number_id_aoci','clear_gl_number_id_inventory','clear_gl_number_unhedged_der_st_asset','clear_gl_number_unhedged_der_lt_asset','clear_gl_number_unhedged_der_st_liab','clear_gl_number_unhedged_der_lt_liab',


             'label_gl_number_id_item_st_asset','label_gl_number_id_item_st_liab','label_gl_number_id_item_lt_asset','label_gl_number_id_item_lt_liab','label_gl_id_amortization','label_gl_id_interest','label_gl_number_id_expense','label_gl_id_st_tax_asset','label_gl_id_lt_tax_asset','label_gl_id_st_tax_liab','label_gl_id_lt_tax_liab','label_gl_id_tax_reserve','label_gl_number_id_aoci','label_gl_number_id_inventory','label_gl_number_unhedged_der_st_asset','label_gl_number_unhedged_der_lt_asset','label_gl_number_unhedged_der_st_liab','label_gl_number_unhedged_der_lt_liab'


            ];
        

            if (combo_option == 150) {// 'Cash-flow Hedges'
                for (i = 0; i < array_cash_flow_show.length; i++) {
                   form_object.showItem(array_cash_flow_show[i]);
                }           
                
                for (i = 0; i < array_cash_flow_hide.length; i++) {
                   form_object.hideItem(array_cash_flow_hide[i]);
                }
            form_object.setItemLabel('label_gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness CR</a>');
            form_object.setItemLabel('label_gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness DR</a>');
            form_object.setItemLabel('label_gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness DR</a>');
            form_object.setItemLabel('label_gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness CR</a>');
            form_object.setItemLabel('label_gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Asset</a>');
            form_object.setItemLabel('label_gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Asset</a>');
            form_object.setItemLabel('label_gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Liability</a>');
            form_object.setItemLabel('label_gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Liability</a>');
            form_object.setItemLabel('label_gl_number_unhedged_der_st_asset', '<a id="gl_number_unhedged_der_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unhedge ST Asset</a>');
            form_object.setItemLabel('label_gl_number_unhedged_der_lt_asset', '<a id="gl_number_unhedged_der_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unhedge LT Asset</a>');
            form_object.setItemLabel('label_gl_number_unhedged_der_st_liab', '<a id="gl_number_unhedged_der_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unhedge ST Liability</a>');
            form_object.setItemLabel('label_gl_number_unhedged_der_lt_liab', '<a id="gl_number_unhedged_der_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unhedge LT Liability</a>');
            form_object.setItemLabel('label_gl_id_st_tax_asset', '<a id="gl_id_st_tax_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax ST Asset</a>');
            form_object.setItemLabel('label_gl_id_lt_tax_asset', '<a id="gl_id_lt_tax_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax LT Asset</a>');
            form_object.setItemLabel('label_gl_id_st_tax_liab', '<a id="gl_id_st_tax_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax ST Liability</a>');
            form_object.setItemLabel('label_gl_id_lt_tax_liab', '<a id="gl_id_lt_tax_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax LT Liability</a>');
            form_object.setItemLabel('label_gl_id_tax_reserve', '<a id="gl_id_tax_reserve" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax Reserve</a>');
            form_object.setItemLabel('label_gl_number_id_aoci', '<a id="gl_number_id_aoci" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">AOCI/Hedge Reserve</a>');
            form_object.setItemLabel('label_gl_number_id_inventory', '<a id="gl_number_id_inventory" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Inventory/Asset</a>');
            form_object.setItemLabel('label_gl_number_id_pnl', '<a id="gl_number_id_pnl" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unrealized Earning</a>');
            form_object.setItemLabel('label_gl_number_id_set', '<a id="gl_number_id_set" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Earnings</a>');
            form_object.setItemLabel('label_gl_number_id_cash', '<a id="gl_number_id_cash" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Receivables</a>');
            form_object.setItemLabel('label_gl_number_id_gross_set', '<a id="gl_number_id_gross_set" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Cash Var Earnings</a>');
                
            } else if (combo_option == 151) {// 'Fair-value Hedges'
                for (i = 0; i < array_fair_value_hedges_hide.length; i++) {
                    form_object.hideItem(array_fair_value_hedges_hide[i]);
                }
                
                for (i = 0; i < array_fair_value_hedges_show.length; i++) {
                   form_object.showItem(array_fair_value_hedges_show[i]);
                }     
            

            form_object.setItemLabel('label_gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Asset</a>');
            form_object.setItemLabel('label_gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Asset</a>');
            form_object.setItemLabel('label_gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Liability</a>');
            form_object.setItemLabel('label_gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Liability</a>');
            form_object.setItemLabel('label_gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item ST Liability</a>');
            form_object.setItemLabel('label_gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item ST Asset</a>');
            form_object.setItemLabel('label_gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item LT Asset</a>');
            form_object.setItemLabel('label_gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item Liability</a>');
            form_object.setItemLabel('label_gl_number_unhedged_der_st_asset', '<a id="gl_number_unhedged_der_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unhedge ST Asset</a>');
            form_object.setItemLabel('label_gl_number_unhedged_der_lt_asset', '<a id="gl_number_unhedged_der_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unhedge LT Asset</a>');
            form_object.setItemLabel('label_gl_number_unhedged_der_st_liab', '<a id="gl_number_unhedged_der_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unhedge ST Liability</a>');
            form_object.setItemLabel('label_gl_number_unhedged_der_lt_liab', '<a id="gl_number_unhedged_der_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unhedge LT Liability</a>');
            form_object.setItemLabel('label_gl_id_st_tax_asset', '<a id="gl_id_st_tax_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax ST Asset</a>');
            form_object.setItemLabel('label_gl_id_lt_tax_asset', '<a id="gl_id_lt_tax_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax LT Asset</a>');
            form_object.setItemLabel('label_gl_id_st_tax_liab', '<a id="gl_id_st_tax_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax ST Liability</a>');
            form_object.setItemLabel('label_gl_id_lt_tax_liab', '<a id="gl_id_lt_tax_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax LT Liability</a>');
            form_object.setItemLabel('label_gl_id_tax_reserve', '<a id="gl_id_tax_reserve" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Tax Reserve</a>');
            form_object.setItemLabel('label_gl_number_id_aoci', '<a id="gl_number_id_aoci" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">AOCI/Hedge Reserve</a>');
            form_object.setItemLabel('label_gl_number_id_inventory', '<a id="gl_number_id_inventory" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Inventory/Asset</a>');
            form_object.setItemLabel('label_gl_number_id_pnl', '<a id="gl_number_id_pnl" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unrealized Earning</a>');
            form_object.setItemLabel('label_gl_number_id_set', '<a id="gl_number_id_set" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Earnings</a>');
            form_object.setItemLabel('label_gl_number_id_cash', '<a id="gl_number_id_cash" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Receivables</a>');
            form_object.setItemLabel('label_gl_number_id_gross_set', '<a id="gl_number_id_gross_set" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Cash Var Earnings</a>');
            form_object.setItemLabel('label_gl_id_interest', '<a id="gl_id_interest" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Accrued Interest</a>');
            form_object.setItemLabel('label_gl_id_amortization', '<a id="gl_id_amortization" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Amortization Expense</a>');
            form_object.setItemLabel('label_gl_number_id_expense', '<a id="gl_number_id_expense" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Interest Expense</a>');
                

            } else if (combo_option == 152) { // MTM (Fair Value)
                for (i = 0; i < array_cash_flow_show.length; i++) {
                   form_object.showItem(array_cash_flow_show[i]);
                } 
                
                for (i = 0; i < array_cash_flow_hide.length; i++) {
                   form_object.showItem(array_cash_flow_hide[i]);
                }
                
                for (i = 0; i < array_mtm_fair_value_hide.length; i++) {
                    form_object.hideItem(array_mtm_fair_value_hide[i]);
                }
                
            form_object.setItemLabel('label_gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM ST Asset</a>');
            form_object.setItemLabel('label_gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM LT Asset</a>');
            form_object.setItemLabel('label_gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM ST Liability</a>');
            form_object.setItemLabel('label_gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM LT Liability</a>');
            form_object.setItemLabel('label_gl_number_id_pnl', '<a id="gl_number_id_pnl" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Unrealized Earning</a>');
            form_object.setItemLabel('label_gl_number_id_set', '<a id="gl_number_id_set" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Earnings</a>');
            form_object.setItemLabel('label_gl_number_id_cash', '<a id="gl_number_id_cash" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Receivables</a>');
            form_object.setItemLabel('label_gl_number_id_gross_set', '<a id="gl_number_id_gross_set" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Cash Var Earnings</a>');
            } else if (combo_option == 153) {// 'Normal Purchase/Sales (Out of Scope)'
                for (i = 0; i < array_cash_flow_show.length; i++) {
                   form_object.hideItem(array_cash_flow_show[i]);
                } 
                
                for (i = 0; i < array_cash_flow_hide.length; i++) {
                   form_object.hideItem(array_cash_flow_hide[i]);
                }
            } else {
                for (i = 0; i < array_cash_flow_show.length; i++) {
                   form_object.showItem(array_cash_flow_show[i]);
                } 
                
                for (i = 0; i < array_cash_flow_hide.length; i++) {
                   form_object.showItem(array_cash_flow_hide[i]);
                }
                
                form_object.setItemLabel('label_gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness CR</a>');
                form_object.setItemLabel('label_gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness DR</a>');
                form_object.setItemLabel('label_gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness DR</a>');
                form_object.setItemLabel('label_gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness CR</a>');
                form_object.setItemLabel('label_gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Asset</a>');
                form_object.setItemLabel('label_gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Asset</a>');
                form_object.setItemLabel('label_gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Liability</a>');
                form_object.setItemLabel('label_gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Liability</a>');
            }
        });
    }
    /**
     * [Enabled/Disabled GL Code Mapping Tab objects for Strategy]
     */
    function enable_disable_gl_code_objects(enable_combos) {
        inner_tab_layout_tabbar.forEachTab(function(tab) {
            if (tab.getAttachedObject() instanceof dhtmlXForm) {
                form_object = tab.getAttachedObject();
            } else {
                return false;
            }
        
            if (enable_combos == true) {
                form_object.enableItem('label_gl_number_id_st_asset');
                form_object.enableItem('label_gl_number_id_lt_asset');
                form_object.enableItem('label_gl_number_id_st_liab');
                form_object.enableItem('label_gl_number_id_lt_liab');
                form_object.enableItem('label_gl_id_st_tax_asset');
                form_object.enableItem('label_gl_id_lt_tax_asset');
                form_object.enableItem('label_gl_id_st_tax_liab');
                form_object.enableItem('label_gl_id_lt_tax_liab');
                form_object.enableItem('label_gl_id_tax_reserve');
                form_object.enableItem('label_gl_number_id_aoci');
                form_object.enableItem('label_gl_number_id_inventory');
                form_object.enableItem('label_gl_number_id_pnl');
                form_object.enableItem('label_gl_number_id_set');
                form_object.enableItem('label_gl_number_id_cash');
                form_object.enableItem('label_gl_number_id_gross_set'); 
                form_object.enableItem('label_gl_number_id_item_st_asset');
                form_object.enableItem('label_gl_number_id_item_st_liab');
                form_object.enableItem('label_gl_number_id_item_lt_asset');
                form_object.enableItem('label_gl_number_id_item_lt_liab');
                form_object.enableItem('label_gl_number_unhedged_der_st_asset');
                form_object.enableItem('label_gl_number_unhedged_der_lt_asset');
                form_object.enableItem('label_gl_number_unhedged_der_st_liab');
                form_object.enableItem('label_gl_number_unhedged_der_lt_liab');
                form_object.enableItem('label_gl_id_amortization');
                form_object.enableItem('label_gl_id_interest');
                form_object.enableItem('label_gl_number_id_expense');
                form_object.enableItem('browse_gl_number_id_st_asset');
                form_object.enableItem('clear_gl_number_id_st_asset');
                form_object.enableItem('browse_gl_number_id_lt_asset');
                form_object.enableItem('clear_gl_number_id_lt_asset');
                form_object.enableItem('browse_gl_number_id_st_liab');
                form_object.enableItem('clear_gl_number_id_st_liab');
                form_object.enableItem('browse_gl_number_id_lt_liab');
                form_object.enableItem('clear_gl_number_id_lt_liab');
                form_object.enableItem('browse_gl_id_st_tax_asset');
                form_object.enableItem('clear_gl_id_st_tax_asset');
                form_object.enableItem('browse_gl_id_lt_tax_asset');
                form_object.enableItem('clear_gl_id_lt_tax_asset');
                form_object.enableItem('browse_gl_id_st_tax_liab');
                form_object.enableItem('clear_gl_id_st_tax_liab');
                form_object.enableItem('browse_gl_id_lt_tax_liab');
                form_object.enableItem('clear_gl_id_lt_tax_liab');
                form_object.enableItem('browse_gl_id_tax_reserve');
                form_object.enableItem('clear_gl_id_tax_reserve');
                form_object.enableItem('browse_gl_number_id_aoci'); 
                form_object.enableItem('clear_gl_number_id_aoci');
                form_object.enableItem('browse_gl_number_id_inventory');
                form_object.enableItem('clear_gl_number_id_inventory');
                form_object.enableItem('browse_gl_number_id_pnl');
                form_object.enableItem('clear_gl_number_id_pnl');
                form_object.enableItem('browse_gl_number_id_set');
                form_object.enableItem('clear_gl_number_id_set');
                form_object.enableItem('browse_gl_number_id_cash');  
                form_object.enableItem('clear_gl_number_id_cash');
                form_object.enableItem('browse_gl_number_id_gross_set');   
                form_object.enableItem('clear_gl_number_id_gross_set');  
                form_object.enableItem('browse_gl_number_id_item_st_asset');
                form_object.enableItem('clear_gl_number_id_item_st_asset');
                form_object.enableItem('browse_gl_number_id_item_st_liab');
                form_object.enableItem('clear_gl_number_id_item_st_liab');
                form_object.enableItem('browse_gl_number_id_item_lt_asset');
                form_object.enableItem('clear_gl_number_id_item_lt_asset');
                form_object.enableItem('browse_gl_number_id_item_lt_liab');
                form_object.enableItem('clear_gl_number_id_item_lt_liab');
                form_object.enableItem('browse_gl_number_unhedged_der_st_asset');
                form_object.enableItem('clear_gl_number_unhedged_der_st_asset');
                form_object.enableItem('browse_gl_number_unhedged_der_lt_asset');
                form_object.enableItem('clear_gl_number_unhedged_der_lt_asset');
                form_object.enableItem('browse_gl_number_unhedged_der_st_liab');
                form_object.enableItem('clear_gl_number_unhedged_der_st_liab');
                form_object.enableItem('browse_gl_number_unhedged_der_lt_liab');
                form_object.enableItem('clear_gl_number_unhedged_der_lt_liab');
                form_object.enableItem('browse_gl_id_amortization');
                form_object.enableItem('browse_gl_id_interest');
                form_object.enableItem('browse_gl_number_id_expense');
                form_object.enableItem('clear_gl_id_amortization');
                form_object.enableItem('clear_gl_id_interest');
                form_object.enableItem('clear_gl_number_id_expense');
            } else {

                form_object.disableItem('label_gl_number_id_st_asset');
                form_object.disableItem('label_gl_number_id_lt_asset');
                form_object.disableItem('label_gl_number_id_st_liab');
                form_object.disableItem('label_gl_number_id_lt_liab');
                form_object.disableItem('label_gl_id_st_tax_asset');
                form_object.disableItem('label_gl_id_lt_tax_asset');
                form_object.disableItem('label_gl_id_st_tax_liab');
                form_object.disableItem('label_gl_id_lt_tax_liab');
                form_object.disableItem('label_gl_id_tax_reserve');
                form_object.disableItem('label_gl_number_id_aoci');
                form_object.disableItem('label_gl_number_id_inventory');
                form_object.disableItem('label_gl_number_id_pnl');
                form_object.disableItem('label_gl_number_id_set');
                form_object.disableItem('label_gl_number_id_cash');
                form_object.disableItem('label_gl_number_id_gross_set'); 
                form_object.disableItem('label_gl_number_id_item_st_asset');
                form_object.disableItem('label_gl_number_id_item_st_liab');
                form_object.disableItem('label_gl_number_id_item_lt_asset');
                form_object.disableItem('label_gl_number_id_item_lt_liab');
                form_object.disableItem('label_gl_number_unhedged_der_st_asset');
                form_object.disableItem('label_gl_number_unhedged_der_lt_asset');
                form_object.disableItem('label_gl_number_unhedged_der_st_liab');
                form_object.disableItem('label_gl_number_unhedged_der_lt_liab');
                form_object.disableItem('label_gl_id_amortization');
                form_object.disableItem('label_gl_id_interest');
                form_object.disableItem('label_gl_number_id_expense');
                form_object.disableItem('browse_gl_number_id_st_asset');
                form_object.disableItem('clear_gl_number_id_st_asset');
                form_object.disableItem('browse_gl_number_id_lt_asset');
                form_object.disableItem('clear_gl_number_id_lt_asset');
                form_object.disableItem('browse_gl_number_id_st_liab');
                form_object.disableItem('clear_gl_number_id_st_liab');
                form_object.disableItem('browse_gl_number_id_lt_liab');
                form_object.disableItem('clear_gl_number_id_lt_liab');
                form_object.disableItem('browse_gl_id_st_tax_asset');
                form_object.disableItem('clear_gl_id_st_tax_asset');
                form_object.disableItem('browse_gl_id_lt_tax_asset');
                form_object.disableItem('clear_gl_id_lt_tax_asset');
                form_object.disableItem('browse_gl_id_st_tax_liab');
                form_object.disableItem('clear_gl_id_st_tax_liab');
                form_object.disableItem('browse_gl_id_lt_tax_liab');
                form_object.disableItem('clear_gl_id_lt_tax_liab');
                form_object.disableItem('browse_gl_id_tax_reserve');
                form_object.disableItem('clear_gl_id_tax_reserve');
                form_object.disableItem('browse_gl_number_id_aoci');
                form_object.disableItem('clear_gl_number_id_aoci');
                form_object.disableItem('browse_gl_number_id_inventory');
                form_object.disableItem('clear_gl_number_id_inventory');
                form_object.disableItem('browse_gl_number_id_pnl');
                form_object.disableItem('clear_gl_number_id_pnl');
                form_object.disableItem('browse_gl_number_id_set');
                form_object.disableItem('clear_gl_number_id_set');
                form_object.disableItem('browse_gl_number_id_cash');
                form_object.disableItem('clear_gl_number_id_cash');
                form_object.disableItem('browse_gl_number_id_gross_set'); 
                form_object.disableItem('clear_gl_number_id_gross_set'); 
                form_object.disableItem('browse_gl_number_id_item_st_asset');
                form_object.disableItem('clear_gl_number_id_item_st_asset');
                form_object.disableItem('browse_gl_number_id_item_st_liab');
                form_object.disableItem('clear_gl_number_id_item_st_liab');
                form_object.disableItem('browse_gl_number_id_item_lt_asset');
                form_object.disableItem('clear_gl_number_id_item_lt_asset');
                form_object.disableItem('browse_gl_number_id_item_lt_liab');
                form_object.disableItem('clear_gl_number_id_item_lt_liab');
                form_object.disableItem('browse_gl_number_unhedged_der_st_asset');
                form_object.disableItem('browse_gl_number_unhedged_der_lt_asset');
                form_object.disableItem('browse_gl_number_unhedged_der_st_liab');
                form_object.disableItem('browse_gl_number_unhedged_der_lt_liab');
                form_object.disableItem('clear_gl_number_unhedged_der_st_asset');
                form_object.disableItem('clear_gl_number_unhedged_der_lt_asset');
                form_object.disableItem('clear_gl_number_unhedged_der_st_liab');
                form_object.disableItem('clear_gl_number_unhedged_der_lt_liab');
                form_object.disableItem('browse_gl_id_amortization');
                form_object.disableItem('browse_gl_id_interest');
                form_object.disableItem('browse_gl_number_id_expense');
                form_object.disableItem('clear_gl_id_amortization');
                form_object.disableItem('clear_gl_id_interest');
                form_object.disableItem('clear_gl_number_id_expense');
            }
        });
    }
    
</script>
</html>