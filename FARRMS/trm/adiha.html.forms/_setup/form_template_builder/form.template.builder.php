<?php
/**
* Form template builder screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
    $application_function_id = 10111000;
    $form_namespace = 'form_builder';
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("FormTemplate", "", "g");
    $form_obj->define_custom_functions("save_form_builder", "load_form_builder");
    echo $form_obj->init_form('Form', 'Form Details');
    echo $form_obj->close_form();
    ?>
<body>
</body>
<script type="text/javascript">
    var udf_tab_name = "UDF";
    var builder_mode = 0;
    $(function(){
        form_builder.menu.hideItem('t1');

        $(document).click(function(event) {
            $(".dhx_tooltip").hide(); // Removed uncleared Tooltip
        });
    });

    form_builder.load_form_builder = function(win, tab_id, grid_obj) {
        var function_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        
        var selected_row = form_builder.grid.getSelectedRowId();
        var col_index = form_builder.grid.getColIndexById("template_name");
        var template_name = form_builder.grid.cells(selected_row, col_index).getValue();
        var col_index = form_builder.grid.getColIndexById("primary_id");
        var primary_field = form_builder.grid.cells(selected_row, col_index).getValue();

        var url = js_php_path + "form.template.connector.php";
        var additional_data = {
             "function_id":function_id,
             "template_name": template_name,
             "primary_field": primary_field,
             "object_id": function_id,
             "parent_object": "win",
             "builder_mode": builder_mode
        };
        builder_mode = 0;
        $.ajax({
             type: "POST",
             dataType: "text",
             url: url,
             data: additional_data,
             success:function(data) {
                 var script = $(data).filter(function(){ return $(this).is("script") });
                 script.each(function() {
                     if ($(this).hasClass("form_script")) {
                         win.progressOff();
                         eval($(this).text());
                     }
                 });
             },
             error:function(data) {
                 win.progressOff();
             }
        });

    }

    form_builder.save_form_builder = function(tab_id) {
        // Open Remarks popup
        var save_popup = new dhtmlXPopup();
        save_popup.attachEvent("onBeforeHide", function(type, ev, id){
            if (type == 'click' || type == 'esc') {
                save_popup.hide();
                return true;
            }
        });
        save_popup.attachEvent("onShow", function(){
            remarks_form = save_popup.attachForm(get_form_json_locale([
                {type: "settings", position: "label-top", labelWidth: 230, inputWidth: 230},
                {type:"input",name:"remarks",label:"Remarks", value:"", rows:3, required: true, "userdata":{"validation_message":"Required Field"}},
                {type: "button", value: "Ok"}
            ]));
            remarks_form.attachEvent("onButtonClick", function(){
                var status = validate_form(remarks_form);
                if (!status) return;
                save_popup.hide();
                var win = form_builder.tabbar.cells(tab_id);
                var valid_status = 1;
                var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
                object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
                var tab_obj = win.tabbar[object_id];
                var detail_tabs = tab_obj.getAllTabs();
                var remarks = remarks_form.getItemValue("remarks");
                var form_xml = '<Root function_id="' + object_id + '" remarks="'+ remarks +'"><FormXML>';
                var fieldset_xml = '<FieldsetXML>';
                var grid_xml = '<GridGroup>';
                var tab_xml = '<TabXML>';
                var tab_seq = 1;
                var validation = '';
                var validation_message_on_error = '';
                var empty_tab_status = "";
                $.each(detail_tabs, function(index,value) {
                    var field_status = 0;
                    var tab_text = tab_obj.cells(value).getText();
                    if (strip(tab_text) != udf_tab_name) {
                        var group_id = value.split("_");
                        tab_xml += '<Tab id="' + group_id[2] + '" name="' + escapeXML(tab_text) + '" hidden="" seq="' + tab_seq + '"></Tab>';
                        tab_seq += 1;
                        layout_obj = tab_obj.cells(value).getAttachedObject();
                        layout_obj.forEachItem(function(cell){
                            attached_obj = cell.getAttachedObject();
                            if (attached_obj instanceof dhtmlXGridObject) {
                                var grid_id = attached_obj.getUserData("","grid_id");
                                var no_cols = attached_obj.getColumnsNum();
                                grid_xml += '<Grid id="' + grid_id + '" tab_id="' + group_id[2] + '">'
                                for (i = 0; i < no_cols; i++) {
                                    var seq = i + 1;
                                    var col_id = attached_obj.getColumnId(i);
                                    var col_name = attached_obj.getColLabel(i);
                                    var col_visibility = attached_obj.isColumnHidden(i);
                                    var is_hidden = (col_visibility == true ? 'y' : 'n');
                                    grid_xml += '<GridCol id="' + col_id + '" name="' + escapeXML(col_name) + '" is_hidden="' + is_hidden + '" seq="' + seq +'"></GridCol>';
                                }
                                grid_xml += '</Grid>'
                            // } else if(attached_obj instanceof dhtmlXDataView) {
                            } else {
                                $.each($(attached_obj).children("span").children("div"), function(){
                                    var id = $(this).attr("id").split("_");
                                    var attached_obj = eval('details_form_' + id[2] + "_" + id[3]);
                                    var state = form_builder.tabbar.cells(form_builder.tabbar.getActiveTab())
                                                    .getAttachedToolbar()
                                                    .getItemState("show_hide");
                                    if (!state) {
                                        attached_obj.filter();
                                        attached_obj.sort(function(a,b) {return parseInt(a.field_seq) > parseInt(b.field_seq) ? 1 : -1;}, "asc");
                                    }
                                    
                                    var count = attached_obj.dataCount();                                    
                                    if (count > 0) {
                                        for (i = 0; i < count; i++) {
                                            var id = attached_obj.idByIndex(i);
                                            var data = attached_obj.get(id);
                                            var insert_required = data.insert_required == 'y' ? 'y' : 'n';
                                            if (insert_required == 'y' && data.is_hidden == 'y' && data.value == '') {
                                                validation_message_on_error = '<b>' + data.label + '</b> must contain default value before hiding.';
                                                validation = 'false';
                                            }
                                            if (insert_required == 'y' && data.disabled == 'y' && data.value == '') {
                                                validation_message_on_error = '<b>' + data.label + '</b> must contain default value before disabling.';
                                                validation = 'false';
                                            }
                                            var field_id = data.application_field_id;
                                            var field_label = data.label;
                                            var default_value = data.value
                                            var is_hidden = data.is_hidden;
                                            var is_disable = data.disabled;
                                            var group_id = data.group_id;
                                            group_id = group_id.split("_");
                                            var fieldset_id = (data.fieldset_id == null ? "" : data.fieldset_id);
                                            var udf_template_id = data.udf_template_id;
                                            var seq = i + 1;
                                            
                                            form_xml += '<Field id="' + field_id + '" name="' + escapeXML(field_label) + '" default_value="' + escapeXML(default_value) + '" hidden="' + is_hidden + '" disable="' + is_disable + '" seq="' + seq + '" group_id="' + group_id[0] + '" fieldset_id="' + fieldset_id + '" udf_template_id="' + udf_template_id + '" insert_required="' + insert_required + '"></Field>';
                                            field_status = 1;
                                        }
                                    }
                                    if (!state) attached_obj.filter("#is_hidden#", "n");
                                });
                                if (field_status == 0)
                                    empty_tab_status += tab_text + ",";

                                $.each($(attached_obj).children("span").children("label"), function() {
                                    var fieldset_label = $(this).text();
                                    var fieldset_id = $(this).attr("id");

                                    fieldset_xml += '<Fieldset id="' + fieldset_id + '" name="' + escapeXML(fieldset_label) + '"></Fieldset>';
                                });
                            }                 
                        });
                    }
                });
                if (validation == 'false') {
                    show_messagebox(validation_message_on_error);
                    return;
                }
                tab_xml += '</TabXML>';
                grid_xml += '</GridGroup>';
                fieldset_xml += '</FieldsetXML>';
                form_xml += '</FormXML>' + fieldset_xml + grid_xml + tab_xml + '</Root>';
                // console.log(form_xml)
                // return;
                data = {"action": "spa_form_template_builder", "flag":"u", "xml":form_xml}
                if (empty_tab_status == "")
                    adiha_post_data("alert", data, "", "", "form_builder.post_callback");
                else
                    show_messagebox("Tab(s) <b>" + empty_tab_status.replace(/,\s*$/, "") + "</b> is/are empty.");
            });
        });
        var list = document.getElementsByClassName('dhxtoolbar_float_left');
        var x = window.dhx4.absLeft(list[1]);
        save_popup.show(x-80,-130,230,200);
    }

    form_builder.post_callback = function(result) {
        if (result[0].errorcode == "Success") {
            var tab_id = form_builder.tabbar.getActiveTab(); 
            form_builder.tabbar.tabs(tab_id).setText(result[0].recommendation);
            form_builder.tabbar.cells(tab_id).getAttachedToolbar().enableItem('save');
            if (result[0].errorcode == "Success") {
                form_builder.refresh_grid("", form_builder.open_tab);
            }
        }
    };

    function en_dis_toolbar(mode, name) {
        if (mode == 'enable') {
            form_builder.tabbar
                    .cells(form_builder.tabbar.getActiveTab())
                    .getAttachedToolbar()
                    .enableItem(name);
        } else if (mode == 'disable'){
            form_builder.tabbar
                    .cells(form_builder.tabbar.getActiveTab())
                    .getAttachedToolbar()
                    .disableItem(name);
        }
    }

    function add_reset_button() {
        var toolbar_obj = form_builder.tabbar
                    .cells(form_builder.tabbar.getActiveTab())
                    .getAttachedToolbar();

        toolbar_obj.addButton('reset', 2, 'Reset', 'undo.gif', 'undo_dis.gif');
        toolbar_obj.addButtonTwoState('show_hide', 3, 'Show Hidden Fields', 'switch_off.png', null);            
        toolbar_obj.attachEvent("onBeforeStateChange", function(id, state){
            toolbar_obj.setItemState(id, !state);
            if (state) {
                toolbar_obj.setItemImage(id, "switch_off.png");
                toolbar_obj.setItemText(id, "Show Hidden Fields");
                check_label_existance('', '', 'hide');
            } else {
                toolbar_obj.setItemImage(id, "switch_on.png");
                toolbar_obj.setItemText(id, "Hide Hidden Fields");
                check_label_existance('', '', 'show');
            }
        });
    }

    form_builder.tab_toolbar_click = function(id) {
        var validation_status = 0;
        switch(id) {
            case "close":             
                var tab_id = form_builder.tabbar.getActiveTab();
                delete form_builder.pages[tab_id];
                form_builder.tabbar.tabs(tab_id).close(true);
            break;
            case "save":
                form_builder.layout.cells("a").expand();
                var tab_id = form_builder.tabbar.getActiveTab();
                form_builder.save_form_builder(tab_id);
            break;
            case "reset":
                form_builder_reset();
            break;
            default:         
            break;        
        }
    }

    function form_builder_reset() {
        var reset_popup = new dhtmlXPopup();
        reset_popup.attachEvent("onBeforeHide", function(type, ev, id){
            if (type == 'click' || type == 'esc') {
                reset_popup.hide();
                return true;
            }
        });
        reset_popup.attachEvent("onShow", function(){
            reset_form = reset_popup.attachForm(get_form_json_locale([
                {type: "settings", position: "label-top", labelWidth: 230, inputWidth: 230},
                {type: "combo", label: "Revision", name: "revision", required: true, "userdata":{"validation_message":"Invalid Selection"}, validate:"ValidInteger"},
                {type:"input",name:"remarks",label:"Remarks", value:"", rows:3, disabled: true},
                {type: "button", value: "Ok"}
            ]));

            var tab_id = form_builder.tabbar.getActiveTab();
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var rev_combo_obj = reset_form.getCombo("revision");
            rev_combo_obj.attachEvent("onChange", function(value, text){
                if (value != null) {
                    var data = {
                        "action": "spa_form_template_builder",
                        "flag": "b",
                        "application_ui_template_audit_id":value
                    }
                    adiha_post_data("return_json", data, "", "", "set_remarks");
                }
            });
            var combo_post_sql = {
                    "action":"spa_form_template_builder", 
                    "flag":"r", 
                    "application_function_id":object_id
                };

            var data = $.param(combo_post_sql);
            var has_blank_option = false;
            var url = js_dropdown_connector_url + '&' + data  + '&has_blank_option=' + has_blank_option;
            rev_combo_obj.load(url, function() {
                rev_combo_obj.selectOption(0);
            });

            reset_form.attachEvent("onButtonClick", function(){
                var status = validate_form(reset_form);
                if (!status) return;
                var tab_id = form_builder.tabbar.getActiveTab();
                var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
                object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
                
                builder_mode = reset_form.getItemValue("revision");
                form_builder.tabbar.tabs(tab_id).setText(object_id);
                form_builder.open_tab();
                reset_popup.hide();
            });
        });
        var list = document.getElementsByClassName('dhxtoolbar_float_left');
        var x = window.dhx4.absLeft(list[1]);
        reset_popup.show(x,-130,230,200);
    }

    function set_remarks(result) {
        var result = JSON.parse(result);
        var remarks = result[0].remarks;
        reset_form.setItemValue("remarks", remarks);
    }

    function auto_hide_show_items() {
        var state = form_builder.tabbar.cells(form_builder.tabbar.getActiveTab())
                                        .getAttachedToolbar()
                                        .getItemState("show_hide");
        if (!state)
            check_label_existance('', '', 'hide');
        else
            check_label_existance('', '', 'show');
    }

    function check_label_existance(n_id, n_label, mode) {
        var tab_id = form_builder.tabbar.getActiveTab();
        var win = form_builder.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var status = false;

        $.each(detail_tabs, function(index,value) {
            if (strip(tab_obj.cells(value).getText()) == udf_tab_name) return;
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    
                // } else if(attached_obj instanceof dhtmlXDataView) {
                } else {
                    $.each($(attached_obj).children("span").children("div"), function(){
                        var id = $(this).attr("id").split("_");
                        var attached_obj = eval('details_form_' + id[2] + "_" + id[3]);

                        if (mode == 'show' || mode == 'hide') {
                            var selected_id_array = attached_obj.getSelected();
                            attached_obj.unselect(selected_id_array);
                            if (mode == 'show') {
                                attached_obj.filter("#is_hidden#", "");
                                attached_obj.sort(function(a,b) {return parseInt(a.field_seq) > parseInt(b.field_seq) ? 1 : -1;}, "asc");
                            } else {
                                attached_obj.filter("#is_hidden#", "n");
                                attached_obj.sort(function(a,b) {return parseInt(a.field_seq) > parseInt(b.field_seq) ? 1 : -1;}, "asc");
                            }
                            if (selected_id_array != "") attached_obj.select(selected_id_array);
                        } else {
                            var count = attached_obj.dataCount();
                            for (i = 0; i < count; i++) {
                                var id = attached_obj.idByIndex(i);
                                var data = attached_obj.get(id);
                                if (id != n_id) {
                                    if (data.label == n_label) {
                                        show_messagebox("Field Name <b>" + n_label + "</b> already exists");
                                        status = true;
                                        break;
                                    }
                                }
                            }
                        }
                        if (status) return false;
                    });
                }
            });
            if (status) return false;
        });
        return status;
    }

    function strip(html) {
        var tmp = document.createElement("DIV");
        tmp.className = 'fake_div';
        tmp.innerHTML = html;
        var text = tmp.textContent || tmp.innerText || "";
        $(tmp).remove();
        return text;
    }

    var global_udt_grid_obj, global_udt_grid_id;
    function get_udt_grid_data(udt_id, udt_grid_obj, grid_id) {
        global_udt_grid_obj = udt_grid_obj;
        global_udt_grid_id = grid_id;

        data = {"action": "spa_user_defined_tables",
            "flag": "g",
            "udt_id": udt_id
        };

        adiha_post_data('return_array', data, '', '', 'create_udt_grid', '');
    }

    function create_udt_grid(result) {
        var grid_col_ids = [];
        var grid_header = [];
        var grid_col_width = [];
        var grid_attached_header = [];
        var grid_col_visibility = [];
        for (var i = 0; i < result.length; i++) {
            grid_col_ids.push(result[i][2]);
            grid_header.push(result[i][3]);
            grid_col_width.push('120');
            grid_attached_header.push('#text_filter');

            //Hide Identity Column && Foreign/ Reference Column
            if (result[i][10] == 0 && (result[i][19] == 0 || result[i][19] == null)) {
                grid_col_visibility.push(false);
            } else {
                grid_col_visibility.push(true);
            }
        }
        
        global_udt_grid_obj.setHeader(grid_header.toString());
        global_udt_grid_obj.setColumnIds(grid_col_ids.toString());
        global_udt_grid_obj.setInitWidths(grid_col_width.toString());
        global_udt_grid_obj.attachHeader(grid_attached_header.toString());
        global_udt_grid_obj.init();
        global_udt_grid_obj.setColumnsVisibility(grid_col_visibility.toString());
        global_udt_grid_obj.enableHeaderMenu();
        global_udt_grid_obj.setUserData("","grid_id", global_udt_grid_id);
        
        enter_edit_grid_header();
    }

    function enter_edit_grid_header() {
        $('.dhxtabbar_cont').find('.hdrcell').dblclick(function(event){
            var original_label = $(this).text().trim();
            if (original_label == '') return false;
            // $('.hdrcell').has('.manual_edit').text($('.hdrcell').has('.manual_edit').children().val());
            $(this).html('<input onfocus="this.value = this.value;" class="manual_edit" type="text" value="' + original_label + '">');
            $(this).children().focus();
            $(this).children().blur(function(){
                $(this).parent().text($(this).val());
            });
        });

        // Exit Edit Mode on Enter Click
        $('.hdrcell').delegate('.manual_edit', 'keyup', function (e) {
            if (e.keyCode == 13) {
                $(this).parent().text($(this).val());
            }
        });
    }
</script>
<style type="text/css">
    .data_container_class {
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: #f9f9f9;
    }
    
    .data_container_inner_class {
        width:100%;
        min-height:10px;
        /*height: 100% !important;*/
    }

    .dhx_dataview .dhx_dataview_default_item, .dhx_dataview .dhx_dataview_default_item_selected {
         border-right: 0px !important; 
         border-bottom: 0px !important; 
    }

    .dhx_dataview {
        overflow: auto !important;
    }

    .dhx_dataview_item:not(.dhx_dataview_default_item_selected) {
        background-color: #f9f9f9 !important;
    }
</style>
<div id="data_view_obj">
</div>
</html>