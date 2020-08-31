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

    $rights_run_auto_nom = 10164200;
    
    list (
       $has_right_run_auto_nom
    ) = build_security_rights (
       $rights_run_auto_nom
    );
    
    $namespace = 'auto_nom';
    $form_name = 'auto_nom_form';

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

    $auto_nom_layout_obj = new AdihaLayout();
    echo $auto_nom_layout_obj->init_layout('auto_nom_layout', '', '2E', $json, $namespace);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10164200', @template_name='RunAutoNomProcess', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    echo $auto_nom_layout_obj->attach_form($form_name, 'b');
    $auto_nom_form_obj = new AdihaForm();
    echo $auto_nom_form_obj->init_by_attach($form_name, $namespace);
    echo $auto_nom_form_obj->load_form($form_json);
    
    $toolbar_json = '[
                        { id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}
                     ]';

    echo $auto_nom_layout_obj->attach_toolbar_cell('run_auto_nom_process_toolbar', 'b');
    $run_auto_nom_process_toolbar = new AdihaToolbar();
    echo $run_auto_nom_process_toolbar->init_by_attach('run_auto_nom_process_toolbar', $namespace);
    echo $run_auto_nom_process_toolbar->load_toolbar($toolbar_json);
    echo $run_auto_nom_process_toolbar->attach_event('', 'onClick', 'run_button_click');

    $term_start = date('Y-m-d', strtotime("+1 days"));
    $term_end = date('Y-m-d', strtotime("+1 days"));

    echo $auto_nom_form_obj->set_input_value($namespace . '.' . $form_name, 'term_start', $term_start);
    echo $auto_nom_form_obj->set_input_value($namespace . '.' . $form_name, 'term_end', $term_end);

    echo $auto_nom_layout_obj->close_layout();
?>
</body>
    
<script>    
    $(function(){
        var has_right_run_auto_nom = Boolean('<?php echo $has_right_run_auto_nom; ?>');
        
        if (has_right_run_auto_nom == false)
            auto_nom.auto_nom_form.disableItem('btn_run');
        else 
            auto_nom.auto_nom_form.enableItem('btn_run');

        var function_id  = 10164200;
        var report_type = 2;
        var filter_obj = auto_nom.auto_nom_layout.cells('a').attachForm();
        var layout_cell_obj =auto_nom.auto_nom_layout.cells('b');
        
        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
    });

    function result_text(name, value) {
        var f = this.getForm();
        return value;
    }

    function run_button_click(args) {
        var term_start = auto_nom.auto_nom_form.getItemValue('term_start', true);
        var term_end = auto_nom.auto_nom_form.getItemValue('term_end', true);
        var destination_sub_book_id = auto_nom.auto_nom_form.getItemValue('destination_sub_book_id', true);

        if (term_start == '') {
            show_messagebox('Please enter Term Start');
            return;
        }

        if (term_end == '') {
            show_messagebox('Please enter Term End');
            return;
        }

        if (term_start > term_end) {
            show_messagebox('Term Start cannot be greater than Term End');
            return;
        }

        var param = 'call_from=run_auto_nom_process&batch_type=c';
        var title = 'Run Auto Nom Process';
        var exec_call = "EXEC spa_split_nom_volume " + 
                        "@flag='c', " + 
                        "@term_start=" + singleQuote(term_start) + ", " +
                        "@term_end=" + singleQuote(term_end) + ", " +
                        "@destination_sub_book_id=" + destination_sub_book_id; 
        
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