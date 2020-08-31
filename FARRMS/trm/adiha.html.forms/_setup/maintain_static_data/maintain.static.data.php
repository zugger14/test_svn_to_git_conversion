<?php
/**
* Maintain static data screen
* @copyright Pioneer Solutions
*/
?>
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
    $app_adiha_loc = $app_php_script_loc;
    $form_namespace = 'setup_static_data';
    $rights_static_data_iu = 10101010;
    $rights_static_data_delete = 10101011;
    $rights_static_data_privilege = 10101020;
	$theme_selected = 'dhtmlx_'.$default_theme;
    
    list (
        $has_rights_static_data_iu,
        $has_rights_static_data_delete,
        $has_rights_static_data_privilege
        ) = build_security_rights(
        $rights_static_data_iu, 
        $rights_static_data_delete,
        $rights_static_data_privilege
    );

    //Hyperlinked 
    $default_id = (isset($_REQUEST["default_id"]) && $_REQUEST["default_id"] != '') ? get_sanitized_value($_REQUEST["default_id"]): '';
    $unique_id = '';
    
    if($default_id != '') {
        $sql = "SELECT type_id, code FROM static_data_value WHERE value_id =" . $default_id . "";
        $static_data_val = readXMLURL2($sql);
        $type_id = $static_data_val[0]['type_id'];
        $unique_id = $type_id . $default_id;
    }

    $form_obj = new AdihaStandardForm($form_namespace, 10101000);
    $form_obj->define_grid('SetupStaticData', "EXEC spa_StaticDataValues @flag='g',@internal_external='0'");
    $form_obj->define_custom_functions('save_data', 'load_form', 'delete_data');
    $form_obj->add_privilege_menu($has_rights_static_data_privilege, 'refresh_grid_after_privilege', 2);
    $form_obj->enable_multiple_select();
    echo $form_obj->init_form('Static Data', 'Setup Static Data', $unique_id);

    if ($default_id != '') {
        echo "setup_static_data.layout.cells('a').collapse();";
    }

    echo $form_obj->close_form();    
?>
</body>
<script type="text/javascript">
    var has_rights_static_data_iu = '<?php echo (($has_rights_static_data_iu) ? $has_rights_static_data_iu : '0'); ?>';
    var has_rights_static_data_delete = '<?php echo (($has_rights_static_data_delete) ? $has_rights_static_data_delete : '0'); ?>';
    var has_rights_static_data_privilege = '<?php echo (($has_rights_static_data_privilege) ? $has_rights_static_data_privilege : '0'); ?>';
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    var theme_selected = 'dhtmlx_' + default_theme;
    var static_data_privilege;
    
    setup_static_data.details_layout = {};
    setup_static_data.details_tabs = {};
    setup_static_data.details_form = {};
		
    $(function(){
        setup_static_data.check_button();
        add_filter_menu();
    });
    
    //add filter menu after process menu
    function add_filter_menu() {
        setup_static_data.menu.addNewSibling('process',"filter", 'Filter', false, "filter.gif", "filter_dis.gif");
		setup_static_data.menu.addCheckbox('child',"filter", null, 'chk_inactive', "Show Inactive Data Types", 0, 4);
		setup_static_data.menu.addCheckbox('child',"filter", null, 'chk_internal', "Show Internal", 0, 4);
  	
        setup_static_data.menu.attachEvent("onClick", function(id) {
            if (id == 'chk_internal' || id == 'chk_inactive') {
                refresh_grid_after_privilege();
            }
        }); 
    }
    
    setup_static_data.deactivate_callback = function (return_value) {
        if (return_value[0][0] == 'Success') {
            success_call(return_value[0][4]);
            refresh_grid_after_privilege();
        } else {
            show_messagebox(return_value[0][4]);
            return;
        } 
    }
    /* Function to delete data */
    setup_static_data.delete_data = function() {
        var function_id_index = setup_static_data.grid.getColIndexById('application_function_id');
        var row_no_index = setup_static_data.grid.getColIndexById('rownumber');
        var code_index = setup_static_data.grid.getColIndexById('code');
        var value_id_index = setup_static_data.grid.getColIndexById('value_id');

        var parent_ids = [];
        var value_ids = [];
        var function_id;
        var delete_xml = '';
        
        var selected_row_id = setup_static_data.grid.getSelectedRowId();
        selected_row_id = selected_row_id.split(',');
        selected_row_id.forEach(function(val) {
            var grid_id = setup_static_data.grid.cells(val, value_id_index).getValue();
            value_ids.push(grid_id);
            parent_ids.push(setup_static_data.grid.getParentId(val));
            if (typeof function_id == 'undefined')
                function_id = setup_static_data.grid.cells(val, function_id_index).getValue();
            if (grid_id != '')
                delete_xml += '<GridGroup><GridDelete grid_id="' + grid_id + '"></GridDelete></GridGroup>';
        });
        var value_ids_string = value_ids.toString();

        var similar_parent_ids_count = parent_ids.find(parent_ids[0]).length;

        if (parent_ids.length !== similar_parent_ids_count) {
            show_messagebox('Please select the <b>Static Data</b> of same <b>Data Type</b>.');
            return;
        }
        
        var final_xml = '<Root function_id="' + function_id + '">' + delete_xml + '</Root>';

        if (delete_xml != '') {
            confirm_messagebox("Are you sure you want to delete?", function() {
                if (function_id == 10101024) {
                    var data = {"action": "spa_hourly_block","flag": "d", "block_value_id": value_ids_string};
                } else if (function_id == 10101021) {
                    var data = {"action": "spa_get_holiday_calendar","flag": "e", "value_id": value_ids_string};
                } else if (function_id == 10101080) {
                    var data = {"action": "spa_commodity_attribute_form","flag": "d", "commodity_attribute_id": value_ids_string};
                } else if (function_id == 10101070) {
                    var data = {"action": "spa_commodity_type_form","flag": "d", "commodity_type_id": value_ids_string};
                } else if (function_id == 10101025) {
                    var data = {"action": "spa_certification_systems","flag": "d", "value_id": value_ids_string};
                } else {
                    var data = {"action": "spa_process_form_data","flag": "d", "xml": final_xml};
                }
                
                if (value_ids.find(0).length > 0) {
                    show_messagebox('System Data cannot be deleted.');
                } else {
                    adiha_post_data('return_json', data, '', '', 'delete_callback');
                }
            });
        }
    }

    /**
     * [delete_callback]
     */
    function delete_callback(result) {
        var result = JSON.parse(result);
        var select_id = setup_static_data.grid.getSelectedRowId();
        select_id = select_id.split(',');

        if (result[0].status == 'Success') {
            success_call(result[0].message);
            select_id.forEach(function(val) {
                var col_index = setup_static_data.grid.getColIndexById('rownumber');
                var full_id = "tab_" + setup_static_data.grid.cells(val, col_index).getValue();

                if (setup_static_data.pages[full_id]) {
                    setup_static_data.tabbar.cells(full_id).close();
                }
            });
            setup_static_data.grid.saveOpenStates();
            var page_no = setup_static_data.grid.currentPage;

            setup_static_data.refresh_grid("", function() {
                refresh_grid_after_privilege();
                setup_static_data.grid.loadOpenStates();
                setup_static_data.grid.changePage(page_no);
            });

            setup_static_data.menu.setItemDisabled("add");
            setup_static_data.menu.setItemDisabled("delete");
        } else {
            show_messagebox(result[0].message);
            return;
        }
    }

    /**
     * [Function to save data]
     */
    setup_static_data.save_data = function(tab_id) {
        var validation_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        
        var field_value = '';
        var field_label = '';
        var name_desc = '';
        var code_desc = '';
		
        var function_id ;
        var type_id;
        var checkflag;
        var is_checkminus;
        var status = false;

        var detail_tabs =  setup_static_data.details_tabs["details_tabs_a_" + object_id].getAllTabs();
        var tabsCount = setup_static_data.details_tabs["details_tabs_a_" + object_id].getNumberOfTabs();
        var form_xml = "<FormXML ";
        var form_status = true;
        var first_err_tab;
        $.each(detail_tabs, function (index, value) {
            attached_obj = setup_static_data.details_tabs["details_tabs_a_" + object_id].cells(value).getAttachedObject();
            
            if (attached_obj instanceof dhtmlXForm) {
                function_id = attached_obj.getUserData("value_id","function_id");
                var type_id = attached_obj.getUserData("value_id","type_id");
                checkflag = false;
                is_checkminus = false;
                status = validate_form(attached_obj);
                form_status = form_status && status; 
                if (tabsCount == 1 && !status) {
                     first_err_tab = "";
                } else if ((!first_err_tab) && !status) {
                    first_err_tab =  setup_static_data.details_tabs["details_tabs_a_" + object_id].cells(value);
                }
                
                if (status == true) {
                    data = attached_obj.getFormData();
                    for (var a in data) {
                        field_label = a;
                        field_value = data[a];
                        if (field_value) {
                            field_value = data[a];    
                        }

                        lbl = attached_obj.getItemLabel(a);
                        lbl_value = attached_obj.getItemValue(a);
                        if (lbl == get_locale_value("System ID")) {   
                            if (lbl_value >= 0) {
                                sdv_data = data[a];
                            } else {
                                is_checkminus = true;            
                            }   
                        }
                        if (field_label == 'type_id') {
                            field_value = type_id;
                        }
                        
                        if((lbl == get_locale_value("Code")) && (lbl_value != "")){
                            sdv_data = data[a];
                            code_desc = sdv_data;
                        }
                        if ((lbl == get_locale_value("Name")) && (lbl_value != "")) {     
                            sdv_data = data[a];
                            name_desc = sdv_data;
                        } 
                        if ((lbl == get_locale_value("Group Name")) && (lbl_value != "")) {     
                            sdv_data = data[a];
                            name_desc = sdv_data;
                        }
                        
                        if (field_label == "location_description") {
                            field_value = name_desc; 
                            attached_obj.setItemValue(field_label, field_value);  
                        }
                        //begin 123
                        if((lbl==get_locale_value("Code"))||(lbl==get_locale_value("Name"))||(lbl==get_locale_value("Group Name"))||(lbl==get_locale_value("Description"))||(lbl==get_locale_value("Legal Entity ID")) || (lbl==get_locale_value("Book ID"))) {  
                            var message = "Error";
                            var patt = /\S/
                            var result = lbl_value.match(patt);
                            var result1 = field_value.match(patt);
                            /**
                            * [Code to save the description with value of name or code if left blank while adding or altering datas]
                            */
                            if ((lbl == get_locale_value("Description") || lbl == get_locale_value("Location Description")) && (!result1)) {                       
                                if (name_desc != "") {                         
                                   field_value = name_desc; 
                                   attached_obj.setItemValue(field_label, name_desc);
                                   
                                   checkflag = true;      
                                } 
                                if (code_desc != "") {
                                    field_value = code_desc;
                                    attached_obj.setItemValue(field_label, code_desc);
                                    checkflag = true;
                                }                                  
                            }
                            

                            if (!checkflag) {
                                if(!result) {
                                    validation_status = 1;
                                    attached_obj.setNote(field_label,{text:"Please enter the proper value"});  
                                    attached_obj.attachEvent("onchange", 
                                        function(field_label, lbl_value){
                                            attached_obj.setNote(field_label,{text:""});
                                        }
                                    );
                                }                        
                            }
                        }      
                        
                        if (!field_value)
                            field_value = 'null';
                            form_xml += " " + field_label + "=\"" + field_value + "\"";
                    }
                } else {
                    validation_status = 0;
                }
            }     
        });  
        
	form_xml += "></FormXML>";
	final_xml = '<Root function_id="' + function_id + '">' + form_xml + '</Root>';
        
        if (validation_status == 1) {
             //console.log(setup_static_data.tabbar.cells(tab_id).getAttachedToolbar());
             setup_static_data.tabbar.cells(tab_id).getAttachedToolbar().disableItem('save');
             if(is_checkminus) {
                show_messagebox('System Data cannot be updated.') 
            } 
        else {
                data = {"action": "spa_process_form_data", "xml": final_xml};
                result = adiha_post_data("alert", data, "", "", "setup_static_data.save_callback");
            }
        } else {
                generate_error_message(first_err_tab);
                return;
        }
    }
    /**
     * [Defined to catch the code value and result from hourly block and calendar]
     */
    setup_static_data.special_menu_case = function(result, code,type) {
        special_case_tab_name = code;
        setup_static_data.save_callback(result, type);
    }
    /**
     * [Defined to update the id field during addition of new data and updating the tab name after addition/update of data]
     */
    setup_static_data.save_callback = function(result,type) {
        //console.log(result);alert(type);
        var active_tab_id = setup_static_data.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        /*setTimeout(
            function() {
                setup_static_data.tabbar.cells(active_tab_id).getAttachedToolbar().enableItem('save');
            },1000);*/
        if (has_rights_static_data_iu && (type == undefined || type == '')) {            
            setup_static_data.tabbar.cells(active_tab_id).getAttachedToolbar().enableItem('save');
        }  
        
        setup_static_data.grid.saveOpenStates();
        var txt = null, lbl = null, form_name = null, hold = null;	
        //checks for whether the defined label is value_id or source_###_id where ### refers to menu name e.g. product
        if (typeof (data) != 'undefined') {
            
            var val = data["xml"].match(/\Wvalue_id/);			
            var sch = data["xml"].match(/source_\w+_id/g);
		
            if (sch != null) {
                for (var i=0; i < sch.length; i++) {
                    var temp = sch[i];
                    var filter = temp.match(/system/);
                    if (filter == null) {
                        var hold = temp;
                    }
                }
            }
            
            if (val != null) {
                txt = val[0].trim();
                lbl = "code";
            } else if (hold != null) {
                txt = hold;
                var tempo = data["xml"].match(/\w+_name/);
                lbl = tempo[0] ;
            }
        } else {
            txt = 'value_id';
            lbl = 'code';
        }


        var stat = result[0].status;
        var new_id = result[0].recommendation;
        var msg = result[0].message;
        if ( stat == 'Success') {
            var tab_name = null;            
            if (type == "calendar") {
                tab_name = special_case_tab_name;
                //calendar_open = false;
                function_id = "10101021";
            } else if (type == "hourly_block") {
                tab_name = special_case_tab_name;
                //hourly_block_open = false;
                function_id = "10101024";
            }  else if (type == "commodity") {
                tab_name = special_case_tab_name;
                //hourly_block_open = false;
                function_id = "10101112";
            } else if (type == "commodity_type") {
                tab_name = special_case_tab_name;
                //hourly_block_open = false;
                function_id = "10101070";
            } else if (type == "commodity_attribute") {
                tab_name = special_case_tab_name;
                //hourly_block_open = false;
                function_id = "10101080";
            } else if (type == "block_type") {
                tab_name = special_case_tab_name;
                //hourly_block_open = false;
                function_id = "10101034";
            } else if (type == "compliance_group") {
                tab_name = special_case_tab_name;
                function_id = "10101010";
            } else if (type == "certification_systems") {
                tab_name = special_case_tab_name;
                function_id = "10101025";
            } else {
                var detail_tabs = setup_static_data.details_tabs["details_tabs_a_" +  active_object_id].getAllTabs();
				
                var attached_obj
                $.each(detail_tabs, function(index, value) {
                    if (index == 0) {
                        attached_obj = setup_static_data.details_tabs["details_tabs_a_" +  active_object_id].cells(value).getAttachedObject();
		    }					
                });
                
                if (new_id != null) {
                    attached_obj.setItemValue(txt, new_id);
                }   
                tab_name = attached_obj.getItemValue(lbl);		
                function_id = attached_obj.getUserData("value_id","function_id");
            }
            setup_static_data.tabbar.tabs(active_tab_id).setText(tab_name);
            var previous_row = setup_static_data.tabbar.tabs(active_tab_id).getUserData("row_id");
            var new_value_id = result[0].recommendation;
            
            if (new_value_id != null && new_value_id != -1) {
                var new_value_id_arr = new_value_id.split('');
    
                if (new_value_id_arr[0] == ',')  {
                    new_value_id = new_value_id.replace(',', '')
                }
            }
            var info_array = get_function_id(active_tab_id);
            if (previous_row != -1 && previous_row != null)  {
//                var unique_id = setup_static_data.grid.cells(previous_row,1).getValue();
                var unique_id = info_array["type_id"] + '' + info_array['value_id'];
            } else {
                if (new_value_id != '') {
                    var unique_id = info_array["type_id"] + '' + new_value_id;
                }
            }


            setup_static_data.refresh_grid("",setup_static_data.grid_refresh = function(){
                refresh_grid_after_privilege('u',unique_id,new_value_id,tab_name);
            });

            setup_static_data.menu.setItemDisabled("add");
            setup_static_data.menu.setItemDisabled("delete");
        }   
    }
    /**
     *
     */ 
    setup_static_data.create_tab_custom = function(full_id, text, grid_obj, acc_id, tab_index, selected_row) {
        if (!setup_static_data.pages[full_id]) {
            setup_static_data.tabbar.addTab(full_id, text, null, tab_index, true, true);
            var win = setup_static_data.tabbar.cells(full_id);
            win.progressOn();
            //using window instead of tab
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath("<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/"+js_dhtmlx_theme +"/imgs/dhxtoolbar_web/");
            toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
            toolbar.attachEvent("onClick", setup_static_data.tab_toolbar_click);
            
            setup_static_data.tabbar.cells(full_id).setActive();            
            setup_static_data.tabbar.cells(full_id).setText(text);
            setup_static_data.load_form(win, full_id, grid_obj, acc_id);
            setup_static_data.pages[full_id] = win;            
            setup_static_data.tabbar.cells(full_id).setUserData("row_id", selected_row);
        }
        else {
            setup_static_data.tabbar.cells(full_id).setActive();
        }
    }
    
    // Function to disable save button if privilege is disabled
    setup_static_data.check_privilege_callback = function(result) {
        // Disable Save button if disabled privilege
        privilege_status = result[0]['privilege_status'];
        if (privilege_status == 'false') {
            setup_static_data.tabbar
                    .cells(setup_static_data.tabbar.getActiveTab())
                    .getAttachedToolbar()
                    .disableItem('save');
        }
    }

    /**
     *
     */ 
    setup_static_data.load_form = function(win,tab_id, grid_obj) {
        win.progressOff();
        var is_new = (tab_id.indexOf("tab_") != -1) ? win.getText() : 'Newtab';
        var selected_row = setup_static_data.grid.getSelectedRowId();
        var is_checked = (setup_static_data.menu.getCheckboxState('chk_internal')) === true ? 1 : 0;  
        
        if (is_checked == 1) { //internal data type
            win.detachToolbar();  
        }  else {
            win.attachToolbar();    
        } 
        
        /*if (has_rights_static_data_iu == 0) {
            toolbar.disableItem("save");    
        }*/
        var setup_static_data_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        setup_static_data_tab_id = ($.isNumeric(setup_static_data_tab_id)) ? setup_static_data_tab_id : ord(setup_static_data_tab_id.replace(" ", ""));	 
        setup_static_data.details_layout["inner_tab_layout_" + setup_static_data_tab_id] = win.attachLayout("1C");
        
        var col_value;        
        var template_name;
        var col_name;
        var function_id;
        
        var get_row_data = get_function_id(tab_id);
        function_id = get_row_data["function_id"];
        template_name = get_row_data["template_name"];
        col_name = get_row_data["col_name"];
        static_data_id = get_row_data["value_id"];
        static_data_type_id = get_row_data["type_id"];

        if (is_new == 'Newtab') {
            col_value = '';
        } else {
            col_value = static_data_id;
        }

        if (col_value < 0 ) {
            win.detachToolbar();
        }
        
        var xml_value =  '<Root><PSRecordset ' + col_name + '="' + col_value + '"></PSRecordset></Root>';
        if (function_id == 10101024) {
            hourly_block_open = true; //declared for refreshing later after addition/update of hourly block data
            win.detachToolbar();
            var url = 'maintain.static.hour.php';
            if (is_new == 'Newtab') {
                var value = '';
            } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value, type_id: static_data_type_id, win_obj : win, grid_object: grid_obj, according_obj : grid_obj });
        } else if (function_id == 10101021) {
            calendar_open = true; //declared for refreshing later after addition/update of calendar data
            win.detachToolbar();
            var url = 'maintain.static.holidaygroup.php';
            if (is_new == 'Newtab') {
                var value = '';
            } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value, type_id: static_data_type_id});
        }  else if (function_id == 10101112) {
            calendar_open = true; //declared for refreshing later after addition/update of calendar data
            win.detachToolbar();
            var url = 'maintain.static.commodity.php';
            if (is_new == 'Newtab') {
                var value = '';
            } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value, type_id: static_data_type_id});
        } else if (function_id == 10101070) {
            calendar_open = true; //declared for refreshing later after addition/update of calendar data
            win.detachToolbar();
            var url = 'maintain.static.commodity.type.php';
            if (is_new == 'Newtab') {
                var value = '';
            } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value});
        } else if (function_id == 10101080) {
            calendar_open = true; //declared for refreshing later after addition/update of calendar data
            win.detachToolbar();
            var url = 'maintain.static.commodity.attribute.php';
            if (is_new == 'Newtab') {
                var value = '';
            } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value});
        } else if (function_id == 10101034) {
            calendar_open = true; //declared for refreshing later after addition/update of calendar data
            win.detachToolbar();
            var url = 'block.type.php';
            if (is_new == 'Newtab') {
                var value = '';
            } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value, type_id: static_data_type_id});
        } else if (function_id == 10101010 && static_data_type_id == 42000) {
            calendar_open = true; //declared for refreshing later after addition/update of calendar data
            win.detachToolbar();
            var url = 'documents.type.php';
            if (is_new == 'Newtab') {
                var value = '';
            } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value});
        } else if (function_id == 10101025 && static_data_type_id == 10011) {
            win.detachToolbar();
            var url = 'certification.systems.php';
            if (is_new == 'Newtab') {
                var value = '';
            } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value, type_id: static_data_type_id});
        } else if (static_data_type_id == 28000) {
            win.detachToolbar();
            var url = 'compliance.group.php';
            if (is_new == 'Newtab') {
                var value = '';
        } else {
                var value = static_data_id;
            }
            win.attachURL(url, null, {value_id: value, type_id: static_data_type_id});
        } else {
            var privilege_active = get_row_data["is_privilege_active"];
            // Privilege Check to disable/enable save button
            if (privilege_active == 1 && is_new != 'Newtab') {
                data = {
                            "action": "spa_static_data_privilege",
                            "flag": 'c',
                            "type_id": static_data_type_id,
                            "value_id": col_value
                       };
                adiha_post_data("", data, "", "", "setup_static_data.check_privilege_callback");
            }

            data = {"action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": function_id,
                "template_name": template_name,
                "parse_xml": xml_value
            };
            //alert(xml_value);
            adiha_post_data('return_array', data, '', '', 'setup_static_data.load_form_data', false);
		}
    }

    /**
     * [load the paramters form and attach it to the tab]
     */
    setup_static_data.load_form_data = function(result) {	
        var active_tab_id = setup_static_data.tabbar.getActiveTab();
        var static_data_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        static_data_id = ($.isNumeric(static_data_id)) ? static_data_id : ord(static_data_id.replace(" ", ""));
        var get_selected_data = get_function_id(active_tab_id);
        var type_id = get_selected_data["type_id"];
        var function_id = get_selected_data["function_id"];
        var result_length = result.length;
        var tab_json = '';
        var form_json = {};
		 
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
			form_json[i] = result[i][2];
        }
        
	    var cell_a = setup_static_data.details_layout["inner_tab_layout_" + static_data_id].cells("a");
        cell_a.progressOn();
        tab_json = '{tabs: [' + tab_json + ']}';
        setup_static_data.details_tabs["details_tabs_a_" + static_data_id] = cell_a.attachTabbar();
        setup_static_data.details_tabs["details_tabs_a_" + static_data_id].loadStruct(tab_json);
        setup_static_data.details_tabs["details_tabs_a_" + static_data_id].setTabsMode("bottom");

        // load forms to tabs
        var i = 0;
        setup_static_data.details_tabs["details_tabs_a_" + static_data_id].forEachTab(function(tab) {
            var id = tab.getId();
            var form_index = "details_form_" + static_data_id + "_" + id;
            setup_static_data.details_form[form_index] = tab.attachForm();
            setup_static_data.details_form[form_index].loadStruct(form_json[i]);
            setup_static_data.details_form[form_index].setItemValue('type_id', type_id);
            setup_static_data.details_form[form_index].setUserData('value_id', "function_id",function_id);
            setup_static_data.details_form[form_index].setUserData('value_id', "type_id",type_id);
            i++;  
        });
	   cell_a.progressOff();
    }

    /**
     * [Enable menu items]
     */
    setup_static_data.enable_menu_item = function(id,ind) {
        var c_row = setup_static_data.grid.getChildItemIdByIndex(id, 0);
        var selected_row = setup_static_data.grid.getSelectedRowId();
        var is_privilege_active = 0;

        if(selected_row == null) {
            setup_static_data.menu.setItemDisabled("add");
        }
        
        if (selected_row.indexOf(",") != -1) {
            setup_static_data.menu.setItemDisabled("activate");
            setup_static_data.menu.setItemDisabled("deactivate");
            is_privilege_active = 1;
        } else {
            if (c_row != null) {
                var d_row = setup_static_data.grid.getChildItemIdByIndex(selected_row, 0); //first child value
                is_privilege_active = (d_row == null) ? 0 : setup_static_data.grid.cells(d_row, setup_static_data.grid.getColIndexById('is_privilege_active')).getValue();         
            } else {
                is_privilege_active = setup_static_data.grid.cells(selected_row, setup_static_data.grid.getColIndexById('is_privilege_active')).getValue();         
            }
        }
         
        var is_checked = (setup_static_data.menu.getCheckboxState('chk_internal')) === true ? 1 : 0;

        setup_static_data.menu.setItemDisabled("delete");
        setup_static_data.menu.setItemDisabled("add");
        setup_static_data.menu.setItemDisabled("activate");
        setup_static_data.menu.setItemDisabled("deactivate");

        if (selected_row == '' || c_row != null) { // if selected row is parent            
            if (has_rights_static_data_iu != 0 && is_checked == 0) {
                setup_static_data.menu.setItemEnabled("add");                
            } 
            
            if (has_rights_static_data_privilege != 0) {
                if (is_privilege_active == 0) {
                    setup_static_data.menu.setItemEnabled("activate");  
                } else {
                    setup_static_data.menu.setItemEnabled("deactivate");
                }
                setup_static_data.menu.setItemDisabled("privilege");
            }
        } else { // if child is selected
            if (has_rights_static_data_iu != 0 && is_checked == 0) {
                setup_static_data.menu.setItemEnabled("add");
            } else {
                setup_static_data.menu.setItemDisabled("add");
            }
                        
            if (has_rights_static_data_delete != 0 && is_checked == 0) {
                setup_static_data.menu.setItemEnabled("delete");
            }
            
            if (has_rights_static_data_privilege != 0 && is_privilege_active == 1) {
                setup_static_data.menu.setItemEnabled("privilege");
            }  else {
                setup_static_data.menu.setItemDisabled("privilege");
            }
        }
    }
    
    /**
     * [Disable Add button]
     */
    setup_static_data.check_button = function(){
        var active_tab_id = setup_static_data.tabbar.getActiveTab();
        var selected_row = setup_static_data.grid.getSelectedRowId();
        if (selected_row) {
            setup_static_data.menu.setItemEnabled("add");    
        }else{
            setup_static_data.menu.setItemDisabled("add");    
        }
    }
     
    /**
     * [ get the function ID and Type of selected data from tab]
     */
    function get_function_id(tab_id){
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));       

        var selected_row = "";
        var primary_value = setup_static_data.grid.findCell(object_id, 1, true,true);   
        var selected_row = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
        if(selected_row == ""){
             var selected_row = setup_static_data.grid.getSelectedRowId();
        }        
        var function_id = setup_static_data.grid.cells(selected_row, 5).getValue();
        var template_name = setup_static_data.grid.cells(selected_row, 6).getValue();
        var col_name = setup_static_data.grid.cells(selected_row, 7).getValue();
        var type_id= setup_static_data.grid.cells(selected_row, 4).getValue();
        var value_id= setup_static_data.grid.cells(selected_row, 2).getValue();
        var is_privilege_active= setup_static_data.grid.cells(selected_row, 8).getValue();
        
        if(function_id == ""){
            var child_row = setup_static_data.grid.getChildItemIdByIndex(selected_row, 0);

            function_id = setup_static_data.grid.cells(child_row, 5).getValue();
            template_name = setup_static_data.grid.cells(child_row, 6).getValue();
            col_name = setup_static_data.grid.cells(child_row, 7).getValue();
            type_id= setup_static_data.grid.cells(child_row, 4).getValue();
            value_id= setup_static_data.grid.cells(child_row, 2).getValue();
            is_privilege_active= setup_static_data.grid.cells(child_row, 8).getValue();
         }

         var return_array = new Array();
         return_array["function_id"] = function_id;
         return_array["type_id"] = type_id;
         return_array["template_name"] = template_name;
         return_array["col_name"] = col_name;
         return_array["value_id"] = value_id;
         return_array["is_privilege_active"] = is_privilege_active;

        
      return return_array;
    }
     
    /**
     * [Returns validation messages]
     */
    function get_message(message_code) {
        switch (message_code) {
            case 'VALIDATE_DATA':
                return 'Please select data you want to delete.';
            case 'DELETE_CONFIRM':
                return 'Are you sure you want to delete?';
        }
    }

    function refresh_grid_after_privilege(operation, unique_id, new_value_id, tab_name) {
        var is_checked = (setup_static_data.menu.getCheckboxState('chk_internal')) === true ? 1 : 0;
        var is_inactive_checked = (setup_static_data.menu.getCheckboxState('chk_inactive')) === true ? 0 : 1;

        if (operation === undefined) {
            operation = false;
        }
        if (unique_id === undefined) {
            unique_id = false;
        }

        if (new_value_id === undefined) {
            new_value_id = false;
        }

        if (tab_name === undefined) {
            tab_name = false;
        }

        if (is_checked == 1) {
            setup_static_data.menu.setItemDisabled("add");
        }

        var data = {
            "action" : "spa_StaticDataValues",
            "flag" : "g",
            "internal_external" : is_checked,
            "grid_type" : "tg",
            "grouping_column" : "type_name,code",
			"active_inactive_filter" : is_inactive_checked
          };

        var sql_param = $.param(data);
        var sql_url = js_data_collector_url + "&" + sql_param;

        setup_static_data.grid.clearAll();
		setup_static_data.grid.loadXML(sql_url, function(){
            setup_static_data.grid.filterByAll();
            if(operation == 'u') {
              selectCurrentRow(unique_id,new_value_id,tab_name);
            }
        });  
        setup_static_data.menu.setItemDisabled("add");
        setup_static_data.menu.setItemDisabled("activate");
        setup_static_data.menu.setItemDisabled("deactivate");
        setup_static_data.menu.setItemDisabled("privilege");
        setup_static_data.menu.setItemDisabled("delete");
    }


    function selectCurrentRow(unique_id,new_value_id,tab_name){
        var new_data_id = "";
        var find_row = setup_static_data.grid.findCell(unique_id, 1, true,true);
        var selected_row = find_row.toString().substring(0, find_row.toString().indexOf(","));

        setup_static_data.grid.selectRowById(find_row,false,true,true);
        if(new_value_id){
            var primary_value = setup_static_data.grid.cells(selected_row,2).getValue();
            var primary_func_id = setup_static_data.grid.cells(selected_row,5).getValue();

            if(primary_value == new_value_id && primary_func_id == function_id){
                new_data_id = setup_static_data.grid.cells(selected_row, 1).getValue();
            }

            var tab_id = 'tab_' + new_data_id;
            var active_tab_id = setup_static_data.tabbar.getActiveTab();
            var tab_index = setup_static_data.tabbar.tabs(active_tab_id).getIndex();

            //if(tab_id != active_tab_id){
            if (setup_static_data.pages[active_tab_id])
                delete setup_static_data.pages[active_tab_id];
            setup_static_data.tabbar.cells(active_tab_id).close(false);
            setup_static_data.tabbar.tabs(active_tab_id).close(true);
            setup_static_data.create_tab_custom(tab_id, tab_name, '', '', tab_index, selected_row);
            //}
        }
        setup_static_data.grid.openItem(setup_static_data.grid.getParentId(selected_row));
        setup_static_data.grid.loadOpenStates();
        setup_static_data.grid.filterByAll();
        setup_static_data.grid.selectRowById(selected_row,false,true,true);
    }
</script>
</html>