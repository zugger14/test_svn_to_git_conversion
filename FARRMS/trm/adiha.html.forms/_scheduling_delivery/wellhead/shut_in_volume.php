<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
</head>

<?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>

<?php 
    // Default date value for date component
    $date = date('Y-m-d');
    $date_begin = date('Y-m-01');
    $date_end = date('Y-m-t');
    //echo '<pre>'.print_r($client_date_format . ':' . $date_format);exit;
    $rights_shut_in_volume  = 10166900;
    $rights_shut_in_volume_i = 10166910;
    $rights_shut_in_volume_u = 10166911;
    $rights_shut_in_volume_delete = 10166912;
        
    list (
        $has_rights_shut_in_volume,
        $has_rights_shut_in_volume_i,
        $has_rights_shut_in_volume_u,
        $has_rights_shut_in_volume_delete
        ) = build_security_rights(
        $rights_shut_in_volume,
        $rights_shut_in_volume_i, 
        $rights_shut_in_volume_u,
        $rights_shut_in_volume_delete
    );
    
	/*Layout*/
	$layout_json = '[
                        {
                            id:             "a",
                            text:           "Filter",
                            height:         135,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            header:         false,
                        }
                    ]';

    $name_space = 'shut_in_volume';
    $shut_in_volume_layout = new AdihaLayout();
    echo $shut_in_volume_layout->init_layout('shut_in_volume_layout', '', '2E', $layout_json, $name_space);

    /*Filter Form*/
    $form_name = 'form_shut_in_volume';
    $form_object = new AdihaForm();
       
    $from_layout = "[	
                        {type: 'settings', labelWidth: 120, inputWidth: ".$ui_settings['field_size'].", position: 'label-top', offsetLeft: ".$ui_settings['offset_left']."},
    					{type: 'combo', comboType: 'custom_checkbox', name: 'nom_group', label: 'Nomination Group', filtering: true}, {type: 'newcolumn'},
					    {type: 'combo', comboType: 'custom_checkbox', name: 'wellhead', validate:'', value:'b', label: 'Wellhead', options:[], filtering: true},{type: 'newcolumn'},
					    {type: 'calendar', required: true, name: 'term_start', value: '$date_begin', label: 'Flow Date From', dateFormat: '$date_format'},{type: 'newcolumn'},
					    {type: 'calendar', required: true, name: 'term_end', value: '$date_end', label: 'Flow Date To', dateFormat: '$date_format'},{type: 'newcolumn'},
                        {type:'input', name:'comments', label:'Comment', hidden:false}
				    ]";
  
    echo $shut_in_volume_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($from_layout);
    
    echo '
    dhxCombo_ng = shut_in_volume.form_shut_in_volume.getCombo("nom_group");
    dhxCombo_ng.attachEvent("onClose", fx_cmb_ng_onclose);
    
    dhxCombo_wh = shut_in_volume.form_shut_in_volume.getCombo("wellhead");
    dhxCombo_wh.attachEvent("onClose", fx_cmb_wh_onclose);
    ';
   
    /* Menu */ 
    $menu_json = '  [   
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                        {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title:"Save"},  
                        {id:"t1", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", title:"Expand/Collapse", disabled: 1},
                        {id:"t2", text:"Action", img:"action.gif", items:[
                            {id:"insert", text:"Insert", img:"add.gif", imgdis:"add_dis.gif", title:"Insert"},
                            {id:"update", text:"Update", img:"edit.gif", imgdis:"edit_dis.gif", title:"Update", disabled: 1},
                            {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", title:"Delete", disabled: 1}
                        ]}
                    ]';

    $menu_shut_in_volume_obj = new AdihaMenu();
    echo $shut_in_volume_layout->attach_menu_cell("menu_shut_in_volume", "b"); 
    echo $menu_shut_in_volume_obj->init_by_attach("menu_shut_in_volume", $name_space);
    echo $menu_shut_in_volume_obj->load_menu($menu_json);
    echo $menu_shut_in_volume_obj->attach_event('', 'onClick', 'menu_shut_in_volume_onClick');

    /*Grid*/

    $grid_name = 'grid_shut_in_volume';
    $grid_shut_in_volume_obj = new AdihaGrid();

    echo $shut_in_volume_layout->attach_grid_cell($grid_name, 'b');

    echo $grid_shut_in_volume_obj->init_by_attach($grid_name, $name_space);
    echo $grid_shut_in_volume_obj->set_header('Wellhead, Nom Id, Meter Id, Comments, Status, Term Start, Term End');
    echo $grid_shut_in_volume_obj->set_columns_ids('NomGroup,Term,Meter,nom_group_id,meter_id,comments,shutin_process,term_start,term_end');
    echo $grid_shut_in_volume_obj->set_column_types('tree,ro,ro,txt,combo,ro,ro');
    echo $grid_shut_in_volume_obj->set_widths('250,100,300,800,*');
    echo $grid_shut_in_volume_obj->enable_multi_select();
    echo $grid_shut_in_volume_obj->return_init();
    echo $grid_shut_in_volume_obj->set_column_visibility('false,true,true,false,false,true,true');
    
    echo $shut_in_volume_layout->close_layout();
    
?>

<script>
    var has_rights_shut_in_volume = '<?php echo (($has_rights_shut_in_volume) ? $has_rights_shut_in_volume : '0'); ?>';
    var has_rights_shut_in_volume_i = '<?php echo (($has_rights_shut_in_volume_i) ? $has_rights_shut_in_volume_i : '0'); ?>';
    var has_rights_shut_in_volume_u = '<?php echo (($has_rights_shut_in_volume_u) ? $has_rights_shut_in_volume_u : '0'); ?>';
    var has_rights_shut_in_volume_delete = '<?php echo (($has_rights_shut_in_volume_delete) ? $has_rights_shut_in_volume_delete : '0'); ?>';
     
    var DEBUG_PROCESS = false;
    var post_data = '';
    
    function combo_options (sql) { 
        var data = $.param(sql);
        var url = js_dropdown_connector_url + '&' + data;
        return url;
    } 
    

    $(function() {
        //var combo_nom_group = shut_in_volume.form_shut_in_volume.getCombo('nom_group');
        if (has_rights_shut_in_volume == 1){
            shut_in_volume.menu_shut_in_volume.setItemDisabled('save');
            shut_in_volume.menu_shut_in_volume.setItemDisabled('insert');
            shut_in_volume.menu_shut_in_volume.setItemDisabled('update');
            shut_in_volume.menu_shut_in_volume.setItemDisabled('delete');
        } 
        if (has_rights_shut_in_volume_i == 1){
            shut_in_volume.menu_shut_in_volume.setItemEnabled('save');
            shut_in_volume.menu_shut_in_volume.setItemEnabled('insert');
        } 
          
        var nom_group_sql = {
            "action" : "('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 31800')"
            , 'has_blank_option' : 'false'
            , 'call_from': 'form'
            
        };
        dhxCombo_ng.load(combo_options(nom_group_sql));
        
        fx_load_events();
    });
    //function to load form events
    fx_load_events = function() {
        shut_in_volume.grid_shut_in_volume.attachEvent('onRowSelect', function(rid, cid) {
            if (has_rights_shut_in_volume_u == 1 ){
                shut_in_volume.menu_shut_in_volume.setItemEnabled('save');
                shut_in_volume.menu_shut_in_volume.setItemEnabled('update');
            } 
            if (has_rights_shut_in_volume_delete == 1){
                shut_in_volume.menu_shut_in_volume.setItemEnabled('save');
                shut_in_volume.menu_shut_in_volume.setItemEnabled('delete');
            }
        });
    };
    
    //function to set comma separated selected options on combo text.
    function fx_set_combo_text_final(cmb_obj) {
        var checked_loc_arr = cmb_obj.getChecked();
        var final_combo_text = new Array();
        var final_combo_value = new Array();
        $.each(checked_loc_arr, function(i) {
            var opt_obj = cmb_obj.getOption(checked_loc_arr[i]);
            final_combo_text.push(opt_obj.text);
            final_combo_value.push(opt_obj.value);  
        });
        cmb_obj.setComboText(final_combo_text.join(','));
    }
    //function for onClose event of nomination group combo
    fx_cmb_ng_onclose = function() {
        
        fx_set_combo_text_final(dhxCombo_ng);
        
        var ng_ids = dhxCombo_ng.getChecked().join(',');
        var cm_param = {
            "action": "spa_getAllMeter",
            "flag": "n",
            "group_id": ng_ids,
            "call_from": 'form',
            "has_blank_option": "false"
        };                
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        //var cm_data = shut_in_volume.form_shut_in_volume.getCombo("wellhead");
        dhxCombo_wh.clearAll();
        dhxCombo_wh.setComboText('');
        dhxCombo_wh.load(url, function(e) {
            
        });
        
        
    }
    //function for onClose event of wellhead combo
    fx_cmb_wh_onclose = function() {
        fx_set_combo_text_final(dhxCombo_wh);
    }

    function refresh_grid () {
        if(!shut_in_volume.form_shut_in_volume.validate()) {
            dhtmlx.message({
                title: 'warning',
                type: 'alert-warning',
                text: 'Please select Flow Date From and Flow Date To'
            });
            return;
        }
        
        shut_in_volume.menu_shut_in_volume.setItemDisabled('update');
        shut_in_volume.menu_shut_in_volume.setItemDisabled('delete');
        var combo_nom_group = ((shut_in_volume.form_shut_in_volume.getCombo('nom_group')).getChecked()).join();
        var combo_wellhead = ((shut_in_volume.form_shut_in_volume.getCombo('wellhead')).getChecked()).join();
        var from_date = shut_in_volume.form_shut_in_volume.getItemValue('term_start', true);
        var to_date = shut_in_volume.form_shut_in_volume.getItemValue('term_end', true);
        var comments = shut_in_volume.form_shut_in_volume.getItemValue('comments');

        if (combo_nom_group == '') {
            combo_nom_group = " @nom_header_ids=null,";
        } else {
            combo_nom_group = " @nom_header_ids='" + combo_nom_group + "',";
        }

        if (combo_wellhead == '') {
            combo_wellhead = " @meter_ids=null,";
        } else {
            combo_wellhead = " @meter_ids='" + combo_wellhead + "',";
        }
        

        var spa = "EXEC spa_shutin_process 's'," + combo_nom_group + combo_wellhead + " @term_start='" + from_date + "', @term_end='" + to_date + "'"
            + (comments == '' ? '' : (", @comments='" + comments + "'"));

        var sql_param = {
            "sql":spa,
            "grid_type":"tg",
            "grouping_column":"NomGroup,Term,Meter"
        }
        //console.log(sql_param);
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        shut_in_volume.grid_shut_in_volume.clearAll();
        var grid_combo = shut_in_volume.grid_shut_in_volume.getColumnCombo(4);
        grid_combo.load('{options:[{value: "s", text: "Shutin"},{value: "r", text: "Undo Shutin"}]}');
        shut_in_volume.grid_shut_in_volume.clearAll();
        shut_in_volume.grid_shut_in_volume.loadXML(sql_url, function() {
            var all_rids = shut_in_volume.grid_shut_in_volume.getAllRowIds();
            if(all_rids == '') {
                shut_in_volume.menu_shut_in_volume.setItemDisabled('expand_collapse');
            } else {
                shut_in_volume.menu_shut_in_volume.setItemEnabled('expand_collapse');
            }
            GRID_EXPAND = false;
        }); 
    }
    
    fx_action_click = function(flag) {
        var grid_obj = shut_in_volume.grid_shut_in_volume;
        var selected_rows = grid_obj.getSelectedRowId();
        var meter_ids;
        var term_start;
        var term_end;
        var nom_group_id;
        //alert(shut_in_volume.grid_shut_in_volume.getLevel(selected_rows));
        var arr_meter_id = [];
        var arr_lvl0 = [];
        var arr_lvl1 = [];
        var arr_lvl2 = [];
        var level1_data = false;
        //console.log(grid_obj);
        
        var case_type = 'none';
        if(selected_rows.indexOf(',') != -1) {
            $.each(selected_rows.split(','), function(k,v) {
                
                if(grid_obj.getLevel(v) == 0) {
                    arr_lvl0.push(v);
                } else if(grid_obj.getLevel(v) == 1) {
                    arr_lvl1.push(v);
                } else {
                    arr_lvl2.push(v);
                }
            });
            
        } else {
            if(grid_obj.getLevel(selected_rows) == 0) {
                arr_lvl0.push(selected_rows);
            } else if(grid_obj.getLevel(selected_rows) == 1) {
                arr_lvl1.push(selected_rows);
            } else {
                arr_lvl2.push(selected_rows);
            }
        }
        
        if(arr_lvl0.length > 0 && arr_lvl1.length == 0 && arr_lvl2.length == 0) {
            case_type = 'only_0';
        } else if(arr_lvl0.length == 0 && arr_lvl1.length > 0 && arr_lvl2.length == 0) {
            case_type = 'only_1';
        } else if(arr_lvl0.length == 0 && arr_lvl1.length == 0 && arr_lvl2.length > 0) {
            case_type = 'only_2';
        } else if(arr_lvl0.length > 0 && arr_lvl1.length > 0 && arr_lvl2.length > 0) {
            case_type = 'all';
        } else if(arr_lvl0.length > 0 && arr_lvl1.length > 0 && arr_lvl2.length == 0) {
            case_type = 'mix_0_1';
        } else if(arr_lvl0.length > 0 && arr_lvl1.length == 0 && arr_lvl2.length > 0) {
            case_type = 'mix_0_2';
        } else if(arr_lvl0.length == 0 && arr_lvl1.length > 0 && arr_lvl2.length > 0) {
            case_type = 'mix_1_2';
        } else {
            case_type = case_type;
        }
        
        switch(case_type) {
            case 'only_2':
                if(flag == 'delete') {
                    dhtmlx.message({
                        type: 'alert',
                        title: 'Alert',
                        text: 'Please select only one date group (second level) to delete.'
                    });
                    return;
                } else if(flag == 'update') {
                    if(selected_rows.indexOf(',') != -1) {
                        $.each(selected_rows.split(','), function(k, v) {
                            arr_meter_id.push(grid_obj.cells(v, 2).getValue());
                            term_start = grid_obj.cells(v, 5).getValue();
                            term_end = grid_obj.cells(v, 6).getValue();
                        });
                        meter_ids = arr_meter_id.join(',');
                    } else {
                        meter_ids = grid_obj.cells(selected_rows, 2).getValue();
                        term_start = grid_obj.cells(selected_rows, 5).getValue();
                        term_end = grid_obj.cells(selected_rows, 6).getValue();
                    }
                }
                
                
                break;
            case 'only_1':
                if(flag == 'delete') {
                    if(selected_rows.indexOf(',') != -1) {
                        dhtmlx.message({
                            type: 'alert',
                            title: 'Alert',
                            text: 'Please select only one date group (second level) to delete.'
                        });
                        return;
                    } else {
                        var term_range = grid_obj.cells(selected_rows, 0).getValue().split('~');
                        term_start = dates.convert_to_sql(term_range[0]);
                        term_end = dates.convert_to_sql(term_range[1]);
                        var child_row_ids = grid_obj.getSubItems(selected_rows);
                        if(child_row_ids.indexOf(',') == -1) {
                            meter_ids = grid_obj.cells(child_row_ids, 2).getValue();
                            nom_group_id = grid_obj.cells(child_row_ids, 1).getValue();
                        } else {
                            $.each(child_row_ids.split(','), function(k, v) {
                                arr_meter_id.push(grid_obj.cells(v, 2).getValue());
                                nom_group_id = grid_obj.cells(v, 1).getValue();
                                //alert(nom_group_id);
                            });
                            meter_ids = arr_meter_id.join(',');
                            
                        }
                        
                    }
                } else if(flag == 'update') {
                    dhtmlx.message({
                        title: 'Alert',
                        type: 'alert',
                        text: 'Please select one to many meters to update shut in volume.'
                    });
                    return;
                }
                
                
                break;
            default:
                if(flag == 'delete') {
                    dhtmlx.message({
                        type: 'alert',
                        title: 'Alert',
                        text: 'Please select only one date group (second level) to delete.'
                    });
                    return;
                } else if(flag == 'update') {
                    dhtmlx.message({
                        title: 'Alert',
                        type: 'alert',
                        text: 'Please select one to many meters to update shut in volume.'
                    });
                    return;
                }
            
        }
        
        if(flag == 'update') {
            parent.TRMHyperlink(10164000, meter_ids, term_start, term_end);
        } else if(flag == 'delete') {
            confirm_messagebox('Do you want to continue?', function() {
                var delete_url = "EXEC spa_shutin_process @flag='d', @nom_header_ids='" + nom_group_id + 
                    "', @meter_ids='" + meter_ids + "', @term_start='" + term_start + "', @term_end='" + term_end + "'";
                //console.log(delete_url);return;
                post_data = { sp_string: delete_url };
                $.ajax({
                    url: js_form_process_url,
                    data: post_data,
                }).done(function(data) {
                    DEBUG_PROCESS && console.log(data);
                    var json_data = data['json'][0];
                    if(json_data.errorcode == 'Success') {
                        success_call('Shutin deleted successfully.');
                        refresh_grid();
                    } else {
                        parent.parent.dhtmlx.message({
                            title: 'Alert',
                            type: 'alert',
                            text: 'Error on deletion. (' + json_data.message + ')'
                        });
                    }
                    
                });    
            });
            
        }
        
    };

    function save_onClick () {
        var changed_rows = (shut_in_volume.grid_shut_in_volume.getChangedRows(true)).split(",");
        var is_shutin = false;
        var xml = "<Root>"; 
        var parent_xml = "";
        var group_xml = "";
        if(shut_in_volume.grid_shut_in_volume.getChangedRows(true) == '') {
            dhtmlx.message({
                title: 'warning',
                type: 'alert-warning',
                text: 'No rows changed.'
            });
            return;
        }
        
        $.each(changed_rows, function(i, row_id) {
            var get_process = shut_in_volume.grid_shut_in_volume.cells(row_id, 4).getValue();
            
            if(get_process == 's') {
                is_shutin = true;
            }

            var level = shut_in_volume.grid_shut_in_volume.getLevel(row_id);

            var get_nom_group_id = shut_in_volume.grid_shut_in_volume.cells(row_id, 1).getValue();
            var get_meter_id = shut_in_volume.grid_shut_in_volume.cells(row_id, 2).getValue();
            var get_comment = shut_in_volume.grid_shut_in_volume.cells(row_id, 3).getValue();
            var get_process = shut_in_volume.grid_shut_in_volume.cells(row_id, 4).getValue();
            var get_term_start = shut_in_volume.grid_shut_in_volume.cells(row_id, 5).getValue();
            var get_term_end = shut_in_volume.grid_shut_in_volume.cells(row_id, 6).getValue();

            if (level == 0) {
                var subitems = (shut_in_volume.grid_shut_in_volume.getSubItems(row_id)).split(",");
                var subitems_level = shut_in_volume.grid_shut_in_volume.getLevel(subitems[0]);

                if (subitems_level == 1) {
                    var items = (shut_in_volume.grid_shut_in_volume.getSubItems(subitems[0])).split(",");
                    DEBUG_PROCESS && console.log(items);
                    $.each(items, function(i,v) {                        
                        get_nom_group_id = shut_in_volume.grid_shut_in_volume.cells(v, 1).getValue();
                        get_term_start = shut_in_volume.grid_shut_in_volume.cells(v, 5).getValue();
                        get_term_end = shut_in_volume.grid_shut_in_volume.cells(v, 6).getValue();
                    });
                    
                }

                parent_xml += "<grid nom_groups_id=\"" + get_nom_group_id + "\" meter_id=\"\" comments=\"" + get_comment + "\" process=\"" + get_process + "\" term_start=\"\" term_end=\"\" />";
            }

            if (level == 1) {
                var items = (shut_in_volume.grid_shut_in_volume.getSubItems(row_id)).split(",");

                $.each(items, function(i,v) {
                    get_nom_group_id = shut_in_volume.grid_shut_in_volume.cells(v, 1).getValue();
                    get_term_start = shut_in_volume.grid_shut_in_volume.cells(v, 5).getValue();
                    get_term_end = shut_in_volume.grid_shut_in_volume.cells(v, 6).getValue();
                });

                group_xml += "<grid nom_groups_id=\"" + get_nom_group_id + "\" meter_id=\"\" comments=\"" + get_comment + "\" process=\"" + get_process + "\" term_start=\"" + get_term_start + "\" term_end=\"" + get_term_end + "\" />";
            }

            if (level == 2) {
                xml += "<grid nom_groups_id=\"" + get_nom_group_id + "\" meter_id=\"" + get_meter_id + "\" comments=\"" + get_comment + "\" process=\"" + get_process + "\" term_start=\"" + get_term_start + "\" term_end=\"" + get_term_end + "\" />";
            }
        });
        
        if(is_shutin && false) {
            dhtmlx.message({
                title: 'Alert',
                type: 'alert',
                text: 'Please select row with status \'Undo ShutIn\'.'
            });
            return;
        }
        //console.log(parent_xml);
        xml += group_xml + parent_xml;        
        xml += "</Root>";

        var data = {
                "action"            : "spa_shutin_process",
                "flag"              : "u",
                "xml"               : xml
        }
        DEBUG_PROCESS && console.log(data);
        
        result = adiha_post_data("alert", data, "", "", "refresh_grid");
    }

    function insert_save_onClick () {
        win = new dhtmlXWindows();
        var insert_win = win.createWindow('comment_win', 100, 100, 780, 320);
        win.window('comment_win').setText("Insert Shutin Volume");


        /*Attach Menu*/
        var save_menu = win.window('comment_win').attachMenu({icons_path: js_image_path + "dhxmenu_web/"});
        save_menu.loadStruct([{id:"save", text:"Save", img:"save.gif", title:"Save"}]);
        save_menu.attachEvent("onClick", function() {
            var nom_header_ids = (insert_form.getCombo('nom_group').getChecked()).join();
            var term_start = insert_form.getItemValue('term_start', true);
            var term_end = insert_form.getItemValue('term_end', true);
            var comments = insert_form.getItemValue('comment');

            var data = {
                "action"            : "spa_shutin_process",
                "flag"              : "i",
                "nom_header_ids"    : nom_header_ids,
                "term_start"        : term_start,
                "term_end"          : term_end,
                "comments"          : comments
            }

            result = adiha_post_data("return_json", data, "", "", "insert_save_onClick_cb");
            
        });        

        /*Attach Insert Form*/
        var form_json = [  
                            {type: 'combo', comboType: 'custom_checkbox', name: 'nom_group', label: 'Nomination Group', width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', filtering: true, offsetLeft : ui_settings['offset_left']},
                            {type : 'newcolumn'},
                            {type: 'calendar', serverDateFormat: '%Y-%m-%d', dateFormat: '<?php echo $date_format; ?>', name: 'term_start', label: 'Flow Date From', value:'<?php echo $date; ?>', width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft : ui_settings['offset_left']},
                            {type : 'newcolumn'},
                            {type: 'calendar', serverDateFormat: '%Y-%m-%d', dateFormat: '<?php echo $date_format; ?>', name: 'term_end', label: 'Flow Date To', value:'<?php echo $date_end; ?>',width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft : ui_settings['offset_left']},
                            {type : 'newcolumn'},
                            {type:'input', name:'comment', label:'Comment', rows:9, position:'label-top', style:'width:710px;height:75px;', offsetLeft : ui_settings['offset_left']}
                        ];
        var insert_form = win.window('comment_win').attachForm(form_json);
        var combo_nom_group = insert_form.getCombo('nom_group');
        var nom_group_sql = {
            "action" : "('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 31800')"
            , 'has_blank_option' : 'false'
            , 'call_from': 'form'
            
        };
        combo_nom_group.attachEvent('onClose', function() {
            fx_set_combo_text_final(combo_nom_group);
        });
        combo_nom_group.load(combo_options(nom_group_sql));
    }

    insert_save_onClick_cb = function(result) {
        //console.log(result);
        var json_obj = $.parseJSON(result);
        //console.log(json_obj);
        if(json_obj[0].errorcode == 'Success') {
            success_call(json_obj[0].message);
            win.window('comment_win').close();
            refresh_grid();
            
        } else {
            dhtmlx.message({
                title: 'Alert'
                ,type: 'alert'
                ,text: json_obj[0].message 
            });
        }
    }
    
    //FUNCTION TO EXPAND AND COLLAPSE THE SHUTIN TREE GRID
    var GRID_EXPAND = false;
    fx_expand_collapse_click = function() {
        if(!GRID_EXPAND) {
            shut_in_volume.grid_shut_in_volume.expandAll();
            GRID_EXPAND = true;
        } else {
            shut_in_volume.grid_shut_in_volume.collapseAll();
            GRID_EXPAND = false;
        }
        
    };
    
    function menu_shut_in_volume_onClick (id, zoneId, cas) {
        switch (id) {
            case 'refresh' :
                refresh_grid();
                break;
            case 'save':
                save_onClick();
                break;
            case 'pdf' :
                shut_in_volume.grid_shut_in_volume.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case 'excel' :
                shut_in_volume.grid_shut_in_volume.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case 'insert':
                insert_save_onClick();
                break;
            case 'update':
                fx_action_click('update');
                break;
            case 'delete':
                fx_action_click('delete');
                break;
            case 'expand_collapse':
                fx_expand_collapse_click();
                break;
        }
    }
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
</script>

</html>