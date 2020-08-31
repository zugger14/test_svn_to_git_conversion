<?php
/**
* Edi screen
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
<body class = "bfix2">
    <?php     
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $form_function_id = 10164300;
    $rights_edi_file_create_add = 10164301;
    $rights_edi_file_delete = 10164302;
    $rights_edi_file_submit = 10164303; //function id of view nomination schedule menu
    
   
    list (
        $has_rights_edi_file_create_add,
        $has_rights_edi_file_delete,
        $has_rights_edi_file_submit
    ) = build_security_rights (
        $rights_edi_file_create_add, 
        $rights_edi_file_delete,
        $rights_edi_file_submit
    );
    
    $form_namespace = 'edi';
    $json = "[
                {
                    id:         'a',
                    text:       ' ',
                    header:     false,
                    collapse:   true,
                    height:     0
                },
                {
                    id:         'b',
                    text:       'Filters',
                    header:     true,
                    collapse:   false,
                    height:     200
                },
                /*
                {
                    id:         'c',
                    text:       'Submitted File Filter',
                    header:     true,
                    collapse:   true,
                    height:     100
                },*/
                {
                    id:         'c',
                    text:       'File Detail',
                    header:     true,
                    collapse:   false
                }

            ]";
          
    $edi_obj = new AdihaLayout();
    echo $edi_obj->init_layout('edi_layout', '', '3E', $json, $form_namespace);

    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$form_function_id', @template_name='EDI'";
    $form_data = readXMLURL2($xml_file);
    $form_data_array = array();
    $tab_data = array();
    
    
    if (is_array($form_data) && sizeof($form_data) > 0) {
        foreach ($form_data as $data) {
            array_push($tab_data, $data['tab_json']);
            array_push($form_data_array, $data['form_json']);
        }
    }
    $form_tab_data = 'tabs: [' . implode(",", $tab_data) . ']';
    $form_data_json = json_encode($form_data_array);
    //print_r($form_data_json);
    
    /*
    $form_json = $form_data[0]['form_json'];
    $form_json_s = $form_data[1]['form_json'];
    $tab_id = $form_data[0]['tab_id'];
        
    echo $edi_obj->attach_form('edi_form', 'b');
    $edi_form = new AdihaForm();
    echo $edi_form->init_by_attach('edi_form', $form_namespace);
    echo $edi_form->load_form($form_json);
    
    echo $edi_obj->attach_form('edi_form_s', 'c');
    $edi_form_s = new AdihaForm();
    echo $edi_form_s->init_by_attach('edi_form_s', $form_namespace);
    echo $edi_form_s->load_form($form_json_s);
    */
    
    
    $menu_json = '[
            {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif", enabled: true},
            {id: "menu_action", text: "Action", img: "action.gif", img_disabled: "action_dis.gif", enabled: true, 
            items: [
                {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif", enabled: ' . (int) $has_rights_edi_file_create_add . '},
                {id: "delete", text: "Delete", img: "delete.gif", img_disabled: "delete_dis.gif", enabled: ' . (int) $has_rights_edi_file_delete . '},
                {id: "submit", text: "Submit", img: "submit.gif", img_disabled: "submit_dis.gif", enabled: ' . (int) $has_rights_edi_file_submit . '}
            ]}
        ]';
    echo $edi_obj->attach_menu_layout_cell('edi_menu', 'c', $menu_json, $form_namespace.'.menu_click');
    
    //attach grid
    $edi_grid_name = 'edi_grid';
    echo $edi_obj->attach_grid_cell($edi_grid_name, 'c');
    $edi_grid_obj = new AdihaGrid();
    //echo $edi_obj->attach_status_bar("d", true);
    echo $edi_grid_obj->init_by_attach($edi_grid_name, $form_namespace);
    
    echo $edi_grid_obj->set_header("Date Time,User,Status,process_id,Process ID,File");
    echo $edi_grid_obj->set_columns_ids("datetime,user,status,process_id,process_id_link,file");
    echo $edi_grid_obj->set_widths("220,180,180,200,320,320");
    echo $edi_grid_obj->set_column_types("ro,ro,ro,ro,link,ro");
    echo $edi_grid_obj->set_sorting_preference('str,str,str,process_id,str,str'); 
    echo $edi_grid_obj->set_search_filter(false,'#daterange_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
            
    echo '
    
/*
    dhxCombo_fp = edi.edi_form[edi_form_detail_tab_0].getCombo("from_partner");
    dhxCombo_fp.attachEvent("onChange", edi.cmb_fp_chg);
    
    dhxCombo_tp = edi.edi_form[edi_form_detail_tab_0].getCombo("to_partner");
    dhxCombo_tp.attachEvent("onChange", edi.cmb_tp_chg);
    
    dhxCombo_cn = edi.edi_form[edi_form_detail_tab_0].getCombo("contract");
    dhxCombo_st = edi.edi_form[edi_form_detail_tab_1].getCombo("status");
        
    option_fp_MFS = dhxCombo_fp.getOptionByLabel("MFS - Questar Gas Company");
    option_tp_QPC_TRAN = dhxCombo_fp.getOptionByLabel("QPC_TRAN - Questar Pipeline Company");
    option_st_Submitted = dhxCombo_st.getOptionByLabel("Submitted");
    option_st_Not_Submitted = dhxCombo_st.getOptionByLabel("Not Submitted");

    
    */
    edi.edi_grid.attachEvent("onMouseOver", function(row, col) {
        if (col == 4) {
            this.cells(row,col).cell.title = this.cells(row,col-1).getTitle();
        } else {
            this.cells(row,col).cell.title = this.cells(row,col).getTitle();
        }
    
    });
    
    ';
          
    /** first param column visibility lsit, second param header menu list **/   
    echo $edi_grid_obj->return_init('false,false,false,true,false,false', 'true,true,true,false,true,true');
    
    //echo $edi_grid_obj->attach_event('', 'onRowDblClicked', $form_namespace.'.create_invoice_detail_tab');
    //echo $edi_grid_obj->attach_event('', 'onRowSelect', $form_namespace.'.invoice_grid_select');
    //attach grid ends
    
    
    echo $edi_obj->close_layout();
    ?>
    <span id="filter_data" style="display: none;"
        from_duns=""
        to_duns=""
        
    ></span>
</body>
    
<script>
	var has_rights_edi_file_create_add =<?php echo (($has_rights_edi_file_create_add) ? $has_rights_edi_file_create_add : '0'); ?>;
	var has_rights_edi_file_delete =<?php echo (($has_rights_edi_file_delete) ? $has_rights_edi_file_delete : '0'); ?>;
	var has_rights_edi_file_submit =<?php echo (($has_rights_edi_file_submit) ? $has_rights_edi_file_submit : '0'); ?>;
	    
		
    dhx_wins = new dhtmlXWindows();
    edi.edi_form = {};
    edi.edi_tab = {};
    
    //alert('<?php echo $app_form_path; ?>')
    
    form_function_id = '<?php echo $form_function_id; ?>';
    js_path_temp_note_processed = '<?php echo urlencode($BATCH_FILE_EXPORT_PATH . '\\EDI\\Processed'); ?>';
    has_rights_edi_file_create_add = Boolean('<?php echo $has_rights_edi_file_create_add; ?>');
    
    $(function() {
        date_obj = new Date();
        date_obj_tomorrow = new Date();
        date_obj_tomorrow.setDate(date_obj.getDate() + 1);
        
        edi.fx_attach_events();
        edi.fx_initial_load();
        
        //console.dir(edi.edi_form[0]);
        //create a custom button CREATE
        //edi.add_create_btn();
        
        edi.refresh_edi_grid();
        
        dhxCombo_st.enableFilteringMode(true);
       
    });
    /*
    Functions to attach neccessary events
    */
    edi.fx_attach_events = function() {
        edi.edi_grid.attachEvent('onRowSelect', function(rid, ind) {
			if(has_rights_edi_file_delete) {
            edi.edi_menu.setItemEnabled('delete');
			}
            if(edi.edi_grid.getSelectedRowId().indexOf(',') != -1 || edi.edi_grid.cells(rid, edi.edi_grid.getColIndexById('status')).getValue() == 'Data Error') {
                edi.edi_menu.setItemDisabled('submit');
            } else {
				if(has_rights_edi_file_submit)
                edi.edi_menu.setItemEnabled('submit');
            }
        });
    }
    /*
    * Function to load initial values to form fields.
    */
    edi.fx_initial_load = function() {
        //dhxCombo_fp.selectOption(option_fp_MFS.index, false, true);
        //dhxCombo_tp.selectOption(option_tp_QPC_TRAN.index, false, true);
        
        
        edi.edi_tabbar = edi.edi_layout.cells('b').attachTabbar({
            <?php echo $form_tab_data;?>
        });
                
        var i=0;
        var form_json = <?php echo $form_data_json;?>;
        //console.dir(form_json);
        edi.edi_tabbar.forEachTab(function(tab){
            var id = tab.getId();
            var tab_text = tab.getText();
            edi.edi_tab[i] = tab;
            
            var form_index = "edi_form_" + id;
            
            edi.edi_form[i] = tab.attachForm();
            //console.log(JSON.stringify(form_json));
            edi.edi_form[i].loadStruct(form_json[i]);

            attached_obj = tab.getAttachedObject();
                if (attached_obj instanceof dhtmlXForm) {
                    form_obj = attached_obj;
                    if (form_obj.isItem('deal_id')) {
                        tab_create_menu = tab.attachToolbar({
                            icon_path: js_image_path + 'dhxtoolbar_web/',
                            items:[
                                {id:"create", title:"Create", text:"Create", type: "button", img: 'run.gif', img_disabled: 'run_dis.gif'}
                            ],
                            onClick:function(id){
                                switch(id) {
                                    case 'create':
                                        if(!validate_form(edi.edi_form[0])) {
                                            return;
                                        }
                                        edi.create_edi_click();
                                        break;
                                }  
                            }
                        });
                    }
                }
            i++;
        });
        
        edi.fx_attach_event_to_form();
        
        edi.edi_form[0].setItemValue('flow_date_start', date_obj_tomorrow);
        edi.edi_form[0].setItemValue('flow_date_end', date_obj_tomorrow);
        edi.edi_form[1].setItemValue('create_date_from', date_obj);
        edi.edi_form[1].setItemValue('create_date_to', date_obj);
        
        edi.edi_layout.cells('a').hideArrow();
		edi.cmb_fp_chg();
		edi.cmb_tp_chg();
        //edi.fx_load_generic_apply_filters();
        
        
    }
    edi.fx_attach_event_to_form = function() {
        attach_browse_event('edi.edi_form[0]');
        
        dhxCombo_fp = edi.edi_form[0].getCombo("from_partner");
        dhxCombo_fp.attachEvent("onChange", edi.cmb_fp_chg);
        
        dhxCombo_tp = edi.edi_form[0].getCombo("to_partner");
        dhxCombo_tp.attachEvent("onChange", edi.cmb_tp_chg);
        
        dhxCombo_cn = edi.edi_form[0].getCombo("contract");
        dhxCombo_st = edi.edi_form[1].getCombo("status");
            
        option_fp_MFS = dhxCombo_fp.getOptionByLabel("MFS - Questar Gas Company");
        option_tp_QPC_TRAN = dhxCombo_fp.getOptionByLabel("QPC_TRAN - Questar Pipeline Company");
        option_st_Submitted = dhxCombo_st.getOptionByLabel("Submitted");
        option_st_Not_Submitted = dhxCombo_st.getOptionByLabel("Not Submitted");
    };
    
    edi.fx_load_generic_apply_filters = function() {
        var filter_obj = edi.edi_layout.cells('a').attachForm();
        var layout_cell_obj = edi.edi_layout.cells('a');
        load_form_filter(filter_obj, layout_cell_obj, form_function_id, 2);
    };
    /*
    * from partner combo onchange event
    */
    edi.cmb_fp_chg = function() {
        //var counterparty_id = dhxCombo_fp.getSelectedValue();
        var counterparty_id = edi.edi_form[0].getCombo("from_partner").getSelectedValue();
         var exec_call = {
          'action': 'spa_edi_file_info',
          'flag': 'x',
          'counterparty_id': counterparty_id  
        };
        adiha_post_data('return_json', exec_call, '', '', 'cmb_fp_chg_ajx');
    }
    function cmb_fp_chg_ajx(result) {
        var json_obj = $.parseJSON(result);
        var fp_duns = json_obj.length > 0 ? json_obj[0].duns_no : '';
        $('#filter_data').attr('from_duns', fp_duns);
        
    }
    /*
    * to partner combo onchange event
    */
    edi.cmb_tp_chg = function() {
        
        //var counterparty_id = dhxCombo_tp.getSelectedValue() == '' ? 'NULL' : dhxCombo_tp.getSelectedValue();
        var to_partner = edi.edi_form[0].getCombo("to_partner").getSelectedValue();
        var counterparty_id = to_partner == '' ? 'NULL' : to_partner;
        
        var exec_call = {
          'action': 'spa_edi_file_info',
          'flag': 'x',
          'counterparty_id': counterparty_id  
        };
        adiha_post_data('return_json', exec_call, '', '', 'cmb_tp_chg_ajx');
        
        var cm_param = {
            'action': 'spa_edi_file_info',
            'flag': 'y',
            'counterparty_id': counterparty_id
        };
                                 
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var cm_data = edi.edi_form[0].getCombo('contract');
        cm_data.clearAll();
        cm_data.setComboText('');
        cm_data.load(url, function(e) {
        });
    }
    function cmb_tp_chg_ajx(result) {
        var json_obj = $.parseJSON(result);
        var tp_duns = json_obj.length > 0 ? json_obj[0].duns_no : '';
        $('#filter_data').attr('to_duns', tp_duns);
    }
    
    
    /*    
    edi.add_create_btn = function() {
        btn_create_obj = {'type': 'block', 'blockOffset':0, 'list': [
    	    {'type': 'newcolumn'},
    		{'type': 'button', 'name': 'btn_create_file', 'value': 'Create', 'width': '100'
                , 'className': 'btn_create_class', 'position': 'absolute', 'inputLeft': '600', 'inputTop': '-40'
                , 'disabled': !has_rights_edi_file_create_add}
            									
    	]};
        edi.edi_form[0].addItem(null, btn_create_obj, 7);
        $('.btn_create_class .dhxform_btn').css({'background-color': '#7CD6A9 !important', 'border-radius': '0px'});
        $('.btn_create_class .dhxform_btn').mouseover(function() {
            if(!$($('.btn_create_class')).hasClass('disabled')) {
                $('.btn_create_class .dhxform_btn').css({'background-color': '#44C484 !important'});
            }
        });
        $('.btn_create_class .dhxform_btn').mouseleave(function() {
            if(!$($('.btn_create_class')).hasClass('disabled')) {
                $('.btn_create_class .dhxform_btn').css({'background-color': '#7CD6A9 !important'});
            }
        });
        
        edi.edi_form[0].attachEvent('onButtonClick', function(name) {
            if(name == 'btn_create_file' && validate_form(edi.edi_form[0])) {
                edi.create_edi_click();
            }
        });
        
    }
    */
    
    edi.menu_click = function(name, value) {
        if (name == 'refresh') {
            edi.refresh_edi_grid();
        } else if(name == 'add') {
            edi.menu_add_click();
        } else if (name == 'delete') {
            edi.menu_delete_click();
        } else if (name == 'submit') {
            edi.menu_submit_click();
        }
    }
    /**
     * [refresh_EDI_grid Refresh invoice grid]
     */
    edi.refresh_edi_grid = function() {
        
        edi.edi_menu.setItemDisabled('submit');
        edi.edi_menu.setItemDisabled('delete');
        
        form_data = edi.edi_form[1].getFormData();
        var filter_param = '';
        for (var a in form_data) {
            if (form_data[a] != '' && form_data[a] != null) {

                if (edi.edi_form[1].getItemType(a) == 'calendar') {
                    value = edi.edi_form[1].getItemValue(a, true);
                } else {
                    value = form_data[a];
                }
                
                if (a == 'create_date_from' || a == 'create_date_to' || a == 'status') {
                    filter_param += "&" + a + '=' + value;    
                }
            }
        }
        var param = {
            "flag": "s",
            "action":"spa_edi_file_info",
            "grid_type":"g"
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param + filter_param;
        
        edi.edi_grid.clearAndLoad(param_url);
        edi.edi_grid.enableHeaderMenu();
        edi.edi_grid.enableMultiselect(true);
        
    }
    
    /*
    * Create menu click function
    */
    edi.create_edi_click = function() {
        var form_data = edi.edi_form[0].getFormData();
        var from_partner = edi.edi_form[0].getItemValue('from_partner');
        var to_partner = edi.edi_form[0].getItemValue('to_partner');
        var flow_date_start = edi.edi_form[0].getItemValue('flow_date_start', true);
        var flow_date_end = edi.edi_form[0].getItemValue('flow_date_end', true);
        var contract = edi.edi_form[0].getItemValue('contract') == '' ? 'NULL' : edi.edi_form[0].getItemValue('contract');
        var deal_id = edi.edi_form[0].getItemValue('deal_id').length == 0 ? 'NULL' : edi.edi_form[0].getItemValue('deal_id');
        //alert(from_partner+'||'+to_partner+'||'+flow_date_start+'||'+flow_date_end+'||'+contract+'||'+deal_id);
        //return;
        
        var exec_call = {
            'action': 'spa_interface_edi',
            'flag': 's',
            'from_partner': from_partner,
            'to_partner': to_partner,
            'term_start': flow_date_start,
            'term_end': flow_date_end,
            'contract_id': contract,
            'header_deal_ids': deal_id
            
        }
        //alert(JSON.stringify(exec_call));return;
        edi.edi_layout.cells('c').progressOn();
        adiha_post_data('return_json', exec_call, '', '', 'create_edi_click_ajx');
        
    }
    function create_edi_click_ajx(result) {
        json_obj = $.parseJSON(result);
        $.each(json_obj, function(i) {
            if(json_obj[i].status == 'dataerror') {
				edi.refresh_edi_grid();
			} else if(json_obj[i].status == 'success') {
                //file write
                
                var file_name_org = json_obj[i].file_name;
                var file_content_org = json_obj[i].file_content;
                var create_file_process_id = json_obj[i].process_id;
                
                var file_name = encodeURIComponent(file_name_org);
                var file_content = file_content_org;
                var post_data = {
                    file_name: file_name,
                    file_path: js_path_temp_note_processed,
                    file_content: file_content,
                    post_from: 'edi_create_file'
                };
                
                var create_mode = 'c';
                
                //alert(app_form_path + '_scheduling_delivery/EDI/edi.php');
                //return;
                $.post(
                    app_form_path + '_scheduling_delivery/EDI/edi.post.php'
                    , post_data
                    , function(data, textStatus, jqXHR) {
                        if(data == 'success_file_put_content') {
                            edi.fx_store_create_edi_info(file_name_org, create_mode, create_file_process_id);
                        } else {
                            console.log(data);
                            dhtmlx.message({
                                title: "Error",
                                type: "alert-error",
                                text: data
                            });
                            //edi.edi_layout.cells('c').progressOff();
                        };
                    }
                ).fail(function(jqXHR, textStatus, errorThrown) {
                    dhtmlx.message({
                        title: "Error",
                        type: "alert-error",
                        text: errorThrown,
                    });
                    //edi.edi_layout.cells('c').progressOff();
                });
            } else if(json_obj[i].status == 'empty') {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: 'No file content returned.',
                });
                //edi.edi_layout.cells('c').progressOff();
            } else {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: 'SQL Error.',
                });
                
            }
        });
        
        edi.edi_layout.cells('c').progressOff();
        
    }
    edi.fx_store_create_edi_info = function(file_name, create_mode, process_id) {
        var exec_call = {
                "action": "spa_edi_file_info", 
                "flag": "i",
                "file_name": file_name,
                "create_mode": create_mode,
                "file_status": 'Not Submitted',
                "call_from": 'edi',
                "process_id": (process_id == undefined ? 'NULL' : process_id)
                
            };
        //console.dir(exec_call);return;
        adiha_post_data('return_json', exec_call, '', '', 'create_edi_click_post_ajx');
    }
    function create_edi_click_post_ajx(result) {
        
        var json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            success_call('EDI File ' + (json_obj[0].recommendation == 'c' ? 'generated' : 'uploaded') + ' successfully.', 'error');
            dhxCombo_st.selectOption(json_obj[0].errorcode == 'Success' ? option_st_Not_Submitted.index : option_st_Submitted.index, false, true);
            edi.refresh_edi_grid();
        } else {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: 'Error on file generation.',
            });
        }
        
        edi.edi_layout.cells('c').progressOff();
    }
    /*
    * Submit click function on menu toolbar
    */
    edi.menu_submit_click = function(call_from) {
        var grid_row_id = edi.edi_grid.getSelectedRowId();
        var from_duns = $('#filter_data').attr('from_duns');
        var to_duns = $('#filter_data').attr('to_duns');
        
        
        if(grid_row_id == null || from_duns == '' || to_duns == '') {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: (grid_row_id == null ? 'No rows selected on grid.' : (from_duns == '' ? 'Please select From Partner.' : 'Please select To Partner.'))
            });
        } else {
            var target_url = "<?php echo urlencode($edi_config['TARGET_URL'] ?? ''); ?>";
            //console.log(target_url);return;
            var download_location = js_path_temp_note_processed;
            
            grid_row_id = grid_row_id.split(',');
            var file_name_arr = new Array();
            var process_id_arr = new Array();
            
            //store file names and process ids on array
            $.each(grid_row_id, function(i) {
                file_name_arr.push(edi.edi_grid.cells(grid_row_id[i], edi.edi_grid.getColIndexById('file')).getValue());
                process_id_arr.push(edi.edi_grid.cells(grid_row_id[i], edi.edi_grid.getColIndexById('process_id')).getValue());
            });
            
            //alert(edi.edi_grid.cells(grid_row_id[loop_count], 3).getValue());
            
            ///*
            var file_name = encodeURIComponent(file_name_arr.join(','));
            var process_id = process_id_arr.join(',');
            
            var post_data = {
                post_from: 'edi_submit_file',
                target_url: target_url,
                download_location: download_location,
                file_path: js_path_temp_note_processed + '\\' + file_name,
                input_format: 'X12',
                refnum: '',
                from_duns: from_duns,
                to_duns: to_duns
            };
            //alert(JSON.stringify(post_data));return;
            //post to php
            $.post(
                app_form_path + '_scheduling_delivery/EDI/edi.post.php'
                , post_data
                , function(data, textStatus, jqXHR) {
                    var data_arr = data.split(',');
                    console.log(JSON.stringify(data_arr));
                    if(data_arr[0] == 'Transmission Success' || data_arr[0] == 'Transmission Failure') {
                        var exec_call = {
                                "action": "spa_edi_file_info", 
                                "flag": "o",
                                "file_name": data_arr[1],
                                "process_id": process_id,
                                "create_mode": 'r',
                                "file_status": data_arr[0],
                                "call_from": 'edi',
                                "error_msg": (data_arr[0] == 'Transmission Success' ? 'Submitted' : 'Not Submitted')
                                
                            };
                        adiha_post_data('return_json', exec_call, '', '', 'menu_submit_click_post_ajx');
                    } else {
                        dhtmlx.message({
                            title: "Error",
                            type: "alert-error",
                            text: data
                        });
                    };
                }
            ).fail(function(jqXHR, textStatus, errorThrown) {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: errorThrown,
                });
            }); 
            
            
        }
    }
    function menu_submit_click_post_ajx(result) {
        json_obj = $.parseJSON(result);
        //dhxCombo_st.selectOption(json_obj[0].recommendation == 'Transmission Success' ? option_st_Submitted.index : option_st_Not_Submitted.index, false, true);
        if(json_obj[0].errorcode == 'Success' && json_obj[0].recommendation == 'Transmission Success') {
            
            //shift tab and change status dd only when last row submit on grid
            if(edi.edi_grid.getRowsNum() == 1) {
                edi.edi_tab[1].setActive();
                dhxCombo_st.selectOption(option_st_Submitted.index);
            }
            
            success_call('File transmission status success. Details saved.', 'error');
            edi.refresh_edi_grid();
        } else if(json_obj[0].errorcode == 'Success' && json_obj[0].recommendation == 'Transmission Failure') {
            success_call('File transmission status failed. Details saved.', 'error');
            edi.refresh_edi_grid();
        } else {
            console.log(json_obj[0].recommendation);
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: 'SQL Error'
            });
            
        }
    }
    /*
    * Submit click function on menu toolbar
    */
    edi.menu_delete_click = function() {
        var grid_row_id = edi.edi_grid.getSelectedRowId();
        
        confirm_messagebox('Are you sure you want to continue?', function() {
            grid_row_id = grid_row_id.split(',');
            
            var process_id = new Array();
            
            $.each(grid_row_id, function(i) {
                process_id.push(edi.edi_grid.cells(grid_row_id[i], edi.edi_grid.getColIndexById('process_id')).getValue());
            });
            
            var exec_call = {
                "action": "spa_edi_file_info", 
                "flag": "d",
                "process_id": process_id.join(',')
                
            };
            //console.dir(exec_call);return;
            adiha_post_data('return_json', exec_call, '', '', 'menu_delete_click_ajx');
        }); 
            
       
    }
    function menu_delete_click_ajx(result) {
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            var grid_row_id = edi.edi_grid.getSelectedRowId();
            //var file_name = edi.edi_grid.cells(grid_row_id, 5).getValue();
            //var file_names = encodeURIComponent(json_obj[0].recommendation);
            var file_names = json_obj[0].recommendation;
            
            if(file_names == null) {
                success_call('File deleted successfully.', 'error');
                edi.refresh_edi_grid();
                return;
            }
            //alert(file_names);return;
            var file_path = js_path_temp_note_processed;
            var post_data = {
                file_path: file_path,
                file_names: file_names,
                post_from: 'edi_delete_file'
            };
            $.post(
                app_form_path + '_scheduling_delivery/EDI/edi.post.php'
                , post_data
                , function(data, textStatus, jqXHR) {
                    if(data == 'delete_success') {
                        success_call('File deleted successfully.', 'error');
                        edi.refresh_edi_grid();
                    } else {
                        dhtmlx.message({
                            title: "Error",
                            type: "alert-error",
                            text: data
                        });
                    };
                }
            ).fail(function(jqXHR, textStatus, errorThrown) {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: errorThrown,
                });
            });
            
        } else {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: 'Error in file deletion.',
            });
        }
    }
    
    /*
    * Add click function on menu toolbar
    */
    edi.menu_add_click = function() {
        edi.edi_upload_win = dhx_wins.createWindow({
            id: 'window_add_file'
            ,left: 400
            ,top: 150
            ,width: 500
            ,height: 215
            ,modal: true
            ,resize: false
            
        });
        
        edi.edi_upload_win.setText('Browse File');
        //edi.edi_upload_win.hideHeader();
        
        //save button added on toolbar
        edi.edi_upload_win_menu = edi.edi_upload_win.attachToolbar({
            icon_path: js_image_path + 'dhxtoolbar_web/',
            items:[
                {id:"upload_ok", title:"Ok", text:"Ok", type: "button", disabled: true, img: 'save.gif', img_disabled: 'save_dis.gif'}
            ],
            onClick:function(id){
                switch(id) {
                    case 'upload_ok':
                        edi.upload_ok_click();
                        break;
                }  
            }
        });
        
        edi.edi_upload_form = edi.edi_upload_win.attachForm([
            {'type': 'settings', 'position': 'label-left'},
            {'type': 'block', 'blockOffset':0, 'list': [
			    {'type': 'fieldset', 'inputWidth':450, 'label': 'File Attachment', 'list':[
					{'type': 'upload',  'inputWidth':400, 'url': js_file_uploader_url + '&call_form=edi_file_upload'
                    , 'autoStart':true, 'name': 'file_uploader'}
				]},
				{'type': 'newcolumn'},
				{'type': 'hidden', 'value':'', 'name':'file_attachment'},
                									
			]}
            //,{'type': 'newrow'},
//            {'type': 'button', 'name': 'upload_ok', 'value': 'Ok', 'width': '80'
//                , 'className': 'btn_upload_ok', 'disabled': true}
        ]);
        edi.edi_upload_form.attachEvent('onUploadComplete', edi.upload_doc);
        edi.edi_upload_form.attachEvent('onFileRemove', edi.remove_doc);
        //edi.edi_upload_form.attachEvent('onButtonClick', edi.upload_ok_click);
        
        /*
        $('.btn_upload_ok .dhxform_btn').css({'background-color': '#7CD6A9 !important', 'border-radius': '0px'});
        $('.btn_upload_ok .dhxform_btn').mouseover(function() {
            if(!$($('.btn_upload_ok')).hasClass('disabled')) {
                $('.btn_upload_ok .dhxform_btn').css({'background-color': '#44C484 !important'});
            }
        });
        $('.btn_upload_ok .dhxform_btn').mouseleave(function() {
            if(!$($('.btn_upload_ok')).hasClass('disabled')) {
                $('.btn_upload_ok .dhxform_btn').css({'background-color': '#7CD6A9 !important'});
            }
        });
        */
        
    }
    /*
    * Upload document
    */
    edi.upload_doc = function(realName,serverName) {
        //console.log(JSON.stringify(edi.edi_upload_form.getItemValue('file_uploader')));
        /*
        var get_pre_name = edi.edi_upload_form.getItemValue('file_attachment');
		var uploader_ins = edi.edi_upload_form.getUploader('file_uploader');
        console.log(JSON.stringify(edi.edi_upload_form.getItemValue('file_uploader')));
		if (get_pre_name == '') {
			final_name = serverName;
		} else {
			final_name = get_pre_name + ', ' + serverName;
		}
		
		edi.edi_upload_form.setItemValue('file_attachment', final_name);
        */
        //edi.edi_upload_form.enableItem('upload_ok');
        edi.edi_upload_win_menu.enableItem('upload_ok');
	}
    /**
	 * [remove_doc Remove document]
	 * @param  {[type]} realName   [description]
	 * @param  {[type]} serverName [description]
	 */
	edi.remove_doc = function(realName,serverName){
		var file_name_list = edi.edi_upload_form.getItemValue('file_attachment');
		file_name_list = edi.remove_file_name(file_name_list, realName);
		edi.edi_upload_form.setItemValue('file_attachment', file_name_list);
	}

	/**
	 * [remove_file_name Remove file name from list]
	 * @param  {[type]} list  [list]
	 * @param  {[type]} value [matching value]
	 */
	edi.remove_file_name = function(list, value) {
		var elements = list.split(", ");
		var remove_index = elements.indexOf(value);

		elements.splice(remove_index,1);
		var result = elements.join(", ");
		return result;
	}
    
    edi.upload_ok_click = function() {
        //if(name == 'upload_ok') {
            var uploader_ins = edi.edi_upload_form.getItemValue('file_uploader');
            var create_mode = 'u';
            var i = 0;
            $.each(uploader_ins, function(key, val) {
                if(key == 'file_uploader_s_' + i) {
                    edi.fx_store_create_edi_info(val, create_mode);
                    i++;
                }
            });
            
            edi.edi_upload_win.close();
        //}
    }
    /*
    * Grid Process ID link click
    */
    edi.grid_link_click = function(row_id) { 
        var process_id = edi.edi_grid.cells(row_id-1, edi.edi_grid.getColIndexById('process_id')).getValue();
        var exec_call = "EXEC spa_get_import_process_status_detail " + singleQuote(process_id) + ", 'EDI File'";
        
        open_spa_html_window('EDI File Detail Status', exec_call, 600, 1200);
    }
    
    //link for generated edi file summary and detail report
    function edi_summary_detail_report(flag, process_id) {
        var report_name = 'EDI File ' + (flag == 's' ? 'Summary' : 'Detail') + ' Report';
        var exec_call = "EXEC spa_interface_edi_report @flag='" + flag + "', @process_id='" + process_id + "'";
        open_spa_html_window(report_name, exec_call, 500, 1150);
    }
    
    
</script>

<style>


</style>