<?php
/**
* Maintain limits screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
</head>
<body>
    <?php
    $namespace = 'maintain_limits';
    $function_id = 10181300;
    $grid_name = 'limit_header';
    $form_obj = new AdihaStandardForm($namespace, $function_id);
    $form_obj->define_grid($grid_name);
    $form_obj->enable_multiple_select();
    $form_obj->define_custom_functions('save_data', 'load_form', 'delete_data');

    echo $form_obj->init_form('Limits', 'Maintain Limits');
    echo $form_obj->close_form();

    $rights_setup_limits_iu = 10181310;
    $rights_setup_limits_del = 10181315;
    $rights_setup_limits_limit_iu = 10181316;
    $rights_setup_limits_limit_del = 10181317;

    list (
        $has_rights_setup_limits_iu,
        $has_rights_setup_limits_del,
        $has_rights_setup_limits_limit_iu,
        $has_rights_setup_limits_limit_del
    ) = build_security_rights(
        $rights_setup_limits_iu,
        $rights_setup_limits_del,
        $rights_setup_limits_limit_iu,
        $rights_setup_limits_limit_del
    );    
    ?>
    <div id="parentObj"></div>
</body>
<script>
    var limit_for_id;
    var deal_cell_win, deal_win, tabbar_obj, general_form_obj;
    var dhx_document, pop_win;
    var php_script_loc = "<?php echo $app_php_script_loc; ?>";
    var has_rights_setup_limits_iu = Boolean('<?php echo $has_rights_setup_limits_iu;?>');
    var has_rights_setup_limits_del = Boolean('<?php echo $has_rights_setup_limits_del;?>');
    var has_rights_setup_limits_limit_iu = Boolean('<?php echo $has_rights_setup_limits_limit_iu;?>');
    var has_rights_setup_limits_limit_del = Boolean('<?php echo $has_rights_setup_limits_limit_del;?>');
    var mapping_source_value_id = 23200;
    var template_name = "MaintainLimits";
    var function_id = <?php echo $function_id;?>;
    var theme_selected = default_theme;
    var curve_source_id = 4500;
    
    $(function() {
        maintain_limits.layout.cells('a').setWidth(305);
        maintain_limits.grid.attachEvent("onRowSelect", function(id,ind) {    
            var tree_level = maintain_limits.grid.getLevel(id);
 
            if (has_rights_setup_limits_iu) {
                maintain_limits.menu.setItemEnabled('add');
            }
            
            if (tree_level == 1) {
                if (has_rights_setup_limits_del) {
                    maintain_limits.menu.setItemEnabled('delete');
                } else {
                    maintain_limits.menu.setItemDisabled('delete');
                }
            } else {
                maintain_limits.menu.setItemDisabled('delete');
            }
        });
        
        maintain_limits.menu.setItemDisabled('add');
    });

    maintain_limits.load_form = function(win, tab_id) {
        win.progressOff();
        var is_new = win.getText();
        var tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        
        maintain_limits["inner_tab_layout_" + tab_id] = win.attachLayout("1C");
        
        if (is_new == 'New') {
            //win.progressOff();
            id = '';
        } else {
            id = tab_id;
        }
        
        var xml = '<Root><PSRecordset id="' + id + '"></PSRecordset></Root>';
        data = {
              "action": "spa_create_application_ui_json",
              "flag": "j",
              "application_function_id": function_id,
              "template_name": template_name,
              "parse_xml": xml
        };
        adiha_post_data('return_array', data, '', '', 'maintain_limits.load_form_data', false);
    }
    /**
     *
     */
    maintain_limits.load_form_data = function(result) {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var limit_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var result_length = result.length;
        var tab_json = '';
        var selected_row = get_selected_limit_id_value();
 
        var commodity_required = false;
        var role_required = false;
        var trader_required = false;
		 var counterparty_required = false;
        var has_first_blank_commodity = false;
        var has_first_blank_role = false;
        var has_first_blank_trader = false;
		var has_first_blank_counterparty = false;
		var flag = (active_tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
		///*
        switch(selected_row) {
			 case '20204': //counterparty
                counterparty_required = true;
            break;
            case '20203': //commodity
                commodity_required = true;
            break;
            case '20201': //trader
                 trader_required = true;
            break;
            case '20202': //trading role
                trader_required = true;
                role_required = true;
            break;
            case '20200': //others
                has_first_blank_commodity = true;
                has_first_blank_role = true;
                has_first_blank_trader = true;
				has_first_blank_counterparty = true;
            break;
            default:
                 
            break;
        }
        //*/
 
        for (i = 0; i < result_length; i++) {
            if (i > 0) {
                tab_json = tab_json + ",";
            }
            tab_json = tab_json + (result[i][1]);
        }
        tab_json = '{tabs: [' + tab_json + ']}';
        maintain_limits["tabs_" + limit_id] = maintain_limits["inner_tab_layout_" + limit_id].cells("a").attachTabbar();
        maintain_limits["tabs_" + limit_id].loadStruct(tab_json);
        maintain_limits["tabs_" + limit_id].setTabsMode("bottom");
        tabbar_obj = maintain_limits["tabs_" + limit_id];

        var form_json = [
            {type:'input', label:'Name', name:'limit_name', width:'<?php echo $ui_settings['field_size'] ?>', position: 'label-top', required:true, userdata:{'validation_message':'Required Field'}, offsetLeft: '<?php echo $ui_settings['offset_left'] ?>'},
            {type:"newcolumn"},
            {type:'combo', label:'Limit For', name:'limit_for', disabled:false, width:'<?php echo $ui_settings['field_size'] ?>', position: 'label-top', required:true, offsetLeft:'<?php echo $ui_settings['offset_left'] ?>'},
            {type:'newcolumn'},
            {type:'combo', label:'Curve Source', name:'curve_source_id', width:'<?php echo $ui_settings['field_size'] ?>', position: 'label-top', offsetLeft:'<?php echo $ui_settings['offset_left'] ?>', required:true, userdata:{'validation_message':'Invalid Selection'}, filtering: true},
            {type:"newcolumn"},
            {type:'combo', label:'Commodity', name:'commodity', width:'<?php echo $ui_settings['field_size'] ?>', position: 'label-top', offsetLeft:'<?php echo $ui_settings['offset_left'] ?>', required:commodity_required, userdata:{'validation_message':'Invalid Selection'}, filtering: true},
            {type:"newcolumn"},
            {type:'combo', label:'Role', name:'role', width:'<?php echo $ui_settings['field_size'] ?>', position: 'label-top', offsetLeft: '<?php echo $ui_settings['offset_left'] ?>', required:role_required, userdata:{'validation_message':'Invalid Selection'}, filtering: true},
            {type:"newcolumn"},
            {type:'combo', label:'Trader', name:'trader_id', width:'<?php echo $ui_settings['field_size'] ?>', position: 'label-top', offsetLeft:'<?php echo $ui_settings['offset_left'] ?>', required:trader_required, userdata:{'validation_message':'Invalid Selection'}, filtering: true},
            {type:'input', name:'limit_id', value:'' + limit_id + '', hidden:true},
			{type:"newcolumn"},
            {type:'combo', label:'Counterparty', name:'counterparty_id', width:'<?php echo $ui_settings['field_size'] ?>', position: 'label-top', offsetLeft:'<?php echo $ui_settings['offset_left'] ?>', required:counterparty_required, userdata:{'validation_message':'Invalid Selection'}, filtering: true},
            {type:"newcolumn"},
            {type:'checkbox', label:'Active', name:'active', width:'<?php echo $ui_settings['field_size'] ?>', position: 'label-right', offsetLeft:'<?php echo $ui_settings['offset_left'] ?>', offsetTop:'30', checked:'true'}
        ];
        

        var i = 0;        
        var inner_tab_id = get_tab_id(0);
        
        maintain_limits["form_" + limit_id] = maintain_limits["tabs_" + limit_id].tabs(inner_tab_id).attachForm();
        maintain_limits['form_' + limit_id].loadStruct(get_form_json_locale(form_json));
        
        var row_value = get_selected_limit_id_value();

        switch(row_value) {
			case '20204':
                maintain_limits['form_' + limit_id].showItem('counterparty_id');
                maintain_limits['form_' + limit_id].hideItem('commodity');
                maintain_limits['form_' + limit_id].hideItem('trader_id');
                maintain_limits['form_' + limit_id].hideItem('role');
            break;
            case '20200':
                maintain_limits['form_' + limit_id].showItem('commodity');
                maintain_limits['form_' + limit_id].showItem('trader_id');
                maintain_limits['form_' + limit_id].showItem('role');
				maintain_limits['form_' + limit_id].hideItem('counterparty_id');
            break;
            case '20201':
                maintain_limits['form_' + limit_id].hideItem('commodity');
                maintain_limits['form_' + limit_id].showItem('trader_id');
                maintain_limits['form_' + limit_id].hideItem('role');
				maintain_limits['form_' + limit_id].hideItem('counterparty_id');
            break;
            case '20202':
                maintain_limits['form_' + limit_id].hideItem('commodity');
                maintain_limits['form_' + limit_id].hideItem('trader_id');
                maintain_limits['form_' + limit_id].showItem('role');
				maintain_limits['form_' + limit_id].hideItem('counterparty_id');
            break;
            case '20203':
                maintain_limits['form_' + limit_id].showItem('commodity');
                maintain_limits['form_' + limit_id].hideItem('trader_id');
                maintain_limits['form_' + limit_id].hideItem('role');
				maintain_limits['form_' + limit_id].hideItem('counterparty_id');
            break;
            default:
                //do nothing
            break;
        }
        var combo_limit_for = maintain_limits['form_' + limit_id].getCombo("limit_for");
        var combo_limit_for_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id":"20200"};
        
        var combo_curve_source = maintain_limits['form_' + limit_id].getCombo("curve_source_id");
        var combo_curve_source_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id":"10007"};

        var combo_commodity = maintain_limits['form_' + limit_id].getCombo("commodity");
        var combo_commodity_sql = {"action":"spa_source_commodity_maintain", "flag":"a"};

        var combo_trader = maintain_limits['form_' + limit_id].getCombo("trader_id");
        var combo_trader_sql = {"action":"spa_source_traders_maintain", "flag":"x"};

        var combo_role = maintain_limits['form_' + limit_id].getCombo("role");
        var combo_role_sql = {"action":"spa_application_security_role", "flag":"n"};
        
        var combo_counterparty = maintain_limits['form_' + limit_id].getCombo("counterparty_id");
        var combo_counterparty_sql = {"action":"spa_source_counterparty_maintain", "flag":"c", "is_active":"y"};
        
        if (commodity_required == false) {
            has_first_blank_commodity = true;   
        }
        if (role_required == false) {
            has_first_blank_role = true;   
        }
        if (counterparty_required == false) {
            has_first_blank_counterparty = true;   
        }

        if(flag == 'i'){
            load_combo(combo_limit_for, combo_limit_for_sql,row_value, "limit_for", true);
            load_combo(combo_curve_source, combo_curve_source_sql, 4500, '', true);
            load_combo(combo_commodity, combo_commodity_sql, '', '', 0, has_first_blank_commodity);
            load_combo(combo_trader, combo_trader_sql, '', '', 0, has_first_blank_trader);
            load_combo(combo_role, combo_role_sql, '', '', 0, has_first_blank_role);
            load_combo(combo_counterparty, combo_counterparty_sql, '', '', 0, has_first_blank_counterparty);
        }
        else if(flag == 'u') {
            var data =  {"sp_string": "EXEC spa_limit_header @flag = 'a', @limit_id = " + limit_id};
            adiha_post_data('return_array', data, '', '', function(result) {
                maintain_limits['form_' + limit_id].setItemValue('limit_name', result[0][1]);

                    load_combo(combo_limit_for, combo_limit_for_sql,result[0][2], "limit_for", 0,true);
                    load_combo(combo_curve_source, combo_curve_source_sql, result[0][6], '',0, true);
                    load_combo(combo_commodity, combo_commodity_sql, result[0][4], '', 0, has_first_blank_commodity);
                    load_combo(combo_trader, combo_trader_sql, result[0][3], '', 0, has_first_blank_trader);
                    load_combo(combo_role, combo_role_sql, result[0][5], '', 0, has_first_blank_role);
                    
                    var is_active = result[0][9];
                    if (is_active == 'y') {
                        maintain_limits['form_' + limit_id].checkItem('active');
                    } else {
                         maintain_limits['form_' + limit_id].uncheckItem('active');
                    }
					
                    load_combo(combo_counterparty, combo_counterparty_sql, result[0][8], '', '', has_first_blank_counterparty);
        
                    
            });
        }
 
        limit_id_1 = (flag == 'u') ? limit_id : null; 
        var sub_book_query = "EXEC spa_portfolio_group_book @flag = 'f', @mapping_source_usage_id = " + limit_id_1 + "," + "@mapping_source_value_id = 23200"; // sdv for limit
        var deal_query = "EXEC spa_portfolio_mapping_deal @flag='x', @mapping_source_usage_id=" + limit_id_1 + "," + "@mapping_source_value_id = 23200"; ;
        var filter_query =  "EXEC spa_portfolio_group_book @flag = 's', @mapping_source_usage_id = " + limit_id_1 + "," + "@mapping_source_value_id = 23200";

        var inner_tab_id = get_tab_id(1);
        maintain_limits["tabs_" + limit_id].tabs(inner_tab_id).attachURL("../run_at_risk/generic.portfolio.mapping.template.php", null, {sub_book: sub_book_query, deals: deal_query, book_filter: filter_query, func_id: function_id, is_tenor_enable: true, req_portfolio_group: true});
        
        if (active_tab_id.indexOf("tab_") != -1) {
            load_tabs(limit_id);    
        }
      
  
        var menu_json = [
                        {id:"edit", img:"edit.gif", imgdis:'edit_dis.gif', text:"Edit", items:[
                            {id:"add", img:"add.gif", imgdis:'add_dis.gif', text:"Add", title:"Add", enabled: has_rights_setup_limits_limit_iu},
                            {id:"delete", img:"delete.gif", imgdis:'delete_dis.gif', text:"Delete", title:"Delete", disabled:true}
                        ]},
                        {id:"export", img:"export.gif", imgdis:'export_dis.gif', text:"Export", items:[
                            {id:"pdf", img:"pdf.gif", imgdis:'pdf_dis.gif', text:"PDF", title:"PDF"},
                            {id:"excel", img:"excel.gif", imgdis:'excel_dis.gif', text:"Excel", title:"Excel"}
                        ]}
                        ];
        var inner_tab_id = get_tab_id(2);
        var menu_obj = maintain_limits["tabs_" + limit_id].tabs(inner_tab_id).attachMenu();
        menu_obj.setIconsPath(js_image_path + "dhxmenu_web/");
        menu_obj.loadStruct(menu_json);

        menu_obj.attachEvent("onClick", function(id){
            switch(id) {
                case 'add':
                    limit_detail(-1, 'i');
                break;
                case 'delete':
                    limit_delete();
                break;
                case 'pdf':
                    maintain_limits["grid_" + limit_id].toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
                case 'excel':
                    maintain_limits["grid_" + limit_id].toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
                default:
                    dhtmlx.alert({title: "Alert!", type: "alert", text: "Not implemented"});
                break;
            }
        });
        // --- End of Menu 

        //--attach status        
        maintain_limits["tabs_" + limit_id].tabs(inner_tab_id).attachStatusBar({
                            height: 30,
                            text: '<div id="pagingAreaGrid_b"></div>'
                        });

        // Grid --- 
        maintain_limits["grid_" + limit_id] = maintain_limits["tabs_" + limit_id].tabs(inner_tab_id).attachGrid();
        maintain_limits["grid_" + limit_id].setColumnIds("maintain_limit_id,limit_id,logical_description,limit_type,var_criteria_det_id,deal_type,curve_id,min_limit_value,limit_value,effective_date,limit_uom,limit_currency,tenor_month_from,tenor_month_to,tenor_granularity,is_active");
        maintain_limits["grid_" + limit_id].setHeader(get_locale_value("ID, Limit ID, Logical Description, Limit Type, At Risk Criteria, Deal Type, Index,Min Limit Value, Limit Value, Effective Date,Limit UOM, Limit Currency, Tenor From, Tenor To, Tenor Granularity, Active",true),null,["text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:right;","text-align:right;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;"]);
        maintain_limits["grid_" + limit_id].attachHeader('#numeric_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
        maintain_limits["grid_" + limit_id].setColSorting('int,int,str,str,str,str,str,int,int,str,str,str,int,int,str,str'); 
        maintain_limits["grid_" + limit_id].setColTypes("ro_int,ro_int,ro,ro,ro,ro,ro,ro_no,ro_no,ro,ro,ro,ro,ro,ro,ro");
        maintain_limits["grid_" + limit_id].setColAlign(',,,,,,,,,,right,right,,,,,');
        maintain_limits["grid_" + limit_id].setInitWidths('50,50,150,100,150,100,100,100,100,100,100,100,100,100,100,100');
        maintain_limits["grid_" + limit_id].enableColumnMove(true, "false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true");
        maintain_limits["grid_" + limit_id].setColumnsVisibility("true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false");
        maintain_limits["grid_" + limit_id].init();
        maintain_limits["grid_" + limit_id].enableMultiselect(true);
        maintain_limits["grid_" + limit_id].enableHeaderMenu();
        maintain_limits["grid_" + limit_id].enablePaging(true, 20, 0, 'pagingAreaGrid_b');
        maintain_limits["grid_" + limit_id].setPagingWTMode(true, true, true, true);
        maintain_limits["grid_" + limit_id].setPagingSkin('toolbar');
        //event for on row double click
        maintain_limits["grid_" + limit_id].attachEvent("onRowDblClicked",function(row_id){
            limit_detail(row_id, 'u');
        });
        //enable delete menu
        maintain_limits["grid_" + limit_id].attachEvent("onRowSelect",function(){
        if (has_rights_setup_limits_limit_del){   
			menu_obj.setItemEnabled('delete');
			}
        });
    }
    /**
     *
     */
    maintain_limits.save_data = function(tab_id) {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var limit_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        limit_id = ($.isNumeric(limit_id)) ? limit_id : ord(limit_id.replace(" ", ""));
        var mode = (active_tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
        var inner_tab_id = get_tab_id(0);
        var validation_status = true;        
        ///
        var detail_tabs, form_obj, att_tabbar_obj;
        form_obj = get_form_obj();
        var general_form_status = validate_form(form_obj,maintain_limits["tabs_" + limit_id].cells(inner_tab_id));
        if (general_form_status == false) {
            /*maintain_limits["tabs_" + limit_id].cells(inner_tab_id).setActive();*/
            generate_error_message(maintain_limits["tabs_" + limit_id].cells(inner_tab_id));
            validation_status = false;
        }
        
        if (mode == 'i') {
            limit_id = 'NULL';
        }

        var limit_name = form_obj.getItemValue('limit_name');
        form_obj.setUserData("", "limit_header_name", limit_name);
        var limit_for = form_obj.getItemValue('limit_for');
        form_obj.setUserData("", "limit_for", limit_for);
        limit_for_id = limit_for;

        var form_xml = '<Root function_id="' + function_id + '"><FormXML ';
        form_data_a = form_obj.getFormData();

        for (var a in form_data_a) {
            field_label = a;
            field_value = form_data_a[a];
			 if (limit_for == 20204) {
                if (field_label == 'commodity') {
                    field_value = '';
                }
                if (field_label == 'trader_id') {
                    field_value = '';
                }
                if (field_label == 'role') {
                    field_value = '';
                }
            }
            if (limit_for == 20203) {
                if (field_label == 'trader_id') {
                    field_value = '';
                }
                if (field_label == 'role') {
                    field_value = '';
                }
				if (field_label == 'counterparty_id') {
                    field_value = '';
                }
            }
            if (limit_for == 20201) {
                if (field_label == 'commodity') {
                    field_value = '';
                }
                if (field_label == 'role') {
                    field_value = '';
                }
				if (field_label == 'counterparty_id') {
                    field_value = '';
                }
            }
            if (limit_for == 20202) {
                if (field_label == 'commodity') {
                    field_value = '';
                }
                if (field_label == 'trader_id') {
                    field_value = '';
                }
				if (field_label == 'counterparty_id') {
                    field_value = '';
                }
            }
            form_xml += " " + field_label + "=\"" + field_value + "\"";    
        }
        form_xml += "></FormXML></Root>";
        
        var inner_tab_id = get_tab_id(1);
        var ifr = tabbar_obj.cells(inner_tab_id).getFrame();
        ifr.blur(); 
        var portfolio_xml = ifr.contentWindow.generic_portfolio.get_portfolio_form_data();

        //
        var deal_ifr = ifr.contentWindow.generic_portfolio.get_deal_frame();
        var del_flag = deal_ifr.contentWindow.deal_selection.grd_deal_selection.getUserData("", "deleted_xml");
        
        if (del_flag == 'deleted') {
            del_msg =  "Some data has been deleted from <b>Deals</b> grid. Are you sure you want to save?";
            dhtmlx.message({
                type: "confirm",
                title: "Warning",
                text: del_msg,
                callback: function(result) {
                    if (result) {
                        //in case of del_flag set and ok clicked
                        if(validation_status == true){
                            data = {"action": "spa_limit_header", 
                                    "flag": "" + mode + "",
                                    "form_xml": form_xml,
                                    "portfolio_xml" : portfolio_xml
                            };
                            adiha_post_data("alert", data, "", "", "post_callback");
                        }
                        deal_ifr.contentWindow.deal_selection.grd_deal_selection.setUserData("","deleted_xml", "");
                    }
                }
            });
        } else {
            //in case of no del_flag set
            if(validation_status == true && portfolio_xml != false){
                maintain_limits.tabbar.tabs(active_tab_id).getAttachedToolbar().disableItem('save');
                data = {"action": "spa_limit_header", 
                        "flag": "" + mode + "",
                        "form_xml": form_xml,
                        "portfolio_xml" : portfolio_xml
                };
                adiha_post_data("alert", data, "", "", "post_callback");
            }
        }
        //
    }
    /**
     *
     */
    function post_callback(result) {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var limit_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var tab_index = maintain_limits.tabbar.tabs(active_tab_id).getIndex();
        var limit_header_name = maintain_limits['form_' + limit_id].getUserData("", "limit_header_name");
        var col_type = maintain_limits.grid.getColType(0);
        if (has_rights_setup_limits_iu) {
            maintain_limits.tabbar.tabs(active_tab_id).getAttachedToolbar().enableItem('save');
        };

        if (col_type == "tree") {
           maintain_limits.grid.saveOpenStates();
        }

        if(result[0].errorcode == 'Success'){
            if (result[0].recommendation == '') {
                maintain_limits.refresh_grid("", maintain_limits.refresh_tab_properties);
            } else {
                tab_id = 'tab_' + result[0].recommendation;
                maintain_limits.refresh_grid("", refresh_grid_callback);
                maintain_limits.create_tab_custom(tab_id, limit_header_name, tab_index);
                maintain_limits.tabbar.tabs(active_tab_id).close(true);
            }
            
            maintain_limits.menu.setItemDisabled("delete");
            maintain_limits.menu.setItemDisabled("add");
        }
    }
    
    function refresh_grid_callback() {
        var col_type = maintain_limits.grid.getColType(0);
        var prev_id = maintain_limits.tabbar.getActiveTab();
        var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;
        if (col_type == "tree") {
            maintain_limits.grid.loadOpenStates();
            var primary_value = maintain_limits.grid.findCell(system_id, 1, true, true);
        } else {
            var primary_value = maintain_limits.grid.findCell(system_id, 0, true, true);
        }
        maintain_limits.grid.filterByAll(); 
        if (primary_value != "") {
            var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
            var tab_text = maintain_limits.get_text(maintain_limits.grid, r_id);
            maintain_limits.tabbar.tabs(prev_id).setText(tab_text);
            maintain_limits.grid.selectRowById(r_id,false,true,true);
        }
    }
    /**
     *
     */
    maintain_limits.create_tab_custom = function(full_id,text, tab_index) {
        var win = maintain_limits.pages[full_id];//tabbar.cells(full_id);
        if (!maintain_limits.pages[full_id]) {
            maintain_limits.tabbar.addTab(full_id, text, null, tab_index, true, true);
            var win = maintain_limits.tabbar.cells(full_id);
            win.progressOn();

            var toolbar = win.attachToolbar();
            toolbar.setIconsPath("<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/"+js_dhtmlx_theme +"/imgs/dhxtoolbar_web/");
            toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
            toolbar.attachEvent("onClick", function(){
                maintain_limits.save_data();
            });

            maintain_limits.tabbar.cells(full_id).setActive();
            maintain_limits.tabbar.cells(full_id).setText(text);
            maintain_limits.load_form(win, full_id);
            maintain_limits.pages[full_id] = win;
        } else {
            maintain_limits.tabbar.cells("'" + full_id + "'").setActive();
        }
    }
    /**
     *
     */
    maintain_limits.delete_data = function() {
        var limit_ids = [];
        var row_id = maintain_limits.grid.getSelectedRowId();
        row_id = row_id.split(',');

        row_id.forEach(function(val) {
            limit_ids.push(maintain_limits.grid.cells(val, 1).getValue());
        });

        limit_ids = limit_ids.toString();
        maintain_limits.grid.saveOpenStates();
        
        if(limit_ids != '0' && limit_ids != '') {
            var delete_sp_string = "EXEC spa_limit_header @flag='d', @del_limit_ids='" + limit_ids + "'";
            var data = {"sp_string": delete_sp_string};
            adiha_post_data('confirm', data, '', '', 'delete_callback', '');
        }
    }
    function delete_callback(result) {
        if (result[0].errorcode == 'Success') {
            var returned_del_ids = result[0].recommendation;
            returned_del_ids = returned_del_ids.split(',');
            returned_del_ids.forEach(function(val) {
                var tab_id = 'tab_' + val;
                if(maintain_limits.pages[tab_id]) {
                    maintain_limits.tabbar.tabs(tab_id).close(true);
                }
            });
            var row = maintain_limits.grid.getSelectedRowId();
            row = row.split(',');
            row.forEach(function(val) {
                maintain_limits.grid.deleteRow(val);
            });
            maintain_limits.grid.loadOpenStates();
            maintain_limits.menu.setItemDisabled("add");
            maintain_limits.menu.setItemDisabled("delete");
        }
    }
    /**
     *
     */
    maintain_limits.callback_select_deal = function(result) {
        deal_win.close();
        var ifr = deal_cell_win.cells('a').getFrame();
        ifr.contentWindow.deal_selection.callback_select_deal(result);
    }
    /**
     *
     */
    function load_tabs(limit_id) {
       
        // Limit Tab --- 
        var data =  {"sp_string": "EXEC spa_maintain_limit @flag = 't', @limit_id = " + limit_id};
        adiha_post_data('return_json', data, '', '', 'load_limit_tab_grid');
    }
    
    /**
     *
     */
    function load_limit_tab_grid(result) {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var limit_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        var json_obj = $.parseJSON(result);
        var json_data = {"total_count":json_obj.length, "pos":0, "data":json_obj};
        maintain_limits["grid_" + limit_id].parse(json_data, "js");
        /* Seems Already Attached Event
        maintain_limits["grid_" + limit_id].attachEvent("onRowSelect", function(id,ind){
            var menu_obj = maintain_limits["tabs_" + limit_id].cells("limit").getAttachedMenu();
            menu_obj.setItemEnabled('delete');
        });*/
    }

    function limit_delete() {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var limit_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        var active_grid_ids = '';
        var selected_row_id = '';
        var selected_row_array = '';
        var att_tabbar_obj = maintain_limits["grid_" + limit_id];
        
        selected_row_id = att_tabbar_obj.getSelectedRowId();
        if (selected_row_id.indexOf(',') != -1) {
            selected_row_array = selected_row_id.split(',');
        } else {
            selected_row_array = Array(selected_row_id);
        }
        for(var i = 0; i < selected_row_array.length; i++) {
           if (i == 0) {
                active_grid_ids = att_tabbar_obj.cells(selected_row_array[i], 0).getValue();
            } else {
                active_grid_ids = active_grid_ids + ',' + att_tabbar_obj.cells(selected_row_array[i], 0).getValue();
            }
        }
        
        dhtmlx.message({
            title:"Confirmation",
            type:"confirm",
            ok: "Confirm",
            text: 'Are you sure you want to delete?',
            callback: function(result) {
                if (result) {
                    var data =  {
                        "sp_string": "EXEC spa_maintain_limit @flag = 'r', @limit_id = " + limit_id + ", @active_grid_ids = '" + active_grid_ids + "'"
                    };
                    adiha_post_data('alert', data, '', '', 'limit_grid_refresh');
                    att_tabbar_obj.deleteRow(selected_row_id);
                    var menu_obj = maintain_limits["tabs_" + limit_id].cells("limit").getAttachedMenu();
                    menu_obj.setItemDisabled('delete');
                } else {
                    return;
                }
            }
        });
    }
    /**
     *
     */
    function limit_grid_refresh(){
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var limit_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        if (!dhx_document) {
            dhx_document = new dhtmlXWindows();
        }
        /*var is_win = dhx_document.isWindow('pop_win');
        if (is_win == true) {
            setTimeout(function(){
                pop_win.close();
            }, 100);
        }*/

        var param = {
                    "action": "spa_maintain_limit",
                    "flag": "t",
                    "limit_id":limit_id,
                    "grid_type": "g"
                };
                
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        maintain_limits["grid_" + limit_id].clearAndLoad(param_url);

        var inner_tab_id = get_tab_id(2);
        var menu_obj = maintain_limits["tabs_" + limit_id].cells(inner_tab_id).getAttachedMenu();
        menu_obj.setItemDisabled('delete');
    }

    function limit_detail(row_id, mode) {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var limit_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        if (active_tab_id.indexOf("tab_") == -1) {
            dhtmlx.alert({title: "Alert!", type: "alert", text: "Please insert <b>Limit Name</b> first."});
            return  false;
        }
        var title_text;
        var maintain_limit_id = '';
        if(mode == 'u') {
            title_text = 'Edit Limit';
            maintain_limit_id = maintain_limits["grid_" + limit_id].cells(row_id,0).getValue();
            limit_id = maintain_limits["grid_" + limit_id].cells(row_id,1).getValue();
        } else {
            title_text = 'Add Limit' ;
            mode = 'i';
        }
        var param = 'maintain.limits.add.edit.php?mode=' + mode +
                    '&limit_id=' + limit_id + 
                    '&maintain_limit_id=' + maintain_limit_id +
                    '&is_pop=true';

        if (!dhx_document) {
            dhx_document = new dhtmlXWindows();
        }

        pop_win = dhx_document.createWindow("pop_win", 0, 0, 830, 350);
        pop_win.centerOnScreen();
        pop_win.setText(title_text);
        pop_win.attachURL(param, false, true);
        pop_win.attachEvent('onClose', function() {
            return true;
        });
    }
    /**
     *
     */
    function load_combo(combo_obj, combo_sql, selected_value, disable_combo, selected_index, has_blank_option) {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var limit_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data + '&has_blank_option=' + has_blank_option;
        
        combo_obj.load(url, function() {
            if (selected_value != false) {
                var val_index = combo_obj.getIndexByValue(selected_value);
                combo_obj.selectOption(val_index);
            }
            else if (has_blank_option == false) {
                combo_obj.selectOption(selected_index);
            }
            if (disable_combo != false) {
                maintain_limits['form_' + limit_id].disableItem(disable_combo);
            }
            
        });
    }
            
    /**
     *
     */
    function get_selected_limit_id_value() {
        var tree_level, parent_id;
        var row_id = maintain_limits.grid.getSelectedRowId();

        if (row_id) {
            tree_level = maintain_limits.grid.getLevel(row_id);
            parent_id = maintain_limits.grid.getItemText(row_id);
        } else {
            tree_level = 0;
            parent_id = 0;
        }
                
        if (tree_level == 1) {
            value = maintain_limits.grid.cells(row_id, 2).getValue();
        } else {
            if (parent_id == 'Commodity') {
                value = '20203';
            } else if (parent_id == 'Counterparty') {
                value = '20204';
            } else if (parent_id == 'Trader') {
                value = '20201';
            } else if (parent_id == 'Others') {
                value = '20200';
            } else if (parent_id == 'Trading Role') {
                value = '20202';
            } else {
                value = limit_for_id;//'20202';
            }
        }   
        return value;
    }
    
    /**
     *
     */
    function get_form_obj() {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var detail_tabs, form_obj, att_tabbar_obj;
        maintain_limits.tabbar.forEachTab(function(tab){
            if (tab.getId() == active_tab_id) {
                var att_lay_obj = tab.getAttachedObject();
                att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                detail_tabs = att_tabbar_obj.getAllTabs();
            }
        });
        $.each(detail_tabs, function(index,value) {
            layout_obj = att_tabbar_obj.cells(value).getAttachedObject();
            
            if (layout_obj instanceof dhtmlXForm) {
                form_obj = layout_obj;
            };
        });
        return form_obj;
    }
    /**
     *
     */
    function get_tab_id(j) {
        var tab_id = [];
        var i = 0;
        var inner_tab_obj = get_inner_tab_obj();
        inner_tab_obj.forEachTab(function(tab){
            tab_id[i] = tab.getId();
            i++;
        });
        return tab_id[j];
    }
    /**
     *
     */
    function get_inner_tab_obj() {
        var active_tab_id = maintain_limits.tabbar.getActiveTab();
        var detail_tabs, att_tabbar_obj;
        maintain_limits.tabbar.forEachTab(function(tab){
            if (tab.getId() == active_tab_id) {
                var att_lay_obj = tab.getAttachedObject();
                att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                detail_tabs = att_tabbar_obj.getAllTabs();
            }
        });
        return att_tabbar_obj;
    }
    /**
     *
     */
    maintain_limits.refresh_tab_properties = function() {
        var col_type = maintain_limits.grid.getColType(0);
        var prev_id = maintain_limits.tabbar.getActiveTab();
        var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;
        if (col_type == "tree") {
            maintain_limits.grid.loadOpenStates();
            var primary_value = maintain_limits.grid.findCell(system_id, 1, true, true);
        } else {
            var primary_value = maintain_limits.grid.findCell(system_id, 0, true, true);
        }
        maintain_limits.grid.filterByAll(); 
        if (primary_value != "") {
            var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
            var tab_text = maintain_limits.get_text(maintain_limits.grid, r_id);
            maintain_limits.tabbar.tabs(prev_id).setText(tab_text);
            maintain_limits.grid.selectRowById(r_id,false,true,true);
        } 
        var win = maintain_limits.tabbar.cells(prev_id);
        var tab_obj = win.tabbar[system_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    attached_obj.clearSelection();
                    var grid_obj = attached_obj.getUserData("","grid_obj");
                    eval(grid_obj + ".refresh_grid()");
                }
            });
        });
    }
</script>