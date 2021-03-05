/**
 * Success call function - Notify about the error/success of event
 * 
 * @param   {String}    message         Message
 * @param   {Boolean}   error_status    Error status
 */
function success_call(message, error_status) {
    if (error_status == undefined) error_status = 'success';

    var expire_time = (error_status == 'error') ? 5000 : 1000;
    var type = 'custom_css_' + error_status

    dhtmlx.message({
        text: get_locale_value(message),
        expire: expire_time,
        type: type // 'customCss' - css class
    });
}

/**
 * Show message box
 * 
 * @param   {String}    message     Error message
 * @param   {Function}  callback    Callback function
 */
function show_messagebox(message, callback) {
    dhtmlx.message({
        title: get_locale_value("Alert"),
        type: "alert",
        ok: get_locale_value("Ok"),
        text: get_locale_value(message),
        callback: function(result) {
            if (result && callback != undefined) {
                callback();
            }
        }
    });
}

/***************** for confirm box ********************/
var process = {} // use your own namespace

/**
 * Use namespace to create confirm box.
 * 
 * @param   {String}    message         To show the error message
 * @param   {Function}  call_back       Callback function
 * @param   {Function}  cancel_callback Cancel click callback function
 */
process.confirm = function(message, call_back, cancel_callback) {
    dhtmlx.message({
        type: "confirm",
        title: get_locale_value("Confirmation"),
        ok: get_locale_value("Confirm"),
        cancel: get_locale_value('Cancel'),
        text: get_locale_value(message),
        callback: function(result) {
            if (result) {
                call_back();
            } else if (cancel_callback != undefined) {
                cancel_callback();
            }
        }
    });
}
/****************** for confirm box ****************/

/**
 * To show confirm message

 * @param   {String}    messsage        To show the error message
 * @param   {Function}  call_back       Call back
 * @param   {Function}  cancel_callback Cancel click callback function
 */
function confirm_messagebox(message, call_back, cancel_callback) {
    process.confirm(message, function() {
        call_back();
    }, function() {
        if (cancel_callback != undefined) {
            cancel_callback();
        }
    });
}

/**
 * Open batch window
 * 
 * @param   {String}    exec_call   Execute sp
 * @param   {String}    param       Additional parameter passed in url
 * @param   {String}    title       Title
 */
function adiha_run_batch_process(exec_call, param, title) {
    batch_window = new dhtmlXWindows();
    var src = js_php_path + 'components/lib/adiha_dhtmlx/adiha_batch_process_3.0/adiha_batch_process_3.0.php?' + param;

    batch_win = batch_window.createWindow('w1', 10, 10, 830, 500);
    batch_win.setText(title);
    batch_win.addUserButton("reload", 0, "Reload", "Reload");
    batch_win.addUserButton("undock", 0, "Undock", "Undock");

    batch_win.button("reload").attachEvent("onClick", function(){
        batch_win.attachURL(src, false, true);
    });

    batch_win.button("undock").attachEvent("onClick", function(){
        open_window(src);
    });

    batch_win.attachURL(src, false, {exec_call: exec_call});
}

/**
 * Create message box using new ajax
 * 
 * @param   {String}    type    Type
*                               alert:          To show the messages as alert<br>
 *                              return_array:   Doesnt show messages as alert and returns Record set[associative array]<br>
 *                              return_json:    Doesnt show messages as alert and returns Record set in json format<br>
 *                              confirm:        The process is carried out after confimation and after process is carried out messages is shown as alert.
 * @param   {String}    data    Data in the following format:
                                <code>
                                    data = {
                                        "action": "spa_source_contract_detail",
                                        "flag": mode,
                                        "source_contract_id": source_contract_id,
                                        "source_system_id": "NULL",
                                        "contract_name": contract_name,
                                        "contract_desc": contract_desc,
                                        "is_active": active,
                                        "standard_contract": standard_contract,
                                        "session_id": session
                                    }
                                </code>
 * @param   {String}    success_message         Message to be dislayed after sucess of event.
 * @param   {String}    error_message           Messsage to be displayed on error occurance.
 * @param   {String}    success_callback        Success callback function with result
 * @param   {Boolean}   asynchonous_status      Status to disable asynchronous ajax,true by default.
 * @param   {String}    error_callback error    Callback function with result
 */
function adiha_post_data(type, data, success_messsage, error_message, success_callback, asynchonous_status, custom_message) {
    var callback_function = success_callback;
    var msg = get_locale_value(custom_message);
    var continue_process = (type == 'confirm' || type == 'confirm-warning') ? 'n' : 'y';

    if (type == 'confirm') {
        if (custom_message == '' || custom_message == undefined) {
            msg = get_locale_value("Are you sure you want to delete?");
        }

        dhtmlx.message({
            type: "confirm",
            title: get_locale_value("Confirmation"),
            text: msg,
            ok: get_locale_value("Confirm"),
            cancel: get_locale_value('Cancel'),
            callback: function(result) {
                if (result)
                    adiha_post_data('alert', data, success_messsage, error_message, success_callback, asynchonous_status, custom_message)
            }
        });
    } else if (type == 'confirm-warning') {
        dhtmlx.message({
            type: "confirm-warning",
            title: get_locale_value("Warning"),
            text: msg,
            ok: get_locale_value("Confirm"),
            cancel: get_locale_value('Cancel'),
            callback: function(result) {
                if (result == true)
                    adiha_post_data('alert', data, success_messsage, error_message, success_callback, asynchonous_status, custom_message)
            }
        });
    } else if (type == 'alert-error') {
        show_messagebox(msg);
    }

    if (continue_process == 'y') {
        var additional_data = {
            "type": type
        };

        if (asynchonous_status == 0) asynchonous_status = false;
        else if (asynchonous_status == undefined || asynchonous_status == '') asynchonous_status = true;

        data = $.param(data) + "&" + $.param(additional_data);

        $.ajax({
            type: "POST",
            dataType: "json",
            url: js_form_process_url,
            async: asynchonous_status,
            data: data,
            success: function(data) {
                // Check session is expired
                if (data.hasOwnProperty("session_expired_url")) {
                    pop_session_expire(data["session_expired_url"], data["session_expired_message"]);
                    return;
                }

                response_data = data["json"];

                if (type == 'return_json') {
                    response_data = JSON.stringify(response_data);
                } else if (type == 'alert') {
                    if (response_data[0].errorcode == 'Success') {
                        if (success_messsage == '' || typeof (success_messsage) == 'undefined') {
                            success_messsage = response_data[0].message;
                        }

                        success_call(success_messsage);
                    } else {
                        if (error_message == '' || typeof (error_message) == 'undefined') {
                            error_message = response_data[0].message;
                        }
                        
                        show_messagebox(error_message);
                    }
                }

                if (callback_function != '') {
                    if(typeof(callback_function) == "function")
                        callback_function(response_data);
                    else
                        eval(callback_function + '(response_data)');
                }
            }
        });
    }
}

/**
 * Open browse popup.
 * @param  {Number}    id                      ID
 * @param  {String}     form                    Form name
 * @param  {Number}     function_id             Function id
 * @param  {String}     callback_function       Call back function
 * @param  {Boolean}    allow_sub_book_check    Allow sub book check
 * @param  {String}     args                    Argument
 */
function open_browse_popup(id, form, function_id, callback_function, allow_sub_book_check, args) {
    var post_json_params = true;
    eval('var my_form = ' + form + '.getForm()');
    var grid_name = my_form.getUserData(id.replace("label_", ""),'grid_name');
    var grid_label = my_form.getUserData(id.replace("label_", ""),'grid_label');
    var application_field_id = my_form.getUserData(id.replace("label_", ""),'application_field_id');
    browse_window = new dhtmlXWindows();
    if (grid_name == 'formula') {   //To Browse the formula editor
        var formula_id = my_form.getItemValue(id.replace("label_", ""));
        if (formula_id == '') { formula_id = 'NULL'; }
        var src = js_php_path + 'adiha.html.forms/_setup/formula_builder/formula.editor.php?formula_id=' + formula_id + '&call_from=others&form_name=' + form + '&browse_name=' + id + '&is_browse=y';
        var src = src.replace("adiha.php.scripts/", "");
        new_browse = browse_window.createWindow('w1', 0, 0, 900, 530);


        new_browse.attachEvent('onClose', function() {
            if (callback_function != '') {
                if(typeof(callback_function) == "function")
                    callback_function();
                else
                    eval(callback_function + '()');
            }
            return true;
        })

    } else if (grid_name == 'report_filter') {   //To Browse the Report filters
        var filter_parameters = my_form.getItemValue(id.replace("label_", ""));
        filter_parameters = (filter_parameters == '') ? 'NULL' : filter_parameters

        // var report_param_id = 29060;
        var report_param_id = my_form.getItemValue('paramset_id');
        // var report_id = 26867;
        var report_id = my_form.getItemValue('report_id');
        var regg_module_header_id = my_form.getCombo('regression_module_header_id').getSelectedValue();
        // var report_name = my_form.getItemValue();
        post_json_params = {
            "active_object_id": report_param_id,
            "report_type": 1,
            "report_id": report_id,
            "regg_module_header_id": regg_module_header_id,
            "report_param_id": report_param_id,
            "call_from": "regression_testing",
            "filter_parameters": filter_parameters
        };

        var src = app_form_path + '_reporting/regression_testing/regression.filter.php';
        new_browse = browse_window.createWindow('w1', 0, 0, 900, 530);
        new_browse.attachEvent('onClose', function() {
            if (callback_function != '') {
                if(typeof(callback_function) == "function")
                    callback_function();
                else
                    eval(callback_function + '()');
            }
            return true;
        });

    } else if (grid_name == 'deal_filter') {   //To Browse the deal page
        new_browse = browse_window.createWindow({
            id: 'w1'
            ,width: 900
            ,height: 530
            ,resize: true
        });
        post_json_params = {
            read_only : true,
            deal_select_completed : callback_function,
            call_from : 'deal_filter',
            trans_type : 'NULL',
            form_obj : form,
            browse_id : id
        }
        //var params = {read_only:true,col_list:'deal_id,id,deal_date,term_start,term_end,location_index,Template,currency,deal_type,deal_volume,deal_volume_uom_id',deal_select_completed:''};
        var src = js_php_path + 'adiha.html.forms/_deal_capture/maintain_deals/maintain.deals.new.php?form_name=' + form;
        var src = src.replace("adiha.php.scripts/", "");

    } else if (grid_name == 'browse_view_shipment') {   //To Browse the View Shipment page
        new_browse = browse_window.createWindow({
            id: 'w1'
            ,width: 900
            ,height: 530
            ,resize: true
        });
        post_json_params = {
            read_only : true,
            select_completed : callback_function,
            call_from : 'actualize_schedule',
            trans_type : 'NULL',
            form_obj : form,
            browse_id : id
        }
        //var params = {read_only:true,col_list:'deal_id,id,deal_date,term_start,term_end,location_index,Template,currency,deal_type,deal_volume,deal_volume_uom_id',deal_select_completed:''};
        var src = js_php_path + 'adiha.html.forms/_scheduling_delivery/scheduling_workbench/view.scheduling.workbench.php?form_name=' + form + '&parent_function_id=' + function_id;
        var src = src.replace("adiha.php.scripts/", "");
    } else if (grid_name == 'existing_formula') {
        var src = js_php_path + 'adiha.html.forms/_setup/formula_builder/formula.existing.php';
        var src = src.replace("adiha.php.scripts/", "");
        new_browse = browse_window.createWindow('w1', 0, 0, 500, 450);
    } else if (grid_name == 'deal_search') {
        form = encodeURIComponent(form);
        var src = js_php_path + 'adiha.php.scripts/spa_deal_search.php?form_name=' + form + '&browse_name=' + id;
        var src = src.replace("adiha.php.scripts/", "");
        new_browse = browse_window.createWindow('w1', 50, 165, 500, 400);
    } else if (grid_name == 'sub_book_mapping') {
        var params = '';
        var is_exist = my_form.isItem("subsidiary_id");

        if (is_exist) {
            params += ((params != '') ? '&' : '') + "subsidiary_id=" + my_form.getItemValue("subsidiary_id");
        } else if (my_form.isItem("sub_id")) {
            params += ((params != '') ? '&' : '') + "subsidiary_id=" + my_form.getItemValue("sub_id");
        }

        /*
         *Removed the block of code to show Sub Book MApping of all type i.e of type Hedge and Item both.
         *Due to change of logic to control this from deal level transaction type, this change needs to be done.
         if (my_form.isItem("hedge_or_item")) params += ((params != '') ? '&' : '') + "hedge_or_item=" + my_form.getItemValue("hedge_or_item");
        */


        var src = js_php_path + 'adiha.html.forms/_accounting/derivative/sub_book_mapping.php?' + params+ '&callback_function=' + callback_function;
        var src = src.replace("adiha.php.scripts/", "");
        new_browse = browse_window.createWindow('w1', 0, 0, 550, 500);
    }else if (grid_name == 'book'){
        form = encodeURIComponent(form);
        var src = js_php_path + 'components/lib/adiha_dhtmlx/generic.browser.php?form_name=' + form + '&browse_name=' + id + '&grid_name=' + grid_name + '&grid_label=' + grid_label + '&function_id=' + function_id + '&callback_function=' + callback_function + '&allow_sub_book_check=' + allow_sub_book_check;
        new_browse = browse_window.createWindow('w1', 0, 0, 550, 400);
    } else if (grid_name == 'source_group') {
        form = encodeURIComponent(form);
        var src = js_php_path + '../adiha.html.forms/_models_and_activity/setup_renewable_source/source.group.php?form_name=' + form + '&browse_name=' + id + '&grid_name=' + grid_name + '&grid_label=' + grid_label + '&function_id=' + function_id + '&callback_function=' + callback_function;
        new_browse = browse_window.createWindow('Source Group', 0, 0, 500, 500);

    } else { //For Generic Browser
        form = encodeURIComponent(form);
        var src = js_php_path + 'components/lib/adiha_dhtmlx/generic.browser.php?form_name=' + form + '&browse_name=' + id + '&grid_name=' + grid_name +'&application_field_id=' + application_field_id +  '&grid_label=' + grid_label + '&function_id=' + function_id + '&callback_function=' + callback_function+ '&' + args;

        new_browse = browse_window.createWindow('w1', 0, 0, 500, 400);
    }

    if (grid_name == 'source_group')
        new_browse.setText("Source Group");
    else
        new_browse.setText("Browse");

    if(grid_name == 'deal_filter' || grid_name == 'browse_view_shipment') {
        new_browse.maximize();
    } else {
        new_browse.centerOnScreen();
    }
    new_browse.setModal(true);
    new_browse.attachURL(src, false, post_json_params);
}

/**
 * Clear Browse
 * 
 * @param   {String}    id      Field id
 * @param   {String}    form    Form name
 */
function clear_browse(id, form) {
    var grid_name = form.getUserData(id.replace("clear_", ""),'grid_name');

    var browse_input = id.replace("clear_", "");
    form.setItemValue(browse_input, '');

    if (grid_name == 'book') {
        form.setItemValue("subsidiary_id", "");
        form.setItemValue("strategy_id", "");
        form.setItemValue("book_id", "");
        form.setItemValue("subbook_id", "");
        form.clearNote("book_structure");
    } else {
        form.setItemValue(id.replace("clear_", "label_"), "");
        form.clearNote(id.replace("clear_", "label_"));
    }
}

/**
 * Attach browse event
 * 
 * @param   {String}        form_name           Form name
 * @param   {Number}        function_id         Function id
 * @param   {Function}      callback_function   Call back function
 */
function attach_browse_event(form_name, function_id, callback_function, allow_sub_book_check, args) {
    if (typeof(callback_function) == 'undefined') callback_function = '';
    eval("var my_form = " + form_name + ".getForm()");
    my_form.attachEvent("onButtonClick", function(name){
        var button_type = name.split("_");
        if (button_type[0] == "clear") {
            clear_browse(name, my_form);
        }
    });

    my_form.forEachItem(function(name){
        if (name == 'book_structure' || name.indexOf("label_") > -1) {
            var browser_inputs = my_form.getInput(name);

            var Node = browser_inputs.parentNode.parentNode.parentNode.parentNode;
            // Node.style.height = "45px";
            browser_inputs.style.cursor = "pointer";

            Node.ondblclick = function() {
                if (!my_form.isItemEnabled(name)) { //Code added to handle browser click event on disabled item
                    return;
                }

                if (my_form.isItemHidden(name)) return; // do not open window, if field is hidden

                open_browse_popup(name, form_name, function_id, callback_function, allow_sub_book_check, args);
                var selection = window.getSelection ? window.getSelection() : document.selection ? document.selection : null;
                if(!!selection) selection.empty ? selection.empty() : selection.removeAllRanges();
            }

            Node.onmouseover = function() {
                var value = my_form.getItemValue(name);

                if (name == 'book_structure')
                    clear_name = 'clear_' + name;
                else
                    clear_name = name.replace('label_','clear_');

                Node.title=unescapeXML(value);

                if (value != '')
                    my_form.showItem(clear_name);
            }

            Node.onmouseout = function() {
                if (name == 'book_structure')
                    clear_name = 'clear_' + name;
                else
                    clear_name = name.replace('label_','clear_');

                my_form.hideItem(clear_name);
            }
        }
    });
}

/*
Added a prototype which gives the child nodes of the xml object which is not empty.
This is added because the xml object generated by the DOMParser generates the empty/blank 
nodes also which gives error while counting the number of rows and columsns.
*/
if (!DOMParser.prototype.childNodesClean) {
    DOMParser.prototype.childNodesClean = function() {
        var xdoc = this;
        var childNodesWithoutEmpty = [];

        for (var cnt = 0; cnt < xdoc.childNodes.length; cnt++) {
            if (xdoc.childNodes[cnt].nodeType != 1)
                childNodesWithoutEmpty.push(xdoc.childNodes[cnt]);
        }
        return childNodesWithoutEmpty;
    };
}

if (!Element.prototype.childNodesClean) {
    Element.prototype.childNodesClean = function() {
        var xdoc = this;
        var childNodesWithoutEmpty = [];

        for (var cnt = 0; cnt < xdoc.childNodes.length; cnt++) {
            if (xdoc.childNodes[cnt].nodeType == 1)
                childNodesWithoutEmpty.push(xdoc.childNodes[cnt]);
        }
        return childNodesWithoutEmpty;
    };
}

/**
 * Form validation event - Shows valid form validation message below the form objects
 * 
 * @param   {Object}    form_obj    Form object
 * @param   {Object}    tab_obj     Tab object
 * 
 * @return  {Boolean}               Form validation status
 */
function validate_form(form_obj, tab_obj) {
    var form_status = false;
    var combo_status = true;

    form_obj.attachEvent("onBeforeValidate", function (id){
        var data = form_obj.getFormData();
        for (var a in data) {
            if(form_obj.getItemType(a) == 'combo') {
                if(data[a] != '') {
                    var dhxCombo = form_obj.getCombo(a);
                    var selected_option = dhxCombo.getSelectedValue(data[a]);

                    if(selected_option == null && dhxCombo.conf.opts_type != 'custom_checkbox' && dhxCombo.conf.opts_type != 'checkbox' && a != 'apply_filters') {
                        combo_status = false;
                        var message = form_obj.getUserData(a,"validation_message");
                        form_obj.setNote(a, {text:message,width:100});
                        form_obj.setValidateCss(a, false);
                        form_obj.attachEvent("onChange", function(a, value){
                                form_obj.clearNote(a);
                                form_obj.setValidateCss(a, true);
                            }
                        );
                    }
                }
            }
        }
    });

    form_obj.attachEvent("onAfterValidate", function (status){
        if (combo_status == true && status == true) {
            form_status = status;
        }
    });

    form_obj.attachEvent("onValidateError", function(name,value,res){
        var message = form_obj.getUserData(name,"validation_message");
        form_obj.setNote(name, {text:message,width:200});
        form_obj.attachEvent("onChange",
            function(name, value){
                form_obj.clearNote(name);
            }
        );
    });

    form_obj.attachEvent("onValidateSuccess", function(name,value,res){
        if (combo_status == true) {
            form_obj.clearNote(name);
        }
    });

    form_obj.validate();
    /*if(!form_status) {
       alert("3");
       if (tab_obj != undefined && tab_obj != 'undefined' && tab_obj != '') {
           generate_error_message();
           tab_obj.setActive();
       };
   }*/
    return form_status;
}

/**
 * Form Validation function for NotEmptywithSpace - Returns false if the validation fails.
 * 
 * @param   {Array}     data    Data of input field
 * 
 * @return  {Boolean}           Validation status
 */
function NotEmptywithSpace(data) {
    data = data.toString();
    data  = data.replace(/^\s+|\s+$/gm, '');

    return data != "";
}

/**
 * Added a prototype which compares two string and returns error if str1 exists in str2
 * 
 * @param   {String}    str1        First String value
 * @param   {String}    str2        Second String value
 * @param   {String}    errMsg      Error message
 * 
 * @return  {Boolean}               Error message.
 */
function compareStr(str1, str2, errMsg) {
    var mystring = str1.toLowerCase();
    var findme = str2.toLowerCase();
    var pos = mystring.search(findme);

    if (pos >= 0) {
        show_messagebox(errMsg);
        return false;
    } else {
        return true;
    }
}

/**
 * Escapes an XML special characters < , > , & , '," - Ordering is important here, 
 * make sure & is escaped first, otherwise, & of & lt; will be & amp; lt; which is not desirable
 * 
 * @param   {String}    xmlStr      XML String
 * 
 * @return  {String}                Formatted String
 */
function escapeXML(xmlStr) {
    return xmlStr.replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/'/g, "&#039;")
        .replace(/"/g, "&quot;");
}

/**
 * UnEscapes an escaped XML special characters < , > , & , '," - Ordering is important here, 
 * make sure & is escaped first, otherwise, & of & lt; will be & amp; lt; which is not desirable.
 * 
 * @param   {String}    str     Escaped XML String
 * @return  {String}            Formatted String.
 */
function unescapeXML(str) {
    return str.replace(/&amp;/g, "&")
        .replace(/&lt;/g, "<")
        .replace(/&gt;/g, ">")
        .replace(/&#039;/g, "'")
        .replace(/&quot;/g, "\"")
        .replace(/&add;/g, "+");
}
/**
 * Create the filter form
 * @param   filter_form_obj Form object where filter form should be loaded
 * @param   layout_cell_obj Layout cell of the form whose filter data need to be saved (Now Supports Array of Layout Cell Objects.)
 * @param   app_report_id   Application id or report id of the report
 * @param   report_type     1 for report manager report, 2 for standard report
 * @param   portfolio_hierarchy_obj  Form name space where portfolio hierarchy is attached.
 */
a = [];

var filter_form_object;

/**
 * Create the filter form
 * 
 * @param   {Object}    filter_form_obj             Form object where filter form should be loaded
 * @param   {Object}    layout_cell_obj             Layout cell of the form whose filter data need to be saved
 * @param   {Object}    app_report_id               Application id or report id of the report
 * @param   {Number}    report_type                 Report type:
 *                                                      1: Report manager report
 *                                                      2: Standard report
 * @param   {Object}    portfolio_hierarchy_obj     Form name space where portfolio hierarchy is attached
 * 
 * @return  {Object}                                Filter form object
 */
function load_form_filter(filter_form_obj, layout_cell_obj, app_report_id, report_type, dependent_combos, portfolio_hierarchy_obj, callback_function, attach_on) {

    if (attach_on === undefined) {
        attach_on = 'form';
    }

    var offsetTop1 = "28";
    var position = "label-top";

    if (attach_on == 'layout') {
        offsetTop1 = "28";
        position = "label-left";

        var filter_icon = js_image_path + 'dhxmenu_web/filter_open.png';
        var filter_close_icon = js_image_path + 'dhxtoolbar_web/close.gif';
        var layout_header = '';
        if (typeof layout_cell_obj.length == 'undefined') {
            layout_cell_obj = Array(layout_cell_obj);
        }
        layout_header = layout_cell_obj[0];
        var filter_id = "__filter_" + layout_header.getId() + "__";
        var filter_close_label = get_locale_value('Close Filter');
        var filter_open_label = get_locale_value('Open Filter');
        apply_filter_html="<div class=\"dhxform_base __custom_header__ __filter__\" style=\"float:right; display:block; padding-top: 2px;\"><img src=\"" + filter_icon + "\" alt=\"" + filter_open_label + "\" title=\"" + filter_open_label + "\" ></div><div class=\"__filter_label__\" style=\"float:right; padding-right:5px\"></div><div id=\"" + filter_id + "\" style=\"float:right;  background-color:#f4f4f4;padding-left: 60px; display:none; margin-top:-6px;\" class=\"form_div123\"><div class=\"dhxform_base __custom_header__ __filter_close__\" style=\"float:left; position:relative; top: 6px; right: 20px; width:0px; display:none; z-index:9999\"><img src=\"" + filter_close_icon + "\" title=\"" + filter_close_label + "\" ></div></div >"
        apply_filter_html += layout_header.getText();
        layout_header.setText(apply_filter_html);
        filter_form_obj = new dhtmlXForm(filter_id,'');
        
        $('#' +  filter_id).addClass('__form_div__');
        $('.__form_div__').css({ transform: 'scale(.9)',  '-moz-transform': 'scale(.9)'});
        $('.__filter__').css({ transform: 'scale(.9)' ,  '-moz-transform': 'scale(.9)'});
        $('.__filter_close__').css({ transform: 'scale(.9)' ,  '-moz-transform': 'scale(.9)'});

        $( ".__filter__" ).click(function() {
            if (layout_header.isCollapsed()) {
                layout_header.expand();
            }

            var cmb_obj = filter_form_obj.getCombo('apply_filters');
            $('.__form_div__').toggle();
            $('.__form_div__').focus();
            $('.__filter__').hide();
            $('.__filter_label__').hide();
        });

        $(".__filter_label__" ).dblclick(function() {
            if (layout_header.isCollapsed()) {
                layout_header.expand();
            }

            var cmb_obj = filter_form_obj.getCombo('apply_filters');
            $('.__form_div__').toggle();
            $('.__form_div__').focus();
            $('.__filter__').hide();
            $('.__filter_label__').hide();
        });

        $( ".__form_div__" ).hover(function() {
            $('.__filter_close__').css('display', 'inline-block');
        },function(){
            $('.__filter_close__').hide();
        });

        $( ".__filter_close__" ).click(function() {
            var cmb_obj = filter_form_obj.getCombo('apply_filters');
            var selected_filter= cmb_obj.getComboText();
            $('.__form_div__').hide();
            $('.__filter__').show();
            $('.__filter_label__').show();
            if (selected_filter != '') $('.__filter_label__').text(get_locale_value('Filter: ') + selected_filter );
        });
    }

    var filter_form_json = [
                                {"type":"settings","position":position},
                                {type: "block", blockOffset: ui_settings['block_offset'], list: [
                                    {"type":"combo","name":"apply_filters","label":get_locale_value("Apply Filters"),"validate":"ValidInteger","hidden":"false","disabled":"false","value":"","userdata":{"application_field_id":7036,"validation_message":"Please enter Valid Number"},"position":position,"offsetLeft":ui_settings['offset_left'],"labelWidth":"auto","inputWidth":ui_settings['field_size'],"tooltip":get_locale_value("Apply Filters"),"required":"false","filtering":"true",
                                        "options":[{"value":"","text":"","selected":"true"}], "filtering_mode": "between"
                                    },
                                    {"type":"newcolumn"},
                                    {type: "button", name: "btn_filter_save", value: "", tooltip: get_locale_value("Save Filter"), className: "filter_save",offsetTop:"28"},
                                    {"type":"newcolumn"},
                                    {type: "button", name: "btn_filter_delete", value: "", tooltip: get_locale_value("Delete Filter"), className: "filter_delete",offsetTop:"28"},
                                    {"type":"newcolumn"},
                                    {type: "button", name: "btn_filter_clear", value: "", tooltip: get_locale_value("Clear Filter"), className: "filter_clear",offsetTop:"28"},
                                    {"type":"newcolumn"},
                                    {type: "button", name: "btn_filter_publish", value: "", tooltip: get_locale_value("Publish Filter"), className: "filter_publish",offsetTop:"28"}
                                ]}
                            ];
    
    
    filter_form_obj.load(filter_form_json, load_form_filter_combo(filter_form_obj, app_report_id, report_type,''));

    if (attach_on == 'layout') {
        $("div > div", ".__form_div__").not(".dhxcombo_select_img").attr('style', 'background-color: #f4f4f4 !important;');

        $('.__form_div__').find('.dhxform_btn').css({"padding-top":"5px"});

    }
    filter_form_obj.attachEvent("onButtonClick", function(name){
        if(name == 'btn_filter_save') {
            var filter_name = filter_form_obj.getItemValue('apply_filters');
            if (filter_name == '') {
                show_messagebox('Filter name cannot be empty.');
                return;
            }

            save_form_filter(filter_form_obj, layout_cell_obj, app_report_id, report_type, portfolio_hierarchy_obj);
        } else if (name == 'btn_filter_delete') {
            delete_form_filter(filter_form_obj, app_report_id, report_type);
        } else if (name == 'btn_filter_clear') {
            clear_filter_form(filter_form_obj, layout_cell_obj, app_report_id);
        } else if (name == 'btn_filter_publish') {
            var filter_cmb = filter_form_obj.getCombo('apply_filters');
            var filter_id = filter_cmb.getSelectedValue();
            if (filter_id == -1 || filter_id == null) {
                show_messagebox('Please select the filter.');
                return;
            }
            var filter_name = filter_form_obj.getItemValue('apply_filters');
            if (filter_name == '') {
                show_messagebox('Filter name cannot be empty.');
                return;
            }
            var filter_text = filter_cmb.getSelectedText();
            var doc_window = new dhtmlXWindows();
            win_doc = doc_window.createWindow('w1', 0, 0, 800, 350);
            win_doc.setText("Publish Apply Filter");
            win_doc.centerOnScreen();
            win_doc.setModal(true);
            win_doc.attachURL(js_php_path + "components/lib/adiha_dhtmlx/apply.filter.publish.php?filter_id=" + filter_id +"&filter_text="+filter_text+"&function_id="+app_report_id + "&report_type=" + report_type);

            // filter_form_object is set as global variable inorder to pass the object to another page apply.filter.publish.php
            filter_form_object = filter_form_obj;
        }
    });

    filter_form_obj.attachEvent("onChange", function (name, value){
        if(name == 'apply_filters') {
            if (attach_on == 'layout') {
                var cmb_obj = filter_form_obj.getCombo('apply_filters');
                var selected_filter = cmb_obj.getComboText();
                if(selected_filter != '') $('.__filter_label__').text(get_locale_value('Filter: ') + '"' + selected_filter + '"');
            }
            apply_filter_change(filter_form_obj, layout_cell_obj, app_report_id, report_type, portfolio_hierarchy_obj, callback_function);
        }
    });

    a[app_report_id] = [];

    // Added logic to make single object as an array.
    if (typeof layout_cell_obj.length == 'undefined') {
        layout_cell_obj = Array(layout_cell_obj);
    }
    // Looping through Layout cell objects provided.
    layout_cell_obj.forEach(function(ind_layout_cell_obj, ind) {
        var att_obj = ind_layout_cell_obj.getAttachedObject();
        if (att_obj != undefined) {
            if (Object.getPrototypeOf(att_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm') {
                a[app_report_id][ind] = att_obj.saveBackup();
            } else if (att_obj instanceof dhtmlXTabBar || Object.getPrototypeOf(att_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXCellTop') {
                att_obj.forEachTab(function(tab){
                    var form_obj = tab.getAttachedObject();
                    var tab_id = tab.getId() + '' + ind;
                    if (Object.getPrototypeOf(form_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm'){
                        a[app_report_id][tab_id] = form_obj.saveBackup();
                    } else if (form_obj instanceof dhtmlXLayoutObject){//added if attached object contains layout instead of form
                        form_obj.forEachItem(function(cell){
                            var cell_obj = cell.getAttachedObject();
                            var new_id_with_cell_id = tab_id + '' + cell.getId();
                            if (cell_obj instanceof dhtmlXForm) {
                                a[app_report_id][new_id_with_cell_id] = cell_obj.saveBackup();
                            }
                        });
                    }
                });
            }
        }
    });


    return filter_form_obj;
}


/**
 * Saves the filter data.
 * 
 * @param   {object}    filter_form_obj             Form object where filter form should be loaded
 * @param   {object}    layout_cell_obj             Layout cell of the form whose filter data need to be saved
 * @param   {Number}    id                          Application id or report id of the report
 * @param   {Number}    report_type                 Report type:
 *                                                      1: Report manager report
 *                                                      2: standard report
 * @param   {object}    portfolio_hierarchy_obj     Portfolio hierarchy object
 */
function save_form_filter(filter_form_obj, layout_cell_obj, id, report_type, portfolio_hierarchy_obj) {
    var combo_obj = filter_form_obj.getCombo('apply_filters');
    var filter_name = combo_obj.getComboText();
	var filter_id = combo_obj.getSelectedValue();
	
	if (filter_id == -1) {
		success_call('No changes can be made to default filter.');
		return;
	}
    
    if (filter_name == 'DEFAULT') {
		success_call('Default name cannot be used.');
		return;
	}

    /*
    if(typeof(portfolio_hierarchy_obj) != "undefined") {
        var subbook_id = portfolio_hierarchy_obj.get_subbook() ? portfolio_hierarchy_obj.get_subbook() : 'NULL';
        var book_id = portfolio_hierarchy_obj.get_book('browser') ? portfolio_hierarchy_obj.get_book('browser') : 'NULL';
        var strategy_id = portfolio_hierarchy_obj.get_strategy('browser') ? portfolio_hierarchy_obj.get_strategy('browser') : 'NULL';
        var subsidiary_id = portfolio_hierarchy_obj.get_subsidiary('browser') ? portfolio_hierarchy_obj.get_subsidiary('browser') : 'NULL';
    }
    */

    var form_xml = '<ApplicationFilter name="' + filter_name + '"';
    if (report_type == 1) {
        form_xml += ' report_id="' + id + '">';
    } else if (report_type == 3) {
        form_xml += ' application_function_id="10201700" report_id="' + id + '">';
    } else if (report_type == 4) { //for excel addin reports
        form_xml += ' application_function_id="10202600" report_id="' + id + '" paramset_id="' + filter_form_obj.getUserData('btn_filter_save', 'extra_paramater')['paramset_id'] + '">';
    } else if (report_type == 5) { //for power bi reports
        form_xml += ' application_function_id="10202700" report_id="' + id + '" paramset_id="' + filter_form_obj.getUserData('btn_filter_save', 'extra_paramater')['paramset_id'] + '">';
    } else {
        form_xml += ' application_function_id="' + id + '">';
    }

    // Make array if the single object is provided.
    if (typeof layout_cell_obj.length == 'undefined') {
        layout_cell_obj = Array(layout_cell_obj);
    }

    // Looping through Layout Cell objects provided.
    layout_cell_obj.forEach(function(ind_layout_cell_obj, ind) {
        var att_obj = ind_layout_cell_obj.getAttachedObject();

        if (Object.getPrototypeOf(att_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm') {
            var data = att_obj.getFormData();

            for (var a in data) {
                //exclude form fields used as config columns (hidden + readonly) , used on view report
                if(att_obj.isItemHidden(a) && att_obj.isReadonly(a)) {
                    continue;
                }

                field_label = a;
                if (att_obj.getItemType(a) == "calendar") {
                    field_value = att_obj.getItemValue(a, true);
                } else {
                    field_value = data[a];
                }
                form_xml += '<Filter name="' + field_label + '" value="' + field_value + '"/>';
            }
        } else if(att_obj instanceof dhtmlXTabBar || Object.getPrototypeOf(att_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXCellTop') {
            att_obj.forEachTab(function(tab){
                form_obj = tab.getAttachedObject();

                if (Object.getPrototypeOf(form_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm') {
                    var data = form_obj.getFormData();

                    for (var a in data) {
                        //exclude form fields used as config columns (hidden + readonly) , used on view report
                        if(form_obj.isItemHidden(a) && form_obj.isReadonly(a)) {
                            continue;
                        }
                        field_label = a;
                        if (form_obj.getItemType(a) == "calendar") {
                            field_value = form_obj.getItemValue(a, true);
                        } else {
                            field_value = data[a];
                        }
                        form_xml += '<Filter name="' + field_label + '" value="' + field_value + '"/>';
                    }
                } else if (form_obj instanceof dhtmlXLayoutObject){ //added if attached object contains layout instead of form
                    form_obj.forEachItem(function(cell){
                        var cell_obj = cell.getAttachedObject();

                        if (cell_obj instanceof dhtmlXForm) {
                            var data = cell_obj.getFormData();

                            for (var a in data) {
                                //exclude form fields used as config columns (hidden + readonly) , used on view report
                                if(cell_obj.isItemHidden(a) && cell_obj.isReadonly(a)) {
                                    continue;
                                }
                                field_label = a;
                                if (cell_obj.getItemType(a) == "calendar") {
                                    field_value = cell_obj.getItemValue(a, true);
                                } else {
                                    field_value = data[a];
                                }
                                form_xml += '<Filter name="' + field_label + '" value="' + field_value + '"/>';
                            }
                        }
                    });
                }
            });
        }
    });

    /*
    if(typeof(portfolio_hierarchy_obj) != "undefined") {
        form_xml += '<Filter_tree name="' + 'subbook_id' + '" value="' + subbook_id + '"/>';
        form_xml += '<Filter_tree name="' + 'book_id' + '" value="' + book_id + '"/>';
        form_xml += '<Filter_tree name="' + 'strategy_id' + '" value="' + strategy_id + '"/>';
        form_xml += '<Filter_tree name="' + 'subsidiary_id' + '" value="' + subsidiary_id + '"/>';
    }
    */

    var grid_filter_xml = get_grid_filter(id);
    form_xml += grid_filter_xml + "</ApplicationFilter>";

    data = {"action": "spa_application_ui_filter", "flag": "i", "xml_string": form_xml};
    data = $.param(data);

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: true,
        data: data,
        success: function(result) {
            var return_data = result['json'];
            var reselect_filter_id = return_data[0].recommendation;

            if (reselect_filter_id == '' || reselect_filter_id == 0) reselect_filter_id = filter_id;

            success_call(return_data[0].message);

            load_form_filter_combo(filter_form_obj, id, report_type,reselect_filter_id);
        }
    });
}

/**
 * Delete the filter data
 * 
 * @param   {Object}    filter_form_obj     Form object where filter form should be loaded
 * @param   {String}    id                  Application id or report id of the report
 * @param   {Number}    report_type         Report type:
 *                                              1: Report manager report
 *                                              2: Standard report
 */
function delete_form_filter(filter_form_obj, id, report_type) {
    var combo_obj = filter_form_obj.getCombo('apply_filters');
    var filter_name = combo_obj.getComboText();
    var filter_id = combo_obj.getSelectedValue();
	
	if (filter_id == -1) {
        success_call('No changes can be made to default filter.');
        return;
	}
	
    var form_xml = '<ApplicationFilter name="' + filter_name + '"';
    if (report_type == 1) {
        form_xml += ' report_id="' + id + '"/>';
    } else if (report_type == 4) {
        form_xml += ' report_id="' + id + '" application_function_id="10202600"/>';
    } else if (report_type == 5) {
        form_xml += ' report_id="' + id + '" application_function_id="10202700"/>';
    } else {
        form_xml += ' application_function_id="' + id + '"/>';
    }

    var data = {"action": "spa_application_ui_filter", "flag": "d", "xml_string": form_xml};
    data = $.param(data);

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: true,
        data: data,
        success: function(result) {
            var return_data = result['json'];

            success_call(return_data[0].message);

            load_form_filter_combo(filter_form_obj, id, report_type, '');
        }
    });
    combo_obj.setComboText('');
}

/**
 * Clears the Multiselect Combo on clearing filter - Added to resolve the issue of 
 * clearing the combo text but not unchecking the elements
 * 
 * @param   {Object}    form_obj    Form object
 */
function clear_multiselect_combo(form_obj) {
    form_obj.forEachItem(function(name) {
        if (form_obj.getItemType(name) == "combo") {
            if (form_obj.getCombo(name).conf.opts_type == 'custom_checkbox') {
                var option_count = form_obj.getCombo(name).getOptionsCount();

                var checked_value = '';
                var combo_obj = form_obj.getCombo(name);
                checked_value = combo_obj.getChecked();

                if (checked_value != '' ) {
                    $.each(checked_value, function(index, value) {
                        combo_obj.setChecked(combo_obj.getIndexByValue(value), false);
                    });
                }
            } else {
                /*
                    # Added this logic because there is issue while clearing value for disabled fields...
                    # Checked enabled/disabled status and unselect option only if it is enabled...
                */
                if (form_obj.isItemEnabled(name)) {
                    form_obj.getCombo(name).unSelectOption();
                }
            }
        }
    });
}

/**
 * Clear the grid and book structure in apply filter
 * 
 * @param   {Object}    filter_form_obj     Form object where filter form should be loaded
 * @param   {Object}    layout_cell_obj     Layout cell object
 * @param   {Number}    app_report_id       Application report id
 */
function clear_filter_form(filter_form_obj, layout_cell_obj, app_report_id) {

    // Added to clear the apply filter combo as well.
    var combo_obj = filter_form_obj.getCombo('apply_filters');
    combo_obj.unSelectOption();

    // Make array if the single object is provided.
    if (typeof layout_cell_obj.length == 'undefined') {
        layout_cell_obj = Array(layout_cell_obj);
    }

    // Looping through Layout Cell objects provided.
    layout_cell_obj.forEach(function(ind_layout_cell_obj, ind) {
        var att_obj = ind_layout_cell_obj.getAttachedObject();

        if (att_obj instanceof dhtmlXForm) {
            //used foreachitem to clear to exclude hidden+readonly values, config cols
            att_obj.forEachItem(function(name) {
                if(att_obj.getItemType(name) == 'input' || att_obj.getItemType(name) == 'calendar' || att_obj.getItemType(name) == 'dyn_calendar'
                    || att_obj.getItemType(name) == 'checkbox' || att_obj.getItemType(name) == 'phone') {
                    if(att_obj.isItemHidden(name) && att_obj.isReadonly(name)) {
                        return;
                    }

                    if(att_obj.getItemType(name) == 'checkbox') {
                        att_obj.uncheckItem(name);
                    } else {
                        att_obj.setItemValue(name,'');
                    }

                }

            });

            // clears the multi select combo
            clear_multiselect_combo(att_obj);

        } else {
            att_obj.forEachTab(function(tab){
                form_obj = tab.getAttachedObject();

                if (Object.getPrototypeOf(form_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm'){
                    // if (form_obj.isItem('report_paramset_id'))
                    //     var report_paramset_id = form_obj.getItemValue('report_paramset_id');
                    // if (form_obj.isItem('paramset_hash'))
                    //     var paramset_hash = form_obj.getItemValue('paramset_hash');

                    //form_obj.clear();
                    //used foreachitem to clear to exclude hidden+readonly values, config cols
                    form_obj.forEachItem(function(name) {
                        if(form_obj.getItemType(name) == 'input' || form_obj.getItemType(name) == 'calendar' || form_obj.getItemType(name) == 'dyn_calendar'
                            || form_obj.getItemType(name) == 'checkbox' || form_obj.getItemType(name) == 'phone') {
                            //console.log(name+':'+form_obj.getItemType(name));
                            if(form_obj.isItemHidden(name) && form_obj.isReadonly(name)) {
                                return;
                            }

                            if(form_obj.getItemType(name) == 'checkbox') {
                                form_obj.uncheckItem(name);
                            } else {
                                form_obj.setItemValue(name,'');
                            }
                        }

                    });
                    // if (form_obj.isItem('report_paramset_id'))
                    //     form_obj.setItemValue('paramset_hash',paramset_hash);
                    // if (form_obj.isItem('paramset_hash'))
                    //     form_obj.setItemValue('report_paramset_id',report_paramset_id);
                    clear_multiselect_combo(form_obj);
                } else if (form_obj instanceof dhtmlXLayoutObject){//added if attached object contains layout instead of form
                    form_obj.forEachItem(function(cell){
                        var cell_obj = cell.getAttachedObject();

                        if (cell_obj instanceof dhtmlXForm) {
                            //cell_obj.clear();
                            //used foreachitem to clear to exclude hidden+readonly values, config cols
                            cell_obj.forEachItem(function(name) {
                                if(cell_obj.getItemType(name) == 'input' || cell_obj.getItemType(name) == 'calendar' || cell_obj.getItemType(name) == 'dyn_calendar'
                                    || cell_obj.getItemType(name) == 'checkbox' || cell_obj.getItemType(name) == 'phone') {
                                    if(cell_obj.isItemHidden(name) && cell_obj.isReadonly(name)) {
                                        return;
                                    }

                                    if(cell_obj.getItemType(name) == 'checkbox') {
                                        cell_obj.uncheckItem(name);
                                    } else {
                                        cell_obj.setItemValue(name,'');
                                    }
                                }

                            });
                            clear_multiselect_combo(cell_obj);
                        }
                    });
                }
            });
        }
    });

    var data = {
        "action": "spa_application_ui_filter",
        "flag": "g",
        "function_id": app_report_id
    };

    data = $.param(data);

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: false,
        data: data,
        success: function(data) {
            response_data = data["json"];
            for (var gcnt = 0; gcnt < response_data.length; gcnt++) {
                var column_name = response_data[gcnt].column_name;
                var grid_obj = response_data[gcnt].grid_object;
                if (column_name == 'book') {
                    eval(grid_obj + '.tree_uncheck_all();');
                } else {
                    eval(grid_obj + '.clearSelection()');
                }
            }
        }
    });
}

/**
 * Load the previously saved filter in the filter combo
 * 
 * @param   {Object}    filter_form_obj     Form object where filter form should be loaded
 * @param   {Number}    id                  Application id or report id of the report
 * @param   {Number}    report_type         Report type:
 *                                              1: Report manager report
 *                                              2: Standard report
 * @param   {Number}   reselect_filter_id   Reselect Filter id 
 */
function load_form_filter_combo(filter_form_obj, id, report_type, reselect_filter_id) {
    var combo_xml = "";
    if (report_type == 1) {
        combo_xml = '<ApplicationFilter report_id="' + id + '"></ApplicationFilter>';
    } else if (report_type == 2) {
        combo_xml = '<ApplicationFilter application_function_id="' + id + '"></ApplicationFilter>';
    } else if (report_type == 3) {
        combo_xml = '<ApplicationFilter report_id="' + id + '" application_function_id="10201700"></ApplicationFilter>';
    } else if (report_type == 4) { //for excel addin reports
        combo_xml = '<ApplicationFilter report_id="' + id + '" application_function_id="10202600"></ApplicationFilter>';
    } else if (report_type == 5) { //for excel addin reports
        combo_xml = '<ApplicationFilter report_id="' + id + '" application_function_id="10202700"></ApplicationFilter>';
    }
    var combo_data = {"action": "spa_application_ui_filter", "flag": "s", "xml_string": combo_xml};

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: true,
        data: combo_data,
        success: function(result1) {
            response_data = result1['json'];
            var cmb_data = JSON.stringify(response_data);
            cmb_data = (JSON.parse(cmb_data));

            var dropdown_json = '[';
            for (var i = 0; i < (cmb_data.length); i++) {
                var field_name = (cmb_data[i].text);
                var field_value = (cmb_data[i].value);
                if (i != 0)
                    dropdown_json += ',';
                dropdown_json += '{value:"' + field_value + '", text:"' + field_name + '"}';
            }
            dropdown_json += ']';

            eval('var json_temp='+dropdown_json);
            // console.log(json_temp);
            var cmb_obj = filter_form_obj.getCombo('apply_filters');
            filter_form_obj.reloadOptions('apply_filters',json_temp);
            cmb_obj.setComboValue(reselect_filter_id);

        }
    });
}

/**
 * Load the saved filter data in the form when the combo is changed
 * 
 * @param   {String}    filter_form_obj             Form object where filter form should be loaded
 * @param   {String}    layout_cell_obj             Layout cell of the form whose filter data need to be saved
 * @param   {Number}    id                          Application id or report id of the report
 * @param   {String}    report_type                 Report type:
 *                                                      1: Report manager report
 *                                                      2: Standard report
 * @param   {Object}    portfolio_hierarchy_obj     Portfolio object
 * @param   {String}    callback_function           Callback function name
 */
function apply_filter_change(filter_form_obj, layout_cell_obj, id, report_type,portfolio_hierarchy_obj, callback_function) {
    combo_obj = filter_form_obj.getCombo('apply_filters');
    var filter_name = combo_obj.getSelectedText();

    var form_xml = '<ApplicationFilter name="' + filter_name + '"';

    if (report_type == 1) {
        form_xml += ' report_id="' + id + '"/>';
    } else if (report_type == 3) {
        form_xml += ' application_function_id="10201700" report_id="' + id + '"/>';
    } else if (report_type == 4) {
        form_xml += ' application_function_id="10202600" report_id="' + id + '" paramset_id="' + filter_form_obj.getUserData('btn_filter_save', 'extra_paramater')['paramset_id'] + '"/>';
    } else if (report_type == 5) {
        form_xml += ' application_function_id="10202700" report_id="' + id + '" paramset_id="' + filter_form_obj.getUserData('btn_filter_save', 'extra_paramater')['paramset_id'] + '"/>';
    } else {
        form_xml += ' application_function_id="' + id + '"/>';
    }

    // Make array if the single object is provided.
    if (typeof layout_cell_obj.length == 'undefined') {
        layout_cell_obj = Array(layout_cell_obj);
    }

    if (filter_name == 'DEFAULT') {
        layout_cell_obj.forEach(function(ind_layout_cell_obj, ind) {
            var att_obj = ind_layout_cell_obj.getAttachedObject();
            if (Object.getPrototypeOf(att_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm') {
                att_obj.restoreBackup(a[id][ind]);
            } else if (att_obj instanceof dhtmlXTabBar || Object.getPrototypeOf(att_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXCellTop') {
                att_obj.forEachTab(function(tab){
                    var form_obj = tab.getAttachedObject();
                    var tab_id = tab.getId() + '' + ind;
                    if (Object.getPrototypeOf(form_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm'){
                        form_obj.restoreBackup(a[id][tab_id]);
                    } else if (form_obj instanceof dhtmlXLayoutObject){//added if attached object contains layout instead of form
                        form_obj.forEachItem(function(cell){
                            var cell_obj = cell.getAttachedObject();
                            var new_id_with_cell_id = tab_id + '' + cell.getId();
                            if (cell_obj instanceof dhtmlXForm) {
                                cell_obj.restoreBackup(a[id][new_id_with_cell_id]);
                            }
                        });
                    }
                });
            }
        });
    } else {
        var combo_data = {"action": "spa_application_ui_filter", "flag": "a", "xml_string": form_xml};

        $.ajax({
            type: "POST",
            dataType: "json",
            url: js_form_process_url,
            async: true,
            data: combo_data,
            success: function(result1) {
                var response_data = result1['json'];
                var form_data = JSON.stringify(response_data);
                form_data = JSON.parse(form_data);

                layout_cell_obj.forEach(function(ind_layout_cell_obj, ind) {
                    var att_obj = ind_layout_cell_obj.getAttachedObject();

                    if (Object.getPrototypeOf(att_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm') {
                        apply_form_filter(att_obj, form_data, portfolio_hierarchy_obj,callback_function, layout_cell_obj);
                    } else if(att_obj instanceof dhtmlXTabBar || Object.getPrototypeOf(att_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXCellTop') {
                        var form_obj;
                        att_obj.forEachTab(function(tab){
                            form_obj = tab.getAttachedObject();

                            if (Object.getPrototypeOf(form_obj).constructor.toString().match(/function (\w*)/)[1] == 'dhtmlXForm'){
                                apply_form_filter(form_obj, form_data,'',callback_function, layout_cell_obj);
                            } else if (form_obj instanceof dhtmlXLayoutObject){//added if attached object contains layout instead of form
                                form_obj.forEachItem(function(cell){
                                    var cell_obj = cell.getAttachedObject();

                                    if (cell_obj instanceof dhtmlXForm) {
                                        apply_form_filter(cell_obj, form_data,'',callback_function, layout_cell_obj);
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    }

    //Load the saved grid filter
    var grid_data = {"action": "spa_application_ui_filter", "flag": "b", "xml_string": form_xml};

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: true,
        data: grid_data,
        success: function(result1) {
            var response_data = result1['json'];
            var grid_info = JSON.stringify(response_data);
            grid_info = (JSON.parse(grid_info));

            var f_book = 0;
            for (var i = 0; i < (grid_info.length); i++) {
                var is_book = grid_info[i].is_book;
                if (is_book == 'y') {
                    if (f_book == 0) {
                        eval(grid_info[i].grid_object_name + '.tree_uncheck_all();');
                        f_book = 1;
                    }

                    if (grid_info[i].grid_object_unique_column == 'subbook' && grid_info[i].field_value != '') {
                        if(grid_info[i].field_value.indexOf(",") != -1) {
                            checked_arr = grid_info[i].field_value.split(',');
                        } else {
                            checked_arr = new Array();
                            checked_arr.push(grid_info[i].field_value);
                        }

                        for (var cnt = 0; cnt < checked_arr.length; cnt++) {
                            eval(grid_info[i].grid_object_name + '.set_book_structure_node(checked_arr[cnt], "subbook")');
                        }
                    } else if (grid_info[i].grid_object_unique_column == 'book' && grid_info[i].field_value != '') {
                        if(grid_info[i].field_value.indexOf(",") != -1) {
                            checked_arr = grid_info[i].field_value.split(',');
                        } else {
                            checked_arr = new Array();
                            checked_arr.push(grid_info[i].field_value);
                        }

                        for (var cnt = 0; cnt < checked_arr.length; cnt++) {
                            eval(grid_info[i].grid_object_name + '.set_book_structure_node(checked_arr[cnt], "book")');
                        }
                    }

                } else {
                    eval(grid_info[i].grid_object_name + '.clearSelection();');
                    if (grid_info[i].field_value == '') return;
                    var field_value_arr = grid_info[i].field_value.split(',');

                    if (grid_info[i].field_value != '') {
                        eval(' var col_ind = ' + grid_info[i].grid_object_name + '.getColIndexById("' + grid_info[i].grid_object_unique_column + '")');

                        var function_string = 'for (var j=0; j<' + grid_info[i].grid_object_name + '.getRowsNum(); j++){ ';
                        function_string += ' var id = ' + grid_info[i].grid_object_name + '.getRowId(j);';
                        function_string += ' var value_id = ' + grid_info[i].grid_object_name + '.cells(id, col_ind).getValue();';
                        function_string += '  if(jQuery.inArray(value_id, field_value_arr) > -1) {';
                        function_string += 		grid_info[i].grid_object_name + '.selectRowById(id, true,true,true);';
                        function_string += 	  '}';
                        function_string += 	  '}';
                        
                        eval(function_string);
                    }
                }
            }
        }
    });
}

/**
 * Load the saved filter data in the form when the combo is changed
 * 
 * @param   {Object}    form_obj            Form object where filter form should be loaded
 * @param   {String}    form_data           Form data in JSON to set in form elements
 * @param   {String}    callback_function   Callback Function
 * @param   {Object}    layout_cell_obj     Callback Function
 */
function apply_form_filter(form_obj, form_data, portfolio_hierarchy_obj, callback_function, layout_cell_obj) {
    /*
    if (typeof(portfolio_hierarchy_obj) != "undefined") {
        for (var i = 0; i < form_data.length; i++) {
            if (form_data[i]["farrms_field_id"] == 'subbook_id') {
                var sub_book = form_data[i]["field_value"];
            } else if (form_data[i]["farrms_field_id"] == 'book_id') {
                var book_id = form_data[i]["field_value"];
            }
        } 

        var checked_arr = new Array();

        if(typeof(sub_book) != "undefined") {
            var checked_name = 'subbook';
            if(sub_book != 'NULL') { // When sub book is enable
                if(sub_book.indexOf(",") != -1) {
                    checked_arr = sub_book.split(',');
                } else {
                    checked_arr[0] = sub_book;
                }
            } else { // When book is enable but sub book is disable.
                if(book_id.indexOf(",") != -1) {
                    checked_arr = book_id.split(',');
                } else {
                    checked_arr[0] = book_id;
                }
                checked_name = 'book';
            }

            portfolio_hierarchy_obj.tree_uncheck_all();
            
            for (var i = 0; i < checked_arr.length; i++) {
                portfolio_hierarchy_obj.set_book_structure_node(checked_arr[i], checked_name);
            } 
        }
    }
    */
    layout_cell_obj.forEach(function(ind_layout_cell_obj, ind) {
        ind_layout_cell_obj.progressOn();
    });

    var field_name, field_value, is_checked, default_format, combo_obj;
    var field_value_arr = [];
    connector_combo_load_state = {};
    combo_events_array = [];
    for (i = 0; i < form_data.length; i++) {
        field_name = (form_data[i].farrms_field_id);
        if (!form_obj.isItem(field_name)) continue;
        field_value = (form_data[i].field_value);
        var is_dependent = form_obj.getUserData(field_name, 'is_dependent');

        if (is_dependent == 1) {
            form_obj.setUserData(field_name, 'filter_values', field_value);
        }

        if (form_obj.getItemType(field_name) == 'combo') {
            combo_obj = form_obj.getCombo(field_name);
            default_format = form_obj.getUserData(field_name, 'default_format');
            var combo_old_value = '';
            if (default_format == 'm' || default_format == 'c')
                combo_old_value = combo_obj.getChecked();
            else
                combo_old_value = form_obj.getItemValue(field_name);

            if ((combo_obj._is_loaded == false && is_dependent != 1 && field_value != combo_old_value) || (is_dependent == 1 && field_value != '' && field_value != combo_old_value)) {
                connector_combo_load_state[field_name] = false;
                if (combo_obj.getIndexByValue(field_value) == -1) {
                    combo_events_array[field_name] = combo_obj.attachEvent("onXLE", function() {
                        mark_combo_load(this, connector_combo_load_state, combo_events_array, layout_cell_obj);
                    });
                }
            }
        }
    }

    var cnt = form_data.length;

    for (i = 0; i < cnt; i++) {
        is_checked = null;
        field_name = (form_data[i].farrms_field_id);
        if (!form_obj.isItem(field_name)) continue;
        field_value = (form_data[i].field_value);
        default_format = form_obj.getUserData(field_name, 'default_format');
        var is_dependent = form_obj.getUserData(field_name, 'is_dependent');

        if (form_obj.getItemType(field_name) == 'combo') {
            combo_obj = form_obj.getCombo(field_name);
            if (combo_obj._is_loaded == false && is_dependent != 1 && field_value) {
                load_combo_v2(form_obj, field_name, field_value);
            }
        }

        if (form_obj.getItemType(field_name) == 'combo' && (default_format == 'm' || default_format == 'c')) {
            // Checked if form item is enabled or not, because there is problem while loading values for disabled fields
            if (form_obj.isItemEnabled(field_name)) {
                combo_obj = form_obj.getCombo(field_name);

                field_value_arr = field_value.split(',');
                var checked_value = '';

                var combo_count = combo_obj.getOptionsCount();
                checked_value = combo_obj.getChecked();

                if (checked_value != '' ) {
                    $.each(checked_value, function(index, value) {
                        combo_obj.setChecked(combo_obj.getIndexByValue(value), false, false);
                    });
                }

                for (var j = 0, fcnt = field_value_arr.length; j < fcnt; j++) {
                    if (field_value_arr[j] != '')
                        combo_obj.setChecked(combo_obj.getIndexByValue(field_value_arr[j]), true, false);
                }
                if (typeof connector_combo_load_state != 'undefined') {
                    if (connector_combo_load_state[field_name] == false && combo_events_array[field_name] == undefined) {
                        mark_combo_load(combo_obj, connector_combo_load_state, combo_events_array, layout_cell_obj);
                    }
                }
            }
        } else if (form_obj.getItemType(field_name) == 'checkbox' && field_value == 'y') {
            form_obj.checkItem(field_name);
            is_checked = true;
        } else if (form_obj.getItemType(field_name) == 'checkbox' && field_value == 'n') {
            form_obj.uncheckItem(field_name);
            is_checked = false;
        } else {
            if (form_obj.getItemType(field_name) != 'combo')
                form_obj.setItemValue(field_name, field_value);
            else {
                if (typeof combo_obj._is_loaded === 'undefined' || combo_obj._is_loaded == true) {
                    form_obj.setItemValue(field_name, field_value);
                    if (typeof connector_combo_load_state != 'undefined') {
                        if (combo_obj._is_loaded == true && connector_combo_load_state[field_name] == false && combo_events_array[field_name] == undefined) {
                            mark_combo_load(combo_obj, connector_combo_load_state, combo_events_array, layout_cell_obj);
                        }
                    }
                }
            }
        }

        if (is_dependent != 1) {
            if (form_obj.getItemType(field_name) == 'combo' && (default_format == 'm' || default_format == 'c'))
                combo_obj.callEvent("onCheck", [field_name, field_value_arr, true]);
            else
                form_obj.callEvent("onChange", [field_name, field_value, is_checked]);
        }
    }
    // If no dropdown to be loaded
    if (typeof connector_combo_load_state === 'undefined') return;
    if (Object.keys(connector_combo_load_state).length == 0)
        layout_cell_obj.forEach(function(ind_layout_cell_obj, ind) {
            ind_layout_cell_obj.progressOff();
        });

    if (callback_function && typeof(callback_function) != 'undefined' && callback_function != '') {
        callback_function();
    }
}

/**
 * Mark Combo as load
 * 
 * @param   {object}    combo_obj                   Combo Obj
 * @param   {array}     connector_combo_load_state  Connector Combo state
 * @param   {array}     combo_events_array Combo    Events
 * @param   {object}    layout_cell_obj             Layout Cell Object
 */
function mark_combo_load(combo_obj, connector_combo_load_state, combo_events_array, layout_cell_obj) {
    connector_combo_load_state[combo_obj.conf.form_name] = true;
    var is_load_remaining = Object.keys(connector_combo_load_state).filter(function(e) {
        return !connector_combo_load_state[e];
    }).length > 0;

    combo_obj.detachEvent(combo_events_array[combo_obj.conf.form_name]);
    if (!is_load_remaining) {
        delete connector_combo_load_state;
        delete combo_events_array;
        layout_cell_obj.forEach(function(ind_layout_cell_obj, ind) {
            ind_layout_cell_obj.progressOff();
        });
    }
}

/**
 * Load V2 Combo if its not already loaded
 * 
 * @param   {object}    form_obj        Form Object
 * @param   {String}    field_name      Field name
 * @param   {String}    default_value   Fiedl value
 */
function load_combo_v2(form_obj, field_name, default_value) {
    var combo_type = form_obj.getUserData(field_name, 'default_format');
    var application_field_id = form_obj.getUserData(field_name, 'application_field_id');

    /* return if call from deal detail ui as deal detail ui form
     *doesnot contain application_field_id to fix data load issue on IE browser
    */
    if(!application_field_id) {
        return;
    }

    var dropdown_param = {
        "call_from": "dependent",
        "application_field_id": application_field_id,
        "value": "",
        "load_child_without_selecting_parent" : "1",
        "SELECTED_VALUE" : default_value
    };

    dropdown_param = $.param(dropdown_param);
    var url = js_dropdown_connector_url + '&' + dropdown_param;

    var combo_obj = form_obj.getCombo(field_name);
    combo_obj.load(url, function() {
        if (combo_type == 'm' || combo_type == 'c')
            combo_obj.callEvent("onCheck", [default_value, false]);
        else
            combo_obj.callEvent("onChange", [default_value, false]);
    });
}

/**
 * Check if the parent dependent combo is loaded or not
 * Only used for parent of type combo_v2
 * 
 * @param  {String}     combo_prop          Combo Properties
 * @param  {Number}     i                   Sequence No
 * @param  {Object}     form                Form Object
 */
function load_dependent_combo_v2(combo_prop, i, form) {
    if(combo_prop) {
        var combo_array = combo_prop.split("~");
        var column_array = combo_array[i].split("->");
        var parent_combo_name = column_array[0];
        var parent_combo = form.getCombo(parent_combo_name);

        if (parent_combo._is_loaded) {
            load_dependent_combo1 (combo_prop, i, form)
        } else {
            parent_combo.attachEvent("onXLE", function() {
                load_dependent_combo1(combo_prop, i, form);
            });
        }
    }
}

/**
 * Get grid filter
 *
 * @param   {Number}    id      Function id
 *
 * @return  {String}            Grid filter XML
 */
get_grid_filter = function(id) {
    var grid_save_xml = new Array();

    var data = {
        "action": "spa_application_ui_filter",
        "flag": "g",
        "function_id": id
    };

    data = $.param(data);

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: false,
        data: data,
        success: function(data) {
            response_data = data["json"];
            for (gcnt = 0; gcnt < response_data.length; gcnt++) {
                var grid_value = new Array();
                var column_name = response_data[gcnt].column_name;
                var layout_grid_id = response_data[gcnt].layout_grid_id;
                var grid_obj = response_data[gcnt].grid_object;
                if (column_name == 'book') {
                    eval('var subsidiary_id = ' + grid_obj + '.get_subsidiary("browser");');
                    eval('var strategy_id = ' + grid_obj + '.get_strategy("browser");');
                    eval('var book_id = ' + grid_obj + '.get_book("browser");');
                    eval('var subbook_id = ' + grid_obj + '.get_subbook();');
                    xml = '<GridFilter layout_grid_id = "' + layout_grid_id + '" value="' + subsidiary_id + '" book_level="subsidiary" />'
                    grid_save_xml.push(xml);
                    xml = '<GridFilter layout_grid_id = "' + layout_grid_id + '" value="' + strategy_id + '" book_level="strategy" />'
                    grid_save_xml.push(xml);
                    xml = '<GridFilter layout_grid_id = "' + layout_grid_id + '" value="' + book_id + '" book_level="book" />'
                    grid_save_xml.push(xml);
                    xml = '<GridFilter layout_grid_id = "' + layout_grid_id + '" value="' + subbook_id + '" book_level="subbook" />'
                    grid_save_xml.push(xml);
                } else {
                    eval('var selected_id = ' + grid_obj + '.getSelectedRowId()');
                    eval('var col = ' + grid_obj + '.getColIndexById(column_name)')

                    if (selected_id != '' && selected_id != null) {
                        var selected_id_arr = selected_id.split(',');
                        for(cnt = 0; cnt < selected_id_arr.length; cnt++) {
                            eval('var value_id = ' + grid_obj + '.cells(selected_id_arr[cnt],col).getValue()');
                            grid_value.push(value_id);
                        }
                    }

                    var xml = '<GridFilter layout_grid_id = "' + layout_grid_id + '" value="' + grid_value.toString() + '" book_level="" />'
                    grid_save_xml.push(xml);
                }
            }
        }
    });
    return grid_save_xml.toString();
}

/**
 * Function from old adiha_function.js - Used in spa_html for report paginging
 *
 * @param   {String}    url             URL
 * @param   {String}    name            Name
 * @param   {Array}     params          Parameters
 * @param   {String}    new_open_widow  New window
 */
function open_window_with_post(url, name, params, new_open_widow) {
    new_open_widow = (new_open_widow == '') ? '_blank' : new_open_widow;
    var form = document.createElement("form");

    form.setAttribute("method", "post");
    form.setAttribute("action", url);
    form.setAttribute("target", new_open_widow);

    for (var i in params) {
        if (params.hasOwnProperty(i)) {6
            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = i;
            input.value = params[i];
            form.appendChild(input);
        }
    }

    document.body.appendChild(form);

    form.submit();
    document.body.removeChild(form);
}

/**
 * Opens Window
 *
 * @param   {String}  window_path       Window URL path
 * @param   {[type]}  additional_param  Additional POST parameters
 */
open_window = function(window_path, additional_param) {
    var undock_form = document.createElement("form");
    undock_form.target = "_blank";
    undock_form.method = "POST";
    undock_form.action = window_path;

    if (additional_param != 'undefined') {
        for (var i in additional_param) {
            if (additional_param.hasOwnProperty(i)) {
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = i;
                input.value = additional_param[i];
                undock_form.appendChild(input);
            }
        }
    }
    document.body.appendChild(undock_form);
    undock_form.submit();
    document.body.removeChild(undock_form);
}

/**
 * TwoDigits Convert single digit to two digit.
 * @param  {Number} d digit.
 */
function twoDigits(d) {
    if(0 <= d && d < 10) return "0" + d.toString();
    if(-10 < d && d < 0) return "-0" + (-1*d).toString();
    return d.toString();
}

var dates = {
    /**
     * Converts the date in d to a date-object. The input can be:
            date object  : returned without modification
            array        : Interpreted as [year,month,day]. NOTE: month is 0-11.
            number       : Interpreted as number of milliseconds since 1 Jan 1970 (a timestamp) 
            string       : Any format supported by the javascript engine, like
                            "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
            object       : Interpreted as an object with year, month and date
                            attributes.  **NOTE** month is 0-11.
     *
     * @param   {Mixed}     d   Date
     *
     * @return  {Object}        Date Object
     */
    convert:function(d) {
        // Converts the date in d to a date-object. The input can be:
        //   a date object: returned without modification
        //  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
        //   a number     : Interpreted as number of milliseconds
        //                  since 1 Jan 1970 (a timestamp) 
        //   a string     : Any format supported by the javascript engine, like
        //                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
        //  an object     : Interpreted as an object with year, month and date
        //                  attributes.  **NOTE** month is 0-11.

        return (
            d.constructor === Date ? d :
                d.constructor === Array ? new Date(d[0],d[1],d[2]) :
                    d.constructor === Number ? new Date(d) :
                        d.constructor === String ? ((d.indexOf('-') == -1 || user_date_format == '%j-%n-%Y' || user_date_format == '%n-%j-%Y') ? new Date(window.dhx4.str2date(d, user_date_format)) : new Date(window.dhx4.str2date(d))):
                            typeof d === "object" ? new Date(d.year,d.month,d.date) :
                                NaN
        );
    },

    /**
     * Converts the datetime in d to a date-object. The input can be:
        date object : returned without modification
        array       : Interpreted as [year,month,day]. NOTE: month is 0-11.
        number      : Interpreted as number of milliseconds
                        since 1 Jan 1970 (a timestamp) 
        string      : Any format supported by the javascript engine, like
                        "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
        object      : Interpreted as an object with year, month and date
                        attributes.  **NOTE** month is 0-11.
     *
     * @param   {Mixed}     d   Date
     *
     * @return  {Object}    Date
     */
    convert_with_time:function(d) {
        // Converts the datetime in d to a date-object. The input can be:
        //   a date object: returned without modification
        //  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
        //   a number     : Interpreted as number of milliseconds
        //                  since 1 Jan 1970 (a timestamp) 
        //   a string     : Any format supported by the javascript engine, like
        //                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
        //  an object     : Interpreted as an object with year, month and date
        //                  attributes.  **NOTE** month is 0-11.

        return (d.constructor === String ? new Date(window.dhx4.str2date(d, user_date_format + ' %H:%i:%s')) :this.convert(d));
    },

    /**
     * Converts to SQL Date
     *
     * @param   {Object}    d  Date
     *
     * @return  {String}    SQL format Date
     */
    convert_to_sql:function(d) {
        d1 = this.convert(d);
        return d1.getFullYear() + "-" + twoDigits(1 + d1.getMonth()) + "-" + twoDigits(d1.getDate());
    },

    /**
     * Converts to Sql date with time
     *
     * @param   {Object}    d  Date
     *
     * @return  {String}    SQL format Date with time
     */
    convert_to_sql_with_time:function(d) {
        d1 = this.convert(d);
        return d1.getFullYear() + "-" + twoDigits(1 + d1.getMonth()) + "-" + twoDigits(d1.getDate()) + ' ' + twoDigits(d1.getHours()) + ':' + twoDigits(d1.getMinutes()) + ':' + twoDigits(d1.getSeconds());
    },

    /**
     * Converts to user format date
     *
     * @param   {Object}    d  Date
     *
     * @return  {String}    User format Date with time
     */
    convert_to_user_format:function(d) {
        var d1 = ((d.indexOf('-') == -1) ? window.dhx4.str2date(d, user_date_format) : window.dhx4.str2date(d));
        return window.dhx4.date2str(d1, user_date_format);
    },

    /**
     * Compare two dates (could be of any type supported by the convert function above) and returns:
            -1 : if a < b
            0 : if a = b
            1 : if a > b
            NaN : if a or b is an illegal date
        NOTE: The code inside isFinite does an assignment (=).
     *
     * @param   {Object}  a     Date
     * @param   {Object}  b     Other date
     *
     * @return  {Mixed}     Compare value
     */
    compare:function(a,b) {
        return (
            isFinite(a=this.convert(a).valueOf()) &&
            isFinite(b=this.convert(b).valueOf()) ?
                (a>b)-(a<b) :
                NaN
        );
    },

    /**
     * Check if date is in range
     *
     * @param   {Object}    a       Date
     * @param   {Object}    start   Start Date
     * @param   {Object}    end     End Date
     *
     * @return  {Mixed}     Range Compare Value
     */
    inRange:function(d,start,end) {
        return (
            isFinite(d=this.convert(d).valueOf()) &&
            isFinite(start=this.convert(start).valueOf()) &&
            isFinite(end=this.convert(end).valueOf()) ?
                start <= d && d <= end :
                NaN
        );
    },

    /**
     * Add months to date
     * 
     * @param   {Object}    date    Date
     * @param   {Number}    months  Months
     *
     * @return  {Object}            Date
     */
    addMonths: function (date, months) {
        var startDate = date.getDate();
        date = new Date(+date);
        date.setMonth(date.getMonth() + Number(months))
        if (date.getDate() != startDate) {
            date.setDate(0);
        }
        return date;
    },

    /**
     * Get Term end date
     *
     * @param   {Object}    start       Start Date
     * @param   {String}    frequency   Frequency
     *
     * @return  {String}                Term end Date
     */
    getTermEnd:function(start, frequency) {
        var start = this.convert(start);
        var new_term_end;
        if (frequency == 'd') { //Daily
            new_term_end = start;
        } else if (frequency == 'a') { //Annually            
            new_term_end = new Date(start.getFullYear(), 11, 31);
        } else if (frequency == 's') { //Semi-Annually
            new_term_end = new Date(start.getFullYear(), 5, 30);
        } else if (frequency == 'q') { //Quarterly
            var currentMonth = (start.getMonth());
            var yyyy = start.getFullYear()
            var start1 = (Math.floor(currentMonth / 3) * 3) + 1,
                end = start1 + 3,
                endDate = end > 12 ? new Date('01-01-' + (yyyy + 1)) : new Date(end + '-01-' + (yyyy));
            new_term_end = new Date((endDate.getTime()) - 1);
        } else if (frequency == 'm') { //monthly
            new_term_end = new Date(start.getFullYear(), start.getMonth() + 1, 0);
        } else if (frequency == 'w') { //weekly
            new_term_end = new Date(start.setDate(start.getDate() - start.getDay()+6));
        }
        return new_term_end.getFullYear() + "-" + twoDigits(1 + new_term_end.getMonth()) + "-" + twoDigits(new_term_end.getDate());
    },

    /**
     * Get Date Difference
     *
     * @param   {Object}    date_from   Date From
     * @param   {Object}    date_to     Date To
     *
     * @return  {Number}                Difference of dates
     */
    diff_days: function(date_from, date_to) {

        var d1 = new Date(date_from);
        var d2 = new Date(date_to);

        var t2 = d2.getTime();
        var t1 = d1.getTime();

        return parseInt((t2-t1)/(24*3600*1000));
    },

    /**
     * Add days to date
     * 
     * @param   {Object}    date    Date
     * @param   {Number}    days    Days
     *
     * @return  {Object}            Date
     */
    addDays: function (date, days) {
        var result = this.convert(date);
        result.setDate(result.getDate() + days);
        return result;
    }
}

/**
 * Opens spa_html window
 *
 * @param   {String}    report_name     Report Name
 * @param   {String}    exec_call       Exec call
 * @param   {Number}    height          Height of the window
 * @param   {Number}    width           Width of the window
 * @param   {Number}    enable_paging   Flag to enable paging
 */
function open_spa_html_window(report_name, exec_call, height, width, enable_paging) {
    var std_report_url = js_php_path +  '../adiha.html.forms/_reporting/view_report/spa.html.template.php?exec_call=' + exec_call + '&report_name=' + report_name + '&enable_paging=' + enable_paging;
    var spa_dhxWins = new dhtmlXWindows();
    /*
    This change is required for Report Manger Report having hyperlink to open link report in spa_html.
    In main sp function [dbo].[FNAStandardReportHyperlink]() is used. Report name is encoded at backed.
    */
    report_name = decodeURI(report_name);
    var spa_win = spa_dhxWins.createWindow({
        id: report_name
        ,width: width
        ,height: height
        ,modal: true
        ,resize: true
        ,text: report_name

    });
    spa_win.centerOnScreen();
    spa_dhxWins.window(report_name).bringToTop();
    spa_win.attachURL(std_report_url);
    spa_win.maximize();
}

/**
 * [TRMWinHyperlink Open DHTMLX windows for menu
 * 
 * @param   {Number}    func_id         function id
 * @param   {String}    arg1            counterparty_id
 * @param   {String}    arg2            contract_id
 * @param   {String}    arg3            calc_id
 * @param   {String}    arg4            source_deal_header_id
 * @param   {String}    arg5            int_ext_flag
 * @param   {String}    arg6            report_type
 * @param   {String}    arg7            invoice_type
 * @param   {String}    arg8            calc_status
 * @param   {String}    arg9            netting_group_id
 * @param   {String}    arg10           settlement_date
 * @param   {Date}      asofdate        As of Date [Deal date from]
 * @param   {Date}      asofdate_to     As of Date [Deal date to]
 */
function TRMWinHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to) {
    get_file_path(func_id);
    $('#messageModal').hide();
    var window_title = '';

    if (func_id == 10101400) {
        var file_path_old = "../../../../trm.depr/adiha.html.forms/_setup/maintain_deal_template/maintain.deal.template.detail.php?&mode=u&source_system_id=2&template_id=" + arg1 + "&session_id=" + js_session_id + "&" + getAppUserName();
        createMdiWindow("win_10101400", file_path_old, "Maintain Deal Template Detail", 850, 650);
        return;
    }

    if (func_id == 10101410) {
        var file_path_old = "../../../../trm.depr/adiha.html.forms/_setup/maintain_deal_template/maintain.deal.template.php?template_id=" + arg1 + "&session_id=" + js_session_id + "&" + getAppUserName();
        createMdiWindow("win_10101410", file_path_old, "Maintain Deal Template", 850, 760);
        return;
    }

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
            break;
        case 10131020: // Trade Ticket
            args = "deal_ids=" + arg1 + "&disable_all_buttons=" + arg2 + "&show_button=" + arg3;
            break;
        case 10131010: // Maintain Deal Detail
            args = "deal_id=" + arg1 + "&view_deleted=" + arg2 + "&buy_sell=" + arg3;
            if (arg7 != '' || arg7 != null) {
                args += "&buy_sell=" + arg7;
            }
            window_title = 'Deal - ' + arg1;
            break;
        case 10171016: // Confirm Deal
            args = "deal_ids=" + arg1;
            break;
        case 10171013: // Deal Confirm History UI
            args = "mode=u&source_deal_header_id=" + arg1 + "&confirm_status_id=" + arg2 + "&call_from=c";
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
            break;
        case 10234500:
            var args = "&show_approved=" + arg1 +
                "&as_of_date_from=" + asofdate +
                "&as_of_date_to=" + asofdate_to;
            break;
        case 10211010:
            var args = "mode=u&contract_id=" + arg1;
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
        case 10106100:
            var args = "function_parameter=" + func_id + "&time_series_id=" + arg1;
            break;
        case 10131025:
            args = "deal_ids=" + arg1;
            break;
        case 10163110:
            var args = "etag_id=" + arg1 + "&oati_tag_id=" + arg2;
            break;
        case 10221300:
            args = "calc_id=" + arg1;
            break;
        case 10202201:
            args = "calc_id=" + arg1;
            break;
        case 10181200:
            args = "criteria_id=" + arg1;
            break;
        case 10183400:
            args = "whatif_criteria_id=" + arg1;
            break;
        case 10182500:
            args = "scenario_group_id=" + arg1;
            break;
        case 10105800:
            args = "counterparty_id=" + arg1 + "&incident_id=" + arg4;
            break;
        case 10163720:
            var convert_uom  = (arg3 == '') ? 1083 : arg3;
            var url_param = '?receipt_detail_ids=&delivery_detail_ids=&convert_uom=' + convert_uom + '&convert_frequency=703&mode=u&contract_id=NULL&bookout_match=m&location_id=NULL&shipment_name=&match_id=&match_shipment_id=' + arg1;

            args = url_param;
            TRMWinHyperlink_callback(func_id, args, window_title);


            break;
        case 10166600:
            args = "ticket_id=" + arg1;
            break;
        /* case 10101000:
             args = "value_id=" + arg1;
             break;*/
        case 10131800:
            var args = 'contract_id=' + arg1 + '&date=' + arg2 + '&volume=' + arg3 + '&counterparty_id=' + arg4 + '&nominated_volume=' + arg5 + '&actual_volume=' + arg6 + '&cashout_percent=' + arg7 + '&location_id=' + arg8;
            //createWindow('windowTransferTermPosition', false, true, args);
            break;
        case 10101122:
            var args = 'counterparty_id=' + arg1;
            break;
        case 14100100:
            args = "jurisdiction_id=" + arg1;
            break;
        case 12101700:
            args = "generator_id=" + arg1;
            break;
        case 10101410:
            var args = "mode=u&template_id=" + arg1;
            break;
        case 10101300:
            args = "gl_code_id=" + arg1;
            break;
        case 10231900:
            args = "relation_id=" + arg1;
            break;
        case 10101000: //Setup Static Data
            args = "default_function_id=" + func_id + "&default_id=" + arg1;
            break;
        case 10233700:
            var args = "&link_id=" + arg1 + '&deal_match_param=' + arg2;
            break;
        case 10102600:
            var args = "&source_price_curve_def_id=" + arg1;
            break;
        case 10102900:
            var args = "notes_object_id=" + arg1 + "&parent_object_id=" + arg2 + "&notes_category=" + arg3 + "&call_from=" + arg4;
            break;
        case 10162000: // Rate Schedule
            var args = "&maintain_rate_schedule=" + arg1 + "&contract_id=" + arg2 +"&call_from=" + arg3;
            break;
        case 20008900: // Rate Schedule
            var args = "&maintain_rate_schedule=" + arg1 + "&contract_id=" + arg2 +"&contract_name=" + arg3 +"&call_from=" + arg4 + "&counterparty_name=" + arg5;
            break;
        case 10162300: // Rate Schedule
            var args = "&storage_asset_id=" + arg1 + "&contract_id=" + arg2 + "&commodity=" + arg3 + '&custom_value=' + arg4;
            break;
        case 10106612:
            var status = '';
            var args = "filter_id=" + arg1 + "&source_column=" + arg2 + "&module_id=" + arg3 + "&process_table_xml=" + arg4 + "&module_event_id=" + arg5+ "&filter_string=" + arg6;
            break;
        case 10233710:
            var args = "&link_id=" + arg1 ;
            break;
        case 20005500: // To open Dashboard
            args = "dashboard_report_name=" + arg1 + "&selected_id=" + arg2;
            break;
        case 10231910:
            var args = "&eff_test_profile_id=" + arg1 ;
            break;
        case 10167300:
            args = "forecast_model_id=" + arg1;
            break;
        case 10102400:
            var args = "formula_id=" + arg1 ;
            break;
        case 20011400:
            var args = "template_id=" + arg1 ;
            break;
        case 20007900:
            var args = "link_id=" + arg1 ;
            break;     
        case 20003400: // View user defined tables
            args = "udt_name=" + arg1;
            break;   
        case 20013000: // Term Mapping
            args = "mapping_code=" + arg1;
            break;
        case 10101025: // Certification Entity 
            args = "value_id=" + arg1;
            break;
        case 20010600: // Setup Eligibility Mapping Template
            args = "template_id=" + arg1
            break;
    }

    if (func_id != 10163720) {
        setTimeout(function() {
        TRMWinHyperlink_callback(func_id, args, window_title);
        }, 500);        
    }
}

/**
 * Callback to Open windows
 * 
 * @param   {Number}    func_id         Function_id
 * @param   {String}    args            Argument
 * @param   {String}    window_title    Window title
 */
function TRMWinHyperlink_callback(func_id, args, window_title) {
    var file_path = $('#file_path').html();
    var window_name = $('#window_name').html();
    var window_label = (window_title != '') ? window_title : $('#window_label').html();


    if (typeof(window_name) === "undefined" || window_name == '') {
        data = {"action": "spa_setup_menu", "flag": "c", "function_id": func_id, "product_category":product_id};
        data = $.param(data);

        $.ajax({
            type: "POST",
            dataType: "json",
            url: js_form_process_url,
            async: true,
            data: data,
            success: function(result) {
                var return_data = result['json'];
                file_path = return_data[0].file_path;
                window_name = (return_data[0].window_name == '' || return_data[0].window_name == null) ? 'Win' + (new Date()).valueOf() : return_data[0].window_name;
                window_label = (window_title == '') ? return_data[0].display_name : window_label;
                open_menu_window(file_path + '?' + args, window_name, window_label, func_id, true);
            }
        });

        if (func_id == 10233700) {
            window_name = window_name;
        } else {
            window_name = 'Win'+ (new Date()).valueOf();
        }

    } else {
        open_menu_window(file_path + '?' + args, window_name, window_label, func_id, true);
    }
}

/**
 * Calls TRMWinHyperlink
 * 
 * @param   {Number}    function_id     Function id
 * @param   {String}    field_name      Name of the field
 * @param   {Object}    obj             Object
 */
function call_TRMWinHyperlink(function_id, field_name, obj) {
    set_params = function(form_obj, field_name){
        form_obj.forEachItem(function(field){
            if(form_obj.hasOwnProperty('additional_hyperlink_fields')){
                var a = form_obj['additional_hyperlink_fields'];

                matched_keys = Object.keys(a).filter(function(e){
                    return (e==field_name);
                });
                if(matched_keys.length > 0){
                    field_params = a[matched_keys[0]].map(function(e){
                        return (form_obj.getItemValue(e));
                    });
                }
            }

            if(form_obj.hasOwnProperty('additional_values')){
                var a = form_obj['additional_values'];

                matched_keys = Object.keys(a).filter(function(e){
                    return (e==field_name);
                });
                if(matched_keys.length > 0){
                    custom_params = a[matched_keys[0]].map(function(e){
                        return e;
                    });
                }
            }
        });
    }

    var arg1 = '';
    var isItemFound = false;
    field_params = '';
    custom_params = '';

    if (function_id == -1) return;

    if (obj == undefined || obj == '')
        var attached_obj = global_layout_object;
    else
        var attached_obj = obj;

    if (attached_obj instanceof dhtmlXTabBar) {
        var active_tab_id = attached_obj.getActiveTab();
        var inner_tab_obj = attached_obj.cells(active_tab_id).getAttachedObject();

        if (inner_tab_obj instanceof dhtmlXTabBar) {
            var inner_active_tab_id = inner_tab_obj.getActiveTab();
            var inner_tab_layout_obj = inner_tab_obj.cells(inner_active_tab_id).getAttachedObject();

            inner_tab_layout_obj.forEachItem(function(cell){
                var form_obj = cell.getAttachedObject();

                if (form_obj instanceof dhtmlXForm) {
                    if (form_obj.isItem(field_name)) {
                        set_params(form_obj, field_name);

                        isItemFound = true;
                        arg1 = form_obj.getItemValue(field_name);
                    }
                }
            });
        } else if (inner_tab_obj instanceof dhtmlXLayoutObject) {
            inner_tab_obj.forEachItem(function(cell){
                var obj = cell.getAttachedObject();

                if (obj instanceof dhtmlXForm) {
                    if (obj.isItem(field_name)) {
                        set_params(obj, field_name)

                        isItemFound = true;
                        arg1 = obj.getItemValue(field_name);
                    }
                } else if ((obj instanceof dhtmlXLayoutObject) || (obj instanceof dhtmlXTabBar)) {
                    call_TRMWinHyperlink(function_id, field_name, obj);
                }
            });
        } else if (inner_tab_obj instanceof dhtmlXForm) {
            if (inner_tab_obj.isItem(field_name)) {

                set_params(inner_tab_obj, field_name)

                isItemFound = true;
                arg1 = inner_tab_obj.getItemValue(field_name);
            }
        }
    } else if (attached_obj instanceof dhtmlXLayoutObject) {
        attached_obj.forEachItem(function(cell){
            var obj = cell.getAttachedObject();

            if (obj instanceof dhtmlXForm) {
                if (obj.isItem(field_name)) {
                    set_params(obj, field_name)
                    isItemFound = true;
                    arg1 = obj.getItemValue(field_name);
                }
            } else if ((obj instanceof dhtmlXLayoutObject) || (obj instanceof dhtmlXTabBar)) {
                call_TRMWinHyperlink(function_id, field_name, obj);
            }
        });
    }
    else if (attached_obj instanceof dhtmlXForm) {
        if (attached_obj.isItem(field_name)) {
            set_params(attached_obj, field_name)
            isItemFound = true;
            arg1 = attached_obj.getItemValue(field_name);
        }
    }

    if (isItemFound) {
        if (function_id == 10162000) { //allowing null argument for Rate Schedule hyperlink
            TRMWinHyperlink(function_id, arg1, field_params[0], custom_params[0]);
            return;
        }else if(function_id == 20008900){
            TRMWinHyperlink(function_id, arg1, field_params[0], field_params[1], custom_params[0], custom_params[1]);
            return;
        }

        if (arg1 == '') {
            var message = "No data selected for hyperlink.";
            show_messagebox(message);
        } else {
            if (function_id == 10162300) { //allowing null argument for Rate Schedule hyperlink
                TRMWinHyperlink(function_id, arg1, field_params[0], field_params[1], custom_params[0]);
                return;
            } else {
                TRMWinHyperlink(function_id, arg1);
            }
        }
        return;
    }
}

/**
 * Sets additional parameters to hyperlink
 *
 * @param   {Object}    form_obj    Form object
 * @param   {String}    field_name  Name of Field
 * @param   {Array}     fields      Fields Array
 * @param   {Array}     values      Values Array
 */
set_additional_hyperlink_parameters = function(form_obj, field_name, fields, values){
    if(form_obj.isItem(field_name)){
        if(fields != '') {
            if(!form_obj.hasOwnProperty('additional_hyperlink_fields')){
                form_obj['additional_hyperlink_fields'] = {};
            }
            form_obj['additional_hyperlink_fields'][field_name] = fields.split(',');
        }

        if(values != ''){
            if(!form_obj.hasOwnProperty('additional_values')){
                form_obj['additional_values'] = {};
            }
            form_obj['additional_values'][field_name] = values.split(',');
        }
    }
}
/**
 * Open privilage.
 * @param  {Function} callback_function Call back function
 * @param  {String} users               Users
 * @param  {String} roles               Roles provide to the given users
 */
function open_privilege(callback_function, users, roles) {
    var privilege = new dhtmlXWindows();
    var win = privilege.createWindow('p1', 0, 0, 670, 400);
    win.setText("Privilege");
    win.centerOnScreen();
    win.setModal(true);
    win.attachURL(js_php_path + '../adiha.html.forms/_users_roles/maintain_privileges/generic.privileges.php?callback_function=' + callback_function + '&users=' + users + '&roles=' + roles);
}

/**
 * Export sql data to excel
 * 
 * @param   {String}    url_path Url path
 */
function export_sql_to_excel(url_path) {
    var div_obj = document.createElement("div");
    div_obj.style.display = "none";
    document.body.appendChild(div_obj);
    var frm_id = "form_" + dhtmlx.uid();
    div_obj.innerHTML = '<form id="' + frm_id + '" method="post" action="' + url_path + '" accept-charset="utf-8"  enctype="application/x-www-form-urlencoded">&nbsp;</form>';
    document.getElementById(frm_id).submit();
    div_obj.parentNode.removeChild(div_obj);
}
/**
 * Return the tab id according to its tab object and tab index
 * 
 * @param   {Object}    tab_obj     Tab Object
 * @param   {Number}    index       Index of the given tab
 * 
 * @return  {Array}                 Return array of tab id and index of given tab
 */
function get_tab_id(tab_obj, index) {
    var i = 1;
    var tab_id = [];
    tab_obj.forEachTab(function(tab){
        tab_id[i] = tab.getId();
        i++;
    });
    return(tab_id[index]);
}

/**
 *  Load dependent combo
 * 
 * @param   {Object}    form_obj    Form object
 * @param   {String}    json_data   JSON data
 */
function attach_dependent_combos(form_obj, json_data) {
    var data_array = json_data.split(',')

    for (var i = 0; i < data_array.length; i++) {
        var get_parent_child = data_array[i].split('->');
        var parent_id  = get_parent_child[0];
        var child_id = get_parent_child[1];
        var is_multiselect = get_parent_child[2];

        var parent_obj = form_obj.getCombo(parent_id);
        var child_obj = form_obj.getCombo(child_id);

        attach_dependent_combos_callback(parent_obj, child_obj, parent_id, child_id, is_multiselect)
    }
}

/**
 * Load dependent combo callback
 * 
 * @param   {Object}    parent_obj      Parent object
 * @param   {Object}    child_obj       Child object
 * @param   {Number}    parent_id       Parent ID
 * @param   {Number}    child_id        Child ID
 * @param   {Boolean}   is_multiselect  Multiselect the values
 */
function attach_dependent_combos_callback(parent_obj, child_obj, parent_id, child_id, is_multiselect) {
    if (is_multiselect == 'm') {
        parent_obj.attachEvent('onCheck', function() {
            var parent_value_ids = parent_value_ids = parent_obj.getChecked();

            parent_value_ids = parent_value_ids.indexOf(",") == 0 ? parent_value_ids.substring(1, parent_value_ids.length) : parent_value_ids;
            child_obj.clearAll();
            child_obj.setComboValue(null);
            child_obj.setComboText(null);
            var application_field_id = form_obj.getUserData(child_id, "application_field_id");
            var url = js_dropdown_connector_url + '&call_from=dependent&value=' + parent_value_ids
                + '&application_field_id=' + application_field_id
                + '&parent_column=' + parent_id;

            child_obj.load(url);
        });
    } else {
        parent_obj.attachEvent('onChange', function(value) {
            child_obj.clearAll();

            var application_field_id = form_obj.getUserData(child_id, "application_field_id");
            var url = js_dropdown_connector_url + '&call_from=dependent&value=' + value
                + '&application_field_id=' + application_field_id
                + '&parent_column=' + parent_id;

        });
    }

}
/**
 * Opens reminder window
 */
function open_reminder_window() {
    if (typeof(dhxWins) === "undefined" || !dhxWins) {
        dhxWins = new dhtmlXWindows();
        dhxWins.attachViewportTo("workspace");
    }

    var window_name = 'Reminders';
    var file_path = '_setup/setup_calendar/reminder.php';

    if (dhxWins.isWindow(window_name)) {
        dhxWins.window(window_name).bringToTop();
    } else {
        dhxWins.createWindow(window_name, 0, 0, 450, 400);
        dhxWins.window(window_name).setText('Reminders');
        dhxWins.window(window_name).center();
        dhxWins.window(window_name).denyResize();
        dhxWins.window(window_name).progressOn();
        dhxWins.window(window_name).attachURL(app_form_path+file_path, false, true);
        dhxWins.window(window_name).attachEvent("onContentLoaded", function(win){
            dhxWins.window(window_name).progressOff();
        });

        dhxWins.window(window_name).button("close").attachEvent("onClick", function(win){
            win.close();
            return true;
        });

        dhxWins.window(window_name).button('minmax').hide();
        dhxWins.window(window_name).button('park').hide();
    }
}

/**
 * Opens search window
 */
open_search_window = function() {
    var search_text = $('#txt_search').val();
    if (search_text == '') {
        show_messagebox('Please enter search keyword.');
        return;
    }

    var search_objects = $("input[name=search_objects]:checked").map(function () {
        return this.value;
    }).get().join(',');

    var search_file_path = js_php_path + 'search.result.php?search_text=' + search_text + '&search_objects=' + search_objects;
    var global_search_window;


    if (typeof(dhx_wins) === "undefined" || !dhx_wins) {
        dhx_wins = new dhtmlXWindows();
        dhx_wins.attachViewportTo('workspace');
    }

    var fixedSidebar = 'fixed-leftmenu';
    if ($('body').hasClass(fixedSidebar) == true) {
        if ($('#page-wrapper').hasClass('nav-small') == false) {
            $('#page-wrapper').toggleClass('nav-small');
        }

        if ($('#page-wrapper #menu-lists li').hasClass('open')) {
            $('#page-wrapper #menu-lists li').parent().find('.open .submenu').slideUp('fast');
            $('#page-wrapper #menu-lists li').parent().find('.open').toggleClass('open');

            dhx_wins.forEachWindow(function(window_name){
                if (window_name.isMaximized()) {
                    window_name.minimize();
                    window_name.maximize();
                }
            });
        }
    }

    if (dhx_wins.isWindow("GLOBAL_SEARCH_WINDOW")) {
        if (dhx_wins.window("GLOBAL_SEARCH_WINDOW").isParked()) {
            dhx_wins._winButtonClick("GLOBAL_SEARCH_WINDOW", "minmax");
        }
        global_search_window = dhx_wins.window("GLOBAL_SEARCH_WINDOW");
        global_search_window.bringToTop();

    } else {
        global_search_window = dhx_wins.createWindow("GLOBAL_SEARCH_WINDOW", 0, 300, 800, 600);
        global_search_window.addUserButton("reload", 0, "Reload", "Reload");
        global_search_window.addUserButton("undock", 0, "Undock", "Undock");
        global_search_window.button('help').show();
        global_search_window.centerOnScreen();
    }

    global_search_window.setText('Search results for "<i>' + search_text + '</i>"');
    global_search_window.maximize();
    global_search_window.progressOn();
    global_search_window.attachURL(search_file_path, false, true);

    global_search_window.attachEvent("onContentLoaded", function(win){
        global_search_window.progressOff();
    });

    global_search_window.button("park").attachEvent("onClick", function(win){
        win_y_position = $("#workspace").height()-25;
        position = win.getPosition();
        dimension = win.getDimension();

        last_x_position = position[0];
        last_y_position = position[1];
        last_width = dimension[0];
        win.park(false);
        // resize
        this.conf.wins._winSetSize(win._idd, 250, null, true, false);
        win.setTitle(win.getText());
        // move window to bottom
        win.setPosition(win_x_position, win_y_position);
        win_x_position = win_x_position+152;

        this.hide();
        arrange_windows();

        return false;
    });


    global_search_window.button("minmax").attachEvent("onClick", function(win){
        if (win.isParked()) {
            // restore position         
            win.setPosition(last_x_position, last_y_position);
            // restore size 
            this.conf.wins._winSetSize(win._idd, last_width, null, true, false);
            win.setTitle('');
            win.park(false);
            win.button("park").show();
            win.allowMove();
            return false;
        }

        return true;
    });


    global_search_window.button("close").attachEvent("onClick", function(win){
        win_x_position = win_x_position-152;
        win.close();
        win_x_position =1;
        arrange_windows();
        return true;
    });


    global_search_window.button("reload").attachEvent("onClick", function(){
        global_search_window.progressOn();
        global_search_window.attachURL(search_file_path, false, true);
        global_search_window.attachEvent("onContentLoaded", function(win){
            global_search_window.progressOff();
        });
    });

    global_search_window.button("undock").attachEvent("onClick", function(){
        open_window(search_file_path);
    });

    global_search_window.button("help").attachEvent("onClick", function(){
        return;
    });
}

/********************************* GRID PIVOT LOGIC BEGIN *******************************/

/**
 * Open grid pivot.
 * @param  {Object} grid_obj    DHTMLX grid obj, to find the grid structure
 * @param  {String} grid_name   Name of the grid. Used to save in filter and To fetech exec_sql in case of adiha_grid_definition's grid.
 *  index - 0 for standard report. 1 for Grid and For tree grid height of the grid
 * @param  {Number} index      Index
 * @param  {String} exec_sql    Sql to return data. No need for grid defined in adiha_grid_definition.
 * @param  {String} grid_label  Grid label
 * @param  {Number} primary_key Primary key
 * @param  {Number} report_id   Report Id
 */
open_grid_pivot = function(grid_obj, grid_name, index, exec_sql, grid_label, primary_key, report_id) {
    var table_col_script_str = '';

    if (exec_sql === undefined)  exec_sql = '';
    if (grid_label === undefined)  grid_label = '';
    if (primary_key === undefined)  primary_key = '';

    if (grid_obj != '') {
        table_col_script_str = build_pivot_columns(grid_obj, Math.abs(index));
    }

    var data = {
        "action": "spa_generate_grid_pivot_file",
        "grid_name": grid_name.replace(/\//g, '_').replace('/\/', '_'),
        "exec_sql": exec_sql,
        "col_script": table_col_script_str,
        "index": index,
        "primary_key": primary_key
    }

    var report_filter = exec_sql.replace(/"/g,"'"); // Double quotes should be replace with single quotes to avoid errors while opening pivot report.
    // report_filter = report_filter.replace(/'/g,"''");
    data = $.param(data)

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: false,
        data: data,
        success: function(data) {
            response_data = data["json"];
            if (response_data[0].errorcode == 'Success') {
                var file_name = response_data[0].filename;
                grid_label = (grid_label == '') ? response_data[0].gridlabel : grid_label;
                open_grid_pivot_callback(grid_name, file_name, grid_label, report_id, report_filter);
            } else {
                show_messagebox('Error');
            }
        }
    });
}

/**
 * Open grid pivot callback
 * 
 * @param   {String}    grid_name       Name of the grid
 * @param   {String}    file_name       File name of the grid
 * @param   {String}    grid_label      Label
 * @param   {Number}    report_id       Report ID
 * @param   {String}    report_filter   Report Filter
 */
open_grid_pivot_callback = function(grid_name, file_name, grid_label, report_id, report_filter) {
    if (typeof report_id == 'undefined') report_id = '';
    var grid_pivot_window;
    if (grid_pivot_window != null && grid_pivot_window.unload != null) {
        grid_pivot_window.unload();
        grid_pivot_window = w1 = null;
    }

    if (!grid_pivot_window) {
        grid_pivot_window = new dhtmlXWindows();
    }

    var win_title = get_locale_value('Pivot') + ' - ' + get_locale_value(grid_label);
    var win_url = js_php_path + '../adiha.html.forms/_reporting/view_report/view.pivot.report.php';

    var win = grid_pivot_window.createWindow('w1', 0, 0, 600, 400);
    win.setText(win_title);
    win.centerOnScreen();
    win.maximize();
    win.attachURL(win_url, false, {file_path: file_name, grid_name: grid_name, report_id:report_id, report_filter:report_filter});
}

/**
 * Build pivot columns.
 * @param  {Object} grid_obj Grid object
 * @param  {Number} index    Index
 */
build_pivot_columns = function(grid_obj, index) {
    var table_col_script = new Array();
    var total_col = grid_obj.getColumnsNum();

    for(cnt = 1; cnt < index; cnt++) {
        var column_label = grid_obj.getColLabel(0);
        table_col_script.push('[' + column_label + ' Group' + cnt + '] NVARCHAR(500)');
    }

    for(cnt = 0; cnt < total_col; cnt++) {
        var column_label = grid_obj.getColLabel(cnt);
        var col_type = grid_obj.getColType(cnt);
        if(column_label == '') {
            column_label = ' ';
        }

        var str = '[' + column_label + '] ';
        if (col_type == 'ro_p' || col_type == 'ro_no' || col_type == 'ed_p' || col_type == 'ed_no' || col_type == 'ron' || col_type == 'edn') {
            str += 'FLOAT '
        } else {
            str += 'NVARCHAR(500)  '
        }

        table_col_script.push(str);
    }
    var table_col_script_str = table_col_script.toString();

    return table_col_script_str;
}

/********************************* GRID PIVOT LOGIC END *******************************/

/**
 returns the user data set in leaf node of the tree
 params: tree_obj: tree object name
 id: id of the selected node
 name: name of the user data
 */

/**
 * Returns the user data set in leaf node of the tree.
 * @param  {Object} tree_obj    Tree object
 * @param  {Number} id         ID of the user
 * @param  {String} name        Name of the user
 * @return {String} User data.
 */
function get_tree_user_data(tree_obj, id, name) {
    var user_data = '';
    var no_of_children = tree_obj.hasChildren(id);
    var child = '';

    if (no_of_children > 0) {
        var child_arr = tree_obj.getSubItems(id);

        id = child_arr.split(',')[0];

        var check_child_1 = tree_obj.hasChildren(id);

        if (check_child_1 == 0) {
            user_data = tree_obj.getUserData(id, name);
        } else {
            var child_arr2 = tree_obj.getSubItems(id);
            id = child_arr2.split(',')[0];
            var check_child_2 = tree_obj.hasChildren(id);

            if (check_child_2 == 0) {
                user_data = tree_obj.getUserData(id, name);
            } else {
                var child_arr3 = tree_obj.getSubItems(id);
                id = child_arr3.split(',')[0];
                var check_child_3 = tree_obj.hasChildren(id);

                if (check_child_3 == 0) {
                    user_data = tree_obj.getUserData(id, name);
                }
            }
        }
    } else {
        user_data = tree_obj.getUserData(id, name);
    }

    return user_data;
}

/**
 * Load combo value based on parent
 * 
 * @param   {String}    combo_prop                              Properties of combo
 * @param   {Number}    i                                       Identifier
 * @param   {Object}    form                                    Form Object
 * @param   {Object}    attach_event                            Attach event
 * @param   {Boolean}   load_child_without_selecting_parent     Boolean value or can be passed 1 or 0 to load child without parent select
 * @param   {String}    callback_function                       Function name
 */
function load_dependent_combo(combo_prop, i, form, attach_event, load_child_without_selecting_parent, callback_function) {

    if (typeof attach_event === 'undefined' || attach_event === '') { attach_event = 1; }
    if (typeof load_child_without_selecting_parent  === 'undefined'){ load_child_without_selecting_parent = 0;  }
    if (!combo_prop) {
        if (callback_function && typeof(callback_function) != 'undefined' && callback_function != '') {
            callback_function();
        }
        return;
    }
    var combo_array = combo_prop.split("~");
    if (combo_array.length == i) {
        if (callback_function && typeof(callback_function) != 'undefined' && callback_function != '') {
            callback_function();
        }
        return;
    };

    var column_array = combo_array[i].split("->");
    var parent_combo_name = column_array[0];
    var dep_combo_name = column_array[1];
    var parent_combo_type = column_array[2];
    var dep_value = column_array[3];
    var child_combo_type = column_array[4];
    load_child_without_selecting_parent = column_array[5];

    var parent_combo = form.getCombo(parent_combo_name);

    if (parent_combo == null) {
        i++;
        load_dependent_combo(combo_prop, i, form, attach_event, load_child_without_selecting_parent, callback_function);
        return;
    }

    var dep_combo = form.getCombo(dep_combo_name);

    if (attach_event == 1) {
        if (parent_combo_type == 'm') {
            parent_combo.attachEvent("onCheck", function(value, state) {
                var parent_value_ids = parent_combo.getChecked();
                parent_value_ids = parent_value_ids.indexOf(",") == 0 ? parent_value_ids.substring(1, parent_value_ids.length) : parent_value_ids;
                dep_combo.clearAll();

                if (parent_value_ids == '' && load_child_without_selecting_parent == 0) {
                    dep_combo.setComboText(null);
                    dep_combo.callEvent("onCheck", [0, false]);
                    return;
                }

                var application_field_id = form.getUserData(dep_combo_name, "application_field_id");
                var url = js_dropdown_connector_url + "&call_from=dependent&application_field_id=" + application_field_id
                    + "&parent_column=" + parent_combo_name
                    + "&load_child_without_selecting_parent=" + load_child_without_selecting_parent;
                
                dep_combo.load(url, 'value=' + parent_value_ids, function() {
                    var field_value = form.getUserData(dep_combo_name, 'filter_values');
                    form.setUserData(dep_combo_name, 'filter_values', '');
                    if (field_value != '' && field_value != null) {
                        var selected_values = field_value.split(',');
                        selected_values.forEach(
                            function(value) {
                                if (value != '') {
                                    dep_combo.setChecked(dep_combo.getIndexByValue(value), true, false);
                                }
                            }
                        );
                    } else {
                        dep_combo.setComboText(null);
                    }
                    dep_combo.callEvent("onCheck", [0, false]);
                });
            });
        } else {
            parent_combo.attachEvent("onChange", function(value) {
                dep_combo.clearAll();

                if ((value == "" || value == null) && load_child_without_selecting_parent == 0) {
                    dep_combo.setComboValue(null);
                    dep_combo.setComboText(null);
                    return;
                }

                var application_field_id = form.getUserData(dep_combo_name, "application_field_id");
                var field_value = form.getUserData(dep_combo_name, 'filter_values');
                var url = js_dropdown_connector_url + "&call_from=dependent&application_field_id=" + application_field_id + "&parent_column=" + parent_combo_name
                    + "&load_child_without_selecting_parent=" + load_child_without_selecting_parent + "&SELECTED_VALUE=" + field_value;

                dep_combo.load(url, 'value=' + value, function() {
                    var field_value = form.getUserData(dep_combo_name, 'filter_values');
                    if (field_value != '' && field_value != null) {
                        dep_combo.callEvent("onChange", [field_value, false]);
                        form.setUserData(dep_combo_name, 'filter_values', '');
                    }
                });
            });
        }
    }

    dep_combo.clearAll();
    var value = form.getItemValue(parent_combo_name);

    if (parent_combo_type == 'm') {
        parent_combo.setChecked(parent_combo.getIndexByValue(''), false, false);
        value = parent_combo.getChecked();
    }

    if (load_child_without_selecting_parent == 1 && value == "") {
        value = 'NULL'
    }

    var application_field_id = form.getUserData(dep_combo_name, "application_field_id");
    if (value != "" && dep_combo.getVersion() == '1') {
        var url = js_dropdown_connector_url + "&call_from=dependent&application_field_id="
            + application_field_id + "&parent_column=" + parent_combo_name + "&load_child_without_selecting_parent=" + load_child_without_selecting_parent;

        dep_combo.load(url, 'value=' + value, function() {
            if (child_combo_type == 'm') {
                $.each(dep_value.split(','), function(index, value) {
                    dep_combo.setChecked(dep_combo.getIndexByValue(value), true, false);
                });
            } else {
                dep_combo.setComboValue(dep_value);
            }

            i++;
            load_dependent_combo(combo_prop, i, form, attach_event,load_child_without_selecting_parent, callback_function);
        });
    } else {
        i++;
        load_dependent_combo(combo_prop, i, form, attach_event,load_child_without_selecting_parent, callback_function);
    }
}

/**
 * Generate error message
 * 
 * @param   {Object}    tab_obj     Created object of tab
 */
function generate_error_message(tab_obj) {
    var text = '<span style="color:red;">' + get_locale_value('One or more data are missing or invalid.Please Check!') + '</span>';
    success_call(text, 'error');
    if (tab_obj != undefined && tab_obj != "") {
        tab_obj.setActive();
    }
    return;

}


/**
 * Generate document in temp note
 *
 * @param   {Number}    object_id               Object id
 * @param   {String}    document_category       Document Category
 * @param   {String}    document_sub_category   Document sub category
 * @param   {Function}  callback_function       Callback function
 * @param   {String}    temp_generate           Flag to temp generate
 * @param   {String}    get_generated           Flag to get generated
 */
generate_document_for_view = function(object_id, document_category, document_sub_category, callback_function, temp_generate, get_generated) {
    if (typeof(callback_function) == 'undefined') callback_function = '';
    if (typeof(temp_generate) == 'undefined') temp_generate = 1;
    if (typeof(get_generated) == 'undefined') get_generated = 1;

    data =  {
        "action": "spa_generate_document",
        "filter_object_id": object_id,
        "document_category":document_category,
        "document_sub_category": document_sub_category,
        "temp_generate": temp_generate,
        "get_generated": get_generated,
        "show_output": 1,
		"user_login_id": js_user_name
    };
    data = $.param(data);

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: true,
        data: data,
        success: function(result) {
            var return_data = result['json'];

            if (return_data[0].status == 'Success') {
                var file_path = return_data[0].file;
                window.open(js_php_path + 'force_download.php?path=' + file_path);
            } else {
                dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text: return_data[0].message
                });
            }

            if (callback_function != '')
                eval(callback_function + '(return_data[0].status,file_path)');

        }
    });
}

/**
 * get Grid Header alignment string
 *
 * @param   {Array}     column_alignment   Column alignment array
 *
 * @return  {String}                        Alignment String
 */
function header_alignment(column_alignment) {
    var header_alignment;
    var counter = 0;
    $.each(column_alignment.split(','), function(index, value) {
        if (counter == 0)
            header_alignment = 'text-align:' + value ;
        else
            header_alignment += ',text-align:' + value ;
        counter ++
    })
    return header_alignment;
}

/**
 * Loads dependent combo
 *
 * @param   {Array}     combo_prop  Combo properties array
 * @param   {Number}    i           Index
 * @param   {Object}    form        Form Object
 */
function load_dependent_combo1 (combo_prop, i, form) {

    //if (typeof attach_event === 'undefined') { attach_event = 1; }  

    var combo_array = combo_prop.split("~");
    if (combo_array.length == i) {
        ns_match.deal_layout.cells('a').progressOff();
        ns_match.deal_layout.cells('b').progressOff();
        return;
    };

    ns_match.deal_layout.cells('a').progressOn();
    ns_match.deal_layout.cells('b').progressOn();

    var column_array = combo_array[i].split("->");
    var parent_combo_name = column_array[0];
    var dep_combo_name = column_array[1];
    var parent_combo_type = column_array[2];
    var dep_value = column_array[3];
    var child_combo_type = column_array[4];

    var parent_combo = form.getCombo(parent_combo_name);
    var dep_combo = form.getCombo(dep_combo_name);
    var value = form.getItemValue(parent_combo_name);

    /* for(j = 0; j < combo_array.length; j++) {
         load_dependent_combo_event(combo_array[j], form, 'd');
     }
     */

    if (parent_combo_type == 'm') {
        //parent_combo.setChecked(parent_combo.getIndexByValue(''), false);
        value = parent_combo.getChecked();
        value = value.indexOf(",") == 0 ? value.substring(1, value.length) : value;
    }



    if (parent_combo == null) {
        alert('')
        i++;
        load_dependent_combo1(combo_prop, i, form, attach_event);
        return;
    }


    dep_combo.clearAll();
    dep_combo.setComboValue(null);
    dep_combo.setComboText(null);

    application_field_id = form.getUserData(dep_combo_name, "application_field_id");
    if (value != "") {
        url = js_dropdown_connector_url + "&call_from=dependent&value="+value+"&application_field_id="+application_field_id+"&parent_column=" +parent_combo_name
            + '&SELECTED_VALUE=' + dep_value;


        dep_combo.load(url, function() {
            /* if (child_combo_type == 'm') {
                 $.each(dep_value.split(','), function(index, value) {
                     dep_combo.setChecked(dep_combo.getIndexByValue(value), true);
                 });

             } else {
                 dep_combo.setComboValue(dep_value);
             }

             for(j = 0; j < combo_array.length; j++) {
                 load_dependent_combo_event(combo_array[j], form, 'a');
             }*/

            i++;
            load_dependent_combo1(combo_prop, i, form);
        });
    } else {
        /* for(j = 0; j < combo_array.length; j++) {
              load_dependent_combo_event(combo_array[j], form, 'a');
         }*/
        i++;
        load_dependent_combo1(combo_prop, i, form);
    }

}

/**
 * Post callback function
 *
 * @param   {Array}     arr_selected_rows   Array of elected rows
 * @param   {Object}    form_object         Form object
 * @param   {String}    browse_id           Browse id
 */
function post_callback(arr_selected_rows, form_object, browse_id) {
    eval('var parent_form = parent.' + form_object + '.getForm()');
    var hidden_field_id = browse_id.replace("label_", "");
    parent_form.setItemValue(browse_id, arr_selected_rows);
    parent_form.setItemValue(hidden_field_id, arr_selected_rows);
    // parent.new_browse.close();
    parent.new_browse.setModal(false);
    parent.new_browse.hide();
}

/**
 * Opens dashboard
 */
open_my_dashboard = function() {
    if (typeof(dhx_wins) === "undefined" || !dhx_wins) {
        dhx_wins = new dhtmlXWindows();
    }

    collapse_main_menu_navbar();

    var window_id = 'w_' + js_user_name;

    if (dhx_wins.isWindow(window_id)) {
        bring_to_top(window_id);
        return
    }

    var form_path = app_form_path;
    var win_title = "My Dashboard";

    var win_url = form_path + '/_reporting/view_report/my.dashboard.main.php';

    var win = dhx_wins.createWindow(window_id, 0, 0, 600, 400);
    win.setText(win_title);
    win.centerOnScreen();
    win.maximize();
    var params = {}

    dhx_wins.window(window_id).addUserButton("reload", 0, "Reload", "Reload");
    dhx_wins.window(window_id).addUserButton("undock", 0, "Undock", "Undock");

    dhx_wins.window(window_id).button("reload").attachEvent("onClick", function(){
        dhx_wins.window(window_id).progressOn();
        dhx_wins.window(window_id).attachURL(win_url, false, params);
        dhx_wins.window(window_id).attachEvent("onContentLoaded", function(win){
            dhx_wins.window(window_id).progressOff();
        });
    });

    dhx_wins.window(window_id).button("undock").attachEvent("onClick", function(){
        open_window(win_url);
    });

    win.attachURL(win_url, false, params);

}

/**
 * Opens pinned pivot report
 *
 * @param   {String}    view_id     View id
 */
open_pinned_pivot_report = function(view_id) {
    data = {"action": "spa_pivot_report_view", "flag":"y", "view_id":view_id};
    adiha_post_data('return', data, '', '', 'open_pinned_pivot_report_callback');
}

/**
 * Opens pinned pivot report callback
 *
 * @param   {Array}     return_val     Return value
 */
open_pinned_pivot_report_callback = function(return_val) {
    if (typeof(dhx_wins) === "undefined" || !dhx_wins) {
        dhx_wins = new dhtmlXWindows();
    }

    collapse_main_menu_navbar();

    var form_path = app_form_path;
    var win_title = "Pivot - " + return_val[0].name;
    var win_url = form_path + '/_reporting/view_report/view.pivot.report.php';
    var window_id = 'w' + return_val[0].view_id;
    var win = dhx_wins.createWindow(window_id, 0, 0, 600, 400);
    win.setText(win_title);
    win.centerOnScreen();
    win.maximize();

    var params = {
        report_filter:return_val[0].params,
        paramset_hash:return_val[0].paramset_hash,
        paramset_id:return_val[0].paramset_id,
        items_combined:return_val[0].component_id,
        report_name:return_val[0].report_name,
        view_id:return_val[0].view_id,
        is_pin:'y',
        report_id:return_val[0].report_id
    }

    win.attachURL(win_url, false, params);
}


/**
 * Date format converter
 * 
 * @param  {Object}     input_date      Input date of the app
 * @return {Object}                     New date.
 */
function app_date_format_converter(input_date) {
    var app_date_format = user_date_format;
    var new_date = '';

    if (app_date_format == '%j.%n.%Y' || app_date_format == '%d.%m.%Y') {
        date_split = input_date.split('.');
        new_date = date_split[2] + '-' + date_split[1] + '-' + date_split[0];
    }  else if (app_date_format == '%j-%n-%Y' || app_date_format == '%d-%m-%Y') {
        date_split = input_date.split('-');
        new_date = date_split[2] + '-' + date_split[1] + '-' + date_split[0];
    } else if (app_date_format == '%j/%n/%Y' || app_date_format == '%d/%m/%Y') {
        date_split = input_date.split('/');
        new_date = date_split[2] + '-' + date_split[1] + '-' + date_split[0];
    } else if (app_date_format == '%n/%j/%Y' || app_date_format == '%m/%d/%Y') {
        date_split = input_date.split('/');
        new_date = date_split[2] + '-' + date_split[0] + '-' + date_split[1];
    } else if (app_date_format == '%n-%j-%Y' || app_date_format == '%m-%d-%Y') {
        date_split = input_date.split('-');
        new_date = date_split[2] + '-' + date_split[0] + '-' + date_split[1];
    } else {
        new_date = input_date;
    }

    return new_date;
}

/**
 * Load move event
 * @param   {Object}    form_object     Load form object
 * @param   {String}    lists_json      List JSON file
 */
function attach_move_event(form_object, lists_json){
    form_object.attachEvent('onButtonClick', function(id){
        for (var i = 0; i < lists_json.length; i++) {
            var a = lists_json[i];
            for (var property in a) {
                if (a.hasOwnProperty(property)){
                    if(id ==  a[property]){
                        if(property == 'add_button')
                            move_option(a.from, a.to);
                        else if(property == 'remove_button')
                            move_option(a.to, a.from);
                    }
                }
            }
        }
    });

    for (var i = 0; i < lists_json.length; i++) {
        var a = lists_json[i];
        for (var property in a) {
            if (a.hasOwnProperty(property) && (property == 'from' || property == 'to')) {
                var from_list = form_object.getSelect(a[property]);

                from_list.ondblclick = (function(a, property){
                    return function(){
                        if(property == 'from')
                            move_option(a.from, a.to);
                        else if(property == 'to')
                            move_option(a.to, a.from);
                    }
                })(a, property);
            }
        }
    }

    /**
     * Move option
     * @param  {String} from From value
     * @param  {String} to   To value
     */
    function move_option(from, to) {
        opt_from = form_object.getSelect(from);
        var options_to = form_object.getSelect(to);

        opt_from_sel = form_object.getItemValue(from);

        $('#' + $(opt_from).attr('id')).find('option').each(function(index, el) {
            if(opt_from_sel.indexOf($(this).attr('value')) != -1) {
                options_to.add(new Option($(this).text().trim(), $(this).attr('value')));
                $(this).remove();
            }

        });
    }

}

/**
 * Function added to create window for password validation
 * @param   {Function}      callback_function   Call back function
 * @param   {Object}        param               Parameter
 */
function is_user_authorized(callback_function,param) {
    var callback_string_param = '';
    if (param && param != '' && param != undefined) {
		// Added below logic to create Object.keys function if it does not exist. Due to this lower IE versions may produce error.
        if (!Object.keys) {
            Object.keys = function(obj) {
                var keys = [];

                for (var i in obj) {
                    if (obj.hasOwnProperty(i)) {
                        keys.push(i);
                    }
                }

                return keys;
            };
        }
        
        var key_first = Object.keys(param)[0];
        callback_string_param += "'" + param[key_first] + "'";
        delete param[key_first];
        for (var key in param) {
            if (param.hasOwnProperty(key)) {
                callback_string_param += ",'" + param[key] + "'";
            }
        }
    }

    var password_form_data = [
        {type: "settings", labelWidth: 'auto', inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft:ui_settings['offset_left']},
        {type: 'newcolumn'},
        {type: "password", name: "password", label: "Password", value : "",inputTop: 10, labelLeft:  20, labelTop: 90, className: 'system_password'},
        {type: "button", value: "Ok", img: "tick.png", inputTop: 10, inputLeft: 80}
    ];
    
    var password_window = new dhtmlXWindows();
    var pwd_win = password_window.createWindow('w1', 0, 0, 300, 150);
    pwd_win.setText("Enter Password");
    pwd_win.centerOnScreen();
    pwd_win.setModal(true);
    var password_form = pwd_win.attachForm(get_form_json_locale(password_form_data), true);
    password_form.getInput('password').autocomplete = "new-password"; //Added to disable autofill of password
    password_form.attachEvent("onEnter", function(name) {
        password_form.callEvent("onButtonClick", ["password"]);
    });
    password_form.attachEvent("onButtonClick", function(name) {
        var password = password_form.getItemValue("password");
        var password_data = {
            "password": password,
            "salt": "pioneer"
        };
        var url = js_php_path + "validate_password.php";
        var data = $.param(password_data);
        $.ajax({
            type: "POST",
            dataType: "json",
            url: url,
            data: data,
            async:false,
            success: function(result) {
                if (result == '1') {
                    pwd_win.close();
                    eval(callback_function +'(' + callback_string_param + ')');
                } else {
                    show_messagebox("Invalid Password. Enter correct password to proceed further.");
                }
            },
            error : function (result) {
                show_messagebox("Error while processing. Try again.");
            }
        });
    });
}

function open_configuration_manager_auth(file_path, window_name, window_label, function_id, call_from_hyperlink) {
    collapse_main_menu_navbar();
    if (dhx_wins && dhx_wins != undefined) {
        if (dhx_wins.isWindow(window_name)) {
            open_menu_window(file_path, window_name, window_label, function_id, call_from_hyperlink);
        } else {
            var param_obj = {
                "param1" : file_path,
                "param2" : window_name,
                "param3" : window_label,
                "param4" : function_id,
                "param5" : (call_from_hyperlink) ? call_from_hyperlink : ''
            };
            is_user_authorized('open_menu_window', param_obj);
        }
    }
}

/**
 * Returns all the values of the particular column of grid as an array.
 * @param  {Object} grid_obj       Grid Object Value
 * @param  {Number} column_index   Column Index Value
 * @return {Array} Values in Grid column.
 */
function get_columns_value(grid_obj, column_index) {
    var values = [];
    grid_obj.expandAll();

    for (var i = 0; i < grid_obj.getRowsNum(); i++) {
        if (grid_obj.cells2(i, column_index).getValue() == '') continue;

        values.push(grid_obj.cells2(i, column_index).getValue());
    }

    return values;
}

/**
 * Layout cell hide
 * 
 * @param   {Object}    layout_cell_obj     Description
 */
function layout_cell_hide(layout_cell_obj) {
    layout_cell_obj.expand();
    layout_cell_obj.hideHeader();
    layout_cell_obj.fixSize(false, true);
    layout_cell_obj.setMinWidth(0);
    layout_cell_obj.setWidth(0);
    layout_cell_obj.setMinHeight(0);
    layout_cell_obj.setHeight(0);

    //  $('.' + layout_cell_obj.cell.className).find('.dhxlayout_sep').hide();

    //  var layout_class = layout_cell_obj.cell.className;
    //  //alert(layout_class);

    //  layout_cell_obj.cell.className = layout_class + ' __hidden_layout__';

    //  var position = $('.__hidden_layout__').next('.' + layout_class).position();

    // $('.__hidden_layout__').next('.' + layout_class).css("top", position.top - 9 + 'px');


    // //$('.dhxlayout_cont').css('margin-top', '-9px');

    //  layout_obj.attachEvent("onCollapse", function(a){
    //      layout_cell_obj = layout_obj.cells(below_cell);
    //      alert(a + ' ' +below_cell);

    //      var position = $('.dhx_cell_layout').position();


    //      var layout_class = layout_cell_obj.cell.className;
    //      alert(position.top);


    //  });

    layout_cell_obj.cell.style.display = 'none';
    $(layout_cell_obj.cell).parent().find('.dhxlayout_sep').remove();
    var t = layout_cell_obj.cell.nextElementSibling.style.top;
    layout_cell_obj.cell.nextElementSibling.style.top = '0px';
    var a = $(layout_cell_obj.cell.nextElementSibling).height();
    $(layout_cell_obj.cell.nextElementSibling).height(a + t);
    var inner_h = $(layout_cell_obj.cell.nextElementSibling).find('.dhx_cell_cont_layout').height();
    $(layout_cell_obj.cell.nextElementSibling).find('.dhx_cell_cont_layout').height(inner_h + t);
}

/*******************Grid Row Popup functions START******************************************/
grid_row_popup = {};
grid_row_form = {};

/**
 * Create grid row popup
 * 
 * @param  {Object}     grid_obj    Grid object
 */
function create_grid_row_popup(grid_obj) {
    var active_object_id = grid_obj._ui_seed;
    var grid_col_ids = grid_obj.columnIds;
    var grid_header = grid_obj.hdrLabels;
    var grid_col_types = grid_obj.cellType;
    var grid_col_visibility = grid_obj._ivizcol;
    var date_format = grid_obj._dtmask;
    var server_date_format = grid_obj._dtmask_inc;
    var combo_arr = new Array();
    var grid_col_visibility2 = new Array();

    //console.log(grid_obj);

    var img1 = "<img class='grid_row_popup_save_img' src='"+ js_php_path +"components/lib/adiha_dhtmlx/themes/dhtmlx_" + default_theme + "/imgs/dhxmenu_web/save.gif' style='position:relative;top:4px;'>  Ok";
    var img2 = "<img class='grid_row_popup_cancel_img' src='"+ js_php_path +"components/lib/adiha_dhtmlx/themes/dhtmlx_" + default_theme + "/imgs/dhxmenu_web/close.gif' style='position:relative;top:4px;'>";
    var form_data_str = '[{"type":"settings","position":"label-top"},{"type": "block", "width": "750", "blockOffset": 0 , "list": [{type: "button",   name: "ok", value: "'+img1+'", "position":"label-top","offsetLeft":"15"},{"type":"newcolumn"},{type: "button",   name: "cancel", value: "'+ img2 +'", "position":"label-top","offsetLeft":"15"}]},{"type": "block", "width": "750", "height":"800", "blockOffset": 0 , "list": [';
    var form_data_type = '';
    var date_format_str = '';
    for (i = 0; i < grid_col_ids.length; i++) {
        if (grid_col_types[i] == 'ed' && 'ron') {
            form_data_type = 'input';
        } else if (grid_col_types[i] == 'dhxCalendarA') {
            form_data_type = 'calendar';
            date_format_str = ',"dateFormat":"' + date_format + '","serverDateFormat":"'+ server_date_format +'"';
        } else {
            if (grid_col_types[i] == 'combo') {
                combo_arr.push(grid_col_ids[i]);
            }
            form_data_type = grid_col_types[i];
        }
        if (grid_col_visibility == undefined) {
            grid_col_visibility2[i] = "false";
        } else {
            grid_col_visibility2[i] = grid_col_visibility[i];
        }

        if (grid_col_visibility2[i] == "false") {
            form_data_str += '{"type": "'+form_data_type+'", "name":"'+grid_col_ids[i]+'", "label":"'+grid_header[i]+'" ' + date_format_str + ', "position":"label-top","offsetLeft":"15","labelWidth":"auto","inputWidth":"230"},{"type":"newcolumn"},';
        }

    }
    form_data_str += ']}]';
    //console.log(form_data_str);

    grid_row_popup[active_object_id] = new dhtmlXPopup();
    grid_row_form[active_object_id] = grid_row_popup[active_object_id].attachForm();
    grid_row_form[active_object_id].load(form_data_str);


    grid_row_form[active_object_id].bind(grid_obj);

    grid_row_form[active_object_id].attachEvent("onButtonClick", function(name){
        if (name == 'ok') {
            grid_row_form[active_object_id].save() //will push updates back to the master list
        } else {
            grid_row_form[active_object_id].unbind(grid_obj);
            grid_row_form[active_object_id].bind(grid_obj);
        }
        grid_row_popup[active_object_id].hide();
    });

    grid_obj.attachEvent("onRightClick",function(id,ind,obj) {
        if (obj.ctrlKey) {
            for(var i=0;i<combo_arr.length;i++) {
                var column_index = grid_obj.getColIndexById(combo_arr[i]);
                var my_Combo = grid_obj.getColumnCombo(column_index);
                var dhx_combo = grid_row_form[active_object_id].getCombo(combo_arr[i]);
                dhx_combo.setSize(230);
                dhx_combo.clearAll();
                my_Combo.forEachOption(function(optId){
                    dhx_combo.addOption(optId.value, optId.text);
                });
                dhx_combo.enableFilteringMode('between');
            }
            grid_obj.selectRowById(id,false,true,true);
            //css
            $('.grid_row_popup_save_img').parent().parent('.dhxform_btn').parent().parent().addClass('grid_row_popup_form_button');
            $('.grid_row_popup_cancel_img').parent().parent('.dhxform_btn').parent().parent().addClass('grid_row_popup_form_button_cancel');
            $('.grid_row_popup_form_button').parent().css('margin-left','-15px');

            show_grid_row_popup(obj, active_object_id);

            grid_row_popup[active_object_id].attachEvent("onBeforeHide", function(type, ev, id) {
                //console.log(type)
                if (type == 'click' || type =='esc') {
                    grid_row_form[active_object_id].unbind(grid_obj);
                    grid_row_form[active_object_id].bind(grid_obj);
                    hide_all_grid_row_popups(0);
                }
                return true;
            });

        }

    });

}

/**
 * Display the grid row popup.
 * @param  {Object} inp Mouse event to focus input
 * @param  {Number} active_object_id Active object id
 */
function show_grid_row_popup(inp, active_object_id) {
    hide_all_grid_row_popups(0);
    if (!grid_row_popup[active_object_id]) {
        grid_row_popup[active_object_id] = new dhtmlXPopup();
        grid_row_popup[active_object_id].attachHTML("You can enter some text into here");
    }
    if (grid_row_popup[active_object_id].isVisible()) {
        grid_row_popup[active_object_id].hide();
    } else {
        var xx = ($( window ).width() - inp.clientX <260) ?-5 : 5;
        var x = inp.clientX+xx; // returns left position related to window
        var y = inp.clientY+5; // returns top position related to window
        var w = 0;
        var h = 0;
        grid_row_popup[active_object_id].show(x,y,w,h);
    }
}

/**
 * Hide Grid row popup
 * @param   {Number}    active_object_id    Takes the active object id
 */
function hide_grid_row_popup(active_object_id) {
    if (grid_row_popup[active_object_id]) grid_row_popup[active_object_id].hide();
}


/**
 * Hide all popups that is bind to grid
 *
 * @param   {Boolean}   is_active   Flag for active
 */
function hide_all_grid_row_popups(is_active) {
    /*
    var active_tab_id = view_user_defined_table.tabbar.getActiveTab();
    if(active_tab_id) {
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;        
        for (var key in grid_row_popup) {
            if (grid_row_popup.hasOwnProperty(key)) {
                if (is_active == 0 || key != active_object_id) {
                    grid_row_popup[key].hide();
                }
            }
        }
    }
    */
    for (var key in grid_row_popup) {
        if (grid_row_popup.hasOwnProperty(key)) {
            if (is_active == 0) {
                grid_row_popup[key].hide();
            }
        }
    }
}
/*******************Grid Row Popup functions END******************************************/

/**
 * Load Grid Menu in Layout cell header
 * 
 * @param   {Object}        layout_cell_obj         Layout cell object to which header menu needs to be shown
 * @param   {Mixed}         menu_json               Menu json/array json
 * @param   {String}        on_click_function       Function to be called on click of menu item
 * @param   {String}        align                   Left/right menu alignment : Default Left
 * @param   {Boolean}       multi_menu              Multiple menu to be shown in same header : Defualt false
 * @return  {Mixed}                                 Menu object or menu object array in case of multi_menu true.
 */
function layout_header_load_menu (layout_cell_obj, menu_json, on_click_function, align, multi_menu) {
    if (multi_menu == undefined || multi_menu == "") multi_menu = false;
    if (align == undefined || align == "") align = 'left';

    var header_text =layout_cell_obj.getText();
    if (align == 'left') {
        header_text = '<div style="text-align:center;">' + header_text + '</div>';
        align = 'menu_align_left';
    } else {
        align = 'menu_align_right';
    }

    var menu_close_icon = js_image_path + 'dhxtoolbar_web/close.gif';
    var menu_icon = js_image_path + 'dhxtoolbar_web/hamburger.png';
    var shift_pos = true;
    if (header_text.indexOf("undock_custom") == -1 && !layout_cell_obj.isUndockArrowVisible() && align == 'menu_align_right')
        shift_pos = false;

    var cell = dhx.uid();
    layout_cell_obj._cell_uid = cell;
    layout_cell_obj._menu_uid = cell;
    var menu_min_id = '__menu_min_' + cell + '__';
    var close_id = '__close_' + cell + '__';

    if (!multi_menu) {
        var menu_json_copy = menu_json;
        menu_json = [];
        menu_json[cell] = menu_json_copy;
        var menu_id = '__menu_' + cell + '__';
    } else {
        var tab_obj = layout_cell_obj.getAttachedObject();
        layout_cell_obj._menu_uid = tab_obj.getActiveTab();
        tab_obj.attachEvent("onTabClick", function(id, last_id) {
            layout_cell_obj._menu_uid = id;
            $('#__menu_' + last_id + "__").hide();
            $('#' + menu_min_id).show();
        });
    }

    Object.keys(menu_json).forEach(function(key, index) {
        var menu_id = '__menu_' + key + '__';
        var close_id = '__close_' + key + '__';
        var close_menu_text = get_locale_value('Close Menu');
        header_text +=
            '<div class="__custom_header__ __menu__ menu_item_holder ' + align + '" id="' + menu_id + '"' +
                (shift_pos ? ' style="right:15px;"' : '') + '>' +
                '<div class="__close__ menu_close_button ' + align + '" id="' + close_id + '">' +
                        '<img src="' + menu_close_icon + '" alt="' + close_menu_text + '" title="' + close_menu_text + '"></div></div>';
    }.bind(menu_json));
    
    var open_menu_text = get_locale_value('Open Menu');
    header_text += '<div class="menu_open_button ' + align + ' __menu_min__ ' + menu_min_id + '" id="' + menu_min_id + '"' +
                (shift_pos ? ' style="right:20px;width:20px;"' : ' style="width:20px;"') + '>' +
                '<img src="' + menu_icon + '" alt="' + open_menu_text + '" title="' + open_menu_text + '"></div>';

    layout_cell_obj.setText(header_text);

    var return_menu_obj = [];
    Object.keys(menu_json).forEach(function(key, index) {
        var menu_id = '__menu_' + key + '__';
        var close_id = '__close_' + key + '__';

        var menu_obj = new dhtmlXMenuObject(menu_id);
        menu_obj.setIconsPath(js_image_path + "dhxmenu_web/");
        menu_obj.loadStruct(this[key]);
        menu_obj.attachEvent("onClick", on_click_function);

        return_menu_obj[key] = menu_obj;

        if (multi_menu) {
            var tab_obj = layout_cell_obj.getAttachedObject();
            var menu_container_obj = tab_obj.tabs(key);
        } else {
            var menu_container_obj = layout_cell_obj;
        }

        var dup_menu_obj = menu_container_obj.attachMenu();
        dup_menu_obj.setIconsPath(js_image_path + "dhxmenu_web/");
        dup_menu_obj.loadStruct(this[key]);
        dup_menu_obj.attachEvent("onClick", on_click_function);

        menu_obj.attachEvent("onItemStateChanged", function(name, state) {
            if (state == "enabled")
                dup_menu_obj.setItemEnabled(name);
            else
                dup_menu_obj.setItemDisabled(name);
        });

        menu_obj.attachEvent("onItemVisibilityChanged", function(name, state) {
            if (state)
                dup_menu_obj.showItem(name);
            else
                dup_menu_obj.hideItem(name);
        });

        menu_container_obj.hideMenu();

        $('#' + close_id).css({ transform: 'scale(.9)' ,  '-moz-transform': 'scale(.9)'});

        $('#' + close_id).click(function() {
            if (multi_menu) {
                var tab_obj = layout_cell_obj.getAttachedObject();
                var tab_id = tab_obj.getActiveTab();
                $('#__menu_' + tab_id + "__").toggle();
            } else {
                $('#' + menu_id).toggle();
            }

            $('#' + menu_min_id).show();
        });

        $('#' + menu_id ).hover(function() {
            $('#' + close_id).css('display', 'inline-block');
        }, function() {
            $('#' + close_id).hide();
        });
    }.bind(menu_json));

    layout_cell_obj.layout._getMainInst().attachEvent("onDock", function(name) {
        if (layout_cell_obj.getId() == name) {
            if (multi_menu) {
                var tab_obj = this._getMainInst().cells(name).getAttachedObject();
                var tab_id = tab_obj.getActiveTab();
                tab_obj.tabs(tab_id).hideMenu();
            } else {
                layout_cell_obj.hideMenu();
            }

            $('.' + menu_min_id).show();
        }
    });

    layout_cell_obj.layout._getMainInst().attachEvent("onBeforeUnDock", function(name) {
        if (layout_cell_obj.getId() == name) {
            if (multi_menu) {
                var tab_obj = this._getMainInst().cells(name).getAttachedObject();
                var tab_id = tab_obj.getActiveTab();
                tab_obj.tabs(tab_id).showMenu();
            } else {
                layout_cell_obj.showMenu();
            }

            $('.' + menu_min_id).hide();
        }
    });

    $('#' + menu_min_id).click(function() {
        if (layout_cell_obj.isCollapsed()) {
            layout_cell_obj.expand();
        }

        if (multi_menu) {
            var tab_obj = layout_cell_obj.getAttachedObject();
            var tab_id = tab_obj.getActiveTab();
            $('#__menu_' + tab_id + "__").toggle();
        } else {
            $('#' + menu_id).toggle();
        }

        $('#' + menu_min_id).hide();
    });

    return (!multi_menu ? return_menu_obj[cell] : return_menu_obj);
}

/**
 * Get static data value.
 * @param  {String} dyn_date_val Dynamic Date Value
 * @return {String}              Static Date Value.
 */
function get_static_date_value(dyn_date_val) {
    dyn_date_val = (dyn_date_val == null) ? '' : dyn_date_val;
    if(dyn_date_val == '' || dyn_date_val.indexOf('|') == -1) {
        return dyn_date_val;
    } else {
        return '';
    }
}

/**
 * Builds the Parameter XML for excel addin filter [Equivalent function build_excel_parameters in adiha_php_functions.3.0.php]
 * Any changes needs to be done in both files functions
 * 
 * @param   {Array}     params      Filters information
 */
function build_excel_parameters(params) {
    var filter_in_xml = '<Parameters>';

    params.forEach(function(i) {
        var dyn_cal_val = Array();
        if (i['filter_value'] != null)
            dyn_cal_val = i['filter_value'].split('|');
        else
            dyn_cal_val[0] = i.filter_value;

        if (dyn_cal_val.length > 1 && i['widget_id'] == '6') { // case for type dynamic date and dynamic date selected
            /* added as the new formate doesnot contain static date as first i.e 45606|0|106400|n*/
            dyn_cal_val[4] = dyn_cal_val[3]; dyn_cal_val[3] = dyn_cal_val[2];
            dyn_cal_val[2] = dyn_cal_val[1]; dyn_cal_val[1] = dyn_cal_val[0];
            dyn_cal_val[0] = "";
        } else if (i['widget_id'] == '6' && dyn_cal_val.length == 1) {  // case for type static date and static date selected
            /*added as the new formate doesnot contains dynamic date part when static date is selected */
            dyn_cal_val[1] = 0;dyn_cal_val[2] = 0;dyn_cal_val[3] = "";dyn_cal_val[4] = "n";
        }
        /*
            # Modified to not build XML for those fields which have null values ...
        */
        if ((dyn_cal_val[0] != '' && dyn_cal_val[0] != null) || (dyn_cal_val.length > 1 && (dyn_cal_val[1] != '' || dyn_cal_val[1] != null ))) {
			
			var filter_value_new = '';
			if (i['widget_id'] == '6') {
				filter_value_new = dyn_cal_val[0];
			} else {
				filter_value_new = i['filter_value'];
			}
			
			if(filter_value_new) {
				filter_value_new = filter_value_new.replace(/,/g, '!');
			} else {
				filter_value_new = '';
			}
            filter_in_xml += '<Parameter>'
                + '<Name>' + i['filter_name'] + '</Name>'
                + '<Value>' + filter_value_new + '</Value>'
                + '<DisplayLabel>' + i['filter_display_label'] + '</DisplayLabel>'
                + '<DisplayValue>' + (i['widget_id'] == '6' ? dyn_cal_val[0] : i['filter_display_value']) + '</DisplayValue>'
                +
                (i['widget_id'] == '6' ?
                        '<OverwriteType>' + dyn_cal_val[1] + '</OverwriteType>'
                        + '<AdjustmentDays>' + dyn_cal_val[2] + '</AdjustmentDays>'
                        + '<AdjustmentType>' + dyn_cal_val[3] + '</AdjustmentType>'
                        + '<BusinessDay>' + dyn_cal_val[4] + '</BusinessDay>'
                        : ''
                )
                + '</Parameter>';
        }
    });

    filter_in_xml += '</Parameters>';
    return filter_in_xml;
}

//Below functions are moved from adiha_function.js

/**
 * window.close is rewrited if parent iframe with name 'main' exists only
 * the window.close rewrite with parent.close was required so that all pages with frames didn't need to be changed
 * for normal pages without main frame, window.close is not rewritten and it works as it usually does
 */
if (parent.frames['main']) {
    window.close =  function() {
        window.parent.close();
    };
}

/**
 * Removes favourite.
 * @param  {String}     function_id     Function ID
 */
function remove_from_favourite(function_id) {
    data = {"action": "spa_favourites", "flag":"d", "function_id":function_id};
    adiha_post_data("return_val", data, '', '', 'refresh_favourites');

    if (!e) var e = window.event;
    var ua = window.navigator.userAgent;
    var msie = ua.indexOf("MSIE ");
    msie = parseInt(ua.substring(msie + 5, ua.indexOf(".", msie)));
    if (msie >= 10 || msie == 0) {
        e.cancelBubble = true;
        if (e.stopPropagation) e.stopPropagation();
    }
}

/**
 * Add to favourite
 * @param   {String}    function_id     Function ID
 * @param   {String}    group_id        Groud ID
 * @param   String}     group_name      Group name
 */
function add_to_favourite(function_id, group_id, group_name, win_obj) {
    data = {"action": "spa_favourites", "flag":"i", "function_id":function_id, "group_name":group_name, "group_id":group_id, "product_category":product_id};
    var callback_fn = (function (result) {refresh_favourites(win_obj , result); });
    adiha_post_data('return_array', data, '', '', callback_fn);
}

/**
 * Get grid value
 * 
 * @param   {String}    gridname    Name of a grid from where value is to be retrive
 * @param   {Number}    clms        Column number
 * @return                          Grid value
 */
function getGridvalue(gridname, clms) {
    //TODO: verify if we need this function. Found in flow.optimization.template.php only.
    try {
        y = "parent." + gridname + ".getGridData(" + clms + ");";
        x = eval(y);
        if (x == "" || x == undefined) {
            x = "NULL"
        }

        if (x == "+") {
            return x;
        } else {
            return (x);
        }
    } catch (exceptions) {
        return "NULL";
    }
}


/**
 * Removes spaces present before string
 * 
 * @param   {String}    str     string with spaces
 * @return  {String}            without spaces behind it
 */
function trim(str) {
    return str.replace(/^\s*|\s*$/g, "");
}

/**
 * URL Tracer
 * 
 * @param   {String}    str     URL
 */
function trace(str) {
    str = js_phpPath + 'components/function_files/' + str;
    str = js_phpPath + 'test.php?url=' + escape(str) + "&session_id=" + js_session_id;
    x = window.open("", "_blank");
    x.document.write(str);
}

/* global org_win_width, org_win_height, org_left, org_top, org_width, org_height */
var org_win_width, org_win_height;
var org_left, org_top, org_width, org_height;

/* * * * * * * * * * * * * * * * * * * ADDED BY SISHIR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * Date : 06 / 01 / 2009 * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * Modified by Raziv Date: 6/15/2011* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * Search array and find matched value's index
 */
if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (elt) {
        var len = this.length;
        var from = Number(arguments[1]) || 0;
        from = (from < 0) ? Math.ceil(from) : Math.floor(from);

        if (from < 0) {
            from += len;
        }

        for (; from < len; from++) {
            if (from in this && this[from] === elt)
                return from;
        }
        return  - 1;
    };
}

//Array.prototype.typeIndependentIndexOf = function(elt /*, from  */)
function typeIndependentIndexOf(arr, elt) {
    var len = arr.length;
    var from = Number(arguments[2]) || 0;

    from = (from < 0) ? Math.ceil(from) : Math.floor(from);

    if (from < 0)
        from += len;

    for (; from < len; from++) {
        if (from in arr && arr[from] == elt)
            return from;
    }

    return -1;
};

Array.prototype.remove = function(x) {

    var idx = typeIndependentIndexOf(this,x);
    if (idx == -1)
        return;
    return this.splice(idx, 1);
}

/**
 * Wraps the value with single quote
 * 
 * @param   {string}    x   String supplied.
 * @return  {String}        Single Quoted string.
 */
function singleQuote(x) {
    if (x == "NULL" || x == null || x == "null") {
        return x;
    } else {
        return "'" + x + "'";
    }
}

/**
 * Checked whether the supplied string is number or not, matched with digits only if digitOnly is set true
 * 
 * @param   {String}    str         Supplied string
 * @param   {Boolean}   digitOnly   Either ture or false
 * @return                          True or False
 */
function isNum(str, digitOnly) {
    if (!str)
        return false;

    if (isNaN(str))
        return false;

    if (digitOnly) {
        for (var i = 0; i < str.length; i++) {
            var ch = str.charAt(i);
            if ("0123456789".indexOf(ch) ==  - 1)
                return false;
        }
    }
    return true;
}


/**
 * Open new HTML window
 * 
 * @param   {String}  sp_url  URL
 */
function openHTMLWindow(sp_url) {
    var w = screen.availWidth - 15;
    var h = screen.availHeight - 100;
    var attr = "width=" + w + ",height=" + h + ",left=0,top=0,toolbar=yes,location=no,maximize=yes,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,copyhistory=yes";
    //  location.href=sp_url;
    sp_url = sp_url + "&session_id=" + js_session_id;
    sp_url = sp_url + "&config_file=" + encodeURIComponent(js_config_file);
    window.opener = self;

    window.open(sp_url, "_blank", attr);
//window.showMod0alDialog(sp_url,'','dialogHeight:' + h + 'px;dialogWidth:' + w + 'px; dialogTop: 0; dialogLeft:0; edge: Raised; help: no; resizable: no; status: no;');
}


/**
 * Opens menu window
 *
 * @param   {String}    file_path               File path
 * @param   {String}    window_name             Window name
 * @param   {String}    window_label            Window label
 * @param   {String}    function_id             Function id
 * @param   {Boolean}   call_from_hyperlink     Call from hyperlink flag
 */
function open_menu_window(file_path, window_name, window_label, function_id, call_from_hyperlink) { 
    // Hides searchbar and clear search box
    if ($('#col-left-inner').hasClass('offset-top-search')) {
        show_menu_searchbar();
        clear_menu_search();
    }

    data = {"action": "spa_my_application_log", "flag":"i", "function_id":function_id, "product_category":product_id};

    if(window_name != "windowReportDatasetIU" && window_name != "windowReportManagerDatasourceListIU") {
        adiha_post_data("return_val", data, '', '', 'refresh_recent_menu');
    }

    var window_undocked = ($("#workspace").length == 0) ? 'y' : 'n';//To check if window is opened from another browser window
    var form_path = app_form_path;

    file_path_old = "../../../trm.depr/adiha.html.forms/"+file_path+"?session_id="+js_session_id+"&"+getAppUserName();
    if(window_name == "win_10201600"){
        createMdiWindow("windowReportManager", file_path_old, "Report Manager", 923, 565);
        return;
    } else if(window_name == "windowReportDatasetIU"){
        file_path_old = "../../../../trm.depr/adiha.html.forms/" + file_path + "&session_id=" + js_session_id + "&" + getAppUserName();
        createMdiWindow("windowReportDatasetIU", file_path_old, "Report Dataset", 923, 565);
        return;
    } else if(window_name == "windowReportManagerDatasourceListIU"){
        file_path_old = "../../../../trm.depr/adiha.html.forms/" + file_path + "&session_id=" + js_session_id + "&" + getAppUserName();
        createMdiWindow("windowReportManagerDatasourceListIU", file_path_old, "Report Dataset", 923, 565);
        return;
    }else if(window_name == "win_10101400"){
        createMdiWindow("win_10101400", file_path_old, "Maintain Deal Template", 923, 565);
        return;

    }else if(window_name == "win_10104200"){
        createMdiWindow("win_10104200", file_path_old, "Maintain Field Template", 923, 565);
        return;
    }else if(window_name == "win_10104100"){
        createMdiWindow("win_10104100", file_path_old, "Maintain UDF Template", 923, 565);
        return;
    }else if(window_name == "win_10121000"){
        createMdiWindow("win_10121000", file_path_old, "Maintain Compliance Groups", 923, 565);
        return;
    } else if(window_name == "windowMaintainConfig"){
        createMdiWindow("windowMaintainConfig", file_path_old, "Configuration", 923, 403);
        return;
    }else if(window_name == "win_10131300"){
        createMdiWindow("windowImportDataDeal", file_path_old, "Import Data", 634, 425);
        return;
    }else if(window_name == "windowImportDataDeal"){
        createMdiWindow("windowImportDataDeal", file_path_old, "Import Data", 634, 425);
        return;
    } else if(window_name == "win_10234700") {
        createMdiWindow("win_10234700", file_path_old, "Maintain Deal Transfer", 923, 565);
        return;
    } else if(window_name == "win_10231000") {
        createMdiWindow("win_10231000", file_path_old, "Setup Inventory GL Account", 923, 620);
        return;
    }else if(window_name == "windowImportDataDeal"){
        createMdiWindow("windowImportDataDeal", file_path_old, "Import Data", 634, 425);
        return;
    }else if(window_name == "win_10201800"){
        createMdiWindow("WindowReportGroupManager", file_path_old, "Report Group Manager", 1084, 650);
        return;
    } else if(window_name == "windowreportwriter"){
        createMdiWindow("windowreportwriter", file_path_old, "Report Writer", 1084, 650);
        return;
    } else if(window_name == "windowTransferTermPosition"){
        file_path_old = "../../../trm.depr/adiha.html.forms/" + file_path + "&session_id=" + js_session_id + "&" + getAppUserName();
        createMdiWindow("windowTransferTermPosition", file_path_old, "Transfer Position", 450, 350);
        return;
    } else if(window_name == "win_10101410") {
        file_path_old = "../../../trm.depr/adiha.html.forms/" + file_path + "&session_id=" + js_session_id + "&" + getAppUserName();
        if (window_undocked == 'y') file_path_old = "../../../../trm.depr/adiha.html.forms/" + file_path + "&session_id=" + js_session_id + "&" + getAppUserName();
        createMdiWindow("windowMaintainDealTemplateDetail", file_path_old, "Maintain Deal Template Detail", 1084, 590);
        return;
    }


    if (typeof(dhx_wins) === "undefined" || !dhx_wins) {
        dhx_wins = new dhtmlXWindows();
        var call_from = 'link';
    } else {
        var call_from = 'main';
    }

    if (dhx_wins.isWindow(window_name) == true) {
        if (window_name == 'win_10106700' || window_name == 'win_10131020' || (window_name == 'win_10233700' && call_from_hyperlink == true)) {
            if (window_name == 'win_10233700' && typeof(call_from_hyperlink) === 'undefined') {
                bring_to_top(window_name);  
            } else {
                dhx_wins.window(window_name).close();
            }            
        }
    }

    if (dhx_wins.isWindow(window_name)) {
        if (call_from_hyperlink == 'true') {
            window.open(form_path + file_path);
        } else {
            bring_to_top(window_name);
        }

    } else {
        collapse_main_menu_navbar();
        if(window_label == 'Setup Storage Rate Schedule' && (typeof contract_group !== 'undefined')){
            contract_group.rate_sch_win = dhx_wins.createWindow(window_name, 0, 0, 600, 590);
        } else {
            dhx_wins.createWindow(window_name, 0, 0, 600, 590);
        }

        dhx_wins.window(window_name).setText(window_label);
        dhx_wins.window(window_name).progressOn();
        dhx_wins.window(window_name).attachURL(form_path+file_path, false, true);
        dhx_wins.window(window_name).maximize();
        dhx_wins.window(window_name).attachEvent("onContentLoaded", function(win){
            dhx_wins.window(window_name).progressOff();
        });
        dhx_wins.window(window_name).button("park").attachEvent("onClick", function(win){
            if (call_from != 'link') {
                win_y_position = $("#workspace").height()-25;
                position = win.getPosition();
                dimension = win.getDimension();

                last_x_position = position[0];
                last_y_position = position[1];
                last_width = dimension[0];
                win.park(false);
                // resize
                this.conf.wins._winSetSize(win._idd, 250, null, true, false);
                win.setTitle(win.getText());
                // move window to bottom
                win.setPosition(win_x_position, win_y_position);
                win_x_position = win_x_position+152;

                this.hide();
                arrange_windows();
            }

            return false;
        });


        dhx_wins.window(window_name).button("minmax").attachEvent("onClick", function(win){
            if (win.isParked()) {
                if (call_from != 'link') {
                    // restore position         
                    win.setPosition(last_x_position, last_y_position);
                    // restore size 
                    this.conf.wins._winSetSize(win._idd, last_width, null, true, false);
                    win.setTitle('');
                    win.park(false);
                    win.button("park").show();
                    win.allowMove();
                }
                return false;
            }

            return true;
        });


        dhx_wins.window(window_name).button("close").attachEvent("onClick", function(win){
            if (call_from != 'link') {
                win_x_position = win_x_position-152;
                // win.close();
                win_x_position =1;
                arrange_windows();
            }
            else {/* Included again to fix the issue for window button.When the window was reopended it was assuming it to be main window*/
                if (dhx_wins != null && dhx_wins.unload != null) {
                    dhx_wins.unload();
                    dhx_wins = window_name = null;
                }
            }
            return true;
        });

        var fav_image = 'unfavourite';
        var fav_label = 'Favorite';
        var unfav_flag = 0;
        if ($("#favourite_menu #" + function_id).length) {
            unfav_flag = 1;
            fav_image = "favourite";
            fav_label = 'Remove from Favorites';
        }

        dhx_wins.window(window_name).button('help').show();
        if (call_from != 'link') {
            dhx_wins.window(window_name).addUserButton("reload", 0, "Reload", "Reload");
            dhx_wins.window(window_name).button("reload").attachEvent("onClick", function(){
                dhx_wins.window(window_name).progressOn();
                dhx_wins.window(window_name).attachURL(form_path+file_path, false, true);
                dhx_wins.window(window_name).attachEvent("onContentLoaded", function(win){
                    dhx_wins.window(window_name).progressOff();
                });
            });
        }
        dhx_wins.window(window_name).addUserButton("undock", 0, "Undock", "Undock");

        if (call_from != 'link') {
            dhx_wins.window(window_name).addUserButton("favourite", 0, 'Remove from Favorites', 'Remove from Favorites');
            dhx_wins.window(window_name).addUserButton("unfavourite", 0, 'Favorites', 'Favorites');


            var group_json = $("#___fav_group___").val();
            group_json = '[{id:"-1", text:"Add to Favorites"},{id: "sep_top_1", type: "separator"},{id:"00", text:"Add to Group",items:[{id:"new_group", text:"<div id=\'___new_group\'>New Group</div>"},{id: "sep_top_2", type: "separator"},' + group_json + ']}]';
            var fav_menu = dhx_wins.window(window_name).button("unfavourite").attachContextMenu({
                json:group_json
            });
            fav_menu.setOverflowHeight(6);

            fav_menu.attachEvent('onClick', function(id) {
                switch(id) {
                    case -1:
                        add_to_favourite(function_id, -1, '',dhx_wins.window(window_name));
                        break;
                    case 'new_group':
                        showPopup(dhx_wins.window(window_name), function_id);
                        break;
                    default:
                        add_to_favourite(function_id, id, '', dhx_wins.window(window_name));
                }

            })

            if (unfav_flag == 1) {
                dhx_wins.window(window_name).button("unfavourite").hide();
            } else {
                dhx_wins.window(window_name).button("favourite").hide();
            }

            dhx_wins.window(window_name).button("favourite").attachEvent("onClick", function(){
                dhtmlx.message ({
                    type: "confirm",
                    title: get_locale_value("Confirmation"),
                    text: get_locale_value('Are you sure you want to change?'),
                    ok: get_locale_value("Confirm"),
                    cancel: get_locale_value('Cancel'),
                    callback: function(result) {
                        if (result) {
                            dhx_wins.window(window_name).button("favourite").hide();
                            dhx_wins.window(window_name).button("unfavourite").show();
                            remove_from_favourite(function_id);
                        }
                    }
                });
                // dhx_wins.window(window_name).button("favourite").hide();
                // dhx_wins.window(window_name).button("unfavourite").show();
            });

            /**
             * Added a user button(fullscreen) in window header
             * which makes iframe open in fullscreen mode
             */
            dhx_wins.window(window_name).addUserButton("fullscreen", 4, 'Fullscreen', 'Fullscreen');
            dhx_wins.window(window_name).button("fullscreen").attachEvent("onClick", function() {
                var elem = $(dhx_wins.window(window_name).cell).find(".dhx_cell_cont_wins iframe")[0];
                // var elem = document.getElementById("workspace");
                if (elem.requestFullscreen) {
                    elem.requestFullscreen();
                } else if (elem.mozRequestFullScreen) {
                    elem.mozRequestFullScreen();
                } else if (elem.webkitRequestFullscreen) {
                    elem.webkitRequestFullscreen();
                } else if (elem.msRequestFullscreen) {
                    elem.msRequestFullscreen();
                }
            });
        }

        dhx_wins.window(window_name).button("undock").attachEvent("onClick", function(){
            open_window(form_path+file_path);
        });

        dhx_wins.window(window_name).button("help").attachEvent("onClick", function(){
            if (helpfile_window != null && helpfile_window.unload != null) {
                helpfile_window.unload();
                helpfile_window = w1 = null;
            }

            if (!helpfile_window) {
                helpfile_window = new dhtmlXWindows();
            }

            help_win = dhx_wins.createWindow('w1', 0, 0, 600, 600);

            help_win.setText("Help :" + window_label);

            help_win.centerOnScreen();
            help_win.maximize();

            var sp_string = "EXEC spa_getdocumentpath " + function_id;
            var data_for_post = {"sp_string": sp_string};
            var return_j = adiha_post_data('return_json', data_for_post, '', '', 'help_callback');

        });
    }
}

/**
 * Create MDI window
 *
 * @param   {String}  instanceName  Instance name
 * @param   {String}  sp_url        Sp url
 * @param   {String}  titleName     Title name
 * @param   {Number}  w             Window width
 * @param   {Number}  h             Window height
 */
function createMdiWindow(instanceName, sp_url, titleName, w, h) {
    x = window.open(sp_url, '', 'toolbar=no,titlebar=yes; location=no,maximize=yes,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,height=' + h + ',width=' + w + ',top=30,left=20');
}

/**
 * Restrict dragging.
 */
function validate_drag() {
    event.returnValue = false;
}

/**
 * Move hour glass.
 */
function moveHourGlass() {
    try {
        wpx = window.dialogWidth;
        hpx = window.dialogHeight;
        w = wpx.replace("px", "");
        h = hpx.replace("px", "");
        leftPos = event.x;
        topPos = event.y;

        if (w < leftPos + 100) {
            leftPos = leftPos - 100;
        }

        if (h < topPos + 100) {
            topPos = topPos - 100;
        }

        hourglass.style.left = leftPos;
        hourglass.style.top = topPos;
    } catch (exceptions) {}
}

/**
 * Show hour glass.
 */
function showHourGlass() {
    try {
        moveHourGlass();
        hourglass.style.display = "";
    } catch (exceptions) {}
}

/**
 * Hide hour glass.
 */
function hideHourGlass() {
    try {
        hourglass.style.display = 'none';
    } catch (exceptions) {}
}

/**
 * Get date format of client
 * @param   {Object}    sqlFormat   Date in sql format
 * @param   {String}    defDate     Default date
 * @return                          Date
 */
function getClientDateFormat(sqlFormat, defDate) {

    if (sqlFormat == 'NULL' || sqlFormat == null)
        return;
    j = sqlFormat.indexOf("/");

    if (j > 1) {
        sqlFormat_Array = sqlFormat.split("/");
    } else if (sqlFormat.indexOf("-") > 0) {
        sqlFormat_Array = sqlFormat.split("-");
    } else if (sqlFormat.indexOf(".") > 0) {
        sqlFormat_Array = sqlFormat.split(".");
    }

    j = dateformatString.indexOf("/");

    if (j > 1) {
        dateformatString_array = dateformatString.split("/");
        dateSeperator = "/";
    } else if (dateformatString.indexOf("-") > 0) {
        dateformatString_array = dateformatString.split("-");
        dateSeperator = "-";
    } else if (dateformatString.indexOf(".") > 0) {
        dateformatString_array = dateformatString.split(".");
        dateSeperator = ".";
    }

    var newDate = new Array();
    for (i = 0; i < 3; i++) {
        if (dateformatString_array[i] == "dd") {
            if (defDate != undefined) {
                newDate[i] = (defDate < 10) ? "0" + defDate : defDate;
            } else {
                newDate[i] = (sqlFormat_Array[2].length == 1) ? "0" + sqlFormat_Array[2] : sqlFormat_Array[2];
            }
        }

        if (dateformatString_array[i] == "mm") {
            newDate[i] = (sqlFormat_Array[1].length == 1) ? "0" + sqlFormat_Array[1] : sqlFormat_Array[1];
        }

        if (dateformatString_array[i] == "yyyy") {
            newDate[i] = sqlFormat_Array[0];
        }
    }
    return newDate[0] + dateSeperator + newDate[1] + dateSeperator + newDate[2];
}

/**
 * Open report in viewport
 *
 * @param   {String}    exec_statement      Exec statement
 */
function open_report_in_viewport(exec_statement) {
    var exec_statement = exec_statement.replace(/\^/g, "'");
    var window_undocked = ($("#workspace").length == 0) ? 'y' : 'n'; //To check if window is opened from another browser window

    if (window_undocked == 'y') {
        var url = "../../../adiha.php.scripts/dev/spa_html.php?spa=" + exec_statement;
    } else {
        var url = "../../adiha.php.scripts/dev/spa_html.php?spa=" + exec_statement;
    }

    if (typeof(message_board_window) === "undefined" || !message_board_window) {
        message_board_window = new dhtmlXWindows();
        if (window_undocked == 'n') message_board_window.attachViewportTo('workspace');
    }

    var window_name = 'drill_window';

    if (message_board_window.isWindow(window_name)) {
        message_board_window.window(window_name).close();
        var win = message_board_window.createWindow(window_name, 0, 300, 500, 500);
        win.setText('Report');
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(url);
    } else {
        var win = message_board_window.createWindow(window_name, 0, 300, 500, 500);
        win.setText('Report');
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(url);
    }

}

/**
 * Second level Drill function
 *
 * @param   {String}  exec_statement  Exec Statement
 */
function second_level_drill_1(exec_statement) {
    var exec_statement = exec_statement.replace(/\^/g, "'");
    var url = "spa_html.php?spa=" + exec_statement;
    window.open(url);
}

function second_level_drill_2(report_name, exec_call, height, width) {
    var exec_call = exec_call.replace(/\^/g, "'");
    var std_report_url = js_php_path +  '../adiha.html.forms/_reporting/view_report/spa.html.template.php?exec_call=' + exec_call + '&report_name=' + report_name; 
    var spa_dhxWins = new dhtmlXWindows();
    spa_dhxWins.attachViewportTo("workspace");
    report_name = decodeURI(report_name);  
     
    var spa_win = spa_dhxWins.createWindow({
        id: report_name
        ,width: width
        ,height: height
        ,modal: true
        ,resize: true
        ,text: report_name

    });
    spa_win.centerOnScreen();
    spa_dhxWins.window(report_name).bringToTop();
    spa_win.attachURL(std_report_url);  
    spa_win.maximize();
}

function get_file_path(func_id) {
    var data = {action : "spa_send_message"
        , flag : 'z'
        , application_functions : func_id}
    var result = adiha_post_data('return_array', data, '', '', 'call_back');
}

/**
 * Database callback
 *
 * @param   {Array}  db_result  Database Result
 */
function call_back(db_result) {
    var file_path = db_result[0][0];
    var window_name = db_result[0][1];
    var window_label = db_result[0][2];
    $('#file_path').html(file_path);
    $('#window_name').html(window_name);
    $('#window_label').html(window_label);
}

/**
 * Create message box according to supplied arguments. Functions required for Compliance Tracker only
 * 
 * @param   {String}    arg1                First Aggument
 * @param   {Object}    date                Date
 * @param   {Number}    hierarchy_level     portfoilo hierarchy level
 * @param   {Number}    approved            approved Approve = 1, Unapprove = 0, Others = -1, approve = 2 when checking for the existence 
 *                                          of the activity where current date is greater than the exception date
 * @param   {String}    callFrom            Option for reload
 * @param   {String}    process_table       Process table
 * @param   {String}    action_type         Action Type
 * @param   {String}    source_column       Source column
 * @param   {String}    source_id           Source id
 */
function CompliancePerformHyperlink(arg1, date, hierarchy_level, approved, callFrom, process_table, action_type, source_column, source_id) {
    var data = {
        "action": "spa_check_dependency_status",
        "risk_control_id": arg1,
        "risk_hierarchy_level": hierarchy_level
    };
    //adiha_post_data('return_json', data, '', '', 'CompliancePerformHyperlink_callback');



    var additional_data = {
        "type": "return_json"
    };
    data = $.param(data) + "&" + $.param(additional_data);
    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: true,
        data: data,
        success: function(data) {
            response_data = data["json"];
            if ((response_data[0].errorcode).toLowerCase() == 'success') {
                if (approved == 0) {
                    msg = "Are you sure you want to unapprove the selected activity?";
                } else if (approved == 1) {
                    msg = "Are you sure you want to approve the selected activity?";
                } else {
                    msg = "Are you sure you want to perform the selected activity?";
                }

                if (approved == 0) {
                    success_message = "Activity unapproved successfully.";
                    error_message = "Failed to unapprove activity.";
                } else if (approved == 1) {
                    success_message = "Activity approved successfully.";
                    error_message = "Failed to approve activity.";
                } else {
                    success_message = "Activity performed successfully.";
                    error_message = "Failed to perform activity.";
                }

                dhtmlx.message({
                    type: "confirm",
                    text: msg,
                    callback: function(result) {
                        if (result) {
                            if (process_table == '') process_table = 'NULL';

                            var data = {
                                "action": "spa_update_process",
                                "risk_control_activity_id": arg1,
                                "asOfDate": date,
                                "user_name": js_user_name,
                                "approved": approved,
                                "process_table": process_table,
                                "action_type": action_type,
                                "source_column": source_column,
                                "source_id": source_id
                            }

                            var additional_data = {
                                "type": "alert"
                            };
                            data = $.param(data) + "&" + $.param(additional_data);
                            $.ajax({
                                type: "POST",
                                dataType: "json",
                                url: js_form_process_url,
                                async: true,
                                data: data,
                                success: function(data) {
                                    response_data = data["json"];
                                    if ((response_data[0].errorcode).toLowerCase() == 'success') {
                                        var returnvalue = new Array();
                                        returnvalue[0] = "btnOk";
                                        window.returnValue = returnvalue;
                                        if (callFrom == 'r') {
                                            window.document.location.reload(true);
                                            if (opener && typeof opener.document != 'unknown') {
                                                var URL = unescape(window.opener.location.href);
                                                window.opener.location.href = URL;
                                            }
                                        }
                                    }
                                }
                            });
                        }
                    }
                });
            } else {
                show_messagebox(response_data[0].message);
            }
        }//success
    });
    return;
}

/**
 * Help callback
 *
 * @param   {Array}     return_arr      Array data
 */
function help_callback (return_arr) {
    var return_data = JSON.parse(return_arr);
    var help_url1 = return_data[0].document_path;
    var pth = '../../adiha.php.scripts/help_module.php';
    help_win.attachURL(pth, false, {help_url : help_url1});
}

/**
 * Bring window to top
 * 
 * @param  {String}     window_name     Window name
 */
function bring_to_top(window_name) {
    if (dhx_wins.window(window_name).isParked()) {
        dhx_wins._winButtonClick(window_name, "minmax");
    }
    dhx_wins.window(window_name).bringToTop();
}

var fav_win, myForm;
/**
 * Show favourite popup
 * 
 * @param  {Object}     win_obj         Window object
 * @param  {String}     function_id     Function ID
 */
function showPopup(win_obj, function_id) {
    if (fav_win != null && fav_win.unload != null) {
        fav_win.unload();
        fav_win = w1 = null;
    }
    if (!fav_win) {
        var formData = [
            {type: "settings", position: "label-top", offsetLeft:10,labelWidth: 110, inputWidth: 130},
            {type: "input", label: "Group Name", name: "group_name", inputHeight: 25, inputWidth: 180}
        ];
        fav_win = new dhtmlXWindows();
        var pos = win_obj.getPosition();
        var dim = win_obj._getWidth();
        dim = dim + pos[0] - 180;

        var win = fav_win.createWindow('w1', dim, pos[1]+50, 225, 130);
        win.setText("Add to favorites");
        win.setModal(true);
        win.hideHeader();
        var fav_toolbar = win.attachToolbar();
        fav_toolbar.setIconsPath(js_image_path + 'dhxtoolbar_web/');
        fav_toolbar.loadStruct([{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Save", title: "Save", disabled: true},
            {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]);

        var fav_form = win.attachForm(get_form_json_locale(formData));
        fav_form.attachEvent('onKeyUp', function(inp, ev, name, value){
            if (fav_form.getItemValue('group_name').trim() != '') {
                fav_toolbar.enableItem('ok');
            } else {
                fav_toolbar.disableItem('ok');
            }
        });
        fav_toolbar.attachEvent('onClick', function(id) {
            if (id == 'ok') {
                var group_name = fav_form.getItemValue('group_name');
                add_to_favourite(function_id, 0, group_name, win_obj);
                win.close();
            } else {
                win.close();
            }
        });
    }
}

/**
 * Retrive data from cookies
 * 
 * @param   {String}    offset  Cookies offset value
 * @return  {String}            Cookies Values
 */
function getCookieVal(offset) {
    var endstr = document.cookie.indexOf(";", offset);

    if (endstr ==  - 1) {
        endstr = document.cookie.length;
    }
    return unescape(document.cookie.substring(offset, endstr));
}

/**
 * Retrive data from cookies
 * 
 * @param   {String}    name    Cookies Name
 * @return  {Mixed}             NULL or Cookies value
 */
function getCookie(name) {
    var arg = name + "=";
    var alen = arg.length;
    var clen = document.cookie.length;

    var i = 0;
    while (i < clen) {
        var j = i + alen;
        if (document.cookie.substring(i, j) == arg) {
            // alert(document.cookie.substring(i, j));
            return getCookieVal(j);
        }

        i = document.cookie.indexOf(" ", i) + 1;

        if (i == 0)
            break;
    }
    return null;
}

/**
 * Set cookies
 * 
 * @param   {String}      name        Cookies Name
 * @param   {String}      value       Cookies value
 * @param   {String}      expires     Expiration date of the cookie
 * @param   {String}      path        Path
 * @param   {String}      domain      Domain name
 * @param   {Boolean}     secure      Boolean value indicating if the cookie transmission requires a secure transmission
 */
function setCookie(name, value, expires, path, domain, secure) {
    document.cookie = name + "=" + escape(value) + ((expires) ? "; expires=" + expires : "") + ((path) ? "; path=" + path : "") + ((domain) ? "; domain=" + domain : "") + ((secure) ? "; secure" : "");
}

/**
 * Delete cookies
 * 
 * @param   {String}    name    Cookies Name
 * @param   {String}    path    Path
 * @param   {String}    domain  Domain name
 */
function deleteCookie(name, path, domain) {
    if (getCookie(name)) {
        document.cookie = name + "=" + ((path) ? "; path=" + path : "") + ((domain) ? "; domain=" + domain : "") + "; expires=Thu, 01-Jan-70 00:00:01 GMT";
    }
}

/**
 * Changes button image
 * 
 * @param   {String}    img_obj     Image Object
 * @param   {String}    img_src     Image path
 */
function change_btn_image(img_obj, img_src) {
    if (img_obj.alt != "disable") {
        img_obj.src = img_src;
    }
}

/**
 * Validates Comma Seperated Value Number
 * 
 * @param   {String}    number      Supplied value
 * 
 * @return  {Boolean}               True/false status
 */
function isCSVNumber(number) {
    var regexplinkid = (/^(-?\d+,*)*-?\d+$/).test(number);
    return regexplinkid;
}

/**
 * Checks condition and returns corresponding string
 * 
 * @param   {String}    condition   if-else condition to check
 * @param   {String}    ifTrue      String to be returned when condition id true
 * @param   {String}    ifFalse     String to be returned when condition id false
 */
function iif(condition, ifTrue, ifFalse) {
    var x;
    if (condition) {
        x = ifTrue;
    } else {
        x = ifFalse;
    }
    return x;
}


/**
 * Event handler to specify what should be done when any key is pressed when the Document object is in focus.
 */
document.onkeydown = disableHotKeys;

/**
 * Disable Hot keys.
 */
function disableHotKeys(){
    // b - Edit bookmarks 66
    // d - Add bookmark 68
    // h - Open History 72
    // i - Page Info 73
    // n - New Window 78
    // o - Open Page 79
    // q - Exit 81
    // s - Save As 83
    // u - Page source 85
    // w - Close 87
    // e - Search Page 69

    //to enable enter in login form and disable in other
    //  if (event.keyCode == 13) {
    //
    //       var windowUrl = document.location.href;
    //       var findStr = windowUrl.search(/index_login_farrms/i);
    //
    //        if (findStr == '-1') {
    //            event.returnValue = false;
    //            event.keyCode = 0;
    //        }
    // }

    if (event.keyCode === 8) { //backspace disabled
        var doPrevent = false;
        var d = event.srcElement || event.target;

        if ((d.tagName.toUpperCase() === 'INPUT' && (d.type.toUpperCase() == undefined || d.type.toUpperCase() === 'TEXT' || d.type.toUpperCase() === 'PASSWORD'))
            || d.tagName.toUpperCase() === 'TEXTAREA' || $(d).hasClass('allow-backspace') || $(d).hasClass('formula-textdiv') || $(d).hasClass('data-import-textdiv'))  {
            doPrevent = d.readOnly || d.disabled;
        } else {
            doPrevent = true;
        }

        if (doPrevent) {
            return false;
        }
    }

    if (event.keyCode == 66 ||
        event.keyCode == 68 ||
        event.keyCode == 72 ||
        event.keyCode == 73 ||
        event.keyCode == 78 ||
        event.keyCode == 79 ||
        event.keyCode == 81 ||
        event.keyCode == 83 ||
        event.keyCode == 85 ||
        event.keyCode == 87 ||
        event.keyCode == 69
    ) { //character "N"
        if (event.ctrlKey) { //if press ctrl
            event.returnValue = false;
            event.keyCode = 0;
        }
    }

    if (event.keyCode == 122) {
        event.returnValue = false;
        event.keyCode = 0;
    }

    if (event.keyCode == 27 ) {
        //window.returnValue="btnOk";
        //window.close();
    }

    if (event.keyCode == 120) {
        var user_login_id = js_user_name;
        openUserDetail(user_login_id);
    } else if (event.keyCode == 119 && typeof(debugMode) != 'undefined' && debugMode) { //F8 to show current page full url
        //_gbl_page_exec_sp is a global variable defined in spa_html
        if (typeof(_gbl_page_exec_sp) != 'undefined' && _gbl_page_exec_sp)
            alert(unescape(_gbl_page_exec_sp));
        else
            alert(document.location);
    }
}

/**
 * Disable Normal Submit - like enter key pressed triggers form submit if its only input tag on a form
 * to negate this feature add "allow-enter" class on the particular form
 */
function handle_normal_form_submit() {
    $(function() {
        $('form:not(".allow-enter")').submit(function() {
            return false;
        });
    });
}

try {
    handle_normal_form_submit();
} catch(e){}

/**
 * It will return an array of all the indexes it found (it will return false if it doesn't find anything).
 Second in addition to passing the usual string or number to look for you can actually pass a regular expression,
 which makes this the ultimate Array prototype.
 * @param string seacrgStr Search item.
 * @return Array of all indexes.
 var tmp = [5, 9, 12, 18, 56, 1, 10, 42, 'blue', 30, 7, 97, 53, 33, 30, 35, 27, 30, '35', 'Ball', 'bubble'];
 var thirty = tmp.find(30);      // Returns 9, 14, 17
 */

Array.prototype.find = function (searchStr) {
    var returnArray = false;
    for (var i = 0; i < this.length; i++) {
        if (typeof(searchStr) == 'function') {
            if (searchStr.test(this[i])) {
                if (!returnArray) {
                    returnArray = [];
                }
                returnArray.push(i);
            }
        } else {
            if (this[i] === searchStr) {
                if (!returnArray) {
                    returnArray = [];
                }
                returnArray.push(i);
            }
        }
    }
    return returnArray;
}

/**
 * Searches occurence of items in a multi - dimensional arrays and returns indexes in an array
 * @param string searchString String to be searched
 * @param string softMatch Whether match should be a soft one or exact match
 * @param string indexes A blank array to temporary store the indexes for each occurence. Due to recursive nature of function, state need to be maintained in such array params.
 * @param string result A blank array in which all occurence will be populated
 * var result = new Array(), indexes = new Array();
 * multiDimensionArray.search(searchString, softMatch, indexes, result);
 * @return   An array of indexes.
 eg. result[0] = '[0][1]'
 result[1] = '[1][1]'
 */

Array.prototype.search = function (searchString, softMatch, indexes, result) {
    var len = this.length;

    for (var i = 0; i < len; i++) {
        indexes.push(i);

        if (this[i].constructor == Array) {
            // recursively call the method until no array
            this[i].search(searchString, softMatch, indexes, result);
            // pop out on every array processing ending.
            // this point means a single 1D array has been finished processing
            // so remove its index. Its like removing parent index
            // after processing of its all child is finished
            indexes.pop();
        } else {
            if ((softMatch && this[i].indexOf(searchString) !=  - 1) || this[i] == searchString) {
                // if searching is successfull, save the index array
                result[result.length] = indexes.join(',');
            }
            // remove index
            indexes.pop();
        }
    }
    return true;
}

/**
 * Compares Array
 * 
 * @param   {Array}     testArr     Supplied array
 * 
 * @return  {Boolean}               True if match else false
 */
Array.prototype.compare = function (testArr) {
    if (this.length != testArr.length)
        return false;
    for (var i = 0; i < testArr.length; i++) {
        if (this[i].compare) {
            if (!this[i].compare(testArr[i]))
                return false;
        }

        if (this[i] !== testArr[i])
            return false;
    }
    return true;
}


/**
 * Check for number with decimal '.', return true if satisfy.
 * @param   {Number}    num       Number with decimal.
 * 
 * @return  {Boolean}           True if satisfy else false
 */
function isDecimal(num) {
    if (num.indexOf('.') >  - 1)
        return true;
}

/**
 * Check for only alphabhetnumeric return true if alphabhetnumeric and false if not
 * 
 * @param   {String}    val     String
 * 
 * @return  {boolean}           True if satisfy else false
 */
function isAlphanumeric(val) {
    if (val && unescape(val).match(/^[a-zA-Z0-9\s]*$/gi))
        return true;

    return false;
}

/**
 * Check for only alphabhets return true if alphabhets and false if not
 * 
 * @param   {String}    val     String
 * 
 * @return  {boolean}           True if satisfy else false
 */
function isAlphabet(val) {
    if (val && unescape(val).match(/^[a-zA-Z]+$/))
        return true;

    return false;
}

/**
 * Check for only numbers return true if numeric and false if not
 * 
 * @param   {String}    val     String
 * 
 * @return  {boolean}           True if satisfy else false
 */
function isnumeric(val) {
    if (val && unescape(val).match(/^[\d\.]*$/))
        return true;

    return false;
}

/**
 * Check for only alphanumeric with white space and customize value of special chars _ and &
 * 
 * @param   {String}    val     String
 * 
 * @return  {boolean}           True if satisfy else false
 */
function isCommonAlphanumeric(val) {
    var arr = new Array('_', '&', '-', '(', ')');
    return (isAlphaSpecialchar(unescape(val), arr));
}

/**
 * Check for alphabets with provided special characters return true if satisfy else false
 * 
 * @param   {String}    val         String
 * @param   {Array}     regex_arr   Regular expression array
 * 
 * @return  {Boolean}               True if satisfy else false
 */
function isAlphaSpecialchar(val, regex_arr) {
    var pattern = regex_arr.join('');
    pattern = escapeRegex(pattern);
    var reg_pattern = '/^[a-zA-Z0-9\\s' + pattern + ']*$/gi';
    if (val && val.match(eval(reg_pattern)))
        return true;

    return false;
}

/**
 * Seperates special characters with escape sequence
 * 
 * @param   {String}    text    String to be validated
 * 
 * @return  {String}            Modified escaped text
 */
function escapeRegex(text) {
    if (!arguments.callee.sRE) {
        var specials = [
            '/', '.', '*', '+', '?', '|',
            '(', ')', '[', ']', '{', '}', '\\', '^', '$', '&', '.', '-'
        ];
        arguments.callee.sRE = new RegExp(
            '(\\' + specials.join('|\\') + ')', 'g');
    }
    // match(/^[a-zA-Z0-9@_~`!@#%:;'"\&\|\$\^\(\)\+\[\]\?\{\}\.\*\-\\\/,\s]*$/))
    return text.replace(arguments.callee.sRE, '\\$1');
}

/**
 * Validates Email
 * @param   {String}    str     String to be validated
 * 
 * @return  {Boolean}           True if satisfy else false
 */
function isEmail(str) {
    var regex = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(unescape(str));
}

/**
 * Validates the URL
 * 
 * @param   {String}    str     String to be validated
 * 
 * @return  {Boolean}           True if satisfy else false
 */
function isUrl(str) {
    var matchUrl = /^(((ht|f){1}(tp:[\/][\/]){1})|((www.){1}))[-a-zA-Z0-9@:%_\+.~#?&\/\/=]+$/;
    return matchUrl.test(unescape(str));
}

/**
 * Validates the phone number
 * 
 * @param   {String}    str     String to be validated
 * 
 * @return  {Boolean}           True if satisfy else false
 */
function isPhoneNum(str) {
    var regex = /^[+]?[(]?[\d]+[)]?[-]?[(]?[\d]{1,3}[)]?[-]?[\d]+([-][\d]+)?$/;
    return regex.test(unescape(str));
}

/**
 * Validates the mobile number
 * 
 * @param   {String}    str     String to be validated
 * 
 * @return  {Boolean}           True if satisfy else false
 */
function isMobileNum(str) {
    var regex = /^[+]?[(]?[\d]+[)]?[-]?[0-9]+$/;
    return regex.test(unescape(str));
}

/**
 * Add slashes to the supplied string if there is  ' (single-quote), " (double quote), \ (backslash)
 * 
 * @param   {String}    str     Supplied string
 * 
 * @return  {String}            String with slashes in place of single-quote, double-quote and backslash
 */
function addslashes(str) {

    str = str.replace(/\'/g, '\\\'');
    str = str.replace(/\"/g, '\\"');
    str = str.replace(/\\/g, '\\\\');
    str = str.replace(/\0/g, '\\0');

    return str;
}

/**
 * Remove slashes from the supplied string for ' (single-quote), " (double quote), \ (backslash)
 * 
 * @param   {String}    str     Supplied string
 * 
 * @return  {String}            String without slashes
 */
function stripslashes(str) {

    str = str.replace(/\\'/g, '\'');
    str = str.replace(/\\"/g, '"');
    str = str.replace(/\\\\/g, '\\');
    str = str.replace(/\\0/g, '\0');

    return str;
}

/**
 * Open HyperLink
 * 
 * @param   {String}    func_id             Function id
 * @param   {String}    arg1                Argument 1
 * @param   {String}    arg2                Argument 2
 * @param   {String}    arg2                Argument 3
 * @param   {Function}  call_back_function  Callback Function
 */
function openHyperLink(func_id, arg1, arg2, arg3, call_back_function) {
    get_file_path(func_id);//set file path

    if ((func_id != '10221300') && (arg1 == undefined || arg1 == "" || arg1 == "NULL" || arg1 == "Error")) {
        var message = "No data selected for hyperlink.";
        show_messagebox(message);
        return false;
    }

    var new_arg1 = arg1 + "&session_id=" + js_session_id;
    switch(func_id) {
        case 10131024:
            openMaintainDeal(new_arg1, arg2);
            break;
        case 10232610:
            openEff_Profile_Id(new_arg1);
            break;
        case 400: //TODO is this need or not
            openInvoice(arg1);
            break;

        case 10234500: //Used for View outstanding Matching  from GRID. Verify with Summy.
            openViewOutstandingResult(new_arg1, "");
            break;
        default:
            break;
    }

}

/**
 * Open Maintain Deal Detail window for FASTracker
 * 
 * @param   {String}    source_deal_header_id       Source deal header id
 * @param   {String}    round_value                 Rounding Value.
 */
function openMaintainDeal(source_deal_header_id, round_value){
    var source_deal_header_id = source_deal_header_id.split('&');
    get_file_path(10131010);
    setTimeout('openMaintainDeal_calback(' + source_deal_header_id[0] + ')', 1000);

}

/**
 * Opens Deal window
 *
 * @param   {Number}    source_deal_header_id   Source deal header id
 */
function openMaintainDeal_calback(source_deal_header_id) {
    args = "deal_id=" + source_deal_header_id + "&view_deleted=n";
    window_title = 'Deal Detail - ' + source_deal_header_id;
    var file_path = $('#file_path').html();
    var window_name = $('#window_name').html();
    var window_label = (window_title != '') ? window_title : $('#window_label').html();
    open_menu_window(file_path + '?' + args, window_name, window_label)
}

/**
 * Open HTML window for Invoice Report
 * 
 * @param   {String}    arg1    Agruments
 */
function openInvoice(arg1) {
    var app_adiha_loc = getAppAdihaLoc();
    var user_name = getAppUserName();
    var tmp_user = user_name.split('=');
    var user = (tmp_user[1]);

    var exec_call = "EXEC spa_save_invoice 'r', NULL, NULL, NULL, NULL, '" + arg1 + "', NULL, NULL, NULL, NULL, NULL , NULL";

    var sp_url = app_adiha_loc + "adiha.php.scripts/dev/" + 'spa_html.php' + "?spa=" + exec_call + "&" + getAppUserName();
    openHTMLWindow(sp_url);

    return;
}

/**
 * Open View Outstanding Automation Results window
 * 
 * @param   {String}    value_id    Value id
 * @param   {String}    args        Arguments
 */
function openViewOutstandingResult(value_id, args) {
    var args = "group_id=" + value_id + args;
    createWindow("windowViewOutstandingAutomationResults", false, true, args);
}


/**
 * Get date in array
 * 
 * @param   {String}    x   Supplied date string
 * 
 * @return  {Array}         Date in array format
 */
function getDateInArray(x) {
    var sp_arrayDate = new Array();
    j = dateformatString.indexOf("/");

    if (j > 1) {
        sp_arrayDate = x.split("/");
    } else if (dateformatString.indexOf("-") > 1) {
        sp_arrayDate = x.split("-");
    } else if (dateformatString.indexOf(".") > 1) {
        sp_arrayDate = x.split(".");
    }
    return sp_arrayDate;
}

/**
 * Adds context menu in ace editor
 *
 * @param   {Object}    editor      Ace editor Object
 * @param   {Array}     menu_items  Array of menu items
 */
function add_ace_context_menu(editor, menu_items) {
    // create context menu
    var $ctx_menu = document.createElement('div')
    $ctx_menu.classList.add('ctx-menu');

    menu_items.forEach(function(menu_item) {
        // create context menu item
        var $ctx_menu_item = document.createElement('div')
        $ctx_menu_item.classList.add('ctx-menu-item')
        $ctx_menu_item.dataset.string = menu_item.text;
        $ctx_menu_item.title = get_locale_value(menu_item.title);
        $ctx_menu_item.textContent = get_locale_value(menu_item.title) + ' ' + get_locale_value(menu_item.text);

        // add context menu item to context menu
        $ctx_menu.appendChild($ctx_menu_item);
    });

    // add context menu to the editor container
    editor.container.appendChild($ctx_menu);

    // add click event
    editor.container.addEventListener('click', function(e) {
        e.stopPropagation();

        if (e.target.classList.contains('ctx-menu-item')) {
            // insert string from context menu item to the editor at cursor position
            editor.getSession().insert(editor.getCursorPosition(), e.target.dataset.string);
        }

        // hide context menu
        this.querySelector('.ctx-menu').style.display = 'none';
    });

    // add context menu event
    editor.container.addEventListener("contextmenu", function(e) {
        e.preventDefault();

        var $ctx_menu = e.target.parentElement.querySelector('.ctx-menu');

        // show context menu
        $ctx_menu.style.display = 'block';

        var clicked_pos_left = e.pageX;
        var clicked_pos_top = e.pageY;
        var editor_width = e.target.parentElement.offsetWidth;
        var editor_height = e.target.parentElement.offsetHeight;
        var context_menu_width = $ctx_menu.offsetWidth;
        var context_menu_height = $ctx_menu.offsetHeight;

        // if right-clicked beyond visible area inside editor pull context menu back to visible area
        var top = clicked_pos_top - (clicked_pos_top + context_menu_height > editor_height ? context_menu_height : 0);
        var left = clicked_pos_left - (clicked_pos_left + context_menu_width > editor_width ? context_menu_width : 0);
        $ctx_menu.style.top = top + 'px';
        $ctx_menu.style.left = left + 'px';

        return false;
    }, false);
}
/* End of Ace editor popup function */

//CSRF Token
var _csrf_token = getCookie('_csrf_token');
//PHP Connector URLs
var js_form_process_url = get_form_process_url();
var js_data_collector_url = get_data_collector_url();
var js_dropdown_connector_url = get_dropdown_connector_url();
var js_dropdown_connector_v2_url = get_dropdown_connector_v2_url();
var js_file_uploader_url = get_file_uploader_url();

/**
 * Returns Form Process URL
 * 
 * @return  {String}    URL
 */
function get_form_process_url() {
    return js_php_path + "form_process.php?_csrf_token=" + _csrf_token;
}

/**
 * Returns Data Collector URL for Grid and TreeGrid
 * 
 * @return  {String}    URL
 */
function get_data_collector_url() {
    return js_php_path + "data.collector.php?_csrf_token=" + _csrf_token;
}

/**
 * Returns Dropdown Connector URL
 * 
 * @return  {String}    URL
 */
function get_dropdown_connector_url() {
    return js_php_path + "dropdown.connector.php?_csrf_token=" + _csrf_token;
}

/**
 * Returns Dropdown Connector URL V2
 * 
 * @return  {String}    URL
 */
function get_dropdown_connector_v2_url() {
    return js_php_path + "dropdown.connector.v2.php?_csrf_token=" + _csrf_token;
}

/**
 * Returns File Uploader URL
 * 
 * @return  {String}    URL
 */
function get_file_uploader_url() {
    return js_php_path + "generic_file_uploader.php?_csrf_token=" + _csrf_token;
}

/**
 * Enables or Disables adiha objects
 * 
 * @param {Object}  objName     DOM Object
 * @param {Boolean} enabled     True/False for enable/disable
 */
function setEnabled(objName, enabled) {
    if (objName == undefined || objName.type == undefined) {
        return;
    }

    if (enabled == true) {
        objName.disabled = false;
        if (objName.type != 'checkbox')
            objName.style.background = "#FFFFFF";

        if (objName.alt == "___drop_down____") {
            var dd_obj = document.forms[0].item("txt_" + objName.name);
            setEnabled(dd_obj, true);
        }
    } else {
        objName.disabled = true;
        if (objName.type != 'checkbox')
            objName.style.background = "#EBEAE9";

        if (objName.alt == "___drop_down____") {
            dd_obj = document.forms[0].item("txt_" + objName.name);
            dd_hidden_obj = document.forms[0].item(objName.name);
            dd_cmb = document.forms[0].item("org_" + objName.name);
            dd_list = document.forms[0].item("lst_" + objName.name);

            if (eval(objName.name + "_blank") == true) {
                dd_obj.value = "";
                dd_hidden_obj = "";
                objName.value = "";
            }

            // To disable textbox of combo
            dd_list.style.display = 'none';
            dd_obj.disabled = true;
            dd_obj.style.background = "#EBEAE9";
        } else {
            if (objName.type == 'text') {
                if (eval(objName.name + "_blank") == true) {
                    objName.value = '';
                }
            }
        }
    }
}

/**
 * Check if string is of valid date format
 * 
 * @param   {String}    str_date            Expected Date String
 * @param   {String}    user_date_format    User's Date Format
 * 
 * @return  {Boolean}                       Validity (true/false)
 */
is_valid_user_date_format = function (str_date, user_date_format) {

    // Useful chunks of date regex
    var regex = {
        day: '(0?[1-9]|[12][0-9]|3[01])',   // regex for day: values  from 1/01 to 31
        month: '(0?[1-9]|1[012])',          // regex for month: values from 1/01 to 12
        year: '\\d{4}',                     // regex for year: 4 digits
        separator: {
            slash: '[\\/]',                 // regex for date separator '/'
            dot: '[\\.]',                   // regex for date separator '.'
            hyphen: '[\\-]'                 // regex for date separator '-'
        }
    }

    // maps string separators to separator regex
    var sep_regex_map = {
        '/': regex.separator.slash,
        '.': regex.separator.dot,
        '-': regex.separator.hyphen
    }

    /*
    * Get separator from user date format
    * For eg. get '/' from '%n/%j/%Y', get '.' from '%j.%n.%Y'
    */
    var date_separator = user_date_format.replace(/[a-z%]/ig, '')[0];

    // get regex for separator. Eg.: '/[\/]/' for '/'
    var date_separator_regex_string = sep_regex_map[date_separator];

    var date_parts_regex_string = user_date_format
        .replace(/[%(\/|\.|\-)]/g, '')           // removes separator from user date format
        .split('')                                             // converts string to array
        .map(function(e) {                                               // gets individual date parts regex
            var date_part_map = {
                j: 'day',
                n: 'month',
                Y: 'year'
            }
            return regex[date_part_map[e]];
        })
        .join(date_separator_regex_string);                             // join date parts regex by separator regex.

    date_parts_regex_string = '^' + date_parts_regex_string + '$'       // regex to match whole Date, not part of it.

    var date_regex = new RegExp(date_parts_regex_string);
    return date_regex.test(str_date);
};

/**
 * Show Pop up with session expire message and redirect to login page
 * 
 * @param   redirect_url    Redirect URL
 * @param   message         Redirect message
 */
function pop_session_expire(redirect_url, message) {
    if (!top.JS_SESSION_EXPIRE) {
        top.JS_SESSION_EXPIRE = true;
        alert(message.replace(/\\n/g, "\r\n"));
        window.top.location.href = redirect_url;
    }
}

/**
 * Automatically collapse the left side menu, when opening any screen from the menu
 */
function collapse_main_menu_navbar() {
    var fixedSidebar = 'fixed-leftmenu';
    if ($('body').hasClass(fixedSidebar) == true) {
        if ($('#page-wrapper').hasClass('nav-none') == false) {
            $('#page-wrapper').toggleClass('nav-none');
            $('.menu_overlay').hide();
        }

        if ($('#page-wrapper #menu-lists li').hasClass('open')) {
            $('#page-wrapper #menu-lists li').parent().find('.open .submenu').slideUp('fast');
            $('#page-wrapper #menu-lists li').parent().find('.open').toggleClass('open');
        }
    }
}

/**
 * Check if string is valid for windows filename
 * @param   {String}    filename            Filename to be validated
 * @return  {Boolean}                       Validity (true/false)
 */
fx_is_valid_windows_filename = function (filename){
    var rg1=/^[^\\/:\*\?"<>\|]+$/; // forbidden characters \ / : * ? " < > |
    var rg2=/^\./; // cannot start with dot (.)
    var rg3=/^(nul|prn|con|lpt[0-9]|com[0-9])(\.|$)/i; // forbidden file names
    return rg1.test(filename)&&!rg2.test(filename)&&!rg3.test(filename);
}

/**
 * Load child Sibling menu of under report menu.
 * @param {object} menu_obj     Menu object name
 * @param {string} menu_name    Menu name
 * @param {string} report_type  Report Type (1: Dashboard Report, 2: Report Manager)
 * @param {number} category_id  Category ID (eg: Counterparty, Location, Price)
 */
function load_report_menu(menu_obj, menu_name, report_type, category_id) {

    if (report_type == 1) {
         data = {
            "action": "spa_pivot_report_dashboard",
            "flag": 'j',
            "category": category_id
        };
    } else if (report_type == 2) {
        data = {
            "action": "spa_view_report",
            "flag": 'j',
            "paraset_category_id": category_id
        };
    }

    data = $.param(data);

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: true,
        data: data,
        success: function(data) {
            var response_data = data["json"];
            var menu_item_jsoned = JSON.parse(response_data[0].json_item);
            eval('var menu_obj = ' + menu_obj + '');

            $.each(menu_item_jsoned, function(index, value){
                menu_obj.addNewChild(menu_name, 0, menu_name +'_' + value[0], value[1], false, 'report.gif', 'report_dis.gif');
            });
            
        }
    });
}

/**
 * Show report in UI form according category defined.
 * @param {number} report_param_id   Report paraset ID
 * @param {xml}    param_filter_xml  Parameter filter 
 * @param {number} category_id       Category ID (-104701 : Counterparty, -104702 : Price)
 */
function show_view_report(report_param_id, param_filter_xml, category_id) {
    
    data = {
        "action": 'spa_view_report',
        "flag": 'c',
        "report_param_id": report_param_id, 
        "call_from": 'report_manager_dhx',
        "param_filter_xml" : param_filter_xml,
        "paraset_category_id" : category_id
    };

    data = $.param(data);

    $.ajax({
        type: "POST",
        dataType: "json",
        url: js_form_process_url,
        async: true,
        data: data,
        success: function(data) {
            var response_data = data["json"];
            var items_combined = response_data[0].items_combined
            var process_id = response_data[0].process_id
            var sec_filters_info = response_data[0].sec_filters_info;
            var report_name =  response_data[0].report_name;

            var url = app_form_path + '_reporting/report_manager_dhx/report.viewer.php?report_name='+ report_name +'&items_combined=' + items_combined + '&paramset_id=' + report_param_id + '&export_type=HTML4.0'
        
            dhxWins = new dhtmlXWindows();
            var is_win = dhxWins.isWindow('w2');

            if (is_win == true) {
                w2.close();
            }

            w2 = dhxWins.createWindow("w3", 100, 0, 1100, 500);
            w2.setText(report_name);
            w2.setModal(true);
            w2.maximize();

            var param = {
                'sec_filters_info': sec_filters_info +'_-_' + process_id + ''
            }
            w2.attachURL(url, false, param);

            w2.attachEvent("onClose", function(win) {
                return true;
            }); 
        }
    });
}

/**
 * Show dashboard report in UI form.
 * @param {number} dashboard_id      Dashboard ID
 * @param {string} dashboard_name    Dashboard name
 * @param {string} param_filter_xml  Parameter filter
 */
function show_dashboard_report(dashboard_id, dashboard_name, param_filter_xml) {
    var dashboard_window;

    if (!dashboard_window) {
        dashboard_window = new dhtmlXWindows();
    }

    dashboard_id = dashboard_id.trim();
    var win_id = dashboard_id;
    var new_dashboard_window = dashboard_window.createWindow(win_id, 0, 0, 400, 400);
    new_dashboard_window.setText(dashboard_name);
    new_dashboard_window.centerOnScreen();
    new_dashboard_window.maximize();

    url = app_form_path + '_reporting/view_report/my.dashboard.php?dashboard_id='+ dashboard_id;

    var post_param = {'param_xml':escape(param_filter_xml)}
    new_dashboard_window.attachURL(url, false, post_param);

    new_dashboard_window.addUserButton("undock", 0, "Undock", "Undock");

    new_dashboard_window.button("undock").attachEvent("onClick", function(){
        open_window(url, post_param);
    });
}

/**
 * Get the equivalent locale text to provided text
 *
 * @param   {String}    text                Text of which equivalent locale text is needed
 * @param   {Boolean}   is_comma_separated  If text is comma separated list (e.g. grid header names)
 * @param   {Boolean}   internal_call       Used internally by the function to know if comma separated string is being processed
 * @return  {String}                        Locale value
 */
function get_locale_value(text, is_comma_separated, internal_call) {
    if (is_comma_separated == undefined) is_comma_separated = false;
    if (internal_call == undefined) internal_call = false;
    
    if (text == '' || text == undefined || text == 'undefined') return text;
    
    if (typeof lang_locales != 'undefined' && lang_locales != '') {
        if (is_comma_separated === true) {
            return text.split(',').map(function(single_text) {
                return get_locale_value(single_text, false, true);
            }).join(',');
        }

        var replaced_text = trim(strip_html(text)).toLowerCase()
                                      .replace(/'/g, '_u0027_')
                                      .replace(/\\/g, "_u005c_")
                                      .replace(/"/g, "_u0022_");
        
        var result = lang_locales[replaced_text];
        
        if (result) {
            if (result instanceof Array) {
                result[0] = result[0].replace(/_u0027_/g, "'")
                            .replace(/_u005c_/g, "\\")
                            .replace(/_u0022_/g, '"');
                
                if (internal_call) {
                    return result[0].replace(/,/g, '\\,');
                } else {
                    return result[0];
                }
            } else {
                result = result.replace(/_u0027_/g, "'")
                        .replace(/_u005c_/g, "\\")
                        .replace(/_u0022_/g, '"');

                if (internal_call) {
                    return result.replace(/,/g, '\\,');
                } else {
                    return result;
                }
            }
        }
    }

    return text;
}

/**
 * Convert form controls labels to locale
 *
 * @param   {Object}  form_json  Form Json
 *
 * @return  {Object}             Form Json in locale
 */
function get_form_json_locale(form_json) {
    $.each(form_json, function(_index, value) {
        var field_type = value['type'];
        if (field_type != 'block') {
            if (field_type == 'button') {
            var button_value = value['value'];
            if (button_value != undefined) {
                value['value'] = get_locale_value(button_value);
            }
        } else {
            var label = value['label'];
            if (label != undefined) {
                value['label'] = get_locale_value(label);
            }
            }

            var tooltip = value['tooltip'];
            if (tooltip != undefined) {
                value['tooltip'] = get_locale_value(tooltip);
            }
        } 
        
        var lists = value['list'];
        if (lists != undefined) {
            get_form_json_locale(lists);    
        }
    });
    
    return form_json;
}

/**
 * Convert tab labels to locale
 *
 * @param   {Obect}  tab_json   Tab Json
 *
 * @return  {Object}            Tab Json in locale
 */
function get_tab_json_locale(tab_json) {
    $.each(tab_json, function(_index, value) {
        value['text'] = get_locale_value(value['text']);
    });
    return tab_json;
}

/**
 * Check if the column needs to be shown as hyperlink in Pivot Report
 * @param column_name   Column Name
 */
is_column_pivot_hyperlink = function(column_name) {
    var is_hyperlink = false;
    
    if (column_name == 'Deal ID') {
        is_hyperlink = true;
    }
    
    return is_hyperlink;
}

/**
 * Build the hyperlink for the pivot report hyperlink columns
 * @param column_name   Column Name
 * @param value         Hyperlink Primary Parameter
 * @param code          Hyperlink Label
 */
build_column_as_pivot_hyperlink = function(column_name, value) {
    var hyperlink_function_id = '';
    var hyperlink_arguments = value;
    
    if (column_name == 'Deal ID') {
        hyperlink_function_id = '10131010';
    }
    
    var hyperlink = '<span style="cursor:pointer" onClick="TRMWinHyperlink(' + hyperlink_function_id + ',' + hyperlink_arguments + ')"><font color=#0000ff><u><l>' + value + '<l></u></font></span>';
    
    return hyperlink;
}


/**
 * Initialize DHTMLX Chart for creating graphs.
 * @param name_space			Form Namespace.
 * @param layout_name			Layout Name of where you want to initialize the Chart.
 * @param layout_cell			Cell of Layout where the chart is initialized.
 * @param chart_name			Name of the Chart.
 * @param view					View of the Chart (Line, Bar).
 * @param xaxis_col				Columns in X-Axis.
 * @param xaxis_label			Label of X-Axis.
 * @param yaxis_col				Columns in Y-Axis.
 * @param yaxis_label			Label of Y-Axis.
 * @param yaxis_series_label	Label of Y-Axis Series.
 * @param origin				Origin.
 * @param alpha					Opacity level.
 * @param start					Start of Y-Axis value.
 * @param end					End of Y-Axis value.
 * @param step					Step value for Y-Axis.
 * @param template_id			Identifier of Template, which will set the colors and theme.
 * @param offset				Offset for Chart.
 * @param width					Width of Main Line in Chart.
 * @param radius				Radius of Dots shown in the Chart.
 */
function init_dhtmlx_chart(name_space, layout_name, layout_cell, chart_name, view, xaxis_col, xaxis_label, yaxis_col, yaxis_label, yaxis_series_label, origin, alpha, start, end, step, template_id, offset, width, radius) {
    var yaxis_series_label = (typeof (yaxis_series_label) == "undefined")?'':yaxis_series_label;
    var alpha = (typeof (alpha) == "undefined")?'1':alpha;
    var start = (typeof (start) == "undefined")?'':start;
    var end = (typeof (end) == "undefined")?'1':end;
    var step = (typeof (step) == "undefined")?'10':step;
    var offset = (typeof (offset) == "undefined")?'y':offset;
    var width = (typeof (width) == "undefined")?1:width;
    var radius = (typeof (radius) == "undefined")?1:radius;

    var html_string = '';
    eval(chart_name + '_series_legend = ""');

    if(yaxis_series_label == '') {
        yaxis_series_label = yaxis_label;
    }

    var view_type = view;
    var marker_type = 'item';

    if(view == 'line' || view == 'spline') {
        marker_type = 'item';
    } else {
        marker_type = 'square';
    }

    var line_color = get_line_color(template_id);

    var legend_eval = chart_name + '_series_legend = ' + chart_name + '_series_legend + ' + '\'{text:"' + yaxis_series_label + '", color:"' + line_color + '", markerType:"item"},\'';
    eval(legend_eval);

    html_string += chart_name + ' = ' + name_space + '.' + layout_name + '.cells("' + layout_cell + '").attachChart({\n';
    html_string += '    view: "' + view + '",\n';
    html_string += '    value: "#' + yaxis_col + '#",\n';
    html_string += '    alpha: "' + alpha + '",\n';
    html_string += '    line:{color:"' + line_color + '",width:"' + width + '"},\n';
    html_string += '    color: "' + line_color + '",\n';
    html_string += '    item:{\n';
    html_string += '        borderColor: "' + line_color + '",\n';
    html_string += '        color: "' + line_color + '",\n';
    html_string += '        radius: "' + radius + '",\n';
    html_string += '        type:"' + get_marker_shape(template_id) + '"\n';
    html_string += '    },\n';
    html_string += '    padding:{left:75, bottom:100, top:25, right:25},\n';
    if (offset == 'y') {
        html_string += '    offset:0,\n';
    }
    html_string += '    yAxis:{\n';
    if ((start != '') && (end != '')) {
        html_string += '    start: "' + start + '",'+'   end: "' + end + '", step: "' + step + '", \n';
    }
    html_string += '    title:"' + yaxis_label + '"},\n';
    html_string += '    xAxis:{ \n';
    html_string += '        template:function(obj){ return "<span>" + obj.' + xaxis_col + ' + "</span>" },\n';
    html_string += '        start:0,end:1,step:30,title:"' + xaxis_label + '"\n';
    html_string += '    },\n';
    if (origin != '') {
        html_string += '    origin: "' + origin + '",\n';
    }
    html_string += '    tooltip:{\n';
    html_string += '        template:function(obj){ return "<span>" + obj.' + yaxis_col + ' + "</span>" }\n';
    html_string += '    }\n';
    html_string += '});\n';

    // console.log(html_string);
    eval(html_string);
}

/**
 * Get the color of the line according to template.
 * @param template_id			Template ID.
 */
function get_line_color(template_id) {
    line_color = '';
    
    switch(template_id) {
        case 1: //Red
            line_color = '#ff0000';
            break;
        case 2: //Orange
            line_color = '#ff4040';
            break;
        case 3: //Purple
            line_color = '#800080';
            break;
        case 4: //Brown
            line_color = '#420420';
            break;
        case 5: //Green
            line_color = '#00ff00';
            break;
        case 6: //Blue
            line_color = '#4ca3dd';
            break;
        case 7: //Light Blue
            line_color = '#3399ff';
            break;
        case 8: //Pink
            line_color = '#ff00ff';
            break;
        default: //Black
            line_color = '#000000';
            break;
    }
    
    return line_color;
}

/**
 * Get the shape of the market(i.e. Points shown in Graph).
 * @param template_id			Template ID.
 */
function get_marker_shape(template_id) {
    marker_shape = '';
    
    switch(template_id) {
        case 1:
            marker_shape = 'r';
            break;
        case 2:
            marker_shape = 's';
            break;
        case 3:
            marker_shape = 'd';
            break;
        case 4:
            marker_shape = 'c';
            break;
        default:
            marker_shape = 'r';
            break;
    }
    
    return marker_shape;
}

/**
 * Add Series/Lines in Chart.
 * @param chart_name	Name of the Chart.
 * @param value			Values to be plot in Series.
 * @param label			Label for the Series.
 * @param template_id	Template ID.
 * @param alpha			Opacity for the series.
 * @param view			View of Series (Line/Bar).
 * @param width			Width of the Line.
 * @param radius		Radius of the Points in Series.
 */
function add_series_in_dhtmlx_chart(chart_name, value, label, template_id, alpha, view, width, radius) {
    var alpha = (typeof (alpha) == "undefined")?'1':alpha;
    var view = (typeof (view) == "undefined")?'line':view;
    var width = (typeof (width) == "undefined")?1:width;
    var radius = (typeof (radius) == "undefined")?1:radius;

    line_color = get_line_color(template_id);
    var html_string = '';
    var legend_eval = '';

    html_string += chart_name + '.addSeries({' + "\n";
    html_string += '    view: "' + view + '",'+ "\n";
    html_string += '    value: "#' + value + '#",'+ "\n";
    html_string += '    alpha: "' + alpha + '",' + "\n";
    html_string += '    line:{' + "\n";
    html_string += '        color:"' + line_color + '",\n';
    html_string += '        width: "' + width + '"'+ "\n";
    html_string += '    },'+ "\n";
    html_string += '    color:"' + line_color + '",'+ "\n";
    html_string += '    item:{'+ "\n";
    html_string += '        borderColor: "' + line_color + '",'+ "\n";
    html_string += '        color: "' + line_color + '",'+ "\n";
    html_string += '        type:"' + get_marker_shape(template_id) + '",'+ "\n";
    html_string += '        radius:"' + radius + ',"'+ "\n";
    html_string += '    },'+ "\n";
    html_string += '    tooltip:{'+ "\n";
    html_string += '        template:function(obj){ return "<span>" + obj.' + value + ' + "</span>" }'+ "\n";
    html_string += '    }'+ "\n";
    html_string += '});'+ "\n";

    // console.log(html_string);
    eval(html_string);

    legend_eval += chart_name + '_series_legend = ' + chart_name + '_series_legend + ' + '\'{text:"' + label + '", color:"' + line_color + '", markerType:"item"},\'';
    // console.log(legend_eval);
    eval(legend_eval);
}

/**
 * Load the legends at specified place around the Chart.
 * @param chart_name	Name of the Chart.
 * @param halign		Horizontal Alignment.
 * @param valign		Vertical Alignment.
 * @param width			Width of the whole Legend Section.
 * @param legend_align	Legend Alignment.
 */
function load_legends(chart_name, halign, valign, width, legend_align) {
    var halign = (typeof (halign) == "undefined")?'right':halign;
    var valign = (typeof (valign) == "undefined")?'top':valign;
    var width = (typeof (width) == "undefined")?70:width;
    var legend_align = (typeof (legend_align) == "undefined")?'y':legend_align;

    var html_string = '';

    html_string += chart_name + '.define("legend", {' + "\n";
    html_string += '    align:"' + halign + '",'+ "\n";
    html_string += '    valign:"' + valign + '",'+ "\n";
    html_string += '    width:"' + width + '",'+ "\n";
    html_string += '    marker:{radius:5, type:"item", width:10, height:5},';
    html_string += '    layout:"' + legend_align + '",'+ "\n";
    html_string += '    toggle:"true",'+ "\n";
    html_string += '    values:['+ eval(chart_name + '_series_legend') +'],'+ "\n";
    html_string += '});'+ "\n";

    // console.log(html_string);
    eval(html_string);
}

/**
 * Stip html tags from string
 *
 * @param   {String}  html  Text
 *
 * @return  {String}        Stripped Text
 */
function strip_html(text) {
    var tmp = document.createElement("DIV");
    tmp.className = 'fake_div';
    tmp.innerHTML = text;
    var stripped_text = tmp.textContent || tmp.innerText || "";
    $(tmp).remove();
    return stripped_text;
}

/**
 * Rounding accurate values on javascript
 *
 * @param   {number}  n       value to round
 * @param   {number}  digits  rounding digit
 *
 * @return  {number}          rounded value
 */
function roundTo(n, digits) {
    if (digits === undefined) {
        digits = 0;
    }

    var multiplicator = Math.pow(10, digits);
    n = parseFloat((n * multiplicator).toFixed(11));
    return Math.round(n) / multiplicator;
}
/**
 * returns number with comma separated form
 *
 * @param   {numeric}  x  number value
 *
 * @return  {string}     comma separated number format
 */
function numberWithCommas(x) {
    return x.toString().split('.').map(function(e, i) {
        if (i == 0) {
            return e.match(/\d{1,3}(?=(\d{3})*$)/g)
        } else {
            return e;
        }
    }).join('.')
}

/**
 * get number format defined by system
 *
 * @param   {numeric}  num       number value
 * @param   {text}  num_type  number type. eg: 'v','p','a','o' where v=>volume, p=>price, a=>amount, o=>no rounding else number rounding defined
 *
 * @return  {string}            formatted number value
 */
function getNumberFormat(num, num_type, reverse) {
    var return_num;

    if (reverse == 1) {
        return_num = num.replace(global_group_separator, '<#GS#>').replace(global_decimal_separator, '<#DS#>')
        .replace('<#GS#>', '').replace('<#DS#>', '.');
    } else {
        var num_round = '2';
        switch (num_type) {
            case 'p':
                num_round = global_price_rounding;
                break;
            case 'v':
                num_round = global_volume_rounding;
                break;
            case 'a':
                num_round = global_amount_rounding;
                break;
            case 'o':
                num_round = '0';
                break;
            default:
                num_round = global_number_rounding;
                break;
        }
        return_num = numberWithCommas(roundTo(num, num_round).toFixed(num_round))
            .replace(',', '<#GS#>').replace('.', '<#DS#>')
            .replace('<#GS#>', global_group_separator).replace('<#DS#>', global_decimal_separator);
    }
    return return_num;
}

/**
 * Create a Canvas DIV Element for E-Charts.
 * @param {DHTMLX Layout Cell Object} layout_cell_obj Layout Cell Object Used for attaching a Div for Graph.
 * @return {HTML Element} A HTML Div Element for E-Charts Canvas, which is attached in the cell.
 */
function create_canvas_div(layout_cell_obj) {
    // Extract Cell HTML
    var graph_cell = layout_cell_obj.cell;
    var existing_canvas_div, canvas_Div, final_canvas_div;

    // Check if canvas is already created.
    var canvas_div_elm_count = 0;
    for (var idx = 0; idx < graph_cell.getElementsByClassName('dhx_cell_cont_layout')[0].children.length; idx++) {
        var element = graph_cell.getElementsByClassName('dhx_cell_cont_layout')[0].children[idx];
        if (element.id == 'canvas_div') {
            existing_canvas_div = graph_cell.getElementsByClassName('dhx_cell_cont_layout')[0].children[idx];
            canvas_div_elm_count++;
        }
    }

    if (canvas_div_elm_count == 0) {
        // Create a DIV Element
        canvas_Div = document.createElement('div');
        canvas_Div.id = 'canvas_div';
        canvas_Div.style.position = 'absolute';
        canvas_Div.style.top = '1px';
        canvas_Div.style.bottom = '1px';
        canvas_Div.style.right = '1px';
        canvas_Div.style.left = '1px';

        // If canvas div not created, then attach Canvas Div.
        graph_cell.getElementsByClassName('dhx_cell_cont_layout')[0].insertAdjacentElement('afterBegin', canvas_Div);
        final_canvas_div = canvas_Div;
    } else {
        // If canvas div is created, then return the existing Canvas Div.
        final_canvas_div = existing_canvas_div;
    }

    return final_canvas_div;
}

/**
 * Reruns the auto schedule issues.
 * @process_id   {numeric}  process_id 

 */
function retry_auto_schedule(process_id, update_process_id) {
    $('#rerun').hide();
	var data = {
		"action": "[spa_deal_transfer_alert_wrapper] @process_id='" + process_id + "'"
	};
	adiha_post_data('return_array', data, '', '', '', '');
    update_message(update_process_id);
}

/**
 * Delete rerun message
 * @process_id   {numeric}  process_id 
 * 
 */
function update_message(process_id){
    var data = {
        "action" : "spa_message_board @flag = 'j', @process_id = '" + process_id + "'"
    }
    adiha_post_data('return_array', data, '', '', '', '');
}