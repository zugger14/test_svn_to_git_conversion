<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php 
    $form_namespace = 'addTerms';
    $deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : '';
    $min_date = (isset($_POST["min_date"]) && $_POST["min_date"] != '') ? get_sanitized_value($_POST["min_date"]) : '';
    $max_date = (isset($_POST["max_date"]) && $_POST["max_date"] != '') ? get_sanitized_value($_POST["max_date"]) : '';
    $type = (isset($_POST["type"]) && $_POST["type"] != '') ? get_sanitized_value($_POST["type"]) : '';
    $from_date = $min_date;
    $to_date = $max_date;

    if ($type != 'leg') {
        $sp_term = "EXEC spa_deal_update_new @flag='m', @from_date='" . $max_date . "', @source_deal_header_id=" . $deal_id;
        $data = readXMLURL2($sp_term);

        $from_date = $data[0]['from_date'];
        $to_date = $data[0]['to_date'];
    }

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $form_json = '[{type: "settings", position: "label-top", offsetLeft:'.$ui_settings['offset_left'].', inputWidth:'.$ui_settings['field_size'].'},
                   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "from_date", "label": "From", "enableTime": false, "calendarPosition": "bottom", "value":"' . $from_date . '"},
                   {"type":"newcolumn"},
                   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "to_date", "label": "To", "enableTime": false, "calendarPosition": "bottom", "value":"' . $to_date . '"}
                  ]';
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('term_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    echo $form_obj->init_by_attach('term_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_from_date" id="txt_from_date"></textarea>
<textarea style="display:none" name="txt_to_date" id="txt_to_date"></textarea>
<script type="text/javascript">
    var type = '<?php echo $type; ?>';
    var min_date = '<?php echo $min_date; ?>';
    min_date = dates.convert_to_user_format(min_date);
    var max_date = '<?php echo $max_date; ?>';
    max_date = dates.convert_to_user_format(max_date);

    $(function() {
        var from_cal = addTerms.term_form.getCalendar('from_date');

        if (type == 'leg') {
            var to_cal = addTerms.term_form.getCalendar('to_date');
            from_cal.setSensitiveRange(min_date, max_date);
            to_cal.setSensitiveRange(min_date, max_date);
        } else {
            from_cal.setSensitiveRange(min_date, null);
        }
    })

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    addTerms.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(addTerms.term_form);
                if (status) {
                    var from_date = addTerms.term_form.getItemValue("from_date", true);
                    var to_date = addTerms.term_form.getItemValue("to_date", true);
                    
                    document.getElementById("txt_from_date").value = from_date;
                    document.getElementById("txt_to_date").value = to_date;
                    var win_obj = window.parent.term_window.window("w1");
                    win_obj.close();
                }
                break;
            case "cancel":
                document.getElementById("txt_from_date").value = 'cancel';
                var win_obj = window.parent.term_window.window("w1");
                win_obj.close();
                break;
        }
    }

    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    addTerms.form_change = function(name, value) {
        var from_date = addTerms.term_form.getItemValue("from_date", true);
        var to_date = addTerms.term_form.getItemValue("to_date", true);
        var min_max_val = (name == 'from_date') ? to_date : from_date;
		
		if (type == 'leg') {
            if (!dates.inRange(value, min_date, max_date) && min_date != 'Invalid Date' && max_date != 'Invalid Date') {
               var  message = 'Date should be in range: ' + min_date + ' - ' + max_date;               
               addTerms.show_error(message, name, min_max_val);
               return;
            }
        } 

        if (name == 'from_date' || name == 'to_date') {
	        if (dates.compare(to_date, from_date) == -1) {
				if (name == 'from_date') {
					addTerms.term_form.setItemValue("to_date", from_date);
					return;
				} else {
					var message = 'To Date cannot be less than From Date.';
				}
				addTerms.show_error(message, name, min_max_val);
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
    addTerms.show_error = function(message, name, min_max_val) {
        dhtmlx.alert({
            title:"Error",
            type:"alert-error",
            text:message,
            callback: function(result){
                addTerms.term_form.setItemValue(name, min_max_val);
            }
        });
    }
</script>
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
</html>