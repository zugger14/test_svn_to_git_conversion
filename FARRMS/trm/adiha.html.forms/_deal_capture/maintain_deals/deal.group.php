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
    $form_namespace = 'dealGroup';
    $deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : '';
    

    $sub_book = $data[0]['sub_book'];
    $counterparty_id = $data[0]['counterparty_id'];
    $contract_id = $data[0]['contract_id'];
    $trader_id = $data[0]['trader_id'];
    $volume = $data[0]['deal_volume'];
    $uom = $data[0]['uom'];
    $deal_date = $data[0]['deal_date'];

    $layout_json = '[{id: "a", header:false,height:100},{id: "b", text: "Existing Group - <i>Selected deals are already present in following groups. <i>"}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
                      
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $sp_url = "EXEC spa_deal_group @flag='l', @source_deal_header_id='" . $deal_id . "'";
    $primary_deal_dropdown = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

    $form_json = '[ 
                    {"type": "settings", "position": "label-top", "offsetLeft": 10},
                    {type:"combo", name: "primary_deal_id", label:"Primary Deal", "labelWidht":300, required:true, filtering:true, "inputWidth":290, "options": ' . $primary_deal_dropdown . '}
                ]';

    echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    echo $form_obj->init_by_attach('form', $form_namespace);
    echo $form_obj->load_form($form_json);
    //echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
	
	$menu_json = '[{id:"refresh", text:"refresh", img:"refresh.gif", title:"Refresh", enabled:true},{id:"remove", text:"Remove from group", img: "close.gif", imgdis: "close_dis.gif", title:"Remove from group", enabled:false}]';
	$menu_object = new AdihaMenu();
	echo $layout_obj->attach_menu_cell('group_menu', 'b');
	echo $menu_object->init_by_attach('group_menu', $form_namespace);
	echo $menu_object->load_menu($menu_json);
	echo $menu_object->attach_event('', 'onClick', $form_namespace . '.group_menu_click');
	
	
	// attach grid
	echo $layout_obj->attach_grid_cell('grouped_deals', 'b');
	$grid_obj = new GridTable('grouped_deals');
	echo $grid_obj->init_grid_table('grouped_deals', $form_namespace, 'n');
	echo $grid_obj->set_column_auto_size();	
	echo $grid_obj->enable_multi_select();
	echo $grid_obj->set_search_filter(true, "");
	echo $grid_obj->return_init();
	$sp_url = "EXEC spa_deal_group @flag='m', @source_deal_header_id='" . $deal_id . "'";
	echo $grid_obj->load_grid_data($sp_url, 'g', false);
	echo $grid_obj->attach_event("", "onSelectStateChanged", $form_namespace . '.grid_row_selection');
	echo $grid_obj->load_grid_functions();
	
	echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_status" id="txt_status">cancel</textarea>
<script type="text/javascript">
	/**
     * [group_menu_click Menu Click functions]
     * @param  {[string]} id [menu id]
     */
	dealGroup.group_menu_click = function(id) {
		if (id == 'refresh') {
			dealGroup.refresh_grid();
		} else if (id == 'remove') {
			var selected_ids = dealGroup.grouped_deals.getColumnValues(0);
			data = {    
				"action": "spa_deal_group", 
				"flag":"d", 
				"source_deal_header_id":selected_ids
			};
			var win_obj = window.parent.deal_group_window.window('w1');
			win_obj.progressOn();
			adiha_post_data("alert", data, '', '', 'dealGroup.save_callback'); 
		}
	}
	
	/**
     * [grid_row_selection Grid rows select/unselect event function]
     * @param  {[string]} row_ids [row ids]
     */
	dealGroup.grid_row_selection = function(row_ids) {		
		var group_ids = dealGroup.grouped_deals.getColumnValues(1);	
		if (row_ids != null && group_ids != '' && group_ids != null) {		
			dealGroup.group_menu.setItemEnabled('remove');
		} else {
			dealGroup.group_menu.setItemDisabled('remove');
		}
	}
	
    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    dealGroup.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(dealGroup.form);
                if (status) {
                    var deal_id = '<?php echo $deal_id; ?>';
                    var primary_deal_id = dealGroup.form.getItemValue("primary_deal_id");

                    data = {    
                            "action": "spa_deal_group", 
                            "flag":"i", 
                            "source_deal_header_id":deal_id, 
                            "structure_deal_id":primary_deal_id
                        };
                    var win_obj = window.parent.deal_group_window.window('w1');
                    win_obj.progressOn();
                    adiha_post_data("alert", data, '', '', 'dealGroup.save_callback');                    
                }
                break;
            case "cancel":
                document.getElementById("txt_status").value = 'cancel';
                var win_obj = window.parent.deal_group_window.window("w1");
                win_obj.close();
                break;
        }
    }

    dealGroup.save_callback = function(result) {
		var win_obj = window.parent.deal_group_window.window("w1");	
		win_obj.progressOff();
		
        if (result[0].errorcode == 'Success') {
            document.getElementById("txt_status").value = 'Success';            
			dealGroup.refresh_grid();
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
</html>