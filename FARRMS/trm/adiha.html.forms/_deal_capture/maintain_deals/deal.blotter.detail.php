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
    $template_id = (isset($_GET["template_id"]) && $_GET["template_id"] != '') ? get_sanitized_value($_GET["template_id"]) : 'NULL';
    $term_start = (isset($_GET["term_start"]) && $_GET["term_start"] != '') ? get_sanitized_value($_GET["term_start"]) : 'NULL';
    $term_end = (isset($_GET["term_end"]) && $_GET["term_end"] != '') ? get_sanitized_value($_GET["term_end"]) : 'NULL';
    $blotterleg = (isset($_GET["blotterleg"]) && $_GET["blotterleg"] != '') ? get_sanitized_value($_GET["blotterleg"]) : 'NULL';
    $row_id = (isset($_GET["row_id"]) && $_GET["row_id"] != '') ? get_sanitized_value($_GET["row_id"]) : 'NULL';
    $process_id = (isset($_GET["process_id"]) && $_GET["process_id"] != '') ? get_sanitized_value($_GET["process_id"]) : 'NULL';
    $counterparty_id = (isset($_GET["counterparty_id"]) && $_GET["counterparty_id"] != '') ? get_sanitized_value($_GET["counterparty_id"]) : 'NULL';
    $term_frequency = (isset($_GET["term_frequency"]) && $_GET["term_frequency"] != '') ? get_sanitized_value($_GET["term_frequency"]) : 'NULL';

    $grid_sp = "EXEC spa_blotter_deal @flag='e', @template_id=" . $template_id . ", @no_of_row=" . $row_id . ", @term_start='" . $term_start . "', @term_end='" . $term_end . "', @blotter_leg=" . $blotterleg . ", @process_id='" . $process_id . "', @term_frequency='" . $term_frequency . "'";

    $sp_detail = "EXEC spa_blotter_deal @flag='d', @process_id='" . $process_id . "'";
    $grid_config = readXMLURL2($sp_detail);

    $form_namespace = 'blotterDetail';

    $layout_json = '[{id: "a", text: "Detail", header:false}]';
   
    $layout_obj = new AdihaLayout();
    $grid_obj = new AdihaGrid();

    echo $layout_obj->init_layout('blotter_detail', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_grid_cell('grid', 'a');
    echo $layout_obj->attach_status_bar("a", true);

    echo $grid_obj->init_by_attach('grid', $form_namespace);
    echo $grid_obj->enable_paging(25, 'pagingArea_a'); 
    echo $grid_obj->load_config_json($grid_config[0]['config_string']);
    echo $grid_obj->enable_header_menu();
    echo $grid_obj->set_search_filter(false, $grid_config[0]['filter_list']);
    echo $grid_obj->set_validation_rule($grid_config[0]['validation_rule']);
    echo $grid_obj->attach_event('', 'onEditCell', $form_namespace . '.deal_detail_edit');
    echo $grid_obj->set_column_auto_size();
    echo $grid_obj->load_grid_functions();

    $combo_fields = array();
    $combo_fields = explode("||||", $grid_config[0]['combo_list']);
    
    foreach ($combo_fields as $combo_column) {
        $json_array = array();
        $json_array = explode("::::", $combo_column);
        echo $grid_obj->load_combo($json_array[0], $json_array[1]);
    }

    echo $grid_obj->load_grid_data($grid_sp, 'g', '', false);


    $context_menu_json = '[{id:"apply_to", text:"Apply to All", title:"Apply to All"}]';
    $context_menu = new AdihaMenu();
    echo $context_menu->init_menu('context_menu', $form_namespace);
    echo $context_menu->render_as_context_menu();
    echo $context_menu->attach_event('', 'onClick', $form_namespace . '.context_menu_click');
    echo $context_menu->load_menu($context_menu_json);

    echo $grid_obj->enable_context_menu($form_namespace . '.context_menu');
    echo $layout_obj->close_layout();
?>
</html>
<script type="text/javascript">
	
	$(function() {
        blotterDetail.grid.enableEditEvents(true,false,true);
		blotterDetail.grid.setUserData("", 'formula_id', 10211093);
		blotterDetail.grid.setDateFormat(user_date_format, "%Y-%m-%d");
		var win_obj = window.parent.detail_window.window("w1");

		win_obj.attachEvent("onClose", function(win){
            var grid_status = blotterDetail.validate_form_grid(blotterDetail.grid, 'Deal Detail');
            
            if (grid_status) {
                blotterDetail.save_grid_data();
                return true;
            } else {
                blotterDetail.grid.clearSelection();
                return false;
            }		    
		});

	    var counterparty_id = '<?php echo $counterparty_id; ?>';
	    var template_id = '<?php echo $template_id; ?>';
	    blotterDetail.load_detail_dropdown(template_id, counterparty_id);
	});

    /**
     * [deal_detail_edit Grid cell on edit function]
     * @param  {[type]} stage  [stage of edit 0 - edit open, 1 - on edit, 2 - on edit close]
     * @param  {[type]} rId    [row_id]
     * @param  {[type]} cInd   [column index]
     * @param  {[type]} nValue [new value]
     * @param  {[type]} oValue [old value]
     */
    blotterDetail.deal_detail_edit = function(stage,rId,cInd,nValue,oValue) {
        if (stage == 2) {
            var column_id = blotterDetail.grid.getColumnId(cInd);
            if (column_id == 'term_start' || column_id == 'term_end') {
                var term_start_index = blotterDetail.grid.getColIndexById('term_start');
                var term_end_index = blotterDetail.grid.getColIndexById('term_end');

                if (term_start_index == undefined || term_end_index == undefined) return true;
                
                var term_start = blotterDetail.grid.cells(rId, term_start_index).getValue();
                var term_end = blotterDetail.grid.cells(rId, term_end_index).getValue();

                if (column_id == 'term_start') {
                    var term_frequency = '<?php echo $term_frequency;?>';
                    var new_term_end = dates.getTermEnd(term_start, term_frequency);
                    blotterDetail.grid.cells(rId, term_end_index).setValue(new_term_end);
                } else if (dates.compare(term_end, term_start) == -1) {
                    var term_start_label = blotterDetail.grid.getColLabel(term_start_index);
                    var term_end_label = blotterDetail.grid.getColLabel(term_end_index);
                    if (cInd == term_start_index) {
                        var message = term_start_label + ' cannot be greater than ' + term_end_label;
                    } else {
                        var message = term_end_label + ' cannot be less than ' + term_start_label;
                    }

                    dhtmlx.alert({
                        title:"Error",
                        type:"alert-error",
                        text:message,
                        callback: function(result){
                            if (oValue.replace('&nbsp;', '') != '' && oValue.replace('&nbsp;', '') != null) {
                                blotterDetail.grid.cells(rId, cInd).setFormattedValue(oValue);
                                return true;
                            } else {
                                blotterDetail.grid.cells(rId, cInd).setFormattedValue('');
                                return false;
                            }
                        }
                    });
                }
            }
            return true;
        }
    }

	/**
	 * [load_detail_dropdown Load dependent dropdowns]
	 * @param  {[type]} template_id     [Template Id]
	 * @param  {[type]} counterparty_id [Counterparty ID]
	 */
	blotterDetail.load_detail_dropdown = function(template_id, counterparty_id) {
        var curve_index = blotterDetail.grid.getColIndexById('curve_id');
        if (typeof curve_index != 'undefined') {
            var curve_combo = blotterDetail.grid.getColumnCombo(curve_index);
            curve_combo.enableFilteringMode("between", null, false);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "curve_id"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            curve_combo.load(url);
        }

        var formula_curve_index = blotterDetail.grid.getColIndexById('formula_curve_id');
        if (typeof formula_curve_index != 'undefined') {
            var formula_curve_combo = blotterDetail.grid.getColumnCombo(formula_curve_index);
            formula_curve_combo.enableFilteringMode("between", null, false);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "formula_curve_id"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            formula_curve_combo.load(url);
        }

        var location_index = blotterDetail.grid.getColIndexById('location_id');
        if (typeof location_index != 'undefined') {
            var location_combo = blotterDetail.grid.getColumnCombo(location_index);
            location_combo.enableFilteringMode("between", null, false);
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "template_id": template_id, "counterparty_id": counterparty_id, "deal_fields": "location_id"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            location_combo.load(url);
        }
    }

    /**
     * [save_grid_data Save Grid data]
     */
	blotterDetail.save_grid_data = function() {
        blotterDetail.grid.clearSelection();

		var row_id = "<?php echo $row_id; ?>";
		var blotterleg = "<?php echo $blotterleg; ?>";
		var process_id = "<?php echo $process_id; ?>";
		blotterDetail.grid.clearSelection();
		var ids = blotterDetail.grid.getChangedRows(true);

		if (ids != '') {
			var changed_ids = {};
			changed_ids = ids.split(",");
			var grid_xml = "<GridXML>";
			$.each(changed_ids, function(index, value) {
				grid_xml += '<GridRow row_id="' + row_id + '" blotterleg="' + blotterleg + '" ';
				for(var cellIndex = 0; cellIndex < blotterDetail.grid.getColumnsNum(); cellIndex++){
					var grid_type = blotterDetail.grid.getColType(cellIndex);
					if (grid_type == 'calendar') {
						var cell_value = blotterDetail.grid.cells(value,cellIndex).getValue();
					} else {
						var cell_value = blotterDetail.grid.cells(value,cellIndex).getValue();
					}
					grid_xml += ' ' + blotterDetail.grid.getColumnId(cellIndex) + '="' + cell_value + '"';
				}
				grid_xml += " ></GridRow> ";
			});
			grid_xml += "</GridXML>";
			data = {"action": "spa_blotter_deal", "flag":"u", "process_id":process_id, "xml":grid_xml};
			adiha_post_data("alert", data);
        }		
	}	

    /**
     * [context_menu_click description]
     * @param  {[string]} menuitemId [menuitemId]
     * @param  {[string]} type       [type]
     */
    blotterDetail.context_menu_click = function(menuitemId,type) {
        var data = blotterDetail.grid.contextID.split("_"); //rowId_colInd
        var row_id = data[0];
        var column_index = data[1];
        var deal_id = '<?php echo $deal_id; ?>';       

        var col_label = blotterDetail.grid.getColLabel(column_index);
        var col_type = blotterDetail.grid.getColType(column_index);
        var col_value = blotterDetail.grid.cells(row_id, column_index).getValue();

        if (col_type == 'win_link') {
            var col_text = blotterDetail.grid.cells(row_id, column_index).getTitle();
            col_value = col_value+'^'+col_text;
        }

        blotterDetail.grid.forEachRow(function(id) {
            blotterDetail.grid.cells(id, column_index).setValue(col_value);
            blotterDetail.grid.cells(id, column_index).cell.wasChanged = true;
        });
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