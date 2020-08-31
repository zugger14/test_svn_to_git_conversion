<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
    <?php
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $module_type = '';//"15500"; //Fas (module type)
    list($default_as_of_date_to, $default_as_of_date_from) = getDefaultAsOfDate($module_type);
    
    $rights_reclasify_dedesignation = 10234000;
    $rights_reclasify_dedesignation_iu = 10234011;
    $rights_reclasify_dedesignation_delete = 10234010;
    // $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_reclasify_dedesignation . ", @template_name='ReclassifyHedgeDedesignation', @group_name='General,Detail'";
//    $return_value1 = readXMLURL($xml_file);
//    $form_json = $return_value1[0][2];
//    $grid_json = json_decode($return_value1[1][4], true);
    
    list (
        $has_rights_reclasify_dedesignation,
        $has_rights_reclasify_dedesignation_iu,
        $has_rights_reclasify_dedesignation_delete
    ) = build_security_rights(
        $rights_reclasify_dedesignation,
        $rights_reclasify_dedesignation_iu,
        $rights_reclasify_dedesignation_delete
    );
    
    $namespace = 'ns_reclassify_dedesignation';
    $layout = new AdihaLayout();
    //JSON for Layout
    $main_layout_json = '[
                        {
                            id:             "a",
                            width:          300,
                            text:           "Portfolio Hierarchy",
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            text:           "btn",
                            header:         false,
                            fix_size:       [false,null]
                        }
                        
                    ]';
                        
    
    $main_layout_name = 'layout_reclassify_dedesignation';
    echo $layout->init_layout($main_layout_name,'', '2U',$main_layout_json, $namespace);
    
    //Attaching Book Structue cell a
    $tree_structure = new AdihaBookStructure($rights_reclasify_dedesignation);
    $tree_name = 'tree_portfolio_hierarchy';
    echo $layout->attach_tree_cell($tree_name, 'a');
    echo $tree_structure->init_by_attach($tree_name, $namespace);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(0);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_bookstructure_events();
    echo $tree_structure->expand_level(0);
    echo $tree_structure->enable_three_state_checkbox();
    echo $tree_structure->load_tree_functons();
    echo $tree_structure->attach_search_filter('ns_reclassify_dedesignation.layout_reclassify_dedesignation', 'a');
    
    //Attach cell layout
    
    $right_layout_cell_json = '[
                            {
                                id:             "a",
                                text:           "Apply Filters",
                                height:         80,
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            },
                            {
                                id:             "b",
                                text:           "Filter Criteria",
                                height:         100,
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            },
                            {
                                id:             "c",
                                header:         false,
                                text:           "Dedesignation Detail"                           
                            }
                        ]';
                        
    $right_layout_cell_name = 'detail_layout_reclassify_dedesignation';
    //Attach second layout in b cell
    echo $layout->attach_layout_cell($right_layout_cell_name,'b', '3E', $right_layout_cell_json);
    $layout_right = new AdihaLayout();
    //initial this new layout in namespace.
    echo $layout_right->init_by_attach($right_layout_cell_name, $namespace);
    
     //Attaching Filter form for grid
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_reclasify_dedesignation . ", @template_name='ReclassifyHedgeDedesignation', @group_name='General,Detail'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    $grid_json = json_decode($return_value1[1][4], true);
    
    //attach toolbar
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar';
    $toolbar_json = "[
                        { id: 'reclassify', type: 'button', img: 'reclassify.gif', imgdis:'reclassify_dis.gif', text: 'Reclassify', title: 'Reclassify', enabled:false}
                    ]";
    echo $layout_right->attach_toolbar($toolbar_name, 'b');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.reclassify_link');
    
    //attach filter form
    $form_obj = new AdihaForm();
    $form_name = 'frm_reclassify_dedesignation';
    echo $layout_right->attach_form($form_name, 'b');    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    
    //Attaching menus in cell c and d at right layout.
    $menu_obj = new AdihaMenu();
    $menu_json = '[
                    { id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id:"t2", text:"Edit", img:"process.gif", items:[
                                { id: "delete", img: "undo.gif", imgdis: "undo_dis.gif", text: "Revert", title: "Revert", enabled:false}
                            ]
                    },
                    {id:"t3", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:"true"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:"true"}
                            ]
                    }
                    
                  ]';    
    
    //attach hedge menu cell at right layout
    $menu_name = 'grid_menu';
    echo $layout_right->attach_menu_cell($menu_name, 'c');    
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', 'onclick_menu');
    
    //Attach grid
    $xml_file = "EXEC spa_adiha_grid 's', '" . $grid_json['grid_id'] . "'";
    $return_value = readXMLURL2($xml_file);
    $grid_json_definition_outst = json_encode($return_value);
    
    $grid_obj = new AdihaGrid();
    $grid_name = 'grid_reclassify_dedesignation';
    echo $layout_right->attach_grid_cell($grid_name, 'c');
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($return_value[0]['column_label_list']);
    echo $grid_obj->set_columns_ids($return_value[0]['column_name_list']);
    echo $grid_obj->set_widths($return_value[0]['column_width']);
    //echo $grid_obj->split_grid(3); 
    echo $grid_obj->set_column_types($return_value[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($return_value[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($return_value[0]['set_visibility']);
    //echo $grid_obj->set_search_filter('true');
    echo $grid_obj->enable_multi_select();
    //echo $grid_obj->enable_paging(25, 'pagingArea_a'); 
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_functions();
    echo $grid_obj->attach_event('', 'onRowSelect', 'set_privileges');
    
    //This should be loaded at end
    echo $layout->close_layout();
    
    ?>
</body>
<script>
    var function_id = '<?php echo $rights_reclasify_dedesignation; ?>';
    var has_rights_reclasify_dedesignation_iu = Boolean(<?php echo $has_rights_reclasify_dedesignation_iu; ?>);
    var has_rights_reclasify_dedesignation_delete = Boolean(<?php echo $has_rights_reclasify_dedesignation_delete; ?>);
   
    $(function() {
        filter_obj = ns_reclassify_dedesignation.detail_layout_reclassify_dedesignation.cells('a').attachForm();
        var layout_cell_obj = ns_reclassify_dedesignation.detail_layout_reclassify_dedesignation.cells('b');        
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', ns_reclassify_dedesignation);   
        form_obj = 'ns_reclassify_dedesignation.frm_reclassify_dedesignation';
        attach_browse_event(form_obj,function_id)
        //set default values
        ns_reclassify_dedesignation.frm_reclassify_dedesignation.setItemValue('dedesignation_date_from', '<?php echo $default_as_of_date_from; ?>');
        ns_reclassify_dedesignation.frm_reclassify_dedesignation.setItemValue('dedesignation_date_to', '<?php echo $default_as_of_date_to; ?>');
             
    });
            
    function onclick_menu(id) {
        switch(id) {
            case "refresh": 
                ns_reclassify_dedesignation.refresh();
                break;
            case "excel":
                ns_reclassify_dedesignation.grid_reclassify_dedesignation.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                ns_reclassify_dedesignation.grid_reclassify_dedesignation.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "reclassify":
                ns_reclassify_dedesignation.reclassify();
                break;
			case "delete":
                ns_reclassify_dedesignation.revert_reclassification();
                break;
            
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert",
                    text:"Function is not defined."
                });
                break;
        }
    }
        
    ns_reclassify_dedesignation.refresh = function() {
        var form_obj = ns_reclassify_dedesignation.frm_reclassify_dedesignation;
        var validation_flag = 0;
        var status = validate_form(form_obj);
        var dedesignation_date_from = form_obj.getItemValue('dedesignation_date_from', true);
        var dedesignation_date_to = form_obj.getItemValue('dedesignation_date_to', true);
        var book_entity_id = ns_reclassify_dedesignation.get_book();
        var err_msg = '';
        
        if (status) {
            if (dedesignation_date_from > dedesignation_date_to) {    
                err_msg = 'Date From should be greater than Date To.';
                validation_flag = 1;
            } else if (book_entity_id == '') {    
                err_msg = 'Please select a Book.';
                validation_flag = 1;                
            }
        }
        
        if (validation_flag == 1) {
            if (err_msg != '') {
                dhtmlx.alert({
                        title: 'Alert',
                        type: 'alert',
                        text: err_msg
                    });
            }
            return;
        }
        
        var sql_param = {
                'action': 'spa_get_locked_values',
                'flag': 's',
                'fas_book_id': book_entity_id,
                'dedesignation_date_from': dedesignation_date_from,
                'dedesignation_date_to': dedesignation_date_to,           
                'grid_type': 'g'
            };
        
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        
        ns_reclassify_dedesignation.grid_reclassify_dedesignation.clearAll();
        ns_reclassify_dedesignation.grid_reclassify_dedesignation.load(sql_url); 
        ns_reclassify_dedesignation.grid_menu.setItemDisabled('delete');  
        ns_reclassify_dedesignation.toolbar.disableItem('reclassify');        
    }
        
    var new_win;
    /* Start popupcode */
    var json_as_of_date =   [  
                    {  
                      "type":"settings",
                      "position":"label-top"
                    },
                    {  
                      type:"block",
                      blockOffset:10,      
                      
                      list:[  
                         {  
                            "type":"calendar",
                            "name":"as_of_date",
                            "label":"As of Date",
                            "validate": "NotEmptywithSpace",
                            "position":"label-top",
                            "offsetLeft":"5",
                            "labelWidth":"130",
                            "inputWidth":"120",
                            "value": '<?php echo $default_as_of_date_to; ?>',
                            "tooltip":"",
                            "required": "true",
                            "dateFormat": '<?php echo $date_format; ?>',
                            "serverDateFormat": "%Y-%m-%d",
                            "calendarPosition": "bottom"
                         },
                        {type: "button", value: "Ok", img: "tick.png"}
                      ]
                    }
                ];
                
    var as_of_date_popup = new dhtmlXPopup();            
    var as_of_date_popup_form_obj = as_of_date_popup.attachForm(json_as_of_date);
    as_of_date_popup_form_obj.attachEvent("onButtonClick", function(){        
        proceed_reclassification();
        toggle_as_of_date_popup();
    });    
    
    ns_reclassify_dedesignation.reclassify_link = function() {
      toggle_as_of_date_popup();
    }    
    
    
    function adjustpopupHeight(width){
        var a = ns_reclassify_dedesignation.layout_reclassify_dedesignation.cells('a').getWidth();
        var b = 0;//ns_reclassify_dedesignation.detail_layout_reclassify_dedesignation.cells('b').getHeight();    
           
        //var height = a + b + 80;
        var height = 25;
        width = 10;
        as_of_date_popup.show(240, height, width,1);         
    }
    
    function toggle_as_of_date_popup () {
        
        if (as_of_date_popup.isVisible()) {
            as_of_date_popup.hide();
        } else {
            adjustpopupHeight(80);           
        }
    }
    
    function hide_as_of_date_popup() {
        as_of_date_popup.hide();
    }
    
    function proceed_reclassification(){ 
        var reclassify_date = as_of_date_popup_form_obj.getItemValue('as_of_date',true);  
        var form_obj = ns_reclassify_dedesignation.filter_form;
        var fas_book_id = get_selected_ids(ns_reclassify_dedesignation.grid_reclassify_dedesignation, 'fas_book_id');        
        var link_id = get_selected_ids(ns_reclassify_dedesignation.grid_reclassify_dedesignation, 'link_id');
        link_id = link_id.substring(link_id.indexOf('<l>')+3,link_id.lastIndexOf('<l>'));//Selected link ID only from hyperlink
        var book_deal_type_map_id = get_selected_ids(ns_reclassify_dedesignation.grid_reclassify_dedesignation, 'book_deal_type_map_id');        
        //alert(fas_book_id + ' ' + link_id + ' ' + reclassify_date + ' ' + book_deal_type_map_id)
        //return;
        data = {
                "action": "spa_get_locked_values",
                "flag": "u",
                "fas_book_id": fas_book_id,
                "link_id": link_id,
                "reclassify_date": reclassify_date,
                "book_deal_type_map_id": book_deal_type_map_id
            } 
                        
        adiha_post_data('return_array', data, '','', 'post_reclassification'); 
             
    }
    
    function post_reclassification(result) {
        ns_reclassify_dedesignation.refresh();
        dhtmlx.message(result[0][4]);        
    }
    
    /* -- reclassify_link ends ----------- */
    ns_reclassify_dedesignation.revert_reclassification = function() {
        var link_id = get_selected_ids(ns_reclassify_dedesignation.grid_reclassify_dedesignation, 'link_id');
        var book_deal_type_map_id = get_selected_ids(ns_reclassify_dedesignation.grid_reclassify_dedesignation, 'book_deal_type_map_id');
        var fas_book_id = get_selected_ids(ns_reclassify_dedesignation.grid_reclassify_dedesignation, 'fas_book_id');
        
        if (link_id != null) {
            link_id = link_id.substring(link_id.indexOf('<l>')+3,link_id.lastIndexOf('<l>'));//Selected link ID only from hyperlink
         	dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: "Are you sure you want to revert?",
                    callback: function(result) {    
                        if (result) {                            
                        data = {
                            "action": "spa_get_locked_values",
                            "flag": "d",
                            "link_id": link_id,
                            "book_deal_type_map_id": book_deal_type_map_id,
                            "fas_book_id": fas_book_id
                        }                                                    
                        adiha_post_data("return_array", data, "", "","post_delete_dedesignation");
                   }
                }
    		});
        }
    }
    
    function post_delete_dedesignation(result) {
        dhtmlx.message(result[0][4]);  
        ns_reclassify_dedesignation.refresh();
    }
    
    function get_selected_ids(grid_obj, column_name) {
        var rid = grid_obj.getSelectedRowId();
        if (rid == '' || rid == null) {
            //alert('Link id is null'); 
            return false;
        }
        var rid_array = new Array();
        if (rid.indexOf(",") != -1) {
            rid_array = rid.split(',');
        } else {
            rid_array.push(rid);
        }
        
        var cid = grid_obj.getColIndexById(column_name);
        var selected_ids = new Array();
        $.each(rid_array, function( index, value ) {
          selected_ids.push(grid_obj.cells(value,cid).getValue());
        });
        selected_ids = selected_ids.toString();
        return selected_ids;
    }
    
    function set_privileges() {
        var ids = ns_reclassify_dedesignation.grid_reclassify_dedesignation.getSelectedRowId();
        
        if (ids == null || ids.indexOf(',') != -1) {
            has_rights_reclassify = false;
            has_rights_revert_reclassification = false;
        } else {
           var status = get_selected_ids(ns_reclassify_dedesignation.grid_reclassify_dedesignation, 'reclassify_date');
           if (status == '' || status == null) {
                has_rights_reclassify = has_rights_reclasify_dedesignation_iu;
                has_rights_revert_reclassification = false;
           }  else {
                has_rights_reclassify = false;
                has_rights_revert_reclassification = has_rights_reclasify_dedesignation_delete; 
           }         
        }
        
        if (has_rights_reclassify) {
            ns_reclassify_dedesignation.toolbar.enableItem('reclassify'); 
        } else {
            ns_reclassify_dedesignation.toolbar.disableItem('reclassify'); 
        }
        if (has_rights_revert_reclassification) {
            ns_reclassify_dedesignation.grid_menu.setItemEnabled('delete');
        } else {
            ns_reclassify_dedesignation.grid_menu.setItemDisabled('delete');
        }
        
    }
    
</script>
</html>