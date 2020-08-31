<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
</head>
<body>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $source_deal_header_id = (isset($_REQUEST["source_deal_header_id"]) && $_REQUEST["source_deal_header_id"] != '') ? get_sanitized_value($_REQUEST["source_deal_header_id"]) : 'NULL';
    $mode = (isset($_REQUEST["mode"]) && $_REQUEST["mode"] != '') ? get_sanitized_value($_REQUEST["mode"]) : 'NULL';
    $edit_enabled = (isset($_REQUEST["edit_enabled"]) && $_REQUEST["edit_enabled"] != '') ? get_sanitized_value($_REQUEST["edit_enabled"]) : 'NULL';
  $certificate_process_id = (isset($_REQUEST["certificate_process_id"]) && $_REQUEST["certificate_process_id"] != '') ? get_sanitized_value($_REQUEST["certificate_process_id"]) : 'NULL';
    $source_certificate_number = (isset($_REQUEST["source_certificate_number"]) && $_REQUEST["source_certificate_number"] != '') ? get_sanitized_value($_REQUEST["source_certificate_number"]) : 'NULL';
    $call_from = isset($_GET['call_from']) ? get_sanitized_value($_GET['call_from']) : '';
    $certificate_temp_id = (isset($_REQUEST["certificate_temp_id"]) && $_REQUEST["certificate_temp_id"] != '') ? get_sanitized_value($_REQUEST["certificate_temp_id"]) : 'NULL';
    if ($mode == 'i') {
        $xml_file =  "EXEC spa_gis_certificate_detail @flag='q', @source_deal_header_id=" . $source_deal_header_id;
        $return_value = readXMLURL($xml_file);
        $term_start = $return_value[0][0];
        $term_end = $return_value[0][1];
        $dt_certificate = $return_value[0][0];
        $source_deal_detail_id = $return_value[0][2];
        $leg = $return_value[0][3];
    } else {
        // $xml_file =  "EXEC spa_gis_certificate_detail @flag='a', @certificate_num=" . $source_certificate_number  . "
        $xml_file =  "EXEC spa_gis_certificate_detail @flag='a', @certificate_num=" . $source_certificate_number . ",@certificate_process_id='". $certificate_process_id."',@certificate_temp_id ='" . $certificate_temp_id . "'";
        $return_value = readXMLURL($xml_file);
        $certificate_num_from = $return_value[0][0];
        $certificate_num_to = $return_value[0][1];
        $dt_certificate = $return_value[0][2];
        $deal_volume = $return_value[0][3];
        $state_value_id = $return_value[0][4];
        $tier_type = $return_value[0][5];
        $contract_exp_date = $return_value[0][6];
        $term_start = $return_value[0][7];  
        $term_end = $return_value[0][8]; 
        $source_deal_header_id = $return_value[0][9]; 
        $source_deal_detail_id = $return_value[0][10];
        $leg = $return_value[0][11];
        $sequence_from = $return_value[0][12];
        $sequence_to = $return_value[0][13];
        $create_ts = $return_value[0][14];
        $update_ts = $return_value[0][15]; 
        $year = $return_value[0][17]; 
        $certification_entity =  $return_value[0][18]; 
        $entire_term_start = $return_value[0][19]; 
        $entire_term_end = $return_value[0][20]; 
    }
    
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Certificate Detail",
                            width:          500,
                            height:         500,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
                    
    $form_namespace = 'certificate_detail' ;            
    $certificate_detail_layout = new AdihaLayout();
    echo $certificate_detail_layout->init_layout('certificate_detail_layout', '', '1C', $layout_json, $form_namespace);
    
    $toolbar_json = '[
                        {id:"save", type: "button", img:"tick.gif", imgdis:"tick_dis.gif", text:"OK", title: "OK", enabled: ' . $edit_enabled . '}
                     ]';
                     
    //Attaching Toolbar
    $certificate_detail_toolbar = new AdihaToolbar();
    echo $certificate_detail_layout->attach_toolbar_cell('certificate_detail_toolbar', 'a');
    echo $certificate_detail_toolbar->init_by_attach('certificate_detail_toolbar', $form_namespace);
    echo $certificate_detail_toolbar->load_toolbar($toolbar_json);
    echo $certificate_detail_toolbar->attach_event('', 'onClick',  $form_namespace . '.certificate_detail_onclick');
    
    // Attaching Form
    $form_object = new AdihaForm();
    $form_name =  'form_certificate_detail'; 
    $sp_url_jurisdication = "EXEC spa_StaticDataValues 'h', 10002";
    echo "jurisdication_cmb = ".  $form_object->adiha_form_dropdown($sp_url_jurisdication, 0, 1, false, '', 2) . ";"."\n";
    $sp_url_tier = "EXEC spa_StaticDataValues 'h', 15000";
    echo "tier_cmb = ".  $form_object->adiha_form_dropdown($sp_url_tier, 0, 1, false, '', 2) . ";"."\n";
    $sp_url_year = "EXEC spa_StaticDataValues 'h', 10092";
    echo "year_cmb = ".  $form_object->adiha_form_dropdown($sp_url_year, 0, 1, true, '', 2) . ";"."\n";
    $sp_url_certification = "EXEC spa_StaticDataValues 'h', 10011";
    echo "certification_cmb = ".  $form_object->adiha_form_dropdown($sp_url_certification, 0, 1, false, '', 2) . ";"."\n";
    
    $form_json ='[
                   {
                      "type":"settings",
                      "position":"label-top"
                   },
                   {
                      type:"block",
                      blockOffset:10,
                      list:[                         
                         {
                            "type":"combo",
                            "name":"certification_entity",
                            "label":"Certification Entity",
                            "validate":"ValidInteger",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Certification Entity",
                            "required":"true",
                            "filtering":"true",
                            "filtering_mode":"between",
                            "options":certification_cmb,
                            "userdata":{"validation_message":"Required Field"}
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"combo",
                            "name":"state_value_id",
                            "label":"Jurisdiction",
                            "validate":"NotEmpty",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Jurisdiction",
                            "required":"true",
                            "filtering":"true",
                            "filtering_mode":"between",
                            "options":jurisdication_cmb,
              "userdata":{"validation_message":"Required Field"}
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"combo",
                            "name":"tier_type",
                            "label":"Tier",
                            "validate":"NotEmpty",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Tier",
                            "required":"true",
                            "filtering":"true",
                            "filtering_mode":"between",
                            "options":"",
              "userdata":{"validation_message":"Required Field"}
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"input",
                            "name":"gis_certificate_number_from",
                            "label":"Certificate From",
                            "validate":"",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Certificate To",
                            "required":"false"
                         },
                         {
                            "type":"newcolumn"
                            }
                      ]
                   },
                   {
                      type:"block",
                      blockOffset:10,
                      list:[
                      {
                            "type":"input",
                            "name":"gis_certificate_number_to",
                            "label":"Certificate To",
                            "validate":"",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Certificate To",
                            "required":"false"
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                           "type":"combo",
                            "name":"year",
                            "label":"Year",
                            "validate":"ValidInteger",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Year",
                            "required":"false",
                            "filtering":"true",
                            "filtering_mode":"between",
                            "options":year_cmb
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"calendar",
                            "name":"term_start",
                            "label":"Term Start",
                            "validate":"",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Term Start",
                            "required":"false",
                            "dateFormat": user_date_format,
                            "serverDateFormat":"%Y-%m-%d"
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"calendar",
                            "name":"term_end",
                            "label":"Term End",
                            "validate":"",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Term End",
                            "required":"false",
                            "dateFormat": user_date_format,
                            "serverDateFormat":"%Y-%m-%d"
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"newcolumn"
                            },
                      ]
                   },
                   {
                      type:"block",
                      blockOffset:10,
                      list:[
                        {
                            "type":"input",
                            "name":"leg",
                            "label":"Leg",
                            "validate":"",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Leg",
                            "required":"false"
                         },
                         {
                            "type":"newcolumn"
                         },
                          {
                            "type":"calendar",
                            "name":"gis_cert_date",
                            "label":"Certification Date",
                            "validate":"",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Certification Date",
                            "required":"false",
                            "dateFormat": user_date_format,
                            "serverDateFormat":"%Y-%m-%d"
                         },
                         {
                            "type":"newcolumn"
                         },
                          {
                            "type":"calendar",
                            "name":"contract_exp_date",
                            "label":"Expiration Date",
                            "validate":"",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Expiration Date",
                            "required":"false",
                            "dateFormat": user_date_format,
                            "serverDateFormat":"%Y-%m-%d" 
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"input",
                            "name":"certificate_number_from_int",
                            "label":"Sequence From",
                            "validate":"ValidInteger",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Sequence To",
                            "required":"false",
              "userdata":{"validation_message":"Invalid Number"}
                         },
                         {
                            "type":"newcolumn"
                         },
                         ]
                   },
                   {
                      type:"block",
                      blockOffset:10,
                      list:[
                         {
                            "type":"input",
                            "name":"certificate_number_to_int",
                            "label":"Sequence To",
                            "validate":"ValidInteger",
                            "hidden":"false",
                            "disabled":"false",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Sequence To",
                            "required":"false",
              "userdata":{"validation_message":"Invalid Number"}
                         },
                         {
                            "type":"newcolumn"
                         },
                          {
                            "type":"input",
                            "name":"source_deal_header_id",
                            "label":"Source Deal Header ID",
                            "validate":"ValidInteger",
                            "hidden":"false",
                            "disabled":"true",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Source Deal Header Id",
                            "required":"false"
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"input",
                            "name":"source_deal_detail_id",
                            "label":"Source Deal Detail ID",
                            "validate":"ValidInteger",
                            "hidden":"false",
                            "disabled":"true",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Source Deal Detail Id",
                            "required":"false"
                         },
                         {
                            "type":"newcolumn"
                         },
                         {
                            "type":"input",
                            "name":"create_ts",
                            "label":"Create TS",
                            "validate":"",
                            "hidden":"false",
                            "disabled":"true",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Sequence To",
                            "required":"false"
                         },
                         {
                            "type":"newcolumn"
                         },
                        ]
                   },
                   {
                      type:"block",
                      blockOffset:10,
                      list:[
                        {
                            "type":"input",
                            "name":"update_ts",
                            "label":"Update TS",
                            "hidden":"false",
                            "disabled":"true",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"auto",
                            "inputWidth":"150",
                            "tooltip":"Update Ts",
                            "required":"false"
                         },
                         {
                            "type":"newcolumn"
                         }
                      ]
                    },
                ]';
                
    echo $certificate_detail_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $form_namespace);
    echo $form_object->load_form($form_json);
    echo $form_object->attach_event('', 'onChange', $form_namespace . '.form_change');
    
    echo $certificate_detail_layout->close_layout();
?>  
</body>
<script type="text/javascript">
    var mode = '<?php echo $mode;?>';
    var source_deal_header_id = '<?php echo $source_deal_header_id;?>';
    var source_deal_detail_id = '<?php echo $source_deal_detail_id;?>';
    var leg = '<?php echo $leg;?>';
    var term_start = '<?php echo $term_start;?>';
    var term_end = '<?php echo $term_end;?>';
    var gis_cert_date = '<?php echo $dt_certificate;?>';
    var certificate_num_from = "<?php echo $certificate_num_from ?? '';?>";
    var certificate_num_to = "<?php echo $certificate_num_to ?? '';?>";
    var sequence_from ="<?php echo $sequence_from ?? '';?>";
    var sequence_to ="<?php echo $sequence_to ?? '';?>";
    var state_value_id = "<?php echo $state_value_id ?? '';?>";
    var tier_type = "<?php echo $tier_type ?? '';?>";
    var contract_exp_date = "<?php echo $contract_exp_date ?? '';?>";
    var year  = "<?php echo $year ?? '';?>";
    var certification_entity = "<?php echo $certification_entity ?? '';?>";
    var create_ts = "<?php echo $create_ts ?? '';?>";
    var update_ts  = "<?php echo $update_ts ?? '';?>";
    var client_date_format = '<?php echo $date_format; ?>'; 
    var deal_term_start;
    var deal_term_end; 
    var set_tier_value = false;
  var certificate_process_id = '<?php echo $certificate_process_id;?>';
  var certificate_temp_id = '<?php echo $certificate_temp_id;?>';
      
  
   if(certificate_process_id == 'undefined' || certificate_process_id == '') {
        certificate_process_id = null;
    }
  //process_id  = null;
  
    if (mode == 'i') {
      deal_term_start = term_start
      deal_term_end = term_end
    } else {
      deal_term_start = "<?php echo $entire_term_start ?? '';?>";
      deal_term_end = "<?php echo $entire_term_end ?? '';?>";
      set_tier_value = true;
    }

    $(function() {
        dhxWins = new dhtmlXWindows(); 
        // certificate_detail.form_certificate_detail.setCalendarDateFormat('term_start', client_date_format); 
        // certificate_detail.form_certificate_detail.setCalendarDateFormat('term_end', client_date_format); 
        // certificate_detail.form_certificate_detail.setCalendarDateFormat('gis_cert_date', client_date_format); 
        // certificate_detail.form_certificate_detail.setCalendarDateFormat('contract_exp_date', client_date_format); 

        //certificate_detail.form_certificate_detail.setItemValue('gis_cert_date',gis_cert_date);
        certificate_detail.form_certificate_detail.setItemValue('term_start',term_start);
        certificate_detail.form_certificate_detail.setItemValue('term_end',term_end);
        certificate_detail.form_certificate_detail.setItemValue('source_deal_header_id',source_deal_header_id);        
        certificate_detail.form_certificate_detail.setItemValue('leg',leg);
        
    
    if(source_deal_header_id == 'NULL') {
    certificate_detail.form_certificate_detail.disableItem('term_start');
    certificate_detail.form_certificate_detail.disableItem('term_end');
    certificate_detail.form_certificate_detail.disableItem('leg');
    }
        
        if(mode == 'u'){
            certificate_detail.form_certificate_detail.setItemValue('source_deal_detail_id',source_deal_detail_id);
            certificate_detail.form_certificate_detail.setItemValue('certificate_number_from_int',sequence_from);
            certificate_detail.form_certificate_detail.setItemValue('certificate_number_to_int',sequence_to);
            certificate_detail.form_certificate_detail.setItemValue('gis_cert_date',gis_cert_date);
            certificate_detail.form_certificate_detail.setItemValue('gis_certificate_number_from',certificate_num_from);
            certificate_detail.form_certificate_detail.setItemValue('gis_certificate_number_to',certificate_num_to);
            var juri_combo = certificate_detail.form_certificate_detail.getCombo('state_value_id');
            juri_combo.setComboValue(state_value_id);
            certificate_detail.form_certificate_detail.setItemValue('contract_exp_date',contract_exp_date);
            certificate_detail.form_certificate_detail.setItemValue('year',year);
            certificate_detail.form_certificate_detail.setItemValue('certification_entity',certification_entity);
      certificate_detail.form_certificate_detail.setItemValue('certificate_temp_id',certificate_temp_id);
            certificate_detail.form_certificate_detail.setItemValue('create_ts',create_ts);
            certificate_detail.form_certificate_detail.setItemValue('update_ts',update_ts);
        }
    });
    
   certificate_detail.form_change = function(name, value) {
      if (name == 'state_value_id') {
         var tier_type_combo = certificate_detail.form_certificate_detail.getCombo('tier_type');
         tier_type_combo.setComboValue('');
         tier_type_combo.setComboText('');
         tier_type_combo.enableFilteringMode('between');
         var cm_param = {
            "action": "spa_gis_certificate_detail",
            "flag": "t",
                "state_value_id":value,
                "has_blank_option": false
         };
         cm_param = $.param(cm_param);
         var url = js_dropdown_connector_url + '&' + cm_param;
         tier_type_combo.clearAll();
         tier_type_combo.load(url, function() {
            if (set_tier_value) {
               tier_type_combo.setComboValue(tier_type);
               set_tier_value = false;
            }
         });
      }
   }

    certificate_detail.certificate_detail_onclick = function() {
    if(!validate_form(certificate_detail.form_certificate_detail)) return;
        var flag = mode;
        var source_certificate_number = '<?php echo $source_certificate_number;?>';
    var certificate_temp_id = '<?php echo $certificate_temp_id;?>';
        var source_deal_header_id = certificate_detail.form_certificate_detail.getItemValue('source_deal_header_id') ? certificate_detail.form_certificate_detail.getItemValue('source_deal_header_id'):'NULL';
        var gis_certificate_number_from = certificate_detail.form_certificate_detail.getItemValue('gis_certificate_number_from') ? certificate_detail.form_certificate_detail.getItemValue('gis_certificate_number_from'):'NULL';
        var gis_certificate_number_to = certificate_detail.form_certificate_detail.getItemValue('gis_certificate_number_to') ? certificate_detail.form_certificate_detail.getItemValue('gis_certificate_number_to'):'NULL';
        var certificate_number_from_int = certificate_detail.form_certificate_detail.getItemValue('certificate_number_from_int') ? certificate_detail.form_certificate_detail.getItemValue('certificate_number_from_int'):'NULL';
        var certificate_number_to_int = certificate_detail.form_certificate_detail.getItemValue('certificate_number_to_int') ? certificate_detail.form_certificate_detail.getItemValue('certificate_number_to_int'):'NULL';
        var state_value_id = certificate_detail.form_certificate_detail.getItemValue('state_value_id') ?  certificate_detail.form_certificate_detail.getItemValue('state_value_id'):'NULL';
        var tier_type = certificate_detail.form_certificate_detail.getItemValue('tier_type') ? certificate_detail.form_certificate_detail.getItemValue('tier_type'):'NULL';
        var contract_exp_date = certificate_detail.form_certificate_detail.getItemValue('contract_exp_date' ,true)? certificate_detail.form_certificate_detail.getItemValue('contract_exp_date' ,true):'NULL';
        var year = certificate_detail.form_certificate_detail.getItemValue('year')? certificate_detail.form_certificate_detail.getItemValue('year'):'NULL';
        var certification_entity = certificate_detail.form_certificate_detail.getItemValue('certification_entity')? certificate_detail.form_certificate_detail.getItemValue('certification_entity'):'NULL';
        var gis_cert_date = certificate_detail.form_certificate_detail.getItemValue('gis_cert_date', true) || 'NULL';
        var leg = certificate_detail.form_certificate_detail.getItemValue('leg', true);
        var term_start = certificate_detail.form_certificate_detail.getItemValue('term_start', true);
        var term_end = certificate_detail.form_certificate_detail.getItemValue('term_end', true);
        var invalid_selection_status = false;
        
    if (source_deal_header_id != 'NULL') {
        if (!term_end || term_end > deal_term_end || !term_start || term_start < deal_term_start || term_start > term_end) {
          dhtmlx.message({
                    title:"Error",
                    type:"alert-error",
                    text: "Term Start and Term End should be between " + deal_term_start + " and " + deal_term_end
                });
                return true;
        }
        }
    
    if(state_value_id == 'NULL') {
       certificate_detail.form_certificate_detail.setValidateCss('state_value_id', true,'validate_error');
             certificate_detail.form_certificate_detail.setNote('state_value_id',{text:'Invalid Selection',width:200});
             invalid_selection_status = true;
        }
    
    if(tier_type == 'NULL') {
       certificate_detail.form_certificate_detail.setValidateCss('tier_type', true,'validate_error');
             certificate_detail.form_certificate_detail.setNote('tier_type',{text:'Invalid Selection',width:200});
             invalid_selection_status = true;
        }

         if(invalid_selection_status) {
                return false;
            }
    
    if (source_deal_header_id == 'NULL') {
      if (term_end == null) {
        term_end = 'NULL';
      }
      
      if (term_start == null) {
      term_start = 'NULL';
      }
      
      if (leg == null || leg == '') {
      leg = 'NULL';
      }
      
      if (certification_entity == null) {
        certification_entity = 'NULL';
      }
      
      if (source_deal_detail_id == null || source_deal_detail_id == '') {
        source_deal_detail_id = 'NULL';
      }
    }
        
        var spa_param = "EXEC spa_gis_certificate_detail"
                  + singleQuote(flag) + ','
                        + source_certificate_number + ',' 
                + source_deal_header_id + ','
                       + source_deal_detail_id + ','
                //        + singleQuote('NULL') + ','
                + singleQuote(gis_certificate_number_from) + ','
                + singleQuote(gis_certificate_number_to) + ','
                + singleQuote(gis_cert_date) + ','
                + state_value_id + ','
                        + tier_type + ','
                        + singleQuote(contract_exp_date) + ','
                + certificate_number_from_int + ','
                        + certificate_number_to_int + ','
                        + year + ','
                        + certification_entity + ','
                        + leg + ','
                        + singleQuote(term_start) + ','
                        + singleQuote(term_end) + ','
            + singleQuote(certificate_process_id)+ ','
            + singleQuote(certificate_temp_id);
           
        var post_data = {"sp_string": spa_param};
        adiha_post_data('return_array', post_data, '', '', 'save_callback', '');
    }
    
    function save_callback(result) {
      if (result[0][0] == 'Error') {
        dhtmlx.message({
                    title: "Error",
                    type: "alert",
                    text: result[0][4]
                });
        return;
        }
    process_id = result[0][5];
    parent.cert_process_id = process_id;
        // dhtmlx.message(result[0][4]);
        setTimeout(function(){parent.dhxWins.window('w11').close()},500);
    }
</script>