<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php');
    $php_script_loc = $app_php_script_loc;
    //$flow_optimization_theme_css = $php_script_loc . '/components/lib/adiha_dhtmlx/themes/dhtmlx_' . $theme. '/flow_optimization.css';
	  $flow_optimization_theme_css = $php_script_loc . '/components/lib/adiha_dhtmlx/flow_optimization.css';
    ?>
    <link type="text/css" rel="stylesheet" href="<?php echo $flow_optimization_theme_css; ?>"/>
</head>
<body>
<?php
//print_r($_GET);

$app_user_loc = $app_user_name;

$flow_start = isset($_GET['flow_start']) ? $_GET['flow_start'] : '';
$flow_end = isset($_GET['flow_end']) ? $_GET['flow_end'] : '';
$receipt_loc = isset($_GET['receipt_loc']) ? $_GET['receipt_loc'] : '';
$delivery_loc = isset($_GET['delivery_loc']) ? $_GET['delivery_loc'] : '';
$receipt_loc_id = isset($_GET['receipt_loc_id']) ? $_GET['receipt_loc_id'] : '';
$delivery_loc_id = isset($_GET['delivery_loc_id']) ? $_GET['delivery_loc_id'] : '';
$match_uom = isset($_GET['uom']) ? $_GET['uom'] : '';
$total_receipt_vol = isset($_GET['total_receipt_vol']) ? $_GET['total_receipt_vol'] : '';
$total_delivery_vol = isset($_GET['total_delivery_vol']) ? $_GET['total_delivery_vol'] : '';
$process_id = isset($_GET['process_id']) ? $_GET['process_id'] : '';
$receipt_deals = isset($_GET['receipt_deals']) ? $_GET['receipt_deals'] : '';
$delivery_deals = isset($_GET['delivery_deals']) ? $_GET['delivery_deals'] : '';
$avail_vol = isset($_GET['avail_vol']) ? $_GET['avail_vol'] : '';
$min_rec_or_del_vol = isset($_GET['min_rec_or_del_vol']) ? $_GET['min_rec_or_del_vol'] : '';
$storage_loc_id = isset($_GET['storage_loc_id']) ? $_GET['storage_loc_id'] : '';
$storage_type = isset($_GET['storage_type']) ? $_GET['storage_type'] : '';
$pool_loc_id = isset($_GET['pool_loc_id']) ? $_GET['pool_loc_id'] : '';
$pool_type = isset($_GET['pool_type']) ? $_GET['pool_type'] : '';
$from_loc_name = isset($_GET['from_loc_name']) ? $_GET['from_loc_name'] : '';
$to_loc_name = isset($_GET['to_loc_name']) ? $_GET['to_loc_name'] : '';
$toggle = isset($_GET['toggle']) ? $_GET['toggle'] : '';
$contract_id = (isset($_GET['contract_id']) && $_GET['contract_id'] != '') ? $_GET['contract_id'] : '';
$sub = isset($_GET['subsidiary_id']) ? $_GET['subsidiary_id'] : '';
$str = isset($_GET['strategy_id']) ? $_GET['strategy_id'] : '';
$book = isset($_GET['book_id']) ? $_GET['book_id'] : '';
$process_id_new = $process_id.'_storage_pool';
$sub_book_id = (isset($_GET['sub_book_id']) && $_GET['sub_book_id'] != '') ? $_GET['sub_book_id'] : '';
$process_id_new_toggle = $process_id.'_pool_storage';
$reschedule = isset($_GET['reschedule']) ? $_GET['reschedule'] : '0';
$call_from = isset($_GET['call_from']) ? $_GET['call_from'] : '0';

$form_function_id = 10163611;
$form_namespace = 'flow_match_single';
$form_name = 'match_single';
$layout_name = 'single_match_layout';
$layout_obj = new AdihaLayout();
$layout_json = '[
                        {id: "a", text: "Match", header: false, height: 200}
                    ]';
echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $form_namespace);
echo $layout_obj->close_layout();

$dest_sub_book_url = "EXEC spa_flow_optimization @flag='d'";
$result_sub_book = readXMLURL2($dest_sub_book_url);
$json_sub_book = json_encode($result_sub_book);
$location = "$receipt_loc_id,$delivery_loc_id";
$xml_file = "EXEC spa_flow_optimization @flag='c',@flow_date_from='$flow_start',@flow_date_to='$flow_end',@from_location='$receipt_loc_id',@to_location='$delivery_loc_id',@process_id='$process_id_new',@pipeline_ids=NULL,@contract_id='$contract_id',@uom='$match_uom',@sub='$sub',@str='$str',@book='$book',@sub_book_id='$sub_book_id',@receipt_deals_id='$receipt_deals',@delivery_deals_id='$delivery_deals',@reschedule='$reschedule'";
$return_solver_data = readXMLURL2($xml_file);
$path_exists_toggle = '';
$box_id[0] = '';
$box_id[1] = '';
$json_solver_data[0] = '';
$json_solver_data[1] = '';
foreach ($return_solver_data as $key=>$value) {
    if ($value['from_loc_id'] == $receipt_loc_id && $value['to_loc_id'] == $delivery_loc_id) {
        $json_solver_data[0] = "[".json_encode($value)."]";
        $box_id[0] = $value['box_id'];
    } else if ($value['from_loc_id'] == $delivery_loc_id && $value['to_loc_id'] == $receipt_loc_id) {
        $json_solver_data[1] = "[".json_encode($value)."]";
        $box_id[1] = $value['box_id'];
        $path_exists_toggle = $value['path_exists'];
    }
}
//var_dump($form_name);
?>
<div id="main_div" style="display: none; position: relative;">
    <div class="first_frame_div">
        <table class="frame_tbl" border=0>
            <tbody>
            <tr class="frame_tbl_tr">
                <td class= "blank_td_outer"></td>
                <td class= "blank_td_outer"></td>
                <td class= "blank_td_outer"></td>
                <td class= "blank_td_outer"></td>
                <td class= "demand_td" colspan="1">Demand Position</td>
            </tr>
            <tr>
                <td class= "blank_td_outer"></td>
                <td class="blank_td_inner"></td>
                <td class="blank_td_inner"></td>
                <td class="blank_td_inner"></td>
                <td>Total</td>
            </tr>
            <tr>
                <td class= "blank_td_outer"></td>
                <td class="blank_td_inner"></td>
                <td class="blank_td_inner"></td>
                <td class="blank_td_inner"></td>
                <td>Beg</td>
            </tr>
            <tr>
                <td class= "blank_td_outer"></td>
                <td class="blank_td_inner"></td>
                <td class="blank_td_inner"></td>
                <td class="blank_td_inner"></td>
                <td>End</td>
            </tr>
            <tr>
                <td class= "supply_td" rowspan="1">Supply<br />Position<br /></td>
                <td>Total</td>
                <td>Beg</td>
                <td>End</td>
                <td style="text-align: left; padding-top: 1px; vertical-align: top;">
                    <input type="checkbox" class="chk_all" onclick="chk_all_onchange(this)" />
                </td>
            </tr>
            </tbody>
        </table>
    </div>

    <div id="sample_div" style="display:none;">
        <div id="div_clone1">
            <div class="box_div"
                 box_type=""
                 route_id=""
                 from_loc_id=""
                 from_loc=""
                 from_loc_grp=""
                 to_loc_id=""
                 to_loc=""
                 to_loc_grp=""
                 total_pmdq=""
                 total_prmdq=""
                 total_irmdq=""
                 from_pos_beg=""
                 from_pos_end=""
                 to_pos_beg=""
                 to_pos_end=""
                 path_ids=""
                 solver_result_rec="0"
                 solver_result_del="0"
            >
                <span class="from_loc_id" style="display: none;"></span>
                <span class="from_loc" style="display: none;"></span>
                <span class="to_loc_id" style="display: none;"></span>
                <span class="to_loc" style="display: none;"></span>
                <span class="route_id" style="display: none;"></span>
                <span class="path_exists" style="display: none;"></span>
                <span class="path_id" style="display: none;"></span>
                <span class="path_name" style="display: none;"></span>
                <span class="contract_id" style="display: none;"></span>
                <span class="contract_name" style="display: none;"></span>
                <span class="original_rmdq" style="display: none;"></span>
                <span class="process_id" style="display: none;"></span>
                <span class="from_loc_grp_id" style="display: none;"></span>
                <span class="from_loc_grp_name" style="display: none;"></span>
                <span class="to_loc_grp_id" style="display: none;"></span>
                <span class="to_loc_grp_name" style="display: none;"></span>
                <span class="storage_deal_info" storage_checked="1" storage_deal_type="n" storage_asset_id="0" storage_volume="0" style="display: none;"></span>
                <ul class="edited_info" edited_by="none" style="display: none;">
                </ul>
                <div class="top_div inner_div">
                    <div class="chk_cell" ><input type="checkbox" /></div>
                    <div class="link_cell"><span class="del_path_link" onclick="fx_path_list_popup(this)">PMDQ</span>
                        <span class="mdq_info">(<span class="mdq_info1"></span>/<span class="mdq_info2"></span>)</span>
                    </div>
                </div>
                <div class="path_insert" onclick="fx_open_delivery_path_window(this, 'i')">+</div>
                <div class="center_div inner_div" onclick="popup_modal_box(this)">
                    <div class="rec_del_div mdq_div">
                        <span class="rd_mdq_info">Rec/Del:(<span class="rec_del_div1" value="0">0</span>/<span class="rec_del_div2" value="0">0</span>)</span>

                    </div>
                </div>
                <div class=" center_div match" onclick="open_match(this)">M</div>

                <div class="bottom_div inner_div" style="display: none;">bottom</div>

            </div>


        </div>
    </div>
    <div id="path_list_div" class="popup_multipath" style="display: none;">
        <ul class="path_list_ul">
            <li>path1</li>
            <li>path2</li>
        </ul>
    </div>
</div>
</body>

<script>
   
    var json_solver_data =  '<?php echo $json_solver_data[0]; ?>';
    var process_id_gbl = '<?php echo $process_id_new; ?>';
    var flow_date_from = '<?php echo $flow_start; ?>';
    var flow_date_to = '<?php echo $flow_end; ?>';
    var uom = '<?php echo $match_uom; ?>';
    var box_id = '<?php echo $box_id[0]; ?>';
    var total_pos_end = '<?php echo $total_delivery_vol; ?>';
    var total_pos_begin = '<?php echo $total_receipt_vol ?>';
    var from_loc_name = '<?php echo $from_loc_name; ?>';
    var to_loc_name = '<?php echo $to_loc_name; ?>';
    var receipt_loc_id = '<?php echo $receipt_loc_id; ?>';
    var delivery_loc_id = '<?php echo $delivery_loc_id; ?>';
    var path_exists_toggle = '<?php echo $path_exists_toggle; ?>';
    var sub = '<?php echo $sub; ?>';
    var book = '<?php echo $book; ?>';
    var str = '<?php echo $str; ?>';
    var sub_book_id = '<?php echo $sub_book_id; ?>';
    var contract_id = '<?php echo $contract_id; ?>';
    var receipt_deals = '<?php echo $receipt_deals; ?>';
    var delivery_deals = '<?php echo $delivery_deals; ?>';
    receipt_deals = (receipt_deals == '')?"NULL":receipt_deals;
    delivery_deals = (delivery_deals == '')?"NULL":delivery_deals;
    var toggle = '<?php echo $toggle; ?>';
    var reschedule = '<?php echo $reschedule; ?>';
    var avail_vol = '<?php echo $avail_vol; ?>';
	var call_from = '<?php echo $call_from ; ?>';
	var storage_type = '<?php echo $storage_type  ; ?>';  
	var min_rec_or_del_vol = '<?php echo $min_rec_or_del_vol  ; ?>';
	
    if (toggle == 'y'){
        switch_values('toggle');
    }
    var ADJUST_VALUE = 1;
    var BEG_POS = 2 + ADJUST_VALUE;
    var END_POS = 3 + ADJUST_VALUE;
    var template_contract_detail = _.template("\
        <table id=\"<%= table_id %>\" class=\"tbl_contract_pop_up <%= active_inactive %>\" border=1>\
            <tr class=\"tbl_contract_pop_up_header\">\
                <td class=\"header_cid\" style=\"display: none;\">ID</td>\
                <td class=\"header_path\">Path</td>\
				<td class=\"header_contract_pipeline\">Contract/Pipeline</td>\
                <td class=\"header_cmdq\" style=\"text-align: right; xdisplay: none;\">CMDQ</td>\
                <td class=\"header_crmdq\" style=\"text-align: right; xdisplay: none;\">CRMDQ</td>\
                <td class=\"header_pmdq\" style=\"text-align: right;\">PMDQ</td>\
                <td class=\"header_prmdq\" style=\"text-align: right;\">PRMDQ</td>\
                <td class=\"header_rec\" style=\"text-align: right;\">Receipt</td>\
                <td class=\"header_lf\" style=\"text-align: right;\">Loss</td>\
                <td class=\"header_del\" style=\"text-align: right;\">Delivery</td>\
            </tr>\
            <tr class=\"tbl_contract_pop_up_footer\">\
                <td colspan=\"4\">Total</td>\
                <td><span class=\"contract_mdq_total\" style=\"display: none;\" value=\"<%= mdq_total %>\"><%= mdq_total_formatted %></span></td>\
                <td><span class=\"contract_rmdq_total\" style=\"display: none;\" value=\"<%= rmdq_total %>\"><%= rmdq_total_formatted %></span></td>\
                <td><span class=\"contract_receipt_total\" value=\"<%= receipt_total %>\"><%= receipt_total_formatted %></span></td>\
                <td><span class=\"contract_lf_total\"</td>\
                <td><span class=\"contract_delivery_total\" value=\"<%= delivery_total %>\"><%= delivery_total_formatted %></span></td>\
                </tr>\
        </table>\
    ");

    var cd_tr_template = _.template(
        "<tr class=\"tbl_contract_pop_up_body\" single_path_id=\"<%= single_path_id %>\" loss_factor=\"<%= loss_factor %>\" title=\"<%= path_name %>\" >\
        <td class=\"contract_id_cd\" segmentation=\"<%= segmentation %>\" style=\"display: none;\"><%= contract_id %></td>\
        <td class=\"path\"><%= path %></td>\
        <td class=\"contract_pipeline\"><%= contract_pipeline %></td>\
        <td class=\"contract_mdq_cd\" style=\"xdisplay: none;\" value=\"<%= contract_mdq %>\"><%= contract_mdq_formatted %></td>\
        <td class=\"contract_rmdq_cd\" style=\"xdisplay: none;\" ormdq=\"<%= contract_ormdq %>\" value=\"<%= contract_rmdq %>\"><%= contract_rmdq_formatted %></td>\
        <td class=\"path_mdq_cd\" value=\"<%= path_mdq %>\"><%= path_mdq_formatted %></td>\
        <td class=\"path_rmdq_cd\" ormdq=\"<%= path_ormdq %>\" value=\"<%= path_rmdq %>\"><%= path_rmdq_formatted %></td>\
        <td ><input <%= is_rec_disabled %> class=\"pop_ip1\" type=\"text\" size=\"3\" maxlength=\"7\" \
            saved_value=\"<%= receipt_saved %>\" \
            value=\"<%= receipt %>\" \
            onkeydown=\"keypressed_pop_ip(this, \'r\', event)\"\
            onpaste=\"keypressed_pop_ip(this, \'r\', event)\"\
            /></td>\
        <td ><input class=\"path_lf\" type=\"text\" style=\"width: 35px;\" \
            value=\"<%= loss_factor %>\" \
            ovalue=\"<%= loss_factor %>\" \
            onkeydown=\"keypressed_pop_ip(this, \'l\', event)\"\
            onpaste=\"keypressed_pop_ip(this, \'l\', event)\"\
            /></td>\
        <td><input <%= is_del_disabled %> class=\"pop_ip2\" type=\"text\" size=\"3\" maxlength=\"7\" \
            saved_value=\"<%= delivery_saved %>\" \
            value=\"<%= delivery %>\" \
            onkeydown=\"keypressed_pop_ip(this, \'d\', event)\"\
            onpaste=\"keypressed_pop_ip(this, \'d\', event)\"\
            /></td>\
        </tr>"
    );
    $(function () {
        var html_string = '<div id="my_popup" style="style="width:auto";">\n' +
            '                                        <div class="popup_body" >\n' +
            '                                            <div class="content_popup">\n' +
            '                                                <span style="display: none;" id="popup_data_hidden"></span>\n' +
            '                                                                                                \n' +
            '                                                <table class="popup_tbl" border=0>\n' +
            '                                                    <tr>\n' +
            '                                                        <td width="100px">From :</td><td><span class="popup_from_loc"></span></td><td><span>Rec/Del Toggle</span>' +
            '                                                                                                 <label class="switch">\n' +
            '                                                                                                   <input id = "popup_toggle" type="checkbox" <?php if ($toggle == 'y') echo "checked" ; ?> onclick="toggle_click(this)">\n' +
            '                                                                                                   <span class="slider round"></span>\n' +
            '                                                                                                 </label>' +
            '                                                                                                 </td>\n' +
            '                                                    </tr>\n' +
            '                                                    <tr>    \n' +
            '                                                        <td>To :</td><td><span class="popup_to_loc"></span></td>\n' +
            '                                                    </tr>\n' +
            '                                                    <tr>\n' +
            '                                                        <td>Path:</td>\n' +
            '                                                        <td>\n' +
            '                                                            <select class="path_dd" onchange="path_dd_change(this)">\n' +
            '                                                            </select>\n' +
            '                                                            <input disabled="true" class="is_group_path" type="checkbox" checked="true" style="vertical-align: bottom;" /> Group Path\n' +
            '                                                        </td>\n' +
            '                                                    </tr>\n' +
            '                                                    <tr>\n' +
            '                                                        <td colspan="2">Contract Detail:</td>\n' +
            '                                                    </tr>\n' +
            '                                                    <tr>\n' +
            '                                                        <td colspan="2" class="template_content_cd"></td>\n' +
            '                                                    </tr>\n' +
            '                                                    <tr class="popup_tr_sc" style="display: none; ">\n' +
            '                                                        <td style="padding-top: 5px;">Storage Contract:</td>\n' +
            '                                                        <td style="padding-top: 5px;">\n' +
            '                                                            <select class="storage_contract_dd">\n' +
            '                                                             <option storage_asset_id="1">35-Powder Wash MM-contract1</option>\n' +
            '                                                             <option storage_asset_id="2">loc1-c2</option>\n' +
            '                                                            </select>\n' +
            '                                                            <input type="checkbox" class="chk_storage_deal" checked="true" style="vertical-align: bottom;" />\n' +
            '                                                        </td>\n' +
            '                                                    </tr>\n' +
            '                                                    \n' +
            '                                                </table>\n' +
            '                                            </div>\n' +
            '                                            <div id="save_popup"><input onclick="save_popup(this)" type="button" value="Save" data-popmodal-but="ok" id="pop_up_save" /></div>\n' +
            '                                        </div>\n' +
            '                                    </div>'
        // flow_match_single.single_match_layout.cells('a').progressOn();
        flow_match_single.single_match_layout.cells('a').attachHTMLString(html_string);
        
        var box_div = $('.box_div');
        if (toggle == 'n') {
			
            // popup_data_load();
            $('.edited_info').html('');
            fill_solver_data(json_solver_data);
        }
       
        $('.dhx_cell_cont_layout, .dhx_cell_layout, .dhxlayout_cont').css('height', '100%');
    })

    function popup_data_load() {
        $('.edited_info').html('');
        var exec_call = {
            "action": "spa_flow_optimization",
            "flag": "r",
            "process_id": process_id_gbl,
            "xml_manual_vol": box_id
        };
        var json_result = adiha_post_data('return_json', exec_call, '', '', 'fill_solver_data', false);

    }

    function toggle_click(obj) {
        var box_div = $('.box_div');
        var edited_info_obj = $('.edited_info', box_div);
        edited_info_obj.html('');
        if(obj.checked) {
            if (path_exists_toggle == '0') {
                $('#popup_toggle').prop('checked', false);
                dhtmlx.message({
                    title: "Warning",
                    type: "confirm-warning",
                    text: 'Delivery Path do not exist between selected locations. Click Ok to add delivery path.',
                    callback: function(is_true) {
                        if(is_true === true) {
                            parent.fx_open_delivery_path_window(delivery_loc_id, receipt_loc_id, to_loc_name,from_loc_name,'single_match_toggle');
                        }
                    }
                });
            } else {
                parent.new_win.progressOn();
                switch_values('toggle');
                fill_solver_data(json_solver_data);
            }
        } else {
            parent.new_win.progressOn();
            switch_values('untoggle');
            fill_solver_data(json_solver_data);
        }
    }

    function switch_values(id) {
        if (id == 'toggle') {
            //process_id_gbl = '<?php //echo $process_id_new_toggle; ?>//';
            total_pos_end = '<?php echo $total_receipt_vol; ?>';
            total_pos_begin = '<?php echo $total_delivery_vol ?>';
            box_id = '<?php echo $box_id[1]; ?>';
            json_solver_data =  '<?php echo $json_solver_data[1]; ?>';
        } else {
            //process_id_gbl = '<?php //echo $process_id_new; ?>//';
            total_pos_end = '<?php echo $total_delivery_vol; ?>';
            total_pos_begin = '<?php echo $total_receipt_vol ?>';
            box_id = '<?php echo $box_id[0]; ?>';
            json_solver_data =  '<?php echo $json_solver_data[0]; ?>';
        }
    }

    function load_popup_mdq(box_div) {
        var from_loc = $('.from_loc', box_div).text();
        var to_loc = $('.to_loc', box_div).text();
        var from_loc_id = $('.from_loc_id', box_div).text();
        var to_loc_id = $('.to_loc_id', box_div).text();
        var selected_path_id = $('.path_id', box_div).text();
        var selected_contract_id = $('.contract_id', box_div).text();
        var from_loc_grp_id = $('.from_loc_grp_id', box_div).text();
        var from_loc_grp_name = $('.from_loc_grp_name', box_div).text();
        var to_loc_grp_id = $('.to_loc_grp_id', box_div).text();
        var to_loc_grp_name = $('.to_loc_grp_name', box_div).text();
        var selected_storage_asset_id = $('.storage_deal_info', box_div).attr('storage_asset_id');
        var selected_storage_checked = $('.storage_deal_info', box_div).attr('storage_checked');

        $('.popup_from_loc').text(from_loc);
        $('.popup_from_loc').attr('from_loc_grp_id', from_loc_grp_id);
        $('.popup_from_loc').attr('from_loc_grp_name', from_loc_grp_name);
        $('.popup_to_loc').text(to_loc);
        $('.popup_to_loc').attr('to_loc_grp_id', to_loc_grp_id);
        $('.popup_to_loc').attr('to_loc_grp_name', to_loc_grp_name);

        //sset data on popup_data_hidden span
        var td_index = box_div.closest('td').index();
        var pos_beg_to = $('.frame_tbl tbody').filter('.total_beg_inv_del').attr('value');
        var pos_end_to = $('.frame_tbl tbody').filter('.total_end_inv_del').attr('value');
        $('#popup_data_hidden').attr(
            {
                'td_id': box_div.closest('.solver_data1').attr('id'),
                'route_id': $('.route_id', box_div).text(),
                'pos_beg_from': $('td:nth-child(' + (BEG_POS -1) + ')', box_div.closest('tr')).attr('value'),
                'pos_end_from': $('td:nth-child(' + (END_POS -1) + ')', box_div.closest('tr')).attr('value'),
                'pos_beg_to': pos_beg_to,
                'pos_end_to': pos_end_to,

            }
        );

        var box_id = parseInt($('.route_id', box_div).html());
        load_path_dd(box_id);
        $('.path_dd option[path_id="' + selected_path_id + '"]').attr('selected', true);

        load_contract_dd(box_div);

        if(from_loc_grp_name == 'Storage' || to_loc_grp_name == 'Storage') {
            var storage_loc = (from_loc_grp_name == 'Storage') ? from_loc_id : to_loc_id;
            $('.popup_tr_sc').show();
            var inj_with = (from_loc_grp_name == 'Storage') ? 'w' : 'i';
            var st_pos = (from_loc_grp_name == 'Storage') ? $('#popup_data_hidden').attr('pos_beg_from') : $('#popup_data_hidden').attr('pos_beg_to');
            load_storage_asset_info(storage_loc, inj_with, st_pos);
            $('.storage_contract_dd option[storage_asset_id="' + selected_storage_asset_id + '"]').attr('selected', true);
            if(selected_storage_checked == 1) $('.chk_storage_deal', box_div).attr('checked', true);
        } else {
            $('.popup_tr_sc').hide();
        }

    }

    function load_storage_asset_info(loc, inj_with, st_pos) {
        var exec_call = {
            'action': 'spa_virtual_storage',
            'flag': 'o',
            'storage_location': loc,
            'effective_date': flow_date_from,
            'inj_with': inj_with,
            'storage_position': total_pos_end
        };
        var json_result = adiha_post_data('return_json', exec_call, '', '', 'ajx_load_storage_asset_info', true);
    }
    function ajx_load_storage_asset_info(json_result) {
        json_obj = $.parseJSON(json_result);
        //console.dir(json_obj);
        $('.storage_contract_dd').html('');
        $.each(json_obj, function(i) {
            $('.storage_contract_dd').append(
                '<option '
                + ' storage_asset_id="' + json_obj[i].storage_asset_id + '"'
                + ' storage_location="' + json_obj[i].storage_location + '"'
                + ' storage_contract="' + json_obj[i].storage_contract + '"'
                + ' storage_cost="' + json_obj[i].storage_cost + '"'
                + ' storage_volume="' + json_obj[i].storage_volume + '"'
                + ' storage_type="' + json_obj[i].storage_type + '"'
                + ' storage_fee="' + json_obj[i].storage_fee + '"'
                + ' min_inj="' + json_obj[i].min_inj + '"'
                + ' max_inj="' + json_obj[i].max_inj + '"'
                + ' min_wid="' + json_obj[i].min_wid + '"'
                + ' max_wid="' + json_obj[i].max_wid + '"'
                + ' ratchet_type="' + json_obj[i].ratchet_type + '"'
                + ' ratchet_term_from="' + json_obj[i].ratchet_term_from + '"'
                + ' ratchet_term_to="' + json_obj[i].ratchet_term_to + '"'
                + ' ratchet_fixed_value="' + json_obj[i].ratchet_fixed_value + '"'
                + '>' + json_obj[i].storage_location_contract);
        });

    }

    function fill_solver_data(json_solver_data) {
		console.log('aaa');
		console.log(json_solver_data);
        var box_div = $('.box_div');
        var mdq_inv_json = $.parseJSON(json_solver_data);
        $.each(mdq_inv_json, function (key1, val1) {
            var input_cls = '';
            $('.box_div').attr(
                {
                    'box_type': mdq_inv_json[key1].box_type,
                    'route_id': mdq_inv_json[key1].box_id,
                    'from_loc_id': mdq_inv_json[key1].from_loc_id,
                    'from_loc': mdq_inv_json[key1].from_loc,
                    'from_loc_grp': mdq_inv_json[key1].from_loc_grp_name,
                    'from_proxy_loc_id': mdq_inv_json[key1].from_proxy_loc_id,
                    'to_loc_id': mdq_inv_json[key1].to_loc_id,
                    'to_loc': mdq_inv_json[key1].to_loc,
                    'to_loc_grp': mdq_inv_json[key1].to_loc_grp_name,
                    'to_proxy_loc_id': mdq_inv_json[key1].to_proxy_loc_id,
                    //'from_pos_beg': mdq_inv_json[key1].box_type,
                    //'from_pos_end': mdq_inv_json[key1].box_type,
                    //'to_pos_beg': mdq_inv_json[key1].box_type,
                    //'to_pos_end': mdq_inv_json[key1].box_type,
                    'total_pmdq': mdq_inv_json[key1].path_mdq,
                    'total_prmdq': mdq_inv_json[key1].path_rmdq,
                    //'total_irmdq': mdq_inv_json[key1].path_rmdq,
                    'path_ids': mdq_inv_json[key1].path_exists,
                    'process_id': mdq_inv_json[key1].process_id
                }
            );

            if(mdq_inv_json[key1].path_exists === '0') {
                $('.top_div, .center_div, .bottom_div').addClass('no_path_cell');
                $('.process_id').text((mdq_inv_json[key1].process_id));
                $('.from_loc_id').text((mdq_inv_json[key1].from_loc_id));
                $('.to_loc_id').text((mdq_inv_json[key1].to_loc_id));
                $('.from_loc').text((mdq_inv_json[key1].from_loc));
                $('.to_loc').text((mdq_inv_json[key1].to_loc));

                //save global var for process id
                process_id_gbl = mdq_inv_json[key1].process_id;
                return;
            }
            ///$('#data' + key1).closest('tr').removeClass('nowhere_to_go_from');
            ///$('.frame_tbl tr:nth-child(2) td:nth-child('+($('#data' + key1).closest('td').index()+1)+')').removeClass('nowhere_to_go_to');

            $.each(val1, function (key2, val2) {

                if (key2 == 'path_mdq') {
                    input_cls = '.mdq_info1';
                    $(input_cls).attr('value', val2);
                    val2 = format_number_to_comma_separated(val2);
                } else if (key2 == 'path_rmdq') {
                    input_cls = '.mdq_info2';
                    $(input_cls).attr('value', val2);
                    $('.original_rmdq').html(val2);
                    val2 = format_number_to_comma_separated(val2);
                } else if (key2 == 'from_loc_id'){
                    input_cls = '.from_loc_id';
                } else if (key2 == 'from_loc'){
                    input_cls = '.from_loc';
                } else if (key2 == 'to_loc_id'){
                    input_cls = '.to_loc_id';
                } else if (key2 == 'to_loc'){
                    input_cls = '.to_loc';
                } else if (key2 == 'box_id'){
                    input_cls = '.route_id';
                } else if (key2 == 'received') {
                    input_cls = '.rec_del_div1';
                    $(input_cls).attr('value', val2);
                    val2 = format_number_to_comma_separated(val2);
                } else if (key2 == 'delivered') {
                    input_cls = '.rec_del_div2';
                    $(input_cls).attr('value', val2);
                    val2 = format_number_to_comma_separated(val2);
                } else if (key2 == 'path_exists'){
                    input_cls = '.path_exists';
                    if (val2 == '0') {
                        $('.top_div, .center_div, .bottom_div').addClass('no_path_cell');
                    }
                } else if (key2 == 'process_id'){
                    input_cls = '.process_id';
                    //save global var for process id
                    process_id_gbl = val2;
                } else if (key2 == 'from_loc_grp_id'){
                    input_cls = '.from_loc_grp_id';
                } else if (key2 == 'from_loc_grp_name'){
                    input_cls = '.from_loc_grp_name';
                } else if (key2 == 'to_loc_grp_id'){
                    input_cls = '.to_loc_grp_id';
                } else if (key2 == 'to_loc_grp_name'){
                    input_cls = '.to_loc_grp_name';
                } else input_cls = 'none';

                if (input_cls != '' && input_cls != 'none') {
                    $(input_cls).html(val2);
                }
            });
        });

        // fx_post_loading_refresh();
        load_popup_mdq(box_div);

    }
    //FORMAT NUMBER DATA TO EN-US NUMBER FORMAT
    function format_number_to_comma_separated(num) {
        return parseInt(num).toLocaleString('en-US').split('.', 1);
    }

    function fill_contract_detail(json_path_contract) {
        /*Hardcorded value*/
        var lastest_click_btn = 0;
        /*End*/

        var json_path_contract = $.parseJSON(json_path_contract);
        var original_rmdq = $('.original_rmdq').text();

        //$('.tbl_contract_pop_up_body').html('');
        var edited_info_detail_obj = $('.edited_info');
        var edited_route = ($('li', edited_info_detail_obj).length > 0) ? true : false;
        var box_id = $('.route_id').html();
        var to_loc_id = $('.to_loc_id').html();
        var from_loc_id = $('.from_loc_id').html();

        var total_row = Object.keys(json_path_contract).length;

        var current_table_id = '';
        var prev_table_id = '';
        var tr_counter = 0;


        $.each(json_path_contract, function(i) {

            if (i != 0) {
                prev_table_id = current_table_id;
            }

            current_table_id = json_path_contract[i].table_id;



            var del_vol_used = (json_path_contract[i].segmentation == 'y' ? 0 : fx_calc_crmdq(json_path_contract[i].contract_id, box_id));
            var del_vol_used_path = fx_calc_prmdq(json_path_contract[i].single_path_id, box_id);
            //var del_vol_used = fx_calc_crmdq(json_path_contract[i].contract_id, box_id);

            var proxy_path_rmdq = fx_calc_proxy_prmdq(json_path_contract[i].path_id, box_id);

            var cell_proxy_type_from = 'np';
            if($('.total_end_inv_rec').filter('[loc_id="' + from_loc_id + '"]') !== undefined) {
                cell_proxy_type_from = $('.total_end_inv_rec').filter('[loc_id="' + from_loc_id + '"]').attr('proxy_type');
            }
            var cell_proxy_type_to = 'np';
            if($('.total_end_inv_del').filter('[loc_id="' + to_loc_id + '"]') !== undefined) {
                cell_proxy_type_to = $('.total_end_inv_del').filter('[loc_id="' + to_loc_id + '"]').attr('proxy_type');
            }

            var cell_proxy_type = 'np';
            if(cell_proxy_type_from == 'cp' || cell_proxy_type_to == 'cp') {
                cell_proxy_type = 'cp';
            } else if(cell_proxy_type_from == 'cv' || cell_proxy_type_to == 'cv') {
                cell_proxy_type = 'cv';
            }

            var path_rmdq = json_path_contract[i].path_rmdq;

            var path_ormdq = $('.path_dd [path_id="' + json_path_contract[i].path_id + '"]').attr('path_ormdq');
            //var path_ormdq = $('.path_dd [path_id="' + json_path_contract[i].path_id + '"]').attr('path_ormdq');

            var is_rec_disabled = '';
            var is_del_disabled = '';
            //DISABLE OTHER THAN FIRST ROWS ON GROUP PATH CASE ON CONTRACT Detail

            if (i != 0) {
                if (prev_table_id != current_table_id) {
                    tr_counter = 0;
                } else {
                    tr_counter++;
                }
            }

            if (json_path_contract[i].group_path ==  'y') {
                //if($('.tbl_contract_pop_up_body', $('#' + json_path_contract[i].path_id)).index() > 0) {

                is_rec_disabled = 'disabled';
                is_del_disabled = 'disabled';

                if (tr_counter == 0) {
                    is_rec_disabled = '';
                }
                if (tr_counter == _.countBy(json_path_contract,'table_id')[current_table_id] - 1) {
                    is_del_disabled = '';
                }

            }


            if(edited_route) { 
                var edited_li = $('li [path_id="' + json_path_contract[i].path_id + '"],[contract_id="' + json_path_contract[i].contract_id + '"]'
                    , edited_info_detail_obj);
                //console.log(edited_li);
                if(cell_proxy_type == 'cp') {
                    path_rmdq = proxy_path_rmdq;
                } else {
                    path_rmdq = edited_li.attr('path_rmdq');
                }
                //deduct mdq for same path used
                //alert(json_path_contract[i].path_rmdq + '-' + parseInt(del_vol_used_path) +'-' +edited_li.attr('delivery'));
                path_rmdq = json_path_contract[i].path_rmdq - parseInt(del_vol_used_path) - edited_li.attr('delivery');

                var contract_rmdq = json_path_contract[i].contract_rmdq - parseInt(del_vol_used) - edited_li.attr('delivery');

                $('.tbl_contract_pop_up_footer', $('#' + json_path_contract[i].table_id)).before(
                    cd_tr_template(
                        {
                            single_path_id: json_path_contract[i].single_path_id
                            ,loss_factor: json_path_contract[i].loss_factor
                            ,segmentation: json_path_contract[i].segmentation
                            , contract_id: json_path_contract[i].contract_id + ','  //comma seperator for group path
                            ,path:json_path_contract[i].path_name //+ ' (' + json_path_contract[i].contract_name + '/' + json_path_contract[i].pipeline + ')'
                            ,contract_pipeline: json_path_contract[i].contract_name + '/' + json_path_contract[i].pipeline
                            ,contract_mdq: json_path_contract[i].contract_mdq
                            ,contract_mdq_formatted: format_number_to_comma_separated(json_path_contract[i].contract_mdq)
                            ,contract_rmdq: contract_rmdq
                            //,contract_ormdq: json_path_contract[i].contract_rmdq
                            //,contract_ormdq: original_rmdq
                            ,contract_ormdq: json_path_contract[i].contract_ormdq
                            ,contract_rmdq_formatted: format_number_to_comma_separated(contract_rmdq)

                            ,path_mdq: json_path_contract[i].path_mdq
                            ,path_mdq_formatted: format_number_to_comma_separated(json_path_contract[i].path_mdq)
                            ,path_rmdq: path_rmdq//edited_li.attr('path_rmdq')
                            ,path_ormdq: edited_li.attr('ormdq')
                            ,path_rmdq_formatted: format_number_to_comma_separated(path_rmdq)

                            ,receipt_saved: edited_li.attr('receipt')
                            ,receipt: json_path_contract[i].receipt //edited_li.attr('receipt')
                            ,receipt_formatted: format_number_to_comma_separated(json_path_contract[i].receipt)
                            ,delivery_saved: edited_li.attr('delivery')
                            ,delivery: json_path_contract[i].delivery//edited_li.attr('delivery')
                            ,delivery_formatted: format_number_to_comma_separated(json_path_contract[i].delivery)
                            ,is_rec_disabled: is_rec_disabled
                            ,is_del_disabled: is_del_disabled
                            ,path_name: json_path_contract[i].path_name + ' (' + json_path_contract[i].contract_name + '/' + json_path_contract[i].pipeline + ')'
                        }
                    )
                );

                //INVALID ON SECOND TIME MANUAL SCHEDULE
                if(parseInt(edited_li.attr('path_rmdq')) < 0) {
                    $('.pop_ip2').addClass('popup_invalid_mdq');
                }
            } else { 
                var contract_rmdq = parseInt(json_path_contract[i].contract_rmdq) - parseInt(del_vol_used);
                //alert($('.edited_info li').filter('[path_id="' + json_path_contract[i].path_id + '"]').length);
                if(cell_proxy_type == 'cp' && $('.edited_info_detail').filter('[path_id="' + json_path_contract[i].path_id + '"]').length > 0) {
                    //alert('pxy:'+proxy_path_rmdq);
                    path_rmdq = proxy_path_rmdq;
                } else {
                    path_rmdq = json_path_contract[i].path_rmdq - del_vol_used_path;
                }



                //console.log(json_path_contract[i].single_path_id);
                $('.tbl_contract_pop_up_footer', $('#' + json_path_contract[i].table_id)).before(

                    cd_tr_template(
                        {
                            single_path_id: json_path_contract[i].single_path_id
                            ,loss_factor: json_path_contract[i].loss_factor
                            ,segmentation: json_path_contract[i].segmentation
                            ,contract_id: json_path_contract[i].contract_id + ',' //comma seperator for group path
                            ,path:json_path_contract[i].path_name //+ ' (' + json_path_contract[i].contract_name + '/' + json_path_contract[i].pipeline + ')'
                            ,contract_pipeline: json_path_contract[i].contract_name + '/' + json_path_contract[i].pipeline
                            ,contract_mdq: json_path_contract[i].contract_mdq
                            ,contract_mdq_formatted: format_number_to_comma_separated(json_path_contract[i].contract_mdq)
                            ,contract_rmdq: contract_rmdq
                            //,contract_ormdq: json_path_contract[i].contract_rmdq
                            //,contract_ormdq: original_rmdq
                            ,contract_ormdq: json_path_contract[i].contract_ormdq
                            ,contract_rmdq_formatted: format_number_to_comma_separated(contract_rmdq)

                            ,path_mdq: json_path_contract[i].path_mdq
                            ,path_mdq_formatted: format_number_to_comma_separated(json_path_contract[i].path_mdq)
                            ,path_rmdq: path_rmdq//json_path_contract[i].path_rmdq
                            ,path_ormdq: json_path_contract[i].path_ormdq //path_ormdq
                            ,path_rmdq_formatted: format_number_to_comma_separated(path_rmdq)

                            ,receipt_saved: (lastest_click_btn == 1 ? json_path_contract[i].receipt : "")
                            ,receipt: (lastest_click_btn == 1 ? json_path_contract[i].receipt : "") //json_path_contract[i].receipt
                            ,receipt_formatted: format_number_to_comma_separated(json_path_contract[i].receipt)
                            ,delivery_saved: (lastest_click_btn == 1 ? json_path_contract[i].delivery : "")
                            ,delivery: (lastest_click_btn == 1 ? json_path_contract[i].delivery : "") //json_path_contract[i].delivery
                            ,delivery_formatted: format_number_to_comma_separated(json_path_contract[i].delivery)
                            ,is_rec_disabled: is_rec_disabled
                            ,is_del_disabled: is_del_disabled
                            ,path_name: json_path_contract[i].path_name + ' (' + json_path_contract[i].contract_name + '/' + json_path_contract[i].pipeline + ')'
                        }
                    )
                );

                $('.contract_receipt_total').attr('value', json_path_contract[i].receipt_total);
                $('.contract_receipt_total').text(format_number_to_comma_separated(json_path_contract[i].receipt_total));

                $('.contract_delivery_total').attr('value', json_path_contract[i].delivery_total);
                $('.contract_delivery_total').text(format_number_to_comma_separated(json_path_contract[i].delivery_total));

                $('.is_group_path').prop('checked', json_path_contract[i].group_path == 'y');


                $('.contract_rmdq_total').attr('value',
                    (
                        (cell_proxy_type == 'cp' && $('.edited_info_detail').filter('[path_id="' + json_path_contract[i].table_id + '"]').length > 0)
                            ? proxy_path_rmdq : json_path_contract[i].first_path_mdq - del_vol_used_path));
                $('.contract_rmdq_total').text(format_number_to_comma_separated(
                    (
                        (cell_proxy_type == 'cp' && $('.edited_info_detail').filter('[path_id="' + json_path_contract[i].table_id + '"]').length > 0)
                            ? proxy_path_rmdq : json_path_contract[i].first_path_mdq - del_vol_used_path)));
            }

            //enable last single path delivery input
            //$('.pop_ip2', $('.tbl_contract_pop_up_body', $('#' + json_path_contract[i].path_id))).last().removeAttr('disabled');
            //$('.pop_ip2', $('.tbl_contract_pop_up_body', $('#' + json_path_contract[i].path_id))).first().attr('disabled','');


            //total adjustment from backend values.
            $('.contract_mdq_total').attr('value', json_path_contract[i].first_path_mdq);
            $('.contract_mdq_total').text(format_number_to_comma_separated(json_path_contract[i].first_path_mdq));
        });

        //calculate compare mdq value
        var box_id = $('#popup_data_hidden').attr('route_id');
        var table_id = $('.cd_active').attr('id');

        var path_id = (table_id.indexOf("_") == -1) ? table_id : table_id.split('_')[0];
        var contract_id = $('.contract_id_cd', '.cd_active').text();

        //Remove last comma
        if (contract_id[contract_id.length -1] == ',') {
            contract_id = contract_id.slice(0, -1);
        }

        //make other input for single paths readonly
        /*
        $.each($('.tbl_contract_pop_up_body'),function(i) {
            alert(i);
            if($(this).attr('single_path_id') != '' && i > 0) {
                $('.pop_ip1', $(this)).attr('readonly','');
            }
        });
        */


        compare_cmdq_gbl = 0;
        fx_calc_cmdq_to_compare(box_id, path_id, contract_id);
		var rec_del_class = (min_rec_or_del_vol == 'receipt' ? '.pop_ip1' : '.pop_ip2');
        $(rec_del_class, '.tbl_contract_pop_up').eq(0).val(avail_vol);
		$(rec_del_class, '.tbl_contract_pop_up').eq(0).trigger('onpaste');
		
    }

    function fx_calc_crmdq(contract_id, box_id) {
        var del_vol_used = 0;
        $('.edited_info li').each(function(i) {
            if($(this).attr('delivery') != "" && parseInt($(this).attr('contract_id')) == contract_id
                && parseInt($('.route_id', $(this).closest('.box_div')).html()) != box_id) {
                del_vol_used += parseInt($(this).attr('delivery'));

            }

        });

        return del_vol_used;
        //alert(del_vol_used);
    }

    function fx_calc_prmdq(path_id, box_id) {
        var del_vol_used_path = 0;
        $('.edited_info li').each(function(i) {
            if($(this).attr('delivery') != "" && parseInt($(this).attr('single_path_id')) == path_id
                && parseInt($('.route_id', $(this).closest('.box_div')).html()) != box_id) {
                del_vol_used_path += parseInt($(this).attr('delivery'));

            }

        });
        //alert(del_vol_used_path);
        return del_vol_used_path;
    }


    function fx_calc_proxy_prmdq(path_id, box_id) {
        var proxy_path_rmdq = 0;
        //alert(path_id)
        $('.edited_info li').each(function(i) {
            //if(box_id != $(this).closest('.box_div').attr('route_id')) {
            if($(this).filter('[path_id="' + path_id + '"]').length > 0) {
                proxy_path_rmdq = $(this).filter('[path_id="' + path_id + '"]').attr('path_rmdq');
            }
            //}
        });
        //alert(proxy_path_rmdq);
        return proxy_path_rmdq;
    }
    /*
      function to calculate other sum of received volume of given contract excluding given box_id and path_id
      */
    function fx_calc_cmdq_to_compare(box_id, path_id, contract_id) {
        var exec_call = {
            'action': 'spa_flow_optimization',
            'flag': 'x',
            'contract_id': contract_id,
            'delivery_path': path_id,
            'xml_manual_vol': box_id,
            'process_id': process_id_gbl
        }
        var json_result = adiha_post_data('return_json', exec_call, '', '', 'ajx_fx_calc_cmdq_to_compare', false);

    }
    function ajx_fx_calc_cmdq_to_compare(json_result) {
        var json_obj = $.parseJSON(json_result);
        //console.log(json_obj.length);
        compare_cmdq_gbl = (json_obj.length > 0 ? json_obj[0].compare_volume : 0);
        //console.log('compare_value:'+compare_cmdq_gbl);
    }

    function save_popup(obj) {
        var td_id = $('#popup_data_hidden').attr('td_id');

        var box_div = $('.box_div');

        //alert(lastest_edit_popup_field);
        var rec_value_new = parseInt($('.contract_receipt_total', '.cd_active').attr('value'));
        var del_value_new = parseInt($('.contract_delivery_total', '.cd_active').attr('value'));
        var path_id = $('.path_dd option:selected').attr('path_id');
        var path_name = $('.path_dd option:selected').val();

        var rec_end_inv = 0;
        var del_end_inv = 0;

        //storage contract info
        var is_storage_loc = 0;
        var from_loc_grp = $('.popup_from_loc').attr('from_loc_grp_name');
        var to_loc_grp = $('.popup_to_loc').attr('to_loc_grp_name');
        var storage_deal_type = 'n';
        var storage_asset_id = 0;
        var storage_checked = false;


        if(from_loc_grp == 'Storage' || to_loc_grp == 'Storage') {
            is_storage_loc = 1;
            storage_asset_id = $('.storage_contract_dd option:selected').attr('storage_asset_id');
            storage_checked = $('.chk_storage_deal').is(':checked') ? true : false;

        }

        var edited_info_obj = $('.edited_info', box_div);
        var tbl_contract_pop_up = $('.tbl_contract_pop_up');
        //var tbl_contract_pop_up = $('.tbl_contract_pop_up', box_div);
        rec_value_new = 0;
        del_value_new = 0;
        var rmdq_final = 0;


        tbl_contract_pop_up.each(function(i) { //alert('pop' + i);
            if($('.tbl_contract_pop_up_body td', $(this)).length != 0) {
                //alert(parseInt($('.contract_receipt_total', $(this)).attr('value')));
                rec_value_new += parseInt($('.contract_receipt_total', $(this)).attr('value'));
                del_value_new += parseInt($('.contract_delivery_total', $(this)).attr('value'));
            }

        });

        //storage constraint validation
        var vol_exceed = '';
        if(box_div.attr('from_loc_grp') == 'Storage' && storage_checked) {
            var storage_obj = $('.storage_contract_dd option:selected');
            var min_wid = storage_obj.attr('min_wid');
            var max_wid = storage_obj.attr('max_wid');
            var ratchet_vol = storage_obj.filter('[ratchet_type="w"]').attr('ratchet_fixed_value');
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
        } else if(box_div.attr('to_loc_grp') == 'Storage' && storage_checked) {
            var storage_obj = $('.storage_contract_dd option:selected');
            var min_inj = storage_obj.attr('min_inj');
            var max_inj = storage_obj.attr('max_inj');
            var ratchet_vol = storage_obj.filter('[ratchet_type="i"]').attr('ratchet_fixed_value');
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

        //## VALIDATIONS FOR MDQ, INVENTORIES
        //violation_mdq_bandwidth(box_div, del_value_new); //compare mdq with delivery volume

        rec_end_inv = violation_available_inv_rec(box_div, rec_value_new);
        if(rec_end_inv === false) {
            return;
        }
        del_end_inv = violation_available_inv_del(box_div, del_value_new);
        if(del_end_inv === false) {
            return;
        }

        if(vol_exceed != '') {
            //let exceed inj,with,ratchet
            //return;
        }
        //if(to_loc_grp == 'Storage') {
        //del_end_inv = Math.abs(del_end_inv);
        //}
        edited_info_obj.html('');
        var receipt_total = 0;
        var mdq_total = 0;
        var delivery_total = 0;
        var rmdq_total = 0;
        tbl_contract_pop_up.each(function(i) {

            var cd_tr = $('.tbl_contract_pop_up_body', $(this));
            receipt_total = $('.contract_receipt_total', $(this)).attr('value');
            delivery_total = $('.contract_delivery_total', $(this)).attr('value');
            mdq_total = $('.contract_mdq_total', $(this)).attr('value');
            rmdq_total = $('.contract_rmdq_total', $(this)).attr('value');
            rmdq_final += parseInt(rmdq_total);

            if(cd_tr.length != 0) {
                cd_tr.each(function(j) {
                    //console.log('path_rmdq_cd:' + $('.path_rmdq_cd', $(this)).attr('value'));
                    var receipt = $('.pop_ip1', $(this)).val() == '' ? 0 : $('.pop_ip1', $(this)).val();
                    var delivery = $('.pop_ip2', $(this)).val() == '' ? 0 : $('.pop_ip2', $(this)).val();
                    var lf = $('.path_lf', $(this)).val() == '' ? 0 : $('.path_lf', $(this)).val();

                    var table_id = $(tbl_contract_pop_up[i]).attr('id');
                    var path_id = (table_id.indexOf("_") == -1) ? table_id : table_id.split('_')[0];
                    edited_info_obj.append(
                        "<li class=\"edited_info_detail\" \
                            table_id=\"" + table_id + "\" \
                            path_id=\"" + path_id + "\" \
                            single_path_id=\"" + $(this).attr('single_path_id') + "\" \
                            path_lf=\"" + lf + "\" \
                            contract_id=\"" + $('.contract_id_cd', $(this)).html() + "\" \
                            contract_rmdq=\"" + $('.contract_rmdq_cd', $(this)).attr('value') + "\" \
                            path_rmdq=\"" + $('.path_rmdq_cd', $(this)).attr('value') + "\" \
                            receipt=\"" + receipt + "\" \
                            delivery=\"" + delivery + "\"\
                            receipt_total=\"" + receipt_total + "\"\
                            delivery_total=\"" + delivery_total + "\"\
                            rmdq_total=\"" + rmdq_total + "\"\
                            ormdq=\"" + $('.path_rmdq_cd', $(this)).attr('ormdq') + "\"\
                            storage_asset_id=\"" + storage_asset_id + "\"\
                            >"
                    );

                    /*
                    if($('.edited_info li') !== undefined ) {
                        $('.edited_info li').filter('[path_id="' + $(tbl_contract_pop_up[i]).attr('id') + '"]').attr(
                            {
                                'path_rmdq': $('.path_rmdq_cd', $(this)).attr('value'),
                                'rmdq_total': rmdq_total
                            }
                        );
                    }
                    */

                });
            }
        });

        edited_info_obj.attr('edited_by', 'manual');

        //SET VALUES ON HIDDEN STORAGE SPAN
        if(storage_checked && is_storage_loc == 1) {
            var storage_volume = '';

            if(from_loc_grp == 'Storage') {
                storage_deal_type = 'w';
                storage_volume = receipt_total;
            } else {
                storage_deal_type = 'i';
                storage_volume = delivery_total;
            }
            $('.storage_deal_info', box_div).attr(
                {
                    'storage_asset_id':storage_asset_id,
                    'storage_deal_type':storage_deal_type,
                    'storage_volume':storage_volume,
                    'storage_checked': (storage_checked ? 1 : 0)
                }
            );
        }

        //save rec/dev vol on contractwise process table
        save_vol_to_pt(box_div);

        //schedule_popup_dhtmlx_obj_gbl.hide();
        // $('#my_popup').hide();
        //event.stopPropagation();

    }

    function save_vol_to_pt(box_div) {
        //var process_id = $('.process_id').eq(0).text();
        var route_id = $('.route_id', box_div).text();
        var storage_deal_type = $('.storage_deal_info', box_div).attr('storage_deal_type');
        var storage_asset_id = $('.storage_deal_info', box_div).attr('storage_asset_id');
        var storage_volume = $('.storage_deal_info', box_div).attr('storage_volume');
        var xml_manual_vol = '<Root>';

        var contract_id = '';
        $('.edited_info li', box_div).each(function(i) {

            contract_id = $(this).attr('contract_id')

            //Remove last comma
            if (contract_id[contract_id.length -1] == ',') {
                contract_id = contract_id.slice(0, -1);
            }

            xml_manual_vol += '<PSRecordset box_id="' + route_id +
                '" path_id="' + $(this).attr('path_id') +
                '" single_path_id="' + ($(this).attr('single_path_id') == '' ? '-1' : $(this).attr('single_path_id')) +
                '" contract_id="' + contract_id +
                '" rec_vol="' + $(this).attr('receipt') +
                '" del_vol="' + $(this).attr('delivery') +
                '" loss_factor="' + $(this).attr('path_lf') +
                '" storage_deal_type="' + storage_deal_type +
                '" storage_asset_id="' + storage_asset_id +
                '" storage_volume="' + storage_volume +
                '"></PSRecordset>';

        });
        xml_manual_vol += '</Root>';

        var exec_call = {
            'action': 'spa_flow_optimization',
            'flag': 'z',
            'process_id': process_id_gbl,
            'xml_manual_vol': xml_manual_vol
        }
        parent.create_match_split_window.window('window_match').progressOn();
        var json_result = adiha_post_data('return_json', exec_call, '', '', 'ajx_save_vol_to_pt', false);

    }

    function ajx_save_vol_to_pt(json_result) {
        var box_div = $('.box_div');
        var box_ids = parseInt($('.route_id', box_div).html());

        if(box_ids == '') {
            //show_messagebox('Please select valid record to proceed.');
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: 'Please select valid record to proceed.',
            });
            parent.create_match_split_window.window('window_match').progressOff();
        } else {
            //logic to open or not sub book window
            			
			if (call_from == 'book_out') {
				
				 var xml_text =  '<Root rec_deals="' + receipt_deals +
							'" del_deals="' + delivery_deals +
							'" rec_location="' + receipt_loc_id +
							'" del_location="' + delivery_loc_id +
							'" flow_date_from="' + flow_date_from +
							'" flow_date_to="' + flow_date_to +
							'" uom="' + uom +
							'" storage_type="' + storage_type +
							'" storage_asset_id="' + "" +
							'">'
				
				
				
				 $('.edited_info li', box_div).each(function(i) {

						xml_text +=  '<PSRecordset path_id="' + -1 +
									'" contract="' + '-1' +
									'" sub_book_id="' + "-1" +
									'" single_path_id="' + "" +
									'" term_start="' + flow_date_from +
									'" rec_vol="' + $(this).attr('receipt') +
									'" del_vol="'+ $(this).attr('delivery') +
									'" loss_factor="' + $(this).attr('path_lf') +
									'" counterparty_id="' + '-1' +
									'" />'

				});
				
				   xml_text += ' </Root>'
				
				  var exec_call = {
							"flag": "m",
							"action": "spa_flow_optimization_match",
							"xml_text": xml_text,
							"process_id": process_id_gbl,
							"call_from": 'opt_book_out'
						};
			} else {
				var exec_call = {
					'action': 'spa_schedule_deal_flow_optimization',
					'flag': 'i',
					'box_ids': box_ids,
					'sub': 'NULL',
					'str': 'NULL',
					'book': 'NULL',
					'sub_book': 'NULL',
					'flow_date_from': flow_date_from,
					'flow_date_to': flow_date_to,
					'contract_process_id': process_id_gbl,
					'call_from': call_from,
					'target_uom': uom,
					'reschedule': reschedule,
					'receipt_deals_id' : receipt_deals,
					'delivery_deals_id' : delivery_deals
				};
			}
			
            var json_result = adiha_post_data('return_json', exec_call, '', '', 'fx_save_schedule_ajax', false);
        }
    }

    function fx_save_schedule_ajax(result) {
        var json_obj = $.parseJSON(result);
        var box_div = $('.box_div');
        var box_ids = parseInt($('.route_id', box_div).html());
        if(json_obj[0].errorcode == 'Error' && json_obj[0].recommendation == 'generic_mapping') {
            parent.create_match_split_window.window('window_match').progressOff();
            //window popup start
            dhx_wins = new dhtmlXWindows();
            dhx_wins.createWindow({
                id: 'window_sub_book'
                ,width: 580
                ,height: 200
                ,modal: true
                ,resize: false
                ,move: false
                ,text: 'Destination Sub Book'
            });

            var wd_sub_book = dhx_wins.window('window_sub_book');

            wd_sub_book.setPosition(0,0);
            //wd_sub_book.maximize();
            var options_sub_book = <?php echo $json_sub_book; ?>;

            var obj_form = wd_sub_book.attachForm([
                {'type': 'settings', 'position': 'label-top'},
                {
                    'type': 'combo', 'label': 'Sub Book', 'name': 'cmb_sb', 'width': '500', 'filtering': true, "filtering_mode":"between",
                    'options': options_sub_book
                },
                {'type': 'button', 'name': 'btn_sb_ok', 'value': 'Ok', 'width': '50'}
            ]);

            obj_form.attachEvent('onButtonClick', function(name) {
                var obj_form_cmb = obj_form.getCombo('cmb_sb');
                var dest_sub_book = obj_form_cmb.getSelectedValue();

                if(dest_sub_book == null) {
                    //show_messagebox('Destination Sub Book is empty.');
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: 'Destination Sub Book is empty.',
                    });

                } else {
                    confirm_messagebox('Are you sure you want to continue?', function() {
                        wd_sub_book.close();
                        var exec_call = {
                            'action': 'spa_schedule_deal_flow_optimization',
                            'flag': 'i',
                            'box_ids': box_ids,
                            'flow_date_from': flow_date_from,
                            'flow_date_to': flow_date_to,
                            'sub': 'NULL',
                            'str': 'NULL',
                            'book': 'NULL',
                            'sub_book': dest_sub_book,
                            'contract_process_id': process_id_gbl,
                            'call_from': 'flow_opt',
                            'target_uom': uom,
                            'reschedule': reschedule,
                            'receipt_deals_id' : receipt_deals,
                            'delivery_deals_id' : delivery_deals
                        };
                        parent.create_match_split_window.window('window_match').progressOn();
                        var fx_call_back = function() {
                            parent.create_match_split_window.window('window_match').progressOff();
                            success_call('Schedule deals have been created successfully.', 'error');
                            parent.single_match_save_callback();
                        };
                        var json_result = adiha_post_data('return_json', exec_call, '', '', fx_call_back, false);
                        
                    });
                }
            });
            //window call end
        } else if(json_obj[0].errorcode == 'Error' && json_obj[0].recommendation == '') {
            parent.create_match_split_window.window('window_match').progressOff();
            // DEBUG_PROCESS && console.log('SQL error on spa_schedule_deal_flow_optimization');
            var msg = json_obj[0].message;
            success_call(msg, 'error');
            parent.single_match_save_callback();
        } else if(json_obj[0].errorcode == 'Success') {
            parent.create_match_split_window.window('window_match').progressOff();
            success_call('Schedule deals have been created successfully.', 'error');
            parent.single_match_save_callback();
        }

    }

    function violation_available_inv_rec(box_div, rec_value) {
        // var total_inv = $('.total_beg_inv_rec').filter('[loc_id="' + box_div.attr('from_loc_id') + '"]').attr('value');
        var total_inv = parseInt(total_pos_begin);
        var total_inv_compare = total_inv;
        var td_index = box_div.closest('td').index();
        var common_proxy_vol_used = 0;
        /* proxy adjust */
        if($('.total_end_inv_rec').filter('[common_proxy_pos]').filter('[proxy_type="cv"]').length > 0) {
            common_proxy_vol_used = 1;
            var common_proxy_pos = $('.total_end_inv_rec').filter('[common_proxy_pos]').filter('[loc_id="' + box_div.attr('from_loc_id') + '"]').attr('common_proxy_pos');
            total_inv = parseInt(common_proxy_pos);
            if($('.edited_info_detail', box_div).length > 0) {
                var manual_sch_vol_own = 0;
                $('.edited_info_detail', box_div).each(function(i) {
                    manual_sch_vol_own += parseInt($(this).attr('delivery'));
                });

                //alert(manual_sch_vol_own);
                total_inv += manual_sch_vol_own;
            }

            //alert(common_proxy_pos);

        }
        /* proxy adjust */

        var sum_of_rec = parseInt(rec_value);
        $('.rec_del_div1', box_div.closest('tr')).each(function(index) {
            if ($(this).closest('td').index() != td_index)
                sum_of_rec += parseInt($(this).attr('value'));
        });
        if (sum_of_rec > Math.abs(total_inv_compare) && box_div.attr('from_loc_grp_name') != 'Storage') {
            //success_call('You do not have enough Receipt volume to schedule. Please re-enter a valid value.', 'error');
            //return false;

            //letting allocate freely
            success_call('Receipt Volume limit exceeded.', 'error');
        }
        //alert(total_inv+':'+sum_of_rec);
        if(common_proxy_vol_used == 1) {
            sum_of_del = parseInt(rec_value) - box_div.attr('solver_result_rec'); //all sum has been on common proxy vol
        }
        var rec_end_inv = total_inv - sum_of_rec;
        return parseInt(rec_end_inv);
    }

    function violation_available_inv_del(box_div, del_value) {
        var td_index = box_div.closest('td').index();
        // var total_inv = parseInt($('.total_beg_inv_del').filter('[loc_id="' + box_div.attr('to_loc_id') + '"]').attr('value'));
        var total_inv = parseInt(total_pos_begin);
        var total_inv_compare = total_inv;
        var common_proxy_vol_used = 0;
        /* proxy adjust */
        if($('.total_end_inv_del').filter('[common_proxy_pos]').filter('[proxy_type="cv"]').length > 0) {
            common_proxy_vol_used = 1;
            var common_proxy_pos = $('.total_end_inv_del').filter('[common_proxy_pos]').filter('[loc_id="' + box_div.attr('to_loc_id') + '"]').attr('common_proxy_pos');
            total_inv = parseInt(common_proxy_pos);
            if($('.edited_info_detail', box_div).length > 0) {
                var manual_sch_vol_own = 0;
                $('.edited_info_detail', box_div).each(function(i) {
                    manual_sch_vol_own += parseInt($(this).attr('delivery'));
                });
                //alert(manual_sch_vol_own);
                total_inv -= manual_sch_vol_own;
            }

            //alert(common_proxy_pos + '::');

        }
        /* proxy adjust */

        var tr_index = box_div.closest('tr').index();//alert('tr_indx:'+(tr_index-1));alert('td_indx:'+(td_index + 1));
        var sum_of_del = parseInt(del_value);
        var tr_context = $('.rec_del_div2');
        tr_context.each(function(index) {
            if ($(this).closest('tr').index() != tr_index) {
                sum_of_del += parseInt($(this).attr('value'));
            }

        });

        if (sum_of_del > Math.abs(total_inv_compare) && $('.to_loc_grp_name', box_div).text() != 'Storage') {
            //success_call('You do not have enough Delivery volume to match. Please re-enter a valid value.', 'error');
            //return false;

            //letting allocate freely
            success_call('Delivery Volume limit exceeded.', 'error');
        }
        if(common_proxy_vol_used == 1) {
            sum_of_del = parseInt(del_value) - box_div.attr('solver_result_del'); //all sum has been on common proxy vol
        }
        var del_end_inv = (total_inv + sum_of_del);

        //alert(alertdel_end_inv);
        return parseInt(del_end_inv);
    }

    function keypressed_pop_ip(obj, flag, event) {
        //console.log(event);
        //event.stopPropagation();
        //alert($(obj).closest('tr').attr('single_path_id'));
        var obj = $(obj);
        var box_div = $('.box_div');
        //var path_loss_factor = parseFloat($('.path_dd option:selected').attr('path_loss_factor'));
        var path_loss_factor = $('.path_lf', obj.closest('tr')).val();

        if(flag == 'r') {
            popup_class = '.pop_ip2';
        } else if(flag == 'd') {
            popup_class = '.pop_ip1';
        } else if(flag == 'l') {
            popup_class = 'lf';
        } else {
            popup_class = '';
        }

        if(popup_class == '') {
            return;
        } else if(popup_class == 'lf') {
            setTimeout(function(){
                var rec_vol = parseInt(Number($('.pop_ip1', obj.closest('tr')).val()));
                var del_vol = parseInt(Number($('.pop_ip2', obj.closest('tr')).val()));
                //var lf = parseFloat(Number($('.path_lf', obj.closest('tr')).val()));
                var lf = $('.path_lf', obj.closest('tr')).val();

                if(isNaN(rec_vol) || rec_vol == '') {
                    rec_vol = 0;
                }
                if(isNaN(del_vol) || rec_vol == '') {
                    del_vol = 0;
                }
                if(isNaN(lf) || lf == '') {
                    lf = -1;
                }


                if(lf > -1 && (rec_vol > 0 || del_vol > 0)) {
                    if(rec_vol == 0) {
                        rec_vol = (del_vol / (1 - lf)).toFixed(0);
                    } else if(del_vol == 0) {
                        del_vol = (rec_vol * (1 - lf)).toFixed(0);
                    } else {
                        del_vol = (rec_vol * (1 - lf)).toFixed(0);
                    }
                    //console.log(rec_vol + ':' + lf + ':' + del_vol);
                    $('.pop_ip1', obj.closest('tr')).val(rec_vol);
                    $('.pop_ip2', obj.closest('tr')).val(del_vol);
                    $('.pop_ip1', obj.closest('tr')).trigger('onpaste');

                } else {
                    return;
                }
            });
            return;
        }

        //var popup_class = (flag == 'r') ? '.pop_ip2' : '.pop_ip1';
        var calc_value = '';


        var segmentation = $('.contract_id_cd', obj.closest('tr')).attr('segmentation');
        var path_ormdq = parseInt($('.path_rmdq_cd', obj.closest('tr')).attr('ormdq')); //used path mdq instead of contract
        var contract_id = $('.contract_id_cd', obj.closest('tr')).text();
        var path_id = obj.closest('.tbl_contract_pop_up_body').attr('single_path_id');
        //alert(path_id);
        var box_id = $('#popup_data_hidden').attr('route_id');

        var td_id = $('#popup_data_hidden').attr('td_id');
        var edited_info_detail_obj = $('.edited_info', '#' + td_id);
        var edited_route = ($('li', edited_info_detail_obj).length > 0) ? true : false;

        var old_del_value = 0;
        if(edited_route) {
            old_del_value = parseInt($('#' + td_id +  ' .edited_info [contract_id="' + contract_id + '"]').attr('delivery'));
            old_del_value = isNaN(old_del_value) ? 0 : old_del_value;
        }
        var contract_rmdq = parseInt($('.contract_rmdq_cd', obj.closest('tr')).attr('ormdq'));
        //alert(contract_rmdq);

        var del_vol_used = fx_calc_crmdq(contract_id, box_id);
        var del_vol_used_path = fx_calc_prmdq(path_id, box_id);
        //wait for value to be pasted
        setTimeout(function(){
            var input_value = parseInt(Number(obj.val()));
            //obj.attr('value', input_value);
            //console.log(input_value);

            var delivery_value = input_value;
            var receipt_value = input_value;
            var instant_rmdq = path_ormdq;
            var instant_crmdq = contract_rmdq;
            if(!isNaN(input_value) && input_value != 0) {
                //contract_ormdq += old_del_value;
                //alert(contract_ormdq);

                if (flag == 'r') {
                    calc_value = ((input_value) * (1 - path_loss_factor)).toFixed(0);
                    delivery_value = calc_value;
                } else {
                    calc_value = ((input_value) / (1 - path_loss_factor)).toFixed(0);
                    receipt_value = calc_value;
                }
                //console.log(input_value +':'+path_loss_factor + ':' + delivery_value);


                $(popup_class, obj.closest('tr')).val(calc_value);
                //alert(path_ormdq +'-' +del_vol_used_path +'-'+ delivery_value);
                instant_rmdq = path_ormdq - del_vol_used_path - delivery_value; //logic to subtract delivery side

                instant_crmdq = contract_rmdq - del_vol_used - delivery_value;
                //alert(contract_rmdq +'-'+ del_vol_used +'-'+ delivery_value);
                $('.path_rmdq_cd', obj.closest('tr')).attr('value', instant_rmdq);
                $('.path_rmdq_cd', obj.closest('tr')).text(format_number_to_comma_separated(instant_rmdq));
                $('.contract_rmdq_cd', obj.closest('tr')).attr('value', instant_crmdq);
                $('.contract_rmdq_cd', obj.closest('tr')).text(format_number_to_comma_separated(instant_crmdq));

                var saved_value2 = $(popup_class, obj.closest('tr')).attr('saved_value');
                var saved_value1 = $(obj).attr('saved_value');

                adjust_total_mdq(obj.closest('.tbl_contract_pop_up'), false);
                if(path_ormdq < delivery_value && call_from != 'book_out') { //no path rmdq red bg validation incase of book out
                    $('.pop_ip2', obj.closest('tr')).addClass('popup_invalid_mdq');
                } else {
                    $('.pop_ip2', obj.closest('tr')).removeClass('popup_invalid_mdq');
                }



                //contract validation for segmentation and non-segmentation case
				if(call_from != 'book_out') { //no validation for book out case
                if(segmentation == 'n') {
                    if(contract_rmdq < (parseInt(receipt_value) + parseInt(compare_cmdq_gbl))) {
                        success_call('Non-Segmented Contract MDQ has been exceeded.', 'error');
                        /*
                        dhtmlx.message({
                           title: 'Error',
                           type: 'alert-error',
                           text: 'Non-Segmented Contract MDQ has been exceeded.'
                        });
                        */

                        /* //let mdq exceed crmdq
                        obj.val(saved_value1);
                        $(popup_class, obj.closest('tr')).val(saved_value2);
                        $('.path_rmdq_cd', obj.closest('tr')).attr('value', path_ormdq);
                        $('.path_rmdq_cd', obj.closest('tr')).text(format_number_to_comma_separated(path_ormdq));
                        $('.contract_rmdq_cd', obj.closest('tr')).attr('value', contract_rmdq);
                        $('.contract_rmdq_cd', obj.closest('tr')).text(format_number_to_comma_separated(contract_rmdq));
                        $('.pop_ip2', obj.closest('tr')).removeClass('popup_invalid_mdq');
                        adjust_total_mdq(obj.closest('.tbl_contract_pop_up'), false);
                        */
                    }
                } else {//in case of segmentation contract
                    if(contract_rmdq < receipt_value) {
                        success_call('Segmented Contract MDQ has been exceeded.', 'error');
                        /*
                        dhtmlx.message({
                           title: 'Error',
                           type: 'alert-error',
                           text: 'Segmented Contract MDQ has been exceeded.'
                        });
                        */

                        /* //let mdq exceed crmdq
                        obj.val(saved_value1);
                        $(popup_class, obj.closest('tr')).val(saved_value2);
                        $('.path_rmdq_cd', obj.closest('tr')).attr('value', path_ormdq);
                        $('.path_rmdq_cd', obj.closest('tr')).text(format_number_to_comma_separated(path_ormdq));
                        $('.contract_rmdq_cd', obj.closest('tr')).attr('value', contract_rmdq);
                        $('.contract_rmdq_cd', obj.closest('tr')).text(format_number_to_comma_separated(contract_rmdq));
                        $('.pop_ip2', obj.closest('tr')).removeClass('popup_invalid_mdq');
                        adjust_total_mdq(obj.closest('.tbl_contract_pop_up'), false);
                        */
                    }
                }
				}



            } else {
                obj.val('');
                $(popup_class, obj.closest('tr')).val('');
                $('.path_rmdq_cd', obj.closest('tr')).attr('value', instant_rmdq - del_vol_used_path);
                $('.path_rmdq_cd', obj.closest('tr')).text(format_number_to_comma_separated(instant_rmdq - del_vol_used_path));
                $('.contract_rmdq_cd', obj.closest('tr')).attr('value', contract_rmdq - del_vol_used);
                $('.contract_rmdq_cd', obj.closest('tr')).text(format_number_to_comma_separated(contract_rmdq - del_vol_used));
                $('.pop_ip2', obj.closest('tr')).removeClass('popup_invalid_mdq');
                adjust_total_mdq(obj.closest('.tbl_contract_pop_up'), true);

                /*//set next row rec value and trigger the event
                var next_spath_obj_tr = $(obj.closest('tr')).next().filter('.tbl_contract_pop_up_body');
                if(next_spath_obj_tr.length > 0) {
                    $('.pop_ip1', next_spath_obj_tr).attr('value', '');
                    setTimeout(function(){
                        $('.pop_ip1', next_spath_obj_tr).trigger('onpaste')
                        ,50
                    });
                }
                */
            }
            //set next row rec value and trigger the event
            //console.log('delivery_value:' + delivery_value);


            if($('.is_group_path').is(':checked')) {
                if(flag == 'r' || flag == 'l') {
                    var next_spath_obj_tr = $(obj.closest('tr')).next().filter('.tbl_contract_pop_up_body');
                    if(next_spath_obj_tr.length > 0) {
                        $('.pop_ip1', next_spath_obj_tr).val(delivery_value);
                        //setTimeout(function(){
                        $('.pop_ip1', next_spath_obj_tr).trigger('onpaste');
                        //,500
                        //});
                    }
                }
                if(flag == 'd' ) {
                    var next_spath_obj_tr = $(obj.closest('tr')).prev().filter('.tbl_contract_pop_up_body');
                    if(next_spath_obj_tr.length > 0) {
                        $('.pop_ip2', next_spath_obj_tr).val(receipt_value);
                        //setTimeout(function(){
                        $('.pop_ip2', next_spath_obj_tr).trigger('onpaste');
                        //,500
                        //});
                    }
                }
            }




            /*
            //set prev row rec value and trigger the event
            var prev_spath_obj_tr = $(obj.closest('tr')).prev().filter('.tbl_contract_pop_up_body');
            if(prev_spath_obj_tr.length > 0) {
                $('.pop_ip2', prev_spath_obj_tr).val(receipt_value);
                //setTimeout(function(){
                    $('.pop_ip2', prev_spath_obj_tr).trigger('onpaste');
                    //,500
                //});
            }
            */
        }, 50);
        lastest_edit_popup_field = flag;

    }

    function adjust_total_mdq(obj, is_blank) {
        var receipt_total = 0;
        var delivery_total = 0;
        //var contract_rmdq_total = 0;
        var path_rmdq_total = 0;
        var obj = $(obj);
        //if (!is_blank) {

        // commented since sum is not required for total rec/delivery (taking first value)
        if($('.is_group_path').is(':checked')) {
            receipt_total  = isNaN(parseInt($('.pop_ip1', obj).eq(0).val())) ? 0 : parseInt($('.pop_ip1', obj).eq(0).val());
            delivery_total = isNaN(parseInt($('.pop_ip2', obj).eq(-1).val())) ? 0 : parseInt($('.pop_ip2', obj).eq(-1).val());


        } else {
            $('.pop_ip1', obj).each(function() {
                receipt_total  += isNaN(parseInt($(this).val())) ? 0 : parseInt($(this).val());
            });
            $('.pop_ip2', obj).each(function() {
                delivery_total += isNaN(parseInt($(this).val())) ? 0 : parseInt($(this).val());

            });
        }
        //}

        //taking minimum of values prmdq for total
        var prmdq_arr = [];
        $('.path_rmdq_cd', obj).each(function() {
            prmdq_arr.push($(this).attr('value'));
        });
        path_rmdq_total = parseInt(Math.min.apply(Math, prmdq_arr));
        path_rmdq_total = isNaN(path_rmdq_total) ? 0 : path_rmdq_total;

        $('.contract_receipt_total', obj).attr('value', receipt_total);
        $('.contract_delivery_total', obj).attr('value', delivery_total);
        $('.contract_rmdq_total', obj).attr('value', path_rmdq_total);

        $('.contract_receipt_total', obj).text(format_number_to_comma_separated(receipt_total));
        $('.contract_delivery_total', obj).text(format_number_to_comma_separated(delivery_total));
        $('.contract_rmdq_total', obj).text(format_number_to_comma_separated(path_rmdq_total));

    }

    function load_path_dd(box_id) {
        // Return location from and its position
		
		if (call_from == 'book_out') {
			box_id = -1;
		}
					
		
        var exec_call = {
            "action": "spa_flow_optimization",
            "flag": "y",
            "xml_manual_vol": box_id,
            "process_id": process_id_gbl
        };


        var result = adiha_post_data("return_json", exec_call, "", "", "fill_multiple_path", false);
    }

    function fill_multiple_path(json_route_path) {
        var json_route_path = $.parseJSON(json_route_path);
        var count_item = json_route_path.length;
        var path_name_modified = '';
        $('.path_dd').html('');
        for(i = 0; i < count_item; i++) {
            path_name_modified = json_route_path[i].path_name
            // + ' (PMDQ=' + format_number_to_comma_separated(json_route_path[i].path_mdq)
            // + '/CMDQ=' + format_number_to_comma_separated(json_route_path[i].contract_mdq) + ')';
            $('.path_dd').append(
                '<option '
                + ' path_id="' + json_route_path[i].path_id + '"'
                + ' path_name="' + json_route_path[i].path_name + '"'
                + ' path_priority="' + json_route_path[i].path_priority + '"'
                + ' path_loss_factor="' + json_route_path[i].path_loss_factor + '"'
                + ' path_mdq="' + json_route_path[i].path_mdq + '"'
                + ' path_ormdq="' + json_route_path[i].path_ormdq + '"'
                + ' first_path_mdq="' + json_route_path[i].first_path_mdq + '"'
                + ' contract_mdq="' + json_route_path[i].contract_mdq + '"'
                + ' contract_id="' + json_route_path[i].contract_id + '"'
                + ' table_id="' + json_route_path[i].table_id + '"'
                + ' group_path="' + json_route_path[i].group_path + '"'
                + '>' + path_name_modified);
        }
    }

    function load_contract_dd(box_div) {
        //var box_div = $(obj).closest('.box_div');
        var path_id = $('.path_dd option:selected').attr('path_id');
        var contract_id = $('.path_dd option:selected').attr('contract_id');
        var selected_table_id = $('.path_dd option:selected').attr('table_id');
        //var process_id = $('.process_id', box_div).text();
        var from_loc_id = $('.from_loc_id', box_div).text();
        var to_loc_id = $('.to_loc_id', box_div).text();
        var valid_paths_array = [];

        current_data_td_id = box_div.closest('.solver_data1').attr('id');
        //alert($('li', edited_info_detail_obj).length);
        var edited_info_detail_obj = $('.edited_info', '#' + current_data_td_id);
        edited_route = ($('li', edited_info_detail_obj).length > 0) ? true : false;
        //alert(edited_route);
        $('.template_content_cd').html('');
        //alert($('.path_dd option').html());
        $('.path_dd option').each(function(i) {
            //$('.path_dd option', box_div).each(function(i) {
            var receipt_total = 0;
            var delivery_total = 0;
            var rmdq_total = 0;
            var current_path_id = $(this).attr('path_id');
            var table_id = $(this).attr('table_id');
            var mdq_total = $(this).filter('[table_id="' + table_id + '"]').attr('first_path_mdq');
            //console.log(mdq_total);
            if(edited_route) {
                var edited_info_obj = $('.edited_info_detail', box_div).filter('[table_id="' + table_id + '"]');
                if(edited_info_obj.length != 0) {
                    receipt_total = edited_info_obj.filter('[table_id="' + table_id + '"]').attr('receipt_total');
                    delivery_total = edited_info_obj.filter('[table_id="' + table_id + '"]').attr('delivery_total');
                    rmdq_total = edited_info_obj.filter('[table_id="' + table_id + '"]').attr('rmdq_total');
                }

            } else {
                rmdq_total = $(this).filter('[table_id="' + table_id + '"]').attr('path_ormdq');
            }

            valid_paths_array.push(current_path_id);
            $('.template_content_cd').append(
                template_contract_detail(
                    {table_id: table_id
                        ,active_inactive: (selected_table_id == table_id) ? 'cd_active' : 'cd_inactive'
                        ,receipt_total: receipt_total
                        ,receipt_total_formatted: format_number_to_comma_separated(receipt_total)
                        ,delivery_total: delivery_total
                        ,delivery_total_formatted: format_number_to_comma_separated(delivery_total)
                        ,mdq_total: mdq_total
                        ,mdq_total_formatted: format_number_to_comma_separated(mdq_total)
                        ,rmdq_total: rmdq_total
                        ,rmdq_total_formatted: format_number_to_comma_separated(rmdq_total)

                    }
                )
            )


        });

        var box_id = parseInt($('.route_id', box_div).html());
		
		if(call_from == 'book_out') {
			box_id = -1;			
		}
		
        var exec_call = {
            "action": "spa_flow_optimization",
            "flag": "q",
            "xml_manual_vol": box_id,
            "process_id": process_id_gbl,
            "flow_date_from": flow_date_from
        };
        var result = adiha_post_data("return_json", exec_call, "", "", "fill_contract_detail", false);
        //$(".dhx_cell_layout").height(1000);
        //$(".dhx_cell_cont_layout").height(1000);
        //parent.new_win.setDimension(null, $("#my_popup").height() + 50);
    }

    function path_dd_change(obj) {
        var table_id = $('.path_dd option:selected').attr('table_id');
        $('.template_content_cd .cd_active').removeClass('cd_active').addClass('cd_inactive');
        $('#' + table_id).removeClass('cd_inactive').addClass('cd_active');
    }

</script>

<style>
    #my_popup {
        width: auto;

    }

</style>