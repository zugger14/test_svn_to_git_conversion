<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <?php  include '../../../adiha.php.scripts/components/include.file.v3.php'; ?>
    </head>

    <body>
        <?php
            $form_namespace = 'margin_analysis';
            $application_function_id = 20010800;
            $date_format = str_replace('yyyy', '%Y', str_replace('dd', '%d', str_replace('mm', '%m', $client_date_format)));
            $as_of_date = date("Y-m-d");

            $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
            $form_obj->define_grid("MarginAnalysis");
            //$form_obj->define_custom_functions("", "", "","", "", "");
            echo $form_obj->init_form('Margin Criteria', 'Margin Criteria Details');
            echo $form_obj->close_form();
        ?>
     </body>
        <script type="text/javascript">
            var client_date_format = '<?php echo $date_format; ?>';
            var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
            var as_of_date = '<?php echo $as_of_date ?>';
            var counterparty_id = "";
            var contract_id = "";
            var product_id = "";
            
            $(function() {
                margin_analysis.menu.addNewSibling('t2','run','Run',true, 'run.gif','run_dis.gif');

                margin_analysis.grid.attachEvent("onXLE", function(grid_obj,count){
                    margin_analysis.grid.expandAll();
                });
                
                margin_analysis.grid.attachEvent("onRowSelect", function(id,ind) {
                    margin_analysis.menu.setItemEnabled('run');
                });
                
                margin_analysis.menu.attachEvent("onClick", function(id, zoneId, cas) {
                    if(id == 'run') {
                     
                        var popup_form_json = [
                                    {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "calendar", name: "as_of_date", label: "As of Date", "dateFormat": client_date_format, "value":as_of_date,serverDateFormat:"%Y-%m-%d"},
                                    {type: "button", value: "Ok", img: "tick.png"}
                                ];
                        var popup = new dhtmlXPopup();
                        var popup_form = popup.attachForm(popup_form_json);
                        //var width = setHistory.invoice_grid.cells('a').getWidth();
                        popup.show(100,100,45,45);

                        popup_form.attachEvent("onButtonClick", function() {

                            var as_of_date = popup_form.getItemValue('as_of_date', true);
                            var r_id = margin_analysis.grid.getSelectedRowId();
                            var col_index_counterparty_id = margin_analysis.grid.getColIndexById("source_counterparty_id");
                            var col_index_contract_id = margin_analysis.grid.getColIndexById("source_contract_id");
                            var col_index_product_id = margin_analysis.grid.getColIndexById("source_product_id");

                            counterparty_id = margin_analysis.grid.cells(r_id, col_index_counterparty_id).getValue();
                            contract_id = margin_analysis.grid.cells(r_id, col_index_contract_id).getValue();
                            product_id = margin_analysis.grid.cells(r_id, col_index_product_id).getValue();
                            
                            run_margin_anlaysis(counterparty_id, contract_id, product_id, as_of_date)

                            popup.hide(); 
                        });
                    }

                });
            });

            function run_margin_anlaysis(counterparty_id, contract_id, product_id, as_of_date) {
                
                var exec_call = "EXEC spa_calc_margin @flag ='i' "
                            + ", @counterparty_id = " + singleQuote(counterparty_id)
                            + ", @contract_id = " + singleQuote(contract_id)
                            + ", @product_id = " + singleQuote(product_id)
                            + ", @as_of_date = " + singleQuote(dates.convert_to_sql(as_of_date));
                           
                                                    

                var param = 'call_from=margin_analysis_Job&gen_as_of_date=1&batch_type=c&as_of_date=' + dates.convert_to_sql(as_of_date); 
                adiha_run_batch_process(exec_call, 'param', 'Run Margin Analysis');

            }
 
        </script>

</html>
