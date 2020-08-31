<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    
<body>
    <?php   
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

    $rights_run_close_deal = 20012300;
    
    list (
       $has_right_run_close_deal
    ) = build_security_rights (
       $rights_run_close_deal
    );
    
    $namespace = 'close_deal';
    $form_name = 'close_deal_form';

    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filters",
                    header:         true,
                    collapse:       false,
                    height:         85
                },
                {
                    id:             "b",
                    text:           "Filters",
                    header:         true,
                    collapse:       false
                }
            ]';

    $close_deal_layout_obj = new AdihaLayout();
    echo $close_deal_layout_obj->init_layout('close_deal_layout', '', '2E', $json, $namespace);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20012300', @template_name='RunCloseDeals', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    echo $close_deal_layout_obj->attach_form($form_name, 'b');
    $close_deal_form_obj = new AdihaForm();
    echo $close_deal_form_obj->init_by_attach($form_name, $namespace);
    echo $close_deal_form_obj->load_form($form_json);
    
    $toolbar_json = '[
                        { id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}
                     ]';

    echo $close_deal_layout_obj->attach_toolbar_cell('run_close_deal_process_toolbar', 'b');
    $run_close_deal_process_toolbar = new AdihaToolbar();
    echo $run_close_deal_process_toolbar->init_by_attach('run_close_deal_process_toolbar', $namespace);
    echo $run_close_deal_process_toolbar->load_toolbar($toolbar_json);
    echo $run_close_deal_process_toolbar->attach_event('', 'onClick', 'run_button_click');
    echo $close_deal_layout_obj->close_layout();
?>
</body>
    
<script>    
    $(function(){
        var has_right_run_close_deal = Boolean('<?php echo $has_right_run_close_deal; ?>');
        
        if (has_right_run_close_deal == false)
            close_deal.close_deal_form.disableItem('btn_run');
        else 
            close_deal.close_deal_form.enableItem('btn_run');

        var function_id  = 20012300;
        var report_type = 2;
        var filter_obj = close_deal.close_deal_layout.cells('a').attachForm();
        var layout_cell_obj =close_deal.close_deal_layout.cells('b');
        
        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
        attach_browse_event('close_deal.close_deal_form', function_id, '');
    });

    function result_text(name, value) {
        var f = this.getForm();
        return value;
    }

    function run_button_click(args) {

        var sub_id =  close_deal.close_deal_form.getItemValue('subsidiary_id', true);
        var stra_id = close_deal.close_deal_form.getItemValue('strategy_id', true);
        var book_id = close_deal.close_deal_form.getItemValue('book_id', true);
        var sub_book_id = close_deal.close_deal_form.getItemValue('subbook_id', true);
        var book_structure = close_deal.close_deal_form.getItemValue('book_structure', true);
        var deal_type = close_deal.close_deal_form.getItemValue('deal_type', true);
        var tenor_from = close_deal.close_deal_form.getItemValue('tenor_from', true);
        var tenor_to = close_deal.close_deal_form.getItemValue('tenor_to', true);
        var approach = close_deal.close_deal_form.getItemValue('approach', true);
        var margin_product = close_deal.close_deal_form.getItemValue('margin_product', true);
        var perfect_volume_match = close_deal.close_deal_form.isItemChecked('perfect_volume_match') ? 'y' : 'n';
        var source_deal_header_id = null;
        var margin_product = (margin_product == '') ? null : margin_product;

        if (book_structure == '') {
            show_messagebox('Please select Book Structure');
            return;
        }

        if (deal_type == '') {
            show_messagebox('Please select Deal Type');
            return;
        }

        if (tenor_from == '') {
            show_messagebox('Please enter Tenor From');
            return;
        }

        if (tenor_to == '') {
            show_messagebox('Please enter Tenor To');
            return;
        }

        if (tenor_from > tenor_to) {
            show_messagebox('Tenor From cannot be greater than Tenor To');
            return;
        }

        if (approach == '') {
            show_messagebox('Please enter Approach');
            return;
        }

        var param = 'call_from=run_close_deal_process&batch_type=c';
        var title = 'Run Close Deals';
        var exec_call = "EXEC spa_match_deal_volume " + 
                        "@flag='c', " + 
                        "@sub_id=" + singleQuote(sub_id) + ", " +
                        "@stra_id=" + singleQuote(stra_id) + ", " +
                        "@book_id=" + singleQuote(book_id) + ", " +
                        "@sub_book_id=" + singleQuote(sub_book_id) + ", " +
                        "@source_deal_header_id=" + singleQuote(source_deal_header_id) + ", " +
                        "@deal_type=" + singleQuote(deal_type) + ", " +
                        "@tenor_from=" + singleQuote(tenor_from) + ", " +
                        "@tenor_to=" + singleQuote(tenor_to) + ", " +
                        "@approach=" + singleQuote(approach) + "," +
                        "@margin_product=" + singleQuote(margin_product) + "," +
                        "@perfect_volume_match=" + singleQuote(perfect_volume_match); 
        
        adiha_run_batch_process(exec_call, param, title);
    }

    function current_date() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();

        dd = (dd < 10)?('0' + dd): dd
        mm = (mm < 10)?('0' + mm): mm

        var current_date = yyyy + '-' + mm + '-' + dd;
        return current_date;
    }
 </script>