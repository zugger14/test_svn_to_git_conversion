<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
</head>

<body>
<?php
    require('../../../../../adiha.php.scripts/components/include.file.v3.php');
    
    $rights_view = 10233300;
    $rights_copy = 10233310;
    $rights_delete = 10233311;
    
    list (
        $has_rights_view,
        $has_rights_copy,
        $has_rights_delete
    ) = build_security_rights(
        $rights_view,
        $rights_copy,
        $rights_delete
    );
    
    // Layout JSON
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Filters",
                            height:          120,
                            header:         true,
                            collapse:       false,
                            fix_size:       [true,null]
                        },
                        {
                            id:             "b",
                            text:           "Prior As of Dates",
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]                            
                        }
                    ]';
    
    $name_space = 'copy_prior_mtm_value';
    $copy_prior_mtm_value_layout = new AdihaLayout();
    echo $copy_prior_mtm_value_layout->init_layout('copy_prior_mtm_value_layout', '', '2E', $layout_json, $name_space);

    // Filter Form
    $filter_form_json = '[
        {type: "settings", position: "label-top", labelWidth: "auto", inputWidth: '.$ui_settings['field_size'].'},
        {type: "calendar", name: "as_of_date_from", label: "As of Date From", offsetLeft: '.$ui_settings['offset_left'].',"inputWidth":'.$ui_settings['field_size'].'},
        {type: "newcolumn"},
        {type: "calendar", name: "as_of_date_to", label: "As of Date To", offsetLeft:'.$ui_settings['offset_left'].',"inputWidth":'.$ui_settings['field_size'].'}
    ]';

    $filter_form_obj = new AdihaForm();
    $filter_form_name = 'filter_form_copy_prior_mtm_value';

    echo $copy_prior_mtm_value_layout->attach_form($filter_form_name, "a");
    echo $filter_form_obj->init_by_attach($filter_form_name, $name_space);
    echo $filter_form_obj->load_form($filter_form_json);
    echo $filter_form_obj->attach_event('', 'onInputChange', 'on_filter_change');

    $toolbar_copy_prior_mtm_value = 'menu_toolbar';

    // Menu JSON
    $menu_json =    '[  {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                        {id:"Edit", img:"edit.gif", text:"Edit", offsetLeft: 20, items:[
                            {id:"copy", img:"copy.gif", imgdis:"copy_dis.gif", title:"Copy", enabled:0},
                            {id:"delete", img:"delete.gif", imgdis:"delete_dis.gif", title:"Delete", enabled:0}
                        ]},
                        {id:"export", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]}
                    ]';

    $copy_prior_mtm_value_menu = new AdihaMenu();
    echo $copy_prior_mtm_value_layout->attach_menu_cell($toolbar_copy_prior_mtm_value, "b"); 
    echo $copy_prior_mtm_value_menu->init_by_attach($toolbar_copy_prior_mtm_value, $name_space);
    echo $copy_prior_mtm_value_menu->load_menu($menu_json);
    echo $copy_prior_mtm_value_menu->attach_event('', 'onClick', 'on_toolbar_menu__click');
    echo $copy_prior_mtm_value_menu->attach_event('', 'onShow', 'hide_copy_popup');

    // Attaching Grid 
    $grid_copy_prior_mtm_value = new AdihaGrid();
    $grid_name = 'grd_copy_prior_mtm_value';
    echo $copy_prior_mtm_value_layout->attach_grid_cell($grid_name, 'b');
    $grid_sql = "EXEC spa_copy_prior_mtm_value 's'";
    
    echo $grid_copy_prior_mtm_value->init_by_attach($grid_name, $name_space);
    echo $grid_copy_prior_mtm_value->set_header('Prior As of Date, Records');
    echo $grid_copy_prior_mtm_value->set_widths('300, 300');
    echo $grid_copy_prior_mtm_value->set_search_filter(false,"#text_filter,#numeric_filter");
    echo $grid_copy_prior_mtm_value->set_column_types('ro,ron');
    echo $grid_copy_prior_mtm_value->set_columns_ids('prior_as_of_date, records');
    echo $grid_copy_prior_mtm_value->set_sorting_preference('str,int');
    echo $grid_copy_prior_mtm_value->return_init();
    echo $grid_copy_prior_mtm_value->load_grid_data($grid_sql);
    echo $grid_copy_prior_mtm_value->attach_event('', 'onRowSelect', 'enable_menu_btn');

    //Close Layout
    echo $copy_prior_mtm_value_layout->close_layout();

?>
</body>

<script type="text/javascript">  
    var client_date_format = '<?php echo $date_format; ?>';  
    var app_php_script_loc = "<?php echo $app_php_script_loc; ?>";
    var date_now = new Date();
    var has_rights_copy = Boolean(<?php echo $has_rights_copy; ?>);
    var has_rights_delete = Boolean(<?php echo $has_rights_delete; ?>);

    /*Previous Three Month*/
    var pre_3_month = new Date(date_now);
    pre_3_month = new Date(pre_3_month.setMonth(pre_3_month.getMonth() - 3));
    pre_3_month = new Date(pre_3_month.setDate(1));

    /*Last Day of Previous Month*/
    var pre_month_last_day = new Date(date_now);
    pre_month_last_day = new Date(pre_month_last_day.setDate(0));
    
    //Popup Field of Copy
    var copy_form_data =    [   
                                {type: "label", label: "To As of Date", labelTop: 25},
                                {type: "calendar", required:true, name: "as_of_date", dateFormat: client_date_format, labelTop: 30},
                                {type: "button", value: "Ok", img: "tick.png"}
                            ];
    
    var copy_popup = new dhtmlXPopup();
    var copy_form_data = copy_popup.attachForm(copy_form_data);
    copy_form_data.setItemValue("as_of_date", date_now);
    copy_form_data.attachEvent("onButtonClick", function(){
        on_btn_copy_click();
        toggle_copy_popup();
    }); 

    $(function () {
        copy_prior_mtm_value.filter_form_copy_prior_mtm_value.setCalendarDateFormat('as_of_date_from', client_date_format);
        copy_prior_mtm_value.filter_form_copy_prior_mtm_value.setCalendarDateFormat('as_of_date_to', client_date_format);

        copy_prior_mtm_value.filter_form_copy_prior_mtm_value.setItemValue('as_of_date_from', pre_3_month);  
        copy_prior_mtm_value.filter_form_copy_prior_mtm_value.setItemValue('as_of_date_to', pre_month_last_day);
    });

    function callback_grid_refresh () {
        var from_date = copy_prior_mtm_value.filter_form_copy_prior_mtm_value.getCalendar('as_of_date_from');
        from_date = from_date.getFormatedDate("%Y-%m-%d");
        var to_date = copy_prior_mtm_value.filter_form_copy_prior_mtm_value.getCalendar('as_of_date_to');
        to_date = to_date.getFormatedDate("%Y-%m-%d");

        if (from_date > to_date) {
            show_messagebox("<b>As of Date From</b> should not be greater than <b>As of Date To</b>.");
            return;
        }
        
        var sql_param = {
            "action"    : "spa_copy_prior_mtm_value",
            "flag"      : "s",
            "from_date" : from_date,
            "to_date"   : to_date
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        copy_prior_mtm_value.grd_copy_prior_mtm_value.clearAll();
        copy_prior_mtm_value.grd_copy_prior_mtm_value.loadXML(sql_url, function(){
            copy_prior_mtm_value.grd_copy_prior_mtm_value.filterByAll();
        });

        copy_prior_mtm_value.menu_toolbar.setItemDisabled("copy");
        copy_prior_mtm_value.menu_toolbar.setItemDisabled("delete");
    }

    function hide_copy_popup() {
        copy_popup.hide();
    }

    function toggle_copy_popup () {
        if (copy_popup.isVisible()) {
            copy_popup.hide();
        } else {
            copy_popup.show(80, 190, 100, 5);
        }
    }

    function enable_menu_btn () {
        if (has_rights_copy) {
            copy_prior_mtm_value.menu_toolbar.setItemEnabled("copy");
        } else {
            copy_prior_mtm_value.menu_toolbar.setItemDisabled("copy");
        }
        
        if (has_rights_delete) {
            copy_prior_mtm_value.menu_toolbar.setItemEnabled("delete");
        } else {
            copy_prior_mtm_value.menu_toolbar.setItemDisabled("delete");
        }
        
    }

    function get_as_of_date_from () {
        var selected_row_id = copy_prior_mtm_value.grd_copy_prior_mtm_value.getSelectedId();
        var as_of_date_from = copy_prior_mtm_value.grd_copy_prior_mtm_value.cells(selected_row_id, 0).getValue();
        as_of_date_from = dates.convert_to_sql(as_of_date_from);
        
        return  as_of_date_from
    }

    function on_toolbar_menu__click (name, value) {

        switch(name) {
            case "copy":
                toggle_copy_popup();
                break;
            case "delete":
                on_delete_copy_prior_mtm_value();
                break;
            case "excel":
                copy_prior_mtm_value.grd_copy_prior_mtm_value.toExcel(app_php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case "pdf":
                copy_prior_mtm_value.grd_copy_prior_mtm_value.toPDF(app_php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "refresh":
                callback_grid_refresh();
                break;
        }
    }

    function on_btn_copy_click () {
        var calendar_obj = copy_form_data.getCalendar('as_of_date');
        var as_of_date = dates.convert_to_sql(calendar_obj.getDate(true));

        if (!as_of_date) {
            show_messagebox("To As Of Date Cannot be empty.")
            return;
        }
        var as_of_date_from = get_as_of_date_from();

        if (as_of_date_from) {
            var app_user_name = '<?php echo $app_user_name; ?>';

            var param = 'call_from=Copy MTM&batch_type=c';
            var title = 'Copy MTM';
            var exec_call = "EXEC spa_copy_prior_mtm_job 'c', '" + as_of_date + "', '" + as_of_date_from + "', '" + app_user_name + "'";
            
            var run_batch = adiha_run_batch_process(exec_call, param, title);
        }
    }

    function on_delete_copy_prior_mtm_value () {
        var app_user_name = '<?php echo $app_user_name; ?>';
        var as_of_date = get_as_of_date_from();
        //Does not required while deleting. just for SP non null value 
        var as_of_date_from = as_of_date;

        if (as_of_date) {
            delete_data =   {   'action'            :  "spa_copy_prior_mtm_job", 
                                'flag'              :  "d", 
                                'as_of_date_copy'   :  as_of_date,
                                'as_of_date_from'   :  as_of_date_from,
                                'user_login_id'     :  app_user_name
                            };

            adiha_post_data('confirm', delete_data, '', '', 'callback_grid_refresh');
        }
        
    }

    function on_filter_change ( name, value ) {
        var as_of_date_from, as_of_date_to;
        var obj_filter_calendar = copy_prior_mtm_value.filter_form_copy_prior_mtm_value.getCalendar(name);
        var filter_date_format = obj_filter_calendar.getDate(true);

        switch ( name ) {
            case 'as_of_date_from' :
                as_of_date_from = filter_date_format;
                break;

            case 'as_of_date_to' :
                as_of_date_to = filter_date_format;
                break;
        }

    }

</script>
</html> 