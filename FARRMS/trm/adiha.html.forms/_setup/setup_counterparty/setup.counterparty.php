<?php
/**
* Setup counterparty screen
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
        <?php require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
    </head>
    <body>
        <?php
        $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
        $incident_id = get_sanitized_value($_GET['incident_id'] ?? '');
        $call_from_combo = get_sanitized_value($_GET['call_from_combo'] ?? '');
        $form_namespace = 'setup_counterparty';
        $function_id = 10105800;
        $rights_counterparty_delete = 10105811;
        $rights_counterparty_add_save = 10105810;
        $rights_conterparty_contact_iu = 10105816;
        $rights_conterparty_contact_delete = 10105817;
        $rights_conterparty_bank_iu = 10105846;
        $rights_conterparty_bank_delete = 10105847;
        $rights_conterparty_contract_iu = 10105831;
        $rights_conterparty_contract_delete = 10105832;
        $rights_conterparty_external_iu = 10105861;
        $rights_conterparty_external_delete = 10105862;
        $rights_conterparty_broker_iu = 10105820;
        $rights_conterparty_broker_delete = 10105821;
        $rights_counterparty_document = 10102900;
        $rights_conterparty_certificate_iu = 10105876;
        $rights_conterparty_certificate_delete = 10105877;
        $rights_conterparty_product_iu = 10105891;
        $rights_conterparty_product_delete = 10105892;
        $rights_counterparty_meter_iu = 10105896;
        $rights_counterparty_meter_delete = 10105897;
        $rights_counterparty_manage_privilege = 10105812;
        $rights_counterparty_fees = 10105803;
        $rights_counterparty_fees_iu = 10105804;
        $rights_counterparty_fees_delete = 10105805;
        $rights_counterparty_meter_mapping = 10105894;
        $rights_approve_counterparty = 10105901;
        $rights_approve_counterparty_delete = 10105902;
        $rights_approve_product = 10105903;
        $rights_conterparty_history_iu = 10105851;
        $rights_conterparty_history_delete = 10105852;
        $rights_conterparty_netting = 10105907;


        list (
                $has_rights_counterparty_delete,
                $has_rights_counterparty_add_save,
                $has_rights_conterparty_contact_iu,
                $has_rights_conterparty_contact_delete,
                $has_rights_conterparty_bank_iu,
                $has_rights_conterparty_bank_delete,
                $has_rights_conterparty_contract_iu,
                $has_rights_conterparty_contract_delete,
                $has_rights_conterparty_external_iu,
                $has_rights_conterparty_external_delete,
                $has_rights_conterparty_broker_iu,
                $has_rights_conterparty_broker_delete,
                $has_rights_counterparty_document,
                $has_rights_conterparty_certificate_iu,
                $has_rights_conterparty_certificate_delete,
                $has_rights_conterparty_product_iu,
                $has_rights_conterparty_product_delete,
                $has_rights_counterparty_meter_iu,
                $has_rights_counterparty_meter_delete,
                $has_rights_counterparty_manage_privilege,
                $has_rights_counterparty_fees,
                $has_rights_counterparty_fees_iu,
                $has_rights_counterparty_fees_delete,
                $has_rights_counterparty_meter_mapping,
                $has_rights_approve_counterparty,
                $has_rights_approve_product,
                $has_rights_approve_counterparty_delete,
                $has_rights_conterparty_history_iu,
                $has_rights_conterparty_history_delete,
                $has_rights_conterparty_netting                            
            ) = build_security_rights(
                $rights_counterparty_delete,
                $rights_counterparty_add_save,
                $rights_conterparty_contact_iu, 
                $rights_conterparty_contact_delete, 
                $rights_conterparty_bank_iu, 
                $rights_conterparty_bank_delete, 
                $rights_conterparty_contract_iu, 
                $rights_conterparty_contract_delete, 
                $rights_conterparty_external_iu, 
                $rights_conterparty_external_delete, 
                $rights_conterparty_broker_iu, 
                $rights_conterparty_broker_delete, 
                $rights_counterparty_document,
                $rights_conterparty_certificate_iu,
                $rights_conterparty_certificate_delete,
                $rights_conterparty_product_iu,
                $rights_conterparty_product_delete,
                $rights_counterparty_meter_iu,
                $rights_counterparty_meter_delete,
                $rights_counterparty_manage_privilege,
                $rights_counterparty_fees,
                $rights_counterparty_fees_iu,
                $rights_counterparty_fees_delete,
                $rights_counterparty_meter_mapping,
                $rights_approve_counterparty,
                $rights_approve_product,
                $rights_approve_counterparty_delete,
                $rights_conterparty_history_iu, 
                $rights_conterparty_history_delete,
                $rights_conterparty_netting 
        );
        
        $form_obj = new AdihaStandardForm($form_namespace, $function_id);
        $form_obj->define_grid('grid_setup_counterparty', '', 'g', false, '', false);
        $form_obj->define_layout_width(520);
        $form_obj->enable_multiple_select();
        $form_obj->add_privilege_menu($has_rights_counterparty_manage_privilege);
        $form_obj->define_custom_functions('save_data', 'load_form', 'delete_tree');
        $form_obj->define_apply_filters(true, '10105900', 'CounterpartyFilters', 'General');
        //$form_obj->enable_grid_pivot();
        echo $form_obj->init_form('Counterparties', 'Counterparty Details', $counterparty_id);
        echo $form_obj->close_form();

        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='SetupCounterparty',@parse_xml='<Root><PSRecordset source_counterparty_id=\"NULL\"></PSRecordset></Root>', @group_name='External ID,Bank Information,Contracts,Contacts,Fees,History,Shipper Info'";
        $form_data = readXMLURL2($form_sql);

        $tab_data = array();
        $grid_definition = array();

        if (is_array($form_data) && sizeof($form_data) > 0) {
            foreach ($form_data as $data) {
                array_push($tab_data, $data['tab_json']);

                // Grid data collection
                $grid_json = array();
                $pre = strpos($data['grid_json'], '[');
                if ($pre === false) {
                    $data['grid_json'] = '[' . $data['grid_json'] . ']';
                }

                $grid_json = json_decode($data['grid_json'], true);
                foreach ($grid_json as $grid) {
                    $grid_def = "EXEC spa_adiha_grid 's', '" . $grid['grid_id'] . "'";
                    $def = readXMLURL2($grid_def);

                    $it = new RecursiveIteratorIterator(new RecursiveArrayIterator($def));
                    $l = iterator_to_array($it, true);

                    array_push($grid_definition, $l);
                }
            }
        }
        //added for fees tab
        //$add_fee_tab = 'tabs: [' . implode(",", $tab_data).',{"id":"detail_tab_Fees","text":"Fees","active":"true"}]';
        
        /*if ('broker selected') {
            //add fee tab in last of tab group
            $grid_tab_data = 'tabs: [' . implode(",", $tab_data) . ',{}]';
        } else {
            $grid_tab_data = 'tabs: [' . implode(",", $tab_data) . ']';
        }*/
        $grid_tab_data = 'tabs: [' . implode(",", $tab_data) . ']';
        $grid_definition_json = json_encode($grid_definition);

        $category_name = 'Counterparty';
        $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
        $category_data = readXMLURL2($category_sql);
        ?>
    </body>

    <style type="text/css">
        /*CSS for IE 11 issue*/
        @media screen and (-ms-high-contrast: active), (-ms-high-contrast: none) {
            .dhxform_obj_dhx_web div.dhxform_base {
                min-height: 0px;
            }
            .dhxtabbar_base_dhx_web div.dhxtabbar_tabs div.dhxtabbar_tabs_cont_left div.dhxtabbar_tab {
                margin-left: 2px;
            }
        }
    </style>
    <script type="text/javascript">
        var call_from_combo = '<?php echo $call_from_combo; ?>';
    
        var category_id = '<?php echo $category_data[0]['value_id'];?>';
        var function_id = '<?php echo $function_id; ?>';
        var counterparty_id = '<?php echo $counterparty_id; ?>';
        var incident_id = '<?php echo $incident_id; ?>';
        var new_tab_id = '';
        var new_win;
		
        setup_counterparty.details_layout = {};
        setup_counterparty.details_tabs = {};
        setup_counterparty.details_form = {};
        setup_counterparty.grid_menu = {};
        setup_counterparty.grids = {};
        setup_counterparty.grid_dropdowns = {};
        setup_counterparty.tab_details_layout = {};
        dhxWins = new dhtmlXWindows();
        sql_stmt = {};
        grid_type = {};
        var popup_window;
        var grid_definition_json = <?php echo $grid_definition_json; ?>;
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        var has_rights_counterparty_delete = Boolean(<?php echo $has_rights_counterparty_delete; ?>);
        var has_rights_counterparty_add_save = Boolean(<?php echo $has_rights_counterparty_add_save; ?>);
        var has_rights_conterparty_contact_iu =<?php echo (($has_rights_conterparty_contact_iu) ? $has_rights_conterparty_contact_iu : '0'); ?>;
        var has_rights_conterparty_contact_delete =<?php echo (($has_rights_conterparty_contact_delete) ? $has_rights_conterparty_contact_delete : '0'); ?>;
        var has_rights_conterparty_bank_iu =<?php echo (($has_rights_conterparty_bank_iu) ? $has_rights_conterparty_bank_iu : '0'); ?>;
        var has_rights_conterparty_bank_delete =<?php echo (($has_rights_conterparty_bank_delete) ? $has_rights_conterparty_bank_delete : '0'); ?>;
        var has_rights_conterparty_contract_iu =<?php echo (($has_rights_conterparty_contract_iu) ? $has_rights_conterparty_contract_iu : '0'); ?>;
        var has_rights_conterparty_contract_delete =<?php echo (($has_rights_conterparty_contract_delete) ? $has_rights_conterparty_contract_delete : '0'); ?>;
        var has_rights_conterparty_external_iu =<?php echo (($has_rights_conterparty_external_iu) ? $has_rights_conterparty_external_iu : '0'); ?>;
        var has_rights_conterparty_external_delete =<?php echo (($has_rights_conterparty_external_delete) ? $has_rights_conterparty_external_delete : '0'); ?>;
        var has_rights_conterparty_broker_iu =<?php echo (($has_rights_conterparty_broker_iu) ? $has_rights_conterparty_broker_iu : '0'); ?>;
        var has_rights_conterparty_broker_delete =<?php echo (($has_rights_conterparty_broker_delete) ? $has_rights_conterparty_broker_delete : '0'); ?>;
        var has_rights_counterparty_document =<?php echo (($has_rights_counterparty_document) ? $has_rights_counterparty_document : '0'); ?>;
        var has_rights_conterparty_certificate_iu =<?php echo (($has_rights_conterparty_certificate_iu) ? $has_rights_conterparty_certificate_iu : '0'); ?>;
        var has_rights_conterparty_certificate_delete =<?php echo (($has_rights_conterparty_certificate_delete) ? $has_rights_conterparty_certificate_delete : '0'); ?>;
        var has_rights_conterparty_product_iu =<?php echo (($has_rights_conterparty_product_iu) ? $has_rights_conterparty_product_iu : '0'); ?>;
        var has_rights_conterparty_product_delete =<?php echo (($has_rights_conterparty_product_delete) ? $has_rights_conterparty_product_delete : '0'); ?>;
        var has_rights_counterparty_meter_iu = <?php echo (($has_rights_counterparty_meter_iu) ? $has_rights_counterparty_meter_iu : '0'); ?>;
        var has_rights_counterparty_meter_delete = <?php echo (($has_rights_counterparty_meter_delete) ? $has_rights_counterparty_meter_delete : '0'); ?>;
        var has_rights_counterparty_manage_privilege = <?php echo (($has_rights_counterparty_manage_privilege) ? $has_rights_counterparty_manage_privilege : '0'); ?>;
        var has_rights_counterparty_fees =  <?php echo (($has_rights_counterparty_fees) ? $has_rights_counterparty_fees : '0'); ?>;
        var has_rights_counterparty_fees_iu =  <?php echo (($has_rights_counterparty_fees_iu) ? $has_rights_counterparty_fees_iu : '0'); ?>;
        var has_rights_counterparty_fees_delete =    <?php echo (($has_rights_counterparty_fees_delete) ? $has_rights_counterparty_fees_delete : '0'); ?>;
        var has_rights_counterparty_meter_mapping =  <?php echo (($has_rights_counterparty_meter_mapping) ? $has_rights_counterparty_meter_mapping : '0'); ?>;
        var has_rights_approve_counterparty =    <?php echo (($has_rights_approve_counterparty) ? $has_rights_approve_counterparty : '0'); ?>;
        var has_rights_approve_product =     <?php echo (($has_rights_approve_product) ? $has_rights_approve_product : '0'); ?>;
        var has_rights_approve_counterparty_delete =     <?php echo (($has_rights_approve_counterparty_delete) ? $has_rights_approve_counterparty_delete : '0'); ?>;
        var has_rights_conterparty_history_iu =<?php echo (($has_rights_conterparty_history_iu) ? $has_rights_conterparty_history_iu : '0'); ?>;
        var has_rights_conterparty_history_delete =<?php echo (($has_rights_conterparty_history_delete) ? $has_rights_conterparty_history_delete : '0'); ?>;
        var has_rights_conterparty_netting =<?php echo (($has_rights_conterparty_netting) ? $has_rights_conterparty_netting : '0'); ?>;

        // locale values of all tab texts
        var external_id = get_locale_value('External ID');
        var broker_fees = get_locale_value('Broker Fees');
        var fees = get_locale_value('Fees');
        var certificate = get_locale_value('Certificate');
        var history_val = get_locale_value('History');
        var shipper_info = get_locale_value('Shipper Info');
        var bank_information = get_locale_value('Bank Information')
        var approved_counterparty = get_locale_value('Approved Counterparty')
        var contracts_val = get_locale_value('Contracts');
        var contacts_val = get_locale_value('Contacts');
        var meter_val = get_locale_value('Meter');
        var product_val =  get_locale_value('Product');
        var new_label = get_locale_value('New');
          
        $(function() {
            var filter_param = setup_counterparty.get_filter_parameters();
            setup_counterparty.refresh_grid("", setup_counterparty.enable_menu_item, filter_param,counterparty_id);            

            
            setup_counterparty.tab_toolbar_click = function(id) {
                switch (id) {
                    case "close":
                        var tab_id = setup_counterparty.tabbar.getActiveTab();
                        delete setup_counterparty.pages[tab_id];
                        setup_counterparty.tabbar.tabs(tab_id).close(true);
                        break;
                    case "save":
                        var tab_id = setup_counterparty.tabbar.getActiveTab();
                        setup_counterparty.save_data(tab_id);
                        break;

                    case "documents":
                        var tab_id = setup_counterparty.tabbar.getActiveTab();
                        setup_counterparty.open_document(tab_id);
                        break;
                    case "credit_file":
                        open_credit_file_win('credit_file_open');
                        break;  
					case "cpty_reminder_alert":
						var tab_id = setup_counterparty.tabbar.getActiveTab();
                        setup_counterparty.alert_reminders(tab_id);
                        break;  
                    default:
                        break;
                }
            };
            
            fx_attach_left_grid_events();
            
          
            load_workflow_status();
            
        });
        fx_attach_left_grid_events = function() {
            setup_counterparty.grid.attachEvent("onXLE", function(grid_obj,count){
                if(counterparty_id != '') {
                    fx_update_cpty(counterparty_id);
                }
                setup_counterparty.menu.setItemDisabled('workflow_status');
            });
        }
        fx_update_cpty = function(cpty_id) {
            var rid_arr = [];
            
            _.each(setup_counterparty.grid.getAllSubItems().split(','), function(data) {
                if(data != '') {
                    if(setup_counterparty.grid.hasChildren(data) == 0) {
                        rid_arr.push(data);
                    }
                }
            });
            if(rid_arr.length > 0) {
                _.each(rid_arr, function(rid) { 
                    setup_counterparty.grid.selectRowById(rid);
                    setup_counterparty.grid.forEachCell(rid, function(cell_obj, cid) {
                        if(cid == 1) {
                            if(cell_obj.getValue() == cpty_id) { 
                                setup_counterparty.create_tab(rid,0,0,0,null);
                            }
                        }
                    });
                });
            }
            
            if (incident_id && incident_id != '' && incident_id != 'undefined' && incident_id != undefined && incident_id != 'NULL') {
                var tab_id = setup_counterparty.tabbar.getActiveTab();
                setup_counterparty.open_document(tab_id,'',counterparty_id,incident_id);
            }
            
            
        }
        setup_counterparty.undock_mappings = function(counterparty_id) {
            var layout_obj = setup_counterparty.details_layout["details_layout_" + counterparty_id];
            layout_obj.cells("b").undock(300, 300, 900, 700);
            layout_obj.dhxWins.window("b").button("park").hide();
            layout_obj.dhxWins.window("b").maximize();
            layout_obj.dhxWins.window("b").centerOnScreen();
        }

        setup_counterparty.on_dock_mappings_event = function(name) {
            $('.on_dock_mappings_event').show();
        }
        setup_counterparty.on_undock_mappings_event = function(name) {
            $('.on_dock_mappings_event').hide();
        }

        // Function to disable save button if privilege is disabled
        setup_counterparty.check_privilege_callback = function(result) {
            // Disable Save button if disabled privilege
            privilege_status = result[0]['privilege_status'];
            
            if (privilege_status == 'false') {
                setup_counterparty.tabbar
                    .cells(setup_counterparty.tabbar.getActiveTab())
                    .getAttachedToolbar()
                    .disableItem('save'); 
            }
        }

        /**
         * [load_form description] - Load Form Data
         * @param  {[type]} win      [Active Tab]
         * @param  {[type]} tab_id   [Tab ID]
         * @param  {[type]} grid_obj [Grid Object - for accordion ]
         */

        var name_change = 'false'; //This is a global variable to check if name is changed or not
        setup_counterparty.load_form = function(win, tab_id, grid_obj) {
            win.progressOff();
           
            var expand_state = 0;
            var is_new = win.getText();

            // get counterparty id from the tab object
            var counterparty_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;

            //setTimeout(function() {
                if (is_new != new_label) {
                    var selected_row = setup_counterparty.grid.getSelectedRowId();
                    selected_row = (selected_row == null) ? setup_counterparty.grid.getRowId(1) : selected_row;
                    
                    var col_index = setup_counterparty.grid.getColIndexById("is_privilege_active");
                    var privilege_active = setup_counterparty.grid.cells(selected_row, col_index).getValue();

                    // Privilege Check to disable/enable save button
                    if (privilege_active == 1) {
                        data = {
                                    "action": "spa_static_data_privilege",
                                    "flag": 'c',
                                    "type_id": 4002,
                                    "value_id": counterparty_id
                               };
                        adiha_post_data("", data, "", "", "setup_counterparty.check_privilege_callback");
                    }
                }
            //}, 1000);
            // Attach layout - 2 cells upper - 'a', lower - 'b'
            setup_counterparty.details_layout["details_layout_" + counterparty_id] = win.attachLayout({
                pattern: "2E",
                cells: [
                    {id: "a", text: "Counterparty Details"},
                    {
                        id: "b",
                        text: "<div><a class=\"undock-btn-a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" setup_counterparty.undock_mappings(" + counterparty_id + ");\"></a>" + get_locale_value('Additional Details') + "</div>",
                        height: 400,
                        header: true,
                        collapse: false,
                        fix_size: [true, null]
                    }
                ]
            });
            setup_counterparty.details_layout["details_layout_" + counterparty_id].attachEvent("onDock", function(name) {
                $('.undock-btn-a').show();
            });
            setup_counterparty.details_layout["details_layout_" + counterparty_id].attachEvent("onUnDock", function(name) {
                $('.undock-btn-a').hide();

            });
            // collect data for upper tabs, and print forms
            var xml_value = '<Root><PSRecordset source_counterparty_id="' + counterparty_id + '"></PSRecordset></Root>';
            data = {"action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": function_id,
                "template_name": 'SetupCounterparty',
                "parse_xml": xml_value,
                "group_name": "General,Contact Info,Address,Submission,Additional"
            };
            result = adiha_post_data('return_array', data, '', '', 'setup_counterparty.load_form_data', false);

            // create lower tabs
            setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id] = setup_counterparty.details_layout["details_layout_" + counterparty_id].cells("b").attachTabbar({
                mode: "bottom",
                arrows_mode: "auto",
                <?php echo $grid_tab_data; ?>
            });

            // add grids to each tab on lower tabs
            var i = 0;
            var ids = setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].getAllTabs();

            setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].forEachTab(function(tab) {
                var tab_id = tab.getId();
                var tab_text = tab.getText();
                var win_type = (tab_text == bank_information) ? 'b' : (tab_text == contracts_val) ? 'c' : (tab_text == meter_val) ? 'm' : (tab_text == contacts_val) ? 'ct' : (tab_text == product_val) ? 'p' : (tab_text == approved_counterparty) ? 'a' : (tab_text == approved_counterparty) ? 'h' : 'e';
                var menu_index = "grid_menu_" + counterparty_id + "_" + tab_id;

                // attach menubar for each tab/grid
                setup_counterparty.grid_menu[menu_index] = tab.attachMenu({
                    icons_path: js_image_path + "dhxmenu_web/",
                    items: [
                        {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif"},
                        {id: "edit", text: "Edit", img: "edit.gif", img_disabled: "edit_dis.gif", items: [
                                {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif"},
                                {id: "add_product", text: "Add Product", disabled: true, img: "add.gif", img_disabled: "add_dis.gif"},
                                {id: "delete", text: "Delete", disabled: true, img: "delete.gif", img_disabled: "delete_dis.gif"},
                                {id: "copy", text: "Copy", img: "copy.gif", img_disabled: "copy_dis.gif", disabled: true},
                            ]},
                        {id: "t2", text: "Export", img: "export.gif", items: [
                                {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                                {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                            ]},
                        {id: "expand_collapse", text: "Expand/Collapse All", img: "exp_col.gif", img_disabled: "exp_col_dis.gif"}
                    ]
                });
                if (is_new == new_label) {
                    setup_counterparty.grid_menu[menu_index].setItemDisabled("edit");
                    setup_counterparty.grid_menu[menu_index].setItemDisabled("refresh");
                    setup_counterparty.grid_menu[menu_index].setItemDisabled("expand_collapse");

                }

                /*Attaching status bar for grid pagination*/
                if (tab_text == contacts_val || tab_text == certificate || tab_text == product_val) {
                    tab.attachStatusBar({
                        height: 30,
                        text: '<div id="pagingAreaGrid_' + grid_definition_json[i]["grid_name"] + '_' + counterparty_id + '"></div>'
                    });
                }
                var grid_name = grid_definition_json[i]["grid_name"];
                if ((tab_text == contacts_val) || (tab_text == bank_information) || (tab_text == contracts_val) || (tab_text == external_id) || (tab_text == broker_fees) || (tab_text == fees)|| (tab_text == certificate)) {
                    setup_counterparty.grid_menu[menu_index].showItem("refresh");
                } else {
                    setup_counterparty.grid_menu[menu_index].hideItem("refresh");
                }
                if (tab_text != product_val) {
                    setup_counterparty.grid_menu[menu_index].hideItem("copy");
                }
                
                if (tab_text != approved_counterparty) {
                    setup_counterparty.grid_menu[menu_index].hideItem("add_product");
                    setup_counterparty.grid_menu[menu_index].hideItem("expand_collapse");
                } else {
                    setup_counterparty.grid_menu[menu_index].setItemText('add', "Add Counterparty");
                    if (has_rights_approve_counterparty == 0){
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                }
                if (tab_text == meter_val) {
                    setup_counterparty.grid_menu[menu_index].hideItem('delete');
                }
                if (tab_text == history_val) {
                    setup_counterparty.grid_menu[menu_index].showItem("refresh");
                    setup_counterparty.grid_menu[menu_index].showItem('add');
                    setup_counterparty.grid_menu[menu_index].showItem("delete");                    
                }
                if (tab_text == shipper_info) {
                    setup_counterparty.grid_menu[menu_index].showItem("refresh");
                    setup_counterparty.grid_menu[menu_index].showItem('add');
                    setup_counterparty.grid_menu[menu_index].showItem("delete");                    
                }

                var grid_index = "grid_" + counterparty_id + "_" + grid_name;
                var grid_cookies = "grid_" + grid_name;
                var pagination_div_name = 'pagingAreaGrid_' + grid_definition_json[i]["grid_name"] + '_' + counterparty_id;
                var header_allignment;
                var counter = 0;
                $.each(grid_definition_json[i]["column_alignment"].split(','), function(index, value) {
                    
                    if (counter == 0)
                        header_allignment = 'text-align:' + value ;
                    else
                        header_allignment += ',text-align:' + value ;
                    counter ++
                    

                })             
              
                // attach grid to the tab, grid definition that is collected above is used to construct grid
                setup_counterparty.grids[grid_index] = tab.attachGrid();
                setup_counterparty.grids[grid_index].setImagePath(js_image_path + "dhxgrid_web/");                
                setup_counterparty.grids[grid_index].setHeader(grid_definition_json[i]["column_label_list"],null,header_allignment.split(","));                
                setup_counterparty.grids[grid_index].setColumnIds(grid_definition_json[i]["column_name_list"]);
                setup_counterparty.grids[grid_index].setInitWidths(grid_definition_json[i]["column_width"]);
                setup_counterparty.grids[grid_index].setColTypes(grid_definition_json[i]["column_type_list"]);
                setup_counterparty.grids[grid_index].setColAlign(grid_definition_json[i]["column_alignment"]);
                setup_counterparty.grids[grid_index].setColumnsVisibility(grid_definition_json[i]["set_visibility"]);
                setup_counterparty.grids[grid_index].setColSorting(grid_definition_json[i]["sorting_preference"]);
                setup_counterparty.grids[grid_index].setDateFormat(user_date_format,'%Y-%m-%d');
                if (tab_text == contacts_val || tab_text == certificate || tab_text == product_val) {
                    setup_counterparty.grids[grid_index].setPagingWTMode(true, true, true, true);
                    setup_counterparty.grids[grid_index].enablePaging(true, 25, 0, pagination_div_name);
                    setup_counterparty.grids[grid_index].setPagingSkin('toolbar');
                }

                var filter = '';
                counter = 0;
                $.each(grid_definition_json[i]["column_name_list"].split(','), function(index, value) {
                    filter += (counter == 0) ? '' : ',';
                    if (grid_definition_json[i]["numeric_fields"] != null) {
                        if (grid_definition_json[i]["numeric_fields"].indexOf(value) != -1)
                            filter += '#numeric_filter';
                        else
                            filter += '#text_filter';
                    } else
                        filter += '#text_filter';
                    counter++;
                });

                setup_counterparty.grids[grid_index].attachHeader(filter);
                
                if (tab_text == certificate || tab_text == history_val || tab_text == shipper_info) {
                    setup_counterparty.grids[grid_index].setColValidators(grid_definition_json[i]["validation_rule"]); 
                    setup_counterparty.grids[grid_index].attachEvent("onValidationError",function(id,ind,value){
                        var message = "Invalid Data";
                        setup_counterparty.grids[grid_index].cells(id,ind).setAttribute("validation", message);
                          return true;
                    });
                    setup_counterparty.grids[grid_index].attachEvent("onValidationCorrect",function(id,ind,value){
                        setup_counterparty.grids[grid_index].cells(id,ind).setAttribute("validation", "");
                        return true;
                    });
                }             

                setup_counterparty.grids[grid_index].enableMultiselect(true);
                setup_counterparty.grids[grid_index].enableColumnMove(true);
                setup_counterparty.grids[grid_index].setUserData("", "grid_id", grid_name);
                setup_counterparty.grids[grid_index].init();
                setup_counterparty.grids[grid_index].loadOrderFromCookie(grid_cookies);
                setup_counterparty.grids[grid_index].loadHiddenColumnsFromCookie(grid_cookies);
                setup_counterparty.grids[grid_index].enableOrderSaving(grid_cookies, cookie_expire_date);
                setup_counterparty.grids[grid_index].enableAutoHiddenColumnsSaving(grid_cookies, cookie_expire_date);

                setup_counterparty.grids[grid_index].attachEvent("onRowSelect", function(row_id, col_id) {
                    console.log(row_id, col_id);
                    /*privilege checking*/
                    if (tab_text == contacts_val) {
                        if (has_rights_conterparty_contact_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                    }
                    else if (tab_text == bank_information) {
                        if (has_rights_conterparty_bank_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                    }
                    else if (tab_text == contracts_val) {
                        if (has_rights_conterparty_contract_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');

                        if(has_rights_conterparty_netting)
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('netting');
                        }
                        
                        if(has_rights_conterparty_netting)
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('netting');
                        
                        setup_counterparty.grid_menu[menu_index].setItemEnabled('workflow_status');
                    }
                    else if (tab_text == external_id) {
                        if (has_rights_conterparty_external_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                    }
                    else if (tab_text == broker_fees) {
                        if (has_rights_conterparty_broker_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                    }

                    //delete button enabled for fees tab
                    else if (tab_text == fees) {
                        if (has_rights_counterparty_fees_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                    } else if (tab_text == certificate) {
                        if (has_rights_conterparty_certificate_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                    } else if (tab_text == product_val) {
                        if (has_rights_conterparty_product_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                        
                        if (has_rights_conterparty_product_iu) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('copy');
                        }
                    }
                    /*
                    else if (tab_text == 'Meter') {
                        if (has_rights_counterparty_meter_mapping) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                    }
                    */
                    else if (tab_text == approved_counterparty) {
                        if (has_rights_approve_counterparty_delete) {
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                        }
                        
                        var selected_id = setup_counterparty.grids[grid_index].getSelectedRowId();
                        if (selected_id != null) {
                            if (has_rights_approve_product) {
                                setup_counterparty.grid_menu[menu_index].setItemEnabled('add_product');
                            }
                        }
                    }
                    //end of delete button fees tab
                    
                    /*end of privilege checking*/

                    if ((tab_text == external_id)) {
                        if (has_rights_conterparty_external_iu)
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('save_changes');
                    }
                    if ((tab_text == broker_fees)) {
                        if (has_rights_conterparty_broker_iu)
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('save_changes');
                    }
                    /*privilege checking for fees tab*/
                    if ((tab_text == fees)) {
                        if (has_rights_counterparty_fees_iu)
                        setup_counterparty.grid_menu[menu_index].setItemEnabled('save_changes');
                    }
                    if ((tab_text == certificate)) {
                        if (has_rights_conterparty_certificate_iu)
                        setup_counterparty.grid_menu[menu_index].setItemEnabled('save_changes');
                    }
                     if ((tab_text == history_val)) {
                        //if (has_rights_conterparty_certificate_iu)
                        if (has_rights_conterparty_history_iu)
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('save_changes');
                        
                        if (has_rights_conterparty_history_delete)
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                    }
                    if ((tab_text == shipper_info)) {
                        //if (has_rights_conterparty_certificate_iu)
                        if (has_rights_conterparty_history_iu)
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('save_changes');
                        
                        if (has_rights_conterparty_history_delete)
                            setup_counterparty.grid_menu[menu_index].setItemEnabled('delete');
                    }
                    /*end*/
                });
                
                setup_counterparty.grids[grid_index].attachEvent("onSelectStateChanged", function(row_id) {
                    if (row_id == null) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled('delete');
                        setup_counterparty.grid_menu[menu_index].setItemDisabled('add_product');
                    }
                });
                
                setup_counterparty.grids[grid_index].attachEvent("onClearAll", function() {
                    setup_counterparty.grid_menu[menu_index].setItemDisabled('delete');
                    setup_counterparty.grid_menu[menu_index].setItemDisabled('add_product');

                    if ((tab_text == external_id) || (tab_text == broker_fees)) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled('save_changes');
                    }
                    
                    if (tab_text == product_val) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled('copy');
                    }
                });

                if ((tab_text == external_id) || (tab_text == broker_fees) || (tab_text == fees) || (tab_text == certificate) || (tab_text == history_val) || (tab_text == shipper_info)) {
                    var item_text = "Save";
                    var parent = "edit";
                    setup_counterparty.grid_menu[menu_index].addNewSibling(parent, "save_changes", item_text, true, "save.gif", "save_dis.gif");
                } else if (tab_text == approved_counterparty) {
                    setup_counterparty.grids[grid_index].attachEvent("onRowDblClicked", function(row_id, col_id) {
                        var level = setup_counterparty.grids[grid_index].getLevel(row_id);
                        if (level == 0) {
                            var state = setup_counterparty.grids[grid_index].getOpenState(row_id);
                            
                            if (state)
                                setup_counterparty.grids[grid_index].closeItem(row_id);
                            else
                                setup_counterparty.grids[grid_index].openItem(row_id);
                        }
                    });
                } else {
                    if (tab_text == contracts_val) {
                        var item_text = "Workflow Status";
                        var parent = "edit";
                        setup_counterparty.grid_menu[menu_index].addNewSibling(parent, "workflow_status", item_text, true, "report.gif", "report_dis.gif"); 

                        item_text = "Netting";
                        parent = "workflow_status";

                        setup_counterparty.grid_menu[menu_index].addNewSibling(parent, "netting", item_text, true, "audit.gif", "audit_dis.gif");    
                    }
                    
                    setup_counterparty.grids[grid_index].attachEvent("onRowDblClicked", function(row_id, col_id) {
                        if (tab_text == shipper_info) return true;
                        if (tab_text == contracts_val) {                            
                            var id = setup_counterparty.grids[grid_index].cells(row_id, 1).getValue(); 
                        } else {
                            var id = setup_counterparty.grids[grid_index].cells(row_id, 0).getValue(); 
                        }

                        if(win_type == 'c') {
                            var selected_level = setup_counterparty.grids[grid_index].getLevel(row_id);
                            if(selected_level == 0) {
                                var has_child = setup_counterparty.grids[grid_index].hasChildren(row_id);
                                if(has_child > 0) { //making internal counterparty of hierarchy unclickable
                                    return
                                }                                 
                            } 
                        }  
                        
                        setup_counterparty.open_popup_window(counterparty_id, id, win_type, sql_stmt[tab_text], setup_counterparty.grids[grid_index], grid_type[tab_text]);
                    });
                }
                /*privilege checking*/
                if (tab_text == contacts_val) {
                    if (!has_rights_conterparty_contact_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_contact_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                }
                else if (tab_text == bank_information) {
                    if (!has_rights_conterparty_bank_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_bank_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                }
                else if (tab_text == contracts_val) {
                    if (!has_rights_conterparty_contract_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_contract_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                }
                else if (tab_text == external_id) {
                    if (!has_rights_conterparty_external_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_external_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                }
                else if (tab_text == broker_fees) {
                    if (!has_rights_conterparty_broker_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_broker_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                }
                else if (tab_text == fees) {
                    if (!has_rights_counterparty_fees_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_broker_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                } else if (tab_text == certificate) {
                    if (!has_rights_conterparty_certificate_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_certificate_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                } else if (tab_text == product_val) {
                    if (!has_rights_conterparty_product_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_product_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                } else if (tab_text == meter_val) {                     
                    if (!has_rights_counterparty_meter_mapping) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    /*if (!has_rights_counterparty_meter_mapping) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }*/                
                } else if (tab_text == history_val) { //#history tab event
                    var combo_obj = setup_counterparty.grids[grid_index].getColumnCombo(setup_counterparty.grids[grid_index].getColIndexById('type')); 
                    combo_obj.attachEvent("onChange", function(value, text) {
                        var row_id = setup_counterparty.grids[grid_index].getSelectedRowId(); 
                        if(value == '105900') {
                            setup_counterparty.grids[grid_index].cells(row_id,4).setDisabled(false); 
                            setup_counterparty.grids[grid_index].cells(row_id,5).setDisabled(false); 
                            setup_counterparty.grids[grid_index].cells(row_id,6).setDisabled(false); 
                            setup_counterparty.grids[grid_index].cells(row_id,7).setDisabled(false); 

                            setup_counterparty.grids[grid_index].cells(row_id,8).setValue('');
                            setup_counterparty.grids[grid_index].cells(row_id,8).setDisabled(true); 
                        } else {
                            setup_counterparty.grids[grid_index].cells(row_id,4).setValue('');
                            setup_counterparty.grids[grid_index].cells(row_id,5).setValue('');
                            setup_counterparty.grids[grid_index].cells(row_id,6).setValue('');
                            setup_counterparty.grids[grid_index].cells(row_id,7).setValue('');

                            setup_counterparty.grids[grid_index].cells(row_id,4).setDisabled(true); 
                            setup_counterparty.grids[grid_index].cells(row_id,5).setDisabled(true); 
                            setup_counterparty.grids[grid_index].cells(row_id,6).setDisabled(true); 
                            setup_counterparty.grids[grid_index].cells(row_id,7).setDisabled(true); 

                            setup_counterparty.grids[grid_index].cells(row_id,8).setDisabled(false); 
                        }
                    });

                    if (!has_rights_conterparty_history_iu) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("add");
                    }
                    if (!has_rights_conterparty_history_delete) {
                        setup_counterparty.grid_menu[menu_index].setItemDisabled("delete");
                    }
                }
                /*end of privilege checking*/
                // populate the dropdowns fields in grids.
                if (grid_definition_json[i]["dropdown_columns"] != null && grid_definition_json[i]["dropdown_columns"] != '') {
                    var dropdown_columns = grid_definition_json[i]["dropdown_columns"].split(',');
                    _.each(dropdown_columns, function(item) {
                        var col_index = setup_counterparty.grids[grid_index].getColIndexById(item);
                        setup_counterparty.grid_dropdowns[item + '_' + counterparty_id] = setup_counterparty.grids[grid_index].getColumnCombo(col_index);
                        setup_counterparty.grid_dropdowns[item + '_' + counterparty_id].enableFilteringMode(true);

                        var cm_param = {"action": "spa_adiha_grid", "flag": "t", "grid_name": grid_definition_json[i]["grid_name"], "column_name": item, "call_from": "grid"};
                        cm_param = $.param(cm_param);
                        var url = js_dropdown_connector_url + '&' + cm_param;
                        setup_counterparty.grid_dropdowns[item + '_' + counterparty_id].load(url);
                    });
                }
                setup_counterparty.grids[grid_index].enableHeaderMenu();

                // save sql_stmt and grid type for each tab for other use.
                sql_stmt[tab_text] = grid_definition_json[i]["sql_stmt"];
                grid_type[tab_text] = grid_definition_json[i]["grid_type"];

                if (sql_stmt[tab_text] != '' && sql_stmt[tab_text] != null && grid_type[tab_text] == 'g') {
                    setup_counterparty.refresh_grids(sql_stmt[tab_text], setup_counterparty.grids[grid_index], grid_type[tab_text], counterparty_id);
                } else {  
                    if (win_type == 'c') {
                        setup_counterparty.refresh_contracts(setup_counterparty.grids[grid_index], counterparty_id);
                    } else {
                        setup_counterparty.refresh_approved_counterparty(setup_counterparty.grids[grid_index], counterparty_id);
                    }                    
                }

                // onclick events for menu items
                setup_counterparty.grid_menu[menu_index].attachEvent("onClick", function(id) {
                    switch (id) {
                        case "add":
                            if ((tab_text == external_id) || (tab_text == broker_fees) || (tab_text == fees) || (tab_text == certificate) || (tab_text == history_val) || (tab_text == shipper_info)) {
                                var newId = (new Date()).valueOf();
                                setup_counterparty.grids[grid_index].addRow(newId, "");
                                setup_counterparty.grids[grid_index].selectRowById(newId);
                                if (tab_text == certificate || tab_text == history_val || tab_text == shipper_info) {
                                    setup_counterparty.grids[grid_index].forEachRow(function(row){
                                        setup_counterparty.grids[grid_index].forEachCell(row,function(cellObj,ind){
                                            setup_counterparty.grids[grid_index].validateCell(row,ind)
                                        });
                                    });
                                }
                            } else {
                                setup_counterparty.open_popup_window(counterparty_id, -1, win_type, sql_stmt[tab_text], setup_counterparty.grids[grid_index], grid_type[tab_text]);
                                if(tab_text == approved_counterparty) expand_state = 0;
                            }
                            break;
                        case "delete":
                            msg = "Are you sure you want to delete?";
                            confirm_messagebox(msg, function() {
                                var selected_row = setup_counterparty.grids[grid_index].getSelectedRowId();
                                //Added for Fees row delete
                                if ((tab_text == external_id) || (tab_text == broker_fees) || (tab_text == fees) || (tab_text == certificate) || (tab_text == history_val) || (tab_text == shipper_info)) {

                                    var deleted_xml = setup_counterparty.grids[grid_index].getUserData("", "grid_delete_xml");
                                    var partsOfStr = selected_row.split(',');
                                    grid_xml = '';
                                    for (i = 0; i < partsOfStr.length; i++) {
                                        selected_value_id = setup_counterparty.grids[grid_index].cells(partsOfStr[i], 0).getValue();
                                        grid_xml += '<GridDelete grid_id=' + '"' + selected_value_id + '"' + '></GridDelete>';
                                        setup_counterparty.grids[grid_index].deleteRow(partsOfStr[i]);
                                    }
                                    grid_xml = grid_xml + deleted_xml;
                                    setup_counterparty.grids[grid_index].setUserData("", "grid_delete_xml", grid_xml);
                                    var grid_delete_xml = setup_counterparty.grids[grid_index].getUserData("", "grid_delete_xml");
                                    grid_xml = '<Root>' + grid_delete_xml + '</Root>';
                                    
                                    //Added this logic to directly delete the data once delete button is triggered.
                                    if (tab_text == external_id) {
                                        data = {"action": "spa_counterparty_epa_account",
                                            "flag": "v",
                                            "xml": grid_xml
                                        };
                                        adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');

                                    } else if (tab_text == certificate) {
                                        data = {"action": "spa_counterparty_certificate",
                                            "flag": "v",
                                            "xml": grid_xml
                                        };
                                        adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                    
                                    } else if (tab_text == history_val) {
                                        data = {"action": "spa_counterparty_history",
                                            "flag": "d",
                                            "xml": grid_xml
                                        };
                                        adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');

                                    } else if (tab_text == shipper_info) {
                                        data = {"action": "spa_counterparty_shipper_info",
                                            "flag": "d",
                                            "xml": grid_xml
                                        };
                                        adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');

                                    }
                                    else {
                                        data = {"action": "spa_broker_fees",
                                            "flag": "v",
                                            "xml": grid_xml
                                        };
                                        adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                    }
                                    setup_counterparty.grid_menu[menu_index].setItemDisabled('save_changes');
                                }
                                else if (tab_text == bank_information) {
                                    var partsOfStr = selected_row.split(',');
                                    grid_xml = '<Root>';
                                    for (i = 0; i < partsOfStr.length; i++) {
                                        var primary_column_value = setup_counterparty.grids[grid_index].cells(partsOfStr[i], 0).getValue();
                                        grid_xml += '<GridDelete grid_id=' + '"' + primary_column_value + '"' + '></GridDelete>';
                                        setup_counterparty.grids[grid_index].deleteRow(partsOfStr[i]);
                                    }
                                    grid_xml += '</Root>';
                                    data = {
                                        "action": "spa_counterparty_bank_info",
                                        "flag": "v",
                                        "xml": grid_xml
                                    };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                }
                                else if (tab_text == contacts_val) {
                                    var partsOfStr = selected_row.split(',');
                                    grid_xml = '<Root>';
                                    for (i = 0; i < partsOfStr.length; i++) {
                                        var primary_column_value = setup_counterparty.grids[grid_index].cells(partsOfStr[i], 0).getValue();
                                        grid_xml += '<GridDelete grid_id=' + '"' + primary_column_value + '"' + '></GridDelete>';
                                        setup_counterparty.grids[grid_index].deleteRow(partsOfStr[i]);
                                    }
                                    grid_xml += '</Root>';
                                    data = {
                                        "action": "spa_counterparty_contacts",
                                        "flag": "v",
                                        "xml": grid_xml
                                    };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                }
                                else if (tab_text == contracts_val) {
                                    var partsOfStr = selected_row.split(',');
                                    grid_xml = '<Root>';
                                    for (i = 0; i < partsOfStr.length; i++) {
                                        var primary_column_value = setup_counterparty.grids[grid_index].cells(partsOfStr[i], 1).getValue();
                                        grid_xml += '<GridDelete grid_id=' + '"' + primary_column_value + '"' + '></GridDelete>';
                                        setup_counterparty.grids[grid_index].deleteRow(partsOfStr[i]);
                                    }
                                    grid_xml += '</Root>';
                                    data = {
                                        "action": "spa_counterparty_contract_address",
                                        "flag": "v",
                                        "xml": grid_xml
                                        };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                } else if (tab_text == product_val) {
                                    var partsOfStr = selected_row.split(',');
                                    grid_xml = '<Root>';
                                    for (i = 0; i < partsOfStr.length; i++) {
                                        var primary_column_value = setup_counterparty.grids[grid_index].cells(partsOfStr[i], 0).getValue();
                                        grid_xml += '<GridDelete grid_id=' + '"' + primary_column_value + '"' + '></GridDelete>';
                                        setup_counterparty.grids[grid_index].deleteRow(partsOfStr[i]);
                                    }
                                    grid_xml += '</Root>';
                                    data = {
                                        "action": "spa_counterparty_products",
                                        "flag": "d",
                                        "xml": grid_xml
                                    };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                } else if (tab_text == approved_counterparty) {
                                    var partsOfStr = selected_row.split(',');
                                    grid_xml = '<Root>';
                                    for (i = 0; i < partsOfStr.length; i++) {
                                        var level = setup_counterparty.grids[grid_index].getLevel(partsOfStr[i]);
                                        
                                        if (level == 0) {
                                            var col_index = setup_counterparty.grids[grid_index].getColIndexById('approved_counterparty_id');
                                            var get_sub_rows = setup_counterparty.grids[grid_index].getSubItems(partsOfStr[i]);
                                            if(get_sub_rows != '') {
                                                var sub_rows_array = get_sub_rows.split(",");
                                                var row_id = sub_rows_array[0];
                                                
                                                var approved_counterparty_id = setup_counterparty.grids[grid_index].cells(row_id, col_index).getValue();
                                                var primary_column_value = setup_counterparty.grids[grid_index].cells(partsOfStr[i], 0).getValue();
                                                grid_xml += '<GridDelete grid_id=' + '"' + approved_counterparty_id + '"' + '></GridDelete>';
                                            }
                                        } else {
                                            var col_index = setup_counterparty.grids[grid_index].getColIndexById('approved_product_id');
                                            var primary_column_value = setup_counterparty.grids[grid_index].cells(partsOfStr[i], col_index).getValue();
                                            grid_xml += '<GridDeleteProduct grid_id=' + '"' + primary_column_value + '"' + '></GridDeleteProduct>';
                                        }
                                        //setup_counterparty.grids[grid_index].deleteRow(partsOfStr[i]);
                                    }
                                    grid_xml += '</Root>';
                                    
                                    data = {
                                        "action": "spa_approved_counterparty",
                                        "flag": "d",
                                        "xml": grid_xml
                                    };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                }
                            })
                            break;
                        case "refresh":
                            if (sql_stmt[tab_text] != '' && sql_stmt[tab_text] != null) {
                                setup_counterparty.refresh_grids(sql_stmt[tab_text], setup_counterparty.grids[grid_index], grid_type[tab_text], counterparty_id);
                            }
                            break;
                        case "excel":
                            setup_counterparty.grids[grid_index].toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                            break;
                        case "pdf":
                            setup_counterparty.grids[grid_index].toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                            break;
                        case "save_changes":
                            var epa_store = new Array();
                            var save_validation_status = 1;
                            var grid_xml = '<Root>';
                            setup_counterparty.grids[grid_index].clearSelection();
                            if (tab_text == external_id) {
                                var grid_status = setup_counterparty.validate_form_grid(setup_counterparty.grids[grid_index],'External ID');
                                setup_counterparty.grids[grid_index].forEachRow(function(id) {
                                    var epa_id = setup_counterparty.grids[grid_index].cells(id, 0).getValue();
                                    var external_type_id = setup_counterparty.grids[grid_index].cells(id, 2).getValue();
                                    var external_value = (setup_counterparty.grids[grid_index].cells(id, 3).getValue()).trim();

                                    if (counterparty_id == '') {
                                        var message = get_message('VALIDATE_COUNTERPARTY');
                                        show_messagebox(message);
                                        save_validation_status = 0;
                                        return;
                                    } else if (external_type_id == '' && external_value != '') {
                                        var message = get_message('SELECT_EXTERNAL_TYPE');

                                        show_messagebox(message);

                                        save_validation_status = 0;
                                        return;
                                    } else if (external_type_id != '' && external_value == '') {
                                        var message = get_message('SELECT_DATA');

                                        show_messagebox(message);

                                        save_validation_status = 0;
                                        return;
                                    } else if (external_type_id != '' && external_value != '') {
                                        //proceed for save operation
                                        var chk_duplicate = epa_store.indexOf(external_type_id);
                                        if (chk_duplicate >= 0) {
                                            var message = get_message('DUPLICATE_TYPE_ID');
                                            show_messagebox(message);
                                            save_validation_status = 0;
                                            return;
                                        }
                                        epa_store.push(external_type_id);

                                        if (epa_id) {
                                            grid_xml = grid_xml + '<GridUpdate counterparty_epa_account_id = ' + '"' + epa_id + '"' + ' counterparty_id=' + '"' + counterparty_id + '"' + ' external_type_id=' + '"' + external_type_id + '" external_value=' + '"' + external_value + '"></GridUpdate>';
                                        }
                                        else {
                                            grid_xml = grid_xml + '<GridInsert counterparty_epa_account_id = ' + '""' + ' counterparty_id=' + '"' + counterparty_id + '"' + ' external_type_id=' + '"' + external_type_id + '" external_value=' + '"' + external_value + '"></GridInsert>';
                                        }
                                    }
                                });

                                if (save_validation_status) {
                                    var grid_delete_xml = setup_counterparty.grids[grid_index].getUserData("", "grid_delete_xml");
                                    grid_xml = grid_xml + grid_delete_xml + '</Root>';
                                    data = {"action": "spa_counterparty_epa_account",
                                        "flag": "v",
                                        "xml": grid_xml
                                    };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                }
                                //ends tab_text == 'external_id'  
                            }
                            
                            /*****added for Fees tab grid row save****/
                            else if (tab_text == fees) {
                                var grid_status = setup_counterparty.validate_form_grid(setup_counterparty.grids[grid_index],'Fees');
                                setup_counterparty.grids[grid_index].forEachRow(function(id) {
                                    var fee_row = setup_counterparty.grids[grid_index].cells(id, 0).getValue();
                                    var effective_date = setup_counterparty.grids[grid_index].cells(id, 1).getValue();
                                    var deal_type = setup_counterparty.grids[grid_index].cells(id, 2).getValue();
                                    var commodity = setup_counterparty.grids[grid_index].cells(id, 3).getValue();
                                    var product = setup_counterparty.grids[grid_index].cells(id, 4).getValue();
                                    var unit_price = setup_counterparty.grids[grid_index].cells(id, 5).getValue();
                                    var fixed_price = setup_counterparty.grids[grid_index].cells(id, 6).getValue();
                                    var currency = setup_counterparty.grids[grid_index].cells(id, 7).getValue();
                                    
                                    save_validation_status = 1;
                                    var labels = '';

                                    if (effective_date == '') {
                                       labels = labels + '<b>Effective Date</b>';
                                        save_validation_status = 0;
                                    }

                                    if (deal_type == '') {
                                        labels = labels + ', <b>Deal Type</>';
                                        save_validation_status = 0;
                                    }

                                    if (commodity == '') {
                                        labels = labels + ', <b>Commodity</b>';
                                        save_validation_status = 0;
                                    }

                                    if (product == '') {
                                        labels = labels + ', <b>Product</b>';
                                        save_validation_status = 0;
                                    }

                                    if (currency == '') {
                                        labels = labels + ', <b>Currency</b>';
                                        save_validation_status = 0;
                                    }

                                    labels_arr = labels.split('');

                                    if (labels_arr[0] == ',') {
                                        labels = labels.substr(1);
                                    }

                                    if (save_validation_status == 0) {
                                        show_messagebox('Data Error in Fees grid. Please check the data in columns '+ labels +' and resave.');

                                        return;
                                    }

                                    if (fee_row != '') {
                                        grid_xml = grid_xml + '<GridUpdate broker_fees_id=' + '"' + fee_row + '"' + ' counterparty_id=' + '"' + counterparty_id + '"' + ' effective_date=' + '"' + effective_date + '" deal_type=' + '"' + deal_type + '" commodity=' + '"' + commodity + '" product=' + '"' + product + '" unit_price=' + '"' + unit_price + '" fixed_price=' + '"' + fixed_price + '" currency=' + '"' + currency + '"></GridUpdate>';
                                    } else {
                                        grid_xml = grid_xml + '<GridInsert counterparty_id=' + '"' + counterparty_id + '"' + ' effective_date=' + '"' + effective_date + '" deal_type=' + '"' + deal_type + '" commodity=' + '"' + commodity + '" product=' + '"' + product + '" unit_price=' + '"' + unit_price + '" fixed_price=' + '"' + fixed_price + '" currency=' + '"' + currency + '"></GridInsert>';
                                    }
                                });

                                if (save_validation_status) {
                                    var grid_delete_xml = setup_counterparty.grids[grid_index].getUserData("", "grid_delete_xml");
                                    grid_xml = grid_xml + grid_delete_xml + '</Root>';
                                    data = {"action": "spa_broker_fees",
                                            "flag": "v",
                                            "xml": grid_xml
                                    };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                }
                            }
                            /****** end of Fees tab grid row save*****/
                            else if (tab_text == broker_fees) {
                                var broker_date_store = new Array();
                                var broker_contract_store = new Array();
                                var broker_date_store1 = new Array();
                                var broker_contract_store1 = new Array();
                                var save_validation_status = 1;
                                setup_counterparty.grids[grid_index].setDateFormat("%m/%d/%Y");
                                setup_counterparty.grids[grid_index].forEachRow(function(id) {

                                    var broker_fees_id = setup_counterparty.grids[grid_index].cells(id, 0).getValue();
                                    var effective_date = setup_counterparty.grids[grid_index].cells(id, 1).getDate(true);
                                    var broker_contract = setup_counterparty.grids[grid_index].cells(id, 2).getValue();
                                    var deal_type = setup_counterparty.grids[grid_index].cells(id, 3).getValue();
                                    var commodity = setup_counterparty.grids[grid_index].cells(id, 4).getValue();
                                    var product = setup_counterparty.grids[grid_index].cells(id, 5).getValue();
                                    if (!product)
                                        product = '';
                                    if (counterparty_id == '') {
                                        var message = get_message('VALIDATE_COUNTERPARTY');
                                        show_messagebox(message);
                                        save_validation_status = 0;
                                        return;
                                    } else if ((!effective_date)) {
                                        var message = get_message('SELECT_DATE');
                                        show_messagebox(message);
                                        save_validation_status = 0;
                                        return;
                                    }
                                    else if ((broker_contract == '')) {
                                        var message = get_message('SELECT_BROKER_CONTRACT');
                                        show_messagebox(message);
                                        save_validation_status = 0;
                                        return;
                                    }
                                    effective_date = ((effective_date.getMonth() + 1) + '/' + effective_date.getDate() + '/' + effective_date.getFullYear());
                                    broker_date_store.push(effective_date);
                                    broker_contract_store.push(broker_contract);
                                    broker_date_store1.push(effective_date);
                                    broker_contract_store1.push(broker_contract);
                                    if (broker_fees_id) {
                                        grid_xml = grid_xml + '<GridUpdate broker_fees_id = ' + '"' + broker_fees_id + '"' + ' counterparty_id=' + '"' + counterparty_id + '"' + ' effective_date=' + '"' + effective_date + '" broker_contract=' + '"' + broker_contract + '" deal_type=' + '"' + deal_type + '" commodity=' + '"' + commodity + '" product=' + '"' + product + '"></GridUpdate>';
                                    }
                                    else {
                                        grid_xml = grid_xml + '<GridInsert broker_fees_id = ' + '"' + broker_fees_id + '"' + ' counterparty_id=' + '"' + counterparty_id + '"' + ' effective_date=' + '"' + effective_date + '" broker_contract=' + '"' + broker_contract + '" deal_type=' + '"' + deal_type + '" commodity=' + '"' + commodity + '" product=' + '"' + product + '"></GridInsert>';
                                    }
                                });
                                // grid_xml += '</Root>';

                                for (i = 0; i < broker_date_store.length; i++) {
                                    l = 0;
                                    for (j = i + 1; j < broker_date_store1.length; j++) {
                                        if (broker_date_store1[j] == broker_date_store[i]) {
                                            if (broker_contract_store[i] == broker_contract_store[j]) {
                                                var message = get_message('VALIDATE_BROKER');
                                                show_messagebox(message);
                                                save_validation_status = 0;
                                                return;
                                            }
                                        }
                                    }
                                }
                                if (save_validation_status) {
                                    var grid_delete_xml = setup_counterparty.grids[grid_index].getUserData("", "grid_delete_xml");
                                    grid_xml = grid_xml + grid_delete_xml + '</Root>';
                                    data = {"action": "spa_broker_fees",
                                        "flag": "v",
                                        "xml": grid_xml
                                    };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                }
                                //ends tab_text == 'External ID'  
                            } else if (tab_text == certificate) {
                                var grid_status = setup_counterparty.validate_form_grid(setup_counterparty.grids[grid_index],'Certificate');
                                setup_counterparty.grids[grid_index].forEachRow(function(id) {
                                    var col_index = setup_counterparty.grids[grid_index].getColIndexById('counterparty_certificate_id');                                    
                                    var certificate_id = setup_counterparty.grids[grid_index].cells(id, col_index).getValue();
                                    var col_index = setup_counterparty.grids[grid_index].getColIndexById('available_reqd');
                                    var available_reqd = setup_counterparty.grids[grid_index].cells(id, col_index).getValue();
                                    var col_index = setup_counterparty.grids[grid_index].getColIndexById('certificate_id');
                                    var certificate_name = setup_counterparty.grids[grid_index].cells(id, col_index).getValue();
                                    var col_index = setup_counterparty.grids[grid_index].getColIndexById('effective_date');
                                    var effective_date = setup_counterparty.grids[grid_index].cells(id, col_index).getValue();
                                    var col_index = setup_counterparty.grids[grid_index].getColIndexById('expiration_date');
                                    var expiration_date = setup_counterparty.grids[grid_index].cells(id,col_index).getValue();
                                    var col_index = setup_counterparty.grids[grid_index].getColIndexById('comments');
                                    var comments = setup_counterparty.grids[grid_index].cells(id, col_index).getValue();
                                    
                                    if (counterparty_id == '') {
                                        var message = get_message('VALIDATE_COUNTERPARTY');
                                        show_messagebox(message);
                                        grid_status = false;
                                        return;
                                    } //else if (certificate_name == '') {
//                                        var message = get_message('VALIDATE_CERTIFICATE_NAME');
//                                        show_messagebox(message);
//                                        save_validation_status = 0;
//                                        return;
//                                    } 
                                    else if (effective_date != '' && expiration_date != '' && expiration_date < effective_date) {
                                        var message = get_message('VALIDATE_DATE_RANGE');
                                        show_messagebox(message);
                                        grid_status = false;
                                    } //else if (certificate_name != '') {
                                        if (certificate_id) {
                                            grid_xml = grid_xml + '<GridUpdate counterparty_certificate_id = ' + '"' + certificate_id + '"' + ' counterparty_id=' + '"' + counterparty_id + '"' + ' effective_date=' + '"' + effective_date + '" expiration_date=' + '"' + expiration_date + '" certificate_id=' + '"' + certificate_name + '" available_reqd=' + '"' + available_reqd + '" comments=' + '"' + comments + '"></GridUpdate>';
                                        }
                                        else {
                                            grid_xml = grid_xml + '<GridInsert counterparty_certificate_id = ' + '""' + ' counterparty_id=' + '"' + counterparty_id + '"' + ' effective_date=' + '"' + effective_date + '" expiration_date=' + '"' + expiration_date + '" certificate_id=' + '"' + certificate_name + '" available_reqd=' + '"' + available_reqd + '" comments=' + '"' + comments + '"></GridInsert>';
                                        }
                                    //}
                                });

                                if (grid_status) {
                                    var grid_delete_xml = setup_counterparty.grids[grid_index].getUserData("", "grid_delete_xml");
                                    grid_xml = grid_xml + grid_delete_xml + '</Root>';
                                    
                                    data = {"action": "spa_counterparty_certificate",
                                            "flag": "v",
                                            "xml": grid_xml
                                            };
                                    adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                                }
                            } else if (tab_text == history_val) {
                                 var grid_status = setup_counterparty.validate_form_grid(setup_counterparty.grids[grid_index],'History');
                                 setup_counterparty.grids[grid_index].forEachRow(function(id) {
                                    var counterparty_history_id = setup_counterparty.grids[grid_index].cells(id, 0).getValue();
                                    var effective_date = setup_counterparty.grids[grid_index].cells(id, 1).getValue();
                                    var counterparty_name = setup_counterparty.grids[grid_index].cells(id, 4).getValue();
                                    // counterparty_name_id is counterparty_id since the variable counterparty has been used for the source_counterparty_id 
                                    var counterparty_id_name = setup_counterparty.grids[grid_index].cells(id, 5).getValue();
                                    var counterparty_desc = setup_counterparty.grids[grid_index].cells(id, 6).getValue();
                                    var parent_counterparty = setup_counterparty.grids[grid_index].cells(id, 7).getValue();
                                    var type = setup_counterparty.grids[grid_index].cells(id, 3).getValue();
                                    var counterparty = setup_counterparty.grids[grid_index].cells(id, 8).getValue();
                                    
                                    if (counterparty_name != '' && counterparty_id_name =='') {
                                        counterparty_id_name = counterparty_name;
                                    }

                                    if (counterparty_name != '' && counterparty_desc =='') {
                                        counterparty_desc = counterparty_name;
                                    }

                                    grid_xml = grid_xml + '<GridSave counterparty_history_id = ' + '"' + counterparty_history_id + '"' + ' effective_date=' + '"' + effective_date + '"' + ' counterparty_name=' + '"' + counterparty_name + '" source_counterparty_id=' + '"' + counterparty_id + '" counterparty_id=' + '"' + counterparty_id_name + '" counterparty_desc=' + '"' + counterparty_desc + '" parent_counterparty=' + '"' + parent_counterparty + '"  type=' + '"' + type + '" counterparty=' + '"' + counterparty + '"></GridSave>';                                                                      
                                });
                                
                                //var grid_delete_xml = setup_counterparty.grids[grid_index].getUserData("", "grid_delete_xml");
                                grid_xml = grid_xml + '</Root>';    

                                data = {"action": "spa_counterparty_history",
                                    "flag": "u",
                                    "xml": grid_xml
                                };
                                adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all'); 
                            } else if (tab_text == shipper_info) {
                                 var grid_status = setup_counterparty.validate_form_grid(setup_counterparty.grids[grid_index],'Shipper Info');
                                 setup_counterparty.grids[grid_index].forEachRow(function(id) {
                                    var counterparty_shipper_info_id = setup_counterparty.grids[grid_index].cells(id, 0).getValue();
                                    var location = setup_counterparty.grids[grid_index].cells(id, 2).getValue();
                                    // counterparty_name_id is counterparty_id since the variable counterparty has been used for the source_counterparty_id 
                                    var commodity = setup_counterparty.grids[grid_index].cells(id, 3).getValue();
                                    var effective_date = setup_counterparty.grids[grid_index].cells(id, 4).getValue();
                                    var shipper_code = setup_counterparty.grids[grid_index].cells(id, 5).getValue();

                                    grid_xml = grid_xml + '<GridSave counterparty_shipper_info_id = ' + '"' + counterparty_shipper_info_id + '"' + ' location=' + '"' + location + '"' + ' commodity=' + '"' + commodity + '" source_counterparty_id=' + '"' + counterparty_id + '" effective_date=' + '"' + effective_date + '" shipper_code=' + '"' + shipper_code + '"></GridSave>';                                                                      
                                });
                                
                                //var grid_delete_xml = setup_counterparty.grids[grid_index].getUserData("", "grid_delete_xml");
                                grid_xml = grid_xml + '</Root>';
                                data = {"action": "spa_counterparty_shipper_info",
                                    "flag": "u",
                                    "xml": grid_xml
                                };
                                adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all'); 
                            }
                            break;
                        case "copy":
                            if (tab_text == product_val) {
                                var selected_id = setup_counterparty.grids[grid_index].getSelectedRowId();
                                var row_index = setup_counterparty.grids[grid_index].getRowIndex(selected_id);
                                var product_id = setup_counterparty.grids[grid_index].cells2(row_index, 0).getValue();
                                
                                data = {"action": "spa_counterparty_products",
                                    "flag": "v",
                                    "dependent_id": product_id
                                };
                                
                                adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all');
                            }  
                            break;
                        case "add_product":
                            var selected_id = setup_counterparty.grids[grid_index].getSelectedRowId();
                            var col_index = setup_counterparty.grids[grid_index].getColIndexById('approved_counterparty_id');
                            var get_sub_rows = setup_counterparty.grids[grid_index].getSubItems(selected_id);
                            if(get_sub_rows != '') {
                                var sub_rows_array = get_sub_rows.split(",");
                                var row_id = sub_rows_array[0];
                                var approved_counterparty_id = setup_counterparty.grids[grid_index].cells(row_id, col_index).getValue();
                            } else {
                                var approved_counterparty_id = setup_counterparty.grids[grid_index].cells(selected_id, col_index).getValue();
                            }
                            setup_counterparty.open_popup_window(counterparty_id, approved_counterparty_id, 'ap', sql_stmt[tab_text], setup_counterparty.grids[grid_index], grid_type[tab_text]);
                            expand_state = 0;
                            break;
                        case "expand_collapse":
                            if(expand_state == 0) {
                                setup_counterparty.grids[grid_index].expandAll();
                                expand_state = 1;
                            } else {
                                setup_counterparty.grids[grid_index].collapseAll();
                                expand_state = 0;
                            }
                            break;
                        case "workflow_status":
                            var selected_id = setup_counterparty.grids[grid_index].getSelectedRowId();
                            var get_sub_rows = setup_counterparty.grids[grid_index].getSubItems(selected_id);
                            if(get_sub_rows != '') {
                                var sub_rows_array = get_sub_rows.split(",");
                                var row_id = sub_rows_array[0];
                                var counterparty_contract_address_id = setup_counterparty.grids[grid_index].cells(row_id, 1).getValue();
                            } else {
                                var counterparty_contract_address_id = setup_counterparty.grids[grid_index].cells(selected_id, 1).getValue();
                            }
                            
                            var workflow_report = new dhtmlXWindows();
                            workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
                            workflow_report_win.setText("Workflow Status");
                            workflow_report_win.centerOnScreen();
                            workflow_report_win.setModal(true);
                            workflow_report_win.maximize();

                            var filter_string = '';
                            var process_table_xml = 'counterparty_contract_address_id:' + counterparty_contract_address_id;
                            var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + counterparty_contract_address_id + '&source_column=counterparty_contract_address_id&module_id=20622&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
                            workflow_report_win.attachURL(page_url, false, null);
                            break;
                        case "netting":
                            var selected_id = setup_counterparty.grids[grid_index].getAllRowIds();
                            var contracts = new Array();

                            $.each(selected_id.split(','), function(index, rowID) { 
                                var tree_level = setup_counterparty.grids[grid_index].getLevel(rowID);

                                if(tree_level == 0) {
                                    var get_sub_rows = setup_counterparty.grids[grid_index].getSubItems(rowID);

                                    if(get_sub_rows != '') {
                                        var sub_rows_array = get_sub_rows.split(",");

                                        $.each(sub_rows_array, function( i, v ) {
                                          contracts.push(setup_counterparty.grids[grid_index].cells(v, setup_counterparty.grids[grid_index].getColIndexById("contract_name")).getValue());
                                        }); 

                                    } else {
                                        contracts.push(setup_counterparty.grids[grid_index].cells(rowID, setup_counterparty.grids[grid_index].getColIndexById("contract_name")).getValue());
                                    }

                                } else {
                                    contracts.push(setup_counterparty.grids[grid_index].cells(rowID, setup_counterparty.grids[grid_index].getColIndexById("contract_name")).getValue());
                                }


                            });  

                            var unique_contracts = [];
                            $.each(contracts, function(i, el){
                                if($.inArray(el, unique_contracts) === -1) unique_contracts.push(el);
                            });
                            contract_ids = unique_contracts.join(',');

                            var netting_button = new dhtmlXWindows();
                            netting_button_win = netting_button.createWindow('w1', 0, 0, 900, 700);
                            netting_button_win.setText("Netting");
                            netting_button_win.centerOnScreen();
                            netting_button_win.setModal(true);
                            netting_button_win.maximize();

                            var process_table_xml = 'contract_ids:' + contract_ids;
                            var page_url = js_php_path + '../adiha.html.forms/_contract_administration/maintain_contract_group/netting.contract.php?counterparty_id=' + counterparty_id;
                            netting_button_win.attachURL(page_url, false, null);
                            break;
                    }
                });

                i++;
            });

            setup_counterparty.details_layout["details_layout_" + counterparty_id].cells("b").showHeader();
            setup_counterparty.details_tabs["details_tabs_a_" + counterparty_id].forEachTab(function(tab) {
                var tab_text = tab.getText();
                if (tab_text == get_locale_value('General') && is_new != new_label) {
                    var id = tab.getId();
                    var form_index = "details_form_" + counterparty_id + "_" + id;
                    var form_obj = setup_counterparty.details_form[form_index];

                    var object_id = counterparty_id;
                    toolbar_obj = setup_counterparty.tabbar.cells("tab_" + object_id).getAttachedToolbar();
                    toolbar_obj.addButton('credit_file', 2, 'Credit File', 'doc.gif', 'doc_dis.gif');
                    add_manage_document_button(object_id, toolbar_obj, 1);// changed to 1 to enable documents button in default
                    toolbar_obj.addButton('cpty_reminder_alert', 3, 'Alerts', 'export.gif', 'export_dis.gif');
                }
            });
        }
        /**
         * [load_form_data Callback function to load upper tab forms]
         * @param  {[Array]} result [Form Array]
         */

        setup_counterparty.load_form_data = function(result) {
            var counterparty_id = setup_counterparty.tabbar.getActiveTab();
            var counterparty_id = (counterparty_id.indexOf("tab_") != -1) ? counterparty_id.replace("tab_", "") : counterparty_id;

            var tab_json = '';
            var form_json = {};

            // create tab json and form json
            for (i = 0; i < result.length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);

                form_json[i] = result[i][2];
            }
            
            // attach forms to the upper cell of layout
            var cell_a = setup_counterparty.details_layout["details_layout_" + counterparty_id].cells("a");
            cell_a.progressOn();
            tab_json = '{tabs: [' + tab_json + ']}';
            setup_counterparty.details_tabs["details_tabs_a_" + counterparty_id] = cell_a.attachTabbar();
            setup_counterparty.details_tabs["details_tabs_a_" + counterparty_id].loadStruct(tab_json);

            // load forms to tabs
            var i = 0;
            setup_counterparty.details_tabs["details_tabs_a_" + counterparty_id].forEachTab(function(tab) {
                
               

                var id = tab.getId();
                var form_index = "details_form_" + counterparty_id + "_" + id;
               

            //console.log(id + " " + tab.getText() + " "+form_index);
                
                setup_counterparty.details_form[form_index] = tab.attachForm();
                var form_name = 'setup_counterparty.details_form["' + form_index + '"]';                
                setup_counterparty.details_form[form_index].loadStruct(form_json[i], function(){
                     
                        if (tab.getText() == get_locale_value('Address')) {
                            attach_browse_event(form_name, 10105800, '', '', 'id=' + counterparty_id)
                            
                        }
                   
                });
                
                i++;

                if (counterparty_id.indexOf("tab_") == -1 && tab.getText() == fees) {
                    data = {"action": "spa_broker_fees",
                            "flag": 'h',
                            "counterparty_id": counterparty_id
                           };
                    adiha_post_data("", data, "", "", "setup_counterparty.get_source_counterparty_id");
                }

                //start of dynamic fees tab
                setup_counterparty.details_form[form_index].attachEvent("onChange", function(name, value) {
                    if (name == 'counterparty_name') {
                        name_change = 'true'; // if name_change is true history should be inserted                       
                    }

                    if (name == 'int_ext_flag') {
                        var fees_tab_id, fees_tab_text;
                        setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].forEachTab(function(tab) {
                            fees_tab_text = tab.getText();
                            if (fees_tab_text.indexOf(fees) != -1) {
                                fees_tab_id = tab.getId();    
                            }
                        });
                        
                        var int_ext_flag_value = setup_counterparty.details_form[form_index].getCombo('int_ext_flag').getSelectedValue();
                        if (int_ext_flag_value!='b') {
                            setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].tabs(fees_tab_id).hide();
                        } else {
                            setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].tabs(fees_tab_id).show();
                        }
                    }
                });
                //end of fee tab
            });
            cell_a.progressOff();
        }
        setup_counterparty.get_source_counterparty_id = function(result) {
            var counterparty_id = setup_counterparty.tabbar.getActiveTab();
            var counterparty_id = (counterparty_id.indexOf("tab_") != -1) ? counterparty_id.replace("tab_", "") : counterparty_id;
            var fees_tab_id, fees_tab_text;

            setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].forEachTab(function(tab) {
                fees_tab_text = tab.getText();
                if (fees_tab_text.indexOf(fees) != -1) {
                    fees_tab_id = tab.getId();    
                }
            });

            if (fees_tab_id != undefined && fees_tab_id != '') {
                setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].tabs(fees_tab_id).hide(); //By default hide tab - 'fees' because default value is always 'External'.
                if(typeof result[0]!= "undefined") { // Check only in update mode.
                    if (result[0]['int_ext_flag']!='b') {
                        setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].tabs(fees_tab_id).hide();
                    } else {
                        setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].tabs(fees_tab_id).show();
                    }
                }
            } 
        }

        /**
         * [refresh_grids Refresh Grid]
         * @param  {[type]} sql_stmt        [Grid Population query]
         * @param  {[type]} grid_obj        [Grid Object]
         * @param  {[type]} grid_type       [Grid Type]
         * @param  {[type]} counterparty_id [Counterparty ID]
         */
        setup_counterparty.refresh_grids = function(sql_stmt, grid_obj, grid_type, counterparty_id) {
            if (sql_stmt.indexOf('<ID>') != -1) {
                var stmt = sql_stmt.replace('<ID>', counterparty_id);
            } else {
                var stmt = sql_stmt;
            }
            // load grid data
            if(sql_stmt.indexOf('spa_counterparty_contract_address') !== -1) { //For contracts tab grid
                var sql_param = {
                "sql": stmt,
                "grid_type": 'tg',
                "grouping_type":5,
                "grouping_column":'internal_counterparty,contract_name'
            };
            }
            else{
	            var sql_param = {
	                "sql": stmt,
	                "grid_type": grid_type
	            };
            }

            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            grid_obj.clearAll();
            grid_obj.load(sql_url, function() {
                grid_obj.filterByAll();

                if(sql_stmt.indexOf('spa_counterparty_history') !== -1) { // For History tab grid.
                    grid_obj.forEachRow(function(id) { 
                        var combo_val = grid_obj.cells(id,3).getValue(); 
                        if(combo_val == '105900') {
                            grid_obj.cells(id,8).setValue('');
                            grid_obj.cells(id,8).setDisabled(true); 
                        } else {
                            grid_obj.cells(id,4).setValue('');
                            grid_obj.cells(id,5).setValue('');
                            grid_obj.cells(id,6).setValue('');
                            grid_obj.cells(id,7).setValue('');

                            grid_obj.cells(id,4).setDisabled(true); 
                            grid_obj.cells(id,5).setDisabled(true); 
                            grid_obj.cells(id,6).setDisabled(true); 
                            grid_obj.cells(id,7).setDisabled(true); 
                        }
                    });
                }

            });
        }

        /**
         * [open_popup_window Open popups for data insertion and update]
         * @param  {[int]} counterparty_id  [Counterparty ID]
         * @param  {[type]} id              [id from the respective grid]
         * @param  {[type]} win_type        [window type 'b' for Bank Info, c for Contract Mapping, m for Meter Mapping]
         */
        setup_counterparty.open_popup_window = function(counterparty_id, id, win_type, sql_stmt, grid_obj, grid_type) {
            unload_window();
            var win_text = '';
            var param = '';
            var width = 850;
            var height = 720;

            if (win_type == 'c') {
                win_text = 'Contract';
                param = 'counterparty.contract.address.php?counterparty_id=' + counterparty_id + '&counterparty_contract_address_id=' + id;
            } else if (win_type == 'm') {
                win_text = 'Meter Mapping';
                param = 'counterparty.meter.php?counterparty_id=' + counterparty_id + '&counterparty_contact_id=' + id + '&privilege=' + has_rights_counterparty_meter_mapping;
                width = 650;
                height = 540;
            } else if (win_type == 'b') {
                win_text = 'Bank Information';
                param = 'counterparty.bank.info.php?counterparty_id=' + counterparty_id + '&counterparty_contact_id=' + id;
                width = 540;
                height = 410;
            } else if (win_type == 'ct') {
                win_text = 'Contact';
                param = 'counterparty.contacts.php?counterparty_id=' + counterparty_id + '&counterparty_contact_id=' + id;
                width = 540;
                height = 550;
                if (counterparty_id != '') {
                    var tab_id = setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].getActiveTab();
                    var tab_text = setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].tabs(tab_id).getText();
                    var i = setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].tabs(tab_id).getIndex();
                    var sql_stmt = grid_definition_json[i]["sql_stmt"];
                    var grid_type = grid_definition_json[i]["grid_type"];
                    var grid_name = grid_definition_json[i]["grid_name"];
                    var grid_index = "grid_" + counterparty_id + "_" + grid_name;
                    var grid_obj = setup_counterparty.grids[grid_index];
                }
            } else if (win_type == 'p') {
                win_text = 'Product';
                param = 'counterparty.products.php?counterparty_id=' + counterparty_id + '&counterparty_product_id=' + id;
                width = 540;
                height = 450;
            } else if (win_type == 'a') {
                win_text = 'Approve Counterparty';
                param = 'approved.counterparty.php?counterparty_id=' + counterparty_id + '&approved_counterparty_id=' + id;
                width = 500;
                height = 500;
            } else if (win_type == 'ap') {
                win_text = 'Products';
                param = 'approved.product.php?approved_counterparty_id=' + id;
                width = 430;
                height = 300;
            }

            if (!popup_window) {
                popup_window = new dhtmlXWindows();
            }
            
            new_win = popup_window.createWindow('w1', 0, 0, width, height);
            new_win.centerOnScreen();
            new_win.setModal(true);
            
            if(sql_stmt != '' && grid_obj != '' && grid_type != '') {
                new_win.attachEvent("onClose", function(win) {
                    if (win_type == 'a' || win_type == 'ap')
                        setup_counterparty.refresh_approved_counterparty(grid_obj, counterparty_id);
                    else if(win_type == 'c') {
                        setup_counterparty.refresh_contracts(grid_obj, counterparty_id);   
                    }else
                        setup_counterparty.refresh_grids(sql_stmt, grid_obj, grid_type, counterparty_id);
                    
                    return true;
                })
            }
            
            new_win.setText(win_text);
            if (win_type == 'c' || win_type == 'ap') {
                new_win.maximize();
            }
            new_win.attachURL(param, false, true);
        }

        /**
         * [delete_grid_value Delete Grid Rows]
         * @param  {[object]} grid_obj        [Grid Object]
         * @param  {[string]} grid_name       [Grid Name]
         * @param  {[int]}    counterparty_id [Counterparty id]
         * @param  {[string]} selected_row    [Selected rows]
         */
        setup_counterparty.delete_grid_value = function(grid_obj, grid_name, counterparty_id, selected_row) {
            var grid_xml = '<GridDelete grid_id="' + grid_name + '">'
            var selected_array = new Array();
            selected_array = (selected_row.indexOf(",") != -1) ? selected_row.split(",") : selected_row;
            $.each(selected_array, function(index, value) {
                var primary_column_id = grid_obj.getColumnId(0);
                var primary_column_value = grid_obj.cells(value, 0);
                grid_xml += '<GridRow ';
                grid_xml += primary_column_id + '="' + primary_column_value + '" ';
                grid_xml += ' ></GridRow> ';
            });

            grid_xml = '</GridDelete>';
            adiha_post_data('alert', data, '', '', '');
            setup_counterparty.refresh_grids(sql_stmt[tab_text], setup_counterparty.grids[grid_index], grid_type[tab_text], counterparty_id);
        }

        /**
         * [unload_window Window unload function]
         * @param  {[type]} win_type [window type]
         */
        function unload_window(win_type) {
            if (popup_window != null && popup_window.unload != null) {
                popup_window.unload();
                popup_window = w1 = null;
            }
        }

        /**
         * [save_data Save Formm Data]
         * @param  {[type]} tab_id [Active tab id]
         */        
        setup_counterparty.save_data = function(tab_id) {
            var counterparty_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var detail_tabs = setup_counterparty.details_tabs["details_tabs_a_" + counterparty_id];
            var tabsCount = detail_tabs.getNumberOfTabs();
            setup_counterparty.source_counterparty_id = 0;
            setup_counterparty.counterparty_name = '';
            var form_xml = '<FormXML ';
            var grid_xml = "";
            var final_xml = "";
            var form_status = true;
            var first_err_tab;
            setup_counterparty.validation_status = 1;
            detail_tabs.forEachTab(function(tab) {
                var id = tab.getId();
                var form_index = "details_form_" + counterparty_id + "_" + id;
                var form_obj = setup_counterparty.details_form[form_index];
                var status = validate_form(form_obj);

                form_status = form_status && status; 
                if (tabsCount == 1 && !status) {
                     first_err_tab = "";
                } else if ((!first_err_tab) && !status) {
                    first_err_tab = tab;
                }

                if (status) {
                    data = form_obj.getFormData();
                    for (var a in data) {
                        var field_label = a;

                        if (a == 'contact_email' || a == 'email_remittance_to' || a == 'cc_email' || a == 'cc_remittance' || a == 'bcc_email' || a == 'bcc_remittance') {
                            var decode_emails;
                            if (data[a].match(/[%]/)) {
                                var message = 'Please enter a valid e-mail address for ' + data[a];   
                                setup_counterparty.validation_status = 0;               
                                show_messagebox(message);
                            } else {
                                decode_emails = decodeURIComponent(data[a]);
                            }
                            var split_emails = decode_emails.split(';');

                            for (var i = 0; i < split_emails.length; i++) {
                                if (split_emails[i] != '') { 
                                    if (isEmail(split_emails[i]) == false) {
                                        var message = 'Please enter a valid e-mail address for ' + singleQuote(split_emails[i]);            
                                        show_messagebox(message);
                                        setup_counterparty.validation_status = 0;
                                        break;
                                    } 
                                }
                            }                    
                        }

                        if (form_obj.getItemType(field_label) == 'calendar') {
                            var field_value = form_obj.getItemValue(field_label, true);
                        } else if (a == 'counterparty_id') {
                             var field_value = form_obj.getItemValue(field_label, true);
                             if (field_value == '') {
                                field_value = data['counterparty_name'];                                
                             }
                        }else {
                            var field_value = data[field_label];
                            if ((field_label == 'counterparty_desc' && field_value == '') || field_label == 'counterparty_id') {
                                field_value = data['counterparty_name'];
                            }
                        }

                        if (!field_value)
                            field_value = '';
                        if (a == 'source_counterparty_id')
                            setup_counterparty.source_counterparty_id = field_value;
                        if (a == 'counterparty_name')
                            setup_counterparty.counterparty_name = field_value;
                        form_xml += " " + field_label + "=\"" + field_value + "\"";
                    }
                }
                else {         
                    setup_counterparty.validation_status = 0;
                }
            });

            if (!form_status) {
                generate_error_message(first_err_tab);
            }


            new_tab_id = tab_id;
            if (setup_counterparty.validation_status) {
                setup_counterparty.tabbar.cells(tab_id).getAttachedToolbar().disableItem('save');
                form_xml += "></FormXML>";
                final_xml = '<Root function_id="10105800">' + form_xml + '</Root>';
                // NOTE: USE STANDARD SP TO SAVE DATA FROM FORM
                data = {"action": "spa_process_form_data", "xml": final_xml};

                if (setup_counterparty.source_counterparty_id)
                    result = adiha_post_data("alert", data, "", "", "setup_counterparty.post_callback");
                else
                    result = adiha_post_data("alert", data, "", "", "setup_counterparty.post_new_callback");
            }
            /*if (name_change == 'true') {
                if (tab_id.indexOf("tab_")!=-1) {
                    data = {"action": "spa_counterparty_history", "flag":'u', "xml": final_xml, "counterparty_id":setup_counterparty.source_counterparty_id};
                    alert('u');
                }
                else{
                    data = {"action": "spa_counterparty_history", "flag":'i', "xml": final_xml, "counterparty_id":setup_counterparty.source_counterparty_id};
                    alert('i');
                }
                
                result = adiha_post_data("alert", data, "", "", "");
            }
            name_change = 'false';*/
        }

        /*
         * Open document
         * @param {type} tab_id
         * @returns {undefined}         */
        setup_counterparty.open_document = function(object_id, certificate_sub_category_id, counterparty_id,incident_id) {
            var url_call_from = 'counterparty_window';
            var parent_object_id = 'NULL';
            if (certificate_sub_category_id != undefined) {
                var sub_category_id = certificate_sub_category_id;
                if (certificate_sub_category_id == 42001)
                    url_call_from = 'counterparty_window_certificate';
                else if (certificate_sub_category_id == 42002)
                    url_call_from = 'counterparty_window_product';
                
                parent_object_id = counterparty_id;
            } else {
                var sub_category_id = 'NULL';
            }
                
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            param = '../../_setup/manage_documents/manage.documents.php?parent_object_id=' + parent_object_id + '&call_from=' + url_call_from + '&notes_category=' + category_id + '&notes_object_id=' + object_id   + '&sub_category_id=' + sub_category_id + '&is_pop=true' + '&incident_id=' + incident_id;
            var is_win = dhxWins.isWindow('w11');
            if (is_win == true) {
                w11.close();
            }
            w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
            w11.setText("Documents");
            w11.setModal(true);
            w11.maximize();
            w11.attachURL(param, false, true);

            w11.attachEvent("onClose", function(win) {
                if (certificate_sub_category_id != undefined)
                    setup_counterparty.refresh_all();
                else
                    update_document_counter(object_id, toolbar_object);
                
                return true;
            });            
        }
        
        var dhx_document;
        setup_counterparty.attach_document = function(object_id, sub_category_id, notes_id, notes_object_id) {
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            param = '../../_setup/manage_documents/manage.documents.add.edit.php?sub_category_id=' + sub_category_id;
            var is_win = dhxWins.isWindow('w11');
            if (is_win == true) {
                w11.close();
            }
    
            if (!dhx_document) {
                dhx_document = new dhtmlXWindows();
            }
            
            var mode = (notes_id == 'NULL') ? 'i' : 'u';
            var data = {call_from: 'counterparty_window_certificate',
                        category_id: 37,
                        parent_object_id: object_id,
                        notes_object_id: notes_object_id,
                        notes_id: notes_id,
                        category_name: 'Counterparty',
                        is_popup: true,
                        mode: mode
                    };
            
            w11 = dhx_document.createWindow("w1", 0, 0, 650, 550);
            w11.setText("Document");
            w11.setModal(true);
            w11.centerOnScreen();
            w11.attachURL(param, false, data);

            w11.attachEvent("onClose", function(win) {
                setup_counterparty.refresh_all();
                return true;
            });            
        }
        
        setup_counterparty.remove_document = function(notes_id) {
            msg = "Are you sure you want to delete?";
            confirm_messagebox(msg, function() {
                data = {    
                            "action": "spa_application_notes",
                            "flag": "d",
                            "notes_ids": notes_id
                        };
                adiha_post_data('alert', data, '', '', 'setup_counterparty.refresh_all();');
            });
        }
        /*
         * Callback fucntion
         */
        setup_counterparty.post_new_callback = function(result) {
            if (result[0].errorcode == 'Success') {
                //save blank row in counterparty_credit_info table
                var counterparty_id = result[0].recommendation;
                data = {"action": "spa_counterparty_credit_info",
                                "flag": "i",
                                "Counterparty_id": counterparty_id
                        };
                adiha_post_data('return_json', data, '', '', '');
                //END

                if (call_from_combo == 'combo_add') {
                    parent.combo_data_add_win.callEvent("onWindowSaveCloseEvent", ["onSave", counterparty_id]);
                    return;
                }

                var tab_id = 'tab_' + result[0].recommendation;
                var active_tab_id = setup_counterparty.tabbar.getActiveTab();
                //setup_counterparty.refresh_grid("", setup_counterparty.enable_menu_item, '','');
                setup_counterparty.create_tab_custom(tab_id, setup_counterparty.counterparty_name);
                setup_counterparty.tabbar.tabs(active_tab_id).close(true);
                
                data = {"action": "spa_source_counterparty_maintain", "flag": "z", "counterparty_id": counterparty_id};
                adiha_post_data("return_json", data, "", "", "");
            } else if (result[0].errorcode == 'Error') {
                setup_counterparty.tabbar.cells(new_tab_id).getAttachedToolbar().enableItem('save');
            }
        }
        /*
         * Create tab after insert. 
         */
        setup_counterparty.create_tab_custom = function(full_id, text, grid_obj, acc_id) {
            if (!setup_counterparty.pages[full_id]) {
                setup_counterparty.tabbar.addTab(full_id, text, null, null, true, true);
                var win = setup_counterparty.tabbar.cells(full_id);
                win.progressOn();
                //using window instead of tab
                var toolbar = win.attachToolbar();
                toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");
                toolbar.attachEvent("onClick", setup_counterparty.tab_toolbar_click);
                toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", imgdis:"save_dis.gif", text: "Save", title: "Save"}]);
                setup_counterparty.tabbar.cells(full_id).setActive();
                setup_counterparty.tabbar.cells(full_id).setText(text);
                setup_counterparty.load_form(win, full_id, grid_obj, acc_id);
                setup_counterparty.pages[full_id] = win;
            }
            else {
                setup_counterparty.tabbar.cells(full_id).setActive();
            }
            var filter_param = setup_counterparty.get_filter_parameters();
            setup_counterparty.refresh_grid("", setup_counterparty.enable_menu_item, filter_param,'');
            setup_counterparty.menu.setItemDisabled('workflow_status');
        };
        /*
         * callback function
         * @param {type} result
         * @returns {undefined} 
         */
        setup_counterparty.post_callback = function(result) {
            if (has_rights_counterparty_add_save) {
               setup_counterparty.tabbar.cells(setup_counterparty.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save'); 
            };
            
            if (result[0].errorcode == 'Success') {
                var active_tab_id = setup_counterparty.tabbar.getActiveTab();
                var counterparty_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                var filter_param = setup_counterparty.get_filter_parameters();
                setup_counterparty.refresh_grid("", setup_counterparty.enable_menu_item, filter_param,'');
                setup_counterparty.menu.setItemDisabled('workflow_status');
                setup_counterparty.tabbar.tabs(active_tab_id).setText(setup_counterparty.counterparty_name);
                
                data = {"action": "spa_source_counterparty_maintain", "flag": "v", "counterparty_id": counterparty_id};
                adiha_post_data("return_json", data, "", "", "");
            }
        }

        // Override the enable_menu_item method to support multiple deletion.
        setup_counterparty.enable_menu_item = function(id, ind) {
            id = (typeof id == 'undefined') ? null : id;
            if (id != null) {
                var selected_rows = setup_counterparty.grid.getSelectedRowId();

                if(has_rights_counterparty_delete == true && id != null) {
                    setup_counterparty.menu.setItemEnabled("delete");
                } else {
                    setup_counterparty.menu.setItemDisabled("delete");
                }
                if(id != null && id.indexOf(",") == -1) {
                    var c_row = null;
                    var col_type = setup_counterparty.grid.getColType(0);
                    if(col_type == "tree") {
                        var c_row = setup_counterparty.grid.getChildItemIdByIndex(id, 0);
                    }
                    if(col_type == "tree" && c_row != null) {
                        var is_active = -1;
                    } else { 
                        var is_active = setup_counterparty.grid.cells(id, setup_counterparty.grid.getColIndexById("is_privilege_active")).getValue();
                    }
                } else {
                    if (id.indexOf(",") != -1) {
                        var splitted_id = id.split(',');
                        var is_active = setup_counterparty.grid.cells(splitted_id[0], setup_counterparty.grid.getColIndexById("is_privilege_active")).getValue();
                    } else {
                        var is_active = -1
                    }
                }
                if (is_active == 0) {
                    if (has_rights_counterparty_manage_privilege == true ){
                        setup_counterparty.menu.setItemEnabled("activate");
                        setup_counterparty.menu.setItemDisabled("deactivate");
                        setup_counterparty.menu.setItemDisabled("privilege");
                    }
                } else if (is_active == 1){
                    if (has_rights_counterparty_manage_privilege == true ){
                        if (id.indexOf(",") != -1) {
                            setup_counterparty.menu.setItemDisabled("activate");
                            setup_counterparty.menu.setItemDisabled("deactivate");
                            setup_counterparty.menu.setItemEnabled("privilege");
                        } else {
                            setup_counterparty.menu.setItemDisabled("activate");
                            setup_counterparty.menu.setItemEnabled("deactivate");
                            setup_counterparty.menu.setItemEnabled("privilege");
                        }
                    }
                } else {
                    setup_counterparty.menu.setItemDisabled("activate");
                    setup_counterparty.menu.setItemDisabled("deactivate");
                    setup_counterparty.menu.setItemDisabled("privilege");
                }
            }
        }


        function get_message(message_code) {
            switch (message_code) {
                case 'VALIDATE_COUNTERPARTY':
                    return 'Please save counterparty first.';
                case 'DELETE_CONFIRM':
                    return 'Are you sure you want to delete?';
                case 'DELETE_SUCCESS':
                    return 'Data deleted successfully.';
                case 'DELETE_FAILED':
                    return 'Failed to delete data.';
                case 'INSERT_SUCCESS':
                    return 'Data Inserted Successfully';
                case 'UPDATE_SUCCESS':
                    return 'Data Updated Successfully';
                case 'INSERT_FAILED':
                    return 'Failed to Insert Data';
                case 'UPDATE_FAILED':
                    return 'Failed to Update Data';
                case 'SAVE_SUCCESS':
                    return 'Successfully Saved Contract Detail values.';
                case 'SAVE_FAIL':
                    return 'Failed to save Contract Detail values.';
                case 'DUPLICATE_TYPE_ID':
                    return 'Value is already entered for selected external type.';
                case 'SELECT_DATA':
                    return 'Data Error in <b>External ID</b> grid. Please check the data in column <b>Value</b> and resave.';
                case 'SELECT_EXTERNAL_TYPE':
                    return 'Data Error in <b>External ID</b> grid. Please check the data in column <b>External Type ID</b> and resave.';
                case 'SELECT_BANK_DETAIL':
                    return 'Please insert account no and currency';
                case 'VALIDATE_DESC':
                    return 'Description is empty.';
                case 'VALIDATE_GRID':
                    return 'Please insert some missing values in grid.';
                case 'SELECT_BROKER_CONTRACT':
                    return 'Broker contract cannot be empty.'
                case 'SELECT_DATE':
                    return 'Effective Date cannot be empty.'
                case 'VALIDATE_BROKER':
                    return 'Effective Date and Broker Contract can only exist for one broker fee.';
                case 'SELECT_PRODUCT':
                    return 'Product cannot be empty.'
                case 'VALIDATE_CERTIFICATE_NAME':
                    return '<b>Certificate</b> cannot be empty.'
                case 'VALIDATE_DATE_RANGE':
                    return '<b>Expiration Date</b> should be greater than <b>Effective Date</b>.'                    
                
            }
        }
        /*
         * Refresh all grids at once.
         */
        setup_counterparty.refresh_all = function(result) {
            if (result == undefined) 
                error_code = 'Success';
            else
                error_code = result[0]['errorcode'];
            
            if (error_code == 'Success') {
                var tab_id = setup_counterparty.tabbar.getActiveTab();
                var counterparty_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
                update_document_counter(object_id, toolbar_object);
                var i = 0;
                var ids = setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].getAllTabs();
    
                setup_counterparty.details_tabs["detail_tab_b_" + counterparty_id].forEachTab(function(tab) {
                    var tab_id = tab.getId();
                    var tab_text = tab.getText();
                    var win_type = (tab_text == bank_information) ? 'b' : (tab_text == contracts_val) ? 'c' : (tab_text == meter_val) ? 'm' : (tab_text == contacts_val) ? 'ct' : 'e';
                    var menu_index = "grid_menu_" + counterparty_id + "_" + tab_id;
                    sql_stmt[tab_text] = grid_definition_json[i]["sql_stmt"];
                    grid_type[tab_text] = grid_definition_json[i]["grid_type"];
                    var grid_name = grid_definition_json[i]["grid_name"];
                    var grid_index = "grid_" + counterparty_id + "_" + grid_name;
                    if (tab_text == approved_counterparty)
                        setup_counterparty.refresh_approved_counterparty(setup_counterparty.grids[grid_index], counterparty_id);
                    else if(tab_text == contracts_val) {
                        setup_counterparty.refresh_contracts(setup_counterparty.grids[grid_index], counterparty_id);
                    }
                    else
                        setup_counterparty.refresh_grids(sql_stmt[tab_text], setup_counterparty.grids[grid_index], grid_type[tab_text], counterparty_id);
                    
                    i++;
                });
            }
        }
        /*
         *
         * @returns {Boolean} Delete tree
         * 
         */
        setup_counterparty.delete_tree = function() {
            var selectedId = setup_counterparty.grid.getSelectedRowId();
            var count = selectedId.indexOf(",") > -1 ? selectedId.split(",").length : 1;
            selectedId = selectedId.indexOf(",") > -1 ? selectedId.split(",") : [selectedId];
            var cpty_id_index = setup_counterparty.grid.getColIndexById('source_counterparty_id');
            var id = '';

            if (selectedId == 'NULL') {
                var message = 'Please select data first.';
                show_messagebox(message);
                return false;
            }

            for ( var i = 0; i < count; i++) {
                var cpty_val = setup_counterparty.grid.cells(selectedId[i], cpty_id_index).getValue();
                if (cpty_val != '') {
                    id += setup_counterparty.grid.cells(selectedId[i], cpty_id_index).getValue();
                    id += ',';
                }
            }
            id = id.slice(0, -1);

            data = {"action": "spa_source_counterparty_maintain",
                "flag": "d",
                "source_counterparty_id": id
            };

            adiha_post_data('confirm', data, '', '', 'setup_counterparty.success_delete_contract');
            // console.log(data);
        }
        /*
         * Delete tree callback
         * 
         */
        setup_counterparty.success_delete_contract = function(result) {
            if (result[0].errorcode == 'Success') {
            var selectedId = setup_counterparty.grid.getSelectedRowId(); 
                if (selectedId.indexOf(",") > -1) { 
                    var ids = selectedId.split(",");
                    var count_ids = ids.length;
                    for (var i = 0; i < count_ids; i++ ) {
                        full_id = 'tab_' + ids[i];
                        if (setup_counterparty.pages[full_id]) {
                            setup_counterparty.tabbar.cells(full_id).close();
                        }
                    }
                } else {
                    if (setup_counterparty.grid.isTreeGrid()) {
                        var cell = setup_counterparty.grid.findCell(selectedId);
                        if (cell.length > 0) {
                            selectedId = cell[0][0];
                        }
                    }
                    var source_cpty_idx = setup_counterparty.grid.getColIndexById("source_counterparty_id");
                    var source_cpty = setup_counterparty.grid.cells(selectedId, source_cpty_idx).getValue();
                    setup_counterparty.grid.deleteRow(selectedId);
                    //close the tab if the contract is deleted from the grid.
                    var ids = setup_counterparty.tabbar.getAllTabs();
                
                    if (ids) {
                        setup_counterparty.tabbar.forEachTab(function(tab) {
                            var id = tab.getId();
                            var object_id = (id.indexOf("tab_") != -1) ? id.replace("tab_", "") : id;
        
                            if (object_id == source_cpty)
                                setup_counterparty.tabbar.tabs(id).close();
                        });
                    }
                }
                setup_counterparty.refresh_grid(); 
                setup_counterparty.menu.setItemDisabled('delete');
                setup_counterparty.menu.setItemDisabled('workflow_status');
            }
        }
     
        function maximize_minimize_window(param) {
            if (param)
                new_win.maximize();
            else
                new_win.minimize();
        }
        
        setup_counterparty.refresh_approved_counterparty = function(grid_obj, counterparty_id) {
            var sql_param = {
                "sql": "EXEC spa_approved_counterparty 's', @counterparty_id=" + counterparty_id,
                "grid_type": 'tg',
                "grouping_column":'counterparty_name,product_string'
            };
            
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            grid_obj.clearAll();
            grid_obj.load(sql_url, function(){
                grid_obj.filterByAll();
            });
        }
        
        setup_counterparty.refresh_contracts = function(grid_obj, counterparty_id) {
            var sql_param = {
                "sql": "EXEC spa_counterparty_contract_address 'm', @counterparty_id=" + counterparty_id,
                "grid_type": 'tg',
                "grouping_type":5,
                "grouping_column":'internal_counterparty,contract_name'
            };
            
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param; 
            grid_obj.clearAll();
            grid_obj.load(sql_url, function(){
                grid_obj.filterByAll();
            });
        }
        
        open_credit_file = function(name, value) {
            return '<a href="#" id= "credit_file_open" onclick="open_credit_file_win(id)">Credit File</a>';
        }
        
        open_credit_file_win = function(id) {
            var tab_id = setup_counterparty.tabbar.getActiveTab();
            var counterparty_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            
            var open_credit_file_popup = new dhtmlXPopup();
            win_text = 'Credit Info';
            param = '../../_credit_risks_analysis/counterparty_credit_info/counterparty.credit.info.php?counterparty_id=' + counterparty_id;
            width = 380;
            height = 350;
            if (!popup_window) {
                popup_window = new dhtmlXWindows();
            }
            var new_win = popup_window.createWindow('w9', 0, 0, width, height);
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.setText(win_text);
            new_win.maximize();
            new_win.attachURL(param, false, true);
        }
        
        load_workflow_status = function() {
            // setup_counterparty.menu.removeItem('pivot');
            setup_counterparty.menu.addNewSibling('process', 'reports', 'Reports', false, 'report.gif', 'report_dis.gif');
            setup_counterparty.menu.addNewChild('reports', '0', 'workflow_status', 'Workflow Status', true, 'report.gif', 'report_dis.gif');
            setup_counterparty.menu.addNewChild('reports', '1', 'dashboard_report', 'Dashboard Report', true, 'report.gif', 'report_dis.gif');
            setup_counterparty.menu.addNewChild('reports', '2', 'report_manager', 'Report Manager', true, 'report.gif', 'report_dis.gif');
            setup_counterparty.menu.addNewChild('reports', '3', 'pivot_c', 'Pivot', false, 'pivot.gif', 'pivot_dis.gif');

            setup_counterparty.grid.attachEvent("onRowSelect",function(rowId,cellIndex){
                setup_counterparty.menu.setItemEnabled('workflow_status');
            });
			
			setup_counterparty.grid.attachEvent("onSelectStateChanged",function(rowId,cellIndex){
				if (rowId != null) {					
					if (rowId.indexOf(",") == -1) setup_counterparty.menu.setItemEnabled('dashboard_report');
                    if (rowId.indexOf(",") == -1) setup_counterparty.menu.setItemEnabled('report_manager');
				}
			});
			
			load_report_menu('setup_counterparty.menu', 'dashboard_report', 1, -104701)
            load_report_menu('setup_counterparty.menu', 'report_manager', 2, -104701)

            setup_counterparty.menu.attachEvent("onClick", function(id, zoneId, cas){
                if(id == 'workflow_status') {
                    var selected_ids = setup_counterparty.grid.getColumnValues(1);
                    var workflow_report = new dhtmlXWindows();
                    workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
                    workflow_report_win.setText("Workflow Status");
                    workflow_report_win.centerOnScreen();
                    workflow_report_win.setModal(true);
                    workflow_report_win.maximize();
                    
                    var filter_string = 'Counterparty ID = <i>' + setup_counterparty.grid.getColumnValues(1) +  '</i>,  Counterparty = <i>' + setup_counterparty.grid.getColumnValues(0) + '</i>';
                    var process_table_xml = 'source_counterparty_id:' + selected_ids;
                    var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + selected_ids + '&source_column=source_counterparty_id&module_id=20602&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
                    workflow_report_win.attachURL(page_url, false, null);
                } else if(id == 'pivot_c') {
                    var filter_param = setup_counterparty.get_filter_parameters();
                    var pivot_exec_spa = "EXEC spa_source_counterparty_maintain 'g', NULL, NULL";
                    pivot_exec_spa += ", @xml='" + filter_param + "'"

                    open_grid_pivot('', 'grid_setup_counterparty', 1, pivot_exec_spa, 'Setup Counterparty');
                } else if (id.indexOf("dashboard_") != -1 && id != 'dashboard_report') {
					var str_len = id.length;
				    var dashboard_id = id.substring(17, str_len);
				    var dashboard_name = setup_counterparty.menu.getItemText(id);
                    var selected_ids = setup_counterparty.grid.getColumnValues(1);
                    var param_filter_xml = '<Root><FormXML param_name="source_counterparty_id" param_value="' + selected_ids + '"></FormXML></Root>';
				    
                    show_dashboard_report(dashboard_id, dashboard_name, param_filter_xml)
				} else if (id.indexOf("report_manager_") != -1 && id != 'report_manager') {
					var str_len = id.length;
				    var report_param_id = id.substring(15, str_len);
                    var selected_cpty_ids = setup_counterparty.grid.getColumnValues(1);
                    var param_filter_xml = '<Root><FormXML param_name="source_id" param_value="' + selected_cpty_ids + '"></FormXML></Root>';
			        
                    show_view_report(report_param_id, param_filter_xml, -104701)
                } 
            });
        }
        
        setup_counterparty.refresh_grid = function(sp_url, callback_function, filter_param,counterparty_id) { 
             if (sp_url == "" || sp_url == undefined) { 

                if(!counterparty_id) {
                    counterparty_id = null
                }

                var sql_param = {
                    "sql":"EXEC spa_source_counterparty_maintain 'g', " + counterparty_id + ", NULL",
                    "grid_type":"tg",
                    "grouping_type":5,
                    "grouping_column":"parent_counterparty_id,counterparty_name"
                    };
             } else { 
                    sql_param = sp_url; 
             };  
             if (filter_param != "" && filter_param != undefined) { 
                   var modified_sql = sql_param["sql"];
                                                modified_sql += ", @xml='" + filter_param + "'"
                                                sql_param["sql"] = modified_sql; 
             } 
             sql_param = $.param(sql_param);
             var sql_url = js_data_collector_url + "&" + sql_param;
             var grid_id = setup_counterparty.grid.getUserData("", "grid_id");
             var grid_obj = setup_counterparty.grid.getUserData("", "grid_obj");
             var grid_label = setup_counterparty.grid.getUserData("", "grid_label");
            setup_counterparty.grid.clearAll();
             if(grid_id != null) {
            setup_counterparty.grid.setUserData("", "grid_id", grid_id);
            setup_counterparty.grid.setUserData("", "grid_obj", grid_obj);
            setup_counterparty.grid.setUserData("", "grid_label", grid_label);
             }
                if (callback_function != "" && callback_function != undefined) {    
            setup_counterparty.grid.load(sql_url, function() {
            setup_counterparty.grid.filterByAll();
                    eval(callback_function ());
                   });
                } else {
            setup_counterparty.grid.load(sql_url, function(){
            setup_counterparty.grid.filterByAll();
                   });
                }
        }
        
		setup_counterparty.alert_reminders = function(object_id) {
			var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            param = '../../_compliance_management/setup_alerts/setup.alerts.reminder.php?module_id=20602&source_id=' + object_id;
            var is_win = dhxWins.isWindow('w11');
            if (is_win == true) {
                w11.close();
            }
            w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
            w11.setText("Alerts");
            w11.setModal(true);
            w11.maximize();
            w11.attachURL(param, false, true);
		}
		
   </script>     
</html>