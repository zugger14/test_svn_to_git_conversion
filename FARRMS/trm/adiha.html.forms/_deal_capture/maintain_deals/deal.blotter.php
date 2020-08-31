<?php
/**
* Deal blotter screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_namespace = 'dealBlotter';
    $sub_book = (isset($_POST["sub_book"]) && $_POST["sub_book"] != '') ? get_sanitized_value($_POST["sub_book"]) : '';
    $book_ids = (isset($_POST["book_ids"]) && $_POST["book_ids"] != '') ? get_sanitized_value($_POST["book_ids"]) : '';
    $layout_obj = new AdihaLayout();
    $layout_json = '[
    					{id: "a", header:false, height:120, width:"610"},
    					{id: "b", header:true, height:120, text:"Default Values"},
    					{id: "c", text:"<div><a class=\"undock_deal undock_custom\" title=\"Undock\" onClick=\"dealBlotter.undock_deals()\"></a>Deals</div>", header:true}
    				]';
    echo $layout_obj->init_layout('blotter_layout', '', '3U', $layout_json, $form_namespace);
    echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_deal_event');
    echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_deal_event');

    echo $layout_obj->attach_event('', 'onExpand', $form_namespace . '.expand_layout');
    echo $layout_obj->attach_event('', 'onCollapse', $form_namespace . '.collapse_layout');
	
	if ($sub_book != '' && $sub_book != 'NULL') {
		$sql_request = "EXEC spa_source_deal_header @flag='z', @function_id = 10131010, @sub_book=" . $sub_book;
		$return_value = readXMLURL($sql_request);

		if ($return_value[0][0] == 1) {
			$enable_save_button = 'true';
		} else {
			$enable_save_button = 'false';  
		}
	} else {
		$enable_save_button = 'true';
	}

    // attach menu
    $menu_json = '[{id: "save", img:"save.gif", img_disabled:"save_dis.gif", text:"Save", title:"Save", enabled:'. $enable_save_button . '}]';
    $menu_obj = new AdihaMenu();
    echo $layout_obj->attach_menu_cell("blotter_menu", "a");  
    echo $menu_obj->init_by_attach("blotter_menu", $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');

    // attach filter form
    $filter_form = new AdihaForm();
    $filter_form_name = 'filter_form';
    echo $layout_obj->attach_form($filter_form_name, 'a');

    //template label
    $label = "<a id='template' href='javascript:void(0);' onclick='open_template_hyperlink();'>Template</a>";
    
    $sp_url = "EXEC spa_getDealTemplate @flag = 's', @source_deal_type_id = NULL, @strategy_id = NULL, @is_blotter='y'";
    $template_dropdown_json = $filter_form->adiha_form_dropdown($sp_url, 0, 1);

    $form_json = '[ 
                    {"type": "settings", "position": "label-top", "offsetLeft": 10},
                    {type:"combo", name: "template", label:"Template", "labelWidth":250, required:true, filtering:true, filtering_mode:"between", "inputWidth":240, "value":"", "options": ' . $template_dropdown_json . ',"validate":"NotEmpty","userdata": {"validation_message": "Invalid selection."}},
                    {type:"newcolumn"},
                    {type:"input", name:"no_of_deals",  label:"No. of Deals", required:true, "validate":"ValidIntGreaterThan0","userdata": {"validation_message": "Invalid number. Number should be greater than zero."}, "labelWidth":100, "inputWidth":80, value:"1"},
                    {type:"newcolumn"},
                    {type:"combo", name: "term_type", label:"Term Type", "labelWidth":250, disabled:true, required:false, filtering:true, "userdata":{"validation_message":"Required Field"},"inputWidth":240}
                ]';

    $filter_form->init_by_attach($filter_form_name, $form_namespace);
    echo $filter_form->load_form($form_json);


    echo $layout_obj->attach_layout_cell('filter_layout', 'b', '2E', '[{id: "a", header:false, height:60},{id:"b", header:false}]');
	$filter_layout_obj = new AdihaLayout();
	echo $filter_layout_obj->init_by_attach('filter_layout', $form_namespace);
	echo $filter_layout_obj->close_layout();


    $default_value_form = new AdihaForm();
    $default_value_form_name = 'default_value_form';
    echo $filter_layout_obj->attach_form($default_value_form_name, 'b');
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10131011', @template_name='deal_insert_blotter', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $default_form_json = $return_value1[0][2];

    $default_value_form->init_by_attach($default_value_form_name, $form_namespace);
    echo $default_value_form->load_form($default_form_json);
    echo $default_value_form->attach_event('', 'onButtonClick', $form_namespace . '.button_click');
    echo $default_value_form->attach_event('', 'onChange', $form_namespace . '.default_value_change');

    $menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", title:"Refresh", enabled:true}]';
    $menu_object = new AdihaMenu();
    echo $layout_obj->attach_menu_cell('grid_menu', 'c');
    echo $menu_object->init_by_attach('grid_menu', $form_namespace);
    echo $menu_object->load_menu($menu_json);
    echo $menu_object->attach_event('', 'onClick', $form_namespace . '.grid_menu_click');

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
		{"type":"button", "label": "ok", "name":"ok", "value":"Ok", "img": "ok.gif", "offsetLeft": "15", "offsetTop": "15"},
		{"type": "hidden", "name": "new_formula_id", "label": "Formula","position": "label-top", "inputWidth": "0", "offsetLeft": "15", "labelWidth": "0", 
			"userdata": {
				"grid_name": "formula",
				"grid_label": "Formula"
			}
		},
		{"type": "hidden", "name": "row_id", "label": "Row"},
		{"type": "hidden", "name": "group_id", "label": "Group"},
		{"type": "hidden", "name": "source_deal_detail_id", "label": "DetailID"},
		{"type": "hidden", "name": "leg", "label": "Leg"}
	]';


    echo $layout_obj->close_layout();
?>
<body>
<script type="text/javascript">
    var save_enabled = '<?php echo $enable_save_button; ?>';
    var detail_window;
    var selected_sub_book = '<?php echo $sub_book; ?>';
    var process_id = '';
    var formula_process_id = '';    
    var blotter_formula_popup, blotter_formula_layout, blotter_formula_form, blotter_formula_field_form;

    function ValidIntGreaterThan0(data) {
        return (data>0);
    }

    $(function() {     
        dealBlotter.filter_form.enableLiveValidation(true);
        dealBlotter.filter_form.attachEvent("onValidateSuccess", function(name, value){
           dealBlotter.filter_form.setNote(name,{text:""});
        });

        dealBlotter.filter_form.attachEvent("onValidateError", function (name, value, result){    
            var message = dealBlotter.filter_form.getUserData(name,"validation_message");
            dealBlotter.filter_form.setNote(name, {text:message,width:250});         
        });
		
		dealBlotter.filter_form.setItemFocus('template');
		var temp_combo = dealBlotter.filter_form.getCombo('template');
		temp_combo.setComboText('');
		
        dealBlotter.filter_form.attachEvent("onChange", dealBlotter.on_change_function);        
		
		dealBlotter.filter_form.attachEvent("onKeyDown", function(inp, ev, name, value){			
			if (name == 'no_of_deals' && ev.keyCode == 9 && !ev.shiftKey) {	
				ev.preventDefault();
				if (dealBlotter.blotter_grid) {
				dealBlotter.blotter_grid.selectCell(0,1,true,true, true);				
				} else {
					dealBlotter.refresh_data();
				}
			}
			return true;
		});

		dealBlotter.default_value_form.enableLiveValidation(true);
		dealBlotter.default_value_form.attachEvent("onValidateSuccess", function(name, value){
           dealBlotter.default_value_form.setNote(name,{text:""});
        });

        dealBlotter.default_value_form.attachEvent("onValidateError", function (name, value, result){    
            var message = dealBlotter.default_value_form.getUserData(name,"validation_message");
            dealBlotter.default_value_form.setNote(name, {text:message,width:250});         
        });

        var button_title = get_locale_value('Apply');
        
        var item1 = $("div.dhxform_btn_txt");
        var item2 = $('div[ title=' + button_title + ']').find(item1);

        $(item2).addClass('btn btn-default importantRule1');
        $(item2).removeClass('dhxform_btn_txt');

        // $('div[title=' + button_title + ']').css({top: 65, left: -245});
        filter_obj = dealBlotter.filter_layout.cells('a').attachForm();
        var layout_cell_obj = dealBlotter.filter_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '10131011', 2);
        dealBlotter.blotter_layout.cells("b").collapse();
    })

    dealBlotter.default_value_change = function(name, value) {
    	if (name == 'counterparty_id') {
    		var contract_combo = dealBlotter.default_value_form.getCombo('contract_id');
	        if (contract_combo) {
	        	var cm_param = {"action": "spa_source_contract_detail", "flag": "r", "counterparty_id": value};
	            var default_value = dealBlotter.default_value_form.getItemValue('contract_id');
	            cm_param = $.param(cm_param);
	            var url = js_dropdown_connector_url + '&' + cm_param;
	            contract_combo.clearAll();
				contract_combo.load(url, function() {
					var index = contract_combo.getOption(default_value);
					if (index && index != null) {
						dealBlotter.default_value_form.setItemValue('contract_id', default_value);
					}  
				});

	        }
    	}
    }

    dealBlotter.button_click = function(id) {
    	if (id == 'apply') {
    		var form_obj = dealBlotter.default_value_form;
            var status = validate_form(form_obj);

            if (!status) {
                return;
            };

            var values = form_obj.getFormData();
            //console.log(values);

            if (dealBlotter.blotter_grid) {
        		var trader_index = dealBlotter.blotter_grid.getColIndexById('trader_id');
        		var counterparty_index = dealBlotter.blotter_grid.getColIndexById('counterparty_id');
        		var contract_index = dealBlotter.blotter_grid.getColIndexById('contract_id');
        		var sub_book_index = dealBlotter.blotter_grid.getColIndexById('sub_book');
        		var commodity_index = dealBlotter.blotter_grid.getColIndexById('commodity_id');
        		var deal_date_index = dealBlotter.blotter_grid.getColIndexById('deal_date');

	            dealBlotter.blotter_grid.forEachRow(function(row_id) {
	            	var deal_date = dealBlotter.blotter_grid.cells(row_id, deal_date_index).getValue();

	        		if ((values.counterparty_id != '' && typeof counterparty_index != 'undefined') || (values.trader_id != '' && typeof trader_index != 'undefined')) {
		        		dealBlotter.loop(
		        			function() { 
		        				if (values.trader_id != '' && typeof trader_index != 'undefined') {		        					
		        					var trader_combo = dealBlotter.blotter_grid.cells(row_id, trader_index).getCellCombo();
		        					var index = trader_combo.getOption(values.trader_id);
				                    if (index && index != null) {
				                        dealBlotter.blotter_grid.cells(row_id, trader_index).setValue(values.trader_id);
				                    }
			        			}
		        			},
		        			function() { 
		        				if (values.counterparty_id != '' && typeof counterparty_index != 'undefined') {		 
		        					var counterparty_combo = dealBlotter.blotter_grid.cells(row_id, counterparty_index).getCellCombo();
		        					var index = counterparty_combo.getOption(values.counterparty_id);
				                    if (index && index != null) {
				                        dealBlotter.blotter_grid.cells(row_id, counterparty_index).setValue(values.counterparty_id);
				                    }
			        			}
		        			}, 
							function() { 
								if ((values.counterparty_id != '' && typeof counterparty_index != 'undefined') || (values.trader_id != '' && typeof trader_index != 'undefined')) {									
									var cpty_id = dealBlotter.blotter_grid.cells(row_id, counterparty_index).getValue();
									var trader_id = dealBlotter.blotter_grid.cells(row_id, trader_index).getValue();

									dealBlotter.load_contract_dropdown(row_id, cpty_id, trader_id);	
                        			dealBlotter.load_detail_dropdown(row_id, cpty_id, trader_id);						
								}
							}, 
							function() { 
								if (values.contract_id != '' && typeof contract_index != 'undefined') {
									var contract_combo = dealBlotter.blotter_grid.cells(row_id, contract_index).getCellCombo();
		        					var index = contract_combo.getOption(values.contract_id);
				                    if (index && index != null) {
				                        dealBlotter.blotter_grid.cells(row_id, contract_index).setValue(values.contract_id);
				                    }		        			
								}
							}
						);    
					} else {
						if (values.contract_id != '' && typeof contract_index != 'undefined') {     
							var contract_combo = dealBlotter.blotter_grid.cells(row_id, contract_index).getCellCombo();
        					var index = contract_combo.getOption(values.contract_id);
		                    if (index && index != null) {
		                        dealBlotter.blotter_grid.cells(row_id, contract_index).setValue(values.contract_id);
		                    }		        			
						}
					}    		

	        		if (values.sub_book != '' && typeof sub_book_index != 'undefined') {
	        			var sub_book_combo = dealBlotter.blotter_grid.cells(row_id, sub_book_index).getCellCombo();
    					var index = sub_book_combo.getOption(values.sub_book);
	                    if (index && index != null) {
	                        dealBlotter.blotter_grid.cells(row_id, sub_book_index).setValue(values.sub_book);
	                    }
	        		}

	        		if (values.commodity_id != '' && typeof commodity_index != 'undefined') {
	        			var commodity_combo = dealBlotter.blotter_grid.cells(row_id, commodity_index).getCellCombo();
    					var index = commodity_combo.getOption(values.commodity_id);
	                    if (index && index != null) {
	                        dealBlotter.blotter_grid.cells(row_id, commodity_index).setValue(values.commodity_id);
	                    }
	        		}

					var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
					if (detail_subgrid) {						
						var curve_index = detail_subgrid.getColIndexById('curve_id');
						var location_index = detail_subgrid.getColIndexById('location_id');
						var fixed_price_index = detail_subgrid.getColIndexById('fixed_price');
						var price_adder_index = detail_subgrid.getColIndexById('price_adder');
						var deal_volume_index = detail_subgrid.getColIndexById('deal_volume');
						var uom_index = detail_subgrid.getColIndexById('deal_volume_uom_id');
						var term_start_index = detail_subgrid.getColIndexById('term_start');
						var term_end_index = detail_subgrid.getColIndexById('term_end');
						var formula_curve_index = detail_subgrid.getColIndexById('formula_curve_id');
						var fixed_price_currency_index = detail_subgrid.getColIndexById('fixed_price_currency_id');

						for (var j = 0; j < detail_subgrid.getRowsNum(); j++){
							var j_row_id = detail_subgrid.getRowId(j);

							if (values.curve_id != '' && typeof curve_index != 'undefined') {
								var curve_combo = detail_subgrid.cells(j_row_id, curve_index).getCellCombo();
		    					var index = curve_combo.getOption(values.curve_id);
			                    if (index && index != null) {
			                        detail_subgrid.cells(j_row_id, curve_index).setValue(values.curve_id);
			                    }
			        		}

			        		if (values.index_price != '' && typeof formula_curve_index != 'undefined') {
								var formula_curve_combo = detail_subgrid.cells(j_row_id, formula_curve_index).getCellCombo();
		    					var index = curve_combo.getOption(values.index_price);
			                    if (index && index != null) {
			                        detail_subgrid.cells(j_row_id, formula_curve_index).setValue(values.index_price);
			                    }
			        		}

			        		if (values.location_id != '' && typeof location_index != 'undefined') {
			        			var location_combo = detail_subgrid.cells(j_row_id, location_index).getCellCombo();
		    					var index = location_combo.getOption(values.location_id);
			                    if (index && index != null) {
			                        detail_subgrid.cells(j_row_id, location_index).setValue(values.location_id);
			                    }
			        		}

			        		if (values.fixed_price != '' && typeof fixed_price_index != 'undefined') {
			        			detail_subgrid.cellByIndex(j, fixed_price_index).setValue(values.fixed_price);
			        		}

			        		if (values.price_adder != '' && typeof price_adder_index != 'undefined') {
			        			detail_subgrid.cellByIndex(j, price_adder_index).setValue(values.price_adder);
			        		}

			        		if (values.deal_volume != '' && typeof deal_volume_index != 'undefined') {
			        			detail_subgrid.cellByIndex(j, deal_volume_index).setValue(values.deal_volume);
			        		}

			        		if (values.deal_volume_uom_id != '' && typeof uom_index != 'undefined') {
			        			detail_subgrid.cellByIndex(j, uom_index).setValue(values.deal_volume_uom_id);
			        		}

			        		if (values.term_start != '' && values.term_start != null && typeof term_start_index != 'undefined') {
			        			detail_subgrid.cellByIndex(j, term_start_index).setValue(values.term_start);
			        		}

			        		if (values.term_end != '' && values.term_end != null && typeof term_end_index != 'undefined') {
			        			detail_subgrid.cellByIndex(j, term_end_index).setValue(values.term_end);
			        		}

			        		if (values.fixed_price_currency_id != '' && typeof fixed_price_currency_index != 'undefined') {
			        			detail_subgrid.cellByIndex(j, fixed_price_currency_index).setValue(values.fixed_price_currency_id);
			        		}

			        		if (values.logical_term != '' && typeof term_start_index != 'undefined') {
			        			var template_id = dealBlotter.filter_form.getItemValue("template");
								var term_frequency = dealBlotter.filter_form.getItemValue("term_type");
								if (term_frequency == '') term_frequency = 'NULL';
								document.getElementById("detail_r_id").value = row_id;

			        			data = {"action": "spa_blotter_deal", "flag":"t", "template_id":template_id, "deal_date":deal_date, "term_frequency":term_frequency, term_rule:values.logical_term};
						        adiha_post_data("return", data, '', '', 'dealBlotter.change_term');
			        		}
                        }
                        dealBlotter.load_shipper1_dropdown(row_id);
                        dealBlotter.load_shipper2_dropdown(row_id);
					}
				});
	        }
    	}
    }

    /**
     * [on_dock_deal_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    dealBlotter.expand_layout = function(id) {
        if (id == 'b') {            
			dealBlotter.blotter_layout.cells("b").showHeader();
            dealBlotter.blotter_layout.cells("b").setHeight(320);
            dealBlotter.filter_layout.cells("a").setHeight(60);
        }
    }
    /**
     * [on_undock_deal_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    dealBlotter.collapse_layout = function(id) {
        if (id == 'b') {
        	dealBlotter.blotter_layout.cells("b").setCollapsedText(get_locale_value("Default Values"));
        	dealBlotter.blotter_layout.cells("b").showHeader();	
            dealBlotter.blotter_layout.cells("b").setHeight(120);       
        }            
    }

    /**
     * [undock_details Undock detail layout]
     */
    dealBlotter.undock_deals = function() {
        var deal_id = "<?php echo $deal_id ?? ''; ?>";
        var layout_obj = dealBlotter.blotter_layout;
        layout_obj.cells("c").undock(300, 300, 900, 700);
        layout_obj.dhxWins.window("c").button("park").hide();
        layout_obj.dhxWins.window("c").maximize();
        layout_obj.dhxWins.window("c").centerOnScreen();
    }

    /**
     * [on_dock_deal_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    dealBlotter.on_dock_deal_event = function(id) {
        if (id == 'c') {            
            $(".undock_deal").show();
        }
    }
    /**
     * [on_undock_deal_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    dealBlotter.on_undock_deal_event = function(id) {
        if (id == 'c') {
            $(".undock_deal").hide();            
        }            
    }

    /**
     * [grid_menu_click Grid Menu click function]
     * @param  {[type]} id [Menu Id]
     */
    dealBlotter.grid_menu_click = function(id) {
        if (id == 'refresh') {
            dealBlotter.refresh_data();
        }
    }

    /**
     * [enable_disable_term Enable Disable term type]
     */
    dealBlotter.enable_disable_term = function(result) {
        if (result[0].enable_term_type == 'y') {
            var tt_combo = dealBlotter.filter_form.getCombo('term_type');  
			var previous_value = dealBlotter.filter_form.getItemValue("term_type");
			
            tt_combo.clearAll(); 
            tt_combo.addOption([
                ["d","Spot"],
                ["m","Term"]
            ]);        
            tt_combo.enableFilteringMode('between');
            dealBlotter.filter_form.enableItem('term_type');
            dealBlotter.filter_form.setItemFocus('term_type');
            dealBlotter.filter_form.setRequired('term_type',true);
			
			if (previous_value != '' && previous_value != null) {
				dealBlotter.filter_form.setItemValue('term_type', previous_value);
			}
        } else {
            var tt_combo = dealBlotter.filter_form.getCombo('term_type');    
            tt_combo.clearAll();         
            tt_combo.unSelectOption();

            dealBlotter.filter_form.setItemValue('term_type', '');
            dealBlotter.filter_form.disableItem('term_type');
            dealBlotter.filter_form.setRequired('term_type',false); 
        }
    }

    /**
     * [refresh_data Refresh Data]
     */
    dealBlotter.refresh_data = function() {
        var status = validate_form(dealBlotter.filter_form);

        if (status) {
            dealBlotter.blotter_layout.cells('c').progressOn();
            var template_id = dealBlotter.filter_form.getItemValue("template");
            var no_of_deals = dealBlotter.filter_form.getItemValue("no_of_deals");
            var term_frequency = dealBlotter.filter_form.getItemValue("term_type");

            if (term_frequency == '') term_frequency = 'NULL';
            if (selected_sub_book == '' || typeof selected_sub_book == 'undefined') selected_sub_book = 'NULL';
            data = {
                        "action": "spa_blotter_deal",
                        "flag": "s",
                        "template_id":template_id,
                        "no_of_row":no_of_deals,
                        "term_frequency":term_frequency,
                        "sub_book":selected_sub_book
                   };
            adiha_post_data('return_json', data, '', '', 'dealBlotter.create_grid');
       }
    }

    /**
     * [on_change_function Form Change event]
     */
    dealBlotter.on_change_function = function(name, value, state) {
        if (name == 'template') {
            var template_id = dealBlotter.filter_form.getItemValue("template");
            if (template_id != '' && template_id != null) {
                var data = {"action": "spa_deal_type_pricing_maping", "flag":'u', "template_id":template_id, "call_from":"b"};  
                adiha_post_data("return", data, '', '', 'dealBlotter.enable_disable_term');
            }
        }
    }

    dealBlotter.loop = function() {
        var args = arguments;
        if (args.length <= 0)
            return;
        (function chain(k) {
            if (k >= args.length || typeof args[k] !== 'function')
                return;
            window.setTimeout(function() {
                args[k]();
                chain(k + 1);
            }, 1000);
        })(0);
    }

    /**
     * [create_grid Create Grid]
     * @param  {[type]} result [description]
     * @return {[type]}        [description]
     */
    dealBlotter.create_grid = function(result) {
        var json_obj = $.parseJSON(result);

        header_info = json_obj[0];
        detail_info = json_obj[1];
        process_id = detail_info.process_id;
        formula_process_id = detail_info.formula_process_id;
        
        var term_frequency = header_info.term_frequency;

        if (dealBlotter.blotter_grid) {
            dealBlotter.blotter_grid.destructor();
            dealBlotter.blotter_grid = null;
        }

        dealBlotter.blotter_grid = dealBlotter.blotter_layout.cells('c').attachGrid();
        dealBlotter.blotter_grid.setImagePath(js_image_path + "dhxgrid_web/");
        dealBlotter.blotter_grid.setIconsPath(js_image_path + "dhxgrid_web/");

        header_config = $.parseJSON(header_info.config_json);
        dealBlotter.blotter_grid.parse(header_config, "json"); 
        dealBlotter.blotter_grid.enableColumnAutoSize(true);
        dealBlotter.blotter_grid.setDateFormat(user_date_format, "%Y-%m-%d");
        dealBlotter.blotter_grid.enableValidation(true);
        dealBlotter.blotter_grid.setColValidators(header_info.validation_rule);
        dealBlotter.blotter_grid.enableEditEvents(true,false,true);
        dealBlotter.blotter_grid.setStyle(
            "", "background-color:#EAF5CA;", "", ""
        );

        dealBlotter.blotter_grid.attachEvent("onValidationError",function(id,ind,value){
            var message = "Invalid Data";
            dealBlotter.blotter_grid.cells(id,ind).setAttribute("validation", message);
            return true;
        });
        dealBlotter.blotter_grid.attachEvent("onValidationCorrect",function(id,ind,value){
            dealBlotter.blotter_grid.cells(id,ind).setAttribute("validation", "");
            return true;
        });
        
        var combo_array = new Array();
        if (header_info.combo_list.indexOf("||||") != -1) {
            combo_array = header_info.combo_list.split('||||');
        } else {
            combo_array.push(header_info.combo_list);
        }

        $.each(combo_array, function(index, value) {
            var json_array = new Array();
            json_array = value.split('::::');
            var combo_index = dealBlotter.blotter_grid.getColIndexById(json_array[0]);
            var combo_obj = dealBlotter.blotter_grid.getColumnCombo(combo_index);
            combo_obj.enableFilteringMode("between", null, false);
            var combo_data = $.parseJSON(json_array[1]);
            combo_obj.load(combo_data);
        });

        var sql_param = {
            "sql": header_info.query, 
            "grid_type": 'g'
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        dealBlotter.blotter_grid.enableHeaderMenu(header_info.header_menu_list);     

        var header_array = new Array();
        var detail_array = new Array();
        header_array = header_info.header_menu_list.split(',');
        detail_array = detail_info.header_menu_list.split(',');
        var total_hcol = header_array.length;
        var total_dcol = detail_array.length;
        var adjust_col = 'y';
        var new_col_width = 150;

        //to adjust grid and columns width when there are less columns in header than in detail, in such case some of the detail fields are hidden
        if (total_hcol < total_dcol-2) {
            var per = Math.floor(100/total_hcol);
            var width_array = new Array();
            var i=0;
            $.each(header_array, function(index, value) {
                if (i == 0) width_array.push('5');
                else width_array.push(per);
                i++;
            });
            widths = width_array.join(',');
            dealBlotter.blotter_grid.setInitWidthsP(widths);
            adjust_col = 'n';
            new_col_width = 10;
        }

        dealBlotter.blotter_grid.clearAll();
        dealBlotter.blotter_grid.load(sql_url, function() {           
            var sub_book_index = dealBlotter.blotter_grid.getColIndexById('sub_book');
            dealBlotter.blotter_grid.forEachRow(function(row_id) {
                dealBlotter.blotter_grid.cells(row_id, 0).open();    
                // if (selected_sub_book != '') {
                //     dealBlotter.blotter_grid.cells(row_id,sub_book_index).setValue(selected_sub_book);            
                // }
                var jurisdiction_index = dealBlotter.blotter_grid.getColIndexById('state_value_id');
                
                if (jurisdiction_index) {
	                var state_value_id = dealBlotter.blotter_grid.cells(row_id, jurisdiction_index).getValue();
	                dealBlotter.load_tier_dropdown(row_id, state_value_id);
                }
            });

            var first_row = dealBlotter.blotter_grid.getRowId(0);
            dealBlotter.blotter_grid.forEachCell(first_row,function(cellObj,col_index){
                var cell_value = dealBlotter.blotter_grid.cells(first_row, col_index).getValue();
                if (cell_value != '' & cell_value != null) {
                    if (adjust_col != 'n')
                        dealBlotter.blotter_grid.adjustColumnSize(col_index);
                }                
            });

            // Added Logical Date Column after Deal Date
            var deal_date_col_ind = dealBlotter.blotter_grid.getColIndexById('deal_date');
            var new_col_id = deal_date_col_ind + 1;
            dealBlotter.blotter_grid.insertColumn(new_col_id, 'Logical Term', 'combo', new_col_width);
            dealBlotter.blotter_grid.setColumnId(new_col_id,"logical_term");
            var logical_term_cmb = dealBlotter.blotter_grid.cells(first_row, new_col_id).getCellCombo();
            var cm_param = {"action": "spa_generic_mapping_header", "call_from": "grid", "flag": "n", "combo_sql_stmt": "EXEC spa_staticdatavalues @flag = 'h', @type_id = 19300, @license_not_to_static_value_id = '19301,19302,19303,19304'", "has_blank_option": true};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            logical_term_cmb.clearAll();
            logical_term_cmb.enableFilteringMode("between", null, false);
            logical_term_cmb.load(url);

            dealBlotter.blotter_layout.cells('c').progressOff();			
        });

        /**
         * Header grid column on change event
         * @param  {[type]} rId     [rowid]
         * @param  {[type]} cInd    [column index]
         */
        dealBlotter.blotter_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            var deal_date_index = dealBlotter.blotter_grid.getColIndexById('deal_date');
            var logical_term_index = dealBlotter.blotter_grid.getColIndexById('logical_term');
            var sub_book_index = dealBlotter.blotter_grid.getColIndexById('sub_book');
            var col_header_buy_sell_flag = dealBlotter.blotter_grid.getColIndexById('header_buy_sell_flag');
            if (stage == 2) {
                if (deal_date_index == cInd) {
                	var logical_term = dealBlotter.blotter_grid.cells(rId, logical_term_index).getValue();
                    dealBlotter.deal_date_changed(rId, nValue, logical_term);
                } else if (logical_term_index == cInd) {
                	var deal_date = dealBlotter.blotter_grid.cells(rId, deal_date_index).getValue();
                    dealBlotter.deal_date_changed(rId, deal_date, nValue);
                } else if (sub_book_index == cInd) {
                    if (nValue != '')
                        dealBlotter.sub_book_changed(rId, nValue);
                } else if (col_header_buy_sell_flag == cInd) {
                    if (nValue != '')
                        dealBlotter.header_buy_sell_flag_changed(rId, nValue);
                }
            }
            return true;
        });

        dealBlotter.blotter_grid.attachEvent("onBeforeSelect", function(new_row,old_row,new_col_index){
            var detail_subgrid = dealBlotter.blotter_grid.cells(old_row, 0).getSubGrid();
            dealBlotter.blotter_grid.clearSelection();
            detail_subgrid.clearSelection();
            return true;
        });


        var counterparty_index = dealBlotter.blotter_grid.getColIndexById('counterparty_id');
        var trader_index = dealBlotter.blotter_grid.getColIndexById('trader_id');
        var jurisdiction_index = dealBlotter.blotter_grid.getColIndexById('state_value_id');

        dealBlotter.blotter_grid.attachEvent("onRowSelect", function(rId, index){
            dealBlotter.context_menu = new dhtmlXMenuObject();
            dealBlotter.context_menu.renderAsContextMenu();

            dealBlotter.context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                var data = dealBlotter.blotter_grid.contextID.split("_"); //rowId_colInd
                var rID = data[0];
				var clicked_row_index = dealBlotter.blotter_grid.getRowIndex(rID);
                var column_index = data[1];
                var deal_id = "<?php echo $deal_id ?? ''; ?>";

                var col_label = dealBlotter.blotter_grid.getColLabel(column_index);
                var col_type = dealBlotter.blotter_grid.getColType(column_index);
                var col_value = dealBlotter.blotter_grid.cells(rID, column_index).getValue();

                if (col_type == 'time') {
                    dealBlotter.blotter_grid.clearSelection();
                    var col_value = dealBlotter.blotter_grid.cells(rID, column_index).getValue();
                    dealBlotter.blotter_grid.cells(rID, column_index).setValue(col_value);
                }
                
                if (col_type == 'win_link') {
                    var col_text = dealBlotter.blotter_grid.cells(rID, column_index).getTitle();
                    col_value = col_value+'^'+col_text;
                }

                dealBlotter.blotter_grid.forEachRow(function(id) {
                    if (index > clicked_row_index && rID != id) {
                        dealBlotter.blotter_grid.cells(id, column_index).setValue(col_value);
                        dealBlotter.blotter_grid.cells(id, column_index).cell.wasChanged = true;
                    }
					
					if (counterparty_index == column_index || trader_index == column_index) {
						var cpty_id = dealBlotter.blotter_grid.cells(rID, counterparty_index).getValue();
                    	var trader_id = dealBlotter.blotter_grid.cells(rID, trader_index).getValue();

						dealBlotter.load_contract_dropdown_apply_to_all(rID, cpty_id, trader_id);
						dealBlotter.load_detail_dropdown_apply_to_all(rID, cpty_id, trader_id);
					}
                });
            });
            dealBlotter.context_menu.loadFromHTML("context_menu", false);
            dealBlotter.blotter_grid.enableContextMenu(dealBlotter.context_menu);
        });

        dealBlotter.blotter_grid.attachEvent("onSubGridCreated",function(detail_subgrid, sub_id, sub_ind){
            var row_id = dealBlotter.blotter_grid.cells(sub_id, 0).getValue();

            detail_subgrid.setImagePath(js_image_path + "dhxgrid_web/");
            detail_subgrid.setIconsPath(js_image_path + "dhxgrid_web/");
            detail_config = $.parseJSON(detail_info.config_json);
            detail_subgrid.parse(detail_config, "json");
            detail_subgrid.setDateFormat(user_date_format, "%Y-%m-%d");
            detail_subgrid.enableColumnAutoSize(true);
            detail_subgrid.enableValidation(true);
            detail_subgrid.setColValidators(detail_info.validation_rule); 
            detail_subgrid.enableEditEvents(true,false,true);       
            detail_subgrid.setStyle(
                "background-color:#83ACC5;border: 1px outset silver;color:white;", "background-color:#F3F8FD;", "", "background-color:#FFE792;"
            );    
            detail_subgrid.attachEvent("onValidationError",function(id,ind,value){
                var message = "Invalid Data";
                detail_subgrid.cells(id,ind).setAttribute("validation", message);
                return true;
            });
            detail_subgrid.attachEvent("onValidationCorrect",function(id,ind,value){
                detail_subgrid.cells(id,ind).setAttribute("validation", "");
                return true;
            });

            var detail_combo_array = new Array();
            if (detail_info.combo_list.indexOf("||||") != -1) {
                detail_combo_array = detail_info.combo_list.split('||||');
            } else {
                detail_combo_array.push(detail_info.combo_list);
            }

            $.each(detail_combo_array, function(index, value) {
                var json_array = new Array();
                json_array = value.split('::::');
                var combo_index = detail_subgrid.getColIndexById(json_array[0]);
                var combo_obj = detail_subgrid.getColumnCombo(combo_index);
                combo_obj.enableFilteringMode("between", null, false);
                var combo_data = $.parseJSON(json_array[1]);
                combo_obj.load(combo_data);
            });
            var detail_sql_param = {
                "sql": detail_info.query + " WHERE row_id = " + row_id, 
                "grid_type": 'g',
                "grouping_column":"row_id"
            };

            detail_sql_param = $.param(detail_sql_param);
            var detail_sql_url = js_data_collector_url + "&" + detail_sql_param; 
            detail_subgrid.enableHeaderMenu(detail_info.header_menu_list); 

            //to adjust grid and columns width when there are less columns in header than in detail, in such case some of the detail fields are hidden
            if (total_hcol < total_dcol-2) {
                var per = Math.floor(100/(total_dcol-1));
                var width_array = new Array();
                var i=0;
                $.each(detail_array, function(index, value) {
                    if (i == 0) width_array.push('5');
                    else if (i == 1 || i == 2) width_array.push('0');
                    else if (value == 'false') width_array.push('0');
                    else width_array.push(per);
                    i++;
                });
                widths = width_array.join(',');
                detail_subgrid.setInitWidthsP(widths);
                adjust_col = 'n';
            }

            detail_subgrid.clearAll();  
            detail_subgrid.load(detail_sql_url, function() {
                var detail_row_id = detail_subgrid.getRowId(0);
                detail_subgrid.forEachCell(detail_row_id,function(cellObj, col_index){
                    var cell_value = detail_subgrid.cells(detail_row_id, col_index).getValue();
                    var col_type = detail_subgrid.getColType(col_index);
                    if (cell_value != '' & cell_value != null && col_type != 'img' && col_type != 'dhxCalendarA' && col_type != 'win_link') {
                        if (adjust_col != 'n') detail_subgrid.adjustColumnSize(col_index);
                    }
                    detail_subgrid.callEvent("onGridReconstructed",[]);
                    dealBlotter.blotter_grid.setSizes(true);
                });
                dealBlotter.load_counterparty_dropdown(sub_id);
                detail_subgrid.setUserData("", 'formula_id', 10211093);
				dealBlotter.blotter_layout.cells('c').progressOff();
            });

            /**
             * Double click event for detail grid first column
             * @param  {[type]} rId     [rowid]
             * @param  {[type]} cInd    [column index]
             */
            detail_subgrid.attachEvent("onRowDblClicked", function(rId,cInd){
                if (cInd == 0) {
                    var row_id = detail_subgrid.cells(rId, 1).getValue(); // hardcoded cell index, coz always returns deal row number
                    var blotterleg = detail_subgrid.cells(rId, 2).getValue(); // hardcoded cell index, coz always returns leg

                    var term_start_index = detail_subgrid.getColIndexById('term_start');
                    var term_end_index = detail_subgrid.getColIndexById('term_end');
                    var term_start = detail_subgrid.cells(rId, term_start_index).getValue();
                    var term_end = detail_subgrid.cells(rId, term_end_index).getValue();
                    var template_id = dealBlotter.filter_form.getItemValue("template");
                    var counterparty_index = dealBlotter.blotter_grid.getColIndexById('counterparty_id');
                    if (typeof counterparty_index == 'undefined') {
                        var counterparty_id = 'NULL';
                    } else {
                        counterparty_id = dealBlotter.blotter_grid.cells(sub_id, counterparty_index).getValue();
                    }
                    
                    var term_frequency_form = dealBlotter.filter_form.getItemValue("term_type");

                    term_frequency = (term_frequency_form == '') ? term_frequency : term_frequency_form;

                    var param = {
                        "template_id":template_id,
                        "term_start":term_start,
                        "term_end":term_end,
                        "blotterleg":blotterleg,
                        "row_id":row_id,
                        "process_id":detail_info.process_id,
                        "counterparty_id":counterparty_id,
                        "term_frequency":term_frequency
                    };
                    param = $.param(param);

                    dealBlotter.unload_detail_window();
                    if (!detail_window) {
                        detail_window = new dhtmlXWindows();
                    }

                    var new_win = detail_window.createWindow('w1', 0, 0, 800, 600);
                    new_win.setText("Deal Detail");
                    new_win.centerOnScreen();
                    new_win.setModal(true);
                    new_win.maximize();
                    new_win.attachURL('deal.blotter.detail.php?' + param, false, true);
                } else {
                    return true;
                }
            });
            
            /**
             * Detail grid column on change event - save changed data to process table
             * @param  {[type]} rId     [rowid]
             * @param  {[type]} cInd    [column index]
             */
            detail_subgrid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            	var type = detail_subgrid.getColType(cInd);

		    	if (type == 'win_link_custom' && stage != 2) {
		        	var pos = detail_subgrid.getPosition(detail_subgrid.cells(rId,cInd).cell);
		        	var y = pos[1];
					var x = pos[0];

		        	var w = detail_subgrid.cells(rId,cInd).cell.offsetWidth;
					var z = detail_subgrid.cells(rId,cInd).cell.offsetHeight;

		        	dealBlotter.open_formula(detail_subgrid, rId, cInd, oValue, x, y, w, z);
		        	return false;
		        } else {
		        	if (blotter_formula_popup && blotter_formula_popup.isVisible()) blotter_formula_popup.hide();
		        }

                if (stage == 2) {
                    var row_id = detail_subgrid.cells(rId, 1).getValue(); 
                    var blotterleg = detail_subgrid.cells(rId, 2).getValue();
                    var column_id = detail_subgrid.getColumnId(cInd);

                    if (column_id == 'location_id') {
                        dealBlotter.load_shipper1_dropdown(row_id-1);//parent row starts from 1 less than child row id
                        dealBlotter.load_shipper2_dropdown(row_id-1);
                    }

                    if (column_id == 'term_start' || column_id == 'term_end') {
                        var term_start_index = detail_subgrid.getColIndexById('term_start');
                        var term_end_index = detail_subgrid.getColIndexById('term_end');

                        if (term_start_index == undefined || term_end_index == undefined) return true;

                        var term_start = detail_subgrid.cells(rId, term_start_index).getValue();
                        var term_end = detail_subgrid.cells(rId, term_end_index).getValue();     

                        if (column_id == 'term_start') {
                            var term_frequency_form = dealBlotter.filter_form.getItemValue("term_type");
                            term_frequency = (term_frequency_form == '') ? term_frequency : term_frequency_form;

                            var new_term_end = dates.getTermEnd(term_start, term_frequency);
                            detail_subgrid.cells(rId, term_end_index).setValue(new_term_end);
                            dealBlotter.load_shipper1_dropdown(row_id-1);//parent row starts from 1 less than child row id
                            dealBlotter.load_shipper2_dropdown(row_id-1);
                        } else if (dates.compare(term_end, term_start) == -1) {
                            var win_obj = window.parent.blotter_window.window("w1");
                            
                            if (save_enabled)
								dealBlotter.blotter_menu.setItemEnabled('save');
                            
                            win_obj.progressOff();
                            
                            var term_start_label = detail_subgrid.getColLabel(term_start_index);
                            var term_end_label = detail_subgrid.getColLabel(term_end_index);
                            if (cInd == term_start_index) {
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
                                        detail_subgrid.cells(rId, cInd).setFormattedValue(oValue);
                                        return false;
                                    } else {
                                        detail_subgrid.cells(rId, cInd).setFormattedValue('');
                                    }
                                }
                            });
                        }
                    }

                    if (typeof nValue == 'undefined') {
                        nValue = detail_subgrid.cells(rId, cInd).getValue();
                    }
                    var grid_xml = "<GridXML>";
                    grid_xml += '<GridRow row_id="' + row_id + '" blotterleg="' + blotterleg + '" ' + column_id + '="' + nValue + '" ></GridRow></GridXML>';
                    data = {"action": "spa_blotter_deal", "flag":"x", "process_id":detail_info.process_id, "xml":grid_xml};
                    adiha_post_data("return", data, '', '', '');

                    return true;
                }                
            });

            detail_subgrid.attachEvent("onBeforeSelect", function(new_row,old_row,new_col_index){
                dealBlotter.blotter_grid.clearSelection();
                return true;
            });

            detail_subgrid.attachEvent("onRowSelect", function(rId, index){
                sub_grid_context_menu = new dhtmlXMenuObject();
                sub_grid_context_menu.renderAsContextMenu();

                sub_grid_context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                    var data = detail_subgrid.contextID.split("_"); //rowId_colInd
                    var sub_grid_row_id = data[0];
                    var column_index = data[1];
                    var deal_id = "<?php echo $deal_id ?? ''; ?>";  

                    var col_label = detail_subgrid.getColLabel(column_index);
                    var col_type = detail_subgrid.getColType(column_index);
                    var col_value = detail_subgrid.cells(sub_grid_row_id, column_index).getValue();

                    if (col_type == 'win_link') {
                        var col_text = detail_subgrid.cells(sub_grid_row_id, column_index).getTitle();
                        col_value = col_value+'^'+col_text;
                    }

                    dealBlotter.blotter_grid.forEachRow(function(id){
                        var get_sub_grid = dealBlotter.blotter_grid.cells(id, 0).getSubGrid();
                        get_sub_grid.forEachRow(function(gid) {
                            get_sub_grid.cells(gid, column_index).setValue(col_value);
                            get_sub_grid.cells(gid, column_index).cell.wasChanged = true;
                            get_sub_grid.callEvent("onEditCell", [2, gid, column_index]);
                        });
                    })
                });
                sub_grid_context_menu.loadFromHTML("context_menu", false);
                detail_subgrid.enableContextMenu(sub_grid_context_menu);
            });
			
			detail_subgrid.attachEvent("onTab", function(mode){
				var a = this._getNextCell(null, 1);
				if (!mode) {	
					if (a !== null) {
						var cell_index = a._cellIndex;
						var row_ind = this.row.rowIndex;
						
						if (cell_index == 4 && row_ind == 1) {
							if (window.event) window.event.preventDefault();
							dealBlotter.select_previous_parent_cell(sub_id);						
							return false;
						}
					} 					
				}
				
				if (a == null && mode) {
					if (window.event) window.event.preventDefault();
					dealBlotter.select_next_parent_cell(sub_id);						
					return false;
				}
					
				return true;
			});
        });
		
		dealBlotter.blotter_grid.attachEvent("onTab", function(mode){
			var a = this._getNextCell(null, 1);	
			
			if ((a == null || this.row != a.parentNode) && mode) {
				var row_id = this.row.idd;
				if (window.event) window.event.preventDefault();
				dealBlotter.select_next_cell(row_id);
				return false;
			} 
			
			if (a != null && a._cellIndex == 2 && !mode) {
				var row_index = this.row.rowIndex;
				if (window.event) window.event.preventDefault();
				dealBlotter.select_previous_child_cell(row_index);
				return false;
			}
			
			return true;
        });

        dealBlotter.blotter_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (stage == 2) {
            	var counterparty_index = dealBlotter.blotter_grid.getColIndexById('counterparty_id');
                var trader_index = dealBlotter.blotter_grid.getColIndexById('trader_id');
    			var jurisdiction_index = dealBlotter.blotter_grid.getColIndexById('state_value_id');

            	if (typeof counterparty_index != 'undefined') {
            		var cpty_id = dealBlotter.blotter_grid.cells(rId, counterparty_index).getValue();
            		var check_cpty_index = counterparty_index;
            	} else {            		
            		var cpty_id = '';
            		var check_cpty_index = '';
            	}

            	if (typeof trader_index != 'undefined') {
            		var trader_id = dealBlotter.blotter_grid.cells(rId, trader_index).getValue();
            		var check_trader_index = trader_index;            		
            	} else {
            		var trader_id = '';
            		var check_trader_index = '';
            	}

            	if (typeof jurisdiction_index != 'undefined') {
            		var state_value_id = dealBlotter.blotter_grid.cells(rId, jurisdiction_index).getValue();
            		var check_jurisdiction_index = jurisdiction_index;
            	} else {
            		var state_value_id = '';
            		var check_jurisdiction_index = '';
            	}

            	if ((check_trader_index == cInd || check_cpty_index == cInd) && nValue != oValue) {
	                dealBlotter.load_contract_dropdown(rId, cpty_id, trader_id);
                    dealBlotter.load_detail_dropdown(rId, cpty_id, trader_id);
	        	} else if (check_jurisdiction_index == cInd && nValue != oValue) {
	        		dealBlotter.load_tier_dropdown(rId, state_value_id);
	        	}

                return true;
            }
        });
    }

    /**
     * [load_tier_dropdown Load tier dropdown according to Jurisdiction]
     * @param  {[type]} row_id          [Grid Row ID]
     * @param  {[type]} state_value_id [Jurisdiction Id]
     */
    dealBlotter.load_tier_dropdown = function(row_id, state_value_id) {
        var template_id = dealBlotter.filter_form.getItemValue("template");
        var tier_index = dealBlotter.blotter_grid.getColIndexById('tier_value_id');

        if (typeof tier_index != 'undefined') {
            var tier_combo = dealBlotter.blotter_grid.cells(row_id, tier_index).getCellCombo();
            var default_value_tier = dealBlotter.blotter_grid.cells(row_id, tier_index).getValue();
            tier_combo.enableFilteringMode("between", null, false);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "state_value_id": state_value_id, "deal_fields": "tier_value_id", "default_value":default_value_tier};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;            
           
            tier_combo.clearAll();
            tier_combo.load(url, function(){
                var index = tier_combo.getOption(default_value_tier);
                if (index && index != null) {
                    dealBlotter.blotter_grid.cells(row_id, tier_index).setValue(default_value_tier);
                } else {
                	dealBlotter.blotter_grid.cells(row_id, tier_index).setValue('');
                }              
            });      
        }
    }

	dealBlotter.open_formula = function(grid, rId, cInd, oValue, x, y, w, z) {
		var formula_id = grid.cells(rId, cInd).getValue();
        var leg = grid.cells(rId, 2).getValue();

        var row_id = grid.cells(rId, 1).getValue();
        var source_deal_detail_id = 'NEW_' + row_id + '_' + leg;
        var group_id = row_id;

		if (blotter_formula_popup && blotter_formula_popup.isVisible()) {
			blotter_formula_popup.hide();
			return;
		}

		if (blotter_formula_layout != null && blotter_formula_layout.unload != null) {
			blotter_formula_layout.unload();
			blotter_formula_layout = null;
		}

		if (blotter_formula_popup != null && blotter_formula_popup.unload != null) {
			blotter_formula_popup.unload();
			blotter_formula_popup = null;
		}

		if (!blotter_formula_popup) {
			blotter_formula_popup = new dhtmlXPopup();
		}

		blotter_formula_popup.attachEvent('onShow', function() {
			if (!blotter_formula_layout) {
				var formula_form_data = <?php echo $formula_form_data;?>;					
				blotter_formula_layout = blotter_formula_popup.attachLayout(600, 200, "2U");
				blotter_formula_layout.cells('a').hideHeader();
				blotter_formula_layout.cells('a').setWidth(210);
				blotter_formula_layout.cells('b').setText('Formula Fields');
				blotter_formula_layout.cells('b').collapse();
				blotter_formula_form = blotter_formula_layout.cells('a').attachForm(formula_form_data);
				blotter_formula_form.setItemValue('source_deal_detail_id',source_deal_detail_id);
				blotter_formula_form.setItemValue('group_id',group_id);
				blotter_formula_form.setItemValue('leg',leg);
				blotter_formula_form.setItemValue('row_id',row_id);
			}
			

			blotter_formula_field_form = blotter_formula_layout.cells('b').attachForm();
			attach_browse_event('blotter_formula_form', 10131010, 'dealBlotter.new_formula_change');

			blotter_formula_form.attachEvent('onChange', function(id, value) {
				if (id == 'form_sel' && value == 't') {
					blotter_formula_form.hideItem('label_new_formula_id');
					blotter_formula_form.showItem('exist_formula');
				} else if (id == 'form_sel' && value == 'c') {
					blotter_formula_form.hideItem('exist_formula');
					blotter_formula_form.showItem('label_new_formula_id');
				} else if (id == 'exist_formula' || id == 'new_formula_id') {
					if (value != '' && value != null) {	
						var d_row_id = blotter_formula_form.getItemValue('row_id');
						var detail_id = blotter_formula_form.getItemValue('source_deal_detail_id');
						var d_leg = blotter_formula_form.getItemValue('leg');
						var d_group_id = blotter_formula_form.getItemValue('group_id');
						var cm_param = {"action": "spa_deal_pricing_formula_udf", "flag": "y", "formula_id":value, "row_id":d_row_id, "source_deal_detail_id":detail_id, "leg":leg, "source_deal_group_id":d_group_id, "process_id":formula_process_id};
						adiha_post_data("return", cm_param, '', '', 'dealBlotter.load_formula_fields');
					}
				}
			})

			blotter_formula_form.attachEvent('onButtonClick', function(btn_id) {
	            if (btn_id == 'ok') {
	                blotter_formula_popup.hide();
	                return;
	            }
	        });

			if (!formula_id) formula_id = '';
			if (formula_id != '' && formula_id != null) {	            	
				var cm_param = {"action": "spa_deal_pricing_formula_udf", "flag": "z", "formula_id":formula_id};
				adiha_post_data("return", cm_param, '', '', 'dealBlotter.is_formula_template');
			}
		});		

		blotter_formula_popup.show(x, y, w, z);
		

		blotter_formula_popup.attachEvent('onHide', function(){
			var new_old = blotter_formula_form.getCheckedValue('form_sel');

			if (new_old == 't') {
				var combo = blotter_formula_form.getCombo('exist_formula'); 
				var formula_id = blotter_formula_form.getItemValue('exist_formula');
				var formula_text = combo.getComboText();
			} else {
				var formula_id = blotter_formula_form.getItemValue('new_formula_id');
				var formula_text = blotter_formula_form.getItemValue('label_new_formula_id');
			}

			grid.cells(rId, cInd).setValue(formula_id + '^' + formula_text);
			grid.cells(rId, cInd).cell.wasChanged=true;
			grid.callEvent("onEditCell", [2, rId, cInd, formula_id, oValue]);

			if (blotter_formula_field_form instanceof dhtmlXForm) {
				var form_data = blotter_formula_field_form.getFormData();
				var form_xml = '<Root>';

				var d_row_id = blotter_formula_form.getItemValue('row_id');
				var detail_id = blotter_formula_form.getItemValue('source_deal_detail_id')
				var d_leg = blotter_formula_form.getItemValue('leg');
				var d_group_id = blotter_formula_form.getItemValue('group_id');

				for (var a in form_data) {
					form_xml += "<FormXML row_id=\"" + d_row_id + "\" leg=\"" + d_leg + "\" source_deal_group_id=\"" + d_group_id + "\" source_deal_detail_id=\"" + detail_id + "\"  udf_template_id=\"" + a + "\"  udf_value=\"" + form_data[a] + "\"></FormXML>";
				}    	

				form_xml += "</Root>";		
			}

			var cm_param = {"action": "spa_deal_pricing_formula_udf", "flag": "x", "process_id":formula_process_id, "form_xml":form_xml};
			adiha_post_data("return", cm_param, '', '', '');
		});
	}

	dealBlotter.new_formula_change = function(row_id, group_id, leg, source_deal_detail_id) {
		var formula_id = blotter_formula_form.getItemValue('new_formula_id');
		if (formula_id != '' && formula_id != null) {	
			var d_row_id = blotter_formula_form.getItemValue('row_id');
			var detail_id = blotter_formula_form.getItemValue('source_deal_detail_id');
			var d_leg = blotter_formula_form.getItemValue('leg');
			var d_group_id = blotter_formula_form.getItemValue('group_id');
			var cm_param = {"action": "spa_deal_pricing_formula_udf", "flag": "y", "formula_id":formula_id, "row_id":d_row_id, "source_deal_detail_id":detail_id, "leg":leg, "source_deal_group_id":d_group_id, "process_id":formula_process_id};
			adiha_post_data("return", cm_param, '', '', 'dealBlotter.load_formula_fields');
		}
	}

	dealBlotter.is_formula_template = function(result) {
		if (result[0].form_json == 'y') {	
			blotter_formula_form.checkItem('form_sel', 't');
			blotter_formula_form.callEvent("onChange", ["form_sel", "t"]);	
			blotter_formula_form.setItemValue('exist_formula', result[0].formula_id);
			blotter_formula_form.callEvent("onChange", ["exist_formula", result[0].formula_id]); 
		} else {
			blotter_formula_form.checkItem('form_sel', 'c');
			blotter_formula_form.callEvent("onChange", ["form_sel", "c"]); 
			blotter_formula_form.setItemValue('new_formula_id', result[0].formula_id);
			blotter_formula_form.setItemValue('label_new_formula_id', result[0].formula_text);
			blotter_formula_form.callEvent("onChange", ["new_formula_id", result[0].formula_id]);
		}	
	}

	dealBlotter.load_formula_fields = function(result) {
		if (result[0].form_json != '' && result[0].form_json != 'undefined') {
			if (blotter_formula_field_form instanceof dhtmlXForm) {
				var form_data = blotter_formula_field_form.getFormData();
				for (var a in form_data) {
					blotter_formula_field_form.removeItem(a);
				} 
				blotter_formula_layout.cells('b').expand();
				blotter_formula_field_form.load(result[0].form_json);
				
			}
		}
	}
	
	dealBlotter.select_next_cell = function(row_id) {
		var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
		detail_subgrid.selectCell(0, 3, false, true, true);
	}
	
	dealBlotter.select_next_parent_cell = function(row_id) {
		var row_index = dealBlotter.blotter_grid.getRowIndex(row_id);
		var no_of_row = dealBlotter.blotter_grid.getRowsNum();
		
		if (row_index != no_of_row-1) {	
			dealBlotter.blotter_grid.selectCell(row_index+1, 1, false, true, true);
		} else {
			var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
			dealBlotter.blotter_grid.clearSelection();
			detail_subgrid.clearSelection();
			dealBlotter.filter_form.setItemFocus('template');
		}
	}
	
	dealBlotter.select_previous_child_cell = function(row_index) {
		if (row_index != 1) {
			var row_id = dealBlotter.blotter_grid.getRowId(row_index-2);
			var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
			var no_of_col = detail_subgrid.getColumnsNum();
			var selected_col = no_of_col-1;
			var no_of_row = detail_subgrid.getRowsNum();
			var selected_row = no_of_row-1;
			detail_subgrid.selectCell(selected_row, selected_col, false, true, true);
		} else {
			dealBlotter.blotter_grid.clearSelection();
			dealBlotter.filter_form.setItemFocus('no_of_deals');
		}
	}
	
	dealBlotter.select_previous_parent_cell = function(row_id) {
		var no_of_col = dealBlotter.blotter_grid.getColumnsNum();
		var selected_col = no_of_col-1;
		var row_ind = dealBlotter.blotter_grid.getRowIndex(row_id);
		dealBlotter.blotter_grid.selectCell(row_ind, selected_col, false, true, true);
	}

    /**
     * [load_deal_mapping_combos Load deal mapping combos after loading grid on template change event]
     * @param  {[type]} rId [description]
     * @return {[type]}     [description]
     */
    dealBlotter.load_deal_mapping_combos = function(rId) {
        var counterparty_index = dealBlotter.blotter_grid.getColIndexById('counterparty_id');
        var trader_index = dealBlotter.blotter_grid.getColIndexById('trader_id');

        if (rId == '') {
            dealBlotter.blotter_grid.forEachRow(function(row_id) {
                if (typeof counterparty_index == 'undefined') {
                    var counterparty_id = 'NULL';
                } else {
                    counterparty_id = dealBlotter.blotter_grid.cells(row_id, counterparty_index).getValue();
                }
                counterparty_id = (counterparty_id == '' || counterparty_id == 'NULL') ? -1 : counterparty_id;

                if (typeof trader_index == 'undefined') {
                    var trader_id = 'NULL';
                } else {
                    trader_id = dealBlotter.blotter_grid.cells(row_id, trader_index).getValue();
                }
                trader_id = (trader_id == '' || trader_id == 'NULL') ? -1 : trader_id;

                dealBlotter.load_contract_dropdown(row_id, counterparty_id, trader_id);
                dealBlotter.load_detail_dropdown(row_id, counterparty_id, trader_id);
            });
        } else {
            if (typeof counterparty_index == 'undefined') {
                var counterparty_id = 'NULL';
            } else {
                counterparty_id = dealBlotter.blotter_grid.cells(rId, counterparty_index).getValue();
            }

            if (typeof trader_index == 'undefined') {
                var trader_id = 'NULL';
            } else {
                trader_id = dealBlotter.blotter_grid.cells(rId, trader_index).getValue();
            }

            dealBlotter.load_contract_dropdown(rId, counterparty_id, trader_id);
            dealBlotter.load_detail_dropdown(rId, counterparty_id, trader_id);
        }
    }

    /**
     * [load_counterparty_dropdown Load counterparty dropdown as defined in deal field mapping]
     * @return {[type]} [description]
     */
    dealBlotter.load_counterparty_dropdown = function(row_id) {  
        var template_id = dealBlotter.filter_form.getItemValue("template");
        var counterparty_index = dealBlotter.blotter_grid.getColIndexById('counterparty_id');
        var trader_index = dealBlotter.blotter_grid.getColIndexById('trader_id');

        if (typeof counterparty_index != 'undefined' || typeof trader_index != 'undefined') {
            //dealBlotter.blotter_grid.forEachRow(function(row_id) {            
                if (typeof counterparty_index != 'undefined') {
	                var default_value_cpty = dealBlotter.blotter_grid.cells(row_id, counterparty_index).getValue();
	                var counterparty_combo = dealBlotter.blotter_grid.cells(row_id, counterparty_index).getCellCombo();

	                var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "deal_fields": "counterparty_id", "default_value":default_value_cpty};
	                cm_param = $.param(cm_param);
	                var url = js_dropdown_connector_url + '&' + cm_param;
	                counterparty_combo.clearAll();
	                counterparty_combo.enableFilteringMode("between", null, false);
	                counterparty_combo.load(url, function() {
	                    var index = counterparty_combo.getOption(default_value_cpty);	
	                    if (index && index != null) {
	                        dealBlotter.blotter_grid.cells(row_id, counterparty_index).setValue(default_value_cpty);
	                    } else {
	                    	dealBlotter.blotter_grid.cells(row_id, counterparty_index).setValue('');
	                    }

	                    if (typeof trader_index == 'undefined')
	                    	dealBlotter.load_deal_mapping_combos(row_id);
	                });
                }

                if (typeof trader_index != 'undefined') {
                	var default_value_trader = dealBlotter.blotter_grid.cells(row_id, trader_index).getValue();
	                var trader_combo = dealBlotter.blotter_grid.cells(row_id, trader_index).getCellCombo();

	                var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "deal_fields": "trader_id", "default_value":default_value_trader};
	                cm_param = $.param(cm_param);
	                var url = js_dropdown_connector_url + '&' + cm_param;
	                trader_combo.clearAll();
	                trader_combo.enableFilteringMode("between", null, false);
	                trader_combo.load(url, function() {
	                    var index = trader_combo.getOption(default_value_trader);
	                    if (index && index != null) {
	                        dealBlotter.blotter_grid.cells(row_id, trader_index).setValue(default_value_trader);
	                    } else {
	                    	dealBlotter.blotter_grid.cells(row_id, trader_index).setValue('');
	                    }
	                    dealBlotter.load_deal_mapping_combos(row_id);
	                });
                }
            //})
        } else {
            dealBlotter.load_deal_mapping_combos('');
        }


    }
	
	var apply_to_all_row1 = null;
	/**
     * [load_contract_dropdown_apply_to_all - call from apply to all Load contract dropdown according to deal mapping relations]
     * @param  {[type]} row_id          [Grid Row ID]
     * @param  {[type]} counterparty_id [Counterparty Id]
     */
    dealBlotter.load_contract_dropdown_apply_to_all = function(row_id, counterparty_id, trader_id) {		
        var template_id = dealBlotter.filter_form.getItemValue("template");
        var contract_index = dealBlotter.blotter_grid.getColIndexById('contract_id');
		
		if (typeof contract_index != 'undefined') {
			var counterparty_trader_index = dealBlotter.blotter_grid.getColIndexById('counterparty_trader');
			var default_value = 'NULL';
			apply_to_all_row1 = row_id;
			var cm_param = {"action": "spa_deal_fields_mapping", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "contract_id", "default_value":default_value, "trader_id":trader_id};
			dealBlotter.blotter_layout.cells('c').progressOn();
			adiha_post_data('return', cm_param, '', '', 'dealBlotter.load_contract_apply_to_all');
		}
    }
	
	dealBlotter.load_contract_apply_to_all = function(return_val) {
		var json_obj = $.parseJSON(return_val[0].json_string);
		var row_index = dealBlotter.blotter_grid.getRowIndex(apply_to_all_row1);
		var contract_index = dealBlotter.blotter_grid.getColIndexById('contract_id');
		
		for (var i = row_index; i < dealBlotter.blotter_grid.getRowsNum(); i++){
			var contract_combo = dealBlotter.blotter_grid.cellByIndex(i, contract_index).getCellCombo();
			var default_value = dealBlotter.blotter_grid.cellByIndex(i, contract_index).getValue();
			contract_combo.enableFilteringMode("between", null, false);

			contract_combo.clearAll();
			contract_combo.load(json_obj,function() {
				var index = contract_combo.getOption(default_value);
				if (index && index != null) {
					dealBlotter.blotter_grid.cells2(i, contract_index).setValue(default_value);
				} else {
					dealBlotter.blotter_grid.cells2(i, contract_index).setValue('');
				}
				
			});
		};
		dealBlotter.blotter_layout.cells('c').progressOff();
	}
	
	var apply_to_all_row2 = null;
	
	dealBlotter.load_curve_apply_to_all = function(return_val) {
		var json_obj = $.parseJSON(return_val[0].json_string);
		var row_index = dealBlotter.blotter_grid.getRowIndex(apply_to_all_row2);
		
		for (var i = row_index; i < dealBlotter.blotter_grid.getRowsNum(); i++){
			var detail_subgrid = dealBlotter.blotter_grid.cellByIndex(i, 0).getSubGrid();
			
			if (detail_subgrid) {
				var curve_index = detail_subgrid.getColIndexById('curve_id');
				if (typeof curve_index == 'undefined') return;
				for (var j = 0; j < detail_subgrid.getRowsNum(); j++){
					var curve_combo = detail_subgrid.cellByIndex(j, curve_index).getCellCombo();
					var default_value_curve = detail_subgrid.cellByIndex(j, curve_index).getValue();
					
					curve_combo.enableFilteringMode("between", null, false);
					curve_combo.clearAll();
					curve_combo.load(json_obj, function() {					
						var index = curve_combo.getOption(default_value_curve);
                        if (index && index != null) {
                            detail_subgrid.cells2(j, curve_index).setValue(default_value_curve);
                        } else {
                        	detail_subgrid.cells2(j, curve_index).setValue('');
                        }
					});
				}
			}
		};	
					
		dealBlotter.blotter_layout.cells('c').progressOff();
	}
	
	dealBlotter.load_formula_curve_apply_to_all = function(return_val) {
		var json_obj = $.parseJSON(return_val[0].json_string);
		var row_index = dealBlotter.blotter_grid.getRowIndex(apply_to_all_row2);
		
		for (var i = row_index; i < dealBlotter.blotter_grid.getRowsNum(); i++){
			var detail_subgrid = dealBlotter.blotter_grid.cellByIndex(i, 0).getSubGrid();
			
			if (detail_subgrid) {
				var curve_index = detail_subgrid.getColIndexById('formula_curve_id');
				if (typeof curve_index == 'undefined') return;
				
				for (var j = 0; j < detail_subgrid.getRowsNum(); j++){
					var curve_combo = detail_subgrid.cellByIndex(j, curve_index).getCellCombo();
					var default_value = detail_subgrid.cellByIndex(j, curve_index).getValue();
					
					curve_combo.enableFilteringMode("between", null, false);
					curve_combo.clearAll();
					curve_combo.load(json_obj, function() {					
						var index = curve_combo.getOption(default_value);
                        if (index && index != null) {
                            detail_subgrid.cells2(j, curve_index).setValue(default_value);
                        } else {
                        	detail_subgrid.cells2(j, curve_index).setValue('');
                        }
					});
				}
			}
		};
		dealBlotter.blotter_layout.cells('c').progressOff();
	}
	
	dealBlotter.load_location_apply_to_all = function(return_val) {
		var json_obj = $.parseJSON(return_val[0].json_string);
		var row_index = dealBlotter.blotter_grid.getRowIndex(apply_to_all_row2);
		
		for (var i = row_index; i < dealBlotter.blotter_grid.getRowsNum(); i++){
			var detail_subgrid = dealBlotter.blotter_grid.cellByIndex(i, 0).getSubGrid();
			
			if (detail_subgrid) {
				var cell_index = detail_subgrid.getColIndexById('location_id');
				if (typeof cell_index == 'undefined') return;
				
				for (var j = 0; j < detail_subgrid.getRowsNum(); j++){
					var combo = detail_subgrid.cellByIndex(j, cell_index).getCellCombo();
					var default_value = detail_subgrid.cellByIndex(j, cell_index).getValue();
					
					combo.enableFilteringMode("between", null, false);
					combo.clearAll();
					combo.load(json_obj, function() {					
						var index = combo.getOption(default_value);
                        if (index && index != null) {
                            detail_subgrid.cells2(j, cell_index).setValue(default_value);
                        } else {
                        	detail_subgrid.cells2(j, cell_index).setValue('');
                        }
					});
				}
			}
		};
		dealBlotter.blotter_layout.cells('c').progressOff();
	}
	
	dealBlotter.load_commodity_apply_to_all = function(return_val) {
		var json_obj = $.parseJSON(return_val[0].json_string);
		var row_index = dealBlotter.blotter_grid.getRowIndex(apply_to_all_row2);
		
		for (var i = row_index; i < dealBlotter.blotter_grid.getRowsNum(); i++){
			var detail_subgrid = dealBlotter.blotter_grid.cellByIndex(i, 0).getSubGrid();
			
			if (detail_subgrid) {
				var cell_index = detail_subgrid.getColIndexById('detail_commodity_id');
				if (typeof cell_index == 'undefined') return;
				
				for (var j = 0; j < detail_subgrid.getRowsNum(); j++){
					var combo = detail_subgrid.cellByIndex(j, cell_index).getCellCombo();
					var default_value = detail_subgrid.cellByIndex(j, cell_index).getValue();
					
					combo.enableFilteringMode("between", null, false);
					combo.clearAll();
					combo.load(json_obj, function() {					
						var index = combo.getOption(default_value);
                        if (index && index != null) {
                            detail_subgrid.cells2(j, cell_index).setValue(default_value);
                        } else {
                        	detail_subgrid.cells2(j, cell_index).setValue('');
                        }
					});
				}
			}
		};
		
		dealBlotter.blotter_layout.cells('c').progressOff();
	}
	
	/**
     * [load_detail_dropdown_apply_to_all Load dropdowns in detail grid according to deal mapping relations]
     * @param  {[type]} row_id          [Grid Row ID]
     * @param  {[type]} counterparty_id [Counterparty Id]
     */
    dealBlotter.load_detail_dropdown_apply_to_all = function(row_id, counterparty_id, trader_id) {
        var template_id = dealBlotter.filter_form.getItemValue("template");
		var default_value = 'NULL';
		var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
		
		if (detail_subgrid) {			
			var curve_index = detail_subgrid.getColIndexById('curve_id');
			if (typeof curve_index != 'undefined') {
				apply_to_all_row2 = row_id;
				var cm_param = {"action": "spa_deal_fields_mapping", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "curve_id", "default_value":default_value, "trader_id":trader_id};
				dealBlotter.blotter_layout.cells('c').progressOn();
				adiha_post_data('return', cm_param, '', '', 'dealBlotter.load_curve_apply_to_all');
			}
			
			var f_curve_index = detail_subgrid.getColIndexById('formula_curve_id');
			if (typeof f_curve_index != 'undefined') {
				cm_param = {"action": "spa_deal_fields_mapping", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "formula_curve_id", "default_value":default_value, "trader_id":trader_id};
				dealBlotter.blotter_layout.cells('c').progressOn();
				adiha_post_data('return', cm_param, '', '', 'dealBlotter.load_formula_curve_apply_to_all');
			}
			
			var location_index = detail_subgrid.getColIndexById('location_id');
			if (typeof f_curve_index != 'undefined') {
				cm_param = {"action": "spa_deal_fields_mapping", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "location_id", "default_value":default_value, "trader_id":trader_id};
				dealBlotter.blotter_layout.cells('c').progressOn();
				adiha_post_data('return', cm_param, '', '', 'dealBlotter.load_location_apply_to_all');
			}
			
			var detail_commodity_index = detail_subgrid.getColIndexById('detail_commodity_id');
			if (typeof detail_commodity_index != 'undefined') {
				cm_param = {"action": "spa_deal_fields_mapping", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "detail_commodity_id", "default_value":default_value, "trader_id":trader_id};
				dealBlotter.blotter_layout.cells('c').progressOn();
				adiha_post_data('return', cm_param, '', '', 'dealBlotter.load_commodity_apply_to_all');
			} else {
				dealBlotter.blotter_layout.cells('c').progressOff();
			}
		}
    }

    /**
     * [load_contract_dropdown Load contract dropdown according to deal mapping relations]
     * @param  {[type]} row_id          [Grid Row ID]
     * @param  {[type]} counterparty_id [Counterparty Id]
     */
    dealBlotter.load_contract_dropdown = function(row_id, counterparty_id, trader_id) {
        var template_id = dealBlotter.filter_form.getItemValue("template");
        var contract_index = dealBlotter.blotter_grid.getColIndexById('contract_id');
        var counterparty_trader_index = dealBlotter.blotter_grid.getColIndexById('counterparty_trader');
        var sub_book_index = dealBlotter.blotter_grid.getColIndexById('sub_book');

        if (typeof contract_index != 'undefined') {
            var contract_combo = dealBlotter.blotter_grid.cells(row_id, contract_index).getCellCombo();
            var default_value_contract = dealBlotter.blotter_grid.cells(row_id, contract_index).getValue();
            contract_combo.enableFilteringMode("between", null, false);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "contract_id", "default_value":default_value_contract, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;            
           
            contract_combo.clearAll();
            contract_combo.load(url, function(){
                var index = contract_combo.getOption(default_value_contract);
                if (index && index != null) {
                    dealBlotter.blotter_grid.cells(row_id, contract_index).setValue(default_value_contract);
                } else {
                	dealBlotter.blotter_grid.cells(row_id, contract_index).setValue('');
                }              
            });      
        }

        if (typeof counterparty_trader_index != 'undefined') {
            var counterparty_trader_combo = dealBlotter.blotter_grid.cells(row_id, counterparty_trader_index).getCellCombo();
            var default_value_ct = dealBlotter.blotter_grid.cells(row_id, counterparty_trader_index).getValue();
            counterparty_trader_combo.enableFilteringMode("between", null, false);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "counterparty_trader", "default_value":default_value_ct, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;   

            counterparty_trader_combo.clearAll();
            counterparty_trader_combo.load(url, function(){
                var index = counterparty_trader_combo.getOption(default_value_ct);
                if (index && index != null) {
                    dealBlotter.blotter_grid.cells(row_id, counterparty_trader_index).setValue(default_value_ct);
                } else {
                	dealBlotter.blotter_grid.cells(row_id, counterparty_trader_index).setValue('');
                }               
            });      
        }

        if (typeof sub_book_index != 'undefined') {
            var sub_book_combo = dealBlotter.blotter_grid.cells(row_id, sub_book_index).getCellCombo();
            var default_value_sb = dealBlotter.blotter_grid.cells(row_id, sub_book_index).getValue();
            sub_book_combo.enableFilteringMode("between", null, false);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "sub_book", "default_value":default_value_sb, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;            
            
            sub_book_combo.clearAll();
            sub_book_combo.load(url, function(){
                var index = sub_book_combo.getOption(default_value_sb);
                if (index && index != null) {
                    dealBlotter.blotter_grid.cells(row_id, sub_book_index).setValue(default_value_sb);
                } else {
                	dealBlotter.blotter_grid.cells(row_id, sub_book_index).setValue('');
                }               
            });      
        }
    }

    /**
     * [load_detail_dropdown Load dropdowns in detail grid according to deal mapping relations]
     * @param  {[type]} row_id          [Grid Row ID]
     * @param  {[type]} counterparty_id [Counterparty Id]
     */
    dealBlotter.load_detail_dropdown = function(row_id, counterparty_id, trader_id) {
        var template_id = dealBlotter.filter_form.getItemValue("template");
        var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
        
        if (detail_subgrid) {
            detail_subgrid.forEachRow(function(detail_row_id){
                var curve_index = detail_subgrid.getColIndexById('curve_id');
                if (typeof curve_index != 'undefined') {
                    var curve_combo = detail_subgrid.cells(detail_row_id, curve_index).getCellCombo();
                    var default_value_curve = detail_subgrid.cells(detail_row_id, curve_index).getValue();
                    curve_combo.enableFilteringMode("between", null, false);
                    var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "curve_id", "default_value":default_value_curve, "trader_id":trader_id};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;

                    curve_combo.clearAll();
                    curve_combo.load(url, function(){
                        var index = curve_combo.getOption(default_value_curve);
                        if (index && index != null) {
                            detail_subgrid.cells(detail_row_id, curve_index).setValue(default_value_curve);
                        } else {
                        	detail_subgrid.cells(detail_row_id, curve_index).setValue('');
                        }               
                    });
                }

                var formula_curve_index = detail_subgrid.getColIndexById('formula_curve_id');
                if (typeof formula_curve_index != 'undefined') {
                    var formula_curve_combo = detail_subgrid.cells(detail_row_id, formula_curve_index).getCellCombo();
                    var default_value_fc = detail_subgrid.cells(detail_row_id, formula_curve_index).getValue();
                    formula_curve_combo.enableFilteringMode("between", null, false);
                    var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "formula_curve_id", "default_value":default_value_fc, "trader_id":trader_id};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    
                    formula_curve_combo.clearAll();
                    formula_curve_combo.load(url, function(){
                        var index = formula_curve_combo.getOption(default_value_fc);
                        if (index && index != null) {
                            detail_subgrid.cells(detail_row_id, formula_curve_index).setValue(default_value_fc);
                        } else {
                        	detail_subgrid.cells(detail_row_id, formula_curve_index).setValue('');
                        }                
                    });
                    
                }

                var location_index = detail_subgrid.getColIndexById('location_id');
                if (typeof location_index != 'undefined') {
                    var location_combo = detail_subgrid.cells(detail_row_id, location_index).getCellCombo();
                    var default_value_loc = detail_subgrid.cells(detail_row_id, location_index).getValue();
                    location_combo.enableFilteringMode("between", null, false);
                    var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "location_id", "default_value":default_value_loc, "trader_id":trader_id};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;     

                    location_combo.clearAll();
                    location_combo.load(url, function(){
                        var index = location_combo.getOption(default_value_loc);
                        if (index && index != null) {
                            detail_subgrid.cells(detail_row_id, location_index).setValue(default_value_loc);
                        } else {
                        	detail_subgrid.cells(detail_row_id, location_index).setValue('');
                        }             
                    });
                    
                }

                var detail_commodity_index = detail_subgrid.getColIndexById('detail_commodity_id');
                if (typeof detail_commodity_index != 'undefined') {
                    var detail_commodity_combo = detail_subgrid.cells(detail_row_id, detail_commodity_index).getCellCombo();
                    var default_value_comm = detail_subgrid.cells(detail_row_id, detail_commodity_index).getValue();
                    detail_commodity_combo.enableFilteringMode("between", null, false);
                    var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "detail_commodity_id", "default_value":default_value_comm, "trader_id":trader_id};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    
                    detail_commodity_combo.clearAll();
                    detail_commodity_combo.load(url, function(){
                        var index = detail_commodity_combo.getOption(default_value_comm);
                        if (index && index != null) {
                            detail_subgrid.cells(detail_row_id, detail_commodity_index).setValue(default_value_comm);
                        } else {
                        	detail_subgrid.cells(detail_row_id, detail_commodity_index).setValue('');
                        }               
                    });                    
                }
                dealBlotter.load_shipper1_dropdown(row_id);
                dealBlotter.load_shipper2_dropdown(row_id);
            });
        }
    }

    /**
     * [load_shipper1_dropdown Load Shipper Code1 dropdown]
     * @param  {[type]} row_id          [Grid Row ID]
     */
    dealBlotter.load_shipper1_dropdown = function(row_id) {
        var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
        var template_id = dealBlotter.filter_form.getItemValue("template");
        if (detail_subgrid) {
            detail_subgrid.forEachRow(function(detail_row_id) {
                var shipper_code1_index = detail_subgrid.getColIndexById('shipper_code1');
                if (typeof shipper_code1_index != 'undefined') {
                    var sub_book_index = dealBlotter.blotter_grid.getColIndexById('sub_book');
                    var sub_book_id = dealBlotter.blotter_grid.cells(row_id, sub_book_index).getValue();
                    
                    var location_id_index = detail_subgrid.getColIndexById('location_id');
                    var location_id;
                    if  (typeof location_id_index != 'undefined') location_id = detail_subgrid.cells(detail_row_id, location_id_index).getValue();

                    var term_start_index = detail_subgrid.getColIndexById('term_start');
                    var term_start;
                    if  (typeof term_start_index != 'undefined') term_start = detail_subgrid.cells(detail_row_id, term_start_index).getValue();                   
                   
                    var shipper_code1_combo = detail_subgrid.cells(detail_row_id, shipper_code1_index).getCellCombo();
                    var default_value_shipper1 = detail_subgrid.cells(detail_row_id, shipper_code1_index).getValue();
                    shipper_code1_combo.enableFilteringMode("between", null, false);
                    var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": "NULL",  "template_id": template_id, "sub_book_id": sub_book_id, "location_id": location_id,  "deal_fields": "shipper_code1", "term_start": term_start, "default_value":default_value_shipper1};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    detail_subgrid.cells(detail_row_id, shipper_code1_index).setValue('');
                    shipper_code1_combo.clearAll();
                    shipper_code1_combo.load(url, function(){                             
                        shipper_code1_combo.forEachOption(function(options){
                            if (options.selected == true) {
                                detail_subgrid.cells(detail_row_id, shipper_code1_index).setValue(options.value);
                            }
                        });                                   
                    });                    
                }
            })
        }
    }

    /**
     * [load_shipper2_dropdown Load Shipper Code1 dropdown]
     * @param  {[type]} row_id          [Grid Row ID]
     */
    dealBlotter.load_shipper2_dropdown = function(row_id) {
        var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
        var template_id = dealBlotter.filter_form.getItemValue("template");
        if (detail_subgrid) {
            detail_subgrid.forEachRow(function(detail_row_id){
                var shipper_code2_index = detail_subgrid.getColIndexById('shipper_code2');
                if (typeof shipper_code2_index != 'undefined') {
                    var counterparty_id_index = dealBlotter.blotter_grid.getColIndexById('counterparty_id');
                    var counterparty_id = dealBlotter.blotter_grid.cells(row_id, counterparty_id_index).getValue();
                    
                    var location_id_index = detail_subgrid.getColIndexById('location_id');
                    var location_id;
                    if  (typeof location_id_index != 'undefined') location_id = detail_subgrid.cells(detail_row_id, location_id_index).getValue();
                    
                    var term_start_index = detail_subgrid.getColIndexById('term_start');
                    var term_start;
                    if  (typeof term_start_index != 'undefined') term_start = detail_subgrid.cells(detail_row_id, term_start_index).getValue();                   
                                     
                    var shipper_code2_combo = detail_subgrid.cells(detail_row_id, shipper_code2_index).getCellCombo();
                    var default_value_shipper2 = detail_subgrid.cells(detail_row_id, shipper_code2_index).getValue();
                    shipper_code2_combo.enableFilteringMode("between", null, false);
                    var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": "NULL", "template_id": template_id, "counterparty_id": counterparty_id, "location_id": location_id,  "deal_fields": "shipper_code2", "term_start": term_start, "default_value":default_value_shipper2};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    detail_subgrid.cells(detail_row_id, shipper_code2_index).setValue('');
                    shipper_code2_combo.clearAll();
                    shipper_code2_combo.load(url, function(){                             
                        shipper_code2_combo.forEachOption(function(options) {
                            if (options.selected == true) {
                                detail_subgrid.cells(detail_row_id, shipper_code2_index).setValue(options.value);
                            } 
                        });                                   
                    });                                    
                }
            })
        }
    }
                

    /**
     * [unload_window Unload splitting invoice window.]
     */
    dealBlotter.unload_detail_window = function() {        
        if (detail_window != null && detail_window.unload != null) {
            detail_window.unload();
            detail_window = w1 = null;
        }
    }

    dealBlotter.menu_click = function(id) {
        switch (id) {
            case "save":
                var form_obj =  dealBlotter.filter_form;
                var status = validate_form(form_obj);
                if (!status) {
                    generate_error_message();
                    return;
                };
                dealBlotter.blotter_grid.clearSelection();
                dealBlotter.blotter_menu.setItemDisabled('save');
                var win_obj = window.parent.blotter_window.window('w1');
                win_obj.progressOn();
                
                var xml_array = new Array();
                xml_array = dealBlotter.collect_all_ids();
				
                if (typeof xml_array != undefined && xml_array != 'undefined' && xml_array[0] && xml_array[1]) {
                    var template_id = dealBlotter.filter_form.getItemValue("template");
                    var term_frequency = dealBlotter.filter_form.getItemValue("term_type");
                    
                    if (term_frequency == '') term_frequency = 'NULL';
                    if (formula_process_id == '' || formula_process_id == null) formula_process_id = 'NULL';

                    var data = {
                        "action":"spa_insert_blotter_deal",
                        "flag":"i",
                        "process_id":process_id,
                        "header_xml":xml_array[0],
                        "detail_xml":xml_array[1],
                        "template_id":template_id,
                        "term_frequency":term_frequency,
                        "formula_process_id":formula_process_id
                    }
                    result = adiha_post_data("return_array", data, '', '', "dealBlotter.save_callback");
                } 

                break;
        }
    }

    dealBlotter.save_callback = function(result) {
        if (result[0][0] == "Success") {
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });

            var win_obj = window.parent.blotter_window.window("w1");
            win_obj.progressOff();
            setTimeout(function() { 
            	win_obj.close();
            }, 1000);
        } else {
            var win_obj = window.parent.blotter_window.window("w1");
            if (save_enabled)
            dealBlotter.blotter_menu.setItemEnabled('save');

            win_obj.progressOff();
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:result[0][4]
            });
        }
    }

    /**
   * Collect selected data in xml from grid
   * @param  {[text]} attribute [description]
   * @return xml
   */
    dealBlotter.collect_all_ids = function() {
        var status = true;
        var header_xml = '<GridXML>';
        var detail_xml = '<GridXML>';
		var xml_array = new Array();

        for (var i = 0; i < dealBlotter.blotter_grid.getRowsNum(); i++){
            var row_id = dealBlotter.blotter_grid.getRowId(i);
            header_xml += '<GridRow ';
            for(var cellIndex = 0; cellIndex < dealBlotter.blotter_grid.getColumnsNum(); cellIndex++){
                dealBlotter.blotter_grid.validateCell(row_id, cellIndex);
                var validation_message = dealBlotter.blotter_grid.cells(row_id, cellIndex).getAttribute("validation");
                if (validation_message != "" && validation_message != undefined) {
                    var win_obj = window.parent.blotter_window.window('w1');
                    
                    if (save_enabled)
						dealBlotter.blotter_menu.setItemEnabled('save');

                    win_obj.progressOff();
                    var column_text = dealBlotter.blotter_grid.getColLabel(cellIndex);
                    var error_message = "Data Error in <b>Deal Header</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                    dhtmlx.alert({
                        title: "Alert",
                        type: "alert",
                        text: error_message
                    });
                    status = false; 
                    break;
                } else {
                    var grid_type = dealBlotter.blotter_grid.getColType(cellIndex);
                    var cell_value = dealBlotter.blotter_grid.cells(row_id,cellIndex).getValue();
                    var column_id = dealBlotter.blotter_grid.getColumnId(cellIndex);
                    if (column_id != 'logical_term')
                    	header_xml += ' ' + column_id + '="' + cell_value + '"';
                }
            }
            header_xml += '></GridRow>';
			
			if (!status) {	
				dhtmlx.alert({
					title: "Alert",
					type: "alert",
					text: error_message
				});
				xml_array.push(false, false);
				return xml_array;
			}
            
            if (status){
                var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
                detail_subgrid.clearSelection();
                for (var j = 0; j < detail_subgrid.getRowsNum(); j++){
                    var detail_row_id = detail_subgrid.getRowId(j);
                    detail_xml += '<GridRow deal_group="New Group" group_id="1" detail_flag="0" ';
                    for(var cellIndex = 1; cellIndex < detail_subgrid.getColumnsNum(); cellIndex++){
                        detail_subgrid.validateCell(detail_row_id, cellIndex);
                        var validation_message = detail_subgrid.cells(detail_row_id, cellIndex).getAttribute("validation");
                        if (validation_message != "" && validation_message != undefined) {
                            var column_text = detail_subgrid.getColLabel(cellIndex);
                            var win_obj = window.parent.blotter_window.window('w1');
                            
                            if (save_enabled)
                            dealBlotter.blotter_menu.setItemEnabled('save');

                            win_obj.progressOff();
                            var error_message = "Data Error in <b>Deal Detail</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                            status = false; 
                            break;
                        } else {
                            var grid_type = detail_subgrid.getColType(cellIndex);
                            var cell_value = detail_subgrid.cells(detail_row_id,cellIndex).getValue();
                            detail_xml += ' ' + detail_subgrid.getColumnId(cellIndex) + '="' + cell_value + '"';
                        }
                    }
                    detail_xml += '></GridRow>';
                };
            }
        };
        header_xml += '</GridXML>';
        detail_xml += '</GridXML>';
        var xml_array = new Array();

        if (!status) {
            dhtmlx.alert({
				title: "Alert",
				type: "alert",
				text: error_message
			});
            xml_array.push(false, false);
        } else {
            xml_array.push(header_xml, detail_xml);
        }
        return xml_array;
    }

    /**
     * [sub_book_changed Sub Book change function]
     * @param  {[type]} rId    [Row Id]
     * @param  {[type]} nValue [Sub Book Id]
     */
    dealBlotter.sub_book_changed = function(rId, nValue) {
        var internal_cpty_index = dealBlotter.blotter_grid.getColIndexById('internal_counterparty');
        if (typeof internal_cpty_index != 'undefined') {
            var internal_cpty_combo = dealBlotter.blotter_grid.getColumnCombo(internal_cpty_index);
            if (internal_cpty_combo) {                
                document.getElementById("detail_r_id").value = '';
                document.getElementById("detail_r_id").value = rId;
                data = {"action": "spa_source_deal_header", "flag":"p", "sub_book":nValue};
                adiha_post_data("return", data, '', '', 'dealBlotter.change_internal_counterparty');
            }
        }
        dealBlotter.load_shipper1_dropdown(rId);
    }

    /**
     * [change_internal_counterparty Set internal counterparty]
     */
    dealBlotter.change_internal_counterparty = function(result) {
        var row_id = $('textarea#detail_r_id').val();
        if (row_id == '') return;
        var internal_cpty_index = dealBlotter.blotter_grid.getColIndexById('internal_counterparty');
        if (typeof internal_cpty_index != 'undefined') {
            var internal_cpty_combo = dealBlotter.blotter_grid.getColumnCombo(internal_cpty_index);
            if (internal_cpty_combo && result[0].counterparty_id != -1 && result[0].counterparty_id != '') {                
				dealBlotter.blotter_grid.cells(row_id, internal_cpty_index).setValue(result[0].counterparty_id);
            }            
        }
    }

    /**
     * [deal_date_changed On change function for deal date]
     * @param  {[type]} rId    [row id]
     * @param  {[type]} deal_date [value]
     * @param  {[type]} term_rule [value]
     */
    dealBlotter.deal_date_changed = function(rId, deal_date, term_rule) {
        var template_id = dealBlotter.filter_form.getItemValue("template");
        var term_frequency = dealBlotter.filter_form.getItemValue("term_type");

        if (term_frequency == '') term_frequency = 'NULL';
        if (term_rule == '') term_rule = 'NULL';

        data = {"action": "spa_blotter_deal", "flag":"t", "template_id":template_id, "deal_date":deal_date, "term_frequency":term_frequency, "term_rule": term_rule};
        document.getElementById("detail_r_id").value = rId;
        adiha_post_data("return", data, '', '', 'dealBlotter.change_term');
    }

    /**
     * [change_term Change Term on deal date change]
     * @param  {[type]} return_val [description]
     * @return {[type]}            [description]
     */
    dealBlotter.change_term = function(return_val) {
        var row_id = $('textarea#detail_r_id').val();
        document.getElementById("detail_r_id").value = "";
        if (row_id == '' || row_id == 'undefined') return;
        
        var detail_subgrid = dealBlotter.blotter_grid.cells(row_id, 0).getSubGrid();
        var term_start_index = detail_subgrid.getColIndexById('term_start');
        var term_end_index = detail_subgrid.getColIndexById('term_end');

        detail_subgrid.forEachRow(function(detail_row_id){
            detail_subgrid.cells(detail_row_id, term_start_index).setValue(return_val[0].term_start);
            detail_subgrid.cells(detail_row_id, term_end_index).setValue(return_val[0].term_end);
        });
       
        dealBlotter.load_shipper1_dropdown(row_id);
        dealBlotter.load_shipper2_dropdown(row_id);
    }
    /**
     *
     */
    function open_template_hyperlink(id) {
        var template_id = dealBlotter.filter_form.getItemValue("template");
        if (template_id) {
            var win_obj = new dhtmlXWindows();
            var win_obj_by_id = window.parent.blotter_window.window("w1");
            win_obj_by_id.maximize();
            var params = '?template_id=' + template_id;// + '&field_template_id=' + template_id + '&mode=u';
            var new_win = win_obj.createWindow('w2', 0, 0, 800, 760);
            var url = '../../../../trm.depr/adiha.html.forms/_setup/maintain_deal_template/maintain.deal.template.php' + params;
            //url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_setup/maintain_deal_template/maintain.field.template.php' + params;
            new_win.setText("Maintain Deal Template");  
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.maximize();
            new_win.attachURL(url, false, true);

            new_win.attachEvent("onClose", function(win){
                win.hide();
                win.setModal(false);
            });
        } else {
            dhtmlx.alert({title:"Alert", type:"alert-error", text:'Please select <b>Template</b> First.'});
        }
    }
	
    dealBlotter.header_buy_sell_flag_changed = function(rId, nValue) {
        var detail_subgrid = dealBlotter.blotter_grid.cells(rId, 0).getSubGrid();
        var buy_sell_flag_index = detail_subgrid.getColIndexById('buy_sell_flag');
        var row_number = detail_subgrid.getColumnsNum();
        detail_subgrid.forEachRow (function(id){
            if (row_number > 1) {
                var current_value = detail_subgrid.cells(id, buy_sell_flag_index).getValue();
                nValue = (current_value == 'b')?'s':'b';
            }
            detail_subgrid.cells(id, buy_sell_flag_index).setValue(nValue);
            detail_subgrid.cells(id, buy_sell_flag_index).cell.wasChanged = true;
        });
    }
	
	$(window).keydown(function(event) {
		if (event.ctrlKey && event.keyCode == 83) { 
			event.preventDefault(); 
			dealBlotter.menu_click('save');
		}
	});
</script>
<textarea style="display:none" name="detail_r_id" id="detail_r_id"></textarea>
<div id="context_menu" style="display: none;">
   <div id="apply_to_all" text="Apply To All"></div>
</div>
</body>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }

	.importantRule1 {
        margin-left: 0px !important;
        padding-top: 6px;
        padding-right: 16px;
        padding-bottom: 6px;
        padding-left: 15px;
        margin-top:11px!important;
        background:#94D8B7!important;

    }
</style>
</html>