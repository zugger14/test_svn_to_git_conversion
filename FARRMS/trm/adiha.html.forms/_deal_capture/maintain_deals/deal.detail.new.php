<?php
/**
* Deal detail new screen
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
</head>
<body>
<?php
include '../../../adiha.php.scripts/components/include.file.v3.php';
$php_script_loc = $app_php_script_loc;
// TODO: should reference global variable when available
$soft_commodity = false;

$deal_id = (isset($_REQUEST["deal_id"]) && $_REQUEST["deal_id"] != '') ? get_sanitized_value($_REQUEST["deal_id"]) : 'NULL';
$view_deleted = (isset($_REQUEST["view_deleted"]) && $_REQUEST["view_deleted"] != '' && $_REQUEST["view_deleted"] != 'undefined' ) ? get_sanitized_value($_REQUEST["view_deleted"]) : 'n';
$template_id = (isset($_REQUEST["template_id"]) && $_REQUEST["template_id"] != '') ? get_sanitized_value($_REQUEST["template_id"]) : 'NULL';
$sub_book = (isset($_REQUEST["sub_book"]) && $_REQUEST["sub_book"] != '') ? get_sanitized_value($_REQUEST["sub_book"]) : 'NULL';
$subsidiary = (isset($_REQUEST["subsidiary"]) && $_REQUEST["subsidiary"] != '') ? get_sanitized_value($_REQUEST["subsidiary"]) : '';
$book = (isset($_REQUEST["book"]) && $_REQUEST["book"] != '') ? get_sanitized_value($_REQUEST["book"]) : '';
$buy_sell = (isset($_REQUEST["buy_sell"]) && $_REQUEST["buy_sell"] != '') ? get_sanitized_value($_REQUEST["buy_sell"]) : '';
$copy_deal_id = (isset($_REQUEST["copy_deal_id"]) && $_REQUEST["copy_deal_id"] != '') ? get_sanitized_value($_REQUEST["copy_deal_id"]) : 'NULL';
$copy_insert_mode = (isset($_REQUEST["copy_insert_mode"]) && $_REQUEST["copy_insert_mode"] != '') ? get_sanitized_value($_REQUEST["copy_insert_mode"]) : 'NULL';
$deal_type_id = (isset($_REQUEST["deal_type_id"]) && $_REQUEST["deal_type_id"] != '') ? get_sanitized_value($_REQUEST["deal_type_id"]) : 'NULL';
$pricing_type_id = (isset($_REQUEST["pricing_type_id"]) && $_REQUEST["pricing_type_id"] != '') ? get_sanitized_value($_REQUEST["pricing_type_id"]) : 'NULL';
$term_frequency = (isset($_REQUEST["term_frequency"]) && $_REQUEST["term_frequency"] != '') ? "'" . get_sanitized_value($_REQUEST["term_frequency"]) . "'" : 'NULL';
$commodity_id = (isset($_REQUEST["commodity_id"]) && $_REQUEST["commodity_id"] != '') ? get_sanitized_value($_REQUEST["commodity_id"]) : 'NULL';
$deal_type = (isset($_REQUEST['deal_type'])) ? get_sanitized_value($_REQUEST['deal_type']) : 'NULL';
$enable_product_button = (isset($_REQUEST['is_environmental'])) ? get_sanitized_value($_REQUEST['is_environmental']) : 'NULL';
$enable_certificate_button = (isset($_REQUEST['is_environmental'])) ? get_sanitized_value($_REQUEST['is_environmental']) : 'NULL';

$lock_data = array();
$insert_mode = false;

// Get Dashboard reports
$sp_db = "EXEC spa_pivot_report_dashboard @flag='x', @category=-104700";
$db_array = readXMLURL2($sp_db);
$db_items = '';

if (is_array($db_array) && sizeof($db_array) > 0) {
    $db_items = ',items:[';
    $icnt = 0;
        foreach ($db_array as $data) {
            if ($icnt > 0) $db_items .= ',';
            $db_items .= ' {id:"dashboard_ ' . $data['dashboard_id'] . '", text:"' . $data['dashboard_name'] . '", img:"report.gif", imgdis:"report_dis.gif", text:"' . $data['dashboard_name'] . '", enabled:true}';
            $icnt++;
        }

    $db_items .= ']';
}

if ($deal_id != 'NULL') {
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
    $sp_deal_lock = "EXEC spa_deal_update_new @flag='l', @source_deal_header_id=" . $deal_id . ", @view_deleted='" . $view_deleted . "'";
    $lock_data = readXMLURL2($sp_deal_lock);
        $insert_mode = false;
} else {
    $insert_mode = true;

    //TAKE SUB BOOK AND DEAL TYPE FROM FIELD TEMPLATE
    $sp_url = "EXEC spa_deal_update_new @flag = 'get_sub_id_from_field_template', @template_id = " . $template_id;
    $result_value = readXMLURL2($sp_url);

    if ($sub_book == 'NULL' && ($result_value[0]['default_value'] ?? null) != null) {
        $sub_book = $result_value[0]['default_value'];
    }

    if ($deal_type_id == 'NULL' && ($result_value[1]['default_value'] ?? null) != null) {
        $deal_type_id = $result_value[1]['default_value'];
    }

    $sp_url_product = "EXEC spa_deal_update_new @flag = 'get_environmental_from_field_template', @template_id = " . $template_id;
    $sp_url_product = readXMLURL2($sp_url_product);

    if($sp_url_product[0]['default_value'] ?? '' != null){
        $enable_product_button = 'true';
    }

    $sp_url_certificate = "EXEC spa_deal_update_new @flag = 'get_certificate_from_field_template', @template_id = " . $template_id;
    $sp_url_certificate = readXMLURL2($sp_url_certificate);

    if($sp_url_certificate[0]['default_value'] ?? '' != null){
        $enable_certificate_button = 'true';
    }



    $sp_term_frequency = "EXEC spa_deal_update_new @flag='x', @source_deal_header_id=" . $deal_id . ", @template_id=" . $template_id . ", @copy_deal_id=" . $copy_deal_id . ",@deal_type_id=" . $deal_type_id . ", @pricing_type=" . $pricing_type_id . ", @term_frequency=" . $term_frequency . ", @commodity_id=" . $commodity_id;
    $term_frequency_arr = readXMLURL2($sp_term_frequency);
    $term_frequency = $term_frequency_arr[0]['term_frequency'];
    $header_cost_enable = $term_frequency_arr[0]['header_cost_enable'];
    $detail_cost_enable = $term_frequency_arr[0]['detail_cost_enable'];
    $pricing_process_id =  ($copy_deal_id != 'NULL') ? $term_frequency_arr[0]['pricing_process_id'] : 'NULL';
    $deal_date = $term_frequency_arr[0]['deal_date'];
    $is_shaped =  $term_frequency_arr[0]['is_shaped'];
    $udf_process_id =  $term_frequency_arr[0]['udf_process_id'];
    $enable_pricing =  $term_frequency_arr[0]['enable_pricing'];
    $deal_type_id = ($term_frequency_arr[0]['deal_type_id'] == '') ? 'NULL' : $term_frequency_arr[0]['deal_type_id'];
    $pricing_type_id = ($term_frequency_arr[0]['pricing_type_id'] == '') ? 'NULL' : $term_frequency_arr[0]['pricing_type_id'];
    $commodity_id = ($term_frequency_arr[0]['commodity_id'] == '') ? 'NULL' : $term_frequency_arr[0]['commodity_id'];
    $enable_udf_tab = ($term_frequency_arr[0]['enable_udf_tab'] == '') ? 'n' : $term_frequency_arr[0]['enable_udf_tab'];
    $enable_prepay_tab = $term_frequency_arr[0]['enable_prepay_tab'];

}

$copy_price_process_id = '';
$copy_provisional_price_process_id = '';

if ($copy_deal_id <> 'NULL') {
    $spa_deal_pricing = "EXEC [dbo].[spa_deal_pricing_detail] @flag = 'j', @source_deal_detail_id = " . $copy_deal_id;
    $spa_deal_pricing_arr = readXMLURL2($spa_deal_pricing);

    $copy_price_process_id = $spa_deal_pricing_arr[0]['recommendation'];

    $spa_deal_provisional_pricing = "EXEC [dbo].[spa_deal_pricing_detail_provisional] @flag = 'j', @source_deal_detail_id = " . $copy_deal_id;
    $spa_deal_provisional_pricing_arr = readXMLURL2($spa_deal_provisional_pricing);

    $copy_provisional_price_process_id = $spa_deal_provisional_pricing_arr[0]['recommendation'];
}

//To avoid syntax error for queries below for cases when term_frequency is NULL
if ($term_frequency == NULL) {
    $term_frequency = 'NULL';
}

$rights_deal_edit = 10131010;
$rights_document = 10102900;
$rights_schedule_deal = 10131028;
$rights_schedule_volume_update = 10131032;
$rights_actual_volume_update = 10131033;
$rights_transfer = 10131024;

list (
    $has_rights_deal_edit,
    $has_document_rights,
    $has_schedule_deal,
    $has_schedule_vol_update,
    $has_actual_vol_update,
	$has_rights_transfer
    ) = build_security_rights(
    $rights_deal_edit,
    $rights_document,
    $rights_schedule_deal,
    $rights_schedule_volume_update,
    $rights_actual_volume_update,
	$rights_transfer
);

$sql_request = "EXEC spa_source_deal_header @flag='z', @deal_ids=". $deal_id . ", @function_id = 10131010, @sub_book=" . $sub_book;
$return_value = readXMLURL($sql_request);

if ($return_value[0][0] == 1) {
    $enable_save_button = 'true';
} else if ($insert_mode) {
    $enable_save_button = 'true';
} else {
    $enable_save_button = 'false';
}

$deal_trade_locked = $lock_data[0]['deal_trade_locked'] ?? '';

if ($view_deleted == 'y' || ($lock_data[0]['deal_locked'] ?? '') == 'y' || $deal_trade_locked == 'y' ) {
    $enable_save_button = 'false';
}

$is_locked = '';
$volume_type = '';
$profile_gran_with_meter = '';
$profile_granularity = '';
    $deal_reference_id = '';
    $enable_header_udt = 'n';
    $enable_detail_udt = 'n';

if (is_array($lock_data) && sizeof($lock_data) > 0) {
    $is_locked = $lock_data[0]['deal_locked'];
    $disable_term = ($lock_data[0]['disable_term'] == 'n') ? true : false;
    $deal_date = $lock_data[0]['deal_date'];
    $enable_efp = $lock_data[0]['enable_efp'];
    $enable_trigger = $lock_data[0]['enable_trigger'];
    $deal_type_text = $lock_data[0]['deal_type'];
    $enable_pricing =  $lock_data[0]['enable_pricing'];
    $enable_provisional_tab = $lock_data[0]['enable_provisional_tab'];
    $enable_escalation_tab = $lock_data[0]['enable_escalation_tab'];
    $pricing_process_id =  $lock_data[0]['pricing_process_id'];
    $is_shaped =  $lock_data[0]['is_shaped'];
    $term_frequency = ($lock_data[0]['term_frequency'] == '') ? 'NULL' : $lock_data[0]['term_frequency'];
    $header_cost_enable = $lock_data[0]['header_cost_enable'];
    $detail_cost_enable = $lock_data[0]['detail_cost_enable'];
    $certificate = $lock_data[0]['certificate'];
    $document_enable = $lock_data[0]['document_enable'];
    $enable_remarks = $lock_data[0]['enable_remarks'];
    $deal_type_id = ($lock_data[0]['deal_type_id'] == '') ? 'NULL' : $lock_data[0]['deal_type_id'];
    $pricing_type_id = ($lock_data[0]['pricing_type_id'] == '') ? 'NULL' : $lock_data[0]['pricing_type_id'];
    $enable_exercise = $lock_data[0]['enable_exercise'];
    $actualization_flag = ($lock_data[0]['actualization_flag'] == '') ? 'NULL' : $lock_data[0]['actualization_flag'];
    $udf_process_id =  $lock_data[0]['udf_process_id'];
    $commodity_id =  ($lock_data[0]['commodity_id'] == '') ? 'NULL' : $lock_data[0]['commodity_id'];
    $enable_udf_tab =  $lock_data[0]['enable_udf_tab'];
    $is_environmental = $lock_data[0]['is_environmental'];
    $profile_granularity =  $lock_data[0]['profile_granularity'];
    $volume_type =  $lock_data[0]['volume_type'];
    $profile_gran_with_meter = $lock_data[0]['profile_gran_with_meter'];
    $enable_prepay_tab = $lock_data[0]['enable_prepay_tab'];
    $deal_reference_id = $lock_data[0]['deal_reference_id'];
    $enable_header_udt = $lock_data[0]['enable_header_udt'];
    $enable_detail_udt = $lock_data[0]['enable_detail_udt'];
} else {
    $disable_term = 'false';
    $enable_efp = 'n';
    $enable_trigger = 'n';
    $deal_type_text = '';
    $enable_provisional_tab = 'n';
    $enable_escalation_tab = 'n';
    $certificate = 'n';
    $document_enable = 'n';
    $enable_remarks = 'n';
    $enable_exercise = 'n';
    $actualization_flag = 'NULL';
    $is_environmental = 'n';
}

$sp_deal_header = "EXEC spa_deal_update_new @flag='h', @source_deal_header_id=" . $deal_id . ", @view_deleted='" . $view_deleted . "', @template_id=" . $template_id . ", @copy_deal_id=" . $copy_deal_id . ",@deal_type_id=" . $deal_type_id . ", @pricing_type=" . $pricing_type_id . ", @term_frequency=" . $term_frequency . ", @sub_book=" . $sub_book . ", @udf_process_id='" . $udf_process_id . "', @commodity_id=" . $commodity_id;
$header_data = readXMLURL2($sp_deal_header);

$sp_deal_detail = "EXEC spa_deal_update_new @flag='d', @source_deal_header_id=" . $deal_id . ", @view_deleted='" . $view_deleted . "', @template_id=" . $template_id . ", @copy_deal_id=" . $copy_deal_id . ",@deal_type_id=" . $deal_type_id . ", @pricing_type=" . $pricing_type_id . ", @term_frequency=" . $term_frequency . ", @udf_process_id='" . $udf_process_id . "', @commodity_id=" . $commodity_id;
$detail_data = readXMLURL2($sp_deal_detail);

$future_deal = 'n';
if (strtolower($deal_type_text) == 'future') {
    $future_deal = 'y';
}

if($is_locked == 'y') $has_rights_deal_edit = 'false';
if ($view_deleted == 'y') {
    $has_rights_deal_edit = 'false';
}

$term_edit_privilege = $has_rights_deal_edit;
if ($has_rights_deal_edit && !$disable_term) $term_edit_privilege = 'false';

if ((!$has_schedule_vol_update || !$has_actual_vol_update) && ($actualization_flag != 'm' || $actualization_flag != 's')) {
    $enable_update_actual = false;
} else {
    $enable_update_actual = true;
}

$tab_data = array();
$form_data = array();
$grid_sql = array();
$header_cost_process_id = '';
$header_formula_fields = '';

$cnt = 0;
if (is_array($header_data) && sizeof($header_data) > 0) {
    foreach ($header_data as $data) {
        array_push($tab_data, $data['tab_json']);

        if ($cnt == 0) $header_formula_fields = $data['header_formula_fields'];

            if ($data['grid_json'] != '') {
                if (!array_key_exists($data['tab_id'], $form_data))
                $form_data[$data['tab_id']] = array();

                $form_data[$data['tab_id']]['grid'] = $data['grid_json'];
            } else if ($data['tab_sql'] == '') {
                if (!array_key_exists($data['tab_id'], $form_data))
                    $form_data[$data['tab_id']] = array();

                $form_data[$data['tab_id']]['form'] = $data['form_json'];
        } else {
            $grid_sql[$data['tab_id']] = $data['tab_sql'];
            $header_cost_process_id = $data['process_id'];
        }
        $cnt++;
    }
}
$header_tab_data = '[' . implode(",", $tab_data) . ']';

$form_namespace = 'dealDetail';
$layout_json = '[{id: "a", text: "Deal", header:true},{id: "b", text:"<div><a class=\"undock_pricing_detail undock_custom\" title=\"Undock\" onClick=\"dealDetail.undock_details(\'b\')\"></a>Additional Details</div>", header:true}, {id: "c", text:"<div><a class=\"undock_detail undock_custom\" title=\"Undock\" onClick=\"dealDetail.undock_details(\'c\')\"></a>Details</div>", header:true}]';
$page_toolbar_json = '[{id:"save", type: "button", img:"save.gif", imgdis:"save_dis.gif", enabled:'. $enable_save_button . ', text:"Save", title: "Save"},{id:"certificate",type:"button",img:"certificate.gif",imgdis:"certificate_dis.gif",text:"Certificate",title:"Certificate"},
{id:"product",type:"button",img:"product.gif",imgdis:"product_dis.gif",text:"Product",title:"Product"}, {id:"transfer",type:"button", text:"Transfer", img:"transfer.gif", imgdis:"transfer_dis.gif", title: "Transfer", enabled:false},
                            {id:"udt",type:"button",img:"data.png",imgdis:"data_dis.png",text:"Additional",title:"Additional"}
                        ]';

$layout_obj = new AdihaLayout();
$page_toolbar = new AdihaToolbar();
$tab_obj = new AdihaTab();

if ($view_deleted == 'y') {
    $udf_menu_json = '[{id:"add", text:"Add/Delete UDFs", title: "Add/Delete UDFs", img:"edit.gif", imgdis:"edit_dis.gif", enabled:false}]';
} else {
    $udf_menu_json = '[{id:"add", text:"Add/Delete UDFs", title: "Add/Delete UDFs", img:"edit.gif", imgdis:"edit_dis.gif"}]';
}

echo $layout_obj->init_layout('deal_detail', '', '3J', $layout_json, $form_namespace);

echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
echo $page_toolbar->init_by_attach('toolbar', $form_namespace);
echo $page_toolbar->load_toolbar($page_toolbar_json);
echo $page_toolbar->attach_event('', 'onClick', $form_namespace . '.page_toolbar_click');

if ($enable_header_udt == 'n') {
    echo $page_toolbar->hide_item('udt');
}

echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_detail_event');
echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_detail_event');
echo $layout_obj->attach_tab_cell('deal_tab', 'a', $header_tab_data);
echo $tab_obj->init_by_attach('deal_tab', $form_namespace);

if (is_array($form_data) && sizeof($form_data) > 0) {
    foreach ($form_data as $tab_id => $form_json) {            
        if (array_key_exists('form', $form_json)) {
            $form_obj[$tab_id] = new AdihaForm();

            if ($tab_id == 0) {
                $udf_menu = new AdihaMenu();
                echo $tab_obj->attach_menu_cell('udf_menu', $tab_id);
                echo $udf_menu->init_by_attach('udf_menu', $form_namespace);
                echo $udf_menu->load_menu($udf_menu_json);
                echo $udf_menu->attach_event('', 'onClick', $form_namespace . '.udf_menu_click');
            }

            echo $tab_obj->attach_form_cell('form_' . $tab_id, $tab_id);
            echo $form_obj[$tab_id]->init_by_attach('form_' . $tab_id, $form_namespace);
            echo $form_obj[$tab_id]->load_form($form_json['form']);
            echo $form_obj[$tab_id]->attach_event('', 'onChange', $form_namespace . '.form_change');         
        } else if (array_key_exists('grid', $form_json)) {
            $udt_grid_details = json_decode($form_json['grid']);
            $udt_grid_name = $udt_grid_details->name;
            $udt_grid_label = $udt_grid_details->label;
            
            $udt_menu_json = '
                [
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                            {id:"add", text:"Add", img:"new.gif", enabled:false, imgdis:"new_dis.gif", title:"Add", enabled:true},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title:"Delete", enabled:false},
                    ]} 
                ]
            ';
            
            $menu_name = $udt_grid_name . '_menu';
            $header_udt_menu = new AdihaMenu();
            echo $tab_obj->attach_menu_cell($menu_name, $tab_id);
            echo $header_udt_menu->init_by_attach($menu_name, $form_namespace);
            echo $header_udt_menu->load_menu($udt_menu_json);
            echo $header_udt_menu->attach_event('', 'onClick', $form_namespace . '.udt_menu_click');
            
            echo $tab_obj->set_user_data($tab_id, 'is_udt_tab', 'y');
            echo $tab_obj->attach_status_bar($tab_id, true, '', 'a_' . $tab_id);
            echo $tab_obj->attach_grid_cell($udt_grid_name, $tab_id);
            $header_udt_grid = new GridTable($udt_grid_name);
            echo $header_udt_grid->init_grid_table($udt_grid_name, $form_namespace, 'n');
            echo $header_udt_grid->set_column_auto_size();
            echo $header_udt_grid->enable_column_move();
            echo $header_udt_grid->enable_multi_select();
            echo $header_udt_grid->enable_paging(25, 'pagingArea_' . $tab_id);
            echo $header_udt_grid->return_init();
            echo $header_udt_grid->set_search_filter(true);
            echo $header_udt_grid->set_user_data("", "grid_id", $udt_grid_name);
            echo $header_udt_grid->set_user_data("", "grid_label", $udt_grid_label);
            echo $header_udt_grid->set_user_data("", "grid_obj", $form_namespace . '.' . $udt_grid_name);
            echo $header_udt_grid->attach_event("", "onRowSelect", $form_namespace . '.header_udt_select');
            echo $header_udt_grid->load_grid_data('', $deal_reference_id, false);
            echo $header_udt_grid->load_grid_functions(true);
        }
    }
}

// attach Menu
echo $layout_obj->attach_menu_cell('deal_detail_menu', 'c');
$menu_object = new AdihaMenu();

if ($template_id != 'NULL' || $copy_deal_id != 'NULL') {
    $menu_json = '[  
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id:"actions", text:"Actions", img:"action.gif", imgdis:"action_dis.gif", enabled:'. (int)$has_rights_deal_edit . ', items:[
                        {id:"add_group", text:"Add Group", img:"add.gif", imgdis:"add_dis.gif", title: "Add Group", enabled:true},
                        {id:"add_leg", text:"Add Leg", img:"add.gif", imgdis:"add_dis.gif", title: "Add Leg", enabled:false},
                        {id:"add_container", text:"Add Shipment", img:"add.gif", imgdis:"add_dis.gif", title: "Add Shipment", enabled:false},
                        {id:"add_product", text:"Add Product", img:"add.gif", imgdis:"add_dis.gif", title: "Add Product", enabled:false},
                        {id:"delete_term", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false},
                        {id:"update_volume", text:"Update Volume", img:"update_volume.gif", imgdis:"update_volume_dis.gif", title: "Update Volume", enabled:false}
            ]}';
    if ($enable_pricing == 'y') {
        $menu_json .= ', {id:"price", text:"Price", img:"price.gif", imgdis:"price_dis.gif", title: "Price", enabled:false}
                           , {id:"provisional_price", text:"Provisional Price", img:"price.gif", imgdis:"price_dis.gif", title: "Provisional Price", enabled:false}';
    }
} else {
    $menu_json = '[  
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id:"export", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]},
                    {id:"edit", enabled:'. (int)$has_rights_deal_edit . ', text:"Edit", img:"edit.gif",  imgdis:"edit_dis.gif", items:[
                        {id:"undo_cell", text:"Undo Cell Edit", img:"undo.gif", imgdis:"undo_dis.gif", title: "Undo Cell Edit"},
                        {id:"redo_cell", text:"Redo Cell Edit", img:"redo.gif", imgdis:"redo_dis.gif", title: "Redo Cell Edit"}
                    ]},
                    {id:"actions", text:"Actions", img:"action.gif", imgdis:"action_dis.gif", enabled:'. (int)$has_rights_deal_edit . ', items:[
                        {id:"add_term", text:"Add Term", img:"add.gif", imgdis:"add_dis.gif", title: "Add Term", enabled:false},
                        {id:"add_leg", text:"Add Leg", img:"add.gif", imgdis:"add_dis.gif", title: "Add Leg", enabled:false},
                        {id:"update_volume", text:"Update Volume", img:"update_volume.gif", imgdis:"update_volume_dis.gif", title: "Update Volume", enabled:false},
						{id:"add_container", text:"Add Shipment", img:"add.gif", imgdis:"add_dis.gif", title: "Add Shipment", enabled:false},
                        {id:"add_product", text:"Add Product", img:"add.gif", imgdis:"add_dis.gif", title: "Add Product", enabled:false},
                        {id:"delete_term", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false},
                        {id:"schedule_deal", text:"Schedule Deal", img:"run_view_schedule.gif", imgdis:"run_view_schedule_dis.gif", title: "Schedule Deal", enabled:false},
                        {id:"lock", text:"Lock", img:"lock.gif", imgdis:"lock_dis.gif", title: "Lock", enabled:false},
                        {id:"unlock", text:"Unlock", img:"unlock.gif", imgdis:"unlock_dis.gif", title: "Unlock", enabled:false}
                    ';

    if ($enable_update_actual) {
        $menu_json .= ',{id:"update_actual", text:"Update Actual", img:"update_volume.gif", imgdis:"update_volume_dis.gif", title: "Update Actual", enabled:false}';
    }

    $menu_json .= ']}'; // close actions menu

    // Add report menu
    $menu_json .= ',{id:"reports", text:"Reports", img:"report.gif", items:[
                            {id:"view_certificate", text:"View Certificate", img:"certificate.gif", imgdis:"certificate_dis.gif", title: "View Certificate", enabled:false},
                            {id:"shipper_code_report", text:"Shipper Code Report", img:"report.gif", imgdis:"report_dis.gif", title: "Shipper Code Report", enabled:false},
                            {id:"dashboard_reports", text:"Dashboard Reports", img:"report.gif", imgdis:"report_dis.gif", title: "Dashboard Reports", enabled:true ' . $db_items . '}
                    ]}';

    if ($enable_efp == 'y' || $enable_trigger == 'y' || $enable_exercise == 'y') {
        $menu_json .= ',{id:"process", text:"Process", img:"process.gif", imgdis:"process_dis.gif", enabled:'. (int)$has_rights_deal_edit . ', items:[';

        if ($enable_efp == 'y') {
            if ($future_deal == 'y') {
                $menu_json .= '{id:"close", text:"Close", img:"add.gif", imgdis:"add_dis.gif", title: "Close", enabled:false}';
            } else {
                $menu_json .= '{id:"post", text:"Post", img:"add.gif", imgdis:"add_dis.gif", title: "Post", enabled:false}';
            }
        }

        if ($enable_trigger == 'y') {
            if ($enable_efp == 'y')
                $menu_json .= ',';

            $menu_json .= '{id:"trigger", text:"Trigger", img:"add.gif", imgdis:"add_dis.gif", title: "Trigger", enabled:false}';
        }

        if ($enable_exercise == 'y') {
            if ($enable_efp == 'y' || $enable_trigger == 'y')
                $menu_json .= ',';

            $menu_json .= '{id:"exercise", text:"Exercise", img:"run_view_schedule.gif", imgdis:"run_view_schedule_dis.gif", title: "Exercise", enabled:false}';
        }

        $menu_json .= ']}';
    }

    if ($enable_pricing == 'y') {
        $menu_json .= ', {id:"price", text:"Price", img:"price.gif", imgdis:"price_dis.gif", title: "Price", enabled:false}';
    }

    if ($enable_pricing == 'y') {
        $menu_json .= ', {id:"provisional_price", text:"Provisional Price", img:"price.gif", imgdis:"price_dis.gif", title: "Provisional Price", enabled:false}';
    }
}

if ($enable_detail_udt == 'y') {
    $menu_json .= ', {id:"udt", text:"Additional", img:"data.png", imgdis:"data_dis.png", title: "Additional", enabled: false}';
}

$menu_json .= ']';
    
echo $menu_object->init_by_attach('deal_detail_menu', $form_namespace);
echo $menu_object->load_menu($menu_json);
echo $menu_object->attach_event('', 'onClick', $form_namespace . '.deal_menu_click');

//attach grid
$grid_obj = new AdihaGrid();
echo $layout_obj->attach_grid_cell('grid', 'c');
echo $layout_obj->attach_status_bar("c", true);

echo $grid_obj->init_by_attach('grid', $form_namespace);
echo $grid_obj->enable_column_move();
echo $grid_obj->enable_paging(25, 'pagingArea_c');
echo $grid_obj->attach_event('', 'onEditCell', $form_namespace . '.deal_detail_edit');
echo $grid_obj->load_config_json($detail_data[0]['config_json'], true, $detail_data[0]['header_menu']);
echo $grid_obj->set_column_auto_size();
echo $grid_obj->set_search_filter(false, $detail_data[0]['filter_list']);
echo $grid_obj->set_validation_rule($detail_data[0]['validation_rule']);

echo $grid_obj->attach_event("", "onSelectStateChanged", $form_namespace . '.grid_row_selection');
echo $grid_obj->attach_event("", "onBeforeSelect", $form_namespace . '.grid_before_row_selection');
echo $grid_obj->attach_event("", "onRowDblClicked", $form_namespace . '.grid_row_dbl_click');
echo $grid_obj->attach_event("", "onDragIn", $form_namespace . '.grid_before_drag');
echo $grid_obj->attach_event("", "onRowSelect", $form_namespace . '.on_row_select');

$combo_fields = array();
$combo_fields = explode("||||", $detail_data[0]['combo_list']);
$combo_url_info = $detail_data[0]['combo_list'];

foreach ($combo_fields as $combo_column) {
    $json_array = array();
    $json_array = explode("::::", $combo_column);
    echo $grid_obj->load_connector_combo($json_array[0], $json_array[1]);
}

$apply_pricing_detail = '';
if($enable_pricing == 'y') {
    $apply_pricing_detail = ',{id:"apply_pricing_to", text:"Apply Pricing to", title: "Apply Pricing to"}';
}

$context_menu_json = '[{id:"apply_to", text:"Apply to..", title: "Apply to.."}' . $apply_pricing_detail . ',{id:"new_group", text:"Move to new group", title: "Move to new group"}]';

$context_menu = new AdihaMenu();
echo $context_menu->init_menu('context_menu', $form_namespace);
echo $context_menu->render_as_context_menu();
echo $grid_obj->attach_event('', 'onRightClick', $form_namespace . '.check_context_menu');
echo $context_menu->attach_event('', 'onClick', $form_namespace . '.context_menu_click');
echo $context_menu->load_menu($context_menu_json);

echo $grid_obj->enable_context_menu($form_namespace . '.context_menu');
//echo $grid_obj->load_grid_data($detail_data[0][data_sp], 'g', '', false);
echo $grid_obj->load_grid_functions();

$hide_pricing = 1;
$hide_efp_trigger = 1;

$detail_tab_obj = new AdihaTab();
$detail_tab_data = '[';

// if show in form is active for some fields, add detail tab
if ($detail_data[0]['tab_json'] != '') {
    $detail_tab_data .= $detail_data[0]['tab_json'];
}


/******* Removed pricing tab : Its availble in new popup window from price button in new enhancement.
// enable pricing tab
if ($enable_pricing == 'y') {
if ($detail_data[0][form_json] != '') {
$detail_tab_data .= ',{id:"tab_pricing", text:"Pricing"}';
} else {
$detail_tab_data .= '{id:"tab_pricing", text:"Pricing", active:true}';
}
}

// enable provisional tab
if ($enable_provisional_tab == 'y') {
if ($detail_data[0][form_json] != '' || $enable_pricing == 'y') {
$detail_tab_data .= ',{id:"tab_provisional", text:"Provisional"}';
} else {
$detail_tab_data .= '{id:"tab_provisional", text:"Provisional", active:true}';
}
}
 */
$additional_tabs = '';
// if escalation tab is enabled
if ($enable_escalation_tab == 'y') {
    if ($detail_data[0]['form_json'] != '') {
        $detail_tab_data .= ',{id:"tab_escalation", text:"Escalation"}';
    } else {
        $detail_tab_data .= '{id:"tab_escalation", text:"Escalation", active:true}';
    }
}

// if efp tab is enabled
if ($enable_efp == 'y') {
    if ($detail_data[0]['form_json'] != '' || $enable_escalation_tab == 'y') {
        $detail_tab_data .= ',{id:"tab_efp", text:"Future"}';
    } else {
        $detail_tab_data .= '{id:"tab_efp", text:"Future", active:true}';
    }
}

// if trigger tab is enabled
if ($enable_trigger == 'y') {
    if ($detail_data[0]['form_json'] != '' || $enable_efp == 'y' || $enable_escalation_tab == 'y') {
        $detail_tab_data .= ',{id:"tab_trigger", text:"Trigger"}';
    } else {
        $detail_tab_data .= '{id:"tab_trigger", text:"Trigger", active:true}';
    }
}

// if efp Exercise is enabled
if ($enable_exercise == 'y') {
    if ($detail_data[0]['form_json'] != '' || $enable_efp == 'y' || $enable_trigger == 'y' || $enable_escalation_tab == 'y') {
        $detail_tab_data .= ',{id:"tab_exercise", text:"Exercise Deal"}';
    } else {
        $detail_tab_data .= '{id:"tab_exercise", text:"Exercise Deal", active:true}';
    }
}

// if efp detail cost is enabled
if ($detail_cost_enable == 'y') {
    if ($detail_data[0]['form_json'] != '' || $enable_efp == 'y' || $enable_trigger == 'y' || $enable_exercise == 'y' || $enable_escalation_tab == 'y') {
        $detail_tab_data .= ',{id:"tab_detail_cost", text:"Cost"}';
    } else {
        $detail_tab_data .= '{id:"tab_detail_cost", text:"Cost", active:true}';
    }
}

if ($enable_udf_tab == 'y' && $deal_id != 'NULL') {
    // add udf tab
    if ($detail_cost_enable == 'y' || $detail_data[0]['form_json'] != '' || $enable_efp == 'y' || $enable_trigger == 'y' || $enable_exercise == 'y' || $enable_escalation_tab == 'y') {
        $detail_tab_data .= ',{id:"tab_detail_udf", text:"UDFs"}';
    } else {
        $detail_tab_data .= '{id:"tab_detail_udf", text:"UDFs", active:true}';
    }
}

$detail_tab_data .= ']';

echo $layout_obj->attach_tab_cell('deal_detail_tab', 'b', $detail_tab_data);
echo $detail_tab_obj->init_by_attach('deal_detail_tab', $form_namespace);

if ($enable_trigger == 'y') {
    $trigger_layout = new AdihaLayout();
    echo $detail_tab_obj->attach_layout('trigger_layout', 'tab_trigger', '1C');
    $trigger_layout->init_by_attach('trigger_layout', $form_namespace);
    echo $trigger_layout->hide_header('a');
    echo $trigger_layout->attach_grid_cell('deal_triggers', 'a');
    echo $trigger_layout->attach_status_bar("a", true);
    $trigger_grid_obj = new GridTable('deal_triggers');
    echo $trigger_grid_obj->init_grid_table('deal_triggers', $form_namespace, 'n');
    echo $trigger_grid_obj->set_column_auto_size();
    echo $trigger_grid_obj->set_search_filter(true, "");
    echo $trigger_grid_obj->enable_paging(50, 'pagingArea_a', 'true');
    echo $trigger_grid_obj->enable_column_move();
    echo $trigger_grid_obj->enable_multi_select();
    echo $trigger_grid_obj->return_init();

    $sp_trigger_grid = "EXEC spa_efp_trigger @flag='g', @deal_id=" . $deal_id;
    echo $trigger_grid_obj->load_grid_data($sp_trigger_grid);
}

if ($enable_efp == 'y') {
    $efp_layout = new AdihaLayout();
    echo $detail_tab_obj->attach_layout('efp_layout', 'tab_efp', '1C');
    $efp_layout->init_by_attach('efp_layout', $form_namespace);
    echo $efp_layout->hide_header('a');
    echo $efp_layout->attach_grid_cell('deal_efp', 'a');
    echo $efp_layout->attach_status_bar("a", true);
    $efp_grid_obj = new GridTable('deal_efp');
    echo $efp_grid_obj->init_grid_table('deal_efp', $form_namespace, 'n');
    echo $efp_grid_obj->set_column_auto_size();
    echo $efp_grid_obj->set_search_filter(true, "");
    echo $efp_grid_obj->enable_paging(50, 'pagingArea_a', 'true');
    echo $efp_grid_obj->enable_column_move();
    echo $efp_grid_obj->enable_multi_select();
    echo $efp_grid_obj->return_init();

    if ($future_deal == 'y') {
        $sp_efp_grid = "EXEC spa_deal_close @flag='p', @deal_id=" . $deal_id;
    } else {
        $sp_efp_grid = "EXEC spa_efp_trigger @flag='h', @deal_id=" . $deal_id;
    }
    echo $efp_grid_obj->load_grid_data($sp_efp_grid);
}

if ($enable_exercise == 'y') {
    $exercise_menu = new AdihaMenu();
    $exercise_json = '[  
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:true}                       
                    ]';
    echo $detail_tab_obj->attach_menu_cell('exercise_menu', 'tab_exercise');
    echo $exercise_menu->init_by_attach('exercise_menu', $form_namespace);
    echo $exercise_menu->load_menu($exercise_json);
    echo $exercise_menu->attach_event('', 'onClick', $form_namespace . '.exercise_menu_click');

    $exercise_layout = new AdihaLayout();
    echo $detail_tab_obj->attach_layout('exercise_layout', 'tab_exercise', '1C');
    $exercise_layout->init_by_attach('exercise_layout', $form_namespace);
    echo $exercise_layout->hide_header('a');
    echo $exercise_layout->attach_grid_cell('deal_exercise', 'a');
    $exercise_grid_obj = new GridTable('deal_exercise');
    echo $exercise_grid_obj->init_grid_table('deal_exercise', $form_namespace, 'n');
    echo $exercise_grid_obj->return_init();
}

/******* Removed pricing tab : Its availble in new popup window from price button in new enhancement.
if ($enable_pricing == 'y') {
echo $detail_tab_obj->attach_url('tab_pricing', 'deal.pricing.php?pricing_provisional=p');
}

if ($enable_provisional_tab == 'y') {
echo $detail_tab_obj->attach_url('tab_provisional', 'deal.pricing.php?pricing_provisional=q');
}
 */
if ($enable_escalation_tab == 'y') {
    // escalation tab
    $escalation_menu = new AdihaMenu();

    $escalation_json = '[  
                        {id:"refresh", text:"Refresh", img:"refresh.gif", enabled:false, imgdis:"refresh_dis.gif", title: "Refresh"},
                        {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                            {id:"add", text:"Add", img:"new.gif", enabled:false ,imgdis:"new_dis.gif", title: "Add"},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false},
                        ]}                       
                    ]';
    echo $detail_tab_obj->attach_menu_cell('escalation_menu', 'tab_escalation');
    echo $escalation_menu->init_by_attach('escalation_menu', $form_namespace);
    echo $escalation_menu->load_menu($escalation_json);
    echo $escalation_menu->attach_event('', 'onClick', $form_namespace . '.escalation_menu_click');

    // escalation grid
    echo $detail_tab_obj->attach_grid_cell('deal_escalation', 'tab_escalation');
    $deal_escalation = new GridTable('deal_escalation');
    echo $deal_escalation->init_grid_table('deal_escalation', $form_namespace, 'n');
    echo $deal_escalation->set_column_auto_size();
    echo $deal_escalation->enable_column_move();
    echo $deal_escalation->enable_multi_select();
    echo $deal_escalation->return_init();
    echo $deal_escalation->enable_cell_edit_events("true", "true", "true");
    echo $deal_escalation->attach_event("", "onSelectStateChanged", $form_namespace . '.deal_escalation_selection');
}

if ($detail_cost_enable != 'n' && $detail_cost_enable != '') {
    $detail_cost_layout = new AdihaLayout();
    echo $detail_tab_obj->attach_layout('detail_cost_layout', 'tab_detail_cost', '2E');
    $detail_cost_layout->init_by_attach('detail_cost_layout', $form_namespace);
    echo $detail_cost_layout->hide_header('a');
    echo $detail_cost_layout->hide_header('b');
    echo $detail_cost_layout->set_cell_height('a', 30);
    echo $detail_cost_layout->set_cell_height('b', 650);

    $form_structure = "[
            {type:'calendar', name:'term_start', label:'Term Start', position:'label-top', inputWidth:200, offsetLeft: 15, dateFormat:'$date_format', serverDateFormat: '%Y-%m-%d'},
            {type:'newcolumn'},
            {type:'calendar', name:'term_end', label:'Term End', position:'label-top', inputWidth:200, offsetLeft: 15, dateFormat:'$date_format', serverDateFormat: '%Y-%m-%d'},
            {type:'newcolumn'},
            {type:'combo', name:'leg', label:'Leg', position:'label-top', inputWidth:200, offsetLeft: 15, options:[{'value':'','text':'','state':'','selected':'true'},{'value':'1','text':'1','state':''},{'value':'2','text':'2','state':''},{'value':'3','text':'3','state':''},{'value':'4','text':'4','state':''},{'value':'5','text':'5','state':''},{'value':'6','text':'6','state':''},{'value':'7','text':'7','state':''},{'value':'8','text':'8','state':''},{'value':'9','text':'9','state':''},{'value':'10','text':'10','state':''},{'value':'11','text':'11','state':''},{'value':'12','text':'12','state':''}]}
        ]";

    $filter_name = 'detail_cost_filter_form';
    echo $detail_cost_layout->attach_form($filter_name, 'a');
    $filter_obj = new AdihaForm();
    echo $filter_obj->init_by_attach($filter_name, $form_namespace);
    echo $filter_obj->load_form($form_structure);

    $detail_cost_menu_json = '[
            {id:"refresh", img:"refresh.gif", text:"Refresh", title:"Refresh"},
            {id:"add", text:"Add/Delete Costs", title: "Add/Delete Costs", img:"edit.gif", imgdis:"edit_dis.gif"}
        ]';

    $detail_cost_menu = new AdihaMenu();
    echo $detail_cost_layout->attach_menu_cell('detail_cost_menu', 'b');
    echo $detail_cost_menu->init_by_attach('detail_cost_menu', $form_namespace);
    echo $detail_cost_menu->load_menu($detail_cost_menu_json);
    echo $detail_cost_menu->attach_event('', 'onClick', $form_namespace . '.detail_cost_menu_click');

    echo $detail_cost_layout->attach_grid_cell('deal_detail_cost', 'b');

    $context_menu_json = '[{id: "apply_to_all", text: "Apply to all"}]';
    $context_menu = new AdihaMenu();
    echo $context_menu->init_menu('grid_context_menu', $form_namespace);
    echo $context_menu->render_as_context_menu();
    echo $context_menu->load_menu($context_menu_json);
    echo $context_menu->attach_event('', 'onClick', $form_namespace . '.udf_cost_context_menu_click');

    $deal_detail_cost = new GridTable('deal_detail_cost');
    echo $deal_detail_cost->init_grid_table('deal_detail_cost', $form_namespace, 'n');
    echo $deal_detail_cost->set_column_auto_size();
    echo $deal_detail_cost->enable_column_move();
    echo $deal_detail_cost->enable_multi_select();
    echo $deal_detail_cost->enable_context_menu($form_namespace . '.grid_context_menu');
    echo $deal_detail_cost->attach_event("", "onBeforeSelect", $form_namespace . '.detail_cost_select');
    echo $deal_detail_cost->attach_event("", "onEditCell", $form_namespace . '.detail_cost_edit');
    echo $deal_detail_cost->return_init();
}

if ($enable_udf_tab == 'y' && $deal_id != 'NULL') {
    // add menu and form on detail UDF tab
    $detail_udf_menu = new AdihaMenu();
    echo $detail_tab_obj->attach_menu_cell('detail_udf_menu', 'tab_detail_udf');
    echo $detail_udf_menu->init_by_attach('detail_udf_menu', $form_namespace);
    echo $detail_udf_menu->load_menu($udf_menu_json);
    echo $detail_udf_menu->attach_event('', 'onClick', $form_namespace . '.detail_udf_menu_click');

    echo $detail_tab_obj->attach_form_cell('detail_udf_form', 'tab_detail_udf');
    $detail_udf_form = new AdihaForm();
    echo $detail_udf_form->init_by_attach('detail_udf_form', $form_namespace);
}

if ($detail_data[0]['form_json'] != '') {
    $detail_tab_array = array();
    $detail_tab_array = explode(',', $detail_data[0]['tab_ids']);
    $form_obj['details_tab'] = new AdihaForm();
    $cnt = 0;
    foreach ($detail_tab_array as $value) {
        $rel_array = array();
        $rel_array = explode("::", $value);

        if ($cnt == 0) {
            echo $detail_tab_obj->attach_form_cell('form_details_tab', $rel_array[0]);
            echo $form_obj['details_tab']->init_by_attach('form_details_tab', $form_namespace);
            echo $form_obj['details_tab']->load_form($detail_data[0]['form_json']);
            echo $detail_tab_obj->set_active_tab($rel_array[0]);
        } else {
            echo $detail_tab_obj->attach_object($rel_array[0], $rel_array[1]);
        }
        $cnt++;
    }

    echo $form_obj['details_tab']->attach_event('', 'onChange', $form_namespace . '.detail_form_change');
    // echo $form_obj['details_tab']->attach_event('', 'onFocus', $form_namespace . '.detail_form_onfocus');
    //echo $form_obj['details_tab']->attach_event('', 'onBlur', $form_namespace . '.detail_form_onblur');

    $hide_pricing = 0;
}

// header costs
if ($header_cost_enable != 'n' && $header_cost_enable != '') {
    echo $tab_obj->attach_grid_cell('header_deal_costs', $header_cost_enable);

    if ($view_deleted == 'y') {
        $cost_menu_json = '[{id:"add", text:"Add/Delete Costs", title: "Add/Delete Costs", img:"edit.gif", imgdis:"edit_dis.gif", enabled:false}]';
    } else {
        $cost_menu_json = '[{id:"add", text:"Add/Delete Costs", title: "Add/Delete Costs", img:"edit.gif", imgdis:"edit_dis.gif"}]';
    }
    $header_cost_menu = new AdihaMenu();
    echo $tab_obj->attach_menu_cell('header_cost_menu', $header_cost_enable);
    echo $header_cost_menu->init_by_attach('header_cost_menu', $form_namespace);
    echo $header_cost_menu->load_menu($cost_menu_json);
    echo $header_cost_menu->attach_event('', 'onClick', $form_namespace . '.header_cost_menu_click');

    $header_deal_costs = new GridTable('deal_costs');
    echo $header_deal_costs->init_grid_table('header_deal_costs', $form_namespace, 'n');
    echo $header_deal_costs->set_column_auto_size();
    echo $header_deal_costs->enable_column_move();
    echo $header_deal_costs->enable_multi_select();
    echo $header_deal_costs->return_init();
    echo $header_deal_costs->enable_header_menu("true,true,true,true,true,true");
    echo $header_deal_costs->set_search_filter(true);
    echo $header_deal_costs->attach_event("", "onBeforeSelect", $form_namespace . '.header_cost_select');
    echo $header_deal_costs->attach_event('', 'onEditCell', $form_namespace . '.header_cost_edit');

    $sp_cost_grid = $grid_sql[$header_cost_enable];
    echo $header_deal_costs->load_grid_data($sp_cost_grid, '', false, $form_namespace . '.header_cost_onload');

}

if ($enable_prepay_tab == 'y' && $insert_mode != true) {
    echo $tab_obj->attach_grid_cell('header_deal_prepay', '-1');

    $prepay_menu_json = '
            [
                {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                        {id:"add", text:"Add", img:"new.gif", enabled:false ,imgdis:"new_dis.gif", title: "Add",enabled:true},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false},
                ]} 
            ]
        ';

    $header_prepay_menu = new AdihaMenu();
    echo $tab_obj->attach_menu_cell('header_prepay_menu', '-1');
    echo $header_prepay_menu->init_by_attach('header_prepay_menu', $form_namespace);
    echo $header_prepay_menu->load_menu($prepay_menu_json);
    echo $header_prepay_menu->attach_event('', 'onClick', $form_namespace . '.prepay_menu_click');

    $header_deal_prepay = new GridTable('DealPrepay');
    echo $header_deal_prepay->init_grid_table('header_deal_prepay', $form_namespace, 'n');
    echo $header_deal_prepay->set_column_auto_size();
    echo $header_deal_prepay->enable_column_move();
    echo $header_deal_prepay->enable_multi_select();
    echo $header_deal_prepay->set_search_filter(false, "#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
    echo $header_deal_prepay->return_init();
    echo $header_deal_prepay->attach_event("", "onRowSelect", $form_namespace . '.header_prepay_select');

    $sp_prepay_grid = "EXEC spa_source_deal_prepay 's', " . $deal_id;
    echo $header_deal_prepay->load_grid_data($sp_prepay_grid, '', false, $form_namespace . '.header_prepay_onload');
}

if ($document_enable == 'y') {
    // document tab
    echo $tab_obj->add_tab('document_tab', 'Documents');

    $document_menu = new AdihaMenu();

    $document_json = '[  
                        {id:"refresh", text:"Refresh", img:"refresh.gif", enabled:true, imgdis:"refresh_dis.gif", title: "Refresh"},
                        {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                            {id:"add", text:"Add", img:"new.gif", enabled:true ,imgdis:"new_dis.gif", title: "Add"},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false},
                        ]}                      
                    ]';

    echo $tab_obj->attach_menu_cell('document_menu', 'document_tab');
    echo $document_menu->init_by_attach('document_menu', $form_namespace);
    echo $document_menu->load_menu($document_json);
    echo $document_menu->attach_event('', 'onClick', $form_namespace . '.document_menu_click');

    echo $tab_obj->attach_grid_cell('deal_documents', 'document_tab');
    $deal_documents = new GridTable('deal_documents');
    echo $deal_documents->init_grid_table('deal_documents', $form_namespace, 'n');
    echo $deal_documents->set_column_auto_size();
    echo $deal_documents->enable_column_move();
    echo $deal_documents->enable_multi_select();
    echo $deal_documents->return_init();
    echo $deal_documents->enable_header_menu("true,true,true");
    //echo $deal_documents->attach_event('', 'onRowDblClicked', $form_namespace . '.update_deal_required_doc');
    echo $deal_documents->attach_event('', 'onSelectStateChanged', $form_namespace . '.doc_selected');

}

if ($enable_remarks == 'y') {
    // remarks tab
    echo $tab_obj->add_tab('tab_remarks', 'Remarks');

    $remarks_menu = new AdihaMenu();

    $remarks_json = '[  
                        {id:"refresh", text:"Refresh", img:"refresh.gif", enabled:true, imgdis:"refresh_dis.gif", title: "Refresh"},
                        {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                            {id:"add", text:"Add pre defined remarks", img:"new.gif", enabled:true ,imgdis:"new_dis.gif", title: "Add pre defined remarks"},
                            {id:"add_new", text:"Add new remarks", img:"new.gif", enabled:true ,imgdis:"new_dis.gif", title: "Add new remarks"},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false},
                        ]}                      
                    ]';
    echo $tab_obj->attach_menu_cell('remarks_menu', 'tab_remarks');
    echo $remarks_menu->init_by_attach('remarks_menu', $form_namespace);
    echo $remarks_menu->load_menu($remarks_json);
    echo $remarks_menu->attach_event('', 'onClick', $form_namespace . '.remarks_menu_click');

    echo $tab_obj->attach_grid_cell('deal_remarks', 'tab_remarks');
    $deal_remarks = new GridTable('deal_remarks');
    echo $deal_remarks->init_grid_table('deal_remarks', $form_namespace, 'n');
    echo $deal_remarks->set_column_auto_size();
    echo $deal_remarks->enable_column_move();
    echo $deal_remarks->enable_multi_select();
    echo $deal_remarks->return_init();
    echo $deal_remarks->enable_header_menu("true,true");
    echo $deal_remarks->attach_event('', 'onSelectStateChanged', $form_namespace . '.remarks_selected');
    echo $deal_remarks->attach_event('', 'onEditCell', $form_namespace . '.remarks_edit');
}

echo $layout_obj->close_layout();

$category_data = array();
if ($template_id == 'NULL') {
    $category_name = 'Deal';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);
}

$detail_formula_fields = $detail_data[0]['detail_formula_field'];
$formula_process_id = ($detail_data[0]['formula_process_id'] == '') ? 'NULL' : $detail_data[0]['formula_process_id'];

if ($template_id != 'NULL' || $copy_deal_id != 'NULL') {
    $process_id = $detail_data[0]['process_id'];
} else {
    $process_id = 'NULL';
}

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
            {type: "combo", position: "label-top", offsetLeft: "15", label: "<a id=\"exist_formula\" href=\"javascript:void(0);\" onclick=\"call_TRMWinHyperlink(10102400,this.id, formula_form);\">Formula</a>", name: "exist_formula", "filtering": "true", "filtering_mode": "between", "labelWidth":180, "inputWidth":180, options:' . $formula_dropdown_json . '}, 
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
        {"type": "hidden", "name": "leg", "label": "Leg"},
        {"type": "hidden", "name": "deal_id", "label": "DetailID"}
    ]';

    //Get valuation index mapped in location
    if ($insert_mode) {
        $sp_url = "EXEC spa_source_deal_header @flag = 'q', @commodity_id = " . $commodity_id . ",@deal_ids=" . $deal_id ;
        $result_value = readXMLURL2($sp_url);
        $valuation_index_json = $result_value[0]['valuation_index_json'];
    } else {
        $valuation_index_json = "{}";
    }

?>
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
</body>
<textarea style="display:none" name="txt_save_status" id="txt_save_status">cancel</textarea>
<script type="text/javascript">
    var php_script_loc = '<?php echo $app_php_script_loc; ?>';
    var category_id = "<?php echo $category_data[0]['value_id'] ?? '';?>";
    var template_id = '<?php echo $template_id;?>';
    var apply_to_window;
    var document_window;
    var hide_pricing = '<?php echo $hide_pricing;?>';
    var enable_efp = '<?php echo $enable_efp;?>';
    var enable_trigger = '<?php echo $enable_trigger;?>';
    var future_deal = '<?php echo $future_deal;?>';
    var copy_deal_id = '<?php echo $copy_deal_id;?>';
    var enable_pricing = '<?php echo $enable_pricing; ?>';
    var enable_provisional_tab = '<?php echo $enable_provisional_tab; ?>';
    var enable_escalation_tab = '<?php echo $enable_escalation_tab; ?>';
    var detail_cost_enable = '<?php echo $detail_cost_enable; ?>';
    var certificate = '<?php echo $certificate?>';
    var document_enable = '<?php echo $document_enable; ?>';
    var copy_insert_mode = '<?php echo $copy_insert_mode; ?>';
    var enable_remarks = '<?php echo $enable_remarks;?>';
    var group_name_win;
    var soft_commodity = Boolean('<?php echo $soft_commodity; ?>');
    var deal_trade_locked = '<?php echo $deal_trade_locked;?>';
    var enable_save_button = '<?php echo $enable_save_button;?>';
    var enable_location = true;
    var enable_exercise = '<?php echo $enable_exercise;?>';
    var exercise_window;
    var is_shaped = '<?echo $is_shaped; ?>';
    var process_id = '<?php echo $process_id;?>';
    var shaped_granularity = '';
    var shaped_created = 'n';
    var header_formula_fields = '<?php echo $header_formula_fields; ?>';
    var detail_formula_fields = '<?php echo $detail_formula_fields; ?>';
    var header_formula_array = new Array();
    var detail_formula_array = new Array();
    var detail_formula_popup, detail_formula_layout, formula_form, formula_field_form;
    var formula_process_id = '<?php echo $formula_process_id; ?>';
    //var is_capacity = '<?php //echo $is_capacity;?>';
    var enable_udf_tab = '<?php echo $enable_udf_tab;?>';
    var enable_detail_udf_tab = 'n';
    var deal_type = '<?php echo $deal_type;?>';
    var deal_type_text = '<?php echo $deal_type_text;?>';
    var is_environmental = '<?php echo $is_environmental;?>';
    var enable_product_button = '<?php echo $enable_product_button;?>';
    var enable_certificate_button= '<?php echo $enable_certificate_button;?>';
    // var enable_environment = '<?php //echo $enable_environment;?>';
    var volume_type = '<?php echo $volume_type; ?>';
    var profile_gran_with_meter = '<?php echo $profile_gran_with_meter; ?>';
    var insert_mode = '<?php echo $insert_mode; ?>';
    var deal_price_data_process_id = '';
    var deal_provisional_price_data_process_id= '';
    var copy_price_process_id = '<?php echo $copy_price_process_id; ?>';
    var enable_prepay_tab = '<?php echo $enable_prepay_tab; ?>';
    var deal_id = '<?php echo $deal_id; ?>';
    var header_prepay_xml = 'NULL';
    var prepay_delete_check = 0;
    var copy_provisional_price_process_id = '<?php echo $copy_provisional_price_process_id; ?>';
    var valuation_index_json = '<?php echo $valuation_index_json; ?>';
    var valuation_index_obj = JSON.parse(valuation_index_json);
    enable_detail_udf_tab = (enable_udf_tab == 'y' && deal_id != 'NULL') ? 'y' : 'n';
    var save_all_detail_cost_udf = 0;
    var combo_url_info = '<?php echo $combo_url_info; ?>';
    var combo_list = '<?php echo $detail_data[0]['combo_list']; ?>';
	var has_rights_transfer = Boolean('<?php echo $has_rights_transfer; ?>');
    var deal_reference_id = '<?php echo $deal_reference_id; ?>';
    var enable_header_udt = '<?php echo $enable_header_udt; ?>';

    if (header_formula_fields != '' && header_formula_fields != null) {
        header_formula_array = header_formula_fields.split(',');
    }

    if (detail_formula_fields != '' && detail_formula_fields != null) {
        detail_formula_array = detail_formula_fields.split(',');
    }

    dealDetail.deleted_details = new Array();

    if (copy_insert_mode == 'y') {
        document.getElementById("txt_save_status").value = 'save';
    }

    $(function() {
        var has_document_rights = '<?php echo (int)$has_document_rights;?>';
        var deal_id = '<?php echo $deal_id; ?>';
        dhxWins = new dhtmlXWindows();

        if (deal_id != 'NULL' && copy_insert_mode != 'y') {
            var win_id = 'w_' + deal_id;

            if (window.parent.update_window) {
                var win_obj = window.parent.update_window.window(win_id);
            } else if (window.parent.dhx_wins) {
                var win_obj = window.parent.dhx_wins.getTopmostWindow();
            } else if (window.parent.dhxWins) {
                var win_obj = window.parent.dhxWins.getTopmostWindow();
            }
            var win_text = '';
            if (win_obj) {
                win_text = win_obj.getText();
            }
            if (win_obj && $.trim(win_text).substring(0, 4) == 'Deal') {
                win_obj.progressOn();
            }
        } else if (copy_deal_id != 'NULL' || template_id != 'NULL' || copy_insert_mode == 'y') {
            var win_obj = window.parent.deal_insert_window.window("w1");
            if (win_obj) {
                win_obj.progressOn();
            }
        }

        if (deal_id != 'NULL') {
            add_manage_document_button(deal_id, dealDetail.toolbar, has_document_rights);
        }


        if (copy_deal_id != 'NULL' ) {
            data = {"action": "spa_deal_update_new", "flag":"check_environmental", "source_deal_header_id":copy_deal_id};
            adiha_post_data("return", data, '', '', 'dealDetail.check_environmental');
        }

        if (is_environmental == 'y') { //enabled Product button only for REC deals
            dealDetail.toolbar.enableItem('product');
            dealDetail.toolbar.enableItem('certificate');
        } else {
            dealDetail.toolbar.disableItem('product');
            dealDetail.toolbar.disableItem('certificate');
        }

        if (enable_product_button == 'true') { //enabled Product button only for REC deals
            dealDetail.toolbar.enableItem('product');
            //dealDetail.toolbar.enableItem('certificate');
        }


        if (enable_certificate_button == 'true'){
            dealDetail.toolbar.enableItem('certificate');
        }
		
		if (deal_id != 'NULL'){
			if (has_rights_transfer) dealDetail.toolbar.enableItem('transfer');
		} else { 
            dealDetail.toolbar.disableItem('transfer');
        }

        dealDetail.grid.enableEditEvents(true,false,true);
        dealDetail.grid.setDateFormat(user_date_format, "%Y-%m-%d");
        dealDetail.grid.setUserData("", 'formula_id', 10211093);
        dealDetail.grid.enableColumnMove(true);
        dealDetail.grid.enableTreeCellEdit(false);
        dealDetail.grid.enableDragAndDrop(true);
        dealDetail.grid.enableTreeGridLines();
        dealDetail.grid.i18n.decimal_separator = global_decimal_separator;
        dealDetail.grid.i18n.group_separator = global_group_separator;
        dealDetail.grid.attachEvent("onBeforeCMove",function(cInd, newPos){
            var col_type = dealDetail.grid.getColType(0);
            if (col_type == "tree") {
                if (cInd < 3 || newPos < 3) return false;
                else return true;
            } else {
                if (cInd < 2 || newPos < 2) return false;
                else return true;
            }
        });
        dealDetail.grid.enableUndoRedo();

        if (copy_deal_id != 'NULL') {
            dealDetail.grid.attachEvent("onXLE", function(grid_obj, count){
                var xml = '<root>';
                var term_start_idx = grid_obj.getColIndexById('term_start');
                var term_end_idx = grid_obj.getColIndexById('term_end');
                var leg_idx = grid_obj.getColIndexById('blotterleg');

                if (term_start_idx != undefined && term_end_idx != undefined) {
                    grid_obj.forEachRow(function(id) {
                        xml += '<deal_details  source_deal_detail_id="' +  grid_obj.cells(id, grid_obj.getColIndexById('source_deal_detail_id')).getValue() + '" ';
                        xml += ' term_start="' +  grid_obj.cells(id, term_start_idx).getValue() + '" ';
                        xml += ' term_end="' +  grid_obj.cells(id, term_end_idx).getValue() + '" ';
                        xml += ' blotterleg="' +  grid_obj.cells(id, leg_idx).getValue() + '" />';
                    });

                    xml += '</root>';

                    var data = {
                        "action":"spa_deal_pricing_detail",
                        "flag": "k",
                        "xml_process_id": copy_price_process_id,
                        "xml": xml,
                        "source_deal_detail_id": copy_deal_id
                    }

                    adiha_post_data("return_array", data, '', '', '');
                    deal_price_data_process_id = copy_price_process_id;

                    var data_provisional = {
                        "action":"spa_deal_pricing_detail_provisional",
                        "flag": "k",
                        "xml_process_id": copy_provisional_price_process_id,
                        "xml": xml,
                        "source_deal_detail_id": copy_deal_id
                    }

                    adiha_post_data("return_array", data_provisional, '', '', '');
                    deal_provisional_price_data_process_id = copy_provisional_price_process_id;
                }
            });
        }

        if (deal_id == 'NULL') {
            setTimeout(function() {
                dealDetail.deal_menu_click('refresh');
            }, 1000);
        } else {
            dealDetail.deal_menu_click('refresh');
        }

        dealDetail.resize_layout();

        if (dealDetail.form_details_tab) {
            var form_data = dealDetail.form_details_tab.getFormData();
            for (var a in form_data) {
                var type = dealDetail.form_details_tab.getItemType(a);

                if (type == 'combo') {
                    dealDetail.form_details_tab.setItemFocus(a);
                }
            }
        }

        dealDetail.deal_detail.cells("b").showHeader();
        dealDetail.deal_detail.cells("b").collapse();

        if (hide_pricing == 1 && (enable_detail_udf_tab == 'n' && enable_efp == 'n' && enable_trigger == 'n' && enable_pricing == 'n' && enable_exercise == 'n' && enable_escalation_tab == 'n' && enable_provisional_tab == 'n' && detail_cost_enable == 'n')) {
            dealDetail.deal_detail.cells("b").hideHeader();
            dealDetail.deal_detail.cells("b").hideArrow();
        }



        if (document_enable == 'y') {
            dealDetail.refresh_document_grid();
        }

        if (enable_remarks == 'y') {
            dealDetail.refresh_remarks_grid();
        }

        if (soft_commodity) {
            dealDetail.deal_detail_menu.hideItem('add_leg');

            if (deal_id != 'NULL')
                dealDetail.deal_detail_menu.hideItem('add_term');

            if (deal_id == 'NULL')
                dealDetail.deal_detail_menu.hideItem('add_group');
        }

        if (enable_save_button == 'false') {
            var tab_obj = dealDetail.deal_tab;

            tab_obj.forEachTab(function(tab) {
                var form_obj = tab.getAttachedObject();

                if (form_obj instanceof dhtmlXForm) {
                    var deal_lock_combo = form_obj.getCombo('deal_locked');
                    if (deal_lock_combo)
                        form_obj.setItemValue('deal_locked','y');
                }
            });
        }

        dealDetail.deal_detail.attachEvent("onDblClick", function(name){
            return;
        });

        if (insert_mode != 1 && enable_prepay_tab == 'y') {
            dealDetail.header_deal_prepay.attachEvent("onEditCell", function(stage, rid, cInd, nValue, oValue){
                var prepay_index = dealDetail.header_deal_prepay.getColIndexById('prepay');

                if (cInd == prepay_index && stage == 2) {
                    var value_index = dealDetail.header_deal_prepay.getColIndexById('value');
                    var prepay_id = dealDetail.header_deal_prepay.cells(rid, prepay_index).getValue();
                    var percentage_index = dealDetail.header_deal_prepay.getColIndexById('percentage');
                    var formula_id_index = dealDetail.header_deal_prepay.getColIndexById('formula_id');
                    var formula_name_index = dealDetail.header_deal_prepay.getColIndexById('formula_name');
                    var b = prepay_properties.filter(function(e) {
                        return e[0] == prepay_id;
                    });

                    var field_type = b[0][1];
                    var internal_type = b[0][2];

                    if (field_type == 'w') {
                        dealDetail.header_deal_prepay.cells(rid, value_index).setDisabled(true);
                        dealDetail.header_deal_prepay.cells(rid, percentage_index).setDisabled(true);
                        dealDetail.header_deal_prepay.cells(rid, value_index).setValue('');
                        dealDetail.header_deal_prepay.cells(rid, percentage_index).setValue('');
                    } else if (field_type != 'w' && internal_type == 18736) {
                        dealDetail.header_deal_prepay.cells(rid, value_index).setDisabled(true);
                        dealDetail.header_deal_prepay.cells(rid, percentage_index).setDisabled(false);
                        dealDetail.header_deal_prepay.cells(rid, value_index).setValue('');
                        dealDetail.header_deal_prepay.cells(rid, formula_id_index).setValue('');
                        dealDetail.header_deal_prepay.cells(rid, formula_name_index).setValue('');
                    } else if (field_type != 'w' && internal_type == 18724) {
                        dealDetail.header_deal_prepay.cells(rid, percentage_index).setDisabled(true);
                        dealDetail.header_deal_prepay.cells(rid, value_index).setDisabled(false);
                        dealDetail.header_deal_prepay.cells(rid, percentage_index).setValue('');
                        dealDetail.header_deal_prepay.cells(rid, formula_id_index).setValue('');
                        dealDetail.header_deal_prepay.cells(rid, formula_name_index).setValue('');
                    }
                }

                return true;
            });
        }

        // Custom filter logic for columns having field type combo. Searches by combo label instead of value.
        dealDetail.grid.attachEvent("onXLE", function(grid_obj, count) {
            combo_list.split('||||').forEach(function(value) {
                var column_id = value.split('::::')[0];
                if (column_id) {
                    var col_ind = dealDetail.grid.getColIndexById(column_id);
                    dealDetail.grid.getFilterElement(col_ind)._filter = function() {
                        var input = this.value;
                        if (input) {
                            return function(value, id) {
                                var combo = dealDetail.grid.getColumnCombo(col_ind);
                                var combo_value = dealDetail.grid.cells(id, col_ind).getValue();

                                if (combo.getOption(combo_value)) {
                                    var combo_text = combo.getOption(combo_value).text;
                                    if (combo_text.toLowerCase().indexOf(input.toLowerCase())!==-1){ 
                                        return true;
                                    }
                                }
                                return false;
                            }
                        } else {
                            return false;
                        }
                    }
                }
            });
            // Expand all columns otherwise filtered data will be in collapsed state
            dealDetail.grid.expandAll();
        });
    });

    dealDetail.prepay_menu_click = function(name) {
        if(name == 'add') {
            var values_array = [];
            var new_id = (new Date()).valueOf();
            dealDetail.header_deal_prepay.addRow(new_id, '', 0);
        } else if (name == 'delete') {
            prepay_delete_check = 1;
            var row_id = dealDetail.header_deal_prepay.getSelectedRowId();
            //dealDetail.header_deal_prepay.deleteRow(row_id);
            dealDetail.header_deal_prepay.deleteSelectedRows();
        } else if (name == 'refresh') {
            var sql_param = {
                'sql': 'EXEC spa_source_deal_prepay @flag="s", @source_deal_header_id=' + deal_id,
                'grid_type': 'g'
            };

            sql_param = $.param(sql_param);

            var sql_url = js_data_collector_url + '&' + sql_param;

            if (insert_mode != 1){
                dealDetail.header_deal_prepay.clearAll();
                dealDetail.header_deal_prepay.loadXML(sql_url);
            }

        }

        return 0;
    }

    dealDetail.header_prepay_onload = function() {
        var data = {
            "action":"spa_source_deal_prepay",
            "flag":"j"
        }

        adiha_post_data("return_array", data, '', '', 'dealDetail.load_callback');
    }

    dealDetail.load_callback = function(result_set) {
        prepay_properties = result_set;
        var prepay_index = dealDetail.header_deal_prepay.getColIndexById('prepay');
        var value_index = dealDetail.header_deal_prepay.getColIndexById('value');
        var percentage_index = dealDetail.header_deal_prepay.getColIndexById('percentage');
        var formula_name_index = dealDetail.header_deal_prepay.getColIndexById('formula_name');

        dealDetail.header_deal_prepay.forEachRow(function(id) {
            delete b;
            var prepay_id = dealDetail.header_deal_prepay.cells(id, prepay_index).getValue();

            var b = result_set.filter(function(e) {
                return e[0] == prepay_id;
            });

            var field_type = b[0][1];
            var internal_type = b[0][2];

            if (field_type == 'w') {
                dealDetail.header_deal_prepay.cells(id, value_index).setDisabled(true);
                dealDetail.header_deal_prepay.cells(id, percentage_index).setDisabled(true);
            } else if (field_type != 'w' && internal_type == 18736) {
                dealDetail.header_deal_prepay.cells(id, value_index).setDisabled(true);
            } else if (field_type != 'w' && internal_type == 18724) {
                dealDetail.header_deal_prepay.cells(id, percentage_index).setDisabled(true);
            }
        });

        return true;
    }

    dealDetail.header_prepay_select = function(row_id, ind) {
        dealDetail.header_prepay_menu.setItemEnabled('delete');

        var formula_index = dealDetail.header_deal_prepay.getColIndexById('formula_name');
        var formula_id_index = dealDetail.header_deal_prepay.getColIndexById('formula_id');
        var formula_id = dealDetail.header_deal_prepay.cells(row_id, formula_id_index).getValue();
        var prepay_index = dealDetail.header_deal_prepay.getColIndexById('prepay');
        var grid_name = 'dealDetail.header_deal_prepay';
        var prepay_id = dealDetail.header_deal_prepay.cells(row_id, prepay_index).getValue();

        if(prepay_id != '') {
            var b = prepay_properties.filter(function(e) {
                return e[0] == prepay_id;
            });

            var field_type = b[0][1];

            if (ind == formula_index && field_type == 'w') {
                ___browse_win_link_window = new dhtmlXWindows();
                var src = '../../_setup/formula_builder/formula.editor.php?formula_id=' + formula_id + '&call_from=browser&is_rate_schedule=1&row_id=' + row_id + '&rate_category_grid=' + grid_name;

                win_formula_id = ___browse_win_link_window.createWindow('w1', 0, 0, 1200, 650);
                win_formula_id.setText("Browse");
                win_formula_id.centerOnScreen();
                win_formula_id.setModal(true);
                win_formula_id.attachURL(src, false);
            }
        }
    }

    function set_formula_columns(formula_id, txt_formula, row_id, rate_category_grid) {
        var formula_id_index = dealDetail.header_deal_prepay.getColIndexById('formula_id');
        var formula_name_index = dealDetail.header_deal_prepay.getColIndexById('formula_name');

        dealDetail.header_deal_prepay.cells(row_id, formula_id_index).setValue(formula_id);
        dealDetail.header_deal_prepay.cells(row_id, formula_name_index).setValue(txt_formula);
        dealDetail.header_deal_prepay.cells(row_id, formula_id_index).cell.wasChanged = true;
    }

    /**
     * [detail_form_onblur Detail Onblur event]
     * @param  {[type]} name [item name]
     */
    dealDetail.detail_form_onblur = function(name) {
        var product_grading = (name == 'origin' || name == 'form' || name == 'attribute1' || name == 'attribute2' || name == 'attribute3' || name == 'attribute4' || name == 'attribute5') ? 'y' : 'n';
        var dep_flag = (name == 'origin') ? 'o' : (name == 'form') ? 'f' : (name == 'attribute1') ? 'a' : (name == 'attribute2') ? 'b' : (name == 'attribute3') ? 'c' : (name == 'attribute4') ? 'e' : 'g';

        if (product_grading == 'n') return true;
        else {
            var combo = dealDetail.form_details_tab.getCombo(name);
            var combo_value = combo.getSelectedValue();

            combo.clearAll();
            if (combo_value != null && combo_value != '') {
                var cm_param = {"action": "spa_counterparty_products", "flag":dep_flag};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                combo.load(url, function() {
                    setTimeout(function() {
                        dealDetail.form_details_tab.setUserData(name,'change_event','n');
                        combo.setComboValue(combo_value);
                        combo.enableFilteringMode('between');
                        dealDetail.form_details_tab.setUserData(name,'change_event','y');
                    }, 100)
                });
            }
        }
    }

    /**
     * [detail_form_onfocus Detail Onfoucs event]
     * @param  {[type]} name [item name]
     */
    dealDetail.detail_form_onfocus = function(name) {
        var selected_row = dealDetail.grid.getSelectedRowId();

        if (selected_row == null) return;

        var product_grading = (name == 'origin' || name == 'form' || name == 'attribute1' || name == 'attribute2' || name == 'attribute3' || name == 'attribute4' || name == 'attribute5') ? 'y' : 'n';

        if (product_grading == 'n') return true;
        else {
            dealDetail.form_details_tab.setUserData(name,'change_event','n');

            var dep_flag = (name == 'origin') ? 'o' : (name == 'form') ? 'f' : (name == 'attribute1') ? 'a' : (name == 'attribute2') ? 'b' : (name == 'attribute3') ? 'c' : (name == 'attribute4') ? 'e' : 'g';
            var parent_name = (name == 'origin') ? 'detail_commodity_id' : (name == 'form') ? 'origin' : (name == 'attribute1') ? 'form' : (name == 'attribute2') ? 'attribute1' : (name == 'attribute3') ? 'attribute2' : (name == 'attribute4') ? 'attribute3' : 'attribute4';

            if (parent_name == 'detail_commodity_id') {
                var detail_commodity_id_index = dealDetail.grid.getColIndexById('detail_commodity_id');
                var value = dealDetail.grid.cells(selected_row, detail_commodity_id_index).getValue();
            } else {
                var parent_combo = dealDetail.form_details_tab.getCombo(parent_name);
                var value = parent_combo.getSelectedValue();
            }
            var combo = dealDetail.form_details_tab.getCombo(name);
            var combo_value = combo.getSelectedValue();

            combo.clearAll();

            if (value != null && value != '') {
                var cm_param = {"action": "spa_counterparty_products", "flag":dep_flag, "dependent_id":value};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                combo.load(url, function() {
                    setTimeout(function() {
                        combo.setComboValue(combo_value);
                        combo.enableFilteringMode('between');
                        combo.openSelect();
                        dealDetail.form_details_tab.setUserData(name,'change_event','y');
                    }, 100)
                });
            }
        }
    }

    /**
     * [detail_form_change Detail Form change Event]
     * @param  {[type]} name  [field name]
     * @param  {[type]} value [field value]
     */
    dealDetail.detail_form_change = function(name, value, state) {
        var type = dealDetail.form_details_tab.getItemType(name);
        var product_grading = (name == 'detail_commodity_id' || name == 'origin' || name == 'form' || name == 'attribute1' || name == 'attribute2' || name == 'attribute3' || name == 'attribute4' || name == 'attribute5') ? 'y' : 'n';
        var concat_array = new Array();
        concat_array = ['detail_commodity_id', 'form', 'origin', 'organic', 'attribute1', 'attribute2', 'attribute3', 'attribute4', 'attribute5'];

        if (product_grading == 'y') {
            var change_event = dealDetail.form_details_tab.getUserData(name,'change_event');
            if (change_event == 'n') return;

            var dep_flag = (name == 'detail_commodity_id') ?  'o' : (name == 'origin') ? 'f' : (name == 'form') ? 'a' : (name == 'attribute1') ? 'b' : (name == 'attribute2') ? 'c' : (name == 'attribute3') ? 'e' : 'g';
            var child = (name == 'detail_commodity_id') ? 'origin' : (name == 'origin') ? 'form' : (name == 'form') ? 'attribute1' : (name == 'attribute1') ? 'attribute2' : (name == 'attribute2') ? 'attribute3' : (name == 'attribute3') ? 'attribute4' : 'attribute5';

            var combo = dealDetail.form_details_tab.getCombo(child);
            if (combo != null && combo != 'null') {
                var combo_value = combo.getSelectedValue();
                combo.clearAll();

                if (value != null && value != '') {
                    var cm_param = {"action": "spa_counterparty_products", "flag":dep_flag, "dependent_id":value};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    combo.load(url, function() {
                        setTimeout(function() {
                            combo.selectOption(1);
                            combo.enableFilteringMode('between');
                            dealDetail.form_details_tab.setUserData(name,'change_event','y');
                        }, 100)
                    });

                }
            }
        }

        value = (value == null) ? '' : value;
        if (type == 'checkbox') {
            value = (state) ? 'y' : 'n';
        }

        var selected_row = dealDetail.grid.getSelectedRowId();

        if (selected_row == null) return;

        var column_index = dealDetail.grid.getColIndexById(name);
        var detail_flag_index = dealDetail.grid.getColIndexById('detail_flag');
        var detail_flag_val = dealDetail.grid.cells(selected_row, detail_flag_index).getValue();

        var group_index = dealDetail.grid.getColIndexById('deal_group');
        var group_id_index = dealDetail.grid.getColIndexById('group_id');
        var leg_index = dealDetail.grid.getColIndexById('blotterleg');
        var avoid_index = [group_index, group_id_index, leg_index, detail_flag_index];

        var change_event = dealDetail.form_details_tab.getUserData(name,'change_event');

        if (change_event == 'n') {
            dealDetail.form_details_tab.setUserData(name,'change_event', 'y');
            return;
        }

        if (detail_flag_val == 0) {
            var parent_id = dealDetail.grid.getParentId(selected_row);

            if (parent_id != 0) {
                dealDetail.grid.cells(parent_id, detail_flag_index).setValue('');

                for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                    if ($.inArray(cellIndex, avoid_index) == -1) {
                        dealDetail.grid.cells(parent_id, cellIndex).setValue('');
                        dealDetail.grid.cells(parent_id, cellIndex).cell.wasChanged = false;
                    }
                }

                dealDetail.grid._h2.forEachChild(parent_id,function(element){
                    dealDetail.grid.cells(element.id, detail_flag_index).setValue(1);
                    dealDetail.grid.cells(element.id, detail_flag_index).cell.wasChanged = true;
                });
            } else {
                dealDetail.grid._h2.forEachChild(selected_row,function(element){
                    dealDetail.grid.cells(element.id, column_index).setValue(value);
                    dealDetail.grid.cells(element.id, column_index).cell.wasChanged = true;
                });
            }
        }

        dealDetail.grid.cells(selected_row, column_index).setValue(value);
        dealDetail.grid.cells(selected_row, column_index).cell.wasChanged = true;

        var concat_string = '';
        $.each(concat_array, function(index, v2){
            var col_index = dealDetail.grid.getColIndexById(v2);
            if (typeof col_index != 'undefined') {
                //var val_id = dealDetail.grid.cells(selected_row, col_index).getValue();
                //var val = dealDetail.grid.cells(selected_row, col_index).getTitle();
                //Modified code to take value from form instead of grid to fix id displayed on product instead of text and change made to not load data on PGS to fix perfomance issue
                var item_type = dealDetail.form_details_tab.getItemType(v2);
                if(item_type == 'combo') {
                    var cmb_object = dealDetail.form_details_tab.getCombo(v2);
                    var val_id = cmb_object.getSelectedValue();
                    var val = cmb_object.getComboText();
                } else if(item_type == 'checkbox') {

                    var val_id = (dealDetail.form_details_tab.isItemChecked(v2) == true) ? 'y' : 'n';
                    //console.log(item_type,val_id);
                    var val = (dealDetail.form_details_tab.isItemChecked(v2) == true) ? 'Yes' : 'No';

                    // console.log(dealDetail.form_details_tab.isItemChecked(v2));
                }

                if (v2 == 'organic' && val == 'No') val = '';
                if (v2 == 'organic' && val == 'Yes') val = 'Organic';
                if (val.indexOf('Not Specified') !== -1 || val == 'N/A') val = '';
                if (v2 == 'origin') val = '| ' + val + ' |';

                if (v2 == 'organic' || val_id > 0) {
                    concat_string = concat_string + ' ' + val;
                }
            }
        });

        var prod_desc_index = dealDetail.grid.getColIndexById('product_description');

        if (typeof prod_desc_index != 'undefined') {
            concat_string = concat_string.replace( /\s\s+/g, ' ' );
            dealDetail.grid.cells(selected_row, prod_desc_index).setValue(concat_string);
            dealDetail.grid.cells(selected_row, prod_desc_index).cell.wasChanged = true;
        }

        return true;
    }

    /**
     * [resize_layout Resize the layout cells]
     */
    dealDetail.resize_layout = function() {
        var h = 0;
        dealDetail.deal_detail.forEachItem(function(item){
            if (item.getId() != 'b')
                h += item.getHeight();
        });
        dealDetail.deal_detail.cells("a").setHeight(h * 0.3);
    }

    /**
     * [check_context_menu Right click event]
     * @param  {[type]} rowId  [rowid]
     * @param  {[type]} cellId [cellid]
     */
    dealDetail.check_context_menu = function(rowId, cellId) {
        var parent_id = dealDetail.grid.getParentId(rowId);
        dealDetail.grid.selectRowById(rowId,true,false,true);
        return true;
    }

    /**
     * [udf_cost_context_menu_click description]
     * @param  {[string]} id [menuitemId]
     * @param  {[string]} type [type]
     */
    dealDetail.udf_cost_context_menu_click = function(id, type) {
        var row_id = dealDetail.deal_detail_cost.getSelectedRowId();

        if (row_id == null) {
            show_messagebox('Please select the row.');
            return;
        }

        var data = dealDetail.deal_detail_cost.contextID.split("_");
        var column_index = data[data.length - 1];
        var sdd_index = dealDetail.deal_detail_cost.getColIndexById('detail_id');
        var cost_index = dealDetail.deal_detail_cost.getColIndexById('cost_name');
        var term_start_index = dealDetail.deal_detail_cost.getColIndexById('term_start');
        var term_end_index = dealDetail.deal_detail_cost.getColIndexById('term_end');
        var leg_index = dealDetail.deal_detail_cost.getColIndexById('leg');
        var charge_type_index = dealDetail.deal_detail_cost.getColIndexById('internal_field_type');

        if (
            sdd_index == column_index || cost_index == column_index || charge_type_index == column_index ||
            term_start_index == column_index || term_end_index == column_index || leg_index == column_index
        ) {
            return;
        }

        var cost_id = dealDetail.deal_detail_cost.cells(row_id, cost_index).getValue();
        var col_value = dealDetail.deal_detail_cost.cells(row_id, column_index).getValue();
        
        dealDetail.deal_detail_cost.forEachRow(function(id) {
            var select_cost_value = dealDetail.deal_detail_cost.cells(row_id, cost_index).getValue();
            var dest_cost_value = dealDetail.deal_detail_cost.cells(id, cost_index).getValue();

            if (select_cost_value == dest_cost_value)
                dealDetail.deal_detail_cost.cells(id, column_index).setValue(col_value);
        });
    }

    /**
     * [context_menu_click description]
     * @param  {[string]} menuitemId [menuitemId]
     * @param  {[string]} type       [type]
     */
    dealDetail.context_menu_click = function(menuitemId,type) {
        var data = dealDetail.grid.contextID.split("_"); //rowId_colInd
        var row_id = dealDetail.grid.getSelectedRowId();
        var column_index = data[data.length - 1];
        var deal_id = '<?php echo $deal_id; ?>';
        var sdd_index = dealDetail.grid.getColIndexById('source_deal_detail_id');

        var no_of_row = dealDetail.grid.hasChildren(row_id);

        var first_child = dealDetail.grid.getChildItemIdByIndex(row_id, 0);

        var source_deal_detail_id = '';

        if (no_of_row == 0) {
            source_deal_detail_id = dealDetail.grid.cells(row_id, sdd_index).getValue();
        } else {
            source_deal_detail_id = dealDetail.grid.cells(first_child, sdd_index).getValue();
        }

        if (menuitemId == 'apply_to' || menuitemId == 'apply_pricing_to') {
            var col_label = dealDetail.grid.getColLabel(column_index);
            var col_type = dealDetail.grid.getColType(column_index);
            var col_value = dealDetail.grid.cells(row_id, column_index).getValue();
            var selected_leg = dealDetail.grid.cells(row_id, 3).getValue();

            if (col_type == 'combo' || 'win_link_custom') {
                var col_text = dealDetail.grid.cells(row_id, column_index).getTitle();
            } else {
                var col_text = col_value;
            }

            if (col_type == 'win_link_custom') {
                col_value = col_value + '^' + col_text;
            }

            var term_start_index = dealDetail.grid.getColIndexById('term_start');
            var min_max_term = dealDetail.grid.collectValues(term_start_index);
            min_max_term.sort(function(a, b){
                return Date.parse(a) - Date.parse(b);
            });
            var max_date = min_max_term[min_max_term.length-1];
            var min_date = min_max_term[0];

            var leg_index = dealDetail.grid.getColIndexById('blotterleg');
            var legs = dealDetail.grid.collectValues(leg_index);
            var max_leg = Math.max.apply(null, legs);

            dealDetail.unload_apply_to_window();
            if (!apply_to_window) {
                apply_to_window = new dhtmlXWindows();
            }

            var win_title = "Apply To Column - " + col_label;
            var win_url = 'apply.to.rows.php';

            if(menuitemId == 'apply_pricing_to') {
                var win_title = "Apply Pricing";
                var win_url = 'apply.pricing.php';
                var col_label = 'Pricing';
                var col_text = '';
            }

            deal_price_data_process_id = (deal_price_data_process_id == '') ? deal_price_data_process_id : 'NULL';
            deal_provisional_price_data_process_id = (deal_provisional_price_data_process_id) ? deal_provisional_price_data_process_id : 'NULL';

            var win = apply_to_window.createWindow('w1', 0, 0, 540, 410);
            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.attachURL(win_url, false, {deal_id:deal_id,term_start:min_date,term_end:max_date,col_label:col_label,col_text:col_text,max_leg:max_leg,selected_leg:selected_leg, source_deal_detail_id:source_deal_detail_id, source_deal_header_id:deal_id, deal_provisional_price_data_process_id: deal_provisional_price_data_process_id});

            win.attachEvent('onClose', function(w) {
                var ifr = w.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                var from_date = $('textarea[name="txt_from_date"]', ifrDocument).val();
                var to_date = $('textarea[name="txt_to_date"]', ifrDocument).val();
                var legs = $('textarea[name="txt_legs"]', ifrDocument).val();
                var leg_array = legs.split(',');
                var lock_deal_detail_index = dealDetail.grid.getColIndexById('lock_deal_detail');
                var form_xml = '<FormXML source_deal_header_id="' + deal_id + '" leg="' + legs + '" term_start="' + from_date + '" term_end="' + to_date + '"></FormXML>';

                if (formula_process_id != '' || formula_process_id != undefined) {
                    var cm_param = {"action": "spa_deal_formula_udf", "flag": "a", "process_id":formula_process_id, "form_xml":form_xml, "source_deal_detail_id":source_deal_detail_id};
                    adiha_post_data("return", cm_param, '', '', '');

                }

                if (from_date != 'Cancel' && from_date != '' && menuitemId !== 'apply_pricing_to') {
                    $.each(leg_array, function(index, value){
                        var legs_rows = dealDetail.grid.findCell(value, 3, false, true);
                        $.each(legs_rows, function(i, v){
                            var t_start = dealDetail.grid.cells(v[0], term_start_index).getValue();
                            var lock_deal_detail = 'n';
                            lock_deal_detail = dealDetail.grid.cells(v[0], lock_deal_detail_index).getValue();

                            if (lock_deal_detail == 'y') return true;
                            if (t_start != '') {
                                var compare_start = '';
                                var compare_end = '';
                                compare_start = dates.compare(t_start, from_date);
                                compare_end = dates.compare(t_start, to_date);

                                if (compare_start == 0 || compare_start == 1) {
                                    if (compare_end == 0 || compare_end == -1) {
                                        dealDetail.grid.cells(v[0], column_index).setValue(col_value);
                                        dealDetail.grid.cells(v[0], column_index).cell.wasChanged=true;

                                        var detail_flag_index = dealDetail.grid.getColIndexById('detail_flag');
                                        var parent_id = dealDetail.grid.getParentId(v[0]);

                                        if (parent_id != 0) {
                                            var group_index = dealDetail.grid.getColIndexById('deal_group');
                                            var group_id_index = dealDetail.grid.getColIndexById('group_id');
                                            var leg_index = dealDetail.grid.getColIndexById('blotterleg');
                                            var avoid_index = [group_index, group_id_index, leg_index, detail_flag_index];
                                            dealDetail.grid.openItem(parent_id);
                                            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                                                if ($.inArray(cellIndex, avoid_index) == -1) {
                                                    dealDetail.grid.cells(parent_id, cellIndex).setValue('');
                                                    dealDetail.grid.cells(parent_id, cellIndex).cell.wasChanged = false;
                                                }
                                            }
                                            dealDetail.grid.cells(parent_id, detail_flag_index).setValue(1);
                                            dealDetail.grid.cells(parent_id, detail_flag_index).cell.wasChanged = true;
                                        }

                                    }
                                }
                            }
                        });
                    });
                }
                return true;
            });
        } else if (menuitemId == 'new_group') {
            var parent_id = dealDetail.grid.getParentId(row_id);
            if (parent_id == 0) return;
            else {
                var changed_rows = dealDetail.grid.getChangedRows(true);
                if (changed_rows != '') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to move detail to new group? Unsaved changes will be lost.",
                        callback: function(result) {
                            if (result) {
                                dealDetail.change_group(row_id);
                            }
                        }
                    });
                } else {
                    dealDetail.change_group(row_id);
                }
            }
        }

    }

    dealDetail.change_group = function(row_id) {
        var deal_id = '<?php echo $deal_id; ?>';
        var new_id = (new Date()).valueOf();
        var group_id_index = dealDetail.grid.getColIndexById('group_id');
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
        var group_ids = dealDetail.grid.collectValues(group_id_index);
        var unique_groups = _.uniq(group_ids);
        var group_count = unique_groups.length + 1;

        var sql_param = {
            "action":"spa_deal_update_new",
            "flag":"f",
            "source_deal_header_id":deal_id,
            "detail_id":detail_id,
            "group_id":group_count
        }
        adiha_post_data("return_json", sql_param, '', '', 'dealDetail.change_group_callback');
    }

    dealDetail.change_group_callback = function() {
        dealDetail.deal_menu_click("refresh");
    }

    /**
     * [grid_before_row_selection Grid Beofre selection function, used to save data to pricing process table]
     * @param  {[type]} new_row [Newly selected rows]
     * @param  {[type]} old_row [Previously selected rows]
     */
    dealDetail.grid_before_row_selection = function(new_row, old_row) {
        if (old_row != null) {
            var parent_id = dealDetail.grid.getParentId(old_row);

            if (parent_id != null) {
                var no_of_child = dealDetail.grid.hasChildren(old_row);
                if (parent_id != 0 || no_of_child == 0) {
                    if (detail_cost_enable == 'y') dealDetail.save_detail_cost(parent_id, old_row);
                    dealDetail.save_detail_udf(old_row, '');
                }
            }
        }

        if (dealDetail.form_details_tab) {
            var status = validate_form(dealDetail.form_details_tab);
        }

        if (enable_pricing == 'y' || enable_provisional_tab == 'y' || enable_escalation_tab == 'y') {
            if (old_row != null) {
                var parent_id = dealDetail.grid.getParentId(old_row);
                var group_id_index = dealDetail.grid.getColIndexById('group_id');

                if (parent_id == 0) {
                    var detail_flag_index = dealDetail.grid.getColIndexById('detail_flag');
                    var detail_flag_val = dealDetail.grid.cells(old_row, detail_flag_index).getValue();

                    if (detail_flag_val == 1) return true;
                }

                if (enable_escalation_tab == 'y ') {
                    // escalation save
                    if(new_row != '')
                        dealDetail.save_escalation_data('');
                }

                /******* Removed pricing tab : Its availble in new popup window from price button in new enhancement.
                 if (enable_pricing == 'y') {
                    // pricing save
                    var w = dealDetail.deal_detail_tab.cells('tab_pricing');
                    var ifr = w.getFrame();
                    var ifrWindow = ifr.contentWindow;
                    ifrWindow.dealPricing.save_pricing();
                    var ifrDocument = ifrWindow.document;
                    var status = $('textarea[name="success_status"]', ifrDocument).val();
                    var error_message = $('textarea[name="error_message"]', ifrDocument).val();
                } else {
                    var status = '';
                    var error_message = '';
                }

                 if (enable_provisional_tab == 'y') {
                    // provisional pricing save
                    var wp = dealDetail.deal_detail_tab.cells('tab_provisional');
                    var ifrp = wp.getFrame();
                    var ifrWindowp = ifrp.contentWindow;
                    ifrWindowp.dealPricing.save_pricing();
                    var ifrDocumentp = ifrWindowp.document;
                    var statusp = $('textarea[name="success_status"]', ifrDocumentp).val();
                    var error_messagep = $('textarea[name="error_message"]', ifrDocumentp).val();
                } else {
                    var statusp = '';
                    var error_messagep = '';
                }

                 if (status.toLowerCase() !== 'error' && statusp.toLowerCase() !== 'error') {
                return true;
                } else {
                    var message = (error_message == '') ? error_messagep : error_message;

                    dhtmlx.alert({
                        title:"Error",
                        type:"alert-error",
                        text:message
                    });
                    return false;
                }
                 */

            }  else return true;
        }

        return true;
    }

    /**
     * [grid_row_selection Grid rows select/unselect event function]
     * @param  {[string]} row_ids [row ids]
     */
    dealDetail.grid_row_selection = function(row_ids) {
        var has_rights_deal_edit = Boolean('<?php echo $has_rights_deal_edit; ?>');
        var has_term_edit_right = Boolean('<?php echo $term_edit_privilege;?>');
        var deal_id = '<?php echo $deal_id; ?>';
        dealDetail.deal_detail.cells('c').progressOn();
        var future_deal = '<?php echo $future_deal; ?>';
        var has_update_actual_edit = Boolean('<?php echo $enable_update_actual; ?>');
        var lock_deal_detail_index = dealDetail.grid.getColIndexById('lock_deal_detail');
        var view_deleted = '<?php echo $view_deleted;?>';
        var enable_detail_udt = '<?php echo $enable_detail_udt; ?>';

        if (row_ids != null && row_ids != '') {
            var lock_deal_detail = dealDetail.grid.cells(row_ids, lock_deal_detail_index).getValue();
            var detail_id = '';
            var parent_id = dealDetail.grid.getParentId(row_ids);
            var group_id_index = dealDetail.grid.getColIndexById('group_id');
            var no_of_child = dealDetail.grid.hasChildren(row_ids);

            if (insert_mode && enable_pricing == 'y') {
                dealDetail.deal_detail_menu.setItemEnabled('price');
                dealDetail.deal_detail_menu.setItemEnabled('provisional_price');
            }

            if (deal_id != 'NULL') {
                if (has_term_edit_right) dealDetail.deal_detail_menu.setItemEnabled('add_term');
                var has_schedule_deal = Boolean('<?php echo $has_schedule_deal;?>');
                if (has_rights_deal_edit && enable_exercise == 'y') dealDetail.deal_detail_menu.setItemEnabled('exercise');

                if (parent_id == 0 && no_of_child > 0) {
                    var first_child = dealDetail.grid.getChildItemIdByIndex(row_ids, 0);
                    var group_id = dealDetail.grid.cells(first_child, group_id_index).getValue();
                } else if (parent_id == 0) {
                    var group_id = dealDetail.grid.cells(row_ids, group_id_index).getValue();
                } else {
                    var group_id = '';
                }

                if (parent_id != 0 || (parent_id == 0 && no_of_child == 0)) {
                    if (has_rights_deal_edit && (volume_type != 'NULL') && lock_deal_detail != 'y') dealDetail.deal_detail_menu.setItemEnabled('update_volume');
                    if (has_schedule_deal) dealDetail.deal_detail_menu.setItemEnabled('schedule_deal');
                    if (has_update_actual_edit && lock_deal_detail != 'y') dealDetail.deal_detail_menu.setItemEnabled('update_actual');
                    if (has_rights_deal_edit && enable_efp == 'y' && future_deal == 'n') {
                        dealDetail.deal_detail_menu.setItemEnabled('post');
                    } else if (has_rights_deal_edit && enable_efp == 'y' && future_deal == 'y') {
                        dealDetail.deal_detail_menu.setItemEnabled('close');
                    }
                    if (has_rights_deal_edit && enable_trigger == 'y') dealDetail.deal_detail_menu.setItemEnabled('trigger');

                    if (has_rights_deal_edit) {
                        dealDetail.deal_detail_menu.setItemEnabled('lock');
                        dealDetail.deal_detail_menu.setItemEnabled('unlock');
                    }

                    if (enable_pricing == 'y') {
                        dealDetail.deal_detail_menu.setItemEnabled('price');
                        dealDetail.deal_detail_menu.setItemEnabled('provisional_price');
                    }

                    if (enable_detail_udt == 'y') {
                        dealDetail.deal_detail_menu.setItemEnabled('udt');
                    }
                } else {
                    dealDetail.deal_detail_menu.setItemDisabled('schedule_deal');
                    if (has_update_actual_edit) dealDetail.deal_detail_menu.setItemDisabled('update_actual');

                    if (enable_trigger == 'y') dealDetail.deal_detail_menu.setItemDisabled('trigger');
                    if (enable_efp == 'y' && future_deal == 'n') dealDetail.deal_detail_menu.setItemDisabled('post');
                    if (enable_efp == 'y' && future_deal == 'y') dealDetail.deal_detail_menu.setItemDisabled('close');

                    dealDetail.deal_detail_menu.setItemDisabled('lock');
                    dealDetail.deal_detail_menu.setItemDisabled('unlock');

                    if (enable_pricing == 'y') {
                        dealDetail.deal_detail_menu.setItemDisabled('price');
                        dealDetail.deal_detail_menu.setItemEnabled('provisional_price');
                    }
                    
                    if (enable_detail_udt == 'y') {
                        dealDetail.deal_detail_menu.setItemDisabled('udt');
                	}
                }

                if (parent_id != 0 || (parent_id == 0 && no_of_child == 0)) {
                    var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
                    detail_id = dealDetail.grid.cells(row_ids, deal_detail_index).getValue();
                    var deal_id = '<?php echo $deal_id; ?>';
                    dealDetail.refresh_efp_trigger(detail_id, 'NULL');
                } else {
                    dealDetail.refresh_efp_trigger('NULL', group_id)
                }
            }

            if (has_rights_deal_edit) {
                if (has_term_edit_right) dealDetail.deal_detail_menu.setItemEnabled('delete_term');
                dealDetail.deal_detail_menu.setItemEnabled('add_leg');
                dealDetail.deal_detail_menu.setItemEnabled('add_container');
                if (parent_id != 0 || no_of_child == 0) {
                    dealDetail.deal_detail_menu.setItemEnabled('add_product');
                    if (is_shaped == 'y') dealDetail.deal_detail_menu.setItemEnabled('update_volume');
                    if (detail_cost_enable == 'y' && view_deleted != 'y') dealDetail.detail_cost_menu.setItemEnabled('add');
                    if (enable_detail_udf_tab == 'y' && view_deleted != 'y') dealDetail.detail_udf_menu.setItemEnabled('add');
                } else {
                    dealDetail.deal_detail_menu.setItemDisabled('add_product');
                    dealDetail.deal_detail_menu.setItemDisabled('update_volume');
                    if (detail_cost_enable == 'y') dealDetail.detail_cost_menu.setItemDisabled('add');
                    if (enable_detail_udf_tab == 'y') dealDetail.detail_udf_menu.setItemDisabled('add');
                }
            }

            if (has_rights_deal_edit && enable_escalation_tab == 'y') {
                dealDetail.escalation_menu.setItemEnabled('refresh');
                dealDetail.escalation_menu.setItemEnabled('add');
                dealDetail.escalation_menu.setItemEnabled('delete');
            }

            var group_id = (parent_id == 0) ? dealDetail.grid.cells(row_ids, group_id_index).getValue() : '';

            if (enable_escalation_tab == 'y') {
                // refresh escalation grid
                dealDetail.refresh_escalation_grid();
            }

            /******* Removed pricing tab : Its availble in new popup window from price button in new enhancement.
             if (enable_pricing == 'y' || enable_provisional_tab == 'y') {
                var pricing_process_id = '<?php echo $pricing_process_id; ?>';
                var leg_index = dealDetail.grid.getColIndexById('blotterleg');
                var leg = dealDetail.grid.cells(row_ids, leg_index).getValue();

                // firstly add the event
                dealDetail.deal_detail_tab.attachEvent("onContentLoaded", function(id) {
                    if (id == 'tab_pricing') dealDetail.deal_detail_tab.cells('tab_pricing').progressOff();
                    if (id == 'tab_provisional') dealDetail.deal_detail_tab.cells('tab_provisional').progressOff();
                });

                if (enable_pricing == 'y') {
                    var price_tab = dealDetail.deal_detail_tab.cells('tab_pricing');
                    price_tab.progressOn();
                    var param_pricing = {group_id:group_id, detail_id:detail_id, deal_id:deal_id, pricing_provisional:'p',pricing_process_id:pricing_process_id, formula_process_id:formula_process_id,leg:leg,lock_deal_detail:lock_deal_detail};
                    var pricing_url = 'deal.pricing.php?' + $.param(param_pricing);
                    price_tab.attachURL(pricing_url);
                }

                if (enable_provisional_tab == 'y') {
                    var provisional_tab = dealDetail.deal_detail_tab.cells('tab_provisional');
                    provisional_tab.progressOn();
                    var param_prov= {group_id:group_id, detail_id:detail_id, deal_id:deal_id, pricing_provisional:'q',pricing_process_id:pricing_process_id, formula_process_id:formula_process_id,leg:leg,lock_deal_detail:lock_deal_detail};
                    var provisional_url = 'deal.pricing.php?' + $.param(param_prov);
                    provisional_tab.attachURL(provisional_url);
                }
            }
             */

            //TODO:
            if (parent_id != 0 || no_of_child == 0) {
                if (detail_cost_enable == 'y') {
                    dealDetail.refresh_detail_cost('', detail_id);
                }
                if (enable_detail_udf_tab == 'y') dealDetail.detail_udf_menu_click('refresh');
            } else {
                if (detail_cost_enable == 'y') {
                    dealDetail.refresh_detail_cost('', '');
                }
                if (enable_detail_udf_tab == 'y') dealDetail.detail_udf_menu_click('refresh');
            }
        } else {
            if (deal_id != 'NULL') {
                dealDetail.deal_detail_menu.setItemDisabled('add_term');
                dealDetail.deal_detail_menu.setItemDisabled('update_volume');
                if (has_update_actual_edit) dealDetail.deal_detail_menu.setItemDisabled('update_actual');
                dealDetail.refresh_efp_trigger('NULL', 'NULL');
                if (detail_cost_enable == 'y') {
                    dealDetail.refresh_detail_cost('', '');
                }
            }

            if (detail_cost_enable == 'y') dealDetail.detail_cost_menu.setItemDisabled('add');
            if (enable_detail_udf_tab == 'y') dealDetail.detail_udf_menu.setItemDisabled('add');

            if (enable_detail_udf_tab == 'y') dealDetail.detail_udf_menu_click('refresh');

            dealDetail.deal_detail_menu.setItemDisabled('delete_term');
            dealDetail.deal_detail_menu.setItemDisabled('add_leg');
            dealDetail.deal_detail_menu.setItemDisabled('add_container');
            dealDetail.deal_detail_menu.setItemDisabled('add_product');

            if (enable_pricing == 'y') dealDetail.deal_detail_menu.setItemDisabled('price');
            if (enable_pricing == 'y') dealDetail.deal_detail_menu.setItemDisabled('provisional_price');
            if (enable_trigger == 'y') dealDetail.deal_detail_menu.setItemDisabled('trigger');
            if (enable_efp == 'y' && future_deal == 'n') dealDetail.deal_detail_menu.setItemDisabled('post');
            if (enable_efp == 'y' && future_deal == 'y') dealDetail.deal_detail_menu.setItemDisabled('close');

            if (enable_pricing == 'y' || enable_provisional_tab == 'y' || enable_escalation_tab == 'y') {
                if (enable_escalation_tab == 'y') {
                    dealDetail.escalation_menu.setItemDisabled('refresh');
                    dealDetail.escalation_menu.setItemDisabled('add');
                    dealDetail.escalation_menu.setItemDisabled('delete');
                }

                /******* Removed pricing tab : Its availble in new popup window from price button in new enhancement.
                 if (enable_pricing == 'y' || enable_provisional_tab == 'y' || enable_escalation_tab == 'y') {


                if (enable_pricing == 'y') {
                    var price_tab = dealDetail.deal_detail_tab.cells('tab_pricing');
                    var param_pricing = {pricing_provisional:'p'}
                    var pricing_url = 'deal.pricing.php?' + $.param(param_pricing);
                    price_tab.attachURL(pricing_url);
                }

                if (enable_provisional_tab == 'y') {
                    var provisional_tab = dealDetail.deal_detail_tab.cells('tab_provisional');
                var param_prov= {pricing_provisional:'q'
                }
                    var provisional_url = 'deal.pricing.php?' + $.param(param_prov);
                    provisional_tab.attachURL(provisional_url);
            } */
            }

        }

        if (hide_pricing == 0 && row_ids != null) {
            var field_array = ['detail_commodity_id', 'origin', 'form', 'attribute1', 'attribute2', 'attribute3', 'attribute4', 'attribute5'];
            $.each(field_array, function(index, value){
                var field_type = dealDetail.form_details_tab.getItemType(value);
                if (field_type != null) {
                    dealDetail.form_details_tab.setUserData(value,'change_event', 'n');
                }
            })
            var loaded_combov2s = [];
            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                var column_id = dealDetail.grid.getColumnId(cellIndex);
                var field_type = dealDetail.form_details_tab.getItemType(column_id);
                if (field_type != null) {
                    val = dealDetail.grid.cells(row_ids,cellIndex).getValue();
                    val = (field_type == 'checkbox') ? (val == 'y' ? 1 : 0) : val;

                    var child_fields = ['origin', 'form', 'attribute1', 'attribute2', 'attribute3', 'attribute4', 'attribute5']

                    // Check if field is dependent child
                    var dependent_child = child_fields.filter(function(field){
                        return field == column_id
                    }).length > 0;

                    if(field_type == 'combo' && val != '') {
                        if(!dealDetail.form_details_tab.getCombo(column_id)._is_loaded && combo_url_info ) {
                            var url_array = combo_url_info
                                .split('||||')
                                .filter(function (combo_prop) {
                                    return combo_prop.split('::::')[0] == column_id;
                                });
                            var url_v2 = (Array.isArray(url_array) && url_array.length == 1) ? url_array[0].split('::::')[1] : '';

                            // Reset default value to value present on grid cell.
                            url_v2 = js_php_path + url_v2.split('&').map(function (params) {
                                var params_array = params.split('=');
                                if (params_array[0] == 'default_value') params_array[1] = val;
                                return params_array;
                            }).map(function (val) {
                                return val.join('=');
                            }).join('&');

                            if(!dependent_child && val != '') {
                                loaded_combov2s.push(column_id);
                                dealDetail.form_details_tab.getCombo(column_id).clearAll();
                                dealDetail.form_details_tab.getCombo(column_id).load(url_v2);
                            }
                        }
                    }

                    // Check if value is set or not.
                    var is_default_set = loaded_combov2s.filter(function (loaded_combov2) {
                        return loaded_combov2 == column_id;
                    }).length > 0;

                    var product_grading = (column_id == 'detail_commodity_id' || column_id == 'origin' || column_id == 'form' || column_id == 'attribute1' || column_id == 'attribute2' || column_id == 'attribute3' || column_id == 'attribute4' || column_id == 'attribute5') ? 'y' : 'n';
                    if (product_grading == 'y') {
                        var parent_combo = dealDetail.form_details_tab.getCombo(column_id);
                        if(!is_default_set) {
                            var combo_index = parent_combo.getIndexByValue(val);
                            if (combo_index == -1) {
                                parent_combo.unSelectOption();
                            } else {
                                parent_combo.selectOption(combo_index);
                            }
                        }

                        var dep_flag = (column_id == 'detail_commodity_id') ?  'o' : (column_id == 'origin') ? 'f' : (column_id == 'form') ? 'a' : (column_id == 'attribute1') ? 'b' : (column_id == 'attribute2') ? 'c' : (column_id == 'attribute3') ? 'e' : 'g';
                        var child = (column_id == 'detail_commodity_id') ? 'origin' : (column_id == 'origin') ? 'form' : (column_id == 'form') ? 'attribute1' : (column_id == 'attribute1') ? 'attribute2' : (column_id == 'attribute2') ? 'attribute3' : (column_id == 'attribute3') ? 'attribute4' : 'attribute5';

                        var dep_combo = dealDetail.form_details_tab.getCombo(child);

                        if (dep_combo != null && dep_combo != 'null' && child != '')    {
                            if (val != null && val != '') {
                                var get_dep_index =  dealDetail.grid.getColIndexById(child);
                                var selected_value = dealDetail.grid.cells(row_ids, get_dep_index).getValue();
                                var cm_param = {"action": "spa_counterparty_products", "flag":dep_flag, "dependent_id":val, "SELECTED_VALUE":selected_value};
                                cm_param = $.param(cm_param);
                                var url = js_dropdown_connector_url + '&' + cm_param;
                                //console.log(child + '   ' + dep_flag + '   ' + val + '   ' + dep_combo);
                                dep_combo.clearAll();
                                dep_combo.load(url);
                                dep_combo.enableFilteringMode('between');
                            } else {
                                dep_combo.clearAll();
                            }
                        } else {
                            child = '';
                        }
                    } else {
                        dealDetail.form_details_tab.setUserData(column_id,'change_event', 'n');
                        if (field_type == 'combo' || field_type == 'combo_v2') {
                            var combo_obj = dealDetail.form_details_tab.getCombo(column_id);
                            combo_obj.setComboText('');
                            combo_obj.setComboValue('');
                        }

                        // Load function automatically sets the value.
                        // Added condition to prevent resetting value.
                        if(!is_default_set) {
                            dealDetail.form_details_tab.setItemValue(column_id, val);
                        }

                        dealDetail.detail_form_change(column_id, val);
                    }
                }
            }

            $.each(field_array, function(index, value){
                var field_type = dealDetail.form_details_tab.getItemType(value);
                if (field_type != null) {
                    dealDetail.form_details_tab.setUserData(value,'change_event', 'y');
                }
            });
        }

        dealDetail.deal_detail.cells('c').progressOff();
        return true;
    }


    /**
     * [save_detail_cost Save Deal Costs]
     * @param  {[type]} parent_id [parent id of previously selected row.]
     * @param  {[type]} row_ids   [Previously row ID]
     */
    dealDetail.save_detail_cost = function(parent_id, row_ids) {
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var detail_id = dealDetail.grid.cells(row_ids, deal_detail_index).getValue();
        var udf_process_id = '<?php echo $udf_process_id; ?>';
        var deal_id = '<?php echo $deal_id; ?>';

        if (deal_id == 'NULL') {
            var template_id = '<?php echo $template_id; ?>';
        } else {
            var template_id = 'NULL';
        }

        if (detail_id == '') detail_id = 'NULL';
        var changed_rows = dealDetail.deal_detail_cost.getChangedRows(true);
        dealDetail.deal_detail_cost.clearSelection();

        if (changed_rows != '') {
            var grid_xml = '<GridXML>';
            var changed_ids = new Array();
            changed_ids = changed_rows.split(",");
            $.each(changed_ids, function(index, value) {
                grid_xml += '<GridRow ';
                for(var cellIndex = 0; cellIndex < dealDetail.deal_detail_cost.getColumnsNum(); cellIndex++){
                    var column_id = dealDetail.deal_detail_cost.getColumnId(cellIndex);
                    var cell_value = dealDetail.deal_detail_cost.cells(value, cellIndex).getValue();
                    grid_xml += ' ' + column_id + '="' + cell_value + '"';
                }
                grid_xml += '></GridRow>';
            });
            grid_xml += '</GridXML>';

            var sql_param = {
                "action":"spa_udf_groups",
                "flag":"u",
                "deal_id":deal_id,
                "detail_id":detail_id,
                "udf_process_id":udf_process_id,
                "template_id":template_id,
                "udf_type":'dc',
                "udf_xml":grid_xml
            }
            adiha_post_data("return_status", sql_param, '', '', '');
        }
    }

    /**
     * [refresh_detail_cost Refresh Detail Cost Grid - if present]
     * @param  {[type]} group_id  [Deal Group Id]
     * @param  {[type]} detail_id [Deal Detail ID]
     */
    dealDetail.refresh_detail_cost = function(group_id, detail_id) {
        if (detail_cost_enable != 'y') {
            return;
        }
        if (detail_id == '') {
            dealDetail.deal_detail_cost.clearAll();
            return;
        }

        var deal_id = '<?php echo $deal_id; ?>';
        var udf_process_id = '<?php echo $udf_process_id; ?>';

        if (deal_id == 'NULL') {
            var template_id = '<?php echo $template_id; ?>';
        } else {
            var template_id = 'NULL';
        }

        if (detail_id == '') detail_id = 'NULL';

        var sql_param = {
            "action":"spa_udf_groups",
            "flag":"z",
            "deal_id":deal_id,
            "detail_id":detail_id,
            "udf_type":'dc',
            "udf_process_id":udf_process_id,
            "template_id":template_id,
            "grid_type":"g"
        }

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        dealDetail.deal_detail_cost.clearAll();
        dealDetail.deal_detail_cost.load(sql_url, function(){
            dealDetail.detail_cost_onload();
        });
    }

    // dealDetail.udf_form_change = function(name, old_value, new_value) {
    //  if (dealDetail.form_0) {
    //      var is_formula = dealDetail.form_0.getUserData(name, "is_formula");

    //   if (is_formula == 'y') {
    //       var formula_id = dealDetail.form_0.getUserData(name, "formula_id");
    //       dealDetail.open_header_formula(dealDetail.form_0, name, formula_id);
    //       return false;
    //   }
    //  }
    //  return true;
    // }

    //   dealDetail.open_header_formula = function(form_obj, name, formula_id) {
    //    if (detail_formula_popup && detail_formula_popup.isVisible()) {
    //  detail_formula_popup.hide();
    //  return;
    // }

    // if (detail_formula_layout != null && detail_formula_layout.unload != null) {
    //           detail_formula_layout.unload();
    //           detail_formula_layout = null;
    //       }

    //    if (detail_formula_popup != null && detail_formula_popup.unload != null) {
    //           detail_formula_popup.unload();
    //           detail_formula_popup = null;
    //       }

    //       if (!detail_formula_popup) {
    //        detail_formula_popup = new dhtmlXPopup();
    //    }


    //   }

    dealDetail.open_formula = function(grid, rId, cInd, oValue, x, y, w, z) {
        var formula_id = grid.cells(rId, cInd).getValue();
        var source_deal_detail_index = grid.getColIndexById('source_deal_detail_id');
        var group_id_index = grid.getColIndexById('group_id');
        var leg_index = grid.getColIndexById('blotterleg');
        var is_formula_changed = false;

        if (typeof source_deal_detail_index != 'undefined') {
            var source_deal_detail_id = dealDetail.grid.cells(rId, source_deal_detail_index).getValue();
            var group_id = dealDetail.grid.cells(rId, group_id_index).getValue();
            var leg = dealDetail.grid.cells(rId, leg_index).getValue();

            source_deal_detail_id = (source_deal_detail_id == '') ? 'NULL' : source_deal_detail_id;
            group_id = (group_id == '') ? 'NULL' : group_id;
        } else {
            var source_deal_detail_id = 'NULL';
            var group_id = 'NULL';
            var leg = 'NULL';
        }

        if (detail_formula_popup && detail_formula_popup.isVisible()) {
            detail_formula_popup.hide();
            return;
        }

        if (detail_formula_layout != null && detail_formula_layout.unload != null) {
            detail_formula_layout.unload();
            detail_formula_layout = null;
        }

        if (detail_formula_popup != null && detail_formula_popup.unload != null) {
            detail_formula_popup.unload();
            detail_formula_popup = null;
        }

        if (!detail_formula_popup) {
            detail_formula_popup = new dhtmlXPopup();
        }

        detail_formula_popup.attachEvent('onShow', function() {
            formula_form_load_status = 0;
            if (!detail_formula_layout) {
                var formula_form_data = <?php echo $formula_form_data;?>;
                detail_formula_layout = detail_formula_popup.attachLayout(600, 200, "2U");
                detail_formula_layout.cells('a').hideHeader();
                detail_formula_layout.cells('a').setWidth(210);
                detail_formula_layout.cells('b').setText('Formula Fields');
                detail_formula_layout.cells('b').collapse();
                formula_form = detail_formula_layout.cells('a').attachForm(formula_form_data);
                formula_form.setItemValue('source_deal_detail_id',source_deal_detail_id);
                formula_form.setItemValue('group_id',group_id);
                formula_form.setItemValue('leg',leg);
                formula_form.setItemValue('row_id',1);
            }

            formula_field_form = detail_formula_layout.cells('b').attachForm();
            attach_browse_event('formula_form', 10131010, 'dealDetail.new_formula_change');

            formula_form.attachEvent('onChange', function(id, value) {
                if (id == 'form_sel' && value == 't') {
                    formula_form.hideItem('label_new_formula_id');
                    formula_form.showItem('exist_formula');
                } else if (id == 'form_sel' && value == 'c') {
                    formula_form.hideItem('exist_formula');
                    formula_form.showItem('label_new_formula_id');
                } else if (id == 'exist_formula' || id == 'new_formula_id') {
                    if (value != '' && value != null) {
                        var detail_id = formula_form.getItemValue('source_deal_detail_id')
                        var d_leg = formula_form.getItemValue('leg');
                        var d_group_id = formula_form.getItemValue('group_id')
                        var cm_param = {"action": "spa_deal_formula_udf", "flag": "y", "formula_id":value, "row_id":1, "source_deal_detail_id":detail_id, "leg":d_leg, "source_deal_group_id":d_group_id, "process_id":formula_process_id};
                        adiha_post_data("return", cm_param, '', '', 'dealDetail.load_formula_fields');
                    }
                }
            });

            formula_form.attachEvent('onButtonClick', function(btn_id) {
                if (btn_id == 'ok') {
                    detail_formula_popup.hide();
                    return;
                }
            });

            if (!formula_id) formula_id = '';
            if (formula_id != '' && formula_id != null) {
                var cm_param = {"action": "spa_deal_formula_udf", "flag": "z", "formula_id":formula_id};
                adiha_post_data("return", cm_param, '', '', 'dealDetail.is_formula_template');
            } else {
                formula_form_load_status = 1;
            }
        });

        detail_formula_popup.show(x, y, w, z);

        detail_formula_popup.attachEvent('onHide', function(){
            if (formula_form_load_status === 0) return;
            var new_old = formula_form.getCheckedValue('form_sel');

            if (new_old == 't') {
                var combo = formula_form.getCombo('exist_formula');
                var formula_id = formula_form.getItemValue('exist_formula');
                var formula_text = combo.getComboText();
            } else {
                var formula_id = formula_form.getItemValue('new_formula_id');
                var formula_text = formula_form.getItemValue('label_new_formula_id');
            }

            grid.cells(rId, cInd).setValue(formula_id + '^' + formula_text);
            grid.cells(rId, cInd).cell.wasChanged=true;
            grid.callEvent("onEditCell", [2, rId, cInd, formula_id, oValue]);

            if (formula_field_form instanceof dhtmlXForm && typeof source_deal_detail_index != 'undefined') {
                var form_data = formula_field_form.getFormData();
                var form_xml = '<Root>';

                for (var a in form_data) {
                    form_xml += "<FormXML row_id=\"1\" leg=\"" + leg + "\" source_deal_group_id=\"" + group_id + "\" source_deal_detail_id=\"" + source_deal_detail_id + "\"  udf_template_id=\"" + a + "\"  udf_value=\"" + form_data[a] + "\"></FormXML>";
                }

                form_xml += "</Root>";
            }

            var cm_param = {"action": "spa_deal_formula_udf", "flag": "x", "process_id":formula_process_id, "form_xml":form_xml};
            adiha_post_data("return", cm_param, '', '', '');
        });
    }

    dealDetail.new_formula_change = function(row_id, group_id, leg, source_deal_detail_id) {
        var formula_id = formula_form.getItemValue('new_formula_id');
        if (formula_id != '' && formula_id != null) {
            var detail_id = formula_form.getItemValue('source_deal_detail_id')
            var d_leg = formula_form.getItemValue('leg');
            var d_group_id = formula_form.getItemValue('group_id')
            var cm_param = {"action": "spa_deal_formula_udf", "flag": "y", "formula_id":formula_id, "row_id":1, "source_deal_detail_id":detail_id, "leg":d_leg, "source_deal_group_id":d_group_id, "process_id":formula_process_id};
            adiha_post_data("return", cm_param, '', '', 'dealDetail.load_formula_fields');
        }
    }

    dealDetail.is_formula_template = function(result) {
        if (result[0].is_template == 'y') {
            formula_form.checkItem('form_sel', 't');
            formula_form.callEvent("onChange", ["form_sel", "t"]);
            formula_form.setItemValue('exist_formula', result[0].formula_id);
            formula_form.callEvent("onChange", ["exist_formula", result[0].formula_id]);
        } else {
            formula_form.checkItem('form_sel', 'c');
            formula_form.callEvent("onChange", ["form_sel", "c"]);
            formula_form.setItemValue('new_formula_id', result[0].formula_id);
            formula_form.setItemValue('label_new_formula_id', result[0].formula_text);
            formula_form.callEvent("onChange", ["new_formula_id", result[0].formula_id]);
        }
        formula_form_load_status = 1;
    }

    dealDetail.load_formula_fields = function(result) {
        if (result[0].form_json != '' && result[0].form_json != 'undefined') {
            if (formula_field_form instanceof dhtmlXForm) {
                var form_data = formula_field_form.getFormData();
                for (var a in form_data) {
                    formula_field_form.removeItem(a);
                }
                detail_formula_layout.cells('b').expand();
                formula_field_form.load(result[0].form_json);

            }
        }
    }

    var save_function_call = 'n';
    /**
     * [deal_detail_edit Grid cell on edit function]
     * @param  {[type]} stage  [stage of edit 0 - edit open, 1 - on edit, 2 - on edit close]
     * @param  {[type]} rId    [row_id]
     * @param  {[type]} cInd   [column index]
     * @param  {[type]} nValue [new value]
     * @param  {[type]} oValue [old value]
     */
    dealDetail.deal_detail_edit = function(stage,rId,cInd,nValue,oValue) {
        var group_index = dealDetail.grid.getColIndexById('deal_group');
        var location_index = dealDetail.grid.getColIndexById('location_id');
        var volume_index = dealDetail.grid.getColIndexById('deal_volume');
        var actual_vol_index = dealDetail.grid.getColIndexById('actual_volume');
        var schedule_vol_index = dealDetail.grid.getColIndexById('schedule_volume');
        var actualization_flag = '<?php echo $actualization_flag;?>';
        var view_deleted = '<?php echo $view_deleted; ?>';
        var column_id = dealDetail.grid.getColumnId(cInd);
        var status_index = dealDetail.grid.getColIndexById('status');
        var tab_obj = dealDetail.deal_tab;
        var granularity = '';
        var volume_type = '' ;

        tab_obj.forEachTab(function(tab) {
            var form_object = tab.getAttachedObject();
            if (form_object instanceof dhtmlXForm)
                var data = form_object.getFormData();

            for (var a in data) {
                var field_label = a;

                if (field_label == 'profile_granularity') {
                    granularity = data[field_label];
                }

                if (field_label == 'internal_desk_id') {
                    volume_type = data[field_label];
                }
            }
        });

        var lock_deal_detail_index = dealDetail.grid.getColIndexById('lock_deal_detail');
        var lock_deal_detail = dealDetail.grid.cells(rId, lock_deal_detail_index).getValue();

        if (lock_deal_detail == 'y') {
            return false;
        }


        if (typeof location_index != 'undefined' && location_index == cInd) {
            if (!enable_location) return false;
        }

        if (stage != 2 && jQuery.inArray(column_id, detail_formula_array) != -1) {
            var pos = dealDetail.grid.getPosition(dealDetail.grid.cells(rId,cInd).cell);
            var y = pos[1];
            var x = pos[0];

            var w = dealDetail.grid.cells(rId,cInd).cell.offsetWidth;
            var z = dealDetail.grid.cells(rId,cInd).cell.offsetHeight;

            dealDetail.open_formula(dealDetail.grid, rId, cInd, oValue, x, y, w, z);
            return false;
        } else {
            if (detail_formula_popup && detail_formula_popup.isVisible()) detail_formula_popup.hide();
        }

        if (stage == 2 && (typeof status_index != 'undefined' && status_index == cInd)) {
            var match_detail_status = check_deal_detail_status();
            var c_status = match_detail_status[2];

            if (match_detail_status[0] == 0) {
                dhtmlx.message({
                    type: "confirm",
                    text: match_detail_status[1],
                    title: "Confirmation",
                    callback: function(result) {
                        if (!result) {
                            dealDetail.grid.cells(rId, status_index).setValue(c_status);
                        }
                    }
                });
            }
        }
        if (stage != 2 && volume_index == cInd && (is_shaped == 'y' || volume_type == 17302) && view_deleted != 'y') {
            dealDetail.deal_detail.cells('c').progressOn();
            dealDetail.open_update_volume();
            return false;
        }

        if (stage != 2 && view_deleted != 'y' && ((typeof actual_vol_index != 'undefined' && actual_vol_index == cInd) || (typeof schedule_vol_index != 'undefined' && schedule_vol_index == cInd)))  {
            if (actualization_flag == 'm' || actualization_flag == 's' || volume_type == 17302) {
                dealDetail.open_update_actual();
                return false;
            }
            /*else if (volume_type == 17301 && (typeof actual_vol_index != 'undefined' && actual_vol_index == cInd) || (profile_gran_with_meter == 'y' && typeof actual_vol_index != 'undefined' && actual_vol_index == cInd)) {
                dealDetail.open_update_actual();
                return false;
            }*/
        }

        // if (stage != 2 && view_deleted != 'y' && volume_type == 17301 && (typeof volume_index != 'undefined' && volume_index == cInd)) {
        //     dealDetail.open_update_profile();
        //     return false;
        // }

        if (stage == 2) {
            var return_val = false;
            var column_id = dealDetail.grid.getColumnId(cInd);

            if (column_id == 'term_start' || column_id == 'term_end') {
                var term_start_index = dealDetail.grid.getColIndexById('term_start');
                var term_end_index = dealDetail.grid.getColIndexById('term_end');
                var expiration_date_index = dealDetail.grid.getColIndexById('contract_expiration_date');

                if (term_start_index == undefined || term_end_index == undefined) return true;
                var term_start = dealDetail.grid.cells(rId, term_start_index).getValue();
                var term_end = dealDetail.grid.cells(rId, term_end_index).getValue();
                var expiration_date = (expiration_date_index) ? dealDetail.grid.cells(rId, expiration_date_index).getValue() : '';

                if (column_id == 'term_start') {
                    var vintage_index = dealDetail.grid.getColIndexById('vintage');
                    if(vintage_index > 0) {
                        dealDetail.grid.cells(rId, vintage_index).setValue(0);
                    }
                    var term_frequency = '<?php echo $term_frequency;?>';
                    var new_term_end = dates.getTermEnd(term_start, term_frequency);
                    dealDetail.grid.cells(rId, term_end_index).setValue(new_term_end);
                    dealDetail.load_shipper_dropdown(rId, 'term_start_end');
                 } 
				if (column_id == 'term_start' || column_id == 'term_end') {
                    // update expiration date by term_start or term_end
                    var term_end = dealDetail.grid.cells(rId, term_end_index).getValue();
                    var parent_id = dealDetail.grid.getParentId(rId);
                    var parent_date = (parent_id) ? dealDetail.grid.cells(parent_id, expiration_date_index).getValue() : '';
                    if (expiration_date_index && !parent_date) dealDetail.grid.cells(rId, expiration_date_index).setValue(term_end);
                } else if (dates.compare(term_end, term_start) == -1) {
                    var term_start_label = dealDetail.grid.getColLabel(term_start_index);
                    var term_end_label = dealDetail.grid.getColLabel(term_end_index);
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
                                dealDetail.grid.cells(rId, cInd).setFormattedValue(oValue);
                                return true;
                            } else {
                                dealDetail.grid.cells(rId, cInd).setFormattedValue('');
                                return false;
                            }
                        }
                    });
                }
            } else if (column_id == 'detail_commodity_id') {
                var detail_commodity_id_index = dealDetail.grid.getColIndexById('detail_commodity_id');
                var detail_commodity_id = dealDetail.grid.cells(rId, detail_commodity_id_index).getValue();
                var origin_index = dealDetail.grid.getColIndexById('origin');
                if (origin_index) {
                    field_array = ['origin', 'form', 'attribute1', 'attribute2', 'attribute3', 'attribute4', 'attribute5'];
                    $.each(field_array, function(index, value){
                        dealDetail.form_details_tab.setUserData(name,'change_event', 'y');
                        var combo = dealDetail.form_details_tab.getCombo(value);
                        combo.setComboText(null);
                        combo.setComboValue(null);
                    })
                }
            } else if (column_id == 'location_id') {
                detail_commodity_id_index = dealDetail.grid.getColIndexById('detail_commodity_id');
                var curve_id_index = dealDetail.grid.getColIndexById('curve_id');
                // Set curve value based on location for insert mode only
                if (insert_mode == 1 && curve_id_index) {
                    var cmb_curve = dealDetail.grid.getColumnCombo(curve_id_index);
                    if (valuation_index_obj.location[nValue] && cmb_curve.getIndexByValue(valuation_index_obj.location[nValue]) != -1) {
                        dealDetail.grid.cells(rId,curve_id_index).setValue(valuation_index_obj.location[nValue]);
                    } else {
                        dealDetail.grid.cells(rId,curve_id_index).setValue('');
                    }
                }
                if (detail_commodity_id_index) {
                    var detail_commodity_combo = dealDetail.grid.cells(rId, detail_commodity_id_index).getCellCombo();

                    detail_commodity_id = dealDetail.grid.cells(rId, detail_commodity_id_index).getValue();
                    var cm_param = {"action": "spa_source_commodity_maintain", "flag": "k", "location_id": nValue, "SELECTED_VALUE":detail_commodity_id};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    detail_commodity_combo.clearAll();
                    detail_commodity_combo.closeAll();
                    detail_commodity_combo.enableFilteringMode(true);
                    detail_commodity_combo.load(url,function () {
                        if(detail_commodity_combo.getIndexByValue(detail_commodity_id) == -1)
                            dealDetail.grid.cells(rId, detail_commodity_id_index).setValue('');
                    });
                }
                dealDetail.load_shipper_dropdown(rId, 'location');
            }  

            var detail_flag_index = dealDetail.grid.getColIndexById('detail_flag');
            var detail_flag_val = dealDetail.grid.cells(rId, detail_flag_index).getValue();

            var group_id_index = dealDetail.grid.getColIndexById('group_id');
            var leg_index = dealDetail.grid.getColIndexById('blotterleg');
            var avoid_index = [group_index, group_id_index, leg_index, detail_flag_index];


            if (detail_flag_val == 0) {
                var parent_id = dealDetail.grid.getParentId(rId);

                if (parent_id != 0) {
                    dealDetail.grid.cells(parent_id, detail_flag_index).setValue('');
                    dealDetail.grid.cells(parent_id, detail_flag_index).cell.wasChanged = false;

                    for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                        if ($.inArray(cellIndex, avoid_index) == -1) {
                            dealDetail.grid.cells(parent_id, cellIndex).setValue('');
                            dealDetail.grid.cells(parent_id, cellIndex).cell.wasChanged = false;
                        }
                    }

                    dealDetail.grid.cells(rId, detail_flag_index).setValue(1);
                    dealDetail.grid.cells(rId, detail_flag_index).cell.wasChanged = true
                    /*
                    dealDetail.grid._h2.forEachChild(parent_id,function(element){
                        dealDetail.grid.cells(element.id, detail_flag_index).setValue(1);
                        dealDetail.grid.cells(element.id, detail_flag_index).cell.wasChanged = false;
                    });
                    */
                } else {
                    var type = dealDetail.grid.getColType(cInd);
                    var text = dealDetail.grid.cells(rId, cInd).getTitle();
                    if (type == 'win_link_custom') {
                        nValue = nValue + '^' + text;
                        dealDetail.grid._h2.forEachChild(rId,function(element){
                            dealDetail.grid.cells(element.id, cInd).setValue(nValue);
                            dealDetail.grid.cells(element.id, cInd).cell.wasChanged = true;
                        });
                    } else {
                        var deal_id = '<?php echo $deal_id; ?>';
                        var no_of_child = dealDetail.grid.hasChildren(rId);
                        if (no_of_child > 0 && nValue != oValue) {
                            if (save_function_call == 'y') {
                                dealDetail.grid._h2.forEachChild(rId,function(element){
                                    dealDetail.grid.cells(element.id, cInd).setValue(nValue);
                                    dealDetail.grid.cells(element.id, cInd).cell.wasChanged = true;
                                });
                            } else {
                                dhtmlx.message({
                                    title:"Confirmation",
                                    type:"confirm",
                                    ok: "Confirm",
                                    text: 'Value will be updated to the selected column in all items of group. Do you want to continue?',
                                    callback: function(result) {
                                        if (result) {
                                            dealDetail.grid._h2.forEachChild(rId,function(element){                                               
                                                dealDetail.grid.cells(element.id, cInd).setValue(nValue);
                                                dealDetail.grid.cells(element.id, cInd).cell.wasChanged = true;
                                                if (column_id == 'location_id') {
                                                    dealDetail.load_shipper_dropdown(element.id, 'set_all_location');
                                                }                                                
                                            });
                                            return true;
                                        } else {
                                            dealDetail.grid.cells(rId, cInd).setValue(oValue);
                                            dealDetail.grid.cells(rId, cInd).cell.wasChanged = false;
                                        }
                                    }
                                });
                            }
                        }

                    }
                }
            }
            return true;
        }
    }


    /**
     * [load_shipper_dropdown Load Shipper Code dropdown]
     * @param  {[type]} row_id          [Grid Row ID]
     * @param  {[type]} call_from          [Function is called from many other functions so added for debugging purpose]
     */
    dealDetail.load_shipper_dropdown = function(rId, call_from) {
        var shipper_code1_index = dealDetail.grid.getColIndexById('shipper_code1');
        var shipper_code2_index = dealDetail.grid.getColIndexById('shipper_code2');       
        var deal_id = '<?php echo $deal_id; ?>';
        var copy_deal_id = '<?php echo $copy_deal_id; ?>';       
        var counterparty_id, template_text;
        var contract_id = '';
        var location_id = '';
        //var template_id = '';

        if (deal_id == 'NULL' && copy_deal_id != 'NULL') {
            deal_id = copy_deal_id;
        }

        var child_rows = dealDetail.grid.hasChildren(rId) ;

        var tab_obj = dealDetail.deal_tab ;   
        tab_obj.forEachTab(function(tab) {
            var form_obj = tab.getAttachedObject();
            
            if (form_obj instanceof dhtmlXForm) {
                var counterparty_combo = form_obj.getCombo('counterparty_id');
                if (counterparty_combo) {
                    counterparty_id = form_obj.getItemValue('counterparty_id');
                }

                var contract_combo = form_obj.getCombo('contract_id');
                if (contract_combo) {
                    contract_id = form_obj.getItemValue('contract_id');
                } 

                var template_obj = form_obj.getCombo('template_id');
                if (template_obj) {
                    template_text = template_obj.getComboText();
                    //template_id = template_obj.getSelectedValue();
                }  
            }
                        
        });   

        if (template_text != 'Transportation NG') contract_id = '';
        var location_id_index = dealDetail.grid.getColIndexById('location_id'); 
       
        if (typeof location_id_index != 'undefined' && template_text != 'Transportation NG') location_id = dealDetail.grid.cells(rId, location_id_index).getValue();
        
        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_start;
        if (typeof term_start_index != 'undefined') term_start = dealDetail.grid.cells(rId, term_start_index).getValue();

        var buy_sell_index = dealDetail.grid.getColIndexById('buy_sell_flag');
        var buy_sell_flag;
        if (typeof buy_sell_index != 'undefined') buy_sell_flag = dealDetail.grid.cells(rId, buy_sell_index).getValue();

        if (shipper_code1_index) {
            var shipper_code1_combo = dealDetail.grid.cells(rId, shipper_code1_index).getCellCombo();           
            default_value_shipper1 = dealDetail.grid.cells(rId, shipper_code1_index).getValue();
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id,  "template_id": template_id, "counterparty_id": counterparty_id, "location_id": location_id,  "deal_fields": 'shipper_code1', "term_start": term_start, "default_value":default_value_shipper1, "contract_id" : contract_id, "buy_sell_flag" : buy_sell_flag, "load_default": insert_mode == 1 || deal_id != 'NULL' ? 1 : 0 || copy_insert_mode == 'y' ? 1 : 0};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            dealDetail.grid.cells(rId, shipper_code1_index).setValue('');
            shipper_code1_combo.clearAll();

            if (child_rows == 0) {
                shipper_code1_combo.enableFilteringMode(true);
                shipper_code1_combo.load(url,function () {                
                    shipper_code1_combo.forEachOption(function(option) {
                        if (option.selected == true) {
                            dealDetail.grid.cells(rId, shipper_code1_index).setValue(option.value);
                        }
                    }); 
                    
                }); 
            }        
                                 
        }

        if (shipper_code2_index) {
            var shipper_code2_combo = dealDetail.grid.cells(rId, shipper_code2_index).getCellCombo();           
            default_value_shipper2 = dealDetail.grid.cells(rId, shipper_code2_index).getValue();  
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id,  "template_id": template_id, "counterparty_id": counterparty_id, "location_id": location_id,  "deal_fields": 'shipper_code2', "term_start": term_start, "default_value":default_value_shipper2, "contract_id" : contract_id, "buy_sell_flag" : buy_sell_flag, "load_default": insert_mode == 1 || deal_id != 'NULL' ? 1 : 0 ||  copy_insert_mode == 'y' ? 1 : 0};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            dealDetail.grid.cells(rId, shipper_code2_index).setValue('');
            shipper_code2_combo.clearAll(); 

            if (child_rows == 0) {     
                shipper_code2_combo.enableFilteringMode(true);
                shipper_code2_combo.load(url,function () {                
                    shipper_code2_combo.forEachOption(function(options) { 
                        if (options.selected == true) {
                            dealDetail.grid.cells(rId, shipper_code2_index).setValue(options.value);
                        }
                    }); 
                    
                });   
            }                   
        }
    }

    /**
     * [undock_details Undock detail layout]
     */
    dealDetail.undock_details = function(cell) {
        var deal_id = '<?php echo $deal_id; ?>';
        var layout_obj = dealDetail.deal_detail;
        layout_obj.cells(cell).undock(300, 300, 900, 700);
        layout_obj.dhxWins.window(cell).button("park").hide();
        layout_obj.dhxWins.window(cell).maximize();
        layout_obj.dhxWins.window(cell).centerOnScreen();
        layout_obj.dhxWins.window(cell).setText('Details - ' + deal_id);
    }

    /**
     * [on_dock_detail_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    dealDetail.on_dock_detail_event = function(id) {
        if (id == 'b') {
            $(".undock_pricing_detail").show();
        }

        if (id == 'c') {
            $(".undock_detail").show();
        }
    }
    /**
     * [on_undock_detail_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    dealDetail.on_undock_detail_event = function(id) {
        if (id == 'b') {
            $(".undock_pricing_detail").hide();
        }
        if (id == 'c') {
            $(".undock_detail").hide();
        }
    }

    /**
     * [get_refresh_param Build refresh param]
     * @return {[type]} [description]
     */
    dealDetail.get_refresh_param = function() {
        var deal_id = '<?php echo $deal_id; ?>';
        var template_id = '<?php echo $template_id; ?>';
        var view_deleted = '<?php echo $view_deleted; ?>';
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        var deal_type_id = '<?php echo $deal_type_id;?>';
        var pricing_type_id = '<?php echo $pricing_type_id;?>';
        var term_frequency = '<?php echo $term_frequency;?>';
        var commodity_id = '<?php echo $commodity_id;?>';

        var data = {
            "action":"spa_deal_update_new",
            "flag":"e",
            "source_deal_header_id":deal_id,
            "view_deleted":view_deleted,
            "grid_type":"tg",
            "grouping_column":"deal_group",
            "grouping_type":3,
            "template_id":template_id,
            "copy_deal_id":copy_deal_id,
            "pricing_process_id":pricing_process_id,
            "deal_type_id":deal_type_id,
            "pricing_type":pricing_type_id,
            "term_frequency":term_frequency,
            "process_id":process_id,
            "commodity_id":commodity_id

        }

        return data;
    }

    /**
     * [deal_menu_click Grid menu click]
     * @param  {[type]} id [Menu id]
     */
    dealDetail.deal_menu_click = function(id) {
        switch(id) {
            case "refresh":
                var deal_id = '<?php echo $deal_id; ?>';
                var data = dealDetail.get_refresh_param();

                if ((dealDetail.grid.getColIndexById('shipper_code1') || dealDetail.grid.getColIndexById('shipper_code2')) && deal_id != 'NULL') {
                    dealDetail.deal_detail_menu.setItemDisabled('shipper_code_report');
                } 
                
                var changed_rows = dealDetail.grid.getChangedRows(true);
                if (changed_rows != '' || dealDetail.deleted_details.length > 0) {
                    confirm_messagebox("There are unsaved changes. Are you sure you want to refresh grid?", function() {
                        dealDetail.deleted_details.length = 0;

                        dealDetail.deal_detail.cells('c').progressOn();
                        dealDetail.refresh_grid(data, function() {
                            dealDetail.deal_detail.cells("c").progressOff();
                            dealDetail.grid.forEachRow(function(id) {
                                dealDetail.load_shipper_dropdown(id, 'refresh_confimation');
                            });
                        });
                        dealDetail.grid.setUserData("", 'formula_id', 10211093);
                        dealDetail.grid_row_selection(null);
                    });
                } else {
                    dealDetail.deal_detail.cells('c').progressOn();
                    dealDetail.refresh_grid(data, function() {
                        dealDetail.deal_detail.cells("c").progressOff();
                        
                        if (deal_id != 'NULL' && copy_insert_mode != 'y') {
                            var win_id = 'w_' + deal_id;

                            if (window.parent.update_window) {
                                var win_obj = window.parent.update_window.window(win_id);
                            } else if (window.parent.dhx_wins) {
                                var win_obj = window.parent.dhx_wins.getTopmostWindow();
                            } else if (window.parent.dhxWins) {
                                var win_obj = window.parent.dhxWins.getTopmostWindow();
                            }
                            var win_text = '';
                            if (win_obj) {
                                win_text = win_obj.getText();
                            }
                            if (win_obj && $.trim(win_text).substring(0, 4) == 'Deal') {
                                win_obj.progressOff();
                            }
                        } else if (copy_deal_id != 'NULL' || template_id != 'NULL' || copy_insert_mode == 'y') {
                            if (is_shaped == 'y') {
                                var tab_obj = dealDetail.deal_tab;
                                var iterate_check = true;
                                tab_obj.forEachTab(function(tab) {
                                    if(iterate_check) {
                                        var form_obj = tab.getAttachedObject();
                                        if (form_obj instanceof dhtmlXForm) {
                                            var prof_gran_combo = form_obj.getCombo('profile_granularity');
                                            if (prof_gran_combo) {
                                                var initial_shaped_gran = form_obj.getItemValue('profile_granularity');
                                                dealDetail.shape_change(initial_shaped_gran);
                                                iterate_check = false;
                                            }
                                        }
                                    }
                                });
                            }
                            var win_obj = window.parent.deal_insert_window.window("w1");
                            if (win_obj) {
                                win_obj.progressOff();
                            }
                        }
                        var col_index_location_id = dealDetail.grid.getColIndexById('location_id');
                        var detail_commodity_id_index = dealDetail.grid.getColIndexById('detail_commodity_id');
                        var curve_id_index = dealDetail.grid.getColIndexById('curve_id');
                        if (col_index_location_id) {
                            var cmb_location = dealDetail.grid.getColumnCombo(col_index_location_id);
                            dealDetail.grid.forEachRow(function(id){
                                var location_id = dealDetail.grid.cells(id,col_index_location_id).getValue();
                                if (insert_mode == 1) {
                                    if (dealDetail.grid.hasChildren(id) == 0) {
                                        // Set location combo value by default when not present
                                        if (cmb_location.getIndexByValue(location_id) == -1 || (!location_id || location_id == '')) {
                                            if (!cmb_location.getOptionByIndex(0).value || cmb_location.getOptionByIndex(0).value == '') {
                                                location_id = cmb_location.getOptionByIndex(1).value;
                                            } else {
                                                location_id = cmb_location.getOptionByIndex(0).value;
                                            }
                                            dealDetail.grid.cells(id,col_index_location_id).setValue(location_id);
                                        }

                                        // Set curve value based on location. If not present select null by default
                                        if (curve_id_index) {
                                            var cmb_curve = dealDetail.grid.getColumnCombo(curve_id_index);
                                            var curve_id = dealDetail.grid.cells(id,curve_id_index).getValue();
                                            if (valuation_index_obj.location[location_id] && cmb_curve.getIndexByValue(valuation_index_obj.location[location_id]) != -1) {
                                                dealDetail.grid.cells(id,curve_id_index).setValue(valuation_index_obj.location[location_id]);
                                            } else if (cmb_curve.getIndexByValue(curve_id) == -1) {
                                                dealDetail.grid.cells(id,curve_id_index).setValue('');
                                            }
                                        }

                                    }
                                }
                                
                                if (location_id != '' && detail_commodity_id_index) {
                                    dealDetail.grid.callEvent("onEditCell", [2, id, col_index_location_id, location_id]);
                                } else {
                                    dealDetail.load_shipper_dropdown(id, 'refresh');
                                }
                            });
                        }
                        dealDetail.add_missing_column();
                    });

                    dealDetail.grid.setUserData("", 'formula_id', 10211093);
                    dealDetail.grid_row_selection(null);

                    /******* Removed pricing tab : Its availble in new popup window from price button in new enhancement.
                     if (enable_pricing == 'y') {
                        var price_tab = dealDetail.deal_detail_tab.cells('tab_pricing');
                        var param_pricing = {pricing_provisional:'p'}
                        var pricing_url = 'deal.pricing.php?' + $.param(param_pricing);
                        price_tab.attachURL(pricing_url);
                    }

                     if (enable_provisional_tab == 'y') {
                        var provisional_tab = dealDetail.deal_detail_tab.cells('tab_provisional');
                        var param_prov= {pricing_provisional:'q'}
                        var provisional_url = 'deal.pricing.php?' + $.param(param_prov);
                        provisional_tab.attachURL(provisional_url);
                    }
                     */
                }
                break;
            case "add_term":
                dealDetail.open_term_window('term');
                break;
            case "add_leg":
                dealDetail.open_term_window('leg');
                break;
            case "delete_term":
                dealDetail.delete_term();
                break;
            case "undo_cell":
                dealDetail.grid.doUndo();
                break;
            case "redo_cell":
                dealDetail.grid.doRedo();
                break;
            case "pdf":
                dealDetail.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                dealDetail.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case "add_group":
                var counter = 0;
                dealDetail.grid.forEachRow(function(id){
                    if (counter == 0) {
                        var selected_id = dealDetail.grid.getSelectedRowId();

                        if (copy_deal_id != 'NULL' && selected_id != '') {
                            id = selected_id;
                        }
                        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
                        var group_index = dealDetail.grid.getColIndexById('deal_group');
                        var group_id_index = dealDetail.grid.getColIndexById('group_id');
                        var group_id = dealDetail.grid.collectValues(group_id_index);

                        var detail_flag_index = dealDetail.grid.getColIndexById('detail_flag');
                        var max_group = Math.max.apply(null, group_id);
                        var leg_index = dealDetail.grid.getColIndexById('blotterleg');
                        var leg = dealDetail.grid.cells(id, leg_index).getValue();
                        var legs = dealDetail.grid.collectValues(leg_index);
                        var max_leg = Math.max.apply(null, legs);
                        max_group = max_group+1;
                        var new_id = (new Date()).valueOf();

                        var group_ids = dealDetail.grid.collectValues(group_id_index);
                        var unique_groups = _.uniq(group_ids);
                        var group_count = unique_groups.length + 1;

                        var group_array = new Array();
                        for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                            if (cellIndex == source_deal_detail_index) {
                                group_array.push("NEW_" + new_id);
                            } else if (group_index == cellIndex) {
                                group_array.push(group_count);
                            } else if(group_id_index == cellIndex) {
                                group_array.push(max_group);
                            } else if (detail_flag_index == cellIndex) {
                                group_array.push(0);
                            } else {
                                var val = dealDetail.grid.cells(id, cellIndex).getValue();
                                var type = dealDetail.grid.getColType(cellIndex);

                                if (type == 'win_link_custom') {
                                    val = val + '^' + dealDetail.grid.cells(id, cellIndex).getTitle();
                                }
                                group_array.push(val);
                            }
                        }

                        dealDetail.grid.addRow(new_id, group_array, 0, null, null,true);

                        var j=0;
                        if (copy_deal_id == 'NULL') {
                            dealDetail.grid._h2.forEachChild(id,function(element){
                                var values_array = new Array();
                                values_array.push('');

                                for(var cellIndex = 1; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                                    if (group_id_index == cellIndex) {
                                        values_array.push(max_group);
                                    } else {
                                        if (element.id != null) {
                                            var val = dealDetail.grid.cells(element.id, cellIndex).getValue();
                                            var type = dealDetail.grid.getColType(cellIndex);

                                            if (type == 'win_link_custom') {
                                                val = val + '^' + dealDetail.grid.cells(element.id, cellIndex).getTitle();
                                            }
                                            values_array.push(val);
                                        } else {
                                            values_array.push('');
                                        }
                                    }
                                }
                                dealDetail.grid.addRow((new Date()).valueOf(), values_array, j, new_id);
                                j++;
                            })
                        }
                    }
                    counter++;
                });
                break;
            case "post":
                dealDetail.call_efp_trigger('e');
                break;
            case "trigger":
                dealDetail.call_efp_trigger('t');
                break;
            case "close":
                dealDetail.call_deal_close();
                break;
            case "update_volume":
                dealDetail.open_update_volume();
                break;
            case 'schedule_deal':
                dealDetail.open_schedule_deal();
                break;
            case "add_container":
                dealDetail.open_container_window();
                break;
            case "add_product":
                dealDetail.add_product();
                break;
            case 'exercise':
                dealDetail.exercise_deal();
                break;
            case 'update_actual':
                var actualization_flag = '<?php echo $actualization_flag; ?>';

                if (actualization_flag != 'NULL' && (actualization_flag != 's' || actualization_flag != 'm')) {
                    return;
                } else {
                    dealDetail.open_update_actual();
                }

                break;
            case 'lock':
                dealDetail.update_detail_lock_status('y');
                break;
            case 'unlock':
                dealDetail.update_detail_lock_status('n');
                break;
            case 'price':
                dealDetail.open_price();
                break;
            case 'provisional_price':
                dealDetail.open_provisional_price();
                break;
            case 'view_certificate':
                dealDetail.open_report('view_certificate');
            case 'shipper_code_report':
                dealDetail.open_report('shipper_code_report');
                break;
            case 'udt':
                dealDetail.open_udt('d');
                break;
                default:
                if (id.indexOf("dashboard_") != -1) {
                    var str_len = id.length;
                    var dashboard_id = id.substring(10, str_len);
                    var dashboard_name = dealDetail.deal_detail_menu.getItemText(id);
                    var selected_ids =  '<?php echo $deal_id; ?>';
                    var param_filter_xml ='<Root><FormXML param_name="source_deal_header_id" param_value="' + selected_ids + '"></FormXML></Root>';
                    
                    show_dashboard_report(dashboard_id, dashboard_name, param_filter_xml)
                    break;
                } else {                	
                    show_messagebox("Under Maintainence! We will be back soon!");
                    break;
                }
        }
    }

    /**
     * [open_schedule_deal Schedule Deal]
     */

    dealDetail.open_provisional_price = function() {
        deal_id = (deal_id == 'NULL') ? 'New' : deal_id;
        var win_title = 'Deal Provisional Pricing Detail - ' + deal_id;
        var win_url = 'deal.provisional.price.detail.php';


        source_deal_detail_id = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('source_deal_detail_id')).getValue();
        /*
                term_start = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('term_start')).getTitle();
                term_end = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('term_end')).getTitle();
                deal_group = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('deal_group')).getTitle();
                location_id = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('location_id')).getTitle();
                volume = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('deal_volume')).getTitle();
                uom = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('deal_volume_uom_id')).getTitle();
                frequency = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('deal_volume_frequency')).getTitle();
                total_volume = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('total_volume')).getTitle();
                position_uom = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('position_uom')).getTitle();
                currency_id = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('fixed_price_currency_id')).getTitle();

                // console.log(deal_group + ' | ' + term_start + ' | ' + term_end + ' | ' + location_id + ' | ' + volume + ' | ' + uom + ' | ' + frequency + ' | ' + total_volume + ' | ' + position_uom + ' | ' + currency_id);

                var filter_details = deal_group + ' | ' + term_start + ' | ' + term_end + ' | ' + location_id + ' | ' + volume + ' | ' + uom + ' | ' + frequency + ' | ' + total_volume + ' | ' + position_uom + ' | ' + currency_id;*/

        if (deal_provisional_price_data_process_id)
            win_url += '?source_deal_detail_id=' + source_deal_detail_id + '&deal_provisional_price_data_process_id=' + deal_provisional_price_data_process_id;
        else
            win_url += '?source_deal_detail_id=' + source_deal_detail_id;

        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }

        win = volume_window.createWindow('w1', 0, 0, 400, 400);
        win.progressOn();
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.addUserButton("reload", 0, "Reload", "Reload");
        win.maximize();

        win.attachURL(win_url, null);

        win.attachEvent("onContentLoaded", function(win){
            win.progressOff();
        });

    }

    dealDetail.open_price = function() {
        deal_id = (deal_id == 'NULL') ? 'New' : deal_id;
        var win_title = 'Deal Pricing Detail - ' + deal_id;
        var win_url = 'deal.price.detail.php';


        source_deal_detail_id = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('source_deal_detail_id')).getValue();
        /*
                term_start = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('term_start')).getTitle();
                term_end = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('term_end')).getTitle();
                deal_group = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('deal_group')).getTitle();
                location_id = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('location_id')).getTitle();
                volume = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('deal_volume')).getTitle();
                uom = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('deal_volume_uom_id')).getTitle();
                frequency = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('deal_volume_frequency')).getTitle();
                total_volume = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('total_volume')).getTitle();
                position_uom = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('position_uom')).getTitle();
                currency_id = dealDetail.grid.cells(dealDetail.grid.getSelectedRowId(),  dealDetail.grid.getColIndexById('fixed_price_currency_id')).getTitle();

                // console.log(deal_group + ' | ' + term_start + ' | ' + term_end + ' | ' + location_id + ' | ' + volume + ' | ' + uom + ' | ' + frequency + ' | ' + total_volume + ' | ' + position_uom + ' | ' + currency_id);

                var filter_details = deal_group + ' | ' + term_start + ' | ' + term_end + ' | ' + location_id + ' | ' + volume + ' | ' + uom + ' | ' + frequency + ' | ' + total_volume + ' | ' + position_uom + ' | ' + currency_id;*/

        if (deal_price_data_process_id != '' || deal_price_data_process_id != 'NULL' || deal_provisional_price_data_process_id == '' || deal_provisional_price_data_process_id == 'NULL' )
            win_url += '?source_deal_detail_id=' + source_deal_detail_id + '&deal_price_data_process_id=' + deal_price_data_process_id;
        else if (deal_provisional_price_data_process_id == '' || deal_provisional_price_data_process_id == 'NULL' || deal_price_data_process_id != '' || deal_price_data_process_id != 'NULL')
            win_url += '&source_deal_detail_id=' + source_deal_detail_id + '&deal_provisional_price_data_process_id=' + deal_provisional_price_data_process_id;
        else if (deal_provisional_price_data_process_id != '' || deal_provisional_price_data_process_id != 'NULL' || deal_price_data_process_id != '' || deal_price_data_process_id != 'NULL')
            win_url += '?source_deal_detail_id=' + source_deal_detail_id + '&deal_price_data_process_id=' + deal_price_data_process_id +'&deal_provisional_price_data_process_id=' + deal_provisional_price_data_process_id;
        else
            win_url += '&source_deal_detail_id=' + source_deal_detail_id;

        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }

        win = volume_window.createWindow('w1', 0, 0, 400, 400);
        win.progressOn();
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.addUserButton("reload", 0, "Reload", "Reload");
        win.maximize();

        win.attachURL(win_url, null);

        win.attachEvent("onContentLoaded", function(win){
            win.progressOff();
        });

    }

    dealDetail.open_schedule_deal = function() {
        var row_id = dealDetail.grid.getSelectedRowId();
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var source_deal_detail_id = dealDetail.grid.cells(row_id, source_deal_detail_index).getValue();

        if (row_id.indexOf(',') > -1) {
            dhtmlx.alert({
                title: 'Alert',
                type: 'alert',
                text: 'Please select one record to process.'
            });
            return;
        }
        //dealDetail.unload_deals_window();
        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }

        var win_title = 'Schedule Deal';
        var win_url = 'schedule.deal.php';


        var param = {};
        var cols = new Array();
        dealDetail.grid.forEachCell(0, function(cell_obj, ind) {
            cols.push(dealDetail.grid.getColumnId(ind));
        })



        param.term_start = dates.convert_to_sql(dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('term_start')).getValue());
        param.term_end = dates.convert_to_sql(dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('term_end')).getValue());
        //param.leg = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('Leg')).getValue();
        //param.location_id = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('location_id')).getValue();
        param.volume = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('deal_volume')).getValue();


        //param.location_id = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('location_index')).getValue();
        //param.counterparty_id = dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('counterparty')).getValue();

        //param.term = dates.convert_to_sql(dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('term_start')).getValue());
        // param.term_end = dates.convert_to_sql(dealDetail.grid.cells(row_id, dealDetail.grid.getColIndexById('term_end')).getValue());
        // param.source_deal_header_id = selected_ids;
        param.group_by = 'Deal';
        //
        var deal_id = '<?php echo $deal_id; ?>';
        win_url += '?term=' + param.term_start + '&term_end=' + param.term_end + '&group_by=' + param.group_by + '&source_deal_header_id=' + deal_id + '&source_deal_detail_id=' + source_deal_detail_id;


        var win = volume_window.createWindow('w1', 0, 0, 400, 400);
        win.progressOn();
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.addUserButton("reload", 0, "Reload", "Reload");
        win.maximize();

        win.attachURL(win_url, null);

        win.attachEvent("onContentLoaded", function(win){
            win.progressOff();
        });


    }

    var deal_close_window;
    /**
     * [call_deal_close Deal Close function]
     */
    dealDetail.call_deal_close = function() {
        var deal_id = '<?php echo $deal_id; ?>';

        dealDetail.unload_deal_close_window();
        if (!deal_close_window) {
            deal_close_window = new dhtmlXWindows();
        }

        var win_title = "Close - " + deal_id;
        var win_url = 'deal.close.php';

        var win = deal_close_window.createWindow('w1', 0, 0, 600, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL(win_url, false, {deal_id:deal_id});

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var status = $('textarea[name="txt_status"]', ifrDocument).val();
            if (status != 'cancel') dealDetail.refresh_efp_trigger('NULL', 'NULL');
            return true;
        });
    }

    /**
     * [unload_deal_close_window Unload deal_close_window]
     */
    dealDetail.unload_deal_close_window = function() {
        if (deal_close_window != null && deal_close_window.unload != null) {
            deal_close_window.unload();
            deal_close_window = w1 = null;
        }
    }

    var efp_trigger_window;
    /**
     * [call_efp_trigger Load EFP & Trigger]
     * @param  {[type]} type [EFP Or Trigger]
     */
    dealDetail.call_efp_trigger = function(type) {
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var row_id = dealDetail.grid.getSelectedRowId();
        var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
        var is_future = '<?php echo $future_deal;?>';

        dealDetail.unload_efp_trigger_window();
        if (!efp_trigger_window) {
            efp_trigger_window = new dhtmlXWindows();
        }

        var win_title = (type == 'e') ? ((is_future == 'y') ? "Future" : "Post") : "Trigger";
        var win_url = 'efp.trigger.php';

        var win = efp_trigger_window.createWindow('w1', 0, 0, 600, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL(win_url, false, {type:type,detail_id:detail_id});

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var status = $('textarea[name="txt_status"]', ifrDocument).val();
            if (status != 'cancel') {
                dealDetail.refresh_efp_trigger(detail_id, 'NULL');
                dealDetail.deal_menu_click('refresh');
            }
            return true;
        });
    }

    /**
     * [refresh_efp_trigger Refesh EFP Grid]
     * @param  {[type]} detail_id [Deal Detail Id]
     */
    dealDetail.refresh_efp_trigger = function(detail_id, group_id) {
        var deal_id = '<?php echo $deal_id; ?>';
        if (enable_efp == 'y') {
            if (future_deal == 'y') {
                var sql_param = {
                    "action":"spa_deal_close",
                    "flag":"p",
                    "deal_id":deal_id,
                    "grid_type":"g"
                }
            } else {
                var sql_param = {
                    "action":"spa_efp_trigger",
                    "flag":"h",
                    "deal_id":deal_id,
                    "detail_id":detail_id,
                    "grid_type":"g"
                }
            }
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            dealDetail.deal_efp.clearAll();
            dealDetail.deal_efp.load(sql_url);
        }
        if (enable_trigger == 'y') {
            var sql_param = {
                "action":"spa_efp_trigger",
                "flag":"g",
                "deal_id":deal_id,
                "detail_id":detail_id,
                "grid_type":"g"
            }
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            dealDetail.deal_triggers.clearAll();
            dealDetail.deal_triggers.load(sql_url);
        }

        if (enable_exercise == 'y') {
            var sql_param = {
                "action":"spa_deal_exercise_detail",
                "flag":"s",
                "source_deal_detail_id":detail_id,
                "source_deal_header_id":deal_id,
                "source_deal_group_id":group_id,
                "grid_type":"g"
            }
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            dealDetail.deal_exercise.clearAll();
            dealDetail.deal_exercise.load(sql_url);
        }
    }

    /**
     * [unload_term_window Unload Terms]
     */
    dealDetail.unload_efp_trigger_window = function() {
        if (efp_trigger_window != null && efp_trigger_window.unload != null) {
            efp_trigger_window.unload();
            efp_trigger_window = w1 = null;
        }
    }

    /**
     * [delete_term Delete Term]
     */
    dealDetail.delete_term = function() {
        var no_of_rows = 0;
        var no_of_parent = 0;
        var deal_id = '<?php echo $deal_id; ?>';

        for (var i=0; i < dealDetail.grid.getRowsNum(); i++){
            if (no_of_parent == 2) break;
            if (no_of_rows == 2) break;

            var id = dealDetail.grid.getRowId(i);
            var pid = dealDetail.grid.getParentId(id);
            if (pid == 0) no_of_parent++;
            else no_of_rows++;
        };

        if (no_of_parent < 2 && no_of_rows < 2) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text: "Deal must have some details."
            });
            return;
        }
        var row_id = dealDetail.grid.getSelectedRowId();
        var parent_id = dealDetail.grid.getParentId(row_id);
        var no_of_child = dealDetail.grid.hasChildren(row_id);
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');

        if (parent_id == 0 && no_of_child > 0) {
            dealDetail.grid._h2.forEachChild(row_id,function(element){
                var source_deal_detail_id = dealDetail.grid.cells(element.id, source_deal_detail_index).getValue();
                if (source_deal_detail_id.indexOf("NEW_") == -1 && source_deal_detail_id != '') {
                    dealDetail.deleted_details.push(source_deal_detail_id);
                }
            })
        } else {
            var source_deal_detail_id = dealDetail.grid.cells(row_id, source_deal_detail_index).getValue();
            if (source_deal_detail_id.indexOf("NEW_") == -1 && source_deal_detail_id != '') {
                dealDetail.deleted_details.push(source_deal_detail_id);
            }
        }

        dealDetail.grid.deleteRow(row_id);
        dealDetail.grid_row_selection(null);
    }

    var term_window;
    /**
     * [open_term_window Open term Window to add leg and term]
     * @param  {[type]} type [description]
     * @return {[type]}      [description]
     */
    dealDetail.open_term_window = function(type) {
        var deal_id = '<?php echo $deal_id; ?>';
        var deal_date = '<?php echo $deal_date;?>';
        var term_start = '';
        var term_end = '';

        dealDetail.unload_term_window();
        if (!term_window) {
            term_window = new dhtmlXWindows();
        }

        var win_title = (type == 'term') ? "Add Term" : (type == 'leg') ? "Add leg" : "Update Term";
        var win_url = 'add.terms.php';
        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var min_max_term = dealDetail.grid.collectValues(term_start_index);
        min_max_term.sort(function(a, b){
            return Date.parse(a) - Date.parse(b);
        });

        var term_end_index = dealDetail.grid.getColIndexById('term_end');
        var max_term_end = dealDetail.grid.collectValues(term_end_index);
        max_term_end.sort(function(a, b){
            return Date.parse(a) - Date.parse(b);
        });

        if (type == 'leg') {
            var max_date = max_term_end[max_term_end.length-1];
            var min_date = min_max_term[0];
        } else if (type == 'term') {
            min_date = deal_date;
            max_date = min_max_term[min_max_term.length-1];
        } else {
            var row_id = dealDetail.grid.getSelectedRowId();
        }
        min_date = (min_date == undefined) ? '' : min_date;
        max_date = (max_date == undefined) ? '' : max_date;

        var win = term_window.createWindow('w1', 0, 0, 530, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL(win_url, false, {deal_id:deal_id,term_start:term_start,term_end:term_end,min_date:min_date,max_date:max_date,type:type});

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var from_date = $('textarea[name="txt_from_date"]', ifrDocument).val();
            var to_date = $('textarea[name="txt_to_date"]', ifrDocument).val();

            if (from_date.toLowerCase() != 'cancel' && from_date != '') {
                if (type == 'term') {
                    dealDetail.add_term(from_date, to_date);
                } else {
                    dealDetail.add_leg(from_date, to_date);
                }
            }
            return true;
        });
    }

    /**
     * [unload_term_window Unload Terms]
     */
    dealDetail.unload_term_window = function() {
        if (term_window != null && term_window.unload != null) {
            term_window.unload();
            term_window = w1 = null;
        }
    }

    /**
     * [open_container_window Open Container Name Window]
     */
    dealDetail.open_container_window = function() {
        var row_id = dealDetail.grid.getSelectedRowId();
        var parent_id = dealDetail.grid.getParentId(row_id);
        var no_of_child = dealDetail.grid.hasChildren(row_id);

        if (group_name_win != null && group_name_win.unload != null) {
            group_name_win.unload();
            group_name_win = w1 = null;
        }
        var deal_id = '<?php echo $deal_id; ?>';

        if (!group_name_win) {
            group_name_win = new dhtmlXWindows();
        }

        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');

        if (parent_id == 0 && no_of_child > 0) {
            var min_max_term = dealDetail.grid.collectValues(term_start_index);
            min_max_term.sort(function(a, b){
                return Date.parse(a) - Date.parse(b);
            });
            var max_term_start = min_max_term[min_max_term.length-1];
            var max_term_end = dealDetail.grid.collectValues(term_end_index);
            max_term_end.sort(function(a, b){
                return Date.parse(a) - Date.parse(b);
            });
            var max_term_end = max_term_end[max_term_end.length-1];
        } else {
            var max_term_start = dealDetail.grid.cells(row_id, term_start_index).getValue();
            var max_term_end = dealDetail.grid.cells(row_id, term_end_index).getValue();
        }

        var win_title = 'Add Shipment';
        var win_url = 'group.name.php';
        var param

        var win = group_name_win.createWindow('w1', 0, 0, 550, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL(win_url, false, {type:'c',term_start:max_term_start,term_end:max_term_end});

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var new_group_name = $('textarea[name="txt_group_name"]', ifrDocument).val();
            var term_start = $('textarea[name="txt_term_start"]', ifrDocument).val();
            var term_end = $('textarea[name="txt_term_end"]', ifrDocument).val();
            var btn_click = $('textarea[name="txt_btn_click"]', ifrDocument).val();

            if (btn_click == 'ok') {
                dealDetail.add_container(parent_id, row_id, new_group_name, term_start, term_end);
            }

            return true;
        });
    }

    /**
     * [add_container Add Shipment]
     * @param {[type]} parent_id      [Parent Id of selected row]
     * @param {[type]} row_id         [Selected Row]
     * @param {[type]} container_name [Container Name]
     */
    dealDetail.add_container = function(parent_id, row_id, container_name, term_start, term_end) {
        var no_of_child = dealDetail.grid.hasChildren(row_id);
        var group_index = dealDetail.grid.getColIndexById('deal_group');
        var group_id_index = dealDetail.grid.getColIndexById('group_id');
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');

        var group_ids = dealDetail.grid.collectValues(group_id_index);
        var unique_groups = _.uniq(group_ids);
        var group_count = unique_groups.length;
        var new_group_id = group_count+1;

        var leg_index = dealDetail.grid.getColIndexById('blotterleg');
        var legs = dealDetail.grid.collectValues(leg_index);
        var max_leg = Math.max.apply(null, legs);
        var new_leg = max_leg + 1;

        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');

        if (parent_id == 0 && no_of_child > 0) {
            var new_id = (new Date()).valueOf();
            dealDetail.grid.addRow(new_id, [], 0 , 0, 'folder.gif', true);
            dealDetail.grid.cells(new_id, group_id_index).setValue(new_group_id);
            dealDetail.grid.cells(new_id, group_index).setValue(container_name);
            dealDetail.grid._h2.forEachChild(row_id, function(element){
                var values_array = new Array();
                var new_row_id = (new Date()).valueOf();

                for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                    if (cellIndex == source_deal_detail_index) {
                        values_array.push("NEW_" + new_row_id);
                    } else if (group_index == cellIndex) {
                        values_array.push('');
                    } else if (cellIndex == group_id_index) {
                        values_array.push(new_group_id);
                    } else if (leg_index == cellIndex) {
                        values_array.push(new_leg);
                        new_leg++;
                    } else if (cellIndex == term_start_index) {
                        values_array.push(term_start);
                    } else if (cellIndex == term_end_index) {
                        values_array.push(term_end);
                    } else {
                        var val = dealDetail.grid.cells(element.id, cellIndex).getValue();
                        var type = dealDetail.grid.getColType(cellIndex);

                        if (type == 'win_link_custom') {
                            val = val + '^' + dealDetail.grid.cells(element.id, cellIndex).getTitle();
                        }
                        values_array.push(val);
                    }
                }
                dealDetail.grid.addRow(new_row_id, values_array, null, new_id, null, false);
            });
        } else {
            var values_array = new Array();
            var new_row_id = (new Date()).valueOf();

            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                if (cellIndex == source_deal_detail_index) {
                    values_array.push("NEW_" + new_row_id);
                } else if (group_index == cellIndex) {
                    values_array.push(container_name);
                } else if (cellIndex == group_id_index) {
                    values_array.push(new_group_id);
                } else if (leg_index == cellIndex) {
                    values_array.push(new_leg);
                } else if (cellIndex == term_start_index) {
                    values_array.push(term_start);
                } else if (cellIndex == term_end_index) {
                    values_array.push(term_end);
                } else {
                    var val = dealDetail.grid.cells(row_id, cellIndex).getValue();
                    var type = dealDetail.grid.getColType(cellIndex);

                    if (type == 'win_link_custom') {
                        val = val + '^' + dealDetail.grid.cells(row_id, cellIndex).getTitle();
                    }
                    values_array.push(val);
                }
            }
            dealDetail.grid.addRow(new_row_id, values_array, 0, 0, 'folder.gif', false);
        }
    }

    dealDetail.add_product = function() {
        var row_id = dealDetail.grid.getSelectedRowId();
        var parent_id = dealDetail.grid.getParentId(row_id);
        var no_of_child = dealDetail.grid.hasChildren(row_id);

        var no_of_child = dealDetail.grid.hasChildren(row_id);
        var group_index = dealDetail.grid.getColIndexById('deal_group');
        var group_id_index = dealDetail.grid.getColIndexById('group_id');
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');

        var leg_index = dealDetail.grid.getColIndexById('blotterleg');
        var legs = dealDetail.grid.collectValues(leg_index);
        var max_leg = Math.max.apply(null, legs);
        var new_leg = max_leg + 1;

        if (parent_id == 0 && no_of_child < 1) {
            var new_id = (new Date()).valueOf();
            var values_array = new Array();

            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                if (group_index == cellIndex) {
                    values_array.push('');
                } else {
                    var val = dealDetail.grid.cells(row_id, cellIndex).getValue();
                    var type = dealDetail.grid.getColType(cellIndex);

                    if (type == 'win_link_custom') {
                        val = val + '^' + dealDetail.grid.cells(row_id, cellIndex).getTitle();
                    }
                    values_array.push(val);
                }

                if (cellIndex != group_index && cellIndex != group_id_index)
                    dealDetail.grid.cells(row_id, cellIndex).setValue('');
            }

            dealDetail.grid.addRow(new_id, values_array, null , row_id, null, false);
            var new_row_id = (new Date()).valueOf();
            dealDetail.grid.addRow(new_row_id, values_array, null , row_id, null, false);
            dealDetail.grid.cells(new_row_id, source_deal_detail_index).setValue("NEW_" + new_row_id);
            dealDetail.grid.cells(new_row_id, leg_index).setValue(new_leg);
            dealDetail.grid.openItem(row_id);
            dealDetail.grid.selectRowById(new_row_id,true,true,true);
        } else {
            var new_id = (new Date()).valueOf();
            var values_array = new Array();

            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                if (cellIndex == source_deal_detail_index) {
                    values_array.push("NEW_" + new_id);
                } else if (group_index == cellIndex) {
                    values_array.push('');
                } else if (leg_index == cellIndex) {
                    values_array.push(new_leg);
                } else {
                    var val = dealDetail.grid.cells(row_id, cellIndex).getValue();
                    var type = dealDetail.grid.getColType(cellIndex);

                    if (type == 'win_link_custom') {
                        val = val + '^' + dealDetail.grid.cells(row_id, cellIndex).getTitle();
                    }
                    values_array.push(val);
                }
            }
            dealDetail.grid.addRow(new_id, values_array, null , parent_id, null, false);
            dealDetail.grid.selectRowById(new_id,true,true,true);
        }
    }


    /**
     * [unload_apply_to_window Unload Apply To Window]
     */
    dealDetail.unload_apply_to_window = function() {
        if (apply_to_window != null && apply_to_window.unload != null) {
            apply_to_window.unload();
            apply_to_window = w1 = null;
        }
    }

    /**
     * [unload_document_window Unload Document Window]
     */
    dealDetail.unload_document_window = function() {
        if (document_window != null && document_window.unload != null) {
            document_window.unload();
            document_window = w1 = null;
        }
    }


    /**
     * [add_term Add term]
     * @param {[array]} result [result array for terms]
     */
    dealDetail.add_term = function(from_date, to_date) {
        var group_index = dealDetail.grid.getColIndexById('deal_group');
        var group_id_index = dealDetail.grid.getColIndexById('group_id');
        var leg_index = dealDetail.grid.getColIndexById('blotterleg');
        var legs = dealDetail.grid.collectValues(leg_index);
        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');
        var contract_expiration_date_index = dealDetail.grid.getColIndexById('contract_expiration_date');
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var deal_volume_index = dealDetail.grid.getColIndexById('deal_volume');
        var total_volume_index = dealDetail.grid.getColIndexById('total_volume');
        var row_id = '';
        var i = 0;
        var added_from_sdd_id = '';
        var ids_to_apply_price = '';

        $.each(legs, function(index, value) {
            var values_array = new Array();
            var new_id = (new Date()).valueOf();
            var leg_row = dealDetail.grid.findCell(value, leg_index, true, true);

            if (leg_row != "") {
                row_id = leg_row.toString().substring(0, leg_row.toString().indexOf(","));

                var parent_id = dealDetail.grid.getParentId(row_id);

                if (parent_id != 0) {
                    row_id = dealDetail.grid.getChildItemIdByIndex(parent_id, 0);
                }

            } else {
                row_id = dealDetail.grid.getSelectedRowId();
            }

            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                if (cellIndex == term_start_index) {
                    values_array.push(from_date);
                } else if (cellIndex == term_end_index) {
                    values_array.push(to_date);
                } else if (cellIndex == contract_expiration_date_index) {
                    values_array.push(to_date);
                } else if (cellIndex == source_deal_detail_index || cellIndex == group_id_index) {
                    values_array.push("NEW_" + new_id);
                } else if (group_index == cellIndex) {
                    values_array.push('New Group');
                } else if (leg_index == cellIndex) {
                    values_array.push(value);
                } else if (is_shaped == 'y' && (cellIndex == deal_volume_index || cellIndex == total_volume_index)) {
                    values_array.push('');
                } else {
                    if (row_id != null) {
                        var val = dealDetail.grid.cells(row_id, cellIndex).getValue();
                        var type = dealDetail.grid.getColType(cellIndex);

                        if (type == 'win_link_custom') {
                            val = val + '^' + dealDetail.grid.cells(row_id, cellIndex).getTitle();
                        }
                        values_array.push(val);
                    } else {
                        values_array.push('');
                    }
                }

            }

            dealDetail.grid.addRow(new_id, values_array, 0 , null, null, true);
            dealDetail.load_shipper_dropdown(new_id, 'term_add');
            ids_to_apply_price = 'NEW_' + new_id;

            var selected_row_id = dealDetail.grid.getSelectedRowId();
            added_from_sdd_id = dealDetail.grid.cells(selected_row_id, source_deal_detail_index).getValue();

            dealDetail.grid.setUserData(new_id, 'added_from_sdd_id',added_from_sdd_id);

            if (i == 0) {
                dealDetail.grid.selectRowById(new_id);
            }
            i++;
        });

        deal_price_data_process_id = (deal_price_data_process_id != '') ? deal_price_data_process_id : 'NULL';
        deal_provisional_price_data_process_id = (deal_provisional_price_data_process_id != '') ? deal_provisional_price_data_process_id : 'NULL';

        var data = {
            "action":"spa_deal_pricing_detail",
            "flag":"t",
            "mode":"fetch",
            "xml_process_id": deal_price_data_process_id,
            "source_deal_detail_id": added_from_sdd_id,
            "ids_to_apply_price": ids_to_apply_price
        }

        adiha_post_data("return_array", data, '', '', 'dealDetail.check_pricing_data');

        var data_prov = {
            "action":"spa_deal_pricing_detail_provisional",
            "flag":"t",
            "mode":"fetch",
            "xml_process_id": deal_provisional_price_data_process_id,
            "source_deal_detail_id": added_from_sdd_id,
            "ids_to_apply_price": ids_to_apply_price
        }

        adiha_post_data("return_array", data_prov, '', '', 'dealDetail.check_provisional_pricing_data');
    }

    /**
     * [add_leg add leg]
     * @param {[array]} result [result array for terms]
     */
    dealDetail.add_leg = function(from_date, to_date) {
        var group_index = dealDetail.grid.getColIndexById('deal_group');
        var group_id_index = dealDetail.grid.getColIndexById('group_id');
        var leg_index = dealDetail.grid.getColIndexById('blotterleg');

        var legs = dealDetail.grid.collectValues(leg_index);
        var max_leg = Math.max.apply(null, legs);

        var group_ids = dealDetail.grid.collectValues(group_id_index);
        var unique_groups = _.uniq(group_ids);
        var group_count = unique_groups.length;

        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');
        var contract_expiration_date_index = dealDetail.grid.getColIndexById('contract_expiration_date');
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var row_id = dealDetail.grid.getSelectedRowId();

        var leg_index2 = dealDetail.grid.getColIndexById('Leg');

        var new_id = (new Date()).valueOf();
        var values_array = new Array();
        var deal_id = '<?php echo $deal_id; ?>';

        for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
            if (deal_id != 'NULL' && (source_deal_detail_index == cellIndex || cellIndex == group_id_index)) {
                values_array.push("NEW_" + new_id);
            } else if (cellIndex == term_start_index) {
                values_array.push(from_date);
            } else if (cellIndex == term_end_index) {
                values_array.push(to_date);
            } else if (cellIndex == contract_expiration_date_index) {
                values_array.push(to_date);
            } else if (leg_index == cellIndex) {
                values_array.push(max_leg+1);
            } else {
                if (row_id != null) {
                    var val = dealDetail.grid.cells(row_id, cellIndex).getValue();
                    var type = dealDetail.grid.getColType(cellIndex);

                    if (type == 'win_link_custom') {
                        val = val + '^' + dealDetail.grid.cells(row_id, cellIndex).getTitle();
                    }

                    if (leg_index2 != undefined && leg_index2 != '' && leg_index2 != null) {
                        if (cellIndex == leg_index2) {
                            val = max_leg+1;
                        }
                    }

                    values_array.push(val);
                } else {
                    values_array.push('');
                }
            }
        }
        var selected_row_id = dealDetail.grid.getSelectedRowId();
        added_from_sdd_id = dealDetail.grid.cells(selected_row_id, source_deal_detail_index).getValue();

        values_array[source_deal_detail_index] = "NEW_" + new_id;
        dealDetail.grid.addRow(new_id, values_array, 0 , null, null, true);
        dealDetail.grid.selectRowById(new_id);
        dealDetail.load_shipper_dropdown(new_id, 'leg_add');
        ids_to_apply_price = values_array[source_deal_detail_index];
        deal_price_data_process_id = (deal_price_data_process_id != '') ? deal_price_data_process_id : 'NULL';
        deal_provisional_price_data_process_id = (deal_provisional_price_data_process_id != '') ? deal_provisional_price_data_process_id : 'NULL';

        var data = {
            "action":"spa_deal_pricing_detail",
            "flag":"t",
            "mode":"fetch",
            "xml_process_id": deal_price_data_process_id,
            "source_deal_detail_id": added_from_sdd_id,
            "ids_to_apply_price": ids_to_apply_price
        }

        adiha_post_data("return_array", data, '', '', 'dealDetail.check_pricing_data');

        var data_prov = {
            "action":"spa_deal_pricing_detail_provisional",
            "flag":"t",
            "mode":"fetch",
            "xml_process_id": deal_provisional_price_data_process_id,
            "source_deal_detail_id": added_from_sdd_id,
            "ids_to_apply_price": ids_to_apply_price
        }

        adiha_post_data("return_array", data_prov, '', '', 'dealDetail.check_provisional_pricing_data');
    }

    dealDetail.check_pricing_data = function (result) {
        if (result[0][3] != 'Error') {
            var process_id = result[0][5];
            deal_price_data_process_id = process_id;
        }
    }

    dealDetail.check_provisional_pricing_data = function (result) {
        if (result[0][3] != 'Error') {
            var process_id = result[0][5];
            deal_provisional_price_data_process_id = process_id;
        }
    }

    dealDetail.loop = function() {
        var args = arguments;
        if (args.length <= 0)
            return;
        (function chain(i) {
            if (i >= args.length || typeof args[i] !== 'function')
                return;
            window.setTimeout(function() {
                args[i]();
                chain(i + 1);
            }, 1000);
        })(0);
    }

    function check_deal_detail_status() {
        var return_array = new Array();

        var is_environmental = false;

        dealDetail.deal_tab.forEachTab(function(cell) {

            if (cell.getText() == 'General') {
                is_environmental = cell.getAttachedObject().getItemValue('is_environmental') == 'y'
            }
        })

        if (!is_environmental) {
            return_array = [1,'',''];
            return return_array;
        }

        var ids = dealDetail.grid.getSelectedRowId();
        var forecast_volume = '';
        var actual_volume = '';
        var certified_volume = '';
        var status = '';

        if (ids != "") {
            var parent_id = dealDetail.grid.getParentId(ids);
            var no_of_child = dealDetail.grid.hasChildren(ids);

            if (parent_id != 0 || no_of_child < 1) {
                for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                    var column_id = dealDetail.grid.getColumnId(cellIndex);
                    var cell_value = dealDetail.grid.cells(ids, cellIndex).getValue();

                    if (column_id == 'contractual_volume') {
                        forecast_volume = cell_value;
                    } else if (column_id == 'schedule_volume') {
                        actual_volume = cell_value;
                    } else if (column_id == 'actual_volume') {
                        certified_volume = cell_value;
                    } else if (column_id == 'status') {
                        status = cell_value;
                    }
                }
            }
        }

        if (status == 25002) {
            var cancel_status = '';
            if (certified_volume != '') {
                cancel_status = 25004;
            } else if (actual_volume != '' && certified_volume == '') {
                cancel_status = 25003;
            } else {
                cancel_status = 25008;
            }

            return_array = [0,'Are you sure you want to set Deal Detail Status to "Expired"?', cancel_status];
        } else if (certified_volume != '' && status != 25004) {
            return_array = [0,'When Certified Volume is available, acceptable detail status is "Certified".  Are you sure you want to proceed?', '25004'];
        } else if (actual_volume != '' && certified_volume == '' && status != 25003) {
            return_array = [0,'When Actual Volume is available, acceptable detail status is "Actual"  Are you sure you want to proceed?', '25003'];
        } else if (forecast_volume != '' && actual_volume == '' && certified_volume == '' && status != 25008) {
            return_array = [0,'When Contractual/Forecast Volume is available, acceptable detail status is "Contractual/Forecast"  Are you sure you want to proceed?', '25008'];
        } else {
            return_array = [1,'',''];
        }

        return return_array;
    }

    /**
     * [page_toolbar_click Page Menu Click]
     * @param  {[type]} id [Menu id]
     */
    dealDetail.page_toolbar_click = function(id) {
        switch(id) {
            case "save":
                dealDetail.toolbar.disableItem('save');
                var row_id = dealDetail.grid.getSelectedRowId();
                dealDetail.deal_detail.progressOn();
                var pricing_save = true;

                if (detail_formula_popup && detail_formula_popup.isVisible()) detail_formula_popup.hide();

                if (row_id != '' && row_id != null) {
                    if ((enable_pricing == 'y' || enable_provisional_tab == 'y' || enable_escalation_tab == 'y' || hide_pricing == 0) && detail_cost_enable != 'n' && detail_cost_enable != '') {
                        dealDetail.loop(
                            function() { pricing_save = dealDetail.grid_before_row_selection(null, row_id); },
                            function() {
                                if (pricing_save) {
                                    if (detail_cost_enable == 'y') dealDetail.save_detail_cost('', row_id);
                                } else {
                                    dealDetail.deal_detail.progressOff();
                                    dealDetail.toolbar.enableItem('save');
                                }
                            },
                            function() { dealDetail.save_detail_udf(row_id, '');  },
                            function() {
                                if (pricing_save) dealDetail.save_deal();
                                else {
                                    dealDetail.deal_detail.progressOff();
                                    dealDetail.toolbar.enableItem('save');
                                }

                            }
                        );
                    } else if (enable_pricing == 'y' || enable_provisional_tab == 'y' || enable_escalation_tab == 'y' || hide_pricing == 0) {
                        dealDetail.loop(
                            function() { pricing_save = dealDetail.grid_before_row_selection(null, row_id); },
                            function() {
                                if (pricing_save) dealDetail.save_deal();
                                else {
                                    dealDetail.deal_detail.progressOff();
                                    dealDetail.toolbar.enableItem('save');
                                }
                            }
                        );
                    } else if (detail_cost_enable != 'n' && detail_cost_enable != '') {
                        dealDetail.loop(
                            function() {
                                if (detail_cost_enable == 'y') dealDetail.save_detail_cost('', row_id);
                            },
                            function() { dealDetail.save_detail_udf(row_id, ''); },
                            function() { dealDetail.save_deal(); }
                        );
                    } else {
                        dealDetail.loop(
                            function() { dealDetail.save_detail_udf(row_id, ''); },
                            function() { dealDetail.save_deal(); }
                        );
                    }
                } else {
                    dealDetail.save_deal();
                }
                break;
            case 'documents':
                dealDetail.open_document();
                break;
            case 'certificate':
                dealDetail.open_certificate();
                break;
			case 'transfer':
                dealDetail.open_deal_transfer();
                break;
            case 'product' :
                dealDetail.open_product();
                break;
            case 'udt':
                dealDetail.open_udt('h');
                break;
            default:
                break;
        }
    }

    dealDetail.save_deal = function() {
        if (enable_remarks == 'y') {
            dealDetail.deal_remarks.clearSelection();
        }

        dealDetail.grid.clearSelection();

        var deleted_deals = dealDetail.deleted_details.length;
        var no_of_rows = 0;
        var no_of_parent = 0;
        var deal_id = '<?php echo $deal_id; ?>';

        for (var i=0; i < dealDetail.grid.getRowsNum(); i++){
            if (no_of_parent == 2) break;
            if (no_of_rows == 2) break;

            var id = dealDetail.grid.getRowId(i);
            var pid = dealDetail.grid.getParentId(id);
            if (pid == 0) no_of_parent++;
            else no_of_rows++;
        };

        if (no_of_parent < 1 && no_of_rows < 1) {
            dealDetail.deal_detail.progressOff();
            dealDetail.toolbar.enableItem('save');

            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text: "Deal must have details for some terms."
            });
            return;
        }

        if (deleted_deals > 0) {
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
                text: "Some of the details are deleted from Details grid. Are you sure you want to save?",
                callback: function(result) {
                    if (result) {
                        dealDetail.save_confirm(dealDetail.deleted_details.join(','));
                    }
                }
            });
        } else {
            dealDetail.save_confirm('');
        }
    }




    /**
     * [save_confirm Confirmed save function]
     * @param  {[type]} deleted_detail_ids [Deleted deal details]
     */
    dealDetail.save_confirm = function(deleted_detail_ids) {
        var final_status = true;
        var first_err_tab;
        var tabsCount = dealDetail.deal_tab.getNumberOfTabs();
        var profile_granularity_old = '<?php echo $profile_granularity; ?>';
        var profile_granularity_new = '';
        var reset_profile_granularity = 'n';

        dealDetail.deal_detail.progressOn();

        if (dealDetail.form_details_tab) {
            var status = validate_form(dealDetail.form_details_tab);

            if (!status) {
                dealDetail.deal_detail.progressOff();
                dealDetail.toolbar.enableItem('save');
                return;
            }
        }

        var grid_status = dealDetail.validate_form_grid(dealDetail.grid, 'Deal Detail', 'deal');

        if (grid_status) {
            var deal_id = '<?php echo $deal_id; ?>';
            var template_id = '<?php echo $template_id; ?>';
            var tab_obj = dealDetail.deal_tab;
            var header_xml = '<Root><FormXML ';
            var grid_xml = "";
            var sub_book = '<?php echo $sub_book; ?>';
            var header_cost_enable = '<?php echo $header_cost_enable;?>';
            var header_cost_process_id = '<?php echo $header_cost_process_id; ?>'
            var deal_type_id = '<?php echo $deal_type_id;?>';
            var pricing_type_id = '<?php echo $pricing_type_id;?>';
            var term_frequency = '<?php echo $term_frequency;?>';

            var header_cost_xml = 'NULL';
            var header_udt_grid_xml = '<GridGroup>';

            if (template_id != 'NULL') {
                header_xml = '<GridXML><GridRow row_id="1" '
            }

            tab_obj.forEachTab(function(tab) {
                var id = tab.getId();

                if (id != header_cost_enable && id != 'document_tab' && id != 'tab_remarks' && id != -1) {
                    var form_obj = tab.getAttachedObject();

                    if (form_obj instanceof dhtmlXGridObject) {
                        // For UDT Grid
                        var grid_label = form_obj.getUserData("", "grid_label");
                        var udt_grid_status = dealDetail.validate_form_grid(form_obj, grid_label);
                        if (udt_grid_status) {
                            form_obj.clearSelection();

                            var grid_id = form_obj.getUserData("", "grid_id");
                            deleted_xml = form_obj.getUserData("", "deleted_xml");

                            var ids = form_obj.getChangedRows(true);
                            if (deleted_xml != null && deleted_xml != "") {
                                header_udt_grid_xml += "<GridDelete grid_id=\""+ grid_id + "\">";
                                header_udt_grid_xml += deleted_xml;
                                header_udt_grid_xml += "</GridDelete>";
                            };

                            if (ids != "") {
                                form_obj.setSerializationLevel(false,false,true,true,true,true);

                                header_udt_grid_xml += '<Grid grid_id="' + grid_id + '">';

                                var changed_ids = new Array();
                                changed_ids = ids.split(",");
                                $.each(changed_ids, function(index, value) {
                                    header_udt_grid_xml += "<GridRow ";
                                    for (var cellIndex = 0; cellIndex < form_obj.getColumnsNum(); cellIndex++) {
                                        header_udt_grid_xml += " " + form_obj.getColumnId(cellIndex) + '="' + form_obj.cells(value, cellIndex).getValue() + '"';
                                    }
                                    header_udt_grid_xml += " ></GridRow> ";
                                });

                                header_udt_grid_xml += '</Grid>';
                            }
                        } else {
                            final_status = false;
                        }
                        return;
                    }

                    var form_status = validate_form(form_obj);
                    if (tabsCount == 1 && !form_status) {
                        first_err_tab = "";
                    } else if ((!first_err_tab) && !form_status) {
                        first_err_tab = tab;
                    }
                    if (form_status) {
                        data = form_obj.getFormData();

                        for (var a in data) {
                            var field_label = a;

                            if (form_obj.getItemType(field_label) == 'calendar') {
                                var field_value = form_obj.getItemValue(field_label, true);
                            } else if (field_label == 'confirm_status_type' && copy_deal_id != 'NULL'){
                                var field_value = 17200;
                            }
                            else {
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

                            if (field_label != 'logical_term')
                                header_xml += " " + field_label + "=\"" + field_value + "\"";
                        }
                    } else {
                        final_status = false;
                    }

                } else if (id != 'document_tab' && id != 'tab_remarks' && id != -1) {
                    dealDetail.header_deal_costs.clearSelection();
                    var header_cost_change = dealDetail.header_deal_costs.getChangedRows(true);

                    //if (header_cost_change != '') {
                    header_cost_xml = '<GridXML>';

                    for (var hci=0; hci < dealDetail.header_deal_costs.getRowsNum(); hci++){
                        header_cost_xml += '<GridRow ';
                        header_cost_xml += ' seq_no="' + hci + '" ';

                        for(var cellIndex = 0; cellIndex < dealDetail.header_deal_costs.getColumnsNum(); cellIndex++){
                            var column_id = dealDetail.header_deal_costs.getColumnId(cellIndex);
                            var cell_value = dealDetail.header_deal_costs.cells2(hci, cellIndex).getValue();
                            header_cost_xml += ' ' + column_id + '="' + cell_value + '"';
                        }
                        header_cost_xml += '></GridRow>';

                    }
                    header_cost_xml += '</GridXML>';
                    //}
                } else if (id == -1) {
                    if (enable_prepay_tab == 'y' && insert_mode != true) {
                        dealDetail.header_deal_prepay.clearSelection();
                        var header_prepay_change = dealDetail.header_deal_prepay.getChangedRows(true);

                        header_prepay_xml = '<GridPrePayXML>';

                        for (var ppi=0; ppi < dealDetail.header_deal_prepay.getRowsNum(); ppi++) {
                            header_prepay_xml += '<GridRow ';

                            for(var cellIndex = 0; cellIndex < dealDetail.header_deal_prepay.getColumnsNum(); cellIndex++){
                                var column_id = dealDetail.header_deal_prepay.getColumnId(cellIndex);
                                var cell_value = dealDetail.header_deal_prepay.cells2(ppi, cellIndex).getValue();

                                if (column_id == 'prepay') {
                                    var b = prepay_properties.filter(function(e) {
                                        return e[0] == cell_value;
                                    });

                                    var field_type = b[0][1];
                                    var internal_type = b[0][2];
                                }

                                if (field_type == 'w') {
                                    if (column_id == 'formula_id') {
                                        if (cell_value == '') {
                                            show_messagebox('Please insert the data in <b>Formula</b> field in <b>Prepay</b> tab.');
                                            final_status = false;
                                        }
                                    }
                                } else if (field_type != 'w' && internal_type == 18724) {
                                    if (column_id == 'value') {
                                        if (cell_value == '') {
                                            show_messagebox('Please insert the data in <b>Value</b> field in <b>Prepay</b> tab.');
                                            final_status = false;
                                        }
                                    }
                                } else if (field_type != 'w' && internal_type == 18736) {
                                    if (column_id == 'percentage') {
                                        if (cell_value == '') {
                                            show_messagebox('Please insert the data in <b>Percentage</b> field in <b>Prepay</b> tab.');
                                            final_status = false;
                                        }
                                    }
                                }

                                header_prepay_xml += ' ' + column_id + '="' + cell_value + '"';
                            }
                            header_prepay_xml += '></GridRow>';
                        }

                        header_prepay_xml += '</GridPrePayXML>';

                        header_prepay_xml = (header_prepay_xml == '<GridPrePayXML></GridPrePayXML>') ? 'NULL' : header_prepay_xml;
                    }
                }
            });

            header_udt_grid_xml += '</GridGroup>';
            
            if (!final_status) {
                dealDetail.deal_detail.progressOff();
                dealDetail.toolbar.enableItem('save');
                generate_error_message(first_err_tab);
                return;
            }

            header_cost_xml = (header_cost_xml == '<GridXML></GridXML>') ? 'NULL' : header_cost_xml;

            if (template_id != 'NULL') {
                header_xml += '></GridRow></GridXML>'
            } else {
                header_xml += "></FormXML></Root>";
            }
            // var shared_docs_path = <?php //echo "'" . addslashes(addslashes($BATCH_FILE_EXPORT_PATH)) . "'"; ?> ;
            // shared_docs_path = shared_docs_path.replace('\\temp_Note', '');
            var vol_validate = '';
            var tab_obj = dealDetail.deal_tab;
            var volume_type_new = '';
            tab_obj.forEachTab(function(tab) {
                var form_object = tab.getAttachedObject();
                if (form_object instanceof dhtmlXForm)
                    var data = form_object.getFormData();

                for (var a in data) {
                    var field_label = a;

                    if (field_label == 'internal_desk_id') {
                        volume_type_new = data[field_label];
                    }
                }
            });

            profile_granularity_new = (volume_type_new != 17302) ? '' : profile_granularity_new;

            var del_msg = '';

            if (volume_type_new != volume_type && volume_type_new != '' && volume_type != '') {
                del_msg = 'Changing Volume Type will erase previously saved volumes. Do you wish to continue?';
                vol_validate = 1;
            } else if (profile_granularity_old != profile_granularity_new && profile_granularity_new != '' && profile_granularity_old != '') {
                del_msg = 'Changing granularity will erase all existing shapes of the deal. Do you wish to continue?';
                vol_validate = 1;
            } else {
                vol_validate = 0;
            }

            var prepay_confirm_check = 0;

            if (prepay_delete_check == 1) {
                header_prepay_xml = (header_prepay_xml == 'NULL') ? '<GridRow></GridRow>' : header_prepay_xml;

                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: "Some of the data are deleted from Prepay grid. Are you sure you want to save?",
                    callback: function(result) {
                        if (result) {
                            if (vol_validate == 1) {
                                dhtmlx.message({
                                    type: "confirm-warning",
                                    text: del_msg,
                                    title: "Warning",
                                    callback: function(result) {
                                        if (result) {
                                            post_confirm_granularity();
                                        } else {
                                            dealDetail.deal_detail.progressOff();
                                            dealDetail.toolbar.enableItem('save');
                                        }
                                    }
                                });
                            } else {
                                post_confirm_granularity();
                            }
                        } else {
                            dealDetail.deal_detail.progressOff();
                            dealDetail.toolbar.enableItem('save');
                        }
                    }
                });
            } else {
                if (vol_validate == 1) {
                    dhtmlx.message({
                        type: "confirm-warning",
                        text: del_msg,
                        title: "Warning",
                        callback: function(result) {
                            if (result) {
                                post_confirm_granularity();
                            } else {
                                dealDetail.deal_detail.progressOff();
                                dealDetail.toolbar.enableItem('save');
                            }
                        }
                    });
                } else {
                    post_confirm_granularity();
                }
            }
        } else {
            dealDetail.deal_detail.progressOff();
            setTimeout(dealDetail.toolbar.enableItem('save'), 4000);
        }

        function post_confirm_granularity() {
            if (final_status && deal_id != 'NULL') {
                var ids = dealDetail.grid.getChangedRows(true);
                var detail_xml = '<GridXML>';
                if (ids != "") {
                    var changed_ids = new Array();
                    changed_ids = ids.split(",");
                    $.each(changed_ids, function(index, value) {
                        var parent_id = dealDetail.grid.getParentId(value);
                        var no_of_child = dealDetail.grid.hasChildren(value);
                        detail_xml += '<GridRow ';

                        detail_xml += ' added_from_sdd_id="' +  dealDetail.grid.getUserData(value, 'added_from_sdd_id') + '"';


                        var group_index = dealDetail.grid.getColIndexById('deal_group');
                        var group_id_index = dealDetail.grid.getColIndexById('group_id');
                        var pId = (parent_id != 0) ? parent_id : value;
                        var group_name = dealDetail.grid.cells(pId, group_index).getValue();
                        // group_name = group_name.replace(/'/g, "''")
                        group_name = escapeXML(group_name);
                        var group_id = dealDetail.grid.cells(pId, group_id_index).getValue();
                        detail_xml += ' deal_group="' + group_name + '"';

                        if (group_id == '') {
                            group_id = dealDetail.grid.cells(value,group_id_index).getValue();
                        }

                        if (group_id == '') {
                            var first_child = dealDetail.grid.getChildItemIdByIndex(value, 0);
                            group_id = dealDetail.grid.cells(first_child,group_id_index).getValue();
                        }

                        detail_xml += ' group_id="' + group_id + '"';

                        if (parent_id != 0 || no_of_child < 1) {
                            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                                var column_id = dealDetail.grid.getColumnId(cellIndex);
                                var cell_value = dealDetail.grid.cells(value, cellIndex).getValue();

                                if (cellIndex != group_index && cellIndex != group_id_index) {
                                    detail_xml += ' ' + column_id + '="' + cell_value + '"';
                                }
                            }
                        } else { // Send parameter as blank because this fileds are used in joins.
                            detail_xml += ' blotterleg="" source_deal_detail_id="" term_start= "" term_end= ""';
                        }

                        detail_xml += '></GridRow>';
                    });
                }

                detail_xml += '</GridXML>';

                var pricing_process_id = '<?php echo $pricing_process_id; ?>';
                detail_xml = (detail_xml != '<GridXML></GridXML>') ? detail_xml : 'NULL';

                pricing_process_id = (pricing_process_id != '') ? pricing_process_id : 'NULL';

                var udf_process_id = '<?php echo $udf_process_id; ?>';

                if (save_all_detail_cost_udf == '1') {
                    var xml_grid = 'NULL';

                    if (dealDetail.deal_detail_cost) {
                        var xml_grid = '<GridXML>';

                        dealDetail.deal_detail_cost.forEachRow(function(ids) {
                            xml_grid = xml_grid + '<GridRow ';

                            dealDetail.deal_detail_cost.forEachCell(ids, function(cell_obj, ind) {
                                var grid_index = dealDetail.deal_detail_cost.getColumnId(ind);
                                var value = cell_obj.getValue(ind);

                                xml_grid = xml_grid + grid_index + '="' + value  + '" ';
                            });

                            xml_grid += '/>';
                        });
                    }
                    xml_grid += '</GridXML>';
                    xml_grid = (xml_grid == '<GridXML></GridXML>') ? 'NULL' : xml_grid;

                    var cm_param = {
                        "action": "spa_udf_groups",
                        "flag": "u",
                        "udf_process_id":udf_process_id,
                        "deal_id":deal_id,
                        "udf_xml":xml_grid,
                        "udf_type":'dc'
                    };
                    save_all_detail_cost_udf = '0';
                    adiha_post_data("return", cm_param, '', '', '');
                }

                if (deleted_detail_ids == '') {
                    data = {"action": "spa_deal_update_new", "flag":"s", "source_deal_header_id":deal_id, "header_xml":header_xml, "detail_xml":detail_xml, pricing_process_id:pricing_process_id, header_cost_xml:header_cost_xml, "deal_type_id":deal_type_id,"pricing_type":pricing_type_id, "term_frequency":term_frequency, "shaped_process_id":process_id, "formula_process_id":formula_process_id, "udf_process_id":udf_process_id,"environment_process_id":environment_process_id,"certificate_process_id":certificate_process_id, "deal_price_data_process_id": deal_price_data_process_id, "deal_provisional_price_data_process_id":deal_provisional_price_data_process_id, header_prepay_xml: header_prepay_xml, header_udt_grid: header_udt_grid_xml};
                } else {
                    data = {"action": "spa_deal_update_new", "flag":"s", "source_deal_header_id":deal_id, "header_xml":header_xml, "detail_xml":detail_xml, pricing_process_id:pricing_process_id, "deleted_details":deleted_detail_ids, header_cost_xml:header_cost_xml, "deal_type_id":deal_type_id,"pricing_type":pricing_type_id, "term_frequency":term_frequency, "shaped_process_id":process_id, "formula_process_id":formula_process_id, "udf_process_id":udf_process_id, "deal_price_data_process_id": deal_price_data_process_id,"deal_provisional_price_data_process_id":deal_provisional_price_data_process_id, header_prepay_xml: header_prepay_xml, header_udt_grid: header_udt_grid_xml};
                }

                adiha_post_data("alert", data, '', '', 'dealDetail.save_callback');
            } else if (final_status && template_id != 'NULL' && copy_deal_id == 'NULL') {
                var leg_index = dealDetail.grid.getColIndexById('blotterleg');
                var legs = dealDetail.grid.collectValues(leg_index);
                var max_leg = Math.max.apply(null, legs);
                var detail_xml = '<GridXML>';

                dealDetail.grid.forEachRow(function(id){
                    var no_of_child = dealDetail.grid.hasChildren(id);
                    var parent_id = dealDetail.grid.getParentId(id);
                    var group_index = dealDetail.grid.getColIndexById('deal_group');
                    var group_id_index = dealDetail.grid.getColIndexById('group_id');
                    var group_name = dealDetail.grid.cells(id, group_index).getValue();
                    group_name = group_name.replace(/'/g, "''")
                    var group_id = dealDetail.grid.cells(id, group_id_index).getValue();

                    if (no_of_child > 0) {
                        dealDetail.grid._h2.forEachChild(id,function(element){
                            detail_xml += '<GridRow row_id="1" ';
                            detail_xml += ' deal_group="' + group_name + '"';
                            group_id = (group_id == '') ? 1 : group_id;
                            detail_xml += ' group_id="' + group_id + '"';

                            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                                var column_id = dealDetail.grid.getColumnId(cellIndex);
                                var cell_value = dealDetail.grid.cells(element.id,cellIndex).getValue();

                                if (cellIndex != group_index && cellIndex != group_id_index) {
                                    detail_xml += ' ' + column_id + '="' + cell_value + '"';
                                }
                            }
                            detail_xml += '></GridRow>';
                        });
                    } else if (parent_id == 0) {
                        detail_xml += '<GridRow row_id="1" ';
                        for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                            var column_id = dealDetail.grid.getColumnId(cellIndex);
                            var cell_value = dealDetail.grid.cells(id,cellIndex).getValue();
                            detail_xml += ' ' + column_id + '="' + cell_value + '"';
                        }
                        detail_xml += '></GridRow>';
                    }
                })

                detail_xml += '</GridXML>';

                detail_xml = (detail_xml != '<GridXML></GridXML>') ? detail_xml : 'NULL';
                document.getElementById("txt_save_status").value = 'save';
                var commodity_id = '<?php echo $commodity_id;?>';

                data = {"action": "spa_insert_blotter_deal", "flag":"i", "call_from":"form", "template_id":template_id, "header_xml":header_xml, "detail_xml":detail_xml, "deal_type_id":deal_type_id,"pricing_type":pricing_type_id, "term_frequency":term_frequency, "shaped_process_id":process_id, header_cost_xml:header_cost_xml, "formula_process_id":formula_process_id, "commodity_id":commodity_id, "environment_process_id":environment_process_id,"certificate_process_id":certificate_process_id, "deal_price_data_process_id":deal_price_data_process_id, "deal_provisional_price_data_process_id":deal_provisional_price_data_process_id};

                adiha_post_data("alert", data, '', '', 'dealDetail.save_callback');
            } else if (final_status && copy_deal_id != 'NULL') {
                var pricing_process_id = '<?php echo $pricing_process_id; ?>';
                var detail_xml = '<GridXML>';
                var group_id_index = dealDetail.grid.getColIndexById('group_id');
                var group_index = dealDetail.grid.getColIndexById('deal_group');

                var group_count = 0;

                dealDetail.grid.forEachRow(function(id){
                    var no_of_child = dealDetail.grid.hasChildren(id);
                    var parent_id = dealDetail.grid.getParentId(id);
                    var group_name = dealDetail.grid.cells(id, group_index).getValue();

                    group_name = group_name.replace(/'/g, "''");

                    var group_id = dealDetail.grid.cells(id, group_id_index).getValue();

                    if (no_of_child > 0) {
                        dealDetail.grid._h2.forEachChild(id,function(element){
                            detail_xml += '<GridRow row_id="1" is_break="n" ';
                            detail_xml += ' deal_group="' + group_name + '"';
                            group_count++;
                            detail_xml += ' group_id="' + group_count + '"';

                            for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                                var column_id = dealDetail.grid.getColumnId(cellIndex);
                                var cell_value = dealDetail.grid.cells(element.id,cellIndex).getValue();
                                if (cellIndex != group_index && cellIndex != group_id_index) {
                                    detail_xml += ' ' + column_id + '="' + cell_value + '"';
                                }
                            }
                            detail_xml += '></GridRow>';
                        });
                    } else if (parent_id == 0) {
                        detail_xml += '<GridRow row_id="1" is_break="n" ';
                        for(var cellIndex = 0; cellIndex < dealDetail.grid.getColumnsNum(); cellIndex++){
                            var column_id = dealDetail.grid.getColumnId(cellIndex);
                            var cell_value = dealDetail.grid.cells(id,cellIndex).getValue();

                            if (column_id == 'deal_group') {
                                cell_value = cell_value.replace(/'/g, "''");
                            }

                            detail_xml += ' ' + column_id + '="' + cell_value + '"';
                        }
                        detail_xml += '></GridRow>';
                    }
                });

                detail_xml += '</GridXML>';

                detail_xml = (detail_xml != '<GridXML></GridXML>') ? detail_xml : 'NULL';

                document.getElementById("txt_save_status").value = 'save';

                data = {"action": "spa_deal_copy", "flag":"s", "copy_deal_id":copy_deal_id,"header_xml":header_xml, "detail_xml":detail_xml, header_cost_xml:header_cost_xml, header_cost_process_id:header_cost_process_id,pricing_process_id:pricing_process_id, "shaped_process_id":process_id,"environment_process_id":environment_process_id,"certificate_process_id":certificate_process_id, "deal_price_data_process_id":deal_price_data_process_id,"deal_provisional_price_data_process_id":deal_provisional_price_data_process_id};
                adiha_post_data("alert", data, '', '', 'dealDetail.save_callback');
            }
        }
    }

    /**
     * [open_document Open Document window]
     */
    dealDetail.open_document = function() {
        dealDetail.unload_document_window();
        var deal_id = '<?php echo $deal_id; ?>';

        if (!document_window) {
            document_window = new dhtmlXWindows();
        }

        var win_title = 'Document';
        var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?call_from=deal_window&notes_object_id=' + deal_id + '&is_pop=true';

        var win = document_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {notes_category:33});

        win.attachEvent('onClose', function(w) {
            update_document_counter(deal_id, dealDetail.toolbar);
            return true;
        });
    }

    /**
     * [save_callback Save callback]
     * @param  {[array]} result [callback array]
     */
    dealDetail.save_callback = function(result) {
        save_function_call = 'n';
        dealDetail.deleted_details.length = 0;
        if (result[0].errorcode == 'Success') {
            deal_price_data_process_id = '';
            var deal_id = '<?php echo $deal_id; ?>';
            var view_deleted = '<?php echo $view_deleted; ?>';
            var template_id = '<?php echo $template_id; ?>';
            var pricing_process_id = '<?php echo $pricing_process_id; ?>';
            var deal_type_id = '<?php echo $deal_type_id;?>';
            var pricing_type_id = '<?php echo $pricing_type_id;?>';
            var term_frequency = '<?php echo $term_frequency;?>';
            var profile_granularity = '<?php echo $profile_granularity;?>';
            var deal_type = '<?php echo $deal_type;?>';
            var recommendation_arr = new Array();
            prepay_delete_check = 0;

            certificate_process_id = '';
            environment_process_id = '';

            if (enable_header_udt == 'y') {
                dealDetail.deal_tab.forEachTab(function(cell) {
                    var attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject && cell.getUserData('is_udt_tab') == 'y') {
                        cell.getAttachedMenu().setItemDisabled('delete');
                        attached_obj.refresh_grid();
                    }
                });
            }
            
            if (enable_prepay_tab == 'y')
                dealDetail.prepay_menu_click('refresh');

            if (result[0].recommendation != '' && result[0].recommendation != null ) {
                recommendation_arr = result[0].recommendation.split(',')

            }

            volume_type = (volume_type == undefined) ? '' : volume_type;
            profile_granularity = (profile_granularity == undefined) ? '' : profile_granularity;

            if (recommendation_arr.length > 0 && insert_mode != 1 && ((volume_type != recommendation_arr[0] && volume_type != '') || (profile_granularity != recommendation_arr[1] && profile_granularity != ''))) {
                deal_price_data_process_id = '';
                var old_location = location.href;
                old_location = old_location.split('?')[0];
                location.href = old_location + '?deal_type=' + deal_type + "&deal_id=" + deal_id + '&view_deleted=' + view_deleted;
            } else {
                deal_price_data_process_id = '';
                dealDetail.deal_detail.progressOff();
                dealDetail.toolbar.enableItem('save');
            }

            document.getElementById("txt_save_status").value = 'save';
            if (template_id != 'NULL' || copy_deal_id != 'NULL') {
                var win_obj = window.parent.deal_insert_window.window("w1");
                var deal_id = result[0].recommendation;
                var param = {deal_id:deal_id,view_deleted:'n',copy_insert_mode:'y'};
                win_obj.setText("Deal - " + deal_id);
                win_obj.attachURL('deal.detail.new.php', false, param);
            } else {
                var data = {
                    "action":"spa_deal_update_new",
                    "flag":"e",
                    "source_deal_header_id":deal_id,
                    "view_deleted":view_deleted,
                    "grid_type":"tg",
                    "grouping_column":"deal_group",
                    "grouping_type":3,
                    "copy_deal_id":copy_deal_id,
                    "pricing_process_id":pricing_process_id,
                    "deal_type_id":deal_type_id,
                    "pricing_type":pricing_type_id,
                    "term_frequency":term_frequency,
                    "process_id":process_id
                }

                if (dealDetail.form_details_tab) {
                    var field_array = ['detail_commodity_id', 'origin', 'form', 'attribute1', 'attribute2', 'attribute3', 'attribute4', 'attribute5'];
                    $.each(field_array, function(index, value){
                        var field_type = dealDetail.form_details_tab.getItemType(value);
                        if (field_type != null) {
                            dealDetail.form_details_tab.setUserData(value,'change_event', 'n');
                        }
                    });
                }

                dealDetail.refresh_grid(data, function () {
                    var col_index_location_id = dealDetail.grid.getColIndexById('location_id');
                    var detail_commodity_id_index = dealDetail.grid.getColIndexById('detail_commodity_id');
                    if (col_index_location_id && detail_commodity_id_index) {
                        dealDetail.grid.forEachRow(function(id){
                            var location_id = dealDetail.grid.cells(id,col_index_location_id).getValue();

                            if (location_id != '')
                                dealDetail.grid.callEvent("onEditCell", [2, id,col_index_location_id,location_id]);
                        });                        
                    } else {
                        dealDetail.grid.forEachRow(function(id) {
                            dealDetail.load_shipper_dropdown(id, 'refresh_after_save');
                        });
                    }                 
                });
                dealDetail.grid.setUserData("", 'formula_id', 10211093);
                dealDetail.grid_row_selection(null);
                if (enable_escalation_tab == 'y') {
                    dealDetail.refresh_escalation_grid();
                }
            }

            if (deal_id != 'NULL' ) {
                data = {"action": "spa_deal_update_new", "flag":"check_environmental", "source_deal_header_id":deal_id};
                adiha_post_data("return", data, '', '', 'dealDetail.check_environmental');
            }

            if (copy_deal_id != 'NULL' ) {
                data = {"action": "spa_deal_update_new", "flag":"check_environmental", "source_deal_header_id":copy_deal_id};
                adiha_post_data("return", data, '', '', 'dealDetail.check_environmental');
            }

            if (hide_pricing == 0) {
                dealDetail.form_details_tab.forEachItem(function(name){
                    if(name.indexOf('dhxId_') == -1) {
                        dealDetail.form_details_tab.setItemValue(name, '');
                    }
                });
            }
        } else {
            deal_price_data_process_id = '';
            if (enable_prepay_tab == 'y'){
                dealDetail.prepay_menu_click('refresh');
            }
            dealDetail.deal_detail.progressOff();
            dealDetail.toolbar.enableItem('save');
        }
    }

    /**
     * [form_change description]
     * @param  {[type]} name  [description]
     * @param  {[type]} value [description]
     * @return {[type]}       [description]
     */

    dealDetail.check_environmental = function (result){
        if(result == '') {
            dealDetail.toolbar.disableItem('product');
            dealDetail.toolbar.disableItem('certificate');
        }
        else {
            dealDetail.toolbar.enableItem('product');
            dealDetail.toolbar.enableItem('certificate');

            if (copy_deal_id != 'NULL' ) {
                data = {"action": "spa_deal_update_new", "flag":"check_buy_sell", "source_deal_header_id":copy_deal_id};
                adiha_post_data("return", data, '', '', 'dealDetail.check_buy_sell');
            }
        }
    }

    dealDetail.check_buy_sell = function(result){
        if (result=='BUY') {
            dealDetail.toolbar.enableItem('product');
            dealDetail.toolbar.enableItem('certificate');
        }
        if(result == '') {
            dealDetail.toolbar.enableItem('product');
            dealDetail.toolbar.disableItem('certificate');
        }
    }

    dealDetail.form_change = function(name, value) {
        if (name == 'broker_id') {
            dealDetail.load_dependent_dropdown();
        } else if (name == 'state_value_id' || name == 'reporting_jurisdiction_id') {
            dealDetail.load_dependent_dropdown(name);
        } else if (name == 'counterparty_id' || name == 'commodity_id' || name == 'source_deal_type_id' || name == 'trader_id') {
            dealDetail.load_dependent_dropdown(1);
        } else if (name == 'counterparty_id2') {
            dealDetail.load_dependent_dropdown(2);
        } else if (name == 'deal_date' || name == 'logical_term') {
            var deal_id = '<?php echo $deal_id; ?>';
            var template_id = '<?php echo $template_id; ?>';
            var term_frequency = '<?php echo $term_frequency;?>';

            if (deal_id == 'NULL' && template_id != 'NULL') {
                var deal_date = '';
                var term_rule = '';
                dealDetail.deal_tab.forEachTab(function(cell) {
                    var header_form_obj = cell.getAttachedObject();
                    if (header_form_obj instanceof dhtmlXForm) {
                        if (header_form_obj.isItem('deal_date')) {
                            deal_date = header_form_obj.getItemValue('deal_date', true);
                            term_rule = header_form_obj.getItemValue('logical_term');
                        }
                    }
                });

                data = {"action": "spa_blotter_deal", "flag":"t", "template_id":template_id, "deal_date":deal_date, "term_frequency":term_frequency, "term_rule": term_rule};
                adiha_post_data("return", data, '', '', 'dealDetail.change_term');
            }
        } else if (name == 'underlying_options') {
            dealDetail.enable_location(value);
        } else if (name == 'internal_desk_id' || name == 'profile_granularity') {
            var deal_volume_index = dealDetail.grid.getColIndexById('deal_volume');
            var actual_volume_index = dealDetail.grid.getColIndexById('actual_volume');
            var schedule_volume_index = dealDetail.grid.getColIndexById('schedule_volume');
            var total_volume_index = dealDetail.grid.getColIndexById('total_volume');

            dealDetail.grid.forEachRow (function(id){
                if (deal_volume_index != undefined) {
                    dealDetail.grid.cells(id,deal_volume_index).setValue(null);
                    dealDetail.grid.cells(id, deal_volume_index).cell.wasChanged = true;
                }

                if (actual_volume_index != undefined) {
                    dealDetail.grid.cells(id,actual_volume_index).setValue(null);
                    dealDetail.grid.cells(id, actual_volume_index).cell.wasChanged = true;
                }
                if (schedule_volume_index != undefined) {
                    dealDetail.grid.cells(id,schedule_volume_index).setValue(null);
                    dealDetail.grid.cells(id, schedule_volume_index).cell.wasChanged = true;
                }
                if (total_volume_index != undefined) {
                    dealDetail.grid.cells(id,total_volume_index).setValue(null);
                    dealDetail.grid.cells(id, total_volume_index).cell.wasChanged = true;
                }
            });

            if (name == 'internal_desk_id') {
                if (value == 17302) {
                    is_shaped = 'y';
                    dealDetail.enable_volume_frequency('y');
                } else if (value == 17301) {
                    is_shaped = 'f';
                    dealDetail.enable_volume_frequency('n');
                } else {
                    is_shaped = 'n';
                    dealDetail.enable_volume_frequency('n');
                }
            }
        } else if (name == 'profile_granularity') {
            dealDetail.shape_change(value);
        } else if (name == 'contract_id') {
            dealDetail.grid.forEachRow(function(id) {
                dealDetail.load_shipper_dropdown(id, 'contract');
            });
        } else if (name == 'sub_book') {
            if (value != '') {
                data = {"action": "spa_source_deal_header", "flag":"p", "sub_book":value};
                adiha_post_data("return", data, '', '', 'dealDetail.change_internal_counterparty');
            }
        } else if (name == 'header_buy_sell_flag' && (value && value != '')) {
            var buy_sell_flag_index = dealDetail.grid.getColIndexById('buy_sell_flag');
            if (buy_sell_flag_index != undefined) {
                var row_ids_string = dealDetail.grid.getAllRowIds();
                if (row_ids_string && row_ids_string != '') {
                    var row_ids_array = row_ids_string.split(',');
                    for (var i = 0; i < row_ids_array.length; i++) {
                        var value_new = value;
                        var no_of_child = dealDetail.grid.hasChildren(row_ids_array[i]);
                        if (no_of_child == 0) {
                            var detail_row_count = dealDetail.grid.getRowsNum();
                            if (row_ids_array.length > 1) { // In case of multiple leg switch value
                                var current_value = dealDetail.grid.cells(row_ids_array[i], buy_sell_flag_index).getValue();
                                value_new = (current_value == 'b')?'s':'b';
                            }
                            dealDetail.grid.cells(row_ids_array[i], buy_sell_flag_index).setValue(value_new);
                            dealDetail.grid.cells(row_ids_array[i], buy_sell_flag_index).cell.wasChanged = true;
                        } else if (no_of_child > 0) {
                            dealDetail.grid._h2.forEachChild(row_ids_array[i],function(element) {
                                row_ids_array = row_ids_array.filter(function(e) { return e !== element.id}); // Remove child ids from array when row is expanded (Child row are included when row is expanded).
                                if (no_of_child > 1) {
                                    var current_value = dealDetail.grid.cells(element.id, buy_sell_flag_index).getValue();
                                    value_new = (current_value == 'b')?'s':'b';
                                }
                                dealDetail.grid.cells(element.id, buy_sell_flag_index).setValue(value_new);
                                dealDetail.grid.cells(element.id, buy_sell_flag_index).cell.wasChanged = true;
                            });
                        }
                    }
                }
            }
        }
    }

    /**
     * [change_internal_counterparty Set internal counterparty]
     */
    dealDetail.change_internal_counterparty = function(result) {
        var tab_obj = dealDetail.deal_tab;
        var iterate_check = true;

        tab_obj.forEachTab(function(tab) {
            if(iterate_check) {
                var form_obj = tab.getAttachedObject();

                if (form_obj instanceof dhtmlXForm) {
                    var internal_cpty_combo = form_obj.getCombo('internal_counterparty');
                    if (internal_cpty_combo && result[0].counterparty_id != -1 && result[0].counterparty_id != '') {
                        form_obj.setItemValue('internal_counterparty', result[0].counterparty_id);
                        iterate_check = false;
                    }
                }
            }
        });
    }

    /**
     * [enable_volume_frequency Enable disable volume frequency]
     * @param  {[type]} value [volume type]
     */
    dealDetail.enable_volume_frequency = function(value) {
        var tab_obj = dealDetail.deal_tab;
        var iterate_check = true;

        tab_obj.forEachTab(function(tab) {
            if(iterate_check) {
                var form_obj = tab.getAttachedObject();

                if (form_obj instanceof dhtmlXForm) {
                    var prof_gran_combo = form_obj.getCombo('profile_granularity');
                    if (prof_gran_combo) {
                        if (value == 'y') {
                            form_obj.enableItem('profile_granularity');
                            form_obj.showItem('profile_granularity');
                            prof_gran_combo.setSize(180);
                            form_obj.setRequired('profile_granularity',true);
                            var initial_shaped_gran = form_obj.getItemValue('profile_granularity');
                            if (initial_shaped_gran != '' && initial_shaped_gran != null) {
                                dealDetail.shape_change(initial_shaped_gran);
                            }
                        } else {
                            form_obj.setItemValue('profile_granularity', '');
                            form_obj.setRequired('profile_granularity',false);
                            form_obj.disableItem('profile_granularity');
                            form_obj.hideItem('profile_granularity');
                        }
                        iterate_check = false;
                    }
                }
            }
        });
    }

    /**
     * [shape_change Volumefrequency change for shaped deal]
     * @param  {[type]} value [Vol freqn value]
     */
    dealDetail.shape_change = function(value) {
        if (value != shaped_granularity) {
            shaped_granularity = value;
            var vol_freq_index = dealDetail.grid.getColIndexById('deal_volume_frequency');
            if (typeof vol_freq_index != 'undefined') {
                var vol_freq = (value == 987) ? 'x' : (value == 989) ? 'y' : (value == 993) ? 'a' : (value == 981) ? 'd' : (value == 982) ? 'h' : (value == 980) ? 'm' : 't';
                dealDetail.grid.forEachRow(function(detail_row_id){
                    var no_of_child = dealDetail.grid.hasChildren(detail_row_id);
                    if (no_of_child == 0) {
                        dealDetail.grid.cells(detail_row_id, vol_freq_index).setValue(vol_freq);
                    }
                    if (no_of_child > 0) {
                        dealDetail.grid._h2.forEachChild(detail_row_id,function(element){
                            dealDetail.grid.cells(element.id, vol_freq_index).setValue(vol_freq);
                        });
                    }
                });
            }
        }
    }

    /**
     * [enable_location Enable location on changing underlying options]
     * @param  {[type]} value [description]
     * @return {[type]}       [description]
     */
    dealDetail.enable_location = function(value) {
        if (value === undefined) {
            var header_cost_enable = '<?php echo $header_cost_enable;?>';
            var tab_obj = dealDetail.deal_tab;
            tab_obj.forEachTab(function(tab) {
                var id = tab.getId();
                if (id != header_cost_enable && id != 'document_tab' && id != 'tab_remarks') {
                    var form_obj = tab.getAttachedObject();

                    var underlying_options_combo = form_obj.getCombo('underlying_options');
                    if (underlying_options_combo) {
                        value = form_obj.getItemValue('underlying_options');
                    }
                }
            });
        }

        if (value === undefined) return;

        var location_index = dealDetail.grid.getColIndexById('location_id');
        if (typeof location_index != 'undefined') {
            var location_combo = dealDetail.grid.getColumnCombo(location_index);
            if (value == 46901) {
                enable_location = true;
            } else {
                enable_location = false;
            }
        }
    }

    /**
     * [change_term Change Term on deal date change]
     * @param  {[type]} return_val [description]
     * @return {[type]}            [description]
     */
    dealDetail.change_term = function(return_val) {
        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');

        dealDetail.grid.forEachRow(function(detail_row_id){
            var no_of_child = dealDetail.grid.hasChildren(detail_row_id);
            if (no_of_child == 0) {
                dealDetail.grid.cells(detail_row_id, term_start_index).setValue(return_val[0].term_start);
                dealDetail.grid.cells(detail_row_id, term_end_index).setValue(return_val[0].term_end);
            }
            if (no_of_child > 0) {
                dealDetail.grid._h2.forEachChild(detail_row_id,function(element){
                    dealDetail.grid.cells(element.id, term_start_index).setValue(return_val[0].term_start);
                    dealDetail.grid.cells(element.id, term_end_index).setValue(return_val[0].term_end);
                });
            }
            
            dealDetail.load_shipper_dropdown(detail_row_id, 'term_change');
        });
    }

    /**
     * [load_dependent_dropdown Load dependent columns as defined in deal fields mapping]
     * @param  {[type]} counterparty_id [Counterparty Id]
     */
    dealDetail.load_dependent_dropdown = function(type_id) {
        var deal_id = '<?php echo $deal_id; ?>';
        var template_id = '<?php echo $template_id; ?>';
        var copy_deal_id = '<?php echo $copy_deal_id; ?>';
        var header_cost_enable = '<?php echo $header_cost_enable;?>';
        var deal_type_id = '<?php echo $deal_type_id;?>';
        var commodity_id = 'NULL';
        var counterparty_id = 'NULL';
        var trader_id = 'NULL';
        var global_contract_combo = false;
        var global_counterparty_trader_combo = false;
        var global_counterparty2_trader_combo = false;
        var global_tier_value_combo = false;
        var global_reporting_tier_combo = false;
        var global_broker_contract_combo = false;
        var broker_id = 'NULL';
        var contract_id = 'NULL';
        var counterparty_trader_id = 'NULL';
        var counterparty2_trader_id = 'NULL';
        var state_value_id = 'NULL';
        var reporting_jurisdiction_id = 'NULL';
        

        if (deal_id == 'NULL' && copy_deal_id != 'NULL') {
            deal_id = copy_deal_id;
        }

        var cpty_obj = (type_id == 2) ? 'counterparty_id2' : 'counterparty_id';

        var tab_obj = dealDetail.deal_tab;
        tab_obj.forEachTab(function(tab) {
            var id = tab.getId();
            var form_obj = tab.getAttachedObject();

            if (form_obj instanceof dhtmlXForm) {
                var commodity_combo = form_obj.getCombo('commodity_id');
                if (commodity_combo) {
                    commodity_id = form_obj.getItemValue('commodity_id');
                }

                var trader_combo = form_obj.getCombo('trader_id');
                if (trader_combo) {
                    trader_id = form_obj.getItemValue('trader_id');
                }

                var counterparty_combo = form_obj.getCombo(cpty_obj);
                if (counterparty_combo) {
                    counterparty_id = form_obj.getItemValue(cpty_obj);
                }

                var contract_combo = form_obj.getCombo('contract_id');
                if (contract_combo) {
                    global_contract_combo = contract_combo;
                    contract_id = form_obj.getItemValue('contract_id');
                }

                var counterparty_trader_combo = form_obj.getCombo('counterparty_trader');
                if (counterparty_trader_combo) {
                    global_counterparty_trader_combo = counterparty_trader_combo;
                    counterparty_trader_id = form_obj.getItemValue('counterparty_trader');
                }

                var counterparty2_trader_combo = form_obj.getCombo('counterparty2_trader');
                if (counterparty2_trader_combo) {
                    global_counterparty2_trader_combo = counterparty2_trader_combo;
                    counterparty2_trader_id = form_obj.getItemValue('counterparty2_trader');
                }

                var sub_book_combo = form_obj.getCombo('sub_book');
                if (sub_book_combo) {
                    global_sub_book_combo = sub_book_combo;
                    sub_book_id = form_obj.getItemValue('sub_book');
                }

                if (type_id == 'state_value_id') {
                    var tier_value_combo = form_obj.getCombo('tier_value_id');
                    if (tier_value_combo) {
                        global_tier_value_combo = tier_value_combo;
                        state_value_id = form_obj.getItemValue('state_value_id');
                    }
                }
                if (type_id == 'reporting_jurisdiction_id') {
                    var reporting_tier_combo = form_obj.getCombo('reporting_tier_id');
                    if (reporting_tier_combo) {
                        global_reporting_tier_combo = reporting_tier_combo;
                        reporting_jurisdiction_id = form_obj.getItemValue('reporting_jurisdiction_id');
                    }
                }

                var broker_combo = form_obj.getCombo('broker_id');
                if(broker_combo) {
                    broker_value = form_obj.getItemValue('broker_id');
                }

                var broker_contract_combo = form_obj.getCombo('UDF___1342');
                if(broker_contract_combo) {
                    global_broker_contract_combo = broker_contract_combo;
                }
            }
        });

        counterparty_id = (counterparty_id == '' || counterparty_id == 'NULL') ? -1 : counterparty_id;
        state_value_id = (state_value_id == '' || state_value_id == 'NULL') ? -1 : state_value_id;
        reporting_jurisdiction_id = (reporting_jurisdiction_id == '' || reporting_jurisdiction_id == 'NULL') ? -1 : reporting_jurisdiction_id;

        if (global_contract_combo) {
            if (global_contract_combo.getSelectedValue() != null) {
                global_contract_combo.setComboValue(null);
                global_contract_combo.setComboText(null);
            }
            global_contract_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "contract_id", "default_value":contract_id, "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            global_contract_combo.clearAll();
            global_contract_combo.load(url);
        }

        if (global_broker_contract_combo) {    
            global_broker_contract_combo.setComboValue('');
            global_broker_contract_combo.setComboText('');
            global_broker_contract_combo.clearAll();
            global_broker_contract_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_counterparty_contract_address"
                , "flag": "n"
                , "broker_id": broker_value
            };
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            global_broker_contract_combo.clearAll();
            global_broker_contract_combo.load(url);
        }

        if (global_sub_book_combo) {
            global_sub_book_combo.setComboValue('');
            global_sub_book_combo.setComboText('');
            global_sub_book_combo.clearAll();
            global_sub_book_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "sub_book", "default_value":sub_book_id, "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            global_sub_book_combo.clearAll();
            global_sub_book_combo.load(url);
        }

        if (global_counterparty_trader_combo) {
            global_counterparty_trader_combo.setComboValue('');
            global_counterparty_trader_combo.setComboText('');
            global_counterparty_trader_combo.clearAll();
            global_counterparty_trader_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "counterparty_trader", "default_value":counterparty_trader_id, "template_id": template_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            global_counterparty_trader_combo.clearAll();
            global_counterparty_trader_combo.load(url);
        }

        if (global_counterparty2_trader_combo) {
            global_counterparty2_trader_combo.setComboValue('');
            global_counterparty2_trader_combo.setComboText('');
            global_counterparty2_trader_combo.clearAll();
            global_counterparty2_trader_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "counterparty2_trader", "default_value":counterparty2_trader_id, "template_id": template_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            global_counterparty2_trader_combo.clearAll();
            global_counterparty2_trader_combo.load(url);
        }

        if (global_tier_value_combo) {
            global_tier_value_combo.setComboValue('');
            global_tier_value_combo.setComboText('');
            global_tier_value_combo.clearAll();
            global_tier_value_combo.enableFilteringMode('between');

            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "tier_value_id", "default_value":contract_id, "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id, "state_value_id": state_value_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            global_tier_value_combo.clearAll();
            global_tier_value_combo.load(url);
        }

        if(global_reporting_tier_combo) {
            global_reporting_tier_combo.setComboValue('');
            global_reporting_tier_combo.setComboText('');
            global_reporting_tier_combo.clearAll();
            global_reporting_tier_combo.enableFilteringMode('between');

            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "reporting_tier_id", "default_value":contract_id, "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id, "reporting_jurisdiction_id": reporting_jurisdiction_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            global_reporting_tier_combo.clearAll();
            global_reporting_tier_combo.load(url);
        }

        var curve_index = dealDetail.grid.getColIndexById('curve_id');
        if (typeof curve_index != 'undefined') {
            var curve_combo = dealDetail.grid.getColumnCombo(curve_index);
            curve_combo.setComboValue('');
            curve_combo.setComboText('');
            curve_combo.clearAll();
            curve_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "curve_id", "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            curve_combo.clearAll();
            curve_combo.load(url);
        }

        if (typeof curve_index != 'undefined') {
            if (dealDetail.form_details_tab) {
                var combo = dealDetail.form_details_tab.getCombo('curve_id');

                if (combo != null && combo != 'null') {
                    var combo_value = combo.getSelectedValue();
                    combo.clearAll();

                    var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "curve_id", "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    combo.load(url, function() {
                        setTimeout(function() {
                            combo.enableFilteringMode('between');
                        }, 100)
                    });
                }
            }
        }

        var formula_curve_index = dealDetail.grid.getColIndexById('formula_curve_id');
        if (typeof formula_curve_index != 'undefined') {
            var formula_curve_combo = dealDetail.grid.getColumnCombo(formula_curve_index);
            formula_curve_combo.setComboValue('');
            formula_curve_combo.setComboText('');
            formula_curve_combo.clearAll();
            formula_curve_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "formula_curve_id", "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            formula_curve_combo.clearAll();
            formula_curve_combo.load(url);
        }

        var location_index = dealDetail.grid.getColIndexById('location_id');
        if (typeof location_index != 'undefined') {
            var location_combo = dealDetail.grid.getColumnCombo(location_index);
            location_combo.setComboValue('');
            location_combo.setComboText('');
            location_combo.clearAll();
            location_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "location_id", "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            location_combo.clearAll();
            location_combo.load(url);

            dealDetail.grid.forEachRow(function(id) {
                dealDetail.load_shipper_dropdown(id, 'dependent_location');
            });
        }

        var detail_commodity_index = dealDetail.grid.getColIndexById('detail_commodity_id');
        if (typeof detail_commodity_index != 'undefined') {
            var detail_commodity_combo = dealDetail.grid.getColumnCombo(detail_commodity_index);
            detail_commodity_combo.setComboValue('');
            detail_commodity_combo.setComboText('');
            detail_commodity_combo.clearAll();
            detail_commodity_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "detail_commodity_id", "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            detail_commodity_combo.clearAll();
            detail_commodity_combo.load(url);
        }

        var deal_volume_uom_index = dealDetail.grid.getColIndexById('deal_volume_uom_id');
        if (typeof deal_volume_uom_index != 'undefined') {
            var deal_volume_uom_combo = dealDetail.grid.getColumnCombo(deal_volume_uom_index);
            deal_volume_uom_combo.setComboValue('');
            deal_volume_uom_combo.setComboText('');
            deal_volume_uom_combo.clearAll();
            deal_volume_uom_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "deal_volume_uom_id", "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            deal_volume_uom_combo.clearAll();
            deal_volume_uom_combo.load(url);
        }

        var detail_status_index = dealDetail.grid.getColIndexById('status');
        if (typeof detail_status_index != 'undefined') {
            var detail_status_combo = dealDetail.grid.getColumnCombo(detail_status_index);
            detail_status_combo.setComboValue('');
            detail_status_combo.setComboText('');
            detail_status_combo.clearAll();
            detail_status_combo.enableFilteringMode('between');
            var cm_param = {"action": "spa_deal_fields_mapping", "call_from": "grid", "flag": "s", "deal_id": deal_id, "counterparty_id": counterparty_id, "deal_fields": "status", "template_id": template_id, "deal_type_id":deal_type_id, "commodity_id":commodity_id, "trader_id":trader_id};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            detail_status_combo.clearAll();
            detail_status_combo.load(url);
        }
    }

    var volume_window;
    dealDetail.open_update_volume = function() {
        var deal_id = '<?php echo $deal_id;?>';

        if (volume_type == 17301) {
            dealDetail.open_update_profile();
            return;
        }

        dealDetail.unload_deals_window();
        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }
        var detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var row_id = dealDetail.grid.getSelectedRowId();
        var detail_id = dealDetail.grid.cells(row_id, detail_index).getValue();

        if (deal_id == 'NULL' || detail_id == '' || detail_id.indexOf('NEW') != -1 || detail_id.indexOf('New') != -1) {
            if (is_shaped == 'y') dealDetail.open_update_volume_post('');
        } else {
            data = {"action": "spa_shaped_deal", "flag":"c", "source_deal_detail_id":detail_id};
            adiha_post_data("return_array", data, '', '', 'dealDetail.open_update_volume_post');
        }
    }

    dealDetail.unload_deals_window = function() {
        if (volume_window != null && volume_window.unload != null) {
            volume_window.unload();
            volume_window = w1 = null;
        }
    }

    dealDetail.open_update_volume_post = function(return_value) {
        if (return_value == '') {
            return_value = [['Success']];

        }
        if (return_value[0][0] == 'Success') {
            var win_title = 'Update Volume';
            var deal_id = '<?php echo $deal_id;?>';
            var detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
            var term_start_index = dealDetail.grid.getColIndexById('term_start');
            var term_end_index = dealDetail.grid.getColIndexById('term_end');
            var detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
            var row_id = dealDetail.grid.getSelectedRowId();
            var detail_id = dealDetail.grid.cells(row_id, detail_index).getValue();
            var term_start = dealDetail.grid.cells(row_id, term_start_index).getValue();
            var term_end = dealDetail.grid.cells(row_id, term_end_index).getValue();
            var leg_index = dealDetail.grid.getColIndexById('blotterleg');
            var volume_index = dealDetail.grid.getColIndexById('deal_volume');
            var price_index = dealDetail.grid.getColIndexById('fixed_price');
            var template_id = '<?php echo $template_id; ?>';
            var tab_obj = dealDetail.deal_tab;
            var term_frequency = '<?php echo $term_frequency;?>';

            tab_obj.forEachTab(function(tab) {
                var form_object = tab.getAttachedObject();
                if (form_object instanceof dhtmlXForm)
                    var data = form_object.getFormData();

                for (var a in data) {
                    var field_label = a;

                    if (field_label == 'profile_granularity') {
                        profile_granularity = data[field_label];
                    }

                    if (field_label == 'internal_desk_id') {
                        vol_type = data[field_label];
                    }
                }
            });

            if (vol_type != 17302) {
                profile_granularity = null
            }

            var copy_deal_id = '<?php echo $copy_deal_id;?>';
            var leg = 'NULL';
            var volume = 'NULL';
            var price = 'NULL';

            if (term_start == '' || term_end == '') {
                show_messagebox('Terms cannot be blank.');
                dealDetail.deal_detail.cells('c').progressOff();
                return;
            }

            if (copy_deal_id != 'NULL' || template_id != 'NULL') {
                //detail_id = '';
                deal_id = '';

            }

            var selected_ids = dealDetail.grid.getColumnValues(1);
            var win = volume_window.createWindow('w1', 0, 0, 400, 400);
            var profile_type = (is_shaped == 'y') ? 17302 : return_value[0][5];
            
            var detail_commodity_id_index = dealDetail.grid.getColIndexById('detail_commodity_id');
            var detail_commodity_id = (detail_commodity_id_index) ? dealDetail.grid.cells(row_id, detail_commodity_id_index).getValue(): '';

            if (is_shaped == 'y' || (volume_type == 17300 && term_frequency != 'd')) {
                var win_url = 'shaped.deals.php?header_detail=d&detail_commodity_id='+detail_commodity_id;
            } else {
                var win_url = 'update.demand.volume.php?header_detail=d';
            }

            var is_new = 'n';

            if (copy_deal_id != 'NULL' || template_id != 'NULL' || detail_id.indexOf('New') == 0 || detail_id.indexOf('NEW') == 0) {
                is_new = 'y';
                leg = dealDetail.grid.cells(row_id, leg_index).getValue();
                if (typeof volume_index != 'undefined')
                    volume = dealDetail.grid.cells(row_id, volume_index).getValue();
                if (typeof price_index != 'undefined')
                    price = dealDetail.grid.cells(row_id, price_index).getValue();
            }

            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.maximize();
            win.attachURL(win_url, false, {deal_ref_ids:deal_id,detail_ids:detail_id, profile_type:profile_type,term_start:term_start,term_end:term_end,template_id:template_id,process_id:process_id,leg:leg,volume:volume,price:price,copy_deal_id:copy_deal_id,is_new:is_new,granularity:profile_granularity});

            win.attachEvent('onClose', function(w) {
                if (is_new == 'n') {
                    var data = dealDetail.get_refresh_param();

                    dealDetail.refresh_grid(data, function() {
                        dealDetail.grid.selectRowById(row_id);
                    });
                } else {
                    var ifr = w.getFrame();
                    var ifrWindow = ifr.contentWindow;
                    var ifrDocument = ifrWindow.document;
                    var vol = $('textarea[name="txt_vol"]', ifrDocument).val();
                    var price = $('textarea[name="txt_price"]', ifrDocument).val();
                    shaped_created = 'y';

                    if (is_new == 'y' && process_id == 'NULL') {
                        process_id = $('textarea[name="txt_process"]', ifrDocument).val();
                    }

                    if (typeof volume_index != 'undefined') {
                        dealDetail.grid.cells(row_id, volume_index).setValue(vol);
                        dealDetail.grid.cells(row_id, volume_index).cell.wasChanged = true;
                    }

                    if (typeof price_index != 'undefined') {
                        dealDetail.grid.cells(row_id, price_index).setValue(price);
                        dealDetail.grid.cells(row_id, price_index).cell.wasChanged = true;
                    }
                }
                return true;
            });
        } else  {
            dealDetail.profile_type_mismatch(return_value[0][4]);
            return;
        }

        dealDetail.deal_detail.cells('c').progressOff();
    }
	
	/**
     * [open_deal_transfer Open Deal Transfer UI.]
     */
    var deal_transfer_window;
    dealDetail.open_deal_transfer = function() {
         var deal_id = '<?php echo $deal_id; ?>';
        if (deal_transfer_window != null && deal_transfer_window.unload != null) {
            deal_transfer_window.unload();
            deal_transfer_window = w1 = null;
        }

        if (!deal_transfer_window) {
            deal_transfer_window = new dhtmlXWindows();
        }

        var transfer_win = deal_transfer_window.createWindow('w1',  0, 0, 500, 500);
        transfer_win.setText("Deal Transfer - " + deal_id);
        transfer_win.centerOnScreen();
        transfer_win.setModal(true);
		transfer_win.maximize();
        transfer_win.attachURL('deal.transfer.php', false, {deal_id:deal_id});
		
        transfer_win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var return_string = $('textarea[name="txt_status"]', ifrDocument).val();

            if (return_string.toLowerCase() == 'success') {
                dealDetail.refresh_grid();
            }

            return true;
        });
    }
	
    /**
     * [profile_type_mismatch Display msg for mismatch deals profile type]
     * @param  {[string]} message [Failed message]
     */
    dealDetail.profile_type_mismatch = function(message) {
        dhtmlx.alert({
            title:"Alert",
            type:"alert",
            text:message
        });
    }

    /**
     * [deal_pricing_deemed_selection Deemed grid selection function]
     * @param  {[type]} row_ids [Row Ids]
     */
    dealDetail.deal_pricing_deemed_selection = function(row_ids) {
        var has_rights_deal_edit = Boolean('<?php echo $has_rights_deal_edit; ?>');
        if (row_ids != null) {
            if (has_rights_deal_edit) dealDetail.escalation_menu.setItemEnabled('delete');
        } else {
            dealDetail.escalation_menu.setItemDisabled('delete');
        }
    }

    /**
     * [escalation_menu_click Menu click function for escalation grid]
     * @param  {[type]} id [Menu id]
     */
    dealDetail.escalation_menu_click = function(id) {
        switch(id) {
            case "add":
                var new_id = (new Date()).valueOf();
                dealDetail.deal_escalation.addRow(new_id, '');
                break;
            case "delete":
                var row_id = dealDetail.grid.getSelectedRowId();
                var parent_id = dealDetail.grid.getParentId(row_id);
                var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
                var group_index = dealDetail.grid.getColIndexById('group_id');
                if (parent_id != 0) {
                    var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
                    var group_id = 'NULL';
                } else {
                    var group_id = dealDetail.grid.cells(row_id, group_index).getValue();
                    var detail_id = 'NULL';
                }

                var id = dealDetail.deal_escalation.getSelectedRowId();
                var system_id = dealDetail.deal_escalation.cells(id, 0).getValue();
                var pricing_process_id = '<?php echo $pricing_process_id; ?>';

                var data = {
                    "action":"spa_deal_pricing",
                    "flag":'d',
                    "source_deal_detail_id":detail_id,
                    "group_id":group_id,
                    "pricing_process_id":pricing_process_id,
                    "pricing_id":system_id,
                    "pricing_table_type":'e'
                }
                dealDetail.deal_escalation.deleteSelectedRows();
                dealDetail.escalation_menu.setItemDisabled('delete');
                adiha_post_data("return", data, '', '', '');
                break;
            case "refresh":
                var changed_rows = dealDetail.deal_escalation.getChangedRows(true);
                if (changed_rows != '') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to refresh grid?",
                        callback: function(result) {
                            if (result) {
                                dealDetail.refresh_escalation_grid();
                            }
                        }
                    });
                } else {
                    dealDetail.refresh_escalation_grid();
                }
                break;
        }
    }

    /**
     * [refresh_escalation_grid Refresh Escalation grid]
     * @return {[type]} [description]
     */
    dealDetail.refresh_escalation_grid = function() {
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var group_index = dealDetail.grid.getColIndexById('group_id');

        var row_id = dealDetail.grid.getSelectedRowId();
        if (row_id != null) {
            var parent_id = dealDetail.grid.getParentId(row_id);
            if (parent_id != 0) {
                var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
                var group_id = 'NULL';
            } else {
                var group_id = dealDetail.grid.cells(row_id, group_index).getValue();
                var detail_id = 'NULL';
            }

            var data = {
                "action":"spa_deal_pricing",
                "flag":'e',
                "source_deal_detail_id":detail_id,
                "group_id":group_id,
                "pricing_process_id":pricing_process_id,
                "grid_type":"g"
            }
            data = $.param(data);
            var sql_url = js_data_collector_url + "&" + data;

            dealDetail.deal_escalation.clearAll();
            dealDetail.deal_escalation.load(sql_url);
        } else {
            dealDetail.deal_escalation.clearAll();
        }
    }

    /**
     * [save_escalation_data Save escalation data to process table.]
     * @return {[type]} [description]
     */
    dealDetail.save_escalation_data = function(row_id) {
        if (row_id == '')
            row_id = dealDetail.grid.getSelectedRowId();

        var changed_rows = dealDetail.deal_escalation.getChangedRows(true);

        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var group_index = dealDetail.grid.getColIndexById('group_id');

        if (row_id != null && changed_rows != '') {
            var parent_id = dealDetail.grid.getParentId(row_id);
            if (parent_id != 0) {
                var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
                var group_id = 'NULL';
            } else {
                var group_id = dealDetail.grid.cells(row_id, group_index).getValue();
                var detail_id = 'NULL';
            }

            escalation_xml = '<GridXML>';
            dealDetail.deal_escalation.forEachRow(function(id){
                escalation_xml += '<GridRow ';
                for(var cellIndex = 0; cellIndex < dealDetail.deal_escalation.getColumnsNum(); cellIndex++){
                    var column_id = dealDetail.deal_escalation.getColumnId(cellIndex);
                    var cell_value = dealDetail.deal_escalation.cells(id,cellIndex).getValue();

                    escalation_xml += ' ' + column_id + '="' + cell_value + '"';
                }
                escalation_xml += '></GridRow>';
            });
            escalation_xml += '</GridXML>';

            var data = {
                "action":"spa_deal_pricing",
                "flag":'t',
                "source_deal_detail_id":detail_id,
                "group_id":group_id,
                "pricing_process_id":pricing_process_id,
                "escalation_xml":escalation_xml
            }
            adiha_post_data("return_status", data, '', '', '');
        }
    }

    /**
     * [Open Certificate window]
     */
    certi_process_id = 0;
    var certificate_process_id ;
    dealDetail.open_certificate = function(){
        var deal_id = '<?php echo $deal_id; ?>';
        var buy_sell = '<?php echo $buy_sell; ?>';

        var param = app_form_path +  '_deal_capture/maintain_deals/certificate.php?&source_deal_header_id=' + deal_id + '&buy_sell=' + buy_sell+ '&certificate_process_id=' + certificate_process_id;
        var is_win = dhxWins.isWindow('w11');

        if (is_win == true) {
            w11.close();
        }

        w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
        w11.setText("Certificate Detail");
        w11.setModal(true);
        w11.maximize();

        w11.attachURL(param, false, true)
        w11.attachEvent('onClose', function(win) {
            certificate_process_id = certi_process_id;
            return true;
        });

    }

    var env_process_id;
    var environment_process_id;
    /**
     * [Open Product window]
     */
    dealDetail.open_product = function(){
        var deal_id = '<?php echo $deal_id; ?>';
        var param = app_form_path +  '_deal_capture/maintain_deals/product.php?&source_deal_header_id=' + deal_id + '&environment_process_id=' + environment_process_id;

        var is_win = dhxWins.isWindow('w11');

        if (is_win == true) {
            w11.close();
        }

        w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
        w11.setText("Product Detail");
        w11.setModal(true);
        w11.maximize();

        w11.attachURL(param, false, true)
        w11.attachEvent('onClose', function(win) {
            environment_process_id = env_process_id;
            return true;
        });

    }

    var cost_udf_window;

    dealDetail.udf_menu_click = function(id) {
        switch(id) {
            case "add":
                var header_xml = 'NULL';

                if (dealDetail.form_0) {
                    header_xml = '<GridXML>';

                    var form_obj = dealDetail.form_0;
                    data = form_obj.getFormData();

                    for (var a in data) {
                        var field_label = a;

                        if (form_obj.getItemType(field_label) == 'calendar') {
                            var field_value = form_obj.getItemValue(field_label, true);
                        } else {
                            var field_value = data[field_label];
                        }

                        header_xml += '<GridRow cost_id="' + field_label.replace('UDF___', '') + '" cost_name="" udf_value="' + field_value + '" currency_id="" uom_id="" counterparty_id=""></GridRow>';
                    }

                    header_xml += '</GridXML>';
                }

                header_xml = (header_xml == '<GridXML></GridXML>') ? 'NULL' : header_xml;

                var udf_process_id = '<?php echo $udf_process_id;?>';
                var deal_id = '<?php echo $deal_id;?>';

                if (deal_id == 'NULL') {
                    var template_id = '<?php echo $template_id; ?>';
                } else {
                    var template_id = 'NULL';
                }

                var cm_param = {"action": "spa_udf_groups", "flag": "u", "udf_process_id":udf_process_id, "deal_id":deal_id, "template_id":template_id, "udf_xml":header_xml, "udf_type":'hu'};
                adiha_post_data("return", cm_param, '', '', 'dealDetail.open_udf_window');
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
                    "flag":'k',
                    "deal_id":deal_id,
                    "template_id":template_id,
                    "udf_process_id":udf_process_id,
                    "udf_type":'hu'
                }
                adiha_post_data("return", data, '', '', 'dealDetail.reload_udf_form');
                break;
        }
    }

    dealDetail.reload_udf_form = function(returnval) {
        if (returnval[0].form_json && dealDetail.form_0) {
            dealDetail.form_0.unload();
            dealDetail.form_0 = null;

            dealDetail.form_0 = dealDetail.deal_tab.tabs('0').attachForm();

            dealDetail.form_0.loadStruct(returnval[0].form_json);
        }
    }


    dealDetail.open_udf_window = function(returnval) {
        if (cost_udf_window != null && cost_udf_window.unload != null) {
            cost_udf_window.unload();
            cost_udf_window = w1 = null;
        }
        var deal_id = '<?php echo $deal_id; ?>';
        var udf_process_id = '<?php echo $udf_process_id;?>';

        if (!cost_udf_window) {
            cost_udf_window = new dhtmlXWindows();
        }

        if (deal_id == 'NULL') {
            var template_id = '<?php echo $template_id; ?>';
        } else {
            var template_id = 'NULL';
        }

        var win_title = 'UDFs';
        var win_url = 'cost.udf.list.php';
        var win = cost_udf_window.createWindow('w1', 0, 0, 600, 600);

        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);

        win.attachURL(win_url, false, {deal_id:deal_id,type:'hu',udf_process_id:udf_process_id,template_id:template_id});
        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var click_type = $('textarea[name="txt_click"]', ifrDocument).val();

            if (click_type == 'ok')
                dealDetail.udf_menu_click('refresh');

            return true;
        });
    }

    /**
     * [header_cost_menu_click Header cost menu click]
     * @param  {[string]} id [menu id]
     */
    dealDetail.header_cost_menu_click = function(id) {
        switch(id) {
            case "add":
                var header_cost_change = dealDetail.header_deal_costs.getChangedRows(true);
                var header_cost_xml = 'NULL';

                if (header_cost_change != '') {
                    header_cost_xml = '<GridXML>';
                    var changed_ids = new Array();
                    changed_ids = header_cost_change.split(",");
                    $.each(changed_ids, function(index, value) {
                        header_cost_xml += '<GridRow ';
                        for(var cellIndex = 0; cellIndex < dealDetail.header_deal_costs.getColumnsNum(); cellIndex++){
                            var column_id = dealDetail.header_deal_costs.getColumnId(cellIndex);
                            var cell_value = dealDetail.header_deal_costs.cells(value, cellIndex).getValue();
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
                adiha_post_data("return", cm_param, '', '', 'dealDetail.open_header_cost_udf_window');

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
                dealDetail.header_deal_costs.clearAll();

                dealDetail.header_deal_costs.load(sql_url, function() {
                    var udf_value_index = dealDetail.header_deal_costs.getColIndexById('udf_value');
                    for (i = 0; i < dealDetail.header_deal_costs.getRowsNum(); i++) {
                        dealDetail.header_deal_costs.cells2(i, udf_value_index).cell.wasChanged = true;
                    }

                    dealDetail.header_cost_onload();
                });

                break;
        }
    }

    dealDetail.open_header_cost_udf_window = function(returnval) {
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
        var win_url = 'cost.udf.list.php';
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
                dealDetail.header_cost_menu_click('refresh');

            return true;
        });
    }

    /**
     * [detail_cost_menu_click Header cost menu click]
     * @param  {[string]} id [menu id]
     */
    dealDetail.detail_cost_menu_click = function(id, call_from) {
        switch(id) {
            case "add":
                dealDetail.deal_detail_cost.clearSelection();
                var detail_cost_change = dealDetail.deal_detail_cost.getChangedRows(true);
                var detail_cost_xml = 'NULL';

                if (detail_cost_change != '') {
                    detail_cost_xml = '<GridXML>';
                    var changed_ids = new Array();
                    changed_ids = detail_cost_change.split(",");
                    $.each(changed_ids, function(index, value) {
                        detail_cost_xml += '<GridRow ';
                        for(var cellIndex = 0; cellIndex < dealDetail.deal_detail_cost.getColumnsNum(); cellIndex++){
                            var column_id = dealDetail.deal_detail_cost.getColumnId(cellIndex);
                            var cell_value = dealDetail.deal_detail_cost.cells(value, cellIndex).getValue();
                            detail_cost_xml += ' ' + column_id + '="' + cell_value + '"';
                        }
                        detail_cost_xml += '></GridRow>';
                    });
                    detail_cost_xml += '</GridXML>';
                }

                detail_cost_xml = (detail_cost_xml == '<GridXML></GridXML>') ? 'NULL' : detail_cost_xml;

                var udf_process_id = '<?php echo $udf_process_id;?>';
                var deal_id = '<?php echo $deal_id;?>';

                if (deal_id == 'NULL') {
                    var template_id = '<?php echo $template_id; ?>';
                } else {
                    var template_id = 'NULL';
                }

                var no_of_child = '';
                var parent_id = '';
                var deal_detail_index = '';
                var detail_id = '';
                var row_id = dealDetail.grid.getSelectedRowId();

                if (row_id) {
                    no_of_child = dealDetail.grid.hasChildren(row_id);
                    parent_id = dealDetail.grid.getParentId(row_id);
                    deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
                    detail_id = (parent_id != 0 || no_of_child < 1) ? dealDetail.grid.cells(row_id, deal_detail_index).getValue() : '';
                }

                var cm_param = {
                    "action": "spa_udf_groups",
                    "flag": "u",
                    "udf_process_id":udf_process_id,
                    "deal_id":deal_id,
                    "template_id":template_id,
                    "udf_xml":detail_cost_xml,
                    "udf_type":'dc',
                    "detail_id":detail_id
                };

                adiha_post_data("return", cm_param, '', '', 'dealDetail.open_detail_cost_udf_window');
                break;
            case "refresh":
                dealDetail.detail_cost_menu.setItemEnabled('add');
                save_all_detail_cost_udf = 1;
                var deal_id = '<?php echo $deal_id;?>';
                var udf_process_id = '<?php echo $udf_process_id;?>';
                var term_start = dealDetail.detail_cost_filter_form.getItemValue('term_start', true);
                var term_end = dealDetail.detail_cost_filter_form.getItemValue('term_end', true);
                var leg = dealDetail.detail_cost_filter_form.getItemValue('leg');;
                var no_of_child = '';
                var parent_id = '';
                var deal_detail_index = '';
                var detail_id = '';

                if (deal_id == 'NULL') {
                    var template_id = '<?php echo $template_id; ?>';
                } else {
                    var template_id = 'NULL';
                }

                var row_id = dealDetail.grid.getSelectedRowId();

                if (row_id) {
                    no_of_child = dealDetail.grid.hasChildren(row_id);
                    parent_id = dealDetail.grid.getParentId(row_id);
                    deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
                    detail_id = (call_from == 'DealDetailGrid' && (parent_id != 0 || no_of_child < 1)) ? dealDetail.grid.cells(row_id, deal_detail_index).getValue() : '';
                }

                var data = {
                    "action":"spa_udf_groups",
                    "flag":'z',
                    "deal_id":deal_id,
                    "template_id":template_id,
                    "udf_process_id":udf_process_id,
                    "udf_type":'dc',
                    "detail_id":detail_id,
                    "term_start":term_start,
                    "term_end":term_end,
                    "leg":leg,
                    "grid_type":"g"
                }
                sql_param = $.param(data);

                var sql_url = js_data_collector_url + "&" + sql_param;
                dealDetail.deal_detail_cost.clearAll();
                dealDetail.deal_detail_cost.load(sql_url);

                break;
        }
    }

    dealDetail.open_detail_cost_udf_window = function(returnval) {
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
        var win_url = 'cost.udf.list.php';
        var win = cost_udf_window.createWindow('w1', 0, 0, 600, 600);

        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);

        var no_of_child = '';
        var parent_id = '';
        var deal_detail_index = '';
        var detail_id = '';
        var row_id = dealDetail.grid.getSelectedRowId();

        if (row_id) {
            no_of_child = dealDetail.grid.hasChildren(row_id);
            parent_id = dealDetail.grid.getParentId(row_id);
            deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
            detail_id = (parent_id != 0 || no_of_child < 1) ? dealDetail.grid.cells(row_id, deal_detail_index).getValue() : '';
        }

        win.attachURL(win_url, false, {deal_id:deal_id,template_id:template_id,type:'dc',udf_process_id:udf_process_id,detail_id:detail_id});
        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var click_type = $('textarea[name="txt_click"]', ifrDocument).val();

            if (click_type == 'ok')
                dealDetail.detail_cost_menu_click('refresh', 'DealDetailGrid');

            return true;
        });
    }

    dealDetail.save_detail_udf = function(row_id, callback_function) {
        if (row_id == '') {
            row_id = dealDetail.grid.getSelectedRowId();
        }

        var no_of_child = dealDetail.grid.hasChildren(row_id);
        var parent_id = dealDetail.grid.getParentId(row_id);
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');

        if (parent_id != 0 || no_of_child < 1) {
            var detail_xml = 'NULL';

            if (dealDetail.detail_udf_form) {
                detail_xml = '<GridXML>';

                var form_obj = dealDetail.detail_udf_form;
                data = form_obj.getFormData();

                for (var a in data) {
                    var field_label = a;

                    if (form_obj.getItemType(field_label) == 'calendar') {
                        var field_value = form_obj.getItemValue(field_label, true);
                    } else {
                        var field_value = data[field_label];
                    }

                    detail_xml += '<GridRow cost_id="' + field_label.replace('UDF___', '') + '" cost_name="" udf_value="' + field_value + '" currency_id="" uom_id="" counterparty_id="" contract_id="" receive_pay=""></GridRow>';
                }

                detail_xml += '</GridXML>';
            }

            detail_xml = (detail_xml == '<GridXML></GridXML>') ? 'NULL' : detail_xml;

            var udf_process_id = '<?php echo $udf_process_id;?>';
            var deal_id = '<?php echo $deal_id;?>';

            if (deal_id == 'NULL') {
                var template_id = '<?php echo $template_id; ?>';
            } else {
                var template_id = 'NULL';
            }

            var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
            var cm_param = {"action": "spa_udf_groups", "flag": "u", "udf_process_id":udf_process_id, "deal_id":deal_id, "template_id":template_id, "udf_xml":detail_xml, "udf_type":'du', "detail_id":detail_id};

            if (callback_function != '') {
                adiha_post_data("return", cm_param, '', '', callback_function);
            } else {
                if (detail_xml != 'NULL')
                    adiha_post_data("return", cm_param, '', '', '');
            }
        }
    }

    dealDetail.detail_udf_menu_click = function(id) {
        switch(id) {
            case "add":
                dealDetail.save_detail_udf('', 'dealDetail.open_detail_udf_window');
                break;
            case "refresh":
                var row_id = dealDetail.grid.getSelectedRowId();

                if (row_id != '' && row_id != null) {
                    var deal_id = '<?php echo $deal_id;?>';
                    var udf_process_id = '<?php echo $udf_process_id;?>';

                    if (deal_id == 'NULL') {
                        var template_id = '<?php echo $template_id; ?>';
                    } else {
                        var template_id = 'NULL';
                    }

                    var no_of_child = dealDetail.grid.hasChildren(row_id);
                    var parent_id = dealDetail.grid.getParentId(row_id);
                    var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');

                    if (parent_id != 0 || no_of_child < 1) {
                        var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
                        var data = {
                            "action":"spa_udf_groups",
                            "flag":'k',
                            "deal_id":deal_id,
                            "template_id":template_id,
                            "udf_process_id":udf_process_id,
                            "detail_id":detail_id,
                            "udf_type":'du'
                        }
                        adiha_post_data("return", data, '', '', 'dealDetail.reload_detail_udf_form');
                    } else {
                        if (dealDetail.detail_udf_form) {
                            dealDetail.detail_udf_form.unload();
                            dealDetail.detail_udf_form = null;
                        }
                    }
                } else {
                    if (dealDetail.detail_udf_form) {
                        dealDetail.detail_udf_form.unload();
                        dealDetail.detail_udf_form = null;
                    }
                }
                break;
        }
    }

    dealDetail.reload_detail_udf_form = function(returnval) {
        if (dealDetail.detail_udf_form) {
            dealDetail.detail_udf_form.unload();
            dealDetail.detail_udf_form = null;
        }

        if (returnval[0].form_json) {
            dealDetail.detail_udf_form = dealDetail.deal_detail_tab.tabs('tab_detail_udf').attachForm();

            dealDetail.detail_udf_form.loadStruct(returnval[0].form_json);
        }
    }

    dealDetail.open_detail_udf_window = function(returnval) {
        if (cost_udf_window != null && cost_udf_window.unload != null) {
            cost_udf_window.unload();
            cost_udf_window = w1 = null;
        }
        var deal_id = '<?php echo $deal_id; ?>';
        var udf_process_id = '<?php echo $udf_process_id;?>';

        if (!cost_udf_window) {
            cost_udf_window = new dhtmlXWindows();
        }

        var row_id = dealDetail.grid.getSelectedRowId();
        var no_of_child = dealDetail.grid.hasChildren(row_id);
        var parent_id = dealDetail.grid.getParentId(row_id);
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        if (parent_id != 0 || no_of_child < 1) {
            var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();

            var win_title = 'UDFs';
            var win_url = 'cost.udf.list.php';
            var win = cost_udf_window.createWindow('w1', 0, 0, 600, 600);

            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);

            win.attachURL(win_url, false, {deal_id:deal_id,type:'du',udf_process_id:udf_process_id,detail_id:detail_id});
            win.attachEvent('onClose', function(w) {
                var ifr = w.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                var click_type = $('textarea[name="txt_click"]', ifrDocument).val();

                if (click_type == 'ok')
                    dealDetail.detail_udf_menu_click('refresh');

                return true;
            });
        }
    }

    /**
     * [document_menu_click Menu click function for Document grid]
     * @param  {[type]} id [Menu id]
     */
    dealDetail.document_menu_click = function(id) {
        switch(id) {
            case "add":
                dealDetail.open_deal_required_document(-1);
                break;
            case "delete":
                if (changed_rows != '') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "Are you sure you want to delete document?",
                        callback: function(result) {
                            if (result) {
                                dealDetail.delete_documents();
                            }
                        }
                    });
                }


                break;
            case "refresh":
                var changed_rows = dealDetail.deal_documents.getChangedRows(true);
                if (changed_rows != '') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to refresh grid?",
                        callback: function(result) {
                            if (result) {
                                dealDetail.refresh_document_grid();
                            }
                        }
                    });
                } else {
                    dealDetail.refresh_document_grid();
                }
                break;
        }
    }

    dealDetail.delete_documents = function() {
        var selected_docs = dealDetail.deal_documents.getColumnValues(1);
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        var deal_id = '<?php echo $deal_id; ?>';
        var data = {
            "action":"spa_deal_update_new",
            "flag":'z',
            "source_deal_header_id":deal_id,
            "document_list":selected_docs,
            "pricing_process_id":pricing_process_id
        }
        dealDetail.deal_documents.deleteSelectedRows();
        dealDetail.document_menu.setItemDisabled('delete');
        adiha_post_data("return_status", data, '', '', 'dealDetail.refresh_document_grid');
    }

    var dhx_document;
    dealDetail.open_deal_required_document = function(note_id) {
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        if (dhx_document != null && dhx_document.unload != null) {
            dhx_document.unload();
            dhx_document = w1 = null;
        }
        var deal_id = '<?php echo $deal_id; ?>';

        if (!dhx_document) {
            dhx_document = new dhtmlXWindows();
        }

        var win_title = 'Required Document';
        var win_url = 'list.required.document.php';
        //var win_url = app_form_path + '_setup/manage_documents/manage.documents.add.edit.php';
        var win = dhx_document.createWindow('w1', 0, 0, 500, 500);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {deal_id:deal_id,process_id:pricing_process_id});

        win.attachEvent('onClose', function(w) {
            dealDetail.refresh_document_grid();
            return true;
        });
    }

    /**
     * [refresh_document_grid Document Grid Refresh]
     */
    dealDetail.refresh_document_grid = function() {
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        var deal_id = '<?php echo $deal_id; ?>';
        var download_path = php_script_loc + 'force_download.php';

        var data = {
            "action":"spa_deal_update_new",
            "flag":'w',
            "source_deal_header_id":deal_id,
            "pricing_process_id":pricing_process_id,
            "grid_type":"g"
        }
        data = $.param(data);
        var sql_url = js_data_collector_url + "&" + data;

        dealDetail.deal_documents.clearAll();
        dealDetail.deal_documents.load(sql_url);
    }

    dealDetail.doc_selected = function(row) {
        if (row != null) {
            dealDetail.document_menu.setItemEnabled('delete');
        }
    }

    /**
     * [grid_row_dbl_click Detail Grid double click function]
     * @param  {[type]} row_id [RowID]
     * @param  {[type]} col_id [ColID]
     */
    dealDetail.grid_row_dbl_click = function(row_id, col_id) {
        var group_index = dealDetail.grid.getColIndexById('deal_group');
        var parent_id = dealDetail.grid.getParentId(row_id);

        if (parent_id == 0 && col_id == group_index) {
            if (group_name_win != null && group_name_win.unload != null) {
                group_name_win.unload();
                group_name_win = w1 = null;
            }
            var deal_id = '<?php echo $deal_id; ?>';

            if (!group_name_win) {
                group_name_win = new dhtmlXWindows();
            }

            var win_title = 'Group Name';
            var win_url = 'group.name.php';
            var group_name = dealDetail.grid.cells(row_id, col_id).getValue();

            var win = group_name_win.createWindow('w1', 0, 0, 550, 400);
            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.attachURL(win_url, false, {group_name:group_name});

            win.attachEvent('onClose', function(w) {
                var ifr = w.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                var new_group_name = $('textarea[name="txt_group_name"]', ifrDocument).val();

                if (new_group_name !== group_name) {
                    dealDetail.grid.cells(row_id, col_id).setValue(new_group_name);
                    dealDetail.grid.cells(row_id, col_id).cell.wasChanged = true;
                }

                return true;
            });
        }
    }

    /**
     * [grid_before_drag Drag and drop control function]
     * @param  {[type]} dId  [drop id]
     * @param  {[type]} tId  [target id]
     * @param  {[type]} sObj [drop object]
     * @param  {[type]} tObj [target object]
     */
    dealDetail.grid_before_drag = function(dId,tId,sObj,tObj) {
        var parent_id = dealDetail.grid.getParentId(tId);
        if (parent_id == 0) {
            dealDetail.grid.setDragBehavior("child");
        } else {
            dealDetail.grid.setDragBehavior("sibling");
        }

        return true;
    }

    /**
     * [remarks_menu_click Remarks Menu Click]
     * @param  {[type]} id [Menu ID]
     */
    dealDetail.remarks_menu_click = function(id) {
        switch(id) {
            case "add":
                dealDetail.open_deal_remarks();
                break;
            case "add_new":
                var new_id = (new Date()).valueOf();
                dealDetail.deal_remarks.addRow(new_id, ["New_"+new_id, '']);
                break;
            case "delete":
                dhtmlx.message({
                    type: "confirm",
                    text: "Are you sure you want to delete selected remarks?",
                    callback: function(result) {
                        if (result) {
                            dealDetail.delete_remarks();
                        }
                    }
                });


                break;
            case "refresh":
                var changed_rows = dealDetail.deal_remarks.getChangedRows(true);
                if (changed_rows != '') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "There are unsaved changes. Are you sure you want to refresh grid?",
                        callback: function(result) {
                            if (result) {
                                dealDetail.refresh_remarks_grid();
                            }
                        }
                    });
                } else {
                    dealDetail.refresh_remarks_grid();
                }
                break;
        }
    }

    dealDetail.remarks_selected = function(row) {
        if (row != null) {
            dealDetail.remarks_menu.setItemEnabled('delete');
        }
    }

    var dhx_remarks;
    /**
     * [open_deal_remarks Open Pre defined remarks window]
     */
    dealDetail.open_deal_remarks = function() {
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        if (dhx_remarks != null && dhx_remarks.unload != null) {
            dhx_remarks.unload();
            dhx_remarks = w1 = null;
        }
        var deal_id = '<?php echo $deal_id; ?>';

        if (!dhx_remarks) {
            dhx_remarks = new dhtmlXWindows();
        }

        var win_title = 'Deal Remarks';
        var win_url = 'list.deal.remarks.php';
        var win = dhx_remarks.createWindow('w1', 0, 0, 500, 500);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL(win_url, false, {deal_id:deal_id,process_id:pricing_process_id});

        win.attachEvent('onClose', function(w) {
            dealDetail.refresh_remarks_grid();
            return true;
        });
    }

    /**
     * [delete_remarks Delete Remarks from process table]
     */
    dealDetail.delete_remarks = function() {
        var selected_remarks = dealDetail.deal_remarks.getColumnValues(0);
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        var deal_id = '<?php echo $deal_id; ?>';
        var data = {
            "action":"spa_deal_update_new",
            "flag":'u',
            "source_deal_header_id":deal_id,
            "remarks_list":selected_remarks,
            "pricing_process_id":pricing_process_id
        }
        dealDetail.deal_remarks.deleteSelectedRows();
        dealDetail.remarks_menu.setItemDisabled('delete');
        adiha_post_data("return_status", data, '', '', 'dealDetail.refresh_remarks_grid');
    }

    /**
     * [refresh_remarks_grid Refresh Remarks Grid]
     */
    dealDetail.refresh_remarks_grid = function() {
        var pricing_process_id = '<?php echo $pricing_process_id; ?>';
        var deal_id = '<?php echo $deal_id; ?>';

        var data = {
            "action":"spa_deal_update_new",
            "flag":'o',
            "source_deal_header_id":deal_id,
            "pricing_process_id":pricing_process_id,
            "grid_type":"g"
        }
        data = $.param(data);
        var sql_url = js_data_collector_url + "&" + data;

        dealDetail.deal_remarks.clearAll();
        dealDetail.deal_remarks.load(sql_url);
    }

    /**
     * [remarks_edit Remarks Grid Edit function]
     * @param  {[type]} stage  [Stage of edit]
     * @param  {[type]} rId    [Row ID]
     * @param  {[type]} cInd   [Column ID]
     * @param  {[type]} nValue [New Value]
     * @param  {[type]} oValue [Old Value]
     */
    dealDetail.remarks_edit = function(stage,rId,cInd,nValue,oValue) {
        if (stage == 2) {
            var pricing_process_id = '<?php echo $pricing_process_id; ?>';
            var deal_id = '<?php echo $deal_id; ?>';

            var remarks_index = dealDetail.deal_remarks.getColIndexById('remark_text');
            if (cInd == remarks_index) {
                var id_index = dealDetail.deal_remarks.getColIndexById('id');
                var id = dealDetail.deal_remarks.cells(rId, id_index).getValue();
                var remarks = dealDetail.deal_remarks.cells(rId, remarks_index).getValue();
                var data = {
                    "action":"spa_deal_update_new",
                    "flag":'v',
                    "source_deal_header_id":deal_id,
                    "remarks_list":id,
                    "document_list":remarks, // used document_list param to avoid extra param
                    "pricing_process_id":pricing_process_id
                }
                dealDetail.deal_remarks.deleteSelectedRows();
                dealDetail.remarks_menu.setItemDisabled('delete');
                adiha_post_data("return_status", data, '', '', 'dealDetail.refresh_remarks_grid');
            }
        }
        return true;
    }

    /**
     * [exercise_deal Open Exercise deal UI and complete the exercise process.]
     */
    dealDetail.exercise_deal = function() {
        var row_id = dealDetail.grid.getSelectedRowId();
        var parent_id = dealDetail.grid.getParentId(row_id);
        var no_of_child = dealDetail.grid.hasChildren(row_id);
        var deal_id = '<?php echo $deal_id;?>';
        var group_id_index = dealDetail.grid.getColIndexById('group_id');
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');

        if (exercise_window != null && exercise_window.unload != null) {
            exercise_window.unload();
            exercise_window = w1 = null;
        }
        var deal_id = '<?php echo $deal_id; ?>';

        if (!exercise_window) {
            exercise_window = new dhtmlXWindows();
        }

        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');

        if (parent_id == 0 && no_of_child > 0) {
            var min_max_term = dealDetail.grid.collectValues(term_start_index);
            min_max_term.sort(function(a, b){
                return Date.parse(a) - Date.parse(b);
            });
            var min_term_start = min_max_term[0];
            var max_term_end = dealDetail.grid.collectValues(term_end_index);
            max_term_end.sort(function(a, b){
                return Date.parse(a) - Date.parse(b);
            });
            var max_term_end = max_term_end[max_term_end.length-1];

            var first_child = dealDetail.grid.getChildItemIdByIndex(row_id, 0);
            var group_id = dealDetail.grid.cells(first_child, group_id_index).getValue();
            var detail_id = '';
        } else {
            var min_term_start = dealDetail.grid.cells(row_id, term_start_index).getValue();
            var max_term_end = dealDetail.grid.cells(row_id, term_end_index).getValue();
            var group_id = '';
            var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
        }

        var win_title = 'Exercise Deal';
        var win_url = 'deal.exercise.php';

        var win = exercise_window.createWindow('w1', 0, 0, 550, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL(win_url, false, {type:'c',term_start:min_term_start,term_end:max_term_end,deal_id:deal_id,detail_id:detail_id,group_id:group_id});
    }

    dealDetail.open_update_profile = function() {
        var tab_obj = dealDetail.deal_tab;
        var granularity = '';
        var volume_type = '' ;

        tab_obj.forEachTab(function(tab) {
            var form_object = tab.getAttachedObject();
            if (form_object instanceof dhtmlXForm)
                var data = form_object.getFormData();

            for (var a in data) {
                var field_label = a;

                if (field_label == 'profile_granularity') {
                    granularity = data[field_label];
                }

                if (field_label == 'internal_desk_id') {
                    volume_type = data[field_label];
                }
            }
        });

        if (update_actual_window != null && update_actual_window.unload != null) {
            update_actual_window.unload();
            update_actual_window = w1 = null;
        }

        if (!update_actual_window) {
            update_actual_window = new dhtmlXWindows();
        }

        var win_url = '../../_price_curve_management/update_profile_data/update.profile.data.php';

        var deal_id = '<?php echo $deal_id; ?>';
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');
        var schedule_volume_index = dealDetail.grid.getColIndexById('schedule_volume');
        var profile_id_index = dealDetail.grid.getColIndexById('profile_id');
        var location_id_index = dealDetail.grid.getColIndexById('location_id');
        var leg_index = dealDetail.grid.getColIndexById('blotterleg');

        var row_id = dealDetail.grid.getSelectedRowId();
        var term_start = dealDetail.grid.cells(row_id, term_start_index).getValue();
        var term_end = dealDetail.grid.cells(row_id, term_end_index).getValue();
        var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
        var profile_id = (profile_id_index != undefined) ? dealDetail.grid.cells(row_id, profile_id_index).getValue() : null;
        var location_id = (location_id_index != undefined) ? dealDetail.grid.cells(row_id, location_id_index).getValue() : null;

        var formatted_term_start = dates.convert_to_user_format(term_start);
        var formatted_term_end = dates.convert_to_user_format(term_end);
        var win_title = 'Update Forecast Volume (Deal: ' + deal_id + ', Term: ' + formatted_term_start + ' - ' + formatted_term_end + ')';
        detail_id = (detail_id.match(/NEW.*/)) ? 'NULL' : detail_id;

        var win = update_actual_window.createWindow('w1', 0, 0, 500, 500);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {call_from: 'deal_detail',deal_id:deal_id,detail_id:detail_id,term_start:term_start,term_end:term_end,granularity:granularity,profile_id:profile_id,location_id:location_id});
        var is_new = 'n';

        if (copy_deal_id != 'NULL' || template_id != 'NULL' || detail_id.indexOf('New') == 0 || detail_id.indexOf('NEW') == 0) {
            is_new = 'y';

            leg = (leg_index != undefined) ? dealDetail.grid.cells(row_id, leg_index).getValue() : null;
            if (typeof volume_index != 'undefined')
                volume = dealDetail.grid.cells(row_id, volume_index).getValue();
            if (typeof price_index != 'undefined')
                price = dealDetail.grid.cells(row_id, price_index).getValue();
        }

        win.attachEvent('onClose', function(w) {
            if (is_new == 'n') {
                var data = dealDetail.get_refresh_param();

                dealDetail.refresh_grid(data, function() {
                    dealDetail.grid.selectRowById(row_id);
                });
            } else {
                var ifr = w.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                var vol = $('textarea[name="txt_vol"]', ifrDocument).val();
                var price = $('textarea[name="txt_price"]', ifrDocument).val();
                shaped_created = 'y';

                if (is_new == 'y' && process_id == 'NULL') {
                    process_id = $('textarea[name="txt_process"]', ifrDocument).val();
                }

                if (typeof volume_index != 'undefined') {
                    dealDetail.grid.cells(row_id, volume_index).setValue(vol);
                    dealDetail.grid.cells(row_id, volume_index).cell.wasChanged = true;
                }

                if (typeof price_index != 'undefined') {
                    dealDetail.grid.cells(row_id, price_index).setValue(price);
                    dealDetail.grid.cells(row_id, price_index).cell.wasChanged = true;
                }
            }
            return true;
        });
    }

    /**
     * [exercise_menu_click Menu clicked function for exercise grid.]
     */
    dealDetail.exercise_menu_click = function(id) {
        var row_id = dealDetail.deal_exercise.getSelectedRowId();
        if (row_id == null) {
            dhtmlx.alert({
                title:"Error",
                type:"alert-error",
                text:"Please select some row(s)."
            });
            return;
        }
        var deal_ids = dealDetail.deal_exercise.cells(row_id, 0).getValue();
        deal_ids = deal_ids.replace(/(<([^>]+)>)/ig,"");


        data = {"action": "spa_source_deal_header", "flag":"d", "deal_ids":deal_ids};
        adiha_post_data("alert", data, '', '', 'dealDetail.exercise_delete_callback');
    }

    /**
     * [exercise_delete_callback Exercise deal delete callback.]
     */
    dealDetail.exercise_delete_callback = function(return_value) {
        if (return_value[0].errorcode == 'Success') {
            dealDetail.deal_exercise.deleteSelectedRows();
        }
    }

    dealDetail.update_actual_clicked = function() {
        var deal_id = '<?php echo $deal_id; ?>';
        var data = {
            "action":"spa_source_deal_header",
            "flag":'f',
            "deal_ids":deal_id
        }
        adiha_post_data("return", data, '', '', 'dealDetail.open_update_actual');
    }

    var update_actual_window;
    /**
     * [open_update_actual Open Update Actual Volume UI.]
     */
    dealDetail.open_update_actual = function() {
        var actualization_flag = '<?php echo $actualization_flag; ?>';

        var tab_obj = dealDetail.deal_tab;
        var granularity = '';
        var volume_type = '' ;

        tab_obj.forEachTab(function(tab) {
            var form_object = tab.getAttachedObject();
            if (form_object instanceof dhtmlXForm)
                var data = form_object.getFormData();

            for (var a in data) {
                var field_label = a;

                if (field_label == 'profile_granularity') {
                    granularity = data[field_label];
                }

                if (field_label == 'internal_desk_id') {
                    volume_type = data[field_label];
                }
            }
        });

        if (volume_type != 17302) {
            granularity = null;
        }

        if (update_actual_window != null && update_actual_window.unload != null) {
            update_actual_window.unload();
            update_actual_window = w1 = null;
        }

        if (!update_actual_window) {
            update_actual_window = new dhtmlXWindows();
        }

        if (actualization_flag == 's' || is_shaped == 'y' || (volume_type == 17300 && profile_gran_with_meter == 'n')) {
            var win_url = 'update.actual.php';
        } else if (actualization_flag == 'm' || volume_type == 17301 || profile_gran_with_meter == 'y') {
            var win_url = 'update.actual.meter.php';
        }

        var deal_id = '<?php echo $deal_id; ?>';
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var term_start_index = dealDetail.grid.getColIndexById('term_start');
        var term_end_index = dealDetail.grid.getColIndexById('term_end');
        var meter_index = dealDetail.grid.getColIndexById('meter_id');
        var location_index = dealDetail.grid.getColIndexById('location_id');
        var schedule_volume_index = dealDetail.grid.getColIndexById('schedule_volume');

        var row_id = dealDetail.grid.getSelectedRowId();
        var term_start = dealDetail.grid.cells(row_id, term_start_index).getValue();
        var term_end = dealDetail.grid.cells(row_id, term_end_index).getValue();
        var detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
        var meter_id = (meter_index) ? dealDetail.grid.cells(row_id, meter_index).getValue() : 'NULL';
        var location_id = (location_index) ? dealDetail.grid.cells(row_id, location_index).getValue() : 'NULL';
        var formatted_term_start = dates.convert_to_user_format(term_start);
        var formatted_term_end = dates.convert_to_user_format(term_end);
        var win_title = 'Update Actual Volume (Deal: ' + deal_id + ', Term: ' + formatted_term_start + ' - ' + formatted_term_end + ')';

        var is_new = 'n';

        if (copy_deal_id != 'NULL' || template_id != 'NULL' || detail_id.indexOf('New') == 0 || detail_id.indexOf('NEW') == 0) {
            is_new = 'y';
            var leg_index = dealDetail.grid.getColIndexById('blotterleg');
            leg = dealDetail.grid.cells(row_id, leg_index).getValue();
            if (typeof volume_index != 'undefined')
                volume = dealDetail.grid.cells(row_id, volume_index).getValue();
            if (typeof price_index != 'undefined')
                price = dealDetail.grid.cells(row_id, price_index).getValue();
        }

        detail_id = (detail_id.match(/NEW.*/)) ? 'NULL' : detail_id;
        var win = update_actual_window.createWindow('w1', 0, 0, 500, 500);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {deal_id:deal_id,detail_id:detail_id,term_start:term_start,term_end:term_end,granularity:granularity,meter_id:meter_id,call_from:'deal_detail',location_id:location_id});

        win.attachEvent('onClose', function(w) {
            if (is_new == 'n') {
                var data = dealDetail.get_refresh_param();

                dealDetail.refresh_grid(data, function() {
                    dealDetail.grid.selectRowById(row_id);
                });
            } else {
                var ifr = w.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                var vol = $('textarea[name="txt_vol"]', ifrDocument).val();
                var price = $('textarea[name="txt_price"]', ifrDocument).val();
                shaped_created = 'y';

                if (is_new == 'y' && process_id == 'NULL') {
                    process_id = $('textarea[name="txt_process"]', ifrDocument).val();
                }

                if (typeof volume_index != 'undefined') {
                    dealDetail.grid.cells(row_id, volume_index).setValue(vol);
                    dealDetail.grid.cells(row_id, volume_index).cell.wasChanged = true;
                }

                if (typeof price_index != 'undefined') {
                    dealDetail.grid.cells(row_id, price_index).setValue(price);
                    dealDetail.grid.cells(row_id, price_index).cell.wasChanged = true;
                }
            }
            return true;
        });
    }

    setup_generation_hyperlink = function(name, value) {
        if (name == "setup_generation") return "<div class='simple_link'><a href='#' onclick='open_setup_generation()'>"+value+"</a></div>";
    }

    collateral_hyperlink = function(name, value) {
        if (name == "collateral_link") return "<div class='simple_link'><a href='#' onclick='open_setup_collateral()'>"+value+"</a></div>";
    }

    var setup_collateral;
    open_setup_collateral = function() {
        var source_deal_header_id = '<?php echo $deal_id; ?>';
        var counterparty_id = '';

        var tab_obj = dealDetail.deal_tab;
        var iterate_check = true;
        tab_obj.forEachTab(function(tab) {
            if(iterate_check) {
                var form_obj = tab.getAttachedObject();
                if (form_obj instanceof dhtmlXForm) {
                    var cpty_combo = form_obj.getCombo('counterparty_id');
                    if (cpty_combo) {
                        counterparty_id = form_obj.getItemValue('counterparty_id');
                        iterate_check = false;
                    }
                }
            }
        });

        if (counterparty_id == '' || counterparty_id == null) {
            dhtmlx.message({
                title:'Alert',
                type:"alert",
                text:"Please select counterparty!"
            });
            return;
        }

        if (setup_collateral != null && setup_collateral.unload != null) {
            setup_collateral.unload();
            setup_collateral = w1 = null;
        }

        if (!setup_collateral) {
            setup_collateral = new dhtmlXWindows();
        }
        setup_collateral_win = setup_collateral.createWindow('w1', 0, 0, 900, 700);
        setup_collateral_win.setText("Counterparty Credit Info");
        setup_collateral_win.centerOnScreen();
        setup_collateral_win.setModal(true);
        setup_collateral_win.maximize();

        var page_url = js_php_path + '../adiha.html.forms/_credit_risks_analysis/counterparty_credit_info/counterparty.credit.info.php?counterparty_id=' + counterparty_id + '&source_deal_header_id=' + source_deal_header_id + '&hide_tab=1&open_enhancement=1';
        setup_collateral_win.attachURL(page_url, false, null);
    }

    open_setup_generation = function() {
        var source_deal_header_id = '<?php echo $deal_id; ?>';
        var setup_generation = new dhtmlXWindows();
        setup_generation_win = setup_generation.createWindow('w1', 0, 0, 900, 700);
        setup_generation_win.setText("Setup Generation");
        setup_generation_win.centerOnScreen();
        setup_generation_win.setModal(true);
        setup_generation_win.maximize();

        var page_url = js_php_path + '../adiha.html.forms/_deal_capture/maintain_deals/setup.generation.php?source_deal_header_id=' + source_deal_header_id;
        setup_generation_win.attachURL(page_url, false, null);
    }
    /**
     * [update_detail_lock_status Lock/Unlock deal detail]
     * @param  {[type]} status [Lock Status - y/n]
     */
    dealDetail.update_detail_lock_status = function(status) {
        var row_id = dealDetail.grid.getSelectedRowId();
        var source_deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var source_deal_detail_id = dealDetail.grid.cells(row_id, source_deal_detail_index).getValue();

        var status_name = (status == 'y') ? 'lock' : 'unlock';
        dhtmlx.message({
            title:"Confirmation",
            type:"confirm",
            ok: "Confirm",
            text: "Are you sure you want to " + status_name + " selected detail?",
            callback: function(result) {
                if (result) {
                    data = {"action": "spa_deal_update_new", "flag":"lock_unlock", "detail_lock_status":status, "detail_id":source_deal_detail_id};
                    adiha_post_data("alert", data, '', '', 'dealDetail.update_detail_lock_status_callback');
                }
            }
        });
    }

    /**
     * [update_detail_lock_status_callback Lock/Unlock deal detail callback]
     */
    dealDetail.update_detail_lock_status_callback = function(result) {
        var row_id = dealDetail.grid.getSelectedRowId();
        var lock_deal_detail_index = dealDetail.grid.getColIndexById('lock_deal_detail');

        if (result[0].errorcode == 'Success') {
            var status = result[0].recommendation;
            dealDetail.grid.cells(row_id, lock_deal_detail_index).setValue(status);

            if (status == 'y') {
                dealDetail.grid.lockRow(row_id,true);
                dealDetail.grid.setRowColor(row_id,"lightgrey");
            } else {
                dealDetail.grid.lockRow(row_id,false);
                dealDetail.grid.setRowColor(row_id,"white");
            }
        }
    }


    /**
     * [header_cost_select Header Cost before select event]
     * @param  {[type]} new_row  [New Row ID]
     * @param  {[type]} old_row  [Old Row ID]
     * @param  {[type]} new_col_index   [Selected Column Index]
     */
    dealDetail.header_cost_select = function(new_row,old_row,new_col_index) {
        var internal_type_column_index = dealDetail.header_deal_costs.getColIndexById('internal_field_type');
        var uom_index = dealDetail.header_deal_costs.getColIndexById('uom_id');
        var type_name = dealDetail.header_deal_costs.cells(new_row, internal_type_column_index).getText();

        var charge_type_index = dealDetail.header_deal_costs.getColIndexById('internal_field_type');

        if (charge_type_index)
            dealDetail.header_deal_costs.cells(new_row, charge_type_index).setDisabled(true);

        if (type_name.match("^Lump Sum")) {
            dealDetail.header_deal_costs.cells(new_row, uom_index).setDisabled(true);
        }

        var udf_field_type_index = dealDetail.header_deal_costs.getColIndexById('udf_field_type');
        var udf_type = dealDetail.header_deal_costs.cells(new_row, udf_field_type_index).getValue();
        var udf_value_index = dealDetail.header_deal_costs.getColIndexById('udf_value');

        if (udf_type == 'w') {
            var formula_id = dealDetail.header_deal_costs.cells(new_row, udf_value_index).getValue();

            var data = {'udf_value' : 'formula_form->0'};
            dealDetail.header_deal_costs.attachBrowser(data);
        }

        return true;
    }

    /**
     * [header_cost_onload Header Cost grid on load event]
     */
    dealDetail.header_cost_onload = function() {
        var contract_index = dealDetail.header_deal_costs.getColIndexById('contract_id');
        var counterparty_index = dealDetail.header_deal_costs.getColIndexById('counterparty_id');
        var udf_field_type_index = dealDetail.header_deal_costs.getColIndexById('udf_field_type');
        var udf_value_index = dealDetail.header_deal_costs.getColIndexById('udf_value');

        dealDetail.header_deal_costs.forEachRow(function(id) {
            var counterparty_id = dealDetail.header_deal_costs.cells(id, counterparty_index).getValue();
            var contract_id = dealDetail.header_deal_costs.cells(id, contract_index).getValue();
            var udf_type = dealDetail.header_deal_costs.cells(id, udf_field_type_index).getValue();

            if (udf_type == 'w') {
                dealDetail.header_deal_costs.setCellExcellType(id,udf_value_index,'browser');
            }

            if (contract_id != '' && contract_id != null && typeof contract_id != 'undefined' && counterparty_id != '' && counterparty_id != null && typeof counterparty_id != 'undefined') {
                var header_cost_contract_combo = dealDetail.header_deal_costs.cells(id, contract_index).getCellCombo();
                header_cost_contract_combo.enableFilteringMode(true);
                header_cost_contract_combo.clearAll();
                var cm_param = {"action": "spa_contract_group", "flag": "r", "counterparty_id": counterparty_id, "SELECTED_VALUE":contract_id};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                header_cost_contract_combo.load(url);
            }
        });
    }

    /**
     * [header_cost_edit Header cost grid cell on edit function]
     * @param  {[type]} stage  [stage of edit 0 - edit open, 1 - on edit, 2 - on edit close]
     * @param  {[type]} rId    [row_id]
     * @param  {[type]} cInd   [column index]
     * @param  {[type]} nValue [new value]
     * @param  {[type]} oValue [old value]
     */
    dealDetail.header_cost_edit = function(stage, rId, cInd, nValue, oValue) {
        if (stage == 2) {
            var counterparty_index = dealDetail.header_deal_costs.getColIndexById('counterparty_id');

            if (counterparty_index == cInd && nValue != oValue) {
                var contract_index = dealDetail.header_deal_costs.getColIndexById('contract_id');

                var header_cost_contract_combo = dealDetail.header_deal_costs.cells(rId, contract_index).getCellCombo();
                dealDetail.header_deal_costs.cells(rId, contract_index).setValue('');
                header_cost_contract_combo.setComboValue('');
                header_cost_contract_combo.setComboText('');
                header_cost_contract_combo.enableFilteringMode(true);
                header_cost_contract_combo.clearAll();

                nValue = (nValue == '' || nValue == null || typeof nValue == 'undefined') ? 'NULL' : nValue;
                if (nValue != '' && nValue != null && typeof nValue != 'undefined') {
                    var cm_param = {"action": "spa_contract_group", "flag": "r", "counterparty_id": nValue};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    header_cost_contract_combo.load(url);
                }
            }
        }

        return true;
    }

    /**
     * [detail_cost_select Detail Cost before select event]
     * @param  {[type]} new_row  [New Row ID]
     * @param  {[type]} old_row  [Old Row ID]
     * @param  {[type]} new_col_index   [Selected Column Index]
     */
    dealDetail.detail_cost_select = function(new_row,old_row,new_col_index) {
        var internal_type_column_index = dealDetail.deal_detail_cost.getColIndexById('internal_field_type');
        var uom_index = dealDetail.deal_detail_cost.getColIndexById('uom_id');
        var type_name = dealDetail.deal_detail_cost.cells(new_row, internal_type_column_index).getValue();

        if (type_name.match("^Lump Sum")) {
            dealDetail.deal_detail_cost.cells(new_row, uom_index).setDisabled(true);
        }
        return true;
    }



    /**
     * [detail_cost_onload Detail Cost grid on load event]
     */
    dealDetail.detail_cost_onload = function() {
        var contract_index = dealDetail.deal_detail_cost.getColIndexById('contract_id');
        var counterparty_index = dealDetail.deal_detail_cost.getColIndexById('counterparty_id');

        dealDetail.deal_detail_cost.forEachRow(function(id) {
            var counterparty_id = dealDetail.deal_detail_cost.cells(id, counterparty_index).getValue();
            var contract_id = dealDetail.deal_detail_cost.cells(id, contract_index).getValue();

            if (contract_id != '' && contract_id != null && typeof contract_id != 'undefined' && counterparty_id != '' && counterparty_id != null && typeof counterparty_id != 'undefined') {
                var detail_cost_contract_combo = dealDetail.deal_detail_cost.cells(id, contract_index).getCellCombo();
                detail_cost_contract_combo.enableFilteringMode(true);
                detail_cost_contract_combo.clearAll();
                var cm_param = {"action": "spa_contract_group", "flag": "r", "counterparty_id": counterparty_id, "SELECTED_VALUE":contract_id};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                detail_cost_contract_combo.load(url);
            }
        });
    }

    /**
     * [detail_cost_edit Detail cost grid cell on edit function]
     * @param  {[type]} stage  [stage of edit 0 - edit open, 1 - on edit, 2 - on edit close]
     * @param  {[type]} rId    [row_id]
     * @param  {[type]} cInd   [column index]
     * @param  {[type]} nValue [new value]
     * @param  {[type]} oValue [old value]
     */
    dealDetail.detail_cost_edit = function(stage, rId, cInd, nValue, oValue) {
        if (stage == 2) {
            var counterparty_index = dealDetail.deal_detail_cost.getColIndexById('counterparty_id');

            if (counterparty_index == cInd && nValue != oValue) {
                var contract_index = dealDetail.deal_detail_cost.getColIndexById('contract_id');

                var detail_cost_contract_combo = dealDetail.deal_detail_cost.cells(rId, contract_index).getCellCombo();
                dealDetail.deal_detail_cost.cells(rId, contract_index).setValue('');
                detail_cost_contract_combo.setComboValue('');
                detail_cost_contract_combo.setComboText('');
                detail_cost_contract_combo.enableFilteringMode(true);
                detail_cost_contract_combo.clearAll();
                nValue = (nValue == '' || nValue == null || typeof nValue == 'undefined') ? 'NULL' : nValue;
                if (nValue != '' && nValue != null && typeof nValue != 'undefined') {
                    var cm_param = {"action": "spa_contract_group", "flag": "r", "counterparty_id": nValue};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    detail_cost_contract_combo.load(url);
                }
            }
        }

        return true;
    }

    /**
     * [open_report Open Report]
     * @param  {[type]} report_type [Report type]
     */
    dealDetail.open_report = function(report_type) {
        var deal_id = '<?php echo $deal_id;?>'

        if (report_type == 'view_certificate') {            
            data = {
                "action": 'spa_call_report_manager_report',
                "flag": 'scheduling_report',
                "report_name": 'REC Deal Detail Certificate',
                "deal_id": deal_id
            };

        } else if (report_type == 'shipper_code_report') {            
            data = {
                "action": 'spa_call_report_manager_report',
                "flag": 'scheduling_report',
                "report_name": 'Shipper Code Report',
                "deal_id": deal_id
            };

        }
        
        adiha_post_data('return_json', data, '', '', 'dealDetail.deal_detail_report_callback', '');
        
    }

    dealDetail.deal_detail_report_callback = function(result) {
        var deal_id = '<?php echo $deal_id;?>'
        var row_id = dealDetail.grid.getSelectedRowId();
        var deal_detail_index = dealDetail.grid.getColIndexById('source_deal_detail_id');
        var deal_detail_id = dealDetail.grid.cells(row_id, deal_detail_index).getValue();
        var result = JSON.parse(result);
        var paramset_id = result[0]['paramset_id'];
        var items_combined = result[0]['items_combined'];
        var process_id = result[0]['process_id'];
        var report_name = result[0]['report_name'];
        var url = '../../_reporting/report_manager_dhx/report.viewer.php?report_name=' + encodeURI(report_name) + '_'+ encodeURI(report_name) + '&is_refresh=1&items_combined=' + items_combined + '&paramset_id=' + paramset_id + '&export_type=HTML4.0'

        dhxWins = new dhtmlXWindows();
        var is_win = dhxWins.isWindow('w2');
        if (is_win == true) {
            w2.close();
        }
        w2 = dhxWins.createWindow("w3", 100, 0, 1100, 500);
        w2.setText(report_name);
        w2.setModal(true);
        w2.maximize();

        if (report_name == 'REC Deal Detail Certificate') {
            var param = {
                'sec_filters_info': 'buy_detail_id='+ deal_detail_id +'_-_' + process_id + ''
            }
        } else if (report_name == 'Shipper Code Report') {
            var tab_obj = dealDetail.deal_tab ;   
            var term_start, location_id = '', contract_id = '';
            tab_obj.forEachTab(function(tab) {
                var form_obj = tab.getAttachedObject();
                
                if (form_obj instanceof dhtmlXForm) {
                    var counterparty_combo = form_obj.getCombo('counterparty_id');
                    if (counterparty_combo) {
                        counterparty_id = form_obj.getItemValue('counterparty_id');
                    }

                    var contract_combo = form_obj.getCombo('contract_id');
                    if (contract_combo) {
                        contract_id = form_obj.getItemValue('contract_id');
                    }   
                }
                            
            });   

            var location_id_index = dealDetail.grid.getColIndexById('location_id'); 
            
            if (typeof location_id_index != 'undefined') var location_id = dealDetail.grid.cells(row_id, location_id_index).getValue();       

            var term_start_index = dealDetail.grid.getColIndexById('term_start');            
            if (typeof term_start_index != 'undefined') var term_start = dealDetail.grid.cells(row_id, term_start_index).getValue();
            
            var term_end_index = dealDetail.grid.getColIndexById('term_end');
            if (typeof term_end_index != 'undefined') var term_end = dealDetail.grid.cells(row_id, term_end_index).getValue();

            var param = {                
                'sec_filters_info': 'deal_header_id=' + deal_id + ',contract_id=' + contract_id + ',counterparty_id=' + counterparty_id + ',location_id=' + location_id + ',term_start=' + term_start + ',term_end=' + term_end + ',deal_detail_id=' + deal_detail_id + ',external_id=NULL_-_' + process_id
            }
        }
        w2.attachURL(url, false, param);

        w2.attachEvent("onClose", function(win) {
            return true;
        });
    }
    /**
     * [Enable/Disable Ok button on grid rows select/unselect]
     */
    dealDetail.on_row_select = function() {
        var deal_id = '<?php echo $deal_id; ?>';
        
        if (deal_id != 'NULL') {
            var buy_sell = '<?php echo $buy_sell; ?>';
            var is_environmental = '<?php echo $is_environmental;?>';
            var row_id = dealDetail.grid.getSelectedRowId();

            if (dealDetail.grid.getColIndexById('buy_sell_flag')) {
                var buy_sell_col_id = dealDetail.grid.getColIndexById('buy_sell_flag');
                var buy_detail_flag = dealDetail.grid.cells(row_id, buy_sell_col_id).getValue();
            } else {
                var buy_detail_flag = '';
            }

            if (row_id) {
                if (buy_detail_flag == 'b' && is_environmental == 'y') {
                    dealDetail.deal_detail_menu.setItemEnabled('view_certificate');
                } else if (buy_detail_flag == 's') {
                    dealDetail.deal_detail_menu.setItemDisabled('view_certificate');
                } else if (buy_sell == 'Buy' && is_environmental == 'y') {
                    dealDetail.deal_detail_menu.setItemEnabled('view_certificate');
                } else {
                    dealDetail.deal_detail_menu.setItemDisabled('view_certificate');
                }
                
                if (dealDetail.grid.getColIndexById('shipper_code1') || dealDetail.grid.getColIndexById('shipper_code2')) {
                    dealDetail.deal_detail_menu.setItemEnabled('shipper_code_report');
                } else {
                    dealDetail.deal_detail_menu.setItemDisabled('shipper_code_report');
                }
            } else {
                dealDetail.deal_detail_menu.setItemDisabled('view_certificate');
                dealDetail.deal_detail_menu.setItemDisabled('shipper_code_report');
            }
        }
    }

    dealDetail.add_missing_column = function() {
        var required_columns = [{id: "term_start", text: "Term Start", type: "dhxCalendarA"},
                                {id: "term_end", text: "Term End", type: "dhxCalendarA"}
                                ];
        var term_frequency = '<?php echo $term_frequency;?>';
        for (var i=0; i < required_columns.length; i++) {
            var column_id = required_columns[i].id;
            if (dealDetail.grid.getColIndexById(column_id)) //Return when column already present in grid
                continue;
            var new_col_index = dealDetail.grid.getColumnsNum();
            dealDetail.grid.insertColumn(new_col_index, required_columns[i].text, required_columns[i].type);
            dealDetail.grid.setColumnId(new_col_index,column_id);
            dealDetail.grid.setColumnHidden(new_col_index,true);
            switch(column_id) {
                case 'term_start':
                    var term_start = null;
                    var term_start_obj = null;
                    dealDetail.grid.forEachRow(function(id) {
                        if (dealDetail.grid.getColIndexById('vintage')) {
                            var col_vintage = dealDetail.grid.getColIndexById('vintage');
                            var vintage = dealDetail.grid.cells(id,col_vintage).getTitle();
                            if (!vintage.trim() || vintage == undefined || vintage == '') {
                                vintage = new Date().getFullYear();
                            }
                            term_start = vintage + '-01-01';
                            term_start_obj = dates.convert(term_start);
                        } else {
                            term_start = new Date().getFullYear() + '-01-01';
                            term_start_obj = dates.convert(term_start);
                        }

                        dealDetail.grid.cells(id,new_col_index).setValue(term_start_obj);
                    });
                    break;
                case 'term_end':
                    var col_term_start = dealDetail.grid.getColIndexById('term_start');
                    var term_end = null;
                    var term_end_obj = null;
                    var term_start = null;
                    var term_start_obj = null;
                    dealDetail.grid.forEachRow(function(id) {
                        if (dealDetail.grid.getColIndexById('vintage')) {
                            var col_vintage = dealDetail.grid.getColIndexById('vintage');
                            var vintage = dealDetail.grid.cells(id,col_vintage).getTitle();
                            if (!vintage.trim() || vintage == undefined || vintage == '') {
                                vintage = new Date().getFullYear();
                            }
                            term_end = vintage + '-12-31';
                            term_end_obj = dates.convert(term_end);
                        } else {
                            term_start = dealDetail.grid.cells(id,col_term_start).getValue();
                            term_end_obj = dates.convert(dates.getTermEnd(term_start, term_frequency));
                        }

                        dealDetail.grid.cells(id,new_col_index).setValue(term_end_obj);
                    });
                    break;
            }
        }

    }
	
    /**
     * Opens UDT window to show the avialable deal UDT's
     * 
     * @param {String} header_detail If opened from header or detail
     */
    dealDetail.open_udt = function(header_detail) {
        dealDetail.unload_udt_window();
        if (!udt_window) {
            udt_window = new dhtmlXWindows();
        }

        var term_start = '';
        var leg = '';
        if (header_detail == 'd') {
            var selected_row_id = dealDetail.grid.getSelectedRowId();
            term_start = dealDetail.grid.cells(selected_row_id, dealDetail.grid.getColIndexById('term_start')).getValue();
            leg = dealDetail.grid.cells(selected_row_id, dealDetail.grid.getColIndexById('Leg')).getValue();
        }

        var data = {
            source_deal_header_id: deal_id,
            deal_reference_id: deal_reference_id,
            header_detail: header_detail,
            term_start: term_start,
            leg: leg
        };

        var win_title = "UDT - " + (header_detail == 'h' ? ' Header' : 'Detail');
        var win = udt_window.createWindow('w1', 0, 0, 540, 410);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL("deal.udt.php", false, data);
    }
    
    var udt_window;
    /**
     * Unloads the UDT window if exists
     */
    dealDetail.unload_udt_window = function() {
        if (udt_window != null && udt_window.unload != null) {
            udt_window.unload();
            udt_window = w1 = null;
        }
    }

    dealDetail.header_udt_select = function(id, ind) {
        var active_tab_id = dealDetail.deal_tab.getActiveTab();
        var tab_attached_menu_obj = dealDetail.deal_tab.tabs(active_tab_id).getAttachedMenu();
        tab_attached_menu_obj.setItemEnabled('delete');
    }

    dealDetail.udt_menu_click = function(name) {
        var active_tab_id = dealDetail.deal_tab.getActiveTab();
        var tab_attached_grid_obj = dealDetail.deal_tab.tabs(active_tab_id).getAttachedObject();

        switch(name) {
            case "add":
                var row_id = (new Date()).valueOf();
                tab_attached_grid_obj.addRow(row_id, "");
                tab_attached_grid_obj.selectRowById(row_id);
                this.setItemEnabled('delete');
                
                tab_attached_grid_obj.forEachRow(function(row) {
                    tab_attached_grid_obj.forEachCell(row, function(cellObj, ind) {
                        tab_attached_grid_obj.validateCell(row, ind);
                    });
                });
                break;
            case "delete":
                var row_id = tab_attached_grid_obj.getSelectedRowId();
                var previously_deleted_xml = tab_attached_grid_obj.getUserData("", "deleted_xml");          
                var grid_xml = "";
                if (previously_deleted_xml != null) {
                    grid_xml += previously_deleted_xml;
                }
                var del_array = new Array();
                del_array = (row_id.indexOf(",") != -1) ? row_id.split(",") : row_id.split();
                $.each(del_array, function(index, value) {
                    if ((tab_attached_grid_obj.cells(value, 0).getValue() != "")) {
                        grid_xml += "<GridRow ";
                        for (var cellIndex = 0; cellIndex < tab_attached_grid_obj.getColumnsNum(); cellIndex++) {
                            grid_xml += " " + tab_attached_grid_obj.getColumnId(cellIndex) + '="' + tab_attached_grid_obj.cells(value,cellIndex).getValue() + '"';
                        }
                        grid_xml += " ></GridRow> ";
                    }
                });
                tab_attached_grid_obj.setUserData("", "deleted_xml", grid_xml);

                tab_attached_grid_obj.deleteRow(row_id);
                this.setItemDisabled('delete');
                break;
            default:
                break;
        }
    }
</script>
</html>