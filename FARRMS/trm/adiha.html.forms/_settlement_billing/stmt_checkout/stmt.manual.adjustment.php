<?php
/**
* Stmt manual adjustment screen
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
        <?php  include '../../../adiha.php.scripts/components/include.file.v3.php'; ?>
    </head>
<body>
<?php
	$form_name = 'form_stmt_manual_adjustment';

	$rights_stmt_manual_adjustment = 20011204;

	$deal_id = (isset($_REQUEST["deal_id"]) && $_REQUEST["deal_id"] != '') ? get_sanitized_value($_REQUEST["deal_id"]) : 'NULL';
	$template_id = (isset($_REQUEST["template_id"]) && $_REQUEST["template_id"] != '') ? get_sanitized_value($_REQUEST["template_id"]) : 'NULL';
    $trader_id = (isset($_REQUEST["trader_id"]) && $_REQUEST["trader_id"] != '') ? get_sanitized_value($_REQUEST["trader_id"]) : 'NULL';
   
	$commodity_id = (isset($_REQUEST["commodity_id"]) && $_REQUEST["commodity_id"] != '') ? get_sanitized_value($_REQUEST["commodity_id"]) : 'NULL';
	$deal_type_id = (isset($_REQUEST['deal_type_id'])) ? get_sanitized_value($_REQUEST['deal_type_id']) : 'NULL';
	$pricing_type_id = (isset($_REQUEST["pricing_type_id"]) && $_REQUEST["pricing_type_id"] != '') ? get_sanitized_value($_REQUEST["pricing_type_id"]) : 'NULL';
	$sub_book = (isset($_REQUEST["sub_book"]) && $_REQUEST["sub_book"] != '') ? get_sanitized_value($_REQUEST["sub_book"]) : 'NULL';
	$subsidiary = (isset($_REQUEST["subsidiary"]) && $_REQUEST["subsidiary"] != '') ? get_sanitized_value($_REQUEST["subsidiary"]) : '';
	$book = (isset($_REQUEST["book"]) && $_REQUEST["book"] != '') ? get_sanitized_value($_REQUEST["book"]) : '';
	$term_frequency = (isset($_REQUEST["term_frequency"]) && $_REQUEST["term_frequency"] != '') ? "'" . get_sanitized_value($_REQUEST["term_frequency"]) . "'" : 'NULL';
    $delivery_month = (isset($_REQUEST["delivery_month"]) && $_REQUEST["delivery_month"] != '') ? "'" . get_sanitized_value($_REQUEST["delivery_month"]) . "'" : 'NULL';
    $counterparty_id = (isset($_REQUEST["counterparty_id"]) && $_REQUEST["counterparty_id"] != '') ? get_sanitized_value($_REQUEST["counterparty_id"]) : 'NULL';
    $contract_id = (isset($_REQUEST["contract_id"]) && $_REQUEST["contract_id"] != '') ? get_sanitized_value($_REQUEST["contract_id"]) : 'NULL';
    
    $book_id = (isset($_REQUEST["book_id"]) && $_REQUEST["book_id"] != '') ? get_sanitized_value($_REQUEST["book_id"]) : 'NULL';
    $subsidiary_id = (isset($_REQUEST["subsidiary_id"]) && $_REQUEST["subsidiary_id"] != '') ? get_sanitized_value($_REQUEST["subsidiary_id"]) : 'NULL';
    $strategy_id = (isset($_REQUEST["strategy_id"]) && $_REQUEST["strategy_id"] != '') ? get_sanitized_value($_REQUEST["strategy_id"]) : 'NULL';
    $subbook_id = (isset($_REQUEST["subbook_id"]) && $_REQUEST["subbook_id"] != '') ? get_sanitized_value($_REQUEST["subbook_id"]) : 'NULL';
    $book_structure = (isset($_REQUEST["book_structure"]) && $_REQUEST["book_structure"] != '') ? get_sanitized_value($_REQUEST["book_structure"]) : 'NULL';


    $exec_sql = "SELECT DATEADD(DAY, 1, EOMONTH(". $delivery_month .", -1)) term_start ,   EOMONTH(". $delivery_month .") term_end ";
    $return_value = readXMLURL($exec_sql);
    $term_start = $return_value[0][0];
    $term_end = $return_value[0][1];

	$sp_url = "EXEC spa_deal_update_new @flag = 'get_sub_id_from_field_template', @template_id = " . $template_id;
	$result_value = readXMLURL2($sp_url);

	if ($sub_book == 'NULL' && $result_value[0]['default_value'] != null) {
	   $sub_book = $result_value[0]['default_value'];
	}

	if ($deal_type_id == 'NULL' && $result_value[1]['default_value'] != null) {
	   $deal_type_id = $result_value[1]['default_value'];
	}

	$sp_term_frequency = "EXEC spa_deal_update_new @flag='x', @source_deal_header_id=" . $deal_id . ", @template_id=" . $template_id . ", @copy_deal_id=NULL,@deal_type_id=" . $deal_type_id . ", @pricing_type=" . $pricing_type_id . ", @term_frequency=" . $term_frequency . ", @commodity_id=" . $commodity_id;
	$term_frequency_arr = readXMLURL2($sp_term_frequency);
	$term_frequency = $term_frequency_arr[0]['term_frequency'];
	$header_cost_enable = $term_frequency_arr[0]['header_cost_enable'];
	$detail_cost_enable = $term_frequency_arr[0]['detail_cost_enable'];
	$deal_date = $term_frequency_arr[0]['deal_date'];
	$is_shaped =  $term_frequency_arr[0]['is_shaped'];
	$udf_process_id =  $term_frequency_arr[0]['udf_process_id'];

	$deal_type_id = ($term_frequency_arr[0]['deal_type_id'] == '') ? 'NULL' : $term_frequency_arr[0]['deal_type_id'];
	$pricing_type_id = ($term_frequency_arr[0]['pricing_type_id'] == '') ? 'NULL' : $term_frequency_arr[0]['pricing_type_id'];
    $commodity_id = ($term_frequency_arr[0]['commodity_id'] == '') ? 'NULL' : $term_frequency_arr[0]['commodity_id'];
	$enable_udf_tab = ($term_frequency_arr[0]['enable_udf_tab'] == '') ? 'n' : $term_frequency_arr[0]['enable_udf_tab'];
	$sp_deal_header = "EXEC spa_deal_update_new @flag='h', @source_deal_header_id=" . $deal_id . ", @view_deleted='', @template_id=" . $template_id . ", @copy_deal_id = NULL, @deal_type_id=" . $deal_type_id . ", @pricing_type=" . $pricing_type_id . ", @term_frequency=" . $term_frequency . ", @sub_book=" . $sub_book . ", @udf_process_id='" . $udf_process_id . "', @commodity_id=" . $commodity_id;
	$header_data = readXMLURL2($sp_deal_header);

	$sp_deal_detail = "EXEC spa_deal_update_new @flag='d', @source_deal_header_id=" . $deal_id . ", @view_deleted='', @template_id=" . $template_id . ", @copy_deal_id=NULL ,@deal_type_id=" . $deal_type_id . ", @pricing_type=" . $pricing_type_id . ", @term_frequency=" . $term_frequency . ", @udf_process_id='" . $udf_process_id . "', @commodity_id=" . $commodity_id;
	$detail_data = readXMLURL2($sp_deal_detail);
   
	$formula_process_id = ($detail_data[0]['formula_process_id'] == '') ? 'NULL' : $detail_data[0]['formula_process_id'];

    if ($template_id != 'NULL') {
        $process_id = $detail_data[0]['process_id'];
    } else {
        $process_id = 'NULL';
    }

    /*echo $sp_deal_header;
    die();*/
    list (
        $has_right_stmt_manual_adjustment
    ) = build_security_rights (
        $rights_stmt_manual_adjustment
    );
    
    //JSON for Layout
    $layout_json = '[   
                        {
                            id:             "a",
                            height:         200,
                            header:         true,
                            collapse:       false,
                            text:           "Manual Adjustment",
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            header:         true,
                            collapse:       false,
                            text:           "Cost Deal",
                            fix_size:       [false,null]
                        }
                    ]';
  
    $name_space = 'stmt_manual_adjustment';
    
    $stmt_manual_adjustment_layout = new AdihaLayout();

    echo $stmt_manual_adjustment_layout->init_layout('stmt_manual_adjustment_layout', '', '2E', $layout_json, $name_space);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20011204', @template_name='ManualAdjustmentUI', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    $toolbar_json = '[
                    { id: "save", type: "button", img: "save.gif",imgdis: "save_dis.gif", text: "Save", title: "save", enabled:'.$has_right_stmt_manual_adjustment.'}
               ]';

    echo $stmt_manual_adjustment_layout->attach_toolbar_cell('stmt_manual_adjustment_toolbar', 'a');
    
   // Attaching Toolbar
    $stmt_manual_adjustment_toolbar = new AdihaToolbar();
    echo $stmt_manual_adjustment_toolbar->init_by_attach('stmt_manual_adjustment_toolbar', $name_space);
    echo $stmt_manual_adjustment_toolbar->load_toolbar($toolbar_json);
    echo $stmt_manual_adjustment_toolbar->attach_event('', 'onClick', 'stmt_manual_adjustment_save');
    
    // Attaching Form
    $form_object = new AdihaForm();
    echo $stmt_manual_adjustment_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($form_json);

    $header_cost_menu_json = '[{id:"add", text:"Add/Delete Costs", title: "Add/Delete Costs", img:"edit.gif", imgdis:"edit_dis.gif",enabled:true}]';
    
    echo $stmt_manual_adjustment_layout->attach_toolbar_cell('stmt_manual_adjustment_grd_toolbar', 'b');
    
   // Attaching Menu
    $header_cost_menu = new AdihaMenu();
    echo $stmt_manual_adjustment_layout->attach_menu_cell('header_cost_menu', 'b');
    echo $header_cost_menu->init_by_attach('header_cost_menu', $name_space);
    echo $header_cost_menu->load_menu($header_cost_menu_json);
    echo $header_cost_menu->attach_event('', 'onClick', $name_space . '.header_cost_menu_click');

    echo $stmt_manual_adjustment_layout->attach_grid_cell('deal_costs', 'b');
    echo $stmt_manual_adjustment_layout->attach_status_bar("b", true);
    $header_deal_costs = new GridTable('deal_costs');        
    echo $header_deal_costs->init_grid_table('deal_costs', $name_space, 'n');
    echo $header_deal_costs->set_column_auto_size();     
    echo $header_deal_costs->enable_column_move();
    echo $header_deal_costs->enable_multi_select();
    echo $header_deal_costs->return_init();
    
    echo $stmt_manual_adjustment_layout->close_layout();   
?>   
</body>

<script type="text/javascript">
	var cost_udf_window;
	var template_id = '<?php echo $template_id; ?>';
	var term_frequency = '<?php echo $term_frequency; ?>';
	var formula_process_id = '<?php echo $formula_process_id; ?>';
	var process_id = '<?php echo $process_id; ?>';
	var commodity_id = '<?php echo $commodity_id; ?>';
	var deal_type_id = '<?php echo $deal_type_id; ?>';
	var pricing_type_id = '<?php echo $pricing_type_id; ?>';
    var trader_id = '<?php echo $trader_id; ?>';
    var term_start = '<?php echo $term_start; ?>';
    var term_end = '<?php echo $term_end; ?>';
    var counterparty_id = '<?php echo $counterparty_id; ?>';
    var contract_id = '<?php echo $contract_id; ?>';
    var book_id = '<?php echo $book_id; ?>';
    var book_structure = '<?php echo $book_structure; ?>';
    var subsidiary_id = '<?php echo $subsidiary_id; ?>';
    var strategy_id = '<?php echo $strategy_id; ?>';
    var subbook_id = '<?php echo $subbook_id; ?>';

	$(function() {
		attach_browse_event('stmt_manual_adjustment.form_stmt_manual_adjustment', '20011204');
        var form_obj = stmt_manual_adjustment.stmt_manual_adjustment_layout.cells("a").getAttachedObject();
        form_obj.setItemValue('counterparty_id', counterparty_id);
        form_obj.setItemValue('Contract_id', contract_id);
        form_obj.setItemValue('book_id', book_id);
        form_obj.setItemValue('subsidiary_id', subsidiary_id);
        form_obj.setItemValue('strategy_id', strategy_id);
        form_obj.setItemValue('subbook_id', subbook_id);
        form_obj.setItemValue('book_structure', book_structure);
        form_obj.setItemValue('term_start', term_start);
        form_obj.setItemValue('term_end', term_end);

        form_obj.attachEvent("onChange", function(name,value,is_checked){
            if (name == 'term_start') {
                var date_from = form_obj.getItemValue(name, true);
                var split = date_from.split('-');
                var year =  +split[0];
                var month = +split[1];
                var day = +split[2];

                var date = new Date(year, month-1, day);
                var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                date_end = formatDate(lastDay);

                form_obj.setItemValue('term_end', date_end);
                form_obj.clearNote("term_end");
            }
        });
	});

    function formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;

        return [year, month, day].join('-');
    }

    /**
	header cost menu.
    **/
	stmt_manual_adjustment.header_cost_menu_click = function(id) { 
		switch(id) {
			case "add":
				
				var header_cost_change = stmt_manual_adjustment.deal_costs.getChangedRows(true);
                var header_cost_xml = 'NULL';

                if (header_cost_change != '') {
                    header_cost_xml = '<GridXML>';
                    var changed_ids = new Array();
                    changed_ids = header_cost_change.split(",");
                    $.each(changed_ids, function(index, value) {
                        header_cost_xml += '<GridRow ';
                        for(var cellIndex = 0; cellIndex < stmt_manual_adjustment.deal_costs.getColumnsNum(); cellIndex++){
                            var column_id = stmt_manual_adjustment.deal_costs.getColumnId(cellIndex);
                            var cell_value = stmt_manual_adjustment.deal_costs.cells(value, cellIndex).getValue();
                            header_cost_xml += ' ' + column_id + '="' + cell_value + '"';
                        }
                        header_cost_xml += '></GridRow>';
                    });
                    header_cost_xml += '</GridXML>';
                }

                header_cost_xml = (header_cost_xml == '<GridXML></GridXML>') ? 'NULL' : header_cost_xml;

                var udf_process_id = '<?php echo $udf_process_id;?>';
				var deal_id = '<?php echo $deal_id;?>';
				if (deal_id == 'NULL') {
		        	var template_id = '<?php echo $template_id; ?>';
		    	} else {
		    		var template_id = 'NULL';
		    	}
		       
	            var cm_param = {"action": "spa_udf_groups", "flag": "u", "udf_process_id":udf_process_id, "deal_id":deal_id, "template_id":template_id, "udf_xml":header_cost_xml, "udf_type":'hc'};
	    		adiha_post_data("return", cm_param, '', '', 'stmt_manual_adjustment.open_header_cost_udf_window');
               
			break;

			case "refresh":
                var deal_id = '<?php echo $deal_id;?>';
	    		var udf_process_id = '<?php echo $udf_process_id;?>';

	    		if (deal_id == 'NULL') {
		        	var template_id = '<?php echo $template_id; ?>';
		    	} else {
		    		var template_id = 'NULL';
		    	}

	    		var data = {
		            "action":"spa_udf_groups",
		            "flag":'z',
		            "deal_id":deal_id,
		            "template_id":template_id,
		            "udf_process_id":udf_process_id,
		            "udf_type":'hc',
		            "grid_type":"g"
		        }   
	    		sql_param = $.param(data);

	    		var sql_url = js_data_collector_url + "&" + sql_param;
	    		stmt_manual_adjustment.deal_costs.clearAll();

	        	stmt_manual_adjustment.deal_costs.load(sql_url, function() {
	        		var udf_value_index = stmt_manual_adjustment.deal_costs.getColIndexById('udf_value');
	        		for (i = 0; i < stmt_manual_adjustment.deal_costs.getRowsNum(); i++) {
	        			stmt_manual_adjustment.deal_costs.cells2(i, udf_value_index).cell.wasChanged = true;
	        		}
                    stmt_manual_adjustment.grid_cell_ed();
	        	});

                break;
	   }
	}

	/**
	open header cost window
	**/
	stmt_manual_adjustment.open_header_cost_udf_window = function(returnval) {
        if (cost_udf_window != null && cost_udf_window.unload != null) {
            cost_udf_window.unload();
            cost_udf_window = w1 = null;
        }
        var deal_id = '<?php echo $deal_id; ?>';
        var udf_process_id = '<?php echo $udf_process_id;?>';

        if (deal_id == 'NULL') {
        	var template_id = '<?php echo $template_id; ?>';
    	} else {
    		var template_id = 'NULL';
    	}

        if (!cost_udf_window) {
            cost_udf_window = new dhtmlXWindows();
        }

        var win_title = 'Costs';
        var win_url = js_php_path + '../adiha.html.forms/_deal_capture/maintain_deals/cost.udf.list.php';
        var win = cost_udf_window.createWindow('w1', 0, 0, 600, 600);

        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);

        win.attachURL(win_url, false, {deal_id:deal_id,template_id:template_id,type:'hc',udf_process_id:udf_process_id});
        win.attachEvent('onClose', function(w) {
        	var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var click_type = $('textarea[name="txt_click"]', ifrDocument).val();

            if (click_type == 'ok')
            	stmt_manual_adjustment.header_cost_menu_click('refresh');

            return true;
        });
    }

	function stmt_manual_adjustment_save() { 

            var form_obj = stmt_manual_adjustment.stmt_manual_adjustment_layout.cells("a").getAttachedObject();

        var subbook_id_validation = form_obj.getItemValue('subbook_id');


        //Validation for multiple bookstructure selected.
        if(subbook_id_validation.split(',').length > 1) {
            show_messagebox('Multiple Subook are selected. Please select only one subbook on Book Structure.');
            return;
        }


		var header_xml = '<Root><FormXML ';
		if (template_id != 'NULL') {
			header_xml = '<GridXML><GridRow row_id="1" '
		}
		var header_cost_xml = 'NULL';
	
		var form_status = validate_form(form_obj);
		if (form_status) {
            data = form_obj.getFormData();

            for (var a in data) {
                var field_label = a;

                if (form_obj.getItemType(field_label) == 'calendar') {
                    var field_value = form_obj.getItemValue(field_label, true);
                } else if (field_label == 'confirm_status_type'){
				    var field_value = 17200;							
				} else if (field_label == 'trader_id') {	
                    var field_value = trader_id;					
				} else {
                    var field_value = data[field_label];                                
                    
                    if (field_label == 'internal_desk_id' && field_value != 17302) {
                        reset_profile_granularity = 'y';
                    }
                    if (field_label == 'profile_granularity') {
                        if (reset_profile_granularity == 'y')
                            field_value = '';

                        profile_granularity_new = data[field_label];
                    }
                }	

                if(field_label == 'subbook_id')		
                	field_label = 'sub_book';

				if(field_label != 'book_structure' && field_label != 'subsidiary_id' && field_label != 'strategy_id' && field_label != 'book_id' && field_label != 'Comments_udf' && field_label != 'period')
                header_xml += " " + field_label + "=\"" + field_value + "\"";
            }
        } else {
            final_status = false;
        }

		stmt_manual_adjustment.deal_costs.clearSelection();
		var header_cost_change = stmt_manual_adjustment.deal_costs.getChangedRows(true);

		header_cost_xml = '<GridXML>';

		for (var hci=0; hci < stmt_manual_adjustment.deal_costs.getRowsNum(); hci++) {
			header_cost_xml += '<GridRow ';
			header_cost_xml += ' seq_no="' + hci + '" ';

			for(var cellIndex = 0; cellIndex < stmt_manual_adjustment.deal_costs.getColumnsNum(); cellIndex++){
			var column_id = stmt_manual_adjustment.deal_costs.getColumnId(cellIndex);
			var cell_value = stmt_manual_adjustment.deal_costs.cells2(hci, cellIndex).getValue();
			header_cost_xml += ' ' + column_id + '="' + cell_value + '"';
			}

			header_cost_xml += '></GridRow>';

		}
		header_cost_xml += '</GridXML>';

		header_cost_xml = (header_cost_xml == '<GridXML></GridXML>') ? 'NULL' : header_cost_xml;

		if (template_id != 'NULL') {
		    header_xml += '></GridRow></GridXML>'
		} else {
		    header_xml += "></FormXML></Root>";
		}

       term_start = form_obj.getItemValue('term_start', true);
       term_end = form_obj.getItemValue('term_end', true);

       detail_xml = '<GridXML><GridRow row_id="1"  deal_group="New Group" group_id="1" detail_flag="0" blotterleg="1" source_deal_detail_id="NEW_1" lock_deal_detail="n" term_start="' + term_start + '" term_end="' + term_end + '"></GridRow></GridXML>';
       //console.log(header_xml); return false;
       data = {"action": "spa_insert_blotter_deal", "flag":"i", "call_from":"form", "template_id":template_id, "header_xml":header_xml, "detail_xml":detail_xml, "deal_type_id":deal_type_id,"pricing_type":pricing_type_id, "term_frequency":term_frequency, "shaped_process_id":process_id, header_cost_xml:header_cost_xml, "formula_process_id":formula_process_id, "commodity_id":commodity_id};
                
       adiha_post_data("return_array", data, '', '', 'stmt_manual_adjustment.save_callback');
	}

    stmt_manual_adjustment.save_callback = function(result) {

        if (result[0][0] == "Success") {
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });

            var source_deal_header_id = result[0][5];
            data_stmt = {"action": "spa_stmt_checkout","flag":"manual_adjustment","source_deal_header_id":source_deal_header_id}; 
            adiha_post_data("alert", data_stmt, '', '', 'stmt_manual_adjustment.save_checkout_callback');
            
        } else {
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });

        }
    }

    stmt_manual_adjustment.grid_cell_ed = function() {
        for (var i=0; i < stmt_manual_adjustment.deal_costs.getRowsNum(); i++) {
            for(var cellIndex = 0; cellIndex < stmt_manual_adjustment.deal_costs.getColumnsNum(); cellIndex++){
            var column_id = stmt_manual_adjustment.deal_costs.getColumnId(cellIndex);
            var cell_value = stmt_manual_adjustment.deal_costs.cells2(i, cellIndex).getValue();
                if(column_id == 'cost_id') {
                    data = {"action": "spa_stmt_checkout","flag":"z","udf_template_id":cell_value, "row_id":i}; 
                    adiha_post_data("return_array", data, '', '', 'stmt_manual_adjustment.grid_cell_ed1');
                }
            }
        }
    }

    stmt_manual_adjustment.grid_cell_ed1 = function(result) {
        if(result[0][0] == 'true') {
            var internal_field_type_ind = stmt_manual_adjustment.deal_costs.getColIndexById('internal_field_type');
            stmt_manual_adjustment.deal_costs.cells(result[0][1],internal_field_type_ind).setDisabled(true);
        }
    }


</script>