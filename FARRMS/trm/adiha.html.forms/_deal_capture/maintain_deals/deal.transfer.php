<?php
/**
* Deal transfer screen
* @copyright Pioneer Solutions
*/
?>
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
    $form_namespace = 'dealTransfer';
    $deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : '';
    $sp_url = "EXEC spa_deal_transfer @flag='s', @source_deal_header_id='" . $deal_id . "'";
    $data = readXMLURL2($sp_url);
    $sub_book = $data[0]['sub_book'];
    $counterparty_id = $data[0]['counterparty_id'];
    $contract_id = $data[0]['contract_id'];
    $trader_id = $data[0]['trader_id'];
    $volume = $data[0]['deal_volume'];
    $available_volume = $data[0]['available_volume'];
    $avail_per = $data[0]['avail_per'];
    $sub_book_name = $data[0]['sub_book_name'];
    $counterparty_name = $data[0]['counterparty_name'];
    $contract_name = $data[0]['contract_name'];
    $trader_name = $data[0]['trader_name'];
    $deal_date = $data[0]['deal_date'];
    $deal_type = $data[0]['deal_type'];

    $function_id = 10131024;

    if ($deal_id <> 'NULL') {        
        $spa_deal_pricing = "EXEC [dbo].[spa_deal_pricing_detail] @flag = 'j', @source_deal_detail_id = " . $deal_id;
        $spa_deal_pricing_arr = readXMLURL2($spa_deal_pricing);

        $transfer_price_process_id = $spa_deal_pricing_arr[0]['recommendation'];
		
		$spa_deal_provisional_pricing = "EXEC [dbo].[spa_deal_pricing_detail_provisional] @flag = 'j', @source_deal_detail_id = " . $deal_id;
        $spa_deal_provisional_pricing_arr = readXMLURL2($spa_deal_provisional_pricing);

        $transfer_provisional_price_process_id = $spa_deal_provisional_pricing_arr[0]['recommendation'];
    }

    $layout_json = '[{id: "a", header:false,height:180, text: "Apply Filter"},{id: "b", header:true, text: "Transfer Criteria"}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
                      
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();
    echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);

    $sp_url = "EXEC spa_transfer_mapping @flag = 's'";
    $transfer_mapping_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

    $sp_url = "EXEC spa_transfer_mapping @flag = 'c'";
    $transfer_type_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, false);
    
    $form_json = '[ 
                    {"type": "settings", "position": "label-top", "offsetLeft": 10},
                    {"type": "block", "blockOffset": 0, "list": [
                        {type:"combo", name: "mapping_id", label:"Apply Filters", "labelWidht":180, filtering:true, "inputWidth":180, "options": ' . $transfer_mapping_json . '},
                        {"type":"newcolumn"},
                        {type: "button", name: "save", value: "", tooltip: "Save Mapping", className: "filter_save",offsetTop:"28"},
                        {"type":"newcolumn"},
                        {type: "button", name: "delete", value: "", tooltip: "Delete Mapping", className: "filter_delete",offsetTop:"28"},
                        {"type":"newcolumn"},
                        {type: "button", name: "clear", value: "", tooltip: "Clear Filter", className: "filter_clear",offsetTop:"28"},
                        {"type":"newcolumn"},
                        {type: "button", name: "publish", value: "", tooltip: "Publish Filter", className: "filter_publish",offsetTop:"28"}
                    ]},
                    {"type": "block", "blockOffset": 0, "list": [
                        {"type": "numeric", "labelWidht":180, "inputWidth":180, "name":"volume", "label": "Deal Volume", disabled:true, value:"", "value":"' . $volume . '"},
                        {type:"newcolumn"},
                        {"type": "numeric", "labelWidht":180, "inputWidth":180, disabled:true, "name":"available_volume", "label": "Available Volume", value:"' . $available_volume . '"},
                        {type:"newcolumn"},
                        {"type": "hidden", disabled:true, "name":"avail_per", "label": "Available percentage", value:"' . $avail_per . '"},
                        {type:"newcolumn"},
                        {type:"combo", name: "transfer", label:"Transfer Type", "labelWidht":180, required:"true", "inputWidth":180, "options": ' . $transfer_type_json . '},
                        /*{type:"newcolumn"},
                        {type: "checkbox", "offsetTop":25, position: "label-right", "labelWidht":180, "inputWidth":180, "name":"without_offset", label: "Transfer without offset", checked:false},
                        {type:"newcolumn"},
                        {type: "checkbox", "offsetTop":25, position: "label-right", "labelWidht":180, "inputWidth":180, "name":"only_offset", label: "Create offset deal only", checked:false},*/
                        {type:"newcolumn"},
                        {"type": "template", "name": "transfer_report", "value": "View Transferred and Offset Deals", "format":"open_deal_transfer_report"}
                    ]}
                ]';

    
    echo $layout_obj->attach_form('form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    echo $form_obj->init_by_attach('form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
    echo $form_obj->attach_event('', 'onButtonClick', $form_namespace . '.button_click');

    $menu_json = '[  
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false},
                    ]}                     
                ]';
    $menu_object = new AdihaMenu();
    echo $layout_obj->attach_menu_cell('transfer_menu', 'b');
    echo $menu_object->init_by_attach('transfer_menu', $form_namespace);
    echo $menu_object->load_menu($menu_json);
    echo $menu_object->attach_event('', 'onClick', $form_namespace . '.transfer_menu_click');

    // attach grid
    echo $layout_obj->attach_grid_cell('deal_transfer', 'b');
    $grid_obj = new GridTable('deal_transfer');
    echo $grid_obj->init_grid_table('deal_transfer', $form_namespace, 'n');
    echo $grid_obj->set_column_auto_size();     
    echo $grid_obj->enable_column_move();
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->return_init();
    echo $grid_obj->enable_cell_edit_events("true", "false", "true");
    echo $grid_obj->attach_event('', 'onEditCell', $form_namespace . '.grid_edit');
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $form_namespace . '.grid_select');

    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_status" id="txt_status">cancel</textarea>
<script type="text/javascript">
    validate_transfer = true;
    validate_offset = true;
    var contract_id = '<?php echo $contract_id; ?>';
    var trader_id = '<?php echo $trader_id; ?>';
    var sub_book = '<?php echo $sub_book; ?>';
    var transfer_price_process_id = '<?php echo $transfer_price_process_id; ?>';
	var transfer_provisional_price_process_id = '<?php echo $transfer_provisional_price_process_id; ?>';
    var deal_type = '<?php echo $deal_type; ?>';
    var transfer_error = false;
   
    $(function() { 
        dealTransfer.hide_show('Offset', false); 
        dealTransfer.hide_show('Transfer', false);
        dealTransfer.add_grid_row();
    });
    
    dealTransfer.grid_select = function(row_ids) {
        if (row_ids != null && row_ids != '') {
            dealTransfer.transfer_menu.setItemEnabled('delete');
        } else {
            dealTransfer.transfer_menu.setItemDisabled('delete');
        }
    }

    /**
     * [toolbar_click Toolbar Click]
     * @param  {[type]} id [toolbar id]
     */
    dealTransfer.toolbar_click = function(id) {
        if (id == 'cancel') {
            document.getElementById("txt_status").value = 'cancel';
            var win_obj = window.parent.deal_transfer_window.window("w1");
            win_obj.close();
        } else if (id == 'ok') {
            dealTransfer.transfer_deal();
        }
    }

    /**
     * [transfer_deal Transfer Deal]
     */
    dealTransfer.transfer_deal = function() {
        var deal_id = '<?php echo $deal_id; ?>';
        var status = validate_form(dealTransfer.form);
        
        if (!status) {
            return;
        };
        dealTransfer.deal_transfer.clearSelection();
        var transfer_combo = dealTransfer.form.getCombo('transfer');
        var selected_type = transfer_combo.getSelectedValue();
        var transfer_without_offset = 0;
        var transfer_only_offset = 0;
        if(selected_type == 'without_offset') {
            transfer_without_offset = 1;
        } else if (selected_type == 'only_offset') {
            transfer_only_offset = 1;
        }
        
        var sub_book = dealTransfer.form.getItemValue('sub_book');

        if (sub_book == '' || sub_book == null) 
            sub_book = 'NULL';   
        
        var xml = '';
        var blank_transfer_counterparty = false;
        var blank_transfer_trader = false;
        var blank_transfer_contract = false;
        var blank_transfer_sub_book = false; 
        var blank_counterparty = false;
        var blank_trader = false;
        var blank_contract = false;
        var blank_sub_book = false;
        var blank_transfer_volume = false;
        var blank_pricing_type = false;
        var blank_vol_per = false;
        var perc_error = false;
        var available_volume = dealTransfer.form.getItemValue('available_volume');
        var avail_per = dealTransfer.form.getItemValue('avail_per');
        var transfer_volume = 0;
        var transfer_per = 0;

        
        /**
         * @var {is_valid_user}
         * If all validation rule passes it will be set to true
         * Checked to determine whether to prevent backend request or not
         */
        var is_valid_grid = true;
        var no_of_rows = dealTransfer.deal_transfer.getRowsNum();

        if (no_of_rows > 0) {
            xml = '<GridXML><GridHeader source_deal_header_id="' + deal_id + '" transfer_without_offset="' +  transfer_without_offset + '" transfer_only_offset="' + transfer_only_offset + '">';
            dealTransfer.deal_transfer.forEachRow(function(id) {
                //## If any row validation fails skip other remaining rows
                if (!is_valid_grid) return;
                //## Assume grid row validation is failed by default
                is_valid_grid = false;
                xml += '<GridRow ';

                for (var cellIndex = 0; cellIndex < dealTransfer.deal_transfer.getColumnsNum(); cellIndex++) {
                    var column_id = dealTransfer.deal_transfer.getColumnId(cellIndex);
                    var cell_value = dealTransfer.deal_transfer.cells(id,cellIndex).getValue();

                    xml += ' ' + column_id + '="' + cell_value + '"';
                    if (validate_transfer) { // validate if transfer criteria is not hidden
                        if (column_id == 'transfer_counterparty_id' && (cell_value == '' || cell_value == null)) {
                            blank_transfer_counterparty = true;
                        } else if (column_id == 'transfer_contract_id' && (cell_value == '' || cell_value == null)) {
                            blank_transfer_contract = true;
                        } else if (column_id == 'transfer_trader_id' && (cell_value == '' || cell_value == null)) {
                            blank_transfer_trader = true;
                        } else if (column_id == 'transfer_sub_book' && (cell_value == '' || cell_value == null)) {
                            blank_transfer_sub_book = true;
                        }
                    }
                                        
                    if (validate_offset) { //validate if offset criteria is not hidden
                        if (column_id == 'counterparty_id' && (cell_value == '' || cell_value == null)) {
                            blank_counterparty = true;
                        } else if (column_id == 'contract_id' && (cell_value == '' || cell_value == null)) {
                            blank_contract = true;
                        } else if (column_id == 'trader_id' && (cell_value == '' || cell_value == null)) {
                            blank_trader = true;
                        } else if (column_id == 'sub_book' && (cell_value == '' || cell_value == null)) {
                            blank_sub_book = true;
                        }
                    } 
                    
                    if (column_id == 'transfer_volume' && (cell_value == '' || cell_value == null)) {
                        blank_transfer_volume = true;
                    } else if (column_id == 'volume_per' && (cell_value == '' || cell_value == null)) {
                        blank_vol_per = true;
                    } else if (column_id == 'pricing_options' && (cell_value == '' || cell_value == null)) {
                        blank_pricing_type = true;
                    } else if (column_id == 'volume_per' && (cell_value != '' && cell_value != null)) {
                        if (cell_value < 0 || cell_value > 100)
                            perc_error = true;
                        else
                            transfer_per =  Number(transfer_per) + Number(cell_value);
                    } else if (column_id == 'transfer_volume' && (cell_value != '' && cell_value != null)) {
                        transfer_volume = Number(transfer_volume) + Number(cell_value);
                    }

                    //## Validate columns for numeric values
                    if ((column_id == 'transfer_volume' || column_id == 'volume_per' || column_id == 'fixed_price' || column_id == 'fixed_adder') && cell_value != '' && cell_value != null && isNaN(cell_value)) {
                        var column_label = dealTransfer.deal_transfer.getColLabel(cellIndex);
                        var error_message = "Data Error in column <b>" + column_label + "</b>. Please check the data and resave.";
                        show_messagebox(error_message);
                        return;
                    }
                }
                xml += '></GridRow>';

                if (blank_transfer_counterparty) {
                    show_messagebox("Please select <b><i>Transfer counterparty</i></b> in a grid.");
                    return;
                }

                if (blank_transfer_contract) {
                    show_messagebox("Please select <b><i>Transfer contract</i></b> in a grid.");
                    return;
                }

                if (blank_transfer_trader) {
                    show_messagebox("Please select <b><i>Transfer trader</i></b> in a grid.");
                    return;
                }

                if (blank_transfer_sub_book) {
                    show_messagebox("Please select <b><i>Transfer sub book</i></b> in a grid.");
                    return;
                }

                if (blank_counterparty) {
                    show_messagebox("Please select <b><i>Offset counterparty</i></b> in a grid.");
                    return;
                }

                if (blank_contract) {
                    show_messagebox("Please select <b><i>Offset contract</i></b> in a grid.");
                    return;
                }

                if (blank_trader) {
                    show_messagebox("Please select <b><i>Offset trader</i></b> in a grid.");
                    return;
                }

                if (blank_sub_book) {
                    show_messagebox("Please select <b><i>Offset sub book</i></b> in a grid.");
                    return;
                }

                if (blank_transfer_volume && blank_vol_per && deal_type == 17300) {
                    show_messagebox("Please select <b><i>Transfer volume</i></b> or <b><i>Volume%</i></b> in a grid.");
                    return;
                }

                if (perc_error) {
                    show_messagebox("<b>Volume%</b> must be between 0 and 100.");
                    return;
                }

                if (blank_pricing_type) {
                    show_messagebox("Please select <b><i>Pricing options</i></b> in a grid.");
                    return;
                }

                blank_transfer_volume = false;
                blank_vol_per = false;
                //## Set is_valid_grid to true only if all validation passes
                is_valid_grid = true;
            });
            xml += '</GridHeader></GridXML>';
        }

        transfer_volume = Number(transfer_volume) + Number(Number(transfer_per) * Number(available_volume)/100);
        
		if (Number(parseFloat(transfer_volume)) > Number(parseFloat(available_volume)) && deal_type == 17300) {
            show_messagebox('Transfer volume exceed available volume.');
            return false;
        }

        if (xml == '' || !is_valid_grid) return;

        var data = {
            "action":"spa_deal_transfer",
            "flag":'t',
            "source_deal_header_id":deal_id,
            //"transfer_without_offset":transfer_without_offset,
            //"transfer_only_offset":transfer_only_offset,
            "xml":xml,
            "transfer_price_process_id": transfer_price_process_id,
			"transfer_provisional_price_process_id": transfer_provisional_price_process_id
        }

        dealTransfer.layout.cells('b').progressOn();
        adiha_post_data("alert", data, '', '', 'dealTransfer.transfer_callback');
    }

    /**
     * [transfer_callback Transfer callback]
     * @param  {[type]} return_val [return array]
     */
    dealTransfer.transfer_callback = function(return_val) {
        dealTransfer.layout.cells('b').progressOff();
        if (return_val[0].errorcode == 'Success') {
            document.getElementById("txt_status").value = 'Success';
            var win_obj = window.parent.deal_transfer_window.window("w1");
            dealTransfer.toolbar.disableItem('ok');
            setTimeout(function() { 
                win_obj.close();
            }, 1000)
        }
    }

    /**
     * [grid_edit Grid cell on edit function]
     * @param  {[type]} stage  [stage of edit 0 - edit open, 1 - on edit, 2 - on edit close]
     * @param  {[type]} rId    [row_id]
     * @param  {[type]} cInd   [column index]
     * @param  {[type]} nValue [new value]
     * @param  {[type]} oValue [old value]
     */
   dealTransfer.grid_edit = function(stage, rId, cInd, nValue, oValue) {
        var counterparty_index = dealTransfer.deal_transfer.getColIndexById('counterparty_id');
        var contract_index = dealTransfer.deal_transfer.getColIndexById('contract_id');
        var fixed_price_index = dealTransfer.deal_transfer.getColIndexById('fixed_price');
        var pricing_options_index = dealTransfer.deal_transfer.getColIndexById('pricing_options');
        var pricing_option_value = dealTransfer.deal_transfer.cells(rId, pricing_options_index).getValue();
        var transfer_counterparty_idx = dealTransfer.deal_transfer.getColIndexById('transfer_counterparty_id');
        var transfer_contract_idx = dealTransfer.deal_transfer.getColIndexById('transfer_contract_id');

        if (transfer_counterparty_idx == cInd && stage == 2) {
            var transfer_contract_combo = dealTransfer.deal_transfer.cells(rId, transfer_contract_idx).getCellCombo();
            var cm_param = {
                "action": "spa_contract_group",
                "flag": "r",
                "counterparty_id": nValue
            };
            
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            
            transfer_contract_combo.clearAll();
            dealTransfer.deal_transfer.cells(rId, transfer_contract_idx).setValue('');          
            transfer_contract_combo.enableFilteringMode(true);            
            transfer_contract_combo.load(url);
        }
        
        if (counterparty_index == cInd) {
            var contract_combo = dealTransfer.deal_transfer.cells(rId, contract_index).getCellCombo();
            var cm_param = {
                "action": "spa_contract_group",
                "flag": "r",
                "counterparty_id": nValue
            };
            
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            contract_combo.clearAll();
            dealTransfer.deal_transfer.cells(rId, contract_index).setValue('');         
            contract_combo.enableFilteringMode(true);            
            contract_combo.load(url);
        }

        if (pricing_option_value != 'x' && cInd == fixed_price_index) {
           return false;
        }
       
        var transfer_volume_index = dealTransfer.deal_transfer.getColIndexById('transfer_volume');
        var volume_percengate_index = dealTransfer.deal_transfer.getColIndexById('volume_per');

        if (stage == 2) {
            transfer_error = false;
            if (cInd == transfer_volume_index || cInd == volume_percengate_index) {
                var deal_volume = dealTransfer.form.getItemValue('volume');
                var available_volume = dealTransfer.form.getItemValue('available_volume');
                var avail_per = dealTransfer.form.getItemValue('avail_per');
                avail_per = avail_per*100;
                var total_volume = 0;
                var total_percentage = 0;

                dealTransfer.deal_transfer.forEachRow (function (id) {
                    var per = dealTransfer.deal_transfer.cells(id, volume_percengate_index).getValue();
                    var vol = dealTransfer.deal_transfer.cells(id, transfer_volume_index).getValue();
                    
                    if (vol != '')
                        total_volume = (Number(total_volume) + Number(vol));
                    if (per != '')
                        total_percentage = (Number(total_percentage) + Number(per));
                });

                if (cInd == transfer_volume_index) {
					
                    if (Number(parseFloat(total_volume)) > Number(parseFloat(available_volume)) && deal_type == 17300) {
                        show_messagebox('Transfer volume exceed available volume.');
                        transfer_error = true;
                        return false;
                    }

                   //var percentage = (nValue/deal_volume)*100;
                   //dealTransfer.deal_transfer.cells(rId, volume_percengate_index).setValue(percentage);
                } else if (cInd == volume_percengate_index) {
                    if ((deal_volume && Number(total_percentage) > Number(avail_per)) && deal_type == 17300) {
                        show_messagebox('Transfer volume exceed available volume.');
                        transfer_error = true;
                        return false;
                    }
                }
            }
        }

        return true;
    }

    /**
     * [button_click Mapping buttons clickk function]
     * @param  {[string]} id [Button Id]
     */
    dealTransfer.button_click = function(id) {
        switch(id) {
            case "save":
                var mapping_name = dealTransfer.form.getItemValue('mapping_id');
                if (mapping_name == '') {
                    show_messagebox('Mapping name cannot be empty.');
                    return;
                } else {
                    dealTransfer.save_mapping();
                }
                break;
            case "delete":
                var mapping_name = dealTransfer.form.getItemValue('mapping_id');
                if (mapping_name == '') {
                    show_messagebox('Please select mapping to delete.');
                    return;
                } else {
                    confirm_messagebox("Are you sure you want to delete selected mapping?", function() {
                        dealTransfer.delete_mapping();
                    });                  
                }                
                break;
            case "clear":
                dealTransfer.form.setItemValue('mapping_id','');
                break;
            case "publish":
                var filter_id = dealTransfer.form.getItemValue('mapping_id');
                if (filter_id == -1 || filter_id == null) {
                    show_messagebox('Please select the filter.');
                    return;
                }
                var doc_window = new dhtmlXWindows();
                win_doc = doc_window.createWindow('w1', 0, 0, 800, 350);
                win_doc.setText("Publish Apply Filter");
                win_doc.centerOnScreen();
                win_doc.setModal(true);
                win_doc.attachURL(js_php_path + "components/lib/adiha_dhtmlx/apply.filter.publish.php?filter_id=" + filter_id);
                break; 
        }
    }

    /**
     * [delete_mapping Delete Mapping]
     */
    dealTransfer.delete_mapping = function() {
        var combo_obj = dealTransfer.form.getCombo('mapping_id');
        var mapping_id = combo_obj.getSelectedValue();

        var data = {
            "action":"spa_transfer_mapping",
            "flag":'d',
            "mapping_id":mapping_id
        }
        adiha_post_data("alert", data, '', '', 'dealTransfer.delete_callback');
    }

    /**
     * [delete_callback Delete Callback]
     * @param  {[type]} result [Result Array]
     */
    dealTransfer.delete_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var combo_obj = dealTransfer.form.getCombo('mapping_id');
            combo_obj.setComboText('');
            combo_obj.setComboValue('');
            combo_obj.clearAll();
            combo_obj.enableFilteringMode('between');
            var cm_param = {"action": "spa_transfer_mapping", "flag": "s"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            combo_obj.load(url, function(){
                dealTransfer.refresh_grid('0');
            });
        }
    }

    /**
     * [save_mapping Mapping save function]
     */
    dealTransfer.save_mapping = function() {
        var combo_obj = dealTransfer.form.getCombo('mapping_id');
        var mapping_name = combo_obj.getComboText();
        var mapping_id = combo_obj.getSelectedValue();
        var no_of_rows = dealTransfer.deal_transfer.getRowsNum();

        var tr_chx_box = dealTransfer.form.getItemValue('without_offset');
        var off_chx_box = dealTransfer.form.getItemValue('only_offset');
        var transfer_type = dealTransfer.form.getItemValue('transfer');

        var counterparty_index = dealTransfer.deal_transfer.getColIndexById('counterparty_id');
        var t_counterparty_index = dealTransfer.deal_transfer.getColIndexById('transfer_counterparty_id');
        var contract_index = dealTransfer.deal_transfer.getColIndexById('contract_id');
        var t_contract_index = dealTransfer.deal_transfer.getColIndexById('transfer_contract_id');
        var trader_index = dealTransfer.deal_transfer.getColIndexById('trader_id');
        var t_trader_index = dealTransfer.deal_transfer.getColIndexById('transfer_trader_id');
        var sub_book_index = dealTransfer.deal_transfer.getColIndexById('sub_book');
        var t_sub_book_index = dealTransfer.deal_transfer.getColIndexById('transfer_sub_book');
        var template_id_index = dealTransfer.deal_transfer.getColIndexById('template_id');
        var transfer_template_id_index = dealTransfer.deal_transfer.getColIndexById('transfer_template_id');
        var location_id_index = dealTransfer.deal_transfer.getColIndexById('location_id');
        var transfer_volume_index = dealTransfer.deal_transfer.getColIndexById('transfer_volume');
        var volume_per_index = dealTransfer.deal_transfer.getColIndexById('volume_per');
        var pricing_options_index = dealTransfer.deal_transfer.getColIndexById('pricing_options');
        var fixed_price_index = dealTransfer.deal_transfer.getColIndexById('fixed_price');
        var transfer_date_index = dealTransfer.deal_transfer.getColIndexById('transfer_date');
        var index_adder_index = dealTransfer.deal_transfer.getColIndexById('index_adder');
        var fixed_adder_index = dealTransfer.deal_transfer.getColIndexById('fixed_adder');

        var sub_book = '';
        var tr_sub_book = '';
        var xml = '';
        
        if (no_of_rows > 0) {
            xml = '<GridXML>';
            dealTransfer.deal_transfer.forEachRow(function(id) {
                xml += '<GridRow ';

                if(tr_chx_box == 0 && off_chx_box == 1) {
                    xml += ' transfer_counterparty_id="" ';
                    xml += ' transfer_contract_id="" ';
                    xml += ' transfer_trader_id="" ';
                    xml += ' transfer_sub_book="" ';
                    xml += ' transfer_template_id="" ';
                    xml += ' counterparty_id="' + dealTransfer.deal_transfer.cells(id,counterparty_index).getValue() + '" ';
                    xml += ' contract_id="' + dealTransfer.deal_transfer.cells(id,contract_index).getValue() + '" ';
                    xml += ' trader_id="' + dealTransfer.deal_transfer.cells(id,trader_index).getValue() + '" ';
                    xml += ' sub_book="' + dealTransfer.deal_transfer.cells(id,sub_book_index).getValue() + '" ';
                    xml += ' template_id="' + dealTransfer.deal_transfer.cells(id,template_id_index).getValue() + '" ';
                    xml += ' location_id="' + dealTransfer.deal_transfer.cells(id,location_id_index).getValue() + '" ';
                    xml += ' transfer_volume="' + dealTransfer.deal_transfer.cells(id,transfer_volume_index).getValue() + '" ';
                    xml += ' volume_per="' + dealTransfer.deal_transfer.cells(id,volume_per_index).getValue() + '" ';
                    xml += ' pricing_options="' + dealTransfer.deal_transfer.cells(id,pricing_options_index).getValue() + '" ';
                    xml += ' fixed_price="' + dealTransfer.deal_transfer.cells(id,fixed_price_index).getValue() + '" ';
                    xml += ' transfer_date="' + dealTransfer.deal_transfer.cells(id,transfer_date_index).getValue() + '" ';
                    xml += ' index_adder="' + dealTransfer.deal_transfer.cells(id,index_adder_index).getValue() + '" ';
                    xml += ' fixed_adder="' + dealTransfer.deal_transfer.cells(id,fixed_adder_index).getValue() + '" ';

                } else if(tr_chx_box == 1 && off_chx_box == 0) {
                    xml += ' transfer_counterparty_id="' + dealTransfer.deal_transfer.cells(id,t_counterparty_index).getValue() + '" ';
                    xml += ' transfer_contract_id="' + dealTransfer.deal_transfer.cells(id,t_contract_index).getValue() + '" ';
                    xml += ' transfer_trader_id="' + dealTransfer.deal_transfer.cells(id,t_trader_index).getValue() + '" ';
                    xml += ' transfer_sub_book="' + dealTransfer.deal_transfer.cells(id,t_sub_book_index).getValue() + '" ';
                    xml += ' transfer_template_id="' + dealTransfer.deal_transfer.cells(id,transfer_template_id_index).getValue() + '" ';
                    xml += ' counterparty_id="" ';
                    xml += ' contract_id="" ';
                    xml += ' trader_id="" ';
                    xml += ' sub_book="" ';
                    xml += ' template_id="" ';
                    xml += ' location_id="' + dealTransfer.deal_transfer.cells(id,location_id_index).getValue() + '" ';
                    xml += ' transfer_volume="' + dealTransfer.deal_transfer.cells(id,transfer_volume_index).getValue() + '" ';
                    xml += ' volume_per="' + dealTransfer.deal_transfer.cells(id,volume_per_index).getValue() + '" ';
                    xml += ' pricing_options="' + dealTransfer.deal_transfer.cells(id,pricing_options_index).getValue() + '" ';
                    xml += ' fixed_price="' + dealTransfer.deal_transfer.cells(id,fixed_price_index).getValue() + '" ';
                    xml += ' transfer_date="' + dealTransfer.deal_transfer.cells(id,transfer_date_index).getValue() + '" ';
                    xml += ' index_adder="' + dealTransfer.deal_transfer.cells(id,index_adder_index).getValue() + '" ';
                    xml += ' fixed_adder="' + dealTransfer.deal_transfer.cells(id,fixed_adder_index).getValue() + '" ';
                    
                } else {
                    xml += ' transfer_counterparty_id="' + dealTransfer.deal_transfer.cells(id, t_counterparty_index).getValue() + '" ';
                    xml += ' transfer_contract_id="' + dealTransfer.deal_transfer.cells(id, t_contract_index).getValue() + '" ';
                    xml += ' transfer_trader_id="' + dealTransfer.deal_transfer.cells(id, t_trader_index).getValue() + '" ';
                    xml += ' transfer_sub_book="' + dealTransfer.deal_transfer.cells(id, t_sub_book_index).getValue() + '" ';
                    xml += ' transfer_template_id="' + dealTransfer.deal_transfer.cells(id,transfer_template_id_index).getValue() + '" ';
                    xml += ' counterparty_id="' + dealTransfer.deal_transfer.cells(id, counterparty_index).getValue() + '" ';
                    xml += ' contract_id="' + dealTransfer.deal_transfer.cells(id,contract_index).getValue() + '" ';
                    xml += ' trader_id="' + dealTransfer.deal_transfer.cells(id,trader_index).getValue() + '" ';
                    xml += ' sub_book="' + dealTransfer.deal_transfer.cells(id,sub_book_index).getValue() + '" ';
                    xml += ' template_id="' + dealTransfer.deal_transfer.cells(id,template_id_index).getValue() + '" ';
                    xml += ' location_id="' + dealTransfer.deal_transfer.cells(id,location_id_index).getValue() + '" ';
                    xml += ' transfer_volume="' + dealTransfer.deal_transfer.cells(id,transfer_volume_index).getValue() + '" ';
                    xml += ' volume_per="' + dealTransfer.deal_transfer.cells(id,volume_per_index).getValue() + '" ';
                    xml += ' pricing_options="' + dealTransfer.deal_transfer.cells(id,pricing_options_index).getValue() + '" ';
                    xml += ' fixed_price="' + dealTransfer.deal_transfer.cells(id,fixed_price_index).getValue() + '" ';
                    xml += ' transfer_date="' + dealTransfer.deal_transfer.cells(id,transfer_date_index).getValue() + '" ';
                    xml += ' index_adder="' + dealTransfer.deal_transfer.cells(id,index_adder_index).getValue() + '" ';
                    xml += ' fixed_adder="' + dealTransfer.deal_transfer.cells(id,fixed_adder_index).getValue() + '" ';
                    
                }
                xml += '></GridRow>';
            });        
            xml += '</GridXML>';
        }

        xml = (xml != '') ? xml : 'NULL';
        mapping_id = (mapping_id == '' || mapping_id == null) ? 'NULL' : mapping_id;

        var data = {
            "action":"spa_transfer_mapping",
            "flag":'i',
            "mapping_id":mapping_id,
            "mapping_name":mapping_name,
            "xml":xml,
            "transfer_type": transfer_type
        }
        adiha_post_data("alert", data, '', '', 'dealTransfer.save_callback');
    }

    /**
     * [save_callback Save Callback]
     * @param  {[type]} result [Result array]
     */
    dealTransfer.save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var combo_obj = dealTransfer.form.getCombo('mapping_id');
            var mapping_name = combo_obj.getComboText();

            combo_obj.clearAll();
            combo_obj.enableFilteringMode('between');
            var cm_param = {"action": "spa_transfer_mapping", "flag": "s"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            combo_obj.load(url, function(){
                var option_obj = combo_obj.getOptionByLabel(mapping_name);
                combo_obj.selectOption(option_obj.index, null, true);
            });
        }
    }

    /**
     * [transfer_menu_click Grid Menu Click]
     * @param  {[type]} id [Menu Id]
     */
    dealTransfer.transfer_menu_click = function(id) {
        switch(id) {
            case "add":
               dealTransfer.add_grid_row()
                break;
            case "delete":
                dealTransfer.deal_transfer.deleteSelectedRows();
                dealTransfer.transfer_menu.setItemDisabled('delete');
                break;
            case "refresh":
                var no_of_rows = dealTransfer.deal_transfer.getRowsNum();
                var first_row_id = dealTransfer.deal_transfer.getRowId(0);
                var counterparty_id = dealTransfer.deal_transfer.cells(first_row_id,0).getValue();

                if (no_of_rows > 1 && (counterparty_id != '' && counterparty_id != null)) {
                    confirm_messagebox("All unsaved data will be cleared from grid. Do you want to continue?.", function() {
                        dealTransfer.refresh_grid('1');
                    });
                } else {
                    dealTransfer.refresh_grid('1');
                }                
                break;
        }
    }
    /**
     * [Adds new row on criteria grid]
     */
    dealTransfer.add_grid_row = function() { 
        var new_id = (new Date()).valueOf();
        dealTransfer.deal_transfer.addRow(new_id, '');
        dealTransfer.deal_transfer.selectRowById(new_id);
        
        var transfer_cpty_index = dealTransfer.deal_transfer.getColIndexById('transfer_counterparty_id');
        var transfer_contract_index = dealTransfer.deal_transfer.getColIndexById('transfer_contract_id');
        var transfer_trader_index = dealTransfer.deal_transfer.getColIndexById('transfer_trader_id');
        var sub_book_index = dealTransfer.deal_transfer.getColIndexById('sub_book');
        var pricing_options_index = dealTransfer.deal_transfer.getColIndexById('pricing_options');
        var transfer_date_index =  dealTransfer.deal_transfer.getColIndexById('transfer_date');
        var trader_index = dealTransfer.deal_transfer.getColIndexById('trader_id');
        var col_volume_per = dealTransfer.deal_transfer.getColIndexById('volume_per');
        var col_transfer_volume = dealTransfer.deal_transfer.getColIndexById('transfer_volume');
        
        var counterparty_from = dealTransfer.form.getItemValue("counterparty_from");
        var contract_from = dealTransfer.form.getItemValue("contract_from");
        var trader_from = dealTransfer.form.getItemValue("trader_from");                
        var sub_book_from = dealTransfer.form.getItemValue("sub_book");
        var deal_date = '<?php echo $deal_date;?>';
        
        var counterparty_id = '<?php echo $counterparty_id; ?>';
        var counterparty_name = '<?php echo $counterparty_name; ?>';
        var contract_id = '<?php echo $contract_id; ?>';
        var trader_id = '<?php echo $trader_id; ?>';
        var sub_book = '<?php echo $sub_book; ?>';

        dealTransfer.deal_transfer.cells(new_id, transfer_cpty_index).setValue(counterparty_id);
        dealTransfer.deal_transfer.cells(new_id, transfer_contract_index).setValue(contract_id);
        dealTransfer.deal_transfer.cells(new_id, transfer_trader_index).setValue(trader_id);
        dealTransfer.deal_transfer.cells(new_id, sub_book_index).setValue(sub_book);
        dealTransfer.deal_transfer.cells(new_id, transfer_date_index).setValue(deal_date);
        dealTransfer.deal_transfer.cells(new_id, pricing_options_index).setValue('d');
        dealTransfer.deal_transfer.cells(new_id, trader_index).setValue(trader_id);

        if(deal_type !== '17300') { // disable if not Deal Volume
            dealTransfer.deal_transfer.cells(new_id,col_transfer_volume).setDisabled(true);
        }

        //dealTransfer.deal_transfer.cells(new_id, col_volume_per).setValue('100');
        //dealTransfer.hide_show_columns('d',new_id);
    }

    /**
     * [refresh_grid Grid Refresh]
     */

    dealTransfer.refresh_grid = function(check_transfer) {
        var combo_obj = dealTransfer.form.getCombo('mapping_id');
        var mapping_id = combo_obj.getSelectedValue();
        var deal_date = '<?php echo $deal_date;?>';
        
        if (mapping_id == '' || mapping_id == null || mapping_id == 'null') {
            // clears rows only, do not removed false.
            dealTransfer.deal_transfer.clearAll(false);
            dealTransfer.transfer_menu_click('add');
            return;
        }
        var data = {
            "action":"spa_transfer_mapping",
            "flag":'r',
            "mapping_id":mapping_id,
            "grid_type":"g",
            "deal_date":deal_date
        }
        var sql_param = $.param(data);
        var sql_url = js_data_collector_url + "&" + sql_param;
        dealTransfer.deal_transfer.clearAll();
        dealTransfer.deal_transfer.load(sql_url, function () {
            var row_id = dealTransfer.deal_transfer.getRowId(0);
            if (row_id && check_transfer == '1') {
                var volume_per_index = dealTransfer.deal_transfer.getColIndexById('volume_per');
                var transfer_volume_index = dealTransfer.deal_transfer.getColIndexById('transfer_volume');
                var value_volume_per = dealTransfer.deal_transfer.cells(row_id, volume_per_index).getValue();
                dealTransfer.deal_transfer.callEvent("onEditCell", [2, row_id, volume_per_index, value_volume_per, value_volume_per]);
                if (transfer_error) {
                    dealTransfer.deal_transfer.forEachRow(function(rid) {
                        dealTransfer.deal_transfer.cells(rid, volume_per_index).setValue('');
                        dealTransfer.deal_transfer.cells(rid, transfer_volume_index).setValue('');
                    });
                    transfer_error = false;
                }
            }
        });
    }

    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    dealTransfer.form_change = function(name, value, state) {
        if (name == 'transfer') {
            if (value == 'without_offset') { // transfer
                dealTransfer.set_cell_value('Offset', false);
                dealTransfer.hide_show('Offset', true);
                dealTransfer.set_cell_value('Transfer', true);
                dealTransfer.hide_show('Transfer', false);
                validate_offset = false;
                validate_transfer = true;
            } else if (value == 'only_offset') { // offset
                dealTransfer.set_cell_value('Transfer', false);
                dealTransfer.hide_show('Transfer', true);
                dealTransfer.set_cell_value('Offset', true);
                dealTransfer.hide_show('Offset', false);
                validate_transfer = false;
                validate_offset = true;
            } else {
                dealTransfer.set_cell_value('Transfer', true);
                dealTransfer.hide_show('Transfer', false);
                dealTransfer.set_cell_value('Offset', true);
                dealTransfer.hide_show('Offset', false);
                validate_transfer = true;
                validate_offset = true;
            }

        } else if (name == 'mapping_id') {
            if (value != null && value != 'null' && value) {
                data = {
                        "action": "spa_transfer_mapping", 
                        "flag":"t", 
                        "mapping_id":value
                    };
                adiha_post_data("return", data, '', '', 'dealTransfer.set_transfer_type');
            } else {
                dealTransfer.refresh_grid('0');
            }
        }
    }
    
    dealTransfer.hide_show = function(header, state) {
        var col_location_id = dealTransfer.deal_transfer.getColIndexById('location_id'); //Always hide column location_id by default
        dealTransfer.deal_transfer.setColumnHidden(col_location_id,true);
        if (header == 'Offset') { //hide offset
            var offset_ids = ['counterparty_id','contract_id','trader_id','sub_book'];
            var col_inds = '';
            offset_ids.forEach(function(e) {
            col_inds = dealTransfer.deal_transfer.getColIndexById(e);
            if (state) {
                dealTransfer.deal_transfer.setColumnHidden(col_inds,true); 
            } else 
                dealTransfer.deal_transfer.setColumnHidden(col_inds,false); 
            });

        } else if (header == 'Transfer') {
            var transfer_ids = ['transfer_counterparty_id','transfer_contract_id','transfer_trader_id',
                'transfer_sub_book','transfer_template_id'];
            var col_inds = '';
            transfer_ids.forEach(function(f) {
                col_inds = dealTransfer.deal_transfer.getColIndexById(f);
                if (state) {
                    dealTransfer.deal_transfer.setColumnHidden(col_inds,true); 
                } else 
                    dealTransfer.deal_transfer.setColumnHidden(col_inds,false); 
                 
            });
        }
    }

    dealTransfer.set_cell_value = function(criteria, to_set) {
        if (criteria == 'Transfer') {
            var counterparty_id = (to_set == true)? '<?php echo $counterparty_id; ?>' : '';
            var contract_id = (to_set == true)? '<?php echo $contract_id; ?>' : '' ;
            var trader_id = (to_set == true)? '<?php echo $trader_id; ?>' : '' ;
        }

        if (criteria == 'Offset') {
            var sub_book = (to_set == true)? '<?php echo $sub_book; ?>' : '' ;
        }

        var transfer_cpty_index = dealTransfer.deal_transfer.getColIndexById('transfer_counterparty_id');
        var transfer_contract_index = dealTransfer.deal_transfer.getColIndexById('transfer_contract_id');
        var transfer_trader_index = dealTransfer.deal_transfer.getColIndexById('transfer_trader_id');
        var sub_book_index = dealTransfer.deal_transfer.getColIndexById('sub_book');

        dealTransfer.deal_transfer.forEachRow(function(id) {
            if (criteria == 'Transfer') {
                dealTransfer.deal_transfer.cells(id, transfer_cpty_index).setValue(counterparty_id);
                dealTransfer.deal_transfer.cells(id, transfer_contract_index).setValue(contract_id);
                dealTransfer.deal_transfer.cells(id, transfer_trader_index).setValue(trader_id);
            } else if (criteria == 'Offset') {
                dealTransfer.deal_transfer.cells(id, sub_book_index).setValue(sub_book);
            }
        });
    }

    dealTransfer.set_transfer_type = function(result) {
        if (result) {
            var transfer_type = result[0].transfer_type;
            if (transfer_type != '' && transfer_type != 'undefined') {
                dealTransfer.form.setItemValue('transfer', transfer_type);
                dealTransfer.form.callEvent("onChange", ['transfer', transfer_type]);
            }
            dealTransfer.refresh_grid('1');
        }
    }
    

    /**
     * [open_deal_transfer_report Create Hyperlink for transfer report]
     * @param  {[type]} name  [name]
     * @param  {[type]} value [value]
     */
    open_deal_transfer_report = function(name, value) {
        if (name == "transfer_report") return "<div class='simple_link'><a href='#' onclick='dealTransfer.open_transfer_report()'>"+value+"</a></div>";
    }

    /**
     * [open_transfer_report Open Deal Transfer Report for selected deal.]
     */
    dealTransfer.open_transfer_report = function() {
        var deal_id = '<?php echo $deal_id; ?>';

        var exec_call = "EXEC spa_deal_transfer 'r', " + deal_id;


        var sp_url = js_php_path + 'dev/spa_html.php?spa=' + exec_call + '&' + getAppUserName();
        openHTMLWindow(sp_url);
    }

    dealTransfer.hide_show_columns = function (val,rId) {
        var col_fixed_price = dealTransfer.deal_transfer.getColIndexById('fixed_price');
        var col_index_adder = dealTransfer.deal_transfer.getColIndexById('index_adder');
        var col_fixed_adder = dealTransfer.deal_transfer.getColIndexById('fixed_adder');
        var show_fixed_price = false;
        var show_index_adder = false;
        var show_fixed_adder = false;
        if (val == 'd') { //Original Deal Price
            show_fixed_price = true;
            show_index_adder = true;
            show_fixed_adder = true;
        } else if (val == 'm') { // Market Price
            show_fixed_price = true;
            show_index_adder = false;
            show_fixed_adder = false;
        } else { // fixed Price or blank
            show_fixed_price = false;
            show_index_adder = false;
            show_fixed_adder = false;
        }
        // /* Hide show columns*/
        // dealTransfer.deal_transfer.setColumnHidden(col_fixed_price,show_fixed_price);
        // dealTransfer.deal_transfer.setColumnHidden(col_index_adder,show_index_adder);
        // dealTransfer.deal_transfer.setColumnHidden(col_fixed_adder,show_fixed_adder);

        /*Disable enable columns*/
        dealTransfer.deal_transfer.cells(rId,col_fixed_price).setDisabled(show_fixed_price);
        dealTransfer.deal_transfer.cells(rId,col_index_adder).setDisabled(show_index_adder);
        dealTransfer.deal_transfer.cells(rId,col_fixed_adder).setDisabled(show_fixed_adder);
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