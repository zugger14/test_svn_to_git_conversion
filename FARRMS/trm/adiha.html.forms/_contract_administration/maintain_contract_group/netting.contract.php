<?php
/**
* Netting contract screen
* @copyright Pioneer Solutions
*/
?>
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
            $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
            $contract_id = get_sanitized_value($_GET['contract_id'] ?? '');
             
            $function_id = 10105898;
            $rights_netting_add_save = 10105899;
            $rights_netting_delete = 10105905;  
            $rights_netting_contract = 10105906;  
            
            list (
                    $has_rights_netting_add_save, 
                    $has_rights_netting_delete,
                    $has_rights_netting_contract
            ) = build_security_rights(
                    $rights_netting_add_save,  
                    $rights_netting_delete,
                    $rights_netting_contract
            );
             
            $layout_json = '[ 
                                {
                                        id:             "a",
                                        text:           "General",                                        
                                        height:         300,
                                        header:         false,
                                        collapse:       false
                                }, 
                                {
                                        id:             "b",
                                        text:           "Invoice",
                                        height:         400,
                                        width:          900,
                                        header:         true,
                                        collapse:       false,
                                        fix_size:       [false,null]
                                }, 
                                {
                                        id:             "c",
                                        text:           "Contract",
                                        height:         400,
                                        width:          250,
                                        header:         true,
                                        collapse:       false,                                        
                                        fix_size:       [false,null]
                                }
                            ]';

            $menu_json = '[
                            {id: "save", img: "save.gif", imgdis:"save_dis.gif", text: "Save", enabled:"' . $has_rights_netting_add_save. '"},
                            {id: "edit", img:"edit.gif", imgdis: "edit_dis.gif", text: "Edit", items:[
                                    {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:"' . $has_rights_netting_add_save. '"},
                                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", enabled:"' . $has_rights_netting_delete. '"}
                                ]
                            },
                            {id: "export", img:"export.gif", imgdis: "export_dis.gif", text: "Export", items:[
                                    {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                                    {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true}
                                ]
                            }
                        ]'; 
     
            $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='netting_invoice', @parse_xml='<Root><PSRecordset contract_id=" . '"' . '"' ."></PSRecordset></Root>'";

            $form_namespace = 'netting_contract';

            //Attaching Layout  
            $netting_contract_layout_obj = new AdihaLayout();
            echo $netting_contract_layout_obj->init_layout('netting_contract_layout', '', '3T', $layout_json, $form_namespace);

            //Attaching Menu  
            $menu_obj = new AdihaMenu();     
            echo $netting_contract_layout_obj->attach_menu_cell('NettingContractMenu', 'a');
            echo $menu_obj->init_by_attach('NettingContractMenu', $form_namespace);
            echo $menu_obj->load_menu($menu_json);
            echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.grid_menu_click'); 

            // //Attaching grid  
            echo $netting_contract_layout_obj->attach_grid_cell('NettingContractGrid', 'a');
            $NettingContractGrid_obj = new GridTable('NettingContractGrid');
            echo $NettingContractGrid_obj->init_grid_table('NettingContractGrid', $form_namespace,'n');
            echo $NettingContractGrid_obj->set_column_auto_size();
            echo $NettingContractGrid_obj->set_search_filter(true, "");
            echo $NettingContractGrid_obj->return_init();   
            echo $NettingContractGrid_obj->attach_event('', 'onRowSelect', 'grid_row_click');   
            echo $NettingContractGrid_obj->attach_event('', 'onCellChanged', 'grid_cell_change');

            //Attaching form
            $form_data = readXMLURL2($form_sql);
            $form_json = $form_data[0]['form_json'];

            $form_name = 'invoice_form';
            echo $netting_contract_layout_obj->attach_form($form_name, 'b');
            $form_obj = new AdihaForm();
            echo $form_obj->init_by_attach($form_name, $form_namespace);
            echo $form_obj->load_form($form_json); 
            
            echo $netting_contract_layout_obj->close_layout();         
        ?>
    </body>     
    <script type="text/javascript">
        var counterparty_id = '<?php echo $counterparty_id;?>';
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        var session = "<?php echo $session_id; ?>";
        var contract_id = '<?php echo $contract_id; ?>';    
        var has_rights_netting_add_save =<?php echo (($has_rights_netting_add_save) ? $has_rights_netting_add_save : '0'); ?>;
        var has_rights_netting_delete =<?php echo (($has_rights_netting_delete) ? $has_rights_netting_delete : '0'); ?>;  
        var has_rights_netting_contract =<?php echo (($has_rights_netting_contract) ? $has_rights_netting_contract : '0'); ?>;  
        
        $(function() {  
             load_netting_contract_grid();
             create_contract_menu();
             create_contract_grid();

             attach_browse_event('netting_contract.invoice_form', 10105898, '', '', 'id=' + counterparty_id);
             attach_browse_event('netting_contract.invoice_form', 10105898, '', '', 'id=' + counterparty_id);
             attach_browse_event('netting_contract.invoice_form', 10105898, '', '', 'id=' + counterparty_id);

             netting_contract.invoice_form.attachEvent("onChange", function (name, value, state){
             if(name == 'offset_method') { 
                var selected_row = netting_contract.NettingContractGrid.getSelectedRowId(); 
                var netting_type = netting_contract.NettingContractGrid.cells(selected_row,netting_contract.NettingContractGrid.getColIndexById('netting_type')).getValue();
                if(netting_type != 109802) {
                    if(value == 43500) { //cash apply 
                        netting_contract.invoice_form.hideItem('holiday_calendar_id');
                        netting_contract.invoice_form.hideItem('invoice_due_date'); //payment_rule
                        netting_contract.invoice_form.hideItem('payment_days');
                        netting_contract.invoice_form.hideItem('payment_calendar');

                    } else if (value == 43501) {//payment date
                        netting_contract.invoice_form.showItem('holiday_calendar_id');
                        netting_contract.invoice_form.showItem('invoice_due_date');
                        netting_contract.invoice_form.showItem('payment_days');
                        netting_contract.invoice_form.showItem('payment_calendar');

                    }  
                }
             }
        });
        });

        netting_contract.grid_menu_click = function(id, zoneId, cas) {
            switch(id) {
                case "add":
                    var newId = (new Date()).valueOf();  
                    netting_contract.NettingContractGrid.addRow(newId, "");
                    netting_contract.NettingContractGrid.selectRowById(newId);
                    netting_contract.NettingContractGrid.forEachRow(function(row) {
                        
                    netting_contract.NettingContractGrid.forEachCell(row,function(cellObj, ind) {
                        netting_contract.NettingContractGrid.validateCell(row, ind);
                    });
                    netting_contract.grid.clearAll();
                });
                    break;
                case "delete":
                        var selected_netting_contract = netting_contract.NettingContractGrid.getSelectedRowId(); 
                        var netting_group_id = netting_contract.NettingContractGrid.cells(selected_netting_contract,netting_contract.NettingContractGrid.getColIndexById('netting_contract_id')).getValue();

                        if(!netting_group_id) {
                            netting_contract.NettingContractGrid.deleteSelectedRows();
                            netting_contract.contract_toolbar.setItemDisabled('add');
                            netting_contract.contract_toolbar.setItemDisabled('save'); 
                            netting_contract.NettingContractMenu.setItemDisabled('delete');
                            netting_contract.NettingContractMenu.setItemDisabled('save');
                        } else {                        
                            data = {
                                        "action": "spa_stmt_contract_netting",
                                        "flag": "f",
                                        "netting_group_id": netting_group_id
                                    };
                            adiha_post_data("confirm", data, "", "", "delete_netting_contract_callback","");
                        }  
                    break;
                case "excel":
                    netting_contract.NettingContractGrid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    netting_contract.NettingContractGrid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case "save":
                    save_netting_contract();
                    break;                
            }
        };

        function delete_netting_contract_callback() {
            load_netting_contract_grid();
        }

        function grid_row_click(id) { 
			if (has_rights_netting_delete) {
				netting_contract.NettingContractMenu.setItemEnabled('delete');
            }
		
            if (has_rights_netting_add_save) {                
                netting_contract.NettingContractMenu.setItemEnabled('save');
            }
                
            var netting_contract_id = netting_contract.NettingContractGrid.cells(id,netting_contract.NettingContractGrid.getColIndexById('contract_id')).getValue();

            if(has_rights_netting_contract) {
                netting_contract.contract_toolbar.setItemEnabled('add');
                netting_contract.contract_toolbar.setItemEnabled('save');
            } else {                    
                netting_contract.contract_toolbar.setItemDisabled('add');
                netting_contract.contract_toolbar.setItemDisabled('save');
            }

            var netting_group_id = netting_contract.NettingContractGrid.cells(id,netting_contract.NettingContractGrid.getColIndexById('netting_contract_id')).getValue();

            var netting_type = netting_contract.NettingContractGrid.cells(id,netting_contract.NettingContractGrid.getColIndexById('netting_type')).getValue(); 
            
            hide_show_invoice_item(netting_type);

            if(netting_contract_id){
                refresh_contract_grid(netting_group_id) 

                //loading invoice form data
                 data = {
                            "action": "spa_stmt_contract_netting",
                            "flag": "d",
                            "netting_contract_id": netting_contract_id,
                            "counterparty_id": counterparty_id
                        };

                adiha_post_data("return", data, "", "", "load_form_data","");  
            }
            // } else {   
            //     netting_contract.grid.clearAll();
            //     var form_obj = netting_contract.invoice_form;

            //     form_obj.setItemValue('invoice_due_date','');
            //     form_obj.setItemValue('payment_days','');
            //     form_obj.setItemValue('settlement_date','');
            //     form_obj.setItemValue('settlement_days','');
            //     form_obj.setItemValue('payment_calendar','');
            //     form_obj.setItemValue('settlement_calendar','');
            //     form_obj.setItemValue('holiday_calendar_id','');
            //     form_obj.setItemValue('volume_granularity',980);
            //     form_obj.setItemValue('invoice_report_template','');
            //     form_obj.setItemValue('contract_report_template','');
            //     form_obj.setItemValue('netting_template','');
            //     form_obj.setItemValue('contract_email_template','');
            //     form_obj.setItemValue('label_credit','');
            //     form_obj.setItemValue('label_payables','');
            //     form_obj.setItemValue('label_receivables','');
            //     form_obj.setItemValue('offset_method','');

            //     netting_contract.invoice_form.hideItem('holiday_calendar_id');
            //     netting_contract.invoice_form.hideItem('invoice_due_date'); //payment_rule
            //     netting_contract.invoice_form.hideItem('payment_days');
            //     netting_contract.invoice_form.hideItem('payment_calendar');
            // }
            
            load_contract_combo();
        }

        function grid_cell_change(rId,cInd,nValue) {
            var netting_type_col_id = netting_contract.NettingContractGrid.getColIndexById('netting_type');
            if(cInd == netting_type_col_id) {
                hide_show_invoice_item(nValue);
            }

        }

        function load_form_data(result) {  
            var form_obj = netting_contract.invoice_form;

            var invoice_due_date = result[0].payment_rule 
            var payment_days = result[0].payment_days
            var settlement_date = result[0].settlement_rule
            var settlement_days = result[0].settlement_days
            var payment_calendar = result[0].payment_calendar
            var settlement_calendar = result[0].settlement_calendar
            var holiday_calendar_id = result[0].holiday_calendar
            var volume_granularity = result[0].invoice_frequency
            var invoice_report_template = result[0].invoice
            var contract_report_template = result[0].remittance
            var netting_template = result[0].netting
            var contract_email_template = result[0].email
            var credit = result[0].credit
            var payables = result[0].payables
            var receivables = result[0].receivables
            var credit_name = result[0].credit_name
            var payables_name = result[0].payables_name
            var receivables_name = result[0].receivables_name
            var offset_method = result[0].offset_method
             
            form_obj.setItemValue('invoice_due_date',invoice_due_date);
            form_obj.setItemValue('payment_days',payment_days);
            form_obj.setItemValue('settlement_date',settlement_date);
            form_obj.setItemValue('settlement_days',settlement_days);
            form_obj.setItemValue('payment_calendar',payment_calendar);
            form_obj.setItemValue('settlement_calendar',settlement_calendar);
            form_obj.setItemValue('holiday_calendar_id',holiday_calendar_id);
            form_obj.setItemValue('volume_granularity',volume_granularity);
            form_obj.setItemValue('invoice_report_template',invoice_report_template);
            form_obj.setItemValue('contract_report_template',contract_report_template);
            form_obj.setItemValue('netting_template',netting_template);
            form_obj.setItemValue('contract_email_template',contract_email_template);
            form_obj.setItemValue('label_credit',credit_name);
            form_obj.setItemValue('label_payables',payables_name);
            form_obj.setItemValue('label_receivables',receivables_name);

            var selected_row = netting_contract.NettingContractGrid.getSelectedRowId(); 
            var netting_type = netting_contract.NettingContractGrid.cells(selected_row,netting_contract.NettingContractGrid.getColIndexById('netting_type')).getValue(); 
              
            if(netting_type == 109800 || netting_type == 109802) {
                form_obj.setItemValue('offset_method',offset_method);
            } else {         
                var offset_method_combo_obj = form_obj.getCombo('offset_method');
                offset_method_combo_obj.setComboValue(null);
                offset_method_combo_obj.setComboText(null);    
            }
            
            if(netting_type == 109800) { //credit
                if(offset_method == 43500) { //cash apply 
                    netting_contract.invoice_form.hideItem('holiday_calendar_id');
                    netting_contract.invoice_form.hideItem('invoice_due_date'); //payment_rule
                    netting_contract.invoice_form.hideItem('payment_days');
                    netting_contract.invoice_form.hideItem('payment_calendar');

                } else if (offset_method == 43501) {//payment date
                    netting_contract.invoice_form.showItem('holiday_calendar_id');
                    netting_contract.invoice_form.showItem('invoice_due_date');
                    netting_contract.invoice_form.showItem('payment_days');
                    netting_contract.invoice_form.showItem('payment_calendar');

                } else {
                    netting_contract.invoice_form.hideItem('holiday_calendar_id');
                    netting_contract.invoice_form.hideItem('invoice_due_date'); //payment_rule
                    netting_contract.invoice_form.hideItem('payment_days');
                    netting_contract.invoice_form.hideItem('payment_calendar');
                }
            } else { 
                netting_contract.invoice_form.showItem('holiday_calendar_id');
                netting_contract.invoice_form.showItem('invoice_due_date');
                netting_contract.invoice_form.showItem('payment_days');
                netting_contract.invoice_form.showItem('payment_calendar');
            }  
        }

        function hide_show_invoice_item(netting_type) { 
            // alert(netting_type);
            var form_obj = netting_contract.invoice_form;
            var offset_method_combo_obj = form_obj.getCombo('offset_method');

            if(netting_type == 109800) { //Credit 
                 form_obj.hideItem('settlement_date');
                 form_obj.hideItem('settlement_days');
                 form_obj.hideItem('settlement_calendar');
                 form_obj.hideItem('volume_granularity');
                 form_obj.hideItem('invoice_report_template');
                 form_obj.hideItem('contract_report_template');
                 form_obj.hideItem('netting_template');   
                 form_obj.hideItem('contract_email_template');   
                 form_obj.hideItem('label_receivables');    
                 form_obj.hideItem('label_payables');   
                 form_obj.showItem('label_credit');   
                 form_obj.hideItem('holiday_calendar_id');

                 form_obj.setRequired('invoice_report_template',false);
                 form_obj.setRequired('contract_report_template',false);
                 form_obj.setRequired('netting_template',false);
                 form_obj.setRequired('contract_email_template',false);
                 form_obj.setRequired('offset_method',true);
 
                 form_obj.showItem('offset_method'); 
            } else if (netting_type == 109801) { //Settlement 
                 form_obj.showItem('settlement_date');
                 form_obj.showItem('settlement_days');
                 form_obj.showItem('settlement_calendar');
                 form_obj.showItem('holiday_calendar_id');
                 form_obj.showItem('volume_granularity');
                 form_obj.showItem('invoice_report_template');
                 form_obj.showItem('contract_report_template');
                 form_obj.showItem('netting_template');   
                 form_obj.showItem('contract_email_template');   
                 form_obj.showItem('label_receivables');   
                 form_obj.showItem('label_payables'); 
                 form_obj.hideItem('label_credit'); 

                 form_obj.setRequired('invoice_report_template',true);
                 form_obj.setRequired('contract_report_template',true);
                 form_obj.setRequired('netting_template',true);
                 form_obj.setRequired('contract_email_template',true);
                 form_obj.setRequired('offset_method',false);
                 form_obj.showItem('invoice_due_date');
                 form_obj.showItem('payment_days');
                 form_obj.showItem('payment_calendar');
                  
                 offset_method_combo_obj.setComboValue(null);
                 offset_method_combo_obj.setComboText(null); 
                 form_obj.hideItem('offset_method');  
            } else { // Both
                 form_obj.showItem('settlement_date');
                 form_obj.showItem('settlement_days');
                 form_obj.showItem('settlement_calendar');
                 form_obj.showItem('holiday_calendar_id');
                 form_obj.showItem('volume_granularity');
                 form_obj.showItem('invoice_report_template');
                 form_obj.showItem('contract_report_template');
                 form_obj.showItem('netting_template');   
                 form_obj.showItem('contract_email_template');   
                 form_obj.showItem('label_receivables');   
                 form_obj.showItem('label_payables'); 
                 form_obj.showItem('label_credit'); 
                 form_obj.showItem('invoice_due_date');
                 form_obj.showItem('payment_days');
                 form_obj.showItem('payment_calendar');
                 form_obj.showItem('offset_method'); 

                 form_obj.setRequired('invoice_report_template',true);
                 form_obj.setRequired('contract_report_template',true);
                 form_obj.setRequired('netting_template',true);
                 form_obj.setRequired('contract_email_template',true);
                 form_obj.setRequired('offset_method',true);
 
                 // offset_method_combo_obj.setComboValue(null);
                 // offset_method_combo_obj.setComboText(null); 
                 // form_obj.hideItem('offset_method'); 
            }
        }
        
        function save_netting_contract() {
            var selected_row = netting_contract.NettingContractGrid.getSelectedRowId();                 
            netting_contract.NettingContractGrid.clearSelection();
            var sel_netting_contract_col_id = netting_contract.NettingContractGrid.getColIndexById('netting_contract'); 

            var grid_xml = "<Root><GridGroup><Grid>";
            var row_ids = netting_contract.NettingContractGrid.getChangedRows(true);
            attached_obj = netting_contract.NettingContractGrid;
            var grid_label = attached_obj.getUserData("", "grid_label"); 
            
            var form_obj = netting_contract.invoice_form;

            if (row_ids != "") {
                netting_contract.NettingContractGrid.setSerializationLevel(false,false,true,true,true,true);
                var grid_status = netting_contract.validate_form_grid(attached_obj,grid_label);
                
                if (grid_status) {
                    netting_contract.NettingContractGrid.forEachRow(function(id) {
                        grid_xml += "<GridRow ";
                            for (var cellIndex = 0; cellIndex < netting_contract.NettingContractGrid.getColumnsNum(); cellIndex++){
                            grid_xml += " " + netting_contract.NettingContractGrid.getColumnId(cellIndex) + '="' + netting_contract.NettingContractGrid.cells(id,cellIndex).getValue() + '"';
                            }
                            grid_xml += " counterparty_id =" + '"' +counterparty_id + '"';
                        grid_xml += " ></GridRow> ";
                    });
                } else {
                    return;
                }

                grid_xml += "</Grid></GridGroup></Root>";


                var sel_netting_contract = netting_contract.NettingContractGrid.cells(selected_row,sel_netting_contract_col_id).getValue();

                //invoice data
                var form_xml = '<FormXML ';
                data = form_obj.getFormData();

                for (var a in data) {
                    var field_label = a; 
                    var field_value = data[field_label];                              

                    if (!field_value)
                        field_value = '';

                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                } 
                form_xml += " netting_contract " + "=\"" + sel_netting_contract + "\"";
                form_xml += " counterparty_id " + "=\"" + counterparty_id + "\"";
                form_xml += "></FormXML>"; 
                //
                
                if (grid_status) {
                    data = {
                        "action": "spa_stmt_contract_netting",
                        "flag": "i",
                        "xml": grid_xml,
                        "form_xml": form_xml
                    };

                    adiha_post_data("return_array", data, "", "", "save_netting_group_callback"); 
                }  
            } else {    
                var sel_netting_contract = netting_contract.NettingContractGrid.cells(selected_row,sel_netting_contract_col_id).getValue();                 
                var form_xml = '<FormXML ';
                data = form_obj.getFormData();

                for (var a in data) {
                    var field_label = a; 
                    var field_value = data[field_label];                              

                    if (!field_value)
                        field_value = '';

                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                } 
                form_xml += " netting_contract  " + "=\"" + sel_netting_contract + "\"";
                form_xml += " counterparty_id " + "=\"" + counterparty_id + "\"";
                form_xml += "></FormXML>"; 

                data = {
                        "action": "spa_stmt_contract_netting",
                        "flag": "i",
                        "form_xml": form_xml
                    };

                adiha_post_data("alert", data, "", "", "","");
            } 
        }

        save_netting_group_callback = function(result) { 
            var msg = result[0][4];
            
            if (result[0][0] == 'Success') {
                dhtmlx.message({
                    text:msg,
                    expire:1000
                }); 

                load_netting_contract_grid();
            } else if(result[0][0] == 'Error') {
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text:msg,
                    expire:1000
                });
            }
        }

         
        function load_netting_contract_grid () {
            var param = {
                "action": "spa_stmt_contract_netting",
                "flag": "s",
                "counterparty_id": counterparty_id,
                "grid_type": "g"
            };
            
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            netting_contract.NettingContractGrid.clearAll();
            netting_contract.NettingContractGrid.loadXML(param_url);
            netting_contract.NettingContractMenu.setItemDisabled('delete');
        }

        function create_contract_grid () {
            netting_contract.grid = netting_contract.netting_contract_layout.cells('c').attachGrid();
            netting_contract.grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
            netting_contract.grid.setHeader("ID,Contract,Description");
            netting_contract.grid.setColumnIds("netting_group_detail_id,contract_id,contract_description");
            netting_contract.grid.setColTypes("ro,combo,ed");
            netting_contract.grid.setColSorting("str,str,str");
            netting_contract.grid.setColumnsVisibility("true,false,true");
            netting_contract.grid.setInitWidths('0,200,300');
            netting_contract.grid.enableMultiselect(true);
            netting_contract.grid.init();

            netting_contract.grid.attachEvent("onRowSelect", function(id,ind){  
                if (has_rights_netting_contract)
                    netting_contract.contract_toolbar.setItemEnabled('delete');
            });
        }   

        function load_contract_combo() {
            var combo_obj = netting_contract.grid.getColumnCombo(netting_contract.grid.getColIndexById('contract_id'));

            var selected_row = netting_contract.NettingContractGrid.getSelectedRowId();  
            if (selected_row != null) {
                var internal_counterparty_col_id = netting_contract.NettingContractGrid.getColIndexById('internal_counterparty_id'); 
                var internal_counterparty = netting_contract.NettingContractGrid.cells(selected_row,internal_counterparty_col_id).getValue();
            }

            var cm_param = {
                    "action": "spa_stmt_contract_netting",
                    "flag": "c", 
                    "counterparty_id": counterparty_id, 
                    "internal_counterparty_id": internal_counterparty, 
                    "has_blank_option": false
            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            combo_obj.load(url, function() {
                combo_obj.enableFilteringMode(true); 
            });
        }

            /*
         * Load menu and its event for the detail grid (contract grid)
         */
        function create_contract_menu() { 
            var detail_grid_menu_json = [
                {id: "save", img: "save.gif", imgdis:"save_dis.gif", disabled: true, title: "Save"},
                {id:"child_menu", text:"Edit", img:"edit.gif", items:[
                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add",disabled: true},
                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                ]} 
            ];
            
            netting_contract.contract_toolbar = netting_contract.netting_contract_layout.cells('c').attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : detail_grid_menu_json
            }); 

            netting_contract.contract_toolbar.attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
                        var new_id = (new Date()).valueOf(); 
                        netting_contract.grid.addRow(new_id,'');
                        netting_contract.grid.selectRowById(new_id);
                        break;
                    case 'save' :
                        var grid_xml = "<Root><GridGroup><Grid>";
                        var changed_rows = netting_contract.grid.getChangedRows();
                        var changed_ids = new Array();
                        changed_ids = changed_rows.split(",");

                        var grid_label = 'Contract'
                        attached_obj = netting_contract.NettingContractGrid;
                        var error = false;
                        if (changed_rows != "") {
                        var grid_status = netting_contract.validate_form_grid(attached_obj,grid_label);

                            if (grid_status) { 
                                $.each(changed_ids, function(id, value) { 
                                    var sel_netting_group = netting_contract.NettingContractGrid.getSelectedRowId();
                                    var netting_group_id = netting_contract.NettingContractGrid.cells(sel_netting_group,netting_contract.NettingContractGrid.getColIndexById('netting_contract_id')).getValue();  

                                    grid_xml += "<GridRow ";    
                                    grid_xml += " netting_group_id =" + '"' +netting_group_id + '" ';  

                                    for(var cellIndex = 0; cellIndex < netting_contract.grid.getColumnsNum(); cellIndex++){
                                            var column_id = netting_contract.grid.getColumnId(cellIndex);
                                            var cell_value = netting_contract.grid.cells(value, cellIndex).getValue();
                                            if (column_id == 'contract_id' || column_id == 'netting_group_detail_id') { 
                                                grid_xml += column_id + '="' + cell_value + '" ';
                                            }
                                            if (column_id == 'contract_id' && cell_value == '') { 
                                                error = true;
                                            }
                                        } 
                                    grid_xml += " ></GridRow> ";
                                });
                                grid_xml += "</Grid></GridGroup></Root>";

                                if(error) {
                                    show_messagebox('<strong>Contract</strong> cannot be empty.');
                                    return
                                }

                                if (grid_status) {
                                    data = {
                                        "action": "spa_stmt_contract_netting",
                                        "flag": "b",
                                        "xml": grid_xml
                                    };

                                    adiha_post_data("return_array", data, "", "", "save_contract_callback","");
                                }
                            }
                        } else {
                            show_messagebox("No change in the grid.");
                        } 
                        break;

                    case 'delete':
                        var selected_contract_row = netting_contract.grid.getSelectedRowId();
                        var selected_contract_row_arr = selected_contract_row.split(','); 
                        var netting_group_detail_array = new Array();

                        for(var i = 0; i < selected_contract_row_arr.length; i++) {     
                            netting_group_detail_id = netting_contract.grid.cells(selected_contract_row_arr[i], netting_contract.grid.getColIndexById('netting_group_detail_id')).getValue();
                            if(!netting_group_detail_id) {                                
                                netting_contract.grid.deleteRow(selected_contract_row_arr[i]); 
                            } else {                                
                                netting_group_detail_array.push(netting_group_detail_id);
                            }
                        } 

                        var netting_group_detail_ids = netting_group_detail_array.toString();  

                        if(!netting_group_detail_ids) {
                            return;
                        }
                        data = {
                                    "action": "spa_stmt_contract_netting",
                                    "flag": "e",
                                    "contract_ids": netting_group_detail_ids
                                };
                        adiha_post_data("confirm", data, "", "", "delete_contract_callback",""); 
                        break; 
                }
            });
        } 

        function delete_contract_callback() {
            var selected_row = netting_contract.NettingContractGrid.getSelectedRowId();
            var netting_group_id = netting_contract.NettingContractGrid.cells(selected_row,netting_contract.NettingContractGrid.getColIndexById('netting_contract_id')).getValue();
            refresh_contract_grid(netting_group_id);
        }

        function save_contract_callback(result) { 
                var msg = result[0][4];
                if (result[0][0] == 'Success') {
                    dhtmlx.message({
                        text:'Changes have been saved successfully.',
                        expire:1000
                    }); 
                    
                    var selected_row = netting_contract.NettingContractGrid.getSelectedRowId();
                    var netting_group_id = netting_contract.NettingContractGrid.cells(selected_row,netting_contract.NettingContractGrid.getColIndexById('netting_contract_id')).getValue();
                    refresh_contract_grid(netting_group_id);
                } else if(result[0][0] == 'Error') {
                    dhtmlx.message({
                        type: "alert-error",
                        title: "Error",
                        text: msg,
                        expire:1000
                    });
                }

            }
            

        function refresh_contract_grid(netting_group_id){
            var param = {
                    "action": "spa_stmt_contract_netting",
                    "flag": "a",
                    "netting_group_id": netting_group_id,
                    "grid_type": "g"
                };
                
                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                netting_contract.grid.clearAll(); 
                netting_contract.grid.loadXML(param_url, function(){
                    netting_contract.contract_toolbar.setItemDisabled('delete');
                });
                
        }

        netting_contract.validate_form_grid = function(attached_obj,grid_label,call_from) {;
            var status = true;
                for (var i = 0;i < attached_obj.getRowsNum();i++){
                    var row_id = attached_obj.getRowId(i);
                    var no_of_child = ""; 
                    if (call_from == "deal") {
                        no_of_child =  attached_obj.hasChildren(row_id);
                    }
                    call_from = (call_from && typeof call_from != "undefined") ? call_from : "";
                    if (call_from == "" || (call_from == "deal" && no_of_child == 0)) {
                     for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
                        var type = attached_obj.getColType(j);
                        if (type == "combo") {
                            combo_obj = attached_obj.getColumnCombo(j); 
                            var value = attached_obj.cells(row_id,j).getValue();
                            if (combo_obj.getOptionsCount() != 0 && value != "") {
                                var selected_option = combo_obj.getIndexByValue(value);
                                if (selected_option == -1) {
                                    var message = "Invalid Data";
                                    attached_obj.cells(row_id,j).setAttribute("validation", message);
                                    attached_obj.cells(row_id, j).cell.className = " dhtmlx_validation_error";
                                } else {
                                    attached_obj.cells(row_id,j).setAttribute("validation", "");
                                    attached_obj.cells(row_id, j).cell.className = attached_obj.cells(row_id, j).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");
                                }
                            }
                        }
                        var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                        if(validation_message != "" && validation_message != undefined){
                            var column_text = attached_obj.getColLabel(j);
                            error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                            dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                            status = false; break;
                        }
                    }
                    }
                if(validation_message != "" && validation_message != undefined){ break;};
            }
         return status;
        }
     

    </script> 
</html>
