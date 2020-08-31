<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>  
</head>
<body>
<?php 
    //parameters
    $source_deal_detail_id = (isset($_REQUEST["source_deal_detail_id"]) && $_REQUEST["source_deal_detail_id"] != '') ? get_sanitized_value($_REQUEST["source_deal_detail_id"]) : 'NULL';
    $deal_price_data_process_id = (isset($_REQUEST["deal_provisional_price_data_process_id"]) && $_REQUEST["deal_provisional_price_data_process_id"] != '') ? get_sanitized_value($_REQUEST["deal_provisional_price_data_process_id"]) : 'NULL';
    // $filter_details = (isset($_REQUEST["filter_details"]) && $_REQUEST["filter_details"] != '') ? $_REQUEST["filter_details"] : 'NULL';

    //main form
    $form_namespace = 'deal_pricing_detail';   
    $form_function_id = 10131048;
    $layout_json = '[
                        {id: "a", text: "Saved Pricing", header:true, height: 100},
                        {id: "b", text: "Price", header:true, height: 85},
                        {id: "c", text: "Pricing Component", header:true, width: 330},
                        {id: "d", header:false}
                    ]';  

    //main form layout
    $outer_layout_obj = new AdihaLayout();
    $outer_layout_json = '[{id: "a", header:false}]';
    echo $outer_layout_obj->init_layout('outer_layout', '', '1C', $outer_layout_json, $form_namespace);
    
    //attached toolbar 
    $toolbar_name = 'toolbar';
    $toolbar_obj = new AdihaToolbar();
    $toolbar_json = '[
                      {id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"},
                      {id:"prev", type:"button", text:"<< Previous ", title: "Save Current Data And Load Previous Deal detail"},
                      {id:"next", type:"button", text:"Next >>", title: "Save Current Data And Load Next Deal detail"}
                  ]';

    echo $outer_layout_obj->attach_toolbar($toolbar_name);
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);  
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');

    //attached tab bar
    $tabbar_obj = new AdihaTab();
    $tabbar_json = '[
                        {id:"price", text:"Price", active:"true" }, 
                        {id:"quality", text:"Quality"}
                    ]';

    $price_tab_name = 'deal_price_tab';
    echo $outer_layout_obj->attach_tab_cell($price_tab_name, 'a', $tabbar_json);
      
    echo $tabbar_obj->init_by_attach($price_tab_name, $form_namespace);  


    $formula_forms = new AdihaForm();
    $sp_formula = "EXEC spa_formula_editor @flag = 'x'";
    $formula_dropdown_json = $formula_forms->adiha_form_dropdown($sp_formula, 0, 1, true);

    $predefined_formula_json ='[ {type: "settings"},
                                    {"type": "block", "blockOffset": 0, "list": [
                                        {type: "combo", position: "label-top", offsetLeft: "15", label: "Formula", name: "formula", "required":true, "userdata":{"validation_message":"Required Field"}, "filtering": "true", "filtering_mode": "between", "labelWidth":180, "inputWidth":180, options:' . $formula_dropdown_json . '},  
                                    ]}
                                ]';

    $price_adjustment_json ='[ {type: "settings"},
                                    {"type": "block", "blockOffset": 0, "list": [
                                        {type: "combo", position: "label-top", offsetLeft: "15", label: "Adjustment", name: "adjustment", "required":true, "userdata":{"validation_message":"Required Field"}, "filtering": "true", "filtering_mode": "between", "labelWidth":180, "inputWidth":180, options:' . $formula_dropdown_json . '},  
                                    ]}
                                ]';

    /********************************************************* START OF PRICE TAB ********************************************************/

    //attached layout
    $price_layout_obj = new AdihaLayout();
    $price_layout_name = 'layout';
    $price_layout_json = '[
                        {id: "a", text: "Saved Pricing", header:true, height: 100},
                        {id: "b", text: "Price", header:true, height: 85},
                        {id: "c", text: "Pricing Component", header:true, width: 330},
                        {id: "d", header:false}
                    ]'; 
    
    echo $tabbar_obj->attach_layout_cell($form_namespace, $price_layout_name, $form_namespace . '.' .$price_tab_name, 'price', '4J', $price_layout_json);
    echo $price_layout_obj->init_by_attach($price_layout_name, $form_namespace);
    
    //attach filter in cell 'a'
    $filter_form = new AdihaForm();
    echo $price_layout_obj->attach_form('filter_form', 'a');

    $sp_url = "EXEC spa_deal_pricing_provisional_filter @flag = 's'";
    $view_dropdown_json = $filter_form->adiha_form_dropdown($sp_url, 0, 1, true);

    $form_json = '[ 
                    {"type": "settings", "position": "label-top"},
                    {type:"block", width:500, list:[
                        {type:"combo", name: "filter", label:"Saved Pricing", "inputWidth":"240", "labelWidth":"240", "required":false, "filtering":true, "options":' . $view_dropdown_json . '},
                        {"type":"newcolumn"},                        
                        {type: "button", name: "save", value: "", tooltip: "Save View", offsetTop:"30", className: "filter_save"},                    
                        {"type":"newcolumn"},
                        {type: "button", name: "delete", value: "", tooltip: "Delete View",offsetTop:"30", className: "filter_delete"},
                        {"type":"newcolumn"},
                        {type: "button", name: "filter_clear", value: "", tooltip: "Clear Filter", offsetTop:"30", className: "filter_clear"},   
                        {"type":"newcolumn"},
                        {type: "button", name: "copy", value: "", tooltip: "Copy Filter",offsetTop:"30", className: "filter_publish"}
                    ]}
                ]';

    
    
    $filter_form->init_by_attach('filter_form', $form_namespace);
    echo $filter_form->load_form($form_json);    
    echo $filter_form->attach_event('', 'onChange', $form_namespace . '.filter_form_change');
    echo $filter_form->attach_event('', 'onButtonClick', $form_namespace . '.filter_menu_click');
    echo $price_layout_obj->collapse_cell('a');


    //attach form in cell 'b'
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$form_function_id', @template_name='deal_provisional_price'";
    $return_value = readXMLURL2($xml_file);
    $form_json = $return_value[0]['form_json']; 

    $deal_price_form_name = 'deal_price_form';
    $price_form_obj = new AdihaForm(); 

    echo $price_layout_obj->attach_form($deal_price_form_name, 'b');
    echo $price_form_obj -> init_by_attach($deal_price_form_name, $form_namespace);
    echo $price_form_obj -> load_form($form_json);
    echo $price_form_obj->attach_event('', 'onChange', $form_namespace . '.price_form_change');
    echo $price_layout_obj->collapse_cell('b');


    //attach menu in cell 'c'
    $price_menu = new AdihaMenu();
    $menu_json =    '[  
                        {id:"t3", text:"Edit", img:"Edit.gif", items:[
                        {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", title: "Add", enabled: true},
                        {id:"add_multiple", text:"Add Multiple", img:"add.gif", imgdis:"add_dis.gif", title: "Add  Multiple", enabled: true},
                        {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", title: "Delete", enabled: true}
                    ]},
                    {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]},
                ]';

    echo $price_layout_obj->attach_menu_cell('price_menu', 'c');
    echo $price_menu->init_by_attach('price_menu', $form_namespace);
    echo $price_menu->load_menu($menu_json);
    echo $price_menu->attach_event('', 'onClick', $form_namespace . '.menu_click');

    //attached grid in cell 'c'
    $price_grid_name = 'deal_pricing_type';
    $price_grid = new GridTable($price_grid_name);
    echo $price_layout_obj->attach_grid_cell($price_grid_name, 'c');
    echo $price_layout_obj->attach_status_bar("c", true);
    echo $price_grid->init_grid_table($price_grid_name, $form_namespace, 'n');
    echo $price_grid->set_column_auto_size();
    echo $price_grid->set_search_filter(true, "");
    echo $price_grid->enable_column_move();
    //echo $price_grid->enable_multi_select();
    echo $price_grid->return_init();
    echo $price_grid->load_grid_functions();
    echo $price_grid->attach_event('', 'onBeforeSelect', $form_namespace . '.save_grid_data');
    echo $price_grid->attach_event('', 'onRowSelect', $form_namespace . '.load_price_type');
    echo $price_grid->attach_event('', 'onCellChanged', $form_namespace . '.load_price_type_cell');

    

    /********************************************************* END OF PRICE TAB ********************************************************/

    /********************************************************* START OF QUALITY TAB ********************************************************/
    //attach layout
    $quality_layout_name = 'quality_layout';
    $quality_layout_obj = new AdihaLayout();

    $quality_layout_json = '[
                                {id: "a", text: "Saved Quality", header:true, height: 150},
                                {id: "b", text: "Quality", header:true, height: 380}
                            ]'; 


    echo $tabbar_obj->attach_layout_cell($form_namespace, $quality_layout_name, $form_namespace . '.' .$price_tab_name, 'quality', '2E', $quality_layout_json);
    echo $quality_layout_obj->init_by_attach($quality_layout_name, $form_namespace);
    

    //attach filter in cell 'a'
    $filter_form = new AdihaForm();
    echo $quality_layout_obj->attach_form('quality_filter_form', 'a');

    $sp_url = "EXEC [spa_deal_pricing_quality_provisional_filter] @flag = 's'";
	$view_dropdown_json = $filter_form->adiha_form_dropdown($sp_url, 0, 1, true);

	$form_json = '[ 
	                {"type": "settings", "position": "label-top"},
	                {type:"block", width:500, list:[
                        {type:"combo", name: "filter", label:"Saved Quality", "inputWidth":"240", "labelWidth":"240", "required":false, "filtering":true, "options":' . $view_dropdown_json . '},
	                    {"type":"newcolumn"},                        
	                    {type: "button", name: "save", value: "", tooltip: "Save View", offsetTop:"30", className: "filter_save"},                    
	                    {"type":"newcolumn"},
	                    {type: "button", name: "delete", value: "", tooltip: "Delete View",offsetTop:"30", className: "filter_delete"},
                        {"type":"newcolumn"},
                        {type: "button", name: "filter_clear", value: "", tooltip: "Clear Filter", offsetTop:"30", className: "filter_clear"},   
	                    {"type":"newcolumn"},
	                    {type: "button", name: "copy", value: "", tooltip: "Copy Filter",offsetTop:"30", className: "filter_publish"}
	                ]}
	            ]';

    $filter_form->init_by_attach('quality_filter_form', $form_namespace);
	echo $filter_form->load_form($form_json);    
    echo $filter_form->attach_event('', 'onChange', $form_namespace . '.quality_filter_form_change');
    echo $filter_form->attach_event('', 'onButtonClick', $form_namespace . '.quality_filter_menu_click');

    echo $quality_layout_obj->collapse_cell('a');

    //attach menu in cell 'b'
    $quality_menu = new AdihaMenu();
    $menu_json =    '[  
                        {id:"t3", text:"Edit", img:"Edit.gif", items:[
                            {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", title: "Add", enabled: true},
                            {id:"add_multiple", text:"Add Multiple", img:"add.gif", imgdis:"add_dis.gif", title: "Add  Multiple", enabled: true},
                            {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", title: "Delete", enabled: true}
                        ]},
                        {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                                ]';

    echo $quality_layout_obj->attach_menu_cell('quality_menu', 'b');
    echo $quality_menu->init_by_attach('quality_menu', $form_namespace);
    echo $quality_menu->load_menu($menu_json);
    echo $quality_menu->attach_event('', 'onClick', $form_namespace . '.quality_menu_click');

    //attached grid in cell 'b'
    $quality_grid_name = 'deal_pricing_quality';
    $quality_grid = new GridTable($quality_grid_name);
    echo $quality_layout_obj->attach_grid_cell($quality_grid_name, 'b');
    echo $quality_layout_obj->attach_status_bar("b", true);
    echo $quality_grid->init_grid_table($quality_grid_name, $form_namespace, 'n');
    echo $quality_grid->set_column_auto_size();
    echo $quality_grid->set_search_filter(true, "");
    echo $quality_grid->enable_column_move();
    echo $quality_grid->enable_multi_select();
    echo $quality_grid->return_init();
    echo $quality_grid->load_grid_functions();

    /********************************************************* END OF QUALITY TAB ********************************************************/


    echo $outer_layout_obj->close_layout();

?>
</body>
<script type="text/javascript">
    var grid = '';
    var quality_grid = ''; 
    var form = '';

    var deal_price_deemed = {};
    var deal_custom_event = {};
    var deal_std_event = {};
    var deal_predefined_formula = {};
    var deal_price_adjustment = {};

    var predefined_formula_json  = <?php echo $predefined_formula_json; ?>;         

    var price_adjustment_json = <?php echo $price_adjustment_json; ?>;        
    var form_function_id = '<?php echo $form_function_id; ?>';
    var source_deal_detail_id = '<?php echo $source_deal_detail_id; ?>';
    var deal_price_data_process_id = '<?php echo $deal_price_data_process_id; ?>';
    var formula_field_form;
    var adjustment_field_form;
    var close_window = 0;
    var is_form_changed = 0;
	

    
    $(function() {
        grid = deal_pricing_detail.deal_pricing_type;
        quality_grid = deal_pricing_detail.deal_pricing_quality;
        form = deal_pricing_detail.deal_price_form;

        deal_pricing_detail.toolbar.addSpacer('cancel');        
        grid.enableDragAndDrop(true);
        deal_pricing_detail.load_data();

    });  

    deal_pricing_detail.load_data = function() {
        var data = {
            "action":"spa_deal_pricing_detail_provisional",
            "flag":"s",
            "mode":"normal",
            "xml_process_id": deal_price_data_process_id,
            "source_deal_detail_id":source_deal_detail_id
        }
        
        adiha_post_data("return_array", data, '', '', 'deal_pricing_detail.load_data_callback');
    } 

    deal_pricing_detail.load_data_callback = function (result) {
        var deal_detail_index = parent.dealDetail.grid.getColIndexById('source_deal_detail_id');
        var detail_arr = get_columns_value(parent.dealDetail.grid, deal_detail_index);
        var key = search_array(detail_arr, source_deal_detail_id);

        if (key == 0) {
            deal_pricing_detail.toolbar.disableItem('prev');
        } else {
            deal_pricing_detail.toolbar.enableItem('prev');
        }

        if (detail_arr.length - 1 == key) {
            deal_pricing_detail.toolbar.disableItem('next');
        } else {
            deal_pricing_detail.toolbar.enableItem('next');
        }

        grid.clearAll();
        quality_grid.clearAll();

        if (result.length == 0) {
            var form_jason = '{"pricing_aggregation": "","tiered":"false","settlement_date":"","settlement_uom":"","settlement_currency":"","fx_conversion_rate":"","pricing_description":""}';
            form.setFormData(JSON.parse(form_jason));

            return;        
        }

        if (result[0][0] != null) form.setFormData(JSON.parse(result[0][0]));
        if (result[0][1] != null) grid.parse(result[0][1],"json")
        if (result[0][2] != null) deal_price_deemed = JSON.parse(result[0][2]);
        if (result[0][3] != null) deal_std_event = JSON.parse(result[0][3]);
        if (result[0][4] != null) deal_custom_event = JSON.parse(result[0][4]);
        if (result[0][5] != null) deal_predefined_formula = JSON.parse(result[0][5]);
        if (result[0][9] != null) deal_price_adjustment = JSON.parse(result[0][9]);
        if (result[0][10] != null) quality_grid.parse(result[0][10],"json")

        if (result[0][8] != null) deal_pricing_detail.layout.cells('b').setText(result[0][8]);

        if (grid.getRowsNum() > 0) {
            grid.selectRow(0, true);
            //deal_pricing_detail.load_price_type(grid.getRowId(0), 0);
        }

        deal_pricing_detail.tiered_combo('l');
    }


    deal_pricing_detail.price_form_change = function (name, value, state) {
            if (name == 'tiered' && state) { // If tired checkbox is checked.
                deal_pricing_detail.tiered_combo();
                deal_pricing_detail.hide_show_item('s');
            } else if (name == 'tiered' && !state) {
                deal_pricing_detail.tiered_combo('u');
                deal_pricing_detail.hide_show_item('h');
            }
    }

    deal_pricing_detail.tiered_combo = function(status) {  // Tiered combo enable/disable case.
        var isChecked_tiered = form.isItemChecked('tiered');
        // var combo_pricing_aggregation = form.getCombo('pricing_aggregation');
        var count = 0;
        grid.forEachRow(function(id) {
            count += 1;
        });

        if (isChecked_tiered) { // If tired checked 
            // combo_pricing_aggregation.setComboValue('w');
            form.setItemValue('pricing_aggregation', 'w');
            form.disableItem('pricing_aggregation');
        } else if(count <= 1) { // If grid has less than 2 row.
            if(status == 'u') {
                form.setItemValue('pricing_aggregation', '');
            }
            form.disableItem('pricing_aggregation');
        } else if(count > 1) { // If grid has equal or greater than 2 row.
            // combo_pricing_aggregation.enable();
            // status_combo = combo_pricing_aggregation.isEnabled();
            status_combo = form.isItemEnabled('pricing_aggregation');
            form.enableItem('pricing_aggregation');
             if(!status_combo) {
                // combo_pricing_aggregation.setComboValue('s');
                form.setItemValue('pricing_aggregation', 's');
            }
        }
        //deal_pricing_detail.check_apply_to_all ();

    }

    deal_pricing_detail.check_apply_to_all = function() {       
        var data = {
            "action":"spa_deal_pricing_detail_provisional",
            "flag":"z",
            "mode": "normal",
            "source_deal_detail_id":source_deal_detail_id
        }
        adiha_post_data("return_array", data, '', '', 'deal_pricing_detail.load_check_apply_to_all');
        
    } 

    deal_pricing_detail.load_check_apply_to_all = function(result) {
        if (result[0][0] == 'TRUE') {
            form.checkItem('apply_to_all');
        }
    }

    deal_pricing_detail.hide_show_item = function(status) { 
        if(status == 's') {
            if (typeof price_type_form !== 'undefined') {
                price_type_form.showItem('volume');
                price_type_form.showItem('volume_uom');
            }
        } else {
            if (typeof price_type_form !== 'undefined') {
                price_type_form.hideItem('volume');
                price_type_form.hideItem('volume_uom');
                price_type_form.setItemValue('volume', '');
                price_type_form.setItemValue('volume_uom', '');
            }
        }
    }

    var need_reloading = 'y';

    deal_pricing_detail.save_grid_data =function (new_row,old_row,new_col_index) { 

        // alert(new_row + ':: ' + old_row);
        //if(new_col_index != 1 ) return true;
        //Start Validation 
        price_type_form = deal_pricing_detail.layout.cells('d').getAttachedObject();
        if(new_row !== old_row) {
            if (typeof price_type_form !== 'undefined') {
                if(price_type_form instanceof dhtmlXForm) { // form validation : 1C
                    var status1 = validate_form(price_type_form);
                    if(!status1) {
                        //console.log('yeta');
                        return
                    }      
                } else { // For Formula validation : 2U
                    var price_type_form = deal_pricing_detail.layout.cells('d').getAttachedObject();
                    if(price_type_form instanceof dhtmlXLayoutObject) {
                        var formula_form = price_type_form.cells('a').getAttachedObject();
                        if (typeof formula_form !== 'undefined') {
                            var status = validate_form(formula_form);
                        }

                        var formula_field_form = price_type_form.cells('b').getAttachedObject();
                        if (typeof formula_field_form !== 'undefined') {
                            var status1 = validate_form(formula_field_form);
                        } 

                        if(!status1 || !status) {
                            //console.log('uta');
                            return
                        }  
                    }
                } 
            }
        }
        // End Validation

        if (old_row == 0 ) return true;

        if (!grid.doesRowExist(old_row)) return true;


        var deal_price_type_id = grid.cells(old_row, grid.getColIndexById('deal_price_type_id')).getValue(); 
        var price_type = grid.cells(old_row, grid.getColIndexById('pricing_type')).getValue(); 
        var price_type_description = grid.cells(old_row, grid.getColIndexById('description')).getValue(); 

        if (!is_form_changed && price_type != 103602) return true;

        if (new_row == old_row &&  price_type == 103606) {
            need_reloading = 'n';
        } else {
            need_reloading = 'y';
        }

        if (price_type == 103600 || price_type == 103601 || price_type ==103602 || price_type == 103604 ) {
           
            if (!deal_price_deemed[old_row]) window.deal_price_deemed[old_row] = {};
     
        } else if (price_type == 103603) {
            if (!deal_std_event[old_row]) window.deal_std_event[old_row] = {};
        } else if (price_type == 103605) {
            if (!deal_custom_event[old_row]) window.deal_custom_event[old_row] = {};
        }  else if (price_type == 103606) {
           if (!deal_predefined_formula[old_row]) window.deal_predefined_formula[old_row] = {};
        } else if (price_type == 103607) {
           if (!deal_price_adjustment[old_row]) window.deal_price_adjustment[old_row] = {};
        } else {
            return true;
        }

        var price_type_form = deal_pricing_detail.layout.cells('d').getAttachedObject();
       
        if (price_type == 103606 && price_type_form instanceof dhtmlXLayoutObject ) {            
            var formula_form = price_type_form.cells('a').getAttachedObject();
            
            deal_predefined_formula[old_row].deal_price_type_id = deal_price_type_id;
            deal_predefined_formula[old_row].price_type = price_type;
            deal_predefined_formula[old_row].price_type_description = price_type_description;

            if (formula_form instanceof dhtmlXForm) {               
                deal_predefined_formula[old_row].formula_id = formula_form.getItemValue('formula');
            }

            var formula_field_form = price_type_form.cells('b').getAttachedObject();
            
            if (formula_field_form instanceof dhtmlXForm) {  
                deal_predefined_formula[old_row].formula_fields = formula_field_form.getFormData();
            }

            return true;
        }

        if (price_type == 103607 && price_type_form instanceof dhtmlXLayoutObject ) {            
            var adjustment_form = price_type_form.cells('a').getAttachedObject();
            
            deal_price_adjustment[old_row].deal_price_type_id = deal_price_type_id;
            deal_price_adjustment[old_row].price_type = price_type;
            deal_price_adjustment[old_row].price_type_description = price_type_description;

            if (adjustment_form instanceof dhtmlXForm) {               
                deal_price_adjustment[old_row].adjustment_id = adjustment_form.getItemValue('adjustment');
            }

            var adjustment_field_form = price_type_form.cells('b').getAttachedObject();

            if (adjustment_field_form instanceof dhtmlXForm) {  
                deal_price_adjustment[old_row].adjustment_fields = adjustment_field_form.getFormData();
            }

            return true;
        }


        if (price_type_form instanceof dhtmlXForm) {

            if (price_type == 103600) {
                
                deal_price_deemed[old_row].deal_price_type_id = deal_price_type_id;
                deal_price_deemed[old_row].price_type = price_type;
                deal_price_deemed[old_row].price_type_description = price_type_description;
                deal_price_deemed[old_row].fixed_price =  price_type_form.getItemValue('fixed_price');
                deal_price_deemed[old_row].pricing_currency =  price_type_form.getItemValue('pricing_currency');
                deal_price_deemed[old_row].pricing_uom =  price_type_form.getItemValue('pricing_uom');
                deal_price_deemed[old_row].volume =  price_type_form.getItemValue('volume');
                deal_price_deemed[old_row].volume_uom =  price_type_form.getItemValue('volume_uom');

                //console.log('aa');
                //console.log(deal_price_deemed[old_row]);

            } else if (price_type == 103601) {
                deal_price_deemed[old_row].deal_price_type_id = deal_price_type_id;
                deal_price_deemed[old_row].price_type = price_type;
                deal_price_deemed[old_row].price_type_description = price_type_description;
                deal_price_deemed[old_row].pricing_index =  price_type_form.getItemValue('pricing_index');
                deal_price_deemed[old_row].pricing_period =  price_type_form.getItemValue('pricing_period');
                deal_price_deemed[old_row].pricing_start =  price_type_form.getItemValue('pricing_start', true);
                deal_price_deemed[old_row].pricing_end =  price_type_form.getItemValue('pricing_end', true);
                deal_price_deemed[old_row].include_weekends =  price_type_form.isItemChecked('include_weekends');
                deal_price_deemed[old_row].multiplier =  price_type_form.getItemValue('multiplier');
                deal_price_deemed[old_row].adder =  price_type_form.getItemValue('adder');
                deal_price_deemed[old_row].adder_currency =  price_type_form.getItemValue('adder_currency');
                deal_price_deemed[old_row].rounding =  price_type_form.getItemValue('rounding');
                deal_price_deemed[old_row].volume =  price_type_form.getItemValue('volume');
                deal_price_deemed[old_row].volume_uom =  price_type_form.getItemValue('volume_uom');
                deal_price_deemed[old_row].balmo_pricing =  price_type_form.isItemChecked('balmo_pricing');

                //console.log('bb');
                //console.log(deal_price_deemed[old_row]);
            } else if (price_type == 103602) {
                deal_price_deemed[old_row].deal_price_type_id = deal_price_type_id;
                deal_price_deemed[old_row].price_type = price_type;
                deal_price_deemed[old_row].price_type_description = price_type_description;
                deal_price_deemed[old_row].formula_id =  price_type_form.getItemValue('formula_id');
                deal_price_deemed[old_row].formula_name =  price_type_form.getItemValue('label_formula_id');
                deal_price_deemed[old_row].formula_currency =  price_type_form.getItemValue('formula_currency');
                deal_price_deemed[old_row].volume =  price_type_form.getItemValue('volume');
                deal_price_deemed[old_row].volume_uom =  price_type_form.getItemValue('volume_uom');

                //console.log('cc');
                //console.log(deal_price_deemed[old_row]);
            } else if (price_type == 103603) {
                deal_std_event[old_row].deal_price_type_id = deal_price_type_id;
                deal_std_event[old_row].price_type = price_type;
                deal_std_event[old_row].price_type_description = price_type_description;
                deal_std_event[old_row].event_type =  price_type_form.getItemValue('event');
                deal_std_event[old_row].event_date =  price_type_form.getItemValue('event_date', true);
                deal_std_event[old_row].pricing_index =  price_type_form.getItemValue('pricing_index'); 
                deal_std_event[old_row].adder =  price_type_form.getItemValue('adder');
                deal_std_event[old_row].adder_currency =  price_type_form.getItemValue('adder_currency');
                deal_std_event[old_row].multiplier =  price_type_form.getItemValue('multiplier');
                deal_std_event[old_row].rounding =  price_type_form.getItemValue('rounding');
                deal_std_event[old_row].volume =  price_type_form.getItemValue('volume');
                deal_std_event[old_row].volume_uom =  price_type_form.getItemValue('volume_uom');
                deal_std_event[old_row].pricing_month =  price_type_form.getItemValue('pricing_month',true);

                //console.log('dd');
                //console.log(deal_std_event[old_row]);

            } else if (price_type == 103604) {
                
                deal_price_deemed[old_row].deal_price_type_id = deal_price_type_id;
                deal_price_deemed[old_row].price_type = price_type;
                deal_price_deemed[old_row].price_type_description = price_type_description;
                deal_price_deemed[old_row].fixed_cost = price_type_form.getItemValue('fixed_cost');
                deal_price_deemed[old_row].Fixed_cost_currency = price_type_form.getItemValue('Fixed_cost_currency');
                deal_price_deemed[old_row].volume = price_type_form.getItemValue('volume');
                deal_price_deemed[old_row].volume_uom = price_type_form.getItemValue('volume_uom');

                //console.log('ee');
                //console.log(deal_price_deemed[old_row]);
            } else if (price_type == 103605) {                
                deal_custom_event[old_row].deal_price_type_id = deal_price_type_id;
                deal_custom_event[old_row].price_type = price_type;
                deal_custom_event[old_row].price_type_description = price_type_description;
                deal_custom_event[old_row].event_type =  price_type_form.getItemValue('event_type');
                deal_custom_event[old_row].event_date =  price_type_form.getItemValue('event_date', true);
                deal_custom_event[old_row].pricing_index =  price_type_form.getItemValue('pricing_index');
                deal_custom_event[old_row].skip_days =  price_type_form.getItemValue('skip_days');
                deal_custom_event[old_row].quotes_before =  price_type_form.getItemValue('quotes_before');
                deal_custom_event[old_row].quotes_after =  price_type_form.getItemValue('quotes_after');
                deal_custom_event[old_row].include_event_date =  price_type_form.isItemChecked('include_event_date');
                deal_custom_event[old_row].include_weekends =  price_type_form.isItemChecked('include_weekends');
                deal_custom_event[old_row].adder =  price_type_form.getItemValue('adder');
                deal_custom_event[old_row].adder_currency =  price_type_form.getItemValue('adder_currency');
                deal_custom_event[old_row].multiplier =  price_type_form.getItemValue('multiplier');
                deal_custom_event[old_row].rounding =  price_type_form.getItemValue('rounding');
                deal_custom_event[old_row].volume =  price_type_form.getItemValue('volume');
                deal_custom_event[old_row].volume_uom =  price_type_form.getItemValue('volume_uom');
				deal_custom_event[old_row].pricing_month =  price_type_form.getItemValue('pricing_month',true);
				deal_custom_event[old_row].skip_granularity =  price_type_form.getItemValue('skip_granularity');                
                //console.log('ff');
                //console.log(deal_custom_event[old_row]);
           }
        }
        return true;
    }

    deal_pricing_detail.load_price_type =function (id, ind) {

        is_form_changed = 0;
       
        price_type = grid.cells(id, grid.getColIndexById('pricing_type')).getValue();
        price_type_form = deal_pricing_detail.layout.cells('d').getAttachedObject();

            
        if (price_type == 103600) {
            group_name = 'Fixed Price';   
        } else if (price_type == 103601) {
            group_name = 'Indexed';   
        } else if (price_type == 103602) {
            group_name = 'Formula';   
        }  else if (price_type == 103603) {
            group_name = 'Standard Event';   
        } else if (price_type == 103604) {
            group_name = 'Fixed Cost';   
        } else if (price_type == 103605) {
            group_name = 'Custom Event';            
        } else if (price_type == 103606) {
            deal_pricing_detail.open_predefined_formula_form();
            return   
        } else if (price_type == 103607) {
            deal_pricing_detail.open_price_adjustment_form();
            return   
        } else {
            return;
        }


        deal_pricing_detail.open_pricing_form(group_name, price_type);
    } 
    
    deal_pricing_detail.load_price_type_cell =function ( rId,cInd,nValue) {

        if (need_reloading == 'n') return;

        if (cInd != 1) return;

        if (nValue == 103600) {
            group_name = 'Fixed Price'; 

        } else if (nValue == 103601) {
            group_name = 'Indexed';   
        } else if (nValue == 103602) {
            group_name = 'Formula';   
        }  else if (nValue == 103603) {
            group_name = 'Standard Event';   
        } else if (nValue == 103604) {
            group_name = 'Fixed Cost';   
        } else if (nValue == 103605) {
            group_name = 'Custom Event';            
        } else if (nValue == 103606) {
             // console.log('cell');
            deal_pricing_detail.open_predefined_formula_form();
            return  
        } else if (nValue == 103607 ) {
             // console.log('cell');
            deal_pricing_detail.open_price_adjustment_form();
            return  
        }

        else {
            return;
        }

        deal_pricing_detail.open_pricing_form(group_name, nValue); 
    }

    deal_pricing_detail.open_predefined_formula_form = function() {
        if (need_reloading == 'n') return;

        is_form_changed = 0;

        formula_layout = deal_pricing_detail.layout.cells('d').attachLayout({
                            pattern: "2U",
                            cells: [
                                {id: "a", text: "Formula", width: 300},
                                {id: "b", text: "Formula Fields"}
                            ]
                        });
        formula_form = formula_layout.cells('a').attachForm();        
        
        var rid = grid.getSelectedRowId();

        formula_form.loadStruct(predefined_formula_json, function() {
            //console.log(deal_predefined_formula[rid]);
            if (deal_predefined_formula[rid]) {
                formula_form.setItemValue('formula',deal_predefined_formula[rid].formula_id);

                if (deal_predefined_formula[rid].formula_id != null) { 
                    var cm_param = {"action": "spa_deal_formula_udf", "flag": "y", "formula_id":deal_predefined_formula[rid].formula_id};
                    adiha_post_data("return", cm_param, '', '', 'deal_pricing_detail.load_formula_fields');

                }
            }  
        });   

        formula_form.attachEvent('onChange', function(id, value) {
            //if (id == 'formula' ) {
                is_form_changed = 1;
                if (value != '' && value != null) { 
                    var cm_param = {"action": "spa_deal_formula_udf", "flag": "y", "formula_id":value};
                    adiha_post_data("return", cm_param, '', '', 'deal_pricing_detail.load_formula_fields');
                }
            //}
        });

        formula_field_form = formula_layout.cells('b').attachForm();
    }

    deal_pricing_detail.load_formula_fields = function(result) {
        if (result[0].form_json != '' && result[0].form_json != 'undefined') {
            if (formula_field_form instanceof dhtmlXForm) {

           
                formula_field_form.attachEvent("onChange", function (name, value) {
                    is_form_changed = 1;
                    return true;
                });



                var form_data = formula_field_form.getFormData();
                for (var a in form_data) {
                    formula_field_form.removeItem(a);
                } 
                
                formula_layout.cells('b').expand();
                
                formula_field_form.load(result[0].form_json, function () {
                    var rid = grid.getSelectedRowId();

                    if (rid == null && grid.getRowsNum() > 0) rid = grid.getRowId(0);
                   
                    if (deal_predefined_formula[rid]) {
                        // console.log(deal_predefined_formula[rid].formula_fields);
                        formula_field_form.setFormData(deal_predefined_formula[rid].formula_fields);
                    }

                });           
            }
        }
    }

    deal_pricing_detail.open_price_adjustment_form = function() {
        if (need_reloading == 'n') return;

        is_form_changed = 0;

        adjustment_layout = deal_pricing_detail.layout.cells('d').attachLayout({
                            pattern: "2U",
                            cells: [
                                {id: "a", text: "Adjustment", width: 300},
                                {id: "b", text: "Attributes"}
                            ]
                        });
        adjustment_form = adjustment_layout.cells('a').attachForm();        
        
        var rid = grid.getSelectedRowId();

        adjustment_form.loadStruct(price_adjustment_json, function() {
            if (deal_price_adjustment[rid]) {
                adjustment_form.setItemValue('adjustment',deal_price_adjustment[rid].adjustment_id);

                if (deal_price_adjustment[rid].adjustment_id != null) { 
                    var cm_param = {"action": "spa_deal_formula_udf", "flag": "y", "formula_id":deal_price_adjustment[rid].adjustment_id};
                    adiha_post_data("return", cm_param, '', '', 'deal_pricing_detail.load_price_adjustment_fields');

                }
            }  
        });   

        adjustment_form.attachEvent('onChange', function(id, value) {
           // if (id == 'adjustment' ) {
                is_form_changed = 1;
                if (value != '' && value != null) { 
                    var cm_param = {"action": "spa_deal_formula_udf", "flag": "y", "formula_id":value};
                    adiha_post_data("return", cm_param, '', '', 'deal_pricing_detail.load_price_adjustment_fields');
                }
            //}
        });

        adjustment_field_form = adjustment_layout.cells('b').attachForm();
    }

    deal_pricing_detail.load_price_adjustment_fields = function(result) {
        if (result[0].form_json != '' && result[0].form_json != 'undefined') {
            if (adjustment_field_form instanceof dhtmlXForm) {

                adjustment_field_form.attachEvent("onChange", function (name, value) {
                    is_form_changed = 1;
                    return true;
                });



                var form_data = adjustment_field_form.getFormData();
                for (var a in form_data) {
                    adjustment_field_form.removeItem(a);
                } 
                
                adjustment_layout.cells('b').expand();
                
                adjustment_field_form.load(result[0].form_json, function () {
                    var rid = grid.getSelectedRowId();

                    if (rid == null && grid.getRowsNum() > 0) rid = grid.getRowId(0);
                   
                    if (deal_price_adjustment[rid]) {
                        // console.log(deal_price_adjustment[rid].adjustment_fields);
                        adjustment_field_form.setFormData(deal_price_adjustment[rid].adjustment_fields);
                    }

                });           
            }
        }
    }


    deal_pricing_detail.open_pricing_form = function(group_name, price_type) { 
        data = {"action": "spa_create_application_ui_json",
            "flag": "j",
            "application_function_id": 10131049,
            "template_name": "deal_provisional_pricing_type",
            "group_name": group_name
        };

        adiha_post_data('return_array', data, '', '', 'load_price_type_detail', '');   
    }

    function load_price_type_detail(result) {            
        var tab_json = '';        
        form_json = result[0][2];            
        price_type_form = deal_pricing_detail.layout.cells('d').attachForm();

        

        price_type_form.attachEvent("onChange", function (name, value, state) {
            is_form_changed = 1;
            deal_pricing_detail.price_period_change(this);
        });

        price_type_form.attachEvent("onKeyDown", function (inp, ev, name, value) {
            is_form_changed = 1;
            return true;
        });

        deal_pricing_detail.price_period_change = function(form_obj) {

            value = form_obj.getItemValue('pricing_period'); 

            if(value == '106608') {
                form_obj.setItemLabel('pricing_start', "Pricing Start");
                form_obj.showItem('pricing_start');
                form_obj.showItem('pricing_end');
                form_obj.enableItem('pricing_start');
                form_obj.enableItem('pricing_end');
            } else if (value == '106602' ) {
                form_obj.setItemLabel('pricing_start', "Est. Movement Date");
                form_obj.showItem('pricing_start');
                form_obj.enableItem('pricing_start')
                form_obj.hideItem('pricing_end');
                form_obj.setItemValue('pricing_end', '');
                form_obj.disableItem('pricing_end');

            } else {
                form_obj.setItemLabel('pricing_start', "Pricing Start");
                form_obj.hideItem('pricing_start');
                form_obj.hideItem('pricing_end');
                form_obj.setItemValue('pricing_start', '');
                form_obj.setItemValue('pricing_end', '');
                form_obj.disableItem('pricing_start');
                form_obj.disableItem('pricing_end');
            }
         
        }
        

        //console.log(form_json);

        price_type_form.loadStruct(form_json, function(){
                var rid = grid.getSelectedRowId();
                attach_browse_event('price_type_form', 10131010, '', '');

                if (rid == null && grid.getRowsNum() > 0) rid = grid.getRowId(0);

                var price_type = grid.cells(rid, grid.getColIndexById('pricing_type')).getValue();

                if (deal_price_deemed[rid] || deal_std_event[rid] || deal_custom_event[rid]) {
                    var price_type_form = deal_pricing_detail.layout.cells('d').getAttachedObject();
                    if (price_type_form instanceof dhtmlXForm) {
                        if (price_type == 103600) {
                            // console.log('price: '  + JSON.stringify(deal_price_deemed[rid]));
                            price_type_form.setItemValue('fixed_price',  deal_price_deemed[rid].fixed_price);  
                            price_type_form.setItemValue('pricing_currency', deal_price_deemed[rid].pricing_currency ); 
                            price_type_form.setItemValue('pricing_uom', deal_price_deemed[rid].pricing_uom ); 
                            price_type_form.setItemValue('volume', deal_price_deemed[rid].volume);   
                            price_type_form.setItemValue('volume_uom',  deal_price_deemed[rid].volume_uom); 

                            // console.log('aa');
                            // console.log(deal_price_deemed[rid]);

                        } else if (price_type == 103601) {
                            price_type_form.setItemValue('pricing_index',  deal_price_deemed[rid].pricing_index);  
                            price_type_form.setItemValue('pricing_period', deal_price_deemed[rid].pricing_period ); 
                            price_type_form.setItemValue('pricing_start', deal_price_deemed[rid].pricing_start ); 
                            price_type_form.setItemValue('pricing_end', deal_price_deemed[rid].pricing_end ); 
                           
                            if (deal_price_deemed[rid].include_weekends)
                                price_type_form.checkItem('include_weekends');   
                            else 
                                price_type_form.uncheckItem('include_weekends');   

                            if (deal_price_deemed[rid].balmo_pricing)
                                price_type_form.checkItem('balmo_pricing');   
                            else 
                                price_type_form.uncheckItem('balmo_pricing');  

                           
                            price_type_form.setItemValue('multiplier',  deal_price_deemed[rid].multiplier);                            
                            price_type_form.setItemValue('adder',  deal_price_deemed[rid].adder);  
                            price_type_form.setItemValue('adder_currency', deal_price_deemed[rid].adder_currency ); 
                            price_type_form.setItemValue('rounding', deal_price_deemed[rid].rounding ); 
                            price_type_form.setItemValue('volume', deal_price_deemed[rid].volume);   
                            price_type_form.setItemValue('volume_uom',  deal_price_deemed[rid].volume_uom);

                            // console.log('bb');
                            // console.log(deal_price_deemed[rid]);
                        }
                        else if (price_type == 103602) {
                            // console.log('price: '  + JSON.stringify(deal_price_deemed[rid]));
                            price_type_form.setItemValue('formula_id',  deal_price_deemed[rid].formula_id);  
                            price_type_form.setItemValue('label_formula_id', deal_price_deemed[rid].formula_name); 
                            price_type_form.setItemValue('formula_currency', deal_price_deemed[rid].formula_currency ); 
                            price_type_form.setItemValue('volume', deal_price_deemed[rid].volume ); 
                            price_type_form.setItemValue('volume_uom', deal_price_deemed[rid].volume_uom);

                            // attach_browse_event('price_type_form', 10131010, '', '');
                            // console.log('cc');
                            // console.log(deal_price_deemed[rid]);
                        }
                        else if (price_type == 103603) {
                           
                            price_type_form.setItemValue('event',  deal_std_event[rid].event_type);  
                            price_type_form.setItemValue('event_date', deal_std_event[rid].event_date );
                            price_type_form.setItemValue('pricing_index', deal_std_event[rid].pricing_index );
                            price_type_form.setItemValue('adder', deal_std_event[rid].adder ); 
                            price_type_form.setItemValue('adder_currency', deal_std_event[rid].adder_currency);   
                            price_type_form.setItemValue('multiplier',  deal_std_event[rid].multiplier);                            
                            price_type_form.setItemValue('rounding', deal_std_event[rid].rounding ); 
                            price_type_form.setItemValue('volume', deal_std_event[rid].volume);   
                            price_type_form.setItemValue('volume_uom',  deal_std_event[rid].volume_uom);
                            price_type_form.setItemValue('pricing_month',  deal_std_event[rid].pricing_month);

                            // console.log('dd');
                            // console.log(deal_std_event[rid]);

                        }
                        else if (price_type == 103604) {
                            
                            price_type_form.setItemValue('fixed_cost',  deal_price_deemed[rid].fixed_cost);  
                            price_type_form.setItemValue('Fixed_cost_currency', deal_price_deemed[rid].Fixed_cost_currency ); 
                            price_type_form.setItemValue('volume', deal_price_deemed[rid].volume);   
                            price_type_form.setItemValue('volume_uom',  deal_price_deemed[rid].volume_uom);

                            // console.log('ee');
                            // console.log(deal_price_deemed[rid]);
                        }
                        else if (price_type == 103605) {                
                            price_type_form.setItemValue('event_type',  deal_custom_event[rid].event_type);  
                            price_type_form.setItemValue('event_date', deal_custom_event[rid].event_date );                             
                            price_type_form.setItemValue('pricing_index',  deal_custom_event[rid].pricing_index);                            
                            price_type_form.setItemValue('skip_days', deal_custom_event[rid].skip_days ); 
                            price_type_form.setItemValue('quotes_before', deal_custom_event[rid].quotes_before);   
                            price_type_form.setItemValue('quotes_after', deal_custom_event[rid].quotes_after);
                            if (deal_custom_event[rid].include_event_date)
                                price_type_form.checkItem('include_event_date');   
                            else 
                                price_type_form.uncheckItem('include_event_date');  

                            if (deal_custom_event[rid].include_weekends)
                                price_type_form.checkItem('include_weekends');   
                            else 
                                price_type_form.uncheckItem('include_weekends');    

                            price_type_form.setItemValue('adder', deal_custom_event[rid].adder ); 
                            price_type_form.setItemValue('adder_currency', deal_custom_event[rid].adder_currency);   
                            price_type_form.setItemValue('multiplier',  deal_custom_event[rid].multiplier);                            
                            price_type_form.setItemValue('rounding', deal_custom_event[rid].rounding ); 
                            price_type_form.setItemValue('volume', deal_custom_event[rid].volume);   
                            price_type_form.setItemValue('volume_uom',  deal_custom_event[rid].volume_uom);
							price_type_form.setItemValue('pricing_month', deal_custom_event[rid].pricing_month);
                            price_type_form.setItemValue('skip_granularity', deal_custom_event[rid].skip_granularity);                            
                            // console.log('ff');
                            // console.log(deal_custom_event[rid]);
                       }
                    }

                }
                
            });

            var tiered_state = deal_pricing_detail.deal_price_form.isItemChecked('tiered');
            if(tiered_state)
                deal_pricing_detail.hide_show_item('s');
            else 
                deal_pricing_detail.hide_show_item('h'); 

            var pricing_period_combo = price_type_form.getCombo('pricing_period');
            if (typeof pricing_period_combo !== 'undefined' && pricing_period_combo !== null) {
                var pricing_period_value = pricing_period_combo.getSelectedValue();

           
                deal_pricing_detail.price_period_change(price_type_form);
            }
    }

    deal_pricing_detail.menu_click = function(id) {
        switch (id) {
            case 'add':
                var new_id = (new Date()).valueOf();
                grid.addRow(new_id, '');
                deal_pricing_detail.tiered_combo();

                grid.forEachRow(function(row) {
                    grid.forEachCell(row,function(cellObj, ind) {
                        grid.validateCell(row, ind);
                    });
                });
                
                break;
               
            case 'delete':
                deal_pricing_detail.layout.cells('d').detachObject(true);
                grid.deleteSelectedRows();
                if (grid.getRowsNum() > 0) {
                    grid.selectRow(0, true);
                }
                deal_pricing_detail.tiered_combo('u');
                break;
            case 'excel':
                grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case 'add_multiple':
                add_multiple_rows(grid);
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    deal_pricing_detail.quality_menu_click = function(id) {        
        
        switch (id) {
            case 'add':
                var new_id = (new Date()).valueOf();
                quality_grid.addRow(new_id, '');
                deal_pricing_detail.tiered_combo();

                quality_grid.forEachRow(function(row) {
                    quality_grid.forEachCell(row,function(cellObj, ind) {
                        quality_grid.validateCell(row, ind);
                    });
                });
                
                break;
               
            case 'delete':
                deal_pricing_detail.layout.cells('d').detachObject(true);
                quality_grid.deleteSelectedRows();
                if (quality_grid.getRowsNum() > 0) {
                    quality_grid.selectRow(0, true);
                }
                deal_pricing_detail.tiered_combo('u');
                break;
            case 'excel':
                quality_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                quality_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case 'add_multiple':
                add_multiple_rows(quality_grid);
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    deal_pricing_detail.toolbar_click  = function(id) {
        switch (id) {
            case 'ok':
                close_window = 1;
                deal_pricing_detail.save('m');                
                break;
            case 'prev':
                close_window = 2;
                deal_pricing_detail.save('p');
                break;
            case 'next':
                close_window = 0;
                deal_pricing_detail.save('n');
                break;
            case 'cancel':
                var win_obj = window.parent.volume_window.window("w1");
                win_obj.close();
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    function add_multiple_rows(grid_obj) {
        var row_no_form_data = [
                                {type: "settings", position: "label-left", labelWidth: 150, inputWidth: 130, position: "label-top", offsetLeft: 20},
                                {type: "input", name: "row_number", label: "Number"},
                                {type: "button", value: "Ok", img: "tick.png"}
                            ];
                            
        var row_no_rerun_popup = new dhtmlXPopup();
        var row_no_form = row_no_rerun_popup.attachForm(row_no_form_data);
        var h = deal_pricing_detail.layout.cells('b').getHeight();

        row_no_rerun_popup.show(30,260,45,h-110);

        row_no_rerun_popup.attachEvent("onBeforeHide", function(type, ev, id){
            row_no_rerun_popup.hide();
        });

        row_no_form.attachEvent("onButtonClick", function(id) {
            var row_number = row_no_form.getItemValue('row_number');
            var patt = /^[1-9]\d*$/
            var result = row_number.match(patt);
            if(!result) {
                row_no_form.setNote("row_number",{text:"Insert positive integer only."});  
                row_no_form.attachEvent("onchange", 
                    function(field_label, lbl_value){
                        row_no_form.setNote("row_number",{text:""});
                    }
                );
                // show_messagebox("Insert positive integer only.");
                return
            }      

            for (i = 0; i < row_number; i++) {
                var new_id = (new Date()).valueOf();
                grid_obj.addRow(new_id, ''); 
                
                grid_obj.forEachRow(function(row) {
                    grid_obj.forEachCell(row,function(cellObj, ind) {
                        grid_obj.validateCell(row, ind);
                    });
                });
            }
            row_no_rerun_popup.hide(); 
            deal_pricing_detail.tiered_combo();
        });
        // row_no_rerun_popup.hide();
        
    }

    deal_pricing_detail.save = function(flag) { 
        rid = grid.getSelectedRowId();

        var is_apply_to_all = 'n';

        if (rid != null) {
            is_form_changed = 1;
            deal_pricing_detail.save_grid_data(rid,rid,0);
        }

        //Start Validation 
        price_type_form = deal_pricing_detail.layout.cells('d').getAttachedObject();
        if (typeof price_type_form !== 'undefined') {
            if (price_type_form instanceof dhtmlXForm) { // form validation : 1C
                var status1 = validate_form(price_type_form);
               
                pricing_start_value = ("" + price_type_form.getItemValue("pricing_start", true) + ""); 
                pricing_end_value = ("" + price_type_form.getItemValue("pricing_end", true) + "");
                var pricing_start_value_parse = Date.parse(pricing_start_value);
                var pricing_end_value_parse = Date.parse(pricing_end_value);


                if ((pricing_start_value_parse !== "") && (pricing_end_value_parse !== "") && (pricing_start_value_parse > pricing_end_value_parse)) {
                    show_messagebox('<strong>Pricing Start</strong> cannot be greater than <strong>Pricing End</strong>.'); 
                    return
                }
                if(!status1) {
                    return
                }      
            } else { // For Formula validation : 2U
                var price_type_form = deal_pricing_detail.layout.cells('d').getAttachedObject();
                if(price_type_form instanceof dhtmlXLayoutObject) {
                    var formula_form = price_type_form.cells('a').getAttachedObject();
                    if (typeof formula_form !== 'undefined') {
                        var status = validate_form(formula_form);
                    }

                    var formula_field_form = price_type_form.cells('b').getAttachedObject();
                    if (typeof formula_field_form !== 'undefined') {
                        var status1 = validate_form(formula_field_form);
                    } 

                    if(!status1 || !status) {
                        return
                    }  
                }
            } 
        }
        // End Validation

        apply_to_all= deal_pricing_detail.layout.cells('b').getAttachedObject().isItemChecked('apply_to_all');
        grid_row = grid.getRowsNum();

        if (apply_to_all && grid_row < 1) {
            dhtmlx.message({
                title:"Confirmation",
                type:"confirm",
                ok: "Confirm",
                text: "Applying empty pricing will remove all pricing components. Are you sure to remove ?",
                callback: function(result) {
                    if (result) {
                        deal_pricing_detail.save_data(flag);
                    }
                }
            });
        } else {
            deal_pricing_detail.save_data(flag);
        }
    }

    deal_pricing_detail.save_data = function (flag) {
         // cell_validation();
        deal_pricing_detail.deal_pricing_type.setSerializationLevel(false, true, true);
        var grid_status = deal_pricing_detail.validate_form_grid(deal_pricing_detail.deal_pricing_type, 'Deal Pricing Type');
        if (grid_status == false) {
            return;
        }

        var xml = '<root><deal_price_qualities>';

        quality_grid.forEachRow(function(id) { 
            xml += '<deal_price_quality deal_price_quality_id="' +  quality_grid.cells(id, quality_grid.getColIndexById('deal_price_quality_id')).getValue() + '" ';
            xml += ' attribute="' +  quality_grid.cells(id, quality_grid.getColIndexById('attribute')).getValue() + '" ';
            xml += ' operator="' +  quality_grid.cells(id, quality_grid.getColIndexById('operator')).getValue() + '" ';
            xml += ' numeric_value="' +  quality_grid.cells(id, quality_grid.getColIndexById('numeric_value')).getValue() + '" ';
            xml += ' text_value="' +  quality_grid.cells(id, quality_grid.getColIndexById('text_value')).getValue() + '" ';
            xml += ' uom="' +  quality_grid.cells(id, quality_grid.getColIndexById('uom')).getValue() + '" ';
            xml += ' basis="' +  quality_grid.cells(id, quality_grid.getColIndexById('basis')).getValue() + '" />';
        });
        xml += '</deal_price_qualities><deal_pricing ';

        var price_form = deal_pricing_detail.layout.cells('b').getAttachedObject();
        if (price_form instanceof dhtmlXForm) {

            xml += ' pricing_aggregation="' + price_form.getItemValue('pricing_aggregation') + '" ';
            xml += ' tiered="' + price_form.isItemChecked('tiered') + '" ';
            xml += ' settlement_date="' + price_form.getItemValue('settlement_date', true) + '" ';
            xml += ' settlement_uom="' + price_form.getItemValue('settlement_uom') + '" ';
            xml += ' settlement_currency="' +  price_form.getItemValue('settlement_currency') + '" ';
            xml += ' fx_conversion_rate="' + price_form.getItemValue('fx_conversion_rate') + '" ';
            xml += ' pricing_description="' + price_form.getItemValue('pricing_description') + '" />';

            is_apply_to_all = price_form.isItemChecked('apply_to_all') ? 'y' : 'n';
        }

        var priority = 0;

        grid.forEachRow(function(id) {
            var isChecked_tiered = form.isItemChecked('tiered');
            rid = id;
            priority = grid.getRowIndex(rid) + 1;
           
            //console.log('save  ' + rid);
            price_type = grid.cells(id, grid.getColIndexById('pricing_type')).getValue(); 

            if (price_type == 103600 ) {
                xml += '<deal_fixed_price  rid="' + id + '" priority= "' + priority + '" ';
                    
                $.each(deal_price_deemed[rid], function(index, value) {
                    if ((value == null) || (!isChecked_tiered && (index == 'volume' || index == 'volume_uom'))) {
                       value = ''; 
                    }
                    xml += index + '="' + value + '"  ';
                });
                xml += '/> ';
               // console.log(deal_price_deemed[rid]);
            } else if (price_type == 103601) {
                xml += '<deal_index rid="' + id + '" priority= "' + priority + '" ';
                $.each(deal_price_deemed[rid], function(index, value) {
                    if ((value == null) || (!isChecked_tiered && (index == 'volume' || index == 'volume_uom'))) {
                       value = ''; 
                    }
                     xml += index + '="' + value + '"  ';
                });
                xml += '/> ';
                //console.log(deal_price_deemed[rid]);
            } 
            else if (price_type ==103602) {
                xml += '<deal_formula rid="' + id + '" priority= "' + priority + '" ';
                $.each(deal_price_deemed[rid], function(index, value) {
                    if ((value == null) || (!isChecked_tiered && (index == 'volume' || index == 'volume_uom'))) {
                       value = ''; 
                    }
                     xml += index + '="' + value + '"  ';
                });
                xml += '/> ';
               // console.log(deal_price_deemed[rid]);
            } 
            else if (price_type == 103604 ) {
                xml += '<deal_fixed_cost rid="' + id + '" priority= "' + priority + '" ';
                $.each(deal_price_deemed[rid], function(index, value) {
                    if ((value == null) || (!isChecked_tiered && (index == 'volume' || index == 'volume_uom'))) {
                       value = ''; 
                    }
                     xml += index + '="' + value + '"  ';
                });
                xml += '/> ';
               // console.log(deal_price_deemed[rid]);
            } else if (price_type == 103603) {
                xml += '<deal_std_event rid="' + id + '" priority= "' + priority + '" ';
                $.each(deal_std_event[rid], function(index, value) {
                    if ((value == null) || (!isChecked_tiered && (index == 'volume' || index == 'volume_uom'))) {
                       value = ''; 
                    }
                     xml += index + '="' + value + '"  ';
                });
                xml += '/> ';
               // console.log(deal_std_event[rid]);
            } else if (price_type == 103605) {
                xml += '<deal_custom_event rid="' + id + '" priority= "' + priority + '" ';
                $.each(deal_custom_event[rid], function(index, value) {
                    if ((value == null) || (!isChecked_tiered && (index == 'volume' || index == 'volume_uom'))) {
                       value = ''; 
                    }
                     xml += index + '="' + value + '"  ';
                });
                xml += '/> ';
                //console.log(deal_custom_event[rid]);                
            } else if (price_type == 103606) {
                var udf_xml = '';
                xml += '<deal_predefined_formula rid="' + id 
                        + '" priority= "' + priority 
                        + '" deal_price_type_id="' + deal_predefined_formula[rid].deal_price_type_id 
                        + '" price_type="' + deal_predefined_formula[rid].price_type
                        + '" price_type_description="' + deal_predefined_formula[rid].price_type_description
                        + '" formula_id="' + deal_predefined_formula[rid].formula_id
                        + '" >';

                Object.keys(deal_predefined_formula[rid].formula_fields).forEach(function(key){
                    udf_xml = '<udf name="' + key + '" value="' + deal_predefined_formula[rid].formula_fields[key] + '"> </udf> ';
                });

                if (udf_xml == '') {
                    udf_xml = '<udf name="" value=""> </udf> ';
                }

                xml += udf_xml;

                xml += ' </deal_predefined_formula>';
            } else if (price_type == 103607) {
                var udf_xml = '';
                xml += '<deal_price_adjustment rid="' + id 
                        + '" priority= "' + priority 
                        + '" deal_price_type_id="' + deal_price_adjustment[rid].deal_price_type_id 
                        + '" price_type="' + deal_price_adjustment[rid].price_type
                        + '" price_type_description="' + deal_price_adjustment[rid].price_type_description
                        + '" formula_id="' + deal_price_adjustment[rid].adjustment_id
                        + '" >';

                Object.keys(deal_price_adjustment[rid].adjustment_fields).forEach(function(key){
                    udf_xml = '<udf name="' + key + '" value="' + deal_price_adjustment[rid].adjustment_fields[key] + '"> </udf> ';
                });

                if (udf_xml == '') {
                    udf_xml = '<udf name="" value=""> </udf> ';
                }

                xml += udf_xml;
                xml += ' </deal_price_adjustment>';
            } else {
                return true;
            }
        });

        xml += '</root>';

        if (is_apply_to_all == 'y') {
            var deal_detail_index = parent.dealDetail.grid.getColIndexById('source_deal_detail_id');
            var deal_detail_ids_arr = get_columns_value(parent.dealDetail.grid, deal_detail_index);
            var deal_detail_ids = deal_detail_ids_arr.toString();

            flag = 't';
        } else {
            deal_detail_ids = 'NULL';
        }

        data = {"action": "spa_deal_pricing_detail_provisional",
                "flag": flag,
                "source_deal_detail_id": source_deal_detail_id, 
                "xml": xml,
                "mode": 'fetch',
                "xml_process_id": deal_price_data_process_id,
                "is_apply_to_all": is_apply_to_all,
                "ids_to_apply_price": deal_detail_ids,
                "update_status": '1'
            };
			
        adiha_post_data('return_array', data, '', '', 'deal_pricing_detail.callback_save', '');  
    }

    deal_pricing_detail.callback_save = function(result) {
		 if (result[0][0] == "Success") {     
                dhtmlx.message({
                    text:result[0][4],
                    expire:1000
                });

                if (result[0][5] != null) {
                    process_id = result[0][5];

                    if (close_window != 1) {
                        parent.dealDetail.grid.expandAll();
                        deal_provisional_price_data_process_id = process_id;                 
                        
                        var deal_detail_index = parent.dealDetail.grid.getColIndexById('source_deal_detail_id');
                        var detail_arr = get_columns_value(parent.dealDetail.grid, deal_detail_index);
                        
                        var key = search_array(detail_arr, source_deal_detail_id);

                        if (close_window == 0) {
                            source_deal_detail_id = detail_arr[key + 1];
                        } else if (close_window == 2) {
                            source_deal_detail_id = detail_arr[key - 1];
                        }

                        
                        deal_pricing_detail.layout.cells('d').detachObject(true);
                        deal_pricing_detail.load_data();
                    }                    
                }                
        } else {
            dhtmlx.message({
                title:"Error",
                type:"alert-error",
                text:result[0][4]
            });
        }

        deal_pricing_detail.tiered_combo('u');
        parent.deal_provisional_price_data_process_id = process_id;
		
    }

    function search_array(arr, val) {
        for (var i = 0; i < arr.length; i++)
            if (arr[i] === val)                    
                return i;

        return false;
    }

    /**
     * [filter_form_change Filter Change Events]
     * @param  {[type]} name  [itemname]
     * @param  {[type]} value [value]
     */
    deal_pricing_detail.filter_form_change = function(name, value, state) {
        if (name == 'filter') {
            var data = {
                "action":"spa_deal_pricing_provisional_filter",
                "flag":"t",
                "filter_id":value
            }
            adiha_post_data("return_array", data, '', '', 'deal_pricing_detail.filter_form_change_callback');
        }
    }

    /**
     * [filter_form_change_callback Filter Change callback]
     * @param  {[type]} result [data realted to filter]
     */
    deal_pricing_detail.filter_form_change_callback = function(result) {
        if (result.length == 0) return;

        form.setFormData(JSON.parse(result[0][0]));

        grid.clearAll();
        
        grid.parse(result[0][1],"json");

        deal_price_deemed = JSON.parse(result[0][2]);
        deal_std_event = JSON.parse(result[0][3]);
        deal_custom_event = JSON.parse(result[0][4]);
        deal_predefined_formula = JSON.parse(result[0][5]);
        deal_price_adjustment = JSON.parse(result[0][6]);

        
        if (grid.getRowsNum() > 0) {             
            grid.selectRow(0, true);
            //deal_pricing_detail.load_price_type(grid.getRowId(0), 0);
        }

    }

    /**
     * [filter_menu_click Filter Menu clicked events]
     * @param  {[type]} id [Menu item]
     */
    deal_pricing_detail.filter_menu_click = function(id) {
        switch (id) {
            case "save":
                var form_obj = deal_pricing_detail.filter_form.getCombo('filter');
                var filter_id = form_obj.getSelectedValue();         
                filter_id = (filter_id == null) ? "NULL" : filter_id;       
                var filter_name = (filter_id == "NULL") ? form_obj.getComboText() : form_obj.getSelectedText();

                if (filter_name == '') {
                    show_messagebox('Filter name cannot be empty.');
                    return;
                }

                var form_json = form.getFormData();
                //console.log(form_json);

                var grid_json = '{rows:[';
                var count = 0;

                grid.forEachRow(function(rid){
                    if (count > 0) grid_json += ',';

                    grid_json += '{id:' + rid + ', data:[';

                    for(var cellIndex = 0; cellIndex < grid.getColumnsNum(); cellIndex++){
                        var column_id = grid.getColumnId(cellIndex);
                        var cell_value = grid.cells(rid,cellIndex).getValue();
                        if (column_id == 'deal_price_type_id') cell_value = '';

                        if (cellIndex > 0) grid_json += ',';
                        grid_json += '"' + cell_value + '"';
                    }

                    grid_json += ']}';
                    count++;
                })

                grid_json += ']}';

                var selected_row = grid.getSelectedRowId();

                if (selected_row != '' && selected_row != null) {
                    deal_pricing_detail.save_grid_data('',selected_row,'');
                }

                Object.keys(deal_price_deemed).forEach(function(k){
                    console.log('bbb ' + deal_price_deemed[k]);
                    deal_price_deemed[k].deal_price_type_id = '';
                });
                Object.keys(deal_std_event).forEach(function(k){
                    deal_std_event[k].deal_price_type_id = '';
                });
                Object.keys(deal_custom_event).forEach(function(k){
                    deal_custom_event[k].deal_price_type_id = '';
                });
                Object.keys(deal_predefined_formula).forEach(function(k){
                    console.log('aaaa ' + deal_predefined_formula[k]);
                    deal_predefined_formula[k].deal_price_type_id = '';
                });
                Object.keys(deal_price_adjustment).forEach(function(k){
                    deal_price_adjustment[k].deal_price_type_id = '';
                });

                var deemed_form = JSON.stringify(deal_price_deemed);
                var std_form = JSON.stringify(deal_std_event);
                var custom_form = JSON.stringify(deal_custom_event); 
                var predefined_formula_form = JSON.stringify(deal_predefined_formula); 
                var price_adjustment = JSON.stringify(deal_price_adjustment); 

                data = {
                    "action": "spa_deal_pricing_provisional_filter",
                    "flag": 'i',
                    "filter_id": filter_id,
                    "filter_name": filter_name,
                    "form_json": JSON.stringify(form_json),
                    "grid_json": grid_json,
                    "deemed_form":deemed_form,
                    "std_form":std_form,
                    "custom_form":custom_form,
                    "predefined_formula_form":predefined_formula_form,
                    "price_adjustment" : price_adjustment
                };

                adiha_post_data("alert", data, '', '', 'deal_pricing_detail.filter_save_callback');
                break;
            case "delete":
                var form_obj = deal_pricing_detail.filter_form.getCombo('filter');
                var filter_id = form_obj.getSelectedValue();         

                if (filter_id == null) {
                    form_obj.setComboText('');
                } else {
                    data = {"action": "spa_deal_pricing_provisional_filter", "flag":'d', "filter_id":filter_id};
                    adiha_post_data("alert", data, '', '', 'deal_pricing_detail.filter_delete_callback');
                }

                break;
            case "copy":
                var form_obj = deal_pricing_detail.filter_form.getCombo('filter');
                var filter_id = form_obj.getSelectedValue();              
                
                data = {"action": "spa_deal_pricing_provisional_filter", "flag":'p', "filter_id":filter_id};
                adiha_post_data("alert", data, '', '', 'deal_pricing_detail.filter_copy_callback');

                break;
             case "filter_clear":
                var form_obj = deal_pricing_detail.filter_form.getCombo('filter');
                form_obj.unSelectOption();
                break;
        }
    }

    /**
     * [filter_save_callback Filter save callback]
     * @param  {[type]} result [returned data]
     */
    deal_pricing_detail.filter_save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var filter_combo = deal_pricing_detail.filter_form.getCombo('filter');
            var filter_id = filter_combo.getSelectedValue(); 

            if (filter_id == null) {
                filter_id =  result[0].recommendation;      
                var filter_name = filter_combo.getComboText();
                filter_combo.addOption(filter_id,filter_name);
                filter_combo.setComboValue(filter_id);
            }
        }
    }

    /**
     * [filter_delete_callback Filter Delete callback]
     * @param  {[type]} result [returned data]
     */
    deal_pricing_detail.filter_delete_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var filter_combo = deal_pricing_detail.filter_form.getCombo('filter');
            var filter_id = filter_combo.getSelectedValue();
            
            filter_id =  result[0].recommendation;
            filter_combo.setComboText('');
            filter_combo.deleteOption(filter_id);
        }
    }

    /**
     * [filter_copy_callback Filter Copy callback]
     * @param  {[type]} result [returned data]
     */
    deal_pricing_detail.filter_copy_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var id_string = result[0].recommendation;
            var id_array = id_string.split(':::');

            var filter_combo = deal_pricing_detail.filter_form.getCombo('filter');
            var filter_id = id_array[0]; 
            var filter_name = id_array[1]; 

            filter_combo.addOption(filter_id,filter_name);
            filter_combo.setComboValue(filter_id);     
        }
    }



    /*********** START OF QUALITY FILTER ******************************************/
    /**
     * [filter_form_change Filter Change Events]
     * @param  {[type]} name  [itemname]
     * @param  {[type]} value [value]
     */
    deal_pricing_detail.quality_filter_form_change = function(name, value, state) {
        if (name == 'filter') {
            var data = {
                "action":"spa_deal_pricing_quality_provisional_filter",
                "flag":"t",
                "filter_id":value
            }
            adiha_post_data("return_array", data, '', '', 'deal_pricing_detail.quality_filter_form_change_callback');
        }
    }

    /**
     * [filter_form_change_callback Filter Change callback]
     * @param  {[type]} result [data realted to filter]
     */
    deal_pricing_detail.quality_filter_form_change_callback = function(result) {
        if (result.length == 0) return;
    
        quality_grid.clearAll();        
        quality_grid.parse(result[0][0],"json");

    }

    /**
     * [filter_menu_click Filter Menu clicked events]
     * @param  {[type]} id [Menu item]
     */
    deal_pricing_detail.quality_filter_menu_click = function(id) {
        switch (id) {
            case "save":
                var form_obj = deal_pricing_detail.quality_filter_form.getCombo('filter');
                var filter_id = form_obj.getSelectedValue();   
    
                filter_id = (filter_id == null) ? "NULL" : filter_id;       
                var filter_name = (filter_id == "NULL") ? form_obj.getComboText() : form_obj.getSelectedText();

                if (filter_name == '') {
                    show_messagebox('Filter name cannot be empty.');
                    return;
                }

                var form_json = form.getFormData();
                //console.log(form_json);

                var grid_json = '{rows:[';
                var count = 0;

                quality_grid.forEachRow(function(rid){
                    if (count > 0) grid_json += ',';

                    grid_json += '{id:' + rid + ', data:[';

                    for(var cellIndex = 0; cellIndex < quality_grid.getColumnsNum(); cellIndex++){
                        var column_id = quality_grid.getColumnId(cellIndex);
                        var cell_value = quality_grid.cells(rid,cellIndex).getValue();
                        if (column_id == 'deal_price_quality_id') cell_value = '';

                        if (cellIndex > 0) grid_json += ',';
                        grid_json += '"' + cell_value + '"';
                    }

                    grid_json += ']}';
                    count++;
                })

                grid_json += ']}';

                var selected_row = quality_grid.getSelectedRowId();

                if (selected_row != '' && selected_row != null) {
                    deal_pricing_detail.save_grid_data('',selected_row,'');
                }

                data = {
                    "action": "spa_deal_pricing_quality_provisional_filter",
                    "flag": 'i',
                    "filter_id": filter_id,
                    "filter_name": filter_name,
                    "grid_json": grid_json
                };

                adiha_post_data("alert", data, '', '', 'deal_pricing_detail.quality_filter_save_callback');
                break;
            case "delete":
                var form_obj = deal_pricing_detail.quality_filter_form.getCombo('filter');
                var filter_id = form_obj.getSelectedValue();         

                if (filter_id == null) {
                    form_obj.setComboText('');
                } else {
                    data = {"action": "spa_deal_pricing_quality_provisional_filter", "flag":'d', "filter_id":filter_id};
                    adiha_post_data("alert", data, '', '', 'deal_pricing_detail.quality_filter_delete_callback');
                }

                break;
            case "copy":
                var form_obj = deal_pricing_detail.quality_filter_form.getCombo('filter');
                var filter_id = form_obj.getSelectedValue();              
                
                data = {"action": "spa_deal_pricing_quality_provisional_filter", "flag":'p', "filter_id":filter_id};
                adiha_post_data("alert", data, '', '', 'deal_pricing_detail.quality_filter_copy_callback');

                break;
             case "filter_clear":
                var form_obj = deal_pricing_detail.quality_filter_form.getCombo('filter');
                form_obj.unSelectOption();
                break;
        }
    }

    /**
     * [filter_save_callback Filter save callback]
     * @param  {[type]} result [returned data]
     */
    deal_pricing_detail.quality_filter_save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var filter_combo = deal_pricing_detail.quality_filter_form.getCombo('filter');
            var filter_id = filter_combo.getSelectedValue(); 

            if (filter_id == null) {
                filter_id =  result[0].recommendation;      
                var filter_name = filter_combo.getComboText();
                filter_combo.addOption(filter_id,filter_name);
                filter_combo.setComboValue(filter_id);
            }
        }
    }

    /**
     * [filter_delete_callback Filter Delete callback]
     * @param  {[type]} result [returned data]
     */
    deal_pricing_detail.quality_filter_delete_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var filter_combo = deal_pricing_detail.quality_filter_form.getCombo('filter');
            var filter_id = filter_combo.getSelectedValue();
            
            filter_id =  result[0].recommendation;
            filter_combo.setComboText('');
            filter_combo.deleteOption(filter_id);
        }
    }

    /**
     * [filter_copy_callback Filter Copy callback]
     * @param  {[type]} result [returned data]
     */
    deal_pricing_detail.quality_filter_copy_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var id_string = result[0].recommendation;
            var id_array = id_string.split(':::');

            var filter_combo = deal_pricing_detail.quality_filter_form.getCombo('filter');
            var filter_id = id_array[0]; 
            var filter_name = id_array[1]; 

            filter_combo.addOption(filter_id,filter_name);
            filter_combo.setComboValue(filter_id);     
        }
    }
    /*********** END OF QUALITY FILTER ******************************************/

</script>

<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }

/*.dhtmlx_message_area{
    left:500px;
    right:auto;
}*/

</style>

</html>
