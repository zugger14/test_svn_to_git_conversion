<?php
/**
* Maintain static holidaygroup screen
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
$rights_holiday_block_delete = 10101011; // delete grid data
$rights_holiday_block_grid_iu = 10101010; // insert update grid

list (
    $has_rights_static_data_iu,
    $has_rights_holiday_block_iu,
    $has_rights_holiday_block_delete
    ) = build_security_rights(
    $rights_static_data_iu,
    $rights_holiday_block_grid_iu,
    $rights_holiday_block_delete
);

$layout = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_name = 'holiday_calendar_layout';

if (isset($_POST['value_id'])) {
    $value_id = get_sanitized_value($_POST['value_id']);
    $xml = '<Root><PSRecordset value_id="' . $value_id . '"></PSRecordset></Root>';
} else {
    $value_id = "null";
    $xml = '<Root><PSRecordset value_id=""></PSRecordset></Root>';
}

$layout_json = '[
                    {
                        id:             "a",
                        text:           "Holiday Calendar",
                        width:          720,
                        height:         160,
                        header:         false,
                        collapse:       false,
                        fix_size:       [true,true]
                    },

                ]';
$name_space = 'holiday_calendar';
echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

$toolbar_name = 'holiday_calendar_toolbar';
echo $layout->attach_toolbar_cell($toolbar_name, 'a');

$toolbar_obj = new AdihaToolbar();
echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);

echo $toolbar_obj->load_toolbar('[{id: "save", type: "button", text:"Save", img: "save.gif", imgdis: "save_dis.gif", title:"Save", action: "holiday_calendar",  }]');
//Save button Privilege
if($value_id != 'null') {
    echo $toolbar_obj->save_privilege(get_sanitized_value($_POST['type_id']), $value_id);
}
//Start of Tabs
$tab_name = 'holiday_calendar_tabs';

$json_tab = '[
                {
                    id:      "a1",
                    text:    "General",
                    width:   null,
                    index:   null,
                    active:  true,
                    enabled: true,
                    close:   false
                }
                ,
                {
                    id:      "a3",
                    text:    "Calendar Detail",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                },
                {
                    id:      "a2",
                    text:    "Calendar",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                }
            ]';

echo $layout->attach_tab_cell($tab_name, 'a', $json_tab);
echo $name_space . "." . $tab_name . '.setTabsMode("bottom");';
$tab_obj = new AdihaTab();

echo $tab_obj->init_by_attach($tab_name, $name_space);

$xml_file = "EXEC spa_create_application_ui_json 'j', 10101021, 'holiday_calendar', '$xml' ";
$return_value1 = readXMLURL($xml_file);
$form_structure_general = $return_value1[0][2];


$data = "EXEC spa_get_holiday_calendar 'c', '" . $value_id. "'";
$exp_cal_value_id_arr = readXMLURL($data );
$exp_cal_value_id = $exp_cal_value_id_arr[0][0];

// echo "<textarea>" . $holiday_value . "</textarea>";
// die();



/*echo str_replace("world","Peter",$form_structure_general);
echo "<textarea>" . $form_structure_general . "</textarea>";
die();
*/
$form_name = 'holiday_calendar_form';
echo $tab_obj->attach_form($form_name, 'a1', $form_structure_general, $name_space);

//for grid
$grid_name = 'holiday_group_calendar_grid';
echo 'holiday_calendar.holiday_group_calendar_grid= holiday_calendar.holiday_calendar_tabs.tabs("a2").attachGrid();';
$grid = new AdihaGrid();
echo $grid->init_by_attach($grid_name, $name_space);
$sql = "EXEC spa_get_holiday_calendar @flag ='g', @value_id = " . $value_id;
echo $grid->set_header('ID,Value ID,Date,Date to,Expiration Date,Settlement Date,Description');
echo $grid->set_widths('0,130,130,130,130,130,130,130');
echo $grid->set_columns_ids('hol_group_ID,hol_group_value_id,hol_date,hol_date_to,exp_date,settlement_date,description');
echo $grid->hide_column('0');
echo $grid->hide_column('1');
echo $grid->hide_column('3');
echo $grid->hide_column('4');
echo $grid->hide_column('5');
echo $grid->set_column_types('ro,ro,dhxCalendarA,dhxCalendarA,dhxCalendarA,dhxCalendarA,ed');
echo $grid->set_sorting_preference('int,int,date,date,date,date,string');
echo $grid->set_search_filter(true,'#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
//echo 'holiday_calendar.holiday_group_calendar_grid.setDateFormat("%m/%d/%Y");';
echo $grid ->load_grid_functions();
echo $grid->load_grid_data($sql);
echo $grid->enable_multi_select();
echo $grid->return_init();

//for holiday Expirition 
$sql_exp_cal = "EXEC spa_get_holiday_calendar @flag ='a', @value_id = " . $value_id;
$grid_name_holiday_exp = 'holiday_expirition_grid';
echo 'holiday_calendar.holiday_expirition_grid= holiday_calendar.holiday_calendar_tabs.tabs("a3").attachGrid();';
$grid_hol_exp = new AdihaGrid();
echo $grid_hol_exp->init_by_attach($grid_name_holiday_exp, $name_space);
//$sql = "EXEC spa_get_holiday_calendar @flag ='g', @value_id = " . $value_id;
echo $grid_hol_exp->set_header('ID,Calendar,Holiday Calendar,Delivery Period,Expiration From,Expiration To');
echo $grid_hol_exp->set_widths('50,130,130,130,130,130');
echo $grid_hol_exp->set_columns_ids('expiration_calendar_id,calendar_id,holiday_calendar,delivery_period,expiration_from,expiration_to');
echo $grid_hol_exp->set_column_visibility('true,true,true,false,false,false');
echo $grid_hol_exp->set_column_types('ro,ro,ro,dhxCalendarA,dhxCalendarA,dhxCalendarA');
echo $grid_hol_exp->set_sorting_preference('int,str,str,date,date,date');
echo $grid_hol_exp->set_search_filter(true,'#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
//echo 'holiday_calendar.holiday_group_calendar_grid.setDateFormat("%m/%d/%Y");';
echo $grid_hol_exp ->load_grid_functions();
echo $grid_hol_exp->load_grid_data($sql_exp_cal);
echo $grid_hol_exp->enable_multi_select();
echo $grid_hol_exp->return_init();
echo $layout->close_layout();
?>

<script type="text/javascript">
    $(function () {

       
        holiday_calendar.change_tab_property();
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        var exp_cal_value_id = '<?php echo $exp_cal_value_id; ?>';

        holiday_calendar.holiday_expirition_grid.setColValidators(["","","","NotEmpty","NotEmpty","NotEmpty"]);
        holiday_calendar.holiday_expirition_grid.attachEvent("onValidationError",function(id, ind, value) {
            var message = "Invalid Data";
            holiday_calendar.holiday_expirition_grid.cells(id,ind).setAttribute("validation", message);
            return true;
        });

        holiday_calendar.holiday_expirition_grid.attachEvent("onValidationCorrect",function(id,ind,value){
            holiday_calendar.holiday_expirition_grid.cells(id,ind).setAttribute("validation", "");
            return true;
        });
        
        // holiday_calendar.holiday_calendar_form.addItem('holiday_calendar', {  
        //             type:"combo",
        //             label:"Holiday Calendar",
        //             validate:"ValidInteger",
        //             hidden:"false",
        //             disabled:"false",
        //             readonly:"false",
        //             width:"220",
        //             userdata:{  
        //                "application_field_id":"",
        //                "default_format":"",
        //                "is_dependent":"0",
        //                "validation_message":"Invalid Selection"
        //             }},6);

        // holiday_calendar.holiday_calendar_tabs.tabs("a3").attachStatusBar({
        //                                 height : 30,
        //                                 text : '<div id="pagingArea_b"></div>'
        //                             });
        // holiday_calendar.holiday_expirition_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        // holiday_calendar.holiday_expirition_grid.enablePaging(true, 10, 0, 'pagingArea_b');
       // holiday_calendar.holiday_expirition_grid.setPagingSkin('toolbar'); 

        holiday_calendar.holiday_expirition_grid.setDateFormat(user_date_format );
        holiday_exp_grid_toolbar = holiday_calendar.holiday_calendar_tabs.tabs("a3").attachMenu();
        holiday_exp_grid_toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");

        //Menu for the Holiday Expirition Grid
        var holiday_exp_toolbar =   [
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: false }
            ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]},

        ];

        holiday_exp_grid_toolbar.loadStruct(holiday_exp_toolbar);
        var holiday_exp_grid_delete_data = "";
        holiday_exp_grid_toolbar.attachEvent('onClick', function (id) {
            switch (id) {
                case "add" :
                    var newId = (new Date()).valueOf();
                    holiday_calendar.holiday_expirition_grid.addRow(newId, '');
                    holiday_calendar.holiday_expirition_grid.forEachRow(function(row){
                        holiday_calendar.holiday_expirition_grid.forEachCell(row,function(cellObj,ind){
                            holiday_calendar.holiday_expirition_grid.validateCell(row,ind)
                        });
                    });
                    //holiday_calendar.holiday_expirition_grid.cells(newId, 1).setValue(value_id);
                    break;
                case "delete" :
                    var del_ids = holiday_calendar.holiday_expirition_grid.getSelectedRowId();
                    var selected_row_array_id = del_ids.split(',');
                    var expiration_calendar_id = '';
                    var static_values_id = '';

                    for (var i = 0; i < selected_row_array_id.length; i++) {
                        expiration_calendar_id = holiday_calendar.holiday_expirition_grid.cells(selected_row_array_id[i], 0).getValue();
                        static_values_id = holiday_calendar.holiday_expirition_grid.cells(selected_row_array_id[i], 1).getValue();
                        
                        holiday_calendar.holiday_expirition_grid.deleteRow(selected_row_array_id[i]);
                        holiday_cal_delete_grid += '<GridHolidayCalDelete  expiration_calendar_id ="' + expiration_calendar_id + '"  hol_group_value_id="' + static_values_id + '" ></GridHolidayCalDelete>';
                    }
                    holiday_exp_grid_toolbar.setItemDisabled("delete");
                    break;
                case "excel":
                    holiday_calendar.holiday_expirition_grid.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    break;
                case "pdf":
                    holiday_calendar.holiday_expirition_grid.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    break;
            }
        });


        holiday_calendar.holiday_calendar_tabs.tabs("a2").attachStatusBar({
                                        height : 30,
                                        text : '<div id="pagingArea_b"></div>'
                                    });
        holiday_calendar.holiday_group_calendar_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        holiday_calendar.holiday_group_calendar_grid.enablePaging(true, 10, 0, 'pagingArea_b');
        holiday_calendar.holiday_group_calendar_grid.setPagingSkin('toolbar'); 


        holiday_calendar.holiday_calendar_tabs.tabs("a3").attachStatusBar({
                                        height : 30,
                                        text : '<div id="pagingArea_c"></div>'
                                    });
        holiday_calendar.holiday_expirition_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        holiday_calendar.holiday_expirition_grid.enablePaging(true, 10, 0, 'pagingArea_c');
        holiday_calendar.holiday_expirition_grid.setPagingSkin('toolbar'); 

        holiday_calendar.holiday_group_calendar_grid.setDateFormat(user_date_format );
        
        var has_rights_static_data_iu = Boolean(<?php echo $has_rights_static_data_iu;?>);
        var has_rights_holiday_block_iu = <?php echo (($has_rights_holiday_block_iu) ? $has_rights_holiday_block_iu : '0'); ?>;
        var has_rights_holiday_block_grid_delete = <?php echo (($has_rights_holiday_block_delete) ? $has_rights_holiday_block_delete : '0'); ?>;

        if (has_rights_static_data_iu == 0) {
            holiday_calendar.holiday_calendar_toolbar.disableItem("save");
            holiday_calendar.holiday_calendar_toolbar.clearItemImage("save");
        }

        var general_Form = holiday_calendar.holiday_calendar_form.getForm();
        var combo_hol_cal = general_Form.getCombo('xref_value');
        //console.log(exp_cal_value_id);
        combo_hol_cal.setComboValue(exp_cal_value_id);

        var value_id = '<?php echo $value_id; ?>';
        var category_id = general_Form.getItemValue('category_id');
        var delete_grid = "";
        var holiday_cal_delete_grid = "";

        if(category_id) {
            grid_show(category_id);
        }

        if(value_id == "") {
            value_id = general_Form.getItemValue('value_id');
        }

     
        grid_toolbar = holiday_calendar.holiday_calendar_tabs.tabs("a2").attachMenu();
        grid_toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");

        //Menu for the Constraints Grid
        var constraints_toolbar =   [
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: false }
            ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]},

        ];

        grid_toolbar.loadStruct(constraints_toolbar);

        if( has_rights_holiday_block_iu == 0 ) {
            grid_toolbar.setItemDisabled("add");
        }

        grid_toolbar.attachEvent('onClick', function (id) {
            switch (id) {
                case "add" :
                    var newId = (new Date()).valueOf();
                    holiday_calendar.holiday_group_calendar_grid.addRow(newId, '');
                    holiday_calendar.holiday_group_calendar_grid.cells(newId, 1).setValue(value_id);
                    break;
                case "delete" :
                    var del_ids = holiday_calendar.holiday_group_calendar_grid.getSelectedRowId();
                    var selected_row_array_id = del_ids.split(',');
                    var values_id = '';
                    var static_values_id = '';

                    for (var i = 0; i < selected_row_array_id.length; i++) {
                        values_id = holiday_calendar.holiday_group_calendar_grid.cells(selected_row_array_id[i], 0).getValue();
                        static_values_id = holiday_calendar.holiday_group_calendar_grid.cells(selected_row_array_id[i], 1).getValue();
                        
                        holiday_calendar.holiday_group_calendar_grid.deleteRow(selected_row_array_id[i]);
                        delete_grid += '<GridDelete  hol_group_ID ="' + values_id + '"  hol_group_value_id="' + static_values_id + '" ></GridDelete>';
                    }

                   /* if (values_id != '' || static_values_id != '') {
                        data = {
                            "action": "spa_get_holiday_calendar",
                            "flag": "d",
                            "value_id": values_id
                        };
                        adiha_post_data("confirm", data, "", "", "grid_delete_callback");
                    } else if( values_id == '' || static_values_id != '') {
                        dhtmlx.alert({
                            title: "Alert",
                            type: "alert-error",
                            text: "Please select a row from grid!"
                        });
                    }*/
                    grid_toolbar.setItemDisabled("delete");
                    break;
                case "excel":
                    holiday_calendar.holiday_group_calendar_grid.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    break;
                case "pdf":
                    holiday_calendar.holiday_group_calendar_grid.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    break;
            }
        });

        // Event after clicking in the
        holiday_calendar.holiday_calendar_toolbar.attachEvent('onClick', function (id) {

            var validation = 0;
            var grid_index;
            var grid_value;
            var blank_value = 0;
            var blank_value_exp = 0;
            var blank_value_desc = 0;
            var blank_settlement_date = 0;
            var date_from;
            var date_to;
            var exp_date;
            var settlement_date;
            var exp_date_greater = 0;
            var settlement_date_greater = 0;
            var date_to_greater = 0;
            var exp_calendar_grid_status = true;
            var valid_date = true;
            tabsCount = holiday_calendar.holiday_calendar_tabs.getNumberOfTabs();
            tab_id = holiday_calendar.holiday_calendar_tabs.getAllTabs();
            generalForm = holiday_calendar.holiday_calendar_form.getForm();
            // generalGrid =
            var xml1; // XML for static data value for calender with static_data_value = 10017
            var grid_xml; // XML for holiday_group
            var code = generalForm.getItemValue('code'); // name
            var description = generalForm.getItemValue('description') //description
            var category_id = generalForm.getItemValue('category_id') //description
            var holiday_calendar_id = generalForm.getItemValue('xref_value');
            var status = validate_form(generalForm);            

            if(category_id != 38701) {
                holiday_calendar.holiday_expirition_grid.clearAll();
            } else {
                var exp_calendar_grid_status = holiday_calendar.validate_form_grid(holiday_calendar.holiday_expirition_grid, "Calendar");
                if(!exp_calendar_grid_status) {
                    return
                }
                var exp_from_index = holiday_calendar.holiday_expirition_grid.getColIndexById("expiration_from");
                var exp_to_index = holiday_calendar.holiday_expirition_grid.getColIndexById("expiration_to");
                holiday_calendar.holiday_expirition_grid.forEachRow(function(row_id) {
                   var expiration_frm = dates.convert_to_sql(holiday_calendar.holiday_expirition_grid.cells(row_id,exp_from_index).getValue());
                   var expiration_to = dates.convert_to_sql(holiday_calendar.holiday_expirition_grid.cells(row_id,exp_to_index).getValue());
                   if((new Date(expiration_to) < new Date(expiration_frm)) && valid_date) {
                    valid_date = false;
                   }
                   
                });
                if(!valid_date) {
                    show_messagebox("<b>Expiration From</b> should be lesser than <b>Expiration To</b>.")
                    return;
                }
            }

            holiday_calendar.holiday_group_calendar_grid.clearSelection();

            if (value_id == "") {
                value_id = generalForm.getItemValue('value_id'); // name
            }

            if (status === false ) {
                generate_error_message( holiday_calendar.holiday_calendar_tabs.tabs(tab_id[0]));
                return;
            }

            if (code != '') {
                if(description == '')
                {
                    description = code;
                    generalForm.setItemValue('description', code);
                }
                /*  For the general tab.
                 *  code and description save on table "<static_data_value>"
                 *  with type_id = 10018 (Hourly Block)
                 */
                xml1 = '<Root><PSRecordset type_id = "10017" value_id= "' + value_id + '" code = "' + code + '" description = "' + description + '" category_id = "' + category_id + '" holiday_calendar_id = "' + holiday_calendar_id +'" ></PSRecordset></Root>';

                /*
                 * For Properties Properties tab
                 * all data save on table "<holiday_group>"
                 * with General tab
                 * */
                grid_xml = '<GridGroup><Grid grid_id = "holiday_group_calendar_grid">';
                grid_xml += delete_grid;
                holiday_calendar.holiday_group_calendar_grid.forEachRow(function (id) {
                    grid_xml = grid_xml + "<GridRow ";

                    holiday_calendar.holiday_group_calendar_grid.forEachCell(id, function (cellObj, ind) {
                        grid_index = holiday_calendar.holiday_group_calendar_grid.getColumnId(ind);
                        if (holiday_calendar.holiday_group_calendar_grid.getColType(ind) == 'dhxCalendarA') {
                            //grid_value = changedate(cellObj.getValue(ind));
                            grid_value = cellObj.getValue(ind);
                            
                            if( ind == 2 && grid_value == '') {
                                blank_value = 1;
                            }  else if (ind == 4 && grid_value == '' && category_id == 38701) {
                                blank_value_exp = 1;
                            } else  if (ind == 5 && grid_value == '' && category_id == 38702) {
                                    blank_settlement_date = 1;
                                }

                                if( ind == 2  ){
                                    date_from = grid_value;
                                } else if( ind == 3 ) {
                                    date_to = grid_value;
                                    //alert(date_to);
                                } else if ( ind == 4 ) {
                                    exp_date = grid_value;
                                } else if ( ind == 5 ) {
                                    settlement_date = grid_value
                                }

                            if( ind == 3 ) {
                                if (category_id == 38701 || category_id == 38702 ) {
                                    if(new Date(date_from).getTime() > new Date(date_to).getTime()) {
                                        if( date_to != '' ) {
                                            date_to_greater = 1;
                                        }
                                    }
                                }
                            }
                            if (grid_index == 'hol_date' || grid_index == 'hol_date_to' || grid_index == 'exp_date' ||  grid_index ==  'settlement_date') {
                                if (grid_value != '')
                                    grid_value = dates.convert_to_sql(grid_value);
                            }
                            grid_xml = grid_xml + " " + grid_index + '="' + grid_value + '"';							
                        } else {		
                            grid_value = cellObj.getValue(ind);
							if (ind == 6 && category_id == 38700 && grid_value == '') {
                                blank_value_desc = 1;
                            }
                            if (grid_index == 'hol_date' || grid_index == 'hol_date_to' || grid_index == 'exp_date' ||  grid_index ==  'settlement_date') {
                                if (grid_value != '')
                                    grid_value = dates.convert_to_sql(grid_value);
                            }
                            grid_xml = grid_xml + " " + grid_index + '="' + escapeXML(grid_value) + '"';
                        };
                    });

                    grid_xml += '></GridRow>';
                });

                grid_xml += '</Grid>';

                

                grid_xml += '<GridCalendarExp>'
                grid_xml += holiday_cal_delete_grid;

                holiday_calendar.holiday_expirition_grid.forEachRow(function (id) {
                    grid_xml = grid_xml + "<GridRow ";
                    holiday_calendar.holiday_expirition_grid.forEachCell(id, function (cellObj, ind) {
                        grid_index = holiday_calendar.holiday_expirition_grid.getColumnId(ind);
                        grid_value = cellObj.getValue(ind);
                        if (holiday_calendar.holiday_expirition_grid.getColType(ind) == 'dhxCalendarA') {
                           if (grid_index == 'delivery_period' || grid_index == 'expiration_from' || grid_index == 'expiration_to') {
                            //alert(grid_value + ' ->' +dates.convert_to_sql(grid_value))
                               if (grid_value != '')
                                   grid_value = dates.convert_to_sql(grid_value);
                           }
                              
                        }
                        grid_xml = grid_xml + " " + grid_index + '="' + escapeXML(grid_value) + '"';
                    });
                    grid_xml = grid_xml + "></GridRow>";
                 });
                grid_xml += '</GridCalendarExp>'

                grid_xml += '</GridGroup>';

                data = {
                    "action": "spa_UpdateHolidayXml",
                    "flag": "i",
                    "xmlValue": xml1,
                    "xmlValue2": grid_xml
                };

                //added the callback parameter to refresh the grid of parent grid
                if( blank_value == 0 && blank_value_exp == 0 && blank_value_desc == 0 && blank_settlement_date == 0 && exp_date_greater == 0 && settlement_date_greater == 0 && date_to_greater == 0 ) {
                    if (delete_grid != "" || holiday_cal_delete_grid != "") {
                        confirm_messagebox("Some data has been deleted from Calendar grid. Are you sure you want to save?", function() {
                            result = adiha_post_data("alert", data, "", "", "save_callback");
                            delete_grid = '';
                        }, function() {
                            refresh_grid(value_id);
                        });
                    } else {
                        result = adiha_post_data("alert", data, "", "", "save_callback");
                    }
                } else {
                    //holiday_calendar.holiday_calendar_tabs.tabs(tab_id[1]).setActive();
                    if (blank_value == 1 && category_id != "38700") {
                        show_messagebox("Data Error in <b>Calendar Properties</b>. Please check the data in column <b>Date From </b> and resave.");
                        return;
                    } else if (blank_value == 1 && category_id == "38700") {
                        show_messagebox("Data Error in <b>Calendar Properties</b>. Please check the data in column <b> Date</b> and resave.");
                        return;
                    } else if (blank_value_exp == 1) {
                        show_messagebox("Data Error in <b>Calendar Properties</b>. Please check the data in column <b>Expiration Date</b> and resave.");
                        return;
                    } else if (blank_settlement_date == 1) {
                        show_messagebox("Data Error in <b>Calendar Properties</b>. Please check the data in column <b>Settlement Date</b> and resave.");
                        return;
                    } else if (blank_value_desc == 1) {
                        show_messagebox("Data Error in <b>Calendar Properties</b>. Please check the data in column <b>Description</b> and resave.");
                        return;
                    } else if (date_to_greater == 1) {
                        show_messagebox("<b>Date To</b> should be greater than <b>Date From</b>.");
                        return;
                    } /*else if (exp_date_greater == 1) {
                        dhtmlx.alert({
                            title: "Error",
                            type: "alert-error",
                            text: "<b>Date From </b> can't be greater than <b>Expiration Date </b>."
                        });
                        return;
                    } else if (settlement_date_greater == 1) {
                        dhtmlx.alert({
                            title: "Error",
                            type: "alert-error",
                            text: "<b>Date From </b> can't be greater than <b>Settlement Date </b>."
                        });
                        return;
                    }*/
                }                    
            }
        });

        var form_obj = holiday_calendar.holiday_calendar_form.getForm();

        var cat_id = form_obj.getItemValue('category_id');
     
        //alert(form_obj);
        form_obj.attachEvent("onChange", function (name, value) {
            if (name == 'category_id') {
                grid_show(value);
                holiday_calendar.change_tab_property();
            }
        });

        holiday_calendar.holiday_group_calendar_grid.attachEvent("onRowSelect", doOnRowSelected);
        function doOnRowSelected(id) {
		if (has_rights_static_data_iu) {
                grid_toolbar.setItemEnabled("delete");
            }
        }

        holiday_calendar.holiday_expirition_grid.attachEvent("onRowSelect", function(id) {
            if (has_rights_static_data_iu) {
                    holiday_exp_grid_toolbar.setItemEnabled("delete");
                }
        });
      
        /**
         * Detail grid column on change event - save changed data to process table
         * @param  {[type]} rId     [rowid]
         * @param  {[type]} cInd    [column index]
         */
            /*holiday_calendar.holiday_group_calendar_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){

                if(stage == 2) {
                 var form_obj = holiday_calendar.holiday_calendar_form.getForm();
                 var cat = form_obj.getItemValue('category_id');
                 var validation = 0;

                 if (cInd == 2 || cInd == 3 || cInd == 4 || cInd == 5) {
                    var date = holiday_calendar.holiday_group_calendar_grid.cellById(rId, 2).getValue();
                    var date1 = holiday_calendar.holiday_group_calendar_grid.cellById(rId, 3).getValue();
                    var date2 = holiday_calendar.holiday_group_calendar_grid.cellById(rId, 4).getValue();
                    var date3 = holiday_calendar.holiday_group_calendar_grid.cellById(rId, 5).getValue();

                    if (date != '') {

                    }

                    var date_from = dates.convert_to_sql(date);
                    var date_to = dates.convert_to_sql(date1);
                    var date_exp = dates.convert_to_sql(date2);
                    var date_sette = dates.convert_to_sql(date3);
                 }
                 var cell_value = holiday_calendar.holiday_group_calendar_grid.cellById(rId, cInd).getValue();

                 if ( cell_value != null || cell_value != "") {

                     if (cat == 38701) {
                         if (( dates.compare(date_from, date_to) == -1 || dates.compare(date_from, date_exp) == -1 ))
                             validation = 1;

                 } else if (cat == 38702){
                     if (dates.compare(date_from, date_to) == -1 && dates.compare(date_from, date_sette) == -1 )
                         validation = 1;
                 }
                 }
                     if (validation == 1) {
                         return true;
                     }
                     else {
                         if (holiday_calendar.holiday_group_calendar_grid.cellById(rId, cInd).getValue() != null) {

                             var field;
                             if (cat == 38701) {
                                 field = "Expiration Date";
                             } else {
                                 field = "Settlement Date";
                             }

                             dhtmlx.alert({
                                 title: "Error",
                                 type: "alert-error",
                                 text: "<b>Date From</b> cannot be smaller than <b> Date to </b> and <b>" + field + "</b>"

                             });
                             return false;
                         }
                     }
                 }

             });*/

    });


    var save_callback = function (result) {
        var message_error;
        if (result[0].status == 'Success') {
            var new_id = result[0].recommendation;
            if(result[0].recommendation == '' ) {
                new_id = '<?php echo $value_id; ?>';
            }
            generalForm.setItemValue('value_id', new_id);
            var code = generalForm.getItemValue('code');
            refresh_grid(new_id);
            parent.setup_static_data.special_menu_case(result, code,'calendar');            
        }
    }

    /**
     * [delete_callback]
     */
    function grid_delete_callback(result){
        if(result[0].status == 'Success') {
            holiday_calendar.holiday_group_calendar_grid.deleteRow(holiday_calendar.holiday_group_calendar_grid.getSelectedRowId());
            grid_toolbar.setItemDisabled("delete");
        }
    }

    function refresh_grid(id){
        //var sql_param = "EXEC spa_get_holiday_calendar @flag ='g', @value_id = " + id;
        var sql_param = {
            "sql":"EXEC spa_get_holiday_calendar @flag ='g', @value_id = " + id
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        holiday_calendar.holiday_group_calendar_grid.clearAll();
        holiday_calendar.holiday_group_calendar_grid.load(sql_url);

    }

    function grid_show(value) {
        if (value == '38700') {
            holiday_calendar.holiday_group_calendar_grid.setHeader('ID, Value ID, Date, Date to, Expiration Date, Settlement Date,   Description');
            holiday_calendar.holiday_group_calendar_grid.setColTypes("ro,ro,dhxCalendarA,dhxCalendarA,dhxCalendarA,dhxCalendarA,ed");
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(2, false);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(3, true);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(4, true);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(5, true);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(6, false);
            holiday_calendar.holiday_group_calendar_grid.setColumnLabel(2,"Date");
            //holiday_calendar.holiday_group_calendar_grid.enableValidation();
            holiday_calendar.holiday_group_calendar_grid.setColValidators(",,NotEmpty,,,,NotEmpty");
        } else if (value == '38701') {
            holiday_calendar.holiday_group_calendar_grid.setColTypes("ro,ro,dhxCalendarA,dhxCalendarA,dhxCalendarA,dhxCalendarA,ed");
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(2, false);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(3, false);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(4, false);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(5, true);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(6, true);
            holiday_calendar.holiday_group_calendar_grid.setColumnLabel(2,"Date From");
            holiday_calendar.holiday_group_calendar_grid.setColValidators(",,NotEmpty,,NotEmpty,,");

        } else if (value == '38702') {
            holiday_calendar.holiday_group_calendar_grid.setColTypes("ro,ro,dhxCalendarA,dhxCalendarA,dhxCalendarA,dhxCalendarA,ed");
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(2, false);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(3, false);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(4, true);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(5, false);
            holiday_calendar.holiday_group_calendar_grid.setColumnHidden(6, true);
            holiday_calendar.holiday_group_calendar_grid.setColumnLabel(2,"Date From");
            holiday_calendar.holiday_group_calendar_grid.setColValidators(",,NotEmpty,,,NotEmpty,");
        }
    }
    holiday_calendar.change_tab_property = function() {
        var form_obj = holiday_calendar.holiday_calendar_form.getForm();

        var cat_id = form_obj.getItemValue('category_id');
        var tab_ids = holiday_calendar.holiday_calendar_tabs.getAllTabs();
        if(cat_id == 38701) { //static_data_value type expiration
            form_obj.showItem('xref_value');
            for (var q=0; q<tab_ids.length; q++) {
               // myTabbar.tabs(ids[q]).disable();
                //var tab_txt = holiday_calendar.holiday_calendar_tabs.tabs(ids[q]).getText();
                if(tab_ids[q] == 'a2') { //Calendar
                    holiday_calendar.holiday_calendar_tabs.tabs(tab_ids[q]).setText("Detail");
                    holiday_calendar.holiday_calendar_tabs.moveTab("a2", 3); 

                } else if (tab_ids[q] == 'a3') { //Calendar Detail
                    holiday_calendar.holiday_calendar_tabs.tabs(tab_ids[q]).setText("Calendar");
                    holiday_calendar.holiday_calendar_tabs.tabs(tab_ids[q]).show();
                    holiday_calendar.holiday_calendar_tabs.moveTab("a3", 2);  
                }
            }
            
        } else {
            var combo_hol_cal = form_obj.getCombo('xref_value');
            combo_hol_cal.setComboValue('');
            form_obj.hideItem('xref_value');
            for (var q=0; q<tab_ids.length; q++) {
               // myTabbar.tabs(ids[q]).disable();
                //var tab_txt = holiday_calendar.holiday_calendar_tabs.tabs(ids[q]).getText();
                if(tab_ids[q] == 'a2') { //Calendar
                    holiday_calendar.holiday_calendar_tabs.tabs('a3').hide();
                    holiday_calendar.holiday_calendar_tabs.tabs(tab_ids[q]).setText("Calendar");
                    holiday_calendar.holiday_calendar_tabs.moveTab("a2", 2); 
                    holiday_calendar.holiday_calendar_tabs.moveTab("a3", 3);   

                } else if (tab_ids[q] == 'a3') { //Calendar Detail
                    holiday_calendar.holiday_calendar_tabs.tabs(tab_ids[q]).setText("Calendar Detail");
                     holiday_calendar.holiday_calendar_tabs.tabs(tab_ids[q]).hide();
                     holiday_calendar.holiday_calendar_tabs.moveTab("a2", 2);  
                     holiday_calendar.holiday_calendar_tabs.moveTab("a3", 3);  
                }
            }
            
        }
    }
    


</script>

