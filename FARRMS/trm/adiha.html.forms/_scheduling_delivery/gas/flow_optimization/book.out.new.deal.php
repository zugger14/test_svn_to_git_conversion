<?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_book_out_new_deal';
    $name_space = 'ns_book_out_new_deal';
    
    $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
    $location_id = get_sanitized_value($_GET['location_id'] ?? '');
    $commodity = get_sanitized_value($_GET['commodity'] ?? '');
    $term_start = get_sanitized_value($_GET['term_start'] ?? '');
    $term_end = get_sanitized_value($_GET['term_end'] ?? '');
    $volume = get_sanitized_value($_GET['volume'] ?? '');
    $del_volume = get_sanitized_value($_GET['del_volume'] ?? '');
    $buy_deal_id = get_sanitized_value($_GET['buy_deal_id'] ?? '');
    $sell_deal_id = get_sanitized_value($_GET['sell_deal_id'] ?? '');
    $process_id = get_sanitized_value($_GET['process_id'] ?? 'NULL');

    $sp_bookout_info = "EXEC spa_book_out @flag='i', @buy_deal_id='$buy_deal_id', @sell_deal_id='$sell_deal_id', @process_id='$process_id'";
    $result_bookout_info = readXMLURL2($sp_bookout_info);
    //print '<pre>';print_r($result_bookout_info);print '</pre>';die();
    $json_bookout_info = json_encode($result_bookout_info);   


    $xml_file = "EXEC spa_delivery_path @flag='s', @from_location=$location_id, @to_location=$location_id";
    $return_value = readXMLURL2($xml_file);
    $path_id = $return_value[0]['path_id'];
    //print '<pre>';print_r($path_id);print '</pre>';die();

    
    $loss_factor_sql = "EXEC spa_delivery_path @flag='z', @path_id=$path_id";
    $loss_factor_return = readXMLURL2($loss_factor_sql);
    $loss = $loss_factor_return[0]['loss'];
    //print '<pre>';print_r($loss);print '</pre>';die();


    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Calculate Margin Analysis",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            hieght:         100
                        }
                    ]';
    
    
    $ns_book_out_new_deal_layout = new AdihaLayout();
    echo $ns_book_out_new_deal_layout->init_layout('ns_book_out_new_deal_layout', '', '1C', $layout_json, $name_space);
    
    $toolbar_book_out_new_deals = 'book_out_new_deal_toolbar';
    $toolbar_json = '[{id:"ok", img:"tick.gif", imgdis:"tick_dis.gif", text:"Ok", title:"Ok"}]';
    
    $toolbar_ns_book_out_new_deal = new AdihaMenu();
    echo $ns_book_out_new_deal_layout->attach_menu_cell($toolbar_book_out_new_deals, "a"); 
    echo $toolbar_ns_book_out_new_deal->init_by_attach($toolbar_book_out_new_deals, $name_space);
    echo $toolbar_ns_book_out_new_deal->load_menu($toolbar_json);
    echo $toolbar_ns_book_out_new_deal->attach_event('', 'onClick', 'fx_toolbar_click');
    
    $form_object = new AdihaForm();

    $sp_url_cpty = "EXEC spa_source_counterparty_maintain @flag = 'y', @type_of_entity=301994";
    echo "cpty_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_cpty, 0, 1, false, $counterparty_id) . ";"."\n";

    $sp_url_contract = "EXEC spa_source_contract_detail 's'";
    echo "contract_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_contract, 0, 1, false) . ";"."\n";
    
    $general_form_structure = '[
        {type: "settings", labelWidth: 200, inputWidth: 200, inputHeight: 25, offsetLeft:10, offsetTop:10, position: "label-top"},
        
        {type: "combo", name: "cmb_counterparty", label: "Pipeline", filtering: 1, required: "true", validate: "NotEmpty", userdata:{validation_message:"Required Field"}, options: cpty_dropdown},
        {type: "combo", name: "cmb_contract", label: "Contract", required: 1, filtering: 1, options: contract_dropdown},
        {type:"newcolumn"},
        {type: "calendar", name: "dt_term_start", value:"' . $result_bookout_info[0]['term_start'] . '", dateFormat: "' . $date_format . '",serverDateFormat: "%Y-%m-%d", label: "Term Start", required: "true", validate: "NotEmpty", userdata:{validation_message:"Required Field"}},
        {type: "input", name: "txt_recived_vol",  label: "Receive Volume", required: "true", validate: "NotEmpty", userdata:{validation_message:"Required Field"}},
        {type:"newcolumn"},
        
        {type: "calendar", name: "dt_term_end", value:"' . $result_bookout_info[0]['term_end'] . '", dateFormat: "' . $date_format . '",serverDateFormat: "%Y-%m-%d", label: "Term End", required: "true", validate: "NotEmpty", userdata:{validation_message:"Required Field"}},
        {type: "input", name: "txt_delivery_vol",  label: "Delivery Volume", required: "true", validate: "NotEmpty", userdata:{validation_message:"Required Field"}}
       
    ]';    
    
    echo $ns_book_out_new_deal_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($general_form_structure);
    
    echo $ns_book_out_new_deal_layout->close_layout();  
    
     
        
?>
<script type="text/javascript">
    var post_data = '';
    var form_obj = ns_book_out_new_deal.form_book_out_new_deal;
    var location_id_gbl = '<?php echo $location_id; ?>';
    var term_start_gbl = '<?php echo $term_start; ?>';
    var term_end_gbl = '<?php echo $term_end; ?>';
    var commodity_gbl = '<?php echo $commodity; ?>';
    var buy_deal_detail_id_gbl = '<?php echo $buy_deal_detail_id; ?>';
    var sell_deal_detail_id_gbl = '<?php echo $sell_deal_detail_id; ?>';
    var process_id_gbl = '<?php echo $process_id; ?>';

    var loss = '<?php echo $loss; ?>';
    var rec_volume = '<?php echo $volume; ?>';
    var del_volume = '<?php echo $del_volume; ?>';
    
    $(function() {
        //dependent combo for counterparty->contract start
        dhxCombo_pipeline = ns_book_out_new_deal.form_book_out_new_deal.getCombo("cmb_counterparty");
        dhxCombo_contract = ns_book_out_new_deal.form_book_out_new_deal.getCombo("cmb_contract");
        dhxCombo_pipeline.attachEvent("onClose", function() {
            fx_cpty_onclose();
        });
        fx_cpty_onclose();
        //dependent combo for counterparty->contract end    
       
        if (rec_volume > del_volume) {
            del_volume = Math.round(rec_volume * (1 - loss))
        } else {
            rec_volume = Math.round(del_volume / (1 - loss))
        }    
        
        ns_book_out_new_deal.form_book_out_new_deal.setItemValue('txt_recived_vol', rec_volume);
        ns_book_out_new_deal.form_book_out_new_deal.setItemValue('txt_delivery_vol', del_volume);

    });
    
    function fx_cpty_onclose() {
        var pipeline = dhxCombo_pipeline.getSelectedValue();
        var cm_param = {
            "action": 'spa_contract_group',
            "call_from": "form",
            "has_blank_option": "false",
            "flag":'r',
            "pipeline":pipeline
        };
                                    
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        dhxCombo_contract.clearAll();
        dhxCombo_contract.load(url, function(e) {
            
        });
    }
    
    
    fx_toolbar_click = function(name) {
        switch(name) {
            case "ok":
                if(validate_form(ns_book_out_new_deal.form_book_out_new_deal)) {
                    fx_ok_click();
                }
                
                break;
            default :
                alert('undefined toolbar id');
        }
    };
    fx_ok_click = function() {

        ns_book_out_new_deal.ns_book_out_new_deal_layout.cells('a').progressOn();
        
        var counterparty_id = ns_book_out_new_deal.form_book_out_new_deal.getItemValue('cmb_counterparty');
        var contract = ns_book_out_new_deal.form_book_out_new_deal.getItemValue('cmb_contract');
        var rec_vol = ns_book_out_new_deal.form_book_out_new_deal.getItemValue('txt_recived_vol');
        var del_vol = ns_book_out_new_deal.form_book_out_new_deal.getItemValue('txt_delivery_vol');
        var term_start = ns_book_out_new_deal.form_book_out_new_deal.getItemValue('dt_term_start', true);
        var term_end = ns_book_out_new_deal.form_book_out_new_deal.getItemValue('dt_term_end', true);
        
        var sp_string = "EXEC spa_flow_optimization @flag='c'" + 
            ",@flow_date_from='" + term_start + "'" +
            ",@flow_date_to='" + term_end + "'" +
            ",@from_location='" + location_id_gbl + "'" +
            ",@to_location='" + location_id_gbl + "'" +
            ",@process_id='" + process_id_gbl + "'" + 
            ""; 
        post_data = { sp_string: sp_string };
        //console.log(sp_string);return;
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if(json_data.box_id == '1') {
                var sp_string = "EXEC spa_book_out @flag='o'" + 
                    ", @process_id='" + process_id_gbl + "'" +  
                    ", @rec_vol=" + rec_vol + 
                    ", @del_vol=" + del_vol + 
                    ", @contract='" + contract + "'" +
                    ", @counterparty_id=" + counterparty_id + 
                    ", @location_id='" + location_id_gbl + "'" +
                    ", @term_start_date='" + term_start + "'" +
                    ", @term_end_date='" + term_end + "'" +
                    ""; 
                post_data = { sp_string: sp_string };
                //console.log(sp_string);return;
                
                $.ajax({
                    url: js_form_process_url,
                    data: post_data,
                }).done(function(data) {
                    var json_data = data['json'][0];
                    
                    if(json_data.errorcode == 'Success') {
                        var sp_string = "EXEC spa_schedule_deal_flow_optimization @flag='i'" + 
                            ", @contract_process_id='" + process_id_gbl + "'" +  
                            ", @box_ids=1" + 
                            ", @counterparty_id=" + counterparty_id + 
                            ", @flow_date_from='" + term_start + "'" +
                            ", @flow_date_to='" + term_end + "'" +
                            ", @sub_book=null" +
                            ""; 
                        post_data = { sp_string: sp_string };
                        //console.log(sp_string);return;
                        
                        $.ajax({
                            url: js_form_process_url,
                            data: post_data,
                        }).done(function(data) {
                            var json_data = data['json'][0];
                            
                            if(json_data.errorcode == 'Success') {
                                parent.success_call(json_data.message);
                                //parent.fx_refresh_grid_childs();
                                parent.refresh();
                                parent.win_book_out_new_deal.close();
                            } else {
                                dhtmlx.message({
                                    title: "Error",
                                    type: "alert-error",
                                    text: json_data.message
                                });
                            }
                        });
                    } else {
                        dhtmlx.message({
                            title: "Error",
                            type: "alert-error",
                            text: json_data.message
                        });
                    }
                 });
            } else {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: json_data.message
                });
            }
        });
    };
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
</script>