<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
<?php
  
include "../../../adiha.php.scripts/components/include.file.v3.php";


$form_namespace = 'ns_match';
$form_name = 'frm_match';
$function_id = 10163720;

$receipt_detail_ids = isset($_REQUEST['receipt_detail_ids']) ? $receipt_detail_ids : 'NULL';
$delivery_detail_ids = isset($_REQUEST['delivery_detail_ids']) ? $delivery_detail_ids : 'NULL';
$match_id = isset($_REQUEST['match_id']) ? $match_id : 'NULL';
$process_id = isset($_REQUEST['process_id']) ? $process_id : 'NULL';
$mode = isset($_REQUEST['mode']) ? $_REQUEST['mode'] : 'i';
$convert_uom = isset($_REQUEST['convert_uom']) ? $_REQUEST['convert_uom'] : 'NULL';
$convert_frequency = isset($_REQUEST['convert_frequency']) ? $_REQUEST['convert_frequency'] : '703';
$shipment_name = isset($_REQUEST['shipment_name']) ? $_REQUEST['shipment_name'] : 'NULL';

$bookout_match = isset($_REQUEST['bookout_match']) ? $_REQUEST['bookout_match'] : 'NULL';
$location_id = isset($_REQUEST['location_id']) ? $_REQUEST['location_id'] : 'NULL';
$contract_id = isset($_REQUEST['contract_id']) ? $_REQUEST['contract_id'] : 'NULL';
$commodity_name = isset($_REQUEST['commodity_name']) ? $_REQUEST['commodity_name'] : 'NULL';
$location_contract_commodity = isset($_REQUEST['location_contract_commodity']) ? $_REQUEST['location_contract_commodity'] : 'NULL';

$match_group_id = isset($_REQUEST['match_group_id']) ? $_REQUEST['match_group_id'] : 'NULL';


if ($mode == 'u') {
	require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
}

$layout_json = '[
                    {id: "a", text: "Navigator", header: true, collapse: false, width: 300},
                    {id: "b", text: "", header:true}
              
                ]';
                
$layout_obj = new AdihaLayout();
echo $layout_obj->init_layout('deal_layout', '', '2U', $layout_json, $form_namespace);
echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_event');
echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_event');

$menu_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Add"}]';

$layout_json_inner = '[
                    {id: "a", text: "Schedule Match Group", header: true, height: 85},
                    {id: "b", text: "Schedule Shipment", header:true, height: 85},
                    {id: "c", text: "Schedule Match", header:true, height: 225},
                    {id: "d", text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\"undock_window_match();\"></a> Match"}              
                ]';
                    
$inner_layout_obj = new AdihaLayout();
echo $layout_obj->attach_layout_cell("rec_del_grids", 'b', '4E', $layout_json_inner);
echo $inner_layout_obj->init_by_attach('rec_del_grids', $form_namespace);
echo $inner_layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_event');
echo $inner_layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_event');

$menu_object = new AdihaToolbar();
echo $layout_obj->attach_toolbar_cell('bookout_menu', 'b');
echo $menu_object->init_by_attach('bookout_menu', $form_namespace);
echo $menu_object->load_toolbar($menu_json);
echo $menu_object->attach_event('', 'onClick', $form_namespace . '.refresh_export_click');



$schedule_match_viewer_grid_name = 'schedule_match_viewer';
echo $layout_obj->attach_grid_cell($schedule_match_viewer_grid_name, 'a');
//echo $layout_obj->attach_status_bar("c", true);
$schedule_match_viewer_grid_obj = new GridTable('ScheduleMatchViewer');        
echo $schedule_match_viewer_grid_obj->init_grid_table($schedule_match_viewer_grid_name, $form_namespace);
echo $schedule_match_viewer_grid_obj->set_search_filter(true, "");      
echo $schedule_match_viewer_grid_obj->return_init();
echo $schedule_match_viewer_grid_obj->enable_header_menu();

echo $schedule_match_viewer_grid_obj->attach_event("", "onSelectStateChanged", $form_namespace . '.schedule_match_viewer_row_click');

$filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163720', @template_name='ScheduleLiquidHydrocarbonProductsMatch', @group_name='Schedule Match Group'";
$filter_arr = readXMLURL2($filter_sql);
$tab_id = $filter_arr[0][tab_id];
$form_json = $filter_arr[0][form_json];
echo $inner_layout_obj->attach_form('form_1', 'a');
$filter_form_obj = new AdihaForm();
echo $filter_form_obj->init_by_attach('form_1', $form_namespace);
echo $filter_form_obj->load_form($form_json);

$filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163720', @template_name='ScheduleLiquidHydrocarbonProductsMatch', @group_name='Schedule Shipment'";
$filter_arr = readXMLURL2($filter_sql);
$tab_id = $filter_arr[0][tab_id];
$form_json = $filter_arr[0][form_json];
echo $inner_layout_obj->attach_form('form_3', 'b');
$filter_form_obj = new AdihaForm();
echo $filter_form_obj->init_by_attach('form_3', $form_namespace);
echo $filter_form_obj->load_form($form_json);

$filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163720', @template_name='ScheduleLiquidHydrocarbonProductsMatch', @group_name='Schedule Match Name'";
$filter_arr = readXMLURL2($filter_sql);
$tab_id = $filter_arr[0][tab_id];
$form_json = $filter_arr[0][form_json];
echo $inner_layout_obj->attach_form('form_2', 'c');
$filter_form_obj = new AdihaForm();
echo $filter_form_obj->init_by_attach('form_2', $form_namespace);
echo $filter_form_obj->load_form($form_json);
echo $filter_form_obj->attach_event("", "onChange", $form_namespace . '.quantity_change');
echo $filter_form_obj->set_input_value($form_namespace.'.form_2', 'frequency', $convert_frequency);

echo $filter_form_obj->attach_dependent_combos('commodity', 'saved_commodity_origin_id', 'get_values_to_set');
echo $filter_form_obj->attach_dependent_combos('saved_commodity_origin_id', 'saved_commodity_form_id', 'get_values_to_set');
echo $filter_form_obj->attach_dependent_combos('saved_commodity_form_id', 'saved_commodity_form_attribute1', 'get_values_to_set');
echo $filter_form_obj->attach_dependent_combos('saved_commodity_form_attribute1', 'saved_commodity_form_attribute2', 'get_values_to_set');
echo $filter_form_obj->attach_dependent_combos('saved_commodity_form_attribute2', 'saved_commodity_form_attribute3', 'get_values_to_set');
echo $filter_form_obj->attach_dependent_combos('saved_commodity_form_attribute3', 'saved_commodity_form_attribute4', 'get_values_to_set');
echo $filter_form_obj->attach_dependent_combos('saved_commodity_form_attribute4', 'saved_commodity_form_attribute5', 'get_values_to_set');


//match_grid
$match_grid_name = 'match';
echo $inner_layout_obj->attach_grid_cell($match_grid_name, 'd');

$match_grid_obj = new GridTable('Match');        
echo $match_grid_obj->init_grid_table($match_grid_name, $form_namespace);
echo $match_grid_obj->set_column_auto_size();
echo $match_grid_obj->set_search_filter(true, "");      
echo $match_grid_obj->enable_column_move();
echo $match_grid_obj->enable_multi_select();
echo $match_grid_obj->split_grid('2');
echo $match_grid_obj->return_init();
echo $match_grid_obj->enable_header_menu();
echo $match_grid_obj->attach_event("", "onChange", $form_namespace . '.value_change');
echo $layout_obj->close_layout();

$category_name = 'Schedule Match';
$category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
$category_data = readXMLURL2($category_sql);

$sp_url = "EXEC spa_scheduling_workbench @flag = 'v'
            , @process_id = '".$process_id."', @buy_deals = '".$receipt_detail_ids."'
            , @sell_deals = '".$delivery_detail_ids."' ,@match_id = '".$match_id."'
            , @convert_uom = ".$convert_uom.", @convert_frequency=".$convert_frequency."
            , @shipment_name = '".$shipment_name."', @mode = '".$mode."', @get_group_id = 1
            , @bookout_match = '" . $bookout_match . "', @location_id = '" . $location_id. "'
            , @contract_id = '" . $contract_id . "',@commodity_name='" . $commodity_name . "'
            , @location_contract_commodity = '" . $location_contract_commodity. "'
            , @match_group_id = " . $match_group_id;

$result_value = readXMLURL2($sp_url);
?>

<script type="text/javascript">
    var first_load = true;
    var category_id = '45';//'<?php echo $category_data[0][value_id]; ?>';
    var document_window;
    var get_group_id = '<?php echo $result_value[0][match_group_id]; ?>';
    
    /**
    * [onload function]
    */
    $(function() {
        
        
        var process_id = '<?php echo $process_id; ?>';
        var match_id = '<?php echo $match_id; ?>';
        var receipt_detail_ids = '<?php echo $receipt_detail_ids; ?>';
        var delivery_detail_ids = '<?php echo $delivery_detail_ids; ?>';
        var convert_uom = '<?php echo $convert_uom; ?>';
        var convert_frequency = '<?php echo $convert_frequency; ?>';
        var shipment_name = '<?php echo $shipment_name; ?>';
        var mode = '<?php echo $mode; ?>';
        var location_id = '<?php echo $location_id; ?>';
        var contract_id = '<?php echo $contract_id; ?>';
        var bookout_match = '<?php echo $bookout_match; ?>';
        var commodity_name = '<?php echo $commodity_name; ?>';
        var location_contract_commodity = '<?php echo $location_contract_commodity; ?>';
        var match_group_id = '<?php echo $match_group_id; ?>';
         
		if(mode == 'u') {
			add_manage_document_button(get_group_id, ns_match.bookout_menu, true);
		} 
		
        var sql_param = {
                            'action':'spa_scheduling_workbench',
                            'flag':'q',
                            'process_id': process_id, 
                            'buy_deals': receipt_detail_ids,
                            'sell_deals': delivery_detail_ids,
                            'match_id' : match_id ,
                            'convert_uom' : convert_uom,
                            'convert_frequency' : convert_frequency,
                            'shipment_name' : shipment_name,
                            'mode' : mode, 
                            'location_id' : location_id,
                            'bookout_match' : bookout_match,
                            'contract_id' : contract_id,
                            'commodity_name' : commodity_name,
                            'location_contract_commodity' : location_contract_commodity,
                            'match_group_id' : match_group_id
                        };  
   
        adiha_post_data('return_array', sql_param, '', '', 'ns_match.create_process_table_callback');   
    });

    function get_values_to_set(parent, child) {
        //alert(parent +'_' + child)
        var process_id = '<?php echo $process_id; ?>';
        var id = ns_match.schedule_match_viewer.getSelectedRowId();
        var region = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('region')).getValue();
        var commodity_id = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('source_commodity_id')).getValue();
        
        var sql_param = {
                        'action' : 'spa_scheduling_workbench',
                        'flag' : '1',
                        'process_id' : process_id,
                        'column_name' : child,
                        'region' : region,
                        'commodity_id' : commodity_id
                    }

        adiha_post_data('return_array', sql_param, '', '', 'get_values_to_set_cal_back');         
    }
    
    function get_values_to_set_cal_back(return_value) {
        if (return_value[0][0] == null) {
            return_value[0][0] = '';   
        }
        //alert('_' + return_value[0][0] + '_')
        ns_match.form_2.setItemValue(return_value[0][1], return_value[0][0]);       
    }
    
    /**
    * [load quantity to grid]
    */
    ns_match.quantity_change = function(name, value) {
        var total_rows = ns_match.match.getRowsNum(); 
        var frequency = ns_match.form_2.getItemValue('frequency');
        var quantity = ns_match.form_2.getItemValue('quantity');
        
        var sch_quantity = ns_match.match.getColIndexById('sch_quantity');  
        var total_qty = ns_match.match.getColIndexById('quantity');  
        var scheduled_to = ns_match.form_2.getItemValue('scheduled_to', true);  
        var scheduled_from = ns_match.form_2.getItemValue('scheduled_from', true);  
        var split_date = scheduled_from.split('-')
        
        var days_in_mths =  new Date(split_date[0], split_date[1] + 1, 0);
        days_in_mths = days_in_mths.getDate();
 
        
        if (name == 'quantity') {
            for (var i = 0 ; i < total_rows; i++) {
                for (var i = 0 ; i < total_rows; i++) {
                    if (frequency == 703) ns_match.match.cells(i, total_qty).setValue(quantity);
                    else ns_match.match.cells(i, total_qty).setValue(quantity * days_in_mths);
                    ns_match.match.cells(i, sch_quantity).setValue(value);
                   
                }  
            }
        } else if (name == 'lineup') {
            var lineup = ns_match.match.getColIndexById('lineup');      
     
            for (var i = 0 ; i < total_rows; i++) {
                
                ns_match.match.cells(i, lineup).setValue(value);
            }
        } else if (name == 'frequency') {
            load_quantity_frequecy();
        } 
    }
    
    /**
    * [load quantity according to frequncy]
    */  
    function load_quantity_frequecy() {
        var total_rows = ns_match.match.getRowsNum(); 
        var frequency = ns_match.form_2.getItemValue('frequency')
        var scheduled_from = ns_match.form_2.getItemValue('scheduled_from', true);  
        var split_date = scheduled_from.split('-')
        var days_in_mths =  new Date(split_date[0], split_date[1] + 1, 0);
        days_in_mths = days_in_mths.getDate();
        
        var sch_quantity = ns_match.match.getColIndexById('sch_quantity');  
        var total_qty = ns_match.match.getColIndexById('quantity');  
         
        var total_sch_qty = '';
 
        if (frequency == 700) { //daily
            for (var i = 0 ; i < total_rows; i++) {
                total_sch_qty = ns_match.match.cells(i, sch_quantity).getValue();
                //alert(days_in_mths + ',' + total_sch_qty)
               ns_match.match.cells(i, sch_quantity).setValue(total_sch_qty/days_in_mths);
            }
        } else {
            for (var i = 0 ; i < total_rows; i++) {
                 //alert(i + ',' + sch_quantity)
                 total_sch_qty = ns_match.match.cells(i, total_qty).getValue();
                 //alert(total_sch_qty)
                ns_match.match.cells(i, sch_quantity).setValue(total_sch_qty);
            }
        }
    }
    
    /**
    * [undock match window]
    */
    function undock_window_match() {
        ns_match.rec_del_grids.cells('c').undock(300, 300, 900, 700);
        ns_scheduling_workbench.rec_del_grids.dhxWins.window('c').maximize();
        ns_scheduling_workbench.rec_del_grids.dhxWins.window('c').button("park").hide();
    }
    
    /**
    * [create process tables]
    */
    ns_match.create_process_table_callback = function(return_value) {
        //ns_match.refresh_grid_match();
        ns_match.refresh_grid_schedule_match_viewer();  
    }
    
    /**
    * [refresh match grid]
    */
    ns_match.refresh_grid_match = function() {
        var process_id = '<?php echo $process_id; ?>';
        var receipt_detail_ids = '<?php echo $receipt_detail_ids; ?>';
        var delivery_detail_ids = '<?php echo $delivery_detail_ids; ?>';
        var match_id = '<?php echo $match_id; ?>';
        var shipment_name = 'NULL';
        var id = ns_match.schedule_match_viewer.getSelectedRowId();
        var commodity_id = ns_match.get_selected_commodity_id();
                        
        var region = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('region')).getValue();
        var tree_level = ns_match.schedule_match_viewer.getLevel(id);

        if (tree_level == 1) {
            shipment_name = ns_match.schedule_match_viewer.cells(id, 0).getValue();
        }
       
        var sql_param = {
                            'action':'spa_scheduling_workbench',
                            'flag':'m',
                            'grid_type':'g',
                            'buy_deals': receipt_detail_ids,
                            'sell_deals': delivery_detail_ids,
                            'process_id': process_id,
                            'match_id' : match_id,
                            'region' : region,
                            'shipment_name' : shipment_name,
                            'commodity_id' : commodity_id
                        };

        sql_param = $.param(sql_param);
        var sql_url = js_php_path + 'data.collector.php?' + sql_param;
        ns_match.match.clearAll();
		ns_match.match.loadXML(sql_url, function() {
		  ///*        
            ns_match.match.attachEvent("onCellChanged", function(rId,cInd,nValue) {
                var total_rows = ns_match.match.getRowsNum();                     
                var sch_quantity = ns_match.match.getColIndexById('sch_quantity');  
                var total_qty = ns_match.match.getColIndexById('quantity');  
                var scheduled_from = ns_match.form_2.getItemValue('scheduled_from', true);  
                var split_date = scheduled_from.split('-')
                var days_in_mths =  new Date(split_date[0], split_date[1] + 1, 0);
                days_in_mths = days_in_mths.getDate();
                
                var frequency = ns_match.form_2.getItemValue('frequency');
                var column_name =  ns_match.match.getColumnId(cInd, rId);
                if (column_name == 'sch_quantity') {
                    if (frequency == 700) ns_match.match.cells(rId,total_qty).setValue(nValue * days_in_mths);
                    else ns_match.match.cells(rId,total_qty).setValue(nValue);
                }  
            });
            //*/              
        });   
    }

    /**
    * [load bookout match grid]
    */
    ns_match.refresh_grid_schedule_match_viewer = function () {
        var process_id = '<?php echo $process_id; ?>';
        var receipt_detail_ids = '<?php echo $receipt_detail_ids; ?>';
        var delivery_detail_ids = '<?php echo $delivery_detail_ids; ?>';
        var match_id = '<?php echo $match_id; ?>';
        
        var sql_param = {
                            'action' : 'spa_scheduling_workbench',
                            'flag' : 'w',
                            'grid_type' : 'tg',
                            'buy_deals': receipt_detail_ids,
                            'sell_deals': delivery_detail_ids,
                            'process_id' : process_id,
                            'match_id' : match_id,
                            'grouping_column' : 'group_name,transportation_grp,bookoutid'
                        };

        sql_param = $.param(sql_param);
        var sql_url = js_php_path + 'data.collector.php?' + sql_param;
 
        ns_match.schedule_match_viewer.load(sql_url,function(){
            ns_match.schedule_match_viewer.expandAll();
            ns_match.schedule_match_viewer.selectRow(2, true, true, true); //select any one on default
            ns_match.get_previous_selected_commodity_id();
            ns_match.get_previous_selected_id(); 
            ns_match.refresh_grid_match();
        });      
    }
    
    /**
    * [load location drop down]
    */
    ns_match.load_location_dd_by_loc_group = function() {
        var id = ns_match.schedule_match_viewer.getSelectedRowId();

        var detail_id = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('source_deal_detail_id')).getValue(); 
        var location_id = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('source_minor_location_id')).getValue();  
        var location_name = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('location_name')).getValue();
        var region = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('region')).getValue();
       
        var cm_param = {'action': 'spa_source_minor_location',
                        'flag': '2',
                        'grid_value_id': region,
                        'source_minor_location_ID' : location_id
                        };
                               
        cm_param = $.param(cm_param);
        var url = js_php_path + 'dropdown.connector.php?' + cm_param; 
        var cm_data = ns_match.form_2.getCombo('location');
        cm_data.clearAll();
 
        cm_data.load(url, function(e) {
            cm_data.setComboValue(location_id);            
        });                
    }
                
    /**
    * [get grid selected location id]
    */
    ns_match.get_selected_id = function() {
        var id = ns_match.schedule_match_viewer.getSelectedRowId();
        var location_id = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('source_minor_location_id')).getValue();  
      
        //ns_match.load_location_dd_by_loc_group();
        return location_id;
    }
    
    /**
    * [get grid selected region id]
    */ 
    ns_match.get_selected_region_id = function() {
        var id = ns_match.schedule_match_viewer.getSelectedRowId();
        var region = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('region')).getValue();  
        return region;
    }
    
    /**
    * [get grid selected commodity id]
    */ 
    ns_match.get_selected_commodity_id = function() {
        var id = ns_match.schedule_match_viewer.getSelectedRowId();
        var commodity_id = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('source_commodity_id')).getValue();  
        return commodity_id;
    }
    
    /**
    * [previous selected id]
    */
    ns_match.get_previous_selected_id = function() {
        var get_selected_id = ns_match.get_selected_region_id() + '_' + ns_match.get_selected_id();
        ns_match.form_1.setItemValue('previous_id', get_selected_id);
    }
    
    /**
    * [previous selected commodity id]
    */
    ns_match.get_previous_selected_commodity_id = function() {
        var get_selected_id = ns_match.get_selected_commodity_id();
        ns_match.form_1.setItemValue('previous_commodity_id', get_selected_id);
    }
    
    /**
    * [populate data for form]
    */
    ns_match.schedule_match_viewer_row_click = function () {
        ns_match.load_location_dd_by_loc_group();
        var process_id = '<?php echo $process_id; ?>';
        var id = ns_match.schedule_match_viewer.getSelectedRowId();
        var tree_level = ns_match.schedule_match_viewer.getLevel(id);
        var match_id = '<?php echo $match_id; ?>';
        var convert_uom = '<?php echo $convert_uom; ?>';
        var convert_frequency = '<?php echo $convert_frequency; ?>';
        var region = ns_match.get_selected_region_id();
        var commodity_id = ns_match.get_selected_commodity_id();
        
        
        if (first_load === true) {
            ns_match.rec_del_grids.cells('a').collapse();
            ns_match.rec_del_grids.cells('b').collapse();
        }
       
        if (tree_level == 2) {
            ns_match.rec_del_grids.cells('a').collapse();            
            ns_match.rec_del_grids.cells('b').collapse();
            ns_match.rec_del_grids.cells('c').expand();
            var match_deal_detail_id = ns_match.schedule_match_viewer.cells(id, 1).getValue();
            
            if (first_load === false) {
                ns_match.schedule_match_save_click('p');                 
            }

            first_load = false;
        } else if (tree_level == 1) {
            ns_match.rec_del_grids.cells('a').collapse();
            ns_match.rec_del_grids.cells('c').collapse();
            ns_match.rec_del_grids.cells('b').expand();
           
            //ns_match.rec_del_grids.cells('b')expand();
            
            ns_match.refresh_grid_match();
            return;
          
        } else if (tree_level == 0) {
            ns_match.rec_del_grids.cells('a').expand();
            ns_match.rec_del_grids.cells('c').collapse();
            ns_match.rec_del_grids.cells('b').collapse();
        }
   
        var data = {
                        'action' : 'spa_scheduling_workbench',
                        'flag' : 'f',
                        'process_id' : process_id,
                        'match_deal_detail_id' : match_deal_detail_id,
                        'match_id' : match_id,
                        'convert_uom' : convert_uom,
                        'convert_frequency' : convert_frequency,
                        'region' : region,
                        'commodity_id' :commodity_id
                        
                    };
    
        adiha_post_data('return_array', data, '', '', 'ns_match.schedule_match_viewer_row_click_callback');   
   
    }
    
    /**
    * [populate data for form callback]
    */
    ns_match.schedule_match_viewer_row_click_callback = function (return_value) {
        ns_match.refresh_grid_match();
        var match_number = return_value[0][0];
        var group_name = return_value[0][1];
        var volume = return_value[0][2];
        var source_commodity_id = return_value[0][3];
        var commodity_name = return_value[0][4];
        var source_minor_location_id = return_value[0][5];
        var location = return_value[0][6];
        var source_counterparty_id = return_value[0][7];
        var counterparty_name = return_value[0][8];
        var user_name = return_value[0][9];
        var update_ts = return_value[0][10];
        var match_id = return_value[0][11];
        var scheduler = return_value[0][12];
        var status = return_value[0][14];	
        var scheduled_from	 = return_value[0][15];
        var scheduled_to = return_value[0][16];	
        var comments = return_value[0][18];	
        var pipeline_cycle = return_value[0][19];
        var consignee = return_value[0][20];	
        var po_number = return_value[0][21];	
        var container = return_value[0][22];	
        var carrier = return_value[0][23];
        var group_id = return_value[0][24];
        var lineup = return_value[0][25];
        var frequency = return_value[0][26];
        var single_multiple = return_value[0][27];
        var saved_commodity_origin_id =  return_value[0][28];
        var saved_commodity_form_id =  return_value[0][29];
        var saved_commodity_form_attribute1 =  return_value[0][30];
        var saved_commodity_form_attribute2 =  return_value[0][31];
        var saved_commodity_form_attribute3 =  return_value[0][32];
        var saved_commodity_form_attribute4 =  return_value[0][33];
        var saved_commodity_form_attribute5 =  return_value[0][34];
        var organic =  return_value[0][35];
        var match_group_shipment_id =  return_value[0][36];
        var match_group_shipment =  return_value[0][37];
        var shipment_status =  return_value[0][38];
        var shipment_workflow_status =  return_value[0][39];    
        var container_number = return_value[0][40];           
       
        ns_match.form_1.setItemValue('group_name', group_name);
        ns_match.form_1.setItemValue('group_id', group_id);
        ns_match.form_2.setItemValue('match_id', match_id);
        ns_match.form_2.setItemValue('match_number', match_number);
        ns_match.form_2.setItemValue('quantity', volume);
        ns_match.form_2.setItemValue('commodity', source_commodity_id);
        ns_match.form_2.setItemValue('last_edited_by', user_name);
        ns_match.form_2.setItemValue('last_edited_on', update_ts);
        ns_match.form_2.setItemValue('scheduler', scheduler);
        ns_match.form_2.setItemValue('location', source_minor_location_id);
        ns_match.form_2.setItemValue('consignee', consignee); 
        ns_match.form_2.setItemValue('status', status);  
        ns_match.form_2.setItemValue('scheduled_from', scheduled_from);
        ns_match.form_2.setItemValue('scheduled_to', scheduled_to);
        ns_match.form_2.setItemValue('comments', comments);
        ns_match.form_2.setItemValue('pipeline_cycle', pipeline_cycle);
        ns_match.form_2.setItemValue('po_number', po_number);
        ns_match.form_2.setItemValue('container', container);
        ns_match.form_2.setItemValue('carrier', carrier);
        ns_match.form_2.setItemValue('lineup', lineup);
        ns_match.form_2.setItemValue('frequency', frequency);
        ns_match.form_2.setItemValue('commodity_origin_id', saved_commodity_origin_id);
        ns_match.form_2.setItemValue('commodity_form_id', saved_commodity_form_id);
        ns_match.form_2.setItemValue('commodity_form_attribute1', saved_commodity_form_attribute1);
        ns_match.form_2.setItemValue('commodity_form_attribute2', saved_commodity_form_attribute2);
        ns_match.form_2.setItemValue('commodity_form_attribute3', saved_commodity_form_attribute3);
        ns_match.form_2.setItemValue('commodity_form_attribute4', saved_commodity_form_attribute4);
        ns_match.form_2.setItemValue('commodity_form_attribute5', saved_commodity_form_attribute5);
        ns_match.form_2.setItemValue('container_number', container_number);

        if (organic == 'y') {
            ns_match.form_2.checkItem('organic');
        } else {
            ns_match.form_2.uncheckItem('organic');
        }
        
        ns_match.form_3.setItemValue('match_group_shipment_id', match_group_shipment_id);
        ns_match.form_3.setItemValue('match_group_shipment', match_group_shipment);
        ns_match.form_3.setItemValue('shipment_status', shipment_status);
        ns_match.form_3.setItemValue('shipment_workflow_status', shipment_workflow_status);
                
        if (single_multiple == 0) {
            ns_match.form_2.disableItem('quantity');    
        } 
    }
    
    /**
    * [save match and bookout]
    */
    ns_match.schedule_match_save_click = function (process_final) {
        ns_match.deal_layout.cells('b').progressOn();
        var process_id = '<?php echo $process_id; ?>';
        var xml_form = ns_match.get_form_data_value();
        var xml_grid = ns_match.get_changed_grid_data();
        var receipt_detail_ids = '<?php echo $receipt_detail_ids; ?>';
        var delivery_detail_ids = '<?php echo $delivery_detail_ids; ?>';
        var xml_value = 'NULL';
        var match_id = '<?php echo $match_id; ?>';
        var mode = '<?php echo $mode; ?>'
        var shipment_name = '<?php echo $shipment_name; ?>';
        var id = ns_match.schedule_match_viewer.getSelectedRowId();
        var region = ns_match.schedule_match_viewer.cells(id, ns_match.schedule_match_viewer.getColIndexById('region')).getValue();
        var location_id = '<?php echo $location_id; ?>';
        var contract_id = '<?php echo $contract_id; ?>';
        var bookout_match = '<?php echo $bookout_match; ?>';
        var location_contract_commodity = '<?php echo $location_contract_commodity; ?>';
      
        
        var data = {
                        'action' : 'spa_scheduling_workbench',
                        'flag' : process_final,
                        'process_id' : process_id,
                        'xml_form' : xml_form,
                        'buy_deals' : receipt_detail_ids,
                        'sell_deals' : delivery_detail_ids,
                        'match_id' : match_id,
                        'xml_value' : xml_grid,
                        'shipment_name' : shipment_name,
                        'mode' : mode,
                        'region' : region,
                        'location_id' : location_id,
                        'bookout_match' : bookout_match,
                        'contract_id' : contract_id,
                        'location_contract_commodity' : location_contract_commodity
                    };
    
        if (process_final == 'p') adiha_post_data('return_array', data, '', '', 'ns_match.schedule_match_viewer_row_click_callback_process');
        else adiha_post_data('return_array', data, '', '', 'ns_match.bookout_save_callback', '', '');
    }
    
    ns_match.schedule_match_viewer_row_click_callback_process = function (return_value) {
        ns_match.deal_layout.cells('b').progressOff();
        //first_load = true;
        //ns_match.schedule_match_viewer_row_click();
        ns_match.get_previous_selected_id();
        ns_match.get_previous_selected_commodity_id();
    }
    
    /**
    * [get XML for changed grid row]
    */
    ns_match.get_changed_grid_data = function () {
        var xml_grid = '<gridXml>';
        ns_match.match.forEachRow(function (id) {
            xml_grid = xml_grid + '<GridRow ';
            ns_match.match.forEachCell(id, function (cellObj, ind) {                    
                grid_index = ns_match.match.getColumnId(ind);
                value = cellObj.getValue(ind);   
                	xml_grid = xml_grid + grid_index + '="' + value  + '" ';
                })  
                	xml_grid = xml_grid + '></GridRow>';                      
            });
       	xml_grid = xml_grid + '</gridXml>';       
        return xml_grid; 
    }
    
    /**
    * [get form data in XML form]
    */
    ns_match.get_form_data_value = function() {
        var form_data_1 = ns_match.form_1.getFormData();
        var form_data_2 = ns_match.form_2.getFormData();
        var form_data_3 = ns_match.form_3.getFormData();
        //var id = ns_match.schedule_match_viewer.getSelectedRowId();
        var region = ns_match.form_1.getItemValue('previous_id');        
        var commodity_id = ns_match.form_1.getItemValue('previous_commodity_id'); 
        var xml_data = '<Root><FormXML region="' + region + '" commodity_id="' + commodity_id + '" ' ;

        for (var a in form_data_1) {
            //if (form_data_1[a] != '' && form_data_1[a] != null) {

                if (ns_match.form_1.getItemType(a) == 'calendar') {
                    value = ns_match.form_1.getItemValue(a, true);
                } else {
                    value = form_data_1[a];
                }
                xml_data +=  a + '="' + value + '" ';
            //}
        }   
        
        for (var a in form_data_2) {
          
           // if (form_data_2[a] != '' && form_data_2[a] != null) {

                if (ns_match.form_2.getItemType(a) == 'calendar') {
                    value = ns_match.form_2.getItemValue(a, true);
                } else if (ns_match.form_2.getItemType(a) == 'checkbox') {
                    value = (ns_match.form_2.isItemChecked(a)) === true ? 'y' : 'n';                    
                } else {
                    value = form_data_2[a];
                }
                xml_data +=  a + '="' + value + '" ';
            //}
        }  
        
        for (var a in form_data_3) {
          
           // if (form_data_2[a] != '' && form_data_2[a] != null) {

                if (ns_match.form_3.getItemType(a) == 'calendar') {
                    value = ns_match.form_3.getItemValue(a, true);
                } else if (ns_match.form_3.getItemType(a) == 'checkbox') {
                    value = (ns_match.form_3.isItemChecked(a)) === true ? 'y' : 'n';                    
                } else {
                    value = form_data_3[a];
                }
                xml_data +=  a + '="' + value + '" ';
            //}
        }  
        
        xml_data += '></FormXML></Root>';
 
        return xml_data;
    }
    
    /**
    * [export switch functions]
    */
    ns_match.refresh_export_click = function(id) {
        switch(id) {   
			case 'save':
                ns_match.schedule_match_save_click('c');
            break;
            case 'documents':
                ns_match.open_document();
            break;
        }
    }
    
    /**
    * [save callback]
    */
    ns_match.bookout_save_callback = function(return_value) {
        ns_match.deal_layout.cells('b').progressOff();
        //alert('')
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4],
                expire:1000
            });
            
            setTimeout('ns_match.close_window()', 1000);   
        } else {
            var msg = return_value[0][4].replace(/&lt;/g, '<');
            msg = msg.replace(/&gt;/g, '>');
            dhtmlx.message({
                        title:'Error',
                        type:'alert-error',
                        text: msg
                    });
            return;
        }
    }
    
    /**
    * [close window]
    */
    ns_match.close_window = function () {
        parent.reload_all_grids();
        var win_obj = parent.bookout_match_window.window('w1');
        win_obj.close();
    }
    
    /**
     * [open_document Open Document window]
     */
    ns_match.open_document = function() {

        ns_match.unload_document_window();

        if (!document_window) {
            document_window = new dhtmlXWindows();
        }
		var match_group_id = ns_match.form_1.getItemValue('group_id');
        var win_title = 'Document';
        var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?notes_category= '+category_id +'&notes_object_id=' + match_group_id + '&is_pop=true';

        var win = document_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {notes_category:category_id});

        win.attachEvent('onClose', function(w) {
            update_document_counter(get_group_id, ns_match.bookout_menu);
            return true;
        });
    }
    
    /**
     * [unload_document_window Unload Document Window]
     */
    ns_match.unload_document_window = function() {
        if (document_window != null && document_window.unload != null) {
            document_window.unload();
            document_window = w1 = null;
        }
    }

</script>