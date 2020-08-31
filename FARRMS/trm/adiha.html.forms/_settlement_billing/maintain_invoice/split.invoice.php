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
    $calc_id = get_sanitized_value($_GET["calc_id"] ?? '');
    $form_namespace = 'splitInvoice';

    $layout_json = '[
                            {id: "a", text: "Original Invoice"},
                            {id: "b", text: "Create Invoice"}
                    ]';

    $inner_layout_json = '[
                            {id: "a", text: "Invoice Template", header: false, height: 40},
                            {id: "b", text: "Create Invoice", header: false}
                    ]';

    $toolbar_json = '[
                        { id: "save", type: "button", img: "save.gif", img_disabled: "save_dis.gif", text:"Save", title: "Save"}
                     ]';

    $layout_obj = new AdihaLayout();
    $inner_layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $original_tree = new AdihaTree();
    $new_tree = new AdihaTree();
    $form_obj = new AdihaForm();
    $original_tree_name = 'original_tree';
    $new_tree_name = 'new_tree';

    $sp_invoice = "EXEC spa_settlement_history @flag='t', @calc_id=" . $calc_id;

    echo $layout_obj->init_layout('split_invoice', '', '2U', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "b");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.split_toolbar_click');
    
    echo $layout_obj->attach_layout_cell('split_layout2', 'b', '2E', $inner_layout_json);
    echo $inner_layout_obj->init_by_attach('split_layout2', $form_namespace);
    echo $layout_obj->attach_tree_cell($original_tree_name, 'a');
    echo $inner_layout_obj->attach_tree_cell($new_tree_name, 'b');

    $sp_url = "EXEC('SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38')";
	$dp_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);
    
    $form_json = '[{type: "settings", position: "label-top"},
					{type: "block", 
                        list: [
                            {type:"combo", name:"invoice_template", "options": ' . $dp_json . ' ,label:"Invoice Template"}
                        ]
                    }]';
    
    $form_name = 'invoice_template_form';
    echo $inner_layout_obj->attach_form($form_name, 'a');
	echo $form_obj->init_by_attach($form_name, $form_namespace);
	echo $form_obj->load_form($form_json);
    
    echo $original_tree->init_by_attach($original_tree_name, $form_namespace);
    
    $grouping_list = "counterparty_id:counterparty,contract_id:contract,invoice_line_item_id:line_item";
    $additional_param = "calc_id=" . $calc_id . "&flag=t";
    echo $original_tree->load_tree_xml("spa_settlement_history", "source_deal_header_id:deal_id", $grouping_list, $additional_param);
    echo $original_tree->enable_DND('false');
    echo $original_tree->set_drag_behavior('child');
    echo $original_tree->attach_event("", "onDragIn", $form_namespace . '.control_dragin');
    echo $original_tree->attach_event("", "onDrop", $form_namespace . '.control_drop');
    echo $original_tree->attach_event("", "onXLE", $form_namespace . '.on_load'); 

    echo $new_tree->init_by_attach($new_tree_name, $form_namespace);

    $grouping_list_new = "counterparty_id:counterparty,contract_id:contract";
    $additional_param_new = "calc_id=" . $calc_id . "&flag=u";
    echo $new_tree->load_tree_xml("spa_settlement_history", "source_deal_header_id:deal_id", $grouping_list_new, $additional_param_new);
    echo $new_tree->attach_event("", "onXLE", $form_namespace . '.expand_all');
    echo $new_tree->enable_DND('false');
    echo $new_tree->set_drag_behavior('child');
    echo $new_tree->attach_event("", "onDragIn", $form_namespace . '.control_dragin');
    echo $new_tree->attach_event("", "onDrop", $form_namespace . '.control_drop');

    echo $layout_obj->close_layout();
?>
<body></body>
<script type="text/javascript">
    $(function() {
		splitInvoice.original_tree.enableMultiselection(true);
		splitInvoice.new_tree.enableMultiselection(true);
        splitInvoice.split_invoice.cells('b').showHeader();
    })
    
    splitInvoice.on_load = function(id) {
		var all_ids = splitInvoice.original_tree.getAllSubItems(0);
        all_ids_arr = all_ids.split(',');
        var charge_arr = new Array();
        var deal_arr = new Array();
        
        for (i=0; i<all_ids_arr.length; i++) {
            var level = splitInvoice.original_tree.getLevel(all_ids_arr[i]);
            if (level == 3) {
                charge_arr.push(all_ids_arr[i]);
            } else if (level == 4) {
                deal_arr.push(all_ids_arr[i]);
            }
        }
        
        if (charge_arr.length < 2 && deal_arr.length < 2) {
            splitInvoice.toolbar.disableItem('save');
        }
    }
    
	splitInvoice.expand_all = function(id) {
		splitInvoice.original_tree.openAllItems(0);
		splitInvoice.new_tree.openAllItems(0);
	}
    
	splitInvoice.split_toolbar_click = function(id) {
		if (id == 'save') {
            splitInvoice.toolbar.disableItem("save");        
            create_invoice();
        }
	}

	/**
	* Remove selected items from new invoice tree except counterparty and contract which are listed by default.
	*/
	/*function remove_item_new_invoice() {
	    var selected_items = splitInvoice.new_tree.getSelectedItemId();
	    var item_array = new Array();
	    item_array = selected_items.split(',');
	    _.each(item_array, function(item, key) {
	        if (splitInvoice.new_tree.getParentId(item) != 0 && splitInvoice.new_tree.getParentId(splitInvoice.new_tree.getParentId(item)) != 0) {
	            splitInvoice.new_tree.deleteItem(item);
	        }
	    })
	}
*/
	/**
	* Save function for splitting invoice window.
	* @param  {[type]} calc_id [calc_id]
	*/
	function create_invoice() {
		var calc_id = '<?php echo $calc_id; ?>';
        var invoice_template = splitInvoice.invoice_template_form.getItemValue('invoice_template');
        var list = splitInvoice.new_tree.getAllSubItems(0);
	    var items = list.split(",");
	    var xml = '<Root>';

	    for (var i = 0; i <= items.length; i++) {
	        var item_level = splitInvoice.new_tree.getLevel(items[i]);

	        if (item_level == 3) {
	            var deal_list = splitInvoice.new_tree.getAllSubItems(items[i]);

	            var deals = new Array();
            	deals = deal_list.split(",");

	            if (deals.length > 0) {
	                _.each(deals, function(val, key) {
	                    if (val != '') {
	                        var deal_detail_mixed_id = splitInvoice.new_tree.getItemText(val);

	                        deal_detail_mixed_id = deal_detail_mixed_id.replace(/(<([^>]+)>)/ig, "");
                            
                            if (deal_detail_mixed_id.indexOf("(") == -1) {
                                var deal_id = deal_detail_mixed_id.substring(0, deal_detail_mixed_id.indexOf(" ||"));
                                var detail_id = '';
                            } else {
                                var deal_id = deal_detail_mixed_id.substring(0, deal_detail_mixed_id.indexOf("("));
                                var detail_id = deal_detail_mixed_id.substring(deal_detail_mixed_id.indexOf("(") + 1, deal_detail_mixed_id.indexOf(")"));
                            }
	                        
	                        xml += '<PSRecordSet calc_id="' + calc_id + '" charge_type_id="' + items[i] + '" deal_id="' + deal_id + '" detail_id="' + detail_id + '"></PSRecordSet>';    	
	                    } else {
	                        xml += '<PSRecordSet calc_id="' + calc_id + '" charge_type_id="' + items[i] + '" deal_id="" detail_id=""></PSRecordSet>';
	                    }
	                });
	            } else {
	                xml += '<PSRecordSet calc_id="' + calc_id + '" charge_type_id="' + items[i] + '" deal_id="" detail_id=""></PSRecordSet>';
	            }
	        }


	    }
	    xml += '</Root>';
        
        var param = {
            "flag": "p",
            "action": "spa_settlement_history",
            "xml": xml,
            "invoice_template": invoice_template
        };
        
        adiha_post_data('alert', param, '', '', '');
	}

	splitInvoice.control_dragin = function(sid, tid, sObject, tObject) {
        if (tObject.getLevel(tid) == 1) return false;
        if (tObject.getLevel(tid) == 4) return false;

        var source_parent_id = sObject.getParentId(sid);
        var source_parent_level = sObject.getLevel(source_parent_id);
        var source_parent_label = sObject.getItemText(source_parent_id);
        var target_level = tObject.getLevel(tid);
        var target_label = tObject.getItemText(tid);

        if (source_parent_level == target_level && target_level == 3) {
            if (source_parent_label != target_label) return false;
        }

        if (tObject != sObject) {
            var source_parent_level = sObject.getLevel(sObject.getParentId(sid));
            var source_parent_id = sObject.getParentId(sid);
            var source_parent_label = sObject.getItemText(source_parent_id);
            var item_label = sObject.getItemText(sid);
            if (source_parent_level == 3 && tObject.getLevel(tid) == 2) {
                if (!tObject.findItemIdByLabel(source_parent_label)) {
                    tObject.insertNewItem(tid, source_parent_id, source_parent_label);

                    if (!tObject.findItemIdByLabel(item_label) || (tObject.findItemIdByLabel(item_label) != sid)) {
                        tObject.insertNewItem(source_parent_id, sid, item_label);
                        sObject.deleteItem(sid);

                        if (!sObject.hasChildren(source_parent_id)) {
                            sObject.deleteItem(source_parent_id);
                        }
                    }

                }
            }
        }
        if (sObject.getLevel(sid) - tObject.getLevel(tid) == 1) return true; //allow drop of items on third level
        return false;
    }

    splitInvoice.control_drop = function(sId, tId, id, sObject, tObject) {
        if (tObject.getLevel(tId) == 2) {
            var item_label = tObject.getItemText(sId);
            var previous_id = tObject.findItemIdByLabel(item_label, 0, 1);
            if (previous_id != sId) {
                var children = tObject.getAllSubItems(sId);
                var item_array = new Array();
                item_array = children.split(',');
                _.each(item_array, function(item, key) {
                    tObject.moveItem(item, 'item_child', previous_id, original_invoice_tree);
                });
                tObject.deleteItem(sId);
            }
        }
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