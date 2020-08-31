<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" /> 
</head>  
<body>       
<?php
    require('../../../adiha.php.scripts/components/include.file.v3.php');
    
    $rights_certificate_info = 10131040;
    $rights_certificate_info_delete = 10131041;
    $source_deal_header_id = (isset($_REQUEST["source_deal_header_id"]) && $_REQUEST["source_deal_header_id"] != '') ? get_sanitized_value($_REQUEST["source_deal_header_id"]) : 'NULL';
    $buy_sell = (isset($_REQUEST["buy_sell"]) && $_REQUEST["buy_sell"] != '') ? get_sanitized_value($_REQUEST["buy_sell"]) : 'NULL';
    $certificate_process_id = (isset($_REQUEST["certificate_process_id"]) && $_REQUEST["certificate_process_id"] != '') ? get_sanitized_value($_REQUEST["certificate_process_id"]) : 'NULL';
    $spa_certificate_detail = "EXEC spa_gis_certificate_detail @flag='s', @source_deal_header_id=" . $source_deal_header_id . ",@certificate_process_id='". $certificate_process_id ."'";

    $php_script_loc = $app_php_script_loc;
    
    list (
        $has_rights_certificate_info,
        $has_rights_certificate_info_delete
        ) = build_security_rights(
        $rights_certificate_info,
        $rights_certificate_info_delete
    );
    
    $edit_enabled = (strtoupper($buy_sell) == 'SELL') ? 0 : 1;
		
	if ($source_deal_header_id != 'NULL') {        		
		$sp_url_product = "EXEC spa_deal_update_new @flag = 'check_buy_sell', @source_deal_header_id='" . $source_deal_header_id . "'";
        $sp_url_product = readXMLURL2($sp_url_product);
        
		if($sp_url_product[0] ?? '' != '' and $has_rights_certificate_info == 1){
			$has_rights_certificate_info = 'true';
		} else {
			$has_rights_certificate_info = 'false';
		}
		
		if($sp_url_product[0] ?? '' != '' and $has_rights_certificate_info_delete == 1){
			$has_rights_certificate_info_delete = 'true';
		} else {
			$has_rights_certificate_info_delete = 'false';
		}		
	}
    
    $form_namespace = 'certificate_info';
    
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Certificate Info",
                            width:          500,
                            height:         500,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $menu_json = '[
                      {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                          {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"'.$has_rights_certificate_info.'"},
                          {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:0}
                      ], enabled: "' . $edit_enabled . '"},
                      {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1}
                  ]';
                  
    //Creating Layout
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('certificate_info_layout', '', '1C', $layout_json, $form_namespace);
                         
    //Attach Menu
    $menu_object = new AdihaMenu();
    echo $layout_obj->attach_menu_cell("certificate_info_menu", "a"); 
    echo $menu_object->init_by_attach("certificate_info_menu", $form_namespace);
    echo $menu_object->load_menu($menu_json);
    echo $menu_object->attach_event('', 'onClick', $form_namespace . '.certificate_info_menu_click');
        
    //Attach grid
    $grid_table_obj = new AdihaGrid();
    $grid_name = 'setup_certificate_info';
    echo $layout_obj->attach_grid_cell($grid_name, 'a');
    $sp_url = $spa_certificate_detail;
    echo $grid_table_obj->init_by_attach($grid_name, $form_namespace);
    echo $grid_table_obj->set_header('Group,Source Certificate Number,Certification Entity,Jurisdiction,Tier,Certificate From,Certificate To,Year,Term Start,Term End,Leg,Certificate Date,Expiration Date,Sequence From,Sequence To,Source Deal Detail ID,Create TS,Update TS,Source Deal Header ID,Certificate Temp ID');
    echo $grid_table_obj->set_widths('100,200,200,100,200,180,180,100,100,100,180,180,150,150,160,100,100,100,150,150');
    echo $grid_table_obj->set_sorting_preference('str,int,str,str,str,str,str,int,date,date,date,int,date,int,int,int,date,date,int,int');
    echo $grid_table_obj->set_column_types('tree,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro');
    echo $grid_table_obj->set_columns_ids('group,source_certificate_number,certification_entity,Jurisdiction,Tier,Cert# From,Cert# To,year,Term Start,Term End,Leg,Certificate Date,Expiration Date,Sequence From,Sequence To,Source Deal Detail ID,Create TS,Update TS,Source Deal Header ID,Certificate Temp ID');
    echo $grid_table_obj->set_column_visibility('false,true,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,true,true,true');
    echo $grid_table_obj->set_search_filter(true, "");
    echo $grid_table_obj->enable_multi_select();
    echo $grid_table_obj->attach_event('', 'onRowSelect', $form_namespace . '.grid_row_click');
    echo $grid_table_obj->attach_event('', 'onRowDblClicked', $form_namespace . '.grid_row_dbclick');
    //echo $grid_table_obj->enable_paging(3, 'pagingArea_a',true);
    echo $grid_table_obj->return_init();
    //echo $grid_table_obj->load_grid_data($sp_url, 'g', 'Group');
    echo $layout_obj->close_layout();       
?>
</body>
<!--  <div id="pagingArea_a"></div>  -->
<script type="text/javascript">
    var has_rights_certificate_info_delete = '<?php echo $has_rights_certificate_info_delete ?>';
	var certificate_process_id = '<?php echo $certificate_process_id ?>';
    var expand_state = 0;
	
	certi_process_id = 0;
	//var certificate_process_id;
	
    $(function() {
        load_grid_response();
        dhxWins = new dhtmlXWindows();
    });
    
    certificate_info.certificate_info_menu_click =  function(id){
        switch(id){
            case 'add': 
                openwindow(flag= 'i',source_certificate_number='');
            break;
            case 'delete': 
                btn_delete_click();
            break;
            case 'expand_collapse':
                if (expand_state == 0) {
                    expand_state = 1;
                    certificate_info.setup_certificate_info.expandAll();
                } else {
                    expand_state = 0;
                    certificate_info.setup_certificate_info.collapseAll();
                }

            default:
            break;
        }
    }
    
    function load_grid_response(){
		certificate_info.certificate_info_menu.setItemDisabled('delete');
        var source_deal_header_id = '<?php echo $source_deal_header_id; ?>';
        var param = {
            "action": "spa_gis_certificate_detail",
            "flag": "s",
            "source_deal_header_id":source_deal_header_id,
            "grid_type": "tg",
            "grouping_column": "group",
            "grouping_type": 2,
	        "certificate_process_id": certificate_process_id
        };
        
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        certificate_info.setup_certificate_info.clearAll();
        certificate_info.setup_certificate_info.loadXML(param_url);
    }
    
    certificate_info.grid_row_dbclick = function() {
        var selected_row_id = certificate_info.setup_certificate_info.getSelectedRowId();
        var source_certificate_number = certificate_info.setup_certificate_info.cells(selected_row_id,1).getValue();
		var certificate_temp_id = certificate_info.setup_certificate_info.cells(selected_row_id,19).getValue();
				
        openwindow('u', source_certificate_number,certificate_temp_id);
    }
    
    certificate_info.grid_row_click = function() { 
        var selected = certificate_info.setup_certificate_info.getSelectedRowId();
        
        if (selected == null) {
            certificate_info.certificate_info_menu.setItemDisabled('delete');
        } else {       
            if(has_rights_certificate_info_delete && certificate_info.setup_certificate_info.getLevel(selected) == 1){
                certificate_info.certificate_info_menu.setItemEnabled('delete');
            }    
            
        }
    } 
       
    function btn_delete_click() {
		if(certificate_process_id == 'undefined'){
			certificate_process_id = null;
		}
        var certificate_temp_id = [];
        var jurisdiction = [];
        var source_certificate_number = [];
		var jurisdiction_col_ind = certificate_info.setup_certificate_info.getColIndexById("Jurisdiction");
        var source_certificate_number_ind = certificate_info.setup_certificate_info.getColIndexById("source_certificate_number");
        var certificate_temp_id_ind = certificate_info.setup_certificate_info.getColIndexById("Certificate Temp ID");

        var selected_row_id = certificate_info.setup_certificate_info.getSelectedRowId();
        selected_row_id = selected_row_id.split(',');
        var certificate_info_val, jurisdiction_val, source_certificate_number_val;
        selected_row_id.forEach(function(selected_row_id) {
            source_certificate_number_val = certificate_info.setup_certificate_info.cells(selected_row_id, source_certificate_number_ind).getValue();
            if (source_certificate_number_val != '')
                source_certificate_number.push(source_certificate_number_val);
            jurisdiction_val = certificate_info.setup_certificate_info.cells(selected_row_id,jurisdiction_col_ind).getValue();
            if (jurisdiction_val != '')
                jurisdiction.push(jurisdiction_val);
            certificate_info_val = certificate_info.setup_certificate_info.cells(selected_row_id, certificate_temp_id_ind).getValue();
            if (certificate_info_val != '')
                certificate_temp_id.push(certificate_info_val);
        });

        certificate_temp_id = certificate_temp_id.toString();
        source_certificate_number = source_certificate_number.toString();
        jurisdiction = jurisdiction.toString();
		
        data = {
                    "action": "spa_gis_certificate_detail",
                    "flag": "d",
                    "certificate_num": source_certificate_number,
                    "certificate_process_id": certificate_process_id,
                    "jurisdiction": jurisdiction,
					"certificate_temp_id": certificate_temp_id
                };
	            
        var confirm_msg = 'Are you sure you want to delete?';
            
        dhtmlx.message({
            type: "confirm",
            title: "Confirmation",
            ok: "Confirm",
            text: confirm_msg,
            callback: function(result) {
                if (result)
                    adiha_post_data('', data, '', '', 'delete_success_callback', '');
            }
        });
    }
    
    function delete_success_callback(result){
		parent.certi_process_id = result[0].recommendation;
	    certificate_process_id = result[0].recommendation;
        load_grid_response();
    }
    
    function openwindow(flag, source_certificate_number,certificate_temp_id){
        var edit_enabled = '<?php echo $edit_enabled; ?>';
        var mode = flag;
        var source_deal_header_id = '<?php echo $source_deal_header_id;?>';
		var source_certificate_number = source_certificate_number;
		var certificate_temp_id = certificate_temp_id;
		var js_path_trm = '<?php echo $app_adiha_loc; ?>';
        var param = js_path_trm +  'adiha.html.forms/_deal_capture/maintain_deals/cert.detail.php?mode=' + mode + '&source_deal_header_id=' + source_deal_header_id + '&source_certificate_number=' + source_certificate_number +'&call_from=certificate_form&edit_enabled=' + edit_enabled + '&certificate_process_id=' + certificate_process_id + '&certificate_temp_id=' + certificate_temp_id;
        var is_win = dhxWins.isWindow('w11');
        
        if (is_win == true) {
            w11.close();
        }
        
        w11 = dhxWins.createWindow("w11", 5, 5, 680, 700);
        w11.setText("Certificate Detail");
        w11.setModal(true);
        w11.maximize();
        
        w11.attachURL(param, false, true)
            w11.attachEvent('onClose', function(win) {		
	 if (typeof(cert_process_id) != "undefined") {			
	    certificate_process_id = cert_process_id;		
	    parent.certi_process_id = cert_process_id;
		//if(certificate_process_id = null){
		//	certificate_process_id = cert_process_id;
		//	}
            load_grid_response();    
		return true;}
		else 
		load_grid_response();       
            return true;
        });
    }
    
    function certificate_callback(return_value) {        
        dhtmlx.message({
            text:'Changes have been saved successfully.',
            expire:1000
        });
    }
    
</script>
