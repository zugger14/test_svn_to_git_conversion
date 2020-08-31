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

    $rights_copy_auto_nom = 10166300;
    
    list (
       $has_right_copy_auto_nom
    ) = build_security_rights (
       $rights_copy_auto_nom
    );
    
    $namespace = 'copy_auto_nom';
    $form_name = 'copy_auto_nom_form';

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
    echo $auto_nom_layout_obj->init_layout('copy_auto_nom_layout', '', '2E', $json, $namespace);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10166300', @template_name='CopyNomination', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];

    echo $auto_nom_layout_obj->attach_form($form_name, 'b');
    $auto_nom_form_obj = new AdihaForm();
    echo $auto_nom_form_obj->init_by_attach($form_name, $namespace);
    echo $auto_nom_form_obj->load_form($form_json);
    
    $toolbar_json = '[
                        { id: "run", type: "button", img: "copy.gif", text: "Copy", title: "Copy"}
                     ]';

    echo $auto_nom_layout_obj->attach_toolbar_cell('copy_auto_nom_optimizer_toolbar', 'b');
    $run_auto_nom_process_toolbar = new AdihaToolbar();
    echo $run_auto_nom_process_toolbar->init_by_attach('copy_auto_nom_optimizer_toolbar', $namespace);
    echo $run_auto_nom_process_toolbar->load_toolbar($toolbar_json);
    echo $run_auto_nom_process_toolbar->attach_event('', 'onClick', 'run_button_click');
    
    $today_date = date('Y-m-d');
    $tomorrow_date = date('Y-m-d', strtotime("+1 days"));

    echo $auto_nom_form_obj->set_input_value($namespace . '.' . $form_name, 'source_date', $today_date);
    echo $auto_nom_form_obj->set_input_value($namespace . '.' . $form_name, 'from_date', $tomorrow_date);
    echo $auto_nom_form_obj->set_input_value($namespace . '.' . $form_name, 'to_date', $tomorrow_date);

    echo $auto_nom_layout_obj->close_layout();
?>
</body>
    
<script>    
    $(function(){
        var has_right_copy_auto_nom = Boolean('<?php echo $has_right_copy_auto_nom; ?>');
        
        if (has_right_copy_auto_nom == false)
            copy_auto_nom.copy_auto_nom_form.disableItem('btn_run');
        else 
            copy_auto_nom.copy_auto_nom_form.enableItem('btn_run');

        var function_id  = 10166300;
        var report_type = 2;
        var filter_obj = copy_auto_nom.copy_auto_nom_layout.cells('a').attachForm();
        var layout_cell_obj = copy_auto_nom.copy_auto_nom_layout.cells('b');
        
        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
    });

    function result_text(name, value) {
        var f = this.getForm();
        return value;
    }

    function run_button_click(args) {
        var source_date = copy_auto_nom.copy_auto_nom_form.getItemValue('source_date', true);
        var from_date = copy_auto_nom.copy_auto_nom_form.getItemValue('from_date', true);
        var to_date = copy_auto_nom.copy_auto_nom_form.getItemValue('to_date', true);
        
        if (source_date == '') {
            show_messagebox('Please enter Source Date');
            return;
        }

        if (from_date == '') {
            show_messagebox('Please enter From Date');
            return;
        }
        
        if (to_date == '') {
            show_messagebox('Please enter To Date');
            return;
        }

        if (source_date > from_date) {
            show_messagebox('Source Date cannot be greater than From Date');
            return;
        }
        
        if (from_date > to_date) {
            show_messagebox('From Date cannot be greater than To Date');
            return;
        }
        
        var msg = "Do you want to purge deals for the selected term?";
        confirm_messagebox(msg, copy_callback);
    }
    
    function copy_callback() {
        var as_of_date = current_date();
        
        var source_date = copy_auto_nom.copy_auto_nom_form.getItemValue('source_date', true);
        var from_date = copy_auto_nom.copy_auto_nom_form.getItemValue('from_date', true);
        var to_date = copy_auto_nom.copy_auto_nom_form.getItemValue('to_date', true);
        
        var param = 'call_from=copy_nominations&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
        var title = 'Copy Nominations';
        var exec_call = "EXEC spa_copy_optimizer_deals " + 
                        "@flow_date=" + singleQuote(source_date) + ", " +
                        "@flow_date_from=" + singleQuote(from_date) + ", " +
                        "@flow_date_to=" + singleQuote(to_date);
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