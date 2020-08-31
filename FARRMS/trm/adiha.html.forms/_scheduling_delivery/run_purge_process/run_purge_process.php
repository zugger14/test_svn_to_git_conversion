<!DOCTYPE html>
<html> 
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
        
    <body class = "bfix">
    <?php 
    include_once('../../../adiha.php.scripts/components/include.file.v3.php'); 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $rights_purge_process = 10166000;
   
    list (
        $has_rights_purge_process
    ) = build_security_rights(
        $rights_purge_process
    );

    
    $json = '[
                {
                    id:             "a",
                    text:           "Run Purge Process",
                    header:         false,
                    collapse:       false,
                    height:         160
                }
            ]';
    
    $namespace = 'purge_process';
    $form_name = 'purge_process_form';
    
    $purge_process_layout_obj = new AdihaLayout();
    echo $purge_process_layout_obj->init_layout('purge_process_layout', '', '1C', $json, $namespace);
 
    $form_json = '[{"type":"settings","position":"label-top"},
                    {type: "block", blockOffset:'.$ui_settings['block_offset'].', 
                    list: [{"type":"calendar","name":"date_from","label":"Date From","validate":"NotEmpty","hidden":"false","disabled":"false","value":"","position":"label-top","offsetLeft":'.$ui_settings['offset_left'].',"labelWidth":"auto","inputWidth":'.$ui_settings['field_size'].',"tooltip":"date_from","required":"true","dateFormat":"%j\/%n\/%Y","serverDateFormat":"%Y-%m-%d","calendarPosition":"bottom","userdata":{"validation_message":"Please select Date From"}}
                            ,{"type":"newcolumn"},
                            {"type":"calendar","name":"date_to","label":"Date To","validate":"NotEmpty","hidden":"false","disabled":"false","value":"","position":"label-top","offsetLeft":'.$ui_settings['offset_left'].',"labelWidth":"auto","inputWidth":'.$ui_settings['field_size'].',"tooltip":"date_to","required":"true","dateFormat":"%j\/%n\/%Y","serverDateFormat":"%Y-%m-%d","calendarPosition":"bottom","userdata":{"validation_message":"Please select Date To"}}
                            ,{"type":"newcolumn"},
                            {"type":"combo","name":"purge_type","label":"Purge Type","userdata":{"validation_message":"Please select Purge Type"},"validate":"NotEmpty","hidden":"false","disabled":"false","value":"","position":"label-top","offsetLeft":'.$ui_settings['offset_left'].',"labelWidth":"auto","inputWidth":'.$ui_settings['field_size'].',"tooltip":"purge_type","required":"true","filtering":"true","options":[{"value":"a","text":"Autonom"}, {"value":"b","text":"Both"}, {"value":"o","text":"Optimizer"}]}
                            ]}]';
    echo $purge_process_layout_obj->attach_form($form_name, 'a');
    $purge_process_form = new AdihaForm();
    echo $purge_process_form->init_by_attach($form_name, $namespace);
    echo $purge_process_form->load_form($form_json);
    
    //Attaching Toolbar for Contract Settlement Grid
    $toolbar_json = '[
                        { id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}
                     ]';

    echo $purge_process_layout_obj->attach_toolbar_cell('purge_process_toolbar', 'a');
    //echo $purge_processlayout_obj->attach_menu_layout_cell('purge_processtoolbar', 'b', $toolbar_json, 'purge_processtoolbar_onclick');
    $purge_process_toolbar = new AdihaToolbar();
    echo $purge_process_toolbar->init_by_attach('purge_process_toolbar', $namespace);
    echo $purge_process_toolbar->load_toolbar($toolbar_json);
    echo $purge_process_toolbar->attach_event('', 'onClick', 'purge_process_toolbar_onclick');
    
    $date_from = date('Y-m-d', strtotime("+1 days"));
    $date_to = date('Y-m-d', strtotime("+1 days"));

    echo $purge_process_form->set_input_value($namespace . '.' . $form_name, 'date_from', $date_from);
    echo $purge_process_form->set_input_value($namespace . '.' . $form_name, 'date_to', $date_to);

    echo $purge_process_layout_obj->close_layout();
    ?> 
    </body>
    
    <style type="text/css">
       html, body {
           width: 100%;
           height: 100%;
           margin: 0px;
           overflow: hidden;
       }
    </style>
    
    <script type="text/javascript"> 
     
        function purge_process_toolbar_onclick(name) {
            var report_name = 'Run Purge Process';
            
            var date_from = purge_process.purge_process_form.getItemValue('date_from', true);
            var date_to = purge_process.purge_process_form.getItemValue('date_to', true);
            var purge_type = purge_process.purge_process_form.getItemValue('purge_type');
            var form_obj = purge_process.purge_process_layout.cells("a").getAttachedObject();
            var validate_return = validate_form(form_obj);
          
            if (validate_return === false) {
                return;
            }
                       
            if (date_from > date_to) {
                show_messagebox('Date From cannot be greater than Date To.');
                return;
            }
            
            var param = 'call_from=run_purge_process&batch_type=c&as_of_date=' + date_from;
            var title = 'Run Purge Process';
            
            var exec_call = "EXEC spa_run_purge_process " + singleQuote(date_from)
                            + ', ' + singleQuote(date_to)
                            + ', ' + singleQuote(purge_type);
                            
            adiha_run_batch_process(exec_call, param, report_name);
        } 

    </script> 
</html>