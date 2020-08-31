<?php
/**
* Maintain static hour screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php

$rights_static_data_iu = 10101010; // main Save
list (
    $has_rights_static_data_iu
    ) = build_security_rights(
    $rights_static_data_iu
);

$layout = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_name = 'hourly_block_layout';
if (isset($_POST['value_id'])) {
    $value_id = get_sanitized_value($_POST['value_id']);
    $xml = '<Root><PSRecordset value_id="' . $value_id . '"></PSRecordset></Root>';
} else {
    $value_id = "null";
    $xml = '<Root><PSRecordset value_id=""></PSRecordset></Root>';
}

$hourly_checkboxes = "EXEC spa_hourly_block @flag = 't', @block_value_id = '" . $value_id . "'";
$checkbox_data = readXMLURL2($hourly_checkboxes);

$holiday_checkboxes = "EXEC spa_hourly_block @flag = 'h', @block_value_id = '" . $value_id . "'";
$holiday_checkbox_data = readXMLURL2($holiday_checkboxes);

$layout_json = '[
                    {
                            id:             "a",
                            text:           "Hourly Block",
                            width:          720,
                            height:         160,
                            header:         false,
                            collapse:       false,
                            fix_size:       [true,true]
                        },

                    ]';

$name_space = 'hourly_block';
echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

$toolbar_name = 'hourly_block_toolbar';
echo $layout->attach_toolbar_cell($toolbar_name, 'a');

$toolbar_obj = new AdihaToolbar();
$toolbar_obj->init_by_attach($toolbar_name, $name_space);
$theme_selected = 'dhtmlx_'.$default_theme;
echo "var icon_loc = '../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/".$theme_selected."/imgs/dhxtoolbar_web/';";
echo 'hourly_block.hourly_block_toolbar.setIconsPath(icon_loc);';
echo $toolbar_obj->load_toolbar('[{id: "save", type: "button",text:"Save", img: "save.gif", imgdis: "save_dis.gif", title:"", action: "save_hourly_block",  }]');
//Save button Privilege
if($value_id != 'null') {
    echo $toolbar_obj->save_privilege(get_sanitized_value($_POST['type_id']), $value_id);
}
//Start of Tabs
$tab_name = 'hourly_block_tabs';

$json_tab = '[
                {
                    id:      "a1",
                    text:    "General",
                    width:   null,
                    index:   null,
                    active:  true,
                    enabled: true,
                    close:   false
                },
                {
                    id:      "a2",
                    text:    "Hourly Block",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                },
            ]';

echo $layout->attach_tab_cell($tab_name, 'a', $json_tab);

echo $name_space . "." . $tab_name . '.setTabsMode("bottom");';
$tab_obj = new AdihaTab();

echo $tab_obj->init_by_attach($tab_name, $name_space);
// For General Tab

//For combo of source_system_id
echo 'source_system_array = ' . $form_obj->adiha_form_dropdown("EXEC spa_hourly_block 'c'", 0, 1, true) . ";" . "\n";
$sp_url_month = "SELECT n [value],  DATENAME(MONTH,DATEADD(MONTH,n,'2018-12-01')) [code] from seq where n <=12 order by 1 ASC";
$month_dropdown = $form_obj ->adiha_form_dropdown($sp_url_month , 0, 1, 'y', '');

$form_name = 'hourly_block_form';

$xml_file = "EXEC spa_create_application_ui_json 'j', 10101024, 'hourly_block', '$xml' ";
$return_value1 = readXMLURL($xml_file);
$form_structure_general = $return_value1[0][2];
//$form_name, $tab_id,$form_json,$namespace
echo $tab_obj->attach_form($form_name, 'a1', $form_structure_general, $name_space);

// getting all the day and number for top of hourly block
$day_number = '{"type":"newcolumn"},{type: "label", label: "Day", className:"dayLabel" position: absolute},';

for ($i = 1; $i <= 24; ++$i) {
    $day_number .= '{"type":"newcolumn"},{type: "label", label: "' . $i . '"},';
}

$week = array('Sun', 'Mon', 'Tue', 'Wed', 'Thurs', 'Fri', 'Sat');
$weekName = '{"type":"newcolumn"},{type: "label", label: "Day", offsetTop:11},';
$i = 1;
foreach ($week as $data) {
    $weekName .= '{type: "button", name: "weekday_' . $i++ . ' ", className:"weekname", value : "' . $data . ' ", width:50, action: "checkrow"},';
}
$weekhourCheck = '';
for ($j = 1; $j <= 24; ++$j) {
    $weekhourCheck .= '{"type":"newcolumn"}, {type: "button", name:"hour_' . $j . '", value: " ' . $j . '  ", width:30, className:"hours"},';
    for ($i = 1; $i <= 7; ++$i) {
        $hr = 'hr' . $j;
        $name = 'day_' . $i . '_' . $hr;
        $checked_param = ((array_key_exists($i - 1, $checkbox_data) ? $checkbox_data[$i - 1][$hr] : 0) == 1) ? "checked:true" : "";
        $weekhourCheck .= '{type: "checkbox", position:"label-left", className:"hrs-chk", name:"' . $name . '",' . $checked_param . '},';
    }
}


// Form for the next tab
for ($j = 1; $j <= 24; ++$j) {
    if ($j == 1) {
        $holidaycheckBox = '';
    } else {
        $holidaycheckBox .= '{"type":"newcolumn"},';
    }
    for ($i = 1; $i <= 1; ++$i) {
        $holiday_hr = 'hr' . $j;
        $holiday_name = 'holiday_hr_' . $j;
        $holiday_checked_param = ((array_key_exists(0, $holiday_checkbox_data) ? $holiday_checkbox_data[0][$holiday_hr] : 0) == 1) ? "checked:true" : "";
        $holidaycheckBox .= "{type: 'checkbox', position:'label-top', name: '" . $holiday_name . "', label:'" . $j . "' , offsetLeft:5, " . $holiday_checked_param . " },";
    }
}

// check peack hour of holiday block
if ((array_key_exists(0, $holiday_checkbox_data) ? $holiday_checkbox_data[0]["onpeak_offpeak"] : '') == 'p') {
    $pk_hr_holiday = "checked:true";
} else {
    $pk_hr_holiday = "checked:false";
}

if ((array_key_exists(0, $checkbox_data) ? $checkbox_data[0]["dst_applies"] : '') == 'y') {
    $dts_applies = "checked:true";
} else {
    $dts_applies = "checked:false";
}
$form_structure_hourly_block = '[
                                    {type:"fieldset", name:"data", label:"On Peak / Off Peak", inputWidth:"auto", blockOffset: 10, list:[
                                        {type:"block", name:"data", inputWidth:"auto", blockOffset: 10, list: [
                                            { type: "button", name: "select_all", className:"select_all", value: "Check/Uncheck", enabled: 0},
                                            {"type":"newcolumn"},
                                            {type: "checkbox", id:"dst_applies",  name: "dst_applies", label: "DST Applicable", position: "label-right", offsetTop:10, offsetLeft:0, ' . $dts_applies . ', value:true}
                                        ]},
                                        {type:"block", name:"data",  
                                            list: [
                                                ' . $weekName . '
                                                ' . $weekhourCheck . '
                                        ]}
                                    ]},
                                    {type:"fieldset", name:"dataQ", label:"Holiday", inputWidth:"auto",
                                        list: [
                                        {"type":"newcolumn"},
                                        {
                                        "type":"combo", "name":"calendar", "label":"Calendar:", "tooltip":"Calendar:", "validate":"",
                                        "position":"label-top",
                                        "inputWidth":"200",
                                        "offsetLeft":"5",
                                        "labelWidth":"260",
                                        "userdata":{"application_field_id":384},
                                        "hidden":"false",
                                        "disabled":"false",
                                        "filtering":"true",
                                        "options":source_system_array,
                                        "value" : "304411",
                                        },
                                        {"type":"newcolumn"},
                                        {"type":"combo", "name":"from_month", "label": "From Month:", "tooltip":"From Month","options": ' . $month_dropdown . ', 
                                        "position":"label-top",
                                        "inputWidth":"200",
                                        "offsetLeft":"5",
                                        "labelWidth":"260",
                                        "hidden":"false",
                                        "disabled":"false",
                                        "filtering":"true",
                                        },
                                        {"type":"newcolumn"},
                                        {"type":"combo", "name":"to_month", "label": "To Month:", "tooltip":"To Month","options": ' . $month_dropdown . ', 
                                        "position":"label-top",
                                        "inputWidth":"200",
                                        "offsetLeft":"5",
                                        "labelWidth":"260",
                                        "hidden":"false",
                                        "disabled":"false",
                                        "filtering":"true",
                                        },
                                        ],
                                        },
                                        {type:"block", name:"dataQ", label:"Holiday", inputWidth:"auto", blockOffset: 10, list: [
                                        ' . $holidaycheckBox . '
                                        ],
                                    }
                                ]

';

$form_name_2 = 'hourly_block_form_2'; // This is for second tab form Hourly Block form.
echo $tab_obj->attach_form($form_name_2, 'a2', $form_structure_hourly_block, $name_space);
echo $layout->close_layout();
?>

</body>
<style type="text/css">
    body {
        padding: 0px;
        margin: 0px;
    }
    .weekname {
        margin:0px 0 0 -15px;
        padding: 10px 0 0 0px; 
        font-weight: bold;
    }
    .hours {
        margin:0 0 0 -7px;
        padding : 0;
        font-weight: bold;
    }
    .hrs-chk {
        padding:10px 0 0 0 !important;
    }
    .hours > div >  div.dhxform_btn_txt {
        margin: 0 0 0 15px !important;
        padding: 0px; 
    } 
    div.select_all > div.dhxform_btn,
    div.select_all > div.dhxform_btn_over,
    div.select_all > div.dhxform_btn_pressed{
        background-repeat: no-repeat !important;
        background-position: 0px 4px !important;
        background-color: #86E2D5 !important;
        -moz-border-radius: 1px;
        -webkit-border-radius: 3px;
        border: 1px solid #009900;
        background-color: #33FF00;
        padding: 1px;
   }

    div.select_all div.dhxform_btn{
        background-image: url(<?php echo $image_path.'dhxtoolbar_web/select_unselect.gif'; ?>) !important;
    }
    .dhxform_obj_dhx_web fieldset.dhxform_fs{
        min-width:900px !important;
        overflow-x:scroll !important;
    }

    .dhx_cell_cont_layout {
        margin-top: 8px;
    }
    div.dhxform_obj_dhx_web div.dhxform_item_label_right {
        padding-top: 5px!important;
    }
    .dhxform_obj_dhx_web div.dhxform_item_label_left {
        padding-top:11px;
    }
    .dayLabel{
        /*padding-top: 20pc*/
    }
    .dhxform_obj_dhx_web div.dhxform_txt_label2{
        margin:0;
    }
    .dhxform_obj_dhx_web div.dhxform_item_label_top div.dhxform_control {
        float: none;
        margin-left: 3px;
        margin-bottom: 5px;
    }
    .dhxform_obj_dhx_web div.dhxform_label div.dhxform_label_nav_link, .dhxform_obj_dhx_web div.dhxform_label div.dhxform_label_nav_link:visited, .dhxform_obj_dhx_web div.dhxform_label div.dhxform_label_nav_link:active, .dhxform_obj_dhx_web div.dhxform_label div.dhxform_label_nav_link:hover {
        outline: none;
        text-decoration: none;
        color: inherit;
        cursor: default;
        overflow: hidden;
        white-space: nowrap;
        text-align: left;
    }

</style>

<script type="text/javascript">    
    $(document).ready(function () {
        var chk_box = 0;
        var has_rights_static_data_iu = <?php echo (($has_rights_static_data_iu) ? $has_rights_static_data_iu : '0'); ?>;
        if (has_rights_static_data_iu == 0) {
            hourly_block.hourly_block_toolbar.disableItem("save");
            hourly_block.hourly_block_toolbar.clearItemImage("save");
        }
        var value = '<?php echo $value_id; ?>';
        var formObj = hourly_block.hourly_block_form_2.getForm();
        var row_checked;
        var col_checked;
        var holiday_calendar_set = hourly_block.hourly_block_form_2.getCombo("calendar");
        var from_month_id = hourly_block.hourly_block_form_2.getCombo("from_month");
        var to_month_id = hourly_block.hourly_block_form_2.getCombo("to_month");

        holiday_calendar_set.setComboValue('<?php echo $checkbox_data[0]['holiday_value_id'] ?? ''; ?>');
        from_month_id.setComboValue('<?php echo $checkbox_data[0]['from_month'] ?? ''; ?>');
        to_month_id.setComboValue('<?php echo $checkbox_data[0]['to_month'] ?? ''; ?>');

        formObj.attachEvent("onButtonClick", function (name) {
            var name_to_check_col;
            var name_to_check_row;            
            //This block will check row Items
            if (name.substring(7, 0) == "weekday") {
                row_checked = formObj.isItemChecked("day_" + parseInt(name.substring(8, 10)) + "_hr1");
                for (var weekday = 1; weekday <= 24; weekday++) {
                    name_to_check_col = "day_" + parseInt(name.substring(8, 10)) + "_hr" + weekday;
                    if (row_checked == false) {
                        formObj.checkItem(name_to_check_col);
                    } else if (row_checked == true) {
                        formObj.uncheckItem(name_to_check_col);
                    }
                }
            } else if (name.substring(4, 0) == "hour") {
                col_checked = formObj.isItemChecked("day_2_hr" + parseInt(name.substring(5, 7)));
                for (var hour = 2; hour <= 6; hour++) {
                    name_to_check_row = "day_" + hour + "_hr" + parseInt(name.substring(5, 7));
                    if (col_checked == false) {
                        formObj.checkItem(name_to_check_row);
                    } else if (col_checked == true) {
                        if (hour == 2){
                            formObj.uncheckItem("day_1" + "_hr" + parseInt(name.substring(5, 7)));
                            formObj.uncheckItem("day_7" + "_hr" + parseInt(name.substring(5, 7)));
                        }
                        formObj.uncheckItem(name_to_check_row);
                    }
                }
            } else if(name == "select_all") {
                if (chk_box == 0) {
                    chk_box = 1;
                    for (var hour = 1; hour <= 7; hour++) {
                        for (var weekday = 1; weekday <= 24; weekday++) {
                            name_to_check_col = "day_" + hour + "_hr" + weekday;
                            formObj.checkItem(name_to_check_col);
                        }
                    }

                }
                else if (chk_box == 1) {
                    for (var hour = 1; hour <= 7; hour++) {
                        for (var weekday = 1; weekday <= 24; weekday++) {
                            name_to_check_col = "day_" + hour + "_hr" + weekday;
                            formObj.uncheckItem(name_to_check_col);
                        }
                    }
                    chk_box = 0;
                }
            }
        })              
    });

    function call_back(result) {

        var formchk = hourly_block.form_name_2.getForm();
        // this is wee_day (i.e : sunday, monday, ...)
        for (week_day = 0; week_day <= 6; week_day++) {
            // this is for the week hour starting from 3 to 26. Hr1 index start form 3 and Hr24 index ends at 26
            for (hr = 3; hr <= 26; hr++) {
                if (result[week_day][hr] == 1) {
                    week_num = week_day + 1;
                    hr_bool = hr - 2;
                    checkValue = 'chk[' + week_num + '][' + hr_bool + ']';
                    formchk.checkItem(checkValue);
                }
            }
        }

    }

    function save_hourly_block() {
        var hr; // = hourly_block.hourly_block_form_2.getCheckedValue('day_1_hr2');
        var value_id = hourly_block.hourly_block_form.getItemValue('value_id');
        var flag;
        if(value_id == '') {
            flag = "i";
        } else {
            flag = "u";
        }
        var code = hourly_block.hourly_block_form.getItemValue('code');
        var desc = hourly_block.hourly_block_form.getItemValue('description');
        var xml1;
        var xml2;
        var xml3;

        var status = validate_form(hourly_block.hourly_block_form);
        if (status == 'false' ) {
            return;
        }

       if(code != "") {
            /*
            * If description field is bank then
            * code value is assigned and save as description.
            * */
            if(desc == "" ) {
                desc = code;
                hourly_block.hourly_block_form.setItemValue('description', code);
            }

            /*  For the general tab.
             *  code and description save on table "<static_data_value>"
             *  with type_id = 10018 (Hourly Block)
             */
            xml1 = '<Root><PSRecordset type_id = "10018" value_id= "' + value_id + '" code = "' + code + '" description = "' + desc + '" ></PSRecordset></Root>';

            /*
             * For Hourly Block tab
             * all data save on table "<hourly_block>"
             * with General tab
             * */
            var dts_applies_value = (hourly_block.hourly_block_form_2.isItemChecked("dst_applies")) ? "y" : "n";
            //var dts_applies_value = "y";
            var holiday_calendar = hourly_block.hourly_block_form_2.getCombo("calendar");
            var holiday_calendar_id = holiday_calendar.getSelectedValue();
            var from_month_id = hourly_block.hourly_block_form_2.getCombo("from_month");
            var from_month = from_month_id.getSelectedValue();
            var to_month_id = hourly_block.hourly_block_form_2.getCombo("to_month");
            var to_month = to_month_id.getSelectedValue();
            xml2 = '<Root>';
            for (var i = 1; i <= 7; i++) {
                xml2 += '<PSRecordset block_value_id = "' + value_id + '" holiday_value_id = "' + holiday_calendar_id + '" from_month = "' + from_month + '" to_month = "' + to_month  + '" week_day = "' + i + '" dst_applies="' + dts_applies_value + '" onpeak_offpeak="p" ';
                for (var j = 1; j <= 24; j++) {
                    hr = (hourly_block.hourly_block_form_2.isItemChecked("day_" + i + "_hr" + j)) ? "1" : "0";
                    xml2 += ' edit_grid' + j + ' = " ' + hr + ' " ';
                }
                xml2 += " ></PSRecordset>";
            }
            xml2 += '</Root>';

            /*
             *  For Holiday Block
             *  all data save on table "<holiday_block>"
             *  */
            // Check Peak hour.
            var pk_hr = hourly_block.hourly_block_form_2.isItemChecked("peak_hour") ? "p" : "o";
            xml3 = '<Root><PSRecordset  block_value_id=" ' + value_id + ' " onpeak_offpeak="' + pk_hr + '" ';
            for (var holiday_j = 1; holiday_j <= 24; holiday_j++) {
                hr = (hourly_block.hourly_block_form_2.isItemChecked("holiday_hr_" + holiday_j)) ? "1" : "0";
                xml3 += ' edit_grid' + holiday_j + ' = "' + hr + '" ';

            }
            xml3 += ' ></PSRecordset></Root >';
            data = {
                "action": "spa_UpdateHourlyXml",
                "flag": flag,
                "xmlValue": xml2,
                "xmlValue2": xml3,
                "xmlValue3": xml1
            };

            //added the callback parameter to refresh the grid of parent grid
            adiha_post_data("alert", data, "", "", "save_callback");
       }
    }

    function save_callback(result) {
        if (result[0].status == 'Success') {
            var new_id = result[0].recommendation;
            hourly_block.hourly_block_form.setItemValue("value_id", new_id);
            var code = hourly_block.hourly_block_form.getItemValue('code');
            parent.setup_static_data.special_menu_case(result, code,'hourly_block');         
        }

    }

</script>

</html>