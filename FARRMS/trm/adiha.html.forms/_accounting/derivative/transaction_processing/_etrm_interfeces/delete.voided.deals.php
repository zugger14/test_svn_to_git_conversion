<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
     <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
    <?php   
   
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

    $rights_delete_voided_deal = 10233000;
    $rights_delete_voided_deal_delete = 10233010;

    list (
       $has_right_delete_voided_deal,
       $has_rights_delete_voided_deal_delete
    ) = build_security_rights (
       $rights_delete_voided_deal,
       $rights_delete_voided_deal_delete
    );
    
    $namespace = 'delete_voided_deal';
    $form_name = 'delete_voided_deal_form';

    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filters",
                    header:         true,
                    collapse:       false,
                    height:         60
                },
                {
                    id:             "b",
                    text:           "Filters Criteria",
                    header:         true,
                    collapse:       false,
                    height:         180
                    
                },
                {
                    id:             "c",
                    header:         true,
                    collapse:       false,
                    text: "<div>Voided Deals <a class=\"undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" new_window_grid();\"><!--&#8599--></a></div>", 
                    
                }
            ]';

    $delete_voided_deal_layout_obj = new AdihaLayout();
    echo $delete_voided_deal_layout_obj->init_layout('delete_voided_deal_layout', '', '3E', $json, $namespace);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10233000', @template_name='delete_void_deal', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    echo $delete_voided_deal_layout_obj->attach_form($form_name, 'b');
    $delete_voided_deal_form_obj = new AdihaForm();
    echo $delete_voided_deal_form_obj->init_by_attach($form_name, $namespace);
    echo $delete_voided_deal_form_obj->load_form($form_json);
  
    $toolbar_json = '[
                        { id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                        { id:"t2", imgdis:"delete_dis.gif", text:"Edit", img:"edit.gif", items:[                            
                            {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", title: "Delete", disabled: true }
                        ]},
                        {id:"t3", disabled: false, imgdis:"export_dis.gif", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"},
                            {id:"batch", text:"Batch", img:"batch.gif", imgdis:"batch_dis.gif"}
                        ]} 
                     ]';

    echo $delete_voided_deal_layout_obj->attach_menu_cell('inventory_calc_toolbar', 'c');
    $inventory_calc_toolbar = new AdihaMenu();
    echo $inventory_calc_toolbar->init_by_attach('inventory_calc_toolbar', $namespace);
    echo $inventory_calc_toolbar->load_menu($toolbar_json);
    echo $inventory_calc_toolbar->attach_event('', 'onClick', 'toolbar_click');    
    
    $grid_name = 'left_grid';
    
    echo $delete_voided_deal_layout_obj->set_cell_height('a','90');
    echo $delete_voided_deal_form_obj->set_input_value($namespace . '.' . $form_name, 'as_of_date', ($as_of_date ?? ''));
    echo $delete_voided_deal_layout_obj->close_layout();
?>
</body>
    
<script>    
    $(function(){
        
        var has_right_delete_voided_deal = Boolean('<?php echo $has_right_delete_voided_deal; ?>');
        
        if (has_right_delete_voided_deal == false){
            delete_voided_deal.delete_voided_deal_form.disableItem('btn_run');
        } else {
            delete_voided_deal.delete_voided_deal_form.enableItem('btn_run');
        }
        var today = new Date();
 
        var function_id  = 10233000;
        var report_type = 2;
        var filter_obj = delete_voided_deal.delete_voided_deal_layout.cells('a').attachForm();
        var layout_cell_obj =delete_voided_deal.delete_voided_deal_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
        delete_voided_deal.delete_voided_deal_form.setItemValue('as_of_date_to', new Date());
        delete_voided_deal.delete_voided_deal_form.setItemValue('as_of_date',new Date((new Date()).getTime() - 30*24*60*60*1000) );
        delete_voided_deal.delete_voided_deal_form.attachEvent("onChange", function(name,value,is_checked){    
            
            if ( is_checked && name == 'deleted_deals' ) {
                delete_voided_deal.delete_voided_deal_form.disableItem('linked_deals');
                display_delated_deals();
            } else if ( !is_checked && name == 'deleted_deals' ) {
                delete_voided_deal.delete_voided_deal_form.enableItem('linked_deals');
                display_linked_deals();
            }  else if ( is_checked && name == 'linked_deals' ) { 
                delete_voided_deal.delete_voided_deal_form.disableItem('deleted_deals');
                display_linked_deals();
            } else if ( !is_checked && name == 'linked_deals' ) { 
                delete_voided_deal.delete_voided_deal_form.enableItem('deleted_deals');
                display_linked_deals();
            } else {
               delete_voided_deal.delete_voided_deal_form.enableItem('deleted_deals');
            }
            
        });
    });    
        
    function display_delated_deals(){
		detach_grid_from_cell_c();
		display_delated_deals_grid();
	}
	
	function display_linked_deals(){
		detach_grid_from_cell_c();
		display_linked_deals_grid();
	}
        
    function display_delated_deals_grid(){
        delete_voided_deal.delete_voided_deal_layout.cells('c').progressOn();
        delete_voided_deal.deleted_grid = delete_voided_deal.delete_voided_deal_layout.cells('c').attachGrid();
        <?php
        //echo $delete_voided_deal_layout_obj->attach_grid_cell($grid_name, 'c');
        $grid_obj_deleted = new AdihaGrid();
        $xml_file = "EXEC spa_adiha_grid 's','grid_deleted_deals'";
        $resultset = readXMLURL2($xml_file);
		
		$deleted_deal_column_list = $resultset[0]['column_name_list'];
		$deleted_deal_label_list = $resultset[0]['column_label_list'];
		$deleted_deal_numeric_col = $resultset[0]['numeric_fields'];
		$deleted_deal_date_col = $resultset[0]['date_fields'];
		$grid_obj_deleted->enable_connector();
        echo $grid_obj_deleted->init_by_attach('deleted_grid', $namespace);
        echo $grid_obj_deleted->set_header($resultset[0]['column_label_list']);
        echo $grid_obj_deleted->set_columns_ids($resultset[0]['column_name_list']);
        echo $grid_obj_deleted->set_widths($resultset[0]['column_width']);
        echo $grid_obj_deleted->set_column_types($resultset[0]['column_type_list']);
        echo $grid_obj_deleted->set_sorting_preference($resultset[0]['sorting_preference']);
        echo $grid_obj_deleted->set_column_auto_size(true);
        echo $grid_obj_deleted->set_search_filter(true);
        echo $grid_obj_deleted->set_column_visibility($resultset[0]['set_visibility']);
        echo $grid_obj_deleted->enable_multi_select(false);
        echo $grid_obj_deleted->return_init('','Deal ID,Reference ID,Link ID,Deal Date,Voided Date,Tenor Period');
        echo $grid_obj_deleted->attach_event('', 'onRowSelect', 'select_grid_row');
        ?> 
        delete_voided_deal.delete_voided_deal_layout.cells('c').attachStatusBar({
                            height: 30,
                            text: '<div id="pagingArea_c"></div>'
                        });
        delete_voided_deal.deleted_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        delete_voided_deal.deleted_grid.enablePaging(true, 100, 0, 'pagingArea_c'); 
        delete_voided_deal.deleted_grid.setPagingSkin('toolbar');
        display_delated_deals_grid_value();
    }

    function detach_grid_from_cell_c(){
      var attached = delete_voided_deal.delete_voided_deal_layout.cells('c').getAttachedObject();
        if (window.dhtmlXGridObject != null && attached instanceof window.dhtmlXGridObject) {
            delete_voided_deal.delete_voided_deal_layout.cells('c').detachObject(true);
        }  
    }
    
    function display_linked_deals_grid(){
        delete_voided_deal.delete_voided_deal_layout.cells('c').progressOn();
        delete_voided_deal.linked_grid = delete_voided_deal.delete_voided_deal_layout.cells('c').attachGrid();
        <?php
            //echo $delete_voided_deal_layout_obj->attach_grid_cell($grid_name, 'c');
            $xml_file = "EXEC spa_adiha_grid 's','grid_linked_deals'";
            $resultset = readXMLURL2($xml_file);
			
			$linked_deal_column_list = $resultset[0]['column_name_list'];
			$linked_deal_label_list = $resultset[0]['column_label_list'];
			$linked_deal_numeric_col = $resultset[0]['numeric_fields'];
			$linked_deal_date_col = $resultset[0]['date_fields'];
			
            $grid_obj_linked = new AdihaGrid();
			$grid_obj_linked->enable_connector();
            echo $grid_obj_linked->init_by_attach('linked_grid', $namespace);
            echo $grid_obj_linked->set_header($resultset[0]['column_label_list']);
            echo $grid_obj_linked->set_columns_ids($resultset[0]['column_name_list']);
            echo $grid_obj_linked->set_widths($resultset[0]['column_width']);
            echo $grid_obj_linked->set_column_types($resultset[0]['column_type_list']);
            echo $grid_obj_linked->set_sorting_preference($resultset[0]['sorting_preference']);
            echo $grid_obj_linked->set_column_auto_size(true);                
            echo $grid_obj_linked->set_search_filter(true);
            echo $grid_obj_linked->set_column_visibility($resultset[0]['set_visibility']);
            echo $grid_obj_linked->enable_multi_select(false);
            echo $grid_obj_linked->return_init('','Deal ID,Reference ID,Link ID,Deal Date,Voided Date,Tenor Period,Counterparty Name,Trader Name,Tran Status');
            echo $grid_obj_linked->attach_event('','onRowSelect','select_grid_row');
        ?>
        delete_voided_deal.delete_voided_deal_layout.cells('c').attachStatusBar({
                            height: 30,
                            text: '<div id="pagingArea_c"></div>'
                        });
        delete_voided_deal.linked_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        delete_voided_deal.linked_grid.enablePaging(true, 100, 0, 'pagingArea_c'); 
        delete_voided_deal.linked_grid.setPagingSkin('toolbar');
        display_delated_deals_grid_value();
    }

    function select_grid_row(){
        if ( delete_voided_deal.delete_voided_deal_form.isItemChecked('deleted_deals') ) { 
            delete_voided_deal.inventory_calc_toolbar.setItemDisabled('delete');
        } else {
            var has_rights_delete_voided_deal_delete = Boolean(<?php echo $has_rights_delete_voided_deal_delete ?>);
            
            if (has_rights_delete_voided_deal_delete)
                delete_voided_deal.inventory_calc_toolbar.setItemEnabled('delete');
            else
                delete_voided_deal.inventory_calc_toolbar.setItemDisabled('delete');
        }
    }
    
    function display_delated_deals_grid_value(){
        delete_voided_deal.delete_voided_deal_layout.cells('c').progressOn();            
        var as_of_date  = delete_voided_deal.delete_voided_deal_form.getItemValue("as_of_date", true);
        var as_of_date_to  = delete_voided_deal.delete_voided_deal_form.getItemValue("as_of_date_to", true);
        var deal_id = delete_voided_deal.delete_voided_deal_form.getItemValue("deal_id");
        var reference_id = delete_voided_deal.delete_voided_deal_form.getItemValue("reference_id");
        
        var show_link;
        var deleted;
        var delated_deals_url;
        var delated_deals_param;
              
        if (delete_voided_deal.delete_voided_deal_form.isItemChecked('deleted_deals')) {            
            show_link = 'n';
            deleted = 'd';        
        } else if (delete_voided_deal.delete_voided_deal_form.isItemChecked('linked_deals')) {            
            show_link = 'y';            
        } else {            
           show_link = 'a';           
        }
        
        delated_deals_param = {
                "action": "spa_deleted_voided_deals",
                "flag_pre": "s",
                "as_of_date": as_of_date,
                "source_deal_header_id" : deal_id,
                "deal_id" :reference_id ,
                "show_linked" : show_link,
                "status" : deleted,
                "as_of_date_to": as_of_date_to,
				"enable_dynamic_loading":"y"
                };
		adiha_post_data("return", delated_deals_param, '', '', 'delete_voided_deal.dynamic_loading');
    }
                
	delete_voided_deal.dynamic_loading = function(result) {
		 if (result[0].process_table == '' || result[0].process_table == null) {
            return;
        }
		// column list should match the column name returned by stored proc,, in this case process tabble
		var column_list = 'DealID,RefID,LinkID,DealDate,VoidedDate,TenorPeriod,CounterpartyName,TraderName,TranStatus';
		var date_fields = 'DealDate,VoidedDate';   

		if (delete_voided_deal.delete_voided_deal_form.isItemChecked('deleted_deals')) { 
            column_list = 'DealID,RefID,VoidedDate,DeletedDate,DeletedBy';
			date_fields = 'VoidedDate,DeletedDate';          
        }  		
		var process_table = result[0].process_table;
		var sql_param = {
            "process_table":process_table,
            "text_field":column_list,
            "id_field": "id",
            "date_fields":date_fields
        };
		sql_param = $.param(sql_param);
        var sql_url = js_php_path + "grid.connector.php?"+ sql_param;

        if(delete_voided_deal.delete_voided_deal_form.isItemChecked('linked_deals')) {  
			delete_voided_deal.linked_grid.clearAll();
            delete_voided_deal.linked_grid.loadXML(sql_url, linked_filter);        
        } else if ( delete_voided_deal.delete_voided_deal_form.isItemChecked('deleted_deals') ) {            
			delete_voided_deal.deleted_grid.clearAll();
            delete_voided_deal.deleted_grid.loadXML(sql_url, deleted_filter);           
        }   else {
			delete_voided_deal.linked_grid.clearAll();
            delete_voided_deal.linked_grid.loadXML(sql_url, linked_filter);
		}  
    }

    deleted_filter = function(){
        delete_voided_deal.deleted_grid.filterByAll();
        delete_voided_deal.delete_voided_deal_layout.cells('c').progressOff();
    }

    linked_filter = function(){
        delete_voided_deal.linked_grid.filterByAll();
        delete_voided_deal.delete_voided_deal_layout.cells('c').progressOff();
    }
    
    function get_message(code) {
        switch (code) {
            case 'AS_OF_DATE_VALIDATION':
                return '<b>As of Date From</b> cannot be greater than <b>As of Date To</b>.';
        }
    }
    
    function toolbar_click(id){
        switch(id) {
            case 'refresh':  
                delete_voided_deal.inventory_calc_toolbar.setItemEnabled('t3');
                var as_of_date_date = delete_voided_deal.delete_voided_deal_form.getItemValue("as_of_date", true);        
                var as_of_date_to  = delete_voided_deal.delete_voided_deal_form.getItemValue("as_of_date_to", true);
                
                if ((as_of_date_date !== "") && (as_of_date_to !== "") && (as_of_date_date > as_of_date_to)) {
                    show_messagebox(get_message('AS_OF_DATE_VALIDATION'));
                    return;
                } 

                if ( delete_voided_deal.delete_voided_deal_form.isItemChecked('deleted_deals') || delete_voided_deal.delete_voided_deal_form.isItemChecked('linked_deals')) { 
                    display_delated_deals_grid_value();
                } else {
                    display_linked_deals();                    
                }

                delete_voided_deal.delete_voided_deal_layout.cells("a").collapse();
                delete_voided_deal.delete_voided_deal_layout.cells("b").collapse();
                break;
            case 'delete':
                delete_grid_data();
                break;
            case 'excel':
                if ( delete_voided_deal.delete_voided_deal_form.isItemChecked('deleted_deals') ) { 
                    delete_voided_deal.deleted_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                } else if ( delete_voided_deal.delete_voided_deal_form.isItemChecked('linked_deals') ) {         
                    delete_voided_deal.linked_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                } else {
                    delete_voided_deal.linked_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                }                
                break;
            case 'pdf':
                if ( delete_voided_deal.delete_voided_deal_form.isItemChecked('deleted_deals') ) { 
                    delete_voided_deal.deleted_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                } else if ( delete_voided_deal.delete_voided_deal_form.isItemChecked('linked_deals') ) {         
                    delete_voided_deal.linked_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                } else {
                    delete_voided_deal.linked_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                }   
                delete_voided_deal.linked_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case 'batch':
                delete_voided_deal_batch();
                break;
        }
    }
    
    function delete_voided_deal_batch(){
        
        var from_date = delete_voided_deal.delete_voided_deal_form.getItemValue("as_of_date", true);
        
        var as_of_date_to  = delete_voided_deal.delete_voided_deal_form.getItemValue("as_of_date_to", true);
        var deal_id = delete_voided_deal.delete_voided_deal_form.getItemValue("deal_id");
        var reference_id = delete_voided_deal.delete_voided_deal_form.getItemValue("reference_id");
        
        var show_link;
        var deleted = '';
        var delated_deals_url;
        var delated_deals_param;
              
        if (delete_voided_deal.delete_voided_deal_form.isItemChecked('deleted_deals')) {            
            show_link = 'n';
            deleted = 'd';        
        } else if (delete_voided_deal.delete_voided_deal_form.isItemChecked('linked_deals')) {            
            show_link = 'y';            
        } else {            
            show_link = 'a';           
        }
        
        var exec_call = 'EXEC spa_deleted_voided_deals ' +
                                singleQuote('s') + ', ' +
                                singleQuote(deal_id) + ', ' +
                                singleQuote(reference_id) + ', ' +
                                singleQuote(from_date) + ', ' + 
                                singleQuote(show_link) + ', ' +
                                singleQuote(deleted) + ', ' +
                                singleQuote(as_of_date_to); // show non-derived price only - removed
        
        if (as_of_date_to == '' ) {
            var param = 'call_from=Price Batch Import&gen_as_of_date=1&batch_type=r';        
        } else {
            var param = 'call_from=Price Batch Import&gen_as_of_date=1&batch_type=r&as_of_date=' + as_of_date_to; 
        }

        adiha_run_batch_process(exec_call, param, 'Voided deal');
    }
    
    function delete_grid_data(){
        var linked_gird_row_selected = delete_voided_deal.linked_grid.getSelectedRowId();        
        var selected_value_id;
        var deal_ids ='';
        var msg = "Are you sure you want to delete?";
        dhtmlx.message({
                                type: "confirm",
                                title: "Confirmation",
                                ok: "Confirm",
                                text: msg,
                                callback: function(result) {
                                    if(result) {
                                        var partsOfStr = linked_gird_row_selected.split(',');
                                        for (i = 0; i < partsOfStr.length; i++) {
                                                selected_value_id = delete_voided_deal.linked_grid.cells(partsOfStr[i], 0).getValue();
                                                if(i!=0){
                                                   deal_ids += ','  
                                                }
                                                deal_ids += selected_value_id ;
                                                //setup_counterparty.grids[grid_index].deleteRow(partsOfStr[i]);
                                                
                                        }
                                        //alert(deal_ids);
                                        delete_grid_value_param = {
                                           "action": "spa_deal_voided_in_external",
                                           "flag": "u",
                                           "deal_id": deal_ids
                                        }
                                        adiha_post_data('alert', delete_grid_value_param, '', '', 'delete_success');
                                    }
                                }
                            });
        /*var linked_gird_row_selected = delete_voided_deal.linked_grid.getSelectedRowId();
        if ( linked_gird_row_selected ) {
            var deal_value = delete_voided_deal.linked_grid.cells(linked_gird_row_selected,1).getValue();            
            var delete_grid_value_param;

            delete_grid_value_param = {
               "action": "spa_deal_voided_in_external",
               "flag": "u",
               "deal_id": deal_value
            }

            adiha_post_data('confirm', delete_grid_value_param, '', '', 'delete_success');
        } */
        
    }
    
    function delete_success(result) {
        //var linked_gird_row_selected = delete_voided_deal.linked_grid.getSelectedRowId();  

        if(result[0]['status'] == "Success") {
           display_linked_deals();
        }
    }
    
    function new_window_grid() {
        delete_voided_deal.delete_voided_deal_layout.cells("a").collapse();
        delete_voided_deal.delete_voided_deal_layout.cells("b").collapse();
        
    }

    function callback_grid_refresh(){
        display_linked_deals();
    }
   
</script>