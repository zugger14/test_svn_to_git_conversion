<?php
/**
* Report manager dataset screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
        require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php'); 
    ?>
</head>
<body>
	<!-- load ace -->
	<script src="../../../adiha.php.scripts/components/lib/ace/ace.js"></script>
	<!-- load ace language tools -->
	<script src="../../../adiha.php.scripts/components/lib/ace/ext-language_tools.js"></script>

    <?php     
    //print '<pre>';print_r($_POST);print '</pre>';die();
    $ds_info_obj = isset($_POST['ds_info_obj']) ? json_decode($_POST['ds_info_obj']) : '';
    $call_from = get_sanitized_value($_POST['call_from'] ?? '');
    $process_id = $ds_info_obj->{'process_id'};
    $report_dataset_id = '';
    $source_id = '';
    $tsql = '';
    $type_id = '';
    $ds_alias = '';
    $ds_name = '';

    if($ds_info_obj->{'ds_flag'} == 'u') {
        $report_dataset_id = $ds_info_obj->{'dataset_id'};
        $sp_url = "EXEC spa_rfx_report_dataset_dhx @flag=e, @report_dataset_id=" . $report_dataset_id . ", @process_id='" . $process_id . "'";
        $read_xml = readXMLURL2($sp_url);
        $ds_name = $read_xml[0]['name'];
        $ds_alias = $read_xml[0]['alias'];
        $tsql = $read_xml[0]['tsql'];
        //echo str_replace("\n","\\n", $tsql);die();
        $type_id = $read_xml[0]['type_id'];
        $source_id = $read_xml[0]['source_id'];
		$enable_relations = true;
    }
    
    
    $form_namespace = 'rm_dataset';
    $layout_json = "[{id:'a'}]";
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    
    
    // attach menu
    $toolbar_json = '[
        {id: "save", type: "button", img: "save.gif", imgdis:"save_dis.gif", text: "Save", title: "Save"},
        {id: "help", type: "button", text: "Help", img: "help.gif", img_disabled: "help_dis.gif"}
    ]';
    
    $toolbar_obj = new AdihaToolbar();
    echo $layout_obj->attach_toolbar_cell("toolbar_ds", 'a');  
    echo $toolbar_obj->init_by_attach("toolbar_ds", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    $source_list_url = "EXEC spa_rfx_data_source_dhx @flag='p', @report_id='" . $ds_info_obj->{'report_id'} . "'";
    $source_list_arr = readXMLURL2($source_list_url);
    
    
    echo $layout_obj->close_layout();
    ?> 
    <div id="div_ds_cols" class="col-listings-from-tsql" ></div>
</body>
<!--<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui.min.js"></script>-->
<script type="text/javascript"> 
    var post_data = '';
    var ds_info_obj = $.parseJSON('<?php echo json_encode($ds_info_obj); ?>');
    var report_dataset_id_gbl = '<?php echo $report_dataset_id; ?>';
    var source_list_arr = $.parseJSON('<?php echo json_encode($source_list_arr);?>');
    var this_window = parent.dhx_wins.window('window_ds');
    var validated_tsql_gbl = '';
    var source_id_gbl = '<?php echo $source_id; ?>';
    
    
    var theme_selected = 'dhtmlx_' + default_theme;
    
    $(function() {
        grid_obj_connected_source = {};
		
        rm_dataset.fx_init_tabs();
        rm_dataset.fx_load_general_contents();
        rm_dataset.fx_load_relationship_contents();
		
		
        
        //set confirm on closing dhtmlx window
        this_window.attachEvent('onClose', function(win) {
            //console.log(win.skip_close_event);
            var unsaved_auto_joins = false;
            grid_obj_relation_joins.forEachRow(function(rid) {
                if(grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('relationship_id')).getValue() == -1) {
                    unsaved_auto_joins = true;
                }
            });            
            if(win.skip_close_event || !unsaved_auto_joins) {
                parent.ifr_dhx.ifr_tab[ds_info_obj.process_id].fx_refresh_grid('grid_ds');
                return true;
            }
            /*
            confirm_messagebox('There are unsaved relations suggested. Do you want to close without saving?', function() {
                win.skip_close_event = true;
                win.close();
            });
            */
            dhtmlx.message({
                title: "Warning",
                type: "confirm-warning",
                text: 'Some unsaved relations are displayed in the Relation grid. Are you sure you want to close?',
                callback: function(e) {
                    if(e) {
                        win.skip_close_event = true;
                        win.close();
                    }
                }
            });
        });

        // Added Help Popup
        help_popup = new dhtmlXPopup({ 
            toolbar: rm_dataset.toolbar_ds,
            id: "help",
            mode: "right"
        });
        help_content = '<ul>';
        help_content += '<li><a>Use Multiline Script Identifier (available from context menu) for multi line data source scripts.</a></li>';
        help_content += '<li><a>Apply filters in data source instead of report whenever applicable for performance improvement.</a></li>';
        help_content += '<li><a>Handle data source filters for nullability unless it is marked as Required Filter.</a></li>';
        help_content += '<li><a>Avoid formatting data (e.g. date format, rounding) in data source. It is best done in reports.</a></li>';
        help_content += '<li><a>Give each column a meaningful alias name in proper case. For e.g. As of Date instead of as_of_date.</a></li>';
        help_content += '<li><a>Define key columns, that uniquely identifies a data row in data source whenever possible.</a></li>';
        help_content += '<li><a>Choose matching widget type (control) for data source columns. For e.g. calendar for date (As of Date), dropdown for list (Buy/Sell Flag), data browser for long list (Counterparty).</a></li>';
        help_content += '</ul>';
        help_popup.attachHTML(help_content);
        help_popup_click_count = 0;       
        
        help_popup.attachEvent("onBeforeHide", function(type, ev, id){
            if (type == 'click') {
                if (help_popup_click_count%2 == 1) {
                    help_popup.hide();                    
                }                
                help_popup_click_count++;
            }
        });
    });
    //init tabs general,relationship
    rm_dataset.fx_init_tabs = function() {
        var json_tabs = [
            {
            id:      "tab_general",      // tab id
            text:    "General",    // tab text
            width:   null,      // numeric for tab width or null for auto, optional
            index:   1,      // numeric for tab index or null for last position, optional
            active:  true,      // boolean, make tab active after adding, optional
            enabled: true,     // boolean, false to disable tab on init
            close:   false       // boolean, render close button on tab, optional
            },
            {
            id:      "tab_relationship",
            text:    "Relationship",
            width:   null,
            index:   2,
            active:  false,
            enabled: true,
            close:   false
            }
        ];
        ds_tabbar = rm_dataset.layout.cells('a').attachTabbar({
            tabs: json_tabs,
            mode: 'bottom'
        });
        
        //hide tab relationship if insert mode
        if(ds_info_obj.ds_flag == 'i') {
            ds_tabbar.tabs('tab_relationship').hide();
        } else { //update mode
            ds_tabbar.tabs('tab_relationship').show();
        }
    };
    
    //load general tab contents
    rm_dataset.fx_load_general_contents = function() {
        //attach layout to tab general
        layout_general = ds_tabbar.cells('tab_general').attachLayout({
            pattern: '2E',
            cells: [
                {id:'a', header: false, height: 50},
                {id:'b', header: false}
            ]
        });
        
        //attach form to layout general
        var form_json_general = rm_dataset.fx_get_form_json('form_general_tab');
        form_obj_general = layout_general.cells('a').attachForm(form_json_general);
        
        //populate view combo
        var cmb_view = form_obj_general.getCombo('cmb_view');
        cmb_view.clearAll();
        var cmb_view_param = {
            "action": 'spa_rfx_data_source_dhx',
            "call_from": "form",
            "has_blank_option": "false",
            "flag": 'v',
            "SELECTED_VALUE": '<?php echo $source_id; ?>'
        };
        cmb_view_param = $.param(cmb_view_param);
        var cmb_view_url = js_dropdown_connector_url + '&' + cmb_view_param;
        cmb_view.load(cmb_view_url, function() {
            cmb_view.sort('asc');
        });
        //populate table combo
        var cmb_table = form_obj_general.getCombo('cmb_table');
        cmb_table.clearAll();
        var cmb_table_param = {
            "action": 'spa_rfx_data_source_dhx',
            "call_from": "form",
            "has_blank_option": "false",
            "flag": 't',
            "SELECTED_VALUE": '<?php echo $source_id; ?>'
        };
        cmb_table_param = $.param(cmb_table_param);
        var cmb_table_url = js_dropdown_connector_url + '&' + cmb_table_param;
        cmb_table.load(cmb_table_url, function() {
            cmb_table.sort('asc');
        });
        
        //onchange event on datset_type combo
        var cmb_ds_type = form_obj_general.getCombo('dataset_type');
        cmb_ds_type.attachEvent('onChange', rm_dataset.fx_ds_type_onchange);
        
        //onchange event on view combo
        var cmb_view = form_obj_general.getCombo('cmb_view');
        cmb_view.attachEvent('onChange', rm_dataset.fx_view_onchange);
        
        //onchange event on table combo
        var cmb_table = form_obj_general.getCombo('cmb_table');
        cmb_table.attachEvent('onChange', rm_dataset.fx_table_onchange);
        
        
        rm_dataset.fx_load_tabs_general_tab_layout();
    };
    
    //load tabs on general tab layout
    rm_dataset.fx_load_tabs_general_tab_layout = function() {
        var json_tabs = [
            {
            id:      "tab_sql",      // tab id
            text:    "SQL",    // tab text
            width:   null,      // numeric for tab width or null for auto, optional
            index:   1,      // numeric for tab index or null for last position, optional
            active:  true,      // boolean, make tab active after adding, optional
            enabled: true,     // boolean, false to disable tab on init
            close:   false       // boolean, render close button on tab, optional
            },
            {
            id:      "tab_ds_columns",
            text:    "Columns",
            width:   null,
            index:   2,
            active:  false,
            enabled: true,
            close:   false
            }
        ];
        ds_tabbar_general = layout_general.cells('b').attachTabbar({
            tabs: json_tabs,
            mode: 'top'
        });
        
        //attach menu (validate) on sql tab
        menu_obj_sql_tab = ds_tabbar_general.cells('tab_sql').attachMenu({
            icons_path: js_image_path + 'dhxmenu_web/',
            items:[
                {id: 'validate', text: 'Validate', title: 'Validate', img: 'verify.gif', img_dis: 'verify_dis.gif'}
            ]
        });
        menu_obj_sql_tab.attachEvent('onClick', function(id) {
            if(id == 'validate') {
                rm_dataset.fx_validate_sql('validate');
            }
            
        });
       
		
		form_obj_sql_tab = ds_tabbar_general.cells('tab_sql').attachHTMLString('<div id="editor" style="font-family:\'PT Mono\'" class="code-editor"></div>');
        
		ace.require("ace/ext/language_tools");
		var editor = ace.edit("editor");
		editor.session.setMode("ace/mode/sqlserver");
		editor.setTheme("ace/theme/sqlserver");
		editor.setValue("<?php echo str_replace('"','\\"', str_replace("\r","\\n", str_replace("\n","\\n", $tsql))); ?>", -1);
		// enable autocompletion and snippets
		editor.setOptions({
			enableBasicAutocompletion: true,
			enableSnippets: true,
			enableLiveAutocompletion: false
		});

        // keywords identifier
        tag_context_menu = new dhtmlXMenuObject();
        tag_context_menu.renderAsContextMenu();
        var tag_obj = [{id:"add_batch_report", text:"Batch Report"}];
        tag_context_menu.loadStruct(tag_obj);
        tag_context_menu.addContextZone("editor");
        tag_context_menu.attachEvent("onClick", function(id, zoneId){
            // Retrieve cursor position
            var cursor_position = editor.getCursorPosition();
            // Insert text (second argument) with given position
            editor.session.insert(cursor_position,"--[__batch_report__]");
        });
		
        //trigger acc to mode flag
        if(ds_info_obj.ds_flag == 'i') {
            rm_dataset.fx_ds_type_onchange(1);    
        } else if(ds_info_obj.ds_flag == 'u') {
            form_obj_general.disableItem('dataset_type');
            var type_id_update = '<?php echo $type_id; ?>';
            var source_id_update = '<?php echo $source_id; ?>';
            rm_dataset.fx_ds_type_onchange(type_id_update);
            if(type_id_update == 1) { //view
                rm_dataset.fx_view_onchange(source_id_update);
            } else if(type_id_update == 3) { //table
                rm_dataset.fx_table_onchange(source_id_update);
            } else if(type_id_update == 2) { //sql
                //handled by rm_dataset.fx_ds_type_onchange()
            }
        }
    };
    
    //validate click event
    rm_dataset.fx_validate_sql = function(call_from) {
        /*if(!validate_form(form_obj_sql_tab)) {
            form_obj_sql_tab.resetValidateCss('txt_sql');
            return false;
        }*/
        
        
        
        ds_tabbar_general.cells('tab_ds_columns').progressOn();
        var editor = ace.edit("editor");
		var tsql = editor.getValue();

		if(tsql == '') {return;}
		
        var parameter_string = prepare_parameters(tsql);
        var sql = unescapeXML(tsql);  
        //console.log(sql);console.log(tsql);   
        var with_criteria = (sql.split('{').length > 1) ? 'n' : 'y';                
        
        var url = 'report.manager.dhx.dataset.column.ajax.php' 
                + '?process_id=' + ds_info_obj.process_id
                + '&source_id=' + source_id_gbl
                + '&mode=' + ds_info_obj.ds_flag
                + '&call_from=ds_sql'
                + '&criteria=' + parameter_string
                + '&with_criteria=' + with_criteria; 
        
        //return;
        $.ajax({
            data : {
                tsql : sql
            },
            type : "POST",
            url : url,
            dataType : 'text',
            success : function (response) {                   
                try {
                    var return_response = $.parseJSON(response);                         
                } catch(e) {
                    var return_response = '';
                }  
                
                if (return_response[0] == 'missing_parameters' && return_response[1] != null) {                            
                    //var success_message = (return_response[1] == null) ? get_message('VALIDATE_SQL_CUSTOM_QUERY_PARAMETERS') : get_message('VALIDATE_SQL_QUERY_PARAMETERS') + return_response[1];
                    var success_message = get_message('VALIDATE_SQL_QUERY_PARAMETERS') + return_response[1];
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: success_message,
                    });
                    ds_tabbar_general.cells('tab_ds_columns').progressOff();
                    return false;
                } else if (return_response[0] == 'check_query') {                        
                    var success_message = get_message('VALIDATE_SQL_QUERY');
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: return_response[1],
                    });
                    ds_tabbar_general.cells('tab_ds_columns').progressOff();
					
					var editor = ace.edit("editor");
					editor.gotoLine(return_response[2]);
                    return false;
                } else {
                    $('.col-listings-from-tsql').html(response);
                    validated_tsql_gbl = tsql;

                    // enables the save button if the data in the components are changed
                    $('.col-listings-from-tsql input, .col-listings-from-tsql select').change(function () {
                        //set_btn_save_enabled(has_rights_sql_save);
                    });
                    
                    ds_tabbar_general.cells('tab_ds_columns').attachObject('div_ds_cols');

                    //document.location.hash = "#traced-columns";
                }
                
                ds_tabbar_general.cells('tab_ds_columns').setActive();
                ds_tabbar_general.cells('tab_ds_columns').progressOff();
                return true;
            },
            error : function () {
                alert('RPC call failed');
                ds_tabbar_general.cells('tab_ds_columns').progressOff();
                return false;
            }
        });
        
    };

    //function to save sql dataset
    rm_dataset.fx_save_sql_ds = function() {
        var source_id = form_obj_general.getItemValue('sql_source_id');
        var report_dataset_id = form_obj_general.getItemValue('dataset_id');
        var name = unescape(form_obj_general.getItemValue('ds_name'));
        var ds_alias = trim(form_obj_general.getItemValue('ds_alias'));
        ds_alias = unescape(ds_alias);
        
		var editor = ace.edit("editor");
		var raw_tsql = editor.getValue();
		var tsql = unescapeXML(raw_tsql);
        var find = "'";
        var re = new RegExp(find, 'g');
        tsql = tsql.replace(re, "''");
        var sql_cols = get_column_rows();
        
        var mode_value = '';
        var parameter_string = prepare_parameters(tsql);

        if (report_dataset_id == '') {
            mode_value = 'i';
        } else {
            mode_value = 'u';
        }

        var sp_string = "EXEC spa_rfx_report_dataset_dhx @flag='" + mode_value + "'"
            + ", @process_id='" + ds_info_obj.process_id + "'"
            + ", @report_dataset_id='" + report_dataset_id + "'"
            + ", @source_id='" + source_id + "'"
            + ", @report_id='" + ds_info_obj.report_id + "'"
            + ", @name='" + name + "'"
            + ", @alias='" + ds_alias + "'"
            + ", @tsql='" + tsql + "'"
            + ", @type_id=2"
            + ", @criteria='" + parameter_string + "'"
            + ", @tsql_column_xml='" + sql_cols + "'"
            + ""; 
        post_data = { sp_string: sp_string };
        
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                // success_call(get_message('VALIDATE_AJAX'));
                //rm_dataset.toolbar_ds.disableItem('save');
                form_obj_general.setItemValue('dataset_id', json_data.message);
                ds_info_obj.dataset_id = json_data.message;
                form_obj_general.setItemValue('sql_source_id', json_data.recommendation);
                form_obj_general.disableItem('dataset_type');

                ds_tabbar.tabs('tab_relationship').show();
                rm_dataset.fx_save_relation_joins();
               
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_data.message
                });
            }
            ds_tabbar_general.cells('tab_ds_columns').progressOff();
        });
    }
    
    //hide show components on ds type basis
    rm_dataset.fx_ds_type_onchange = function(value, text) {
        if(value == 1) { //view
            form_obj_general.showItem('cmb_view');
            form_obj_general.setRequired('cmb_view', true);
            form_obj_general.hideItem('cmb_table');
            form_obj_general.setRequired('cmb_table', false);
            form_obj_general.hideItem('ds_name');
            form_obj_general.setRequired('ds_name', false);
            
            ds_tabbar_general.cells('tab_sql').hide();
            $('#div_ds_cols').html('');
            var view_id = form_obj_general.getItemValue('cmb_view');
            if(view_id != '') {
                rm_dataset.fx_view_onchange(view_id);
            }
            
        } else if (value == 2) { //sql
            form_obj_general.hideItem('cmb_view');
            form_obj_general.setRequired('cmb_view', false);
            form_obj_general.hideItem('cmb_table');
            form_obj_general.setRequired('cmb_table', false);
            form_obj_general.showItem('ds_name');
            form_obj_general.setRequired('ds_name', true);
            
            ds_tabbar_general.cells('tab_sql').show();
            ds_tabbar_general.cells('tab_sql').setActive();
            $('#div_ds_cols').html('');
            rm_dataset.fx_validate_sql('on_type_change');
        } else { //table
            form_obj_general.hideItem('cmb_view');
            form_obj_general.setRequired('cmb_view', false);
            form_obj_general.showItem('cmb_table');
            form_obj_general.setRequired('cmb_table', true);
            form_obj_general.hideItem('ds_name');
            form_obj_general.setRequired('ds_name', false);
            
            ds_tabbar_general.cells('tab_sql').hide();
            $('#div_ds_cols').html('');
            var table_id = form_obj_general.getItemValue('cmb_table');
            if(table_id != '') {
                rm_dataset.fx_table_onchange(table_id);
            }
        }
    };
    
    //event on view change
    rm_dataset.fx_view_onchange = function(value, text) {
        ds_tabbar_general.cells('tab_ds_columns').progressOn();
        var url = 'report.manager.dhx.dataset.column.ajax.php' 
                + '?process_id=' + ds_info_obj.process_id
                + '&source_id=' + value
                + '&call_from=ds_view'
                + '&mode=' + ds_info_obj.ds_flag;
        $.ajax({
            data : {
                tsql : ''
            },
            type : "POST",
            url : url,
            dataType : 'text',
            success : function (response) {                   
                try {
                    var return_response = $.parseJSON(response);                         
                } catch(e) {
                    var return_response = '';
                }  
                
                if (return_response[0] == 'missing_parameters' && return_response[1] != null) {                            
                    //var success_message = (return_response[1] == null) ? get_message('VALIDATE_SQL_CUSTOM_QUERY_PARAMETERS') : get_message('VALIDATE_SQL_QUERY_PARAMETERS') + return_response[1];
                    var success_message = get_message('VALIDATE_SQL_QUERY_PARAMETERS') + return_response[1];
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: success_message,
                    });
                    return;
                } else if (return_response[0] == 'check_query') {                        
                    var success_message = get_message('VALIDATE_SQL_QUERY');
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: success_message,
                    });
                    return;
                } else {
                    $('.col-listings-from-tsql').html(response);

                    // enables the save button if the data in the components are changed
                    $('.col-listings-from-tsql input, .col-listings-from-tsql select').change(function () {
                        //set_btn_save_enabled(has_rights_sql_save);
                    });
                    
                    ds_tabbar_general.cells('tab_ds_columns').attachObject('div_ds_cols');

                    //document.location.hash = "#traced-columns";
                }
                ds_tabbar_general.cells('tab_ds_columns').progressOff();
            },
            error : function () {
                alert('RPC call failed');
                ds_tabbar_general.cells('tab_ds_columns').progressOff();
            }
        });
    };
    //event on table change
    rm_dataset.fx_table_onchange = function(value, text) {
        ds_tabbar_general.cells('tab_ds_columns').progressOn();
        var url = 'report.manager.dhx.dataset.column.ajax.php' 
                + '?process_id=' + ds_info_obj.process_id
                + '&source_id=' + value
                + '&mode=' + ds_info_obj.ds_flag
                + '&call_from=ds_table'; 
        $.ajax({
            data : {
                tsql : ''
            },
            type : "POST",
            url : url,
            dataType : 'text',
            success : function (response) {                   
                try {
                    var return_response = $.parseJSON(response);                         
                } catch(e) {
                    var return_response = '';
                }  
                
                if (return_response[0] == 'missing_parameters' && return_response[1] != null) {                            
                    //var success_message = (return_response[1] == null) ? get_message('VALIDATE_SQL_CUSTOM_QUERY_PARAMETERS') : get_message('VALIDATE_SQL_QUERY_PARAMETERS') + return_response[1];
                    var success_message = get_message('VALIDATE_SQL_QUERY_PARAMETERS') + return_response[1];
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: success_message,
                    });
                    return;
                } else if (return_response[0] == 'check_query') {                        
                    var success_message = get_message('VALIDATE_SQL_QUERY');
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: success_message,
                    });
                    return;
                } else {
                    $('.col-listings-from-tsql').html(response);

                    // enables the save button if the data in the components are changed
                    $('.col-listings-from-tsql input, .col-listings-from-tsql select').change(function () {
                        //set_btn_save_enabled(has_rights_sql_save);
                    });
                    
                    ds_tabbar_general.cells('tab_ds_columns').attachObject('div_ds_cols');

                    //document.location.hash = "#traced-columns";
                }
                ds_tabbar_general.cells('tab_ds_columns').progressOff();
            },
            error : function () {
                alert('RPC call failed');
                ds_tabbar_general.cells('tab_ds_columns').progressOff();
            }
        });
    };
    
    /**
     * toolbar save click
     * @param id 
     */
    rm_dataset.toolbar_click = function(id) {
        switch (id) {
            case 'save':
                rm_dataset.save_dataset();
                break;
            case 'help':               
                help_popup.show('help');
            break;            
        }
    };

    /**
     * Save Dataset
     */
    rm_dataset.save_dataset = function() {
        
        if(!validate_form(form_obj_general)) {
            return;
        }
        
        if(!rm_dataset.fx_validate_relation_joins()) {
            return;
        }
        
        var dataset_type = form_obj_general.getItemValue('dataset_type');
        var report_dataset_id = form_obj_general.getItemValue('dataset_id');
        var ds_alias = trim(form_obj_general.getItemValue('ds_alias'));
        ds_alias = unescape(ds_alias);

        if (ds_alias.indexOf(' ')> -1) {
            var success_message = get_message('ALIAS_WITH_SPACE');
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: success_message,
            });
            return;
        }
        
        if(dataset_type == 1) { //view save
            
	
            var source_id = form_obj_general.getItemValue('cmb_view');
	
            if (source_id == 'NULL') {
                var success_message = get_message('VALIDATE_VIEW');
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: success_message,
                });
                return;
            }
	
            var mode_value = '';
	
            if (report_dataset_id == '') {
                var success_message = get_message('INSERT_SUCCESS');                
                mode_value = 'i';
            } else {
                var success_message = get_message('UPDATE_SUCCESS');
                mode_value = 'u';
            }
	
            
            var sp_string = "EXEC spa_rfx_report_dataset_dhx @flag='" + mode_value + "'"
                + ", @process_id='" + ds_info_obj.process_id + "'"
                + ", @report_dataset_id='" + report_dataset_id + "'"
                + ", @source_id='" + source_id + "'"
                + ", @report_id='" + ds_info_obj.report_id + "'"
                + ", @alias='" + ds_alias + "'"
                + ""; 
            post_data = { sp_string: sp_string };
            //console.log(sp_string);
            
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                
                var json_data = data['json'][0];
                if(json_data.errorcode == 'Success') {
                    //success_call(success_message);
                    //rm_dataset.toolbar_ds.disableItem('save');
                    if (mode_value == 'i') {
                        form_obj_general.setItemValue('dataset_id', json_data.message);
                        form_obj_general.disableItem('dataset_type');
                        ds_info_obj.dataset_id = json_data.message;
                        ds_tabbar.tabs('tab_relationship').show();
                        success_call('Changes have been saved successfully.');
                    } else if(mode_value == 'u') {
                        rm_dataset.fx_save_relation_joins();
                    }
                    
                } else {
                    dhtmlx.message({
                        title: 'Error',
                        type: 'alert-error',
                        text: json_data.message
                    });
                }
                
            });
	
            
        } else if(dataset_type == 2) { //sql save
            var ds_name = form_obj_general.getItemValue('ds_name');
            console.log(ds_name)
            var reg_exp = /^[a-zA-Z0-9-_ ]+$/; /** supports alphanumeric, dash -, underscore _, space  **/
            if (ds_name.search(reg_exp) == -1) { 
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: 'Dataset name should not contain special character(s).',
                });
                return false;
            }

            var editor = ace.edit("editor");
            var raw_tsql = editor.getValue();

            if(validated_tsql_gbl != raw_tsql) {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: 'Please validate the sql.',
                });
                ds_tabbar_general.cells('tab_ds_columns').progressOff();
                return false;
            } else {
                rm_dataset.fx_save_sql_ds();
            }
            
            
	    } else if(dataset_type == 3) { //table save
            var source_id = form_obj_general.getItemValue('cmb_table');
            
            var mode_value = '';
            
            mode_value = (report_dataset_id == '') ? 'i' : 'u';   
            
            var sp_string = "EXEC spa_rfx_report_dataset_dhx @flag='" + mode_value + "'"
                + ", @process_id='" + ds_info_obj.process_id + "'"
                + ", @report_dataset_id='" + report_dataset_id + "'"
                + ", @source_id='" + source_id + "'"
                + ", @report_id='" + ds_info_obj.report_id + "'"
                + ", @alias='" + ds_alias + "'"
                + ""; 
            post_data = { sp_string: sp_string };
            //console.log(sp_string);
            var success_message = (mode_value == 'i') ? get_message('INSERT_SUCCESS') : get_message('UPDATE_SUCCESS');
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                
                var json_data = data['json'][0];
                if(json_data.errorcode == 'Success') {
                    success_call(success_message);
                    //rm_dataset.toolbar_ds.disableItem('save');
                    if (mode_value == 'i') {
                        form_obj_general.setItemValue('dataset_id', json_data.message);
                        form_obj_general.disableItem('dataset_type');

                        ds_tabbar.tabs('tab_relationship').show();
                        
                    } else if(mode_value == 'u') {
                        rm_dataset.fx_save_relation_joins();
                    }
                } else {
                    dhtmlx.message({
                        title: 'Error',
                        type: 'alert-error',
                        text: json_data.message
                    });
                }
                
            });         
	    }
    };
    
    //returns form json for general tab layout
    rm_dataset.fx_get_form_json = function(type) {
        var form_json = [];
        if(type == 'form_general_tab') {
            form_json = [ 
                {"type": "settings", "position": "label-top", "offsetLeft": ui_settings.offset_left, "offsetTop": 5, "inputWidth":ui_settings.field_size},
                {type:"combo", name: "dataset_type", label:"Dataset Type", required:true, filtering:true
                , options: [
                    {value: "1", label: "View", selected: <?php echo ($type_id == 1) ? 1 : 0 ?>},
                    {value: "2", label: "SQL", selected: <?php echo ($type_id == 2) ? 1 : 0 ?>},
                    {value: "3", label: "Table", selected: <?php echo ($type_id == 3) ? 1 : 0 ?>},
                ]}, {type:"newcolumn"},
                {type:"combo", name: "cmb_view", label:"Views", required:true, validate:"ValidInteger",filtering:true, options: [],userdata:{validation_message:"Required Field"}}, {type:"newcolumn"},
                {type:"combo", name: "cmb_table", label:"Tables", required:true, filtering:true, options: []}, {type:"newcolumn"},
                {type:"input", name: "ds_name", value: "<?php echo $ds_name; ?>", label:"Name", required:true}, {type:"newcolumn"},
                {type:"input", name: "ds_alias", value: "<?php echo $ds_alias; ?>", label:"Alias", required:true,userdata:{validation_message:"Required Field"}},
                {type:"input", name: "dataset_id", value: "<?php echo $report_dataset_id; ?>", hidden:true},
                {type:"input", name: "sql_source_id", value: "<?php echo ($type_id == 2) ? $source_id : '' ?>", hidden:true}
            
            ];
        } else if(type == 'form_sql_tab') {
            form_json = [ 
                {"type": "settings", "position": "label-top", "offsetLeft": 3, "offsetTop": 3},
                {type:"input", rows: 1, name: "txt_sql"
                , value: "<?php echo str_replace('"','\\"', str_replace("\r","\\n", str_replace("\n","\\n", $tsql))); ?>"
                //, value: "select * from report"
                , required:true, style:"width:1150px;height:250px;", userdata:{"validation_message":"Required Field."}}
            
            ];
        }
         
        return form_json;
    };
    
    //prepare parameter string for validate tsql (old code)
    function prepare_parameters(tsql) {
        var parameter_string = '';
        var unesape_tsql = unescape(tsql);
        var parameter_array = new Array();
        var sql_keywords = [
            '@@FETCH_STATUS',
            '@@ROWCOUNT',
            '@@ERROR',
            '@@IDENTITY',
            '@@TRANCOUNT'
            //add others as required
        ];
        
        if (unesape_tsql.match(/@([^_]\w+)/g)) {
            parameter_array = unesape_tsql.match(/@([^_]\w+)/g);

            //removed duplicate items in array and rejected sql keywords while formation of report filter.
            parameter_array = _.reject(_.uniq(parameter_array), function(data) {
                return _.contains(sql_keywords,data.toUpperCase());
            });
        }

        for (var j = 0; j < parameter_array.length; j++) {
            parameter_array[j] = parameter_array[j].replace(/[^\w]/gi, '');
            parameter_array[j] = parameter_array[j] + ' = 1900';
        }

        parameter_string = parameter_array.join(',');
        return parameter_string;
    }
    
    //get sql xml columns (old code)
    function get_column_rows() {
        var datasource = $('#datasource-region tr.clone');
        var xml_ds_columns = '<Root>';
        var context, column_id, column_name, column_alias, column_tooltip, param_optional, filter, key_column, data_type, widget_type, default_value, renderas, source_value;

        datasource.each(function () {
            context = $(this);
            column_id = $('.column-id', context).val();
            column_name = $('.dataset-column', context).val();
            column_alias = $('.dataset-alias', context).val();
	
            if ($.trim(column_alias) == '') {
                column_alias = column_name;
            }

            column_tooltip = $('.dataset-tooltip', context).val();
            param_optional = ($('.param-optional:checked', context).val() == undefined) ? 0 : $('.param-optional:checked', context).val();

            required_filter = $('.required-filter', context).is(':disabled') ? -1 : $('.required-filter', context).is(':checked') ? 1 : 0;
            
            filter = ($('.append-filter:checked', context).val() == undefined) ? 0 : $('.append-filter:checked', context).val();
            key_column = ($('.key-column:checked', context).val() == undefined) ? 0 : $('.key-column:checked', context).val();
            data_type = $('.datatype-list', context).val();
            widget_type = $('.datawidget-list', context).val();
            default_value = $('.defult_value_list', context).val();
            renderas = $('.renderas-list', context).val();
			
			// Include Multiselect Combo's SQL String in XML.
            if (widget_type == '2' || widget_type == '9') {
                source_value = $('.source-list', context).val();
            } else if (widget_type == '7') {
                source_value = $('.source-list-open-window', context).val();
            } else {
                source_value = '';
            }
	
            source_value = source_value.split('+').join('_ADD_');
            source_value = source_value.split("'").join("''");
	
            xml_ds_columns += '<PSRecordset DataSourceColumnID="' + column_id 
                                + '" Name="' + column_name 
                                + '" Alias="' + column_alias 
                                + '" Tooltip="' + column_tooltip 
                                //+ '" RequiredParam="' + param_optional 
                                + '" RequiredFilter="' + required_filter 
                                + '" Widget="' + widget_type
                                + '" DataType="' + data_type 
                                + '" ParamDataSource="' + source_value 
                                + '" ParamDefaultValue="' + default_value 
                                //+ '" AppendFilter="' + filter 
                                + '" ColumnTemplate="' + renderas 
                                + '" KeyColumn="' + key_column 
                                + '"></PSRecordset>';
        });

        xml_ds_columns += '</Root>';
        return xml_ds_columns;
    }
    
    //load relationship tab contents
    rm_dataset.fx_load_relationship_contents = function() {
        //attach layout to tab relationship
        layout_relationship = ds_tabbar.cells('tab_relationship').attachLayout({
            pattern: '3E',
            cells: [
                {id:'a', header: true, height: 190, text: 'Connected Sources', collapse: 0},
                {id:'b', header: true, text: 'Relation'},
                {id:'c',text: "Advanced Mode", collapse: true}
            ]
        });
        
        rm_dataset.fx_init_connected_source_content();  
        rm_dataset.fx_init_relation_joins_content();
        
    };
    //init connected source contents (menu,grid)
    rm_dataset.fx_init_connected_source_content = function() {
        var menu_json_cs = [
            {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled: 0},
            {id: "edit", text: "Edit", img:"edit.gif", items: [
                {id:"add", img:"add.gif", text:"Add", imgdis:"add_dis.gif", enabled: true },
                {id:"delete", text:"Delete", img:"remove.gif", imgdis:"remove_dis.gif", enabled: false},
                
            ]},
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", enabled: 1},
            {id: "action", text: "Action", img:"action.gif", items: [
                {id:"advance", img:"upload.gif", text:"Advanced Mode", imgdis:"upload_dis.gif", enabled: false },
            ]}
            
        ];
                                
        menu_obj_connected_source = layout_relationship.cells('a').attachMenu({
            icons_path : js_image_path + "dhxmenu_web/",
            json       : menu_json_cs
        });
        
        menu_obj_connected_source.attachEvent("onClick",rm_dataset.menu_connected_source_click);
        
        grid_obj_connected_source = layout_relationship.cells('a').attachGrid();
        grid_obj_connected_source.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxgrid_web/");
        grid_obj_connected_source.setHeader('Dataset ID, Data Source, Alias');
        grid_obj_connected_source.setColumnIds('report_dataset_id,datasource_name,alias');
        grid_obj_connected_source.setColTypes('ro,combo,ed');
        grid_obj_connected_source.setColumnsVisibility("true,false,false");
        grid_obj_connected_source.setColValidators(',NotEmpty');
        
        grid_obj_connected_source.setInitWidths('100,400,150');
        grid_obj_connected_source.init();
        grid_obj_connected_source.enableHeaderMenu();
        //grid_obj_connected_source.enableValidation(true);
        
        //populate view combo
        var combo_obj = grid_obj_connected_source.getColumnCombo(grid_obj_connected_source.getColIndexById('datasource_name'));
        combo_obj.clearAll();
        combo_obj.enableFilteringMode('between');
        //combo_obj.allowFreeText(false);
        
        var data = {
                "action": 'spa_rfx_data_source_dhx',
                "call_from": "form",
                "has_blank_option": "false",
                "flag": 'r',
                "report_id": ds_info_obj.report_id,
                "source_id": source_id_gbl
            };
        
        data = $.param(data);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj.load(url, function() {
            //combo_obj.sort('asc');
        });
               
           
        
        rm_dataset.fx_refresh_grid_cs();
        
        grid_obj_connected_source.attachEvent("onRowSelect", function(rid) {
            menu_obj_connected_source.setItemEnabled("delete");
        });
        
        grid_obj_connected_source.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            
            if(stage == 2 && grid_obj_connected_source.getColumnId(cInd) == 'datasource_name' && nValue != '' 
                && (rm_dataset.fx_get_source_id_by_name(nValue) != rm_dataset.fx_get_source_id_by_name(oValue))) {
                
                menu_obj_connected_source.setItemEnabled('save');
                
                var exclude_ds_ids = [];
                var exclude_alias = [];
                grid_obj_connected_source.forEachRow(function(rid1) {
                    if(rId != rid1) {
                        //grid_obj_connected_source.forEachCell(rid1, function(cell_obj, cid1) {
                            //if(grid_obj_connected_source.getColumnId(cid1) == 'datasource_name' || grid_obj_connected_source.getColumnId(cid1) == 'alias') {
                            //exclude_ds.push(['ds_id': cell_obj.getValue(), 'ds_alias': ]);
                            //}   
                        //});
                        
                        var ds_id = rm_dataset.fx_get_source_id_by_name(grid_obj_connected_source.cells(rid1, grid_obj_connected_source.getColIndexById('datasource_name')).getTitle()).toString();
                        
                        var ds_alias = grid_obj_connected_source.cells(rid1, grid_obj_connected_source.getColIndexById('alias')).getValue();
                        exclude_ds_ids.push(ds_id);
                        exclude_alias.push(ds_alias);
                    }
                });

                if(exclude_ds_ids.length > 0 ) {
                    if($.inArray(nValue, exclude_ds_ids) > -1) {
                        dhtmlx.message({
                            title: 'Alert',
                            type: 'alert',
                            text: 'Datasource already exists on grid.'
                        });
                        return false;
                    }
                    
                }
                
                rm_dataset.fx_populate_alias(rId,cInd,nValue,exclude_alias.join(','));
                
            }
            return true;
        });
    }
    
    //function to auto populate alias of added connected source
    rm_dataset.fx_populate_alias = function(rid, cid, ds_id, grid_alias) {
        var report_dataset_id = grid_obj_connected_source.cells(rid,grid_obj_connected_source.getColIndexById('report_dataset_id')).getValue();
        var sp_string = "EXEC spa_rfx_report_dataset_dhx @flag='z'"
            + ", @process_id='" + ds_info_obj.process_id + "'"
            + ", @report_dataset_id='" + report_dataset_id + "'"
            + ", @report_id='" + ds_info_obj.report_id + "'"
            + ", @source_id='" + ds_id + "'"
            + ", @grid_alias='" + grid_alias + "'"
            + ""; 
        post_data = { sp_string: sp_string };
        //console.log(sp_string);return;
        
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            
            var json_data = data['json'][0];
            grid_obj_connected_source.cells(rid, grid_obj_connected_source.getColIndexById('alias')).setValue(json_data.populated_alias);
            
        });   
    };
    
    //init relation joins contents (menu,grid)
    rm_dataset.fx_init_relation_joins_content = function() {
        var menu_json_rj = [
            {id: "edit", text: "Edit", img:"edit.gif", items: [
                {id:"add", img:"add.gif", text:"Add", imgdis:"add_dis.gif", enabled: true },
                {id:"delete", text:"Delete", img:"remove.gif", imgdis:"remove_dis.gif", enabled: false},
                
            ]},
            //{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", enabled: 1}
        ];
                                
        menu_obj_relation_joins = layout_relationship.cells('b').attachMenu({
            icons_path : js_image_path + "dhxmenu_web/",
            json       : menu_json_rj
        });
        
        menu_obj_relation_joins.attachEvent("onClick",rm_dataset.menu_relation_joins_click);
        
        grid_obj_relation_joins = layout_relationship.cells('b').attachGrid();
        grid_obj_relation_joins.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxgrid_web/");
        grid_obj_relation_joins.setHeader('Relationship ID,Connection Join, Connecting Dataset, Root Dataset, From Column, To Dataset, To Column');
        grid_obj_relation_joins.setColumnIds('relationship_id,connection_join,connecting_dataset,root_dataset,from_col,to_dataset,to_col');
        grid_obj_relation_joins.setColTypes('ro,combo,combo,ro,combo,combo,combo');
        grid_obj_relation_joins.setColumnsVisibility("true,false,false,true,false,false,false");
        grid_obj_relation_joins.setColValidators(',NotEmpty,NotEmpty,NotEmpty,NotEmpty,NotEmpty,NotEmpty');
        grid_obj_relation_joins.setInitWidths('*,*,*,*,*,*,*');
        grid_obj_relation_joins.init();
        grid_obj_relation_joins.enableHeaderMenu();
        grid_obj_relation_joins.enableMultiselect(true);
        
        //grid_obj_relation_joins.attachEvent('onCellChanged', rm_dataset.fx_connection_ds_onchange);
        grid_obj_relation_joins.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if(stage == 2 && (grid_obj_relation_joins.getColumnId(cInd) == 'connecting_dataset' || grid_obj_relation_joins.getColumnId(cInd) == 'to_dataset')) {
                //rm_dataset.fx_connection_ds_onchange(rId,cInd,nValue, 'combo_click');
                var param_obj = {
                    rid : rId,
                    cid : cInd,
                    report_dataset_id : nValue
                }; 
                var join_side = (grid_obj_relation_joins.getColumnId(cInd) == 'connecting_dataset' ? 'from' : 'to');
                rm_dataset.fx_populate_join_column_combo(param_obj, join_side, 'combo_click');
            }
            return true;
        });
        
        grid_obj_relation_joins.attachEvent("onRowSelect", function(id) {
            menu_obj_relation_joins.setItemEnabled("delete");
        });
        
        
        //rm_dataset.fx_refresh_grid_rj();
    }
    //fired when connection dataset is changed on join grid
    rm_dataset.fx_connection_ds_onchange = function(rid, cid, new_val, call_from) {
        
        if(grid_obj_relation_joins.getColIndexById('connecting_dataset') == cid) {
            //set from dataset same as connecting dataset
            //grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('from_dataset'))
            //.setValue(grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connecting_dataset')).getText());
            
            var dataset_id = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connecting_dataset')).getValue();
            //popupate from columns
            var param_obj = {
                rid : rid,
                cid : cid,
                report_dataset_id : dataset_id
            };
            
            rm_dataset.fx_populate_join_column_combo(param_obj, 'from', call_from);
        } else if(grid_obj_relation_joins.getColIndexById('to_dataset') == cid) {
            //popupate from columns
            var dataset_id = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_dataset')).getValue();
            var param_obj = {
                rid : rid,
                cid : cid,
                report_dataset_id : dataset_id
            };
            
            rm_dataset.fx_populate_join_column_combo(param_obj, 'to', call_from);
        }
        
    };
    //populate data source columns on join grid
    rm_dataset.fx_populate_join_column_combo = function(param_obj, join_side, call_from) {
        //alert(join_side);
        //populate to dataset combo (right datasets)
        var col_ind = 0;
        if(join_side == 'from') {
            col_ind = grid_obj_relation_joins.getColIndexById('from_col');
        } else {
            col_ind = grid_obj_relation_joins.getColIndexById('to_col');
        }
        var combo_obj_cols = grid_obj_relation_joins.cells(param_obj.rid, col_ind).getCellCombo();
        
        combo_obj_cols.clearAll();
        combo_obj_cols.enableFilteringMode('between');
        
        var data = {
            "action": 'spa_rfx_report_dataset_relationship',
            "call_from": "form",
            "has_blank_option": "true",
            "flag": 'k',
            "report_dataset_id": param_obj.report_dataset_id,
            "process_id": ds_info_obj.process_id
        };
    
        data = $.param(data);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj_cols.load(url, function() {
            
            grid_obj_relation_joins.refreshComboColumn(col_ind);
            var relationship_id = grid_obj_relation_joins.cells(param_obj.rid, grid_obj_relation_joins.getColIndexById('relationship_id')).getValue();
            var connecting_ds = grid_obj_relation_joins.cells(param_obj.rid, grid_obj_relation_joins.getColIndexById('connecting_dataset')).getValue();
            var from_col_id = grid_obj_relation_joins.cells(param_obj.rid, grid_obj_relation_joins.getColIndexById('from_col')).getValue();
            var to_ds = grid_obj_relation_joins.cells(param_obj.rid, grid_obj_relation_joins.getColIndexById('to_dataset')).getValue();
            var to_col_id = grid_obj_relation_joins.cells(param_obj.rid, grid_obj_relation_joins.getColIndexById('to_col')).getValue();

            //retain already saved relation population when datasets changed.
            var new_col_id = '';

            $.each(relationship_state_gbl, function(k, data) {
                
                if(data[0] == relationship_id && data[1] == connecting_ds && join_side == 'from') {
                    new_col_id = data[2];
                } else if(data[0] == relationship_id && data[3] == to_ds && join_side == 'to') {
                    new_col_id = data[4];
                }
            });
            

            if(call_from == 'combo_click') {
                grid_obj_relation_joins.cells(param_obj.rid, col_ind).setValue(new_col_id);
            }
            
            
        });
    };
    //refresh grid connected sources
    rm_dataset.fx_refresh_grid_cs = function() {

        var report_dataset_id = form_obj_general.getItemValue('dataset_id');
        var param = {
            "flag": "l",
            "action": "spa_rfx_report_dataset_relationship",
            "process_id": ds_info_obj.process_id,
            "report_dataset_id": report_dataset_id
        };
                
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        grid_obj_connected_source.clearAndLoad(param_url, function() {
            
            menu_obj_connected_source.setItemDisabled('delete');
            if(grid_obj_connected_source.getAllRowIds() == '') {
                menu_obj_relation_joins.setItemDisabled('add');
                menu_obj_connected_source.setItemDisabled('save');
            } else {
                menu_obj_relation_joins.setItemEnabled('add');
                menu_obj_connected_source.setItemEnabled('save');
            }
            rm_dataset.fx_refresh_grid_rj();
            
        });
    };
    //refresh grid relation joins
    var relationship_state_gbl = new Array();
    rm_dataset.fx_refresh_grid_rj = function() {
        var report_dataset_id = form_obj_general.getItemValue('dataset_id');
        var param = {
            "flag": "a",
            "action": "spa_rfx_report_dataset_relationship",
            "process_id": ds_info_obj.process_id,
            "report_dataset_id": report_dataset_id
        };
                
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        grid_obj_relation_joins.clearAndLoad(param_url, function() {
            //console.log(c);
            //menu_obj_connected_source.setItemDisabled('delete');
            //populate connection join combo
            var combo_obj_cj = grid_obj_relation_joins.getColumnCombo(grid_obj_relation_joins.getColIndexById('connection_join'));
            combo_obj_cj.clearAll();
            combo_obj_cj.readonly(true);
            combo_obj_cj.addOption([
                {value:"1",text:"INNER"},
                {value:"2",text:"LEFT"},
                {value:"3",text:"FULL"}
            ]);
            grid_obj_relation_joins.refreshComboColumn(grid_obj_relation_joins.getColIndexById('connection_join'));
                        
            //populate connecting dataset combo (left datasets)
            var combo_obj_cd = grid_obj_relation_joins.getColumnCombo(grid_obj_relation_joins.getColIndexById('connecting_dataset'));
            combo_obj_cd.clearAll();
            combo_obj_cd.enableFilteringMode('between');
            
            var data = {
                "action": 'spa_rfx_report_dataset_relationship',
                "call_from": "form",
                "has_blank_option": "false",
                "flag": 'c',
                "process_id": ds_info_obj.process_id,
                "report_id": ds_info_obj.report_id,
                "report_dataset_id": ds_info_obj.dataset_id
            };
        
            data = $.param(data);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj_cd.load(url, function() {
                grid_obj_relation_joins.refreshComboColumn(grid_obj_relation_joins.getColIndexById('connecting_dataset'));
                
            });
            
           
            
            //populate to dataset combo (right datasets)
            var combo_obj_td = grid_obj_relation_joins.getColumnCombo(grid_obj_relation_joins.getColIndexById('to_dataset'));
            combo_obj_td.clearAll();
            combo_obj_td.enableFilteringMode('between');
            
            var data = {
                "action": 'spa_rfx_report_dataset_relationship',
                "call_from": "form",
                "has_blank_option": "false",
                "flag": 'j',
                "process_id": ds_info_obj.process_id,
                "report_id": ds_info_obj.report_id,
                "report_dataset_id": ds_info_obj.dataset_id
            };
        
            data = $.param(data);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj_td.load(url, function() {
                grid_obj_relation_joins.refreshComboColumn(grid_obj_relation_joins.getColIndexById('to_dataset'));
            }); 
            
            grid_obj_relation_joins.forEachRow(function(rid) {
                if(grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('relationship_id')).getValue() == -1) {
                    grid_obj_relation_joins.setRowColor(rid, '#E2EEFE');
                }
                grid_obj_relation_joins.forEachCell(rid, function(cell_obj, cid) {
                    if(grid_obj_relation_joins.getColumnId(cid) == 'connecting_dataset' || grid_obj_relation_joins.getColumnId(cid) == 'to_dataset') {
                        rm_dataset.fx_connection_ds_onchange(rid,cid,cell_obj.getValue(), 'refresh');
                        
                    }
    
                });

                //capture grid state data
                relationship_state_gbl.push(
                    [
                    grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('relationship_id')).getValue()
                    ,grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connecting_dataset')).getValue()
                    ,grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('from_col')).getValue()
                    ,grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_dataset')).getValue()
                    ,grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_col')).getValue()
                    ]
                );

                
            });

            

        });
        
    };
    //menu click function for connected sources menu
    rm_dataset.menu_connected_source_click = function(id) {
        switch(id) {
            case "add":
                var new_id = (new Date()).valueOf();
                grid_obj_connected_source.addRow(new_id,'');
                /*myCombo = grid_obj_connected_source.cells(new_id, 7);
                myCombo.setValue('No');
                grid_obj_connected_source.forEachCell(new_id,function(cell_obj,ind){
                    grid_obj_connected_source.validateCell(new_id,ind);
                });
                */
                break;
            case "delete":
                confirm_messagebox('Are you sure you want to delete selected data?', function() {
                    var row_id = grid_obj_connected_source.getSelectedRowId();
                    var dataset_id = grid_obj_connected_source.cells(row_id, grid_obj_connected_source.getColIndexById('report_dataset_id')).getValue();
                    if(dataset_id == '') {
                        grid_obj_connected_source.deleteRow(row_id);
                    } else {
                        rm_dataset.fx_delete_connected_source(dataset_id);
                    }
                });
                break;
            case "save":
                rm_dataset.fx_save_connected_sources();
                break;
            case "refresh":
                rm_dataset.fx_refresh_grid_cs();
                break;    
                
        }
    };
    //menu click function for relation joins menu
    rm_dataset.menu_relation_joins_click = function(id) {
        switch(id) {
            case "refresh":
                //rm_dataset.refresh_grid_relationship_detail();
                rm_dataset.fx_refresh_grid_rj();
            case "add":
                var new_id = (new Date()).valueOf();
                var root_dataset_id = form_obj_general.getItemValue('dataset_id');
                grid_obj_relation_joins.addRow(new_id,',1,,' + root_dataset_id + '');
                break;   
            case "delete":
                confirm_messagebox('Are you sure you want to delete selected data?', function() {
                    var row_id = grid_obj_relation_joins.getSelectedRowId();
                    grid_obj_relation_joins.deleteSelectedRows();
                });
                break;             
        }
    };
    
    //function to save connected sources grid info
    rm_dataset.fx_save_connected_sources = function() {
        
        var root_dataset_id = form_obj_general.getItemValue('dataset_id');
        
        var prev_alias = '-1';
        var cs_info_xml = '<PSRecordSet>';
        var err_arr = [];
        
        grid_obj_connected_source.forEachRow(function(rid) {
            var report_dataset_id = grid_obj_connected_source.cells(rid, grid_obj_connected_source.getColIndexById('report_dataset_id')).getValue();
            var ds_name = grid_obj_connected_source.cells(rid, grid_obj_connected_source.getColIndexById('datasource_name')).getValue();
            var alias = grid_obj_connected_source.cells(rid, grid_obj_connected_source.getColIndexById('alias')).getValue();
            
            grid_obj_connected_source.validateCell(rid, grid_obj_connected_source.getColIndexById('datasource_name'));
            
            if(ds_name == '') {
                err_arr.push('Data Error in Connected Sources grid. Please check the data in column Datasource and resave.');
                return;
            } else if(prev_alias.toLowerCase() == alias.toLowerCase() && alias != '') {
                err_arr.push('Same alias "' + alias + '" used for multiple data. Please check the data in column Alias and resave.');
                return;
            } 
            
            var source_name = grid_obj_connected_source.cells(rid, grid_obj_connected_source.getColIndexById('datasource_name')).getText();
            var source_id = rm_dataset.fx_get_source_id_by_name(source_name);
            cs_info_xml += '<DataInfo report_dataset_id="' + report_dataset_id + '"'
                            + ' source_id="' + source_id + '"' 
                            + ' report_id="' + ds_info_obj.report_id + '"' 
                            + ' alias="' + alias + '"'
                            + ' root_dataset_id="' + root_dataset_id + '"'
                            + ' />';
            
            prev_alias = alias;
        });
        
        //check if any err logged on object
        if(err_arr.length > 0) {
            dhtmlx.message({
                title: 'Alert',
                type: 'alert',
                text: err_arr[0]
            });
            
            return;
        }
        
        cs_info_xml += '</PSRecordSet>';
        //console.log(cs_info_xml);return;
        var sp_string = "EXEC spa_rfx_report_dataset_dhx @flag='r'"
            + ", @process_id='" + ds_info_obj.process_id + "'"
            + ", @report_dataset_id='" + root_dataset_id + "'"
            + ", @tsql='" + cs_info_xml + "'"
            + ", @report_id='" + ds_info_obj.report_id + "'"
            + ""; 
        post_data = { sp_string: sp_string };
        //console.log(sp_string);return;
        
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                success_call('Changes have been saved successfully');
                rm_dataset.fx_refresh_grid_cs();
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_data.message
                });
            }
            
        });   
    };
    //delete selected connected source
    rm_dataset.fx_delete_connected_source = function(dataset_id) {
        var sp_string = "EXEC spa_rfx_report_dataset_relationship @flag='d'"
            + ", @process_id='" + ds_info_obj.process_id + "'"
            + ", @report_dataset_id='" + dataset_id + "'"
            + ""; 
        post_data = { sp_string: sp_string };
        //console.log(sp_string);return;
        
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                success_call('Data deleted successfully.');
                rm_dataset.fx_refresh_grid_cs();
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_data.message
                });
            }
            
        });        
    };
    
    //filter source list array using name an return source_id
    rm_dataset.fx_get_source_id_by_name = function(source_name){
        var filtered_arr = source_list_arr.filter(function(obj) {
            return (obj['name'] == source_name);
        });

        if(filtered_arr.length > 0) {
            return (filtered_arr[0]['data_source_id']);
        } else {
            return source_name;
        }
        
    };
    
    //save relationship tab info
    rm_dataset.fx_save_relation_joins = function() {
        var join_row_ids = grid_obj_relation_joins.getAllRowIds();
        var relation_joins_xml = '<Root>';
        
        if(join_row_ids == '') {
            relation_joins_xml += '<PSRecordset Dataset="' + ds_info_obj.dataset_id + '"'
                + ' DatasetFrom="-1"'
                + ' ColumnFrom=""'
                + ' DatasetTo=""'
                + ' ColumnTo=""'
                + ' JoinType=""'
                + ' ></PSRecordset>'
        } else {
            grid_obj_relation_joins.forEachRow(function(rid) {
                var from_dataset = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connecting_dataset')).getValue()
                var from_col = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('from_col')).getValue()
                var to_dataset = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_dataset')).getValue()
                var to_col = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_col')).getValue()
                var join_type = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connection_join')).getValue()
                               
                relation_joins_xml += '<PSRecordset Dataset="' + ds_info_obj.dataset_id
                    + '" DatasetFrom="' + grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connecting_dataset')).getValue()
                    + '" ColumnFrom="' + grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('from_col')).getValue()
                    + '" DatasetTo="' + grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_dataset')).getValue()
                    + '" ColumnTo="' + grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_col')).getValue()
                    + '" JoinType="' + grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connection_join')).getValue()
                    + '" ></PSRecordset>'
            });
        }
        
        
        relation_joins_xml += '</Root>';
        var is_adv_mode = false;
        var flag = (is_adv_mode ? 'x' : 'i');
        var sp_string = "EXEC spa_rfx_report_dataset_relationship @flag='" + flag + "'"
            + ", @process_id='" + ds_info_obj.process_id + "'"
            + ", @report_dataset_id='" + ds_info_obj.dataset_id + "'"
            + ", @xml='" + relation_joins_xml + "'"
            + ""; 
        post_data = { sp_string: sp_string };
        //console.log(sp_string);return;
        
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                success_call('Changes have been saved successfully.');
                rm_dataset.fx_refresh_grid_rj();
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_data.message
                });
            }
            
        });
    };
    
    //function to validate relation grid, check if invalid record exists on grid        
    rm_dataset.fx_validate_relation_joins = function() {
        var err_arr = [];
                                
        grid_obj_relation_joins.forEachRow(function(rid) {  
            grid_obj_relation_joins.validateCell(rid, grid_obj_relation_joins.getColIndexById('connecting_dataset'));
            grid_obj_relation_joins.validateCell(rid, grid_obj_relation_joins.getColIndexById('from_col'));
            grid_obj_relation_joins.validateCell(rid, grid_obj_relation_joins.getColIndexById('to_dataset'));
            grid_obj_relation_joins.validateCell(rid, grid_obj_relation_joins.getColIndexById('to_col'));
            
            var from_dataset = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connecting_dataset')).getValue()
            var from_col = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('from_col')).getValue()
            var to_dataset = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_dataset')).getValue()
            var to_col = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('to_col')).getValue()
            var join_type = grid_obj_relation_joins.cells(rid, grid_obj_relation_joins.getColIndexById('connection_join')).getValue()
            
            if(from_dataset == '' || from_col == '' || to_dataset == '' || to_col == '' || join_type == '') {
                err_arr.push('Data Error in Relation grid. Please check the data and resave.');
                return;
            }
        });
        //check if any err logged on object
        if(err_arr.length > 0) {
            dhtmlx.message({
                title: 'Alert',
                type: 'alert',
                text: err_arr[0]
            });
            
            return false;
        } else {
            return true;
        }           
    }
    
    //alert messages
    function get_message(arg) {
        switch (arg) {
            case 'DELETE_CONFIRM':
                return 'Are you sure you want to delete the selected data?';
            case 'DELETE_SUCCESS':
                return 'Data deleted successfully.';
            case 'DELETE_FAILED':
                return 'Connected source used in report.';
            case 'INSERT_SUCCESS':
                return 'Data inserted successfully.';
            case 'INSERT_FAILED':
                return 'Error while inserting data.';
            case 'UPDATE_SUCCESS':
                return 'Data updated successfully.';
            case 'ALIAS_WITH_SPACE':
                return 'Alias field cannot contain whitespace.';
            case 'VALIDATE_VIEW':
                return 'Please select any View.';
            case 'VALIDATE_DATASET':
                return 'Please select dataset to connect';
            case 'VALIDATE_NAME':
                return 'Please enter Name to connect.';
            case 'VALIDATE_CAONNECTING_DATASOURCE':
                return 'Please select a connecting data source.';
            case 'VALIDATE_ALIAS':
                return 'Alias field cannot contain space.';
            case 'VALIDATE_TABLE':
                return 'Please select a Table.';
            case 'VALIDATE_NAME_TYPE':
                return 'Please enter Name.';
            case 'VALIDATE_SQL':
                return 'Please enter SQL.';
            case 'VALIDATE_AJAX':
                return 'Details saved.';
            case 'VALIDATE_AJAX_ERROR':
                return 'Error while saving details.';
            case 'VALIDATE_PRIVILEGE':
                return 'Privilege Issue! Contact your System Administrator for the required privilege.';                
            case 'VALIDATE_GRID':
                return 'Please select an item from the grid.';
            case 'VALIDATE_SQL_QUERY':
                return "Please correct the SQL query.";
            case 'VALIDATE_SQL_QUERY_PARAMETERS':
                return "The following requierd fields are missing in the select query: ";
            case 'VALIDATE_SQL_CUSTOM_QUERY_PARAMETERS':
                return "The requierd fields are missing in the select query."
        }      
    }
    
    
    
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
    
</script>
<style>
.txtarea_sql {
    height: 100%;
    width: 100%;
}

div#div_ds_cols {
    position: relative;
    width: 100%;
    height: 100%;
    overflow: auto;
}
.ds_cols_th {
    font-size: 13px;
    font-weight: 100;
    height:25px!important;
}
.ds_cols_th th { 
    font-weight: normal!important; 
    padding:5px;    
}
.data-table td { border-bottom:1px solid #ccc; padding-top:11px; 
}

input[type="text"]:disabled {
   padding: 1px 0px 1px 3px!important;
}

</style>
</html>