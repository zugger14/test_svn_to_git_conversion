<?php
/**
* Shaped deals screen
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
        $form_namespace = 'shapedDeal';
        
        $deal_id = (isset($_POST["deal_ref_ids"]) && $_POST["deal_ref_ids"] != '') ? get_sanitized_value($_POST["deal_ref_ids"]) : 'NULL';
        $detail_id = (isset($_POST["detail_ids"]) && $_POST["detail_ids"] != '') ? get_sanitized_value($_POST["detail_ids"]) : 'NULL';

        $term_start = (isset($_POST["term_start"]) && $_POST["term_start"] != '') ? "'" . get_sanitized_value($_POST["term_start"]) . "'": 'NULL';
        $term_end = (isset($_POST["term_end"]) && $_POST["term_end"] != '') ? "'" . get_sanitized_value($_POST["term_end"]) . "'": 'NULL';
        $template_id = (isset($_POST["template_id"]) && $_POST["template_id"] != '') ? get_sanitized_value($_POST["template_id"]) : 'NULL';
        $process_id = (isset($_POST["process_id"]) && $_POST["process_id"] != '') ? get_sanitized_value($_POST["process_id"]) : 'NULL';
        $leg = (isset($_POST["leg"]) && $_POST["leg"] != '') ? get_sanitized_value($_POST["leg"]) : 'NULL';
        $volume = (isset($_POST["volume"]) && $_POST["volume"] != '') ? get_sanitized_value($_POST["volume"]) : 'NULL';
        $price = (isset($_POST["price"]) && $_POST["price"] != '') ? get_sanitized_value($_POST["price"]) : 'NULL';
        $copy_deal_id = (isset($_POST["copy_deal_id"]) && $_POST["copy_deal_id"] != '') ? get_sanitized_value($_POST["copy_deal_id"]) : 'NULL';
        $is_new = (isset($_POST["is_new"]) && $_POST["is_new"] != '') ? get_sanitized_value($_POST["is_new"]) : 'NULL';
        $granularity = (isset($_POST["granularity"]) && $_POST["granularity"] != '') ? get_sanitized_value($_POST["granularity"]) : 'NULL';

        $location_id = (isset($_POST["location_id"]) && $_POST["location_id"] != '') ? get_sanitized_value($_POST["location_id"]) : 'NULL';
        $curve_id = (isset($_POST["curve_id"]) && $_POST["curve_id"] != '') ? get_sanitized_value($_POST["curve_id"]) : 'NULL';
        $contract_id = (isset($_POST["contract_id"]) && $_POST["contract_id"] != '') ? get_sanitized_value($_POST["contract_id"]) : 'NULL';
        $detail_commodity_id = isset($_GET["detail_commodity_id"]) ? get_sanitized_value($_GET["detail_commodity_id"]) : '';


        if ($is_new == 'y') {
            $source_deal_detail_id = "'" . $detail_id . "'";
        } else {
            $source_deal_detail_id = $detail_id;
        }

        $process_id = ($process_id == 'NULL') ? $process_id : "'" . $process_id . "'";
        
        $sp_grid = "EXEC spa_update_shaped_volume @flag='s', @source_deal_detail_id=" . $source_deal_detail_id . ", @source_deal_header_id=" . $deal_id . ",@term_start=" . $term_start . ", @term_end=" . $term_end . ", @template_id=" . $template_id . ", @process_id=" . $process_id . ", @leg=" . $leg . ", @copy_deal_id=".$copy_deal_id . ",@granularity=".$granularity . ", @location_id=" . $location_id . ", @curve_id=" . $curve_id . ",@contract_id=" . $contract_id;
        $data = readXMLURL2($sp_grid);
        
        $granularity = ($granularity == 'NULL') ? $data[0]['granularity'] : $granularity;
        $max_leg = $data[0]['max_leg'];
        $term_start = $data[0]['term_start'];
        $term_end = $data[0]['term_end'];
        $process_id = $data[0]['process_id'];
        $min_term_start = $data[0]['min_term_start'];
        $max_term_end = $data[0]['max_term_end'];
		$is_locked = $data[0]['is_locked'];
        $dst_term = $data[0]['dst_term'];

        //982, 989, 987, 994
        if ($granularity == 982 || $granularity == 989 || $granularity == 987 || $granularity == 994) {
            $show_hour = true;
        } else {
            $show_hour = false;
        }

        if ($granularity == 989 || $granularity == 987 || $granularity == 994) {
            $sp_hour = "EXEC('Select n-1 id, n-1 name from seq WHERE n <= 24')";
        } else {
            if($detail_commodity_id == -1){
                $sp_hour = "select n id , n name from seq WHERE n between 7 AND 24 union all select n id , n name from seq WHERE n  between 1 and 6";
            } else {
                $sp_hour = "EXEC('Select n id, n name from seq WHERE n <= 24')";
            }
        } 

        $layout_json = '[{id: "a", text:"Filter",header:true,height:100},{id: "b", header:false}]';
                          
        $layout_obj = new AdihaLayout();
        $form_obj = new AdihaForm();
        
        $sp_url = "EXEC('Select n id, n name from seq WHERE n <= " . $max_leg . "')";
        $leg_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

        $hr_json = $form_obj->adiha_form_dropdown($sp_hour, 0, 1, true);

        $form_json = '[ 
                        {"type": "settings", "position": "label-top", "offsetLeft": 10,inputWidth:150},
                        {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_start", "label": "Term Start", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
                        {"type":"newcolumn"},
                        {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_end", "label": "Term End", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"},
                        {"type":"newcolumn"},
                        {type:"combo", name:"leg", "options": ' . $leg_json . ' ,label:"Leg", required:false, "offsetLeft":"10"},
                        {type: "hidden", name:"process_id", value:"' . $process_id . '"},
                        {"type":"newcolumn"},
                        {type:"combo", name:"volume_price", label:"Volume/Price", required:false, "offsetLeft":"10","options":[
                            {value:"", label:""},
                            {value:"v", label:"Volume"},
                            {value:"p", label:"Price"}
                            ]
                        }
                        ';
            if ($show_hour) {
                $form_json .= ',{"type":"newcolumn"},                       
                                {type:"combo", name:"hr_from", "options": ' . $hr_json . ' ,label:"Interval Start", required:false, "offsetLeft":"10"},
                                {"type":"newcolumn"},
                                {type:"combo", name:"hr_to", "options": ' . $hr_json . ' ,label:"Interval End", required:false, "offsetLeft":"10"}
                                ';
            }
            
        $form_json .= ']';

        echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);
        echo $layout_obj->attach_form('form', 'a');
        
        echo $form_obj->init_by_attach('form', $form_namespace);
        echo $form_obj->load_form($form_json);
        echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
        
        $menu_json = '[
                        {id:"refresh", text:"Refresh", img:"refresh.gif", title:"Refresh", enabled:true},
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"save", text:"Save", img: "save.gif", imgdis: "save_dis.gif", title: "Save"}        
                      ]';
        $menu_object = new AdihaMenu();
        echo $layout_obj->attach_menu_cell('menu', 'b');
        echo $menu_object->init_by_attach('menu', $form_namespace);
        echo $menu_object->load_menu($menu_json);
        echo $menu_object->attach_event('', 'onClick', $form_namespace . '.menu_click');
        
        echo $layout_obj->attach_status_bar("b", true);
        echo $layout_obj->close_layout();

        $volume = ($volume == 'NULL') ? '' : $volume;
        $price = ($price == 'NULL') ? '' : $price;
    ?>
</body>

<textarea style="display:none" name="txt_vol" id="txt_vol"><?php echo $volume;?></textarea>
<textarea style="display:none" name="txt_price" id="txt_price"><?php echo $price;?></textarea>
<textarea style="display:none" name="txt_process" id="txt_process"><?php echo $process_id;?></textarea>
<script type="text/javascript">
    var save_flag = 'n';
    var granularity = '<?php echo $granularity;?>';    
    var leg = '<?php echo $leg;?>';
    var dst_term = '<?php echo $dst_term;?>';

    $(function() {
		var is_locked = '<?php echo $is_locked;?>';
		if (is_locked == 'y') {
			shapedDeal.menu.setItemDisabled('save');
		}
		
        if (leg != 'NULL') {
            shapedDeal.form.disableItem('leg');
        }

        if (granularity == '') {
            show_messagebox('Granularity is not defined in template.', function() {
                var win_obj = window.parent.volume_window.window("w1");
                win_obj.close();
            });
            return;
        }
        
        var min_term = '<?php echo $min_term_start;?>';
        var max_term = '<?php echo $max_term_end;?>';
        var from_cal = shapedDeal.form.getCalendar('term_start');
        var to_cal = shapedDeal.form.getCalendar('term_end');
        from_cal.setSensitiveRange(min_term, max_term);
        to_cal.setSensitiveRange(min_term, max_term);
        
        shapedDeal.load_grid();
    });
    
    /**
     * [menu_click Form Menu click function]
     * @param  {[type]} id [menu id]
     */
    shapedDeal.menu_click = function(id) {
        switch(id) {
            case 'refresh':
                shapedDeal.save_changes('refresh');
                break;
            case "pdf":
                shapedDeal.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                shapedDeal.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'save':
                shapedDeal.save_changes('save');
                break;              
        }
    }
    
    /**
     * [save_changes Save changed data]
     * @param  {[type]} call_from [call from flag]
     */
    shapedDeal.save_changes = function(call_from) {
        shapedDeal.grid.clearSelection();
        var changed_rows = shapedDeal.grid.getChangedRows(true);
        var template_id = '<?php echo $template_id;?>';
        var copy_deal_id = '<?php echo $copy_deal_id;?>';

        var term_start = shapedDeal.form.getItemValue("term_start", true);
        var term_end = shapedDeal.form.getItemValue("term_end", true);

        if (changed_rows != '') {
            var grid_xml = '<GridXML>';
            var changed_ids = new Array();
            changed_ids = changed_rows.split(",");
            $.each(changed_ids, function(index, value) {
                grid_xml += '<GridRow ';
                for(var cellIndex = 0; cellIndex < shapedDeal.grid.getColumnsNum(); cellIndex++){
                    var column_id = shapedDeal.grid.getColumnId(cellIndex);
                    var cell_value = shapedDeal.grid.cells(value, cellIndex).getValue();
                    if (column_id == 'term_date') {
                        cell_value = dates.convert_to_sql(cell_value);
                    }
                    grid_xml += ' col_' + column_id + '="' + cell_value + '"';
                }
                grid_xml += '></GridRow>';
            });
            grid_xml += '</GridXML>';
            
            var deal_id = '<?php echo $deal_id;?>'; 
            var process_id = (shapedDeal.form.getItemValue('process_id') == '') ? 'NULL' : shapedDeal.form.getItemValue('process_id');
            var granularity = '<?php echo $granularity;?>';
            var contract_id = '<?php echo $contract_id;?>';
            var curve_id = '<?php echo $curve_id;?>';
            var location_id = '<?php echo $location_id;?>';
            data = {'action' : 'spa_update_shaped_volume', 
                    'flag' : 'u', 
                    'xml' : grid_xml,
                    'source_deal_header_id' : deal_id,
                    'process_id':process_id,
                    'template_id':template_id,
                    'copy_deal_id':copy_deal_id,
                    'term_start':term_start,
                    'term_end':term_end,
                    'granularity':granularity,
                    'curve_id':curve_id,
                    'location_id':location_id,
                    'contract_id':contract_id


            };
            
            if (call_from == 'save')
                save_flag = 'y';
            else 
                save_flag = 'n';
            
            adiha_post_data("return", data, '', '', 'shapedDeal.save_temp_callback');
        } else {
            if (call_from == 'refresh')
                shapedDeal.load_grid();
            else 
                shapedDeal.save_data();
        }
    }
    
    /**
     * [save_temp_callback Save callback for temporary table]
     * @param  {[type]} result [returned array]
     */
    shapedDeal.save_temp_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            if (save_flag == 'y') {
                shapedDeal.save_data();
                save_flag = 'n';
            } else {
                shapedDeal.load_grid();
            }
        }
    }
    
    /**
     * [save_data Save data]
     */
    shapedDeal.save_data = function() {
        var deal_id = '<?php echo $deal_id;?>'; 
        var process_id = (shapedDeal.form.getItemValue('process_id') == '') ? 'NULL' : shapedDeal.form.getItemValue('process_id');
        var term_start = shapedDeal.form.getItemValue("term_start", true);
        var term_end = shapedDeal.form.getItemValue("term_end", true);

        var detail_id = '<?php echo $detail_id;?>';
        var template_id = '<?php echo $template_id;?>';
        var leg = '<?php echo $leg;?>';
        var copy_deal_id = '<?php echo $copy_deal_id;?>';
        var granularity = '<?php echo $granularity;?>';
        var contract_id = '<?php echo $contract_id;?>';
        var curve_id = '<?php echo $curve_id;?>';
        var location_id = '<?php echo $location_id;?>';
        data = {'action' : 'spa_update_shaped_volume', 
                'flag' : 'v', 
                'source_deal_header_id' : deal_id,
                'process_id':process_id,
                'template_id':template_id,
                'source_deal_detail_id' : detail_id,
                'leg':leg,
                'copy_deal_id':copy_deal_id,
                'term_start':term_start,
                'term_end':term_end,
                'granularity':granularity,
                'curve_id':curve_id,
                'location_id':location_id,
                'contract_id':contract_id
        };
        shapedDeal.layout.cells('b').progressOn();
        adiha_post_data("alert", data, '', '', 'shapedDeal.save_callback');
    }
    
    /**
     * [save_callback Save callback]
     * @param  {[type]} result [returned array]
     */
    shapedDeal.save_callback = function(result) {
        shapedDeal.layout.cells('b').progressOff();
        if (result[0].errorcode == 'Success') {
            if (result[0].recommendation != '' && result[0].recommendation != null) {
                var ret_val = result[0].recommendation;
                var vol = '';
                var price = '';

                if (ret_val.indexOf("::") !== -1) {
                    var ret_arr = new Array();
                    ret_arr = ret_val.split("::");
                    vol = ret_arr[0];
                    price = ret_arr[1];
                } else {
                    vol = ret_val;
                }
                document.getElementById("txt_vol").value = vol;
                document.getElementById("txt_price").value = price;
            }
            shapedDeal.load_grid();
        }
    }
    
    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    shapedDeal.form_change = function(name, value) {
        var term_start = shapedDeal.form.getItemValue("term_start", true);
        var term_end = shapedDeal.form.getItemValue("term_end", true);
        var min_max_val = (name == 'term_start') ? term_end : term_start;
        
        if (dates.compare(term_end, term_start) == -1) {
            if (name == 'term_start') {
                shapedDeal.form.setItemValue('term_end', term_start);
                return;
            } else {
                var message = 'Term End cannot be greater than Term Start.';
            }
            shapedDeal.show_error(message, name, min_max_val);
            return;
        }
    }
    
    /**
     * [show_error Show Error]
     * @param  {[string]} message     [Message]
     * @param  {[string]} name        [Item name]
     * @param  {[date]} min_max_val   [Date]
     */
    shapedDeal.show_error = function(message, name, min_max_val) {
        show_messagebox(message, function() {
            shapedDeal.form.setItemValue(name, min_max_val);
        });
    }
    
    /**
     * [load_grid Load Grid]
     */
    shapedDeal.load_grid = function() {
        var term_start = shapedDeal.form.getItemValue("term_start", true);
        var term_end = shapedDeal.form.getItemValue("term_end", true);
        var leg = shapedDeal.form.getItemValue("leg");
        var show_hour = Boolean('<?php echo $show_hour; ?>');
        var process_id = (shapedDeal.form.getItemValue('process_id') == '') ? 'NULL' : shapedDeal.form.getItemValue('process_id');
                
        var deal_id = '<?php echo $deal_id;?>';
        var detail_id = '<?php echo $detail_id;?>';
        var template_id = '<?php echo $template_id;?>';
        var leg = '<?php echo $leg;?>';
        var copy_deal_id = '<?php echo $copy_deal_id;?>';

        var hr_from = 'NULL';
        var hr_to = 'NULL';

        if (show_hour) {
            hr_from = (shapedDeal.form.getItemValue('hr_from') == '') ? 'NULL' : shapedDeal.form.getItemValue('hr_from');
            hr_to = (shapedDeal.form.getItemValue('hr_to') == '') ? 'NULL' : shapedDeal.form.getItemValue('hr_to');
			
            if (Number(hr_from) > Number(hr_to)) {
                show_messagebox("<b>Interval End</b> should be greater than <b>Interval Start</b>");
                return
            }
        }
        shapedDeal.layout.cells('b').progressOn();
        var granularity = '<?php echo $granularity;?>';
        var contract_id = '<?php echo $contract_id;?>';
        var curve_id = '<?php echo $curve_id;?>';
        var location_id = '<?php echo $location_id;?>';
        data = {'action' : 'spa_update_shaped_volume', 
                'flag' : 't', 
                'source_deal_header_id' : deal_id,
                'source_deal_detail_id' : detail_id,
                'term_start' : term_start,
                'term_end' : term_end,
                'hour_from':hr_from,
                'hour_to':hr_to,
                'process_id':process_id,
                'template_id':template_id,
                'leg':leg,
                'copy_deal_id':copy_deal_id,
                'granularity':granularity,
                'curve_id':curve_id,
                'location_id':location_id,
                'contract_id':contract_id
            };
       adiha_post_data('return', data, '', '', 'shapedDeal.load_grid_callback');
    }
    
    /**
     * [load_grid_callback Load Grid Callback - create grid]
     */
    shapedDeal.load_grid_callback = function(result) {
        var show_hour = Boolean('<?php echo $show_hour; ?>');
        if (shapedDeal.grid) {
            shapedDeal.grid.destructor();
        }
        shapedDeal.grid = shapedDeal.layout.cells('b').attachGrid();
        shapedDeal.grid.setImagePath(js_image_path + "dhxgrid_web/");
        shapedDeal.grid.setPagingWTMode(true,true,true,true);
        shapedDeal.grid.enablePaging(true, 50, 0, 'pagingArea_b'); 
        shapedDeal.grid.setPagingSkin('toolbar');        
        shapedDeal.grid.setHeader(result[0].column_label);
        shapedDeal.grid.setColumnIds(result[0].column_list);
        shapedDeal.grid.setColTypes(result[0].column_type);
        shapedDeal.grid.setInitWidths(result[0].column_width);
        shapedDeal.grid.setDateFormat(user_date_format, '%Y-%m-%d');
        
        var split_at;
        if (show_hour) {
            split_at = 5;
        } else {
            split_at = 4;
        }
        shapedDeal.grid.splitAt(split_at);

        shapedDeal.grid.init();       
        shapedDeal.grid.setColumnsVisibility(result[0].visibility);
        shapedDeal.grid.enableEditEvents(true,false,true);

        shapedDeal.grid.attachEvent('onEditCell', function(stage, rId, cInd, nValue, oValue) {
            var column_id = shapedDeal.grid.getColumnId(cInd);
            if (column_id.indexOf('_DST') != -1) {
                if (dst_term != '') {
                    var term_index = shapedDeal.grid.getColIndexById('term_date');
                    var term_date = shapedDeal.grid.cells(rId, term_index).getValue();

                    if (dates.compare(term_date, dst_term) != 0) {
                        return false;
                    }
                }
            }

            return true;
        });

        shapedDeal.grid.attachEvent("onBeforeContextMenu", function(id, ind, obj) {
            shapedDeal.grid.selectRowById(id);
            return !(ind < split_at);
        });
        
        var term_start = shapedDeal.form.getItemValue("term_start", true);
        var term_end = shapedDeal.form.getItemValue("term_end", true);
        var leg = (shapedDeal.form.getItemValue("leg") == '') ? 'NULL' : shapedDeal.form.getItemValue("leg");
        var process_id = (shapedDeal.form.getItemValue('process_id') == '') ? 'NULL' : shapedDeal.form.getItemValue('process_id');

        var hr_from = 'NULL';
        var hr_to = 'NULL';
        
        var deal_id = '<?php echo $deal_id; ?>';
        var detail_id = '<?php echo $detail_id; ?>';
        var template_id = '<?php echo $template_id; ?>';
        var copy_deal_id = '<?php echo $copy_deal_id; ?>';
        
        if (template_id != 'NULL' || copy_deal_id != 'NULL')
            leg = '<?php echo $leg; ?>';
        
        if (show_hour) {
            var hr_from = (shapedDeal.form.getItemValue('hr_from') == '') ? 'NULL' : shapedDeal.form.getItemValue('hr_from');
            var hr_to = (shapedDeal.form.getItemValue('hr_to') == '') ? 'NULL' : shapedDeal.form.getItemValue('hr_to');
        }

        var volume_price = shapedDeal.form.getItemValue('volume_price');

        volume_price = (volume_price == '') ? 'NULL' : volume_price;
        var granularity = '<?php echo $granularity; ?>';
        var contract_id = '<?php echo $contract_id; ?>';
        var curve_id = '<?php echo $curve_id; ?>';
        var location_id = '<?php echo $location_id; ?>';

        param = {
            'action' : 'spa_update_shaped_volume', 
            'flag' : 'a', 
            'source_deal_header_id' : deal_id,
            'source_deal_detail_id' : detail_id,
            'term_start' : term_start,
            'term_end' : term_end,
            'hour_from': hr_from,
            'hour_to': hr_to,
            'process_id': process_id,
            'volume_price': volume_price,
            'template_id': template_id,
            'leg': leg,
            'copy_deal_id': copy_deal_id,
            'granularity': granularity,
            'curve_id': curve_id,
            'location_id': location_id,
            'contract_id': contract_id
        };

        param = $.param(param);
        var refresh_url = js_data_collector_url + '&' + param;

        shapedDeal.grid.loadXML(refresh_url, function() {
            var col_type = result[0].column_type;
            var col_array = col_type.split(",");

            var type_name_cId = shapedDeal.grid.getColIndexById("type_name");
            var term_date_col_ind = shapedDeal.grid.getColIndexById("term_date");
            
            shapedDeal.grid.forEachRow(function(rId) {
                col_array.forEach(function(item, index) {
                    if (index >= split_at) {
                        var type_cId = shapedDeal.grid.getColIndexById("type");
                        var type = shapedDeal.grid.cells(rId,type_cId).getValue();

                        if ('p' == type ) {
                            shapedDeal.grid.setCellExcellType(rId, index, 'ed_p');
                        } else if ('v' == type ) {
                            shapedDeal.grid.setCellExcellType(rId, index, 'ed_v');
                        }
                    }
                });
            });
        });

        shapedDeal.layout.cells('b').progressOff();       
        save_flag = 'y';

        var context_menu = new dhtmlXMenuObject();
        context_menu.renderAsContextMenu();
        var menu_obj = [
            {id: "apply_to_all", text: "Apply To All"}
        ];
        context_menu.loadStruct(menu_obj);
        shapedDeal.grid.enableContextMenu(context_menu);

        context_menu.attachEvent("onClick", function(menu_item_id) {
            switch(menu_item_id) {
                case "apply_to_all":
                    // Grid contextID provides row id and column index in array
                    var data = shapedDeal.grid.contextID.split("_");
                    var col_ind = data[data.length -1];
                    var row_id = shapedDeal.grid.getSelectedRowId();

                    var cell_value = shapedDeal.grid.cells(row_id, col_ind).getValue();
                    shapedDeal.grid.forEachCell(row_id, function(cell_obj, ind) {
                        if (ind > split_at - 1 && ind != col_ind) {
                            cell_obj.setValue(cell_value);
                        }
                    });
                    break;
                default:
                    break;
            }
        });
    }
</script>
</html>