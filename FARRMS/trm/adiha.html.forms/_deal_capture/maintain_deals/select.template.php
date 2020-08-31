<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_namespace = 'selectTemplate';

    $layout_obj = new AdihaLayout();
    $layout_json = '[{id: "a", header:false, height:50}, {id: "b", header:false}, {id: "c", header:false, height:50}]';
    echo $layout_obj->init_layout('layout', '', '3E', $layout_json, $form_namespace);

    $menu_json = '[
    				{id:"refresh", text:"Refresh", img:"refresh.gif", enabled:true, imgdis:"refresh_dis.gif", title: "Refresh"},    				
                    {id:"t2", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]},
    			]';

    $menu = new AdihaMenu();
    echo $layout_obj->attach_menu_cell('menu', 'b');
    echo $menu->init_by_attach('menu', $form_namespace);
    echo $menu->load_menu($menu_json);
    echo $menu->attach_event('', 'onClick', $form_namespace . '.menu_click');
    
    // attach grid
	echo $layout_obj->attach_grid_cell('select_template', 'b');
	echo $layout_obj->attach_status_bar("b", true);
	$grid_obj = new GridTable('select_template');
	echo $grid_obj->init_grid_table('select_template', $form_namespace, 'n');
    echo $grid_obj->set_column_auto_size();
    echo $grid_obj->set_search_filter(true);
	echo $grid_obj->enable_paging(50, 'pagingArea_b', 'true');
	echo $grid_obj->return_init('', 'true,false,false,false,false,false,true,true,true,true,true');
	echo $grid_obj->attach_event('', 'onTab', $form_namespace . '.grid_tab');
	echo $grid_obj->load_grid_data();
   	
   	$insert_form = new AdihaForm();
	$insert_form_name = 'insert_form';
	echo $layout_obj->attach_form($insert_form_name, 'c');
	$form_json = '[ 
				{"type": "settings", "position": "label-top", "offsetLeft": 10},
				{"type": "block", "blockOffset":0, "list": [
					{type: "button", name: "next", "offsetTop":20, value: "Next", width:"70", tooltip: "Next", className: "form-button1", disabled:false},
					{"type":"newcolumn"},
					{type: "button", name: "cancel", "offsetTop":20, value: "Cancel", width:"70", "offsetLeft":690, tooltip: "Cancel", className: "form-button2", disabled:false}
				]}
			]';

	$insert_form->init_by_attach($insert_form_name, $form_namespace);
	//echo $insert_form->attach_event('', 'onFocus', $form_namespace . '.form_focus');
	echo $insert_form->attach_event('', 'onButtonClick', $form_namespace . '.button_click');
	echo $insert_form->load_form($form_json);

    echo $layout_obj->close_layout();    
?>
<body>
<textarea style="display:none" name="success_template" id="success_template">-1</textarea>
<textarea style="display:none" name="deal_type_id" id="deal_type_id"></textarea>
<textarea style="display:none" name="pricing_type_id" id="pricing_type_id"></textarea>
<textarea style="display:none" name="template_name" id="template_name"></textarea>
<textarea style="display:none" name="commodity_id" id="commodity_id"></textarea>
<textarea style="display:none" name="term_type" id="term_type"></textarea>
<textarea style="display:none" name="selected_row" id="selected_row"></textarea>
</body>

<script type="text/javascript">
    $(function(){
        var item1 = $("div.dhxform_btn_txt");
        var item2 = $("div.dhxform_item_label_left.form-button1").find(item1);
        var item3 = $("div.dhxform_item_label_left.form-button2").find(item1);

        $(item2).addClass('btn btn-default btn-mini importantRule1');
        $(item2).removeClass('dhxform_btn_txt');

        $(item3).addClass('btn btn-default importantRule2');
        $(item3).removeClass('dhxform_btn_txt');

        filter_obj = selectTemplate.layout.cells('a').attachForm();
        var layout_cell_obj = selectTemplate.layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '10131010', 2);
    })

    selectTemplate.grid_tab = function(mode) {
    	var selected_row = selectTemplate.select_template.getSelectedRowId();
		if (selected_row == null) return;

		if (mode) {	
			if (window.event) window.event.preventDefault();
        	var form_obj = selectTemplate.insert_form;
			form_obj.setItemFocus('next');

			return false;
		} else {
			if (window.event) window.event.preventDefault();
			var filter_obj = selectTemplate.layout.cells('a').getAttachedObject();
			filter_obj.setItemFocus('apply_filters');
			return false;
		}
			
		return true;
    }

    selectTemplate.menu_click = function(id) {
    	switch(id) {
    		case 'refresh':
	    		var data = {
		            "action":"spa_deal_type_pricing_maping",
		            "flag":'y',
		            "grid_type":"g"
		        }   
	    		sql_param = $.param(data);

	    		var sql_url = js_data_collector_url + "&" + sql_param;
	    		selectTemplate.select_template.clearAll();
	        	selectTemplate.select_template.load(sql_url);
    			break;
    		case "pdf":
                selectTemplate.select_template.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                selectTemplate.select_template.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
        }
    }

    selectTemplate.button_click = function(id) {
        if (id == 'next') {
        	var selected_row = selectTemplate.select_template.getSelectedRowId();
			
			if (selected_row == null || selected_row == '') {
				show_messagebox('Please select a template mapping from grid.');
	            return;
			}

			var template_id_index = selectTemplate.select_template.getColIndexById('template_id');
			var deal_type_id_index = selectTemplate.select_template.getColIndexById('deal_type_id');
			var commodity_id_index = selectTemplate.select_template.getColIndexById('commodity_id');
			var pricing_type_id_index = selectTemplate.select_template.getColIndexById('pricing_type_id');
			var term_type_id_index = selectTemplate.select_template.getColIndexById('term_type_id');
			var template_name_index = selectTemplate.select_template.getColIndexById('template_name');


			var template_id = selectTemplate.select_template.cells(selected_row, template_id_index).getValue();
			var deal_type_id = selectTemplate.select_template.cells(selected_row, deal_type_id_index).getValue();
			var commodity_id = selectTemplate.select_template.cells(selected_row, commodity_id_index).getValue();
			var pricing_type_id = selectTemplate.select_template.cells(selected_row, pricing_type_id_index).getValue();
			var term_type_id = selectTemplate.select_template.cells(selected_row, term_type_id_index).getValue();
			var template_name = selectTemplate.select_template.cells(selected_row, template_name_index).getValue();

        	document.getElementById("success_template").value = template_id;
            document.getElementById("template_name").value = template_name;

            if (term_type_id != '')
                document.getElementById("term_type").value = term_type_id;

            if (deal_type_id != '' && deal_type_id != null)
                document.getElementById("deal_type_id").value = deal_type_id;

            if (pricing_type_id != '' && pricing_type_id != null)
                document.getElementById("pricing_type_id").value = pricing_type_id;

        	if (commodity_id != '' && commodity_id != null)
                document.getElementById("commodity_id").value = commodity_id;
        } 

        var win_obj = window.parent.blotter_window.window("w1");
        win_obj.close();        
    }    
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

    .importantRule1 {
        margin-left: 0px !important;
        padding-top: 6px;
        padding-right: 16px;
        padding-bottom: 6px;
        padding-left: 21px;
    }
    .importantRule1:focus {
    	border:2px solid black;
    	color: yellow !important;
    }
    .importantRule2 {
        margin-left: 0px !important;
        padding-top: 6px;
        padding-right: 16px;
        padding-bottom: 6px;
        padding-left: 18px;
    }
    .importantRule:focus {
        border:2px solid black;
    }
    
</style>