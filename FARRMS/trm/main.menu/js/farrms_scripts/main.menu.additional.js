$(window).on('blur',function() {
    $('header.navbar .dropdown-toggle').parent().removeClass('open');
});
var count_current_msg_only = 1;
var count_current_alert_only = 1;
var count_reminder = 0;


refresh_favourites();
refresh_recent_menu();
refresh_pinned_report();

var dhxWins;
dhx_wins = new dhtmlXWindows();
dhx_wins.attachViewportTo("workspace");

var date = new Date();
var current_year = document.getElementById('current_year') ;
current_year.innerHTML = date.getFullYear();

var version_data = {
    "action": "spa_application_version",
    "flag": "s"
};

adiha_post_data("return_array", version_data, '', '', "get_version");

var win_x_position = 1;

function get_version(result) {
    var version = document.getElementById("version");
    version.innerHTML = result[0][3];
}

/**
 * Unload help invoice window.
 */
function unload_window() {
    if (helpfile_window != null && helpfile_window.unload != null) {
        helpfile_window.unload();
        helpfile_window = w1 = null;
    }
}

function arrange_windows(){
    var win_y_position = $("#workspace").height()-25;
    win_x_position = 1;
    dhx_wins.forEachWindow(function(win) {
        if (win.isParked()) {
            win.setPosition(win_x_position, win_y_position);
            win_x_position = win_x_position + 252;
        }
    });
}

function tile_windows(){
    var win_y_position = 0;
    var win_x_position = 0;

    var win_height = $("#workspace").height();
    var win_width = $("#workspace").width();

    var temp_width = win_width/5;
    var i = 1;
    var break_point = 6;
    dhx_wins.forEachWindow(function(win) {
        if (i % 5 == 0) {
            break_point = i + 1;
        } else if (i == break_point) {
            if (i == 11) {
                document.getElementById('workspace').style.overflowY = 'scroll';
            }
            win_x_position = 0;
            win_y_position = win_y_position + (win_height-25)/2;
        }

        win.setDimension(temp_width, (win_height-35)/2);
        win.setPosition(win_x_position, win_y_position);
        win_x_position = win_x_position + temp_width;
        i++;
    });
}


function reset_timer() {
    clearTimeout(timer);
}

function mark_message_call_back(result) {
    if (result[0][0] == 'Success') {
        document.getElementById(result[0][5]).className = "item";
        var unread_message_no = result[0][7];
        if (unread_message_no > 0 && unread_message_no < 100) {
            updateMessageNumber("message-count", result[0][7]);
        }  else if (unread_message_no > 99) {
            updateMessageNumber("message-count", '99+');
        }

        var unread_alert_no = result[0][6];
        if (unread_alert_no > 0 && unread_alert_no < 100) {
            updateMessageNumber("alert-count", result[0][6]);
        }  else if (unread_alert_no > 99) {
            updateMessageNumber("alert-count", '99+');
        }
    }
}

function refresh_all_message() {
    $('#msg-search').val('');
    $("#msg-search" ).trigger("keyup");
    load_message_alert('n');
    $('#filter_msg_counts_message').html($("#post_count").html() + ' Messages');
    //check_uncheck_checkbox(false);
}

function delete_message_call_back(result) {
    var ref_msg_cnt = $("#post_count").html();
    var pre_message_count = $("#pre_count").html(ref_msg_cnt);
    load_message_alert('n');
    check_uncheck_checkbox(false);
}

function multiple_message_delete(message_filter) {
    var selected_id = get_selected_checkbox();
    delete_message(selected_id, message_filter);
    //console.log(all_ids);
}

function check_uncheck_checkbox(flag) {
    $('input:checkbox.checkboxes_classes').each(function(){ this.checked = flag; });
}
/* Same function is defined twice.
 function message_pop_up_drill(message_id) {
 var form_path = '<?php echo $app_form_path;?>';
 var url = '../../adiha.php.scripts/dev/spa_html.php?message_id=' + message_id + '&pop_up=true';
 var message_model_state = $('#messageModal').css('display');
 var alert_model_state = $('#alertModal').css('display');

 $('#messageModal').css('display', 'none');
 $('#alertModal').css('display', 'none');

 var message_board_window = new dhtmlXWindows();
 message_board_window.attachViewportTo("workspace");

 var win = message_board_window.createWindow('w1', 0, 300, 800, 600);
 win.setText('Message Board Report');
 win.centerOnScreen();
 win.setModal(true);
 win.maximize();
 message_board_window.window("w1").addUserButton("dock", 3, "Undock", "Undock");
 win.attachURL(url);

 win.attachEvent("onClose", function(win){
 $('#messageModal').css('display', message_model_state);
 $('#alertModal').css('display', alert_model_state);
 return true;
 });

 message_board_window.window("w1").button("dock").attachEvent("onClick", function(){
 open_window_with_post(url);
 });
 }
 */
function message_pop_up_drill(message_id, url_or_desc, enable_paging) { 
    if (enable_paging === undefined)  enable_paging = 'n';
    var url = '../../adiha.php.scripts/dev/spa_html.php?message_id=' + message_id + '&pop_up=true&url_or_desc=' + url_or_desc;
    if (enable_paging == 'y') url = url + "&enable_paging=y&np=1";
    open_message_dhtmlx(url, 'drill1')
}

function second_level_drill_1(exec_statement) {
    var exec_statement = exec_statement.replace(/\^/g, "'");
    var url = "../../adiha.php.scripts/dev/spa_html.php?spa=" + exec_statement + '&pop_up=true';
    open_message_dhtmlx(url, 'drill2')
}

function compliance_status_drill(exec_statement) {
    var exec_statement = exec_statement.replace(/\^/g, "'");
    var url = "../../adiha.php.scripts/" + exec_statement + '&pop_up=true';
    open_message_dhtmlx(url, 'drill2')
}

function open_message_dhtmlx(url, window_name) {
    var message_model_state = $('#messageModal').css('display');
    var alert_model_state = $('#alertModal').css('display');

    $('#messageModal').css('display', 'none');
    $('#alertModal').css('display', 'none');

    var message_board_window = new dhtmlXWindows();
    message_board_window.attachViewportTo("workspace");

    var win = message_board_window.createWindow(window_name, 0, 300, 800, 600);
    win.setText('Message Board Report');
    win.centerOnScreen();
    win.setModal(true);
    win.maximize();
    message_board_window.window(window_name).addUserButton("dock", 3, "Undock", "Undock");
    win.attachURL(url);

    win.attachEvent("onClose", function(win){
        $('#messageModal').css('display', message_model_state);
        $('#alertModal').css('display', alert_model_state);
        return true;
    });

    message_board_window.window(window_name).button("dock").attachEvent("onClick", function(){
        open_window_with_post(url);
    });


}
function reset_count() {
    check_uncheck_checkbox(false);
    var pre_message_count = $("#pre_count").html();
    var ref_msg_cnt = $("#post_count").html();
    var diff_message = ref_msg_cnt - pre_message_count;
    setTimeout('reset_count_call_back()', 500)
    $("#pre_count").html(ref_msg_cnt);
}

function reset_count_call_back() {
    $("#message-count").removeClass('count');
    $("#message-count").css('display', 'none');
    $("#message-count").html(0); //$(this).html('0')
    count_current_msg_only = 0;
}

function reset_count_alert() {
    load_message_alert('n');
    check_uncheck_checkbox(false);
    var pre_alert_count_alert = $("#pre_count_alert").html();
    var ref_msg_cnt_alert = $("#post_count_alert").html();
    var diff_alert_alert = ref_msg_cnt_alert - pre_alert_count_alert;
    setTimeout('reset_count_alert_call_back()', 500)
    $("#pre_count_alert").html(ref_msg_cnt_alert);
}

function reset_count_alert_call_back() {
    $("#alert-count").removeClass('count');
    $("#alert-count").html($(this).html('0'));
}

function TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to) {
    get_file_path(func_id);
    $('#messageModal').hide();
    var window_title = '';
    switch (func_id) {
        case 10221013:
            args = "counterparty_id=" + arg1 +
                "&contract_id=" + arg2 +
                "&calc_id=" + arg3 +
                "&source_deal_header_id=" + arg4 +
                "&deal_date_from=" + asofdate +
                "&deal_date_to=" + asofdate +
                "&prod_month=" + asofdate_to +
                "&estimate_calc=n" +
                "&int_ext_flag=" + arg5 +
                "&report_type=" + arg6 +
                "&invoice_type=" + arg7 +
                "&calc_status=" + arg8 +
                "&netting_group_id=" + arg9 +
                "&settlement_date=" + arg10;
            //createWindow("windowGenerateInvoice", false, true, args);
            break;
        case 10131020: // Trade Ticket
            args = "deal_ids=" + arg1 + "&disable_all_buttons=" + arg2 + "&show_button=" + arg3;
            //createWindow("windowTradeTicket", false, true, args)
            break;
        case 10131010: // Maintain Deal Detail
            // if (arg2 == 'n') {
            //check if this deal exists or not.
            //check_deal(arg1);
            //} else {
            //args = "mode=u&source_deal_header_id=" + arg1 + "&deleted_deal=" + arg2;
            args = "deal_id=" + arg1 + "&view_deleted=" + arg2;
            //  open_menu_window("_setup/maintain_static_data/maintain.static.data.php", "windowMaintainStaticData", "Setup Static Data")
            //createWindow("windowMaintainDealDetail", false, true, args);
            //alert(args);
            //}
            window_title = 'Deal Detail - ' + arg1;
            break;
        case 10171016: // Confirm Deal
            args = "source_deal_header_id=" + arg1;
            //createWindow("windowConfirmGenerate", false, true, args)
            break;
        case 10101122: // Credit Info
            args = "counterparty_id=" + arg1;
            break;
        case 10171013: // Deal Confirm History UI
            args = "mode=u&source_deal_header_id=" + arg1 + "&confirm_status_id=" + arg2 + "&call_from=c";
            //createWindow("windowDealConfirmStatusIU", false, true, args)
            break;

        case 10234411: // Auto Matching Hedge Report
            var args = "process_id=" + arg1 + "&sub_id=" + arg2 + "&h_or_i=" + arg3 + "&v_buy_sell=" + arg4 +
                "&str_id=" + arg5 +
                "&book_id=" + arg6 +
                "&as_of_date_from=" + asofdate +
                "&as_of_date_to=" + asofdate_to +
                "&fifo_lifo=" + arg7 +
                "&b_s_match_option=" + arg8 +
                "&v_curve_id=" + arg9 +
                "&call_from="+arg10+
                "&call_for_report=y";

            //createWindow("windowAutoMatchingHedgeReport", false, true, param);
            break;
        case 10234500:
            var args = "&show_approved=" + arg1 +
                "&as_of_date_from=" + asofdate +
                "&as_of_date_to=" + asofdate_to;
            //openViewOutstandingResult('NULL', param);
            break;
        case 10201020:
            //openBatchWindowfromlink(arg1, arg2, arg3, arg4, arg5, arg6, arg7, asofdate);
            break;

        case 10211010:
            var args = "mode=u&contract_id=" + arg1;
            // createWindow("windowMaintainContractGroupDetail", false, true, args);
            break;
        case 10211300:
            var args = "contract_id=" + arg1 + "&contract_name=" + arg2;
            break;
        case 10211200:
            var args = "contract_id=" + arg1 + "&contract_name=" + arg2;
            break;
        case 10211400:
            var args = "contract_id=" + arg1 + "&contract_name=" + arg2;
            break;
        case 10202210: //view report
            $('#file_path').html('_reporting/report_manager_dhx/report.viewer.php');
            var report_name = arg2.split('_');
            $('#window_name').html(report_name[0]);
            $('#window_label').html(report_name[0]);
            var args = 'report_name=' + arg2 + arg1 + '&session_id=' + js_session_id;
            break;
        case 10106100:
            var args = "function_parameter=" + func_id + "&time_series_id=" + arg1 + "&term_start=" + arg2 + "&term_end=" + arg3;
            break;
        case 10131025:
            args = "deal_ids=" + arg1;
        case 10161100:
            args = "call_from=schedule_detail_report&mode=u&path_id=" + arg1;
            break;

        case 10164000:
            var args = "meter_ids=" + arg1 + '&term_start=' + arg2 + '&term_end=' + arg3 + '&call_from=shutin';
            break;
        case 10105800: // Setup Counterparty
            args = "counterparty_id=" + arg1;
            break;
        case 10163710: // Match
            args = arg1;
            break;
        case 10101200: // tree
            args = "tree_id=" + arg1 + '&level_name=' + arg2 + '&tab_name=' + arg3 ;
            break;
        case 10221300: // view invoice.
            args = "calc_id=" + arg1;
            break;
        case 12101700:
            args = "generator_id=" + arg1;
            break;
        case 10106700:
            args = "workflow_activity_id=" + arg1 + '&call_from=' + arg2 ;
            break;
        case 10233700:
            var args = "&link_id=" + arg1;
            break;
        case 10231900:
            args = "relation_id=" + arg1;
            break;
        case 10102600:
            var args = "&source_price_curve_def_id=" + arg1;
            break;

    }

    setTimeout(function() {
        TRMHyperlink_callback(args, window_title);
    }, 500);
}

function TRMHyperlink_callback(args, window_title) {
    var file_path = $('#file_path').html();
    var operator = (file_path.indexOf('?') > 0) ? '&' : '?';// For cases which have function id in file path saved in application_functions
    var window_name = $('#window_name').html();
    var window_label = (window_title != '') ? window_title : $('#window_label').html();

    open_menu_window(file_path + operator + args, window_name, window_label)
}

function show_result() {
    var src = document.getElementById('txt_src').value;

    if (typeof result_window !== 'undefined') {
        result_window.hide();
    }

    result_window = new dhtmlXPopup();

    var window_width = $(window).width();
    var window_height = $(window).height();
    var popup_ht = window_height - 100;
    var popup_wd = window_width - 20;

    result_window.attachHTML('<div id="search_result_popup"><div class="fa  fa-close close clear">&nbsp;</div><br /><iframe style="width:' + popup_wd + 'px;height:'+ popup_ht +'px;" src=' + src + '></iframe></div>');
    $('#search_result_popup .close').click(function(){ result_window.hide();})

    result_window.show(100, 0, 50, 50);
}

function compliance_status_pop_up_drill(message_id) {
    var url = '../../adiha.php.scripts/dev/spa_html_complaince_status_1.1.php?message_id=' + message_id + '&pop_up=true';
    open_message_dhtmlx(url, 'drill1')
}

/**
 * refresh_pinned_report Refresh Pinned reports
 */
function refresh_pinned_report() {
    data = {"action": "spa_pivot_report_view", "flag":"x"};
    adiha_post_data('return_json', data, '', '', 'refresh_pinned_report_callback', 0);
}

/**
 * [refresh_pinned_report_callback Callback for report refresh function]
 * @param  {[type]} result [return array]
 */
function refresh_pinned_report_callback(result) {
    result = JSON.parse(result);
    var group_present = false;
    var items = new Array();
    var group_items = new Array();
    if (result.length > 0) {
        $.each(result, function(i, item) {
            var json_data = '';
            json_data = JSON.parse(item.json);

            if (item.group_id == -1) {
                items.push(generate_report_list(json_data, 0));
                items.push('<li class="divider"></li>');
            } else {
                if (json_data != null && json_data != '') {
                    var ul_data = '';
                    ul_data = '<li class="dropdown-submenu"><a href="#" class="dropdown-toggle" data-toggle="dropdown">' + item.group_name + '</a><ul class="dropdown-menu pull-right nested_list col-xs-12">'
                    ul_data += generate_report_list(json_data, 1)
                    ul_data += '</ul></li>';
                    items.push(ul_data);
                    group_present = true;
                }
                group_items.push('{"id":"'+item.group_id+'","text":"' + item.group_name + '"}');
            }
        });
        if (group_present) {
            items.push('<li class="divider"></li>');
        }
        items.push('<li><a href="#" onclick="open_manage_pinned()">' + get_locale_value('Manage Pinned Reports...') + '</a></li>');
    } else {
        items.push('<li><a href="#">' + get_locale_value('There are no pinned reports.') + '</a></li>');
    }

    items.push('<li class="divider"></li>');
    items.push('<li><a href="#" onclick="open_my_dashboard()">' + get_locale_value('My Dashboard') + '</a></li>');

    $('#pinned_reports li').remove();
    $('#pinned_reports').append(items.join(''));
}


/**
 * [generate_report_list Generate Report List]
 * @param  {[json]} data [json data]
 * @param  {[type]} lg   [list group]
 */
function generate_report_list(data, lg) {
    if (typeof(data) == 'object') {
        var ul = new Array();
        $.each(data, function(i, item) {
            ul.push('<li><a href="#" view_id="' + item.id + '" onclick="open_pinned_pivot_report(&quot;' + item.id + '&quot;)">' + item.name + '</a><span class="pull-right" style="margin-top:-25px;padding-right:10px;cursor:pointer"><i class="fa fa-times" style="color:#A8040A" title="Remove from pinned reports" onclick="remove_from_pinned(' + item.id + ')"></i></span></li>');
        });
        return ul.join('');
    }
}

var manage_pinned_reports;
/**
 * [open_manage_pinned Open Manage Pinned Reports]
 */
function open_manage_pinned() {
    if (manage_pinned_reports != null && manage_pinned_reports.unload != null) {
        manage_pinned_reports.unload();
        manage_pinned_reports = w1 = null;
    }
    if (!manage_pinned_reports) {
        manage_pinned_reports = new dhtmlXWindows();
        manage_pinned_reports.attachViewportTo("workspace");
        var win = manage_pinned_reports.createWindow('w1', 0, 0, 400, 600);
        win.setText("Manage Pinned Reports");
        win.setModal(true);
        win.centerOnScreen();
        win.button("park").hide();
        var url = js_php_path + 'manage.pinned.reports.php';
        win.attachURL(url);
        win.attachEvent("onClose", function(win){
            refresh_pinned_report();
            return true;
        })
    }
}

/**
 * [refresh_favourites Refresh favourites]
 * @return {[type]} [description]
 */
function refresh_favourites(win_obj, result) {
    if(result) {
        if(result[0][3] == "Error"){
            show_messagebox(result[0][4]);
        } else {
            win_obj.button("favourite").show();
            win_obj.button("unfavourite").hide();
        }
    }
    data = {"action": "spa_favourites", "flag":"s"};
    adiha_post_data('return_json', data, '', '', 'favourites_populate', 0);
}

/**
 * [favourites_populate populate favourites]
 * @param  {[type]} result [description]
 * @return {[type]}        [description]
 */
function favourites_populate(result) {
    result = JSON.parse(result);
    var items = new Array();
    var group_items = new Array();
    var group_present = false;
    if (result.length > 0) {
        $.each(result, function(i, item) {
            var json_data = '';
            json_data = JSON.parse(item.json);

            if (item.group_id == -1) {
                items.push(generate_list(json_data, 0));
                items.push('<li class="divider"></li>');
            } else {
                if (json_data != null && json_data != '') {
                    var ul_data = '';
                    ul_data = '<li class="dropdown-submenu"><a href="#" class="dropdown-toggle" data-toggle="dropdown">' + item.group_name + '</a><ul class="dropdown-menu pull-right nested_list col-xs-12">'
                    ul_data += generate_list(json_data, 1)
                    ul_data += '</ul></li>';
                    items.push(ul_data);
                    group_present = true;
                }
                group_items.push('{"id":"'+item.group_id+'","text":"' + item.group_name + '"}');
            }
        });
        if (group_present) {
            items.push('<li class="divider"></li>');
        }
        items.push('<li><a href="#" onclick="open_manage_favourites()">' + get_locale_value('Manage Favorites...') + '</a></li>');
    } else {
        items.push('<li><a href="#">' + get_locale_value('There are no favorites.') + '</a></li>');
    }

    $('#favourite_menu li').remove();
    $('#favourite_menu').append(items.join(''));
    $("#___fav_group___").val('');

    if (group_items.length > 0)
        $("#___fav_group___").val(group_items.join(','));
}


var manage_favourites;
/**
 * [open_manage_favourites Open Manage Favourites]
 */
function open_manage_favourites() {
    collapse_main_menu_navbar();
    
    if (manage_favourites != null && manage_favourites.unload != null) {
        manage_favourites.unload();
        manage_favourites = w1 = null;
    }
    if (!manage_favourites) {
        manage_favourites = new dhtmlXWindows();
        manage_favourites.attachViewportTo("workspace");
        var win = manage_favourites.createWindow('w1', 0, 0, 400, 600);
        win.setText("Manage Favorites");
        win.setModal(true);
        win.centerOnScreen();
        win.button("park").hide();
        var url = js_php_path + 'manage.favourites.php';
        win.attachURL(url);
        win.attachEvent("onClose", function(win){
            refresh_favourites();
            return true;
        })
    }
}

/**
 * [generate_list Generate List]
 * @param  {[json]} data [json data]
 * @param  {[type]} lg   [list group]
 */
function generate_list(data, lg) {
    if (typeof(data) == 'object') {
        var ul = new Array();
        var remove_fav_label = get_locale_value('Remove from Favourite');
        $.each(data, function(i, item) {
            if (item.function_id == 20006300) {
                ul.push('<li><a href="#" onclick="$(\'#myModalTheme\').modal(\'show\')">' + get_locale_value(item.function_name) + '</a><span class="pull-right" style="margin-top:-25px;padding-right:10px;cursor:pointer"><i class="fa fa-times" style="color:#A8040A" title="' + remove_fav_label + '" onclick="remove_from_favourite(' + item.function_id + ')"></i></span></li>');
            } else if (item.function_id == 20006200) {
                ul.push('<li id="' + item.function_id + '" ><a href="#" onclick="open_configuration_manager_auth(&quot;' + item.file_path + '&quot;, &quot;' + item.window_name + '&quot;,&quot;' + item.favourites_menu_name + '&quot;,&quot;' + item.function_id + '&quot;)">' + get_locale_value(item.favourites_menu_name) + '</a><span class="pull-right" style="margin-top:-25px;padding-right:10px;cursor:pointer"><i class="fa fa-times" style="color:#A8040A" title="' + remove_fav_label + '" onclick="remove_from_favourite(' + item.function_id + ')"></i></span></li>');
            } else {
                ul.push('<li id="' + item.function_id + '" ><a href="#" onclick="open_menu_window(&quot;' + item.file_path + '&quot;, &quot;' + item.window_name + '&quot;,&quot;' + item.favourites_menu_name + '&quot;,&quot;' + item.function_id + '&quot;)">' + get_locale_value(item.favourites_menu_name) + '</a><span class="pull-right" style="margin-top:-25px;padding-right:10px;cursor:pointer"><i class="fa fa-times" style="color:#A8040A" title="' + remove_fav_label + '" onclick="remove_from_favourite(' + item.function_id + ')"></i></span></li>');
            }
        });
        return ul.join('');
    }
}
/**
 * [recent_menu_populate Populate recent menu]
 * @param  {[type]} result [description]
 * @return {[type]}        [description]
 */
function recent_menu_populate(result) {
    result = JSON.parse(result);
    var items = new Array();
    if (result.length > 0) {
        $.each(result, function(i, item) {
            if (item.function_id == 20006300) {
                items.push('<li><a href="#" onclick="$(\'#myModalTheme\').modal(\'show\')">' + get_locale_value(item.function_name) + '</a></li>');
            } else if (item.function_id == 20006200) {
                items.push('<li><a href="#" onclick="open_configuration_manager_auth(&quot;' + item.file_path + '&quot;, &quot;' + item.window_name + '&quot;,&quot;' + item.function_name + '&quot;,&quot;' + item.function_id + '&quot;)">' + get_locale_value(item.function_name) + '</a></li>');
            } else {
                items.push('<li><a href="#" onclick="open_menu_window(&quot;' + item.file_path + '&quot;, &quot;' + item.window_name + '&quot;,&quot;' + item.function_name + '&quot;,&quot;' + item.function_id + '&quot;)">' + get_locale_value(item.function_name) + '</a></li>');
            }
        });
    } else {
        items.push('<li><a href="#">' + get_locale_value('There are no recent items.') + '</a></li>');
    }
    $('#recent_menu li').remove();
    $('#recent_menu').append(items.join(''));
}

function close_forward_box() {
    $('#forwardMessageModal').removeClass( "in" );
}

function counter_click(type) {
    //reset_counter(type);
    load_message_alert('n',type);
}


function reset_counter(type,cnt) {
    if (type == 'alert') {
        if (typeof cnt !== 'undefined') {
            //cnt is total remaining alerts after deletion.
            $("#post_count_alert").html(cnt);
        }

        var ref_alert_cnt = $("#post_count_alert").html();
        $("#pre_count_alert").html(ref_alert_cnt);
        $("#alert-count").removeClass('count');
        $("#alert-count").css('display', 'none');
        $("#alert-count").html(0); //$(this).html('0')
        count_current_alert_only = 0;
    } else {
        if (typeof cnt !== 'undefined') {
            //cnt is total remaining messages after deletion.
            $("#post_count").html(cnt);
        }

        var ref_msg_cnt = $("#post_count").html();
        $("#pre_count").html(ref_msg_cnt);
        $("#message-count").removeClass('count');
        $("#message-count").css('display', 'none');
        $("#message-count").html(0); //$(this).html('0')
        count_current_msg_only = 0;
    }
}

function load_message_alert(flag,type) {
    $.ajax({
        type: "POST",
        dataType: "text",
        url: "message_board.php",
        success: function(data) {
            var divs = $(data).filter(function(){ return $(this).is('div') });

            divs.each(function() {
                if ($(this).hasClass("alerts")) {
                    $("#alerts").html($(this).html());
                } else if($(this).hasClass("messages")) {
                    $("#messages").html($(this).html());
                }
            });
            $('.nano-message-box').nanoScroller({
                alwaysVisible: true,
                preventPageScrolling: true,
                contentClass: 'message-board-content'
            });
        }
    });
}

function updateMessageNumber(className,num) {
    $('#'+className).html(num);
}

function open_reminder_window_from_parent() {
    open_reminder_window();
}

function open_setup_application_theme() {
    $('#myModalTheme').modal('show');
    var data = {"action": "spa_my_application_log", "flag":"i", "function_id":20006300, "product_category":product_id};
    adiha_post_data("return_val", data, '', '', 'refresh_recent_menu');
}