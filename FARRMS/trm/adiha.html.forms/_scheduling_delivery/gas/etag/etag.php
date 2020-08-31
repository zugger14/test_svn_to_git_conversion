<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    <?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;
    
    $as_of_date = "2016-01-01";//date('Y-m-d');
    
    $rights_etag_view = 10163100;
    $rights_etag_detail_iu = 10163110;
    $rights_etag_match_unmatch = 10163111;

    $has_rights_etag_view = false;
    $has_rights_etag_detail_iu = false;
    $has_rights_etag_match_unmatch = false;

    list (
        $has_rights_etag_view,
        $has_rights_etag_detail_iu,
        $has_rights_etag_match_unmatch
        )
        = build_security_rights(
        $rights_etag_view,
        $rights_etag_detail_iu,
        $rights_etag_match_unmatch
    );
    
    $layout_json = '[
                        {id: "a", text: "Apply Filter", header: true, height:90},
                        {id: "b", text: "Filter Criteria", header: true, height:165},
                        {id: "c", text: "Tags", header: true},
                        {id: "d", text: "Deal", header: true}
                    ]';
    $layout_obj = new AdihaLayout();
    $filter_form_obj = new AdihaForm();
    
    $form_namespace = 'etag';
    
    echo $layout_obj->init_layout('etag_layout', '', '4J', $layout_json, $form_namespace);
       
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163100', @template_name='Etag', @group_name='General'";
    $filter_arr = readXMLURL2($filter_sql);
    $form_json = $filter_arr[0]['form_json'];
    
    $form_name = 'filters_form';
    echo $layout_obj->attach_form($form_name, 'b');
    $filter_form_obj->init_by_attach($form_name, $form_namespace);
    echo $filter_form_obj->load_form($form_json);
    echo $filter_form_obj->set_input_value($form_namespace.'.'.$form_name, 'as_of_date', $as_of_date);
    
    $menu_name = 'etag_menu';
    $menu_json = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
            {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                {id:"delete", text:"Delete", img:"delete.gif", imgdis: "delete_dis.gif", disabled: true}
            ]},
            {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", disabled: true, items:[
                {id:"excel", text:"Excel", img:"excel.gif"},
                {id:"pdf", text:"PDF", img:"pdf.gif"}
            ]},
            {id:"action", text:"Actions", img:"action.gif", imgdis:"action_dis.gif", items:[
                {id:"refresh_tags", text:"Load Tag", img:"refresh.gif"},
                {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", disabled: true}
            ]},
            {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 0},
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $form_namespace.'.tag_menu_click');
    
    $menu_name = 'etag_deal_menu';
    $menu_json = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
            {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                {id:"delete_deal", text:"Delete", img:"delete.gif", imgdis: "delete_dis.gif", disabled: true}
            ]},
            {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", disabled: true, items:[
                {id:"excel_deal", text:"Excel", img:"excel.gif"},
                {id:"pdf_deal", text:"PDF", img:"pdf.gif"}
            ]},
            {id:"action", text:"Actions", img:"action.gif", imgdis:"action_dis.gif", items:[
                {id:"unmatch", text:"Unmatch", img:"unmatch.gif", imgdis:"unmatch_dis.gif", disabled: true}
            ]},
            {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 0},
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'd', $menu_json, $form_namespace.'.tag_deal_menu_click');
    
    echo $layout_obj->close_layout();
    
    $etag_grid_sql = "EXEC spa_adiha_grid 's', 'Etag'";
    $etag_grid_arr = readXMLURL2($etag_grid_sql);
    $etag_column_name = $etag_grid_arr[0]['column_name_list'];
    $etag_column_label = $etag_grid_arr[0]['column_label_list'];
    $etag_column_type = $etag_grid_arr[0]['column_type_list'];
    $etag_column_width = $etag_grid_arr[0]['column_width'];
    $etag_column_visibility = $etag_grid_arr[0]['set_visibility'];
    
    $etag_deal_grid_sql = "EXEC spa_adiha_grid 's', 'EtagDeal'";
    $etag_deal_grid_arr = readXMLURL2($etag_deal_grid_sql);
    $etag_deal_column_name = $etag_deal_grid_arr[0]['column_name_list'];
    $etag_deal_column_label = $etag_deal_grid_arr[0]['column_label_list'];
    $etag_deal_column_type = $etag_deal_grid_arr[0]['column_type_list'];
    $etag_deal_column_width = $etag_deal_grid_arr[0]['column_width'];
    $etag_deal_column_visibility = $etag_deal_grid_arr[0]['set_visibility'];
    ?>
    <div id="window_label" style="display: none;"></div>
    <div id="window_name" style="display: none;"></div>
    <div id="file_path" style="display: none;"></div>
    <script type="text/javascript">
	    var has_rights_etag_detail_iu = <?php echo (($has_rights_etag_detail_iu) ? $has_rights_etag_detail_iu : '0'); ?>;
		var has_rights_etag_match_unmatch = <?php echo (($has_rights_etag_match_unmatch) ? $has_rights_etag_match_unmatch : '0'); ?>;
        var expand_state_deal = 0;
        var expand_state = 0;
        $(function(){
            filter_obj = etag.etag_layout.cells('a').attachForm();
            var layout_cell_obj = etag.etag_layout.cells('b');
            load_form_filter(filter_obj, layout_cell_obj, '10163100', 2);
            
            //etag.etag_layout.cells("c").fixSize(true, true);
            etag.etag_layout.cells('a').collapse();
        });
        
        etag.tag_menu_click = function (id) {
            var ifr_etag = etag.etag_layout.cells("c").getFrame();
            
            switch(id) {
                case "refresh":
                    etag.etag_layout.cells('a').collapse();
                    etag.etag_layout.cells('b').collapse();
                    refresh_etag_grid();
                    break;
                case "refresh_tags":
                    etag.etag_layout.cells('a').collapse();
                    etag.etag_layout.cells('b').collapse();
                    refresh_etag_grid();
                    break;
                case "delete":
                    delete_etag_grid_row();
                    break;
                case "pdf":
                    etag.etag_grid.toPDF(js_php_path +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case "excel":
                    etag.etag_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "save":
                    save_detail();
                    break;
                case "expand_collapse":
                    if (expand_state == 0) 
                        openAllEtag();
                    else
                        closeAllEtag();
                    break;
                default:
                break;
            }
        }
        
        etag.tag_deal_menu_click = function (id) {
            switch(id) {
                case "refresh":
                    etag.etag_layout.cells('a').collapse();
                    etag.etag_layout.cells('b').collapse();
                    refresh_etag_deal_grid();
                    break;
                case "delete_deal":
                    delete_deal_grid_row();
                    break;
                case "unmatch":
                    unmatch();
                    break;
                case "pdf_deal":
                    etag.etag_deal_grid.toPDF(js_php_path +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case "excel_deal":
                    etag.etag_deal_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "expand_collapse":
                    if (expand_state_deal == 0) 
                        openAllDeals();
                    else
                        closeAllDeals();
                    break;
                default:
                break;
            }
        }
        
        /**
    	*[openAllDeals Open All nodes of Deal Grid]
    	*/
    	openAllDeals = function() {
           etag.etag_deal_grid.expandAll();
           expand_state_deal = 1;
    	}
        
        /**
    	*[closeAllDeals Close All nodes of Deal Grid]
    	*/
    	closeAllDeals = function() {
           etag.etag_deal_grid.collapseAll();
           expand_state_deal = 0;
    	}
        
        /**
    	*[openAllDeals Open All nodes of Deal Grid]
    	*/
    	openAllEtag = function() {
           etag.etag_grid.expandAll();
           expand_state = 1;
    	}
        
        /**
    	*[closeAllDeals Close All nodes of Deal Grid]
    	*/
    	closeAllEtag = function() {
           etag.etag_grid.collapseAll();
           expand_state = 0;
    	}
        
        function delete_deal_grid_row() {
            var select_id = etag.etag_deal_grid.getSelectedId();
        	if (select_id != null) {
                etag.etag_deal_grid.deleteSelectedRows();
        	}
        }
        
        function delete_etag_grid_row() {
            var select_id = etag.etag_grid.getSelectedId();
        	if (select_id != null) {
                etag.etag_grid.deleteSelectedRows();
        	}
        }
        
        function refresh_etag_grid() {
            var header_name = '<?php echo $etag_column_label; ?>';
            var header_id = '<?php echo $etag_column_name; ?>';
            var column_type = '<?php echo $etag_column_type; ?>';
            var column_widths = '<?php echo $etag_column_width; ?>';
            var column_visibility = '<?php echo $etag_column_visibility; ?>';
            
            etag.etag_grid = etag.etag_layout.cells('c').attachGrid();
            etag.etag_layout.cells('c').attachStatusBar({
                                            height: 30,
                                            text: '<div id="pagingArea_c"></div>'
                                        });
            etag.etag_grid.setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
            etag.etag_grid.enablePaging(true, 100, 0, 'pagingArea_c'); 
            etag.etag_grid.setPagingSkin('toolbar'); 
            etag.etag_grid.setHeader(header_name);
            etag.etag_grid.setColumnIds(header_id);
            etag.etag_grid.setColTypes(column_type);
            etag.etag_grid.setColumnsVisibility(column_visibility);
            etag.etag_grid.setInitWidths(column_widths);
            etag.etag_grid.init();
            etag.etag_grid.enableHeaderMenu();
            etag.etag_grid.enableColumnAutoSize(true);
            etag.etag_grid.enableMathEditing(true);
            etag.etag_grid.enableDragAndDrop(true);
            etag.etag_grid.enableMercyDrag(true);
            etag.etag_grid.attachEvent("onRowSelect", select_tag_row);
            etag.etag_grid.attachEvent("onBeforeDrag",function(id){
                // denies dragging if user data exists
                var has_children = etag.etag_grid.hasChildren(id);
                if (has_children != 0) return false;
                 //allows dragging in any other case
                return true;                                        
            });
            etag.etag_grid.attachEvent("onDrag",function(sid,tid){
                return false;
            });
			
			var from_hour = etag.filters_form.getItemValue('from_hour');
			var to_hour = etag.filters_form.getItemValue('to_hour');
            var hide_hour_arr = new Array();
			
			for (cnt = 1; cnt < 26; cnt++) {	
				if (cnt < from_hour || cnt > to_hour) {
					hide_hour_arr.push(cnt+2);
				}
			}
			
			for (cnt = 0; cnt < hide_hour_arr.length; cnt++) {
				etag.etag_grid.setColumnHidden(hide_hour_arr[cnt], true);
			}
			
            form_data = etag.filters_form.getFormData();
            var filter_param = '';
            for (var a in form_data) {
                if (form_data[a] != '' && form_data[a] != null && a != 'from_hour' && a != 'to_hour' && a != 'match_status') {
    
                    if (etag.filters_form.getItemType(a) == 'calendar') {
                        value = etag.filters_form.getItemValue(a, true);
                    } else {
                        value = form_data[a];
                    }
                    
                    filter_param += "&" + a + '=' + value;
                }
            }
            var param = {
                "flag": "s",
                "action":"spa_etag",
                "grid_type":"tg",
                "grouping_column":"oati_tag_id,id"
            };
        
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param + filter_param;
            
            etag.etag_grid.clearAndLoad(param_url, function(){
                enable_disable_tag_menu("delete", false);
                enable_disable_tag_menu("t2", true);
                enable_disable_tag_menu("save", true);
                enable_disable_tag_menu("expand_collapse", true);
				etag.etag_grid.expandAll();
                expand_state = 1;
            });
			
			
        }
        
        function refresh_etag_deal_grid() {
            var header_name = '<?php echo $etag_deal_column_label; ?>';
            var header_id = '<?php echo $etag_deal_column_name; ?>';
            var column_type = '<?php echo $etag_deal_column_type; ?>';
            var column_widths = '<?php echo $etag_deal_column_width; ?>';
            var column_visibility = '<?php echo $etag_deal_column_visibility; ?>';
            
            etag.etag_deal_grid = etag.etag_layout.cells('d').attachGrid();
            etag.etag_layout.cells('d').attachStatusBar({
                                            height: 30,
                                            text: '<div id="pagingArea_d"></div>'
                                        });
            etag.etag_deal_grid.setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
            etag.etag_deal_grid.enablePaging(true, 100, 0, 'pagingArea_d'); 
            etag.etag_deal_grid.setPagingSkin('toolbar'); 
            etag.etag_deal_grid.setHeader(header_name);
            etag.etag_deal_grid.setColumnIds(header_id);
            etag.etag_deal_grid.setColTypes(column_type);
            etag.etag_deal_grid.setColumnsVisibility(column_visibility);
            etag.etag_deal_grid.setInitWidths(column_widths);
            etag.etag_deal_grid.init();
            etag.etag_deal_grid.enableHeaderMenu();
            etag.etag_deal_grid.enableColumnAutoSize(true);
            etag.etag_deal_grid.enableMathEditing(true);
            etag.etag_deal_grid.enableDragAndDrop(true);
            etag.etag_deal_grid.enableMercyDrag(true);
            etag.etag_deal_grid.attachEvent("onRowSelect", etag.select_row);
            etag.etag_deal_grid.attachEvent("onGridReconstructed", find_matched_percentage);
            etag.etag_deal_grid.attachEvent("onDrop", trigger_match_process);
            etag.etag_deal_grid.attachEvent("onDrag",function(sid,tid){
                var has_children = etag.etag_deal_grid.hasChildren(tid);
                if (has_children == 0) return false;
                return true;
            });
            etag.etag_deal_grid.attachEvent("onBeforeDrag",function(id){
                return false;                                        
            });
            
			var from_hour = etag.filters_form.getItemValue('from_hour');
			var to_hour = etag.filters_form.getItemValue('to_hour');
            var hide_hour_arr = new Array();
			
			for (cnt = 1; cnt < 26; cnt++) {	
				if (cnt < from_hour || cnt > to_hour) {
					hide_hour_arr.push(cnt+2);
				}
			}
			
			for (cnt = 0; cnt < hide_hour_arr.length; cnt++) {
				etag.etag_deal_grid.setColumnHidden(hide_hour_arr[cnt], true);
			}
			
            form_data = etag.filters_form.getFormData();
            var filter_param = '';
            for (var a in form_data) {
                if (form_data[a] != '' && form_data[a] != null && a != 'from_hour' && a != 'to_hour') {
    
                    if (etag.filters_form.getItemType(a) == 'calendar') {
                        value = etag.filters_form.getItemValue(a, true);
                    } else {
						value = form_data[a];
                    }
                    
                    filter_param += "&" + a + '=' + value;
                }
            }
            var param = {
                "flag": "t",
                "action":"spa_etag",
                "grid_type":"tg",
                "grouping_column":"deal,id"
            };
        
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param + filter_param;
            
            etag.etag_deal_grid.clearAndLoad(param_url, function() {
                enable_disable_tag_deal_menu("delete_deal", false);
                enable_disable_tag_deal_menu("unmatch", false);
                enable_disable_tag_deal_menu("t2", true);
                enable_disable_tag_deal_menu("expand_collapse", true);
				etag.etag_deal_grid.expandAll();
                find_matched_percentage();				
                expand_state_deal = 1;
            });
        }
        
        function enable_disable_tag_menu(name, enable) {
            if(enable)
                etag.etag_menu.setItemEnabled(name);
            else    
                etag.etag_menu.setItemDisabled(name);
        }
        
        function enable_disable_tag_deal_menu(name, enable) {
            if(enable)
                etag.etag_deal_menu.setItemEnabled(name);
            else    
                etag.etag_deal_menu.setItemDisabled(name);
        }
        
        function save_complete(result) {
            if (result[0]["errorcode"] == 'Success') {
                var ifr_etag = etag.etag_layout.cells("c").getFrame();
                var data = return_sp_url('s', 'json');
                ifr_etag.contentWindow.tag_refresh(data);
            }
        }
        
        function create_detail_window(file_path, window_name, window_label) {
            var width = 1000;
            var height = 400;
        
            var dhxWins = new dhtmlXWindows();
            var win = dhxWins.createWindow(window_name, 0, 0, width, height);
            win.attachURL(file_path);
            win.setText(window_label);
            win.centerOnScreen();
        }
        
        function trigger_match_process(id_source, id_target, id_dropped, grid_source, grid_target) {
            var tag_id = this.cells(id_dropped, 0).getValue();
            var deal_string = this.cells(id_target, 0).getValue();
            var matched_deal = this.cells(id_dropped, 2).getValue();
            var deal_id = deal_string.substring(0, deal_string.indexOf(","));
            
            if (matched_deal != '' && matched_deal != 0) {
                var message = 'Tag is already matched to deal - ' + matched_deal + '. Are you sure you want to match it?';
                
                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: message,
                    callback: function(result) {
                        if (result) {
                            match_tag(this, tag_id, deal_id, id_dropped, grid_source, grid_target, matched_deal);
                        } else {
                            grid_target.deleteRow(id_dropped);
                        }
                    }
                });
            } else {
                match_tag(this, tag_id, deal_id, id_dropped, grid_source, grid_target, matched_deal);
            }
        }
        
        function match_tag(object, tag_id, deal_id, id_dropped, grid_source, grid_target, matched_deal) {
            matched_deal_g = matched_deal;
            deal_id_g = deal_id;
            id_dropped_g = id_dropped;
            grid_source_g = grid_source;
            grid_target_g = grid_target;
            
            var param = {
                            "flag": "m",
                            "action": "spa_etag",
                            "etag_id": tag_id,
                            "deal_id": deal_id
                        };
                       
            var return_value = adiha_post_data('alert', param, '', '', 'match_tag_callback', '');
        }
            
        function match_tag_callback(result) {
            if (result[0]["errorcode"] == 'Success') {
                grid_source_g.selectRowById(id_dropped_g);
                grid_source_g.cells(id_dropped_g,2).setValue(deal_id_g);
                
                if ((matched_deal_g != '' && matched_deal_g != 0) || (grid_source_g == grid_target_g)) {
                    var match_value = grid_target_g.cells(id_dropped_g,1).getValue();
                    var search_result = grid_target_g.findCell(match_value, 1);
                    search_result = search_result.toString().replace(',1', '');
                    
                    var row_ids_array = new Array();
                    row_ids_array = search_result.split(',');
                    
                    jQuery.each(row_ids_array, function(i, val) {
                        if (val != id_dropped_g) {
                            grid_target_g.deleteRow(val);
                        }
                    });
                }
    
                var parent_id = grid_target_g.getParentId(id_dropped_g);
                var no_of_child = grid_target_g.hasChildren(parent_id);
                grid_target_g.changeRowId(id_dropped_g, 'sub_' + parent_id + '_' + no_of_child);
				refresh_etag_deal_grid();
            }
        }
        
        function unmatch() {
            var id = etag.etag_deal_grid.getSelectedRowId();
            var tag_id = etag.etag_deal_grid.cells(id, etag.etag_deal_grid.getColIndexById('deal')).getValue();
            
            var param = {
                            "flag": "n",
                            "action": "spa_etag",
                            "etag_id": tag_id
                        };
                        
            var return_value = adiha_post_data('alert', param, '', '', 'unmatch_tag_callback', '');
        }
        
        function unmatch_tag_callback(result) {
            if (result[0]['errorcode'] == 'Success') {
                delete_deal_grid_row();
                enable_disable_tag_deal_menu("unmatch", false);
                enable_disable_tag_deal_menu("delete_deal", false);
                
                refresh_etag_grid();
				refresh_etag_deal_grid();
            }
        }
        
        function openHyperLink(func_id, arg1, arg2, arg3, call_back_function) {
            etag_id = arg1;
            var data = {action : "spa_send_message"
                        , flag : 'z'
                        , application_functions : func_id}
            var result = adiha_post_data('return_array', data, '', '', 'open_call_back');
        }
        
        function open_call_back(result) {
            var param = 'mode=u&etag_id=' + etag_id;
            var file_path = app_form_path + result[0][0] + '?' + param;
            var window_name = result[0][1];
            var window_label = result[0][2];
            create_detail_window(file_path, window_name, window_label);
        }
        
        etag.select_row = function(id, ind) {
            var selected_row_val = etag.etag_deal_grid.cells(id, etag.etag_deal_grid.getColIndexById('tag_id')).getValue();
            
            if (selected_row_val != '' && selected_row_val != 'Deal') {
				if (has_rights_etag_match_unmatch){
					enable_disable_tag_deal_menu("unmatch", true);
				}
            } else {
                enable_disable_tag_deal_menu("unmatch", false);
            }
			if(has_rights_etag_detail_iu){
				enable_disable_tag_deal_menu("delete_deal", true);
			}
        }
                
        function select_tag_row(id, ind) {
            enable_disable_tag_menu("delete", true);
        }
        
        function find_matched_percentage() {
            etag.etag_deal_grid.forEachRow(function(parent_id) {
                if (etag.etag_deal_grid.hasChildren(parent_id) != 0) {
                    var tag_sum = 0;
                    var deal_sum = 0;
                    var matched_percentage = 0;
    
                    etag.etag_deal_grid._h2.forEachChild(parent_id,function(element){
                        var row_type = etag.etag_deal_grid.cells(element.id, 1).getValue();
    
                        if(row_type != '') {
                            for(var cell_index = 4; cell_index < etag.etag_deal_grid.getColumnsNum(); cell_index++){
                                var cell_value = etag.etag_deal_grid.cells(element.id, cell_index).getValue();
    
                                if (cell_value != '') {
                                    if (row_type != 'Deal') {
                                        tag_sum = +tag_sum + +cell_value;
                                    } else {
                                        deal_sum = +deal_sum + +cell_value;
                                    }
                                }
                            }
                        }
                    });
    
                    if (deal_sum != 0) {
                        matched_percentage = parseFloat(parseFloat(tag_sum)/parseFloat(deal_sum)) * 100;
                    } else {
                        matched_percentage = 0;
                    }
    
                    var previous_value = '';
                    previous_value = etag.etag_deal_grid.cells(parent_id, 0).getValue();
                    index = previous_value.indexOf(', Matched Percentage');
    
                    if (index != -1) {
                        previous_value = previous_value.substring(0, index);
                    }
    
                    if (previous_value != '') {
                        previous_value += " , Matched Percentage = " + Math.abs(parseFloat(matched_percentage).toFixed(2)) + "%";
                        etag.etag_deal_grid.cells(parent_id, 0).setValue(previous_value);
                    }
                    previous_value = '';
                }
            });
        }
        
        function save_detail() {
            var xml = get_grd_etag_data();
            var as_of_date = etag.filters_form.getItemValue('as_of_date', true);
            var param = {
    	            "flag": "u",
    	            "action": "spa_etag_detail",
                    "as_of_date": as_of_date,
    	            "xml": xml
    	        };
                
            adiha_post_data('alert', param, '', '', 'save_complete', '');
        }
        
        function get_grd_etag_data() {
            var ps_xml = "<Root>";
            etag.etag_grid.forEachRow(function(parent_id) {
                etag.etag_grid._h2.forEachChild(parent_id, function(element) {
                    ps_xml = ps_xml + "<PSRecordset ";
                    for (var cell_index = 0; cell_index < etag.etag_grid.getColumnsNum(); cell_index++) {
                        if (cell_index == 0) {
                            ps_xml = ps_xml + " " + 'id="' + etag.etag_grid.cells(element.id, cell_index).getValue().replace(/(<([^>]+)>)/ig, "") + '"';
                        } else if(cell_index == 1) {
                            ps_xml = ps_xml + " "  + 'oati_tag_id="' + etag.etag_grid.cells(element.id, cell_index).getValue().replace(/(<([^>]+)>)/ig, "") + '"';
                        } else {
                            ps_xml = ps_xml + " " + etag.etag_grid.getColumnId(cell_index) + '="' + etag.etag_grid.cells(element.id, cell_index).getValue().replace(/(<([^>]+)>)/ig, "") + '"';
                        }
                    }
                    ps_xml = ps_xml + " ></PSRecordset> ";
                });
            });
            ps_xml = ps_xml + "</Root>";
            return ps_xml;
        }
		
		function open_etag_hyperlink(etag_id, oati_tag_id) {
			alert(1);
		}
    </script>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            padding: 0px;
            background-color: #ebebeb;
            overflow: hidden;
        }
    </style>