<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <?php require('../../../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
</head>
<body>
<?php 
    $layout_obj = new AdihaLayout();
	$namespace = 'ns_process_treatment';
    $rights_process_treatment = 10234610;
    $rights_document = 10102900;
    $source_deal_header_id = get_sanitized_value($_POST["source_deal_header_id"] ?? 'NULL');
    $pnl_value = get_sanitized_value($_POST["pnl_value"] ?? '');
    $pnl_date = get_sanitized_value($_POST["pnl_date"] ?? '');
    $mode = get_sanitized_value($_POST["mode"] ?? 'i');
    
    $fas_deal_type_id = get_sanitized_value($_POST["fas_deal_type_id"] ?? '');
    $exl_treatment = ($fas_deal_type_id == 401) ? 4086 : "NULL";
    list (
        $has_rights_process_treatment,
        $has_document_rights
    ) = build_security_rights(
        $rights_process_treatment,
        $rights_document
    );
    
    $layout_json = '[{id: "a", header:false}]';
    $layout_name = 'layout_process_treatment';
    echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $namespace);
	    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_json = '[{id:"save", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Save", title: "Save", enabled:"' . $has_rights_process_treatment . '"}]';
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.tab_toolbar_click');
    
    $sql = "EXEC spa_first_day_gain_loss_decision @flag='a', @source_deal_header_id=" . $source_deal_header_id;
    $return_value = readXMLURL($sql);
    
	if (count($return_value) > 0) {
	    $first_day_gain_loss_decision_id = $return_value[0][0];
		$treatment_value_id = $return_value[0][3];
		$fdgl = $return_value[0][4];
		$rel_id = $return_value[0][5];
	}
    
    $treatment_type = "EXEC spa_StaticDataValues @flag = 'h', @type_id=4085, @license_not_to_static_value_id=" . $exl_treatment;
    
    $form_obj = new AdihaForm();
    $treatment_type_dropdown = $form_obj->adiha_form_dropdown($treatment_type, 0, 1, false, '', 2);
    $form_json = '[{"type": "settings", position: "label-top","offsetTop":"5", inputWidth:200, labelWidth:200},
                    {"type": "block", blockOffset: 20, width:"auto", list: [
                        {"type":"input","name":"source_deal_header_id","label":"Deal ID", required:false,"value":"' . $source_deal_header_id . '","hidden":"false","disabled":"true","offsetLeft":"10"},
                        {"type":"newcolumn"},
                        {"type":"input","name":"deal_id","label":"Reference ID","hidden":"false","disabled":"true","value":"' . $rel_id . '","offsetLeft":"10"},
                        {"type":"newcolumn"},
                        {"type":"input","name":"pnl","label":"PNL","hidden":"false","disabled":"true","value":"' . $pnl_value . '","offsetLeft":"10"}
                    ]
                    },
                    {"type": "block", blockOffset: 20, width:"auto", list: [
                        {"type": "calendar", "validate":"NotEmptywithSpace","value":"' . $pnl_date . '", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "pnl_date", "label": "PNL Date","offsetLeft":"10"},
                        {"type":"newcolumn"},
                        {"type":"combo","name":"treatment_type","label":"Treatment","tooltip":"Fuel Loss Group","validate":"ValidInteger","hidden":"false","disabled":"false","value":"' . $treatment_value_id . '","offsetLeft":"10","labelWidth":200,"inputWidth":200,"filtering":"true","options":' . $treatment_type_dropdown . '},
                        {"type":"newcolumn"},
                        {"type":"input","name":"fdgl","label":"FDGL","validate":"ValidNumeric","hidden":"false","disabled":"false","value":"' . $fdgl . '","userdata":{"validation_message":"Invalid Number."},"offsetLeft":"10"}
                        ]
                    }
                  ]';
                  
    $form_name = 'form_process_treatment';
    echo $layout_obj->attach_form($form_name, 'a');    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    
    
    echo $layout_obj->close_layout();
?>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
</body>
<script type="text/javascript">
    var has_document_rights = '<?php echo (int)$has_document_rights;?>';
    var deal_id = '<?php echo $source_deal_header_id; ?>';
    var category_id = 33; //33 sdv for Deal
    var is_win;
    var flag = '<?php echo $mode; ?>';
    
    $(function(){
        add_manage_document_button(deal_id, ns_process_treatment.toolbar, has_document_rights);
    })

    ns_process_treatment.tab_toolbar_click = function(id) {
        switch(id) {
            case 'save':
                ns_process_treatment.save_process();
                break;
            case 'documents':
                ns_process_treatment.open_document();
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    ns_process_treatment.save_process = function() {
        var form_obj = ns_process_treatment.form_process_treatment;
        var status = validate_form(form_obj);
        var first_day_gain_loss_decision_id = '<? echo $first_day_gain_loss_decision_id; ?>';
        
        if (status) {
            var pnl_date = form_obj.getItemValue('pnl_date', true);
            var fdgl = form_obj.getItemValue('fdgl');
            var treatment_type = form_obj.getItemValue('treatment_type');
        } else {
            return;
        }
        
        var data = {
                        "action": "spa_first_day_gain_loss_decision",
                        "flag": flag,
                        "source_deal_header_id": deal_id,
                        "treatment_value_id": treatment_type,
                        "deal_date": pnl_date,
                        "FDGL": fdgl,
                        "first_day_gain_loss_decision_id": first_day_gain_loss_decision_id
                    };
        
        adiha_post_data('array', data, '', '', 'post_process_treatment', '');
    }
    
    function post_process_treatment(result) {
        if (result[0].errorcode == 'Success') {
            document.getElementById("success_status").value = 'Success';
            var win_obj = window.parent.new_win.window("w1");
            win_obj.close();
        } else {
            dhtmlx.alert({
                   title: 'Error',
                   type: "alert-error",
                   text: result[0].message
                });
        }
    }
    
    ns_process_treatment.open_document = function() {
        var object_id = deal_id;
        param = '../../../../_setup/manage_documents/manage.documents.php?notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true';
            
        var dhxWins = new dhtmlXWindows();
        var is_win = dhxWins.isWindow('w11');
        if (is_win == true) {
            w11.close();
        }
        w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
        w11.setText("Documents");
        w11.setModal(true);
        w11.maximize();
        w11.attachURL(param, false, true);

        w11.attachEvent("onClose", function(win) {
            update_document_counter(object_id, ns_process_treatment.toolbar);
            return true;
        });            
    }
</script>
</html>