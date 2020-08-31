<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body class = "bfix2">
    <?php     
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $form_function_id = 10167100;
    $rights_forecast_price_run_optimizer = 10163601;
    $rights_forecast_price_save_schedule = 10163602;
    $rights_forecast_price_view_schedule = 10163400; //function id of view nomination schedule menu
    
    list (
        $has_right_forecast_price_run_optimizer,
        $has_right_forecast_price_save_schedule,
        $has_right_forecast_price_view_schedule
    ) = build_security_rights (
        $rights_forecast_price_run_optimizer, 
        $rights_forecast_price_save_schedule,
        $rights_forecast_price_view_schedule
    );
    
    $form_namespace = 'forecast_price';
    $json = "[
                {
                    id:         'a',
                    text:       'Apply Filter',
                    header:     true,
                    collapse:   false,
                    height:     100
                },
                {
                    id:         'b',
                    text:       'Run Criteria',
                    header:     true,
                    collapse:   false
                }

            ]";
          
    $forecast_price_obj = new AdihaLayout();
    echo $forecast_price_obj->init_layout('layout', '', '2E', $json, $form_namespace);
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_json = '[
                        { id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}
                     ]';
    echo $forecast_price_obj->attach_toolbar("forecast_price_toolbar");  
    echo $toolbar_obj->init_by_attach("forecast_price_toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.fx_toolbar_click');

    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$form_function_id', @template_name='forecast_price'";
    $return_value = readXMLURL2($xml_file);
    $form_json = $return_value[0]['form_json'];
    //$tab_id = $return_value[0]['tab_id'];
    echo $forecast_price_obj->attach_form('forecast_price_form', 'b');
    $forecast_price_form = new AdihaForm();
    echo $forecast_price_form->init_by_attach('forecast_price_form', $form_namespace);
    echo $forecast_price_form->load_form($form_json);
    echo $forecast_price_form->attach_event('', 'onChange', $form_namespace . '.forecast_price_form_onchange');
    
    echo $forecast_price_form->attach_event('', 'onButtonClick', $form_namespace . '.forecast_price_form_click');
        
    echo $forecast_price_obj->close_layout();
    ?>
</body>
    
<script>
    var DEBUG_PROCESS = true;
    var post_data = '';
    
    $(function(){
        //create js date obj and sotre next day date
        date_obj_tomorrow = new Date();
        date_obj_today = new Date();
        date_obj_tomorrow.setDate(date_obj_tomorrow.getDate() + 1);
        
        fx_initial_load();
        
    });
    //function to load initial values
    function fx_initial_load() {
        //attach_browse_event('forecast_price.forecast_price_form', 10167100, 'fx_browse_callback');
        attach_browse_event('forecast_price.forecast_price_form', 10167100, '');
        
        filter_obj = forecast_price.layout.cells('a').attachForm();
        var layout_cell_obj = forecast_price.layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '10167100', 2);
            
        forecast_price.forecast_price_form.setItemValue('as_of_date', date_obj_today);
        forecast_price.forecast_price_form.setItemValue('date_from', date_obj_tomorrow);
        forecast_price.forecast_price_form.setItemValue('date_to', date_obj_tomorrow);
        
        
    }
            
    forecast_price.fx_toolbar_click = function(name, value) {
        if(name == 'run' && validate_form(forecast_price.forecast_price_form)) {
            var xml_param = fx_get_form_data_xml();
            var param = 'call_from=forecast_price&gen_as_of_date=1&batch_type=c&as_of_date=' + forecast_price.forecast_price_form.getItemValue('as_of_date', true);
            var title = 'Run Forecast Load';
            var exec_call = "EXEC spa_run_forecast_price @flag='r', @xml_param='" + xml_param + "'"; 
            adiha_run_batch_process(exec_call, param, title); 
        
        
            /*
            post_data = { sp_string: sp_string };
            //console.log(sp_string);
            $.ajax({
                url: ajax_url,
                data: post_data,
            }).done(function(data) {
                
            }); 
            */
        }
    }
    fx_get_form_data_xml = function() {
        var form_obj = forecast_price.forecast_price_form;
        var xml_data = '<Root><PSRecordset' +  
            ' as_of_date="' + form_obj.getItemValue('as_of_date', true) +
            '" date_from="' + form_obj.getItemValue('date_from', true) + 
            '" date_to="' + form_obj.getItemValue('date_to', true) +
            '" price_curve="' + form_obj.getItemValue('price_curve') +
            '" approach="' + form_obj.getItemValue('approach') +
            '" retrain_model="' + (form_obj.isItemChecked('retrain_model') == true ? 1 : 0) +
        '"></PSRecordset></Root>';
        console.log(xml_data);
        return xml_data;
    }
    
    
/*=================== FILTER SAVE LOGIC ==================*/
    
    /**
     * [forecast_price_form_click form button event function for filter form]
     * @param  {[type]} name   [Name of the button]
     */
    forecast_price.forecast_price_form_click = function(name) {
    }
    forecast_price.forecast_price_form_onchange = function(name, value) {
        if(name == 'as_of_date') {
            var date_obj = new Date(value);
            date_obj.setDate(date_obj.getDate() + 1);
            forecast_price.forecast_price_form.setItemValue('date_from', date_obj);
            forecast_price.forecast_price_form.setItemValue('date_to', date_obj);
        }
    }
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
</script>