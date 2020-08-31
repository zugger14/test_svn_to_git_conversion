<?php
/**
* Flow optimization template screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <?php require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <?php 
    $php_script_loc = $app_php_script_loc;
    //$flow_optimization_theme_css = $php_script_loc . '/components/lib/adiha_dhtmlx/themes/dhtmlx_' . $theme. '/flow_optimization.css';
      $flow_optimization_theme_css = $php_script_loc . '/components/lib/adiha_dhtmlx/flow_optimization.css';
    ?>
    <!--<script type="text/javascript" src="<?php echo $php_script_loc; ?>components/ui/underscore.min.js"></script>
    <script src="<?php echo $php_script_loc; ?>/components/jQuery/modal_popup_jquery/popModal.js"></script>-->
    <script src="<?php echo $php_script_loc; ?>/components/jQuery/js_spinner/spin.js"></script>
    
    <link type="text/css" rel="stylesheet" href="<?php echo $flow_optimization_theme_css; ?>"/>
    
</head>
<body style="overflow: auto; height: auto; width: auto;">
    <?php
    $form_name = 'form_flow_optimization';
    $form_name = 'form_flow_optimization';
    $flow_date_from = get_sanitized_value($_POST['flow_date_from']);
    $flow_date_to = get_sanitized_value($_POST['flow_date_to']);
    $priority_from = get_sanitized_value($_POST['priority_from']);
    $priority_to = get_sanitized_value($_POST['priority_to']);
    $path_priority = get_sanitized_value($_POST['path_priority']);
    $opt_objectives = get_sanitized_value($_POST['opt_objectives']);
    $receipt_group = get_sanitized_value($_POST['receipt_group']);
    //$receipt_group = '24';//hardcoded
    $receipt_location_name = get_sanitized_value($_POST['receipt_location_name']);
    $delivery_group = get_sanitized_value($_POST['delivery_group']);
    //$delivery_group = '25';//hardcoded
    $delivery_location_name = get_sanitized_value($_POST['delivery_location_name']);
    $pipeline = get_sanitized_value($_POST['pipeline']);
    $contract = get_sanitized_value($_POST['contract']);
    $subsidiary_id = get_sanitized_value($_POST['subsidiary_id']);
    $strategy_id = get_sanitized_value($_POST['strategy_id']);
    $book_id = get_sanitized_value($_POST['book_id']);
    $sub_book_id = get_sanitized_value($_POST['sub_book_id']);
    $uom = get_sanitized_value($_POST['uom']);
    $uom_name = get_sanitized_value($_POST['uom_name']);
    $delivery_path = get_sanitized_value($_POST['delivery_path']);
    $hide_pos_zero = get_sanitized_value($_POST['hide_pos_zero']);
    $reschedule = get_sanitized_value($_POST['reschedule']);
    $book_structure_text = get_sanitized_value($_POST['book_structure_text']);
	$granularity = get_sanitized_value($_POST['granularity'] ?? '');
	$period_from = get_sanitized_value($_POST['period_from'] ?? '');
	$SPA_FLOW_OPTIMIZATION_SP = ($granularity == '982' ? 'spa_flow_optimization_hourly' : 'spa_flow_optimization');
	$dest_sub_book_url = "EXEC $SPA_FLOW_OPTIMIZATION_SP @flag='d'";
    $result_sub_book = readXMLURL2($dest_sub_book_url);
    $json_sub_book = json_encode($result_sub_book);
    $call_from = get_sanitized_value($_POST['call_from']);
    ?> 
    
    <!--Start of flow optimization table-->
    <form name="<?php echo $form_name; ?>" style="height: 100%;">
        <table border="0" width="100%" height="100%" cellpadding="0" cellspacing="0"> 
            <tr> 
                <td valign="top">
                    
                        
                            <div class="flow_optimization_grid autonom_disabled_area" >
                            <!-- Division for div-->
                            <div id="loading"></div>
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
                                                total_oprmdq=""
                                                from_pos_beg=""
                                                from_pos_end="" 
                                                to_pos_beg=""
                                                to_pos_end=""
                                                path_ids=""
                                                solver_result_rec="0"
                                                solver_result_del="0"
                                                path_id_selected=""
                                                contract_id_selected=""
                                                first_hour_rec_vol="" 
                                                first_hour_del_vol=""
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
                                                <!-- remove + text -->
                                                <div title="Setup Delivery Path" class="path_insert" onclick="fx_open_delivery_path_window(this, 'i')"> </div>
                                                <div class="center_div inner_div" <?php
                                                if ($call_from != 'flow_deal_match') {
                                                    echo 'onclick="popup_modal_box(this)"';
                                                }
                                                ?>
                                                >
                                                     <div class="rec_del_div mdq_div">
                                                        <span title="Rec/Del Detail" class="rd_mdq_info">Rec/Del:(<span class="rec_del_div1" value="0">0</span>/<span class="rec_del_div2" value="0">0</span>)</span>
                                                        
                                                     </div>
                                                </div>
                                                <!-- remove M text -->
                                                <?php
                                                if ($call_from != 'flow_deal_match') {
                                                    echo '<div style="display: none;" title="Flow Deal Match" class=" center_div match" onclick="open_match(this)"></div>';
                                                }
                                                ?>

                                               
                                                <div class="bottom_div inner_div"></div>

                                            </div>

                                            
                                        </div>
                                    </div>
                                    <div id="path_list_div" class="popup_multipath" style="display: none;">
                                        <ul class="path_list_ul">
                                            <li>path1</li>
                                            <li>path2</li>
                                        </ul>
                                    </div>
                                    
                                    <div id="my_popup" style="display: none;">
                                        <div class="popup_body" >
                                            <div class="content_popup">
                                                <span style="display: none;" id="popup_data_hidden"></span>
                                                                                                
                                                <table class="popup_tbl" border=0>
                                                    <tr>
                                                        <td width="100px">From :</td><td><span class="popup_from_loc"></span></td>
                                                    </tr>
                                                    <tr>    
                                                        <td>To :</td><td><span class="popup_to_loc"></span></td>
                                                    </tr>
                                                    <tr>
                                                        <td>Path:</td>
                                                        <td>
                                                            <select class="path_dd" onchange="path_dd_change(this)">
                                                            </select>
                                                            <input disabled="true" class="is_group_path" type="checkbox" checked="true" style="vertical-align: bottom; margin: 0px 0 1px 2px;" /> Group Path
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">Contract Detail:</td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" class="template_content_cd"></td>
                                                    </tr>
                                                    <tr class="popup_tr_sc" style="display: none; ">
                                                        <td style="padding-top: 5px;">Storage Contract:</td>
                                                        <td style="padding-top: 5px;">
                                                            <select class="storage_contract_dd">
                                                             <option storage_asset_id="1">35-Powder Wash MM-contract1</option>
                                                             <option storage_asset_id="2">loc1-c2</option>
                                                            </select>
                                                            <input type="checkbox" class="chk_storage_deal" checked="true" style="vertical-align: bottom; margin: 0 0 2px 0;" />
                                                        </td>
                                                    </tr>
                                                    
                                                </table>
                                            </div>
                                            <div id="save_popup"><input onclick="save_popup(this)" type="button" value="Save" data-popmodal-but="ok" id="pop_up_save" /></div>
                                        </div>
                                    </div>
                                    
                                </div> 
                            <!-- Division for div End-->
                            </div>
                         
                                 
                    
                    <div class="clear div_bottom_clear" style="height: 0px;"></div>
                    
                </td> 
            </tr> 
        </table>
        
        <span id="filter_set_hidden" style="display: none;"
            flow_date_from=""
            flow_date_to=""
            priority_from=""
            priority_to=""
            receipt_group=""
            delivery_group=""
            receipt_loc=""
            delivery_loc=""
            path_priority="" 
            contract_ids=""
            pipeline_ids=""
            opt_objective=""
        ></span>
        
    </form> 
</body>
<script type="text/javascript"> 
    var DEBUG_PROCESS = false;
    var ADJUST_VALUE = 1;
    var ADDED_COLS = 4 + ADJUST_VALUE;
    var TOTAL_POS = 1 + ADJUST_VALUE;
    var BEG_POS = 2 + ADJUST_VALUE;
    var END_POS = 3 + ADJUST_VALUE;
    var LOC_POS = 4 + ADJUST_VALUE;
    var hide_filter_state = false;
    
    var flow_date_from = '<?php echo $flow_date_from; ?>';
    var flow_date_to = '<?php echo $flow_date_to; ?>';
    var priority_from = '<?php echo $priority_from; ?>';
    var priority_to = '<?php echo $priority_to; ?>';
    var path_priority = '<?php echo $path_priority; ?>';
    var opt_objectives = '<?php echo $opt_objectives; ?>';
    var receipt_group = '<?php echo $receipt_group; ?>';
    var receipt_location_name= '<?php echo $receipt_location_name; ?>';
    var delivery_group= '<?php echo $delivery_group; ?>';
    var delivery_location_name= '<?php echo $delivery_location_name; ?>';
    var pipeline= '<?php echo $pipeline; ?>';
    var contract= '<?php echo $contract; ?>';
    var subsidiary_id= '<?php echo $subsidiary_id; ?>';
    var strategy_id= '<?php echo $strategy_id; ?>';
    var book_id= '<?php echo $book_id; ?>';
    var sub_book_id= '<?php echo $sub_book_id; ?>';
    var uom = '<?php echo $uom; ?>';
	var uom_name = '<?php echo $uom_name; ?>';
    var delivery_path = '<?php echo $delivery_path; ?>';
    var call_from = '<?php echo $call_from; ?>';
    var hide_pos_zero = '<?php echo $hide_pos_zero; ?>';
    var reschedule = '<?php echo $reschedule; ?>';
    var book_structure_text  = '<?php echo $book_structure_text ; ?>';
	
	var granularity  = '<?php echo $granularity ; ?>';
	var SPA_FLOW_OPTIMIZATION_SP = '<?php echo $SPA_FLOW_OPTIMIZATION_SP ; ?>';
	
	var period_from  = '<?php echo $period_from ; ?>';
    
    //window scroll function event
    window.onscroll = fx_onscroll;
    function fx_onscroll() {
        //alert(1);
        var timer = 0, delay = 100;
        //console.log(delay);
        
        
        if (timer) {
            clearTimeout(timer);
            timer = 0;
        }
        timer = setTimeout(fx_scrolling_handler, delay);
    }
    function fx_scrolling_handler() {
        var grid_pos = $('.flow_optimization_grid').offset();   
        //console.log(JSON.stringify(grid_pos));         
        if(col > 0) {
            var scroll_top = $(document).scrollTop();
            var scrolling_loc_cols = $('.scrolling_div_cols');
            var loc_box_top = $('.frame_tbl tr:nth-child(' + ADDED_COLS + ') td:nth-child(' + BEG_POS + ')').offset().top - scroll_top;
            //console.log(loc_box_top +':'+ grid_pos.top)
            var is_scroll_top = (loc_box_top < grid_pos.top ? true : false);
            
            if(is_scroll_top) {
                scrolling_loc_cols.addClass('scrolled_d');
                scrolling_loc_cols.offset({top: scroll_top});//.offset({top: grid_pos.top});
                $('.d_inv_appended').css('display', 'inline');
                $('.d_inv_appended').attr('disabled', true);
                scrolling_loc_cols.css('height', '45px');
                $('a', scrolling_loc_cols).css('color', '#fff');
                
            } else {
                scrolling_loc_cols.removeClass('scrolled_d');
                scrolling_loc_cols.removeAttr('style');
                $('a', scrolling_loc_cols).removeAttr('style');
                $('.d_inv_appended').css('display', 'none');
            }    
        }
        
        if(row > 0) {
            var scroll_left = $(document).scrollLeft();
            var scrolling_loc_rows = $('.scrolling_div_rows', '.frame_tbl');
            var loc_box_left = $('.frame_tbl tr:nth-child(' + BEG_POS + ') td:nth-child(' + ADDED_COLS + ')').offset().left - scroll_left;
            var is_scroll_left = (loc_box_left < grid_pos.left ? true : false);
            
            if(is_scroll_left ) {
                scrolling_loc_rows.addClass('scrolled_r');
                scrolling_loc_rows.offset({left: scroll_left});
                $('.r_inv_appended').css('display', 'inline');
                $('.r_inv_appended').attr('disabled', true);
                scrolling_loc_rows.css('height', '45px');
                $('a', scrolling_loc_rows).css('color', '#fff');
                
                if(is_scroll_top) {
                    var scrolled_cell_right_pos_s = scrolling_loc_rows.eq(0).offset().left + scrolling_loc_rows.eq(0).outerWidth();
                    var scrolled_obj_d = $('.scrolled_d');
                    var scrolled_obj_r = $('.scrolled_r');
                    
                    scrolled_obj_d.each(function(i) {
                        
                        if((scrolled_obj_r.eq(0).offset().left + 167) >= $(scrolled_obj_d[i]).offset().left) {
                            $(scrolled_obj_d[i]).css('visibility', 'hidden');   
                        } else {
                            $(scrolled_obj_d[i]).css('visibility', 'visible');   
                        }
                         
                    });
                } else {
                    
                }
            } else {
                scrolling_loc_rows.removeClass('scrolled_r');
                scrolling_loc_rows.removeAttr('style');
                $('.r_inv_appended').css('display', 'none');
                $('a', scrolling_loc_rows).removeAttr('style');
                if(col > 0) scrolling_loc_cols.css('visibility', 'visible');
            }    
        }
    }  
    
    $(function() {
        pre_loading(0);
        dhx_wins = new dhtmlXWindows();
        
    });
    
    
    //CLOSE MULTIPATH POPUP WHEN CLICK OUTSIDE
    $(document).click(function(event) {
        if (event.target.className != 'del_path_link') {
            $('.popup_multipath').hide();    
        }
    });
    $('.popup_multipath').click(function(event) {
        $('.popup_multipath').show();
        event.stopPropagation();
    });
    //CLOSE SCHEDULE POPUP WHEN CLICK OUTSIDE
    $(document).click(function(event) {
        //alert(event.target.className + ':' + $(event.target).closest('.center_div').length);
        if (event.target.className != 'center_div' && $(event.target).closest('.center_div').length == 0) {
            $('#my_popup').hide();    
        }
    });
    $('#my_popup').click(function(event) {
        if(event.target.id == 'pop_up_save') {
            $('#my_popup').hide();
        } else {
            $('#my_popup').show();
        }
        
        event.stopPropagation();
    });
    
    //HIDE ROW/COL WITH ZERO POSITION
    function fx_hide_position_zero(is_hide_zero) {
        
        if (is_hide_zero) {
            //RECEIPT HIDE SHOW
            $('.inv_zero_r').hide();
            
            //DELIVERY HIDE SHOW
            var zero_class_loop = $('.inv_zero_d');
            zero_class_loop.each(function(index) {
               var td_index = $(this).closest('td').index();
               
               var inner_loop1 = $('.frame_tbl tr:lt('+ADDED_COLS+') td:nth-child(' + (td_index + 1) + ')');
               inner_loop1.each(function(index1) {
                $(this).hide();
               });
               
               var inner_loop = $('.frame_tbl tr:gt('+END_POS+') td:nth-child(' + td_index + ')');
               inner_loop.each(function(index1) {
                $(this).hide();
               }); 
            });
                
        } else {
            //RECEIPT HIDE SHOW
            ///$('.inv_zero_r').not('.nowhere_to_go_from').show();
            $('.inv_zero_r').show();
            
            //DELIVERY HIDE SHOW
            var zero_class_loop = $('.inv_zero_d');
            zero_class_loop.each(function(index) {
               var td_index = $(this).closest('td').index();
               
               ///var inner_loop1 = $('.frame_tbl tr:lt(4) td:nth-child(' + (td_index + 1) + ')').not('.nowhere_to_go_to');
               var inner_loop1 = $('.frame_tbl tr:lt('+ADDED_COLS+') td:nth-child(' + (td_index + 1) + ')');
               //var inner_loop1 = $('.frame_tbl tr:lt(4) td:nth-child(' + (td_index + 1) + ')');
               inner_loop1.each(function(index1) {
                $(this).show();
               });
               
               ///var inner_loop = $('.frame_tbl tr:gt(3) td:nth-child(' + td_index + ')').not('.nowhere_to_go_to');
               var inner_loop = $('.frame_tbl tr:gt('+END_POS+') td:nth-child(' + td_index + ')');
               //var inner_loop = $('.frame_tbl tr:gt(3) td:nth-child(' + td_index + ')');
               inner_loop.each(function(index1) {
                $(this).show();
               }); 
            });
            
        }
    }
          
    function supply_demand_align() {
        var w = $('.flow_optimization_grid').width();
        if ($('.frame_tbl').width() > w) {
            w = w/2 - 100;
            $('.demand_td').css('text-align', 'left');
            $('.demand_td').css('padding-left', w + 'px');
        }
        
        var h = $('.flow_optimization_grid').height();
        if ($('.frame_tbl').height() > h) {
            //console.log($('.frame_tbl').height() + ':' + $('.flow_optimization_grid').height());
            h = h/2-50;
            $('.supply_td').css('vertical-align', 'top');
            $('.supply_td').css('padding-top', h + 'px');
        }
    }
    
      
</script> 
    
<!-- Division for div-->
<style>

</style>
<script type="text/javascript">

    // <td class=\"header_cname\">Path</td>\
    // <td class=\"header_pipeline\">Pipeline</td>\

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

    // <td class=\"contract_name_cd\"><%= contract_name %></td>\
    // <td class=\"path_pipeline\"><%= path_pipeline %></td>\

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
            style=\"padding: 1px 0px !important;\"\
            /></td>\
        <td ><input class=\"path_lf\" type=\"text\" style=\"width: 35px;\" \
            value=\"<%= loss_factor %>\" \
            ovalue=\"<%= loss_factor %>\" \
            onkeydown=\"keypressed_pop_ip(this, \'l\', event)\"\
            onpaste=\"keypressed_pop_ip(this, \'l\', event)\"\
            style=\"padding: 1px 0px !important;\"\
            /></td>\
        <td><input <%= is_del_disabled %> class=\"pop_ip2\" type=\"text\" size=\"3\" maxlength=\"7\" \
            saved_value=\"<%= delivery_saved %>\" \
            value=\"<%= delivery %>\" \
            onkeydown=\"keypressed_pop_ip(this, \'d\', event)\"\
            onpaste=\"keypressed_pop_ip(this, \'d\', event)\"\
            style=\"padding: 1px 0px !important;\"\
            /></td>\
        </tr>"
    );

    
    lastest_edit_popup_field = '';
    initial_table_frame = $('.first_frame_div').html();
    col = 0;
    row = 0;
    rec_loc_inv_json = [];
    del_loc_inv_json = [];
    lastest_click_btn = -1;
    rec_locs = '';
    del_locs = '';
    process_id_gbl = '';
    EXCEED_INFO_GBL = [];
    
    /*
     * [Initialize the grid when refresh is clicked]
     */
    function pre_loading(time_lag) {        
        var minor_location_r = receipt_group;
        var minor_location_d = delivery_group;
        
        $('#main_div').hide();
        $('#loading').show();
        
        var opts = {
          lines: 13, // The number of lines to draw
          length: 10, // The length of each line
          width: 2, // The line thickness
          radius: 10, // The radius of the inner circle
          corners: 1, // Corner roundness (0..1)
          rotate: 0, // The rotation offset
          direction: 1, // 1: clockwise, -1: counterclockwise
          color: '#000', // #rgb or #rrggbb or array of colors
          speed: 1, // Rounds per second
          trail: 60, // Afterglow percentage
          shadow: false, // Whether to render a shadow
          hwaccel: false, // Whether to use hardware acceleration
          className: 'spinner', // The CSS class to assign to the spinner
          zIndex: 2e9, // The z-index (defaults to 2000000000)
          top: '50%', // Top position relative to parent
          left: '50%' // Left position relative to parent
        };
        var target = document.getElementById('loading');
        

        if (call_from != 'match')spinner = new Spinner(opts).spin(target);
        
        setTimeout('btn_refresh()', time_lag);
    }
    
            
    function btn_refresh() {
        tool_bar_status(0);
        
        // Return location from and its position
        var exec_call_rec = {
                            "action": SPA_FLOW_OPTIMIZATION_SP, 
                           "flag": "l",
                            "sub": subsidiary_id,
                            "str": strategy_id,
                            "book": book_id,
                            "sub_book_id": sub_book_id,
                            "receipt_delivery":"FROM",
                            "flow_date_from":flow_date_from,
                            "flow_date_to":flow_date_to,
                            "major_location": receipt_group,
                            "minor_location": receipt_location_name,
                            "from_location":receipt_location_name,
                            "to_location": delivery_location_name,
                            "path_priority": path_priority,
                            "opt_objective": opt_objectives,
                            "priority_from": priority_from,
                            "priority_to": priority_to,
                            "contract_id": contract,
                            "pipeline_ids": pipeline,
                            "delivery_path": delivery_path,
							"uom": uom,
                            'hide_pos_zero': hide_pos_zero,
                            'reschedule': reschedule,
                            "granularity": granularity,
                            "period_from": period_from
                        };
        DEBUG_PROCESS && console.log(JSON.stringify(exec_call_rec));
        result = adiha_post_data("return_json", exec_call_rec, "", "", "get_location_data_rec", false);
        
        // Return location from and its position
        var exec_call_del = {
                            "action": SPA_FLOW_OPTIMIZATION_SP, 
                            "flag": "l",
                            "sub": subsidiary_id,
                            "str": strategy_id,
                            "book": book_id,
                            "sub_book_id": sub_book_id,
                            "receipt_delivery":"TO",
                            "flow_date_from":flow_date_from,
                            "flow_date_to":flow_date_to,
                            "major_location": delivery_group,
                            "minor_location": delivery_location_name,
                            "from_location":receipt_location_name,
                            "to_location": delivery_location_name,
                            "path_priority": path_priority,
                            "opt_objective": opt_objectives,
                            "priority_from": priority_from,
                            "priority_to": priority_to,
                            "contract_id": contract,
                            "pipeline_ids": pipeline,
                            "process_id": process_id_gbl,
                            "delivery_path": delivery_path,
							"uom": uom,
                            'hide_pos_zero': hide_pos_zero,
                            'reschedule': reschedule,
                            "granularity": granularity,
                            "period_from": period_from
                        };
        
        DEBUG_PROCESS && console.log(JSON.stringify(exec_call_del));
        result1 = adiha_post_data("return_json", exec_call_del, "", "", "get_location_data_del", false);
        
        $('.first_frame_div').html(initial_table_frame);
        
        draw_matrix(); 
        
        fill_loc_name_row_col();
        fill_beg_inv_row_col();
        
        $('#filter_set_hidden').attr({
            flow_date_from : flow_date_from,
            flow_date_to : flow_date_to,
            priority_from : priority_from,
            priority_to : priority_to,
            receipt_group : receipt_group,
            delivery_group : delivery_group,
            path_priority : path_priority,
            contract_ids : contract,
            pipeline_ids : pipeline,
            opt_objective : opt_objectives
        });
        
        
        if(row == 0 || col == 0) {
            
            DEBUG_PROCESS && console.log('nothing to plot:row(' + row + ') col(' + col + ')');
            first_row_col_span();
            $('#loading').hide();
            supply_demand_align();
            dhtmlx.message({
                type: 'alert-error',
                title: 'Error',
                text: 'Nothing to plot.'
            });
            
            if (call_from != 'flow_deal_match') {
                parent.flow_optimization.flow_optimization_menu.setItemEnabled('refresh');
            }
            return;
        }
        
        set_div_for_solver_data();
        DEBUG_PROCESS && console.log('##time00:'+Date.now());
        //## CLONE THE MDQ DIV
        var div_clone1_template = $('#div_clone1').clone();
        $('.solver_data1').html($(div_clone1_template));
        DEBUG_PROCESS && console.log('##time01:'+Date.now());
        
        var exec_call = {
                            "action": SPA_FLOW_OPTIMIZATION_SP, 
                            "flag": "c",
                            "sub": subsidiary_id,
                            "str": strategy_id,
                            "book": book_id,
                            "sub_book_id": sub_book_id,
                            "flow_date_from":flow_date_from,
                            "flow_date_to":flow_date_to,
                            "from_location": $('#filter_set_hidden').attr('receipt_loc'),
                            "to_location": $('#filter_set_hidden').attr('delivery_loc'),
                            "path_priority": path_priority,
                            "opt_objective": opt_objectives,
                            "priority_from": priority_from,
                            "priority_to": priority_to,
                            "contract_id": contract,
                            "pipeline_ids": pipeline,
                            "uom": uom,
                            'process_id': process_id_gbl,
                            'delivery_path': delivery_path ,
                            'reschedule': reschedule,
                            "granularity": granularity,
                            "period_from": period_from
                        };
        

        DEBUG_PROCESS && console.log(JSON.stringify(exec_call));
        
        var json_solver_data = adiha_post_data("return_json", exec_call, "", "", "fill_solver_data");
        
        if (call_from != 'flow_deal_match') {
            // Enable refresh button from parent window
            parent.flow_optimization.flow_optimization_menu.setItemEnabled('refresh'); 
        }
    }
    
    function get_location_data_rec(loc_data_json_rec) {
        
        rec_loc_inv_json = $.parseJSON(loc_data_json_rec);
        //console.dir(rec_loc_inv_json);
        row = rec_loc_inv_json.length;
        //console.log(row);
        if(row > 0) {
            process_id_gbl = rec_loc_inv_json[0].process_id;
        }
        
    }
    
    function get_location_data_del(loc_data_json_del) {
        del_loc_inv_json = $.parseJSON(loc_data_json_del);
        //console.log(del_loc_inv_json);
        col = del_loc_inv_json.length;
    }
    
    function fx_run_optimizer() {
        //alert(flow_date_from + ':' + flow_date_to);return;
        //multiple flow dates solver validation
        if(flow_date_from != flow_date_to) {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: "Solver process cannot be run for multiple flow dates."
            });
            return;
        }
        
        $('.solver_loading').show();
        $('.solver_data1').hide();
        setTimeout(run_optimizer_call, 500);
    }
    
    function run_optimizer_call() {  
        tool_bar_status(1);
        var box_ids_arr = new Array();
        $('.chk_cell input:checkbox', $('.frame_tbl .top_div:not(".no_path_cell")')).each(function(){
            var box_div = $(this).closest('.box_div');
            if (!$(this).closest('td').is(':hidden') && (box_div.attr('box_type') != 'to_proxy' || box_div.attr('box_type') != 'from_proxy')) {
                var route_id = $('.route_id', box_div).text();
                box_ids_arr.push(route_id);    
            }
        });
        
        $('.edited_info').html('');
        
        var exec_call = {
                            "action": SPA_FLOW_OPTIMIZATION_SP, 
                            "flag": "r",
                            "process_id": process_id_gbl,
                            "xml_manual_vol": box_ids_arr.join(',')
                        };
        DEBUG_PROCESS && console.log(JSON.stringify(exec_call));
        DEBUG_PROCESS && console.log('##time_s0:'+Date.now());
        var json_result = adiha_post_data('return_json', exec_call, '', '', 'fill_solver_data_r', false);
        $('.frame_tbl .edited_info').attr('edited_by', 'solver');
        
    }
    
    function reset_grid_data() {
                
        if (lastest_click_btn == -1 || lastest_click_btn == 0) {
            var alert_msg = (lastest_click_btn == -1) ? 'Please refresh the grid first.' : 'Please run solver first.';
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: alert_msg,
            });
        }
        tool_bar_status(2);
        fill_solver_data_r(reset_mdq);
    }
    function ajx_reset_grid_data(result) {
        //console.log(result);
        var json_obj = $.parseJSON(result);
    }
    function adjust_ending_inv() {
        
        //receipt
        var tr_context = $('.frame_tbl tbody tr:gt('+END_POS+')');
        var total_inv = 0;
        var sum_of_rec = 0;
        tr_context.each(function (index) {
            total_inv = parseInt($('.total_beg_inv_rec', $(this)).attr('value'));
            sum_of_rec = 0;
            $('.rec_del_div1', $(this)).each(function(index1) {
                if(granularity == '982') {// if hourly case pick first hour volume only
                    var box_rec_vol = parseInt($(this).closest('.box_div').attr('first_hour_rec_vol'));
                    box_rec_vol = (isNaN(box_rec_vol) ? 0 : box_rec_vol);
                    sum_of_rec += box_rec_vol;
                } else {
                    var box_rec_vol = parseInt($(this).attr('value'));
                    box_rec_vol = (isNaN(box_rec_vol) ? 0 : box_rec_vol);
                    sum_of_rec += box_rec_vol;
                }
               
            });
            $('.total_end_inv_rec', $(this)).attr('value', (total_inv - sum_of_rec));
            $('.r_inv_appended2', $(this)).attr('value', (total_inv - sum_of_rec));
            $('.total_end_inv_rec', $(this)).text(format_number_to_comma_separated(total_inv - sum_of_rec));
            $('.r_inv_appended2', $(this)).text(format_number_to_comma_separated(total_inv - sum_of_rec));
        });
        
        //delivery
        
        var col_count = col + ADDED_COLS;
        for(i = ADDED_COLS +1; i <= col_count; i++) {
            var td_index = i - 1;
            var total_inv = parseInt($('.frame_tbl tbody tr:nth-child('+BEG_POS+') td:nth-child(' + (td_index + 1) + ')').attr('value'));
            
            var sum_of_del = 0;
            var tr_context = $('.frame_tbl tbody tr:gt('+END_POS+') td:nth-child(' + (td_index) + ') .rec_del_div2');
            tr_context.each(function(index) {
                if(granularity == '982') {// if hourly case pick first hour volume only
                    var box_del_vol = parseInt($(this).closest('.box_div').attr('first_hour_del_vol'));
                    box_del_vol = (isNaN(box_del_vol) ? 0 : box_del_vol);
                    sum_of_del += box_del_vol;
                } else {
                    var box_del_vol = parseInt($(this).attr('value'));
                    box_del_vol = (isNaN(box_del_vol) ? 0 : box_del_vol);
                    sum_of_del += box_del_vol;
                }
            });
            var loc_type = $('.frame_tbl tbody tr:nth-child('+END_POS+') td:nth-child(' + (td_index) + ')').attr('loc_type');
            
            var del_end_inv = parseInt(total_inv + sum_of_del);// * -1;
            //console.log(total_inv + '+' +  sum_of_del);
            $('.frame_tbl tbody tr:nth-child('+END_POS+') td:nth-child(' + (td_index + 1) + ')').attr('value', del_end_inv);
            $('.frame_tbl tbody tr:nth-child('+(END_POS + 1)+') td:nth-child(' + (td_index + 1) + ') .d_inv_appended2').attr('value', del_end_inv);
            $('.frame_tbl tbody tr:nth-child('+END_POS+') td:nth-child(' + (td_index + 1) + ')').text(format_number_to_comma_separated(del_end_inv));
            $('.frame_tbl tbody tr:nth-child('+(END_POS + 1)+') td:nth-child(' + (td_index + 1) + ') .d_inv_appended2').text(format_number_to_comma_separated(del_end_inv));    
        }
        
        //copy proxy location end inv
        
        $('.total_end_inv_del').each(function(i) {
            var proxy_loc_id = '';
            if($(this).attr('proxy_loc_id') !== undefined && $(this).attr('proxy_type') == 'cv') {
                var proxy_end_inv = $('.total_end_inv_del').filter('[loc_id="' + $(this).attr('proxy_loc_id') + '"]').attr('value');
                proxy_loc_id = $(this).attr('proxy_loc_id');
                $(this).attr('value', proxy_end_inv);
                $(this).attr('common_proxy_pos', proxy_end_inv);
                $(this).text(format_number_to_comma_separated(proxy_end_inv));
            } 
            if(proxy_loc_id != '') {
                $('.total_end_inv_del').filter('[loc_id="' + proxy_loc_id + '"]').attr('common_proxy_pos', proxy_end_inv);
            }
            
            
        });
        
        
    }
    //## DRAW INITIAL MATRIX ON BASIS OF ROWS AND COLUMNS
    function draw_matrix() {
        $('.frame_tbl tr').each(function (index) {
            for(i = 0; i < col; i++) {
                ///if (index == 1) $(this).append('<td class="total_beg_inv_del nowhere_to_go_to"></td>');
                if (index == (BEG_POS - 1)) $(this).append('<td class="total_beg_inv_del"></td>');
                else if (index == (END_POS -1)) $(this).append('<td class="total_end_inv_del">0</td>');
                else $(this).append('<td>');      
            }
        });
        var total_cols = col + ADDED_COLS;
        var td_for_rows = '';
        for(i = 0; i < total_cols; i++) {
            if (i == (BEG_POS -1)) td_for_rows += '<td class="total_beg_inv_rec"></td>';
            else if (i == (END_POS -1)) td_for_rows += '<td class="total_end_inv_rec">0</td>';
            else td_for_rows += '<td></td>';
        }
        ///var last_tr = '<tr class="nowhere_to_go_from">' + td_for_rows + '</tr>';
        var last_tr = '<tr class="">' + td_for_rows + '</tr>';
    
        for(i = 0; i < row  ; i++) {
            $('.frame_tbl tbody').append(last_tr);    
        }  
        
        //$('.frame_tbl tr:nth-child(1) td:lt(3)').addClass('supply_td')
//        $('.frame_tbl tr:nth-child(2) td:lt(3)').addClass('supply_demand_bar')
//        $('.frame_tbl tr:nth-child(3) td:nth-child(1)').addClass('demand_td')  
    }
    
    //## FILL UP GRID WITH LOCATION NAMES
    function fill_loc_name_row_col() {
        var row_chk_html = '<div class="loc_name_wrapper scrolling_div_rows"><div class="row_chk_div" ><input type="checkbox" class="row_chk" onclick="row_chk_onchange(this)"/></div><div title="Location" class="row_label">';
        var col_chk_html = '<div class="loc_name_wrapper scrolling_div_cols"><div class="col_chk_div" ><input type="checkbox" class="col_chk" onclick="col_chk_onchange(this)"/></div><div title="Location" class="col_label">';
        var locname_colwise = $('.frame_tbl tbody tr:nth-child(' + ADDED_COLS + ') td:gt(' + (LOC_POS - 1) + ')');
        var del_loc_arr = new Array();
        locname_colwise.each(function(index){
            
            //if(del_loc_inv_json[index].is_proxy == 0) {
                del_loc_arr.push(del_loc_inv_json[index].location_id);
            //}
            
            $(this).html(col_chk_html + '<a location_id="' + del_loc_inv_json[index].location_id 
                + '" href="javascript:void(0);" onclick="fx_open_location(' + del_loc_inv_json[index].location_id + ')">' 
                + del_loc_inv_json[index].location_name 
                + '</a>'
                + '<span class="d_inv_appended" style="display: none;" onclick="">' 
                + ' (<span class="d_inv_appended1" value="' + del_loc_inv_json[index].position + '">' + format_number_to_comma_separated(del_loc_inv_json[index].position) + '</span>' 
                + '/<span class="d_inv_appended2" value="' + del_loc_inv_json[index].position + '">' + format_number_to_comma_separated(del_loc_inv_json[index].position) + '</span>)' 
                + '</span>' 
                
                
                //+ '<div class="clear"></div>'
                //+ '<div class="inv_scroll_rec" style="display: block;border:solid 1px black;">(<span class="beg_inv_scroll_rec"></span>/<span class="end_inv_scroll_rec"></span>)</div>'
            );
            $('.beg_inv_del', $(this)).text(del_loc_inv_json[index].position);
            //$('.beg_inv_del', $(this)).text(end_loc_inv_json[index].position);
        });
        
        var locname_rowwise = $('.frame_tbl tbody tr:gt(' + (LOC_POS - 1) + ') td:nth-child(' + ADDED_COLS + ')');
        var receipt_loc_arr = new Array();
        locname_rowwise.each(function(index){
            
            //if(rec_loc_inv_json[index].is_proxy == 0) {
                receipt_loc_arr.push(rec_loc_inv_json[index].location_id);
            //}
            
            $(this).html(row_chk_html + '<a location_id="' + rec_loc_inv_json[index].location_id 
                + '" href="javascript:void(0);" onclick="fx_open_location(' + rec_loc_inv_json[index].location_id + ')">' 
                + rec_loc_inv_json[index].location_name + '</a>'
                + '<span class="r_inv_appended" style="display: none;" onclick="">' 
                + ' (<span class="r_inv_appended1" value="' + rec_loc_inv_json[index].position + '">' + format_number_to_comma_separated(rec_loc_inv_json[index].position) + '</span>' 
                + '/<span class="r_inv_appended2" value="' + rec_loc_inv_json[index].position + '">' + format_number_to_comma_separated(rec_loc_inv_json[index].position) + '</span>)' 
                + '</span>'
                
            );
        }); 
        
        rec_locs = receipt_loc_arr.join(',');
        del_locs = del_loc_arr.join(',');
        
        DEBUG_PROCESS && console.log('rec_locs:'+rec_locs);
        DEBUG_PROCESS && console.log('del_locs:'+del_locs);
        //set_txt_receipt_loc_hidden_value(rec_locs);
        //set_txt_delivery_loc_hidden_value(del_locs);
        $('#filter_set_hidden').attr({
            receipt_loc : rec_locs,
            delivery_loc : del_locs  
        })
        
                
    }
    
    //FORMAT NUMBER DATA TO EN-US NUMBER FORMAT
    function format_number_to_comma_separated(num) {
        // return parseInt(num).toLocaleString('en-US').split('.', 1);
        return (parseInt(num).toLocaleString('en-US').split('.', 1)[0]).replace(',',global_group_separator);
    }
    //## FILL UP GRID WITH CORRESPONDING BEGINNING INVENTORY
    
    function fill_beg_inv_row_col() {
		//console.log(rec_loc_inv_json);
        var total_colwise = $('.frame_tbl tbody tr:nth-child('+TOTAL_POS+') td:gt(' + (BEG_POS + 1) +')');
        var beg_colwise = $('.frame_tbl tbody tr:nth-child('+BEG_POS+') td:gt(' + (BEG_POS + 1) +')');
        var end_colwise = $('.frame_tbl tbody tr:nth-child('+END_POS+') td:gt('+END_POS+')');
        var highlight = '';
		
		
        total_colwise.each(function(index){


            $(this).attr('value', del_loc_inv_json[index].total_pos);
            //$(this).attr('value', '5000');
			
			//highlight = '';
			//if(del_loc_inv_json[index].is_unschedule == 'y' && reschedule == 0) highlight = 'style="color:RED"';
			
            highlight = ((del_loc_inv_json[index].total_pos > 0 && del_loc_inv_json[index].location_type != 'Storage') ? 'color_red' : '');
			
            $(this).html('<span onclick="fx_position_report(this)" class="position_drill_d ' + highlight + '" title="Total Position"\
                loc_type="' + del_loc_inv_json[index].location_type + '" \
                loc_id="' + del_loc_inv_json[index].location_id + '" \
                proxy_loc_id="' + del_loc_inv_json[index].proxy_loc_id + '" \
                proxy_loc_type="' + del_loc_inv_json[index].proxy_loc_type + '" \
                proxy_type="' + del_loc_inv_json[index].proxy_type + '" \
				>' 
                + format_number_to_comma_separated(del_loc_inv_json[index].total_pos));
            
        });
        
        beg_colwise.each(function(index){
            if (del_loc_inv_json[index].total_pos == '0' || del_loc_inv_json[index].total_pos == 0) {
                $(this).addClass('inv_zero_d');
            }
            $(this).attr('is_proxy', del_loc_inv_json[index].is_proxy);
            if(del_loc_inv_json[index].is_proxy == 2) {
                $(this).addClass('proxy_loc_to');
            }
            $(this).attr('value', del_loc_inv_json[index].position);
            $(this).attr('loc_type', del_loc_inv_json[index].location_type);
            $(this).attr('loc_id', del_loc_inv_json[index].location_id);
            $(this).html('<span onclick="" class="" \
                loc_type="' + del_loc_inv_json[index].location_type + '" \
                loc_id="' + del_loc_inv_json[index].location_id + '" \
                proxy_loc_id="' + del_loc_inv_json[index].proxy_loc_id + '" \
                proxy_loc_type="' + del_loc_inv_json[index].proxy_loc_type + '" \
                proxy_type="' + del_loc_inv_json[index].proxy_type + '" \
				imbalance_paths="' + del_loc_inv_json[index].imbalance_paths + '" \
                >'
                + format_number_to_comma_separated(del_loc_inv_json[index].position));
            
        });
        
        end_colwise.each(function(index){
            $(this).attr('value', del_loc_inv_json[index].position);
            $(this).html(format_number_to_comma_separated(del_loc_inv_json[index].position));
            $(this).attr('loc_id', del_loc_inv_json[index].location_id);
            if(del_loc_inv_json[index].proxy_loc_id != -1) {
                $(this).attr('proxy_loc_id', del_loc_inv_json[index].proxy_loc_id);
                $(this).attr('proxy_type', del_loc_inv_json[index].proxy_type);
            }
            
        });
        
        var total_rowwise = $('.frame_tbl tbody tr:gt('+ (TOTAL_POS + 2) +') td:nth-child('+ (BEG_POS-1) +')');
        var beg_rowwise = $('.frame_tbl tbody tr:gt('+ (BEG_POS + 1) +') td:nth-child('+ BEG_POS +')');
        var end_rowwise = $('.frame_tbl tbody tr:gt('+ END_POS +') td:nth-child('+ END_POS +')');
        
        total_rowwise.each(function (index){
            //console.log('index:'+index);
			
			//highlight = '';
			//if(rec_loc_inv_json[index].is_unschedule == 'y' && reschedule == 0) highlight = 'style="color:RED"';
			
            highlight = ((rec_loc_inv_json[index].total_pos < 0 && rec_loc_inv_json[index].location_type != 'Storage') ? 'color_red' : '');

            $(this).attr('value', rec_loc_inv_json[index].total_pos);
            $(this).html('<span onclick="fx_position_report(this)" class="position_drill_d ' + highlight + '" title="Total Position"\
                loc_type="' + rec_loc_inv_json[index].location_type + '" \
                loc_id="' + rec_loc_inv_json[index].location_id + '" \
                proxy_loc_id="' + rec_loc_inv_json[index].proxy_loc_id + '" \
                proxy_loc_type="' + rec_loc_inv_json[index].proxy_loc_type + '" \
                proxy_type="' + rec_loc_inv_json[index].proxy_type + '" \
				>' 
                + format_number_to_comma_separated(rec_loc_inv_json[index].total_pos));
            
        });
        
        beg_rowwise.each(function (index){
            if (rec_loc_inv_json[index].total_pos == '0' || rec_loc_inv_json[index].total_pos == 0) {
                $(this).closest('tr').addClass('inv_zero_r');
		
            }
            $(this).attr('is_proxy', rec_loc_inv_json[index].is_proxy);                                   
            $(this).attr('value', rec_loc_inv_json[index].position);
            $(this).attr('loc_id', rec_loc_inv_json[index].location_id);
            $(this).attr('loc_type', rec_loc_inv_json[index].location_type);
            $(this).html('<span onclick=""  \
                loc_type="' + rec_loc_inv_json[index].location_type + '" \
                loc_id="' + rec_loc_inv_json[index].location_id + '" \
                proxy_loc_id="' + rec_loc_inv_json[index].proxy_loc_id + '" \
                proxy_loc_type="' + rec_loc_inv_json[index].proxy_loc_type + '" \
                proxy_type="' + rec_loc_inv_json[index].proxy_type + '" \
                imbalance_paths="' + rec_loc_inv_json[index].imbalance_paths + '" \
                >' 
                + format_number_to_comma_separated(rec_loc_inv_json[index].position));
            
            //hide proxy location rows (from)
            if(rec_loc_inv_json[index].is_proxy == 1) {
                $(this).closest('tr').hide();
            }
            
        });
        end_rowwise.each(function (index){
            $(this).attr('value', rec_loc_inv_json[index].position);
            $(this).html(format_number_to_comma_separated(rec_loc_inv_json[index].position));
            $(this).attr('loc_id', rec_loc_inv_json[index].location_id);
            if(rec_loc_inv_json[index].proxy_loc_id != -1) {
                $(this).attr('proxy_loc_id', rec_loc_inv_json[index].proxy_loc_id);
                $(this).attr('proxy_type', rec_loc_inv_json[index].proxy_type);
            }
        });

		//if (reschedule == 0) fx_imbalance_task();
    }
	
    /*
	function fx_imbalance_task() {
		
		var imb_paths = [];	
		$('.total_beg_inv_rec').each(function (index){
			imb_paths = _.uniq($('.total_beg_inv_del .position_drill_d').map(function(){return $(this).attr("imbalance_paths");}).get());
			//console.log(imb_paths);
			
			if($.inArray($(this).attr("loc_id"),imb_paths) > -1) {
				//console.log('imb found');
				//$(this).prev().siblings('span').attr("abc","abc");
                $('.position_drill_d', $(this).prev()).css("color","RED");
			}
		});

        $('.total_beg_inv_del').each(function (index){
            var target_obj = $(this);
            var imb_paths_arr = $('.total_beg_inv_rec span').eq(0).map(function(){return $(this).attr("imbalance_paths");}).get().join(',').split(',');
            //console.log(imb_paths_arr);

            $(imb_paths_arr).each(function(k,v) {
                if(v != "null")
                    imb_paths.push(v.trim());
            });
            imb_paths = _.uniq(_.without(_.compact(imb_paths),"null"));
            //console.log('aaaaaaaaaaa');
            //console.log(imb_paths);
            
            //if($.inArray($(this).attr("loc_id"),imb_paths) > -1) {
                //console.log('imb found');
                //$(this).prev().siblings('span').attr("abc","abc");
                //$('.position_drill_d', $(this).prev()).css("color","RED");
                //$('.position_drill_d', $(this).parent().prev()).filter('[loc_id="' + ).css("color","RED");
                
            //}
            $(imb_paths).each(function(k,v) {
                //console.log($('.position_drill_d', target_obj.parent().prev()).filter('[loc_id="' + v + '"]').length);

                $('.position_drill_d', target_obj.parent().prev()).filter('[loc_id="' + v + '"]').css("color","RED");
            });
        });

       // total_beg_inv_del
	}
    */
    
    //function to open position report total
    function fx_position_report_total(loc_id) {
        var flow_date_from = $('#filter_set_hidden').attr('flow_date_from');
        var flow_date_to = $('#filter_set_hidden').attr('flow_date_to');
        var exec_call = "EXEC "+SPA_FLOW_OPTIMIZATION_SP+" @flag='p', @uom='" + uom + "', @flow_date_from='" + flow_date_from 
            + "',  @flow_date_to='" + flow_date_to 
            + "', @minor_location='" + loc_id + "', @process_id='" + process_id_gbl + "', @reschedule='" + reschedule + "'";
            
        parent.fx_position_report(exec_call);
    }
    /*
    function to open report manager report for position report
    */
    function fx_position_report(obj) {
        var obj = $(obj);
        var location_id = obj.attr('loc_id');
        var proxy_loc_id = obj.attr('proxy_loc_id');
        var loc_type = obj.attr('loc_type');
        var proxy_loc_type = obj.attr('proxy_loc_type');
        var proxy_type = obj.attr('proxy_type');
        
        if(proxy_loc_id != -1 && proxy_type == 'cv') {
            location_id = proxy_loc_id;
            loc_type = proxy_loc_type;
        }
        
        var flow_date_from = $('#filter_set_hidden').attr('flow_date_from');
        var flow_date_to = $('#filter_set_hidden').attr('flow_date_to');
        var round = (granularity == '982' ? 2 : 3 );
        var param_uom_id = (uom == '' ? 'NULL' : uom);
        var exec_call = "EXEC "+SPA_FLOW_OPTIMIZATION_SP+" @flag='p', @uom=" + param_uom_id + ", @flow_date_from='" + flow_date_from 
            + "',  @flow_date_to='" + flow_date_to 
            + "', @minor_location='" + location_id + "', @process_id='" + process_id_gbl + "', @reschedule='" + reschedule + "'";
        
        if (loc_type == 'Storage') {
            exec_call = "EXEC spa_storage_position_report NULL, NULL, NULL, NULL, NULL, NULL, " + location_id + ", '" + flow_date_from + "', '" + flow_date_to + "'," + param_uom_id + ",NULL,NULL,NULL,NULL,NULL,'Optimization'";
             
        }
        exec_call = exec_call + '&rnd=' + round;
        
        parent.fx_position_report(exec_call);
    }
    function ajx_fx_position_report(json_result) {
        //console.log(json_result);
        var json_obj = $.parseJSON(json_result);
        var report_filter = 'process_id=' + process_id_gbl + ',location_id=' + json_obj[0].location_id;
        var param = 'paramset_id=' + json_obj[0].paramset_id
                        + '&report_name=' + json_obj[0].report_name
                        + '&report_filter=' + encodeURIComponent(report_filter)
                        + '&is_refresh=0'
                        + '&items_combined=' + json_obj[0].items_combined
                        + '&session_id=' + js_session_id 
                        + '&export_type=HTML4.0'
                        + '&' + getAppUserName();
        //console.log(param);
        createWindow('windowReportViewer', false, false, param);
    }
    //## CREATE DIV FOR SOLVER DATA        
    function set_div_for_solver_data() {
        var solver_data_cells = $('.frame_tbl tbody tr:gt(' + END_POS + ')');
        var count_data_id = 0;
        solver_data_cells.each(function(index) {
            $('td:gt(' + END_POS + ')', $(this)).each(function(index1) {
                $(this).html('<div class="solver_data1" id="data' + count_data_id + '"></div>\
                                <div class="solver_loading">Loading...</div>');
                
                $(this).closest('td').addClass('data_td');
                count_data_id++;
            });    
        });   
    }
    
    function ajx_fn_set_have_path_attr(ajax_result) {
        //console.log(ajax_result);
        var json_obj = $.parseJSON(ajax_result);
        $(json_obj).each(function(index) {
            $('.solver_data1').filter('[from_loc_id="'+json_obj[index].from_location+'"][to_loc_id="'+json_obj[index].to_location+'"]').addClass('has_path');
        });
    }
    
    
    //## FILL SOLVER DATA ON EACH DELIVERY PATH CELL
    function fill_solver_data_r(json_solver_data) {  
        console.log(json_solver_data);
        var mdq_inv_json = $.parseJSON(json_solver_data);
        
        if(mdq_inv_json[0].errorcode == 'Error' && mdq_inv_json[0].status == 'group_path_error') {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: mdq_inv_json[0].message,
            });
            $('.solver_loading').hide();
            $('.solver_data1').show();
            return;
        }
        
        //group path existence validation for solver run
        
        reset_mdq = json_solver_data;
        //var mdq_inv_json = $.parseJSON(json_solver_data);
        DEBUG_PROCESS && console.log('##time_s1:'+Date.now());
        $.each(mdq_inv_json, function (key1, val1) {
            var input_cls = '';
            var received_vol = (mdq_inv_json[key1].received ? mdq_inv_json[key1].received : 0);
            var delivered_vol = (mdq_inv_json[key1].received ? mdq_inv_json[key1].delivered : 0);
            var route_context = '#data' + key1;
            $('.box_div', route_context).attr(
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
                    'total_pmdq': mdq_inv_json[key1].path_mdq,
                    'total_prmdq': mdq_inv_json[key1].path_rmdq
                    ,'solver_result_rec': mdq_inv_json[key1].received
                    ,'solver_result_del': mdq_inv_json[key1].delivered
                    ,'first_hour_rec_vol': mdq_inv_json[key1].first_hour_rec_vol
                    ,'first_hour_del_vol': mdq_inv_json[key1].first_hour_del_vol
                }
            );
            
        
            if(mdq_inv_json[key1].path_exists == '0') {
                $('.top_div, .center_div, .bottom_div', route_context).addClass('no_path_cell');
                return;
            }

            $('.mdq_info1', route_context).attr('value', mdq_inv_json[key1].path_mdq);
            $('.mdq_info1', route_context).text(format_number_to_comma_separated(mdq_inv_json[key1].path_mdq));
            $('.mdq_info2', route_context).attr('value', mdq_inv_json[key1].path_rmdq);
            $('.mdq_info2', route_context).text(format_number_to_comma_separated(mdq_inv_json[key1].path_rmdq));
            $('.from_loc_id', route_context).text(mdq_inv_json[key1].from_loc_id);
            $('.from_loc', route_context).text(mdq_inv_json[key1].from_loc);
            $('.to_loc_id', route_context).text(mdq_inv_json[key1].to_loc_id);
            $('.to_loc', route_context).text(mdq_inv_json[key1].to_loc);
            $('.route_id', route_context).text(mdq_inv_json[key1].box_id);
            $('.rec_del_div1', route_context).attr('value', received_vol);
            $('.rec_del_div1', route_context).text(format_number_to_comma_separated(received_vol));
            $('.rec_del_div2', route_context).attr('value', delivered_vol);
            $('.rec_del_div2', route_context).text(format_number_to_comma_separated(delivered_vol));
            $('.path_exists, .path_id', route_context).text(mdq_inv_json[key1].path_exists);
             
                         
        });  
        DEBUG_PROCESS && console.log('##time_s2:'+Date.now());
        $('.solver_loading').hide();
        $('.solver_data1').show();
        adjust_ending_inv();
        $('.no_path_cell').css('visibility', 'hidden');
    }
    
    function fill_solver_data(json_solver_data) {  
        DEBUG_PROCESS && console.log('##time02:'+Date.now());
        var mdq_inv_json = $.parseJSON(json_solver_data);
        //console.dir(mdq_inv_json);
        $.each(mdq_inv_json, function (key1, val1) {
            var input_cls = '';
            var route_context = '#data' + key1;
            $('.box_div', route_context).attr(
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
                    'from_pos_beg': $('.total_beg_inv_rec').filter('[loc_id="' + mdq_inv_json[key1].from_loc_id + '"]').attr('value'),
                    //'from_pos_end': mdq_inv_json[key1].box_type,
                    'to_pos_beg': $('.total_beg_inv_del').filter('[loc_id="' + mdq_inv_json[key1].to_loc_id + '"]').attr('value'),
                    //'to_pos_end': mdq_inv_json[key1].box_type,
                    'total_pmdq': mdq_inv_json[key1].path_mdq,
                    'total_prmdq': mdq_inv_json[key1].path_rmdq,
                    'total_oprmdq': mdq_inv_json[key1].path_rmdq,
                    'path_ids': mdq_inv_json[key1].path_exists,
                    'process_id': mdq_inv_json[key1].process_id,
                    'first_hour_rec_vol': mdq_inv_json[key1].first_hour_rec_vol,
                    'first_hour_del_vol': mdq_inv_json[key1].first_hour_del_vol
                }
            );
            
            if(mdq_inv_json[key1].path_exists === '0') {
                $('.top_div, .center_div, .bottom_div', route_context).addClass('no_path_cell');
                $('.process_id', route_context).text((mdq_inv_json[key1].process_id));
                $('.from_loc_id', route_context).text((mdq_inv_json[key1].from_loc_id));
                $('.to_loc_id', route_context).text((mdq_inv_json[key1].to_loc_id));
                $('.from_loc', route_context).text((mdq_inv_json[key1].from_loc));
                $('.to_loc', route_context).text((mdq_inv_json[key1].to_loc));
                
                //save global var for process id
                process_id_gbl = mdq_inv_json[key1].process_id;
                return;
            }
            ///$(route_context).closest('tr').removeClass('nowhere_to_go_from');
            ///$('.frame_tbl tr:nth-child(2) td:nth-child('+($(route_context).closest('td').index()+1)+')').removeClass('nowhere_to_go_to');
            $.each(val1, function (key2, val2) {  

                if (key2 == 'path_mdq') {
                    input_cls = '.mdq_info1';
                    $(input_cls, route_context).attr('value', val2);
                    val2 = format_number_to_comma_separated(val2);
                } else if (key2 == 'path_rmdq') {
                    input_cls = '.mdq_info2';
                    $(input_cls, route_context).attr('value', val2);
                    $('.original_rmdq', route_context).html(val2);
                    val2 = format_number_to_comma_separated(val2);
                    
					/*
					//visual notification for pmdq change
                    if($('.mdq_info1', route_context).attr('value') > $('.mdq_info2', route_context).attr('value')) {
                        $('.del_path_link', route_context).css("color", "white");
                        $('.del_path_link', route_context).css("background-color", "#39ad3d");

                    }
					*/           
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

					val2 = (val2 ?  val2 : 0);
                    $(input_cls, route_context).attr('value', val2);					
                    val2 = format_number_to_comma_separated(val2);
                } else if (key2 == 'delivered') {
                    input_cls = '.rec_del_div2';	

					val2 = (val2 ?  val2 : 0);
                    $(input_cls, route_context).attr('value', val2);					
                    val2 = format_number_to_comma_separated(val2);
                } else if (key2 == 'path_exists'){
                    input_cls = '.path_exists';
                    if (val2 == '0') {
                        $('.top_div, .center_div, .bottom_div', route_context).addClass('no_path_cell');
                    }
                } else if (key2 == 'process_id') {
                    input_cls = '.process_id';
                    //save global var for process id
                    process_id_gbl = val2;
                } else if (key2 == 'from_loc_grp_id') {
                    input_cls = '.from_loc_grp_id';
                } else if (key2 == 'from_loc_grp_name') {
                    input_cls = '.from_loc_grp_name';
                } else if (key2 == 'to_loc_grp_id') {
                    input_cls = '.to_loc_grp_id';
                } else if (key2 == 'to_loc_grp_name') {
                    input_cls = '.to_loc_grp_name';
                } else input_cls = 'none';
                
                if (input_cls != '' && input_cls != 'none') {
                    $(input_cls, route_context).html(val2);
                } 
            });

            EXCEED_INFO_GBL.push({
                box_id: mdq_inv_json[key1].box_id,
                position_exceed: '0',
                pmdq_exceed: '0',
                storage_violate: '0'
            });
        });  
        DEBUG_PROCESS && console.log('##time03:'+Date.now());

        if (call_from == 'match') {
            var flow_date_from = '<?php echo $flow_date_from; ?>';
            var flow_date_to = '<?php echo $flow_date_to; ?>';

            var data = {
                'action': 'spa_flow_optimization',
                'flag': 'e',
                'from_location': receipt_location_name,
                'to_location': delivery_location_name
            }

            adiha_post_data('return_array', data, '', '', function(result) {
                var receipt_child_id = result[0][0];
                var delivery_child_id = result[0][1];

                receipt_location_name += (receipt_child_id != null && receipt_child_id != '' ? ',' + receipt_child_id : '')
                delivery_location_name += (delivery_child_id != null && delivery_child_id != '' ? ',' + delivery_child_id : '');
            
                var args = "?process_id=" + process_id_gbl + "&flow_date_from=" + flow_date_from + "&flow_date_to=" + flow_date_to + "&box_id=" + 1 + "&receipt_loc_id=" + receipt_location_name + "&delivery_loc_id=" + delivery_location_name  + '&from_loc_grp_id=' + receipt_group + '&to_loc_grp_id=' + delivery_group + '&uom=' + uom + '&contract=' + contract + '&pipeline=' + pipeline + '&subsidiary_id=' + subsidiary_id
                    + '&strategy_id=' + strategy_id + '&book_id=' + book_id + '&sub_book_id=' + sub_book_id + '&book_structure_text=' + encodeURIComponent(book_structure_text);
                
                open_match_auto(args);
            });
        }

        fx_post_loading_refresh();
        
        
    }
    //events to load after btn refresh grid
    function fx_post_loading_refresh() {
        $('.no_path_cell').css('visibility', 'hidden');
        ///$('.nowhere_to_go_from', '.frame_tbl').hide();
        
        //enable menu of parent frame
        if (call_from != 'flow_deal_match')
            parent.fx_enable_disable_menu_items('enable', 'all');
        
        //hide proxy location cols (to)
        var class_loop_proxy = $('.proxy_loc_to');
        class_loop_proxy.each(function(index) {
            var td_index = $(this).closest('td').index();
            
            var inner_loop = $('.frame_tbl tr td:nth-child(' + (td_index + 1) + ')');
            inner_loop.each(function(index) {
                $(this).hide();
            });
        });
        
        
        first_row_col_span();
        $('#loading').hide();
        $('#main_div').show();
        $('.frame_tbl input:checkbox').removeAttr('checked');
        supply_demand_align();
        
        //fx_hide_position_zero(true);
        DEBUG_PROCESS && console.log('##time04:'+Date.now());
        DEBUG_PROCESS && console.log(process_id_gbl);
    }
    function fx_path_list_popup(obj) {
        var box_div = $(obj).closest('.box_div');
        var box_id = parseInt($('.route_id', box_div).html());
        var exec_call = {
            "action": SPA_FLOW_OPTIMIZATION_SP, 
            "flag": "y",
            "xml_manual_vol": box_id,
            "process_id": process_id_gbl
        };
        DEBUG_PROCESS && console.log(JSON.stringify(exec_call));
        var result = adiha_post_data("return_json", exec_call, "", "", "load_multipath_li", false);
        
        var left_pos = $(obj).position().left ;
        var top_pos = $(obj).position().top + 13;
        //alert(left_pos);
        $('.popup_multipath').css('left',left_pos);      // <<< use pageX and pageY
        $('.popup_multipath').css('top',top_pos);
        $('.popup_multipath').css('display','inline');     
        $('.popup_multipath').css("position", "absolute");
        
        
        
        
        return;
        /* using dhtmlx */
        
        var box_div = $(obj).closest('.box_div');
        var from_loc = $('.from_loc_id', box_div).text();
        var to_loc = $('.to_loc_id', box_div).text();
        
        path_popup_dhtmlx_obj = new dhtmlXPopup();
        
        var x = $(obj).offset().left;
        var y = $(obj).offset().top;
        var w = obj.offsetWidth;
        var h = obj.offsetHeight;
        
        // Return location from and its position
        /*
        var exec_call = {
                            "action": "spa_flow_optimization", 
                            "flag": "y",
                            "from_location": from_loc,
                            "to_location": to_loc,
                            "path_priority": path_priority,
                            "contract_id":contract,
                            "pipeline_ids":pipeline,
                            "flow_date": flow_date
                        };
        */
        var box_id = parseInt($('.route_id', box_div).html());
        var exec_call = {
            "action": SPA_FLOW_OPTIMIZATION_SP, 
            "flag": "y",
            "xml_manual_vol": box_id,
            "process_id": process_id_gbl
        };
        DEBUG_PROCESS && console.log(JSON.stringify(exec_call));
        var result = adiha_post_data("return_json", exec_call, "", "", "load_multipath_li", false);
        
        path_popup_dhtmlx_obj.show(x,y,w,h);
        
        
        //open delivery path window menu with path_id
        var ev_id_onclick = path_popup_dhtmlx_obj.attachEvent('onclick', function(id) {
            var args = '?call_from=flow_optimization&mode=u&path_id=' + id;
            if (parent && parent.parent)
                parent.parent.open_menu_window("_scheduling_delivery/gas/Setup_Delivery_Path/Setup.Delivery.Path.php" + args, "windowSetupDeliveryPath", "Setup Delivery Path");
        });        
    }

    // function unique(list) {
    //     var result = [];
    //     var path;
    //     $.each(list, function(i, e) {           
    //         path = e.path_name.substring(0, (e.path_name.indexOf('(') == -1 ? e.path_name.length : e.path_name.indexOf('(')));            
    //         if ($.inArray(path, result) == -1) result.push(path);
    //     });
    //     return result;
    // }
    
    function load_multipath_li(json_multipath) {
        $('.path_list_ul').html('');
        var json_multipath = $.parseJSON(json_multipath);
        var li_html = '';
        DEBUG_PROCESS && console.log(json_multipath);

        var unique_path_name = [];
        //unique_path_name = unique(json_multipath);

        /*
        $.each(unique_path_name, function(i) {             
            var path_name_modified = unique_path_name[i];
            li_html += '<li onclick="fx_open_delivery_path_window(this,\'u\',' + json_multipath[i].path_id + ')">' + path_name_modified + '</li>';            
        });
        */

        unique_path_name = _.uniq(json_multipath.map(function(data) {
            return (data.path_id + "_-_" + trim(data.path_name.split('(')[0]));
        }));
        //console.log(unique_path_name);
        
        $.each(unique_path_name, function(i, v) {             
            li_html += '<li onclick="fx_open_delivery_path_window(this,\'u\',' + v.split('_-_')[0] + ')">' + v.split('_-_')[1] + '</li>';            
        });

        $('.path_list_ul').append(li_html);
        
        return;
        /* use of dhtmlx popup */
        //console.log(json_multipath);
        var json_multipath = $.parseJSON(json_multipath);
        
        var data_list = [];
        
        $.each(json_multipath, function(i) {
            var path_name_modified = json_multipath[i].path_name + ' (PMDQ=' + format_number_to_comma_separated(json_multipath[i].path_mdq) 
                        + '/CMDQ=' + format_number_to_comma_separated(json_multipath[i].contract_mdq) + ')';
            data_list.push({'id': json_multipath[i].path_id, 'name': path_name_modified}, path_popup_dhtmlx_obj.separator);
        });
        path_popup_dhtmlx_obj.attachList('name', data_list);
        
    }
    
    
        
    function popup_modal_box(obj) { 
		//console.log(obj);
		var box_div = $(obj).closest('.box_div');
		
		if(granularity == '982' || granularity == '982') { //981 daily,982 
		
			var win_text = 'Daily Scheduling';
			if (granularity == '982') win_text = 'Hourly Scheduling';
			parent.flow_deal_match_window.createWindow({
                id: 'window_hourly_schd'
                ,modal: true
                ,text: win_text
                ,center: true
                ,height: 500
                ,width: 1250
            });
            //parent.flow_deal_match_window.window('window_hourly_schd').maximize();
            //parent.flow_deal_match_window.window('window_hourly_schd').denyResize();
            //console.log(post_params);
            var path_id_selected = (box_div.attr('path_id_selected') == "" ? box_div.attr('path_ids').split(',')[0] : box_div.attr('path_id_selected'));
			var args = {
				process_id: process_id_gbl
				,flow_start: flow_date_from
				,flow_end: flow_date_to
				,box_id: box_div.attr('route_id')
				,uom: uom
				,receipt_loc: receipt_location_name
				,delivery_loc: delivery_location_name 
				,receipt_loc_id: box_div.attr('from_loc_id')
				,delivery_loc_id: box_div.attr('to_loc_id')
				,from_loc_grp_name: $('.from_loc_grp_name', box_div).text()
				,to_loc_grp_name: $('.to_loc_grp_name', box_div).text()
                ,selected_path_id: path_id_selected
                ,selected_contract_id: box_div.attr('contract_id_selected')
				,from_loc_name: receipt_location_name 
				,to_loc_name: delivery_location_name
                ,granularity: granularity
                ,period_from: period_from
                ,from_pos_beg: box_div.attr('from_pos_beg')
                ,to_pos_beg: box_div.attr('to_pos_beg')
				,call_from: 'flow_optimization'
		
			};
            var url_hourly = (granularity == '981' ? 'match.php?' : 'hourly.scheduling.php?') + $.param(args);
            parent.flow_deal_match_window.window('window_hourly_schd').attachURL(url_hourly, false);
			
		} else if(granularity == '981') {
			var box_div = $(obj).parent();
	        var left_pos = $(obj).position().left - 2;
	        var top_pos = $(obj).position().top + 22;
	        //alert(left_pos);
	        $('#my_popup').css('left',left_pos);      // <<< use pageX and pageY
	        $('#my_popup').css('top',top_pos);
	        $('#my_popup').css('display','inline');     
	        $('#my_popup').css("position", "absolute");
	        load_popup_mdq(box_div);
	        return;
	        /* use of dhtmlx popup */
	        var box_div = $(obj).parent();
	        var path_exists = $('.path_exists', box_div).text();
	        
	        //define it global so that obj can be destruct
	        schedule_popup_dhtmlx_obj_gbl = new dhtmlXPopup();
	        schedule_popup_dhtmlx_obj_gbl.attachObject('my_popup');
	        load_popup_mdq(box_div); //loading the opup values first
	        
	        var x = $(obj).offset().left;
	        var y = $(obj).offset().top;
	        var w = obj.offsetWidth;
	        var h = obj.offsetHeight;
	        schedule_popup_dhtmlx_obj_gbl.show(x,y,w,h);
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
        var pos_beg_to = $('.frame_tbl tbody tr:nth-child(' + BEG_POS + ') td:nth-child(' + (td_index + 2) + ')').filter('.total_beg_inv_del').attr('value');
        var pos_end_to = $('.frame_tbl tbody tr:nth-child(' + END_POS + ') td:nth-child(' + (td_index + 2) + ')').filter('.total_end_inv_del').attr('value');
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
                            'storage_position': st_pos
                        };
        DEBUG_PROCESS && console.log(JSON.stringify(exec_call));             
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
    function load_path_dd(box_id) {
         // Return location from and its position
        var exec_call = {
            "action": SPA_FLOW_OPTIMIZATION_SP, 
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
        /*
        var exec_call = {
                            "action": "spa_flow_optimization", 
                            "flag": "q",
                            "from_location": from_loc_id,
                            "to_location": to_loc_id,
                            "process_id": process_id_gbl,
                            "delivery_path":valid_paths_array.join(',')
                        };
                        */
        var box_id = parseInt($('.route_id', box_div).html());
        var exec_call = {
            "action": SPA_FLOW_OPTIMIZATION_SP, 
            "flag": "q",
            "xml_manual_vol": box_id,
            "process_id": process_id_gbl,
            "flow_date_from": flow_date_from
        };
        DEBUG_PROCESS && console.log(JSON.stringify(exec_call));
        var result = adiha_post_data("return_json", exec_call, "", "", "fill_contract_detail", false);

    }
    function fill_contract_detail(json_path_contract) {
        var json_path_contract = $.parseJSON(json_path_contract);
        
        var original_rmdq = $('.original_rmdq', '#' + current_data_td_id).text();
        
        //$('.tbl_contract_pop_up_body').html('');
        var edited_info_detail_obj = $('.edited_info', '#' + current_data_td_id);
        var box_id = $('.route_id', '#' + current_data_td_id).html();
        var to_loc_id = $('.to_loc_id', '#' + current_data_td_id).html();
        var from_loc_id = $('.from_loc_id', '#' + current_data_td_id).html();
    
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
            //var path_ormdq = $('.path_dd [path_id="' + json_path_contract[i].path_id + '"]', '#' + current_data_td_id).attr('path_ormdq');
            
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
                var edited_li = $('li [path_id="' + json_path_contract[i].path_id + '"],[contract_id="' + json_path_contract[i].contract_id + '"]' , edited_info_detail_obj);
                //console.log(edited_li);
                if(cell_proxy_type == 'cp') {
                    path_rmdq = proxy_path_rmdq;
                    //alert(path_rmdq);
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
                    $('.pop_ip2', '#' + current_data_td_id).addClass('popup_invalid_mdq');
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
                
                $('.contract_receipt_total', $('#' + json_path_contract[i].table_id)).attr('value', json_path_contract[i].receipt_total);
                $('.contract_receipt_total', $('#' + json_path_contract[i].table_id)).text(format_number_to_comma_separated(json_path_contract[i].receipt_total));
                
                $('.contract_delivery_total', $('#' + json_path_contract[i].table_id)).attr('value', json_path_contract[i].delivery_total);
                $('.contract_delivery_total', $('#' + json_path_contract[i].table_id)).text(format_number_to_comma_separated(json_path_contract[i].delivery_total));

                $('.is_group_path').prop('checked', json_path_contract[i].group_path == 'y');
                
                
                $('.contract_rmdq_total', $('#' + json_path_contract[i].table_id)).attr('value', 
                    (
                    (cell_proxy_type == 'cp' && $('.edited_info_detail').filter('[path_id="' + json_path_contract[i].table_id + '"]').length > 0) 
                    ? proxy_path_rmdq : json_path_contract[i].first_path_mdq - del_vol_used_path));
                $('.contract_rmdq_total', $('#' + json_path_contract[i].table_id)).text(format_number_to_comma_separated(
                    (
                    (cell_proxy_type == 'cp' && $('.edited_info_detail').filter('[path_id="' + json_path_contract[i].table_id + '"]').length > 0) 
                    ? proxy_path_rmdq : json_path_contract[i].first_path_mdq - del_vol_used_path)));
            }
            
            //enable last single path delivery input
            //$('.pop_ip2', $('.tbl_contract_pop_up_body', $('#' + json_path_contract[i].path_id))).last().removeAttr('disabled');
            //$('.pop_ip2', $('.tbl_contract_pop_up_body', $('#' + json_path_contract[i].path_id))).first().attr('disabled','');
            
            
            //total adjustment from backend values.
            $('.contract_mdq_total', $('#' + json_path_contract[i].table_id)).attr('value', json_path_contract[i].first_path_mdq);
            $('.contract_mdq_total', $('#' + json_path_contract[i].table_id)).text(format_number_to_comma_separated(json_path_contract[i].first_path_mdq));
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
        
        
        
    }
    function path_dd_change(obj) {
        var table_id = $('.path_dd option:selected').attr('table_id');
        $('.template_content_cd .cd_active').removeClass('cd_active').addClass('cd_inactive');
        $('#' + table_id).removeClass('cd_inactive').addClass('cd_active');
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
    
    //var allow_exceed_path_mdq_gbl = false; //check first time allow for exceeding of path mdq
    
    function keypressed_pop_ip(obj, flag, event) {
        //console.log(event);
        //event.stopPropagation();
        //alert($(obj).closest('tr').attr('single_path_id'));
        var obj = $(obj);
        var box_div = obj.closest('.box_div');
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
                if(path_ormdq < delivery_value) {
                    $('.pop_ip2', obj.closest('tr')).addClass('popup_invalid_mdq');
                } else {
                    $('.pop_ip2', obj.closest('tr')).removeClass('popup_invalid_mdq');
                }
                
                
                
                //contract validation for segmentation and non-segmentation case
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
    /*
    function to calculate other sum of received volume of given contract excluding given box_id and path_id
    */
    function fx_calc_cmdq_to_compare(box_id, path_id, contract_id) {
        var exec_call = {
            'action': SPA_FLOW_OPTIMIZATION_SP,
            'flag': 'x',
            'contract_id': contract_id,
            'delivery_path': path_id,
            'xml_manual_vol': box_id,
            'process_id': process_id_gbl
        }
        DEBUG_PROCESS && console.log(JSON.stringify(exec_call));
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

        var box_div = $('.box_div', '#' + td_id);
        
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
                    var  contract_id = $('.contract_id_cd', $(this)).html();
                    //Remove last comma
		            if (contract_id[contract_id.length -1] == ',') {
		                contract_id = contract_id.slice(0, -1);
		            }
                    edited_info_obj.append(
                        "<li class=\"edited_info_detail\" \
                            table_id=\"" + table_id + "\" \
                            path_id=\"" + path_id + "\" \
                            single_path_id=\"" + $(this).attr('single_path_id') + "\" \
                            path_lf=\"" + lf + "\" \
                            contract_id=\"" + contract_id + "\" \
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
        
        //write final value to cell
        $('.rec_del_div1', box_div).attr('value', rec_value_new);
        $('.rec_del_div1', box_div).text(format_number_to_comma_separated(rec_value_new));
        $('.rec_del_div2', box_div).attr('value', del_value_new);
        $('.rec_del_div2', box_div).text(format_number_to_comma_separated(del_value_new));
        
        //rmdq = mdq - del_value_new;
        //rmdq = $('.edited_info_detail', edited_info_obj).attr('rmdq_total');
        
        $('.mdq_info2', box_div).attr('value', rmdq_final);
        $('.mdq_info2', box_div).text(format_number_to_comma_separated(rmdq_final));
        
        //adjust received inv
        $('.total_end_inv_rec', box_div.closest('tr')).attr('value', rec_end_inv);
        $('.r_inv_appended2', box_div.closest('tr')).attr('value', rec_end_inv);
        $('.total_end_inv_rec', box_div.closest('tr')).text(format_number_to_comma_separated(rec_end_inv));
        $('.r_inv_appended2', box_div.closest('tr')).text(format_number_to_comma_separated(rec_end_inv));
        
        //adjust delivery inv
        var td_index = box_div.closest('td').index();

        $('.frame_tbl tbody tr:nth-child(' + END_POS + ') td:nth-child(' + (td_index + 2) + ')').filter('.total_end_inv_del').attr('value', del_end_inv);
        $('.frame_tbl tbody tr:nth-child(' + (END_POS + 1) + ') td:nth-child(' + (td_index + 2) + ') .d_inv_appended2').attr('value', del_end_inv);
        $('.frame_tbl tbody tr:nth-child(' + END_POS + ') td:nth-child(' + (td_index + 2) + ')').filter('.total_end_inv_del').text(format_number_to_comma_separated(del_end_inv));
        $('.frame_tbl tbody tr:nth-child(' + (END_POS + 1) + ') td:nth-child(' + (td_index + 2) + ') .d_inv_appended2').text(format_number_to_comma_separated(del_end_inv));
        
             //adjust proxy position demand side
        var to_loc_id = box_div.attr('to_loc_id');
        var to_proxy_loc_id = box_div.attr('to_proxy_loc_id');
        if(to_proxy_loc_id != undefined) {
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_proxy_loc_id + '"]').filter('[proxy_type="cv"]').attr('value', del_end_inv);
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_proxy_loc_id + '"]').filter('[proxy_type="cv"]').attr('common_proxy_pos', del_end_inv);
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_proxy_loc_id + '"]').filter('[proxy_type="cv"]').text(format_number_to_comma_separated(del_end_inv));
        } else if($('.total_end_inv_del').filter('[proxy_loc_id="' + to_loc_id + '"]').length > 0) {
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_loc_id + '"]').filter('[proxy_type="cv"]').attr('value', del_end_inv);
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_loc_id + '"]').filter('[proxy_type="cv"]').text(format_number_to_comma_separated(del_end_inv));
            $('.total_end_inv_del').filter('[loc_id="' + to_loc_id + '"]').attr('common_proxy_pos', del_end_inv);
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_loc_id + '"]').filter('[proxy_type="cv"]').attr('common_proxy_pos', del_end_inv);
        }
        
        
        if($('.total_end_inv_del').filter('[loc_id="' + to_loc_id + '"]').attr('proxy_type') == 'cv') {
            $('.total_end_inv_del').filter('[loc_id="' + to_proxy_loc_id + '"]').attr('value', del_end_inv);
            $('.total_end_inv_del').filter('[loc_id="' + to_proxy_loc_id + '"]').attr('common_proxy_pos', del_end_inv);
            $('.total_end_inv_del').filter('[loc_id="' + to_proxy_loc_id + '"]').text(format_number_to_comma_separated(del_end_inv));
        }
        
        //adjust proxy position supply side
        var from_loc_id = box_div.attr('from_loc_id');
        var from_proxy_loc_id = box_div.attr('from_proxy_loc_id');
        if(from_proxy_loc_id !== undefined) {
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_proxy_loc_id + '"]').filter('[proxy_type="cv"]').attr('value', rec_end_inv);
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_proxy_loc_id + '"]').filter('[proxy_type="cv"]').attr('common_proxy_pos', rec_end_inv);
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_proxy_loc_id + '"]').filter('[proxy_type="cv"]').text(format_number_to_comma_separated(rec_end_inv));
        } else if($('.total_end_inv_rec').filter('[proxy_loc_id="' + from_loc_id + '"]').length > 0) {
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_loc_id + '"]').filter('[proxy_type="cv"]').attr('value', rec_end_inv);
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_loc_id + '"]').filter('[proxy_type="cv"]').text(format_number_to_comma_separated(rec_end_inv));
            $('.total_end_inv_rec').filter('[loc_id="' + from_loc_id + '"]').attr('common_proxy_pos', rec_end_inv);
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_loc_id + '"]').filter('[proxy_type="cv"]').attr('common_proxy_pos', rec_end_inv);
            
        }
        
        if($('.total_end_inv_rec').filter('[loc_id="' + from_loc_id + '"]').attr('proxy_type') == 'cv') {
            $('.total_end_inv_rec').filter('[loc_id="' + from_proxy_loc_id + '"]').attr('value', rec_end_inv);
            $('.total_end_inv_rec').filter('[loc_id="' + from_proxy_loc_id + '"]').attr('common_proxy_pos', rec_end_inv);
            $('.total_end_inv_rec').filter('[loc_id="' + from_proxy_loc_id + '"]').text(format_number_to_comma_separated(rec_end_inv));
        }
        
        
        
        //adjust proxy path rmdq
        var path_ids = box_div.attr('path_ids');
        var current_route = box_div.attr('route_id');
        $('.box_div').each(function(i) {
             if(current_route != $(this).attr('route_id')) {
                if(path_ids == $(this).attr('path_ids')) {
                    $('.mdq_info2', $(this)).attr('value', rmdq_final);
                    $('.mdq_info2', $(this)).text(format_number_to_comma_separated(rmdq_final));
                }
             }
        });
        
        
        
        //set common fields
        //$('.path_id', box_div).text(path_id);
        //$('.path_name', box_div).html(path_name);
        
        //save rec/dev vol on contractwise process table
        save_vol_to_pt(box_div);
        
        //schedule_popup_dhtmlx_obj_gbl.hide();
        $('#my_popup').hide();
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
            'action': SPA_FLOW_OPTIMIZATION_SP,
            'flag': 'z',
            'process_id': process_id_gbl,
            'xml_manual_vol': xml_manual_vol
        }
        
        var json_result = adiha_post_data('return_json', exec_call, '', '', 'ajx_save_vol_to_pt', false);
        
    }
    function ajx_save_vol_to_pt(json_result) {
        
    }
    
    function violation_available_inv_rec(box_div, rec_value) {
        var total_inv = $('.total_beg_inv_rec').filter('[loc_id="' + box_div.attr('from_loc_id') + '"]').attr('value');
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
            if ($(this).closest('td').index() != td_index) {
                if(granularity == '982') {// if hourly case pick first hour volume only
                    var box_rec_vol = parseInt($(this).closest('.box_div').attr('first_hour_rec_vol'));
                    box_rec_vol = (isNaN(box_rec_vol) ? 0 : box_rec_vol);
                    sum_of_rec += box_rec_vol;
                } else {
                    var box_rec_vol = parseInt($(this).attr('value'));
                    box_rec_vol = (isNaN(box_rec_vol) ? 0 : box_rec_vol);
                    sum_of_rec += box_rec_vol;
                }
            }
                
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
        //alert(rec_end_inv);
        return parseInt(rec_end_inv);
    }
    function violation_available_inv_del(box_div, del_value) {
        var td_index = box_div.closest('td').index();
        var total_inv = parseInt($('.total_beg_inv_del').filter('[loc_id="' + box_div.attr('to_loc_id') + '"]').attr('value'));
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
        }
        /* proxy adjust */
        
        var tr_index = box_div.closest('tr').index();//alert('tr_indx:'+(tr_index-1));alert('td_indx:'+(td_index + 1));
        var sum_of_del = parseInt(del_value);
        var tr_context = $('.frame_tbl tbody tr:gt(' + END_POS + ') td:nth-child(' + (td_index + 1) + ') .rec_del_div2');
        tr_context.each(function(index) {
            if ($(this).closest('tr').index() != tr_index) {
                if(granularity == '982') {// if hourly case pick first hour volume only
                    var box_del_vol = parseInt($(this).closest('.box_div').attr('first_hour_del_vol'));
                    box_del_vol = (isNaN(box_del_vol) ? 0 : box_del_vol);
                    sum_of_del += box_del_vol;
                } else {
                    var box_del_vol = parseInt($(this).attr('value'));
                    box_del_vol = (isNaN(box_del_vol) ? 0 : box_del_vol);
                    sum_of_del += box_del_vol;
                }
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
        
        //alert(del_end_inv);
        return parseInt(del_end_inv);
    }
    
    //## CORNER CHECK EVENT
    function chk_all_onchange(obj) {
        $('.row_chk, .col_chk').removeAttr('checked');
        
        if ($(obj).is(':checked')) {
            $('.chk_cell input:checkbox').prop('checked', true); //used prop since attr wont work 
        } else {
            $('.chk_cell input:checkbox').removeAttr('checked');
        }                                     
        
    }
    //## ROW WISE CHECKBOX EVENT
    function row_chk_onchange(obj) {
        $('.chk_all').removeAttr('checked');
        if ($(obj).is(':checked')) {
            $('.chk_cell input:checkbox', $(obj).closest('tr')).prop('checked', true);
        } else {
            $('.chk_cell input:checkbox', $(obj).closest('tr')).removeAttr('checked');
        }
    }
    
    
    //## COLUMN WISE CHECKBOX EVENT
    function col_chk_onchange(obj) {
        $('.chk_all').removeAttr('checked');
        var td_index = $(obj).closest('td').index();
        var solver_data_cells = $('.frame_tbl tbody tr:gt(' + END_POS + ')');
        var context_td = '';
        if ($(obj).is(':checked')) {
            solver_data_cells.each(function(index) {
                context_td = $(this).find('td:nth-child(' + (td_index ) + ')');
                $('.chk_cell input:checkbox', context_td).prop('checked', true);
            });
        } else {
            solver_data_cells.each(function(index) {
                context_td = $(this).find('td:nth-child(' + (td_index ) + ')');
                $('.chk_cell input:checkbox', context_td).removeAttr('checked');
            });  
        }
    }
   
    
    //### SAVE SCHEDULE FUNCTION
    function fx_save_schedule_pre() {
        //console.log(EXCEED_INFO_GBL);
        var position_exceed = EXCEED_INFO_GBL.some(function(el, ind) {
            if(el.position_exceed == '1') return true;
            else return false;
        }) ? 'y' : 'n';
        var pmdq_exceed = EXCEED_INFO_GBL.some(function(el, ind) {
            if(el.pmdq_exceed == '1') return true;
            else return false;
        }) ? 'y' : 'n';
        var storage_violate = EXCEED_INFO_GBL.some(function(el, ind) {
            if(el.storage_violate != '0') return true;
            else return false;
        }) ? 'y' : 'n';

        if(position_exceed == 'y' || pmdq_exceed == 'y' || storage_violate == 'y') {
            var confirm_msg_prefix = '';
            if(position_exceed == 'y') {
                confirm_msg_prefix += '/Volume';
            } 
            if(pmdq_exceed == 'y') {
                confirm_msg_prefix += '/Capacity';
            } 
            if(storage_violate == 'y') {
                confirm_msg_prefix += '/Storage';
            } 
            confirm_msg_prefix = confirm_msg_prefix.substr(1);
            var confirm_msg = confirm_msg_prefix + ' limit has been violated. Do you want to continue?';
            parent.confirm_messagebox(confirm_msg, function() {
                fx_save_schedule();
            });
        } else {
            fx_save_schedule();
        }
    }
    function fx_save_schedule() {
        //alert('process');return;
        var box_ids_arr = new Array();
        $('.chk_cell input:checkbox:checked', $('.frame_tbl .top_div:not(".no_path_cell")')).each(function(){
            var box_div = $(this).closest('.box_div');
            if (!$(this).closest('td').is(':hidden') && (box_div.attr('box_type') != 'to_proxy' || box_div.attr('box_type') != 'from_proxy')) {
                var route_id = $('.route_id', box_div).text();
                box_ids_arr.push(route_id);    
            }
        });
        box_ids = box_ids_arr.join(',');
         
        if(box_ids == '') {
            //show_messagebox('Please select valid record to proceed.');
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: 'Please select valid record to proceed.',
            });
        } else {
            //logic to open or not sub book window
            var exec_call = {
                'action': 'spa_schedule_deal_flow_optimization',
                'flag': 'i',
                'box_ids': box_ids,
                'flow_date_from': flow_date_from,
                'flow_date_to': flow_date_to,
                'sub': subsidiary_id,
                'str': strategy_id,
                'book': book_id,
                'sub_book': 'NULL', //pass null for generic mapping existence
                'contract_process_id': process_id_gbl,
                'from_priority': priority_from,
                'to_priority': priority_to,
                'call_from': 'flow_opt',
				'target_uom': uom,
                'reschedule': reschedule,
                'granularity': granularity
            };
            
            var json_result = adiha_post_data('return_json', exec_call, '', '', 'fx_save_schedule_ajax', false);
            DEBUG_PROCESS && console.log(JSON.stringify(exec_call));
            //logic to open or not sub book window
        }
    }
    function fx_save_schedule_ajax(result) {
        var json_obj = $.parseJSON(result);
        DEBUG_PROCESS && console.log(JSON.stringify(json_obj));
        if(json_obj[0].errorcode == 'Error' && json_obj[0].recommendation == 'generic_mapping') {
            //window popup start
            dhx_wins.createWindow({
                id: 'window_sub_book'
                ,left: 200
                ,top: 200
                ,width: 730
                ,height: 250
                ,modal: true
                //,center: true
            });
            
            var wd_sub_book = dhx_wins.window('window_sub_book');
            
            wd_sub_book.setText('Destination Sub Book');
            var options_sub_book = <?php echo $json_sub_book; ?>;
            
            var obj_form = wd_sub_book.attachForm([
                {'type': 'settings', 'position': 'label-top'},
                {
                    'type': 'combo', 'label': 'Sub Book', 'name': 'cmb_sb', 'width': '690', 'filtering': true, "filtering_mode":"between",
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
                            'sub': subsidiary_id,
                            'str': strategy_id,
                            'book': book_id,
                            'sub_book': dest_sub_book,
                            'contract_process_id': process_id_gbl,
                            'from_priority': priority_from,
                            'to_priority': priority_to,
                            'call_from': 'flow_opt',
							'target_uom': uom,
                            'reschedule': reschedule,
                            'granularity': granularity
                        };
                        DEBUG_PROCESS && console.log(JSON.stringify(exec_call));
                        
                        var json_result = adiha_post_data('return_json', exec_call, '', '', '', false);
                        pre_loading(5000);
                        success_call('Schedule deals have been created successfully.', 'error');
                        parent.flow_optimization.flow_optimization_form.uncheckItem('reschedule');
                        reschedule = 0;
                    }); 
                }
            });
            //window call end
        } else if(json_obj[0].errorcode == 'Error' && json_obj[0].recommendation == '') {
           // DEBUG_PROCESS && console.log('SQL error on spa_schedule_deal_flow_optimization');
		    var msg = json_obj[0].message; 
            success_call(msg, 'error');
            pre_loading(5000);
        } else if(json_obj[0].errorcode == 'Success') {
            success_call('Schedule deals have been created successfully.', 'error');
            pre_loading(5000);
            parent.flow_optimization.flow_optimization_form.uncheckItem('reschedule');
            reschedule = 0;
        }
        
    }
    
    function fx_open_delivery_path_window(obj, mode, id) {
        
        if(mode == 'u') {
            var args = '?call_from=flow_optimization&mode=u&path_id=' + id;
        } else {
            var box_div = $(obj).closest('.box_div');
            var from_loc_id = $('.from_loc_id', box_div).text();
            var to_loc_id = $('.to_loc_id', box_div).text();
            var from_loc = $('.from_loc', box_div).text();
            var to_loc = $('.to_loc', box_div).text();
            
            var args = '?call_from=flow_optimization&mode=' + mode + '&from_loc_id=' + from_loc_id + '&to_loc_id=' + to_loc_id +
                '&from_loc=' + from_loc + '&to_loc=' + to_loc;
        }
        
        if (parent && parent.parent)
            parent.parent.open_menu_window("_scheduling_delivery/gas/Setup_Delivery_Path/Setup.Delivery.Path.php" + args, "windowSetupDeliveryPath", "Setup Delivery Path");
    }
    function fx_open_location(location_id) {
        var args = '?call_from=flow_optimization&location_id=' + location_id;
        if (parent && parent.parent)
            parent.parent.open_menu_window("_setup/setup_location/setup.location.php" + args, "windowSetupLocation", "Setup Location");
    }
   
    function tool_bar_status(flag) {
        lastest_click_btn = flag; //-1:no button click, 0:refresh btn click, 1:run solver click, 2:reset grid click
    }
    
    function fx_view_schedules() {
        var flow_date_from = $('#filter_set_hidden').attr('flow_date_from');
        var flow_date_to = $('#filter_set_hidden').attr('flow_date_to');
        var receipt_locs = ($('#filter_set_hidden').attr('receipt_loc') == '' ? '-1' : $('#filter_set_hidden').attr('receipt_loc'));
        var delivery_locs = ($('#filter_set_hidden').attr('delivery_loc') == '' ? '-2' : $('#filter_set_hidden').attr('delivery_loc'));
        var location_ids =  receipt_locs + ',' + delivery_locs;
        var receipt_group = ($('#filter_set_hidden').attr('receipt_group') == '' ? '-1' : $('#filter_set_hidden').attr('receipt_group'));
        var delivery_group = ($('#filter_set_hidden').attr('delivery_group') == '' ? '-1' : $('#filter_set_hidden').attr('delivery_group'));
        var delivery_receipt_group = receipt_group + ',' +  delivery_group;

        var path_ids_arr = $('.box_div').map(function() {
            if($(this).attr('path_ids') != '') {
                return $(this).attr('path_ids');
            };
        }).get();
        var path_ids = (path_ids_arr.length > 0) ? _.uniq(path_ids_arr.join().split(',')).join(',') : '';
        
        var data = {
            'action': 'spa_flow_optimization',
            'flag': 'e',
            'from_location': receipt_locs,
            'to_location': delivery_locs
        }

        adiha_post_data('return_array', data, '', '', function(result) {
            var receipt_child_id = result[0][0];
            var delivery_child_id = result[0][1];
            
            location_ids += (receipt_child_id != null && receipt_child_id != '' ? ',' + receipt_child_id : '')
                         + (delivery_child_id != null && delivery_child_id != '' ? ',' + delivery_child_id : '');
            
            if (parent && parent.parent) {
                var args = '?call_from=flow_optimization&location_ids=' + location_ids + '&flow_date=' + flow_date_from + '&flow_date_end=' + flow_date_to + '&delivery_receipt_group=' + delivery_receipt_group + '&path_ids=' + path_ids;
                //console.log(args);return;
                parent.parent.open_menu_window("_scheduling_delivery/gas/view_nom_schedules/view.nom.schedules.php" + args, "windowSchedulesView", "View Nomination Schedules");
            }
        });
    }

    function fx_view_pipeline_capacity() {
        var flow_date_from = $('#filter_set_hidden').attr('flow_date_from');
        var path_ids_arr = $('.box_div').map(function() {
            if($(this).attr('path_ids') != '') {
                return $(this).attr('path_ids');
            };
        }).get();
        var path_ids = (path_ids_arr.length > 0) ? _.uniq(path_ids_arr.join().split(',')).join(',') : '';

        if (parent && parent.parent) {
            var args = '?call_from=flow_optimization&flow_date=' + flow_date_from + '&flow_date_end=' + flow_date_from + '&path_ids=' + path_ids;
            
            parent.parent.open_menu_window("_scheduling_delivery/view_available_pipeline_capacity/view.available.pipeline.capacity.php" + args, "win_10167500", "View Available Pipeline Capacity");
        }
    }
    
    function fx_book_out(call_from) {
        var flow_date_from = $('#filter_set_hidden').attr('flow_date_from');
        var flow_date_to = $('#filter_set_hidden').attr('flow_date_to');
		var receipt_locs = ($('#filter_set_hidden').attr('receipt_loc') == '' ? '-1' : $('#filter_set_hidden').attr('receipt_loc'));
        var delivery_locs = ($('#filter_set_hidden').attr('delivery_loc') == '' ? '-2' : $('#filter_set_hidden').attr('delivery_loc'));
        var location_ids =  receipt_locs;
        
        if (delivery_locs != null && delivery_locs != '') {
            location_ids += ',' + delivery_locs;
        }
        
        var data = {
            'action': 'spa_flow_optimization',
            'flag': 'e',
            'from_location': receipt_locs,
            'to_location': delivery_locs
        }

        adiha_post_data('return_array', data, '', '', function(result) {
            var receipt_child_id = result[0][0];
            var delivery_child_id = result[0][1];

            location_ids += (receipt_child_id != null && receipt_child_id != '' ? ',' + receipt_child_id : '')
                         + (delivery_child_id != null && delivery_child_id != '' ? ',' + delivery_child_id : '');
            
            if (parent && parent.parent) {
                var args = '?flow_date_from=' + flow_date_from + '&flow_date_to=' + flow_date_to + '&uom_name=' + uom_name + '&process_id=' + process_id_gbl + '&location_ids=' + location_ids;
                var label = 'Book Out';
                if (call_from == 'back_to_back') {
                    args += '&menu=back_to_back';
                    label = 'Back to Back';
                }
                parent.parent.open_menu_window("_scheduling_delivery/gas/flow_optimization/book.out.php" + args, "windowBookOut", label);
            }
        });
    }   
    
    function exit() {
        throw new Error('forceful stop of javascript.');
    }
    
    function first_row_col_span() {
        var first_instance = $('td.supply_td');
        // iterate through rows
        var r_num = 1;
        $('table.frame_tbl tbody').find('tr').each(function () {
        
            // find the td of the correct column (determined by the dimension_col set above)
            var dimension_td = $(this).find('td:nth-child(1)');
     
            if (first_instance == null) {
                // must be the first row
                first_instance = dimension_td;
                //first_instance.attr('rowspan');
            } else if (dimension_td.text() == '' && r_num > END_POS) { 
                // the current td is identical to the previous
                // remove the current td
                dimension_td.remove();
                // increment the rowspan attribute of the first instance
                first_instance.attr('rowspan', parseInt(first_instance.attr('rowspan')) + 1);
            } else {
                // this cell is different from the last
                first_instance = dimension_td;
            }
            r_num++;
        });
        first_instance.css('text-align','center');
        
        var first_instance = $('td.demand_td');
        var c_num = 1;
        $('table.frame_tbl tbody').find('tr:nth-child(1)').find('td').each(function () {
            var dimension_td = $(this);
            if (first_instance == null) {
                // must be the first row
                first_instance = dimension_td;
                //first_instance.attr('rowspan');
            } else if (dimension_td.text() == '' && c_num > END_POS) { 
                // the current td is identical to the previous
                // remove the current td
                dimension_td.remove();
                // increment the rowspan attribute of the first instance
                first_instance.attr('colspan', parseInt(first_instance.attr('colspan')) + 1);
            } else {
                // this cell is different from the last
                first_instance = dimension_td;
            }
           c_num++;
           first_instance.css('text-align','center');     
        });
     }      
       
          
    
    function on_click_grd_pipeline() {
        //spa_contract_group.php?flag=t&is_active=y&use_grid_labels=true&__user_name__=
        var pipeline_id = getGridvalue('main.grd_pipeline', 0);
        var sp_url = 'spa_contract_group.php' 
                    + '?use_grid_labels=true&flag=t&is_active=y' 
                    + '&pipeline=' + pipeline_id 
                    + '&' + getAppUserName();
        grid_grd_contract_refresh(sp_url);
    }


    function open_match_auto(args) {
        var src = 'flow.deal.match.php' + args + '&call_from_ui=match';
        
        var w_width = window.innerWidth;
        var w_height = parent.window.innerHeight;
        
        var win_book_out_new_deal = parent.flow_deal_match_window.createWindow('w1', 0, 0, w_width, w_height);
        win_book_out_new_deal.setText("Flow Deal Match");
        //win_book_out_new_deal.centerOnScreen();
        win_book_out_new_deal.setModal(true);
        //win_book_out_new_deal.denyResize();
        win_book_out_new_deal.maximize();
        win_book_out_new_deal.attachURL(src, false);
    } 

    function open_match(obj) {
        var box_div = $(obj).closest('.box_div');
        var box_id = parseInt($('.route_id', box_div).html());
        var from_loc_id = $('.from_loc_id', box_div).text();
        var to_loc_id = $('.to_loc_id', box_div).text();
        var from_loc = $('.from_loc', box_div).text();
        var to_loc = $('.to_loc', box_div).text();
        var selected_path_id = $('.path_id', box_div).text();
        var selected_contract_id = $('.contract_id', box_div).text();
        var from_loc_grp_id = $('.from_loc_grp_id', box_div).text();
        var from_loc_grp_name = $('.from_loc_grp_name', box_div).text();
        var to_loc_grp_id = $('.to_loc_grp_id', box_div).text();
        var to_loc_grp_name = $('.to_loc_grp_name', box_div).text();
        var selected_storage_asset_id = $('.storage_deal_info', box_div).attr('storage_asset_id');
        var selected_storage_checked = $('.storage_deal_info', box_div).attr('storage_checked'); 
        var flow_date_from = $('#filter_set_hidden').attr('flow_date_from');
        var flow_date_to = $('#filter_set_hidden').attr('flow_date_to');




        var args = "?process_id=" + process_id_gbl + "&flow_date_from=" + flow_date_from + "&flow_date_to=" + flow_date_to + "&box_id=" + box_id + "&receipt_loc_id=" + from_loc_id + "&delivery_loc_id=" + to_loc_id + "&receipt_loc=" + from_loc + "&delivery_loc=" + to_loc + '&from_loc_grp_name=' + from_loc_grp_name + '&to_loc_grp_name=' + to_loc_grp_name + '&selected_path_id=' + selected_path_id + '&selected_contract_id=' + selected_contract_id + '&selected_storage_asset_id=' + selected_storage_asset_id + '&selected_storage_checked=' + selected_storage_checked + '&uom=' + uom 
            + '&from_loc_grp_id=' +  from_loc_grp_id + '&to_loc_grp_id=' + to_loc_grp_id;

 /*
        parent.open_menu_window("_scheduling_delivery/gas/flow_optimization/flow.deal.match.php"+ args, 'windowFlowMatch', "Flow Deal Match");

        */
        
            var src = 'flow.deal.match.php' + args + '&call_from_ui=box_match';
            
        w_width = window.innerWidth;
        w_height = parent.window.innerHeight;
        
        win_book_out_new_deal = parent.flow_deal_match_window.createWindow('w1', 0, 0, w_width, w_height);
        
        //win_book_out_new_deal = parent.flow_deal_match_window.createWindow('w1', 0, 0, 1000, 500);
            win_book_out_new_deal.setText("Flow Deal Match");
        //win_book_out_new_deal.centerOnScreen();
            win_book_out_new_deal.setModal(true);
            //win_book_out_new_deal.denyResize();
        //win_book_out_new_deal.maximize();
            win_book_out_new_deal.attachURL(src, false);



    }

    function set_box_value(box_id, receipt_value, delivery_value, path_rmdq, path_id_selected, contract_id_selected, call_from, first_hour_rec_vol, first_hour_del_vol, limit_exceeded) { 
         //write final value to cell
        
        var box_div = $('.box_div').filter('[route_id="' + box_id + '"]');

        $('.chk_cell input:checkbox', box_div).prop('checked', true);

        if(call_from == 'clear_adj') {
            receipt_value = 0; 
            delivery_value = 0;
            path_rmdq = box_div.attr('total_oprmdq');
            path_id_selected = "";
            contract_id_selected = "";
            first_hour_rec_vol = 0;
            first_hour_del_vol = 0;
        }
        //set selected path and contract ids so that update mode retains same selection on hourly schedule screen
        box_div.attr({
            'path_id_selected': path_id_selected,
            'contract_id_selected': contract_id_selected,
            'first_hour_rec_vol': first_hour_rec_vol,
            'first_hour_del_vol': first_hour_del_vol
        });
        rec_end_inv = violation_available_inv_rec(box_div, first_hour_rec_vol);
        if(rec_end_inv === false) {
            return;   
        }
        del_end_inv = violation_available_inv_del(box_div, first_hour_del_vol);
        if(del_end_inv === false) {
            return;   
        }
        
        $('.rec_del_div1', box_div).attr('value', receipt_value);
        $('.rec_del_div1', box_div).text(format_number_to_comma_separated(receipt_value));
        $('.rec_del_div2', box_div).attr('value', delivery_value);
        $('.rec_del_div2', box_div).text(format_number_to_comma_separated(delivery_value));

        if(path_rmdq !== undefined) {
            $('.mdq_info2', box_div).attr('value', path_rmdq);
            $('.mdq_info2', box_div).text(format_number_to_comma_separated(path_rmdq));
        }
        
        var td_index = box_div.closest('td').index();
        
        
       
        //adjust received inv
        $('.total_end_inv_rec', box_div.closest('tr')).attr('value', rec_end_inv);
        $('.r_inv_appended2', box_div.closest('tr')).attr('value', rec_end_inv);
        $('.total_end_inv_rec', box_div.closest('tr')).text(format_number_to_comma_separated(rec_end_inv));
        $('.r_inv_appended2', box_div.closest('tr')).text(format_number_to_comma_separated(rec_end_inv));
        
        //adjust delivery inv
      
       


        $('.frame_tbl tbody tr:nth-child(' + END_POS + ') td:nth-child(' + (td_index + 2) + ')').filter('.total_end_inv_del').attr('value', del_end_inv);
        $('.frame_tbl tbody tr:nth-child(' + (END_POS + 1) + ') td:nth-child(' + (td_index + 2) + ') .d_inv_appended2').attr('value', del_end_inv);
        $('.frame_tbl tbody tr:nth-child(' + END_POS + ') td:nth-child(' + (td_index + 2) + ')').filter('.total_end_inv_del').text(format_number_to_comma_separated(del_end_inv));
        $('.frame_tbl tbody tr:nth-child(' + (END_POS + 1) + ') td:nth-child(' + (td_index + 2) + ') .d_inv_appended2').text(format_number_to_comma_separated(del_end_inv));
        
             //adjust proxy position demand side
        var to_loc_id = box_div.attr('to_loc_id');
        var to_proxy_loc_id = box_div.attr('to_proxy_loc_id');
        if(to_proxy_loc_id != undefined) {
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_proxy_loc_id + '"]').filter('[proxy_type="cv"]').attr('value', del_end_inv);
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_proxy_loc_id + '"]').filter('[proxy_type="cv"]').attr('common_proxy_pos', del_end_inv);
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_proxy_loc_id + '"]').filter('[proxy_type="cv"]').text(format_number_to_comma_separated(del_end_inv));
        } else if($('.total_end_inv_del').filter('[proxy_loc_id="' + to_loc_id + '"]').length > 0) {
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_loc_id + '"]').filter('[proxy_type="cv"]').attr('value', del_end_inv);
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_loc_id + '"]').filter('[proxy_type="cv"]').text(format_number_to_comma_separated(del_end_inv));
            $('.total_end_inv_del').filter('[loc_id="' + to_loc_id + '"]').attr('common_proxy_pos', del_end_inv);
            $('.total_end_inv_del').filter('[proxy_loc_id="' + to_loc_id + '"]').filter('[proxy_type="cv"]').attr('common_proxy_pos', del_end_inv);
        }
        
        
        if($('.total_end_inv_del').filter('[loc_id="' + to_loc_id + '"]').attr('proxy_type') == 'cv') {
            $('.total_end_inv_del').filter('[loc_id="' + to_proxy_loc_id + '"]').attr('value', del_end_inv);
            $('.total_end_inv_del').filter('[loc_id="' + to_proxy_loc_id + '"]').attr('common_proxy_pos', del_end_inv);
            $('.total_end_inv_del').filter('[loc_id="' + to_proxy_loc_id + '"]').text(format_number_to_comma_separated(del_end_inv));
        }
        
        //adjust proxy position supply side
        var from_loc_id = box_div.attr('from_loc_id');
        var from_proxy_loc_id = box_div.attr('from_proxy_loc_id');
        if(from_proxy_loc_id !== undefined) {
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_proxy_loc_id + '"]').filter('[proxy_type="cv"]').attr('value', rec_end_inv);
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_proxy_loc_id + '"]').filter('[proxy_type="cv"]').attr('common_proxy_pos', rec_end_inv);
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_proxy_loc_id + '"]').filter('[proxy_type="cv"]').text(format_number_to_comma_separated(rec_end_inv));
        } else if($('.total_end_inv_rec').filter('[proxy_loc_id="' + from_loc_id + '"]').length > 0) {
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_loc_id + '"]').filter('[proxy_type="cv"]').attr('value', rec_end_inv);
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_loc_id + '"]').filter('[proxy_type="cv"]').text(format_number_to_comma_separated(rec_end_inv));
            $('.total_end_inv_rec').filter('[loc_id="' + from_loc_id + '"]').attr('common_proxy_pos', rec_end_inv);
            $('.total_end_inv_rec').filter('[proxy_loc_id="' + from_loc_id + '"]').filter('[proxy_type="cv"]').attr('common_proxy_pos', rec_end_inv);
            
        }
        
        if($('.total_end_inv_rec').filter('[loc_id="' + from_loc_id + '"]').attr('proxy_type') == 'cv') {
            $('.total_end_inv_rec').filter('[loc_id="' + from_proxy_loc_id + '"]').attr('value', rec_end_inv);
            $('.total_end_inv_rec').filter('[loc_id="' + from_proxy_loc_id + '"]').attr('common_proxy_pos', rec_end_inv);
            $('.total_end_inv_rec').filter('[loc_id="' + from_proxy_loc_id + '"]').text(format_number_to_comma_separated(rec_end_inv));
        }
        
        
        /*
        //adjust proxy path rmdq
        var path_ids = box_div.attr('path_ids');
        var current_route = box_div.attr('route_id');
        $('.box_div').each(function(i) {
             if(current_route != $(this).attr('route_id')) {
                if(path_ids == $(this).attr('path_ids')) {
                    $('.mdq_info2', $(this)).attr('value', rmdq_final);
                    $('.mdq_info2', $(this)).text(format_number_to_comma_separated(rmdq_final));
                }
             }
        });
        
        */

        if (limit_exceeded == '1') {
            $('.bottom_div', box_div).addClass('limit_exceeded_box');
        }

    }

</script>
<!-- Division for div End-->

<style>
.dhxform_obj_dhx_web div.dhxform_btn {
    background-color: #7CD6A9 !important;
}
.dhxform_obj_dhx_web div.dhxform_btn:hover {
    background-color: #44C484 !important;
}
.color_red { color: red; }

<?php
    if ($call_from == 'flow_deal_match') {
        echo '.chk_all, .chk_cell, .row_chk, .col_chk, .path_insert {
            display: none;
        }
        .tbl_contract_pop_up_header {
            background: #94D8B7;
        }
        .center_div {
            cursor: default;
        }
        ';
    }

?>

</style>

