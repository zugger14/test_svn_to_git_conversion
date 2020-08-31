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
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

        
    $filter_application_function_id = 20007900;

    $rights_deal_match = 20007900;
    $rights_deal_match_iu = 20007901;
    $rights_deal_match_delete_match = 20007902;
    $rights_deal_match_auto_adjustment = 20007903;
    $rights_deal_match_manual_adjustment = 20007904;
    $rights_deal_match_delete_match_deal = 20007905;
    
    list (
        $has_rights_deal_match,
        $has_rights_deal_match_iu,
        $has_rights_deal_match_delete_match,
        $has_rights_deal_match_auto_adjustment,
        $has_rights_deal_match_manual_adjustment,
        $has_rights_deal_match_delete_match_deal
    ) = build_security_rights(
        $rights_deal_match,
        $rights_deal_match_iu,
        $rights_deal_match_delete_match,
        $rights_deal_match_auto_adjustment,
        $rights_deal_match_manual_adjustment,
        $rights_deal_match_delete_match_deal
    );

    $mode = 'i'; // update mode u: insert mode: i

    if (isset($_POST['active_object_id'])) {
        $active_tab_id = get_sanitized_value($_POST['active_object_id']);
        $pos = strrpos($active_tab_id, "tab_");
        if ($pos === false) { 
            // not found...
            $mode = 'i';
            // Value is not sanitized because, the returned data is JSON.
            $data_json_from_insert = $_POST['data'];
            $active_tab_id = '0';
        } else {
            $mode = 'u';
            $data_json_from_insert = "{}";

        }
    }
    if (ISSET($_POST['product_class'])) {
        $product_class = get_sanitized_value($_POST['product_class']);
    }
    
        
    $namespace = 'buy_sell_deal_match_ui';

    $layout_obj = new AdihaLayout();
    
    
    $enable = 'true';

    $layout_json = '[
                        {id: "a", height:150, text: "Deal Match Info", header: true},                        
                        {id: "b", text: "Sell Deal",header: true, collapse: false, fix_size: [false,null]},         
                        {id: "c", text: "Buy Deal", header: true, collapse: false, fix_size: [false,null]},
                    ]';
    
    $patterns = '3T';

    $layout_name = 'deal_match_ui';
    echo $layout_obj->init_layout($layout_name, '', $patterns, $layout_json, $namespace);


    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_deal_match . ", @template_name='BuySellMatch', @group_name='Link'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $filter_name = 'form_link';
    echo $layout_obj->attach_form($filter_name, 'a');
    $filter_obj = new AdihaForm();
    echo $filter_obj->init_by_attach($filter_name, $namespace);    
    echo $filter_obj->load_form($form_json);
    

    if ($mode == 'u') {
        $sql = "EXEC spa_buy_sell_match @flag = 'a', @link_id = " . str_replace('tab_', '', $active_tab_id);
        $form_link_data = readXMLURL2($sql);

        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'link_id', $form_link_data[0]['link_id']);
        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'description', $form_link_data[0]['description']);
        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'effective_date', $form_link_data[0]['effective_date']);
        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'group1', $form_link_data[0]['group1']);
        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'group2', $form_link_data[0]['group2']);
        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'group3', $form_link_data[0]['group3']);
        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'group4', $form_link_data[0]['group4']);
        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'match_status', $form_link_data[0]['match_status']);
        echo $filter_obj->set_input_value('buy_sell_deal_match_ui.form_link', 'assignment_type', $form_link_data[0]['assignment_type']);
        
    }

    $menu_obj = new AdihaMenu();
    $menu_name = 'left_dealset_menu';
    $menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id: "edit", enabled: true, img:"edit.gif", imgdis: "edit_dis.gif", text: "Edit", items:[
                            {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:"' . $has_rights_deal_match_manual_adjustment. '"},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", enabled:false}
                        ]
                    },';

    if($mode == 'u') {
        $menu_json .= ' {id: "delivery_date", img: "run_view_schedule.gif", text: "Delivered", title: "Delivered"},';
    }
    $menu_json .=  '{id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]}';
    $menu_json .= ']';
    echo $menu_obj->attach_menu_layout_header($namespace, $layout_name, 'b', $menu_name, $menu_json, $namespace . '.onclick_menu_left');


    $grid_obj = new AdihaGrid();
    $grid_name = 'left_grid_ui';
    echo $layout_obj->attach_grid_cell($grid_name, 'b');   
    echo $layout_obj->attach_status_bar('b', true); 
    $xml_file = "EXEC spa_adiha_grid 's','BuySellMatchDealsetIU'";
    $resultset = readXMLURL2($xml_file);
    echo $grid_obj->init_by_attach($grid_name, $namespace);    
    echo $grid_obj->set_header($resultset[0]['column_label_list']);
    echo $grid_obj->set_column_alignment($resultset[0]['column_alignment']);
    echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset[0]['column_width']);
    echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
    echo $grid_obj->enable_column_move();
    echo $grid_obj->enable_multi_select(true);
    echo $grid_obj->set_date_format($date_format, "%Y-%m-%d");
    echo $grid_obj->enable_paging(100, 'pagingArea_b');
    if ($mode == 'i') {
        echo $grid_obj->set_user_data("", "grid_id","buy_sell_link_ui_insert.left_grid");
    }
    echo $grid_obj->set_search_filter(true); 
    echo $grid_obj -> split_grid('1');
    echo $grid_obj->return_init();
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.set_left_dealset_menu_privileges');
	echo $grid_obj->enable_filter_auto_hide();

    $menu_obj = new AdihaMenu();
    $menu_name = 'right_dealset_menu';
    
	echo $menu_obj->attach_menu_layout_header($namespace, $layout_name, 'c', $menu_name, $menu_json, $namespace . '.onclick_menu_right');

    $grid_obj = new AdihaGrid();
    $grid_name = 'right_grid_ui';
    echo $layout_obj->attach_grid_cell($grid_name, 'c'); 
    echo $layout_obj->attach_status_bar('c', true); 
    $xml_file = "EXEC spa_adiha_grid 's','BuySellMatchDealsetIU'";
    $resultset = readXMLURL2($xml_file);
    echo $grid_obj->init_by_attach($grid_name, $namespace);    
    echo $grid_obj->set_header($resultset[0]['column_label_list']);
    echo $grid_obj->set_column_alignment($resultset[0]['column_alignment']);
    echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset[0]['column_width']);
    echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
    echo $grid_obj->enable_column_move();
    echo $grid_obj->enable_multi_select(true);
    echo $grid_obj->set_date_format($date_format, "%Y-%m-%d");
    if ($mode == 'i') {
        echo $grid_obj->set_user_data("", "grid_id","buy_sell_link_ui_insert.right_grid");
    }
    echo $grid_obj->set_search_filter(true); 
    echo $grid_obj->enable_paging(100, 'pagingArea_c');
    echo $grid_obj->return_init();
	echo $grid_obj -> split_grid('1');
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.set_right_dealset_menu_privileges');
    echo $grid_obj->attach_event ('','onRowAdded', $namespace . '.set_load_pop_up');
	echo $grid_obj->enable_filter_auto_hide();
   
    echo $layout_obj->close_layout(); 
    ?>
</body>
<script>
    var filter_application_function_id = '<?php echo $filter_application_function_id;?>';

    var has_rights_deal_match_iu = Boolean(<?php echo $has_rights_deal_match_iu; ?>);
    var has_rights_deal_match_delete_match = Boolean(<?php echo $has_rights_deal_match_delete_match; ?>);
    var has_rights_deal_match_auto_adjustment = Boolean(<?php echo $has_rights_deal_match_auto_adjustment; ?>);
    var has_rights_deal_match_manual_adjustment = Boolean(<?php echo $has_rights_deal_match_manual_adjustment; ?>);
    var has_rights_deal_match_delete_match_deal = Boolean(<?php echo $has_rights_deal_match_delete_match_deal; ?>);

    var active_tab_id = '<?php echo $active_tab_id;?>';
   
    var mode = '<?php echo $mode;?>';
    var product_class = Boolean(<?php echo $product_class; ?>);
	var show_popup_window = 0; 
	var process_id_right_grid;
	var newId = (new Date()).valueOf();
	var is_match = 0;
    var deliver_pop_up;
    var client_date_format ='<?php echo $date_format; ?>';
    var php_script_loc_ajax = '<?php echo $app_php_script_loc; ?>';
    
    
    $(function() {
        attach_browse_event('buy_sell_deal_match_ui.form_link',filter_application_function_id);
        // tab id is created as -1 from buysell.match.template.php
        var frame_obj = parent.buy_sell_link_ui_template["inner_tab_layout_-1"].cells("a").getFrame();
        if (mode == 'i') {
			parent.buy_sell_link_ui_template.refresh_match_grids('-1');
			is_match = 1; 
            var eff_date = frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.getItemValue('effective_date_2', true);			
            buy_sell_deal_match_ui.form_link.setItemValue('effective_date', eff_date); 

            if (product_class) {
                buy_sell_deal_match_ui.form_link.getCombo('assignment_type').setComboValue(5146)
            } else { 
                buy_sell_deal_match_ui.form_link.getCombo('assignment_type').setComboValue(10013);
            }            
        }

        //deal_match_ui.left_grid_ui.enableLightMouseNavigation(true);
        //deal_match_ui.right_grid_ui.enableLightMouseNavigation(true);

        buy_sell_deal_match_ui.set_process_id();
        
        if (!deliver_pop_up) {
            deliver_pop_up = new dhtmlXPopup();
            deliver_pop_up.attachEvent("onBeforeHide", function(type, ev, id) {
                if (type == 'click' || type == 'esc') {
                    deliver_pop_up.hide();
                    return true;
                }
            });        
        }        

        //deal_match_ui.load_match_grids();


        buy_sell_deal_match_ui.deal_match_ui.attachEvent("onResizeFinish", function(){
            // your code here
            this.cells('b').setWidth((this.cells('a').getWidth())/2);
        });

        buy_sell_deal_match_ui.left_grid_ui.attachEvent("onXLE", function(grid_obj,count){
            buy_sell_deal_match_ui.load_grid_footer2(grid_obj,1);
        });
        buy_sell_deal_match_ui.right_grid_ui.attachEvent("onXLE", function(grid_obj,count){
            buy_sell_deal_match_ui.right_grid_ui.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (stage ==2) {
                var remaining_index = buy_sell_deal_match_ui.right_grid_ui.getColIndexById("remaining");
                var remaining_val = parseFloat(buy_sell_deal_match_ui.right_grid_ui.cells(rId, remaining_index).getValue())
            }

            if (stage == 2 && parseFloat(nValue) <= (parseFloat(oValue) + remaining_val)) {
                buy_sell_deal_match_ui.right_grid_ui.cells(rId, remaining_index).setValue(remaining_val + parseFloat(oValue) - parseFloat(nValue));
                buy_sell_deal_match_ui.set_grid_footer_val();
                return true;
            }

            var match_col_index = buy_sell_deal_match_ui.right_grid_ui.getColIndexById('matched');
            if(match_col_index == cInd) {
                var id_col_index = buy_sell_deal_match_ui.right_grid_ui.getColIndexById('id');
                var id_val = buy_sell_deal_match_ui.right_grid_ui.cells(rId, id_col_index).getValue();
                if(id_val != '') {
                    return false;
                }
            } 
            return true; 
            
        });
            buy_sell_deal_match_ui.load_grid_footer2(grid_obj,2);
        });

        // buy_sell_deal_match_ui.left_grid_ui.attachEvent("onScroll", function(sLeft,sTop){
        //     $('#footer_iu_div1').css('padding-left',sLeft);
        // });

        // buy_sell_deal_match_ui.right_grid_ui.attachEvent("onScroll", function(sLeft,sTop){
        //     $('#footer_iu_div2').css('padding-left',sLeft);
        // });
       
        buy_sell_deal_match_ui.left_grid_ui.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            
            if (stage ==2) {
                var remaining_index = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("remaining");

                var remaining_val = parseFloat(buy_sell_deal_match_ui.left_grid_ui.cells(rId, remaining_index).getValue())
            }
            if (stage == 2 && parseFloat(nValue) <= (parseFloat(oValue) + remaining_val)   ) {

                buy_sell_deal_match_ui.left_grid_ui.cells(rId, remaining_index).setValue(remaining_val + parseFloat(oValue) - parseFloat(nValue));
                buy_sell_deal_match_ui.set_grid_footer_val();
                return true;

            }

        });

        var arr_orginal_matched_vals_right = new Array();

        // Remove the option to delete the deal in Sell Deal Panel for the matched deal
        buy_sell_deal_match_ui.left_dealset_menu.hideItem('edit');
        buy_sell_deal_match_ui.left_dealset_menu.hideItem('delivery_date');

        //Hidden column transfer_status from left grid and column id from right grid
        col_idx = buy_sell_deal_match_ui.left_grid_ui.getColIndexById('transfer_status');
        col_idx_right = buy_sell_deal_match_ui.right_grid_ui.getColIndexById('id');
        buy_sell_deal_match_ui.left_grid_ui.setColumnHidden(col_idx , true);
        buy_sell_deal_match_ui.right_grid_ui.setColumnHidden(col_idx_right , true);

        
        // Add option to open new window for auto adjustment in Buy Deal Panel
        if (mode == 'u') {
            var is_disabled = has_rights_deal_match_auto_adjustment === true ? false : true;
            buy_sell_deal_match_ui.right_dealset_menu.addNewSibling('edit', 'auto_adjust', 'Auto-Adjustment', is_disabled, 'finalize.gif', 'finalize_dis.gif');
        }
    });

    buy_sell_deal_match_ui.set_left_dealset_menu_privileges = function(id) {
        if (has_rights_deal_match_delete_match_deal && id != null)        
            buy_sell_deal_match_ui.left_dealset_menu.setItemEnabled('delete');
        else
            buy_sell_deal_match_ui.left_dealset_menu.setItemDisabled('delete');
        
    }

    buy_sell_deal_match_ui.set_right_dealset_menu_privileges = function(id) {
        if (has_rights_deal_match_delete_match_deal && id != null)        
            buy_sell_deal_match_ui.right_dealset_menu.setItemEnabled('delete');
        else
            buy_sell_deal_match_ui.right_dealset_menu.setItemDisabled('delete');
        
    }
	
	buy_sell_deal_match_ui.set_load_pop_up = function(id) {
        show_popup_window = 1;     
	}

    /**
    * Saved Matched Deals
    */
    buy_sell_deal_match_ui.save_matched_deals = function(active_tab_id) {
        $('#mt_q1').trigger('click');
        // Used for product validation
        var dealset1_arr = new Array();
        var dealset2_arr = new Array();
        var error_json = {};

        var validate_return = validate_form(buy_sell_deal_match_ui.form_link);
        var attached_form = buy_sell_deal_match_ui.form_link;
							
		if (show_popup_window == 1 || is_match == 1){
			process_id_right_grid = attached_form.getItemValue('process_id');
		}
        

        if (validate_return === false) {
            return;
        }
        
        // # Get value of Deal Detail ID from Left Grid and push into dealset1_arr
        buy_sell_deal_match_ui.left_grid_ui.forEachRow(function(row_id) {
            var source_deal_detail_id_index = buy_sell_deal_match_ui.left_grid_ui.getColIndexById('source_deal_detail_id');
            var source_deal_detail_id =  buy_sell_deal_match_ui.left_grid_ui.cells(row_id, source_deal_detail_id_index).getValue();
            dealset1_arr.push(source_deal_detail_id);
        });

        // # Get value of Deal Detail ID from Right Grid and push into dealset2_arr
        buy_sell_deal_match_ui.right_grid_ui.forEachRow(function(row_id) {
            var source_deal_detail_id_index = buy_sell_deal_match_ui.right_grid_ui.getColIndexById('source_deal_detail_id');
            var source_deal_detail_id = buy_sell_deal_match_ui.right_grid_ui.cells(row_id, source_deal_detail_id_index).getValue();
            dealset2_arr.push(source_deal_detail_id);
        });

        //Validation for same deals matched (Use of Underscore JS)
        var common_dealset_arr = _.intersection(dealset1_arr, dealset2_arr);

        if (common_dealset_arr.length > 0) {
            error_json =  {title: 'Alert', type: 'alert', text: 'Same Deal(s) are selected.'};
            return error_json;
        }
        
        var total_matched_volume1 = parseFloat($('#mt_q1').text().replace(',',''));
        var total_matched_volume2 = parseFloat($('#mt_q2').text().replace(',',''));

        if (total_matched_volume1 != total_matched_volume2) {
            validate_return = false;
            if (total_matched_volume1 > total_matched_volume2)
                show_messagebox('Matched Volume exceeded in <b>Sell Deal</b> Grid.');
            else
                show_messagebox('Matched Volume Exceeded in <b>Buy Deal</b> Grid.');
            return error_json;
        }

        /******Validation End*********/

        var total_matched_volume = (total_matched_volume1 < total_matched_volume2) ? total_matched_volume1 : total_matched_volume2;

        var form_xml = "<FormXML ";

        var form_data = attached_form.getFormData();

        var match_status = "";
        var has_negative = false;

        buy_sell_deal_match_ui.right_grid_ui.forEachRow(function(id) {
            var remaining_deal_value = document.getElementById("rm_q1").innerHTML.replace(',', '');
            var actual_deal_value1 = document.getElementById("av_q1").innerHTML.replace(',', '');
            var matched_deal_value1 = document.getElementById("mt_q1").innerHTML.replace(',', '');

            var actual_deal_value2 = buy_sell_deal_match_ui.right_grid_ui.getRowData(id).actual_volume;
            var matched_deal_value2 = buy_sell_deal_match_ui.right_grid_ui.getRowData(id).matched;
            var remaining_deal_value2 = buy_sell_deal_match_ui.right_grid_ui.getRowData(id).remaining;
            
            if (parseFloat(remaining_deal_value2) < 0 || parseFloat(remaining_deal_value) < 0) {
                has_negative = true;
            }
        });

        if (has_negative == true)
            match_status = 27209;

        var check_remaining_deal_value = document.getElementById("rm_q1").innerHTML.replace(',', '');
        var check_status = buy_sell_deal_match_ui.form_link.getItemValue('match_status');

        // If Remaining value is 0 and status is not selected by user then set 'Matched' as Status
        if (check_remaining_deal_value == 0 && check_status == '') {
            // Matched
            match_status = 27201;
        }

        for (var a in form_data) {
            field_label = a;
            field_value = form_data[a];
            if (attached_form.getItemType(field_label) == 'calendar') {
                field_value = attached_form.getItemValue(field_label, true);
            } else if (field_label == 'match_status' && match_status != "") {
                field_value = match_status;
            }
            form_xml += " " + field_label + "=\"" + field_value + "\"";
        }

        form_xml += " total_matched_volume =\"" + total_matched_volume + "\"";
        form_xml += "></FormXML>";

        var grid_xml = "<Grid>";
        var inner_grid_xml = '';
        var inner_grid_xml2 = '';

        var data_json = <?php echo $data_json_from_insert;?>;

        for (var row_id1=0; row_id1 < buy_sell_deal_match_ui.left_grid_ui.getRowsNum(); row_id1++) {
            var source_deal_header_id_index1 = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("source_deal_header_id");
            var deal_id_index1 = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("source_deal_detail_id");
            var matched_index1 = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("matched");
            var remaining_vol_index1 = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("remaining");
            var best_available_volume_index1 = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("actual_volume");
            if (buy_sell_deal_match_ui.left_grid_ui.cells2(row_id1, matched_index1).getValue() != 0) {
                inner_grid_xml += '<GridRow ';
                inner_grid_xml += ' source_deal_header_id="' + buy_sell_deal_match_ui.left_grid_ui.cells2(row_id1, source_deal_header_id_index1).getValue() + '"';
                inner_grid_xml += ' actual_volume="' + buy_sell_deal_match_ui.left_grid_ui.cells2(row_id1, best_available_volume_index1).getValue() + '"';
                inner_grid_xml += ' remaining="' + buy_sell_deal_match_ui.left_grid_ui.cells2(row_id1, remaining_vol_index1).getValue() + '"';
                inner_grid_xml += ' source_deal_detail_id="' + buy_sell_deal_match_ui.left_grid_ui.cells2(row_id1, deal_id_index1).getValue()
                                    + '" matched="' + buy_sell_deal_match_ui.left_grid_ui.cells2(row_id1, matched_index1).getValue()
                                    + '" vintage_year= ""'
                                    + ' expiration_date=""'
                                    + ' set_id="1" sequence_from="" sequence_to="" ';
                inner_grid_xml += '></GridRow>';
            }
        }

        /**Dealset2 xml**/
        for (var row_id2=0; row_id2 < buy_sell_deal_match_ui.right_grid_ui.getRowsNum(); row_id2++)  {
            var source_deal_header_id_index2 = buy_sell_deal_match_ui.right_grid_ui.getColIndexById("source_deal_header_id");
            var deal_id_index2 = buy_sell_deal_match_ui.right_grid_ui.getColIndexById("source_deal_detail_id");
            var matched_index2 = buy_sell_deal_match_ui.right_grid_ui.getColIndexById("matched");
            var vintage_year_index2 = buy_sell_deal_match_ui.right_grid_ui.getColIndexById("vintage_year");
            var exp_date_index2 = buy_sell_deal_match_ui.right_grid_ui.getColIndexById("expiration_date");
            var sequence_from = buy_sell_deal_match_ui.right_grid_ui.getColIndexById("sequence_from");
            var sequence_to = buy_sell_deal_match_ui.right_grid_ui.getColIndexById("sequence_to");
            var remaining_vol_index2 = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("remaining");
            var best_available_volume_index2 = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("actual_volume");
            
            if (buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, matched_index2).getValue() != 0) {
                inner_grid_xml2 += '<GridRow ';
                inner_grid_xml2 += ' source_deal_header_id="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, source_deal_header_id_index2).getValue() +'"';
                inner_grid_xml2 += ' actual_volume="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, best_available_volume_index2).getValue() + '"';
                inner_grid_xml2 += ' remaining="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, remaining_vol_index2).getValue() + '"';
                inner_grid_xml2 += ' source_deal_detail_id="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, deal_id_index2).getValue()
                                + '" matched="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, matched_index2).getValue()
                                + '" vintage_year="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, vintage_year_index2).getValue()
                                + '" expiration_date="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, exp_date_index2).getValue()
                                + '" set_id="2"'
                                + ' sequence_from="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, sequence_from).getValue()
                                + '" sequence_to="' + buy_sell_deal_match_ui.right_grid_ui.cells2(row_id2, sequence_to).getValue();
                inner_grid_xml2 += '"></GridRow>';
            }
        }

        if (inner_grid_xml == '' || inner_grid_xml2 == '') {
            validate_return = false;
            error_json =  {title: 'Error', type: 'alert-error', text: 'Empty Grid Row fetched.'};
            return error_json;
        }
        
        grid_xml += inner_grid_xml + inner_grid_xml2;
        grid_xml += "</Grid>";
        var xml = "<Root>";
        xml += form_xml;
        xml += grid_xml;
        xml += "</Root>";
        xml = xml.replace(/'/g, "\"");

        parent.enable_disable_menu('save', false);
        data = {
                "action" : "spa_buy_sell_match",
                "flag" : 'i',
                "link_id" : <?php echo str_replace('tab_', '', $active_tab_id);?>,
                "xmlValue" : xml,
                "process_id" : process_id_right_grid
            }
        result1 = adiha_post_data("return_json", data, "", "", "buy_sell_deal_match_ui.save_matched_deals_callback");
    }

    buy_sell_deal_match_ui.save_matched_deals_callback = function(return_value) {
        var grid_data = return_value;        
        return_value = JSON.parse(return_value);
		process_id_right_grid = 0;
		
								
        if (return_value.length > 0 && return_value[0].errorcode == undefined && (show_popup_window == 1 || is_match == 1)) {
			var width = 650;
            var height = 350;
            win_text = 'Common Product Data';
            popup_window = new dhtmlXWindows();
            param = 'buysell.match.multiple.case.php';
            new_win = popup_window.createWindow('wind', 0, 0, width, height);
            new_win.setText(win_text);
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.attachURL(param, false, {grids: [grid_data]});
            new_win.attachEvent("onClose", function(win) {
                parent.buy_sell_link_ui_template.refresh_match_grids(-1);
                parent.enable_disable_menu('save', true);
				 // var act_tab = parent.get_active_tab_id();
                // parent.buy_sell_link_ui_template.close_tabs(act_tab);
                return true;
            });
        }  else if (return_value.length > 0 && return_value[0].errorcode == undefined && show_popup_window == 0) {
			
			    parent.buy_sell_link_ui_template.refresh_match_grids(-1);
                parent.enable_disable_menu('save', true);                
                return true;
           } 		
		else if (return_value[0].errorcode == 'Success' ) {
            parent.enable_disable_menu('save', true);
            if (mode == 'u') {
                buy_sell_deal_match_ui.load_match_grids();
                if (typeof new_win != 'undefined')
                    new_win.close();
            }
            parent.buy_sell_link_ui_template.save_matched_deals_callback_parent(mode, 'Success',return_value[0].message, return_value[0].recommendation);
        } else {
             dhtmlx.message({
                title:'Error',
                type:"alert-error",
                text:return_value[0].message
            });
            parent.enable_disable_menu('save', true);
        } 
		//show_popup_window = 0;
    }

    buy_sell_deal_match_ui.set_process_id = function() {
        
        if(mode == 'i') {
            
            var data_json = <?php echo $data_json_from_insert;?>;
            deal_ids_arr = new Array();
            //
            var grid_xml = '<Grid>';
            var process_id_grid = data_json.grids[1].right_grid_ui[0].rows[0].process_id;


            for (i=1; i<=2; i++) { 
                var attached_grid = (i==1) ? buy_sell_deal_match_ui.left_grid_ui : buy_sell_deal_match_ui.right_grid_ui;
                var len_arr = (i==1) ? data_json.grids[0].left_grid_ui[0].rows : data_json.grids[1].right_grid_ui[0].rows;
                var grid_menu = (i==1) ? buy_sell_deal_match_ui.left_dealset_menu : buy_sell_deal_match_ui.right_dealset_menu;

                grid_menu.setItemDisabled('delete');

                for (var z=0;z<len_arr.length;z++) {
                    deal_ids_arr.push(len_arr[z].id);
                    grid_xml += '<GridRow source_deal_header_id ="' + len_arr[z].source_deal_header_id + '" set_id="';
                    (i==1)? grid_xml += '1' : grid_xml += '2';
                    grid_xml +='" source_deal_detail_id="' + len_arr[z].source_deal_detail_id + '" matched="' + len_arr[z].matched + '" remaining="' + len_arr[z].remaining + '" actual_volume="' + len_arr[z].actual_volume + '" vintage_year="'+ len_arr[z].vintage_year +'" expiration_date="'+ len_arr[z].expiration_date +'" sequence_from="' + len_arr[z].sequence_from + '" sequence_to="' + len_arr[z].sequence_to + '" ></GridRow>'
                }
                
            }
            grid_xml += "</Grid>";
            var xml = "<Root>" +  grid_xml + "</Root>";
            xml = xml.replace(/'/g, "\"");
            data = {"action": "spa_buy_sell_match", "flag":"j", "xmlValue":""+ xml+"", "process_id":"" + process_id_grid + ""};
            adiha_post_data("return_array", data, '', '', 'buy_sell_deal_match_ui.load_match_grids');
        } else {
            buy_sell_deal_match_ui.load_match_grids();
        }
        
    }

    buy_sell_deal_match_ui.load_match_grids = function(result) {
        // deal_match_ui.deal_match_ui.cells('b').progressOn();
        // deal_match_ui.deal_match_ui.cells('c').progressOn();
		
        
			
        if (mode == 'i') {

            if(result[0][0] == "Error") {
                dhtmlx.message({
                    title:'Alert',
                    type:"alert",
                    text:result[0][4],
                    callback: function() { 
                        var active_tab_id = parent.buy_sell_link_ui_template.link_ui_tabbar.getActiveTab(); 
                        active_tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                        parent.buy_sell_link_ui_template.close_tabs(active_tab_id);
                       
                    }
                });
                return;
            }

            buy_sell_deal_match_ui.form_link.setItemValue('process_id',result[0]);

            for (i=1; i<=2; i++) {
                var attached_grid = (i==1) ? buy_sell_deal_match_ui.left_grid_ui : buy_sell_deal_match_ui.right_grid_ui;
                var sql_param = {
                            "sql":"EXEC spa_buy_sell_match @flag = 't', @process_id = '" + result[0] + "', @set=" + i +"",
                            "grid_type":"g"
                        };
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;

                if (i == 2) {
                    attached_grid.clearAndLoad(sql_url);
                } else {
                    attached_grid.clearAndLoad(sql_url);
                }

                if ($('#mt_q'+i).length == 1) {
                    attached_grid.detachFooter(0);
                }                
            }
        } else {
            // update mode
            for (i=1; i<=2; i++) { 
                var attached_grid = (i==1) ? buy_sell_deal_match_ui.left_grid_ui : buy_sell_deal_match_ui.right_grid_ui;

                var sql_param = {
                        "sql":"EXEC spa_buy_sell_match @flag = 't', @link_id = <?php echo str_replace('tab_', '', $active_tab_id);?>,  @set= '"+i+"'",
                        "grid_type":"g"
                    };
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;

                if (i == 2) {
                    attached_grid.clearAndLoad(sql_url,buy_sell_deal_match_ui.load_grid_footer);
                } else {
                    attached_grid.clearAndLoad(sql_url);
                }

                if ($('#mt_q'+i).length == 1) {
                    attached_grid.detachFooter(0);
                }
                
            }
        }
    }

     /**
     *
     */
    buy_sell_deal_match_ui.onclick_menu_left = function(id) {
        switch (id) {
            case 'refresh':
                buy_sell_deal_match_ui.refresh_deal_grid(buy_sell_deal_match_ui.left_grid_ui,1);
                break;

            case 'add':
                var transaction_type = 400;
			     buy_sell_deal_match_ui.select_deal(buy_sell_deal_match_ui.left_grid_ui,transaction_type,'buy_grid');
                break;

            case 'delete':
                buy_sell_deal_match_ui.left_grid_ui.deleteSelectedRows();
                buy_sell_deal_match_ui.left_dealset_menu.setItemDisabled('delete');
                setTimeout(buy_sell_deal_match_ui.set_grid_footer_val(),2);
                break; 

            case 'excel':
                buy_sell_deal_match_ui.left_grid_ui.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break

            case 'pdf':
                buy_sell_deal_match_ui.left_grid_ui.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break        
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    buy_sell_deal_match_ui.onclick_menu_right = function(id) {
        switch (id) {
            case 'refresh':
                buy_sell_deal_match_ui.refresh_deal_grid(buy_sell_deal_match_ui.right_grid_ui,2);
                break;

            case 'add':
                var transaction_type = 400;
				 buy_sell_deal_match_ui.select_deal(buy_sell_deal_match_ui.right_grid_ui,transaction_type,'sale_grid');
                break;

            case 'delete':
                buy_sell_deal_match_ui.right_grid_ui.deleteSelectedRows();
                buy_sell_deal_match_ui.right_dealset_menu.setItemDisabled('delete');
                setTimeout(buy_sell_deal_match_ui.set_grid_footer_val(),2);
                break;
            case 'auto_adjust':
				buy_sell_deal_match_ui.open_adjustment_window();
                break;    

            case 'delivery_date':
                show_pop_up(this);
                break;

            case 'excel':
                buy_sell_deal_match_ui.right_grid_ui.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;

            case 'pdf':
                buy_sell_deal_match_ui.right_grid_ui.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;    
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    function show_pop_up(inp) {
        if (deliver_pop_up.isVisible()) {
            deliver_pop_up.hide();
        } else {
            var template_height = parent.buy_sell_link_ui_template.template_layout.cells('a').getHeight();
            var template_width = parent.buy_sell_link_ui_template.template_layout.cells('a').getWidth();
            var x = template_width - buy_sell_deal_match_ui.deal_match_ui.cells('c').getWidth() + 200 ;
            var y = template_height - buy_sell_deal_match_ui.deal_match_ui.cells('c').getHeight() - 250;
            deliver_pop_up.show(x,y,200,200);
            
            var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
            var date_form_data = [
                                    {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    
                                    {type: "calendar", name: "delivery_date", label: "Delivery Date " ,"dateFormat": client_date_format, serverDateFormat:"%Y-%m-%d"},
                                    {type: "button", id: 'save', value: "Ok", img: "tick.png"}

                        ];
        var date_form = deliver_pop_up.attachForm(date_form_data);
        var new_date = new Date();
        var date = new Date(new_date.getFullYear(), new_date.getMonth() , new_date.getDate());
        

        date_form.setItemValue('delivery_date', date);
        
        date_form.attachEvent("onButtonClick", function() {
            var deli_date = date_form.getItemValue('delivery_date', true);
            var my_grid = buy_sell_deal_match_ui.right_grid_ui;
            var col_index = my_grid.getColIndexById('delivery_date');
            var selected_row = my_grid.getSelectedRowId();
            var all_rows = my_grid.getAllRowIds();
            var rows = all_rows.split(",");
            var grid_xml1 = '<Grid>';
            var id_col = my_grid.getColIndexById('id');
            //var deal_id = [];

            if (selected_row != '' && selected_row != null) {
                selected_row.split(',').forEach(function(index){
                        id = my_grid.cells(index, id_col).getValue();
                        my_grid.cells(index, col_index).setValue(deli_date);
                        grid_xml1 += '<GridRow id="' + id + '" delivery_date="' + deli_date + '" ></GridRow>'       
                });   
                grid_xml1 += '</Grid>'
                delivered_callback(grid_xml1);        
                 
            }
            // else if (count == 1){
            //     id = my_grid.cells('0', deal_id_col).getValue();
            //     buy_sell_deal_match_ui.right_grid_ui.cells('0', col_index).setValue(deli_date);
            // }
            else {
                dhtmlx.message({
                        type: "confirm",
                        title: "Confirmation",
                        ok: "Confirm",
                        text: "This adds value to all the rows. Do you want to continue?",
                        callback:function(result) {
                            if (result) {
                                rows.forEach(function(index){
                                        id = my_grid.cells(index, id_col).getValue();
                                        my_grid.cells(index, col_index).setValue(deli_date);
                                        grid_xml1 += '<GridRow id="' + id + '" delivery_date="' + deli_date + '" ></GridRow>'      
                                });
                            }
                            grid_xml1 += '</Grid>'
                            delivered_callback(grid_xml1);
                            return;
                        }
                        
                });
            }

        });  
        }
    }

    function delivered_callback(grid_xml) {
        var grid_xml1 = grid_xml + '</Grid>'
        data = {
                    "action": "spa_buy_sell_match",
                     "flag":"r", 
                     "xmlValue": grid_xml,
                     "link_id" : <?php echo str_replace('tab_', '', $active_tab_id);?>                    
                };
          
        adiha_post_data("return_array", data, '', '', 'buy_sell_deal_match_ui.save_callback');
        deliver_pop_up.hide();          

    }

    buy_sell_deal_match_ui.save_callback = function(result) {
        buy_sell_deal_match_ui.refresh_deal_grid(buy_sell_deal_match_ui.right_grid_ui,2);
    }

    
    buy_sell_deal_match_ui.refresh_deal_grid = function(grid_obj,grid_num) {
        if (grid_num == 1)
            buy_sell_deal_match_ui.deal_match_ui.cells('b').progressOn();
        else
            buy_sell_deal_match_ui.deal_match_ui.cells('c').progressOn();

        var grid_menu = (grid_num==1) ? buy_sell_deal_match_ui.left_dealset_menu : buy_sell_deal_match_ui.right_dealset_menu;
        grid_menu.setItemDisabled('delete');
		
        if (mode == 'i') {
            //from deal match TAB
           /*
            var len_arr = (grid_num == 1) ? data_json.grids[0].left_grid_ui[0].rows : data_json.grids[1].right_grid_ui[0].rows;
           

            var grid_xml = '<Grid>';
            var deal_ids_arr = new Array();
            for (var z=0;z<len_arr.length;z++) {
                deal_ids_arr.push(len_arr[z].id);
                grid_xml += '<GridRow source_deal_header_id="' + len_arr[z].id + '" matched="' + len_arr[z].matched + '" remaining="' + len_arr[z].remaining + '" ></GridRow>'
            }
            
            grid_xml += "</Grid>";
            var xml = "<Root>" +  grid_xml + "</Root>";
            xml = xml.replace(/'/g, "\"");

            var deal_ids = deal_ids_arr.toString();*/

            var process_id =  buy_sell_deal_match_ui.form_link.getItemValue('process_id');
            var sql_param = {
                        "sql":"EXEC spa_buy_sell_match @flag = 't', @process_id = '" + process_id + "', @set=" + grid_num +"",
                        "grid_type":"g"
                    };
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            grid_obj.clearAndLoad(sql_url,buy_sell_deal_match_ui.set_grid_footer_val);
            /*
                var row_datas = new Array();
                for (var z=0;z<len_arr.length;z++) {
                    row_datas[z] = new Array();
                    for (var k = 0;k<len_arr[z].data.length;k++) {
                        row_datas[z][k] = len_arr[z].data[k];
                    }          
                }
                console.log(row_datas)
                grid_obj.parse(row_datas,"jsarray");
                
                
                for (var z=0;z<len_arr.length;z++) {
                    grid_obj.addRow(z+newId,len_arr[z].data);
                } */
                


            //setTimeout(deal_match_ui.set_grid_footer_val(),5);                
            
        } else {
            // update mode
                var sql_param = {
                        "sql":"EXEC spa_buy_sell_match @flag = 't', @link_id = <?php echo str_replace('tab_', '', $active_tab_id);?>,  @set= '"+grid_num+"'",
                        "grid_type":"g"
                    };
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;

                grid_obj.clearAndLoad(sql_url,buy_sell_deal_match_ui.set_grid_footer_val);



        }
        
    }

    

    buy_sell_deal_match_ui.select_deal = function(obj, trans_type, grid_type) {
       
        
		// Collect deals from create and view deals page. 
        var col_list = 'id'; //id for source_deal_header_id       
        var view_deal_window = new dhtmlXWindows();
        var win_id = 'w1';
        //deal_win should be global variable to access from callback function 'deal_match_ui.callback_select_deal' to close child window ie deal window
        deal_win = view_deal_window.createWindow(win_id, 0, 0, 600, 600);
        deal_win.setModal(true);
        
        var win_title = 'Select Deal';
        var win_url = '../maintain_deals/maintain.deals.new.php';  
        var params = {read_only:true,col_list:col_list,deal_select_completed:'buy_sell_deal_match_ui.process_selected_match_deal',trans_type:trans_type,call_from:'buysell_match'};
        
        deal_win.setText(win_title);
        deal_win.maximize();
        processing_grid_obj = obj;
        deal_win.attachURL(win_url, false, params);        
        
    } //end deal_match_ui.select_deal()
    
   
    buy_sell_deal_match_ui.process_selected_match_deal = function(result) {
		show_popup_window = 1;
        //close child window
        var ignore_deal_ids = processing_grid_obj.collectValues(processing_grid_obj.getColIndexById("source_deal_header_id"));
        var sell_deal_id = buy_sell_deal_match_ui.left_grid_ui.cells(0,0).getValue();

        var source_deal_header_id_from;
        var deal_changed_rows = (processing_grid_obj.getChangedRows() == "") ? [] : processing_grid_obj.getChangedRows().split(',');
        var deal_changed_ids= [];

		for(var i =0; i<deal_changed_rows.length; i++) {
            deal_changed_ids.push(processing_grid_obj.cells(deal_changed_rows[i],processing_grid_obj.getColIndexById("source_deal_header_id")).getValue());
            processing_grid_obj.deleteRow(deal_changed_rows[i]);
        }

        if(deal_changed_ids.length > 0) {
            source_deal_header_id_from = result.concat(deal_changed_ids);
        } else {
            source_deal_header_id_from = result;
        }

        deal_win.close();

        if (result.length > 0) {
            var deal_ids = result.toString();
            var data = {
                            "action": "spa_buy_sell_match",
                            "flag":'g',
                            "source_deal_header_id": sell_deal_id,
                            "source_deal_header_id_from": source_deal_header_id_from.toString()
                        };
            
            adiha_post_data('return_array', data, '', '', 'buy_sell_deal_match_ui.append_to_grid', ''); 
        } 
            
    }

    buy_sell_deal_match_ui.append_to_grid = function(result) {
        
        if(result.length == 0) {
            show_messagebox('Product details of deals do not match. Please check the deals.');
            return;
        } 
        var deal_detail_id_index = processing_grid_obj.getColIndexById("source_deal_detail_id")
        var all_deal_ids = processing_grid_obj.collectValues(deal_detail_id_index);
        var res = result.map(function(e) {
            return e[8].toString();
        });
        var exist = all_deal_ids.filter(function(e) {
            return res.indexOf(e) != -1;
        });

        var exist = exist.map(function(e){
            return parseInt(e);
        });

        var new_result = result.filter(function(e) {
            return exist.indexOf(e[8]) == -1;
        });
        
        var matched_col_indx = processing_grid_obj.getColIndexById('matched');
        var rowId = (new Date()).valueOf();
        
        var new_process_id = result[0][21];
       
        buy_sell_deal_match_ui.form_link.setItemValue('process_id', new_process_id);

        for(var i=0; i<new_result.length; i++) {
            result[i].pop();
            result[i].pop();
        }
        // need to reset rowids before parse
        for (var z=0;z<processing_grid_obj.getRowsNum();z++) {    
            processing_grid_obj.setRowId(z,z+rowId);
        }
        processing_grid_obj.parse(new_result, "jsarray");

        var detail_ids = [];
        for(var i =0; i<result.length; i++) {
            detail_ids.push(new_result[i][8].toString());
        }

        for (var z=0;z<processing_grid_obj.getRowsNum();z++) {    
            processing_grid_obj.setRowId(z,z+rowId);
        }
        
        processing_grid_obj.forEachRow(function(id){
            var deal_detail_val = processing_grid_obj.cells(id,deal_detail_id_index).getValue();
            if($.inArray(deal_detail_val, detail_ids) > -1) {
                processing_grid_obj.cells(id, matched_col_indx).cell.wasChanged = true;
            }
        });

        setTimeout(buy_sell_deal_match_ui.set_grid_footer_val(),2);
    }

    buy_sell_deal_match_ui.set_grid_footer_val = function() {
        for (var i =1; i<3; i++) {
            var attached_grid = (i == 1) ? buy_sell_deal_match_ui.left_grid_ui : buy_sell_deal_match_ui.right_grid_ui;
        
            var nrQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("actual_volume"));
            var srQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("matched"));
            var nrS_val = sumColumn(attached_grid,attached_grid.getColIndexById("remaining"));
        
            var nrQ = document.getElementById("av_q"+i);
                nrQ.innerHTML = nrQ_val;
            var srQ = document.getElementById("mt_q"+i);
                srQ.innerHTML = srQ_val;
            var nrS = document.getElementById("rm_q"+i);
                nrS.innerHTML = nrS_val;

        }
        buy_sell_deal_match_ui.deal_match_ui.cells('b').progressOff();
        buy_sell_deal_match_ui.deal_match_ui.cells('c').progressOff();

    }

    buy_sell_deal_match_ui.load_grid_footer2 = function(attached_grid, i) {
        attached_grid.filterByAll();
        if ($('#mt_q'+i).length == 0) {
            var nrQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("actual_volume"));
            var srQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("matched"));
            var nrS_val = sumColumn(attached_grid,attached_grid.getColIndexById("remaining"));

            attached_grid.attachFooter(",<div id='footer_iu_div"+i+"'><div style='float:left;padding-right:20px;font-weight:bold;'>Best Available Volume : <span id='av_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;font-weight:bold;'>Matched : <span id='mt_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;font-weight:bold;'>Remaining : <span id='rm_q"+i+"'>0</span></div></div>,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan",["height:30px;text-align:left;font-weight:bold;"]);
             
            var nrQ = document.getElementById("av_q"+i);
                nrQ.innerHTML = nrQ_val;
            var srQ = document.getElementById("mt_q"+i);
                srQ.innerHTML = srQ_val;
            var nrS = document.getElementById("rm_q"+i);
                nrS.innerHTML = nrS_val;

            // Display Match Status
            check_match_status(parseFloat(nrQ_val.replace(',', '')), parseFloat(srQ_val.replace(',', '')), parseFloat(nrS_val.replace(',', '')), i);
        } 
        
        buy_sell_deal_match_ui.deal_match_ui.cells('b').setWidth(buy_sell_deal_match_ui.deal_match_ui.cells('b').getWidth() + 0.1);
        
        if (i == 1)
            buy_sell_deal_match_ui.deal_match_ui.cells('b').progressOff();
        else 
            buy_sell_deal_match_ui.deal_match_ui.cells('c').progressOff();
    }

    buy_sell_deal_match_ui.load_grid_footer = function(stage) {
        if (mode == 'i') {
            for (var i=1;i<3;i++) {
                var attached_grid = (i ==1) ? buy_sell_deal_match_ui.left_grid_ui : buy_sell_deal_match_ui.right_grid_ui;  
                buy_sell_deal_match_ui.load_grid_footer2(attached_grid,i);        
            }
        }        
     } 

     
    function sumColumn(myGrid,ind){
        var out = 0;
        for(var i=0;i<myGrid.getRowsNum();i++){
            out+= parseFloat(myGrid.cells2(i,ind).getValue())
        }
        return numberWithCommas(out);
    }

    function numberWithCommas(x) {
        x = Math.round(x * 100) / 100;
        x = x.toFixed(2);
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    // Opens new window for auto adjustment
    buy_sell_deal_match_ui.open_adjustment_window = function() {
        dhxWins = new dhtmlXWindows();
        var is_win = dhxWins.isWindow('w1');
        var effective_date = dates.convert_to_sql(buy_sell_deal_match_ui.form_link.getItemValue('effective_date'));
        first_row_id = buy_sell_deal_match_ui.left_grid_ui.getRowId(0);
        deal_column_index = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("source_deal_header_id"); 
        var deal_detail_column_index = buy_sell_deal_match_ui.left_grid_ui.getColIndexById("source_deal_detail_id");
        var deal_id = buy_sell_deal_match_ui.left_grid_ui.cells(first_row_id, deal_column_index).getValue();
        var detail_id = buy_sell_deal_match_ui.left_grid_ui.cells(first_row_id, deal_detail_column_index).getValue();
        param = 'buysell.match.auto.adjust.php?is_pop=true' + '&deal_id=' + deal_id + '&effective_date=' + effective_date
         + '&sell_deal_detail_id=' + detail_id;
        
        text = 'Auto-Adjustment';
        if (is_win == true) {
            w1.close();
        }
        w1 = dhxWins.createWindow("w1", 0, 0, 1000, 450);
        w1.centerOnScreen();
        w1.setText(text);
        w1.setModal(true);
        //w1.denyMove();
        //w1.denyResize();
        //w1.button('minmax').hide();
        //w1.button('park').hide();
        w1.attachURL(param, false, true);
    }

    function check_match_status(nrQ_val, srQ_val, nrS_val, grid_index) {
        var form_obj = buy_sell_deal_match_ui.deal_match_ui.cells('a').getAttachedObject();
        var match_status = form_obj.getItemValue('match_status');
        var combo_obj = form_obj.getCombo('match_status');
        var display_status = false;
        var match_status = '';
        var has_negative = false;
        buy_sell_deal_match_ui.right_grid_ui.forEachRow(function(id) {
            var actual_deal_value2 = buy_sell_deal_match_ui.right_grid_ui.getRowData(id).actual_volume;
            var matched_deal_value2 = buy_sell_deal_match_ui.right_grid_ui.getRowData(id).matched;
            var remaining_deal_value2 = buy_sell_deal_match_ui.right_grid_ui.getRowData(id).remaining;

            if (parseFloat(remaining_deal_value2) < 0) {
                has_negative = true;
            }
        });

        if (nrQ_val < srQ_val || has_negative == true) {
            buy_sell_deal_match_ui.form_link.setItemValue('match_status', 27209);
            match_status_label = "Exception";
            color = "red";
            display_status = true;
        } else if (nrS_val > 0 && grid_index == 1) {
            buy_sell_deal_match_ui.form_link.setItemValue('match_status', 27207);
            match_status_label = "Incomplete";
            color = "blue";
            display_status = true;
        } else {
            display_status = false;
        }

        if (display_status) {
            if (buy_sell_deal_match_ui.form_link.isItem('show_match_status') == null) {
                var itemData =  {type:"newcolumn"};
                buy_sell_deal_match_ui.form_link.addItem('match_status', itemData, null, true);
                var itemData =  {type:"label", name:"show_match_status", label: match_status_label, offsetTop: ui_settings['checkbox_offset_top']};
                buy_sell_deal_match_ui.form_link.addItem('match_status', itemData, null, true);
                $('.dhxform_txt_label2').css({"color": color});
            } else {
                buy_sell_deal_match_ui.form_link.setItemLabel('show_match_status', match_status_label);
                $('.dhxform_txt_label2').css({"color": color});
            }
        }
    }
</script>
</html>