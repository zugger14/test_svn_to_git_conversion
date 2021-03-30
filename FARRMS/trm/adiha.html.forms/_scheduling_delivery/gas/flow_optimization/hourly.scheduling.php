<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php
$app_user_loc = $app_user_name;
$form_function_id = 10163611;
$rights_sch_file_create_add = 10164301;
$rights_sch_file_delete = 10164302;
$rights_sch_file_submit = 10164303; //function id of view nomination schedule menu

list (
    $has_right_sch_file_create_add,
    $has_right_sch_file_delete,
    $has_right_sch_file_submit
    ) = build_security_rights (
    $rights_sch_file_create_add,
    $rights_sch_file_delete,
    $rights_sch_file_submit
);

$flag = 'i';
$volume = get_sanitized_value($_GET['volume'] ?? '');
$rad_value = ($volume > 0) ? 'd' : 'r';
$location_id = get_sanitized_value($_GET['location_id'] ?? '');
$term = get_sanitized_value($_GET['term'] ?? '');
$term_end = get_sanitized_value($_GET['term_end'] ?? '');
$counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
$primary_counterparty_id = get_sanitized_value($_GET['primary_counterparty_id'] ?? 'NULL');
$source_deal_header_id = get_sanitized_value($_GET['source_deal_header_id'] ?? 'NULL');
$source_deal_detail_id = get_sanitized_value($_GET['source_deal_detail_id'] ?? 'NULL');
$deal_id = get_sanitized_value($_GET['deal_id'] ?? 'NULL');
$call_from = get_sanitized_value($_GET['call_from'] ?? 'NULL');
$parent_call_from = get_sanitized_value($_GET['parent_call_from'] ?? 'NULL');
$book_deal_type_map_id = get_sanitized_value($_GET['book_deal_type_map_id'] ?? 'NULL');
$option_radio_label_array = array('Deliver', 'Receive');
$option_radio_value_array = array('d', 'r');
$available_volume = 0;

$flow_start =  get_sanitized_value($_GET['flow_start'] ?? '');
$flow_end = get_sanitized_value($_GET['flow_end'] ?? ''); 
$receipt_loc_id = get_sanitized_value($_GET['receipt_loc_id'] ?? '');
$delivery_loc_id = get_sanitized_value($_GET['delivery_loc_id'] ?? '');
$match_uom = get_sanitized_value($_GET['uom'] ?? '');
$total_receipt_vol = get_sanitized_value($_GET['total_receipt_vol'] ?? '');
$total_delivery_vol = get_sanitized_value($_GET['total_delivery_vol'] ?? '');
$process_id = get_sanitized_value($_GET['process_id'] ?? '');
$receipt_deals = get_sanitized_value($_GET['receipt_deals'] ?? '');
$delivery_deals = get_sanitized_value($_GET['delivery_deals'] ?? '');
$avail_vol = get_sanitized_value($_GET['avail_vol'] ?? '');
$min_rec_or_del_vol = get_sanitized_value($_GET['min_rec_or_del_vol'] ?? '');
$storage_loc_id = get_sanitized_value($_GET['storage_loc_id'] ?? '');
$storage_type = get_sanitized_value($_GET['storage_type'] ?? '');
$pool_loc_id = get_sanitized_value($_GET['pool_loc_id'] ?? '');
$pool_type = get_sanitized_value($_GET['pool_type'] ?? '');
$from_loc_name = get_sanitized_value($_GET['from_loc_name'] ?? '');
$to_loc_name = get_sanitized_value($_GET['to_loc_name'] ?? '');
$box_id = get_sanitized_value($_GET['box_id'] ?? '');
$granularity = get_sanitized_value($_GET['granularity'] ?? '');
$period_from = get_sanitized_value($_GET['period_from'] ?? '');
$from_loc_grp_name = get_sanitized_value($_GET['from_loc_grp_name'] ?? '');
$to_loc_grp_name = get_sanitized_value($_GET['to_loc_grp_name'] ?? '');
$from_pos_beg = get_sanitized_value($_GET['from_pos_beg'] ?? '');
$to_pos_beg = get_sanitized_value($_GET['to_pos_beg'] ?? '');

//get subgrid header definition
$xml_file = "EXEC spa_flow_optimization_hourly @flag='s1', @call_from='get_subgrid_definition', @flow_date_from='$flow_start', @granularity=$granularity, @period_from='$period_from'";
$subgrid_header_definition = readXMLURL2($xml_file);

$hide_storage_contract_col = 'true';
$storage_asset_info_arr = [];
if($from_loc_grp_name == 'Storage' || $to_loc_grp_name == 'Storage') {
    $hide_storage_contract_col = 'false';
    $param_st_loc_id = '';
    $param_inj_with_flag = '';
    $param_st_pos = '';

    if($from_loc_grp_name == 'Storage') {
        $param_st_loc_id = $receipt_loc_id;
        $param_inj_with_flag = 'w';
        $param_st_pos = $from_pos_beg;
    } else if($to_loc_grp_name == 'Storage') {
        $param_st_loc_id = $delivery_loc_id;
        $param_inj_with_flag = 'i';
        $param_st_pos = $to_pos_beg;
    }
    $storage_loc_id = $param_st_loc_id;
    $storage_type = $param_inj_with_flag;
    fx_store_storage_asset_info($param_st_loc_id, $param_inj_with_flag, $param_st_pos);
}
/**
 * function to store storage asset information which will be used for storage case
 *
 * @return  [type]  [return description]
 */
function fx_store_storage_asset_info($storage_loc_id, $inj_with_flag, $storage_position) {
    global $flow_start, $storage_asset_info_arr;
    $xml_file = "EXEC spa_virtual_storage @flag='o', @storage_location=$storage_loc_id, @effective_date='" . $flow_start . "', @inj_with='" . $inj_with_flag . "', @storage_position=$storage_position";
    $storage_asset_info_arr = readXMLURL2($xml_file);
    
}

/*
if ($pool_type == '' || $storage_type == '') {
    if($pool_type == 'i') {
        $delivery_loc_id = $pool_loc_id;
    } else if ($pool_type == 'w') {
        $receipt_loc_id = $pool_loc_id;
    } else if ($storage_type == 'i') {
        $delivery_loc_id = $storage_loc_id;
    } else if ($storage_type == 'w') {
        $receipt_loc_id = $storage_loc_id;
    }
}
*/

if (($counterparty_id == 0 || $counterparty_id == '') && $source_deal_detail_id != 'NULL') {
    $xml_file = "EXEC spa_getsourcecounterparty @flag='a', @source_system_id=$source_deal_detail_id";
    $return_value = readXMLURL($xml_file);
    $counterparty_id = $return_value[0][0];
}


$rad_value = 'd';

/*
$xml_file = "EXEC spa_get_loss_factor_volume @path=null, @flag='t', @source_deal_header_id=$source_deal_header_id, @source_deal_detail_id=$source_deal_detail_id";

$return_value = readXMLURL2($xml_file);

$physical_deal_id = $return_value[0]['source_deal_header_id'];
$deal_id = $return_value[0]['deal_id'];
$trader_id = $return_value[0]['trader_id'];
$total_volume = $return_value[0]['total_volume'];
$primary_counterparty_id = $return_value[0]['primary_counterparty_id'];
$entire_term_start = $return_value[0]['entire_term_start'];
$entire_term_end = $return_value[0]['entire_term_end'];
$counterparty_id =  $return_value[0]['counterparty_id'];
$location_id = ($location_id == '') ? $return_value[0]['location_id'] : $location_id;
$uom = $return_value[0]['deal_volume_uom_id'];
*/
$volume = $available_volume;       //not in use

$physical_path = get_sanitized_value($_GET['selected_path_id'] ?? '');
$selected_contract_id = get_sanitized_value($_GET['selected_contract_id'] ?? '');

$xml_file = "EXEC spa_delivery_path @flag='s', @from_location=$delivery_loc_id, @to_location=$receipt_loc_id, @call_from='" . $call_from . "'";
$return_value = readXMLURL($xml_file);
$physical_path_toggle = isset($return_value[0][0]) ? $return_value[0][0] : '';

if($physical_path == '') {
    $xml_file = "EXEC spa_delivery_path @flag='s', @from_location=$receipt_loc_id, @to_location=$delivery_loc_id, @call_from='" . $call_from . "'";
    $return_value = readXMLURL($xml_file);
    $physical_path = isset($return_value[0][0]) ? $return_value[0][0] : '';
}

if (isset($return_value[0][2]) && ($call_from == 'opt_book_out' || $call_from == 'opt_book_out_b2b')) {
    $loc_pipeline = $return_value[0][2];
} else {
    $loc_pipeline = '';
}

if ($call_from == 'NULL' || $call_from == 'null' || $call_from == '') {
    $call_from = 'Deal';
} 
$form_namespace = 'sch';
$json = "[
            {
                id:		'a',
                text:	'Schedule',
                header:	false,
            }

        ]";



$sch_obj = new AdihaLayout();
echo $sch_obj->init_layout('sch_layout', '', '1C', $json, $form_namespace);

$xml_file = "EXEC spa_create_application_ui_json @flag='j'
                                                    , @application_function_id='$form_function_id'
                                                    , @template_name='flow_match' 
                                                    ";
$return_value1 = readXMLURL2($xml_file);
$form_json = $return_value1[0]['form_json'];
$tab_id = $return_value1[0]['tab_id'];

$menu_json = '[
            {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif", enabled: true},
            {id: "save_schd", text: "Save", img: "save.gif", img_disabled: "save_dis.gif", enabled: 1},
            {id: "clear_adj", text: "Clear Adjustments", img: "clear.gif", img_disabled: "clear_dis.gif", enabled: 1}
        ]';
echo $sch_obj->attach_menu_layout_cell('sch_menu', 'a', $menu_json, $form_namespace.'.menu_click');

//attach sch grid
$sch_grid_name = 'hourly_sch_grid';
echo $sch_obj->attach_grid_cell($sch_grid_name, 'a');
$sch_grid_obj = new AdihaGrid();
echo $sch_grid_obj->init_by_attach($sch_grid_name, $form_namespace);

$column_text = "&nbsp;,Path,Contract,Storage Contract,Book,Term From,Term To,New";
$column_id = "sub,path,contract,storage_contract,book,term_from,term_to,new";
$column_width = "30,170,*,*,*,*,*,*";
$column_type = "sub_row_grid,combo,combo,combo,combo,ro_dhxCalendarA,ro_dhxCalendarA,ro";
$column_visbility = "false,false,false,$hide_storage_contract_col,false,false,false,true";

echo $sch_grid_obj->set_header($column_text);
echo $sch_grid_obj->set_columns_ids($column_id);
echo $sch_grid_obj->set_widths($column_width);
echo $sch_grid_obj->set_column_types($column_type);
echo $sch_grid_obj->set_column_visibility($column_visbility);
echo $sch_grid_obj->set_date_format($date_format, "%Y-%m-%d");
echo $sch_grid_obj->return_init();
echo $sch_grid_obj->enable_header_menu();

echo $sch_obj->close_layout();
?>
<div id="window_info" process_id="<?php echo $process_id; ?>" style="display: none;"></div>
</body>

<script>

    dhx_wins = new dhtmlXWindows();
    var post_data = '';

    vol_validate = new Array(2);

    for(i = 0; i< 50; i++) {
        vol_validate[i] = new Array();
    }

    get_param = {};
    context_info = {};
    context_info.rId = '';
    context_info.cId = '';
    context_info.grid_obj = '';

    form_function_id = '<?php echo $form_function_id; ?>';
    has_right_sch_file_create_add = Boolean('<?php echo $has_right_sch_file_create_add; ?>');
    is_add_clicked = false;

    get_param.deal_id = '<?php echo $source_deal_header_id; ?>';
    get_param.deal_detail_id = '<?php echo $source_deal_detail_id; ?>';
    get_param.deal_ref_id = '<?php echo $deal_id; ?>';
    get_param.location_id = '<?php echo $location_id; ?>';
    get_param.counterparty = '<?php echo $counterparty_id; ?>';
    get_param.path_id = '<?echo $physical_path; ?>';
    get_param.contract_id = '<?echo $selected_contract_id; ?>';
    get_param.path_id_toggle = '<?echo $physical_path_toggle; ?>';
    get_param.call_from = '<?echo $call_from; ?>';
    get_param.parent_call_from = '<?echo $parent_call_from; ?>';
    get_param.primary_counterparty_id = '<?echo $primary_counterparty_id; ?>';


    get_param.flow_start = '<?php echo $flow_start; ?>';
    get_param.flow_end = '<?php echo $flow_start; ?>'; //keep only for 1 day for now
    get_param.rec_location_id = '<?php echo $receipt_loc_id; ?>';
    get_param.del_location_id = '<?php echo $delivery_loc_id; ?>';
    get_param.match_uom = '<?php echo $match_uom; ?>';
    get_param.total_receipt_vol = '<?php echo $total_receipt_vol; ?>';
    get_param.total_delivery_vol = '<?php echo $total_delivery_vol; ?>';
    get_param.process_id = '<?php echo $process_id; ?>';
    get_param.receipt_deals = '<?php echo $receipt_deals;?>';
    get_param.delivery_deals = '<?php echo $delivery_deals;?>';

    get_param.avail_vol = '<?php echo $avail_vol;?>';
    get_param.min_rec_or_del_vol = '<?php echo $min_rec_or_del_vol;?>';
    get_param.storage_type = '<?php echo $storage_type;?>';
    //get_param.storage_asset_id =98;
    get_param.storage_location_id ='<?php echo $storage_loc_id;?>'  ;
    get_param.loc_pipeline = '<?php echo $loc_pipeline;?>';
    get_param.pool_type ='<?php echo $pool_type;?>'  ;
    get_param.pool_location_id ='<?php echo $pool_loc_id;?>'  ;
    get_param.from_loc_name = '<?php echo $from_loc_name; ?>';
    get_param.to_loc_name = '<?php echo $to_loc_name; ?>';
    get_param.box_id = '<?php echo $box_id; ?>';
    get_param.granularity = '<?php echo $granularity; ?>';
    get_param.period_from = '<?php echo $period_from; ?>';
    //console.log(get_param.period_from);

    get_param.row_id = '';
    get_param.toggle = 0;
    var check_subgrid = new Array();

    if(parent.flow_optimization !== undefined) {
        IFRAME_FLOW_OPT_TEMPLATE = parent.flow_optimization.layout.cells('d').getFrame();
    } else {
        IFRAME_FLOW_OPT_TEMPLATE = '';
    }
    
    STORAGE_ASSET_INFO = JSON.parse('<?php echo json_encode($storage_asset_info_arr) ?>');
    SUBGRID_HEADER_DEFINITION = JSON.parse('<?php echo json_encode($subgrid_header_definition) ?>')[0];
    
    var rec_row_index = 1;
    var fuel_row_index = 2;
    var del_row_index = 3;

    var hourly_info_json_gbl = '';
    var APPLY_VALIDATION_MESSAGE = (get_param.parent_call_from == 'book_out' ? false : true);
	
	var ROUNDING_VALUE = 4;

    $(function() {
        date_obj = new Date();
        date_obj_tomorrow = new Date();
        date_obj_tomorrow.setDate(date_obj.getDate() + 1);
		
		sch.fx_attach_events(sch.hourly_sch_grid);
        
        sch.refresh_sch_grid();
		// sch.get_receive_delivery_vol();
    });
   
    /*
    * Function for grid other initialization.
    */
    sch.fx_grid_other_initialization = function(grid_obj) {

        var col_num = grid_obj.getColumnsNum();

        for(i = 3; i < col_num; i ++) {
            grid_obj.setNumberFormat('0,000.', i, '.', ',');
        }
    };

    /*
    Function to attach events on schedule grid
    */
    sch.fx_attach_events = function (grid_obj) {
        grid_obj.attachEvent('onEditCell', function(stage, rid, cid, n_val, o_val) {
        	if (stage == 2 && (grid_obj.getColumnId(cid) == 'path' || grid_obj.getColumnId(cid) == 'contract')) {
                if (isNaN(n_val) || n_val == '') {
                    return false;
                } else if (n_val != o_val) {
                    if (grid_obj.getColumnId(cid) == 'path') {
                        var grid_type = 'sch';//grid_obj.getUserData('', 'grid_type');
                        
                        var subgrid = grid_obj.cells(rid, grid_obj.getColIndexById('sub')).getSubGrid();
                        var fx_reload_grid = function() { 
                        	reload_subgrid(subgrid, rid);
                        }
                       	load_path_contract(rid, fx_reload_grid);
                    } else if (grid_obj.getColumnId(cid) == 'contract') {
                        var subgrid = grid_obj.cells(rid, grid_obj.getColIndexById('sub')).getSubGrid();
                        reload_subgrid(subgrid, rid);
                    }

                    return true;
                }
            } else {
                return true;
            }
        });

        grid_obj.attachEvent("onSubGridCreated", function(subgrid, rid, ind) {
        	create_sub_grid(subgrid, rid, grid_obj);
        });
    }
    
    function context_menu_match_click(menu_id, type) {
        rId = context_info.rId;
        cId = context_info.cId;
        subgrid = context_info.grid_obj;
		subgrid.editStop();
        col_value = subgrid.cells(rId, cId).getValue();

        col_num = subgrid.getColumnsNum();


        for(i = cId + 1; i < col_num; i++) {
            subgrid.cells(rId, i).setValue(col_value);
            fx_change_vol(rId, i, subgrid, col_value);
        }
    }
    /**
     * [load_path_contract description]
     *
     * @return  [type]  [return description]
     */
    function load_path_contract (rids, callback) { 
    	$.each(rids.split(','), function(rid) {
            var selected_path_id = sch.hourly_sch_grid.cells(rid,sch.hourly_sch_grid.getColIndexById('path')).getValue();
            var set_grid_value_contract = function () {
                var selected_contract = sch.hourly_sch_grid.getColumnCombo(sch.hourly_sch_grid.getColIndexById('contract')).getOptionByIndex(0).value;

                if(get_param.contract_id != '') {
                    selected_contract = get_param.contract_id;
                }

                sch.hourly_sch_grid.cells(rid,sch.hourly_sch_grid.getColIndexById('contract')).setValue(selected_contract);
                if(typeof callback === 'function') {
                    callback();
                }
            }
            sch.load_dropdown("EXEC spa_flow_optimization_hourly @flag='c1', @from_location='" + get_param.rec_location_id + "', @to_location='" + get_param.del_location_id + "', @process_id='" + get_param.process_id + "', @xml_manual_vol='" + (get_param.parent_call_from == 'book_out' ? '-1' : '') + "'", sch.hourly_sch_grid.getColIndexById('contract'), set_grid_value_contract, sch.hourly_sch_grid);

        });
    }

    /*
    Function for menu click on layout b
    */
    sch.menu_click = function(name, value) {

        if (name == 'refresh') {
            sch.refresh_sch_grid();
        } else if(name == 'save_schd') {
            sch.fx_save_schd();
        } else if(name == 'clear_adj') {
            var subgrid = sch.hourly_sch_grid.cells(sch.hourly_sch_grid.getRowId(0), sch.hourly_sch_grid.getColIndexById('sub')).getSubGrid();
            reload_subgrid(subgrid, sch.hourly_sch_grid.getRowId(0), 1);
            
        }
    }

    sch.fx_set_parent_box_values = function(call_from) {
        var subgrid = sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('sub')).getSubGrid();
        var path_id_selected = sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('path')).getValue();
        var contract_id_selected = sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('contract')).getValue();
        var total_rec = 0;
        var total_del = 0;
        var total_path_rmdq = 0;
        var first_hour_rec_vol = 0;
        var first_hour_del_vol = 0;
        subgrid.forEachCell(subgrid.getRowId(rec_row_index), function(cellObj, cid) {
            if (cid > 6) { //only for hour columns
                var rec_hrly = parseInt(cellObj.getValue() == '' ? 0 : cellObj.getValue()); 
                var del_hrly = parseInt(subgrid.cells2(del_row_index, cid).getValue() == '' ? 0 : subgrid.cells2(del_row_index, cid).getValue());

                if (cid == 7) {
                    first_hour_rec_vol = rec_hrly;
                    first_hour_del_vol = del_hrly;
                }

                total_rec += rec_hrly;
                total_del += del_hrly;
                total_path_rmdq += parseInt(subgrid.cells2(0, cid).getValue().split('/')[1]);
            }
        });

        var storage_asset_id = sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('storage_contract')).getValue();
        var storage_violate = '0';

        if (get_param.storage_type != '') {//avoid validation for non-storage case
            storage_violate = sch.fx_storage_validation(storage_asset_id, total_rec, total_del);

            if (IFRAME_FLOW_OPT_TEMPLATE != '') {
                $.each(IFRAME_FLOW_OPT_TEMPLATE.contentWindow.EXCEED_INFO_GBL, function(k, v) {
                    if(v.box_id == get_param.box_id) {
                        this.storage_violate = storage_violate;
                    }
                });
            }
        }
        
        if (IFRAME_FLOW_OPT_TEMPLATE != '') {

            var position_exceed = hourly_info_json_gbl.some(function(el,ind) {
                if(el.position_exceed_rec == '1' || el.position_exceed_del == '1') return true;
                else return false;
            }) ? '1' : '0';
            var pmdq_exceed = hourly_info_json_gbl.some(function(el,ind) {
                if(el.pmdq_exceed_rec == '1') return true;
                else return false;
            }) ? '1' : '0';

            var limit_exceeded = '0';
            if (position_exceed == '1' || pmdq_exceed == '1' || storage_violate != '0') {
                limit_exceeded = '1';
            }

            IFRAME_FLOW_OPT_TEMPLATE.contentWindow.set_box_value(get_param.box_id, total_rec, total_del, total_path_rmdq, path_id_selected, contract_id_selected, call_from, first_hour_rec_vol, first_hour_del_vol, limit_exceeded);

        }        
    }

    /**
     * Function to validate storage capacities
     */
    sch.fx_storage_validation = function(storage_asset_id, rec_value_new, del_value_new) {
        if(STORAGE_ASSET_INFO == 0) { //no storage asset information captured
            parent.success_call('Storage asset not defined.', 'error');
            return;
        }
        var storage_info_selected = STORAGE_ASSET_INFO.filter(function(val) {
            return (val.storage_asset_id == storage_asset_id);
        })[0];

        var vol_exceed = '0';
        if(get_param.storage_type == 'w') {
            var min_wid = storage_info_selected.min_wid;
            var max_wid = storage_info_selected.max_wid;
            var ratchet_vol = (storage_info_selected.ratchet_type == 'w' ? storage_info_selected.ratchet_fixed_value : 0);
            if(ratchet_vol == '' || ratchet_vol == undefined) {
                ratchet_vol = 0;
            }
            if(del_value_new < min_wid && min_wid != -1) {
                success_call('Minimum Withdrawal Capacity not reached.', 'error');
                vol_exceed = 'min_wid';
            }
            if(del_value_new > max_wid && max_wid != -1) {
                success_call('Maximum Withdrawal Capacity exceeded.', 'error');
                vol_exceed = 'max_wid';
            }
            if(del_value_new > ratchet_vol && ratchet_vol > 0) {
                success_call('Withdrawal Ratchet exceeded.', 'error');
                vol_exceed = 'wid_rat';
            } 
        } else if(get_param.storage_type == 'i') {
            var min_inj = storage_info_selected.min_inj;
            var max_inj = storage_info_selected.max_inj;
            var ratchet_vol = (storage_info_selected.ratchet_type == 'i' ? storage_info_selected.ratchet_fixed_value : 0);
            if(ratchet_vol == '' || ratchet_vol == undefined) {
                ratchet_vol = 0;
            }
            if(rec_value_new < min_inj && min_inj != -1) {
                success_call('Minimum Injection Capacity not reached.', 'error');
                vol_exceed = 'min_inj';
            }
            if(rec_value_new > max_inj && max_inj != -1) {
                success_call('Maximum Injection Capacity exceeded.', 'error');
                vol_exceed = 'max_inj';
            }
            if(del_value_new > ratchet_vol && ratchet_vol > 0) {
                success_call('Injection Ratchet exceeded.', 'error');
                vol_exceed = 'inj_rat';
            } 
        }
        return vol_exceed;
    };

    sch.fx_save_schd = function() {
        //console.log(hourly_info_json_gbl);return;
        var sub_book = sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('book')).getValue();

        if(get_param.call_from == 'flow_deal_match' && sub_book == '') {
            dhtmlx.message({
                title: 'Error',
                type: 'alert-error',
                text: 'Please select book to save schedule deal.'
            });
            return;
        }

        var xml_manual_vol = '<Root>';
        
        var subgrid = sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('sub')).getSubGrid();
        var path_id_selected = sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('path')).getValue();
        subgrid.editStop();
        subgrid.forEachCell(subgrid.getRowId(rec_row_index), function(cellObj, cid) { //loop for Rec row
            if(cid > 6) {//only for hour columns
				var hr = subgrid.getColumnId(cid).replace('hr','');
				var is_dst = 0;
				if (hr.indexOf('_DST') > 0) {
					hr = hr.replace('_DST', '');
					is_dst = 1;
				}					
                xml_manual_vol += '<PSRecordset from_loc_id="' + get_param.rec_location_id +
                    '" to_loc_id="' + get_param.del_location_id +
                    '" path_id="' + path_id_selected +
                    '" contract_id="' + sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('contract')).getValue() +
                    '" hour="' + hr +
					'" is_dst="' + is_dst +
                    '" received="' + cellObj.getValue() +
                    '" delivered="' + subgrid.cells2(del_row_index, cid).getValue() +
                    '" path_rmdq="' + subgrid.cells2(0, cid).getValue().split('/')[1] +
                    '" storage_asset_id="' + sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('storage_contract')).getValue() +
                    '"></PSRecordset>';
            }
        });
        xml_manual_vol += '</Root>';
		
		//console.log(xml_manual_vol);return;
        
        var sp_string = "EXEC spa_flow_optimization_hourly @flag='s2', @process_id='" + get_param.process_id + "', @xml_manual_vol='" + xml_manual_vol + "', @call_from='" + get_param.call_from + "'";
        post_data = { sp_string: sp_string };

        sch.fx_progress_load(1);
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                if(get_param.call_from == 'flow_optimization') {
                    parent.success_call('Changes saved.');
                    
                    //push volume exceed info, so that confirm message box can use this info on parent while saving schedule
                    if (IFRAME_FLOW_OPT_TEMPLATE != '') {
                        $.each(IFRAME_FLOW_OPT_TEMPLATE.contentWindow.EXCEED_INFO_GBL, function(k, v) {
                            if(v.box_id == get_param.box_id) {
                                this.position_exceed = (
                                    hourly_info_json_gbl.some(function(el,ind) {
                                        if(el.position_exceed_rec == '1' || el.position_exceed_del == '1') return true;
                                        else return false;
                                    }) ? '1' : '0'
                                );
                                this.pmdq_exceed = (
                                    hourly_info_json_gbl.some(function(el,ind) {
                                        if(el.pmdq_exceed_rec == '1') return true;
                                        else return false;
                                    }) ? '1' : '0'
                                );
                            }
                        });
                    }
                    
                    sch.fx_set_parent_box_values();
                    parent.flow_optimization.fx_close_window('window_hourly_schd');
                    sch.fx_progress_load(0);
                } else if(get_param.call_from == 'flow_deal_match') {
                    var return_data = JSON.parse(json_data.recommendation);
                    var param = {
                        box_id: return_data["box_id"]
                    };
                    var param_callback = function() {
                        sch.fx_progress_load(0);
                    };
                    sch.fx_save_schedule_deal(param, param_callback);
                } else {
                    sch.fx_progress_load(0);
                }
                
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_data.message
                });
                sch.fx_progress_load(0);
            }

        });
    }
    /**
     * Save schedule deal. This call is used when call from schedule deal, gas scheduling deal match. not from flow optimization, as flow optimization has its deal saving logic on its own page.
     * @param   {object}    param       - collection of param values. e.g. box_id
     * @param   {callback}  callback    - callback function to be called. 
     */
    sch.fx_save_schedule_deal = function(param, callback) {
        var sub_book = sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('book')).getValue();
        var sp_string = "EXEC spa_schedule_deal_flow_optimization @flag='i'" + 
            ", @box_ids='" + param.box_id + "'" + 
            ", @flow_date_from='" + get_param.flow_start + "'" + 
            ", @flow_date_to='" + get_param.flow_end + "'" + 
            ", @sub_book='" + sub_book + "'" + 
            ", @contract_process_id='" + get_param.process_id + "'" + 
            ", @call_from='flow_opt'" + 
            ", @granularity='" + get_param.granularity + "'"
            ;
        //console.log(sp_string);return;
        post_data = { sp_string: sp_string };

        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'][0];
            if(json_data.errorcode == 'Success') {
                parent.success_call(json_data.message);

                if(get_param.call_from == 'flow_deal_match') {
                    if(typeof parent.flow_match.fx_close_window === "function") {
                        parent.flow_match.fx_close_window('window_match');
                    }

                    if(typeof parent.refresh === "function") {
                        parent.refresh('refresh_all');
                    }
                }
                
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_data.message
                });
            }

            if(typeof callback === 'function') {
                callback();
            }
        });

        
    };
    /*
    Function to load progress On and Off
    */
    sch.fx_progress_load = function(on) {
    	if(on == 1) {
			sch.sch_layout.cells('a').progressOn();
    	} else {
    		sch.sch_layout.cells('a').progressOff();
    	}
    };
    /**
     * Function to load all combos on sch grid
     */
    sch.sch_load_all_grid_cmbo = function(grid_obj) {
        sch.fx_progress_load(1);

        var row_ids = grid_obj.getAllRowIds();
        var load_path_callback = function () {
            var fx_call_back = function() {
                sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('sub')).open();
            };
            load_path_contract(row_ids, fx_call_back);
            
        }
        sch.load_dropdown("EXEC spa_flow_optimization_hourly @flag='p1', @from_location='" + get_param.rec_location_id + "', @to_location='" + get_param.del_location_id + "', @process_id='" + get_param.process_id + "', @xml_manual_vol='" + (get_param.parent_call_from == 'book_out' ? '-1' : '') + "'", sch.hourly_sch_grid.getColIndexById('path'), load_path_callback, grid_obj);
        sch.load_dropdown("EXEC spa_get_source_book_map @flag='s',@function_id=10131000", sch.hourly_sch_grid.getColIndexById('book'), '', grid_obj);
        sch.load_dropdown("EXEC spa_virtual_storage @flag='c',@storage_location=" + (get_param.storage_location_id == '' ? 'NULL' : get_param.storage_location_id), sch.hourly_sch_grid.getColIndexById('storage_contract'), '', grid_obj);

    };

    /*
    Loads the dropdown values on grid cells
    */
    sch.load_dropdown = function(sql_stmt, column_index, callback_function, obj_grid) {
        var cm_param = {
            "action": "spa_generic_mapping_header",
            "flag": "n",
            "combo_sql_stmt": sql_stmt,
            "call_from": "grid"
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + "&" + cm_param;
        var combo_obj = obj_grid.getColumnCombo(column_index);
        combo_obj.enableFilteringMode("between", null, false)

        combo_obj.clearAll();
        
        combo_obj.load(url, function() {
        	if (callback_function != '') {
                callback_function();
           	}
        	obj_grid.refreshComboColumn(obj_grid.getColIndexById('path'));
        	obj_grid.refreshComboColumn(obj_grid.getColIndexById('contract'));
        	obj_grid.refreshComboColumn(obj_grid.getColIndexById('storage_contract'));
        });
    };
   
    /*
    Function to refresh sch grid
    */
    sch.refresh_sch_grid = function(call_from) {
        check_subgrid = [];
                
        var param = {
            "flag": "h1",
            "action":"spa_flow_optimization_hourly",
            "flow_date_from": get_param.flow_start,
            "flow_date_to": get_param.flow_end,
            "call_from": get_param.call_from,
            "process_id": get_param.process_id,
            "from_location": get_param.rec_location_id,
            "to_location": get_param.del_location_id,
            //"path_ids": get_param.path_id,
            "contract_id": get_param.contract_id,
            "xml_manual_vol": (get_param.parent_call_from == 'book_out' ? '-1' : '')
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;

        sch.fx_progress_load(1);
        sch.hourly_sch_grid.clearAndLoad(param_url, function(data) {
        	if(sch.hourly_sch_grid.getRowsNum() > 0) {
                sch.sch_load_all_grid_cmbo(sch.hourly_sch_grid);
                sch.hourly_sch_grid.forEachRow(function(rid) {
	                if(sch.hourly_sch_grid.cells(rid, sch.hourly_sch_grid.getColIndexById('new')).getValue() == 'n') {
	                    sch.hourly_sch_grid.setRowColor(rid, "#EBD3AA");
	                    var colNum = sch.hourly_sch_grid.getColumnsNum();
	                    for (i = 0; i < colNum; i++) {
	                        if (i != 0) {
	                            //sch.hourly_sch_grid.cells(rid,i).setDisabled(true);
	                            //sch.hourly_sch_grid.cells(rid,i).setTextColor('red');
	                        }
	                    }
	                }
	                //sch.subgrid(rid, '' ,sch.hourly_sch_grid);
	                
	            });
            }
		});

    };
	
	sch.fx_get_hourly_info_json = function(path_id, param_callback) {
		var param = {
						"flag": "VOL_LIMIT",
						"action": "spa_flow_optimization_hourly",
						"from_location": get_param.rec_location_id,
						"to_location": get_param.del_location_id,
                        "process_id": get_param.process_id,
                        "receipt_deals_id": get_param.receipt_deals,
                        "delivery_deals_id": get_param.delivery_deals,
                        "flow_date_from": get_param.flow_start,
                        "path_ids": path_id,
                        "xml_manual_vol": get_param.box_id
					};

		var fx_callback = function(result) {
            hourly_info_json_gbl = JSON.parse(result[0][0]); //console.log(hourly_info_json_gbl);
            if(typeof param_callback === "function") {
                param_callback();
            }
        };
		
		adiha_post_data('return_array', param, '', '', fx_callback, '');
	}

	
    function create_sub_grid(subgrid, rid, grid_obj) {
    		
        if (typeof subgrid !== 'undefined') {

            /*
            var term_start = grid_obj.cells(rid, grid_obj.getColIndexById('term_from')).getValue();
            var term_to = grid_obj.cells(rid, grid_obj.getColIndexById('term_to')).getValue();
            //alert(term_start);
            var header = 'Path Detail ID,Path ID,Path,Contract ID,Contract,Group Path ID,Volume';
            var column_ids = 'delivery_path_detail_id,path_id,path,contract_id,contract,group_path_id,volume';
            var col_types = 'ro,ro,ro,ro,ro,ro,ro';
            var width = '70,70,166,100,100,100,100';
            var col_sorting = 'int,int,str,int,str,int,int';

            var days = dates.diff_days(term_start,term_to);
			var hours = get_param.period_from.split(',');

            for(i = 0; i<hours.length ; i++) {
                var display_gas_hr = (parseInt(hours[i]) <= 18 ? parseInt(hours[i]) + 6 : parseInt(hours[i]) - 18);
                header += "," + ('0' + display_gas_hr + ':00').slice(-5);
                column_ids += ',' + 'hr'+ hours[i];
                col_types += ',ro';
                width += ',70';
                col_sorting += ',int';

            }
            */

            var ds_context_menu = new dhtmlXMenuObject({
                icons_path: js_image_path + 'dhxmenu_web/',
                context: true,
                items:[{id:"add",  text:"Apply To All"}]
            });
            ds_context_menu.attachEvent("onClick", context_menu_match_click);


            subgrid.setImagePath(js_php_path + "components/dhtmlxSuite/codebase/imgs/");
            subgrid.setHeader(SUBGRID_HEADER_DEFINITION.column_headers);
            subgrid.setColumnIds(SUBGRID_HEADER_DEFINITION.column_ids);
			subgrid.setColTypes(SUBGRID_HEADER_DEFINITION.column_types);
            subgrid.setInitWidths(SUBGRID_HEADER_DEFINITION.column_widths);
            subgrid.enableMultiselect(true);
            subgrid.enableColumnMove(true);
            subgrid.setColumnsVisibility("true,true,false,true,false,true");
            //enable auto width mode, set the maximal and minimal allowed width
            subgrid.enableAutoWidth(true,2600,100);
            subgrid.enableContextMenu(ds_context_menu);
			
			subgrid.init();
            subgrid.enableAutoHeight(true);
            subgrid.enableHeaderMenu();
			
            subgrid.attachEvent("onBeforeContextMenu", function(id, ind, obj){
                if(obj.getRowIndex(id) >= rec_row_index  && ind > 2) {
                    context_info.rId = id;
                    context_info.cId = ind;
                    context_info.grid_obj = obj;
                    return true;
                } else {
                    return false;
                }

            });

            subgrid.attachEvent("onEditCell",  function(stage,rId,cInd,nValue,oValue){
                if (stage == 2 && nValue != oValue) {
					if (isNaN(nValue)) {
						return false;
					}
					//setting number format of edited cell, according to rounding value after edit
					subgrid.cells(rId, cInd).setValue(roundTo(nValue, ROUNDING_VALUE).toFixed(ROUNDING_VALUE))
                    fx_change_vol(rId, cInd, subgrid, nValue);
                }
                return true;
            });
        }
        reload_subgrid(subgrid, rid);
    }

    function fx_change_vol(rId, cInd, subgrid, nValue) {
        if(nValue == '') {
            nValue = 0;
        }
		
		var hour = parseInt(subgrid.getColumnId(cInd).replace('hr', ''));
		var hourly_info = hourly_info_json_gbl.filter(function (entry) {
            return entry.hr == hour
        });
    	var loss = 0;
    	var path_mdq_display = subgrid.cells(0, cInd).getValue().split('/');
        if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Rec') {

            loss = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 1), cInd).getValue();
            var new_del_volume = parseFloat(nValue) * (1 - loss);
            new_del_volume = roundTo(new_del_volume, ROUNDING_VALUE).toFixed(ROUNDING_VALUE);
            subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 2), cInd).setValue(new_del_volume);

            var new_path_rmdq = parseFloat(hourly_info[0]['path_ormdq']) - parseFloat(new_del_volume);
            //path_mdq_display = path_mdq_display[0] + '/' + new_path_rmdq.toString();
            subgrid.cells(subgrid.getRowId(0), cInd).setValue(path_mdq_display[0] + '/' + new_path_rmdq.toString());
            
            if(APPLY_VALIDATION_MESSAGE) {
                //Check for path MDQ
                if(parseFloat(path_mdq_display[0]) < parseFloat(nValue)) {
                    success_call('Received Volume exceeded path MDQ.');				
                    subgrid.cells(subgrid.getRowId(0), cInd).setTextColor('red');
                } else {
                    subgrid.cells(subgrid.getRowId(0), cInd).setTextColor('black');
                }
                
                //Check for Supply Volume Limit
                if(parseFloat(hourly_info[0]['supply_position']) < parseFloat(nValue)) {
                    success_call('Received Volume exceeded supply.');
                    subgrid.cells(rId,cInd).setTextColor('red');
                } else {
                    subgrid.cells(rId,cInd).setTextColor('black');
                }  

                //Check for Demand Volume Limit
                if(parseFloat(hourly_info[0]['demand_position']) < parseFloat(new_del_volume) && get_param.storage_type != 'i') {
                    success_call('Delivery Volume exceeded demand.');
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 2), cInd).setTextColor('red');
                } else {
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 2), cInd).setTextColor('black');
                }

                //update json info for exceed info
                $.each(hourly_info_json_gbl, function(k, v) {
                    if(v.hr == hour) {
                        this.position_exceed_rec = (parseFloat(hourly_info[0]['supply_position']) < parseFloat(nValue) ? '1' : '0');
                        this.position_exceed_del = ((parseFloat(hourly_info[0]['demand_position']) < parseFloat(new_del_volume) && get_param.storage_type != 'i') ? '1' : '0');
                        this.pmdq_exceed_rec = (parseFloat(path_mdq_display[0]) < parseFloat(nValue) ? '1' : '0');
                    }
                });
            }
        } else if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Fuel') {
            loss = nValue;
            var new_del_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -1), cInd).getValue() * (1 - loss);
            new_del_volume = roundTo(new_del_volume, ROUNDING_VALUE).toFixed(ROUNDING_VALUE);
			subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 1), cInd).setValue(new_del_volume);
            
            if(APPLY_VALIDATION_MESSAGE) {
                //Check for Demand Volume Limit
                if(parseFloat(hourly_info[0]['demand_position']) < parseFloat(new_del_volume) && get_param.storage_type != 'i') {
                    success_call('Delivery Volume exceeded demand.');
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 1), cInd).setTextColor('red');
                } else {
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 1), cInd).setTextColor('black');
                }

                //update json info for exceed info
                $.each(hourly_info_json_gbl, function(k, v) {
                    if(v.hr == hour) {
                        this.position_exceed_del = ((parseFloat(hourly_info[0]['demand_position']) < parseFloat(new_del_volume) && get_param.storage_type != 'i') ? '1' : '0');
                    }
                });
            }

        } else if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Del') {
            loss = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) - 1), cInd).getValue();
            var new_rec_volume = parseFloat(nValue) / (1 - loss);
            new_rec_volume = roundTo(new_rec_volume, ROUNDING_VALUE).toFixed(ROUNDING_VALUE);
           	subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) - 2), cInd).setValue(new_rec_volume);

           	var new_path_rmdq = parseFloat(hourly_info[0]['path_ormdq']) - nValue;
            //path_mdq_display = path_mdq_display[0] + '/' + new_path_rmdq.toString();
            subgrid.cells(subgrid.getRowId(0), cInd).setValue(path_mdq_display[0] + '/' + new_path_rmdq.toString());
            
            if(APPLY_VALIDATION_MESSAGE) {
                //Check for path MDQ
                if(parseFloat(path_mdq_display[0]) < new_rec_volume) {
                    success_call('Received Volume exceeded path MDQ.');
                    subgrid.cells(subgrid.getRowIndex(0),cInd).setTextColor('red');
                } else {
                    subgrid.cells(subgrid.getRowIndex(0),cInd).setTextColor('black');
                }
                
                //Check for Supply Volume Limit
                if(parseFloat(hourly_info[0]['supply_position']) < parseFloat(new_rec_volume)) {
                    success_call('Received Volume exceeded supply.');
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) - 2), cInd).setTextColor('red');
                } else {
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) - 2), cInd).setTextColor('black');
                }  
                
                //Check for Demand Volume Limit
                if(parseFloat(hourly_info[0]['demand_position']) < parseFloat(nValue) && get_param.storage_type != 'i') {
                    success_call('Delivery Volume exceeded demand.');
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId)), cInd).setTextColor('red');
                } else {
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId)), cInd).setTextColor('black');
                }

                //update json info for exceed info
                $.each(hourly_info_json_gbl, function(k, v) {
                    if(v.hr == hour) {
                        this.position_exceed_rec = (parseFloat(hourly_info[0]['supply_position']) < parseFloat(new_rec_volume) ? '1' : '0');
                        this.position_exceed_del = ((parseFloat(hourly_info[0]['demand_position']) < parseFloat(nValue) && get_param.storage_type != 'i') ? '1' : '0');
                        this.pmdq_exceed_rec = (parseFloat(path_mdq_display[0]) < new_rec_volume ? '1' : '0');
                    }
                });
            }
        }
    }

    function reload_subgrid(subgrid, rid, clear_adj) {
    	var path_id = sch.hourly_sch_grid.cells(rid, sch.hourly_sch_grid.getColIndexById('path')).getValue();
        var term_start = sch.hourly_sch_grid.cells(rid, sch.hourly_sch_grid.getColIndexById('term_from')).getValue();
        var term_end = sch.hourly_sch_grid.cells(rid, sch.hourly_sch_grid.getColIndexById('term_to')).getValue();
        var contract = sch.hourly_sch_grid.cells(rid, sch.hourly_sch_grid.getColIndexById('contract')).getValue();
        
		if (sch.hourly_sch_grid.cells(rid, sch.hourly_sch_grid.getColIndexById('new')).getValue() == 'y') {
            data = {
                "flag": "s1",
                "action": "spa_flow_optimization_hourly",
                "process_id": get_param.process_id,
                "delivery_path": path_id,
                "contract_id": contract,
                "flow_date_from": term_start,
                "granularity": get_param.granularity,
                "period_from": get_param.period_from,
                "call_from": ((clear_adj == 1) ? 'clear_adj' : ''),
                "receipt_deals_id": get_param.receipt_deals,
                "delivery_deals_id": get_param.delivery_deals,
                "from_location": get_param.rec_location_id,
                "to_location": get_param.del_location_id,
                "xml_manual_vol": (get_param.parent_call_from == 'book_out' ? '-1' : ''),
				"round": ROUNDING_VALUE,
                "dst_case": SUBGRID_HEADER_DEFINITION.dst_case
            };
        } else {
            data = {
                "flag": "m",
                "action": "spa_get_loss_factor_volume",
                "path": path_id,
                "term_start": term_start,
                "term_end" : term_end,
                "receipt_deal_ids": '',
                "delivery_deal_ids":''

            };
        }

        header_param = $.param(data);
        var header_url = js_data_collector_url + "&" + header_param;
        check_subgrid[rid] = true;
        
        if (typeof subgrid !== 'undefined') {
            sch.fx_progress_load(1);
            subgrid.clearAndLoad(header_url, function(data) {

                var fx_callback = function() {
                    subgrid.forEachCell(rec_row_index, function(cellObj, ind) {
                        if (ind > 6) {
                            subgrid.callEvent("onEditCell", [2, rec_row_index, ind, cellObj.getValue(), 0]);
                        }
                    });
                };
                
                sch.fx_get_hourly_info_json(path_id, fx_callback);
				
                // disable and set blank for contract column on parent grid in case of group path, since group paths have single paths and contract is associated with each single path
                if (subgrid.cells2(0, subgrid.getColIndexById('group_path_id')).getValue() == '') {
                    sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('contract')).setDisabled(false);
                } else {
                    sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('contract')).setDisabled(true);
                    sch.hourly_sch_grid.cells2(0, sch.hourly_sch_grid.getColIndexById('contract')).setValue('');
                }
                sch.fx_disable_grid_cells(subgrid);
            	if (clear_adj == 1) {
                    sch.fx_set_parent_box_values('clear_adj');
                }
                sch.fx_progress_load(0);
            });
        }
        return;
    }

    sch.fx_disable_grid_cells = function(subgrid) {
        var col_index_volume = subgrid.getColIndexById('volume');
        var total_column_count = subgrid.getColumnsNum();
        var total_row_count = subgrid.getRowsNum();

        var fxi_set_cell_type = function(rid) {
            for (i = col_index_volume + 1; i < total_column_count; i++) {
                subgrid.setCellExcellType(rid, i, "ed");
            }
        }

        if (total_row_count == 4) { //for single path case
            fxi_set_cell_type(rec_row_index);
            fxi_set_cell_type(del_row_index);
        } else if (total_row_count > 4) { //for group path case
            subgrid.forEachRow(function(rid) {
                var volume_col = subgrid.cells(rid, subgrid.getColIndexById('volume')).getValue();
                if (volume_col == 'Fuel') {
                    fxi_set_cell_type(rid);
                } else if (volume_col == 'Rec' && subgrid.getRowIndex(rid) == 2) {
                    fxi_set_cell_type(rid);
                } else if (volume_col == 'Del' && subgrid.getRowIndex(rid) == total_row_count - 1) {
                    fxi_set_cell_type(rid);
                }
            });
        }
    }
   
    function fx_open_delivery_path_window(from_loc_id, to_loc_id, from_loc_name, to_loc_name,popup_call_from) {
        var args = '?call_from=flow_optimization_match&mode=i&from_loc_id=' + from_loc_id + '&to_loc_id=' + to_loc_id + '&from_loc=' + from_loc_name + '&to_loc=' + to_loc_name;
        var param = "../Setup_Delivery_Path/Setup.Delivery.Path.php" + args

        var win = new dhtmlXWindows();
        setup_delivery_path_win = win.createWindow("windowSetupDeliveryPath", 0, 0, 400, 400);
        setup_delivery_path_win.setText("Setup Delivery Path");
        setup_delivery_path_win.setModal(true);
        setup_delivery_path_win.maximize();
        setup_delivery_path_win.attachURL(param, false, true);
    }

    function SetupDeliveryPath_SaveCallback(id) {
        get_param.path_id_toggle = id;
        sch.toggle_click(0);
    };

    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
</script>
