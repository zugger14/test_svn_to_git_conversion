<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <style type="text/css">
        #overlay {
            visibility: hidden;
            position: absolute;
            left: 0px;
            top: 0px;
            width:100%;
            height:100%;
            text-align:center;
            z-index: 1000;
            background-color: rgba(76, 108, 82, 0.4);
        }
        #overlay div {
            width:300px;
            margin: 100px auto;
            background-color: #F4F4F4;
            border:1px solid #000;
            padding:15px;
            text-align:center;
        }
    </style>
</head>
<body>
<?php 
    $form_namespace = 'dealPricing';
    $deal_id = (isset($_REQUEST["deal_id"]) && $_REQUEST["deal_id"] != '') ? get_sanitized_value($_REQUEST["deal_id"]) : 'NULL';
    $group_id = (isset($_REQUEST["group_id"]) && $_REQUEST["group_id"] != '') ? get_sanitized_value($_REQUEST["group_id"]) : 'NULL';
    $detail_id = (isset($_REQUEST["detail_id"]) && $_REQUEST["detail_id"] != '') ? get_sanitized_value($_REQUEST["detail_id"]) : 'NULL';
    $pricing_provisional = (isset($_REQUEST["pricing_provisional"]) && $_REQUEST["pricing_provisional"] != '') ? get_sanitized_value($_REQUEST["pricing_provisional"]) : 'NULL';
    $pricing_process_id = (isset($_REQUEST["pricing_process_id"]) && $_REQUEST["pricing_process_id"] != '') ? get_sanitized_value($_REQUEST["pricing_process_id"]) : 'NULL';
    $formula_process_id = (isset($_REQUEST["formula_process_id"]) && $_REQUEST["formula_process_id"] != '') ? get_sanitized_value($_REQUEST["formula_process_id"]) : 'NULL';
    $leg = (isset($_REQUEST["leg"]) && $_REQUEST["leg"] != '') ? get_sanitized_value($_REQUEST["leg"]) : 'NULL';

    $sp_pricing_type = "EXEC spa_deal_pricing @flag='p', @source_deal_detail_id=" . $detail_id . ",  @group_id=" . $group_id . ", @pricing_provisional='" . $pricing_provisional . "', @pricing_process_id='".$pricing_process_id."'";
    $pricing_type_array = readXMLURL2($sp_pricing_type);

    if (is_array($pricing_type_array) && sizeof($pricing_type_array) > 0) { 
        $pricing_type = ($pricing_type_array[0]['pricing_type'] != '') ? $pricing_type_array[0]['pricing_type'] : 'a';
        $pricing_type2 = ($pricing_type_array[0]['pricing_type2'] != '') ? $pricing_type_array[0]['pricing_type2'] : '103600';
    } else {
        $pricing_type = 'a';
        $pricing_type2 = '103600';
    }    

    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();

    $rights_deal_edit = 10131010;

    list (
         $has_rights_deal_edit
    ) = build_security_rights(
         $rights_deal_edit
    );

    $sp_url = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 103600";
    $pricing_type2_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, false, $pricing_type2, 2);

    $sp_url = "SELECT 'a' [value], 'Average' [text], 1 [enable] UNION ALL SELECT 's', 'Sum', 1 UNION ALL SELECT 'w', 'WACOG', 1";
    $pricing_type_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, false, $pricing_type, 2);
    
    $layout_json = '[{id: "a", header:false, height:120},{id: "b", header:false}]';  

    $form_json = '[ 
                    {"type": "settings", "position": "label-top", "offsetLeft": 10},
                    {type:"combo", name: "pricing_type", label:"Pricing Aggregation", "labelWidht":160, filtering:true, "inputWidth":150, "options": ' . $pricing_type_json . '},
                    {"type":"newcolumn"},
                    {type:"combo", name: "pricing_type2", label:"Pricing Type", "labelWidht":160, filtering:true, "inputWidth":150, "options": ' . $pricing_type2_json . '}
                ]';

    $accordion_obj = new AdihaAccordion();

    echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);
    echo $layout_obj->progress_on();
    echo $layout_obj->attach_form('form', 'a');
    echo $form_obj->init_by_attach('form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');

    $acc_json = '{items:[
                    {id:"deemed",open: false,text:"<div><a class=\"undock_deemed undock_custom\" title=\"Undock\" onClick=\"dealPricing.undock_details(\'deemed\')\"></a>Pricing</div>"},
                    {id:"std_event",open: false,text:"<div><a class=\"undock_std undock_custom\" title=\"Undock\" onClick=\"dealPricing.undock_details(\'std_event\')\"></a>Standard Event</div>"},
                    {id:"custom_event",open: false,text:"<div><a class=\"undock_event undock_custom\" title=\"Undock\" onClick=\"dealPricing.undock_details(\'custom_event\')\"></a>Custom Event</div>"}]}';
    echo $layout_obj->attach_accordion_cell('accordion', 'b');
    echo $accordion_obj->init_by_attach('accordion', $form_namespace);
    echo $accordion_obj->load_accordion($acc_json);
    echo $accordion_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_detail_event');
    echo $accordion_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_detail_event');


    echo $accordion_obj->attach_grid_cell('deal_pricing_deemed', 'deemed');
    echo $accordion_obj->attach_menu_cell("deemed_menu", 'deemed');

    echo $accordion_obj->attach_grid_cell('deal_std_events', 'std_event');
    echo $accordion_obj->attach_menu_cell("std_event_menu", 'std_event');

    echo $accordion_obj->attach_grid_cell('deal_custom_events', 'custom_event');
    echo $accordion_obj->attach_menu_cell("custom_event_menu", 'custom_event');

    $deemed_menu = new AdihaMenu();
    $std_event_menu = new AdihaMenu();
    $custom_event_menu = new AdihaMenu();

    $menu_json = '[  
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                        {id:"add", text:"Add", img:"new.gif", enabled:' . (int)$has_rights_deal_edit . ' ,imgdis:"new_dis.gif", title: "Add"},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false},
                    ]}                       
                ]';

    echo $deemed_menu->init_by_attach('deemed_menu', $form_namespace);
    echo $deemed_menu->load_menu($menu_json);
    echo $deemed_menu->attach_event('', 'onClick', $form_namespace . '.deemed_menu_click');

    echo $std_event_menu->init_by_attach('std_event_menu', $form_namespace);
    echo $std_event_menu->load_menu($menu_json);
    echo $std_event_menu->attach_event('', 'onClick', $form_namespace . '.std_event_menu_click');

    echo $custom_event_menu->init_by_attach('custom_event_menu', $form_namespace);
    echo $custom_event_menu->load_menu($menu_json);
    echo $custom_event_menu->attach_event('', 'onClick', $form_namespace . '.custom_event_menu_click');


    $deal_pricing_deemed = new GridTable('deal_pricing_deemed');        
    echo $deal_pricing_deemed->init_grid_table('deal_pricing_deemed', $form_namespace, 'n');
    echo $deal_pricing_deemed->set_column_auto_size();
    //echo $deal_pricing_deemed->set_search_filter(true, "");
    //echo $deal_pricing_deemed->enable_paging(50, 'pagingArea_deemed', 'true');       
    echo $deal_pricing_deemed->enable_column_move();
    echo $deal_pricing_deemed->enable_multi_select();
    echo $deal_pricing_deemed->return_init();
    echo $deal_pricing_deemed->enable_cell_edit_events("true", "true", "true");
    echo $deal_pricing_deemed->enable_DND();
    echo $deal_pricing_deemed->attach_event("", "onSelectStateChanged", $form_namespace . '.deal_pricing_deemed_selection');
    echo $deal_pricing_deemed->attach_event("", "onEditCell", $form_namespace . '.deal_pricing_deemed_edit');

    $deal_std_events = new GridTable('deal_std_events');        
    echo $deal_std_events->init_grid_table('deal_std_events', $form_namespace, 'n');
    echo $deal_std_events->set_column_auto_size();
    //echo $deal_std_events->set_search_filter(true, "");
    //echo $deal_std_events->enable_paging(50, 'pagingArea_std_event', 'true');       
    echo $deal_std_events->enable_column_move();
    echo $deal_std_events->enable_multi_select();
    echo $deal_std_events->return_init();
    echo $deal_std_events->enable_cell_edit_events("true", "true", "true");
    echo $deal_std_events->attach_event("", "onSelectStateChanged", $form_namespace . '.deal_std_events_selection');

    $deal_custom_events = new GridTable('deal_custom_events');        
    echo $deal_custom_events->init_grid_table('deal_custom_events', $form_namespace, 'n');
    echo $deal_custom_events->set_column_auto_size();
    //echo $deal_custom_events->set_search_filter(true, "");
    //echo $deal_custom_events->enable_paging(50, 'pagingArea_custom_event', 'true');       
    echo $deal_custom_events->enable_column_move();
    echo $deal_custom_events->enable_multi_select();
    echo $deal_custom_events->return_init();
    echo $deal_custom_events->enable_cell_edit_events("true", "true", "true");
    echo $deal_custom_events->attach_event("", "onSelectStateChanged", $form_namespace . '.deal_custom_events_selection');

    $formula_forms = new AdihaForm();
    $sp_formula = "EXEC spa_formula_editor @flag = 'x'";
	$formula_dropdown_json = $formula_forms->adiha_form_dropdown($sp_formula, 0, 1, true);

	$formula_form_data = '[
		{type: "settings"},
		{type: "label", label: "Formula", offsetLeft: "15"},
		{type:"block", "blockOffset": "15", list:[
			{type:"settings", position:"label-right"},
			{type: "radio", name: "form_sel", value:"t", label: "Template", checked: true},
			{type: "newcolumn"},
			{type: "radio", offsetLeft:30, value:"c", name: "form_sel", label: "Custom"}
		]},
		{"type": "block", "blockOffset": 0, "list": [
			{type: "combo", position: "label-top", offsetLeft: "15", label: "Formula", name: "exist_formula", "filtering": "true", "filtering_mode": "between", "labelWidth":180, "inputWidth":180, options:' . $formula_dropdown_json . '},	
			{"type": "newcolumn"},					
			{"type": "input", "name": "label_new_formula_id", "label": "Formula", "value": "", "className": "browse_label", "position": "label-top", "inputWidth": "180", "offsetLeft": "15", "labelWidth": "180","readonly": "true","hidden": "true"}, 
			{"type": "newcolumn"}, 
			{"type": "button", "name": "clear_new_formula_id", "value": "", "tooltip": "Clear", "className": "browse_clear", "position": "label-top", "inputWidth": "0", "offsetLeft": "-25", "offsetTop": "20", "labelWidth": "0","hidden": "true"}
		]},
		{"type": "hidden", "name": "new_formula_id", "label": "Formula","position": "label-top", "inputWidth": "0", "offsetLeft": "15", "labelWidth": "0", 
			"userdata": {
				"grid_name": "formula",
				"grid_label": "Formula"
			}
		},
		{"type": "hidden", "name": "row_id", "label": "Row"},
		{"type": "hidden", "name": "group_id", "label": "Group", "value":"' . $group_id .'"},
		{"type": "hidden", "name": "source_deal_detail_id", "label": "DetailID", "value":"' . $detail_id .'"},
		{"type": "hidden", "name": "leg", "label": "Leg", "value":"' . $leg .'"}
	]';

    echo $layout_obj->close_layout();
?>

<div id="overlay">
     <div>
          <p>Please select a row in gird.</p>
     </div>
</div>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
<textarea style="display:none" name="error_message" id="error_message"></textarea>
</body>
<script type="text/javascript">    
	var formula_process_id = '<?php echo $formula_process_id;?>';

    $(function() {    
        var pricing_type = '<?php echo $pricing_type;?>';
        dealPricing.deemed_menu_click('refresh');
        dealPricing.std_event_menu_click('refresh');
        dealPricing.custom_event_menu_click('refresh');
        dealPricing.deal_pricing_deemed.setUserData("", 'formula_id', 10211093);
        var group_id = '<?php echo $group_id;?>';
        var detail_id = '<?php echo $detail_id;?>';

        if (group_id == 'NULL' && detail_id == 'NULL') {
            overlay();
        } else {
        	dealPricing.form_change('pricing_type', pricing_type, '');
        	dealPricing.pricing_type2_change();   
        }
    });

    function overlay() {
        el = document.getElementById("overlay");
        el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
    }

    var pricing_formula_popup, pricing_formula_layout, pricing_formula_form, pricing_formula_field_form;
    dealPricing.open_formula = function(grid, rId, cInd, oValue, x, y, w, z) {
    	var formula_id = grid.cells(rId, cInd).getValue();

    	if (pricing_formula_popup && pricing_formula_popup.isVisible()) {
			pricing_formula_popup.hide();
			return;
		}

    	if (pricing_formula_layout != null && pricing_formula_layout.unload != null) {
            pricing_formula_layout.unload();
            pricing_formula_layout = null;
        }

    	if (pricing_formula_popup != null && pricing_formula_popup.unload != null) {
            pricing_formula_popup.unload();
            pricing_formula_popup = null;
        }

        if (!pricing_formula_popup) {
        	pricing_formula_popup = new dhtmlXPopup();
    	}

    	pricing_formula_popup.attachEvent('onShow', function() {
	    	if (!pricing_formula_layout) {
	    		var formula_form_data = <?php echo $formula_form_data;?>;					
				pricing_formula_layout = pricing_formula_popup.attachLayout(600, 200, "2U");
				pricing_formula_layout.cells('a').hideHeader();
				pricing_formula_layout.cells('a').setWidth(210);
				pricing_formula_layout.cells('b').setText('Formula Fields');
				pricing_formula_layout.cells('b').collapse();
				pricing_formula_form = pricing_formula_layout.cells('a').attachForm(formula_form_data);
			}

			pricing_formula_field_form = pricing_formula_layout.cells('b').attachForm();
			attach_browse_event('pricing_formula_form', 10131010, 'dealPricing.new_formula_change');

			pricing_formula_form.attachEvent('onChange', function(id, value) {
				if (id == 'form_sel' && value == 't') {
					pricing_formula_form.hideItem('label_new_formula_id');
					pricing_formula_form.showItem('exist_formula');
				} else if (id == 'form_sel' && value == 'c') {
					pricing_formula_form.hideItem('exist_formula');
					pricing_formula_form.showItem('label_new_formula_id');
				} else if (id == 'exist_formula' || id == 'new_formula_id') {
					if (value != '' && value != null) {	
						var detail_id = pricing_formula_form.getItemValue('source_deal_detail_id')
						var d_leg = pricing_formula_form.getItemValue('leg');
						var d_group_id = pricing_formula_form.getItemValue('group_id');
						var cm_param = {"action": "spa_deal_pricing_formula_udf", "flag": "y", "formula_id":value, "row_id":1, "source_deal_detail_id":detail_id, "leg":d_leg, "source_deal_group_id":d_group_id, "process_id":formula_process_id};
						adiha_post_data("return", cm_param, '', '', 'dealPricing.load_formula_fields');
					}
				}
			})

            if (!formula_id) formula_id = '';
            if (formula_id != '' && formula_id != null) {	            	
            	var cm_param = {"action": "spa_deal_pricing_formula_udf", "flag": "z", "formula_id":formula_id};
				adiha_post_data("return", cm_param, '', '', 'dealPricing.is_formula_template');
        	}
    	});		
		pricing_formula_popup.show(x, y, w, z);

		pricing_formula_popup.attachEvent('onHide', function(){
			var new_old = pricing_formula_form.getCheckedValue('form_sel');

			if (new_old == 't') {
				var combo = pricing_formula_form.getCombo('exist_formula'); 
				var formula_id = pricing_formula_form.getItemValue('exist_formula');
				var formula_text = combo.getComboText();
			} else {
				var formula_id = pricing_formula_form.getItemValue('new_formula_id');
				var formula_text = pricing_formula_form.getItemValue('label_new_formula_id');
			}

			grid.cells(rId, cInd).setValue(formula_id + '^' + formula_text);
			grid.cells(rId, cInd).cell.wasChanged=true;
  			grid.callEvent("onEditCell", [2, rId, cInd, formula_id, oValue]);

  			if (pricing_formula_field_form instanceof dhtmlXForm) {
    			var form_data = pricing_formula_field_form.getFormData();
    			var form_xml = '<Root>';

    			var detail_id = pricing_formula_form.getItemValue('source_deal_detail_id')
				var d_leg = pricing_formula_form.getItemValue('leg');
				var d_group_id = pricing_formula_form.getItemValue('group_id');

				for (var a in form_data) {
					form_xml += "<FormXML row_id=\"1\" leg=\"" + d_leg + "\" source_deal_group_id=\"" + d_group_id + "\" source_deal_detail_id=\"" + detail_id + "\"  udf_template_id=\"" + a + "\"  udf_value=\"" + form_data[a] + "\"></FormXML>";
				}    	

				form_xml += "</Root>";		
    		}

    		var cm_param = {"action": "spa_deal_pricing_formula_udf", "flag": "x", "process_id":formula_process_id, "form_xml":form_xml};
    		adiha_post_data("return", cm_param, '', '', '');
		});
    }

    dealPricing.new_formula_change = function(row_id, group_id, leg, source_deal_detail_id) {
		var formula_id = pricing_formula_form.getItemValue('new_formula_id');
		if (formula_id != '' && formula_id != null) {	
			var detail_id = pricing_formula_form.getItemValue('source_deal_detail_id')
			var d_leg = pricing_formula_form.getItemValue('leg');
			var d_group_id = pricing_formula_form.getItemValue('group_id')
			var cm_param = {"action": "spa_deal_formula_udf", "flag": "y", "formula_id":formula_id, "row_id":1, "source_deal_detail_id":detail_id, "leg":d_leg, "source_deal_group_id":d_group_id, "process_id":formula_process_id};
			adiha_post_data("return", cm_param, '', '', 'dealPricing.load_formula_fields');
		}
	}

	dealPricing.is_formula_template = function(result) {
		if (result[0].form_json == 'y') {	
			pricing_formula_form.checkItem('form_sel', 't');
			pricing_formula_form.callEvent("onChange", ["form_sel", "t"]);	
            pricing_formula_form.setItemValue('exist_formula', result[0].formula_id);
            pricing_formula_form.callEvent("onChange", ["exist_formula", result[0].formula_id]); 
		} else {
			pricing_formula_form.checkItem('form_sel', 'c');
			pricing_formula_form.callEvent("onChange", ["form_sel", "c"]); 
			pricing_formula_form.setItemValue('new_formula_id', result[0].formula_id);
			pricing_formula_form.setItemValue('label_new_formula_id', result[0].formula_text);
			pricing_formula_form.callEvent("onChange", ["new_formula_id", result[0].formula_id]);
		}	
	}

    dealPricing.load_formula_fields = function(result) {
    	if (result[0].form_json != '' && result[0].form_json != 'undefined') {
    		if (pricing_formula_field_form instanceof dhtmlXForm) {
    			var form_data = pricing_formula_field_form.getFormData();
				for (var a in form_data) {
					pricing_formula_field_form.removeItem(a);
				} 
				pricing_formula_layout.cells('b').expand();
    			pricing_formula_field_form.load(result[0].form_json);
    			
    		}
    	}
    }

    dealPricing.deal_pricing_deemed_edit = function(stage,rId,cInd,nValue,oValue) {
    	var pricing_type2 =  dealPricing.form.getItemValue("pricing_type2");
		var fixed_price_index = dealPricing.deal_pricing_deemed.getColIndexById('fixed_price');
    	var currency_index = dealPricing.deal_pricing_deemed.getColIndexById('currency');
    	var pricing_index_index = dealPricing.deal_pricing_deemed.getColIndexById('pricing_index');
    	var formula_id_index = dealPricing.deal_pricing_deemed.getColIndexById('formula_id');
    	var formula_currency_index = dealPricing.deal_pricing_deemed.getColIndexById('formula_currency');
    	var type = dealPricing.deal_pricing_deemed.getColType(cInd);

    	if (type == 'win_link_custom' && stage != 2) {
        	var pos = dealPricing.deal_pricing_deemed.getPosition(dealPricing.deal_pricing_deemed.cells(rId,cInd).cell);
        	var y = pos[1];
			var x = pos[0];

        	var w = dealPricing.deal_pricing_deemed.cells(rId,cInd).cell.offsetWidth;
			var z = dealPricing.deal_pricing_deemed.cells(rId,cInd).cell.offsetHeight;

        	dealPricing.open_formula(dealPricing.deal_pricing_deemed, rId, cInd, oValue, x, y, w, z);
        	return false;
        } else {
        	if (pricing_formula_popup && pricing_formula_popup.isVisible()) pricing_formula_popup.hide();
        }


    	if (stage == 2) {
    		if (nValue != '') {
        		dealPricing.deal_pricing_deemed.cells(rId,cInd).cell.className = dealPricing.deal_pricing_deemed.cells(rId,cInd).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");
    		}

    		if (pricing_type2 == 103600) {
    			var fixed_price = dealPricing.deal_pricing_deemed.cells(rId, fixed_price_index).getValue();
    			var fixed_price_currency = dealPricing.deal_pricing_deemed.cells(rId, currency_index).getValue();

    			/*if (fixed_price == '' || fixed_price == null) {
    				dhtmlx.alert({
		                title:"Error",
		                type:"alert-error",
		                text:"Fixed Price cannot be blank."
		            });
    			}

    			if (fixed_price_currency == '' || fixed_price_currency == null) {
    				dhtmlx.alert({
		                title:"Error",
		                type:"alert-error",
		                text:"Pricing Currency cannot be blank."
		            });
    			}*/
    		} else if (pricing_type2 == 103601) {
    			var pricing_index = dealPricing.deal_pricing_deemed.cells(rId, pricing_index_index).getValue();

    			/*if (pricing_index == '' || pricing_index == null) {
    				dhtmlx.alert({
		                title:"Error",
		                type:"alert-error",
		                text:"Pricing Index cannot be blank."
		            });
    			}*/

    		} else if (pricing_type2 == 103602) {
    			var pricing_index = dealPricing.deal_pricing_deemed.cells(rId, pricing_index_index).getValue();
    			var formula_id = dealPricing.deal_pricing_deemed.cells(rId, formula_id_index).getValue();
    			var formula_currency = dealPricing.deal_pricing_deemed.cells(rId, formula_currency_index).getValue();

    			if ((cInd == pricing_index_index || cInd == formula_id_index) && (pricing_index != '' || formula_id != null)) {
    				var col_ind = (cInd == pricing_index_index) ? formula_id_index : pricing_index_index;
    				dealPricing.deal_pricing_deemed.cells(rId,col_ind).cell.className = dealPricing.deal_pricing_deemed.cells(rId,col_ind).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");

    				if (cInd == pricing_index_index && pricing_index != '') {
    					dealPricing.deal_pricing_deemed.cells(rId,formula_currency_index).cell.className = dealPricing.deal_pricing_deemed.cells(rId,formula_currency_index).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");
    				}
    			}

    			/*if ((pricing_index == '' || pricing_index == null) && (formula_id == '' || formula_id == null)) {
    				dhtmlx.alert({
		                title:"Error",
		                type:"alert-error",
		                text:"Pricing Index or Formula must be selected."
		            });
    			}

    			if ((formula_id != '' && formula_id != null) && (formula_currency == '' || formula_currency == null)) {
    				dhtmlx.alert({
		                title:"Error",
		                type:"alert-error",
		                text:"Formula Currency cannot be blank for formula based price."
		            });
    			}*/
    		}

			var pricing_start_index = dealPricing.deal_pricing_deemed.getColIndexById('pricing_start');
    		var pricing_end_index = dealPricing.deal_pricing_deemed.getColIndexById('pricing_end');

    		if (cInd == pricing_start_index || cInd == pricing_end_index) {
    			var pricing_start = dealPricing.deal_pricing_deemed.cells(rId, pricing_start_index).getValue();
            	var pricing_end = dealPricing.deal_pricing_deemed.cells(rId, pricing_end_index).getValue();
            	
            	if (pricing_start == '' || pricing_end == '') {
            		return true;
        		}

            	if (dates.compare(pricing_end, pricing_start) == -1) {
					if (cInd == pricing_start_index) {
            			dealPricing.deal_pricing_deemed.cells(rId, pricing_end_index).setValue(pricing_start);
            			return true;
            		}

                    var term_start_label = dealPricing.deal_pricing_deemed.getColLabel(pricing_start_index);
                    var term_end_label = dealPricing.deal_pricing_deemed.getColLabel(pricing_end_index);

                    if (cInd == pricing_start_index) {
                        var message = term_start_label + ' cannot be greater than ' + term_end_label;
                    } else {
                        var message = term_end_label + ' cannot be less than ' + term_start_label;
                    }

                    dhtmlx.alert({
                        title:"Alert",
                        type:"alert",
                        text:message,
                        callback: function(result){
                            if (oValue.replace('&nbsp;', '') != '' && oValue.replace('&nbsp;', '') != null) {
                                dealPricing.deal_pricing_deemed.cells(rId, cInd).setFormattedValue(oValue);
                                return true;
                            } else {
                                dealPricing.deal_pricing_deemed.cells(rId, cInd).setFormattedValue('');
                                return false;
                            }
                        }
                    });
                }
            }
    	} else if (stage == 0) {
    		if (pricing_type2 == 103602) {
    			var pricing_index = dealPricing.deal_pricing_deemed.cells(rId, pricing_index_index).getValue();
    			var formula_id = dealPricing.deal_pricing_deemed.cells(rId, formula_id_index).getValue();
    			var formula_currency = dealPricing.deal_pricing_deemed.cells(rId, formula_currency_index).getValue();

    			if ((pricing_index != '' && pricing_index != null && cInd == formula_id_index) || (formula_id != '' && formula_id != null && cInd == pricing_index_index)) {
    				dhtmlx.alert({
		                title:"Error",
		                type:"alert-error",
		                text:"Please define only one of Pricing Index and Formula."
		            });
		            return false;
    			} 
    		}
    	}

    	return true;
	}

    dealPricing.deal_pricing_deemed_selection = function(row_ids) {
        var has_rights_deal_edit = Boolean('<?php echo $has_rights_deal_edit; ?>');
        if (row_ids != null) {
            if (has_rights_deal_edit) dealPricing.deemed_menu.setItemEnabled('delete');
        } else {
            dealPricing.deemed_menu.setItemDisabled('delete');


        }
    }

    dealPricing.deal_std_events_selection = function(row_ids) {
        var has_rights_deal_edit = Boolean('<?php echo $has_rights_deal_edit; ?>');
        if (row_ids != null) {
            if (has_rights_deal_edit) dealPricing.std_event_menu.setItemEnabled('delete');
        } else {
            dealPricing.std_event_menu.setItemDisabled('delete');
        }
    }

    dealPricing.deal_custom_events_selection = function(row_ids) {
        var has_rights_deal_edit = Boolean('<?php echo $has_rights_deal_edit; ?>');
        if (row_ids != null) {
            if (has_rights_deal_edit) dealPricing.custom_event_menu.setItemEnabled('delete');
        } else {
            dealPricing.custom_event_menu.setItemDisabled('delete');
        }
    }

    dealPricing.deemed_menu_click = function(id) {
        switch(id) {
            case "add":
            	var pricing_type =  dealPricing.form.getItemValue("pricing_type");
            	var row_count = dealPricing.deal_pricing_deemed.getRowsNum();
            	if (pricing_type == '' && row_count > 0) return;

                var new_id = (new Date()).valueOf();
                dealPricing.deal_pricing_deemed.addRow(new_id, '');
                dealPricing.deal_pricing_deemed.selectRowById(new_id);

                var pricing_type2 =  dealPricing.form.getItemValue("pricing_type2");

                if (pricing_type2 == 103600) {
		        	var empty_field_array = ['fixed_price', 'currency'];
		        } else if (pricing_type2 == 103601) {
		        	var empty_field_array = ['pricing_index'];
		        } else if (pricing_type2 == 103602) {
		        	var empty_field_array = ['pricing_index', 'formula_currency', 'formula_id'];
		        } else {
		        	var empty_field_array = new Array();
		        }

		        dealPricing.deal_pricing_deemed.forEachRow(function(row){
					dealPricing.deal_pricing_deemed.forEachCell(row,function(cellObj,ind){
						var column_id = dealPricing.deal_pricing_deemed.getColumnId(ind);						
						var cell_value = dealPricing.deal_pricing_deemed.cells(row,ind).getValue();

						if (jQuery.inArray(column_id, empty_field_array) != -1 && cell_value == '') {
							dealPricing.deal_pricing_deemed.cells(row, ind).cell.className = " dhtmlx_validation_error";
		                }						
					});
				});

                break;
            case "delete":
                dealPricing.deal_pricing_deemed.deleteSelectedRows();
                dealPricing.deemed_menu.setItemDisabled('delete');
                break;
            case "refresh":
                var changed_rows = dealPricing.deal_pricing_deemed.getChangedRows(true);
                var data = dealPricing.prepare_string('x');                

                if (changed_rows != '') {
                    dhtmlx.message({
                    	title:"Confirmation",
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to refresh grid?",
                        callback: function(result) {
                            if (result) {
                                dealPricing.deal_pricing_deemed.clearAll();
                                dealPricing.deal_pricing_deemed.post(js_data_collector_url, data, function() {
                                    var deemed_data_number = dealPricing.deal_pricing_deemed.getRowsNum();
                                    if (deemed_data_number != null && deemed_data_number > 0) {
                                        if (!dealPricing.accordion.cells("deemed").isOpened())
                                            dealPricing.accordion.cells("deemed").open();
                                    }
                                });
                                dealPricing.deal_pricing_deemed.setUserData("", 'formula_id', 10211093);
                            }
                        }
                     });
                } else {
                    dealPricing.deal_pricing_deemed.clearAll();
                    dealPricing.deal_pricing_deemed.post(sql_url, data, function() {
                        var deemed_data_number = dealPricing.deal_pricing_deemed.getRowsNum();
                        if (deemed_data_number != null && deemed_data_number > 0) {
                            if (!dealPricing.accordion.cells("deemed").isOpened())
                                dealPricing.accordion.cells("deemed").open();
                        }
                    });
                    dealPricing.deal_pricing_deemed.setUserData("", 'formula_id', 10211093);
                }
                break;
        }
    }

    dealPricing.std_event_menu_click = function(id) {
        switch(id) {
            case "add":
            	var pricing_type =  dealPricing.form.getItemValue("pricing_type");
            	var row_count = dealPricing.deal_std_events.getRowsNum();
            	if (pricing_type == '' && row_count > 0) return;

                var new_id = (new Date()).valueOf();
                dealPricing.deal_std_events.addRow(new_id, '');
                break;
            case "delete":
                dealPricing.deal_std_events.deleteSelectedRows();
                dealPricing.std_event_menu.setItemDisabled('delete');
                break;
            case "refresh":
                var changed_rows = dealPricing.deal_std_events.getChangedRows(true);
                var data = dealPricing.prepare_string('y');                

                if (changed_rows != '') {
                    dhtmlx.message({
                    	title:"Confirmation",
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to refresh grid?",
                        callback: function(result) {
                            if (result) {
                                dealPricing.deal_std_events.clearAll();
                                dealPricing.deal_std_events.post(js_data_collector_url, data, function(){
                                    var std_events_number = dealPricing.deal_std_events.getRowsNum();
                                    if (std_events_number != null && std_events_number > 0) {
                                        if (!dealPricing.accordion.cells("std_event").isOpened())
                                            dealPricing.accordion.cells("std_event").open();
                                    }
                                });
                            }
                        }
                     });
                } else {
                    dealPricing.deal_std_events.clearAll();
                    dealPricing.deal_std_events.post(sql_url, data, function(){
                        var std_events_number = dealPricing.deal_std_events.getRowsNum();
                        if (std_events_number != null && std_events_number > 0) {
                            if (!dealPricing.accordion.cells("std_event").isOpened())
                                dealPricing.accordion.cells("std_event").open();
                        }
                    });
                }
                
                
                break;
        }
    }

    dealPricing.custom_event_menu_click = function(id) {
        switch(id) {
            case "add":
            	var pricing_type =  dealPricing.form.getItemValue("pricing_type");
            	var row_count = dealPricing.deal_custom_events.getRowsNum();
            	if (pricing_type == '' && row_count > 0) return;

                var new_id = (new Date()).valueOf();
                dealPricing.deal_custom_events.addRow(new_id, '');
                break;
            case "delete":
                dealPricing.deal_custom_events.deleteSelectedRows();
                dealPricing.custom_event_menu.setItemDisabled('delete');
                break;
            case "refresh":
                var changed_rows = dealPricing.deal_custom_events.getChangedRows(true);
                var data = dealPricing.prepare_string('z');                

                if (changed_rows != '') {
                    dhtmlx.message({
                    	title:"Confirmation",
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to refresh grid?",
                        callback: function(result) {
                            if (result) {
                                dealPricing.deal_custom_events.clearAll();
                                dealPricing.deal_custom_events.post(js_data_collector_url, data, function(){
                                    var custom_events_number = dealPricing.deal_custom_events.getRowsNum();
                                    if (custom_events_number != null && custom_events_number > 0) {
                                        if (!dealPricing.accordion.cells("custom_event").isOpened())
                                            dealPricing.accordion.cells("custom_event").open();
                                    }
                                });
                            }
                        }
                     });
                } else {
                    dealPricing.deal_custom_events.clearAll();
                    dealPricing.deal_custom_events.post(sql_url, data, function(){
                        var custom_events_number = dealPricing.deal_custom_events.getRowsNum();
                        if (custom_events_number != null && custom_events_number > 0) {
                            if (!dealPricing.accordion.cells("custom_event").isOpened())
                                dealPricing.accordion.cells("custom_event").open();
                        }
                        dealPricing.layout.progressOff();
                    });
                }
                
                break;
        }
    }

    dealPricing.prepare_string = function(flag) {
        var detail_id = '<?php echo $detail_id; ?>';
        var group_id = '<?php echo $group_id; ?>';
        var pricing_provisional = '<?php echo $pricing_provisional; ?>';
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        var data = {
            "action":"spa_deal_pricing",
            "flag":flag,
            "source_deal_detail_id":detail_id,
            "group_id":group_id,
            "pricing_provisional":pricing_provisional,
            "pricing_process_id":pricing_process_id,
            "grid_type":"g"
        }
        sql_param = $.param(data);
        return sql_param;
    }

    dealPricing.undock_details = function(cell) {
        var layout_obj = dealPricing.accordion;
        var cell_text = layout_obj.cells(cell).getText();
        var tmp = document.createElement("DIV");
        tmp.innerHTML = cell_text;
        layout_obj.cells(cell).undock(300, 300, 900, 700);
        layout_obj.dhxWins.window(cell).button("park").hide();
        layout_obj.dhxWins.window(cell).maximize();
        layout_obj.dhxWins.window(cell).centerOnScreen();
        layout_obj.dhxWins.window(cell).setText(tmp.textContent);
    }

    /**
     * [on_dock_detail_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    dealPricing.on_dock_detail_event = function(id) {
        if (id == 'deemed') {
            $(".undock_deemed").show();            
        } else if (id == 'std_event') {
            $(".undock_std").show(); 
        } else if (id == 'custom_event') {
            $(".undock_event").show();            
        }
    }
    /**
     * [on_undock_detail_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    dealPricing.on_undock_detail_event = function(id) {
        if (id == 'deemed') {
            $(".undock_deemed").hide();            
        } else if (id == 'std_event') {
            $(".undock_std").hide(); 
        } else if (id == 'custom_event') {
            $(".undock_event").hide();            
        }          
    }
    
    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    dealPricing.form_change = function(name, value, state) {
        if (name == 'pricing_type') {            
            var p_vol_index = dealPricing.deal_pricing_deemed.getColIndexById('volume');
            var p_uom_index = dealPricing.deal_pricing_deemed.getColIndexById('uom');

            var s_vol_index = dealPricing.deal_std_events.getColIndexById('volume');
            var s_uom_index = dealPricing.deal_std_events.getColIndexById('uom');

            var c_vol_index = dealPricing.deal_custom_events.getColIndexById('volume');
            var c_uom_index = dealPricing.deal_custom_events.getColIndexById('uom');

            if (value == 'w') {
                dealPricing.deal_pricing_deemed.setColumnHidden(p_vol_index, false);
                dealPricing.deal_pricing_deemed.setColumnHidden(p_uom_index, false);
                dealPricing.deal_std_events.setColumnHidden(s_vol_index, false);
                dealPricing.deal_std_events.setColumnHidden(s_uom_index, false);
                dealPricing.deal_custom_events.setColumnHidden(c_vol_index, false);
                dealPricing.deal_custom_events.setColumnHidden(c_uom_index, false);
            } else {
                dealPricing.deal_pricing_deemed.setColumnHidden(p_vol_index, true);
                dealPricing.deal_pricing_deemed.setColumnHidden(p_uom_index, true);
                dealPricing.deal_std_events.setColumnHidden(s_vol_index, true);
                dealPricing.deal_std_events.setColumnHidden(s_uom_index, true);
                dealPricing.deal_custom_events.setColumnHidden(c_vol_index, true);
                dealPricing.deal_custom_events.setColumnHidden(c_uom_index, true);

            }
        } else if (name == 'pricing_type2') {
        	dealPricing.pricing_type2_change();
        }
    }

    dealPricing.pricing_type2_change = function() {
    	var pricing_type2 =  dealPricing.form.getItemValue("pricing_type2");

		if (pricing_type2 == 103604 || pricing_type2 == 103600 || pricing_type2 == 103601 || pricing_type2 == 103602) {
			var fixed_price_index = dealPricing.deal_pricing_deemed.getColIndexById('fixed_price');
        	var currency_index = dealPricing.deal_pricing_deemed.getColIndexById('currency');
        	var pricing_uom_index = dealPricing.deal_pricing_deemed.getColIndexById('pricing_uom');

        	var pricing_index_index = dealPricing.deal_pricing_deemed.getColIndexById('pricing_index');
        	var multiplier_index = dealPricing.deal_pricing_deemed.getColIndexById('multiplier');
        	var adder_index = dealPricing.deal_pricing_deemed.getColIndexById('adder');
        	var adder_currency_index = dealPricing.deal_pricing_deemed.getColIndexById('adder_currency');


        	var pricing_period_index = dealPricing.deal_pricing_deemed.getColIndexById('pricing_period');
        	var pricing_start_index = dealPricing.deal_pricing_deemed.getColIndexById('pricing_start');
        	var pricing_end_index = dealPricing.deal_pricing_deemed.getColIndexById('pricing_end');
        	var formula_id_index = dealPricing.deal_pricing_deemed.getColIndexById('formula_id');
        	var formula_currency_index = dealPricing.deal_pricing_deemed.getColIndexById('formula_currency');
		}


    	if (pricing_type2 == 103600 || pricing_type2 == 103601 || pricing_type2 == 103602) {
    		dealPricing.accordion.cells('deemed').show();
    		dealPricing.accordion.cells('std_event').hide();
    		dealPricing.accordion.cells('custom_event').hide();

    		if (!dealPricing.accordion.cells("deemed").isOpened())
                dealPricing.accordion.cells("deemed").open();

    		if (pricing_type2 == 103600) {
    			// show
    			dealPricing.deal_pricing_deemed.setColumnHidden(fixed_price_index, false);
                dealPricing.deal_pricing_deemed.setColumnHidden(currency_index, false);
                dealPricing.deal_pricing_deemed.setColumnHidden(pricing_uom_index, false);

                // hide
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_index_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(multiplier_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(adder_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(adder_currency_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_period_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_start_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_end_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(formula_id_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(formula_currency_index, true);

    		} else if (pricing_type2 == 103601) {
    			// show
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_index_index, false);
                dealPricing.deal_pricing_deemed.setColumnHidden(multiplier_index, false);
                dealPricing.deal_pricing_deemed.setColumnHidden(adder_index, false);
    			dealPricing.deal_pricing_deemed.setColumnHidden(adder_currency_index, false);

    			// hide
    			dealPricing.deal_pricing_deemed.setColumnHidden(fixed_price_index, true);
                dealPricing.deal_pricing_deemed.setColumnHidden(currency_index, true);
                dealPricing.deal_pricing_deemed.setColumnHidden(pricing_uom_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_period_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_start_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_end_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(formula_id_index, true);
    			dealPricing.deal_pricing_deemed.setColumnHidden(formula_currency_index, true);

    		} else if (pricing_type2 == 103602) {
    			// show
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_index_index, false);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_period_index, false);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_start_index, false);
    			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_end_index, false);
    			dealPricing.deal_pricing_deemed.setColumnHidden(multiplier_index, false);
                dealPricing.deal_pricing_deemed.setColumnHidden(adder_index, false);
    			dealPricing.deal_pricing_deemed.setColumnHidden(adder_currency_index, false);
    			dealPricing.deal_pricing_deemed.setColumnHidden(formula_id_index, false);
    			dealPricing.deal_pricing_deemed.setColumnHidden(formula_currency_index, false);

    			// hide
    			dealPricing.deal_pricing_deemed.setColumnHidden(fixed_price_index, true);
                dealPricing.deal_pricing_deemed.setColumnHidden(currency_index, true);
                dealPricing.deal_pricing_deemed.setColumnHidden(pricing_uom_index, true);                
    		}
    		dealPricing.layout.setSizes();
    	} else if (pricing_type2 == 103603) {
    		dealPricing.accordion.cells('deemed').hide();
    		dealPricing.accordion.cells('std_event').show();
    		dealPricing.accordion.cells('custom_event').show();            
    		dealPricing.layout.setSizes();

    		if (!dealPricing.accordion.cells("std_event").isOpened())
                dealPricing.accordion.cells("std_event").open();
    	} else if (pricing_type2 == 103604) {
    		dealPricing.accordion.cells('deemed').show();
    		dealPricing.accordion.cells('std_event').show();
    		dealPricing.accordion.cells('custom_event').show();

    		// show
			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_index_index, false);
			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_period_index, false);
			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_start_index, false);
			dealPricing.deal_pricing_deemed.setColumnHidden(pricing_end_index, false);
			dealPricing.deal_pricing_deemed.setColumnHidden(multiplier_index, false);
            dealPricing.deal_pricing_deemed.setColumnHidden(adder_index, false);
			dealPricing.deal_pricing_deemed.setColumnHidden(adder_currency_index, false);
			dealPricing.deal_pricing_deemed.setColumnHidden(formula_id_index, false);
			dealPricing.deal_pricing_deemed.setColumnHidden(formula_currency_index, false);
			dealPricing.deal_pricing_deemed.setColumnHidden(fixed_price_index, false);
            dealPricing.deal_pricing_deemed.setColumnHidden(currency_index, false);
            dealPricing.deal_pricing_deemed.setColumnHidden(pricing_uom_index, false);            
    		dealPricing.layout.setSizes();

    		if (!dealPricing.accordion.cells("deemed").isOpened())
                dealPricing.accordion.cells("deemed").open();
    	}
    }

    dealPricing.get_saved_status = function() {

    }

    dealPricing.save_pricing = function() {
        var deemed_ids = dealPricing.deal_pricing_deemed.getChangedRows(true);
        var std_event_ids = dealPricing.deal_std_events.getChangedRows(true);
        var custon_event_ids = dealPricing.deal_custom_events.getChangedRows(true);
        
        var pricing_type2 = dealPricing.form.getItemValue("pricing_type2");
        var pricing_provisional = '<?php echo $pricing_provisional; ?>';

        dealPricing.deal_pricing_deemed.clearSelection();
        dealPricing.deal_std_events.clearSelection();
        dealPricing.deal_custom_events.clearSelection();


        if (pricing_type2 == 103600) {
        	var empty_field_array = ['fixed_price', 'currency'];
        } else if (pricing_type2 == 103601) {
        	var empty_field_array = ['pricing_index'];
        } else if (pricing_type2 == 103602) {
        	var empty_field_array = ['pricing_index', 'formula_currency', 'formula_id'];
        } else {
        	var empty_field_array = new Array();
        }

        var error_field_array = new Array();
        var errors = new Array();
        
        // deemed
        var deemed_xml = '';
        deemed_xml = '<GridXML>';
        dealPricing.deal_pricing_deemed.forEachRow(function(id){
            deemed_xml += '<GridRow ';
            for(var cellIndex = 0; cellIndex < dealPricing.deal_pricing_deemed.getColumnsNum(); cellIndex++){
                var column_id = dealPricing.deal_pricing_deemed.getColumnId(cellIndex);
                var cell_value = dealPricing.deal_pricing_deemed.cells(id,cellIndex).getValue();


                if (jQuery.inArray(column_id, empty_field_array) != -1 && cell_value == '') {
                	error_field_array.push([id, column_id]);
                	errors.push(column_id);
                }

                deemed_xml += ' ' + column_id + '="' + cell_value + '"';
            }
            var row_index = dealPricing.deal_pricing_deemed.getRowIndex(id);
            var priority = row_index+1;
            deemed_xml += ' priority="' + priority + '"';
            deemed_xml += '></GridRow>';
        });
        deemed_xml += '</GridXML>';

        if (errors.length > 0) {
        	var error = false;
        	if (pricing_type2 == 103602) {
        		if (jQuery.inArray('pricing_index', errors) != -1 && jQuery.inArray('formula_id', errors) == -1 && jQuery.inArray('formula_currency', errors) == -1) {
					error = false;
        		} else if (jQuery.inArray('pricing_index', errors) == -1 && (jQuery.inArray('formula_id', errors) != -1 || jQuery.inArray('formula_currency', errors) != -1)) {
        			error = false;
        		} else {
        			error = true;
        		}
        	} else {
        		error = true;
        	}

        	if (error) {       
        		var column_index = dealPricing.deal_pricing_deemed.getColIndexById(error_field_array[0][1]);
        		var column_label = dealPricing.deal_pricing_deemed.getColLabel(column_index); 	
        		var tab = (pricing_provisional == 'p') ? 'Pricing' : 'Provisional';
        		var message = column_label + ' cannot be blank.' + ' (' + tab + ')';	
        		dealPricing.deal_pricing_deemed.cells(error_field_array[0][0], column_index).cell.className = " dhtmlx_validation_error";
	        	document.getElementById("success_status").value = 'error';
	        	document.getElementById("error_message").value = message;
	        	return;
        	}
        } else {
        	document.getElementById("success_status").value = '';
        }
    
        var std_event_xml = '';
        std_event_xml = '<GridXML>';
        dealPricing.deal_std_events.forEachRow(function(id){
            std_event_xml += '<GridRow ';
            for(var cellIndex = 0; cellIndex < dealPricing.deal_std_events.getColumnsNum(); cellIndex++){
                var column_id = dealPricing.deal_std_events.getColumnId(cellIndex);
                var cell_value = dealPricing.deal_std_events.cells(id,cellIndex).getValue();

                if (column_id == 'pricing_index' && cell_value == '') {
                    pricing_index_error_status = true;
                }

                std_event_xml += ' ' + column_id + '="' + cell_value + '"';
            }
            std_event_xml += '></GridRow>';
        });        
        std_event_xml += '</GridXML>';
        
        var custom_event_xml = '';
        custom_event_xml = '<GridXML>';
        dealPricing.deal_custom_events.forEachRow(function(id){
            custom_event_xml += '<GridRow ';
            for(var cellIndex = 0; cellIndex < dealPricing.deal_custom_events.getColumnsNum(); cellIndex++){
                var column_id = dealPricing.deal_custom_events.getColumnId(cellIndex);
                var cell_value = dealPricing.deal_custom_events.cells(id,cellIndex).getValue();
                custom_event_xml += ' ' + column_id + '="' + cell_value + '"';
            }
            custom_event_xml += '></GridRow>';
        });
        custom_event_xml += '</GridXML>';

        var detail_id = '<?php echo $detail_id; ?>';
        var group_id = '<?php echo $group_id; ?>';
        
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';

        var pricing_type = dealPricing.form.getItemValue("pricing_type");

        detail_id = (detail_id != '') ? detail_id : 'NULL';
        group_id = (group_id != '') ? group_id : 'NULL';
        deemed_xml = (deemed_xml != '' && deemed_xml != '<GridXML></GridXML>') ? deemed_xml : 'NULL';
        std_event_xml = (std_event_xml != '' && std_event_xml != '<GridXML></GridXML>') ? std_event_xml : 'NULL';
        custom_event_xml = (custom_event_xml != '' && custom_event_xml != '<GridXML></GridXML>') ? custom_event_xml : 'NULL';

        var data = {
            "action":"spa_deal_pricing",
            "flag":'s',
            "source_deal_detail_id":detail_id,
            "group_id":group_id,
            "pricing_provisional":pricing_provisional,
            "pricing_process_id":pricing_process_id,
            "deemed_xml":deemed_xml,
            "std_event_xml":std_event_xml,
            "custom_event_xml":custom_event_xml,
            "pricing_type":pricing_type,
            "pricing_type2":pricing_type2
        }
        adiha_post_data("return", data, '', '', 'dealPricing.save_callback');
    }

    dealPricing.save_callback = function(result) {
        document.getElementById("success_status").value = result[0].errorcode;
        var pricing_provisional = '<?php echo $pricing_provisional; ?>';
        var tab = (pricing_provisional == 'p') ? 'Pricing' : 'Provisional';
        var message = result[0].message + '(' + tab + ')';
        if (result[0].errorcode.toLowerCase() != 'success') document.getElementById("error_message").value = message;
    }
    
</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>