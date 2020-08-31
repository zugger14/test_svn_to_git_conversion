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
//print_r($_GET);
$php_script_loc = $app_php_script_loc;
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
$volume = isset($_GET['volume']) ? $_GET['volume'] : '';
$rad_value = ($volume > 0) ? 'd' : 'r';
$location_id = get_sanitized_value($_GET['location_id'] ?? '');
$term = get_sanitized_value($_GET['term'] ?? '');
$term_end = get_sanitized_value($_GET['term_end'] ?? '');
$counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
$primary_counterparty_id = get_sanitized_value($_GET['primary_counterparty_id'] ?? 'NULL');
$source_deal_header_id = get_sanitized_value($_GET['source_deal_header_id'] ?? 'NULL');
$source_deal_detail_id =  get_sanitized_value($_GET['source_deal_detail_id'] ?? ''); 
$deal_id = get_sanitized_value($_GET['deal_id'] ?? '');
//$call_from = isset($_GET['group_by']) ? $_GET['group_by'] : 'Deal_Detail';
$call_from = get_sanitized_value($_GET['call_from'] ?? 'Deal_Detail');
$book_deal_type_map_id = get_sanitized_value($_GET['book_deal_type_map_id'] ?? '');
$option_radio_label_array = array('Deliver', 'Receive');
$option_radio_value_array = array('d', 'r');
$available_volume = 0;

$flow_start = get_sanitized_value($_GET['flow_start'] ?? '');
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

$visibility_storage_contract = 'false';

//$visibility_storage_contract = 'true';

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

$receipt_loc_id = $receipt_loc_id == ''?'NULL': $receipt_loc_id;
$delivery_loc_id = $delivery_loc_id == ''?'NULL': $delivery_loc_id;


if (($counterparty_id == 0 || $counterparty_id == '') && $source_deal_detail_id != 'NULL') {
    $xml_file = "EXEC spa_getsourcecounterparty @flag='a', @source_system_id=$source_deal_detail_id";
    $return_value = readXMLURL($xml_file);
    $counterparty_id = $return_value[0][0];
}


$rad_value = 'd';
$xml_file = "EXEC spa_get_loss_factor_volume @path=null, @flag='t', @source_deal_header_id=$source_deal_header_id, @source_deal_detail_id=$source_deal_detail_id";

//print_r($xml_file);exit();
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

$volume = $available_volume;       //not in use
$xml_file = "EXEC spa_delivery_path @flag='s', @from_location=$receipt_loc_id, @to_location=$delivery_loc_id, @call_from='$call_from', @from_source_deal_header_id=$source_deal_header_id";

/*if ($rad_value == 'd') {
    $xml_file = "EXEC spa_delivery_path @flag='s', @from_location=$receipt_loc_id, @to_location=$delivery_loc_id";
} else if ($rad_value == 'r') {
    $xml_file = "EXEC spa_delivery_path @flag=s, @to_location=$receipt_loc_id";
}*/
//echo $xml_file;exit();
$return_value_path = readXMLURL($xml_file);
$physical_path = isset($return_value_path[0][0]) ? $return_value_path[0][0] : 'NULL';

$from_storage = $return_value_path[0][14];
$to_storage = $return_value_path[0][15];


if ($from_storage == 'Yes') {
	$storage_type = 'i';
	$storage_loc_id = $return_value[0][12];
}
if ($to_storage == 'Yes') {
	$storage_type = 'w';
	$storage_loc_id = $return_value[0][13];
}

if ($storage_type != '') {
    $visibility_storage_contract = 'true';
}

$xml_file = "EXEC spa_delivery_path @flag='s', @from_location=$delivery_loc_id, @to_location=$receipt_loc_id, @call_from='$call_from', @from_source_deal_header_id=$source_deal_header_id";
$return_value = readXMLURL($xml_file);
$physical_path_toggle = isset($return_value[0][0]) ? $return_value[0][0] : '';

if (isset($return_value[0][2]) && ($call_from == 'opt_book_out' || $call_from == 'opt_book_out_b2b')) {
    $loc_pipeline = $return_value[0][2];
} else {
    $loc_pipeline = '';
}

//echo $physical_path;exit();
if ($call_from == 'NULL' || $call_from == 'null' || $call_from == '') $call_from = 'Deal';
$form_namespace = 'sch';
$json = "[
                {
                    id:         'a',
                    text:       'Filters',
                    header:     true,
                    collapse:   false,
                    height:     150
                },
                {
                    id:         'b',
                    text:       'Schedules',
                    header:     true,
                    collapse:   false,
                    height:     600,
                    width:      1500
                }

            ]";



$sch_obj = new AdihaLayout();
echo $sch_obj->init_layout('sch_layout', '', '2E', $json, $form_namespace);

$xml_file = "EXEC spa_create_application_ui_json @flag='j'
                                                    , @application_function_id='$form_function_id'
                                                    , @template_name='flow_match' 
                                                    ";
$return_value1 = readXMLURL2($xml_file);
$form_json = $return_value1[0]['form_json'];
$tab_id = $return_value1[0]['tab_id'];

echo $sch_obj->attach_form('sch_form', 'a');
$sch_form = new AdihaForm();
echo $sch_form->init_by_attach('sch_form', $form_namespace);
echo $sch_form->load_form($form_json);

$menu_json = '[
            {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif", enabled: true},
            {id: "menu_action", text: "Action", img: "action.gif", img_disabled: "action_dis.gif", enabled: true,
            items: [
                {id: "insert_deal_sch", text: "Add Row", img: "add.gif", img_disabled: "add_dis.gif", enabled: ' . (int) $has_right_sch_file_create_add . '},
                {id: "delete_grid_row", text: "Delete Row", img: "delete.gif", img_disabled: "delete_dis.gif", enabled: 0},
                {id: "delete_deal_sch", text: "Delete Schedule", img: "delete.gif", img_disabled: "delete_dis.gif", enabled: 0}
            ]},
            {id: "process_deal_sch", text: "Save Schedule", img: "run_view_schedule.gif", img_disabled: "run_view_schedule_dis.gif", enabled: 1},
            {id: "process_deal_resch", text: "View Nomination", img: "run_view_schedule.gif", img_disabled: "run_view_schedule_dis.gif", enabled: 0},
            {id:"html", text:"Export", img:"export.gif", imgdis:"export_dis.gif", title: "Export"},
            {id:"toggle", text:"Rec/Del Toggle", img:"export.gif", imgdis:"export_dis.gif", title: "Toggle"}
        ]';
echo $sch_obj->attach_menu_layout_cell('sch_menu', 'b', $menu_json, $form_namespace.'.menu_click');

//attach sch grid
$sch_grid_name = 'sch_grid';
echo $sch_obj->attach_grid_cell($sch_grid_name, 'b');
$sch_grid_obj = new AdihaGrid();
//echo $sch_obj->attach_status_bar("b", true);
echo $sch_grid_obj->init_by_attach($sch_grid_name, $form_namespace);

$column_text = "&nbsp;,Path,Contract,Storage Contract,MDQ/RMDQ,Book,Term From,Term To,New";
$column_id = "sub,path,contract,storage_contract,mdq_rmdq,book,term_from,term_to,new";
$column_width = "40,170,*,*,*,*,*,*,*";
$column_type = "sub_row_grid,combo,combo,combo,ro,combo,dhxCalendarA,dhxCalendarA,ro";
$column_visbility = "false,false,false,$visibility_storage_contract,false,false,false,false,true";

echo $sch_grid_obj->set_header($column_text);
echo $sch_grid_obj->set_columns_ids($column_id);
echo $sch_grid_obj->set_widths($column_width);
echo $sch_grid_obj->set_column_types($column_type);
echo $sch_grid_obj->set_column_visibility($column_visbility);
//echo $sch_grid_obj->set_search_filter(false, '#daterange_filter,#text_filter,#text_filter, , ,#text_filter, ');
echo $sch_grid_obj->set_date_format($date_format, "%Y-%m-%d");
echo $sch_grid_obj->return_init();
echo $sch_grid_obj->enable_header_menu();
echo $sch_grid_obj->attach_event('', 'onRowSelect', 'sch.schedule_select');


echo $sch_obj->close_layout();


?>

</body>

<script>
    dhx_wins = new dhtmlXWindows();


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
    var php_script_loc = '<?php echo $php_script_loc; ?>';

	var path_detail = <?php echo json_encode($return_value_path );?>; 

    get_param.term_start = '<?php echo $entire_term_start; ?>';
    get_param.term_end = '<?php echo $entire_term_end; ?>';
    get_param.deal_id = '<?php echo $source_deal_header_id; ?>';
    get_param.deal_detail_id = '<?php echo $source_deal_detail_id; ?>';
    get_param.deal_ref_id = '<?php echo $deal_id; ?>';
    get_param.location_id = '<?php echo $location_id; ?>';
    get_param.counterparty = '<?php echo $counterparty_id; ?>';
    get_param.trader_id = '<?php echo $trader_id; ?>';
    get_param.uom = '<?php echo $uom; ?>';
    get_param.total_volume = '<?php echo $total_volume; ?>';
    get_param.path_id = '<?echo $physical_path; ?>';
    get_param.path_id_toggle = '<?echo $physical_path_toggle; ?>';
    get_param.call_from = '<?echo $call_from; ?>';
    get_param.primary_counterparty_id = '<?echo $primary_counterparty_id; ?>';


    get_param.flow_start = '<?php echo $flow_start; ?>';
    get_param.flow_end = '<?php echo $flow_end; ?>';
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

    get_param.row_id = '';
    get_param.toggle = 0;

    grid_creation_status = {};
    grid_creation_status.status = 0;

    var check_subgrid = new Array();

    $(function() {
        date_obj = new Date();
        date_obj_tomorrow = new Date();
        date_obj_tomorrow.setDate(date_obj.getDate() + 1);

        attach_browse_event('sch.sch_form');
        //sch.fx_grid_other_initialization(sch.sch_grid);
        //sch.fx_grid_other_initialization(sch.resch_grid);
        sch.fx_attach_events(sch.sch_grid);
        //sch.fx_attach_events(sch.resch_grid);

        attach_form_event();
        sch.fx_initial_load();

        sch.refresh_sch_grid();

    });

    function attach_form_event() {

        sch.sch_form.attachEvent('onChange', function(name, value) {
            if (name == 'vol_per') {
                change_vol_per(value);
            }
        });
    }

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
    * Function to load initial values to form fields.
    */
    sch.fx_initial_load = function() {

        sch.sch_form.setItemValue('flow_start', get_param.flow_start);
        sch.sch_form.setItemValue('flow_end', get_param.flow_end);
        sch.sch_form.setItemValue('rec_location', get_param.rec_location_id);
        sch.sch_form.setItemValue('del_location', get_param.del_location_id);
        sch.sch_form.setItemValue('rec_volume', get_param.total_receipt_vol);
        sch.sch_form.setItemValue('del_volume', get_param.total_delivery_vol);
        sch.sch_form.setItemValue('uom', get_param.match_uom);
        sch.sch_load_all_grid_cmbo(sch.sch_grid);

    }
    /*
    Function to attach events on schedule grid
    */
    sch.fx_attach_events = function (grid_obj) {
        sch.sch_grid.attachEvent('onRowSelect', function (rid, ind) {

            grid_creation_status.status = 0;

            /* if (sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('path')).getValue() != '') {
                // sch.refresh_resch_grid(rid, true);
                 sch.sch_menu.setItemDisabled('process_deal_sch');
                 sch.sch_menu.setItemEnabled('delete_deal_sch');
                 sch.sch_menu.setItemDisabled('delete_grid_row');

             } else {
                 //sch.refresh_resch_grid(rid);
                 sch.sch_menu.setItemEnabled('process_deal_sch');
                 sch.sch_menu.setItemDisabled('delete_deal_sch');
                 sch.sch_menu.setItemEnabled('delete_grid_row');

             }*/
        });

        grid_obj.attachEvent('onEditCell', function(stage, rid, cid, n_val, o_val) {

            if(grid_obj.getColumnId(cid) == 'term_to') {
                if (stage == 2) {
                    var path_id = grid_obj.cells(rid, grid_obj.getColIndexById('path')).getValue()
                    var contract = grid_obj.cells(rid, grid_obj.getColIndexById('contract')).getValue()
                    var term_start = grid_obj.cells(rid, grid_obj.getColIndexById('term_from')).getValue()
                    var subgrid = grid_obj.cells(rid, grid_obj.getColIndexById('sub')).getSubGrid();
                    //alert('1');
                    reload_subgrid(subgrid, rid);
                    //create_sub_grid(subgrid, false, rid, '', sch.sch_grid, '');
                }

                return true;
            } else if (grid_obj.getColumnId(cid) == 'term_from' ) {
                if (stage == 2) {

                    var path_id = grid_obj.cells(rid, grid_obj.getColIndexById('path')).getValue()
                    var contract = grid_obj.cells(rid, grid_obj.getColIndexById('contract')).getValue()
                    var term_start = grid_obj.cells(rid, grid_obj.getColIndexById('term_from')).getValue()

                    load_dependent_values(grid_obj, rid, path_id, contract, term_start)
                }

                return true;
            } else if (stage == 2 ) {
                if (isNaN(n_val) || n_val == '') {
                    return false;
                } else if (n_val != o_val) {
                    /*if (grid_obj.getColumnId(cid) == 'Scheduled Volume') {
                        var calc_val = n_val * (1 - grid_obj.cells(rid, grid_obj.getColIndexById('Shrinkage')).getValue());
                        grid_obj.cells(rid, grid_obj.getColIndexById('Delivered Volume')).setValue(calc_val);

                        sch.change_group_path_volume(grid_obj, rid, n_val);

                    } else if (grid_obj.getColumnId(cid) == 'Shrinkage') {
                        var schedule_volume = grid_obj.cells(rid, grid_obj.getColIndexById('Scheduled Volume')).getValue()
                        var calc_val = schedule_volume * (1 - n_val);
                        grid_obj.cells(rid, grid_obj.getColIndexById('Delivered Volume')).setValue(calc_val);

                    } */



                    if (grid_obj.getColumnId(cid) == 'path') {
                        var grid_type = 'sch';//grid_obj.getUserData('', 'grid_type');
                        /*var call_back_fx = 'sch.change_path_event_sch' ;
                        var param = {
                            "action": 'spa_get_loss_factor_volume',
                            "flag": 'l',
                            "term_start": grid_obj.cells(rid, grid_obj.getColIndexById('term_from')).getValue(),
                            "path": n_val

                        };
                        adiha_post_data('return_json', param, '', '', call_back_fx); */                  				
						load_path_contract(sch.sch_grid,rid, n_val);
						load_storage_contract(sch.sch_grid,rid, n_val)

                        check_subgrid[rid] = true;
                        if (grid_type == 'sch')
                            sch.subgrid(rid, '', grid_obj, 's');
                        else
                            sch.subgrid(rid, '', grid_obj, 'r');

                    }
                    if (grid_obj.getColumnId(cid) == 'contract') {
                        var subgrid = grid_obj.cells(rid, grid_obj.getColIndexById('sub')).getSubGrid();
                        // alert('2');
                        reload_subgrid(subgrid, rid);
                    }

                    return true;
                }
            }
        });

        grid_obj.attachEvent("onCellChanged", function(stage, rid, cid, n_val, o_val){
            if (grid_obj.getColumnId(cid) == 'path' && is_add_clicked) {
                // sch.subgrid();
            }
        });


        grid_obj.attachEvent('onXLE', function (grid_obj,count) {

            if(get_param.call_from != 'opt_book_out' && get_param.call_from != 'opt_book_out_b2b') {
                grid_obj.forEachRow(function(id){
                    load_path_contract(sch.sch_grid, id, sch.sch_grid.cells(id, sch.sch_grid.getColIndexById('path')).getValue());
                });
            }

            row_num = sch.sch_grid.getRowsNum();
            if (sch.sch_grid.getRowsNum() == 0) {
                sch.refresh_sch_grid('insert_row');
            }
        });



    }

    function context_menu_match_click(menu_id, type) {
        rId = context_info.rId;
        cId = context_info.cId;
        subgrid = context_info.grid_obj;
        col_value = subgrid.cells(rId, cId).getValue();

        col_num = subgrid.getColumnsNum();


        for(i = cId + 1; i < col_num; i++) {
            subgrid.cells(rId, i).setValue(col_value);
            change_vol(rId, i, subgrid);
        }
    }

    sch.change_group_path_volume = function(grid_obj, rid, schedule_volume) {

        var sub_grid = grid_obj.cells(rid, grid_obj.getColIndexById('sub')).getSubGrid();

        if (sub_grid != 'null') {
            if (sub_grid.getRowsNum() != 0) {
                sub_grid.forEachRow(function(rid) {
                    var new_sch_vol;
                    if (rid == 0) {
                        new_sch_vol = schedule_volume;
                        sub_grid.cells(rid, sub_grid.getColIndexById('scheduled_volume')).setValue(new_sch_vol);

                    } else {
                        new_sch_vol = sub_grid.cells(rid - 1, sub_grid.getColIndexById('delivered_volume')).getValue();
                        sub_grid.cells(rid, sub_grid.getColIndexById('scheduled_volume')).setValue(new_sch_vol);

                    }

                    var calc_val = parseInt(new_sch_vol * (1 - sub_grid.cells(rid, sub_grid.getColIndexById('shrinkage')).getValue()));
                    sub_grid.cells(rid, sub_grid.getColIndexById('delivered_volume')).setValue(calc_val);

                    //scheduled_volume,shrinkage,delivered_volume,

                });
            }
        }


        // ;
    }


    /*
    Function to set loss factor when path dd is changed on sch grid
    */
    sch.change_path_event_sch = function(result) {
        var json_obj = $.parseJSON(result);
        console.dir(json_obj);
        sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Shrinkage')).setValue(json_obj[0].loss_factor);

        var calc_val = sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Scheduled Volume')).getValue() * (1 - json_obj[0].loss_factor);
        sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Delivered Volume')).setValue(calc_val);
        sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Contract')).setValue(json_obj[0].contract);
        //  sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Location From')).setValue(json_obj[0].from_location);
        sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Location To')).setValue(json_obj[0].to_location);


    };

    function load_path_contract(grid_obj, rid, path_id) { //alert('aaaaa');
        var cm_param = {"action": "spa_counterparty_contract_rate_schedule", "flag": "p", "path_id": path_id,"has_blank_option" : "n"};
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + "&" + cm_param;

        var contract_combo = grid_obj.cells(rid, sch.sch_grid.getColIndexById('contract')).getCellCombo();
        contract_combo.clearAll();
        contract_combo.load(url, function(){
            if(contract_combo.getOptionByIndex(0) !== null) {
                //alert(contract_combo.getOptionByIndex(0).value)

                grid_obj.cells(rid, sch.sch_grid.getColIndexById('contract')).setValue(contract_combo.getOptionByIndex(0).value);
                get_param.row_id = rid;

                load_dependent_values(grid_obj, rid, path_id, contract_combo.getOptionByIndex(0).value, grid_obj.cells(rid, sch.sch_grid.getColIndexById('term_from')).getValue());
            } else {
                grid_obj.cells(rid, sch.sch_grid.getColIndexById('contract')).setValue('');
                grid_obj.cells(rid, sch.sch_grid.getColIndexById('mdq_rmdq')).setValue('');
            }
        });
    }
	
	function load_storage_contract(grid_obj, rid, path_id) {
		
		var selected_path = path_detail.filter(function (e) {
		  return e[0] == path_id;
		});
		
		if (path_id == -1 ) {
			
			selected_path[0] = path_detail[0]
		}
		
		
		
		console.log(selected_path);
		get_param.storage_location_id = '';
		
		//alert(selected_path[0][14] + ' ' + selected_path[0][15])
	
		if (selected_path[0][14] == 'Yes'){
			get_param.storage_type = 'w'
			get_param.storage_location_id = selected_path[0][12];
			
			
		}
		if (selected_path[0][15] == 'Yes'){			
			get_param.storage_type = 'i'
			get_param.storage_location_id = selected_path[0][13];
		}
		
		var cm_param = {"action": "spa_virtual_storage", "flag": "c", "storage_location": get_param.storage_location_id};
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + "&" + cm_param;

        var storage_contract_combo = grid_obj.cells(rid, sch.sch_grid.getColIndexById('storage_contract')).getCellCombo();
		
		if (selected_path[0][14] == 'No' && selected_path[0][15] == 'No') {			
			grid_obj.setColumnHidden(sch.sch_grid.getColIndexById('storage_contract'),true);
		} else{
			grid_obj.setColumnHidden(sch.sch_grid.getColIndexById('storage_contract'),false);
		}
		
		storage_contract_combo.clearAll();
		console.log(url);
        storage_contract_combo.load(url);
      
		
    }
	
	
    function load_dependent_values(grid_obj, rid, path_id, contract, term_start) {
        var param = {
            "action": 'spa_get_loss_factor_volume',
            "flag": 'e',
            "path": path_id,
            "contract" : contract,
            'term_start': term_start
        };

        //alert(path_id + '  ' + contract + ' ' + term_start);
        var callback_function = '';
        if (sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('new')).getValue() == 'y') {
            callback_function = 'load_dependent_values_cb';
        }

        adiha_post_data('return_array', param, '', '', callback_function);
    }

    function load_dependent_values_cb (result) {


        sch.sch_grid.cells(get_param.row_id, sch.sch_grid.getColIndexById('mdq_rmdq')).setValue(result[0][0]);

        var subgrid = sch.sch_grid.cells(get_param.row_id, sch.sch_grid.getColIndexById('sub')).getSubGrid();
//alert(3);
        reload_subgrid(subgrid, get_param.row_id);

        //create_sub_grid(subgrid, false, get_param.row_id, '', sch.sch_grid, '');
    }

    /*
    Function to set loss factor when path dd is changed on resch grid
    */
    sch.change_path_event_resch = function(result) {
        var json_obj = $.parseJSON(result);
        sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('Shrinkage')).setValue(json_obj[0].loss_factor);
        sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('path_id')).setValue('');

        var calc_val = sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('Scheduled Volume')).getValue() * (1 - json_obj[0].loss_factor);
        sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('Delivered Volume')).setValue(calc_val);
        sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('Contract')).setValue(json_obj[0].contract);
    };
    /*
    Function for menu click on layout b
    */
    sch.menu_click = function(name, value) {

        if (name == 'refresh') {
            sch.refresh_sch_grid();
        } else if(name == 'insert_deal_sch') {
            sch.refresh_sch_grid('insert_row');
        } else if (name == 'delete_grid_row') {
            sch.menu_delete_grid_row();
        } else if (name == 'delete_deal_sch') {
            sch.menu_delete_schedule();
        } else if (name == 'process_deal_sch') {
            sch.menu_process_deal_sch(0);
        } else if (name == 'process_deal_resch') {
            sch.menu_process_deal_resch(0);
        } else if (name == 'html') {
            sch.html_view();
        } else if (name == 'toggle') {
            var toggle_status = get_param.toggle;
            sch.toggle_click(toggle_status);
        }

    }


    /**
     * Function to load all combos on sch grid
     */
    sch.sch_load_all_grid_cmbo = function(grid_obj) {
        sch.sch_layout.cells('b').progressOn();
        if(get_param.call_from == 'opt_book_out' || get_param.call_from == 'opt_book_out_b2b') {
            sch.load_dropdown("select -1 [Path ID], 'Back to Back Path' [Path Code]", sch.sch_grid.getColIndexById('path'), '', grid_obj);
            sch.load_dropdown("EXEC spa_contract_group @flag='j',@pipeline=" + get_param.loc_pipeline, sch.sch_grid.getColIndexById('contract'), '', grid_obj);
        } else {
            sch.load_dropdown("EXEC spa_delivery_path @flag='x', @from_location=" + get_param.rec_location_id + ", @to_location=" + get_param.del_location_id + ", @from_source_deal_header_id=" + get_param.deal_id , sch.sch_grid.getColIndexById('path'), '', grid_obj);
            sch.load_dropdown("EXEC spa_contract_group @flag='j'", sch.sch_grid.getColIndexById('contract'), '', grid_obj);
        }


        sch.load_dropdown("EXEC spa_get_source_book_map @flag='s',@function_id=10131000", sch.sch_grid.getColIndexById('book'), '', grid_obj);
        sch.load_dropdown("EXEC spa_virtual_storage @flag='c',@storage_location=" + get_param.storage_location_id , sch.sch_grid.getColIndexById('storage_contract'), '', grid_obj);

    };

    /*
    Loads the dropdown values on grid cells
    */
    sch.load_dropdown = function(sql_stmt, column_index, callback_function, obj_grid) {
        var cm_param = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": sql_stmt,
            "call_from": "grid"
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + "&" + cm_param;
        var combo_obj = obj_grid.getColumnCombo(column_index);
        combo_obj.enableFilteringMode("between", null, false)

        /*        combo_obj.attachEvent("onChange", function(value, text){
                    alert(value);
                });

        */
        if (callback_function != '')
            combo_obj.load(url, callback_function);
        else
            combo_obj.load(url);
    };
    /**
     * Function for menu insert sch deal
     */
    /**
     // sch.menu_insert_schedule = function() {
        //     sch.refresh_sch_grid('insert_row');
        //     // return;
        //     // var param = {
        //     //     "flag": "r",
        //     //     "action": "spa_get_loss_factor_volume",
        //     //     "schedule_volume": 0,
        //     //     "deliver_volume": 0,
        //     //     "path": get_param.path_id,
        //     //     "volume": get_param.total_volume,
        //     //     "term_start": get_param.term_start,
        //     //     "term_end": get_param.term_end,
        //     //     "source_deal_header_id": get_param.deal_id
        //     // };
        //     // //console.log(filter_param);
        //     // adiha_post_data('return_array', param, '', '', 'sch.menu_insert_schedule_cb');

        // }
     */
    /*
    callback for insert schedule fx
    */
    sch.menu_insert_schedule_cb = function(result) {
        //var json_obj = $.parseJSON(result);
        //console.dir(result);
        var num_rows = sch.sch_grid.getRowsNum();
        sch.sch_grid.addRow(num_rows+1, result.join(','));
        sch.sch_grid.enableHeaderMenu();
        sch.sch_layout.cells('b').progressOff();
    };

    /*
    Function to delete the selected rows on schedule grid
    */
    sch.menu_delete_grid_row = function() {
        sch.sch_grid.deleteSelectedRows();
        sch.sch_menu.setItemDisabled('process_deal_sch');
    };
    /*
    Function to schedule the selected deal
    */
    sch.menu_process_deal_sch = function(is_confirm) {
        if(sch.sch_grid instanceof dhtmlXGridObject) {
            sch.sch_layout.cells('b').progressOn();
            var grid_obj = sch.sch_grid;
            grid_obj.forEachRow(function(id) {
                var new_index = grid_obj.getColIndexById('new');
                var new_val = grid_obj.cells(id, new_index).getValue();
                if (new_val == 'y') {
                    var subgrid = sch.sch_grid.cells(id, sch.sch_grid.getColIndexById('sub')).getSubGrid();
                    var storage_contract = sch.sch_grid.cells(id, sch.sch_grid.getColIndexById('storage_contract')).getValue();
                    var sel_term_start = sch.sch_grid.cells(id, sch.sch_grid.getColIndexById('term_from')).getValue();
                    var sel_term_end = sch.sch_grid.cells(id, sch.sch_grid.getColIndexById('term_to')).getValue();
                    var uom = sch.sch_form.getItemValue('uom');
                    var storage_type = '';
                    if (get_param.pool_type != '') {     //when selected pool and receipt
                        storage_type = get_param.pool_type;
                    } else {
                        storage_type = get_param.storage_type;
                    }
                    var xml_text =  '<Root rec_deals="' + get_param.receipt_deals +
                        '" del_deals="' + get_param.delivery_deals +
                        '" rec_location="' + get_param.rec_location_id +
                        '" del_location="' + get_param.del_location_id +
                        '" flow_date_from="' + sel_term_start +
                        '" flow_date_to="' + sel_term_end +
                        '" uom="' + uom +
                        '" storage_type="' + storage_type +
                        '" storage_asset_id="' + storage_contract +
                        '">'
                    var path_id = sch.sch_grid.cells(id, sch.sch_grid.getColIndexById('path')).getValue();
                    var contract = sch.sch_grid.cells(id, sch.sch_grid.getColIndexById('contract')).getValue();
                    var sub_book_id = sch.sch_grid.cells(id, sch.sch_grid.getColIndexById('book')).getValue();

                    path_num = subgrid.getRowsNum()/3;
                    date_num = subgrid.getColumnsNum();

                    for (i = 0; i < path_num; i++) {
                        for(j = 3; j < date_num; j++) {
                            xml_text +=  '<PSRecordset path_id="' + path_id +
                                '" contract="' + contract +
                                '" sub_book_id="' + sub_book_id +
                                '" single_path_id="' + subgrid.cells(subgrid.getRowId(i * 3) , 0).getValue() +
                                '" term_start="' + dates.convert_to_sql(subgrid.getColLabel(j)) +
                                '" rec_vol="' + subgrid.cells(subgrid.getRowId((i * 3)), j).getValue() +
                                '" del_vol="'+ subgrid.cells(subgrid.getRowId((i * 3) + 2), j).getValue() +
                                '" loss_factor="' + subgrid.cells(subgrid.getRowId((i * 3) + 1), j).getValue() +
                                '" counterparty_id="' + get_param.loc_pipeline +
                                '" />'
                        }
                    }
                    xml_text += ' </Root>'
                    var param = {
                        "flag": "m",
                        "action": "spa_flow_optimization_match",
                        "xml_text": xml_text,
                        "process_id": get_param.process_id,
                        "call_from": get_param.call_from
                    };
                    //console.log(param);return;
                    adiha_post_data('return_json', param, '', '', 'menu_process_deal_sch_cb');
                }
            });
        }
    };

    /*
    Callback fx for schd deal process
    */
    menu_process_deal_sch_cb = function(result) {
        sch.sch_layout.cells('b').progressOff();
        var json_obj = $.parseJSON(result);
        //console.dir(json_obj);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Deal Scheduled successfully.', 'error');
            sch.update_total_volume();

            parent.new_win.close();
            //sch.refresh_sch_grid();
        } else if(json_obj[0].message.indexOf('proceed') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
            dhtmlx.message({
                title: "Warning",
                type: "confirm-warning",
                text: json_obj[0].message,
                callback: function(is_true) {
                    if(is_true === true) {
                        sch.menu_process_deal_sch(1);
                    }
                }
            });
        } else if(json_obj[0].message.indexOf('Insufficient') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
                callback: function(is_true) {

                }
            });
        } else if(json_obj[0].message.indexOf('MDQ') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
                callback: function(is_true) {

                }
            });

        }  else if(json_obj[0].message.indexOf('Counterparty') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
                callback: function(is_true) {

                }
            });

        } else if(json_obj[0].message.indexOf('pipeline') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
                callback: function(is_true) {

                }
            });

        } else {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: 'SQL Error (menu_process_deal_sch)',
                callback: function(is_true) {

                }
            });
        }
    };


    /*
    Function to Reschedule the selected deal
    */
    sch.menu_process_deal_resch = function(is_confirm) {
        if(sch.resch_grid instanceof dhtmlXGridObject) {
            var selected_row_id = sch.resch_grid.getSelectedRowId();
            //sch.resch_grid.clearSelection();
            //sch.sch_layout.cells('c').progressOn();

            var group_path_xml = '';
            var row_no;

            var sub_grid = sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('sub')).getSubGrid();

            if(sub_grid !== null) {
                sub_grid.forEachRow(function(rid) {
                    row_no = parseInt(rid) + 1;
                    group_path_xml = group_path_xml + '<group_path row_no="' + row_no + '" contract_id="' + sub_grid.cells(rid, sub_grid.getColIndexById('contract')).getValue()
                        + '" clm_primary_path_id="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('path')).getValue()
                        + '" clm_path="' +  sub_grid.cells(rid, sub_grid.getColIndexById('path_id')).getValue() + '"/>';
                });
            }rec_location_id


            var deal_xml = '<Root>';

            //sch.resch_grid.forEachCell(selected_row_id, function(cell_obj, ind) {
            deal_xml += '<PSRecordset edit_grid0="' + selected_row_id +
                '" edit_grid1="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Path')).getValue() +
                '" edit_grid2="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Contract')).getValue() +
                '" edit_grid3="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Flow Date From')).getValue() +
                '" edit_grid4="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Flow Date To')).getValue() +
                '" edit_grid5="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Scheduled Volume')).getValue() +
                '" edit_grid6="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Shrinkage')).getValue() +
                '" edit_grid7="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Fuel Charge')).getValue() +
                '" edit_grid8="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Delivered Volume')).getValue() +
                '" edit_grid9="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Total Sch Vol')).getValue() +
                '" edit_grid10="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Total Del Vol')).getValue() +
                '" edit_grid11="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Location From')).getValue() +
                '" edit_grid12="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Location To')).getValue() +
                '" edit_grid13="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Book')).getValue() +
                '" edit_grid14="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Volume Frequency')).getValue() +
                '" edit_grid15="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Receiving Counterparty')).getValue() +
                '" edit_grid16="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Shipping Counterparty')).getValue() +
                '" edit_grid17="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Trans ID')).getValue() +
                '" edit_grid18="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Is MR')).getValue() +
                '" edit_grid19="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Available Volume')).getValue() +
                '" edit_grid20="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Deal ID')).getValue() +
                '" edit_grid21="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('delivery_path_detail_id')).getValue() +
                '" edit_grid23="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('storage_contract')).getValue() +
                '" edit_grid22="' + get_param.trader_id +

                '"> ' + group_path_xml +' </PSRecordset></Root>';

            //});
            //console.log(deal_xml);
            var param = {
                "flag": "r",
                "action": "spa_insert_position_schedule_xml_deal",
                "deal_xml": deal_xml,
                "source_deal_header_id": get_param.deal_id,
                "isconfirm": is_confirm
            };
            console.dir(param);
            adiha_post_data('return_json', param, '', '', 'sch.menu_process_deal_resch_cb');
        }
    };
    /*
    Callback fx for schd deal process
    */
    sch.menu_process_deal_resch_cb = function(result) {
        //sch.sch_layout.cells('c').progressOff();
        var json_obj = $.parseJSON(result);
        //console.dir(json_obj);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Deal Re-Scheduled successfully.', 'error');
            sch.update_total_volume();
            sch.refresh_sch_grid();
            sch.refresh_resch_grid(-1);
        } else if(json_obj[0].message.indexOf('proceed') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
            dhtmlx.message({
                title: "Warning",
                type: "confirm-warning",
                text: json_obj[0].message,
                callback: function(is_true) {
                    if(is_true === true) {
                        sch.menu_process_deal_resch(1);
                    }
                }
            });
        } else if(json_obj[0].message.indexOf('Insufficient') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
                callback: function(is_true) {

                }
            });
        } else {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: 'SQL Error (menu_process_deal_sch)',
                callback: function(is_true) {

                }
            });
        }
    };

    sch.html_view = function() {
        var url = "EXEC spa_deal_schedule_report 'd', "+ get_param.deal_id + ", '"+ get_param.term_start +"', '"+ get_param.term_end +"'";
        open_spa_html_window('Schedule Detail Report', url, 600, 1175);
    }

    //

    function sch_under_over_detail_report(warning_type, process_id) {
        var report_name = 'Schedule Detail Report';
        var exec_call = "EXEC spa_view_validation_log 'schedule_detail','" + process_id + "', 's'";
        open_spa_html_window(report_name, exec_call, 500, 1150);
    }

    /*
    Function to update deal volume after successful deal schedule
    */
    sch.update_total_volume = function() {
        var param = {
            "flag": "t",
            "action": "spa_get_loss_factor_volume",
            "source_deal_header_id": get_param.deal_id,
            "path": get_param.path_id,
            "source_deal_detail_id": get_param.deal_detail_id
        };
        //console.dir(param);
        adiha_post_data('return_json', param, '', '', 'sch.update_total_volume_cb');

    };
    /*
    Callback fx for update_total_volume
    */
    sch.update_total_volume_cb = function(result) {
        var json_obj = $.parseJSON(result);
        sch.sch_form.setItemValue('total_volume', json_obj[0].total_volume);
        parent.new_win.progressOff();
    }
    /*
    Function to refresh sch grid
    */
    sch.refresh_sch_grid = function(call_from) {
        sch.sch_menu.setItemDisabled('process_deal_sch');
        check_subgrid = [];
        /*sch.sch_menu.setItemDisabled('process_deal_sch');
        sch.sch_menu.setItemDisabled('delete_deal_sch');
        sch.sch_menu.setItemDisabled('delete_grid_row');*/
        // sch.refresh_resch_grid(-1);

        var flag = 'd';
        var filter_param = '&path=' + get_param.path_id ;
        //+ '&term_start=' + get_param.term_start
        // + '&term_end=' + get_param.term_end + '&source_deal_header_id=' + get_param.deal_id + '&source_deal_detail_id=' + get_param.deal_detail_id;

        if(call_from == 'insert_row') {
            sch.sch_menu.setItemEnabled('process_deal_sch');
            flag = 'w';
        } else {
            flag = 'y'
        }

        sch.sch_layout.cells('b').progressOff();
        var param = {
            "flag": flag,
            "action":"spa_get_loss_factor_volume",
            "path": get_param.path_id,
            "term_start": get_param.flow_start,
            "term_end": get_param.flow_end,
            "receipt_deal_ids": get_param.receipt_deals,
            "call_from": get_param.call_from
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param + filter_param;

        sch.sch_grid.clearAndLoad(param_url, function() {

            // load_path_contract(sch.sch_grid, 1, get_param.path_id);
            //sch.sch_grid.setUserData('', "grid_type", "sch");
            sch.sch_layout.cells('b').progressOff();

            sch.sch_grid.forEachRow(function(rid) {
                if(sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('new')).getValue() == 'n') {
                    sch.sch_grid.setRowColor(rid, "#EBD3AA");
                    var colNum = sch.sch_grid.getColumnsNum();
                    for (i = 0; i < colNum; i++) {
                        if (i != 0) {
                            //sch.sch_grid.cells(rid,i).setDisabled(true);
                            //sch.sch_grid.cells(rid,i).setTextColor('red');
                        }
                    }
                }

                if(rid == row_num - 1)
                    sch.sch_grid.cellById(rid, 0).open();

            });
			
			load_storage_contract(sch.sch_grid,0, -1);
        });
        sch.subgrid(sch.sch_grid.getRowsNum(), '' ,sch.sch_grid);
        sch.sch_menu.setItemDisabled('delete_deal_sch');
        sch.sch_menu.setItemDisabled('delete_grid_row');
		
		
		
    };

    sch.subgrid = function (rid, sub_open, grid_obj, status_gird) {
        if(typeof check_subgrid[rid] === 'undefined') {
            // does not exist
            check_subgrid[rid] = false;
        } else {
            check_subgrid[rid] = true;
        }

        if (check_subgrid[rid] == false) {
            grid_obj.callEvent("onGridReconstructed", []);
            grid_obj.callEvent("onSubGridCreated", []);
            grid_obj.attachEvent("onSubGridCreated", function(subgrid, id, ind) {  // alert('onSubGridCreated');

                create_sub_grid(subgrid, true, id, sub_open, grid_obj, status_gird);
                check_subgrid[rid] = true;
            });
        }

        /* else {
             subgrid = grid_obj.cells(rid,1).getSubGrid();
             alert('4');
             create_sub_grid(subgrid, false, rid, sub_open,grid_obj, status_gird);
         }
            */
    }

    function create_sub_grid(subgrid, is_new_grid, rid, sub_open, grid_obj, status_gird) {
        is_add_clicked = true;
        //alert(typeof subgrid);
        //var subgrid = sch.sch_grid.cells(rid, 1).getSubGrid();
        if ((is_new_grid == true) && (typeof subgrid !== 'undefined')) {

            var term_start = grid_obj.cells(rid, grid_obj.getColIndexById('term_from')).getValue();
            var term_to = grid_obj.cells(rid, grid_obj.getColIndexById('term_to')).getValue();
            //alert(term_start);
            var header = 'Path ID,Path,Volume';
            var column_ids = 'path_id,path,volume';
            var col_types = 'ro,ro,ro';
            var width = '70,170,70';
            var col_sorting = 'int,int,int';

            var days = dates.diff_days(term_start,term_to);

            for(i = 0; i<=days ; i++) {
                header += "," + dates.convert_to_user_format(dates.convert_to_sql(dates.addDays(term_start, i)));
                column_ids += ',' + 'day'+ i;
                col_types += ',ed';
                width += ',70';
                col_sorting += ',int';

            }

            var ds_context_menu = new dhtmlXMenuObject({
                icons_path: js_image_path + 'dhxmenu_web/',
                context: true,
                items:[{id:"add",  text:"Apply To All"}]
            });
            ds_context_menu.attachEvent("onClick", context_menu_match_click);


            subgrid.setImagePath(php_script_loc + "components/dhtmlxSuite/codebase/imgs/");
            subgrid.setHeader(header);
            subgrid.setColumnIds(column_ids);
            subgrid.setColTypes(col_types);
            subgrid.setInitWidths(width);
            subgrid.enableMultiselect(true);
            //subgrid.setColSorting(col_sorting);
            //subgrid.attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
            subgrid.enableColumnMove(true);
            subgrid.setColumnHidden(0,true);
            //enable auto width mode, set the maximal and minimal allowed width
            subgrid.enableAutoWidth(true,2600,100);
            subgrid.enableContextMenu(ds_context_menu);


            /* subgrid.attachEvent("onXLE", function(grid_obj,count){
                 save_avail_value(subgrid);
                 //disable_del_vol();
             });*/

            /*subgrid.attachEvent("onCellChanged", function(rId,cInd,nValue){
                    if (cInd < 3) return false;

                    if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Rec') {
                       var total_row = subgrid.getRowsNum();
                       var i = 0;
                        while((subgrid.getRowIndex(rId) + 2 + i) < total_row) {
                            if(i != 0) {
                               new_rec_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -1 + i), cInd).getValue();
                               subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + i), cInd).setValue(new_rec_volume);
                            }


                            loss = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 1 + i), cInd).getValue();
                            new_del_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + i), cInd).getValue() * (1 - loss);

                            subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 2 + i), cInd).setValue(Math.round(new_del_volume));


                            i += 3;
                        }

                    } else if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Fuel') {
                        var total_row = subgrid.getRowsNum();
                        var i = 0;
                        //alert(total_row);
                        while((subgrid.getRowIndex(rId) + 1 + i) < total_row) {
                            if(i != 0) {
                               new_rec_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -2 + i), cInd).getValue();
                               subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -1 + i), cInd).setValue(new_rec_volume);
                            }


                            loss = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + i), cInd).getValue();
                            new_del_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -1 + i), cInd).getValue() * (1 - loss);

                            subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 1 + i), cInd).setValue(Math.round(new_del_volume));


                            i += 3;
                        }

                    }
            });*/

            subgrid.attachEvent("onBeforeContextMenu", function(id, ind, obj){

                //if((obj.cells(id, 2).getValue() == 'Rec' || obj.cells(id, 2).getValue() == 'Fuel') && ind > 2) {
                if(obj.getRowIndex(id) < 2  && ind > 2) {
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

                    change_vol(rId, cInd, subgrid);

                    /*

                   else if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Del') {
                        //alert('fuel');
                       loss = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -1) , cInd).getValue();
                       new_rec_volume = nValue * (1 + loss) ;

                       subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -2 ), cInd).setValue(parseInt(new_rec_volume));
                   } */

                }

                return true;

            });

            subgrid.init();
            subgrid.enableAutoHeight(true);

            sch.sch_form.setItemValue('vol_per', '');

        }

        /* if(!sub_open || sub_open == 'undefined') {
             grid_obj.attachEvent("onSubRowOpen", function(id,state) {

                 if (id == undefined) {
                     rid = rid_num;
                 } else {
                     rid = id;
                     rid_num = rid;
                 }

                 sch.subgrid(rid, 'true', grid_obj,status_gird);

             });
         }
        */

        // if (rid == undefined)
        //  return;

        try {
            var path_id = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('path')).getValue();
            var term_start = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('term_from')).getValue();
            var term_end = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('term_to')).getValue();

        } catch(e) {
            console.log(e);
        }
        //return;
        //var schedule_volume = 1; //grid_obj.cells(rid, grid_obj.getColIndexById('Scheduled Volume')).getValue()


        // if (get_param.receipt_deals != '') {
        //     receipt_deal_ids =  get_param.receipt_deals;
        //     minor_location = get_param.rec_location_id;
        // } else {
        //     receipt_deal_ids =  get_param.delivery_deals;
        //     minor_location = get_param.del_location_id;
        // }
        var vol_rec_del = 0;
        if (get_param.storage_type != '' && get_param.pool_type != '') {
            vol_rec_del = (get_param.total_receipt_vol == '0') ? get_param.total_delivery_vol:get_param.total_receipt_vol;
            if (get_param.pool_type == 'i') {
                receipt_deal_ids =  get_param.receipt_deals;
                minor_location = get_param.rec_location_id;
                delivery_deal_ids =  null;
                delivery_location = null;
            } else if (get_param.pool_type == 'w') {
                receipt_deal_ids =  null;
                minor_location = null;
                delivery_deal_ids =  get_param.delivery_deals;
                delivery_location = get_param.del_location_id;
            }
        } else  if (get_param.pool_type == 'i' && get_param.delivery_deals == '') {
            receipt_deal_ids =  get_param.receipt_deals;
            minor_location = get_param.rec_location_id;
            delivery_deal_ids =  null;
            delivery_location = null;
        } else if (get_param.pool_type == 'w' && get_param.receipt_deals == '') {
            receipt_deal_ids =  null;
            minor_location = null;
            delivery_deal_ids =  get_param.delivery_deals;
            delivery_location = get_param.del_location_id;
        } else if(get_param.storage_type == 'i') {     //when selected storage and receipt
            receipt_deal_ids =  get_param.receipt_deals;
            minor_location = get_param.rec_location_id;
            delivery_deal_ids =  null;
            delivery_location = null;
        } else if (get_param.storage_type == 'w') {     //when selected storage and delivery
            receipt_deal_ids =  null;
            minor_location = null;
            delivery_deal_ids =  get_param.delivery_deals;
            delivery_location = get_param.del_location_id;
        } else {    //when selected delivery and receipt
            receipt_deal_ids =  get_param.receipt_deals;
            minor_location = get_param.rec_location_id;
            delivery_deal_ids =  get_param.delivery_deals;
            delivery_location = get_param.del_location_id;
        }
        var uom = sch.sch_form.getItemValue('uom');
        if (sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('new')).getValue() == 'y') {
            //  alert('up');
            data = {
                "flag": "z",
                "action": "spa_get_loss_factor_volume",
                "path": path_id,
                "term_start": term_start,
                "term_end" : term_end,
                "process_id": get_param.process_id,
                "minor_location": minor_location,
                "receipt_deal_ids":receipt_deal_ids,
                "del_location":delivery_location,
                "delivery_deal_ids":delivery_deal_ids,
                //"avail_vol": get_param.avail_vol,
                "call_from": get_param.call_from,
                "uom":uom,
                "volume" : vol_rec_del

            };
        } else {
            data = {
                "flag": "m",
                "action": "spa_get_loss_factor_volume",
                "path": path_id,
                "term_start": term_start,
                "term_end" : term_end,
                "receipt_deal_ids": receipt_deal_ids,
                "delivery_deal_ids":delivery_deal_ids

            };
        }


        header_param = $.param(data);

        // alert(header_param);

        var header_url = js_data_collector_url + "&" + header_param;

        check_subgrid[rid] = true;
        //alert ('subgrid ' + typeof subgrid);
        if (typeof subgrid !== 'undefined') {
            //subgrid.clearAll();
            //alert(header_url)
            subgrid.loadXML(header_url);
        } else {
            if (!sub_open || sub_open == 'undefined') {
                grid_obj.callEvent("onSubRowOpen", []);
            }
        }
    }

    function save_avail_value(subgrid) {
        col_num = subgrid.getColumnsNum();
        row_num = subgrid.getRowsNum();
        if (row_num == 0 ) return true;

        for (i = 0; i < col_num ; i++) {
            vol_validate[i][0] = subgrid.getColLabel(i);
            vol_validate[i][1] = subgrid.cells(subgrid.getRowId(0), i).getValue();
        }

        /* for(i = 0; i < col_num; i++) {
             alert(vol_validate[i][0] + '  ' + vol_validate[i][1]);
         }*/
    }

    function change_vol_per(per) {
        if(sch.sch_grid.getRowsNum() == 1 ) {
            rId = 0;
        } else if (sch.sch_grid.getRowsNum() > 1) {
            rId = sch.sch_grid.getSelectedRowId();
        } else {
            return;
        }
        var subgrid = sch.sch_grid.cells(sch.sch_grid.getRowId(rId), sch.sch_grid.getColIndexById('sub')).getSubGrid();

        col_num = subgrid.getColumnsNum();

        for (i = 3; i < col_num; i++) {
            subgrid.cells(subgrid.getRowId(0), i).setValue(Math.round(subgrid.cells(subgrid.getRowId(0), i).getValue() * per));
            change_vol(subgrid.getRowId(0), i, subgrid);
        }
    }

    function change_vol(rId, cInd, subgrid) {
        if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Rec') {

            if (parseInt(vol_validate[cInd][1]) < parseInt(subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId)), cInd).getValue())) {
                //alert(vol_validate[cInd][1]  + ' --- ' + subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId)), cInd).getValue());
                subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId)), cInd).setTextColor('red');
            } else {
                subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId)), cInd).setTextColor('black');
            }
            var total_row = subgrid.getRowsNum();
            var i = 0;
            while((subgrid.getRowIndex(rId) + 2 + i) < total_row) {
                if(i != 0) {
                    new_rec_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -1 + i), cInd).getValue();
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + i), cInd).setValue(new_rec_volume);
                }


                loss = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 1 + i), cInd).getValue();
                new_del_volume = parseInt(subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + i), cInd).getValue()) * (1 - loss);
                /*alert(subgrid.getRowIndex(rId));
                alert(loss + '  ' + new_del_volume + '  ' + subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + i), cInd).getValue() );*/
                subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 2 + i), cInd).setValue(Math.round(new_del_volume));


                i += 3;
            }

        } else if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Fuel') {
            var total_row = subgrid.getRowsNum();
            var i = 0;
            //alert(total_row);
            while((subgrid.getRowIndex(rId) + 1 + i) < total_row) {
                if(i != 0) {
                    new_rec_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -2 + i), cInd).getValue();
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -1 + i), cInd).setValue(new_rec_volume);
                }


                loss = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + i), cInd).getValue();
                new_del_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -1 + i), cInd).getValue() * (1 - loss);

                subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + 1 + i), cInd).setValue(Math.round(new_del_volume));

                i += 3;
            }

        } else if (subgrid.cells(rId, subgrid.getColIndexById('volume')).getValue() == 'Del') {
            var total_row = subgrid.getRowsNum();
            var i = 0;
            while((subgrid.getRowIndex(rId) + 0 + i) < total_row) {
                if(i != 0) {
                    new_del_volume = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) -3 + i), cInd).getValue();
                    subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) - 2 + i), cInd).setValue(new_del_volume);
                }


                loss = subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) - 1 + i), cInd).getValue();
                new_rec_volume = parseInt(subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) + i), cInd).getValue()) / (1 - loss);

                subgrid.cells(subgrid.getRowId(subgrid.getRowIndex(rId) - 2 + i), cInd).setValue(Math.round(new_rec_volume));

                i += 3;
            }
        }
    }

    function reload_subgrid(subgrid, rid) {
        if(!subgrid || typeof subgrid == 'undefined')return;

        var col_num = subgrid.getColumnsNum();

        for(i = 3; i < col_num ; i++){
            // alert(i);
            subgrid.deleteColumn(3);
        }

        var term_start = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('term_from')).getValue();
        var term_to = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('term_to')).getValue();

        var days = dates.diff_days(term_start,term_to);


        for (i = 0; i<=days; i++) {
            subgrid.insertColumn(3 + i,dates.convert_to_user_format(dates.convert_to_sql(dates.addDays(term_start, i))),'ed',70);
        }

        try {

            var path_id = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('path')).getValue();
            var term_start = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('term_from')).getValue();
            var term_end = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('term_to')).getValue();
            var contract = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('contract')).getValue();
        } catch(e) {
            console.log(e);
        }
        //var schedule_volume = 1; //grid_obj.cells(rid, grid_obj.getColIndexById('Scheduled Volume')).getValue()

        // if (get_param.receipt_deals != '') {
        //     receipt_deal_ids =  get_param.receipt_deals;
        //     minor_location = get_param.rec_location_id;
        // } else {
        //     receipt_deal_ids =  get_param.delivery_deals;
        //     minor_location = get_param.del_location_id;
        // }

        var vol_rec_del = 0;
        if (get_param.storage_type != '' && get_param.pool_type != '') {
            vol_rec_del = (get_param.total_receipt_vol == '0') ? get_param.total_delivery_vol:get_param.total_receipt_vol;
            if (get_param.pool_type == 'i') {
                receipt_deal_ids =  get_param.receipt_deals;
                minor_location = get_param.rec_location_id;
                delivery_deal_ids =  null;
                delivery_location = null;
            } else if (get_param.pool_type == 'w') {
                receipt_deal_ids =  null;
                minor_location = null;
                delivery_deal_ids =  get_param.delivery_deals;
                delivery_location = get_param.del_location_id;
            }
        } else  if (get_param.pool_type == 'i' && get_param.delivery_deals == '') {
            receipt_deal_ids =  get_param.receipt_deals;
            minor_location = get_param.rec_location_id;
            delivery_deal_ids =  null;
            delivery_location = null;
        } else if (get_param.pool_type == 'w' && get_param.receipt_deals == '') {
            receipt_deal_ids =  null;
            minor_location = null;
            delivery_deal_ids =  get_param.delivery_deals;
            delivery_location = get_param.del_location_id;
        }  else if(get_param.storage_type == 'i') {     //when selected storage and receipt
            receipt_deal_ids =  get_param.receipt_deals;
            minor_location = get_param.rec_location_id;
            delivery_deal_ids =  null;
            delivery_location = null;
        } else if (get_param.storage_type == 'w') {     //when selected storage and delivery
            receipt_deal_ids =  null;
            minor_location = null;
            delivery_deal_ids =  get_param.delivery_deals;
            delivery_location = get_param.del_location_id;
        } else {    //when selected delivery and receipt
            receipt_deal_ids =  get_param.receipt_deals;
            minor_location = get_param.rec_location_id;
            delivery_deal_ids =  get_param.delivery_deals;
            delivery_location = get_param.del_location_id;
        }
        var uom = sch.sch_form.getItemValue('uom');
        data = {
            "flag": "z",
            "action": "spa_get_loss_factor_volume",
            "path": path_id,
            "term_start": term_start,
            "term_end" : term_end,
            "process_id": get_param.process_id,
            "minor_location": minor_location,
            "receipt_deal_ids": receipt_deal_ids,
            "del_location":delivery_location,
            "delivery_deal_ids":delivery_deal_ids,
            "contract": contract,
            "call_from": get_param.call_from,
            "uom": uom,
            "volume" : vol_rec_del
            //"avail_vol": get_param.avail_vol
        };

        header_param = $.param(data);
        //alert(path_id + '  ' + contract + ' ' + term_start);
        get_param.row_id = rid;
        adiha_post_data('return_array', data, '', '', 'reload_subgrid_cb');
    }

    function reload_subgrid_cb (result) {
        var subgrid = sch.sch_grid.cells(get_param.row_id, sch.sch_grid.getColIndexById('sub')).getSubGrid();

        subgrid.clearAll();
        var col_values = '';
        $.each(result , function(index, obj) {

            var newId = (new Date()).valueOf();
            col_values = '';
            $.each(obj, function(key, value) {

                if (key == 0) col_values = value;
                else col_values += ',' + value;

            });
            subgrid.addRow(newId,col_values);
        });

        save_avail_value(subgrid);

        //disable_del_vol();

        sch.sch_form.setItemValue('vol_per', '');
    }

    function disable_del_vol() {
        sch.sch_grid.forEachRow(function(rid){
            var subgrid = sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('sub')).getSubGrid();

            subgrid.forEachRow(function(id){

                if (sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('new')).getValue() == 'y') {

                    if (subgrid.getRowIndex(id) > 1) {
                        // if(subgrid.cells(id,2).getValue() == 'Del') {
                        var col_num = subgrid.getColumnsNum();
                        for(cid = 3; cid < col_num; cid++) {
                            subgrid.cells(id, cid).setDisabled(true);
                        }
                    }
                } else {
                    subgrid.setRowColor(id, "#EBD3AA");
                    var col_num = subgrid.getColumnsNum();
                    for(cid = 3; cid < col_num; cid++) {
                        subgrid.cells(id, cid).setDisabled(true);
                    }

                }
            });
        });
    }

    /*
    Function to refresh resch grid
    */
    sch.refresh_resch_grid = function(rid, call_grid) {
        check_subgrid = [];
        // console.log('refresh_resch_grid : ' + rid);
        if(rid == -1) { //
            sch.resch_grid.clearAll();
            return;
        }
        sch.sch_menu.setItemDisabled('process_deal_resch');
        //sch.sch_layout.cells('c').progressOn();
        var flag = 'c';
        var filter_param = '&path=' + get_param.path_id + '&term_start=' + get_param.term_start
            + '&term_end=' + get_param.term_end + '&volume=' + get_param.total_volume
            + '&schedule_volume=' + sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Scheduled Volume')).getValue()
            + '&deliver_volume=' + sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Delivered Volume')).getValue()
            + '&process_id=' + sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Process ID')).getValue()
            + '&trans_id=' + sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Trans ID')).getValue()
        ;
        // console.log(filter_param);
        var param = {
            "flag": flag,
            "action":"spa_get_loss_factor_volume"
        };
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param + filter_param;

        sch.resch_grid.clearAndLoad(param_url, function() {

            sch.resch_grid.setUserData('', "grid_type", "resch");

            sch.resch_grid.forEachRow(function(id){
                load_path_contract(sch.resch_grid, id, sch.resch_grid.cells(id, sch.resch_grid.getColIndexById('Path')).getValue())
            });

            //sch.sch_layout.cells('c').progressOff();
        });
        if(call_grid)
            sch.subgrid(rid, '', sch.resch_grid, 'r');
        // sch.subgrid(rid, '', sch.sch_grid);
    };
    /*
    Function to delete the schedule deal
    */
    sch.menu_delete_schedule = function() {

        var param = {
            "flag": "f",
            "action": "spa_get_loss_factor_volume",
            "path": get_param.path_id,
            "receipt_deal_ids": get_param.receipt_deals
        };
        //console.dir(param);

        confirm_messagebox('Are you sure you want to delete the seleted deal(s)?', function() {
            sch.sch_layout.cells('b').progressOn();
            adiha_post_data('return_json', param, '', '', 'sch.menu_delete_schedule_cb');
        });

    };

    sch.menu_delete_schedule_cb = function(result) {
        var json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Schedule successfully deleted.');
            sch.refresh_sch_grid();
            //sch.refresh_resch_grid(-1);
            sch.update_total_volume();
        } else {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
                callback: function(is_true) {

                }
            });
            sch.sch_layout.cells('b').progressOff();
        }
    };


    sch.schedule_select = function(id, index) {
        var grid_obj = sch.sch_grid;
        var new_index = grid_obj.getColIndexById('new');
        var new_val = grid_obj.cells(id, new_index).getValue();
        if (new_val == 'y') {
            sch.sch_menu.setItemEnabled('delete_grid_row');
            sch.sch_menu.setItemDisabled('delete_deal_sch');
        } else {
            sch.sch_menu.setItemEnabled('delete_deal_sch');
            sch.sch_menu.setItemDisabled('delete_grid_row');
        }
    }

    sch.toggle_click = function (toggle_status) {
        if (toggle_status == 0) {
            get_param.rec_location_id = '<?php echo $delivery_loc_id; ?>';
            get_param.del_location_id = '<?php echo $receipt_loc_id; ?>';
            if (get_param.path_id_toggle) {
                get_param.toggle = 1;
                get_param.total_receipt_vol = '<?php echo $total_delivery_vol; ?>';
                get_param.total_delivery_vol = '<?php echo $total_receipt_vol; ?>';
                get_param.receipt_deals = '<?php echo $delivery_deals;?>';
                get_param.delivery_deals = '<?php echo $receipt_deals;?>';
                get_param.path_id = '<?echo $physical_path_toggle; ?>';
            } else {
                dhtmlx.message({
                    title: "Warning",
                    type: "confirm-warning",
                    text: 'Delivery Path do not exist between selected locations. Click Ok to add delivery path.',
                    callback: function(is_true) {
                        if(is_true === true) {
                            fx_open_delivery_path_window(get_param.rec_location_id, get_param.del_location_id, get_param.to_loc_name, get_param.from_loc_name);
                        }
                    }
                });
            }
        } else {
            get_param.toggle = 0;
            get_param.rec_location_id = '<?php echo $receipt_loc_id; ?>';
            get_param.del_location_id = '<?php echo $delivery_loc_id; ?>';
            get_param.total_receipt_vol = '<?php echo $total_receipt_vol; ?>';
            get_param.total_delivery_vol = '<?php echo $total_delivery_vol; ?>';
            get_param.receipt_deals = '<?php echo $receipt_deals;?>';
            get_param.delivery_deals = '<?php echo $delivery_deals;?>';
            get_param.path_id = '<?echo $physical_path; ?>';
            get_param.path_id_toggle = '<?echo $physical_path_toggle; ?>';
        }

        if (get_param.pool_type == 'i') {
            get_param.pool_type = 'w';
        } else if (get_param.pool_type == 'w'){
            get_param.pool_type = 'i';
        }

        if (get_param.storage_type == 'i') {
            get_param.storage_type = 'w';
        } else if (get_param.storage_type == 'w'){
            get_param.storage_type = 'i';
        }

        sch.fx_initial_load();
        sch.refresh_sch_grid();
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


</script>
