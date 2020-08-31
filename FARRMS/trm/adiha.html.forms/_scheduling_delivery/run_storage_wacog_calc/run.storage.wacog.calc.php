<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
     <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
    <?php   
   
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

    $rights_run_wacog_calc = 10162100;
    
    list (
       $has_right_run_wacog_calc
    ) = build_security_rights (
       $rights_run_wacog_calc
    );
    
    $namespace = 'wacog_calc';
    $form_name = 'wacog_calc_form';

    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filters",
                    header:         true,
                    collapse:       true,
                    height:         90
                },
                {
                    id:             "b",
                    text:           "Filters",
                    header:         true,
                    collapse:       false
                }
            ]';

    $wacog_calc_layout_obj = new AdihaLayout();
    echo $wacog_calc_layout_obj->init_layout('wacog_calc_layout', '', '2E', $json, $namespace);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10162100', @template_name='wacog_calc', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    echo $wacog_calc_layout_obj->attach_form($form_name, 'b');
    $wacog_calc_form_obj = new AdihaForm();
    echo $wacog_calc_form_obj->init_by_attach($form_name, $namespace);
    echo $wacog_calc_form_obj->load_form($form_json);

    $toolbar_obj = new AdihaToolbar();
    $toolbar_json = '[
                        { id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}
                     ]';
    echo $wacog_calc_layout_obj->attach_toolbar("inventory_calc_toolbar");  
    echo $toolbar_obj->init_by_attach("inventory_calc_toolbar", $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'run_button_click');
    
    $as_of_date = date('Y-m-d');

    echo $wacog_calc_form_obj->set_input_value($namespace . '.' . $form_name, 'as_of_date', $as_of_date);
    echo $wacog_calc_layout_obj->close_layout();
?>
</body>
    
<script>    
    $(function(){
        attach_browse_event('wacog_calc.wacog_calc_form',10162100, 'browse_callback');
        var has_right_run_wacog_calc = Boolean('<?php echo $has_right_run_wacog_calc; ?>');

        if (has_right_run_wacog_calc == false){
            wacog_calc.wacog_calc_form.disableItem('btn_run');
        } else {
            wacog_calc.wacog_calc_form.enableItem('btn_run');
        }

        wacog_calc.wacog_calc_form.attachEvent("onButtonClick", function(name){
            if (name == 'clear_assets_name') {
                wacog_calc.wacog_calc_form.setItemValue('location_id', '');
                wacog_calc.wacog_calc_form.setItemValue('label_location_id', '');
                wacog_calc.wacog_calc_form.setItemValue('contract', '');
                wacog_calc.wacog_calc_form.setItemValue('label_contract', '');
            }
        });

        var as_of_date = wacog_calc.wacog_calc_form.getItemValue('as_of_date', true);
        changeDate(as_of_date);

        wacog_calc.wacog_calc_form.attachEvent("onChange", function(name,value,is_checked) {
            if (name == 'as_of_date') {
                 var as_of_date = wacog_calc.wacog_calc_form.getItemValue(name, true);
                 changeDate(as_of_date);
            } 
        });
        
        var function_id  = 10162100;
        var report_type = 2;
        var filter_obj = wacog_calc.wacog_calc_layout.cells('a').attachForm();
        var layout_cell_obj =wacog_calc.wacog_calc_layout.cells('b');

        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
    });

    function changeDate(as_of_date) {
        var split = as_of_date.split('-');
        var year =  +split[0];
        var month = +split[1];
        var day = +split[2];

        var date = new Date(year, month-1, day);
        var FirstDay = new Date(date.getFullYear(), date.getMonth(), 1);
        var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
        date_end = formatDate(lastDay);

        wacog_calc.wacog_calc_form.setItemValue('term_start', FirstDay);
        wacog_calc.wacog_calc_form.setItemValue('term_end', date_end);

    }

    //function to formatDate
    function formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;

        return [year, month, day].join('-');
    }

    function browse_callback() {
        var asset_id = wacog_calc.wacog_calc_form.getItemValue('assets_name');
        var sp_string = "EXEC spa_storage_assets @flag = 'p', @asset_ids = '" + asset_id + "'";           
        var data_for_post =  {"sp_string": sp_string};
        adiha_post_data('return_array', data_for_post, '', '', 'location_callback');
    }

    function location_callback(result) {
        wacog_calc.wacog_calc_form.setItemValue('location_id', result[0][0]);
        wacog_calc.wacog_calc_form.setItemValue('label_location_id', result[0][1]);
        
        var asset_id = wacog_calc.wacog_calc_form.getItemValue('assets_name');
        var sp_string = "EXEC spa_storage_assets @flag = 'y', @asset_ids = '" + asset_id + "'";           
        var data_for_post =  {"sp_string": sp_string};
        adiha_post_data('return_array', data_for_post, '', '', 'contract_callback');
    }
    function contract_callback(result) {
        wacog_calc.wacog_calc_form.setItemValue('contract', result[0][0]);
        wacog_calc.wacog_calc_form.setItemValue('label_contract', result[0][1]);
    }

    function run_button_click(args) {
        var status = validate_form(wacog_calc.wacog_calc_form);
        
        if (status) {
            var as_of_date = wacog_calc.wacog_calc_form.getItemValue('as_of_date', true);
            var assets_name = wacog_calc.wacog_calc_form.getItemValue('assets_name');
            var contract = wacog_calc.wacog_calc_form.getItemValue('contract');
            var forward_settlement = wacog_calc.wacog_calc_form.getItemValue('forward_settlement');
            var location_id = wacog_calc.wacog_calc_form.getItemValue('location_id');
            var term_start = wacog_calc.wacog_calc_form.getItemValue('term_start', true);
            var term_end = wacog_calc.wacog_calc_form.getItemValue('term_end', true);
            var status = validate_form(wacog_calc.wacog_calc_form);
            if (status == 0) { return; }
            
            if (location_id == '') {
                show_messagebox('Please select <b>Location</b>');
                return;
            } else {
                wacog_calc.wacog_calc_form.setNote('label_location_id',{text:""});
            }
            
            if (term_start > term_end) {
                show_messagebox('<b>Term Start</b> cannot be greater than <b>Term End</b>');
                return;
            }
    
            var param = 'call_from=run_wacog_calc_process&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
            var title = 'Run Storage WACOG Calc';
            var exec_call = "EXEC spa_calc_storage_wacog " + 
                        // "@flag='" + forward_settlement + "', " + 
                        "@as_of_date=" + singleQuote(as_of_date) + ", " +
                        "@storage_assets_id=" + singleQuote(assets_name) + ", " +
                        "@contract=NULL, " + 
                        "@location_id=NULL, " +
                        "@term_start=" + singleQuote(term_start) + ", " +
                        "@term_end=" + singleQuote(term_end)
                        // "@book_entity_id=" + singleQuote(book_entity_id);        
            adiha_run_batch_process(exec_call, param, title);
        }
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