<?php
/**
* Group name screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <style type="text/css">
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            padding: 0px;
            background-color: #ebebeb;
            overflow: hidden;
        }
    </style>
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php 
    $form_namespace = 'groupName';
    $group_name = (isset($_POST["group_name"]) && $_POST["group_name"] != '') ? get_sanitized_value($_POST["group_name"]) : '';
	$type = (isset($_POST["type"]) && $_POST["type"] != '') ? get_sanitized_value($_POST["type"]) : '';
	$term_start = (isset($_POST["term_start"]) && $_POST["term_start"] != '') ? get_sanitized_value($_POST["term_start"]) : '';
	$term_end = (isset($_POST["term_end"]) && $_POST["term_end"] != '') ? get_sanitized_value($_POST["term_end"]) : '';

    $name = '';
    $desc = '';

    if ($group_name != '') {
        $names = array();
        $names = explode('::', $group_name);

        $quant_array = array();
        if (sizeof($names) > 1) {
            $trimmed_names = array_map('trim', $names);
            $name = $trimmed_names[0];
            $desc = $trimmed_names[1];

            $quant_array = explode('x->', html_entity_decode($name));
            if (sizeof($quant_array) > 1) {
                $trimmed_quants = array_map('trim', $quant_array);
                $quantity = $trimmed_quants[0];
                $name = $trimmed_quants[1];
            } else {
                $name = $name;
                $quantity = '';
            }
        } else {
            $desc = $group_name;
            $quant_array = explode('x->', html_entity_decode($desc));

            if (sizeof($quant_array) > 1) {
                $trimmed_quants = array_map('trim', $quant_array);
                $quantity = $trimmed_quants[0];
                $desc = $trimmed_quants[1];
            } else {
                $desc = $desc;
                $quantity = '';
            }
        }
    }
    
    // Group description handled encoded values for double quote
    $desc = str_replace('"', '\"', html_entity_decode($desc));

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $sp_url = "EXEC spa_staticDataValues @flag = 'h', @type_id = 40100";
    $group_name_data = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true, '', 2);

    $form_json = '[{type: "settings", position: "label-top", "offsetLeft":'.$ui_settings['offset_left'].'},
                   {"type":"combo","name":"group_name","label":"Name", width: '.$ui_settings['field_size'].', "validate":"NotEmptywithSpace", "hidden":"false","disabled":"false","userdata":{"validation_message":"Invalid Selection"}, "tooltip":"Name", "filtering":"true","options":' . $group_name_data . '},
                   {"type":"newcolumn"},
                   {type: "input", inputWidth:'.$ui_settings['field_size'].', "name":"group_desc", label: "Group Description", required:true, disabled:"false", value:"' . $desc . '"},
                   {"type":"newcolumn"},
                   {type: "numeric", inputWidth:'.$ui_settings['field_size'].', "name":"group_quantity", label: "Quantity", required:false, disabled:"false", value:"' . $quantity . '", data_type: "float"}
                   
                  ]';
				  
	if ($type == 'c') {
		$form_json = '[{type: "settings", position: "label-top", offsetLeft:'.$ui_settings['offset_left'].'},
					{"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "from_date", "label": "Term Start", inputWidth: '.$ui_settings['field_size'].', "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
                   {"type":"combo","name":"group_name","label":"Name", width: '.$ui_settings['field_size'].', "validate":"NotEmptywithSpace", "hidden":"false", "disabled":"false","userdata":{"validation_message":"Invalid Selection"}, "tooltip":"Name", "filtering":"true","options":' . $group_name_data . '},
                   {type: "numeric", inputWidth:'.$ui_settings['field_size'].', "name":"group_quantity", label: "Quantity", required:false, disabled:"false", value:"' . $quantity . '", data_type: "float"},
                   {"type":"newcolumn"},
				   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "to_date", "label": "Term End", width: '.$ui_settings['field_size'].', "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"},
                   {type: "input", inputWidth:'.$ui_settings['field_size'].', "name":"group_desc", label: "Group Description", required:true, disabled:"false", value:"' . $desc . '"}
                  ]';
	}
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    echo $form_obj->init_by_attach('form', $form_namespace);
    echo $form_obj->load_form($form_json);	
    echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
    echo $layout_obj->close_layout();
?>
<textarea style="display:none" name="txt_group_name" id="txt_group_name"><?php echo $group_name; ?></textarea>
<textarea style="display:none" name="txt_term_start" id="txt_term_start"><?php echo $term_start; ?></textarea>
<textarea style="display:none" name="txt_term_end" id="txt_term_end"><?php echo $term_end; ?></textarea>
<textarea style="display:none" name="txt_btn_click" id="txt_btn_click">cancel</textarea>
</body>

<script type="text/javascript">

    $(function() {
        var name = '<?php echo $name; ?>';
        var combo = groupName.form.getCombo("group_name");
        var val = combo.getOptionByLabel(name);
        combo.setComboValue(val.value);
    })
    
    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    groupName.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(groupName.form);

                var win_obj = window.parent.group_name_win.window("w1");

                if (status) {
                    var combo = groupName.form.getCombo("group_name");
                    var name = combo.getComboText();
                    var desc = groupName.form.getItemValue("group_desc");
                    var quantity = groupName.form.getItemValue("group_quantity");
					var term_start = groupName.form.getItemValue("from_date", true);
					var term_end = groupName.form.getItemValue("to_date", true);

                    if (name != '') {
                        var group_name = name + ' :: ' + desc;
                    } else {
                        var group_name = desc;
                    }

                    if (quantity != '') {
                        group_name = quantity + 'x->' + group_name.trim();
                    }
                    document.getElementById("txt_group_name").value = group_name;
					document.getElementById("txt_term_start").value = term_start;
					document.getElementById("txt_term_end").value = term_end;
                    document.getElementById("txt_btn_click").value = 'ok';
                    win_obj.close();
                }
                break;
            case "cancel":
                var win_obj = window.parent.group_name_win.window("w1");
                document.getElementById("txt_btn_click").value = 'cancel';
                win_obj.close();
                break;
        }
    }
	
	/**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    groupName.form_change = function(name, value) {
		if (name == 'from_date' || name == 'to_date') {
			var from_date = groupName.form.getItemValue("from_date", true);
			var to_date = groupName.form.getItemValue("to_date", true);
			var min_max_val = (name == 'from_date') ? to_date : from_date;
			
			if (dates.compare(to_date, from_date) == -1) {
				if (name == 'from_date') {
					groupName.form.setItemValue("to_date", from_date);
					return;
				} else {
					var message = 'To Date cannot be less than From Date.';
				}
				groupName.show_error(message, name, min_max_val);
				return;
			}
		}
        
    }
	
	/**
     * [show_error Show Error]
     * @param  {[string]} message     [Message]
     * @param  {[string]} name        [Item name]
     * @param  {[date]} min_max_val   [Date]
     */
    groupName.show_error = function(message, name, min_max_val) {
        dhtmlx.alert({
            title:"Error",
            type:"alert-error",
            text:message,
            callback: function(result){
                groupName.form.setItemValue(name, min_max_val);
            }
        });
    }
</script>