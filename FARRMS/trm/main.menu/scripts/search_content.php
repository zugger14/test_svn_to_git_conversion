<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
    
</html>
<style type="text/css">
        body{
                overflow: auto;
                background :url("../../main.menu/icons/thin-menu-background-transparent.png") repeat-x;
            }
        
        #search {
            position:fixed;
            margin-left: 50px; 
            margin-top : 25px;
            height:100%;
            width:100%;
            z-index: 201;
        }

        #modifySearch {
            display:none;
            position:fixed;
            height:100%;
            width: 170px;
            float: left;
            position: relative;
            z-index: 202;
        }

        #result {
            display:none;
            width: 350px;
            height:100%;
            top:25px;
            left:15px;
            float: left;
            position: relative;
            vertical-align: top;
            z-index: 202;
        }

        #resultData {
            font-family:verdana;
            font-size:14px; 
            color:#0547FE;
        }

        p.record {
            font-family:verdana;
            font-size:12px; 
            color:#000000;
            font-weight: 800;
            vertical-align: top;
            text-decoration: none;
            margin-top: 3px;
            margin-bottom: 0px;
            margin-left: 0px;
        }
        a.thick {
            font-family:verdana;
            font-size:12px; 
            color:#0033CC;
            font-weight: 800;
            vertical-align: top;
            text-decoration: underline;
            cursor: pointer;
        }
        a.link {
            font-family:verdana;
            font-size:12px; 
            color:#0033CC;
            font-weight: 800;
            vertical-align: top;
            font-style: italic;
            cursor: pointer;
            margin-left: 5px;
            text-decoration: underline;
        }


        a:visited {color: #0033cc;}

    </style>
<?php
  
require "../../adiha.php.scripts/components/include.file.v3.php";
$name_space = 'ns_search';
$form_name = 'frm_search';
$search_text = isset($_GET['search_text']) ? $_GET['search_text'] : '';
$layout_obj = new AdihaLayout();

$layout_json = '[
                        {
                            id:             "a",
                            header:         false,
                            collapse:       false,
                            height:         165,
                            fix_size:       [true, true]
                            
                        },
                        {
                            id:             "b",                           
                            header:         false,
                            collapse:       false,
                            height:         165,
                            fix_size:       [true, true]
                        },
                        {
                            id:             "c",
                            header:         false,
                            height:         220,
                            fix_size:       [false, null]
                        },
                        {
                            id:             "d",
                            header:         false
                        }
                    ]';

echo $layout_obj->init_layout('layout', '', '4F', $layout_json, $name_space);

$grid_name='grd_data';
echo $layout_obj->attach_grid_cell($grid_name, 'a');
$grid_data = new AdihaGrid();
echo $grid_data->init_by_attach($grid_name, $name_space);
echo $grid_data->set_header('Table Name,Data');
echo $grid_data->set_columns_ids('tableName,table_display_name');
echo $grid_data->set_widths('300,*');
echo $grid_data->set_column_visibility('true,false');
echo $grid_data->return_init();    
echo $grid_data->load_grid_data("EXEC spa_search_engine @flag='t'"); 
echo $grid_data->set_column_types('ro,ro');
echo $grid_data->enable_multi_select();      
echo $grid_data->load_grid_functions();
echo $grid_data->set_column_auto_size();
echo $grid_data->attach_event('', 'onRowSelect', 'grd_data_click');

$logical_operator_value = array('AND', 'OR');
$logical_operator_label = array('AND', 'OR');

$additional_columns_value = array('deal_date', 'counterparty', 'book', 'location', 'commodity', 'block_definition', 'broker', 'buy_sell', 'contract', 'deal_category', 'deal_status', 'deal_type', 'forecast_profile', 'deal_formula', 'generator', 'index_name', 'meter', 'parent_counterparty', 'physical_financial', 'deal_id', 'strategy', 'subsidiary', 'template', 'trader', 'entire_term_end', 'entire_term_start');
$additional_columns_label = array('Deal Date', 'Counterparty', 'Book', 'Location', 'Commodity', 'Block Definition', 'Broker', 'Buy/Sell', 'Contract', 'Deal Category', 'Deal Status', 'Deal Type', 'Forecast Profile', 'Formula', 'Generator', 'Index', 'Meter', 'Parent Counterparty', 'Physical/Financial', 'Reference ID', 'Strategy', 'Subsidiary', 'Template', 'Trader', 'Term End', 'Term Start');

$comparing_operator = array('=', '>', '<', '>=', '<=', '<>', 'IN', 'LIKE');

$form_object = new AdihaForm();
echo "cmb_logical_operator = ".  $form_object->create_static_combo_box($logical_operator_value, $logical_operator_label, '', 2) . ";"."\n";
echo "cmb_additional_columns = ".  $form_object->create_static_combo_box($additional_columns_value, $additional_columns_label, '', 27) . ";"."\n";
echo "cmb_comparing_operator = ".  $form_object->create_static_combo_box($comparing_operator, $comparing_operator, '', 8) . ";"."\n";

$general_form_structure = "[
    {type: 'label', name: 'additional_filters', label: 'Additional Filters:', position: 'absolute', labelWidth: 160},
    {type: 'button', name: 'btn_add_additional_filter', value: '+', position: 'absolute', inputTop: 25},    
    {type: 'combo', name: 'logical_operator', required: true, width: 120, position: 'absolute', inputLeft: 65, options: cmb_logical_operator, inputTop: 25},
    {type: 'combo', name: 'additional_columns', required: true, width: 120, position: 'absolute', inputLeft: 205, options: cmb_additional_columns, inputTop: 25},
    {type: 'combo', name: 'comparing_operator', required: true, width: 80, position: 'absolute', inputLeft: 345, options: cmb_comparing_operator, inputTop: 25},
    {type: 'input', name: 'text_additional_message', width: 150, position: 'absolute', inputLeft: 450, inputTop: 24},
        
    {type: 'combo', name: 'logical_operator_additional', required: true, width: 120, position: 'absolute', inputLeft: 65, inputTop: 70, options: cmb_logical_operator},
    {type: 'combo', name: 'additional_columns_additional', required: true, width: 120, position: 'absolute', inputLeft: 205, inputTop: 70, options: cmb_additional_columns},
    {type: 'combo', name: 'comparing_operator_additional', required: true, width: 80, position: 'absolute', inputLeft: 345, inputTop: 70, options: cmb_comparing_operator},
    {type: 'input', name: 'text_additional_message_additional', width: 150, position: 'absolute', inputLeft: 450, inputTop: 67},
    
    {type: 'combo', name: 'logical_operator_additional_1', required: true, width: 120, position: 'absolute', inputLeft: 65, inputTop: 117, options: cmb_logical_operator},
    {type: 'combo', name: 'additional_columns_additional_1', required: true, width: 120, position: 'absolute', inputLeft: 205, inputTop: 117, options: cmb_additional_columns},
    {type: 'combo', name: 'comparing_operator_additional_1', required: true, width: 80, position: 'absolute', inputLeft: 345, inputTop: 117, options: cmb_comparing_operator},
    {type: 'input', name: 'text_additional_message_additional_1', width: 150, position: 'absolute', inputLeft: 450, inputTop: 114},
    
    {type: 'combo', name: 'logical_operator_additional_2', required: true, width: 120, position: 'absolute', inputLeft: 65, inputTop: 164, options: cmb_logical_operator},
    {type: 'combo', name: 'additional_columns_additional_2', required: true, width: 120, position: 'absolute', inputLeft: 205, inputTop: 164, options: cmb_additional_columns},
    {type: 'combo', name: 'comparing_operator_additional_2', required: true, width: 80, position: 'absolute', inputLeft: 345, inputTop: 164, options: cmb_comparing_operator},
    {type: 'input', name: 'text_additional_message_additional_2', width: 150, position: 'absolute', inputLeft: 450, inputTop: 161},
    
    {type: 'combo', name: 'logical_operator_additional_3', required: true, width: 120, position: 'absolute', inputLeft: 65, inputTop: 211, options: cmb_logical_operator},
    {type: 'combo', name: 'additional_columns_additional_3', required: true, width: 120, position: 'absolute', inputLeft: 205, inputTop: 211, options: cmb_additional_columns},
    {type: 'combo', name: 'comparing_operator_additional_3', required: true, width: 80, position: 'absolute', inputLeft: 345, inputTop: 211, options: cmb_comparing_operator},
    {type: 'input', name: 'text_additional_message_additional_3', width: 150, position: 'absolute', inputLeft: 450, inputTop: 208},
       
    {type: 'input', name: 'txt_process_table', hidden: true},
    {type: 'input', name: 'txt_sws_table', hidden: true},
    
    {type: 'button', name: 'btn_ok', value: 'Search', position: 'absolute', inputTop: 185, className: 'search_cls'}
    ]";  
echo $layout_obj->attach_form($form_name, 'c');    
echo $form_object->init_by_attach($form_name, $name_space);
echo $form_object->load_form($general_form_structure);
echo $form_object->attach_event('', 'onButtonClick', 'btn_add_additional_filter_click', $name_space.'.'.$form_name);

echo "
init();
setTimeout('ns_search.grd_data.selectRow(2);', 20);
";

echo $layout_obj->close_layout()

?>    
<script type="text/javascript">
    $(function(){
        ns_search.frm_search.hideItem('logical_operator_additional');
        ns_search.frm_search.hideItem('additional_columns_additional');
        ns_search.frm_search.hideItem('comparing_operator_additional');
        ns_search.frm_search.hideItem('text_additional_message_additional');
        
        ns_search.frm_search.hideItem('logical_operator_additional_1');
        ns_search.frm_search.hideItem('additional_columns_additional_1');
        ns_search.frm_search.hideItem('comparing_operator_additional_1');
        ns_search.frm_search.hideItem('text_additional_message_additional_1');
        
        ns_search.frm_search.hideItem('logical_operator_additional_2');
        ns_search.frm_search.hideItem('additional_columns_additional_2');
        ns_search.frm_search.hideItem('comparing_operator_additional_2');
        ns_search.frm_search.hideItem('text_additional_message_additional_2');
        
        ns_search.frm_search.hideItem('logical_operator_additional_3');
        ns_search.frm_search.hideItem('additional_columns_additional_3');
        ns_search.frm_search.hideItem('comparing_operator_additional_3');
        ns_search.frm_search.hideItem('text_additional_message_additional_3');        
        
        ns_search.frm_search.attachEvent("onKeyUp",function(inp, ev, name, value){
            if (ev.keyCode == 13 && (name == 'text_additional_message' 
                || name == 'text_additional_message_additional'
                || name == 'text_additional_message_additional_1'
                || name == 'text_additional_message_additional_2'
                || name == 'text_additional_message_additional_3')) {
                
                
                if (click_count > 2) {
                    $('.search_cls .dhxform_btn').css('margin-top', '25px');
                }
                
                if (click_count > 3) {
                    $('.search_cls .dhxform_btn').css('margin-top', '65px');
                }
                
                btn_add_additional_filter_click('btn_ok');
            }
        }); 
    });
    
    function init() {        
        var search_by_word = '<?php echo $search_text; ?>';
        var table_name = 'master_deal_view';
        
        grd_data_click(table_name);
        
        var exec_call = "EXEC spa_search_engine 's',"
                        + singleQuote(search_by_word) + ",''"
                        + singleQuote(table_name) + "'',"
                        + "NULL,NULL, 's'";
        var sp_url = js_php_path + "dev/spa_xml.php?spa="
                    + escape(exec_call)
                    + "&session_id=" + js_session_id + "&" + getAppUserName();

        var xml_doc = load_xml_doc_from_string(http_get(sp_url));
        
        try {
            ns_search.layout.cells('d').attachHTMLString(convert_to_table(xml_doc));
        } catch (exception) {
            ns_search.layout.cells('d').attachHTMLString("<p class=record> No Matching Data.</p>");
        }
    }
    
    var click_count = 0;
    
    btn_add_additional_filter_click = function (args, table_name_refresh) {
        
        if (table_name_refresh == 'master_deal_view') {
            $('.search_cls .dhxform_btn').css('margin-top', '6px');
        } else if (table_name_refresh == 'undefined') {
            $('.search_cls .dhxform_btn').css('margin-top', '0px');
        }
                                
        switch(args) {
            case 'btn_add_additional_filter':    
                click_count++;
                
                if (click_count <= 4) {
                    if (click_count > 0) {                    
                        ns_search.frm_search.showItem('logical_operator_additional');
                        ns_search.frm_search.showItem('additional_columns_additional');
                        ns_search.frm_search.showItem('comparing_operator_additional');
                        ns_search.frm_search.showItem('text_additional_message_additional');
                    }
                    
                    if (click_count > 1) {
                        ns_search.frm_search.showItem('logical_operator_additional_1');
                        ns_search.frm_search.showItem('additional_columns_additional_1');
                        ns_search.frm_search.showItem('comparing_operator_additional_1');
                        ns_search.frm_search.showItem('text_additional_message_additional_1');
                    }
                    
                    if (click_count > 2) {
                        $('.search_cls .dhxform_btn').css('margin-top', '25px');
                        ns_search.frm_search.showItem('logical_operator_additional_2');
                        ns_search.frm_search.showItem('additional_columns_additional_2');
                        ns_search.frm_search.showItem('comparing_operator_additional_2');
                        ns_search.frm_search.showItem('text_additional_message_additional_2');
                    }
                    
                    if (click_count > 3) {
                        $('.search_cls .dhxform_btn').css('margin-top', '65px');
                        ns_search.frm_search.showItem('logical_operator_additional_3');
                        ns_search.frm_search.showItem('additional_columns_additional_3');
                        ns_search.frm_search.showItem('comparing_operator_additional_3');
                        ns_search.frm_search.showItem('text_additional_message_additional_3');
                    }
                } else {
                    show_messagebox('Only 5 Additional Fields can be added.');
                    $('.search_cls .dhxform_btn').css('margin-top', '65px');
                }
                break;
            case 'btn_ok':
                var search_by_word = '<?php echo $search_text; ?>';
                var table_name_row = ns_search.grd_data.getSelectedRowId();
                
                var logical_operator = ns_search.frm_search.getItemValue('logical_operator'); 
                var additional_column = ns_search.frm_search.getItemValue('additional_columns');
                var comparing_operator = ns_search.frm_search.getItemValue('comparing_operator');
                var additional_field = ns_search.frm_search.getItemValue('text_additional_message');
                
                
                additional_field = (additional_field != '') ? singleQuote(singleQuote(additional_field)) : additional_field;
                var filter_text = '';
                
                
                if (additional_field == '') {
                    filter_text = ''
                } else {
                   filter_text = ' ' + logical_operator + ' ' + additional_column + ' ' + comparing_operator + ' ' + additional_field;
                }
                
                var logical_operator_additional = ns_search.frm_search.getItemValue('logical_operator_additional'); 
                var additional_column_additional = ns_search.frm_search.getItemValue('additional_columns_additional');
                var comparing_operator_additional = ns_search.frm_search.getItemValue('comparing_operator_additional');
                var additional_field_additional = ns_search.frm_search.getItemValue('text_additional_message_additional');
                
                additional_field_additional = (additional_field_additional != '') ? singleQuote(singleQuote(additional_field_additional)) : additional_field_additional;
                                                
                if (additional_field_additional == '') {
                    filter_text = filter_text;
                } else {
                    filter_text = filter_text + ' ' + logical_operator_additional + ' ' + additional_column_additional + ' ' + comparing_operator_additional + ' ' + additional_field_additional;
                }
                
                var logical_operator_additional_1 = ns_search.frm_search.getItemValue('logical_operator_additional_1'); 
                var additional_column_additional_1 = ns_search.frm_search.getItemValue('additional_columns_additional_1');
                var comparing_operator_additional_1 = ns_search.frm_search.getItemValue('comparing_operator_additional_1');
                var additional_field_additional_1 = ns_search.frm_search.getItemValue('text_additional_message_additional_1');
                
                additional_field_additional_1 = (additional_field_additional_1 != '') ? singleQuote(singleQuote(additional_field_additional_1)) : additional_field_additional_1;
                                                
                if (additional_field_additional_1 == '') {
                    filter_text = filter_text;
                } else {
                    filter_text = filter_text + ' ' + logical_operator_additional_1 + ' ' + additional_column_additional_1 + ' ' + comparing_operator_additional_1 + ' ' + additional_field_additional_1;
                }
                
                var logical_operator_additional_2 = ns_search.frm_search.getItemValue('logical_operator_additional_2'); 
                var additional_column_additional_2 = ns_search.frm_search.getItemValue('additional_columns_additional_2');
                var comparing_operator_additional_2 = ns_search.frm_search.getItemValue('comparing_operator_additional_2');
                var additional_field_additional_2 = ns_search.frm_search.getItemValue('text_additional_message_additional_2');
                
                additional_field_additional_2 = (additional_field_additional_2 != '') ? singleQuote(singleQuote(additional_field_additional_2)) : additional_field_additional_2;
                                                
                if (additional_field_additional_2 == '') {
                    filter_text = filter_text;
                } else {
                    filter_text = filter_text + ' ' + logical_operator_additional_2 + ' ' + additional_column_additional_2 + ' ' + comparing_operator_additional_2 + ' ' + additional_field_additional_2;
                }
                
                var logical_operator_additional_3 = ns_search.frm_search.getItemValue('logical_operator_additional_3'); 
                var additional_column_additional_3 = ns_search.frm_search.getItemValue('additional_columns_additional_3');
                var comparing_operator_additional_3 = ns_search.frm_search.getItemValue('comparing_operator_additional_3');
                var additional_field_additional_3 = ns_search.frm_search.getItemValue('text_additional_message_additional_3');
                
                additional_field_additional_3 = (additional_field_additional_3 != '') ? singleQuote(singleQuote(additional_field_additional_3)) : additional_field_additional_3;
                                                
                if (additional_field_additional_3 == '') {
                    filter_text = filter_text;
                } else {
                    filter_text = filter_text + ' ' + logical_operator_additional_3 + ' ' + additional_column_additional_3 + ' ' + comparing_operator_additional_3 + ' ' + additional_field_additional_3;
                }
                
                if (ns_search.grd_field != 'undefined') {
                    var column_name_row = ns_search.grd_field.getSelectedRowId();
                    
                    if (column_name_row != null) { 
                        var selected_row_field_array = column_name_row.split(',');
                        var column_name = '';
                        
                        for(var i = 0; i < selected_row_field_array.length; i++) {
                            
                            if (i == 0) {
                                column_name = ns_search.grd_field.cells(selected_row_field_array[i], 0).getValue();
                            } else {
                                column_name = column_name + ',' + ns_search.grd_field.cells(selected_row_field_array[i], 0).getValue();
                            }
                        }
                    } else {
                        column_name = '';                 
                    }
                }
                
                if (table_name_refresh != 'master_deal_view') {
                    if (table_name_row != null) { 
                        var selected_row_array = table_name_row.split(',');
                        var table_name = '';
                        
                        for(var i = 0; i < selected_row_array.length; i++) {
                            
                            if (i == 0) {
                                table_name = ns_search.grd_data.cells(selected_row_array[i], 0).getValue();
                            } else {
                                table_name = table_name + ',' + ns_search.grd_data.cells(selected_row_array[i], 0).getValue();
                            }
                        }
                    } else {
                        table_name = '';                 
                    }
                } else {
                    table_name = table_name_refresh;
                } 
                               
                var table_array = unescape(table_name).split(',');
                
                if (table_array.length > 1 && table_name.indexOf('master_deal_view') != -1) {
                    show_messagebox('Multiple object selection is not allowed when Deal is selected.');
                    return;
                }
                
                if ((table_name != 'NULL') && (column_name != 'NULL')){
                    var exec_call = "EXEC spa_search_engine  's',"
                            + singleQuote(search_by_word) + ",''"
                            + singleQuote(table_name) + "'',"
                            + singleQuote(column_name) + ",NULL";
                } else if ((table_name != 'NULL') && (column_name == 'NULL')) {
                    var exec_call = "EXEC spa_search_engine 's',"
                            + singleQuote(search_by_word) + ",''"
                            + singleQuote(table_name) + "'',"
                            + "NULL,NULL";
                } else {
                    var exec_call = "EXEC spa_search_engine 's',"
                            + singleQuote(search_by_word)
                            + ',NULL,NULL,NULL';
                }
                
                exec_call = exec_call + ", 's', " + singleQuote(filter_text);
                
                var sp_url = js_php_path + "dev/spa_xml.php?spa="
                            + escape(exec_call)
                            + "&session_id=" + js_session_id + "&" + getAppUserName();
        
                var xml_doc = load_xml_doc_from_string(http_get(sp_url));
                
                try {
                    ns_search.layout.cells('d').attachHTMLString(convert_to_table(xml_doc));
                } catch (exception) {
                    ns_search.layout.cells('d').attachHTMLString("<p class=record> No Matching Data.</p>");
                }
            break;
        }
    }
    
    function grd_data_click(table_name) {
        var table_name_row = ns_search.grd_data.getSelectedRowId();
        
        $('.search_cls .dhxform_btn').css('margin-top', '0px');
        
        if (table_name != 'master_deal_view') {            
            if (table_name_row != null) { 
                var selected_row_array = table_name_row.split(',');
                
                for(var i = 0; i < selected_row_array.length; i++) {
                    
                    if (i == 0) {
                        table_name = ns_search.grd_data.cells(selected_row_array[i], 0).getValue();
                    } else {
                        table_name = table_name + ',' + ns_search.grd_data.cells(selected_row_array[i], 0).getValue();
                    }
                }
            } else {
                table_name = '';                 
            }
        } else {
            table_name = 'master_deal_view'
        }
        
        ns_search.frm_search.hideItem('logical_operator_additional');
        ns_search.frm_search.hideItem('additional_columns_additional');
        ns_search.frm_search.hideItem('comparing_operator_additional');
        ns_search.frm_search.hideItem('text_additional_message_additional');
        ns_search.frm_search.hideItem('logical_operator_additional_1');
        ns_search.frm_search.hideItem('additional_columns_additional_1');
        ns_search.frm_search.hideItem('comparing_operator_additional_1');
        ns_search.frm_search.hideItem('text_additional_message_additional_1');
        ns_search.frm_search.hideItem('logical_operator_additional_2');
        ns_search.frm_search.hideItem('additional_columns_additional_2');
        ns_search.frm_search.hideItem('comparing_operator_additional_2');
        ns_search.frm_search.hideItem('text_additional_message_additional_2');
        ns_search.frm_search.hideItem('logical_operator_additional_3');
        ns_search.frm_search.hideItem('additional_columns_additional_3');
        ns_search.frm_search.hideItem('comparing_operator_additional_3');
        ns_search.frm_search.hideItem('text_additional_message_additional_3');
        click_count = 0;
        
        
        if (table_name != 'master_deal_view') {
            ns_search.frm_search.load([{type: 'label', name: 'additional_filters_validation', label: 'Additional Filters are only applicable for Deal search.', position: 'absolute', labelWidth: 350, labelTop: 40, labelLeft: 150, hidden: true}]);
            ns_search.frm_search.hideItem('btn_add_additional_filter');
            ns_search.frm_search.hideItem('logical_operator');
            ns_search.frm_search.hideItem('additional_columns');
            ns_search.frm_search.hideItem('comparing_operator');
            ns_search.frm_search.hideItem('text_additional_message');
            ns_search.frm_search.showItem('additional_filters_validation');
            btn_add_additional_filter_click('btn_ok');            
        } else {
            ns_search.frm_search.showItem('btn_add_additional_filter');
            ns_search.frm_search.showItem('logical_operator');
            ns_search.frm_search.showItem('additional_columns');
            ns_search.frm_search.showItem('comparing_operator');
            ns_search.frm_search.showItem('text_additional_message');           
            ns_search.frm_search.hideItem('additional_filters_validation'); 
            setTimeout(function(){ btn_add_additional_filter_click('btn_ok', 'master_deal_view'); }, 1);            
        }
        
        
        
        ns_search.grd_field = ns_search.layout.cells('b').attachGrid();
        ns_search.grd_field.setImagePath(js_image_path + "dhxgrid_web/");
        ns_search.grd_field.setHeader('Column Name,Fields'); 
        ns_search.grd_field.setColumnIds("columnName,column_display_name");
        ns_search.grd_field.setInitWidths('300,*');
        ns_search.grd_field.setColumnsVisibility('true,false');
        ns_search.grd_field.enableHeaderMenu();
        ns_search.grd_field.setColTypes("ro,ro");
        ns_search.grd_field.init();
        
        var sp_url_param = {                    
            'flag':             'c',
            'searchString':     'NULL',
            'searchTables':     table_name,
            'searchOnSearch':   'NULL',
            'callFrom':         'NULL',
            'action':           'spa_search_engine'
        };

        sp_url_param  = $.param(sp_url_param );
        var sp_url = js_php_path + "data.collector.php?" + sp_url_param ;
        ns_search.grd_field.loadXML(sp_url);
        ns_search.grd_field.attachEvent("onRowSelect", grd_field_click);        
    }
    
    function grd_field_click() {
        btn_add_additional_filter_click('btn_ok');
    }
    
    function http_get(url) {
        var xml_http = null;
        xml_http = new XMLHttpRequest();
        xml_http.open("GET", url, false);
        xml_http.send(null);
        
        return xml_http.responseText;
    }
    
    function load_xml_doc_from_string(text) {
        try {
            parser = new DOMParser();
                xmlDoc = parser.parseFromString(text, "text/xml");
            
                return xmlDoc;
        } catch (e) {
        }
    }
    
    function convert_to_table(xmlDoc, call_from) {
            //..Google Chrome, Firefox and other browsers supports both the methods firstElementChild and firstChild but IE does not support firstElementChild
            var targetNode = xmlDoc.firstChild;
            var columnCount = targetNode.firstElementChild.childNodesClean().length;
            var rowCount = targetNode.childNodesClean().length;
            
            myTable = document.createElement("table");
            myTable.border = 0;
            myTable.borderColor = "black";
            myTable.style.textAlign = "left";
    
            //set process id for search
            var process_table_value = targetNode.firstElementChild.firstElementChild.firstChild.nodeValue;
            var process_table_obj = ns_search.frm_search.getForm('txt_process_table');
            process_table_obj.setItemValue('txt_process_table', process_table_value);
            
            var sws_table_value = targetNode.firstElementChild.childNodesClean()[5].firstChild.nodeValue;
            var sws_table_obj = ns_search.frm_search.getForm('txt_sws_table');
            sws_table_obj.setItemValue('txt_sws_table', sws_table_value);
            
            
            // fill the rows with data
            
            for (var i2 = 0; i2 < rowCount; i2++) {
    
                var newRow = myTable.insertRow();
    
                newRow.insertCell().innerHTML = " <a class=thick href=# onclick=link_click(" + "'" + targetNode.childNodesClean()[i2].childNodesClean()[2].firstChild.nodeValue + "'" + ")>"
                        + targetNode.childNodesClean()[i2].childNodesClean()[3].firstChild.nodeValue + "   ("
                        + targetNode.childNodesClean()[i2].childNodesClean()[1].firstChild.nodeValue + " Results Found.)";
    
                var newRow2 = myTable.insertRow();           
            }
    
            // send it as string instead of a table object
            return myTable.outerHTML;
    }
        
    function link_click(search_object) {
        var search_by_word = '<?php echo $search_text; ?>';
        var process_table = ns_search.frm_search.getItemValue('txt_process_table');
        var sws_table = ns_search.frm_search.getItemValue('txt_sws_table');
        var column_name = '';
        var table_name_row = ns_search.grd_data.getSelectedRowId();
        
        if (table_name_row != null) { 
            var selected_row_array = table_name_row.split(',');
            var table_name = '';
            
            for(var i = 0; i < selected_row_array.length; i++) {
                
                if (i == 0) {
                    table_name = ns_search.grd_data.cells(selected_row_array[i], 0).getValue();
                } else {
                    table_name = table_name + ',' + ns_search.grd_data.cells(selected_row_array[i], 0).getValue();
                }
            }
        } else {
            table_name = '';                 
        } 
        
        if (table_name == '')
            table_name = 'NULL';

        if (table_name == 'NULL') 
            table_name = 'master_deal_view';
        
        if (ns_search.grd_field != 'undefined') { 
            var column_name_row = ns_search.grd_field.getSelectedRowId();
            
            if (column_name_row != null) { 
                var selected_row_array = column_name_row.split(',');
                column_name = '';
                
                for(var i = 0; i < selected_row_array.length; i++) {
                    
                    if (i == 0) {
                        column_name = ns_search.grd_field.cells(selected_row_array[i], 0).getValue();
                    } else {
                        column_name = column_name + ',' + ns_search.grd_field.cells(selected_row_array[i], 0).getValue();
                    }
                }
            } else {
                column_name = '';                 
            }
        }
        
        var src = js_php_path + 'spa_search_result.php?&search_by_word=' + search_by_word + 
                                '&process_table=' + process_table + 
                                '&search_object=' + search_object + 
                                '&column_name=' + column_name + 
                                '&sws_table=' + sws_table +
                                '&table_name=' + table_name;
        
        window.parent.document.getElementById('txt_src').value = src; 
        window.parent.show_result();
    }
</script>