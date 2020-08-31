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

        
    $filter_application_function_id = 20004700;

    $rights_deal_match = 20004700;
    $rights_deal_match_iu = 20004701;
    $rights_deal_match_delete = 20004702;
    
    list (
        $has_rights_deal_match,
        $has_rights_deal_match_iu,
        $has_rights_deal_match_delete
    ) = build_security_rights(
        $rights_deal_match,
        $rights_deal_match_iu,
        $rights_deal_match_delete
    );

    $mode = 'i'; // update mode u: insert mode: i

    if (isset($_POST['active_object_id'])) {
        $active_tab_id = get_sanitized_value($_POST['active_object_id']);
        $pos = strrpos($active_tab_id, "tab_");
        if ($pos === false) { 
            // not found...
            $mode = 'i';
            $data_json_from_insert = get_sanitized_value($_POST['data']);
            $active_tab_id = '0';
        } else {
            $mode = 'u';
            $data_json_from_insert = "{}";

        }
    }
    
        
    $namespace = 'deal_match_ui';

    $layout_obj = new AdihaLayout();
    
    
    $enable = 'true';

    $layout_json = '[
                        {id: "a", height:150, text: "Deal Match Info", header: true},                        
                        {id: "b", text: "Dealset 1",header: true, collapse: false, fix_size: [false,null]},         
                        {id: "c", text: "Dealset 2", header: true, collapse: false, fix_size: [false,null]},
                    ]';
    
    $patterns = '3T';

    $layout_name = 'deal_match_ui';
    echo $layout_obj->init_layout($layout_name, '', $patterns, $layout_json, $namespace);


    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_deal_match . ", @template_name='DealMatch', @group_name='Link'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $filter_name = 'form_link';
    echo $layout_obj->attach_form($filter_name, 'a');
    $filter_obj = new AdihaForm();
    echo $filter_obj->init_by_attach($filter_name, $namespace);    
    echo $filter_obj->load_form($form_json);

    if ($mode == 'u') {
        $sql = "EXEC spa_deal_match @flag = 'a', @link_id = " . str_replace('tab_', '', $active_tab_id);
        $form_link_data = readXMLURL2($sql);

        echo $filter_obj->set_input_value('deal_match_ui.form_link', 'link_id', $form_link_data[0]['link_id']);
        echo $filter_obj->set_input_value('deal_match_ui.form_link', 'description', $form_link_data[0]['description']);
        echo $filter_obj->set_input_value('deal_match_ui.form_link', 'effective_date', $form_link_data[0]['effective_date']);
        echo $filter_obj->set_input_value('deal_match_ui.form_link', 'group1', $form_link_data[0]['group1']);
        echo $filter_obj->set_input_value('deal_match_ui.form_link', 'group2', $form_link_data[0]['group2']);
        echo $filter_obj->set_input_value('deal_match_ui.form_link', 'group3', $form_link_data[0]['group3']);
        echo $filter_obj->set_input_value('deal_match_ui.form_link', 'group4', $form_link_data[0]['group4']);
		echo $filter_obj->set_input_value('deal_match_ui.form_link', 'match_status', $form_link_data[0]['match_status']);
        
    }

    $menu_obj = new AdihaMenu();
    $menu_name = 'left_dealset_menu';
    $menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id: "edit", enabled: true, img:"edit.gif", imgdis: "edit_dis.gif", text: "Edit", items:[
                            {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:"' . $has_rights_deal_match_iu. '"},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", enabled:false},
                        ]
                    }
                ]';
    echo $layout_obj->attach_menu_cell($menu_name, 'b');
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.onclick_menu_left');
    

    $grid_obj = new AdihaGrid();
    $grid_name = 'left_grid_ui';
    echo $layout_obj->attach_grid_cell($grid_name, 'b');    
    $xml_file = "EXEC spa_adiha_grid 's','DealMatchDealsetIU'";
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
    if ($mode == 'i') {
        echo $grid_obj->set_user_data("", "grid_id","link_ui_insert.left_grid");
    }
    echo $grid_obj->set_search_filter(true); 
    echo $grid_obj -> split_grid('1');
    echo $grid_obj->return_init();
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.set_left_dealset_menu_privileges');

    $menu_obj = new AdihaMenu();
    $menu_name = 'right_dealset_menu';
    echo $layout_obj->attach_menu_cell($menu_name, 'c');
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.onclick_menu_right');

    $grid_obj = new AdihaGrid();
    $grid_name = 'right_grid_ui';
    echo $layout_obj->attach_grid_cell($grid_name, 'c');  
    $xml_file = "EXEC spa_adiha_grid 's','DealMatchDealsetIU'";
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
    if ($mode == 'i') {
        echo $grid_obj->set_user_data("", "grid_id","link_ui_insert.right_grid");
    }
    echo $grid_obj->set_search_filter(true); 
    echo $grid_obj -> split_grid('1');
    echo $grid_obj->return_init();
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.set_right_dealset_menu_privileges');
    
    echo $layout_obj->close_layout(); 
    ?>
</body>
<script>
    var filter_application_function_id = '<?php echo $filter_application_function_id;?>';

    var has_rights_deal_match_iu = Boolean(<?php echo $has_rights_deal_match_iu; ?>);
    var has_rights_deal_match_delete = Boolean(<?php echo $has_rights_deal_match_delete; ?>);

    var active_tab_id = '<?php echo $active_tab_id;?>';
    var mode = '<?php echo $mode;?>';

    var newId = (new Date()).valueOf();
    //var data = {rows:[{ id:0,data:[ "74","EUAT","Buy", "XYZ","11/10/2017","11/10/2017","123","0","123","Tons","3.15","EUR"]}],};
    
    $(function() {
        attach_browse_event('deal_match_ui.form_link',filter_application_function_id);

        //deal_match_ui.left_grid_ui.enableLightMouseNavigation(true);
        //deal_match_ui.right_grid_ui.enableLightMouseNavigation(true);

        deal_match_ui.load_match_grids();


        deal_match_ui.deal_match_ui.attachEvent("onResizeFinish", function(){
            // your code here
            this.cells('b').setWidth((this.cells('a').getWidth())/2);
        });

        deal_match_ui.left_grid_ui.attachEvent("onXLE", function(grid_obj,count){
            deal_match_ui.load_grid_footer2(grid_obj,1);
        });
        deal_match_ui.right_grid_ui.attachEvent("onXLE", function(grid_obj,count){
            deal_match_ui.load_grid_footer2(grid_obj,2);
        });

        deal_match_ui.left_grid_ui.attachEvent("onScroll", function(sLeft,sTop){
            $('#footer_iu_div1').css('padding-left',sLeft);
        });

        deal_match_ui.right_grid_ui.attachEvent("onScroll", function(sLeft,sTop){
            $('#footer_iu_div2').css('padding-left',sLeft);
        });

       
        deal_match_ui.left_grid_ui.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            
            if (stage ==2) {
                var remaining_index = deal_match_ui.left_grid_ui.getColIndexById("remaining");

                var remaining_val = parseFloat(deal_match_ui.left_grid_ui.cells(rId, remaining_index).getValue())
            }
            if (stage == 2 && parseFloat(nValue) <= (parseFloat(oValue) + remaining_val)   ) {

                deal_match_ui.left_grid_ui.cells(rId, remaining_index).setValue(remaining_val + parseFloat(oValue) - parseFloat(nValue));
                deal_match_ui.set_grid_footer_val();
                return true;

            }

        });

        var arr_orginal_matched_vals_right = new Array();
        deal_match_ui.right_grid_ui.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (stage ==2) {
                var remaining_index = deal_match_ui.right_grid_ui.getColIndexById("remaining");
                var remaining_val = parseFloat(deal_match_ui.right_grid_ui.cells(rId, remaining_index).getValue())
            }
            if (stage == 2 && parseFloat(nValue) <= (parseFloat(oValue) + remaining_val)) {
                deal_match_ui.right_grid_ui.cells(rId, remaining_index).setValue(remaining_val + parseFloat(oValue) - parseFloat(nValue));
                deal_match_ui.set_grid_footer_val();
                return true;
            }

        });

    })

    deal_match_ui.set_left_dealset_menu_privileges = function(id) {
        if (has_rights_deal_match_delete && id != null)        
            deal_match_ui.left_dealset_menu.setItemEnabled('delete');
        else
            deal_match_ui.left_dealset_menu.setItemDisabled('delete');
        
    }

    deal_match_ui.set_right_dealset_menu_privileges = function(id) {
        if (has_rights_deal_match_delete && id != null)        
            deal_match_ui.right_dealset_menu.setItemEnabled('delete');
        else
            deal_match_ui.right_dealset_menu.setItemDisabled('delete');
        
    }

    /**
    * Saved Matched Deals
    */
    deal_match_ui.save_matched_deals = function(active_tab_id) {

        $('#mt_q1').trigger('click');

        // Used for product validation
        var commodity_name = '';
        var uom_name = '';
        var buy_sell = '';
        var dealset1_arr = new Array();
        var dealset2_arr = new Array();
        var validated = true;
        var error_json = {};

        var validate_return = validate_form(deal_match_ui.form_link);
        var attached_form = deal_match_ui.form_link;
    
        if (validate_return === false) {
            return;
        }

        /******Validation***********/
        deal_match_ui.left_grid_ui.forEachRow(function(row_id) {
            deal_match_ui.left_grid_ui.forEachCell(row_id,function(cellObj,ind){
                if (deal_match_ui.left_grid_ui.getColumnId(ind) == 'source_deal_header_id') {
                    dealset1_arr.push(cellObj.getValue());
                }
                if (deal_match_ui.left_grid_ui.getColumnId(ind) == 'commodity') {
                    if (commodity_name != '' && commodity_name != cellObj.getValue()) {
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different product have been selected.'};  
                        validated = false;      
                    } else {
                        commodity_name = cellObj.getValue();
                    }
                }
                /*
                if (deal_match_ui.left_grid_ui.getColumnId(ind) == 'uom') {
                    if (uom_name != '' && uom_name != cellObj.getValue()) {
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different UOM have been selected.'};
                        validated = false;            
                    } else {
                        uom_name = cellObj.getValue();
                    }
                }*/
                if (deal_match_ui.left_grid_ui.getColumnId(ind) == 'buy_sell') {
                    if (buy_sell != '' && buy_sell != cellObj.getValue()) {
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different Buy/Sell have been selected.'};
                        validated = false;            
                    } else {
                        buy_sell = cellObj.getValue();
                    }
                }
            });
        });
        var buy_sell_left = buy_sell;
        var buy_sell = '';
        deal_match_ui.right_grid_ui.forEachRow(function(row_id) {
            deal_match_ui.right_grid_ui.forEachCell(row_id,function(cellObj,ind){
                if (deal_match_ui.right_grid_ui.getColumnId(ind) == 'source_deal_header_id') {
                    dealset2_arr.push(cellObj.getValue());
                }
                if (deal_match_ui.right_grid_ui.getColumnId(ind) == 'commodity') {
                    if (commodity_name != '' && commodity_name != cellObj.getValue()) {
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different product have been selected.'};
                        validated = false;
                    } else {
                        commodity_name = cellObj.getValue();
                    }
                }
                /*
                if (deal_match_ui.right_grid_ui.getColumnId(ind) == 'uom') {
                    if (uom_name != '' && uom_name != cellObj.getValue()) {
                        validated = false;
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different UOM have been selected.'};
                        validated = false;
                    } else {
                        uom_name = cellObj.getValue();
                    }
                }*/
                if (deal_match_ui.right_grid_ui.getColumnId(ind) == 'buy_sell') {
                    if (buy_sell != '' && buy_sell != cellObj.getValue()) {
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different Buy/Sell have been selected.'};
                        validated = false;            
                    } else {
                        buy_sell = cellObj.getValue();
                    }
                }
            });
        });
        if (buy_sell == buy_sell_left) {
            error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with same Buy/Sell have been selected at Both Grids.'};
            validated = false;
        }

        if(!validated) {
            return error_json;
        }
        //Validation for same deals matched
        var common_dealset_arr = _.intersection(dealset1_arr, dealset2_arr);

        if (common_dealset_arr.length > 0) {
            error_json =  {title: 'Alert', type: 'alert', text: 'Same Deal(s) are selected.'};
            return error_json; 

        }
        /******Validation End*********/


        var total_matched_volume1 = parseFloat($('#mt_q1').text().replace(',',''));
        var total_matched_volume2 = parseFloat($('#mt_q2').text().replace(',',''));

        if (total_matched_volume1 != total_matched_volume2) {
            validate_return = false;
            error_json =  {title: 'Alert', type: 'alert', text: 'Matched Volume exceeded.'};
            return error_json;
        }

        var total_matched_volume = (total_matched_volume1 < total_matched_volume2) ? total_matched_volume1 : total_matched_volume2;

        

        var form_xml = "<FormXML ";

        var form_data = attached_form.getFormData();

        for (var a in form_data) {
            field_label = a;
            field_value = form_data[a];
            if (attached_form.getItemType(field_label) == 'calendar') {
                field_value = attached_form.getItemValue(field_label, true);
            } 
            
            form_xml += " " + field_label + "=\"" + field_value + "\"";
            
        }
        form_xml +=  " total_matched_volume =\"" + total_matched_volume + "\"";
        form_xml += "></FormXML>";


        var grid_xml = "<Grid>";
        var inner_grid_xml = '';
        var inner_grid_xml2 = '';


        if (mode == 'i') {
            var data_json = <?php echo $data_json_from_insert;?>;

            for (var row_id1=0; row_id1 < deal_match_ui.left_grid_ui.getRowsNum(); row_id1++)  {

                    var deal_id_index1 = deal_match_ui.left_grid_ui.getColIndexById("source_deal_header_id");
                    var matched_index1 = deal_match_ui.left_grid_ui.getColIndexById("matched");                   
                    if (deal_match_ui.left_grid_ui.cells2(row_id1, matched_index1).getValue() != 0) {
                        inner_grid_xml += '<GridRow ';
                        inner_grid_xml += ' source_deal_header_id="' + deal_match_ui.left_grid_ui.cells2(row_id1, deal_id_index1).getValue()
                                            + '" matched_volume="' + deal_match_ui.left_grid_ui.cells2(row_id1, matched_index1).getValue()
                                            + '" set="1"';
                        inner_grid_xml += '></GridRow>'; 

                    }
                    
                
            }

            /**Dealset2 xml**/
            for (var row_id2=0; row_id2 < deal_match_ui.right_grid_ui.getRowsNum(); row_id2++)  {

                var deal_id_index2 = deal_match_ui.right_grid_ui.getColIndexById("source_deal_header_id");
                var matched_index2 = deal_match_ui.right_grid_ui.getColIndexById("matched");
                
                if (deal_match_ui.right_grid_ui.cells2(row_id2, matched_index2).getValue() != 0) {
                    inner_grid_xml2 += '<GridRow ';
                    inner_grid_xml2 += ' source_deal_header_id="' + deal_match_ui.right_grid_ui.cells2(row_id2, deal_id_index2).getValue()
                                    + '" matched_volume="' + deal_match_ui.right_grid_ui.cells2(row_id2, matched_index2).getValue()
                                    + '" set="2"';
                    inner_grid_xml2 += '></GridRow>'; 

                }
                
            }

            if (inner_grid_xml == '' || inner_grid_xml2 == '') {

                validate_return = false;
                error_json =  {title: 'Error', type: 'alert-error', text: 'Empty Grid Row fetched.'};
                return error_json;
            }
        } else {
        /**** Update mode *********/
            for (var row_id1=0; row_id1 < deal_match_ui.left_grid_ui.getRowsNum(); row_id1++)  {
                var deal_id_index1 = deal_match_ui.left_grid_ui.getColIndexById("source_deal_header_id");
                var matched_index1 = deal_match_ui.left_grid_ui.getColIndexById("matched");
                
                if (deal_match_ui.left_grid_ui.cells2(row_id1, matched_index1).getValue() != 0) {
                    inner_grid_xml += '<GridRow ';
                    inner_grid_xml += ' source_deal_header_id="' + deal_match_ui.left_grid_ui.cells2(row_id1, deal_id_index1).getValue()
                                        + '" matched_volume="' + deal_match_ui.left_grid_ui.cells2(row_id1, matched_index1).getValue()
                                        + '" set="1"';
                    inner_grid_xml += '></GridRow>';

                } 
            }

            for (var row_id2=0; row_id2 < deal_match_ui.right_grid_ui.getRowsNum(); row_id2++)  {
                var deal_id_index2 = deal_match_ui.right_grid_ui.getColIndexById("source_deal_header_id");
                var matched_index2 = deal_match_ui.right_grid_ui.getColIndexById("matched");

                if (deal_match_ui.right_grid_ui.cells2(row_id2, matched_index2).getValue() != 0) {
                    inner_grid_xml2 += '<GridRow ';
                    inner_grid_xml2 += ' source_deal_header_id="' + deal_match_ui.right_grid_ui.cells2(row_id2, deal_id_index2).getValue()
                                    + '" matched_volume="' + deal_match_ui.right_grid_ui.cells2(row_id2, matched_index2).getValue()
                                    + '" set="2"';
                    inner_grid_xml2 += '></GridRow>'; 

                }
            }

            if (inner_grid_xml == '' || inner_grid_xml2 == '') {

                validate_return = false;
                error_json =  {title: 'Error', type: 'alert-error', text: 'Empty Grid Row fetched.'};
                return error_json;
            }

        }
        
        grid_xml += inner_grid_xml + inner_grid_xml2;
        grid_xml += "</Grid>";
        var xml = "<Root>";
        xml += form_xml;
        xml += grid_xml;
        xml += "</Root>";
        xml = xml.replace(/'/g, "\"");
        //console.log(xml);

        /*
        if (mode == 'i') {
            var confirm_msg = 'Do you want to match these deals ?';
            parent.enable_disable_menu('save',false);
            dhtmlx.confirm({
                    title:"Confirmation",
                    ok: "Confirm",
                    text: confirm_msg,
                    callback:function(result){
                        parent.enable_disable_menu('save',true);
                        if (result) {
                            data = {"action": "spa_deal_match", "flag": mode, "link_id" : <?php echo str_replace('tab_', '', $active_tab_id);?>, "xmlValue":xml}
                            result1 = adiha_post_data("return_array", data, "", "", "deal_match_ui.save_matched_deals_callback");
                        }
                    }
            });
        } else {
            */
            parent.enable_disable_menu('save', false);
            data = {"action": "spa_deal_match", "flag": mode, "link_id" : <?php echo str_replace('tab_', '', $active_tab_id);?>, "xmlValue":xml}
            result1 = adiha_post_data("return_array", data, "", "", "deal_match_ui.save_matched_deals_callback");
        /*}*/

        

    }

    deal_match_ui.save_matched_deals_callback = function(return_value) {
        if (return_value[0][0] == 'Success') {            
            parent.enable_disable_menu('save', true);
            parent.link_ui_template.save_matched_deals_callback_parent(mode, 'Success',return_value[0][4], return_value[0][5]);
        } else {
             dhtmlx.message({
                title:'Error',
                type:"alert-error",
                text:return_value[0][4]
            });
             parent.enable_disable_menu('save', true);
        }
        
    }

    deal_match_ui.load_match_grids = function() {

        deal_match_ui.deal_match_ui.cells('b').progressOn();
        deal_match_ui.deal_match_ui.cells('c').progressOn();

        if (mode == 'i') {
            
            //from deal match TAB
            var data_json = <?php echo $data_json_from_insert;?>;
            
            
            //
            for (i=1; i<=2; i++) { 
                var attached_grid = (i==1) ? deal_match_ui.left_grid_ui : deal_match_ui.right_grid_ui;
                var len_arr = (i==1) ? data_json.grids[0].left_grid_ui[0].rows : data_json.grids[1].right_grid_ui[0].rows;
                var grid_menu = (i==1) ? deal_match_ui.left_dealset_menu : deal_match_ui.right_dealset_menu;

                grid_menu.setItemDisabled('delete');

                var grid_xml = '<Grid>';
                deal_ids_arr = new Array();
                for (var z=0;z<len_arr.length;z++) {
                    deal_ids_arr.push(len_arr[z].id);
                    grid_xml += '<GridRow source_deal_header_id="' + len_arr[z].id + '" matched="' + len_arr[z].matched + '" remaining="' + len_arr[z].remaining + '" ></GridRow>'
                }
                
                grid_xml += "</Grid>";
                var xml = "<Root>" +  grid_xml + "</Root>";
                xml = xml.replace(/'/g, "\"");

                var deal_ids = deal_ids_arr.toString();


                var sql_param = {
                        "sql":"EXEC spa_deal_match @flag = 't', @xmlValue = '" + xml + "', @source_deal_header_id = '" + deal_ids +"',  @ignore_source_deal_header_id= ''",
                        "grid_type":"g"
                    };
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;

                if (i == 2) {
                    attached_grid.clearAndLoad(sql_url,deal_match_ui.load_grid_footer);
                } else {
                    attached_grid.clearAndLoad(sql_url);
                }

                if ($('#mt_q'+i).length == 1) {
                    attached_grid.detachFooter(0);
                }
                
            }
            //

            /*
            for (var z=0;z<data_json.grids[0].left_grid_ui[0].rows.length;z++) {
                deal_match_ui.left_grid_ui.addRow(z+newId,data_json.grids[0].left_grid_ui[0].rows[z].data);
            }    

            for (var z=0;z<data_json.grids[1].right_grid_ui[0].rows.length;z++) {
                deal_match_ui.right_grid_ui.addRow(z+newId,data_json.grids[1].right_grid_ui[0].rows[z].data);
            }

            

            for (i=1; i<=2; i++) {                        
                var attached_grid = (i==1) ? deal_match_ui.left_grid_ui : deal_match_ui.right_grid_ui;
                if ($('#mt_q'+i).length == 1) {
                    attached_grid.detachFooter(0);
                }

                if (i == 2) {
                    setTimeout(deal_match_ui.load_grid_footer(),5);
                }
                
            }*/
            
        } else {
            // update mode

            for (i=1; i<=2; i++) { 
                var attached_grid = (i==1) ? deal_match_ui.left_grid_ui : deal_match_ui.right_grid_ui;

                var sql_param = {
                        "sql":"EXEC spa_deal_match @flag = 't', @link_id = <?php echo str_replace('tab_', '', $active_tab_id);?>,  @set= '"+i+"'",
                        "grid_type":"g"
                    };
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;

                if (i == 2) {
                    attached_grid.clearAndLoad(sql_url,deal_match_ui.load_grid_footer);
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
    deal_match_ui.onclick_menu_left = function(id) {
        switch (id) {
            case 'refresh':
                deal_match_ui.refresh_deal_grid(deal_match_ui.left_grid_ui,1);
                break;

            case 'add':
                var transaction_type = 400;
                deal_match_ui.select_deal(deal_match_ui.left_grid_ui,transaction_type);
                break;

            case 'delete':
                deal_match_ui.left_grid_ui.deleteSelectedRows();
                deal_match_ui.left_dealset_menu.setItemDisabled('delete');
                setTimeout(deal_match_ui.set_grid_footer_val(),2);
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

     deal_match_ui.onclick_menu_right = function(id) {
        switch (id) {
            case 'refresh':
                deal_match_ui.refresh_deal_grid(deal_match_ui.right_grid_ui,2);
                break;

            case 'add':
                var transaction_type = 400;
                deal_match_ui.select_deal(deal_match_ui.right_grid_ui,transaction_type);
                break;

            case 'delete':
                deal_match_ui.right_grid_ui.deleteSelectedRows();
                deal_match_ui.right_dealset_menu.setItemDisabled('delete');
                setTimeout(deal_match_ui.set_grid_footer_val(),2);
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

    deal_match_ui.refresh_deal_grid = function(grid_obj,grid_num) {

        if (grid_num == 1)
            deal_match_ui.deal_match_ui.cells('b').progressOn();
        else
            deal_match_ui.deal_match_ui.cells('c').progressOn();

        var grid_menu = (grid_num==1) ? deal_match_ui.left_dealset_menu : deal_match_ui.right_dealset_menu;
        grid_menu.setItemDisabled('delete');

        if (mode == 'i') {
            
            //from deal match TAB
            var data_json = <?php echo $data_json_from_insert;?>;
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

            var deal_ids = deal_ids_arr.toString();


            var sql_param = {
                    "sql":"EXEC spa_deal_match @flag = 't', @xmlValue = '" + xml + "', @source_deal_header_id = '" + deal_ids +"',  @ignore_source_deal_header_id= ''",
                    "grid_type":"g"
                };
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            grid_obj.clearAndLoad(sql_url,deal_match_ui.set_grid_footer_val);
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
                        "sql":"EXEC spa_deal_match @flag = 't', @link_id = <?php echo str_replace('tab_', '', $active_tab_id);?>,  @set= '"+grid_num+"'",
                        "grid_type":"g"
                    };
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;

                grid_obj.clearAndLoad(sql_url,deal_match_ui.set_grid_footer_val);



        }
        
    }

     deal_match_ui.select_deal = function(obj, trans_type) {
        
       // Collect deals from create and view deals page.
        var col_list = 'id'; //id for source_deal_header_id       
        var view_deal_window = new dhtmlXWindows();
        var win_id = 'w1';
        //deal_win should be global variable to access from callback function 'deal_match_ui.callback_select_deal' to close child window ie deal window
        deal_win = view_deal_window.createWindow(win_id, 0, 0, 600, 600);
        deal_win.setModal(true);
        
        var win_title = 'Select Deal';
        var win_url = '../maintain_deals/maintain.deals.new.php';  
        var params = {read_only:true,col_list:col_list,deal_select_completed:'deal_match_ui.process_selected_match_deal',trans_type:trans_type,call_from:'deal_match'};
        
        deal_win.setText(win_title);
        deal_win.maximize();
        processing_grid_obj = obj;
        deal_win.attachURL(win_url, false, params);        
        
    } //end deal_match_ui.select_deal()
    
   
    deal_match_ui.process_selected_match_deal = function(result) {
        //close child window
        var ignore_deal_ids = processing_grid_obj.collectValues(processing_grid_obj.getColIndexById("source_deal_header_id"));
       
        var ignore_deal_id = ignore_deal_ids.toString();
        deal_win.close();

        if (result.length > 0) {
            var deal_ids = result.toString();
            var data = {
                            "action": "spa_deal_match",
                            "flag":'t',
                            "source_deal_header_id": deal_ids,
                            "ignore_source_deal_header_id": ignore_deal_id
                        };
            
            adiha_post_data('return_array', data, '', '', 'deal_match_ui.append_to_grid', ''); 
        } 
            
    }

    deal_match_ui.append_to_grid = function(result) {

        var rowId = (new Date()).valueOf();
        for (var z=0;z<processing_grid_obj.getRowsNum();z++) {
            processing_grid_obj.setRowId(z,z+rowId);
        }

        processing_grid_obj.parse(result, "jsarray");
        for (var z=0;z<processing_grid_obj.getRowsNum();z++) {
            processing_grid_obj.setRowId(z,z+rowId);
        }

        
        setTimeout(deal_match_ui.set_grid_footer_val(),2);
    }

    deal_match_ui.set_grid_footer_val = function() {
        for (var i =1; i<3; i++) {

            var attached_grid = (i == 1) ? deal_match_ui.left_grid_ui : deal_match_ui.right_grid_ui;
        
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
         deal_match_ui.deal_match_ui.cells('b').progressOff();
          deal_match_ui.deal_match_ui.cells('c').progressOff();

    }

    deal_match_ui.load_grid_footer2 = function(attached_grid, i) {
        attached_grid.filterByAll();
        if ($('#mt_q'+i).length == 0) {
            var nrQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("actual_volume"));
            var srQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("matched"));
            var nrS_val = sumColumn(attached_grid,attached_grid.getColIndexById("remaining"));

            attached_grid.attachFooter(",<div id='footer_iu_div"+i+"'><div style='float:left;padding-right:20px;font-weight:bold;'>Actual Volume : <span id='av_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;font-weight:bold;'>Matched : <span id='mt_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;font-weight:bold;'>Remaining : <span id='rm_q"+i+"'>0</span></div></div>,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan",["height:30px;text-align:left;font-weight:bold;"]);
             
             var nrQ = document.getElementById("av_q"+i);
                nrQ.innerHTML = nrQ_val;
            var srQ = document.getElementById("mt_q"+i);
                srQ.innerHTML = srQ_val;
            var nrS = document.getElementById("rm_q"+i);
                nrS.innerHTML = nrS_val;
        } 
        
        deal_match_ui.deal_match_ui.cells('b').setWidth(deal_match_ui.deal_match_ui.cells('b').getWidth() + 0.1);
        
        if (i == 1)
            deal_match_ui.deal_match_ui.cells('b').progressOff();
        else 
            deal_match_ui.deal_match_ui.cells('c').progressOff();
        
    }

    deal_match_ui.load_grid_footer = function(stage) {        
        if (mode == 'i') {
            for (var i=1;i<3;i++) {
                var attached_grid = (i ==1) ? deal_match_ui.left_grid_ui : deal_match_ui.right_grid_ui;  
                deal_match_ui.load_grid_footer2(attached_grid,i);        
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
</script>>
</html>