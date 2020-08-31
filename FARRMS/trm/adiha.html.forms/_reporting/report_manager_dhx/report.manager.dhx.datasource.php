<?php
/**
* Report manager datasource screen
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
    // print '<pre>';print_r($_POST);print '</pre>';die();
    $ds_info_obj = isset($_POST['ds_info_obj']) ? json_decode($_POST['ds_info_obj']) : '';
    $ui_call_from = get_sanitized_value($_POST['call_from'] ?? '');
    $is_validated = get_sanitized_value($_POST['is_validated'] ?? '');
    $report_datasource_id = '';
    $source_id = '';
    $ds_category = '';
    $cmb_wf_workflow_module = '';
    $type_id = '';
    $tsql = '';
    $ds_name = '';
    $ds_alias = '';
    $ds_description = '';
    $wf_primary_table = '';
    $wf_primary_column = '';
    $ds_system_defined = '';

    if($ds_info_obj->{'ds_flag'} == 'u') { // Update for view.
        $report_datasource_id = $ds_info_obj->{'data_source_id'};
        $sp_url = "EXEC spa_rfx_data_source_dhx @flag= 'a', @source_id=" . $report_datasource_id;
        $read_xml = readXMLURL2($sp_url);
        $ds_name = $read_xml[0]['name'];
        $ds_alias = $read_xml[0]['alias'];
        $ds_description = $read_xml[0]['description'];
        $ds_category = $read_xml[0]['category'];
        $ds_system_defined = $read_xml[0]['system_defined'];
        $wf_primary_table = $read_xml[0]['physical_table_name'];
        $wf_primary_column = $read_xml[0]['primary_column'];
        $is_action_view = $read_xml[0]['is_action_view'];
        $cmb_wf_workflow_module = $read_xml[0]['module_id'];

        $tsql = $read_xml[0]['tsql'];
        $tsql = html_entity_decode($read_xml[0]['tsql'], ENT_QUOTES | ENT_XML1 , 'UTF-8');

        $type_id = $read_xml[0]['type_id'];
        $source_id = $read_xml[0]['data_source_id'];
		$enable_relations = true;
    }
    // print '<pre>';print_r($read_xml);print '</pre>';die();
    if ($ui_call_from == 'rfx_data_source')
        $ds_category = 106500;

  
    $form_namespace = 'rm_datasource';
    $layout_json = "[
                {id:'a', header: false, height: 100},
                {id:'b', header: false}
            ]";

    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);
                    
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

    $source_list_url = "EXEC spa_rfx_data_source_dhx @flag='p'";
    $source_list_arr = readXMLURL2($source_list_url);

    echo $layout_obj->close_layout();
    ?> 
    <div id="div_ds_cols" class="col-listings-from-tsql" ></div>
</body>
<!--<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui.min.js"></script>-->

<script type="text/javascript"> 
    var post_data = '';
    var ds_info_obj = $.parseJSON('<?php echo json_encode($ds_info_obj); ?>');
    var report_datasource_id_gbl = '<?php echo $report_datasource_id; ?>';
    var source_list_arr = $.parseJSON('<?php echo json_encode($source_list_arr);?>');
    var validated_tsql_gbl = '';
    var source_id_gbl = '<?php echo $source_id; ?>';
    var tsql_table = '';
    var ui_call_from = '<?php echo $ui_call_from; ?>';
    var is_validated = '<?php echo $is_validated; ?>';
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    
    var theme_selected = 'dhtmlx_' + default_theme;
    var ds_category_val = '<?php echo $ds_category ?>';
    var workflow_module_id = '<?php echo $cmb_wf_workflow_module?>';
    
    $(function() {
        grid_obj_connected_source = {};
        rm_datasource.fx_load_general_contents();
        //set confirm on closing dhtmlx window
        if (ui_call_from == 'rfx_data_source') {
            var this_window = parent.dhx_wins.window('window_data_source');
            this_window.attachEvent('onClose', function(win) {
                parent.rm.fx_refresh_tree('s');
                return true;
            });
        }
		// trigger extension
		
		//$("#editor").css("font-family","\'Consolas!importan\'");
		//$('#editor').attr('style','font-family:Consolas !important');
		
		/*$( '#editor' ).each(function () {
			this.style.setProperty( 'font-family', 'Consolas', 'important' );
        });
		*/                 
         
        // Added Help Popup
        help_popup = new dhtmlXPopup({ 
            toolbar: rm_datasource.toolbar_ds,
            id: "help",
            mode: "right"
        });
        help_content_report = '<ul>';
        help_content_report += '<li><a>' + get_locale_value('Use Multiline Script Identifier (available from context menu) for multi line data source scripts.') + '</a></li>';
        help_content_report += '<li><a>' + get_locale_value('Apply filters in data source instead of report whenever applicable for performance improvement.') + '</a></li>';
        help_content_report += '<li><a>' + get_locale_value('Handle data source filters for nullability unless it is marked as Required Filter.') + '</a></li>';
        help_content_report += '<li><a>' + get_locale_value('Avoid formatting data (e.g. date format, rounding) in data source. It is best done in reports.') + '</a></li>';
        help_content_report += '<li><a>' + get_locale_value('Give each column a meaningful alias name in proper case. For e.g. As of Date instead of as_of_date.') + '</a></li>';
        help_content_report += '<li><a>' + get_locale_value('Define key columns, that uniquely identifies a data row in data source whenever possible.') + '</a></li>';
        help_content_report += '<li><a>' + get_locale_value('Choose matching widget type (control) for data source columns. For e.g. calendar for date (As of Date), dropdown for list (Buy/Sell Flag), data browser for long list (Counterparty).') + '</a></li>';
        help_content_report += '</ul>';

        help_content_alert = '<ul>';
        help_content_alert += '<li><a>' + get_locale_value('Use Multiline Script Identifier (available from context menu) for multi line data source scripts.') + '</a></li>';
        help_content_alert += '<li><a>' + get_locale_value('Use Alert Process Table (available from context menu) to be passed as process table from other application logic to the workflow.') + '</a></li>';
        help_content_alert += '<li><a>' + get_locale_value('Use User Defined View for the calendar/time based.') + '</a></li>';
		help_content_alert += '<li><a>' + get_locale_value('Don’t use –[__alert_process_table__] ON a.xyz = b.xyz for the User Defined View.') + '</a></li>';
		help_content_alert += '<li><a>' + get_locale_value('Primary Column defined in view should match with the column in the workflow process table.') + '</a></li>';
        help_content_alert += '</ul>';
		
		help_content_std_alert = '<ul>';
        help_content_std_alert += '<li><a>' + get_locale_value('Use Standard View for standard workflows (Triggered from any menu).') + '</a></li>';
        help_content_std_alert += '<li><a>' + get_locale_value('Use Multiline Script Identifier (available from context menu) for multi line data source scripts.') + '</a></li>';
        help_content_std_alert += '<li><a>' + get_locale_value('Use Alert Process Table (available from context menu) to be passed as process table from other application logic to the workflow.') + '</a></li>';
		help_content_std_alert += '<li><a>' + get_locale_value('Use –[__alert_process_table__] ON a.xyz = b.xyz to improve the performance of the Standard View.') + '</a></li>';
		help_content_std_alert += '<li><a>' + get_locale_value('Primary Column defined in view should match with the column in the workflow process table.') + '</a></li>';
        help_content_std_alert += '</ul>';

        help_content_function = '<ul>';
		help_content_function += '<li><a>' + get_locale_value('Formula name cannot have spaces. e.g. FunctionName') + '</a></li>';
		help_content_function += '<li><a>' + get_locale_value('Use Multiline Script Identifier (available from context menu) for multi line data source scripts.') + '</a></li>';
        help_content_function += '<li><a>' + get_locale_value('Apply filters in data source instead of report whenever applicable for performance improvement.') + '</a></li>';
		help_content_function += '<li><a>' + get_locale_value('Handle data source filters for nullability unless it is marked as Required Filter.') + '</a></li>';
		help_content_function += '<li><a>' + get_locale_value('Avoid formatting data (e.g. date format, rounding) in data source.') + '</a></li>';
		help_content_function += '<li><a>' + get_locale_value('Give each column a meaningful alias name in proper case. For e.g. As of Date instead of as_of_date.') + '</a></li>';
        help_content_function += '<li><a>' + get_locale_value('The view query should have prod_date, hour, mins and value columns in its output.') + '</a></li>';
        help_content_function += '</ul>';

        help_content_import = '<ul>';
        help_content_import += '<li><a>' + get_locale_value('One import source type will only have one data source view. Currently Data Source Name = Import Type (static data type - 21400)') + '</a></li>';
        help_content_import += '<li><a>' + get_locale_value('Mostly these views don’t changes unless new filter static data is added. If any static data value is added in import filter (static data type - 112200) then logic should be added to respective import filter view') + '</a></li>';
        help_content_import += '<li><a>' + get_locale_value('For Import Filter view for Email, the view will return valid notes_id (from email_notes table)') + '</a></li>';
        help_content_import += '<li><a>' + get_locale_value('For Import Filter view for FTP/File Location, the view will return valid filenames.') + '</a></li>';
		help_content_import += '<li><a>' + get_locale_value('Use Multiline Script Identifier (available from context menu) for multi line data source scripts.') + '</a></li>';
        help_content_import += '<li><a>' + get_locale_value('Apply filters in data source instead of report whenever applicable for performance improvement.') + '</a></li>';
		help_content_import += '<li><a>' + get_locale_value('Handle data source filters for nullability unless it is marked as Required Filter.') + '</a></li>';
		help_content_import += '<li><a>' + get_locale_value('Avoid formatting data (e.g. date format, rounding) in data source.') + '</a></li>';
		help_content_import += '<li><a>' + get_locale_value('Give each column a meaningful alias name in proper case. For e.g. As of Date instead of as_of_date.') + '</a></li>';
        help_content_import += '</ul>';

        help_content_none = get_locale_value('Please select View Category.');

        help_content = help_content_none;
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
    
    //load general tab contents
    rm_datasource.fx_load_general_contents = function() {
        
        //attach form to layout general
        var form_json_general = rm_datasource.fx_get_form_json('form_general_tab');
        form_obj_general = rm_datasource.layout.cells('a').attachForm(get_form_json_locale(form_json_general));

        form_obj_general.hideItem('cmb_wf_workflow_module');
        form_obj_general.hideItem('wf_primary_column');
        form_obj_general.hideItem('wf_primary_table');

        rm_datasource.layout.cells('a').setHeight(180);

        form_obj_general.getCombo('ds_category').attachEvent('onChange', function(value, text) {
            
            if (value == 106502) {
                form_obj_general.showItem('cmb_wf_workflow_module');
                form_obj_general.showItem('wf_primary_column');
                form_obj_general.showItem('wf_primary_table');
                form_obj_general.setRequired('cmb_wf_workflow_module',true);
                form_obj_general.setRequired('wf_primary_column',true);
                form_obj_general.setRequired('wf_primary_table',true);
            } else if (value == 106503) {
                form_obj_general.showItem('cmb_wf_workflow_module');
                form_obj_general.setRequired('cmb_wf_workflow_module',true);
                form_obj_general.hideItem('wf_primary_column');
                form_obj_general.hideItem('wf_primary_table');
                form_obj_general.setRequired('wf_primary_column',false);
                form_obj_general.setRequired('wf_primary_table',false);
            } else {
                form_obj_general.hideItem('cmb_wf_workflow_module');
                form_obj_general.hideItem('wf_primary_column');
                form_obj_general.hideItem('wf_primary_table');
                form_obj_general.setRequired('cmb_wf_workflow_module',false);
                form_obj_general.setRequired('wf_primary_column',false);
                form_obj_general.setRequired('wf_primary_table',false);
            }
            
            // Attached Developer Notes to help popup
            if (value == 106503) {
                help_content = help_content_alert;
            } else if (value == 106502) {
				help_content = help_content_std_alert;
			} else if (value == 106501) {
                help_content = help_content_function;
            } else if (value == 106504) {
                help_content = help_content_import;
            } else if (value == 106500) {
                help_content = help_content_report;
            } else {
                help_content = help_content_none;
            }
            help_popup.attachHTML(help_content);

        });
       
        //populate table combo
        var cmb_table = form_obj_general.getCombo('cmb_table');
        cmb_table.clearAll();
        var cmb_table_param = {
            "action": 'spa_rfx_column_generate',
            "call_from": "form",
            "has_blank_option": "false",
            "flag": 't',
            "SELECTED_VALUE": ''
        };
        cmb_table_param = $.param(cmb_table_param);
        var cmb_table_url = js_dropdown_connector_url + '&' + cmb_table_param;
        cmb_table.load(cmb_table_url, function() {
            cmb_table.sort('asc');
        });

        //populate View Category combo
        var cmb_ds_category = form_obj_general.getCombo('ds_category');
        cmb_ds_category.clearAll();
        var cmb_ds_category_param = {
            "action": 'spa_StaticDataValues',
            "call_from": "form",
            "has_blank_option": "true",
            "flag": 'h',
            "type_id" : '106500'
        };

        cmb_ds_category_param = $.param(cmb_ds_category_param);
        var cmb_wf_workflow_module_url = js_dropdown_connector_url + '&' + cmb_ds_category_param;
        cmb_ds_category.load(cmb_wf_workflow_module_url, function() {
            if (ds_category_val!= '') {
                form_obj_general.setItemValue('ds_category', ds_category_val);
             } 
            cmb_ds_category.sort('asc');
        });

        //populate workflow module combo
        var cmb_wf_workflow_module = form_obj_general.getCombo('cmb_wf_workflow_module');
        cmb_wf_workflow_module.clearAll();
        var cmb_wf_workflow_module_param = {
            "action": 'spa_workflow_module_event_mapping',
            "call_from": "form",
            "has_blank_option": "false",
            "flag": 'g'
        };

        cmb_wf_workflow_module_param = $.param(cmb_wf_workflow_module_param);
        var cmb_wf_workflow_module_url = js_dropdown_connector_url + '&' + cmb_wf_workflow_module_param;
        cmb_wf_workflow_module.load(cmb_wf_workflow_module_url, function() {
            if (workflow_module_id!= '') {
                form_obj_general.setItemValue('cmb_wf_workflow_module', workflow_module_id);
             } 
            cmb_wf_workflow_module.sort('asc');
        });

        //onchange event on datset_type combo
        var cmb_ds_type = form_obj_general.getCombo('datasource_type');
        cmb_ds_type.attachEvent('onChange', rm_datasource.fx_ds_type_onchange);
        
        //onchange event on table combo
        var cmb_table = form_obj_general.getCombo('cmb_table');
        cmb_table.attachEvent('onChange', rm_datasource.fx_table_onchange);
        
        rm_datasource.fx_load_tabs_general_tab_layout();
    };
    
    //load tabs on general tab layout
    rm_datasource.fx_load_tabs_general_tab_layout = function() {
        var json_tabs = [
            {
            id:      "tab_sql",      // tab id
            text:    get_locale_value("SQL"),    // tab text
            width:   null,      // numeric for tab width or null for auto, optional
            index:   1,      // numeric for tab index or null for last position, optional
            active:  true,      // boolean, make tab active after adding, optional
            enabled: true,     // boolean, false to disable tab on init
            close:   false       // boolean, render close button on tab, optional
            },
            {
            id:      "tab_table_columns",
            text:    get_locale_value("Table Columns"),
            width:   null,
            index:   2,
            active:  false,
            enabled: true,
            close:   false
            },
            {
            id:      "tab_ds_columns",
            text:    get_locale_value("Columns"),
            width:   null,
            index:   3,
            active:  false,
            enabled: true,
            close:   false
            }
        ];
        ds_tabbar_general = rm_datasource.layout.cells('b').attachTabbar({
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

        //attach menu (validate) on sql tab
        menu_obj_table_columns_tab = ds_tabbar_general.cells('tab_table_columns').attachMenu({
            icons_path: js_image_path + 'dhxmenu_web/',
            items:[
                {id: 'validate_table', text: 'Validate', title: 'Validate', img: 'verify.gif', img_dis: 'verify_dis.gif'}
            ]
        });

        menu_obj_sql_tab.attachEvent('onClick', function(id) {
            if(id == 'validate') {
                rm_datasource.fx_validate_sql('validate');
            }
            
        });

        menu_obj_table_columns_tab.attachEvent('onClick', function(id) {
            if(id == 'validate_table') {
                rm_datasource.fx_validate_sql('validate_table');
            }
            
        });

        var form_json_sql_tab = rm_datasource.fx_get_form_json('form_sql_tab');
        //form_obj_sql_tab = ds_tabbar_general.cells('tab_sql').attachForm(form_json_sql_tab);
		form_obj_sql_tab = ds_tabbar_general.cells('tab_sql').attachHTMLString('<div id="editor" class="code-editor"></div>');

		ace.require("ace/ext/language_tools");
		var editor = ace.edit("editor");
		editor.session.setMode("ace/mode/sqlserver");
		editor.setTheme("ace/theme/sqlserver");
		
       
        editor.setValue("<?php echo str_replace('"','\\"',str_replace("\\n\\n\\n","\\n\\n" , str_replace("\r","\\n", str_replace("\n","\\n", $tsql)))); ?>", -1);
               
		// enable autocompletion and snippets
		editor.setOptions({
			enableBasicAutocompletion: true,
			enableSnippets: true,
			enableLiveAutocompletion: false
		});

        // keywords identifier
        tag_context_menu = new dhtmlXMenuObject();
        tag_context_menu.renderAsContextMenu();
        tag_obj = [{id:"add_batch_report", text:"Multiline Script Identifier"},{id:"add_alert_process_table", text:"Alert Process Table"}];
                
        tag_context_menu.loadStruct(tag_obj);
        tag_context_menu.addContextZone("editor");

        tag_context_menu.attachEvent("onClick", function(id, zoneId){
            // Retrieve cursor position
            var cursor_position = editor.getCursorPosition();
            // Insert text (second argument) with given position
            var keyword = '';
            if (id == 'add_batch_report')
                keyword = '--[__batch_report__]';
            else if (id == 'add_alert_process_table')
                keyword = '--[__alert_process_table__]';
            editor.session.insert(cursor_position,keyword);
        });

        // Handled to show menu based on View Category
        editor.container.addEventListener("contextmenu", function(e) {
            e.preventDefault();
            var ds_category = form_obj_general.getItemValue('ds_category');
            if (ds_category == 106502 || ds_category == 106503 || ds_category == '') {
                tag_context_menu.showItem('add_alert_process_table');
            } else {
                tag_context_menu.hideItem('add_alert_process_table');
            }
            return false;
        }, false);
		
        grid_obj_table_cols = ds_tabbar_general.tabs('tab_table_columns').attachGrid();
        grid_obj_table_cols.setImagePath(js_image_path + "dhxgrid_web/");
        grid_obj_table_cols.setHeader(',Columns');
        grid_obj_table_cols.setColumnIds('Status,Columns');
        grid_obj_table_cols.setColumnsVisibility('false,false');
        grid_obj_table_cols.setColTypes('ch,ro');
        grid_obj_table_cols.setInitWidths("30,250");
        grid_obj_table_cols.setColSorting('int,str');
        grid_obj_table_cols.init();
        grid_obj_table_cols.enableHeaderMenu();
        grid_obj_table_cols.enableMultiselect(true);
        
        //trigger acc to mode flag
        if(ds_info_obj.ds_flag == 'i') {
            rm_datasource.fx_ds_type_onchange(1);    
        } else if(ds_info_obj.ds_flag == 'u') {
            form_obj_general.disableItem('datasource_type');
            var type_id_update = '<?php echo $type_id; ?>';
            var source_id_update = '<?php echo $source_id; ?>';
            rm_datasource.fx_ds_type_onchange(type_id_update);
            if(type_id_update == 1) { //view
                rm_datasource.fx_validate_sql('validate');
                // rm_datasource.fx_view_onchange(source_id_update);
            } else if(type_id_update == 3) { //table
                rm_datasource.fx_table_onchange(source_id_update);
            }
        }
    };
    
    //validate click event
    rm_datasource.fx_validate_sql = function(call_from) {

        if(call_from != 'validate_table' && call_from != 'validate_table_1') { // For SQL validation [Get sql value from textbox]
            /*if(!validate_form(form_obj_sql_tab)) {
                form_obj_sql_tab.resetValidateCss('txt_sql');
                return false;
            }*/

            ds_tabbar_general.cells('tab_ds_columns').progressOn();
            //var tsql = form_obj_sql_tab.getItemValue('txt_sql');
			
			var editor = ace.edit("editor");
			var tsql = editor.getValue();
			
        } else { // For Tables column validation [Get sql value]
            if(call_from != 'validate_table_1') {
				
				if(tsql == '') {return;}
                generate_sql();
                var tsql = tsql_table; // tsql from table
            } else {
                var tsql = ""; // tsql empty.....
            }
        }

		if(tsql == '') {return;}

        var parameter_string = prepare_parameters(tsql);
        var sql = unescapeXML(tsql);  
        //console.log(sql);console.log(tsql);   

        var with_criteria = (sql.split('{').length > 1) ? 'n' : 'y';     

        var url = 'report.manager.dhx.dataset.column.ajax.php' 
                + '?process_id=NULL' 
                + '&source_id=' + source_id_gbl
                + '&mode=' + ds_info_obj.ds_flag
                + '&call_from=datasource'
                + '&criteria=' + parameter_string
                + '&with_criteria=' + with_criteria
                ; 
        
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
                
                if(call_from != 'sql_save') { // No extra validation popup.
                    if(call_from != 'sql_success') { // just need to refresh Column grid, No error checking.
                        if (return_response[0] == 'missing_parameters' && return_response[1] != null) {

                            var success_message = get_message('VALIDATE_SQL_QUERY_PARAMETERS') + return_response[1];
                            show_messagebox(success_message);
                            ds_tabbar_general.cells('tab_ds_columns').progressOff();
                            return false;
                        } else if (return_response[0] == 'check_query') {                        
                            var success_message = get_message('VALIDATE_SQL_QUERY');
                            show_messagebox(return_response[1] + ' Line Number: ' + return_response[2] + '.');
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
                        }
                    }

                    if(call_from != 'validate_table_1') {
                        ds_tabbar_general.cells('tab_ds_columns').setActive();
                    }
                }
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

    function generate_sql() {

        var table_from = form_obj_general.getItemValue('cmb_table');
        var columns_arr = [];

        if (table_from != '' && table_from != 'NULL') {

            grid_obj_table_cols.forEachRow(function(id) {
                var status_value = grid_obj_table_cols.cells(id,grid_obj_table_cols.getColIndexById('Status')).getValue();
                var columns_value = grid_obj_table_cols.cells(id,grid_obj_table_cols.getColIndexById('Columns')).getValue();

                if(status_value == '1') {
                    columns_arr.push(columns_value);
                }
            });

            if (columns_arr.length == 0) {
                columns = '*';
            } else {
                columns = columns_arr.join();
                columns = columns.split(',').reverse().join('], [');
                columns = '[' + columns + ']';
            }

            tsql_table = 'SELECT ' + columns + ' FROM ' + table_from;

        } else {
            tsql_table = '';
        }
    }

    //function to save sql dataset
    rm_datasource.fx_save_sql_ds = function(call_from) {
        
        if(typeof ds_info_obj.report_id == 'undefined') {
            var report_id = 'null';
        }

        var sql_cols = get_column_rows(); // Get column fields attribute.
        if(!sql_cols) {
            return
        }

        var datasource_type = form_obj_general.getItemValue('datasource_type');
        var source_id = form_obj_general.getItemValue('sql_source_id');
        var report_datasource_id = form_obj_general.getItemValue('datasource_id');
        var ds_name = unescape(form_obj_general.getItemValue('ds_name'));
        var ds_description = unescape(form_obj_general.getItemValue('ds_description'));
        var ds_system_defined = form_obj_general.getItemValue('ds_system_defined');
        var ds_category = form_obj_general.getItemValue('ds_category');
        var ds_alias = trim(form_obj_general.getItemValue('ds_alias'));
        
        var cmb_wf_workflow_module = form_obj_general.getItemValue('cmb_wf_workflow_module') ? form_obj_general.getItemValue('cmb_wf_workflow_module') : 'NULL';
        var wf_primary_table = unescape(form_obj_general.getItemValue('wf_primary_table')) ? unescape(form_obj_general.getItemValue('wf_primary_table')) : 'NULL';
        var wf_primary_column = unescape(form_obj_general.getItemValue('wf_primary_column')) ? unescape(form_obj_general.getItemValue('wf_primary_column')) : 'NULL';
        
        var is_action_view = 'NULL';

        if (ds_category == '106502'){
            is_action_view = 'y'
        } else if (ds_category == '106503') {
            is_action_view = 'n'
        } else {
            is_action_view = 'NULL'
        }
     
        ds_alias = unescape(ds_alias);
        if (is_validated == '0' && ds_system_defined == '1')
            is_validated = 1;

        if(call_from == 'sql') {
			var editor = ace.edit("editor");
            var raw_tsql = editor.getValue();
            var tsql = unescapeXML(raw_tsql);
            var find = "'";
            var re = new RegExp(find, 'g');
            tsql = tsql.replace(re, "''");
            var parameter_string = prepare_parameters(tsql);
        } else {
            tsql = tsql_table;
        }

        var mode_value = '';
        if (report_datasource_id == '') {
            report_datasource_id = null;
            mode_value = 'i';
        } else {
            mode_value = 'u';
        }

        var criteria = null;

        var sp_string = "EXEC spa_rfx_data_source_dhx '" + mode_value + "'"
            + ", " + report_id + ""
            + ", '" + ds_name + "'"
            + ", '" + tsql + "'"
            + ", " + datasource_type + ""
            + ", '" + ds_alias + "'"
            + ", "  + report_datasource_id + ""
            + ", '" + ds_description + "'"
            + ", " + criteria + ""
            + ", '" + sql_cols + "'"
            + ", '" + ds_category + "'"
            + ", '" + ds_system_defined + "'"
            + ", '" + wf_primary_table + "'"
            + ", '" + wf_primary_column + "'"
            + ", '"  + is_action_view + "'"
            + ", " + cmb_wf_workflow_module + "";
        post_data = { sp_string: sp_string };
        
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                if (mode_value == 'i') {
                    form_obj_general.setItemValue('datasource_id', json_data.recommendation);
                    form_obj_general.disableItem('datasource_type');
                }
                success_call('Changes saved successfully.');
                rm_datasource.fx_validate_sql('sql_success'); // Refresh Columns tab.
                if (call_from == '' && ui_call_from == 'rfx_data_source') {
                    parent.rm.fx_refresh_tree('s');
                } else if (ui_call_from == 'setup_user_defined_view') {
                    let report_id = (mode_value == 'i')?json_data.recommendation:report_datasource_id_gbl;
                    parent.setup_user_defined_view.save_call_back(report_id,mode_value);
                }

            } else {
                show_messagebox(json_data.message);
            }
            
        });
    }
    
    //hide show components on ds type basis
    rm_datasource.fx_ds_type_onchange = function(value, text) {
        if (value == 1) { // View
            
            ds_tabbar_general.cells('tab_table_columns').hide(false);
            form_obj_general.hideItem('cmb_table');
            form_obj_general.setRequired('cmb_table', false);
            form_obj_general.showItem('ds_name');
            form_obj_general.setRequired('ds_name', true);
            
            ds_tabbar_general.cells('tab_sql').show(true);
            $('#div_ds_cols').html('');
            rm_datasource.fx_validate_sql('on_type_change');
        } else { // Table
            
            form_obj_general.showItem('cmb_table');
            form_obj_general.setRequired('cmb_table', true);
            form_obj_general.showItem('ds_name');
            form_obj_general.setRequired('ds_name', true);
            
            ds_tabbar_general.cells('tab_sql').hide(false);
            ds_tabbar_general.cells('tab_table_columns').show(true);
            $('#div_ds_cols').html('');
            var table_id = form_obj_general.getItemValue('cmb_table');
            if(table_id != '') {
                rm_datasource.fx_table_onchange(table_id);
            }
        }
    };
    
    //event on view change
    rm_datasource.fx_view_onchange = function(value, text) {

        ds_tabbar_general.cells('tab_ds_columns').progressOn();
        var url = 'report.manager.dhx.dataset.column.ajax.php' 
                + '?process_id=NULL' +
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
                    var success_message = get_message('VALIDATE_SQL_QUERY_PARAMETERS') + return_response[1];
                    show_messagebox(success_message);
                    return;
                } else if (return_response[0] == 'check_query') {                        
                    var success_message = get_message('VALIDATE_SQL_QUERY');
                    show_messagebox(success_message);
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

    //event on table change #tablechange
    rm_datasource.fx_table_onchange = function(value, text) {

        ds_tabbar_general.cells('tab_ds_columns').progressOn();

        if(typeof ds_info_obj.report_id == 'undefined') {
            var report_id = '';
        }

        //*********************Load data in Columns grid****************
        var param = {
            "flag": "s",
            "action": "spa_rfx_column_generate",
            "table_name": value,
            "source_id": report_id
        };

        param  = $.param(param );
        // console.log(param);
        var sp_url  = js_data_collector_url + "&" + param ;
        grid_obj_table_cols.clearAndLoad(sp_url);

        rm_datasource.fx_validate_sql('validate_table_1');
        ds_tabbar_general.cells('tab_table_columns').setActive();

        ds_tabbar_general.cells('tab_ds_columns').progressOff();

        //****************************************************************
    };
    
    /**
     * toolbar save click
     * @param id 
     */
    rm_datasource.toolbar_click = function(id) {
        switch (id) {
            case 'save':
                rm_datasource.save_data_source();
                break;
            case 'help':               
                help_popup.show('help');
            break;            
        }
    };
    
    /**
     * Save Data Source
     */
    rm_datasource.save_data_source = function() {
        if(!validate_form(form_obj_general)) {
            return;
        }
        
        var datasource_type = form_obj_general.getItemValue('datasource_type');
        var ds_alias = trim(form_obj_general.getItemValue('ds_alias'));
        ds_alias = unescape(ds_alias);

        if (ds_alias.indexOf(' ')> -1) {
            var success_message = get_message('ALIAS_WITH_SPACE');
            show_messagebox(success_message);
            return;
        }

        if(datasource_type == 1) { // **************************************** sql save
            rm_datasource.fx_validate_sql('sql_save');
			var editor = ace.edit("editor");
            var raw_tsql = editor.getValue();

            if(validated_tsql_gbl != raw_tsql) {
                show_messagebox('Please validate the sql.');
                ds_tabbar_general.cells('tab_ds_columns').progressOff();
                return false;
            } else {
                if (form_obj_general.getItemValue('ds_system_defined') == 1 && is_validated != 1) {
                    var param_obj = {
                        "param1"  :  'sql'
                    };
                    is_user_authorized('rm_datasource.fx_save_sql_ds',param_obj);
                } else {
                    rm_datasource.fx_save_sql_ds('sql');
                }

            }
            
            
	    } else if(datasource_type == 3) { // ********************************** table save
            if (form_obj_general.getItemValue('ds_system_defined') == 1 && is_validated != 1) {
                var param_obj = {
                    "param1"  :  'tables'
                };
                is_user_authorized('rm_datasource.fx_save_sql_ds',param_obj);
            } else {
                rm_datasource.fx_save_sql_ds('tables');
            }
	    }
    };
    
    //returns form json for general tab layout
    rm_datasource.fx_get_form_json = function(type) {
        var form_json = [];
        if(type == 'form_general_tab') {
            form_json = [ 
                {"type": "settings", "position": "label-top", "offsetLeft": ui_settings.offset_left, "offsetTop": 5, "inputWidth":ui_settings.field_size},
                {type:"combo", name: "datasource_type", label:"Datasource Type", required:true, filtering:true
                , options: [
                    {value: "1", label: "View", selected: <?php echo ($type_id == 1) ? 1 : 0 ?>},
                    {value: "3", label: "Table", selected: <?php echo ($type_id == 3) ? 1 : 0 ?>},
                ]}, 
                {type:"newcolumn"},
                {type:"combo", name: "cmb_table", label:"Tables", required:true, filtering:true, options: []}, 
                {type:"newcolumn"},
                {type:"input", name: "ds_name", value: "<?php echo $ds_name; ?>", label:"Name", required:true, userdata:{validation_message:"Required Field"}}, 
                {type:"newcolumn"},
                {type:"input", name: "ds_alias", value: "<?php echo $ds_alias; ?>", label:"Alias", required:true,userdata:{validation_message:"Required Field"}},
                {type:"newcolumn"},
                {type:"input", name: "ds_description", value: "<?php echo $ds_description; ?>", label:"Description"},
                {type:"newcolumn"},
                {type:"combo", name:"ds_category", label:"View Category",required:true,disabled:<?php echo ($ui_call_from == 'rfx_data_source') ? 'true' : 'false'; ?>, filtering: true, width: ui_settings['field_size'],offsetLeft : ui_settings['offset_left'], filtering_mode: 'between', options: []
                },
                {type:"newcolumn"},

                {type:"combo", name: "cmb_wf_workflow_module", label:"Workflow Module", required:false,disabled:<?php echo ($ui_call_from == 'rfx_data_source') ? 'true' : 'false'; ?>,  filtering:true,  options: []}, 
                {type:"newcolumn"},
                {type: "input",name:'wf_primary_table', label:"Primary Table", value: "<?php echo $wf_primary_table; ?>", disabled:<?php echo ($ui_call_from == 'rfx_data_source') ? 'true' : 'false'; ?>,},
                {type:'newcolumn'},

                {type:"input", name: "wf_primary_column", label:"Primary Column", value: "<?php echo $wf_primary_column; ?>", disabled:<?php echo ($ui_call_from == 'rfx_data_source') ? 'true' : 'false'; ?>,},
                {type:"newcolumn"},

                {type: "checkbox",name:'ds_system_defined', label:"System", checked:"<?php echo ($ds_system_defined == 1)?true:false; ?>", position: 'label-right', offsetLeft : ui_settings['offset_left'], labelWidth: ui_settings['field_size'],offsetTop: 20},
                {type:'newcolumn'},
                {type:"input", name: "datasource_id", value: "<?php echo $source_id; ?>", hidden:true}

            ];
        } else if(type == 'form_sql_tab') {
            form_json = [ 
                {"type": "settings", "position": "label-top", "offsetLeft": 3, "offsetTop": 3},
				{"type": "div", name:"txt_sql", id: "editor", labelWidth: 1150, labelHeight: 5 }
            
            
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
        var err_check;
        var datasource = $('#datasource-region tr.clone');
        var xml_ds_columns = '<Root>';
        var context, column_id, column_name, column_alias, column_tooltip, param_optional, filter, key_column, data_type, widget_type, default_value, renderas, source_value;

        var row_count = 0;
        datasource.each(function () {
            row_count ++;
            var e_id = row_count + 'error_mssg';
            $("#" + e_id).text("");
            $("#" + e_id).css({"color":"white"});
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
	   
            // Validating default value.
            if(data_type == '2') { //Date
                var date_val = default_value;

                var dmy_format = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/; //dd/mm/yyyy or dd-mm-yyyy format
                var dmy_result = date_val.match(dmy_format);

                var mdy_format = /^(0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])[\/\-]\d{4}$/; //mm/dd/yyyy or mm-dd-yyyy format
                var mdy_result = date_val.match(mdy_format);

                var ymd_format = /^\d{4}[\/\-](0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])$/; //yyyy/mm/dd or yyyy-mm-dd format
                var ymd_result = date_val.match(ymd_format);

                var ydm_format = /^\d{4}[\/\-](0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])$/; //yyyy/dd/mm or yyyy-dd-mm format
                var ydm_result = date_val.match(ydm_format);

                // date_val = date_val.replace(/-/g, '/');
                if((!dmy_result && !mdy_result && !ymd_result && !ydm_result) &&(date_val != '')) {
                    $("#" + e_id).text("Invalid Date");
                    $("#" + e_id).css({"color":"red"});

                    err_check = true;
                }
            } else if (data_type == '4') { //Int
                var int_val = default_value;
                var patt = /\d{1,10}/
                var result = int_val.match(patt);
                var check = parseInt(int_val, 10);

                if((!result && int_val != '')||(check != int_val && int_val != '')) {
                    $("#" + e_id).text("Invalid Number");
                    $("#" + e_id).css({"color":"red"});

                    err_check = true;
                }

            } else if (data_type == '3') { //Float
                var int_val = default_value;
                var patt = /\d{1,10}/
                var result = int_val.match(patt);

                if(!result && int_val != '') {
                    $("#" + e_id).text("Invalid Number");
                    $("#" + e_id).css({"color":"red"});

                    err_check = true;
                }

            }

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
        if(err_check) {
            return false;
        } else {
            return xml_ds_columns;
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
    background-color: #5DD7C6;
    font-size: 13px; 
}
.data-table th { 
    font-weight: normal!important; 
    padding: 5px 2px; 
    
}
.data-table td { 
    border-bottom: 1px solid #ccc; 
    padding: 8px 0px 5px!important; 
}
</style>

</html>

