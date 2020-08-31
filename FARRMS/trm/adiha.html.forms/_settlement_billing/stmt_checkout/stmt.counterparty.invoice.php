<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $stmt_invoice_id = ($_GET['stmt_invoice_id'] == "")?"-1":get_sanitized_value($_GET['stmt_invoice_id']);

    $json = '[
                {
                    id:             "a",
                    text:           "Counterparty Invoice",
                    header:         false,
                    collapse:       false,
                    width:          390,
                    height:         170
                },
                {
                    id:             "b",
                    text:           "Counterparty Invoice",
                    header:         false,
                    collapse:       false,
                    width:          390
                },
            ]';

    $namespace = 'counterparty_invoice';
    $counterparty_invoice_layout_obj = new AdihaLayout();
    echo $counterparty_invoice_layout_obj->init_layout('counterparty_invoice_layout', '', '2E', $json, $namespace);

    //Attaching Toolbar for Contract Settlement Grid
    $toolbar_json = '[
                        { id: "refresh", type: "button", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                        { type: "separator" },
                        { id: "save", type: "button", img: "save.gif", text: "Save", title: "Save" },
                        { type: "separator" },
                        {id:"excel", type: "button", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        { type: "separator" }
                     ]';

    //Attaching filter form for Counterparty/Contract Grid
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20012203', @template_name='settlement counterparty invoice', @parse_xml='<Root><PSRecordset stmt_invoice_id=\"$stmt_invoice_id\"></PSRecordset></Root>'";
    $form_arr = readXMLURL2($form_sql);
    $tab_id = $form_arr[0]['tab_id'];
    $form_json = $form_arr[0]['form_json'];

    echo $counterparty_invoice_layout_obj->attach_form('counterparty_invoice_form', 'a');
    $filter_form_obj = new AdihaForm();
    echo $filter_form_obj->init_by_attach('counterparty_invoice_form', $namespace);
    echo $filter_form_obj->load_form($form_json);
    
    echo $counterparty_invoice_layout_obj->attach_toolbar_cell('counterparty_invoice_toolbar', 'b');
    $counterparty_invoice_toolbar_obj = new AdihaToolbar();
    echo $counterparty_invoice_toolbar_obj->init_by_attach('counterparty_invoice_toolbar', $namespace);
    echo $counterparty_invoice_toolbar_obj->load_toolbar($toolbar_json);
    echo $counterparty_invoice_toolbar_obj->attach_event('', 'onClick', 'counterparty_invoice_toolbar_onclick');

    echo $counterparty_invoice_layout_obj->attach_grid_cell('counterparty_invoice_grid', 'b');
    $counterparty_invoice_grid_obj = new GridTable('SettlementCounterpartyInvoice');
    echo $counterparty_invoice_grid_obj->init_grid_table('counterparty_invoice_grid', $namespace);
    echo $counterparty_invoice_grid_obj->return_init();
    echo $counterparty_invoice_grid_obj->attach_event('', 'onCellChanged', $namespace.'.grid_cell_change');
    echo $counterparty_invoice_grid_obj->attach_event('', 'onEditCell', $namespace.'.grid_cell_edit');
    echo $counterparty_invoice_grid_obj->load_grid_functions();
    

    echo $counterparty_invoice_layout_obj->close_layout();
    ?>
    
    <script type="text/javascript">  
        var stmt_invoice_id = '<?php echo $stmt_invoice_id; ?>';
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        
        $(function() {
            counterparty_invoice_toolbar_onclick('refresh');
        });
        
        function counterparty_invoice_toolbar_onclick(name, value) {
            if (name == 'refresh') {
                var form_obj = counterparty_invoice.counterparty_invoice_layout.cells('a').getAttachedObject();
                var status = validate_form(form_obj);
                if (status == false) {
                    return;
                }
                
                var invoice_date = counterparty_invoice.counterparty_invoice_form.getItemValue('invoice_date',true);
                var invoice_due_date = counterparty_invoice.counterparty_invoice_form.getItemValue('invoice_due_date',true);
                var description1 = counterparty_invoice.counterparty_invoice_form.getItemValue('description1');
                var description2 = counterparty_invoice.counterparty_invoice_form.getItemValue('description2');
                var amount = counterparty_invoice.counterparty_invoice_form.getItemValue('description3');
                
                var param = {
                                "flag": 'g',
                                "action": "spa_stmt_invoice",
                                "grid_type": "g",
                                "stmt_invoice_id": stmt_invoice_id,
                                "amount": amount
                            };
                
                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                counterparty_invoice.counterparty_invoice_grid.clearAll();

                counterparty_invoice.counterparty_invoice_grid.loadXML(param_url, function(){
                    var row_number = counterparty_invoice.counterparty_invoice_grid.getRowsNum();
                    var col_number = counterparty_invoice.counterparty_invoice_grid.getColumnsNum(); 
                    
                    for (i = row_number-1; i < row_number; i++) {                        
                        for (j = 0; j < col_number-1; j++) {
                            counterparty_invoice.counterparty_invoice_grid.cells(i,j).setDisabled(true); 
                            counterparty_invoice.counterparty_invoice_grid.setCellTextStyle(i,j,"font-weight:bold;");  
                        }
                    }
                });
               
            } else if (name == 'save') {
                save_counterparty_invoice();
            } else if (name == 'excel') {
                counterparty_invoice.counterparty_invoice_grid.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            } 
        }
        
        counterparty_invoice.grid_cell_edit = function(stage, rId, cInd, nValue, oValue) {
            var amount_index = counterparty_invoice.counterparty_invoice_grid.getColIndexById("amount");
            if (stage == 2 && cInd == amount_index) {
                if (cInd = amount_index && nValue != oValue) {
                    nValue = nValue * -1;
                    counterparty_invoice.counterparty_invoice_grid.cells(rId,amount_index).setValue(nValue);
                }
            }
            
            return nValue;
        }
        counterparty_invoice.grid_cell_change = function(rId,cInd,nValue) {  
            var colLabel=counterparty_invoice.counterparty_invoice_grid.getColLabel(cInd);
            var sel_row = counterparty_invoice.counterparty_invoice_grid.getSelectedRowId();
            var shadow_calc_index=counterparty_invoice.counterparty_invoice_grid.getColIndexById("shadow_calc");
            var amount_index=counterparty_invoice.counterparty_invoice_grid.getColIndexById("amount");
            var variance_index=counterparty_invoice.counterparty_invoice_grid.getColIndexById("variance");
            var row_number = counterparty_invoice.counterparty_invoice_grid.getRowsNum();  
            var shadow_calc_total = 0;
            var amount_total = 0;
            var variance_total = 0;

            if (rId == row_number - 1) {
                return false;
            }

            if (sel_row) {     
                if (colLabel == 'Shadow Calc') {  
                    var amount = counterparty_invoice.counterparty_invoice_grid.cells(rId,amount_index).getValue();  
                    var variance = nValue - amount;  
                    variance = Math.round(variance * 100) / 100
                    counterparty_invoice.counterparty_invoice_grid.cells(rId,variance_index).setValue(variance); 
                } else if (colLabel == 'Amount') {
                    var shadow_calc = counterparty_invoice.counterparty_invoice_grid.cells(rId,shadow_calc_index).getValue();  
                    var variance = shadow_calc - nValue;  
                    variance = Math.round(variance * 100) / 100
                    counterparty_invoice.counterparty_invoice_grid.cells(rId,variance_index).setValue(variance); 
                } 


                for (i = row_number-1; i < row_number; i++) {                        
                    for (j = 0; j < row_number-1; j++) {
                        var shadow_calc = counterparty_invoice.counterparty_invoice_grid.cells(j,shadow_calc_index).getValue();
                        var amount = counterparty_invoice.counterparty_invoice_grid.cells(j,amount_index).getValue();
                        var variance = counterparty_invoice.counterparty_invoice_grid.cells(j,variance_index).getValue();

                        shadow_calc_total = parseFloat(shadow_calc_total) + parseFloat(shadow_calc);
                        amount_total = parseFloat(amount_total) + parseFloat(amount);
                        variance_total = parseFloat(variance_total) + parseFloat(variance);
                    } 
                }


                counterparty_invoice.counterparty_invoice_grid.cells(row_number-1,shadow_calc_index).setValue(shadow_calc_total); 
                counterparty_invoice.counterparty_invoice_grid.cells(row_number-1,amount_index).setValue(amount_total); 
                counterparty_invoice.counterparty_invoice_grid.cells(row_number-1,variance_index).setValue(variance_total);                 
                 
            }     
            
        }

        function save_counterparty_invoice() {
            counterparty_invoice.counterparty_invoice_grid.clearSelection();
            
            var amount = counterparty_invoice.counterparty_invoice_form.getItemValue('amount');            
            var invoice_ref_no = counterparty_invoice.counterparty_invoice_form.getItemValue('invoice_ref_no');
            var invoice_date = counterparty_invoice.counterparty_invoice_form.getItemValue('invoice_date',true);
            var invoice_due_date = counterparty_invoice.counterparty_invoice_form.getItemValue('invoice_due_date',true);
            var description1 = counterparty_invoice.counterparty_invoice_form.getItemValue('description1');
            var description2 = counterparty_invoice.counterparty_invoice_form.getItemValue('description2');
            
            var ps_xml = "<Root>";
            for (var row_index=0; row_index < counterparty_invoice.counterparty_invoice_grid.getRowsNum()-1; row_index++) {
                ps_xml = ps_xml + "<PSRecordset ";
                for(var cellIndex = 0; cellIndex < counterparty_invoice.counterparty_invoice_grid.getColumnsNum(); cellIndex++){
                    ps_xml = ps_xml + " " + counterparty_invoice.counterparty_invoice_grid.getColumnId(cellIndex) + '="' + counterparty_invoice.counterparty_invoice_grid.cells2(row_index,cellIndex).getValue() + '"';
                }
                ps_xml = ps_xml + " ></PSRecordset> ";
            }
            ps_xml = ps_xml + "</Root>";

            var data = {
                            "action": "spa_stmt_invoice",
                            "flag": "b",
                            "amount": amount,
                            "invoice_ref_no": invoice_ref_no,
                            "invoice_date": invoice_date,
                            "invoice_due_date": invoice_due_date,
                            "description1": description1,
                            "description2": description2,
                            "stmt_invoice_id": stmt_invoice_id,
                            "xml": ps_xml
                
                        };

            adiha_post_data('alert', data, '', '', 'save_invoice_callback', '');
        
        }
        
        function save_invoice_callback() {
            counterparty_invoice.counterparty_invoice_form.setItemValue('amount', null);
            counterparty_invoice_toolbar_onclick('refresh');
        }
    </script>