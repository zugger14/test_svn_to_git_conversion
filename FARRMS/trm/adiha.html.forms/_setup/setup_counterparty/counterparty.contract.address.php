<?php
/**
* Counterparty contract address screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <?php  require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
</head>
<body>
    <?php
    $counterparty_id = get_sanitized_value($_GET['counterparty_id']);
    $counterparty_contract_address_id = ($_GET['counterparty_contract_address_id']) ? get_sanitized_value($_GET['counterparty_contract_address_id']) : -1;
    
    $mode = ($counterparty_contract_address_id == -1) ? 'i' : 'u';
    
    $form_namespace = 'contract_mapping';
    $function_id = 10105830;
    $rights_conterparty_contract_iu = 10105831;
    list (
        $has_rights_conterparty_contract_iu
    ) = build_security_rights(
        $rights_conterparty_contract_iu            
    );



    $contract_counterparty_type_url = "SELECT null [value], ' ' [text] UNION ALL SELECT value_id [value],code [text] FROM static_data_value WHERE type_id = 105800";
    $result_contract_counterparty_type = readXMLURL2($contract_counterparty_type_url);
    $json_contract_counterparty_type = json_encode($result_contract_counterparty_type);



    $template_name = 'Contracts';        
    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();
    $menu_obj = new AdihaMenu();
    
    $layout_json = '[{ 
                        id:             "a",
                        header:         false
                    }]'; 
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis:"save_dis.gif", text:"Save", title: "Save"}]';     
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='" . $template_name . "', @group_name='General,Credit,Settlement,Product,Contract', @parse_xml = '<Root><PSRecordSet counterparty_contract_address_id=\"" . $counterparty_contract_address_id . "\"></PSRecordSet></Root>'";
    
    $form_data = readXMLURL($form_sql); 

    $i = 0;
    $tab_json = '';
    foreach ($form_data as $temp) {
        if ($i > 0)
            $tab_json = $tab_json . ',';
        $tab_json = $tab_json . $temp[1];
        $i++;
    }
    $tab_json = '[' . $tab_json . ']';
    /* END */
            
    echo $layout_obj->init_layout('layout_contract_mapping_layout', '', '1C', $layout_json, $form_namespace);
    
    $menu_json = '[{id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save", enabled: "'.$has_rights_conterparty_contract_iu.'"}]';  
    echo $layout_obj->attach_menu_layout_cell("menu_contract_mapping", "a", $menu_json, $form_namespace . '.save_click');


    //attach tab to the main layout.
    /* start */
    $tab_name = 'tab_component'; 
    echo $layout_obj->attach_tab_cell($tab_name, 'a', $tab_json);

    //Attaching tabbar.
    /* START */
    $tab_obj = new AdihaTab();
    echo $tab_obj->init_by_attach($tab_name, $form_namespace);     
    $yy = 0;

    foreach ($form_data as $temp1) {
        $form_json = $temp1[2];
        if (strpos($temp1[4], '[') === false) {
            $temp1[4] = '[' .  $temp1[4] . ']';
        }
        $grid_json = json_decode($temp1[4], true);
        $tab_id = 'detail_tab_' . $temp1[0];
        $form_name = 'form_' . $temp1[0];
        if ($form_json) {
            echo $tab_obj->attach_form($form_name, $tab_id, $form_json, $form_namespace);
            if ($yy == 0) { //General Tab
                $first_form = $form_namespace . "." . $form_name;
            } else if ($yy == 1) { //Credit Tab
                $second_form = $form_namespace . "." . $form_name;
            } else if ($yy == 2) {//Settlement Tab
                $third_form = $form_namespace . "." . $form_name;
            }    
        }

        foreach ($grid_json as $obj) {
            if ($obj['grid_id'] == '' || $obj['grid_id'] == null) { continue; }
            if ($obj['grid_id'] != 'FORM') {
                $grid_def = "EXEC spa_adiha_grid 's', '" . $obj['grid_id'] . "'";
                $def = readXMLURL2($grid_def);

                if ($yy == 3) { //Product Tab
                    $product_form_json = $form_json;
                    $product_tab_id = $tab_id;
                    $product_form_name = $form_name;
                    $fourth_form = $form_namespace . "." . $tab_name . "." . 'tabs("' . $tab_id . '")';
                    $grid_definition_json = json_encode($def);
                } else if ($yy == 4) { //contract Tab
                    $fifth_form = $form_namespace . "." . $tab_name . "." . 'tabs("' . $tab_id . '")';
                    $contract_grid_definition_json = json_encode($def);
                }
            }
        }
        $yy++;
    }
    /*/* END */
    echo $layout_obj->close_layout();
    ?>
</body>
<script type="text/javascript">
    var mode = '<?php echo $mode; ?>';
    var app_php_script_loc = "<?php echo $app_php_script_loc; ?>";
    var counterparty_id = '<?php echo $counterparty_id; ?>';    
    var counterparty_contract_address_id = '<?php echo $counterparty_contract_address_id; ?>';   
    var has_rights_conterparty_contract_iu = '<?php echo $has_rights_conterparty_contract_iu;?>';
    var popup_window;
    var delete_grid_name = '';
    var contract_id  = '';
    var internal_counterparty_id = '';
    var grid_definition_json = <?php echo $grid_definition_json; ?>;  
    var contract_grid_definition_json = <?php echo $contract_grid_definition_json; ?>;  
    dhxWins = new dhtmlXWindows();
    sql_stmt = {};
    grid_type = {};
    var popup_window;
    var document_window;    
    var options_contract_counterparty_type = <?php echo $json_contract_counterparty_type; ?>;
    var function_id = <?php echo $function_id; ?>;

    $(function() {
        var first_form = <?php echo $first_form; ?>;
        var second_form = <?php echo $second_form; ?>;
        var third_form = <?php echo $third_form; ?>;
        var fourth_form = '<?php echo $fourth_form; ?>'; 
        var fifth_form = <?php echo $fifth_form; ?>;
    
        load_product_tab();  
        load_contract_tab();
        refresh_cpty_contract_type_grid();
        contract_id  = first_form.getItemValue('contract_id');  
        internal_counterparty_id = first_form.getItemValue('internal_counterparty_id');
        //## Set counterparty_id field value
        first_form.setItemValue('counterparty_id', counterparty_id);
 
        // loading grid data   
        setTimeout(function() { 
        refresh_grid(contract_id,internal_counterparty_id);     
        }, 200);  
            
        var cash_apply = second_form.getItemValue("offset_method");  
       
        if (cash_apply == 43500 && mode == 'u') {
            second_form.hideItem('payment_days');
            second_form.hideItem('invoice_due_date');
            second_form.hideItem('holiday_calendar_id');
        } 
       
        second_form.attachEvent("onChange", function(name, value){
            
        if (name == 'offset_method' && value == 43500 ){
                second_form.hideItem('payment_days');
                second_form.hideItem('invoice_due_date');
                second_form.hideItem('holiday_calendar_id');
            } else if (name == 'offset_method' && value != 43500) {
                second_form.showItem('payment_days');
                second_form.showItem('invoice_due_date');
                second_form.showItem('holiday_calendar_id');
            }
        }); 
        attach_browse_event('<?php echo $first_form; ?>', 10105830, '', '', 'id=' + counterparty_id);
        attach_browse_event('<?php echo $second_form; ?>', 10105830, '', '', 'id=' + counterparty_id);
        attach_browse_event('<?php echo $third_form; ?>', 10105830, '', '', 'id=' + counterparty_id);
    });

    function load_product_tab() {

        var product_layout = <?php echo $fourth_form; ?>.attachLayout({
                                pattern: '2E',
                                cells: [{ 
                                            id:             "a",
                                            height:         100,
                                            header:         false
                                        }
                                        ,
                                        {
                                            id:             "b",
                                            text:           "Blocked Product",
                                            header:         true,
                                            collapse:       false,
                                            fix_size:       [false,null]
                                        }
                                        ]
                            });

        form_obj_product =  product_layout.cells('a').attachForm(<?php echo $product_form_json; ?>); 
        

        var menu_json_cs = [ 
            {id: "edit", text: "Edit", img:"edit.gif", items: [
                {id:"add", img:"add.gif", text:"Add", imgdis:"add_dis.gif", enabled: true },
                {id:"delete", text:"Delete", img:"remove.gif", imgdis:"remove_dis.gif", enabled: false},
                
            ]},
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", enabled: 1},
            {id:"export", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]} 
            
        ];
                                
        grid_menu_obj = product_layout.cells('b').attachMenu({
            icons_path : js_image_path + "dhxmenu_web/",
            json       : menu_json_cs
        });

       
        grid_obj_product =  product_layout.cells('b').attachGrid(); 
        grid_obj_product.setHeader(grid_definition_json[0]["column_label_list"]);
        grid_obj_product.setColumnIds(grid_definition_json[0]["column_name_list"]);
        grid_obj_product.setColTypes(grid_definition_json[0]["column_type_list"]);
        grid_obj_product.setColumnsVisibility(grid_definition_json[0]["set_visibility"]);
        grid_obj_product.setColSorting(grid_definition_json[0]["sorting_preference"]);
        grid_obj_product.enableMultiselect(true);
        grid_obj_product.attachHeader("#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
        grid_obj_product.init();
        grid_obj_product.enableHeaderMenu();
        
        grid_obj_product.attachEvent("onRowSelect", function(){ 
            enable_menu_btn();
        });  

        grid_obj_product.attachEvent("onRowDblClicked", function(){ 
            grid_edit();
        });    

         //Attaching Menu event
        grid_menu_obj.attachEvent("onClick", function(id) {
            switch(id) { 
                case "add":
                    var tab_text = 'Product';
                    var win_type = 'p';

                    contract_mapping.open_popup_window(counterparty_id,internal_counterparty_id,contract_id, -1, win_type, sql_stmt[tab_text], grid_obj_product, grid_type[tab_text]);
                break;    
                case "delete":
                    var msg = "Are you sure you want to delete?";
                    dhtmlx.message({
                        type: "confirm",
                        title: "Confirmation",
                        ok: "Confirm",
                        text: msg,
                        callback: function(result) {
                            if (result) { 
                                var selected_row = grid_obj_product.getSelectedRowId();
                                var partsOfStr = selected_row.split(','); 
                                grid_xml = '<Root>';
                                for (i = 0; i < partsOfStr.length; i++) {
                                    var primary_column_value = grid_obj_product.cells(partsOfStr[i], 0).getValue();
                                    grid_xml += '<GridDelete grid_id=' + '"' + primary_column_value + '"' + '></GridDelete>';
                                    grid_obj_product.deleteRow(partsOfStr[i]);
                                }
                                grid_xml += '</Root>';  
                                data = {
                                    "action": "spa_counterparty_contract_address",
                                    "flag": "g",
                                    "xml": grid_xml
                                };
                                 
                                adiha_post_data('alert', data, '', '', 'delete_callback');
                                }
                            } 
                    });
                break;
                case "excel":
                    grid_obj_product.toExcel(app_php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
                case "pdf":
                    grid_obj_product.toPDF(app_php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
                case "refresh":
                    refresh_grid(contract_id,internal_counterparty_id);
                break;
            }
           });  


        form_obj_product.attachEvent("onChange", function (name, value){
             if (name == 'allow_all_products') {   
                refresh_grid(contract_id,internal_counterparty_id);
             }  
        });    
    }    

    function load_contract_tab() {
        var contract_layout = <?php echo $fifth_form; ?>.attachLayout({
                                pattern: '2E',
                                cells: [{ 
                                            id:             "a",
                                            height:         100,
                                            header:         false
                                        }
                                        ,
                                        {
                                            id:             "b",
                                            text:           "Contract Type",
                                            header:         true,
                                            collapse:       false,
                                            fix_size:       [false,null]
                                        }
                                        ]
                            }); 

        var contract_form_json = [  //counterparty_contract_type_cmb
                            {"type":"settings","position":"label-left"},
                            {"type": "block", blockOffset: 10, list: [
                                    {
                                        'type': 'combo',
                                        'name': 'contract_counterparty_type',
                                        'label': 'Contract Type',
                                        'position': 'label-top',
                                        'inputWidth': 200,
                                        'offsetLeft':"10",
                                        'labelWidth': 'auto',
                                        'tooltip': 'Workflow Type',
                                        'filtering':true,
                                        'filtering_mode': 'between',
                                        'options':options_contract_counterparty_type
                                    }                                    
                                ]}
                           ];
        form_obj_contract =  contract_layout.cells('a').attachForm(contract_form_json);       

         var cct_menu_json_cs = [ 
            {id: "edit", text: "Edit", img:"edit.gif", items: [ 
                {id:"add", img:"add.gif", text:"Add", imgdis:"add_dis.gif", enabled: true },
                {id:"delete", text:"Delete", img:"remove.gif", imgdis:"remove_dis.gif", enabled: false},
                
            ]},
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", enabled: 1},
            {id:"export", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]} 
            
        ];
                                
        grid_cct_menu_obj = contract_layout.cells('b').attachMenu({
            icons_path : js_image_path + "dhxmenu_web/",
            json       : cct_menu_json_cs
        });

       
        grid_obj_cpty_contract_type =  contract_layout.cells('b').attachGrid(); 
        // grid_obj_cpty_contract_type.setHeader('ID,Counterparty Contract Address ID,Counterparty, Contract Type,Counterparty Contract Type ID, Attached Document, Description');
        // grid_obj_cpty_contract_type.setColumnIds('id,counterparty_contract_address_id,counterparty,counterparty_contract_type,cct_id,document_attached,description');
        // grid_obj_cpty_contract_type.setColTypes('ro,ro,ro,ro,ro,ro,ro');        
        // grid_obj_cpty_contract_type.setColSorting('str,str,str,str,str,str,str');

        grid_obj_cpty_contract_type.setHeader(contract_grid_definition_json[0]["column_label_list"]);
        grid_obj_cpty_contract_type.setColumnIds(contract_grid_definition_json[0]["column_name_list"]);
        grid_obj_cpty_contract_type.setColTypes(contract_grid_definition_json[0]["column_type_list"]);
        grid_obj_cpty_contract_type.setColumnsVisibility(contract_grid_definition_json[0]["set_visibility"]);
        grid_obj_cpty_contract_type.setColSorting(contract_grid_definition_json[0]["sorting_preference"]); 

        grid_obj_cpty_contract_type.attachHeader("#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
        grid_obj_cpty_contract_type.init();
        // grid_obj_cpty_contract_type.setColumnsVisibility('true,true,true,false,true,false,false');
        grid_obj_cpty_contract_type.enableHeaderMenu();
        grid_obj_cpty_contract_type.enableMultiselect(true); 
        
        grid_obj_cpty_contract_type.attachEvent("onRowSelect", function(){ 
            grid_cct_menu_obj.setItemEnabled("delete");
        });  

        grid_obj_cpty_contract_type.attachEvent("onRowDblClicked", function(rowId,cellIndex){   
            fx_open_counterparty_contract_type('u',rowId,cellIndex);
        });       

        //Attaching Menu event
        grid_cct_menu_obj.attachEvent("onClick", function(id,item_id) {
            switch(id) {     
                case "add":
                    fx_open_counterparty_contract_type('i',null,null,item_id);
                break;
                break;    
                case "delete":  
                    msg = "Are you sure you want to delete?";
                                dhtmlx.message({
                                    type: "confirm",
                                    title: "Confirmation",
                                    ok: "Confirm",
                                    text: msg,
                                    callback: function(result) {
                                        if (result) { 
                                            var selected_row = grid_obj_cpty_contract_type.getSelectedRowId();
                                            var partsOfStr = selected_row.split(','); 
                                            grid_xml = '<Root>';
                                            for (i = 0; i < partsOfStr.length; i++) {
                                                var primary_column_value = grid_obj_cpty_contract_type.cells(partsOfStr[i], 0).getValue();
                                                grid_xml += '<GridDelete grid_id=' + '"' + primary_column_value + '"' + '></GridDelete>';
                                                grid_obj_cpty_contract_type.deleteRow(partsOfStr[i]);
                                            }
                                            grid_xml += '</Root>';    
                                            data = {
                                                "action": "spa_counterparty_contract_type",
                                                "flag": "d",
                                                "xml": grid_xml
                                            };
                                             
                                            adiha_post_data('alert', data, '', '', 'delete_cct_callback');
                                            }
                                        } 
                                });
                break;
                case "excel":
                    grid_obj_cpty_contract_type.toExcel(app_php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
                case "pdf":
                    grid_obj_cpty_contract_type.toPDF(app_php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
                case "refresh":  
                    refresh_cpty_contract_type_grid();
                break;
            }
           });                    
    }

    function refresh_cpty_contract_type_grid() {
        if (mode == 'i') {
            grid_obj_cpty_contract_type.clearAll();
            grid_cct_menu_obj.setItemDisabled("refresh"); 
            grid_cct_menu_obj.setItemDisabled("add"); 
            grid_cct_menu_obj.setItemDisabled("excel");
            grid_cct_menu_obj.setItemDisabled("pdf");
            return;
        }

        var counterparty_contract_type_dropdown_value = form_obj_contract.getItemValue('contract_counterparty_type');
        
        var param = {
                    "action": "spa_counterparty_contract_type",
                    "flag": "k",                    
                    "counterparty_id": counterparty_id,
                    "counterparty_contract_address_id": counterparty_contract_address_id,
                    "counterparty_contract_type": counterparty_contract_type_dropdown_value, 
                };

                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                grid_obj_cpty_contract_type.clearAll();
                grid_obj_cpty_contract_type.loadXML(param_url, function() {
                   grid_cct_menu_obj.setItemDisabled("delete"); 
                });                
    }

    /*
     * [Open counterparty_contract_type window]
     */
    function fx_open_counterparty_contract_type(mode,rowId,cellIndex,item_id) {
        if(mode == 'u') {
            var counterparty_contract_type_id = grid_obj_cpty_contract_type.cells(rowId,0).getValue()
            var counterparty_contract_type_dropdown_id = grid_obj_cpty_contract_type.cells(rowId,4).getValue();
            var description = grid_obj_cpty_contract_type.cells(rowId,6).getValue();
            var ammendment_date = grid_obj_cpty_contract_type.cells(rowId,7).getValue();
            var number = grid_obj_cpty_contract_type.cells(rowId,8).getValue();
            var contract_status = grid_obj_cpty_contract_type.cells(rowId,9).getValue();
            var contract_status_id = grid_obj_cpty_contract_type.cells(rowId,10).getValue();
        } else {
            var counterparty_contract_type_id = ''
            var description = ''
            var ammendment_date = ''
            var number = ''
            var contract_status = ''
        }

        if(mode == 'u' && (counterparty_contract_type_id == 0 || counterparty_contract_type_id == "")) {
            return;
        } 

        var parent_object_id = 'NULL';
        var sub_category_id = 'NULL';
        var category_id = 56; 
        var notes_object_id = counterparty_contract_address_id;
        var contract_id = <?php echo $first_form; ?>.getItemValue('contract_id');

        counterparty_contract_type_log_window = new dhtmlXWindows(); 
        data = {
            category_id: category_id,
            sub_category_id : sub_category_id,
            contract_id : contract_id,
            counterparty_id : counterparty_id,
            counterparty_contract_address_id : counterparty_contract_address_id,
            notes_object_id : notes_object_id,
            parent_object_id : parent_object_id,
            counterparty_contract_type_id : counterparty_contract_type_id,
            description : description,
            counterparty_contract_type_dropdown_id : counterparty_contract_type_dropdown_id,
            item_id : item_id,
            ammendment_date: ammendment_date,
            number: number,
            contract_status: contract_status,
            contract_status_id: contract_status_id
        }

        var src = js_php_path + '../adiha.html.forms/_setup/setup_counterparty/counterparty.contract.type.php';
        counterparty_contract_type_log_win_obj = counterparty_contract_type_log_window.createWindow('w1', 0, 0, 1300, 700);
        counterparty_contract_type_log_win_obj.setText("Counterparty Contract Type Document");
        
        counterparty_contract_type_log_win_obj.centerOnScreen();
        counterparty_contract_type_log_win_obj.setModal(true);
        //counterparty_contract_type_log_win_obj.maximize();
        counterparty_contract_type_log_win_obj.attachURL(src, false, data);
        counterparty_contract_type_log_win_obj.attachEvent("onClose", function(win) {            
                refresh_cpty_contract_type_grid();
                return true;
            });
    }    

    /**
     * Save Counterparty Contract Address Mapping
     * @param  {String} id Menu ID
     */
    contract_mapping.save_click = function(id) {
        if (id == 'save') {
            contract_mapping.form_validation_status = 0;
            var detail_tabs = contract_mapping.tab_component.getAllTabs();

            var contract_start_date = <?php echo $first_form; ?>.getItemValue("contract_start_date", true);
            var contract_end_date = <?php echo $first_form; ?>.getItemValue("contract_end_date", true);

            if (contract_start_date > contract_end_date) {
                dhtmlx.message({
                    type: "alert",
                    title: "Alert",
                    text: "<strong>Contract End Date</strong> should be greater than <strong>Contract Start Date</strong>."
                });
                return;
            }
            
            var form_xml = '<FormXML';
            $.each(detail_tabs, function(index, value) {
                // Implemented the same previous logic to build xml for only 4 tabs
                if (index > 3) return;

                var layout_obj = contract_mapping.tab_component.cells(value).getAttachedObject();
                var attached_obj = layout_obj;
                // For Product Tab
                if (index == 3) {
                    attached_obj = form_obj_product;
                }

                var status = validate_form(attached_obj);
                if (!status) {
                    contract_mapping.form_validation_status = 1;
                } else if (attached_obj instanceof dhtmlXForm) {
                    var data = attached_obj.getFormData();
                    for (var field_label in data) {
                        if (attached_obj.getItemType(field_label) == "calendar") {
                            field_value = attached_obj.getItemValue(field_label, true);
                        } else {
                            field_value = data[field_label];
                        }
                        form_xml += " " + field_label + "=\"" + field_value + "\"";
                    }
                }
            });
            
            form_xml += '></FormXML></Root>';    
            form_xml = '<Root function_id="' + function_id + '" object_id="' + counterparty_contract_address_id + '">' + form_xml;

            if (contract_mapping.form_validation_status) {
                generate_error_message();
                return;
            }

            var param = {
                "flag": "i",
                "action": "spa_counterparty_contract_address",
                "xml": form_xml
            };
            
            contract_mapping.menu_contract_mapping.setItemDisabled('save');
            adiha_post_data('alert', param, '', '', 'contract_mapping.save_callback');
        }
    }

    /**
     * Save callback
     * @param  {Object} result Response from database after save
     */
    contract_mapping.save_callback = function(result) {
        if (has_rights_conterparty_contract_iu) {
            contract_mapping.menu_contract_mapping.setItemEnabled('save');
        }
        
        if (result[0].errorcode == 'Success') {
            <?php echo $first_form; ?>.setItemValue('counterparty_contract_address_id', (result[0]).recommendation);
            mode = 'u';
            setTimeout(function() { 
                window.parent.popup_window.window('w1').close(); 
            }, 1000);
        }
    }

    open_contract = function(id) {
        var contract_id = <?php echo $first_form; ?>.getItemValue('contract_id');
        var param = {
            "action": "('SELECT contract_type_def_id FROM contract_group WHERE contract_id =" + contract_id + "')"
        };  
        adiha_post_data('return_array', param, '', '', 'open_contract_win_callback','');
        
    }
    
    open_contract_win_callback = function(result) {
        if (result == 38400) {
            var call_from = 'standard';
        } else if (result == 38401) {
            var call_from = 'nonstandard';
        } else {
            var call_from = 'transportation';
        }
       
        var contract_id = <?php echo $first_form; ?>.getItemValue('contract_id'); 
        win_text = 'Setup Contract';
        param = '../../_contract_administration/maintain_contract_group/maintain.contract.template.php?call_from=' + call_from + '&contract_id=' + contract_id;
        width = 380;
        height = 350;

         if (!popup_window) {
            popup_window = new dhtmlXWindows();
        }
             
        var new_win = popup_window.createWindow('w9', 0, 0, width, height);
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.setText(win_text);
        new_win.maximize();
        new_win.attachURL(param, false, true);
    }

    function enable_menu_btn () {  
        grid_menu_obj.setItemEnabled("delete");
    } 

    function grid_edit () {       
        var tab_text = 'Product';
        var win_type = 'p';      
        var row_id = grid_obj_product.getSelectedRowId(); 
        var id = grid_obj_product.cells(row_id, 0).getValue();  
        contract_mapping.open_popup_window(counterparty_id,internal_counterparty_id,contract_id, id, win_type, sql_stmt[tab_text], grid_obj_product, grid_type[tab_text]);
    }

    function delete_callback() {
        refresh_grid(contract_id,internal_counterparty_id);
    }

    function delete_cct_callback() { 
        refresh_cpty_contract_type_grid();
    }

    function refresh_grid(contract_id,internal_counterparty_id) {      
        var is_allow_all_products_checked = form_obj_product.isItemChecked('allow_all_products');
        if (is_allow_all_products_checked || mode == 'i') {
            grid_obj_product.clearAll();
            grid_menu_obj.setItemDisabled("refresh"); 
            grid_menu_obj.setItemDisabled("add"); 
            grid_menu_obj.setItemDisabled("excel");
            grid_menu_obj.setItemDisabled("pdf");
            return;
        } else {
            grid_menu_obj.setItemEnabled("refresh"); 
            grid_menu_obj.setItemEnabled("add"); 
            grid_menu_obj.setItemEnabled("excel");
            grid_menu_obj.setItemEnabled("pdf");
            var param = {
                "action": "spa_counterparty_contract_address",
                "flag": "h",
                "counterparty_id": counterparty_id,
                "internal_counterparty_id": internal_counterparty_id,
                "contract_id": contract_id 
            };

                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                grid_obj_product.clearAll();
                grid_obj_product.loadXML(param_url); 
            }            
        }

        
    function load_combo(combo_obj, combo_sql) {
        var data = $.param(combo_sql);
        var url = js_php_path + 'dropdown.connector.php?' + data;
        combo_obj.load(url);
        combo_obj.enableFilteringMode(true);
    }
    
    contract_mapping.open_popup_window = function(counterparty_id,internal_counterparty_id,contract_id,id, win_type, sql_stmt, grid_obj, grid_type) {
        unload_window();
        var win_text = '';
        var param = '';
        var width = 850;
        var height = 720;

        if (win_type == 'p') {
            win_text = 'Product';
            param = 'counterparty.contract.product.php?counterparty_id=' + counterparty_id + '&internal_counterparty_id=' + internal_counterparty_id + '&contract_id=' + contract_id  + '&counterparty_credit_block_id=' + id + '&counterparty_contract_address_id=' + counterparty_contract_address_id;
            width = 540;
            height = 450;
        }  

        if (!popup_window) {
            popup_window = new dhtmlXWindows();
        }
        
        new_win = popup_window.createWindow('w1', 0, 0, width, height);
        new_win.centerOnScreen();
        new_win.setModal(true);
        
        if(sql_stmt != '' && grid_obj != '' && grid_type != '') {
            new_win.attachEvent("onClose", function(win) {
                refresh_grid(contract_id,internal_counterparty_id);
                return true;
            })
        }
        
        new_win.setText(win_text);

        new_win.attachURL(param, false, true);
    }

    contract_mapping.open_counterparty_contract_type_document_popup_window = function(counterparty_id,internal_counterparty_id,contract_id,id, win_type, sql_stmt, grid_obj, grid_type) {
        unload_window();
        var win_text = '';
        var param = '';
        var width = 850;
        var height = 720;

        if (win_type == 'p') {
            win_text = 'Product';
            param = 'counterparty.contract.product.php?counterparty_id=' + counterparty_id + '&internal_counterparty_id=' + internal_counterparty_id + '&contract_id=' + contract_id  + '&counterparty_credit_block_id=' + id;
            width = 540;
            height = 450;
        }  

        if (!popup_window) {
            popup_window = new dhtmlXWindows();
        }
        
        new_win = popup_window.createWindow('w1', 0, 0, width, height);
        new_win.centerOnScreen();
        new_win.setModal(true);
        
        if(sql_stmt != '' && grid_obj != '' && grid_type != '') {
            new_win.attachEvent("onClose", function(win) {
                refresh_grid(contract_id,internal_counterparty_id);
                return true;
            })
        }
        
        new_win.setText(win_text);

        new_win.attachURL(param, false, true);
    }

    /**
     * [unload_window Window unload function]
     * @param  {[type]} win_type [window type]
     */
    function unload_window(win_type) {
        if (popup_window != null && popup_window.unload != null) {
            popup_window.unload();
            popup_window = w1 = null;
        }
    }
</script> 
