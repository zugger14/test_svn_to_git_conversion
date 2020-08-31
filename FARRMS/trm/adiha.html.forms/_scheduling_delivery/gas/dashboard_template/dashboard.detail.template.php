<?php
/**
* Dashboard detail template screen
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
</head>
    <?php 
        include '../../../../adiha.php.scripts/components/include.file.v3.php'; 
        $dashboard_template_id = get_sanitized_value($_GET['dashboard_template_id'] ?? '');
    ?>
	
    <style>
        #source_content {
            height: 545px;
            width: 150px;
            background-color: white;
            padding-top: 5px;
        }
        
        #source_content ul, #destination_content ul {
            list-style-type: none;
            padding: 0px;
            margin: 0px;
            font-size: 12px;
        }
        
        #source_content li {
            height: 25px;
            margin: 3px;
            padding: 5px 0 0 15px;
            background-color: #B4D6BB;
        }
        
        #source_content .checkoption {
            display:none;
        }
        
        #destination_content {
            height: 550px; 
            width: 580px;
            background-color: white;
            overflow-y: scroll;
        }
        
        #destination_content li {
            margin: 3px;
            padding: 3px;
        }
            
        #destination_content .checkoption {
            float:left;
        }
        
        #destination_content .drop_item {
            background-color: #B4D6BB;
            margin-left: 50px;
            vertical-align: middle;
            line-height: 20px;
        }
        
        #source_content li:hover, #destination_content li .forhover:hover{
            cursor: move;
        }
        
        .drop_item {
            height:25px;
         }
        
        .category_div {
            height: 27px;
            padding-left: 5px;
            padding-top: 3px;
            background-color: #94ACEB;
        }
        
        .category a, .forhover a{
            text-decoration: none;
            color: black;
        }
        
        .data_container_ul{
            min-height:25px;  
        }
        
        .subtotal {
            height:25px;
            margin-left: 25px!important;
            background-color:  #F0DD91!important;
        }
        
        .hidden_item {
            display:none;
        }
        
        #source_content input[type='text'] {
            display:none!important;
        }
        
        #source_content a {
            display:block!important;
        }
    </style>
    <script src="https://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
    <link type="text/css" href="<? echo $app_php_script_loc;?>components/ui/theme/jquery-ui-1.8.20.custom.css" rel="stylesheet" /> 
    
    <div class="component-container">
        <div id="source_content">
            <ul id="source_content_ul">
                <?php 
                $xml_file = 'EXEC spa_StaticDataValues @flag=s, @type_id=27300';
                $return_value1 = readXMLURL2($xml_file);
                
                foreach($return_value1 as $value) {
                    if($value['value_id'] != 27307) {
                    ?>
                        <li class="drop_item">
                            <div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>
                            <div class="hidden_item"><?php echo $value['value_id']; ?></div>
                            <div class="forhover">
                                <a href="javascript:void(0);" onclick="$(this).next('input[type=text]').show().val($(this).text()); $(this).hide()"> <?php echo $value['code']; ?> </a>
                                <input type="text" name="droptext" style="display:none; width:190px;" onblur="$(this).hide(); $(this).prev('a').text($(this).val()); $(this).prev('a').show()" />	   
                            </div>
                        </li>
                    <?php } else { 
                        $subtotal_data_type = $value['value_id'];
                        $subtotal_data_type_code = $value['code'];
                    }
                 } ?>
            </ul>
        </div> 
    </div> 
    <div class="component-container"> 
        <div id="destination_content">
            <ul id="destination_content_ul">
            </ul>
        </div> 
    </div>
    
    <script>
        var dashboard_template_id = '<?php echo $dashboard_template_id; ?>';
        refresh_destination_grid(dashboard_template_id);
        
        var options_window;
        /**
         * [unload_options_window Unload Options window.]
         */
        function unload_options_window() {        
            if (options_window != null && options_window.unload != null) {
                options_window.unload();
                options_window = w1 = null;
            }
        }
        
        function sort_item(){
            $("#destination_content ul").sortable();
        }
        
        $(document).ready(function(){
            $("#source_content li").draggable({
                cursor: 'move',
                connectToSortable: '.category ul',
                helper: 'clone',
            });
            sort_item();
        });
        
        function add_category() {
            var result = '';
            result += '<li class="category">' 
                        + '<div class="category_div"><a href="javascript:void(0);" onclick="$(this).next(\'input[type=text]\').show().val($(this).text()); $(this).text(\'\')">Category</a>'
                        + '<input type="text" name="droptext" style="display:none; width:190px;" onblur="$(this).hide(); $(this).prev(\'a\').text($(this).val());" >'
                        + '<input type="radio" name="rdo_template_datatype" value=""/></div>'
                        + '<ul class="data_container_ul">'
                        + '</ul>'
                        + '</li>';
            
            $("#destination_content_ul").append(result);
            sort_item(); 
        }
        
        function add_sub_total() {
            var selected_category =  $('input[name="rdo_template_datatype"]:checked').parent().parent().attr('class');
            
            if (selected_category != 'category') {
                var message = get_message('SELECT_CATEGORY');
                show_messagebox(message);
                return;
            }
            
            var subtotal_data_type = '<?php echo $subtotal_data_type; ?>';
            var subtotal_data_type_code = '<?php echo $subtotal_data_type_code; ?>';
            
            var result = ''
            result += '<li class="subtotal drop_item">';
            result += '<div class="checkoption"><input type="radio" name="rdo_template_datatype" value="0"/></div>';
            result += '<div class="hidden_item">' + subtotal_data_type + '</div>';
            result += '<div colspan = "2" class="forhover"><a href="javascript:void(0)" onclick="$(this).next(\'input[type=text]\').show().val($(this).text()); $(this).text(\'\')">' + subtotal_data_type_code + '</a>'
            result += '<input type="text" name="droptext" style="display:none; width:190px;" onblur="$(this).hide(); $(this).prev(\'a\').text($(this).val());" ></div>';
            result += '</li>';
            
            $('input[name="rdo_template_datatype"]:checked').parent().parent().find('ul').append(result);
        }
        
        function delete_selected_item() {
            $('input[name="rdo_template_datatype"]:checked').parent('div').parent('li').remove();
        }
        
        function btn_options_click() {
            var dashboard_template_detail_id = $('input[name="rdo_template_datatype"]:checked').val();
            var template_datatype =  $('input[name="rdo_template_datatype"]:checked').parent('div .checkoption').parent('li').find('.forhover').text();
            
            if(template_datatype == '') {
                var message = get_message('SELECT_DASHBOARD_DATATYPE');
                show_messagebox(message);
                return;
            }
            
            if(dashboard_template_detail_id == 0) {
                var message = get_message('DASHBOARD_NOT_SAVED');
                show_messagebox(message);
                return;
            }
            
            unload_options_window();
            if (!options_window) {
                options_window = new dhtmlXWindows();
            }
            
            var win = options_window.createWindow('w1', 0, 0, 375, 280);
            //win.attachViewportTo("workspace");
            win.setText("Options");
            win.centerOnScreen();
            win.setModal(true);
            win.attachURL('dashboard.template.detail.options.php?dashboard_template_detail_id=' + dashboard_template_detail_id, false, true);
        }
        
        function btn_filter_click() {
            var dashboard_template_detail_id = $('input[name="rdo_template_datatype"]:checked').val();
            var template_datatype =  $('input[name="rdo_template_datatype"]:checked').parent('div .checkoption').parent('li:not(.subtotal)').find('.hidden_item').text();
            
            if(template_datatype == '') {
                var message = get_message('SELECT_DASHBOARD_DATATYPE');
                show_messagebox(message);
                return;
            }
            
            if(dashboard_template_detail_id == 0) {
                var message = get_message('DASHBOARD_NOT_SAVED');
                show_messagebox(message);
                return;
            }
            
            if(template_datatype == '27305' || template_datatype == '27306') { //Filter is not applies in what-if and custom datatype
                var message = get_message('FILTER_NOT_APPLY');
                show_messagebox(message);
                return;
            }
            
            var return_array = new Array();
            return_array["dashboard_template_detail_id"] = dashboard_template_detail_id;
            return_array["template_datatype"] = template_datatype;
            return return_array;
        }
        
        function refresh_destination_grid(dashboard_template) {
            data = {"action": "spa_dashboard_template_detail",
                    "flag": "s",
                    "dashboard_template_id": dashboard_template
                };

            adiha_post_data('return_array', data, '', '', 'call_back_grid_click', '', '')
        }
            
        function call_back_grid_click(result_array) {
            var no_items = result_array.length;
            var first_category = 1;
            var result = '';
            
            for (var i = 0 ; i < no_items ; i++) {
                 var dashboard_template_detail_id = result_array[i][0];
                 var template_data_type = result_array[i][1];
                 var template_data_type_name = result_array[i][2];
                 var template_data_type_order = result_array[i][3];
                 
                 if(template_data_type_order == 0) {
                    if(first_category == 0) { result +='</ul></li>'; }
                    result += '<li class="category">'
                    result += '<div class="category_div"><a href="javascript:void(0);" onclick="$(this).next(\'input[type=text]\').show().val($(this).text()); $(this).text(\'\')">' + template_data_type_name + '</a>'
                    result += '<input type="text" name="droptext" style="display:none; width:190px;" onblur="$(this).hide(); $(this).prev(\'a\').text($(this).val());" >'
                    result += '<input type="radio" name="rdo_template_datatype" value=""/></div>'
                    result += '<ul class="data_container_ul">'
                    first_category = 0;
                 } 
                 else if (template_data_type == 27307) {
                    result += '<li class="drop_item subtotal">';
                    result += '<div class="checkoption"><input type="radio" name="rdo_template_datatype" value="' + dashboard_template_detail_id + '"/></div>';
                    result += '<div class="hidden_item">' + template_data_type + '</div>';
                    result += '<div colspan = "2" class="forhover"><a href="javascript:void(0)" onclick="$(this).next(\'input[type=text]\').show().val($(this).text()); $(this).text(\'\')">' + template_data_type_name + '</a>'
                    result += '<input type="text" name="droptext" style="display:none; width:190px;" onblur="$(this).hide(); $(this).prev(\'a\').text($(this).val());" ></div>';
                    result += '</li>';
                 } else {
                    result += '<li class="drop_item">';
                    result += '<div class="checkoption"><input type="radio" name="rdo_template_datatype" value="' + dashboard_template_detail_id + '"/></div>';
                    result += '<div class="hidden_item">' + template_data_type + '</div>';
                    result += '<div class="forhover">' 
                    result += '<a href="javascript:void(0);" onclick="$(this).next(\'input[type=text]\').show().val($(this).text()); $(this).text(\'\')">' + template_data_type_name + '</a>'
                    result += '<input type="text" name="droptext" style="display:none; width:190px;" onblur="$(this).hide(); $(this).prev(\'a\').text($(this).val());" >'
                    result += '</div>';
                    result += '</li>';
                 }
            }
            if (no_items > 0) { result += '</ul></li>'; }
            $("#destination_content_ul").html(result);
            sort_item(); 
        }
        
        function get_message(message_code) {
            switch (message_code) {
                case 'SELECT_DASHBOARD_DATATYPE':
                    return 'Please select dashboard datatype.';
                case 'DELETE_CONFIRM':
                    return 'Are you sure you want to delete the selected data?';
                case 'DELETE_SUCCESS':
                    return 'Data deleted successfully.';
                case 'DELETE_FAILED':
                    return 'Failed deleting data.';
                case 'UNCATEGORIZED_DATA':
                    return 'Please categorize the data.';
                case 'SAME_DATA_IN_CATEGORY':
                    return 'Please remove the repeated data in a category.';
                case 'EMPTY_DASHBOARD_NAME':
                    return 'Dashboard name is empty.';
                case 'EMPTY_DASHBOARD_DESC':
                    return 'Dashboard description is empty.';
                case 'DASHBOARD_NOT_SAVED':
                    return 'Please save the dashboard first.'; 
                case 'SELECT_CATEGORY':
                    return 'Please select the category'; 
                case 'SAVE_CONFIRM': 
                    return 'Please confirm to save it.';
                case 'DUBLICATE_CATEGORY': 
                    return 'Please remove the repeated category';  
                case 'EMPTY_CATEGORY_NAME': 
                    return 'category name is empty';  
                case 'EMPTY_DATA_TYPE_NAME': 
                    return 'Data type name is empty'; 
                case 'FILTER_NOT_APPLY': 
                    return 'Filter is not applied in this data type'; 
            }
        }
        
        function get_data_type_xml(dashboard_template_id) {
            var xml = '';
            $('#destination_content_ul li.category').each(function(category_index){
                var category = $(this).find('.category_div a').text();
                 
                $(this).find('ul li').each(function(datatype_index){
                    var datatype = $(this).find('.hidden_item').text();
                    var datatype_name = $(this).find('.forhover a').text();
                    var category_order = category_index + 1;
                    var datatype_order = datatype_index + 1;
                    
                    xml = xml + '<PSRecordset'
                            + ' dashboard_template_id="' + dashboard_template_id + '"'
                            + ' template_data_type="' + datatype + '"'
                            + ' category="' + category + '"'
                            + ' template_data_type_order="' + datatype_order + '"'
                            + ' category_order="' + category_order + '"'
                            + ' template_data_type_name="' + datatype_name + '"'
                            + '></PSRecordset>';
                });
            });
            return xml;
        }
    </script>