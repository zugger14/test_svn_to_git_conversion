<?php
/**
* Amortize locked aoci screen
* @copyright Pioneer Solutions
*/
?>

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
    $rights_amortize_locked_aoci = 10234100;
    $rights_amortize_locked_aoci_iu = 10234111;
    $rights_amortize_locked_aoci_delete = 10234110;

    list (
        $has_rights_amortize_locked_aoci,
        $has_rights_amortize_locked_aoci_iu,
        $has_rights_amortize_locked_aoci_delete
    ) = build_security_rights(
        $rights_amortize_locked_aoci,
        $rights_amortize_locked_aoci_iu,
        $rights_amortize_locked_aoci_delete
    );
    
    $namespace = 'ns_amortize_locked_aoci';
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
                        
    
    $main_layout_name = 'layout_amortize_locked_aoci';
    echo $layout->init_layout($main_layout_name,'', '2U',$main_layout_json, $namespace);
    
    //Attaching Book Structue cell a
    $tree_structure = new AdihaBookStructure($rights_amortize_locked_aoci);
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
    echo $tree_structure->attach_search_filter('ns_amortize_locked_aoci.layout_amortize_locked_aoci', 'a'); 
    
    //Attach cell layout
    
    $right_layout_cell_json = '[
                            {
                            id:             "a",
                            text:           "Apply Filters",
                            height:         80,
                            header:         true,
                            collapse:       true,
                            fix_size:       [false,null]
                            },
                            {
                                id:             "b",
                                text:           "Filters",
                                height:         150,
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            },
                            {
                                id:             "c",
                                header:         true,
                                text:           "Amortization Detail"                           
                            }
                        ]';
                        
    $right_layout_cell_name = 'detail_layout_amortize_locked_aoci';
    //Attach second layout in b cell
    echo $layout->attach_layout_cell($right_layout_cell_name,'b', '3E', $right_layout_cell_json);
    $layout_right = new AdihaLayout();
    //initial this new layout in namespace.
    echo $layout_right->init_by_attach($right_layout_cell_name, $namespace);
    
     //Attaching Filter form for grid
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_amortize_locked_aoci . ", @template_name='AmortizeLockedAOCI', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    $grid_json = json_decode($return_value1[0][4], true);
    
    //attach toolbar
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar';
    $toolbar_json = "[
                        { id: 'amortize', type: 'button', img: 'amortize.gif', imgdis:'amortize_dis.gif', text: 'Amortize', title: 'Amortize', enabled:false}
                    ]";
    echo $layout_right->attach_toolbar($toolbar_name, 'b');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.btn_amortize_click');
    
    //attach filter form
    $form_obj = new AdihaForm();
    $form_name = 'form_amortize_locked_aoci';
    echo $layout_right->attach_form($form_name, 'b');    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    
    //Attaching menus in cell c and d at right layout.
    $menu_obj = new AdihaMenu();
    $menu_json = '[
                    { id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id:"t2", text:"Edit", img:"process.gif", items:[
                                { id: "delete", img: "delete.gif", imgdis: "delete_dis.gif", text: "Delete", title: "Delete", enabled:false}
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
    
    $grid_obj = new AdihaGrid();
    $grid_name = 'grid_amortize_aoci';
    echo $layout_right->attach_grid_cell($grid_name, 'c');
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header('Seq id, Process ID, Error Description, As of Date, Link ID, Deal ID, Contract Month, AOCI, AOCI Amortized, Volume, Volume Amortized, Perc Amortized, Fully Amortized, Update By, Update TS, Selected');
    echo $grid_obj->set_columns_ids('seq_id,process_id,error_desc,as_of_date,rel_id,deal_id,con_month,aoci,aoci_amortized,volume,volume_amortized,perc_amortized,fully_amortized,update_by,update_ts,selected');
    echo $grid_obj->set_widths('150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150');
    echo $grid_obj->set_column_types('ro_int,ro,ro,ro,ro_int,ro_int,ro,ro_v,ro_v,ro_v,ro_v,ro_v,ro,ro,ro,ro');
    echo $grid_obj->set_sorting_preference('int,str,str,str,int,int,str,int,int,int,int,int,str,str,str,str');    
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility('true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,true');    
    //echo $grid_obj->set_search_filter('true');
    //echo $grid_obj->enable_multi_select();
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_functions();
    echo $grid_obj->attach_event('', 'onRowSelect', 'set_privileges');
    echo $layout->close_layout();
    ?>
</body>
<script>
    var function_id = '<?php echo $rights_amortize_locked_aoci; ?>';
    var has_rights_amortize_locked_aoci_iu = Boolean(<?php echo $has_rights_amortize_locked_aoci_iu; ?>);
    var has_rights_amortize_locked_aoci_delete = Boolean(<?php echo $has_rights_amortize_locked_aoci_delete; ?>);
    var volume_reclassify_mode = 'n';
    
    $(function() {
        filter_obj = ns_amortize_locked_aoci.detail_layout_amortize_locked_aoci.cells('a').attachForm();
        var layout_cell_obj = ns_amortize_locked_aoci.detail_layout_amortize_locked_aoci.cells('b');        
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', ns_amortize_locked_aoci);   
        form_obj = 'ns_amortize_locked_aoci.form_amortize_locked_aoci';
        attach_browse_event(form_obj,function_id);
        var filter_form_obj = ns_amortize_locked_aoci.detail_layout_amortize_locked_aoci.cells('b').getAttachedObject();
        filter_form_obj.attachEvent('onChange', function(name, value, is_checked){
            if (name == 'chk_prior_value'){
                if (is_checked){
                    ns_amortize_locked_aoci.form_amortize_locked_aoci.hideItem('total_monthly_volume');
                    ns_amortize_locked_aoci.form_amortize_locked_aoci.hideItem('volume_uom');
                } else {
                    ns_amortize_locked_aoci.form_amortize_locked_aoci.showItem('total_monthly_volume');
                    ns_amortize_locked_aoci.form_amortize_locked_aoci.showItem('volume_uom');
                }
            }
        });
             
    });
            
    function onclick_menu(id) {
        switch(id) {
            case "refresh": 
                ns_amortize_locked_aoci.refresh();
                break;
            case "excel":
                ns_amortize_locked_aoci.grid_amortize_aoci.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                ns_amortize_locked_aoci.grid_amortize_aoci.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "delete":
                ns_amortize_locked_aoci.btn_delete_click();
                break;
        }
    }
    
    function get_message(arg){
    	switch (arg) {
    	case 'BOOK_VALIDATE':
    		return 'Please select a Strategy or Book.';
    		break;    
            
    	}
    }
        
    ns_amortize_locked_aoci.refresh = function() {
        var form_obj = ns_amortize_locked_aoci.form_amortize_locked_aoci;
        var status = true;
        var as_of_date_from = form_obj.getItemValue('as_of_date_from', true);
        var book_entity_id = ns_amortize_locked_aoci.get_book();
        var strategy_id = ns_amortize_locked_aoci.get_strategy();
	    var volume_reclassify = form_obj.getItemValue('total_monthly_volume');
    	var volume_uom = form_obj.getItemValue('volume_uom');
    	var sort_order = form_obj.getItemValue('sort_order');
        var as_of_date_from = form_obj.getItemValue('as_of_date_from', true);
        var flag = 's';
        var prior_value = form_obj.isItemChecked('chk_prior_value');
        
        if (prior_value == true) {
    		flag = 'p';
    	}
        
        if (flag != 'p') {
    		if (strategy_id == '' && book_entity_id == '' || flag == 's') {
                if (strategy_id == '' && book_entity_id == '') {
            		show_messagebox(get_message('BOOK_VALIDATE'));
            		return;
            	}
                status = validate_form(form_obj);
            }
    	}
        
        if (strategy_id == '' && book_entity_id == '') {
    		show_messagebox(get_message('BOOK_VALIDATE'));
    		return;
    	}
        
        if (status == false) return; 
        
        var sql_param = {
                            'action': 'spa_amortize_aoci',
                            'flag': flag,
                            'fas_strategy': strategy_id,
                            'fas_book_id': book_entity_id,
                            'sort_order': sort_order,           
                            'volume_reclassify': volume_reclassify,
                            'volume_uom': volume_uom,
                            'reclassify_date': as_of_date_from
                        };
                
        if (flag == 's') {
        	if (volume_reclassify == '') {
        		volume_reclassify_mode = 'n';
                result = adiha_post_data('return_data', sql_param, '', '', 'ns_amortize_locked_aoci.refresh_grid_callback');    			
        	} else {
        		volume_reclassify_mode = 'y';
                
                if (msg_box_display() == 'Success') {
                    result = adiha_post_data('return_data', sql_param, '', '', 'ns_amortize_locked_aoci.refresh_grid_callback');
    			}
        	}
            
           ns_amortize_locked_aoci.grid_menu.setItemDisabled('delete');  
        } else if(flag == 'p') {
            if (has_rights_amortize_locked_aoci_delete) {
                ns_amortize_locked_aoci.grid_menu.setItemEnabled('delete');
            } else {
                ns_amortize_locked_aoci.grid_menu.setItemDisabled('delete');
            }
              
            ns_amortize_locked_aoci.toolbar.disableItem('amortize');
            
            if (volume_reclassify == '') {
        		volume_reclassify_mode = 'n';
        	    result = adiha_post_data('return_data', sql_param, '', '', 'ns_amortize_locked_aoci.check_delete_volume_reclassify');
        	} else {
        		volume_reclassify_mode = 'y';
                result = adiha_post_data('return_data', sql_param, '', '', 'ns_amortize_locked_aoci.check_delete');
        	}   
        }   
    }
    
    function msg_box_display() {
        var form_obj = ns_amortize_locked_aoci.form_amortize_locked_aoci;
        var as_of_date_from = form_obj.getItemValue('as_of_date_from', true);
        var book_entity_id = ns_amortize_locked_aoci.get_book();
        var strategy_id = ns_amortize_locked_aoci.get_strategy();
	    var volume_reclassify = form_obj.getItemValue('total_monthly_volume');
    	var volume_uom = form_obj.getItemValue('volume_uom');
    	var sort_order = form_obj.getItemValue('sort_order');
        var as_of_date_from = form_obj.getItemValue('as_of_date_from', true);
        var flag = 'v';
        var prior_value = form_obj.isItemChecked('chk_prior_value');
        var responce;
        
        if (prior_value == true) {
            var responce = 'Success';
        } else {
            var sql_param = {
                            'action': 'spa_amortize_aoci',
                            'flag': flag,
                            'fas_strategy': strategy_id,
                            'fas_book_id': book_entity_id,
                            'sort_order': sort_order,           
                            'volume_reclassify': volume_reclassify,
                            'volume_uom': volume_uom,
                            'reclassify_date': as_of_date_from
                        };
                        
            data = $.param(sql_param);
            
            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: data,
                success: function(data) {
                            response_data = data["json"];
                            responce = response_data[0].errorcode;
                        }
            }); 
        }
        
        return responce;       
    }
   
    // After Grid Refresh when Prior Value is unchecked
    ns_amortize_locked_aoci.refresh_grid_callback = function(result) {
        ns_amortize_locked_aoci.grid_amortize_aoci.clearAll();
        ns_amortize_locked_aoci.grid_amortize_aoci.parse(result, 'js');
        ns_amortize_locked_aoci.grid_amortize_aoci.selectAll();
        
        var row_id = ns_amortize_locked_aoci.grid_amortize_aoci.getSelectedRowId(); 
        
        if (row_id == null) {
            ns_amortize_locked_aoci.toolbar.disableItem('amortize');
        } else {
            if (has_rights_amortize_locked_aoci_iu) {
                ns_amortize_locked_aoci.toolbar.enableItem('amortize'); 
            } else {
                ns_amortize_locked_aoci.toolbar.disableItem('amortize'); 
            }
        }       
    }    
    
    // After Grid Refresh when Prior Value is checked and Volume is given
    ns_amortize_locked_aoci.check_delete = function(result) {
        ns_amortize_locked_aoci.grid_amortize_aoci.clearAll();
        ns_amortize_locked_aoci.grid_amortize_aoci.parse(result, 'js');
        
        ns_amortize_locked_aoci.grid_amortize_aoci.selectRowById(1);
        var row_id = ns_amortize_locked_aoci.grid_amortize_aoci.getSelectedRowId(); 
        
        if (row_id == null) {
            ns_amortize_locked_aoci.grid_menu.setItemDisabled('delete');
        } else {
            if (has_rights_amortize_locked_aoci_delete) {
                ns_amortize_locked_aoci.grid_menu.setItemEnabled('delete');
            } else {
                ns_amortize_locked_aoci.grid_menu.setItemDisabled('delete');
            }
        }
    }
    
    // After Grid Refresh when Prior Value is checked and Volume is NOT given
    ns_amortize_locked_aoci.check_delete_volume_reclassify = function(result) {
        ns_amortize_locked_aoci.grid_amortize_aoci.clearAll();
        ns_amortize_locked_aoci.grid_amortize_aoci.parse(result, 'js');
        
        var row_id = ns_amortize_locked_aoci.grid_amortize_aoci.getSelectedRowId(); 
        
        if (row_id == null) {
            ns_amortize_locked_aoci.grid_menu.setItemDisabled('delete');
        } else {
            if (has_rights_amortize_locked_aoci_delete) {
                ns_amortize_locked_aoci.grid_menu.setItemEnabled('delete');
            } else {
                ns_amortize_locked_aoci.grid_menu.setItemDisabled('delete');
            }
        }
    }
    
    function get_first_selected_row_column_value(column_number) {
        ns_amortize_locked_aoci.grid_amortize_aoci.selectRowById(1);
        var row_id = ns_amortize_locked_aoci.grid_amortize_aoci.getSelectedRowId(); 
        var value = ns_amortize_locked_aoci.grid_amortize_aoci.cells(row_id, column_number).getValue();
        ns_amortize_locked_aoci.grid_amortize_aoci.selectAll();
        return value;
    }
    
    ns_amortize_locked_aoci.btn_amortize_click = function() {
        var status = get_first_selected_row_column_value('2');
        var process_id = get_first_selected_row_column_value('1');
        var data;
        
        if (status != '' && status != undefined) { 
            dhtmlx.message({
                    type: 'confirm',
                    title: 'Confirmation',
                    ok: 'Confirm',
                    text: status,
                    callback: function(result) {    
                        if (result) {                            
                        data = {
                            'action': 'spa_amortize_aoci',
                            'flag': 'u',
                            'process_id': process_id
                        }                                                    
                        adiha_post_data('alert', data, status, '', 'reload_grid');
                   }
                }
    		});
        } else {
            data = {
                'action': 'spa_amortize_aoci',
                'flag': 'u',
                'process_id': process_id
            } 
                                                             
            adiha_post_data('alert', data, '', '', 'reload_grid');
        }    
    } 
    
     function reload_grid() {
        ns_amortize_locked_aoci.grid_amortize_aoci.selectRowById(1);
        var row_id = ns_amortize_locked_aoci.grid_amortize_aoci.getSelectedRowId(); 
    	var process_id = ns_amortize_locked_aoci.grid_amortize_aoci.cells(row_id, '1').getValue();

        var sql_param = {
                'action': 'spa_amortize_aoci',
                'flag': 'r',
                'process_id': process_id
        };
        
        result = adiha_post_data('return_data', sql_param, '', '', 'ns_amortize_locked_aoci.reload_callback');
        ns_amortize_locked_aoci.toolbar.disableItem('amortize');       
    }    
    
    ns_amortize_locked_aoci.reload_callback = function(result) {
        ns_amortize_locked_aoci.grid_amortize_aoci.clearAll();
        ns_amortize_locked_aoci.grid_amortize_aoci.parse(result, 'js');
        // ns_amortize_locked_aoci.grid_menu.setItemDisabled('delete');
        var status = get_first_selected_row_column_value('2');
        var prior_value = form_obj.isItemChecked('chk_prior_value');
        
        if (prior_value == true) {
            //ns_amortize_locked_aoci.enableItem('grid_amortize_aoci');
            //unselect all
        } else {
            ns_amortize_locked_aoci.grid_amortize_aoci.selectAll();
            //ns_amortize_locked_aoci.disableItem('grid_amortize_aoci');
            ns_amortize_locked_aoci.toolbar.disableItem('amortize');
        }
        
        if (status != "NULL" && status != undefined) {
    		show_messagebox(status);
    	}
    }
    
    ns_amortize_locked_aoci.btn_delete_click = function() {
        var row_id = ns_amortize_locked_aoci.grid_amortize_aoci.getSelectedRowId(); 
        var seq_id = ns_amortize_locked_aoci.grid_amortize_aoci.cells(row_id, '0').getValue();
    	var process_id = ns_amortize_locked_aoci.grid_amortize_aoci.cells(row_id, '1').getValue();
        
        if (seq_id != null) {
            dhtmlx.message({
                type: 'confirm',
                title: 'Confirmation',
                ok: 'Confirm',
                text: 'Are you sure you want to delete the selected data?',
                callback: function(result) {    
                    if (result) {                            
                        sql_param = {
                                'action': 'spa_amortize_aoci',
                                'flag': 'd',
                                'process_id': process_id,
                                'seq_id': seq_id
                        };   
                                                                   
                        adiha_post_data('alert', sql_param, '', '','reload_grid');
                    }
                }
    		});
        }
    }

    function set_privileges() {
        var ids = ns_amortize_locked_aoci.grid_amortize_aoci.getSelectedRowId();
        
        if (ids == null || ids.indexOf(',') != -1) {
            has_rights_amortize_locked_aoci_iu = false;
            has_rights_amortize_locked_aoci_delete = false;
        } 

        if (has_rights_amortize_locked_aoci_iu) {
            ns_amortize_locked_aoci.toolbar.enableItem('amortize'); 
        } else {
            ns_amortize_locked_aoci.toolbar.disableItem('amortize'); 
        }
        
        if (has_rights_amortize_locked_aoci_delete) {
            ns_amortize_locked_aoci.grid_menu.setItemEnabled('delete');
        } else {
            ns_amortize_locked_aoci.grid_menu.setItemDisabled('delete');
        }
        
    }
    
</script>
</html>